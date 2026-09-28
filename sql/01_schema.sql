-- ============================================================
-- SCHEMA: Sistema de Gestión Empresarial
-- Caso de uso: Empresa de distribución de productos
-- Compatible con PostGraphile
-- ============================================================

-- Eliminar schema anterior si existe (para desarrollo)
DROP SCHEMA IF EXISTS empresa CASCADE;
CREATE SCHEMA empresa;

-- Configurar el search_path
SET search_path TO empresa, public;

-- ============================================================
-- TABLA: departamentos
-- Representa los departamentos internos de la empresa
-- ============================================================
CREATE TABLE empresa.departamentos (
  id          SERIAL PRIMARY KEY,
  nombre      VARCHAR(100) NOT NULL UNIQUE,
  descripcion TEXT,
  presupuesto NUMERIC(12, 2) DEFAULT 0,
  activo      BOOLEAN NOT NULL DEFAULT TRUE,
  creado_en   TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  actualizado_en TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE empresa.departamentos IS 'Departamentos internos de la empresa';
COMMENT ON COLUMN empresa.departamentos.presupuesto IS 'Presupuesto anual asignado en USD';

-- ============================================================
-- TABLA: empleados
-- Personal de la empresa con su departamento asignado
-- ============================================================
CREATE TABLE empresa.empleados (
  id              SERIAL PRIMARY KEY,
  nombre          VARCHAR(100) NOT NULL,
  apellido        VARCHAR(100) NOT NULL,
  email           VARCHAR(150) NOT NULL UNIQUE,
  telefono        VARCHAR(20),
  cargo           VARCHAR(100) NOT NULL,
  salario         NUMERIC(10, 2) NOT NULL CHECK (salario > 0),
  fecha_ingreso   DATE NOT NULL DEFAULT CURRENT_DATE,
  departamento_id INTEGER REFERENCES empresa.departamentos(id) ON DELETE SET NULL,
  activo          BOOLEAN NOT NULL DEFAULT TRUE,
  creado_en       TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  actualizado_en  TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE empresa.empleados IS 'Empleados registrados en la empresa';
COMMENT ON COLUMN empresa.empleados.salario IS 'Salario mensual en USD';

-- ============================================================
-- TABLA: categorias_productos
-- Categorías para clasificar el catálogo de productos
-- ============================================================
CREATE TABLE empresa.categorias_productos (
  id          SERIAL PRIMARY KEY,
  nombre      VARCHAR(100) NOT NULL UNIQUE,
  descripcion TEXT,
  activo      BOOLEAN NOT NULL DEFAULT TRUE,
  creado_en   TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE empresa.categorias_productos IS 'Clasificación del catálogo de productos';

-- ============================================================
-- TABLA: productos
-- Catálogo de productos de la empresa
-- ============================================================
CREATE TABLE empresa.productos (
  id            SERIAL PRIMARY KEY,
  codigo        VARCHAR(50) NOT NULL UNIQUE,
  nombre        VARCHAR(200) NOT NULL,
  descripcion   TEXT,
  precio        NUMERIC(10, 2) NOT NULL CHECK (precio >= 0),
  stock         INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
  stock_minimo  INTEGER NOT NULL DEFAULT 5,
  categoria_id  INTEGER REFERENCES empresa.categorias_productos(id) ON DELETE SET NULL,
  activo        BOOLEAN NOT NULL DEFAULT TRUE,
  creado_en     TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  actualizado_en TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE empresa.productos IS 'Catálogo de productos disponibles para venta';
COMMENT ON COLUMN empresa.productos.stock_minimo IS 'Nivel mínimo de stock antes de generar alerta de reabastecimiento';

-- ============================================================
-- TABLA: clientes
-- Clientes registrados que realizan pedidos
-- ============================================================
CREATE TABLE empresa.clientes (
  id          SERIAL PRIMARY KEY,
  nombre      VARCHAR(100) NOT NULL,
  apellido    VARCHAR(100),
  empresa     VARCHAR(200),
  email       VARCHAR(150) NOT NULL UNIQUE,
  telefono    VARCHAR(20),
  direccion   TEXT,
  ciudad      VARCHAR(100),
  pais        VARCHAR(100) DEFAULT 'México',
  activo      BOOLEAN NOT NULL DEFAULT TRUE,
  creado_en   TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  actualizado_en TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE empresa.clientes IS 'Clientes que realizan compras en la empresa';

-- ============================================================
-- TABLA: pedidos
-- Cabecera de los pedidos de venta
-- ============================================================
CREATE TABLE empresa.pedidos (
  id              SERIAL PRIMARY KEY,
  numero_pedido   VARCHAR(20) NOT NULL UNIQUE DEFAULT ('PED-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || nextval('empresa.pedidos_id_seq')),
  cliente_id      INTEGER NOT NULL REFERENCES empresa.clientes(id) ON DELETE RESTRICT,
  empleado_id     INTEGER REFERENCES empresa.empleados(id) ON DELETE SET NULL,
  estado          VARCHAR(20) NOT NULL DEFAULT 'pendiente'
                    CHECK (estado IN ('pendiente', 'confirmado', 'en_proceso', 'enviado', 'entregado', 'cancelado')),
  fecha_pedido    TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  fecha_entrega   DATE,
  total           NUMERIC(12, 2) DEFAULT 0,
  notas           TEXT,
  creado_en       TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  actualizado_en  TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE empresa.pedidos IS 'Órdenes de compra realizadas por los clientes';
COMMENT ON COLUMN empresa.pedidos.estado IS 'Estados posibles: pendiente, confirmado, en_proceso, enviado, entregado, cancelado';

-- ============================================================
-- TABLA: detalle_pedidos
-- Líneas de detalle de cada pedido (productos incluidos)
-- ============================================================
CREATE TABLE empresa.detalle_pedidos (
  id          SERIAL PRIMARY KEY,
  pedido_id   INTEGER NOT NULL REFERENCES empresa.pedidos(id) ON DELETE CASCADE,
  producto_id INTEGER NOT NULL REFERENCES empresa.productos(id) ON DELETE RESTRICT,
  cantidad    INTEGER NOT NULL CHECK (cantidad > 0),
  precio_unitario NUMERIC(10, 2) NOT NULL CHECK (precio_unitario >= 0),
  descuento   NUMERIC(5, 2) DEFAULT 0 CHECK (descuento >= 0 AND descuento <= 100),
  subtotal    NUMERIC(12, 2) GENERATED ALWAYS AS (
                ROUND(cantidad * precio_unitario * (1 - descuento / 100), 2)
              ) STORED,
  creado_en   TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE empresa.detalle_pedidos IS 'Ítems incluidos en cada pedido';
COMMENT ON COLUMN empresa.detalle_pedidos.descuento IS 'Porcentaje de descuento aplicado (0-100)';
COMMENT ON COLUMN empresa.detalle_pedidos.subtotal IS 'Calculado automáticamente: cantidad * precio * (1 - descuento/100)';

-- ============================================================
-- ÍNDICES para mejorar el rendimiento de consultas frecuentes
-- ============================================================
CREATE INDEX idx_empleados_departamento ON empresa.empleados(departamento_id);
CREATE INDEX idx_empleados_email ON empresa.empleados(email);
CREATE INDEX idx_productos_categoria ON empresa.productos(categoria_id);
CREATE INDEX idx_productos_codigo ON empresa.productos(codigo);
CREATE INDEX idx_pedidos_cliente ON empresa.pedidos(cliente_id);
CREATE INDEX idx_pedidos_estado ON empresa.pedidos(estado);
CREATE INDEX idx_pedidos_fecha ON empresa.pedidos(fecha_pedido);
CREATE INDEX idx_detalle_pedido ON empresa.detalle_pedidos(pedido_id);

-- ============================================================
-- FUNCIÓN: Actualizar campo actualizado_en automáticamente
-- ============================================================
CREATE OR REPLACE FUNCTION empresa.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.actualizado_en = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger a todas las tablas con actualizado_en
CREATE TRIGGER trg_departamentos_updated
  BEFORE UPDATE ON empresa.departamentos
  FOR EACH ROW EXECUTE FUNCTION empresa.set_updated_at();

CREATE TRIGGER trg_empleados_updated
  BEFORE UPDATE ON empresa.empleados
  FOR EACH ROW EXECUTE FUNCTION empresa.set_updated_at();

CREATE TRIGGER trg_productos_updated
  BEFORE UPDATE ON empresa.productos
  FOR EACH ROW EXECUTE FUNCTION empresa.set_updated_at();

CREATE TRIGGER trg_clientes_updated
  BEFORE UPDATE ON empresa.clientes
  FOR EACH ROW EXECUTE FUNCTION empresa.set_updated_at();

CREATE TRIGGER trg_pedidos_updated
  BEFORE UPDATE ON empresa.pedidos
  FOR EACH ROW EXECUTE FUNCTION empresa.set_updated_at();

-- ============================================================
-- FUNCIÓN: Actualizar el total del pedido al modificar detalles
-- ============================================================
CREATE OR REPLACE FUNCTION empresa.actualizar_total_pedido()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE empresa.pedidos
  SET total = (
    SELECT COALESCE(SUM(subtotal), 0)
    FROM empresa.detalle_pedidos
    WHERE pedido_id = COALESCE(NEW.pedido_id, OLD.pedido_id)
  )
  WHERE id = COALESCE(NEW.pedido_id, OLD.pedido_id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_actualizar_total_pedido
  AFTER INSERT OR UPDATE OR DELETE ON empresa.detalle_pedidos
  FOR EACH ROW EXECUTE FUNCTION empresa.actualizar_total_pedido();

-- ============================================================
-- VISTA: resumen de pedidos con datos del cliente
-- ============================================================
CREATE VIEW empresa.vista_pedidos_completos AS
SELECT
  p.id,
  p.numero_pedido,
  p.estado,
  p.fecha_pedido,
  p.fecha_entrega,
  p.total,
  c.nombre || ' ' || COALESCE(c.apellido, '') AS cliente_nombre,
  c.email AS cliente_email,
  c.empresa AS cliente_empresa,
  e.nombre || ' ' || e.apellido AS vendedor,
  COUNT(dp.id) AS cantidad_items
FROM empresa.pedidos p
JOIN empresa.clientes c ON c.id = p.cliente_id
LEFT JOIN empresa.empleados e ON e.id = p.empleado_id
LEFT JOIN empresa.detalle_pedidos dp ON dp.pedido_id = p.id
GROUP BY p.id, p.numero_pedido, p.estado, p.fecha_pedido,
         p.fecha_entrega, p.total, c.nombre, c.apellido,
         c.email, c.empresa, e.nombre, e.apellido;

COMMENT ON VIEW empresa.vista_pedidos_completos IS 'Vista resumida de pedidos con información de cliente y vendedor';

-- ============================================================
-- VISTA: productos con bajo stock
-- ============================================================
CREATE VIEW empresa.vista_productos_bajo_stock AS
SELECT
  p.id,
  p.codigo,
  p.nombre,
  p.stock,
  p.stock_minimo,
  p.stock - p.stock_minimo AS diferencia,
  cp.nombre AS categoria
FROM empresa.productos p
LEFT JOIN empresa.categorias_productos cp ON cp.id = p.categoria_id
WHERE p.stock <= p.stock_minimo
  AND p.activo = TRUE
ORDER BY p.stock ASC;

COMMENT ON VIEW empresa.vista_productos_bajo_stock IS 'Productos que necesitan reabastecimiento urgente';
