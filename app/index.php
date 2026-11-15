<?php
// Tienda de la nube: e-commerce de ejemplo del obligatorio de ISC.
// Los datos de conexión y de la instancia los escribe el user-data en /var/www/config.php
require '/var/www/config.php';

// Los errores de MySQL se manejan como excepciones (try/catch de abajo)
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

// ---------------------------------------------------------------
// Catálogo: único lugar a editar para cambiar productos o imágenes.
// Las imágenes están en app/img/ (la 1 se muestra siempre, la 2 al pasar el mouse)
// ---------------------------------------------------------------
$catalogo = [
    1 => ['nombre' => 'This Guy Forks Shirt', 'descripcion' => 'Para quien hace fork de todo repo que encuentra', 'precio' => 22.00, 'stock' => 25, 'img' => ['ThisGuyForks-1.jpg', 'ThisGuyForks-2.jpg']],
    2 => ['nombre' => 'There is no cloud Shirt', 'descripcion' => 'It is just someone else\'s computer', 'precio' => 20.00, 'stock' => 15, 'img' => ['thereisnocloud-1.png', 'thereisnocloud-2.jpg']],
    3 => ['nombre' => "It's Not a Bug. It's a Feature Shirt", 'descripcion' => 'La respuesta oficial a cualquier reporte de error', 'precio' => 20.00, 'stock' => 4, 'img' => ['notabug-1.jpg', 'notabug-2.jpg']],
    4 => ['nombre' => 'GitHub Shirt', 'descripcion' => 'Where forking is done', 'precio' => 22.00, 'stock' => 10, 'img' => ['GitHub-1.jpg', 'GitHub-2.jpg']],
    5 => ['nombre' => 'Breaking Bugs Shirt', 'descripcion' => 'Say my name: debugger', 'precio' => 24.00, 'stock' => 8, 'img' => ['BreakingBugs-1.jpg', 'BreakingBugs-2.jpg']],
];

$error = '';
$productos = [];
$pedidos = [];
$latencia = null;

