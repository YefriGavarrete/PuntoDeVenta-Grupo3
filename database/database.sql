CREATE DATABASE IF NOT EXISTS punto_venta
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE punto_venta;

-- =====================================================
-- ROLES Y PERMISOS
-- =====================================================

CREATE TABLE IF NOT EXISTS roles (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(255),
    estado TINYINT(1) NOT NULL DEFAULT 1,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS permisos (
    id_permiso INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(255),
    estado TINYINT(1) NOT NULL DEFAULT 1,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS roles_permisos (
    id_rol INT NOT NULL,
    id_permiso INT NOT NULL,
    PRIMARY KEY (id_rol, id_permiso),

    CONSTRAINT fk_roles_permisos_rol
        FOREIGN KEY (id_rol)
        REFERENCES roles(id_rol)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_roles_permisos_permiso
        FOREIGN KEY (id_permiso)
        REFERENCES permisos(id_permiso)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- =====================================================
-- USUARIOS
-- =====================================================

CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    usuario VARCHAR(100) NOT NULL UNIQUE,
    correo VARCHAR(150) UNIQUE,
    password VARCHAR(255) NOT NULL,
    id_rol INT NOT NULL,
    estado TINYINT(1) NOT NULL DEFAULT 1,
    ultimo_acceso DATETIME NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_usuarios_roles
        FOREIGN KEY (id_rol)
        REFERENCES roles(id_rol)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- =====================================================
-- INVENTARIO Y CLIENTES
-- =====================================================

CREATE TABLE IF NOT EXISTS categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    categoria VARCHAR(150) NOT NULL UNIQUE,
    descripcion VARCHAR(255),
    estado TINYINT(1) NOT NULL DEFAULT 1,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion DATETIME NULL ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS proveedores (
    id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL,
    empresa VARCHAR(200),
    identidad VARCHAR(50) UNIQUE,
    telefono VARCHAR(50),
    correo VARCHAR(150),
    direccion TEXT,
    estado TINYINT(1) NOT NULL DEFAULT 1,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion DATETIME NULL ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(100) UNIQUE,
    codigo_barras VARCHAR(100) UNIQUE,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    id_categoria INT NOT NULL,
    precio_costo DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    stock DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    stock_minimo DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    stock_maximo DECIMAL(12,2) NULL,
    unidad_medida VARCHAR(50) NOT NULL DEFAULT 'Unidad',
    tipo ENUM('Producto','Servicio') NOT NULL DEFAULT 'Producto',
    imagen VARCHAR(255) NULL,
    estado TINYINT(1) NOT NULL DEFAULT 1,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_productos_categorias
        FOREIGN KEY (id_categoria)
        REFERENCES categorias(id_categoria)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL,
    identidad VARCHAR(50) UNIQUE,
    telefono VARCHAR(50),
    correo VARCHAR(50),
    direccion TEXT,
    limite_credito DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    saldo_credito DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    estado TINYINT(1) NOT NULL DEFAULT 1,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion DATETIME NULL ON UPDATE CURRENT_TIMESTAMP
);

-- =====================================================
-- CAJA Y FORMAS DE PAGO
-- =====================================================

CREATE TABLE IF NOT EXISTS formas_pago (
    id_forma_pago INT AUTO_INCREMENT PRIMARY KEY,
    forma_pago VARCHAR(100) NOT NULL UNIQUE,
    estado TINYINT(1) NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS cajas (
    id_caja INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(255),
    estado TINYINT(1) NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS aperturas_caja (
    id_apertura INT AUTO_INCREMENT PRIMARY KEY,
    id_caja INT NOT NULL,
    id_usuario INT NOT NULL,
    fecha_apertura DATETIME NOT NULL,
    fecha_cierre DATETIME NULL,
    monto_inicial DECIMAL(12,2) NOT NULL,
    monto_final DECIMAL(12,2) DEFAULT NULL,
    diferencia DECIMAL(12,2) DEFAULT 0.00,
    estado ENUM('ABIERTA','CERRADA') NOT NULL DEFAULT 'ABIERTA',
    observacion TEXT,

    CONSTRAINT fk_aperturas_caja
        FOREIGN KEY (id_caja)
        REFERENCES cajas(id_caja),

    CONSTRAINT fk_aperturas_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuarios(id_usuario)
);

-- =====================================================
-- VENTAS
-- =====================================================

CREATE TABLE IF NOT EXISTS ventas (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    numero_factura VARCHAR(30) NOT NULL UNIQUE,
    id_cliente INT NULL,
    id_usuario INT NOT NULL,
    id_apertura INT NOT NULL,
    fecha DATETIME NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    id_forma_pago INT NOT NULL,
    referencia VARCHAR(100),
    banco VARCHAR(100),
    estado ENUM('ACTIVA','ANULADA') NOT NULL DEFAULT 'ACTIVA',

    CONSTRAINT fk_ventas_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES clientes(id_cliente),

    CONSTRAINT fk_ventas_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuarios(id_usuario),

    CONSTRAINT fk_ventas_apertura
        FOREIGN KEY (id_apertura)
        REFERENCES aperturas_caja(id_apertura),

    CONSTRAINT fk_ventas_forma_pago
        FOREIGN KEY (id_forma_pago)
        REFERENCES formas_pago(id_forma_pago)
);

CREATE TABLE IF NOT EXISTS detalle_ventas (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    precio DECIMAL(12,2) NOT NULL,
    impuesto DECIMAL(12,2) DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL,

    CONSTRAINT fk_detalle_venta
        FOREIGN KEY (id_venta)
        REFERENCES ventas(id_venta),

    CONSTRAINT fk_detalle_producto
        FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto)
);

CREATE TABLE IF NOT EXISTS movimientos_caja (
    id_movimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_apertura INT NOT NULL,
    tipo ENUM('INGRESO','EGRESO') NOT NULL,
    descripcion TEXT NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_usuario INT NOT NULL,

    CONSTRAINT fk_movimientos_apertura
        FOREIGN KEY (id_apertura)
        REFERENCES aperturas_caja(id_apertura),

    CONSTRAINT fk_movimientos_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuarios(id_usuario)
);

-- =====================================================
-- EMPRESA
-- =====================================================

CREATE TABLE IF NOT EXISTS empresa (
    id_empresa INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    razon_social VARCHAR(150),
    nombre_comercial VARCHAR(150),
    rtn VARCHAR(50),
    telefono VARCHAR(20),
    correo VARCHAR(100),
    departamento VARCHAR(100),
    municipio VARCHAR(100),
    direccion TEXT,
    logo VARCHAR(255),
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado CHAR(1) DEFAULT 'A'
);

-- =====================================================
-- DATOS INICIALES
-- =====================================================

INSERT IGNORE INTO roles (nombre, descripcion) VALUES
('Administrador', 'Acceso total al sistema'),
('Cajero', 'Realiza ventas y operaciones de caja'),
('Supervisor', 'Supervisa operaciones y reportes');

INSERT IGNORE INTO permisos (nombre, descripcion) VALUES
('usuarios_ver', 'Ver usuarios'),
('usuarios_crear', 'Crear usuarios'),
('usuarios_editar', 'Editar usuarios'),
('usuarios_eliminar', 'Eliminar usuarios'),
('roles_ver', 'Ver roles'),
('roles_crear', 'Crear roles'),
('roles_editar', 'Editar roles'),
('roles_eliminar', 'Eliminar roles'),
('categorias_ver', 'Ver categorías'),
('categorias_crear', 'Crear categorías'),
('categorias_editar', 'Editar categorías'),
('categorias_eliminar', 'Eliminar categorías'),
('productos_ver', 'Ver productos'),
('productos_crear', 'Crear productos'),
('productos_editar', 'Editar productos'),
('productos_eliminar', 'Eliminar productos'),
('clientes_ver', 'Ver clientes'),
('clientes_crear', 'Crear clientes'),
('clientes_editar', 'Editar clientes'),
('clientes_eliminar', 'Eliminar clientes'),
('proveedores_ver', 'Ver proveedores'),
('proveedores_crear', 'Crear proveedores'),
('proveedores_editar', 'Editar proveedores'),
('proveedores_eliminar', 'Eliminar proveedores'),
('ventas_ver', 'Ver ventas'),
('ventas_crear', 'Crear ventas'),
('ventas_editar', 'Editar ventas'),
('ventas_anular', 'Anular ventas'),
('caja_ver', 'Ver caja'),
('caja_abrir', 'Abrir caja'),
('caja_cerrar', 'Cerrar caja'),
('caja_movimientos', 'Registrar movimientos de caja'),
('reportes_ver', 'Ver reportes'),
('reportes_exportar', 'Exportar reportes'),
('empresa_ver', 'Ver datos de la empresa'),
('empresa_editar', 'Editar datos de la empresa');

-- El Administrador recibe todos los permisos.
INSERT IGNORE INTO roles_permisos (id_rol, id_permiso)
SELECT r.id_rol, p.id_permiso
FROM roles r
CROSS JOIN permisos p
WHERE r.nombre = 'Administrador';

-- Permisos del Cajero.
INSERT IGNORE INTO roles_permisos (id_rol, id_permiso)
SELECT r.id_rol, p.id_permiso
FROM roles r
INNER JOIN permisos p
    ON p.nombre IN (
        'clientes_ver', 'clientes_crear',
        'ventas_ver', 'ventas_crear',
        'caja_ver', 'caja_abrir', 'caja_cerrar', 'caja_movimientos'
    )
WHERE r.nombre = 'Cajero';

-- Permisos del Supervisor.
INSERT IGNORE INTO roles_permisos (id_rol, id_permiso)
SELECT r.id_rol, p.id_permiso
FROM roles r
INNER JOIN permisos p
    ON p.nombre IN (
        'categorias_ver', 'categorias_crear', 'categorias_editar', 'categorias_eliminar',
        'productos_ver', 'productos_crear', 'productos_editar', 'productos_eliminar',
        'clientes_ver', 'clientes_crear', 'clientes_editar', 'clientes_eliminar',
        'proveedores_ver', 'proveedores_crear', 'proveedores_editar', 'proveedores_eliminar',
        'ventas_ver', 'ventas_crear', 'ventas_anular',
        'reportes_ver', 'reportes_exportar'
    )
WHERE r.nombre = 'Supervisor';

INSERT IGNORE INTO categorias (categoria, descripcion) VALUES
('General', 'Categoría general de productos');

INSERT INTO formas_pago (forma_pago)
SELECT 'Efectivo'
WHERE NOT EXISTS (SELECT 1 FROM formas_pago WHERE forma_pago = 'Efectivo');

INSERT INTO formas_pago (forma_pago)
SELECT 'Tarjeta'
WHERE NOT EXISTS (SELECT 1 FROM formas_pago WHERE forma_pago = 'Tarjeta');

INSERT INTO formas_pago (forma_pago)
SELECT 'Transferencia'
WHERE NOT EXISTS (SELECT 1 FROM formas_pago WHERE forma_pago = 'Transferencia');

INSERT INTO formas_pago (forma_pago)
SELECT 'Crédito'
WHERE NOT EXISTS (SELECT 1 FROM formas_pago WHERE forma_pago = 'Crédito');

INSERT INTO cajas (nombre, descripcion)
SELECT 'Caja Principal', 'Caja principal del negocio'
WHERE NOT EXISTS (SELECT 1 FROM cajas WHERE nombre = 'Caja Principal');

INSERT IGNORE INTO usuarios
    (nombre, usuario, correo, password, id_rol)
SELECT
    'Administrador',
    'admin',
    'admin@localhost.com',
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llCkLz2O9Z2y4G2JZr3W',
    r.id_rol
FROM roles r
WHERE r.nombre = 'Administrador';
