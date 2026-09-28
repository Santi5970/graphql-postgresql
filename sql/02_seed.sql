-- ============================================================
-- DATOS DE PRUEBA: Sistema de Gestión Empresarial
-- Caso real: Empresa distribuidora "TechDist S.A."
-- ============================================================

SET search_path TO empresa, public;

-- ============================================================
-- DEPARTAMENTOS
-- ============================================================
INSERT INTO empresa.departamentos (nombre, descripcion, presupuesto) VALUES
  ('Ventas',          'Equipo encargado de la captación y gestión de clientes',       150000.00),
  ('Almacén',         'Control de inventario, recepción y despacho de productos',      80000.00),
  ('Tecnología',      'Infraestructura IT y desarrollo de sistemas internos',         200000.00),
  ('Recursos Humanos','Gestión del talento, nómina y bienestar del personal',          60000.00),
  ('Finanzas',        'Contabilidad, tesorería y reportes financieros',               90000.00);

-- ============================================================
-- EMPLEADOS
-- ============================================================
INSERT INTO empresa.empleados (nombre, apellido, email, telefono, cargo, salario, fecha_ingreso, departamento_id) VALUES
  ('Carlos',    'Mendoza',   'carlos.mendoza@techdist.com',   '555-1001', 'Gerente de Ventas',        4500.00, '2020-03-15', 1),
  ('Ana',       'González',  'ana.gonzalez@techdist.com',     '555-1002', 'Ejecutiva de Ventas',       2800.00, '2021-06-01', 1),
  ('Luis',      'Ramírez',   'luis.ramirez@techdist.com',     '555-1003', 'Ejecutivo de Ventas',       2800.00, '2021-09-12', 1),
  ('María',     'Torres',    'maria.torres@techdist.com',     '555-1004', 'Jefe de Almacén',          3200.00, '2019-11-20', 2),
  ('Roberto',   'Sánchez',   'roberto.sanchez@techdist.com',  '555-1005', 'Auxiliar de Almacén',      1800.00, '2022-01-10', 2),
  ('Elena',     'Jiménez',   'elena.jimenez@techdist.com',    '555-1006', 'Directora de Tecnología',  5500.00, '2018-07-08', 3),
  ('Pablo',     'Herrera',   'pablo.herrera@techdist.com',    '555-1007', 'Desarrollador Backend',    3500.00, '2022-04-15', 3),
  ('Sofía',     'Castro',    'sofia.castro@techdist.com',     '555-1008', 'Gerente de RRHH',          4000.00, '2020-08-25', 4),
  ('Fernando',  'Morales',   'fernando.morales@techdist.com', '555-1009', 'Contador General',         3800.00, '2019-03-01', 5),
  ('Valentina', 'Ríos',      'valentina.rios@techdist.com',   '555-1010', 'Analista Financiera',      2900.00, '2023-02-14', 5);

-- ============================================================
-- CATEGORÍAS DE PRODUCTOS
-- ============================================================
INSERT INTO empresa.categorias_productos (nombre, descripcion) VALUES
  ('Laptops y Computadoras', 'Equipos de cómputo portátiles y de escritorio'),
  ('Periféricos',            'Teclados, mouse, monitores y accesorios de entrada/salida'),
  ('Redes y Conectividad',   'Routers, switches, cables y equipos de red'),
  ('Almacenamiento',         'Discos duros, SSDs y memorias USB'),
  ('Software y Licencias',   'Licencias de sistemas operativos y aplicaciones');

