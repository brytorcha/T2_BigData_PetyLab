USE master;
GO

IF DB_ID(N'PetyLab_DW') IS NULL
BEGIN
    CREATE DATABASE PetyLab_DW;
END;
GO

USE PetyLab_DW;
GO

-- ====================================================
-- DIMENSIONES
-- ====================================================
IF OBJECT_ID(N'dbo.DimTiempo', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimTiempo (
        id_Tiempo INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DimTiempo PRIMARY KEY,
        fecha DATE NOT NULL,
        hora TIME NULL,
        dia TINYINT NOT NULL,
        NombreDia NVARCHAR(15) NOT NULL,
        mes TINYINT NOT NULL,
        NombreMes NVARCHAR(15) NOT NULL,
        trimestre TINYINT NOT NULL,
        bimestre TINYINT NOT NULL,
        semestre TINYINT NOT NULL,
        año SMALLINT NOT NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.DimCliente', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimCliente (
        id_Cliente INT NOT NULL CONSTRAINT PK_DimCliente PRIMARY KEY,
        dni NVARCHAR(20) NOT NULL,
        apellidoMa NVARCHAR(80) NOT NULL,
        apellidoPa NVARCHAR(80) NOT NULL,
        Nombre NVARCHAR(80) NOT NULL,
        Telefono NVARCHAR(30) NULL,
        Direccion NVARCHAR(200) NULL,
        fecha_registro DATE NOT NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.DimMascota', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimMascota (
        id_Mascota INT NOT NULL CONSTRAINT PK_DimMascota PRIMARY KEY,
        Nombre NVARCHAR(80) NOT NULL,
        FechaNac DATE NULL,
        Sexo NVARCHAR(30) NOT NULL,
        Raza NVARCHAR(80) NOT NULL,
        Especie NVARCHAR(80) NOT NULL,
        Color NVARCHAR(50) NOT NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.DimEmpleado', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimEmpleado (
        Id_Empleado INT NOT NULL CONSTRAINT PK_DimEmpleado PRIMARY KEY,
        Nombre NVARCHAR(80) NOT NULL,
        Apellido NVARCHAR(80) NOT NULL,
        Cargo NVARCHAR(80) NOT NULL,
        Usuario NVARCHAR(50) NOT NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.DimUbicacion', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimUbicacion (
        Id_Ubicacion INT NOT NULL CONSTRAINT PK_DimUbicacion PRIMARY KEY,
        Departamento NVARCHAR(80) NOT NULL,
        Provincia NVARCHAR(80) NOT NULL,
        Distrito NVARCHAR(80) NOT NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.DimServicio', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimServicio (
        Id_Servicio INT NOT NULL CONSTRAINT PK_DimServicio PRIMARY KEY,
        Nombre NVARCHAR(80) NOT NULL,
        Categoria NVARCHAR(50) NOT NULL,
        Precio_Base DECIMAL(10,2) NOT NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.DimMetodoPago', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimMetodoPago (
        Id_MetodoPago INT NOT NULL CONSTRAINT PK_DimMetodoPago PRIMARY KEY,
        Descripcion NVARCHAR(50) NOT NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.DimProducto', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimProducto (
        Id_Producto INT NOT NULL CONSTRAINT PK_DimProducto PRIMARY KEY,
        Nombre NVARCHAR(100) NOT NULL,
        Categoria NVARCHAR(50) NOT NULL,
        Precio_Venta DECIMAL(10,2) NOT NULL,
        Costo DECIMAL(10,2) NOT NULL,
        Stock_Minimo INT NOT NULL
    );
END;
GO

-- Id_Promocion = 0 representa "Sin Promocion"
IF OBJECT_ID(N'dbo.DimPromocion', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimPromocion (
        Id_Promocion INT NOT NULL CONSTRAINT PK_DimPromocion PRIMARY KEY,
        Nombre NVARCHAR(100) NOT NULL,
        Categoria_Objetivo NVARCHAR(50) NOT NULL,
        Porcentaje_Descuento DECIMAL(5,2) NOT NULL,
        Fecha_Inicio DATE NULL,
        Fecha_Fin DATE NULL
    );
END;
GO

-- ====================================================
-- TABLAS DE HECHOS
-- ====================================================
IF OBJECT_ID(N'dbo.Fact_Cita', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Fact_Cita (
        Id_Fact_Cita INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Fact_Cita PRIMARY KEY,
        Id_Tiempo INT NOT NULL,
        Id_Cliente INT NOT NULL,
        Id_Mascota INT NOT NULL,
        Id_Empleado INT NOT NULL,
        Id_Ubicacion INT NOT NULL,
        Cantidad_Citas INT NOT NULL CONSTRAINT DF_Fact_Cant_Citas DEFAULT (1),
        Cantidad_Atenciones INT NOT NULL CONSTRAINT DF_Fact_Cant_Aten DEFAULT (0),
        Citas_Canceladas INT NOT NULL CONSTRAINT DF_Fact_Citas_Canc DEFAULT (0),
        Monto_Total DECIMAL(10,2) NULL,
        CONSTRAINT FK_Fact_Cita_Tiempo    FOREIGN KEY (Id_Tiempo)    REFERENCES dbo.DimTiempo(id_Tiempo),
        CONSTRAINT FK_Fact_Cita_Cliente   FOREIGN KEY (Id_Cliente)   REFERENCES dbo.DimCliente(id_Cliente),
        CONSTRAINT FK_Fact_Cita_Mascota   FOREIGN KEY (Id_Mascota)   REFERENCES dbo.DimMascota(id_Mascota),
        CONSTRAINT FK_Fact_Cita_Empleado  FOREIGN KEY (Id_Empleado)  REFERENCES dbo.DimEmpleado(Id_Empleado),
        CONSTRAINT FK_Fact_Cita_Ubicacion FOREIGN KEY (Id_Ubicacion) REFERENCES dbo.DimUbicacion(Id_Ubicacion)
    );
END;
GO

-- Fact_Venta:
IF OBJECT_ID(N'dbo.Fact_Venta', N'U') IS NOT NULL
   AND COL_LENGTH(N'dbo.Fact_Venta', N'Id_Promocion') IS NULL
BEGIN
    DROP TABLE dbo.Fact_Venta;
END;
GO

IF OBJECT_ID(N'dbo.Fact_Venta', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Fact_Venta (
        Id_Fact_Venta INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Fact_Venta PRIMARY KEY,
        Id_Tiempo INT NOT NULL,
        Id_Cliente INT NOT NULL,
        Id_Mascota INT NOT NULL,
        Id_Empleado INT NOT NULL,
        Id_Ubicacion INT NOT NULL,
        Id_Servicio INT NOT NULL,
        Id_MetodoPago INT NOT NULL,
        Id_Promocion INT NOT NULL CONSTRAINT DF_Fact_Venta_Promo DEFAULT (0),
        Cantidad INT NOT NULL,
        Precio_Unitario DECIMAL(10,2) NOT NULL,
        Descuento DECIMAL(10,2) NOT NULL CONSTRAINT DF_Fact_Venta_Desc DEFAULT (0),
        Monto_Bruto DECIMAL(10,2) NOT NULL,
        Monto_Neto DECIMAL(10,2) NOT NULL,
        CONSTRAINT FK_Fact_Venta_Tiempo    FOREIGN KEY (Id_Tiempo)     REFERENCES dbo.DimTiempo(id_Tiempo),
        CONSTRAINT FK_Fact_Venta_Cliente   FOREIGN KEY (Id_Cliente)    REFERENCES dbo.DimCliente(id_Cliente),
        CONSTRAINT FK_Fact_Venta_Mascota   FOREIGN KEY (Id_Mascota)    REFERENCES dbo.DimMascota(id_Mascota),
        CONSTRAINT FK_Fact_Venta_Empleado  FOREIGN KEY (Id_Empleado)   REFERENCES dbo.DimEmpleado(Id_Empleado),
        CONSTRAINT FK_Fact_Venta_Ubicacion FOREIGN KEY (Id_Ubicacion)  REFERENCES dbo.DimUbicacion(Id_Ubicacion),
        CONSTRAINT FK_Fact_Venta_Servicio  FOREIGN KEY (Id_Servicio)   REFERENCES dbo.DimServicio(Id_Servicio),
        CONSTRAINT FK_Fact_Venta_Metodo    FOREIGN KEY (Id_MetodoPago) REFERENCES dbo.DimMetodoPago(Id_MetodoPago),
        CONSTRAINT FK_Fact_Venta_Promo     FOREIGN KEY (Id_Promocion)  REFERENCES dbo.DimPromocion(Id_Promocion)
    );
END;
GO

IF OBJECT_ID(N'dbo.Fact_Venta_Producto', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Fact_Venta_Producto (
        Id_Fact_Venta_Producto INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Fact_Venta_Producto PRIMARY KEY,
        Id_Tiempo INT NOT NULL,
        Id_Cliente INT NOT NULL,
        Id_Mascota INT NOT NULL,
        Id_Empleado INT NOT NULL,
        Id_Ubicacion INT NOT NULL,
        Id_Producto INT NOT NULL,
        Id_MetodoPago INT NOT NULL,
        Id_Promocion INT NOT NULL CONSTRAINT DF_FVP_Promo DEFAULT (0),
        Cantidad INT NOT NULL,
        Precio_Unitario DECIMAL(10,2) NOT NULL,
        Costo_Unitario DECIMAL(10,2) NOT NULL,
        Descuento DECIMAL(10,2) NOT NULL CONSTRAINT DF_FVP_Desc DEFAULT (0),
        Monto_Bruto DECIMAL(10,2) NOT NULL,
        Monto_Neto DECIMAL(10,2) NOT NULL,
        Margen_Bruto DECIMAL(10,2) NOT NULL,
        CONSTRAINT FK_FVP_Tiempo    FOREIGN KEY (Id_Tiempo)     REFERENCES dbo.DimTiempo(id_Tiempo),
        CONSTRAINT FK_FVP_Cliente   FOREIGN KEY (Id_Cliente)    REFERENCES dbo.DimCliente(id_Cliente),
        CONSTRAINT FK_FVP_Mascota   FOREIGN KEY (Id_Mascota)    REFERENCES dbo.DimMascota(id_Mascota),
        CONSTRAINT FK_FVP_Empleado  FOREIGN KEY (Id_Empleado)   REFERENCES dbo.DimEmpleado(Id_Empleado),
        CONSTRAINT FK_FVP_Ubicacion FOREIGN KEY (Id_Ubicacion)  REFERENCES dbo.DimUbicacion(Id_Ubicacion),
        CONSTRAINT FK_FVP_Producto  FOREIGN KEY (Id_Producto)   REFERENCES dbo.DimProducto(Id_Producto),
        CONSTRAINT FK_FVP_Metodo    FOREIGN KEY (Id_MetodoPago) REFERENCES dbo.DimMetodoPago(Id_MetodoPago),
        CONSTRAINT FK_FVP_Promo     FOREIGN KEY (Id_Promocion)  REFERENCES dbo.DimPromocion(Id_Promocion)
    );
END;
GO

-- Cantidad_Neta: positiva en entradas, negativa en salidas (stock = SUM)
IF OBJECT_ID(N'dbo.Fact_Inventario', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Fact_Inventario (
        Id_Fact_Inventario INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Fact_Inventario PRIMARY KEY,
        Id_Tiempo INT NOT NULL,
        Id_Producto INT NOT NULL,
        Tipo_Movimiento NVARCHAR(10) NOT NULL,
        Cantidad INT NOT NULL,
        Cantidad_Neta INT NOT NULL,
        Costo_Unitario DECIMAL(10,2) NOT NULL,
        Valor_Movimiento DECIMAL(12,2) NOT NULL,
        CONSTRAINT FK_FInv_Tiempo   FOREIGN KEY (Id_Tiempo)   REFERENCES dbo.DimTiempo(id_Tiempo),
        CONSTRAINT FK_FInv_Producto FOREIGN KEY (Id_Producto) REFERENCES dbo.DimProducto(Id_Producto)
    );
END;
GO

-- Id_Tiempo apunta al primer dia del mes de la meta
IF OBJECT_ID(N'dbo.Fact_Meta_Venta', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Fact_Meta_Venta (
        Id_Fact_Meta INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Fact_Meta_Venta PRIMARY KEY,
        Id_Tiempo INT NOT NULL,
        Id_Ubicacion INT NOT NULL,
        Monto_Meta DECIMAL(10,2) NOT NULL,
        CONSTRAINT FK_FMeta_Tiempo    FOREIGN KEY (Id_Tiempo)    REFERENCES dbo.DimTiempo(id_Tiempo),
        CONSTRAINT FK_FMeta_Ubicacion FOREIGN KEY (Id_Ubicacion) REFERENCES dbo.DimUbicacion(Id_Ubicacion)
    );
END;
GO

-- ====================================================
-- VERIFICACION
-- ====================================================
SELECT N'PetyLab_DW creado correctamente' AS resultado;

SELECT TABLE_NAME DIMENSIONES 
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

SELECT name AS ClaveForanea FROM sys.foreign_keys ORDER BY name;
GO
SELECT 'Fact_Cita' AS tabla, COUNT(*) AS filas FROM dbo.Fact_Cita
UNION ALL SELECT 'Fact_Venta', COUNT(*) FROM dbo.Fact_Venta
UNION ALL SELECT 'Fact_Venta_Producto', COUNT(*) FROM dbo.Fact_Venta_Producto
UNION ALL SELECT 'Fact_Inventario', COUNT(*) FROM dbo.Fact_Inventario
UNION ALL SELECT 'Fact_Meta_Venta', COUNT(*) FROM dbo.Fact_Meta_Venta;
go
SELECT 'DimCliente' AS tabla, COUNT(*) AS filas FROM dbo.DimCliente
UNION ALL SELECT 'DimMascota', COUNT(*) FROM dbo.DimMascota
UNION ALL SELECT 'DimEmpleado', COUNT(*) FROM dbo.DimEmpleado
UNION ALL SELECT 'DimUbicacion', COUNT(*) FROM dbo.DimUbicacion
UNION ALL SELECT 'DimServicio', COUNT(*) FROM dbo.DimServicio
UNION ALL SELECT 'DimMetodoPago', COUNT(*) FROM dbo.DimMetodoPago
UNION ALL SELECT 'DimProducto', COUNT(*) FROM dbo.DimProducto
UNION ALL SELECT 'DimPromocion', COUNT(*) FROM dbo.DimPromocion
UNION ALL SELECT 'DimTiempo', COUNT(*) FROM dbo.DimTiempo
UNION ALL SELECT 'Fact_Cita', COUNT(*) FROM dbo.Fact_Cita
UNION ALL SELECT 'Fact_Venta', COUNT(*) FROM dbo.Fact_Venta
UNION ALL SELECT 'Fact_Venta_Producto', COUNT(*) FROM dbo.Fact_Venta_Producto
UNION ALL SELECT 'Fact_Inventario', COUNT(*) FROM dbo.Fact_Inventario
UNION ALL SELECT 'Fact_Meta_Venta', COUNT(*) FROM dbo.Fact_Meta_Venta;
GO
SELECT
  (SELECT COUNT(*) FROM PETYLAB.dbo.CITA)                  AS Citas_Origen,
  (SELECT COUNT(*) FROM dbo.Fact_Cita)                     AS Citas_DW,
  (SELECT COUNT(*) FROM PETYLAB.dbo.DETALLE_CITA)          AS DetCita_Origen,
  (SELECT COUNT(*) FROM dbo.Fact_Venta)                    AS Venta_DW,
  (SELECT COUNT(*) FROM PETYLAB.dbo.DETALLE_PRODUCTO)      AS DetProd_Origen,
  (SELECT COUNT(*) FROM dbo.Fact_Venta_Producto)           AS VentaProd_DW,
  (SELECT COUNT(*) FROM PETYLAB.dbo.MOVIMIENTO_INVENTARIO) AS Mov_Origen,
  (SELECT COUNT(*) FROM dbo.Fact_Inventario)               AS Mov_DW,
  (SELECT SUM(Monto_Total) FROM dbo.Fact_Cita)             AS Facturacion_FactCita,
  (SELECT SUM(Monto_Neto) FROM dbo.Fact_Venta)
    + (SELECT ISNULL(SUM(Monto_Neto),0) FROM dbo.Fact_Venta_Producto) AS Facturacion_Ventas,
  (SELECT SUM(monto_pagado) FROM PETYLAB.dbo.PAGO)         AS Pagos_Origen;