CREATE DATABASE IF NOT EXISTS db_kedai_kopi CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_kedai_kopi;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS coin_transactions, order_items, orders, menu_variants, menus, categories, operating_hours, users;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE users (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nama        VARCHAR(100) NOT NULL,
  email       VARCHAR(100) NOT NULL UNIQUE,
  no_hp       VARCHAR(20),
  password    VARCHAR(255) NOT NULL,
  role        ENUM('admin','kasir','pelanggan') NOT NULL DEFAULT 'pelanggan',
  saldo_coin  INT UNSIGNED NOT NULL DEFAULT 0,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE categories (
  id    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nama  VARCHAR(80) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE menus (
  id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  category_id  INT UNSIGNED NOT NULL,
  nama         VARCHAR(100) NOT NULL,
  harga        DECIMAL(12,2) NOT NULL,
  CONSTRAINT fk_menu_category FOREIGN KEY (category_id) REFERENCES categories(id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE menu_variants (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  menu_id       INT UNSIGNED NOT NULL,
  nama_varian   VARCHAR(80) NOT NULL,
  harga_tambah  DECIMAL(12,2) NOT NULL DEFAULT 0,
  CONSTRAINT fk_variant_menu FOREIGN KEY (menu_id) REFERENCES menus(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE operating_hours (
  id         TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  hari       ENUM('Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu') NOT NULL UNIQUE,
  jam_buka   TIME NOT NULL,
  jam_tutup  TIME NOT NULL,
  is_buka    TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE orders (
  id                 BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  pelanggan_id       BIGINT UNSIGNED NULL,
  kasir_id           BIGINT UNSIGNED NULL,
  sumber_pesanan     ENUM('qr_code','manual') NOT NULL DEFAULT 'qr_code',
  jenis_pesanan      ENUM('dine_in','take_away') NOT NULL,
  catatan            VARCHAR(255),
  metode_pembayaran  ENUM('tunai','non_tunai') NOT NULL,
  status             ENUM('menunggu','dikonfirmasi','ditolak','selesai') NOT NULL DEFAULT 'menunggu',
  subtotal           DECIMAL(12,2) NOT NULL DEFAULT 0,
  coin_digunakan     INT UNSIGNED NOT NULL DEFAULT 0,
  potongan_harga     DECIMAL(12,2) NOT NULL DEFAULT 0,
  total              DECIMAL(12,2) NOT NULL DEFAULT 0,
  created_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_order_pelanggan FOREIGN KEY (pelanggan_id) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_order_kasir FOREIGN KEY (kasir_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE order_items (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id    BIGINT UNSIGNED NOT NULL,
  menu_id     INT UNSIGNED NOT NULL,
  variant_id  INT UNSIGNED NULL,
  jumlah      INT UNSIGNED NOT NULL DEFAULT 1,
  harga       DECIMAL(12,2) NOT NULL,
  subtotal    DECIMAL(12,2) NOT NULL,
  CONSTRAINT fk_item_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  CONSTRAINT fk_item_menu FOREIGN KEY (menu_id) REFERENCES menus(id),
  CONSTRAINT fk_item_variant FOREIGN KEY (variant_id) REFERENCES menu_variants(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE coin_transactions (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id     BIGINT UNSIGNED NOT NULL,
  order_id    BIGINT UNSIGNED NULL,
  tipe        ENUM('didapat','ditukar','penyesuaian') NOT NULL,
  jumlah      INT NOT NULL,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_coin_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_coin_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE SET NULL
) ENGINE=InnoDB;