-- ============================================================
-- PRODUCTOS
-- ============================================================
INSERT INTO empresa.productos (codigo, nombre, descripcion, precio, stock, stock_minimo, categoria_id) VALUES
  ('LAP-001', 'Laptop Dell Inspiron 15',      'Intel Core i5, 8GB RAM, 256GB SSD, Windows 11',   850.00,  25, 5, 1),
  ('LAP-002', 'Laptop HP Pavilion 14',        'AMD Ryzen 5, 16GB RAM, 512GB SSD, Windows 11',    950.00,  18, 5, 1),
  ('LAP-003', 'Laptop Lenovo ThinkPad E15',   'Intel Core i7, 16GB RAM, 512GB SSD, Windows 11', 1250.00,  10, 3, 1),
  ('LAP-004', 'MacBook Air M2',               'Apple M2, 8GB RAM, 256GB SSD, macOS',            1299.00,   8, 3, 1),
  ('PER-001', 'Monitor LG 24" Full HD',       'Panel IPS, 75Hz, 1920x1080, HDMI+VGA',           220.00,  40, 10, 2),
  ('PER-002', 'Teclado Mecánico Logitech G',  'Switch Red, RGB, USB, Layout español',             85.00,  60, 15, 2),
  ('PER-003', 'Mouse Inalámbrico Logitech M', 'DPI ajustable, receptor nano USB, ergonómico',     35.00,  80, 20, 2),
  ('PER-004', 'Webcam Logitech C920 HD',      '1080p, micrófono estéreo, USB, compatible Zoom',  75.00,  30, 8,  2),
  ('RED-001', 'Router WiFi 6 TP-Link AX3000', 'Dual band, 3000Mbps, 4 antenas, MU-MIMO',        120.00,  35, 8,  3),
  ('RED-002', 'Switch 8 puertos Cisco SG',    'Gigabit, administrable, montaje en rack',         180.00,  20, 5,  3),
  ('RED-003', 'Cable UTP Cat6 (caja 305m)',   'Para instalaciones de red de alta velocidad',      65.00,  15, 4,  3),
  ('ALM-001', 'SSD Samsung 870 EVO 500GB',    'SATA III, lectura 560MB/s, escritura 530MB/s',    80.00,  45, 10, 4),
  ('ALM-002', 'Disco Duro WD 2TB Blue',       '3.5", SATA, 7200 RPM, para escritorio',           60.00,  50, 12, 4),
  ('ALM-003', 'Memoria USB Kingston 64GB',    'USB 3.2, lectura hasta 200MB/s',                  12.00, 100, 25, 4),
  ('SOF-001', 'Windows 11 Pro (licencia)',     'Licencia digital OEM, activación online',        150.00,   3, 2,  5),  -- bajo stock intencionalmente
  ('SOF-002', 'Microsoft Office 365 Anual',   'Apps de Office para 1 usuario, 1 año',             70.00,   4, 3,  5);  -- bajo stock intencionalmente

-- ============================================================
-- CLIENTES
-- ============================================================
INSERT INTO empresa.clientes (nombre, apellido, empresa, email, telefono, direccion, ciudad, pais) VALUES
  ('Jorge',     'Pérez',       'Constructora JP S.A.',         'jorge.perez@construcctorajp.com',  '555-2001', 'Av. Reforma 100, Piso 3',      'Ciudad de México', 'México'),
  ('Diana',     'López',       'Escuela Técnica Norte',        'diana.lopez@escuelatecnica.edu',   '555-2002', 'Calle Educación 45',           'Guadalajara',      'México'),
  ('Empresa',   NULL,          'Gobierno Municipal Centro',    'compras@gob-municipal.gob.mx',     '555-2003', 'Plaza Principal S/N',          'Monterrey',        'México'),
  ('Alejandro', 'Vega',        'Startup DigitalNow',           'alejandro@digitalnow.io',          '555-2004', 'Colonia Roma, Calle 5 #20',    'Ciudad de México', 'México'),
  ('Patricia',  'Flores',      'Clínica MediSalud',            'patricia.flores@medisalud.com',    '555-2005', 'Blvd. Salud 500',              'Puebla',           'México'),
  ('Ricardo',   'Moreno',      'Hotel Gran Plaza',             'ricardo.moreno@hotelgranza.com',   '555-2006', 'Paseo Turístico 1200',         'Cancún',           'México'),
  ('Laura',     'Gutiérrez',   'Despacho Contable LG',         'laura@despacholg.com',             '555-2007', 'Insurgentes Sur 3000, Of 12',  'Ciudad de México', 'México'),
  ('Miguel',    'Hernández',   NULL,                           'miguel.hernandez@gmail.com',       '555-2008', 'Calle Libertad 88',            'León',             'México');

-- ============================================================
-- PEDIDOS Y DETALLES
-- ============================================================

-- Pedido 1: Constructora JP (equipos para nueva oficina)
INSERT INTO empresa.pedidos (numero_pedido, cliente_id, empleado_id, estado, fecha_pedido, fecha_entrega, notas) VALUES
  ('PED-2024-001', 1, 2, 'entregado', '2024-01-10 09:00:00+00', '2024-01-15', 'Entrega en recepción, preguntar por Jorge Pérez');

INSERT INTO empresa.detalle_pedidos (pedido_id, producto_id, cantidad, precio_unitario, descuento) VALUES
  (1, 1,  5, 850.00, 5.0),  -- 5 Laptops Dell con 5% descuento
  (1, 5,  5, 220.00, 5.0),  -- 5 Monitores LG
  (1, 2,  5,  85.00, 0.0),  -- 5 Teclados mecánicos
  (1, 3,  5,  35.00, 0.0);  -- 5 Mouse inalámbricos

