/**
 * Script para reinsertar solo los datos de prueba (sin recrear tablas)
 * Útil para resetear datos en desarrollo sin borrar la estructura
 *
 * Uso: node src/database/seed.js
 */

require('dotenv').config();
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

const pool = process.env.DATABASE_URL
  ? new Pool({
      connectionString: process.env.DATABASE_URL,
      ssl: {
        rejectUnauthorized: false,  // necesario para certificados de Aiven
      },
    })
  : new Pool({
      host:     process.env.DB_HOST     || 'localhost',
      port:     parseInt(process.env.DB_PORT || '5432'),
      database: process.env.DB_NAME     || 'techdist',
      user:     process.env.DB_USER     || 'postgres',
      password: process.env.DB_PASSWORD || 'postgres',
    });

async function runSeed() {
  const client = await pool.connect();

  try {
    console.log('🔌 Conectando a PostgreSQL...');
    await client.query('SELECT 1');
    console.log('✅ Conexión exitosa.\n');

    // Limpiar datos existentes (respeta el orden de las FK)
    console.log('🧹 Limpiando datos anteriores...');
    await client.query(`
      TRUNCATE TABLE
        empresa.detalle_pedidos,
        empresa.pedidos,
        empresa.clientes,
        empresa.productos,
        empresa.categorias_productos,
        empresa.empleados,
        empresa.departamentos
      RESTART IDENTITY CASCADE;
    `);
    console.log('✅ Datos anteriores eliminados.\n');

    // Insertar datos frescos
    console.log('🌱 Insertando datos de prueba...');
    const seedPath = path.join(__dirname, '..', '..', 'sql', '02_seed.sql');
    const seedSql  = fs.readFileSync(seedPath, 'utf8');
    const result   = await client.query(seedSql);

    const conteo = result[result.length - 1]?.rows;
    if (conteo) {
      console.log('\n📊 Registros actuales:');
      conteo.forEach(({ tabla, registros }) => {
        console.log(`   ${tabla.padEnd(20)} → ${registros} registros`);
      });
    }

    console.log('\n🎉 Seed completado exitosamente.\n');

  } catch (err) {
    console.error('\n❌ Error al ejecutar seed:', err.message);
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
  }
}

runSeed();
