# GraphQL con PostgreSQL — TechDist S.A.

Sistema de Gestión Empresarial construido con **PostGraphile**, **Node.js** y **PostgreSQL**.  
PostGraphile genera automáticamente un schema GraphQL completo a partir de las tablas de la base de datos.

---

## ¿Qué es GraphQL?

GraphQL es un lenguaje de consulta para APIs desarrollado por Meta (Facebook). A diferencia de REST, con GraphQL:

| REST | GraphQL |
|------|---------|
| Múltiples endpoints (`/clientes`, `/pedidos`, `/productos`) | Un solo endpoint `/graphql` |
| El servidor decide qué datos devuelve | El **cliente** decide exactamente qué campos necesita |
| Overfetching (datos de más) o Underfetching (datos de menos) | Respuesta exacta, sin datos innecesarios |
| Requiere documentación manual (Swagger) | Schema auto-documentado e introspectable |

---

## Arquitectura del proyecto

```
GraphQL con PostgreSQL/
│
├── src/
│   ├── index.js                  ← Servidor Express + PostGraphile
│   └── database/
│       ├── init.js               ← Ejecuta schema + datos de prueba
│       └── seed.js               ← Solo recarga los datos
│
├── sql/
│   ├── 01_schema.sql             ← Tablas, índices, triggers, vistas
│   └── 02_seed.sql               ← Datos de prueba (empresa TechDist)
│
├── ejemplos/
│   ├── 01_queries_basicas.graphql
│   ├── 02_queries_avanzadas.graphql
│   ├── 03_mutations_crud.graphql
│   ├── 04_casos_empresariales.graphql
│   └── 05_cliente_nodejs.js
│
├── docs/
│   └── schema.graphql            ← Generado automáticamente al iniciar
│
├── .env                          ← Variables de entorno (credenciales)
├── .env.example                  ← Plantilla de configuración
├── .gitignore
└── package.json
```

---

## Modelo de datos

El schema `empresa` contiene las siguientes tablas:

```
departamentos
    │
    └── empleados ──────────────────────────┐
                                            │
categorias_productos                        │
    │                                       │
    └── productos                           │
            │                              │
            └── detalle_pedidos ── pedidos ─┘
                                      │
                                   clientes
```

### Tablas

| Tabla | Descripción | Campos clave |
|-------|-------------|--------------|
| `departamentos` | Áreas internas de la empresa | nombre, presupuesto |
| `empleados` | Personal de la empresa | nombre, cargo, salario, departamento_id |
| `categorias_productos` | Clasificación del catálogo | nombre |
| `productos` | Catálogo con precio y stock | codigo, precio, stock, stock_minimo |
| `clientes` | Compradores registrados | nombre, empresa, email |
| `pedidos` | Órdenes de venta | numero_pedido, estado, total |
| `detalle_pedidos` | Líneas de cada pedido | cantidad, precio_unitario, descuento, subtotal |

### Vistas incluidas

- **`vista_pedidos_completos`** — Pedidos con datos del cliente y vendedor
- **`vista_productos_bajo_stock`** — Productos que necesitan reabastecimiento

---

## Requisitos previos

Antes de comenzar necesitas tener instalado:

