<?php
// ============================================
// CONTROLADOR EMPRESA
// Guarda y actualiza los datos de la empresa
// ============================================

session_start();
require "../config/db.php";

// Solo aceptamos método POST (cuando se envía el formulario)
if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    // Capturamos los datos del formulario
    $nombre       = trim($_POST['nombre'] ?? '');
    $razon_social = trim($_POST['razon_social'] ?? '');
    $rtn          = trim($_POST['rtn'] ?? '');
    $telefono     = trim($_POST['telefono'] ?? '');
    $correo       = trim($_POST['correo'] ?? '');
    $direccion    = trim($_POST['direccion'] ?? '');

    // Validación básica: nombre obligatorio
    if (empty($nombre)) {
        $_SESSION['mensaje'] = "El nombre de la empresa es obligatorio.";
        $_SESSION['tipo']    = "danger";
        header("Location: ../empresa.php");
        exit;
    }

    // Actualizamos siempre el registro con id_empresa = 1
    $query = "
        UPDATE empresa
        SET
            nombre = ?,
            razon_social = ?,
            rtn = ?,
            telefono = ?,
            correo = ?,
            direccion = ?
        WHERE id_empresa = 1
    ";

    $stmt = $conn->prepare($query);
    $stmt->bind_param(
        "ssssss",
        $nombre,
        $razon_social,
        $rtn,
        $telefono,
        $correo,
        $direccion
    );

    if ($stmt->execute()) {
        // Mensaje de éxito
        $_SESSION['mensaje'] = "Datos de la empresa actualizados correctamente.";
        $_SESSION['tipo']    = "success";
    } else {
        // Mensaje de error
        $_SESSION['mensaje'] = "Error al actualizar los datos de la empresa.";
        $_SESSION['tipo']    = "danger";
    }

    $stmt->close();
    $conn->close();

    // Volvemos a la vista de empresa
    header("Location: ../empresa.php");
    exit;

} else {
    // Si no es POST, redirigimos a la vista
    header("Location: ../empresa.php");
    exit;
}
?>