try {
    // Conexión a RDS, midiendo cuánto tarda (se muestra en la barra de estado)
    $t0 = microtime(true);
    $db = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
    $db->set_charset('utf8mb4');
    $db->query('SELECT 1');
    $latencia = round((microtime(true) - $t0) * 1000);

    // Crea las tablas la primera vez (si ya existen, no hace nada)
    $db->query("CREATE TABLE IF NOT EXISTS productos (
        id INT PRIMARY KEY,
        nombre VARCHAR(80) NOT NULL,
        descripcion VARCHAR(200),
        precio DECIMAL(6,2) NOT NULL,
        stock INT NOT NULL)");
    $db->query("CREATE TABLE IF NOT EXISTS pedidos (
        id INT AUTO_INCREMENT PRIMARY KEY,
        producto_id INT NOT NULL,
        instancia VARCHAR(30),
        az VARCHAR(20),
        fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");

    // Carga el catálogo: crea los productos nuevos y actualiza nombre, descripción y precio
    // de los existentes (el stock se respeta, para no perder las compras hechas)
    $st = $db->prepare("INSERT INTO productos (id, nombre, descripcion, precio, stock) VALUES (?, ?, ?, ?, ?)
                        ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), descripcion = VALUES(descripcion), precio = VALUES(precio)");
    foreach ($catalogo as $id => $p) {
        $st->bind_param('issdi', $id, $p['nombre'], $p['descripcion'], $p['precio'], $p['stock']);
        $st->execute();
    }
    // Quita productos que ya no están en el catálogo
    $db->query("DELETE FROM productos WHERE id NOT IN (" . implode(',', array_keys($catalogo)) . ")");

    // Compra: descuenta stock y registra el pedido, todo junto (transacción)
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $id = (int) $_POST['id'];
        $instancia = INSTANCIA;
        $az = AZ;

        $db->begin_transaction();
        $st = $db->prepare("UPDATE productos SET stock = stock - 1 WHERE id = ? AND stock > 0");
        $st->bind_param('i', $id);
        $st->execute();

        if ($st->affected_rows === 1) {
            $st = $db->prepare("INSERT INTO pedidos (producto_id, instancia, az) VALUES (?, ?, ?)");
            $st->bind_param('iss', $id, $instancia, $az);
            $st->execute();
            $pedido = $db->insert_id;
            $db->commit();
            header('Location: /?compra=ok&pedido=' . $pedido);
        } else {
            $db->rollback();
            header('Location: /?compra=sinstock');
        }
        exit;
    }

    $productos = $db->query("SELECT * FROM productos ORDER BY id")->fetch_all(MYSQLI_ASSOC);
    $pedidos = $db->query("SELECT p.id, pr.nombre, p.instancia, p.az, p.fecha
                           FROM pedidos p JOIN productos pr ON pr.id = p.producto_id
                           ORDER BY p.id DESC LIMIT 8")->fetch_all(MYSQLI_ASSOC);
} catch (Exception $e) {
    $error = 'Sin conexión con la base de datos. Si es un failover, esperá unos segundos y refrescá.';
}

// Escapa texto para mostrarlo en HTML de forma segura
function e($texto) {
    return htmlspecialchars((string) $texto, ENT_QUOTES, 'UTF-8');
}

$compra = $_GET['compra'] ?? '';
?>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Tienda de la nube</title>
<style>
    :root {
        --bg: #0d1117; --panel: #161b22; --borde: #30363d; --texto: #c9d1d9;
        --verde: #3fb950; --ambar: #d29922; --rojo: #f85149; --azul: #58a6ff; --gris: #8b949e;
    }
    * { box-sizing: border-box; }
    body { margin: 0; background: #010409; color: var(--texto); font-family: "Fira Code", Consolas, monospace; padding: 24px 16px 64px; }

    /* Ventana de terminal */
    .ventana { max-width: 1100px; margin: 0 auto; background: var(--bg); border: 1px solid var(--borde); border-radius: 10px; overflow: hidden; box-shadow: 0 20px 60px rgba(0,0,0,.6); }
    .barra-titulo { display: flex; align-items: center; gap: 8px; padding: 10px 14px; background: var(--panel); border-bottom: 1px solid var(--borde); font-size: 13px; color: var(--gris); }
    .punto { width: 12px; height: 12px; border-radius: 50%; }
    .rojo { background: #ff5f56; } .amarillo { background: #ffbd2e; } .verde { background: #27c93f; }
    .barra-titulo span.titulo { margin-left: 12px; }
    .contenido { padding: 24px; }

    /* Cabezal */
    pre.logo { color: var(--verde); margin: 0; font-family: monospace; font-size: 14px; line-height: 1.3; overflow-x: auto; }
    .lema { color: var(--gris); margin: 8px 0 24px; }
    .cursor { display: inline-block; width: 9px; height: 1em; background: var(--verde); vertical-align: text-bottom; animation: parpadeo 1s steps(1) infinite; }
    @keyframes parpadeo { 50% { opacity: 0; } }
    .prompt { color: var(--gris); margin: 24px 0 12px; }
    .prompt b { color: var(--verde); font-weight: normal; }

    /* Productos */
    .grilla { display: grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); gap: 18px; }
    .tarjeta { position: relative; background: var(--panel); border: 1px solid var(--borde); border-radius: 8px; overflow: hidden; transition: transform .15s, border-color .15s, box-shadow .15s; }
    .tarjeta:hover { transform: translateY(-3px); border-color: var(--verde); box-shadow: 0 0 18px rgba(63,185,80,.25); }
    .fotos { position: relative; aspect-ratio: 1 / 1; background: #fff; border-bottom: 1px solid var(--borde); }
    .fotos img { position: absolute; inset: 0; width: 100%; height: 100%; object-fit: cover; transition: opacity .3s; }
    .fotos .foto2 { opacity: 0; }
    .tarjeta:hover .foto2 { opacity: 1; }
    .info { padding: 14px; }
    .info h3 { margin: 0 0 6px; font-size: 15px; color: #e6edf3; }
    .info p { margin: 0 0 12px; font-size: 13px; color: var(--gris); min-height: 34px; }
    .pie-tarjeta { display: flex; align-items: center; justify-content: space-between; }
    .precio { color: var(--ambar); font-size: 18px; }
    .badge { position: absolute; z-index: 2; top: 10px; right: 10px; font-size: 11px; padding: 3px 8px; border-radius: 4px; border: 1px solid; background: rgba(1,4,9,.8); }
    .badge.pocas { color: var(--ambar); border-color: var(--ambar); }
    .badge.agotado { color: var(--rojo); border-color: var(--rojo); }
    button { background: transparent; color: var(--verde); border: 1px solid var(--verde); border-radius: 4px; padding: 7px 12px; font-family: inherit; cursor: pointer; }
    button:hover { background: var(--verde); color: var(--bg); }
    button:disabled { color: var(--gris); border-color: var(--borde); background: transparent; cursor: not-allowed; }

    /* Avisos */
    .aviso { position: fixed; top: 20px; right: 20px; padding: 12px 16px; border-radius: 6px; background: var(--panel); border: 1px solid; animation: desaparece 5s forwards; z-index: 10; }
    .aviso.ok { color: var(--verde); border-color: var(--verde); }
    .aviso.warn { color: var(--ambar); border-color: var(--ambar); }
    @keyframes desaparece { 0%, 80% { opacity: 1; } 100% { opacity: 0; visibility: hidden; } }
    .error { color: var(--rojo); border: 1px solid var(--rojo); padding: 16px; border-radius: 6px; }

    /* Log de pedidos */
    table { width: 100%; border-collapse: collapse; font-size: 13px; }
    th { text-align: left; color: var(--gris); font-weight: normal; border-bottom: 1px solid var(--borde); padding: 6px; }
    td { padding: 6px; border-bottom: 1px dashed var(--borde); }
    td.az { color: var(--azul); }
    .vacio { color: var(--gris); }

    /* Barra de estado (estilo tmux) */
    .estado { position: fixed; bottom: 0; left: 0; right: 0; display: flex; flex-wrap: wrap; gap: 0; font-size: 12px; background: var(--verde); color: var(--bg); }
    .estado span { padding: 5px 12px; border-right: 1px solid rgba(1,4,9,.3); }
    .estado .mal { background: var(--rojo); color: #fff; }
    .estado .der { margin-left: auto; }

    .logo-movil { display: none; color: var(--verde); margin: 0; font-size: 22px; }
    @media (max-width: 600px) { .contenido { padding: 16px; } pre.logo { display: none; } .logo-movil { display: block; } }
</style>
</head>
<body>

<?php if ($compra === 'ok'): ?>
    <div class="aviso ok">✔ pedido #<?= e($_GET['pedido'] ?? '') ?> confirmado</div>
<?php elseif ($compra === 'sinstock'): ?>
    <div class="aviso warn">⚠ sin stock</div>
<?php endif; ?>

<div class="ventana">
    <div class="barra-titulo">
        <div class="punto rojo"></div><div class="punto amarillo"></div><div class="punto verde"></div>
        <span class="titulo">guest@tienda-de-la-nube: ~</span>
    </div>

    <div class="contenido">
<pre class="logo"> _____ _             _           _       _                 _
|_   _(_)___ _ _  __| |__ _   __| |___  | |__ _   _ _ _  _| |__  ___
  | | | / -_) ' \/ _` / _` | / _` / -_) | / _` | | ' \ || | '_ \/ -_)
  |_| |_\___|_||_\__,_\__,_| \__,_\___| |_\__,_| |_||_\_,_|_.__/\___|</pre>
        <h1 class="logo-movil">☁ tienda de la nube</h1>
        <p class="lema">remeras para gente que vive en la terminal · envíos a todas las AZ <span class="cursor"></span></p>

        <?php if ($error): ?>
            <p class="error">✘ <?= e($error) ?></p>
        <?php else: ?>
            <p class="prompt"><b>guest@tienda:~$</b> ls productos/</p>
            <div class="grilla">
            <?php foreach ($productos as $p): ?>
                <div class="tarjeta">
                    <?php if ($p['stock'] == 0): ?>
                        <span class="badge agotado">AGOTADO</span>
                    <?php elseif ($p['stock'] <= 5): ?>
                        <span class="badge pocas">ÚLTIMAS <?= e($p['stock']) ?></span>
                    <?php endif; ?>
                    <div class="fotos">
                        <img src="img/<?= e($catalogo[$p['id']]['img'][0]) ?>" alt="<?= e($p['nombre']) ?>" loading="lazy">
                        <img class="foto2" src="img/<?= e($catalogo[$p['id']]['img'][1]) ?>" alt="<?= e($p['nombre']) ?> (puesta)" loading="lazy">
                    </div>
                    <div class="info">
                        <h3><?= e($p['nombre']) ?></h3>
                        <p><?= e($p['descripcion']) ?></p>
                        <div class="pie-tarjeta">
                            <span class="precio">USD <?= e($p['precio']) ?></span>
                            <form method="post">
                                <input type="hidden" name="id" value="<?= e($p['id']) ?>">
                                <button <?= $p['stock'] > 0 ? '' : 'disabled' ?>>$ comprar</button>
                            </form>
                        </div>
                    </div>
                </div>
            <?php endforeach; ?>
            </div>

            <p class="prompt"><b>guest@tienda:~$</b> tail pedidos.log</p>
            <?php if (!$pedidos): ?>
                <p class="vacio">(todavía no hay pedidos)</p>
            <?php else: ?>
                <table>
                    <tr><th>#</th><th>producto</th><th>atendido por</th><th>az</th><th>fecha (utc)</th></tr>
                    <?php foreach ($pedidos as $o): ?>
                    <tr>
                        <td><?= e($o['id']) ?></td>
                        <td><?= e($o['nombre']) ?></td>
                        <td><?= e($o['instancia']) ?></td>
                        <td class="az"><?= e($o['az']) ?></td>
                        <td><?= e($o['fecha']) ?></td>
                    </tr>
                    <?php endforeach; ?>
                </table>
            <?php endif; ?>
        <?php endif; ?>
    </div>
</div>

<div class="estado">
    <span>● <?= e(INSTANCIA) ?></span>
    <span><?= e(AZ) ?></span>
    <?php if ($error): ?>
        <span class="mal">DB: sin conexión</span>
    <?php else: ?>
        <span>DB: OK <?= e($latencia) ?> ms</span>
    <?php endif; ?>
    <span class="der"><?= e(gmdate('H:i:s')) ?> UTC</span>
</div>

</body>
</html>
