/**
 * Cliente GraphQL desde Node.js
 * ─────────────────────────────────────────────────────────────
 * Muestra cómo consumir la API GraphQL desde código JavaScript.
 * Equivalente a lo que haría un frontend (React, Vue) o
 * un microservicio backend.
 *
 * Requisito: npm install node-fetch  (o usar fetch nativo Node 18+)
 * Uso: node ejemplos/05_cliente_nodejs.js
 */

const GRAPHQL_URL = 'http://localhost:4000/graphql';

// ─── Función genérica para llamar al endpoint GraphQL ────────────────────────
async function graphqlRequest(query, variables = {}) {
  const response = await fetch(GRAPHQL_URL, {
    method:  'POST',
    headers: { 'Content-Type': 'application/json' },
    body:    JSON.stringify({ query, variables }),
  });

  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }

  const { data, errors } = await response.json();

  if (errors) {
    console.error('Errores GraphQL:', errors);
    throw new Error(errors[0].message);
  }

  return data;
}

// ─── EJEMPLO 1: Listar todos los empleados ───────────────────────────────────
async function listarEmpleados() {
  const query = `
    query {
      allEmpleados(orderBy: APELLIDO_ASC) {
        totalCount
        nodes {
          id
          nombre
          apellido
          cargo
          salario
          departamentoByDepartamentoId {
            nombre
          }
        }
      }
    }
  `;

  const data = await graphqlRequest(query);
  const { totalCount, nodes } = data.allEmpleados;

  console.log(`\n👥 Empleados (${totalCount} total):`);
  console.log('─'.repeat(60));
  nodes.forEach(emp => {
    const dept = emp.departamentoByDepartamentoId?.nombre || 'Sin depto';
    console.log(`  [${emp.id}] ${emp.nombre} ${emp.apellido}`);
    console.log(`       Cargo: ${emp.cargo} | Depto: ${dept}`);
    console.log(`       Salario: $${parseFloat(emp.salario).toLocaleString('es-MX')}`);
  });
}

// ─── EJEMPLO 2: Crear un nuevo cliente ───────────────────────────────────────
async function crearCliente(datosCliente) {
  const mutation = `
    mutation CrearCliente($nombre: String!, $email: String!, $empresa: String) {
      createCliente(input: {
        cliente: {
          nombre:   $nombre
          email:    $email
          empresa:  $empresa
          activo:   true
        }
      }) {
        cliente {
          id
          nombre
          email
          empresa
          creadoEn
        }
      }
    }
  `;

  const data = await graphqlRequest(mutation, datosCliente);
  return data.createCliente.cliente;
}

// ─── EJEMPLO 3: Buscar productos con filtro ──────────────────────────────────
async function buscarProductos(busqueda, precioMax) {
  const query = `
    query BuscarProductos($busqueda: String!, $precioMax: BigFloat!) {
      allProductos(
        filter: {
          nombre: { includesInsensitive: $busqueda }
          precio: { lessThanOrEqualTo: $precioMax }
          activo: { equalTo: true }
        }
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
  `;

  const data = await graphqlRequest(query, { busqueda, precioMax });
  return data.allProductos;
}

// ─── EJEMPLO 4: Ver pedido completo ──────────────────────────────────────────
async function verPedido(pedidoId) {
  const query = `
    query VerPedido($id: Int!) {
      pedidoById(id: $id) {
        numeroPedido
        estado
        total
        clienteByClienteId {
          nombre
          apellido
          empresa
        }
        detallePedidosByPedidoId {
          nodes {
            cantidad
            precioUnitario
            descuento
            subtotal
            productoByProductoId {
              codigo
              nombre
            }
          }
        }
      }
    }
  `;

  const data = await graphqlRequest(query, { id: pedidoId });
  return data.pedidoById;
}

// ─── Función principal: ejecuta todos los ejemplos ───────────────────────────
async function main() {
  console.log('🚀 Cliente GraphQL — TechDist S.A.');
  console.log('='.repeat(60));

  try {
    // 1. Listar empleados
    await listarEmpleados();

    // 2. Crear un cliente nuevo
    console.log('\n➕ Creando nuevo cliente...');
    const nuevoCliente = await crearCliente({
      nombre:  'Test Usuario',
      email:   `test.${Date.now()}@ejemplo.com`,
      empresa: 'Empresa de Prueba S.A.',
    });
    console.log('✅ Cliente creado:', nuevoCliente);

    // 3. Buscar productos
    console.log('\n🔍 Buscando laptops hasta $1,200...');
    const resultado = await buscarProductos('laptop', '1200');
    console.log(`   Encontrados: ${resultado.totalCount} productos`);
    resultado.nodes.forEach(p => {
      console.log(`   • [${p.codigo}] ${p.nombre} — $${p.precio} (stock: ${p.stock})`);
    });

    // 4. Ver pedido #2
    console.log('\n📦 Detalle del pedido #2:');
    const pedido = await verPedido(2);
    if (pedido) {
      console.log(`   Pedido: ${pedido.numeroPedido} | Estado: ${pedido.estado}`);
      console.log(`   Cliente: ${pedido.clienteByClienteId.nombre} — ${pedido.clienteByClienteId.empresa}`);
      console.log(`   Total: $${parseFloat(pedido.total).toLocaleString('es-MX')}`);
      console.log(`   Ítems:`);
      pedido.detallePedidosByPedidoId.nodes.forEach(item => {
        console.log(`     • ${item.productoByProductoId.nombre} x${item.cantidad} = $${item.subtotal}`);
      });
    }

    console.log('\n✅ Todos los ejemplos ejecutados correctamente.\n');

  } catch (err) {
    console.error('\n❌ Error:', err.message);
    console.error('   ¿Está corriendo el servidor? npm start\n');
  }
}

main();