-- Pedido 2: Escuela Técnica Norte (laboratorio de cómputo)
INSERT INTO empresa.pedidos (numero_pedido, cliente_id, empleado_id, estado, fecha_pedido, fecha_entrega, notas) VALUES
  ('PED-2024-002', 2, 3, 'entregado', '2024-02-05 10:30:00+00', '2024-02-12', 'Facturar a nombre de la escuela, requiere carta responsiva');

INSERT INTO empresa.detalle_pedidos (pedido_id, producto_id, cantidad, precio_unitario, descuento) VALUES
  (2, 1,  10, 850.00, 8.0),  -- 10 Laptops Dell con 8% descuento por volumen
  (2, 5,  10, 220.00, 8.0),  -- 10 Monitores LG
  (2, 9,   2, 120.00, 0.0),  -- 2 Routers WiFi 6
  (2, 15, 10, 150.00, 0.0);  -- 10 Licencias Windows 11

-- Pedido 3: Startup DigitalNow (equipos premium para desarrolladores)
INSERT INTO empresa.pedidos (numero_pedido, cliente_id, empleado_id, estado, fecha_pedido, fecha_entrega, notas) VALUES
  ('PED-2024-003', 4, 2, 'enviado', '2024-03-20 14:00:00+00', '2024-03-25', 'Requieren factura electrónica CFDI');

INSERT INTO empresa.detalle_pedidos (pedido_id, producto_id, cantidad, precio_unitario, descuento) VALUES
  (3, 4, 3, 1299.00, 3.0),  -- 3 MacBook Air M2
  (3, 3, 2, 1250.00, 3.0),  -- 2 Lenovo ThinkPad
  (3, 8, 5,   75.00, 0.0),  -- 5 Webcams
  (3, 7, 5,   35.00, 0.0);  -- 5 Mouse inalámbrico

-- Pedido 4: Clínica MediSalud (red y almacenamiento)
INSERT INTO empresa.pedidos (numero_pedido, cliente_id, empleado_id, estado, fecha_pedido, fecha_entrega, notas) VALUES
  ('PED-2024-004', 5, 1, 'confirmado', '2024-04-01 08:00:00+00', '2024-04-10', 'Urgente: instalación de red clínica');

INSERT INTO empresa.detalle_pedidos (pedido_id, producto_id, cantidad, precio_unitario, descuento) VALUES
  (4, 10, 3, 180.00, 0.0),  -- 3 Switches Cisco
  (4, 11, 2,  65.00, 0.0),  -- 2 Cajas Cable UTP
  (4, 12, 8,  80.00, 2.0),  -- 8 SSD Samsung
  (4, 16, 5,  70.00, 0.0);  -- 5 Microsoft Office

-- Pedido 5: Hotel Gran Plaza (pedido pendiente)
INSERT INTO empresa.pedidos (numero_pedido, cliente_id, empleado_id, estado, fecha_pedido, fecha_entrega, notas) VALUES
  ('PED-2024-005', 6, 3, 'pendiente', '2024-04-10 16:00:00+00', '2024-04-20', 'Cotización inicial, pendiente de aprobación gerencial');

INSERT INTO empresa.detalle_pedidos (pedido_id, producto_id, cantidad, precio_unitario, descuento) VALUES
  (5, 2, 15, 950.00, 10.0),  -- 15 HP Pavilion con 10% por volumen
  (5, 5, 15, 220.00, 10.0),  -- 15 Monitores LG
  (5, 9,  5, 120.00,  5.0);  -- 5 Routers WiFi 6

-- ============================================================
-- Verificación de datos insertados
-- ============================================================
SELECT 'departamentos' AS tabla, COUNT(*) AS registros FROM empresa.departamentos
UNION ALL
SELECT 'empleados',          COUNT(*) FROM empresa.empleados
UNION ALL
SELECT 'categorias',         COUNT(*) FROM empresa.categorias_productos
UNION ALL
SELECT 'productos',          COUNT(*) FROM empresa.productos
UNION ALL
SELECT 'clientes',           COUNT(*) FROM empresa.clientes
UNION ALL
SELECT 'pedidos',            COUNT(*) FROM empresa.pedidos
UNION ALL
SELECT 'detalle_pedidos',    COUNT(*) FROM empresa.detalle_pedidos;
