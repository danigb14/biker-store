-- ============================================
-- APIGEST - Script completo de instalación
-- Ejecutar en MySQL Workbench o consola mysql
-- ============================================

CREATE DATABASE IF NOT EXISTS apigest CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE apigest;

-- ============================================
-- APIGEST - Esquema de base de datos (MySQL 8)
-- ============================================

CREATE TABLE categoria (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  slug VARCHAR(120) UNIQUE
) ENGINE=InnoDB;

CREATE TABLE marca (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE producto (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  sku VARCHAR(50) NOT NULL UNIQUE,
  nombre VARCHAR(200) NOT NULL,
  descripcion TEXT,
  categoria_id BIGINT UNSIGNED,
  marca_id BIGINT UNSIGNED,
  precio DECIMAL(10,2) NOT NULL DEFAULT 0,
  estado ENUM('disponible','bajo_stock','agotado') DEFAULT 'disponible',
  ecommerce_id VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (categoria_id) REFERENCES categoria(id),
  FOREIGN KEY (marca_id) REFERENCES marca(id),
  INDEX idx_ecommerce (ecommerce_id)
) ENGINE=InnoDB;

CREATE TABLE almacen (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  tipo ENUM('central','tienda','transito') DEFAULT 'tienda',
  ubicacion VARCHAR(200)
) ENGINE=InnoDB;

CREATE TABLE usuario (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  rol ENUM('admin','almacenista','consulta') DEFAULT 'almacenista',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE inventario (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  producto_id BIGINT UNSIGNED NOT NULL,
  almacen_id BIGINT UNSIGNED NOT NULL,
  cantidad INT NOT NULL DEFAULT 0,
  stock_minimo INT NOT NULL DEFAULT 0,
  FOREIGN KEY (producto_id) REFERENCES producto(id) ON DELETE CASCADE,
  FOREIGN KEY (almacen_id) REFERENCES almacen(id),
  UNIQUE KEY uk_producto_almacen (producto_id, almacen_id)
) ENGINE=InnoDB;

CREATE TABLE cliente (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL,
  email VARCHAR(150),
  telefono VARCHAR(30),
  direccion TEXT
) ENGINE=InnoDB;

CREATE TABLE pedido (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  ecommerce_order_id VARCHAR(50) UNIQUE,
  cliente_id BIGINT UNSIGNED,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  estado ENUM('pendiente','pagado','enviado','entregado','cancelado') DEFAULT 'pendiente',
  total DECIMAL(10,2) NOT NULL DEFAULT 0,
  FOREIGN KEY (cliente_id) REFERENCES cliente(id)
) ENGINE=InnoDB;

CREATE TABLE pedido_det (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  pedido_id BIGINT UNSIGNED NOT NULL,
  producto_id BIGINT UNSIGNED NOT NULL,
  cantidad INT NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,
  subtotal DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (pedido_id) REFERENCES pedido(id) ON DELETE CASCADE,
  FOREIGN KEY (producto_id) REFERENCES producto(id)
) ENGINE=InnoDB;

CREATE TABLE pago (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  pedido_id BIGINT UNSIGNED NOT NULL,
  monto DECIMAL(10,2) NOT NULL,
  metodo ENUM('tarjeta','transferencia','efectivo','paypal') NOT NULL,
  estado ENUM('pendiente','aprobado','rechazado','reembolsado') DEFAULT 'pendiente',
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (pedido_id) REFERENCES pedido(id)
) ENGINE=InnoDB;

CREATE TABLE envio (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  pedido_id BIGINT UNSIGNED NOT NULL,
  paqueteria VARCHAR(80),
  guia VARCHAR(80),
  estado ENUM('preparando','en_transito','entregado') DEFAULT 'preparando',
  direccion TEXT,
  FOREIGN KEY (pedido_id) REFERENCES pedido(id)
) ENGINE=InnoDB;

CREATE TABLE movimiento (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  folio VARCHAR(20) NOT NULL UNIQUE,
  producto_id BIGINT UNSIGNED NOT NULL,
  tipo ENUM('entrada','salida','ajuste','traspaso') NOT NULL,
  cantidad INT NOT NULL,
  almacen_origen_id BIGINT UNSIGNED NULL,
  almacen_destino_id BIGINT UNSIGNED NULL,
  pedido_id BIGINT UNSIGNED NULL,
  motivo VARCHAR(200),
  usuario_id BIGINT UNSIGNED,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (producto_id) REFERENCES producto(id),
  FOREIGN KEY (almacen_origen_id) REFERENCES almacen(id),
  FOREIGN KEY (almacen_destino_id) REFERENCES almacen(id),
  FOREIGN KEY (pedido_id) REFERENCES pedido(id),
  FOREIGN KEY (usuario_id) REFERENCES usuario(id),
  INDEX idx_fecha (fecha),
  INDEX idx_tipo (tipo)
) ENGINE=InnoDB;

CREATE TABLE proveedor (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL,
  contacto VARCHAR(150),
  email VARCHAR(150)
) ENGINE=InnoDB;

CREATE TABLE orden_compra (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  proveedor_id BIGINT UNSIGNED NOT NULL,
  usuario_id BIGINT UNSIGNED,
  fecha DATE NOT NULL,
  estado ENUM('borrador','enviada','recibida','cancelada') DEFAULT 'borrador',
  total DECIMAL(10,2) DEFAULT 0,
  FOREIGN KEY (proveedor_id) REFERENCES proveedor(id),
  FOREIGN KEY (usuario_id) REFERENCES usuario(id)
) ENGINE=InnoDB;

CREATE TABLE orden_compra_det (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  orden_compra_id BIGINT UNSIGNED NOT NULL,
  producto_id BIGINT UNSIGNED NOT NULL,
  cantidad INT NOT NULL,
  costo_unitario DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (orden_compra_id) REFERENCES orden_compra(id) ON DELETE CASCADE,
  FOREIGN KEY (producto_id) REFERENCES producto(id)
) ENGINE=InnoDB;