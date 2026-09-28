/**
 * Servidor principal - GraphQL con PostgreSQL
 * Empresa: TechDist S.A. - Sistema de Gestión Empresarial
 *
 * PostGraphile genera automáticamente el schema GraphQL
 * a partir de las tablas del schema "empresa" en PostgreSQL.
 *
 * Rutas:
 *   GET  /              → Info del servidor
 *   GET  /health        → Health check
 *   ANY  /graphql       → Endpoint GraphQL (API)
 *   GET  /graphiql      → Playground interactivo (solo desarrollo)
 */

require('dotenv').config();
const express     = require('express');
const cors        = require('cors');
const { postgraphile } = require('postgraphile');
const PgSimplifyInflectorPlugin = require('@graphile-contrib/pg-simplify-inflector');

const app  = express();
const PORT = process.env.PORT || 4000;
const ENV  = process.env.NODE_ENV || 'development';

// ─── Cadena de conexión a PostgreSQL ─────────────────────────────────────────
// Aiven requiere SSL — se incluye sslmode=require en la URL
const DATABASE_URL = process.env.DATABASE_URL ||
  `postgres://${process.env.DB_USER || 'postgres'}:${process.env.DB_PASSWORD || 'postgres'}@${process.env.DB_HOST || 'localhost'}:${process.env.DB_PORT || 5432}/${process.env.DB_NAME || 'techdist'}`;

// Opciones de conexión para PostGraphile (SSL para Aiven)
const pgConfig = process.env.DATABASE_URL
  ? {
      connectionString: DATABASE_URL,
      ssl: { rejectUnauthorized: false },
    }
  : DATABASE_URL;

// ─── Middlewares globales ─────────────────────────────────────────────────────
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  methods: ['GET', 'POST', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

app.use(express.json());

// ─── Ruta de información ──────────────────────────────────────────────────────
app.get('/', (req, res) => {
  res.json({
    proyecto:    'GraphQL con PostgreSQL - TechDist S.A.',
    version:     '1.0.0',
    descripcion: 'API GraphQL generada automáticamente con PostGraphile',
    endpoints: {
      graphql:   `http://localhost:${PORT}/graphql`,
      graphiql:  `http://localhost:${PORT}/graphiql`,
      health:    `http://localhost:${PORT}/health`,
    },
    schema:  'empresa',
    tablas:  ['departamentos', 'empleados', 'categorias_productos', 'productos', 'clientes', 'pedidos', 'detalle_pedidos'],
    entorno: ENV,
  });
});

// ─── Health check ─────────────────────────────────────────────────────────────
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// ─── PostGraphile middleware ──────────────────────────────────────────────────
// PostGraphile inspecciona el schema de PostgreSQL y genera:
//   • Queries  → para leer datos (allEmpleados, empleadoById, etc.)
//   • Mutations → para crear/actualizar/eliminar (createEmpleado, etc.)
//   • Subscriptions → para cambios en tiempo real (con --subscriptions)
app.use(
  postgraphile(pgConfig, 'empresa', {
    // ── Plugins ──────────────────────────────────────────────────────────────
    appendPlugins: [PgSimplifyInflectorPlugin],

    // ── Interfaz gráfica (solo en desarrollo) ─────────────────────────────
    graphiql:            ENV === 'development',
    enhanceGraphiql:     ENV === 'development',

    // ── Esquema ───────────────────────────────────────────────────────────
    watchPg:             false,                 // desactivado en Aiven (requiere permisos de superusuario)
    dynamicJson:         true,                  // soporta JSON nativo de PostgreSQL
    setofFunctionsContainNulls: false,
    ignoreRBAC:          false,                 // respetar permisos de PostgreSQL

    // ── Rendimiento ───────────────────────────────────────────────────────
    enableQueryBatching: true,                  // múltiples queries en una solicitud
    legacyRelations:     'omit',                // no duplicar relaciones

    // ── Errores (más detalle en desarrollo) ───────────────────────────────
    extendedErrors:      ENV === 'development'
      ? ['hint', 'detail', 'errcode']
      : [],
    showErrorStack:      ENV === 'development',

    // ── Seguridad ─────────────────────────────────────────────────────────
    // En producción agregar: jwtSecret, jwtPgTypeIdentifier
    // para autenticación basada en JWT y roles de PostgreSQL

    // ── Exportar schema ───────────────────────────────────────────────────
    exportGqlSchemaPath: ENV === 'development'
      ? './docs/schema.graphql'
      : undefined,

    // ── Opciones adicionales ───────────────────────────────────────────────
    graphqlRoute:    '/graphql',
    graphiqlRoute:   '/graphiql',
    bodySizeLimit:   '1MB',
  })
);

// ─── Manejo de errores 404 ────────────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({
    error:   'Ruta no encontrada',
    rutas_disponibles: ['/graphql', '/graphiql', '/health'],
  });
});

// ─── Manejo de errores globales ───────────────────────────────────────────────
app.use((err, req, res, _next) => {
  console.error('Error del servidor:', err.message);
  res.status(500).json({ error: 'Error interno del servidor' });
});

// ─── Inicio del servidor ──────────────────────────────────────────────────────
app.listen(PORT, () => {
  console.log('');
  console.log('╔══════════════════════════════════════════════════════════╗');
  console.log('║     GraphQL con PostgreSQL — TechDist S.A.              ║');
  console.log('╠══════════════════════════════════════════════════════════╣');
  console.log(`║  Entorno   : ${ENV.padEnd(44)}║`);
  console.log(`║  Puerto    : ${String(PORT).padEnd(44)}║`);
  console.log(`║  GraphQL   : http://localhost:${PORT}/graphql${''.padEnd(44 - String(PORT).length - 9)}║`);
  console.log(`║  GraphiQL  : http://localhost:${PORT}/graphiql${''.padEnd(44 - String(PORT).length - 10)}║`);
  console.log('╚══════════════════════════════════════════════════════════╝');
  console.log('');
  console.log('  Schema PostgreSQL: empresa');
  console.log('  Tablas expuestas : departamentos, empleados, productos,');
  console.log('                     clientes, pedidos, detalle_pedidos');
  console.log('');
  if (ENV === 'development') {
    console.log('  💡 Abre GraphiQL en tu navegador para explorar la API:');
    console.log(`     http://localhost:${PORT}/graphiql`);
    console.log('');
  }
});

module.exports = app;
