/**
 * Script de inicialización de la base de datos
 * Ejecuta el schema SQL y los datos de prueba
 *
 * Uso: node src/database/init.js
 */

require('dotenv').config();
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

// ─── Configuración de conexión ────────────────────────────────────────────────
// Si existe DATABASE_URL (Aiven, Neon, etc.) la usa directamente
// Si no, arma la conexión con variables individuales
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

// ─── Función principal ────────────────────────────────────────────────────────
async function initDatabase() {
  const client = await pool.connect();

  try {
    console.log('🔌 Conectando a PostgreSQL...');
    await client.query('SELECT 1'); // Verificar conexión
    console.log('✅ Conexión exitosa.\n');

    // Leer y ejecutar schema
    console.log('📋 Ejecutando schema (tablas, índices, vistas)...');
    const schemaPath = path.join(__dirname, '..', '..', 'sql', '01_schema.sql');
    const schemaSql  = fs.readFileSync(schemaPath, 'utf8');
    await client.query(schemaSql);
    console.log('✅ Schema creado correctamente.\n');

    // Leer y ejecutar datos de prueba
    console.log('🌱 Insertando datos de prueba (seed)...');
    const seedPath = path.join(__dirname, '..', '..', 'sql', '02_seed.sql');
    const seedSql  = fs.readFileSync(seedPath, 'utf8');
    const result   = await client.query(seedSql);

    // Mostrar conteo de registros insertados
    const conteo = result[result.length - 1]?.rows;
    if (conteo) {
      console.log('\n📊 Registros insertados:');
      conteo.forEach(({ tabla, registros }) => {
        console.log(`   ${tabla.padEnd(20)} → ${registros} registros`);
      });
    }

    console.log('\n🎉 Base de datos inicializada correctamente.');
    console.log('   Puedes iniciar el servidor con: npm start\n');

  } catch (err) {
    console.error('\n❌ Error al inicializar la base de datos:');
    console.error('   ', err.message);
    console.error('\n💡 Verifica que:');
    console.error('   1. PostgreSQL esté corriendo');
    console.error('   2. Las credenciales en .env sean correctas');
    console.error('   3. La base de datos "' + (process.env.DB_NAME || 'techdist') + '" exista');
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
  }
}

initDatabase();
