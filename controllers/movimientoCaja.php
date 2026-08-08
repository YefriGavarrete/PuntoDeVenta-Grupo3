<?php
// ============================================
// CONTROLADOR MOVIMIENTO DE CAJA
// Registra ingresos y egresos en la caja abierta
// ============================================

session_start();
require "../config/db.php";

// Verificamos que el usuario esté logueado
if (!isset($_SESSION['id_usuario'])) {
    $_SESSION['mensaje'] = "Debe iniciar sesión para registrar movimientos de caja.";
    $_SESSION['tipo']    = "danger";
    header("Location: ../login.php");
    exit;
}

$id_usuario = $_SESSION['id_usuario'];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    // Capturamos datos del formulario
    $tipo        = $_POST['tipo'] ?? '';
    $descripcion = trim($_POST['descripcion'] ?? '');
    $monto       = floatval($_POST['monto'] ?? 0);

    // Validación básica
    if (empty($tipo) || empty($descripcion) || $monto <= 0) {
        $_SESSION['mensaje'] = "Complete todos los datos del movimiento.";
        $_SESSION['tipo']    = "danger";
        header("Location: ../movimientoCaja.php");
        exit;
    }

    // Buscamos la apertura de caja actual del usuario
    $query_apertura = "
        SELECT id_apertura
        FROM aperturas_caja
        WHERE id_usuario = ?
        AND estado = 'ABIERTA'
        LIMIT 1
    ";

    $stmt_apertura = $conn->prepare($query_apertura);
    $stmt_apertura->bind_param("i", $id_usuario);
    $stmt_apertura->execute();
    $resultado_apertura = $stmt_apertura->get_result();

    if ($resultado_apertura->num_rows === 0) {
        // No hay caja abierta
        $_SESSION['mensaje'] = "No tiene una caja abierta. Debe abrir una caja antes de registrar movimientos.";
        $_SESSION['tipo']    = "warning";
        header("Location: ../movimientoCaja.php");
        exit;
    }

    $apertura = $resultado_apertura->fetch_assoc();
    $id_apertura = $apertura['id_apertura'];

    $stmt_apertura->close();

    // Insertamos el movimiento
    $query_mov = "
        INSERT INTO movimientos_caja
        (
            id_apertura,
            id_usuario,
            tipo,
            descripcion,
            monto,
            fecha
        )
        VALUES
        (
            ?,
            ?,
            ?,
            ?,
            ?,
            NOW()
        )
    ";

    $stmt_mov = $conn->prepare($query_mov);
    $stmt_mov->bind_param(
        "iissd",
        $id_apertura,
        $id_usuario,
        $tipo,
        $descripcion,
        $monto
    );

    if ($stmt_mov->execute()) {
        $_SESSION['mensaje'] = "Movimiento de caja registrado correctamente.";
        $_SESSION['tipo']    = "success";
    } else {
        $_SESSION['mensaje'] = "Error al registrar el movimiento de caja.";
        $_SESSION['tipo']    = "danger";
    }

    $stmt_mov->close();
    $conn->close();

    header("Location: ../movimientoCaja.php");
    exit;

} else {
    header("Location: ../movimientoCaja.php");
    exit;
}
?>