- [Node.js](https://nodejs.org/) v18 o superior
- [PostgreSQL](https://www.postgresql.org/) v14 o superior
- npm (incluido con Node.js)

Verificar instalaciones:
```bash
node --version    # v18.x.x o superior
npm --version     # 9.x.x o superior
psql --version    # PostgreSQL 14.x o superior
```

---

## Instalación paso a paso

### 1. Crear la base de datos en PostgreSQL

Abre tu terminal y conéctate a PostgreSQL:

```bash
psql -U postgres
```

Dentro de psql, ejecuta:

```sql
CREATE DATABASE techdist;
\q
```

### 2. Instalar dependencias de Node.js

En la carpeta del proyecto:

```bash
npm install
```

Esto instala: `express`, `postgraphile`, `pg`, `dotenv`, `cors`,  
`@graphile-contrib/pg-simplify-inflector` y `nodemon`.

### 3. Configurar variables de entorno

El archivo `.env` ya está creado con valores por defecto.  
Si tu PostgreSQL usa un password diferente, edita `.env`:

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=techdist
DB_USER=postgres
DB_PASSWORD=TU_PASSWORD_AQUI
PORT=4000
```

### 4. Inicializar la base de datos

Este comando crea todas las tablas, índices, triggers, vistas  
e inserta los datos de prueba de la empresa TechDist S.A.:

```bash
npm run db:init
```

Salida esperada:
```
🔌 Conectando a PostgreSQL...
✅ Conexión exitosa.

📋 Ejecutando schema (tablas, índices, vistas)...
✅ Schema creado correctamente.

🌱 Insertando datos de prueba (seed)...

📊 Registros insertados:
   departamentos        → 5 registros
   empleados            → 10 registros
   categorias           → 5 registros
   productos            → 16 registros
   clientes             → 8 registros
   pedidos              → 5 registros
   detalle_pedidos      → 18 registros

🎉 Base de datos inicializada correctamente.
```

### 5. Iniciar el servidor

```bash
npm start
```

O en modo desarrollo (recarga automática):

```bash
npm run dev
```

Salida esperada:
```
╔══════════════════════════════════════════════════════════╗
║     GraphQL con PostgreSQL — TechDist S.A.              ║
╠══════════════════════════════════════════════════════════╣
║  Entorno   : development                                ║
║  Puerto    : 4000                                       ║
║  GraphQL   : http://localhost:4000/graphql              ║
║  GraphiQL  : http://localhost:4000/graphiql             ║
╚══════════════════════════════════════════════════════════╝
```

---

## Uso de la API

### GraphiQL — Playground interactivo

Abre en tu navegador: **http://localhost:4000/graphiql**

GraphiQL es un IDE visual donde puedes:
- Escribir y ejecutar queries y mutations
- Ver el schema completo con documentación
- Autocompletar campos al escribir
- Ver errores en tiempo real

### Endpoint GraphQL (para aplicaciones)

```
POST http://localhost:4000/graphql
Content-Type: application/json
```

---

## Ejemplos de Queries y Mutations

### Query básica — Listar empleados

```graphql
query {
  empleados(orderBy: APELLIDO_ASC) {
    totalCount
    nodes {
      id
      nombre
      apellido
      cargo
      salario
      departamento {
        nombre
      }
    }
  }
}
```

### Query con filtro — Productos activos

```graphql
query {
  productos(
    condition: { activo: true }
    orderBy: PRECIO_ASC
  ) {
    totalCount
    nodes {
      codigo
      nombre
      precio
      stock
    }
  }
}
```

### Query con relaciones — Pedido completo

```graphql
query {
  pedido(id: 1) {
    numeroPedido
    estado
    total
    cliente {
      nombre
      empresa
    }
    detallePedidos {
      nodes {
        cantidad
        subtotal
        producto {
          nombre
          codigo
        }
      }
    }
  }
}
```

### Mutation — Crear un nuevo empleado

```graphql
mutation {
  createEmpleado(input: {
    empleado: {
      nombre:         "Andrea"
      apellido:       "Vargas"
      email:          "andrea@techdist.com"
      cargo:          "Analista de Datos"
      salario:        "3200"
      departamentoId: 3
    }
  }) {
    empleado {
      id
      nombre
      apellido
      cargo
    }
  }
}
```

### Mutation — Actualizar estado de un pedido

```graphql
mutation {
  updatePedidoById(input: {
    id: 5
    pedidoPatch: { estado: "confirmado" }
  }) {
    pedido {
      numeroPedido
      estado
      total
    }
  }
}
```

---

## Casos de uso empresariales

Los ejemplos en `ejemplos/04_casos_empresariales.graphql` cubren:

| # | Caso | Área | Descripción |
|---|------|------|-------------|
| 1 | **Dashboard Gerencial** | Dirección | Métricas clave en una sola query |
| 2 | **CRM — Perfil de Cliente** | Ventas | Historial completo de un cliente |
| 3 | **Reporte de Inventario** | Almacén | Stock actual y alertas de reabastecimiento |
| 4 | **Flujo de Ventas** | Ventas | Cotización → Pedido → Entrega (mutations) |
| 5 | **Reporte de Nómina** | RRHH / Finanzas | Costo de personal por departamento |
| 6 | **E-commerce** | Tienda Online | Búsqueda avanzada con múltiples filtros |
| 7 | **Variables dinámicas** | Frontend | Queries parametrizadas desde la app |

### Comparativa GraphQL vs REST para el Dashboard Gerencial

**Con REST necesitarías 4 llamadas HTTP:**
```
GET /api/clientes?activo=true&count=true
GET /api/productos?activo=true&count=true
GET /api/pedidos?estado=pendiente&count=true
GET /api/pedidos?limit=5&order=fecha_desc
GET /api/inventario/bajo-stock
```

**Con GraphQL: una sola llamada trae todo:**
```graphql
query DashboardGerencial {
  totalClientes: clientes(condition: { activo: true }) { totalCount }
  totalProductos: productos(condition: { activo: true }) { totalCount }
  pedidosPendientes: pedidos(condition: { estado: "pendiente" }) { totalCount }
  ultimosPedidos: pedidos(first: 5, orderBy: FECHA_PEDIDO_DESC) { nodes { numeroPedido estado total } }
  alertasStock: vistaProductosBajoStocks { nodes { nombre stock diferencia } }
}
```

---

## Comandos disponibles

```bash
npm start          # Inicia el servidor en producción
npm run dev        # Inicia con nodemon (recarga automática en desarrollo)
npm run db:init    # Crea las tablas e inserta datos de prueba
npm run db:seed    # Solo recarga los datos (sin recrear tablas)
```

---

## Estructura de la API GraphQL generada

PostGraphile genera automáticamente estos tipos de operaciones:

### Queries (lectura)
- `empleados` — Lista todos con filtros, orden y paginación
- `empleado(id)` — Busca uno por ID
- `productos`, `producto(id)` — Para productos
- `pedidos`, `pedido(id)` — Para pedidos
- `clientes`, `cliente(id)` — Para clientes
- *(y así para cada tabla)*

### Mutations (escritura)
- `createEmpleado` — Inserta un nuevo registro
- `updateEmpleadoById` — Actualiza por ID
- `deleteEmpleadoById` — Elimina por ID
- *(y así para cada tabla)*

### Filtros disponibles en `condition:`
- `condition: { activo: true }` — igualdad exacta
- Para rangos y búsquedas de texto usa `filter:` con operadores avanzados

### Ordenamiento con `orderBy:`
- `NOMBRE_ASC`, `NOMBRE_DESC`
- `PRECIO_ASC`, `PRECIO_DESC`
- `FECHA_PEDIDO_ASC`, `FECHA_PEDIDO_DESC`
- *(un campo ASC/DESC por cada columna)*

### Paginación
```graphql
productos(first: 10, offset: 0) {
  totalCount
  pageInfo { hasNextPage hasPreviousPage }
  nodes { ... }
}
```

---

## Tecnologías utilizadas

| Tecnología | Versión | Rol |
|-----------|---------|-----|
| [Node.js](https://nodejs.org/) | v18+ | Entorno de ejecución |
| [Express](https://expressjs.com/) | v4.18 | Servidor HTTP |
| [PostGraphile](https://www.graphile.org/postgraphile/) | v4.14 | Generador automático de GraphQL |
| [PostgreSQL](https://www.postgresql.org/) | v14+ | Base de datos |
| [pg](https://node-postgres.com/) | v8.11 | Driver PostgreSQL para Node.js |
| [dotenv](https://github.com/motdotla/dotenv) | v16 | Variables de entorno |
| [cors](https://github.com/expressjs/cors) | v2.8 | Control de acceso cross-origin |

---

## Solución de problemas frecuentes

**Error: ECONNREFUSED — No puede conectar a PostgreSQL**
```
Verifica que PostgreSQL esté corriendo:
  Windows: net start postgresql-x64-14
  Verifica el puerto y credenciales en .env
```

**Error: database "techdist" does not exist**
```sql
-- En psql ejecuta:
CREATE DATABASE techdist;
```

**Error: schema "empresa" does not exist**
```
Ejecuta primero: npm run db:init
```

**Puerto 4000 ya está en uso**
```
Cambia el puerto en .env: PORT=4001
```

---

## Errores reales encontrados en Windows (y cómo resolverlos)

Estos son problemas que ocurren en una instalación típica de Windows y que
no están documentados en la mayoría de tutoriales.

---

### 1. `psql` no se reconoce como comando

**Error:**
```
psql : El término 'psql' no se reconoce como nombre de un cmdlet...
```

**Causa:** PostgreSQL está instalado pero su carpeta `bin` no está en el PATH de Windows.

**Solución A — Agregar al PATH (permanente):**
```powershell
# Primero verifica qué versión tienes instalada
Get-ChildItem "C:\Program Files\PostgreSQL"

# Agrega al PATH (cambia 16 por tu versión)
[Environment]::SetEnvironmentVariable(
  "PATH",
  [Environment]::GetEnvironmentVariable("PATH","User") + ";C:\Program Files\PostgreSQL\16\bin",
  "User"
)
# Cierra y vuelve a abrir PowerShell
```

**Solución B — Usar la ruta completa sin modificar PATH:**
```powershell
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -c "CREATE DATABASE techdist;"
```

**Solución C — Usar pgAdmin (interfaz gráfica):**
1. Abre pgAdmin 4 desde el menú Inicio
2. Clic derecho en **Databases** → **Create** → **Database**
3. Escribe `techdist` y guarda
4. Abre **Query Tool** y ejecuta `sql/01_schema.sql` y `sql/02_seed.sql`

---

### 2. `npm` bloqueado por política de ejecución de PowerShell

**Error:**
```
npm : El archivo C:\Program Files\nodejs\npm.ps1 no está firmado digitalmente.
No se puede ejecutar este script en el sistema actual.
```

**Causa:** PowerShell en Windows tiene por defecto la política `Restricted` que bloquea
la ejecución de scripts `.ps1`, incluyendo el script de `npm`.

**Solución:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# Escribe S y Enter para confirmar
```

Esto solo afecta tu usuario y es la configuración estándar para desarrollo en Windows.

---

### 3. `npm` no se reconoce como comando

**Error:**
```
npm : El término 'npm' no se reconoce como nombre de un cmdlet...
```

**Causa:** Node.js está instalado en `C:\Program Files\nodejs` pero esa carpeta
no está en el PATH de la sesión actual de PowerShell.

**Solución temporal (solo esta sesión):**
```powershell
$env:PATH += ";C:\Program Files\nodejs"
```

**Solución permanente:**
```powershell
[Environment]::SetEnvironmentVariable(
  "PATH",
  [Environment]::GetEnvironmentVariable("PATH","User") + ";C:\Program Files\nodejs",
  "User"
)
# Cierra y vuelve a abrir PowerShell
```

---

### 4. Error de autenticación de PostgreSQL

**Error:**
```
error: la autentificación password falló para el usuario "postgres"
code: '28P01'
```

**Causa:** El password configurado en `.env` no coincide con el que se definió
al instalar PostgreSQL.

**Solución:** Edita el archivo `.env` y cambia `DB_PASSWORD` por tu password real:
```env
DB_PASSWORD=TuPasswordReal
```

Si no recuerdas el password, puedes resetearlo editando `pg_hba.conf`:
```powershell
# Detener el servicio (ajusta el número de versión)
Stop-Service -Name "postgresql-x64-16"

# Cambiar autenticación a trust temporalmente
$hba = "C:\Program Files\PostgreSQL\16\data\pg_hba.conf"
(Get-Content $hba) -replace 'scram-sha-256', 'trust' | Set-Content $hba

# Reiniciar e ingresar sin password
Start-Service -Name "postgresql-x64-16"
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -c "ALTER USER postgres PASSWORD 'nuevo_password';"

# Restaurar autenticación segura
(Get-Content $hba) -replace 'trust', 'scram-sha-256' | Set-Content $hba
Restart-Service -Name "postgresql-x64-16"
```

---

### 5. Nombres de queries incorrectos en GraphiQL

**Error:**
```json
{
  "message": "Cannot query field \"allEmpleados\" on type \"Query\". Did you mean \"empleados\"?"
}
```

**Causa:** El plugin `pg-simplify-inflector` simplifica los nombres generados por
PostGraphile. Los nombres reales son más cortos que los documentados en muchos tutoriales.

**Tabla de conversión de nombres:**

| Nombre sin plugin | Nombre real (con simplify-inflector) |
|---|---|
| `allEmpleados` | `empleados` |
| `empleadoById(id: 1)` | `empleado(id: 1)` |
| `allProductos` | `productos` |
| `pedidoById(id: 1)` | `pedido(id: 1)` |
| `clienteByClienteId { }` | `cliente { }` (relación) |
| `detallePedidosByPedidoId { }` | `detallePedidos { }` (relación) |
| `filter: { activo: { equalTo: true } }` | `condition: { activo: true }` |

> **Tip:** Abre el panel **Docs** en GraphiQL (esquina superior derecha) para ver
> los nombres exactos del schema generado en tu instalación.

---

## Datos de prueba incluidos

El seed carga datos reales de la empresa ficticia **TechDist S.A.**:
- **5 departamentos**: Ventas, Almacén, Tecnología, RRHH, Finanzas
- **10 empleados** con cargos y salarios reales
- **5 categorías** de productos tecnológicos
- **16 productos**: laptops, periféricos, redes, almacenamiento, licencias
- **8 clientes**: constructora, escuela, gobierno, startup, clínica, hotel
- **5 pedidos** en distintos estados (pendiente → entregado)
- **18 líneas de detalle** con subtotales calculados automáticamente
