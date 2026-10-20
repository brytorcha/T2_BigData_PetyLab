/*
    Esquema inicial de PETYLAB
    Reconstruido a partir de VeterinariaService.java y los DTO del proyecto.

    Ejecutar este archivo conectado a la instancia de SQL Server que usa el
    proyecto. El script no elimina una base existente.
*/

IF DB_ID(N'PETYLAB') IS NULL
BEGIN
    CREATE DATABASE PETYLAB;
END;
GO

USE PETYLAB;
GO

IF OBJECT_ID(N'dbo.EMPLEADO', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.EMPLEADO (
        id_empleado INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_EMPLEADO PRIMARY KEY,
        nombre NVARCHAR(80) NOT NULL,
        apellido NVARCHAR(80) NOT NULL,
        cargo NVARCHAR(80) NOT NULL,
        usuario NVARCHAR(50) NOT NULL CONSTRAINT UQ_EMPLEADO_USUARIO UNIQUE,
        clave NVARCHAR(255) NOT NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.CLIENTE', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.CLIENTE (
        id_cliente INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_CLIENTE PRIMARY KEY,
        dni NVARCHAR(20) NOT NULL CONSTRAINT UQ_CLIENTE_DNI UNIQUE,
        apellido_paterno NVARCHAR(80) NOT NULL,
        apellido_materno NVARCHAR(80) NOT NULL,
        nombre NVARCHAR(80) NOT NULL,
        telefono NVARCHAR(30) NULL,
        direccion NVARCHAR(200) NULL,
        fecha_registro DATE NOT NULL CONSTRAINT DF_CLIENTE_FECHA DEFAULT (CONVERT(date, GETDATE())),
        ESTADO BIT NOT NULL CONSTRAINT DF_CLIENTE_ESTADO DEFAULT (1)
    );
END;
GO

IF OBJECT_ID(N'dbo.ESPECIE', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ESPECIE (
        id_especie INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ESPECIE PRIMARY KEY,
        nombre_especie NVARCHAR(80) NOT NULL CONSTRAINT UQ_ESPECIE_NOMBRE UNIQUE
    );
END;
GO

IF OBJECT_ID(N'dbo.RAZA', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.RAZA (
        id_raza INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_RAZA PRIMARY KEY,
        nombre_raza NVARCHAR(80) NOT NULL,
        id_especie INT NOT NULL,
        CONSTRAINT FK_RAZA_ESPECIE FOREIGN KEY (id_especie) REFERENCES dbo.ESPECIE(id_especie),
        CONSTRAINT UQ_RAZA_ESPECIE_NOMBRE UNIQUE (id_especie, nombre_raza)
    );
END;
GO

IF OBJECT_ID(N'dbo.SEXO', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.SEXO (
        id_sexo INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_SEXO PRIMARY KEY,
        descripcion NVARCHAR(30) NOT NULL CONSTRAINT UQ_SEXO_DESCRIPCION UNIQUE
    );
END;
GO

IF OBJECT_ID(N'dbo.COLOR', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.COLOR (
        id_color INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_COLOR PRIMARY KEY,
        descripcion NVARCHAR(50) NOT NULL CONSTRAINT UQ_COLOR_DESCRIPCION UNIQUE
    );
END;
GO

IF OBJECT_ID(N'dbo.UBICACION', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.UBICACION (
        id_ubicacion INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_UBICACION PRIMARY KEY,
        departamento NVARCHAR(80) NOT NULL,
        provincia NVARCHAR(80) NOT NULL,
        distrito NVARCHAR(80) NOT NULL,
        ubigeo NVARCHAR(10) NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.MASCOTA', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.MASCOTA (
        id_mascota INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_MASCOTA PRIMARY KEY,
        nombre NVARCHAR(80) NOT NULL,
        fecha_nacimiento DATE NULL,
        id_cliente INT NOT NULL,
        id_raza INT NOT NULL,
        id_sexo INT NOT NULL,
        id_color INT NOT NULL,
        id_ubicacion INT NOT NULL,
        ESTADO BIT NOT NULL CONSTRAINT DF_MASCOTA_ESTADO DEFAULT (1),
        CONSTRAINT FK_MASCOTA_CLIENTE FOREIGN KEY (id_cliente) REFERENCES dbo.CLIENTE(id_cliente),
        CONSTRAINT FK_MASCOTA_RAZA FOREIGN KEY (id_raza) REFERENCES dbo.RAZA(id_raza),
        CONSTRAINT FK_MASCOTA_SEXO FOREIGN KEY (id_sexo) REFERENCES dbo.SEXO(id_sexo),
        CONSTRAINT FK_MASCOTA_COLOR FOREIGN KEY (id_color) REFERENCES dbo.COLOR(id_color),
        CONSTRAINT FK_MASCOTA_UBICACION FOREIGN KEY (id_ubicacion) REFERENCES dbo.UBICACION(id_ubicacion)
    );
END;
GO

IF OBJECT_ID(N'dbo.CITA', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.CITA (
        id_cita INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_CITA PRIMARY KEY,
        fecha_cita DATE NOT NULL,
        hora_cita TIME NOT NULL,
        motivo NVARCHAR(250) NOT NULL,
        estado NVARCHAR(30) NOT NULL,
        id_mascota INT NOT NULL,
        id_empleado INT NOT NULL,
        ESTADO_ACTIVO BIT NOT NULL CONSTRAINT DF_CITA_ESTADO_ACTIVO DEFAULT (1),
        CONSTRAINT FK_CITA_MASCOTA FOREIGN KEY (id_mascota) REFERENCES dbo.MASCOTA(id_mascota),
        CONSTRAINT FK_CITA_EMPLEADO FOREIGN KEY (id_empleado) REFERENCES dbo.EMPLEADO(id_empleado)
    );
END;
GO

IF OBJECT_ID(N'dbo.VACUNA', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.VACUNA (
        id_vacuna INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_VACUNA PRIMARY KEY,
        nombre NVARCHAR(100) NOT NULL CONSTRAINT UQ_VACUNA_NOMBRE UNIQUE,
        descripcion NVARCHAR(250) NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.VACUNACION', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.VACUNACION (
        id_vacunacion INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_VACUNACION PRIMARY KEY,
        fecha_aplicacion DATE NOT NULL,
        id_mascota INT NOT NULL,
        id_vacuna INT NOT NULL,
        ESTADO BIT NOT NULL CONSTRAINT DF_VACUNACION_ESTADO DEFAULT (1),
        CONSTRAINT FK_VACUNACION_MASCOTA FOREIGN KEY (id_mascota) REFERENCES dbo.MASCOTA(id_mascota),
        CONSTRAINT FK_VACUNACION_VACUNA FOREIGN KEY (id_vacuna) REFERENCES dbo.VACUNA(id_vacuna)
    );
END;
GO

/* Datos mínimos para que los combos de la aplicación funcionen. */
IF NOT EXISTS (SELECT 1 FROM dbo.EMPLEADO WHERE usuario = N'admin')
    INSERT INTO dbo.EMPLEADO (nombre, apellido, cargo, usuario, clave)
    VALUES (N'Administrador', N'PETYLAB', N'Administrador', N'admin', N'admin123');

IF NOT EXISTS (SELECT 1 FROM dbo.ESPECIE WHERE nombre_especie = N'Perro')
    INSERT INTO dbo.ESPECIE (nombre_especie) VALUES (N'Perro');
IF NOT EXISTS (SELECT 1 FROM dbo.ESPECIE WHERE nombre_especie = N'Gato')
    INSERT INTO dbo.ESPECIE (nombre_especie) VALUES (N'Gato');

IF NOT EXISTS (SELECT 1 FROM dbo.RAZA WHERE nombre_raza = N'Mestizo')
    INSERT INTO dbo.RAZA (nombre_raza, id_especie)
    SELECT N'Mestizo', id_especie FROM dbo.ESPECIE WHERE nombre_especie = N'Perro';

IF NOT EXISTS (SELECT 1 FROM dbo.SEXO WHERE descripcion = N'Macho')
    INSERT INTO dbo.SEXO (descripcion) VALUES (N'Macho');
IF NOT EXISTS (SELECT 1 FROM dbo.SEXO WHERE descripcion = N'Hembra')
    INSERT INTO dbo.SEXO (descripcion) VALUES (N'Hembra');

IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Negro')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Negro');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Blanco')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Blanco');

IF NOT EXISTS (SELECT 1 FROM dbo.UBICACION WHERE ubigeo = N'150101')
    INSERT INTO dbo.UBICACION (departamento, provincia, distrito, ubigeo)
    VALUES (N'Lima', N'Lima', N'Lima', N'150101');

IF NOT EXISTS (SELECT 1 FROM dbo.VACUNA WHERE nombre = N'Antirrábica')
    INSERT INTO dbo.VACUNA (nombre, descripcion)
    VALUES (N'Antirrábica', N'Vacuna contra la rabia');
IF NOT EXISTS (SELECT 1 FROM dbo.VACUNA WHERE nombre = N'Quíntuple')
    INSERT INTO dbo.VACUNA (nombre, descripcion)
    VALUES (N'Quíntuple', N'Vacuna múltiple para perros');
GO

/* ==========================================================================
   Datos adicionales: 100 registros del Excel + 450 adicionales
   = 550 clientes y 550 mascotas, con sus citas y vacunaciones. Solo agrega lo que falta.
   ========================================================================== */
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
BEGIN TRANSACTION;

/* Verifica los datos base que ya trae el esquema (ESPECIE, SEXO, COLOR) */
IF (SELECT COUNT(*) FROM dbo.ESPECIE WHERE nombre_especie IN (N'Perro', N'Gato')) <> 2
   OR (SELECT COUNT(*) FROM dbo.SEXO WHERE descripcion IN (N'Macho', N'Hembra')) <> 2
   OR (SELECT COUNT(*) FROM dbo.COLOR WHERE descripcion IN (N'Negro', N'Blanco')) <> 2
    THROW 50001, 'Faltan los datos base de archPETYLAB.sql (Perro/Gato, Macho/Hembra, Negro/Blanco).', 1;

/* ESPECIE y SEXO: no se agrega nada, ya existen Perro, Gato, Macho y Hembra. */

/* RAZA (solo las que faltan) */
IF NOT EXISTS (SELECT 1 FROM dbo.RAZA r JOIN dbo.ESPECIE e ON e.id_especie = r.id_especie WHERE r.nombre_raza = N'Única' AND e.nombre_especie = N'Gato')
    INSERT INTO dbo.RAZA (nombre_raza, id_especie) SELECT N'Única', id_especie FROM dbo.ESPECIE WHERE nombre_especie = N'Gato';
IF NOT EXISTS (SELECT 1 FROM dbo.RAZA r JOIN dbo.ESPECIE e ON e.id_especie = r.id_especie WHERE r.nombre_raza = N'American Bully' AND e.nombre_especie = N'Perro')
    INSERT INTO dbo.RAZA (nombre_raza, id_especie) SELECT N'American Bully', id_especie FROM dbo.ESPECIE WHERE nombre_especie = N'Perro';
IF NOT EXISTS (SELECT 1 FROM dbo.RAZA r JOIN dbo.ESPECIE e ON e.id_especie = r.id_especie WHERE r.nombre_raza = N'Bichon' AND e.nombre_especie = N'Perro')
    INSERT INTO dbo.RAZA (nombre_raza, id_especie) SELECT N'Bichon', id_especie FROM dbo.ESPECIE WHERE nombre_especie = N'Perro';
IF NOT EXISTS (SELECT 1 FROM dbo.RAZA r JOIN dbo.ESPECIE e ON e.id_especie = r.id_especie WHERE r.nombre_raza = N'Bigel' AND e.nombre_especie = N'Perro')
    INSERT INTO dbo.RAZA (nombre_raza, id_especie) SELECT N'Bigel', id_especie FROM dbo.ESPECIE WHERE nombre_especie = N'Perro';
IF NOT EXISTS (SELECT 1 FROM dbo.RAZA r JOIN dbo.ESPECIE e ON e.id_especie = r.id_especie WHERE r.nombre_raza = N'Boston Terrier' AND e.nombre_especie = N'Perro')
    INSERT INTO dbo.RAZA (nombre_raza, id_especie) SELECT N'Boston Terrier', id_especie FROM dbo.ESPECIE WHERE nombre_especie = N'Perro';
IF NOT EXISTS (SELECT 1 FROM dbo.RAZA r JOIN dbo.ESPECIE e ON e.id_especie = r.id_especie WHERE r.nombre_raza = N'Boxer Alemán' AND e.nombre_especie = N'Perro')
    INSERT INTO dbo.RAZA (nombre_raza, id_especie) SELECT N'Boxer Alemán', id_especie FROM dbo.ESPECIE WHERE nombre_especie = N'Perro';
IF NOT EXISTS (SELECT 1 FROM dbo.RAZA r JOIN dbo.ESPECIE e ON e.id_especie = r.id_especie WHERE r.nombre_raza = N'Buldog Frances' AND e.nombre_especie = N'Perro')
    INSERT INTO dbo.RAZA (nombre_raza, id_especie) SELECT N'Buldog Frances', id_especie FROM dbo.ESPECIE WHERE nombre_especie = N'Perro';
IF NOT EXISTS (SELECT 1 FROM dbo.RAZA r JOIN dbo.ESPECIE e ON e.id_especie = r.id_especie WHERE r.nombre_raza = N'Cocker' AND e.nombre_especie = N'Perro')
    INSERT INTO dbo.RAZA (nombre_raza, id_especie) SELECT N'Cocker', id_especie FROM dbo.ESPECIE WHERE nombre_especie = N'Perro';
IF NOT EXISTS (SELECT 1 FROM dbo.RAZA r JOIN dbo.ESPECIE e ON e.id_especie = r.id_especie WHERE r.nombre_raza = N'Cocker Americano' AND e.nombre_especie = N'Perro')
    INSERT INTO dbo.RAZA (nombre_raza, id_especie) SELECT N'Cocker Americano', id_especie FROM dbo.ESPECIE WHERE nombre_especie = N'Perro';
IF NOT EXISTS (SELECT 1 FROM dbo.RAZA r JOIN dbo.ESPECIE e ON e.id_especie = r.id_especie WHERE r.nombre_raza = N'Cocker Ingles' AND e.nombre_especie = N'Perro')
    INSERT INTO dbo.RAZA (nombre_raza, id_especie) SELECT N'Cocker Ingles', id_especie FROM dbo.ESPECIE WHERE nombre_especie = N'Perro';
IF NOT EXISTS (SELECT 1 FROM dbo.RAZA r JOIN dbo.ESPECIE e ON e.id_especie = r.id_especie WHERE r.nombre_raza = N'Golden' AND e.nombre_especie = N'Perro')
    INSERT INTO dbo.RAZA (nombre_raza, id_especie) SELECT N'Golden', id_especie FROM dbo.ESPECIE WHERE nombre_especie = N'Perro';
IF NOT EXISTS (SELECT 1 FROM dbo.RAZA r JOIN dbo.ESPECIE e ON e.id_especie = r.id_especie WHERE r.nombre_raza = N'Golden / Cocker' AND e.nombre_especie = N'Perro')
    INSERT INTO dbo.RAZA (nombre_raza, id_especie) SELECT N'Golden / Cocker', id_especie FROM dbo.ESPECIE WHERE nombre_especie = N'Perro';
IF NOT EXISTS (SELECT 1 FROM dbo.RAZA r JOIN dbo.ESPECIE e ON e.id_especie = r.id_especie WHERE r.nombre_raza = N'Labrador' AND e.nombre_especie = N'Perro')
    INSERT INTO dbo.RAZA (nombre_raza, id_especie) SELECT N'Labrador', id_especie FROM dbo.ESPECIE WHERE nombre_especie = N'Perro';
IF NOT EXISTS (SELECT 1 FROM dbo.RAZA r JOIN dbo.ESPECIE e ON e.id_especie = r.id_especie WHERE r.nombre_raza = N'Pequines Alvino' AND e.nombre_especie = N'Perro')
    INSERT INTO dbo.RAZA (nombre_raza, id_especie) SELECT N'Pequines Alvino', id_especie FROM dbo.ESPECIE WHERE nombre_especie = N'Perro';
IF NOT EXISTS (SELECT 1 FROM dbo.RAZA r JOIN dbo.ESPECIE e ON e.id_especie = r.id_especie WHERE r.nombre_raza = N'Perro Peruano' AND e.nombre_especie = N'Perro')
    INSERT INTO dbo.RAZA (nombre_raza, id_especie) SELECT N'Perro Peruano', id_especie FROM dbo.ESPECIE WHERE nombre_especie = N'Perro';
IF NOT EXISTS (SELECT 1 FROM dbo.RAZA r JOIN dbo.ESPECIE e ON e.id_especie = r.id_especie WHERE r.nombre_raza = N'Poodle con Bichón' AND e.nombre_especie = N'Perro')
    INSERT INTO dbo.RAZA (nombre_raza, id_especie) SELECT N'Poodle con Bichón', id_especie FROM dbo.ESPECIE WHERE nombre_especie = N'Perro';
IF NOT EXISTS (SELECT 1 FROM dbo.RAZA r JOIN dbo.ESPECIE e ON e.id_especie = r.id_especie WHERE r.nombre_raza = N'Pug' AND e.nombre_especie = N'Perro')
    INSERT INTO dbo.RAZA (nombre_raza, id_especie) SELECT N'Pug', id_especie FROM dbo.ESPECIE WHERE nombre_especie = N'Perro';
IF NOT EXISTS (SELECT 1 FROM dbo.RAZA r JOIN dbo.ESPECIE e ON e.id_especie = r.id_especie WHERE r.nombre_raza = N'Salchicha' AND e.nombre_especie = N'Perro')
    INSERT INTO dbo.RAZA (nombre_raza, id_especie) SELECT N'Salchicha', id_especie FROM dbo.ESPECIE WHERE nombre_especie = N'Perro';
IF NOT EXISTS (SELECT 1 FROM dbo.RAZA r JOIN dbo.ESPECIE e ON e.id_especie = r.id_especie WHERE r.nombre_raza = N'Schnauzer' AND e.nombre_especie = N'Perro')
    INSERT INTO dbo.RAZA (nombre_raza, id_especie) SELECT N'Schnauzer', id_especie FROM dbo.ESPECIE WHERE nombre_especie = N'Perro';
IF NOT EXISTS (SELECT 1 FROM dbo.RAZA r JOIN dbo.ESPECIE e ON e.id_especie = r.id_especie WHERE r.nombre_raza = N'Sharpein' AND e.nombre_especie = N'Perro')
    INSERT INTO dbo.RAZA (nombre_raza, id_especie) SELECT N'Sharpein', id_especie FROM dbo.ESPECIE WHERE nombre_especie = N'Perro';
IF NOT EXISTS (SELECT 1 FROM dbo.RAZA r JOIN dbo.ESPECIE e ON e.id_especie = r.id_especie WHERE r.nombre_raza = N'Shitzu' AND e.nombre_especie = N'Perro')
    INSERT INTO dbo.RAZA (nombre_raza, id_especie) SELECT N'Shitzu', id_especie FROM dbo.ESPECIE WHERE nombre_especie = N'Perro';
IF NOT EXISTS (SELECT 1 FROM dbo.RAZA r JOIN dbo.ESPECIE e ON e.id_especie = r.id_especie WHERE r.nombre_raza = N'Shitzu Toy' AND e.nombre_especie = N'Perro')
    INSERT INTO dbo.RAZA (nombre_raza, id_especie) SELECT N'Shitzu Toy', id_especie FROM dbo.ESPECIE WHERE nombre_especie = N'Perro';
IF NOT EXISTS (SELECT 1 FROM dbo.RAZA r JOIN dbo.ESPECIE e ON e.id_especie = r.id_especie WHERE r.nombre_raza = N'Siberiano' AND e.nombre_especie = N'Perro')
    INSERT INTO dbo.RAZA (nombre_raza, id_especie) SELECT N'Siberiano', id_especie FROM dbo.ESPECIE WHERE nombre_especie = N'Perro';
IF NOT EXISTS (SELECT 1 FROM dbo.RAZA r JOIN dbo.ESPECIE e ON e.id_especie = r.id_especie WHERE r.nombre_raza = N'Terrier Tibetano' AND e.nombre_especie = N'Perro')
    INSERT INTO dbo.RAZA (nombre_raza, id_especie) SELECT N'Terrier Tibetano', id_especie FROM dbo.ESPECIE WHERE nombre_especie = N'Perro';
IF NOT EXISTS (SELECT 1 FROM dbo.RAZA r JOIN dbo.ESPECIE e ON e.id_especie = r.id_especie WHERE r.nombre_raza = N'Única' AND e.nombre_especie = N'Perro')
    INSERT INTO dbo.RAZA (nombre_raza, id_especie) SELECT N'Única', id_especie FROM dbo.ESPECIE WHERE nombre_especie = N'Perro';

/* COLOR (solo los que faltan; Negro y Blanco ya existen) */
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Marrón')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Marrón');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Gris')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Gris');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Crema')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Crema');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Beige')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Beige');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Canela')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Canela');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Dorado')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Dorado');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Chocolate')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Chocolate');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Café')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Café');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Café claro')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Café claro');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Café oscuro')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Café oscuro');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Miel')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Miel');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Arena')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Arena');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Marfil')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Marfil');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Perla')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Perla');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Hueso')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Hueso');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Champán')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Champán');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Plateado')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Plateado');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Cenizo')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Cenizo');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Gris claro')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Gris claro');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Gris oscuro')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Gris oscuro');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Gris plata')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Gris plata');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Gris humo')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Gris humo');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Gris carbón')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Gris carbón');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Negro azabache')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Negro azabache');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Negro mate')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Negro mate');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Negro brillante')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Negro brillante');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Blanco puro')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Blanco puro');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Blanco crema')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Blanco crema');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Blanco humo')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Blanco humo');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Amarillo claro')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Amarillo claro');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Naranja')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Naranja');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Naranja claro')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Naranja claro');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Naranja oscuro')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Naranja oscuro');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Rojizo')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Rojizo');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Cobrizo')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Cobrizo');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Caoba')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Caoba');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Avellana')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Avellana');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Trigo')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Trigo');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Mostaza claro')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Mostaza claro');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Ocre')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Ocre');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Caramelo')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Caramelo');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Almendra')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Almendra');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Nuez')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Nuez');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Castaño')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Castaño');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Castaño claro')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Castaño claro');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Castaño oscuro')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Castaño oscuro');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Sable')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Sable');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Sable claro')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Sable claro');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Sable oscuro')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Sable oscuro');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Leonado')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Leonado');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Leonado claro')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Leonado claro');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Leonado oscuro')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Leonado oscuro');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Atigrado')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Atigrado');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Atigrado claro')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Atigrado claro');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Atigrado oscuro')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Atigrado oscuro');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Atigrado gris')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Atigrado gris');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Atigrado marrón')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Atigrado marrón');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Atigrado naranja')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Atigrado naranja');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Manchado')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Manchado');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Moteado')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Moteado');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Jaspeado')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Jaspeado');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Rayado')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Rayado');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Bicolor')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Bicolor');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Tricolor')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Tricolor');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Calicó')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Calicó');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Carey')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Carey');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Tabby')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Tabby');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Tabby gris')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Tabby gris');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Tabby marrón')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Tabby marrón');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Tabby naranja')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Tabby naranja');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Blanco y negro')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Blanco y negro');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Blanco y marrón')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Blanco y marrón');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Blanco y gris')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Blanco y gris');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Blanco y canela')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Blanco y canela');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Blanco y crema')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Blanco y crema');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Negro y blanco')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Negro y blanco');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Negro y marrón')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Negro y marrón');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Negro y canela')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Negro y canela');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Marrón y blanco')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Marrón y blanco');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Marrón y negro')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Marrón y negro');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Gris y blanco')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Gris y blanco');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Gris y negro')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Gris y negro');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Crema y blanco')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Crema y blanco');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Canela y blanco')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Canela y blanco');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Chocolate y blanco')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Chocolate y blanco');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Dorado y blanco')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Dorado y blanco');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Roano')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Roano');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Roano azul')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Roano azul');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Roano marrón')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Roano marrón');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Merle')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Merle');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Merle gris')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Merle gris');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Merle marrón')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Merle marrón');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Arlequín')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Arlequín');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Sal y pimienta')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Sal y pimienta');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Albino')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Albino');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Punto crema')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Punto crema');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Punto chocolate')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Punto chocolate');
IF NOT EXISTS (SELECT 1 FROM dbo.COLOR WHERE descripcion = N'Punto gris')
    INSERT INTO dbo.COLOR (descripcion) VALUES (N'Punto gris');

/* UBICACION (solo los distritos que faltan) */
IF NOT EXISTS (SELECT 1 FROM dbo.UBICACION WHERE departamento = N'LIMA' AND provincia = N'LIMA' AND distrito = N'LOS OLIVOS')
    INSERT INTO dbo.UBICACION (departamento, provincia, distrito, ubigeo)
    VALUES (N'LIMA', N'LIMA', N'LOS OLIVOS', N'15307');
IF NOT EXISTS (SELECT 1 FROM dbo.UBICACION WHERE departamento = N'LIMA' AND provincia = N'LIMA' AND distrito = N'SAN JUAN DE LURIGANCHO')
    INSERT INTO dbo.UBICACION (departamento, provincia, distrito, ubigeo)
    VALUES (N'LIMA', N'LIMA', N'SAN JUAN DE LURIGANCHO', N'150132');
IF NOT EXISTS (SELECT 1 FROM dbo.UBICACION WHERE departamento = N'LIMA' AND provincia = N'LIMA' AND distrito = N'SAN BORJA')
    INSERT INTO dbo.UBICACION (departamento, provincia, distrito, ubigeo)
    VALUES (N'LIMA', N'LIMA', N'SAN BORJA', N'150130');
IF NOT EXISTS (SELECT 1 FROM dbo.UBICACION WHERE departamento = N'LIMA' AND provincia = N'LIMA' AND distrito = N'LA MOLINA')
    INSERT INTO dbo.UBICACION (departamento, provincia, distrito, ubigeo)
    VALUES (N'LIMA', N'LIMA', N'LA MOLINA', N'150114');
IF NOT EXISTS (SELECT 1 FROM dbo.UBICACION WHERE departamento = N'LIMA' AND provincia = N'LIMA' AND distrito = N'COMAS')
    INSERT INTO dbo.UBICACION (departamento, provincia, distrito, ubigeo)
    VALUES (N'LIMA', N'LIMA', N'COMAS', N'150110');
IF NOT EXISTS (SELECT 1 FROM dbo.UBICACION WHERE departamento = N'LIMA' AND provincia = N'LIMA' AND distrito = N'SAN MARTIN DE PORRES')
    INSERT INTO dbo.UBICACION (departamento, provincia, distrito, ubigeo)
    VALUES (N'LIMA', N'LIMA', N'SAN MARTIN DE PORRES', N'150135');
IF NOT EXISTS (SELECT 1 FROM dbo.UBICACION WHERE departamento = N'LIMA' AND provincia = N'LIMA' AND distrito = N'MIRAFLORES')
    INSERT INTO dbo.UBICACION (departamento, provincia, distrito, ubigeo)
    VALUES (N'LIMA', N'LIMA', N'MIRAFLORES', N'150122');
IF NOT EXISTS (SELECT 1 FROM dbo.UBICACION WHERE departamento = N'LIMA' AND provincia = N'LIMA' AND distrito = N'ATE')
    INSERT INTO dbo.UBICACION (departamento, provincia, distrito, ubigeo)
    VALUES (N'LIMA', N'LIMA', N'ATE', N'150103');
IF NOT EXISTS (SELECT 1 FROM dbo.UBICACION WHERE departamento = N'LIMA' AND provincia = N'LIMA' AND distrito = N'SANTIAGO DE SURCO')
    INSERT INTO dbo.UBICACION (departamento, provincia, distrito, ubigeo)
    VALUES (N'LIMA', N'LIMA', N'SANTIAGO DE SURCO', N'150140');
IF NOT EXISTS (SELECT 1 FROM dbo.UBICACION WHERE departamento = N'LIMA' AND provincia = N'LIMA' AND distrito = N'JESUS MARIA')
    INSERT INTO dbo.UBICACION (departamento, provincia, distrito, ubigeo)
    VALUES (N'LIMA', N'LIMA', N'JESUS MARIA', N'150113');
IF NOT EXISTS (SELECT 1 FROM dbo.UBICACION WHERE departamento = N'LIMA' AND provincia = N'LIMA' AND distrito = N'MAGDALENA DEL MAR')
    INSERT INTO dbo.UBICACION (departamento, provincia, distrito, ubigeo)
    VALUES (N'LIMA', N'LIMA', N'MAGDALENA DEL MAR', N'150120');

/* CLIENTE: único por DNI */
INSERT INTO dbo.CLIENTE (dni, apellido_paterno, apellido_materno, nombre, telefono, direccion, fecha_registro, ESTADO)
SELECT v.dni, v.ap, v.am, v.nombre, v.telefono, v.direccion, v.fecha_registro, 1 FROM (VALUES
    (1,N'73049233',N'CASTRO',N'PICHIHUA',N'DELIA NELLY',N'964893048',N'Calle Los Cedros 913, Los Olivos','20230419'),
    (2,N'21102353',N'VERANO',N'VASQUEZ',N'RAUL FRANCISCO',N'960022970',N'Calle Los Cedros 672, Los Olivos','20230422'),
    (3,N'71161158',N'ACUÑA',N'SILVA',N'MANUEL ARTURO',N'920677032',N'Calle Las Acacias 523, Los Olivos','20230421'),
    (4,N'53019203',N'ALFARO',N'ANTEZANA DE HUAMAN',N'JULIA ROSA',N'920387507',N'Calle Las Acacias 135, Los Olivos','20230420'),
    (5,N'17804016',N'ALLCCA',N'HUAMANI',N'RENE AVELINA',N'931698401',N'Calle Los Cedros 890, Los Olivos','20230421'),
    (6,N'65683365',N'AMENABAR',N'AMENABAR',N'BORIS CESAR',N'986955389',N'Av. Los Pinos 702, Los Olivos','20230420'),
    (7,N'92473722',N'CALDERON',N'OLAZABAL',N'YOLANDA ROCIO',N'970372907',N'Av. Los Pinos 269, Los Olivos','20230418'),
    (8,N'71042911',N'CANO',N'PINTO',N'JULIA MARGARITA',N'967262413',N'Jr. Las Palmeras 924, Los Olivos','20230419'),
    (9,N'31161878',N'CARRASCO',N'HUARCAYA',N'ISABEL MARIA',N'950283033',N'Av. Las Flores 923, Los Olivos','20230422'),
    (10,N'83495146',N'CASTILLO',N'CUYA',N'MARIA',N'990816231',N'Av. Las Flores 884, Los Olivos','20230418'),
    (11,N'20693447',N'CHACALTANA',N'MATOS',N'ROCIO DEL PILAR',N'942717267',N'Av. Las Flores 624, Los Olivos','20230421'),
    (12,N'31843366',N'CHAPOÑAN',N'CAMARENA',N'RICARDO RONNY',N'940848951',N'Calle Las Acacias 142, Los Olivos','20230419'),
    (13,N'24804339',N'CHUMACERO',N'HERRERA',N'CLIDER',N'917270298',N'Av. Las Flores 915, Los Olivos','20230420'),
    (14,N'59580044',N'CHUQUIMANTARI',N'INGA',N'BLANCA GLADIS',N'971352015',N'Av. Las Flores 392, Los Olivos','20230420'),
    (15,N'58200384',N'COLLAS',N'BORDA',N'MERCEDES',N'965172233',N'Calle Las Acacias 314, Los Olivos','20230420'),
    (16,N'77442758',N'CORDOVA',N'VALLES',N'VICTOR AUGUSTO',N'995336468',N'Av. Las Flores 38, Los Olivos','20230419'),
    (17,N'35946785',N'COTRADO',N'SANDOVAL',N'MARIA CECILIA',N'990905388',N'Calle Las Acacias 749, Los Olivos','20230417'),
    (18,N'66490721',N'ESPINAL',N'BECERRA DE MAIHUASCA',N'MARIA CLEOFE',N'931099382',N'Calle Las Acacias 778, Los Olivos','20230417'),
    (19,N'83010312',N'FALCON',N'DIAZ',N'LILIANA KATHERINE',N'911576265',N'Av. Las Flores 9, Los Olivos','20230422'),
    (20,N'43622481',N'FERMIN',N'AGUILAR',N'MARTHA BEATRIZ',N'917100405',N'Jr. Las Palmeras 270, Los Olivos','20230420'),
    (21,N'72987366',N'FIGUEROA',N'NAVARRO',N'LEILA AMELIA',N'942641652',N'Av. Las Flores 510, Los Olivos','20230420'),
    (22,N'40409222',N'FLORES',N'RAMOS',N'NYLO ARMANDO',N'915146305',N'Av. Las Flores 979, Los Olivos','20230420'),
    (23,N'18686265',N'GAMARRA',N'SOLIS',N'FELIPE RAUL',N'995347449',N'Av. Las Flores 488, Los Olivos','20230419'),
    (24,N'99982179',N'GARCIA',N'ORMAECHE',N'DORA LUISA',N'915124193',N'Calle Los Cedros 898, Los Olivos','20230421'),
    (25,N'82171493',N'HINOJOSA',N'REQUENA',N'MANUEL SANTOS',N'993909600',N'Jr. Los Jazmines 931, Los Olivos','20230421'),
    (26,N'59631561',N'HOYOS',N'MORALES',N'ENRIQUE ANGEL',N'955044897',N'Av. Los Pinos 378, Los Olivos','20230422'),
    (27,N'77059003',N'HUAMAN',N'-',N'NESTOR',N'933238187',N'Jr. Los Jazmines 897, Los Olivos','20230422'),
    (28,N'51883468',N'HUAYTALLA',N'AMAU',N'JUAN',N'910973021',N'Jr. Los Jazmines 618, Los Olivos','20230422'),
    (29,N'23274785',N'HUMERES',N'GARCIA',N'MAURO DAVID',N'914201181',N'Av. Las Flores 612, Los Olivos','20230419'),
    (30,N'22884877',N'LANDEO',N'GUERRERO',N'JOSE ENRIQUE',N'906257191',N'Calle Los Cedros 431, Los Olivos','20230422'),
    (31,N'65072361',N'LOREÑA',N'YUMBO',N'CESAR RAFAEL',N'992141107',N'Calle Los Cedros 936, Los Olivos','20230422'),
    (32,N'50357259',N'MAMANI',N'RODRIGUEZ',N'DARWIN',N'987443169',N'Av. Los Pinos 708, Los Olivos','20230421'),
    (33,N'57394899',N'MARTINEZ',N'ALVARADO',N'FREDDY JAVIER',N'921534070',N'Av. Los Pinos 621, Los Olivos','20230419'),
    (34,N'96639359',N'MEDINA',N'FLORES DE GONZALES',N'FILOMENA ROSAURA',N'972708614',N'Av. Los Pinos 473, Los Olivos','20230422'),
    (35,N'45449433',N'MEDINA',N'FLORES',N'JUAN DIEGO',N'996410533',N'Calle Las Acacias 30, Los Olivos','20230420'),
    (36,N'87073258',N'MENDEZ',N'PACHECO',N'MARCELO SANDOVAL',N'913386839',N'Calle Las Acacias 139, Los Olivos','20230422'),
    (37,N'43098654',N'MENDEZ',N'PONCIANO',N'LUZ CONSUELO',N'955332669',N'Av. Los Pinos 551, Los Olivos','20230421'),
    (38,N'76113377',N'MENDOZA',N'SANCHEZ',N'MARITA CARLA',N'983610386',N'Jr. Los Jazmines 643, Los Olivos','20230420'),
    (39,N'80879931',N'MONTENEGRO',N'ACUÑA',N'ROSA LUZ',N'948202951',N'Av. Los Pinos 647, Los Olivos','20230418'),
    (40,N'71323763',N'MORI',N'BARRIOS',N'BETTY NANCY',N'976012624',N'Calle Las Acacias 330, Los Olivos','20230419'),
    (41,N'71578881',N'MUCHA',N'MOYA',N'GUILLERMO ARTURO',N'945088970',N'Av. Las Flores 571, Los Olivos','20230419'),
    (42,N'14255487',N'ORDOÑEZ',N'OCHOA',N'JOSE CESAR',N'920440472',N'Jr. Los Jazmines 695, Los Olivos','20230419'),
    (43,N'17095703',N'ORMEÑO',N'SALAS',N'LUISA ROSA',N'996544893',N'Calle Las Acacias 510, Los Olivos','20230420'),
    (44,N'77707788',N'PACHECO',N'DE LA CRUZ',N'LUZ LINDA VICTORIA',N'973491883',N'Jr. Las Palmeras 769, Los Olivos','20230422'),
    (45,N'44978812',N'PARIONA',N'PANDAL',N'SEVERIANO',N'965787901',N'Calle Los Cedros 346, Los Olivos','20230422'),
    (46,N'78043250',N'PAUCARA',N'QUISPE',N'SILVIA DORIS',N'938096733',N'Av. Las Flores 689, Los Olivos','20230420'),
    (47,N'86028611',N'PINEDA',N'PEREZ',N'ANATOLIA MARGARITA SARA',N'980286797',N'Av. Los Pinos 232, Los Olivos','20230418'),
    (48,N'10453063',N'PINTO',N'VICTORIO',N'SARA ROSA',N'909940655',N'Av. Las Flores 481, Los Olivos','20230418'),
    (49,N'37811251',N'POLANCO',N'PALOMINO',N'CARMEN ELENA',N'993137340',N'Av. Los Pinos 425, Los Olivos','20230418'),
    (50,N'67914971',N'QUINTANA',N'FERNANDEZ',N'NILDA',N'961253397',N'Calle Las Acacias 127, Los Olivos','20230420'),
    (51,N'53474998',N'QUIROZ',N'VALENZUELA',N'ANTONIA',N'937975812',N'Jr. Los Jazmines 962, Los Olivos','20230421'),
    (52,N'61755938',N'QUISPE',N'CHAUPIN',N'RICARDO',N'920402412',N'Av. Los Pinos 445, Los Olivos','20230421'),
    (53,N'46340188',N'QUISPE',N'DE DUYMOVICH',N'OLGA ADELA',N'952773729',N'Calle Los Cedros 343, Los Olivos','20230420'),
    (54,N'79976947',N'QUISPE',N'VALENCIA',N'LUIS',N'914914275',N'Jr. Las Palmeras 936, Los Olivos','20230421'),
    (55,N'52722310',N'REA',N'COTERA',N'ELENA HAYDEE',N'953564873',N'Calle Los Cedros 976, Los Olivos','20230418'),
    (56,N'43760409',N'REYES',N'BUSTAMANTE',N'ALFREDO ARMANDO',N'987570507',N'Calle Los Cedros 510, Los Olivos','20230420'),
    (57,N'58743611',N'ROMERO',N'ESPINOZA',N'VIDA ALCIDA',N'909053406',N'Av. Los Pinos 708, Los Olivos','20230422'),
    (58,N'94538328',N'ROSADIO',N'ANTON',N'KETTY ROXANA',N'918058883',N'Jr. Las Palmeras 796, Los Olivos','20230420'),
    (59,N'74519257',N'SANCHEZ',N'BRAVO',N'PASTOR',N'959856846',N'Jr. Los Jazmines 701, Los Olivos','20230420'),
    (60,N'23700218',N'SANCHEZ',N'CASTILLO',N'JUAN RAMON',N'928928984',N'Jr. Las Palmeras 68, Los Olivos','20230420'),
    (61,N'41585435',N'SANCHEZ',N'ORTIZ DE RAMOS',N'GLORIA ESTHER',N'958178109',N'Jr. Los Jazmines 566, Los Olivos','20230420'),
    (62,N'83258857',N'SANTISTEBAN',N'SANDOVAL',N'GILBERTO',N'954457780',N'Jr. Las Palmeras 572, Los Olivos','20230418'),
    (63,N'29051955',N'SUAREZ',N'AGUILAR',N'LIANA CECILIA',N'940886573',N'Av. Las Flores 343, Los Olivos','20230419'),
    (64,N'36079144',N'SUCA',N'MEZA',N'TOMAS ANGEL',N'947398761',N'Av. Las Flores 914, Los Olivos','20230422'),
    (65,N'93021703',N'SURCA',N'TASAYCO',N'CARLOS GENARO',N'920708429',N'Jr. Los Jazmines 770, Los Olivos','20230422'),
    (66,N'30379788',N'TAIPE',N'SUAREZ',N'ABADEZA',N'942532097',N'Calle Las Acacias 51, Los Olivos','20230418'),
    (67,N'59086363',N'TITO',N'LAURA',N'HAYDEE',N'912780355',N'Jr. Las Palmeras 519, Los Olivos','20230420'),
    (68,N'11703235',N'TORIBIO',N'TORREJON',N'ROSA ANDREA',N'981017353',N'Jr. Las Palmeras 754, Los Olivos','20230421'),
    (69,N'58839322',N'TUCTA',N'ALFARO',N'FELIPE',N'982840242',N'Calle Las Acacias 148, Los Olivos','20230422'),
    (70,N'50143134',N'VIVAR',N'RIMAYCUNA',N'NILA AURELIA',N'908772268',N'Jr. Los Jazmines 508, Los Olivos','20230421'),
    (71,N'47600393',N'YANTAZ',N'MARTINEZ',N'TERESA',N'965593638',N'Av. Los Pinos 17, Los Olivos','20230421'),
    (72,N'19397597',N'YATO',N'BEGAZO',N'DORIS LUPE',N'981612996',N'Jr. Las Palmeras 431, Los Olivos','20230420'),
    (73,N'66369156',N'CHIRINOS',N'GONZALES',N'ROMARIO KEVIN',N'944832614',N'Av. Los Pinos 126, Los Olivos','20230419'),
    (74,N'32357106',N'HUACHUA',N'PALLIN',N'AMPARO LUZ',N'965134346',N'Calle Los Cedros 183, Los Olivos','20230419'),
    (75,N'48535253',N'VICUÑA',N'MIGUEL',N'MANUEL JESUS',N'949923319',N'Av. Las Flores 584, Los Olivos','20230418'),
    (76,N'44598490',N'VILLANUEVA',N'ORTIZ',N'MARIA JESUS',N'986397165',N'Calle Los Cedros 398, Los Olivos','20230418'),
    (77,N'92117808',N'AGUILAR',N'GALVEZ',N'ELOY',N'993145686',N'Calle Las Acacias 331, Los Olivos','20230418'),
    (78,N'53258560',N'ALVARADO',N'ZAVALA',N'DANTE',N'962857568',N'Av. Las Flores 880, Los Olivos','20230418'),
    (79,N'70081614',N'ANCA',N'ANTAY',N'PEDRO CELESTINO',N'924309544',N'Calle Las Acacias 797, Los Olivos','20230419'),
    (80,N'62179698',N'APAZA',N'HANCO',N'BALTAZAR',N'933359372',N'Calle Los Cedros 525, Los Olivos','20230418'),
    (81,N'11101735',N'BARCENA',N'LEE',N'GUILLERMO',N'987956896',N'Jr. Las Palmeras 731, Los Olivos','20230419'),
    (82,N'43966135',N'CANAZA',N'APAZA',N'NAPOLEON',N'964609473',N'Calle Los Cedros 212, Los Olivos','20230419'),
    (83,N'50069966',N'CLAROS',N'SOLIS',N'RONALD EDGARDO',N'982132641',N'Av. Las Flores 87, Los Olivos','20230420'),
    (84,N'37662171',N'GONZA',N'CONDORI',N'CALIXTO',N'958059562',N'Jr. Los Jazmines 571, Los Olivos','20230420'),
    (85,N'32576233',N'HUANCA',N'CONDORI',N'SABINO',N'913536036',N'Av. Las Flores 642, Los Olivos','20230419'),
    (86,N'44167765',N'HUAYANCA',N'AVALOS',N'MAXIMO',N'955442620',N'Jr. Los Jazmines 398, Los Olivos','20230419'),
    (87,N'14512500',N'IQUISE',N'VARGAS',N'TORIBIO',N'956442992',N'Calle Los Cedros 754, Los Olivos','20230422'),
    (88,N'87135532',N'LAUPA',N'ANTAY',N'ROBERTO',N'936173261',N'Av. Las Flores 195, Los Olivos','20230421'),
    (89,N'45141552',N'LOAYZA',N'ARAMBURU',N'GERARDO',N'906387843',N'Calle Las Acacias 282, Los Olivos','20230422'),
    (90,N'43731506',N'LOAYZA',N'HUAYHUAPOMA',N'REINER BENJAMIN',N'918764883',N'Calle Las Acacias 648, Los Olivos','20230420'),
    (91,N'83106100',N'MAMANI',N'APAZA',N'SIMON',N'936031519',N'Jr. Los Jazmines 45, Los Olivos','20230420'),
    (92,N'50606432',N'MENDOZA',N'PAREDES',N'CLEMENTE ALBERTO',N'935987964',N'Jr. Los Jazmines 507, Los Olivos','20230418'),
    (93,N'85463093',N'MUÑOZ',N'TORBISCO',N'HONORATO',N'916630754',N'Jr. Las Palmeras 442, Los Olivos','20230418'),
    (94,N'35087613',N'ORTIZ',N'DE LA CRUZ',N'ZENOBIO SERAFIN',N'907144662',N'Jr. Las Palmeras 327, Los Olivos','20230419'),
    (95,N'77915097',N'QUISPE',N'QUISPE',N'LAZARO',N'958568337',N'Av. Las Flores 383, Los Olivos','20230418'),
    (96,N'51430602',N'RAMOS',N'NEYRA',N'MARCOS ANTONIO',N'924353909',N'Av. Las Flores 295, Los Olivos','20230418'),
    (97,N'27898879',N'RAMOS',N'YLLESCAS',N'ANGEL ELEUTERIO',N'913805061',N'Av. Los Pinos 350, Los Olivos','20230422'),
    (98,N'37591160',N'ROMANI',N'TACURI',N'JUAN LUIS',N'989574364',N'Calle Las Acacias 347, Los Olivos','20230419'),
    (99,N'33715647',N'TITO',N'TORRES',N'JUVENAL DAVID',N'969688534',N'Jr. Los Jazmines 230, Los Olivos','20230419'),
    (100,N'36338780',N'TORRES',N'MENDOZA',N'JOSE ANTONIO',N'957495611',N'Av. Los Pinos 89, Los Olivos','20230421'),
    (101,N'53316884',N'ACUÑA',N'CAMPOS',N'HECTOR MANUEL',N'999252017',N'Av. Las Flores 570, San Juan de Lurigancho','20251103'),
    (102,N'46075844',N'CORONADO',N'YUPANQUI',N'SILVIA',N'985930507',N'Av. San Borja Norte 1444, San Borja','20240127'),
    (103,N'16537126',N'CAMPOS',N'FLORES',N'VICTOR HUGO',N'983990782',N'Psje. Miguel Grau 2036, San Borja','20241027'),
    (104,N'75874880',N'AGUILAR',N'RODRIGUEZ',N'LUIS MIGUEL',N'983198517',N'Psje. Los Cipreses 1014, La Molina','20240223'),
    (105,N'50665804',N'ROMERO',N'MAMANI',N'OSCAR',N'942922012',N'Av. Las Flores 1566, San Juan de Lurigancho','20260524'),
    (106,N'73756858',N'RAMIREZ',N'HUERTA',N'CARLOS ALBERTO',N'918682036',N'Psje. Los Olivos 224, Comas','20260611'),
    (107,N'46337525',N'TORRES',N'DE LA CRUZ',N'VICTOR HUGO',N'991218369',N'Av. Tomás Valle 608, San Martín de Porres','20240121'),
    (108,N'75598594',N'PAREDES',N'GUERRA',N'ANA LUCIA',N'956006491',N'Av. Las Flores 442, San Juan de Lurigancho','20241102'),
    (109,N'71990332',N'MALDONADO',N'ZEGARRA',N'CLAUDIA',N'977163115',N'Psje. Los Olivos 511, Miraflores','20250922'),
    (110,N'58213469',N'IPARRAGUIRRE',N'FLORES',N'RICARDO',N'937229254',N'Av. Próceres de la Independencia 1228, San Juan de Lurigancho','20260801'),
    (111,N'77344573',N'CHAMBI',N'SANCHEZ',N'ELIZABETH',N'964062390',N'Psje. Los Cipreses 207, La Molina','20240409'),
    (112,N'70536828',N'RAMIREZ',N'FERNANDEZ',N'OSCAR',N'934125372',N'Av. Alfredo Mendiola 1223, San Martín de Porres','20240201'),
    (113,N'39138767',N'SOTO',N'SALAZAR',N'JUANA',N'976159071',N'Jr. Cusco 1329, San Martín de Porres','20240218'),
    (114,N'47246945',N'CHAMBI',N'ESTRADA',N'RENATO',N'908283364',N'Calle Las Acacias 204, San Juan de Lurigancho','20230913'),
    (115,N'57535139',N'GOMEZ',N'MEDINA',N'FRANCISCO',N'912807180',N'Psje. Bolognesi 943, La Molina','20260828'),
    (116,N'51064536',N'ARIAS',N'OLIVERA',N'KATHERINE',N'964220452',N'Av. Alameda del Corregidor 2036, La Molina','20250416'),
    (117,N'31366985',N'ROJAS',N'CHAVEZ',N'MARIA ELENA',N'991392216',N'Av. Aviación 1512, San Borja','20241230'),
    (118,N'38386240',N'RAMIREZ',N'PAREDES',N'CESAR AUGUSTO',N'927253301',N'Av. Los Fresnos 804, La Molina','20260520'),
    (119,N'23781600',N'ARCE',N'SALAZAR',N'MARIO',N'910422096',N'Av. Tomás Valle 1845, San Martín de Porres','20250726'),
    (120,N'75149339',N'PAREDES',N'DIAZ',N'VICTOR HUGO',N'939253503',N'Calle Los Eucaliptos 417, San Martín de Porres','20250818'),
    (121,N'32374940',N'ESPINOZA',N'GUERRA',N'LUZ MARINA',N'941321845',N'Av. Javier Prado Este 458, Ate','20260526'),
    (122,N'35967986',N'BENITES',N'VILCA',N'VICTOR HUGO',N'995494814',N'Av. San Borja Norte 903, San Borja','20230821'),
    (123,N'43015498',N'PAREDES',N'URBANO',N'CARMEN ROSA',N'948945845',N'Av. Tomás Marsano 2008, Santiago de Surco','20240904'),
    (124,N'38320094',N'MENDOZA',N'DE LA VEGA',N'DIANA CAROLINA',N'976719813',N'Av. Belaúnde 1685, Comas','20260408'),
    (125,N'39512989',N'CONDORI',N'CAMPOS',N'JULIA ESTHER',N'910264594',N'Av. Benavides 2088, Santiago de Surco','20250831'),
    (126,N'50251342',N'REYES',N'GOMEZ',N'GRACIELA',N'919273498',N'Psje. Tacna 1250, San Juan de Lurigancho','20240810'),
    (127,N'54344343',N'ESPINOZA',N'YUPANQUI',N'FRANCISCO',N'916175447',N'Av. Las Flores 800, San Juan de Lurigancho','20260715'),
    (128,N'60693432',N'CHAVEZ',N'VEGA',N'TEODORO',N'917749236',N'Av. Naranjal 572, San Martín de Porres','20250422'),
    (129,N'61283202',N'SOTO',N'LOPEZ',N'CARMEN ROSA',N'983144094',N'Av. Benavides 1320, Miraflores','20250418'),
    (130,N'42339214',N'GOMEZ',N'ALVAREZ',N'MILAGROS',N'958101672',N'Av. Arenales 557, Jesús María','20250406'),
    (131,N'35860182',N'OROZCO',N'RAMOS',N'ELIZABETH',N'911711357',N'Jr. Cusco 1115, Jesús María','20260115'),
    (132,N'32056535',N'RAMIREZ',N'SILVA',N'YESENIA',N'954821372',N'Av. Universitaria 1744, Comas','20260623'),
    (133,N'49176341',N'BRAVO',N'TAPIA',N'INES',N'993050448',N'Calle Los Álamos 789, Santiago de Surco','20240501'),
    (134,N'44353078',N'CHAVEZ',N'CASTILLO',N'DIANA CAROLINA',N'941701710',N'Av. Benavides 2006, Santiago de Surco','20261009'),
    (135,N'54073127',N'CHAVEZ',N'FLORES',N'MANUEL',N'953551647',N'Av. Wiese 995, San Juan de Lurigancho','20260529'),
    (136,N'11644275',N'FERNANDEZ',N'MARTINEZ',N'KATHERINE',N'940430696',N'Av. Canto Grande 282, San Juan de Lurigancho','20251025'),
    (137,N'70251498',N'MENDOZA',N'YUPANQUI',N'DELIA',N'990814738',N'Av. Próceres de la Independencia 1214, San Juan de Lurigancho','20261008'),
    (138,N'75331516',N'NAVARRO',N'ROMERO',N'RENATO',N'941683076',N'Psje. Santa Rosa 216, San Juan de Lurigancho','20230514'),
    (139,N'18249549',N'MARTINEZ',N'ESTRADA',N'CARMEN ROSA',N'927085691',N'Av. Bolívar 495, Magdalena del Mar','20250507'),
    (140,N'44057414',N'VARGAS',N'PEREZ',N'JAVIER',N'974397751',N'Jr. Junín 925, Miraflores','20260308'),
    (141,N'27749817',N'VALDIVIA',N'FLORES',N'OMAR',N'941483781',N'Av. Alameda del Corregidor 993, La Molina','20240605'),
    (142,N'14179958',N'GARCIA',N'CHAVEZ',N'ROSA MARIA',N'975324453',N'Av. Naranjal 2031, San Martín de Porres','20240105'),
    (143,N'35029611',N'SANCHEZ',N'YUPANQUI',N'OLGA',N'906509064',N'Av. Universitaria 1170, Comas','20240923'),
    (144,N'43588550',N'MEDINA',N'CABRERA',N'CHRISTIAN',N'932662226',N'Psje. Las Flores 132, Santiago de Surco','20250322'),
    (145,N'56162302',N'GUTIERREZ',N'NAVARRO',N'CARLOS ALBERTO',N'962053402',N'Jr. San Martín 167, Ate','20250329'),
    (146,N'37855761',N'QUISPE',N'CARDENAS',N'WALTER',N'954661770',N'Psje. Los Laureles 705, San Borja','20240101'),
    (147,N'79028178',N'CASTRO',N'MEDINA',N'MARIA ELENA',N'983202408',N'Calle Tacna 1678, San Borja','20231223'),
    (148,N'53561260',N'HUAMAN',N'SALAZAR',N'OLGA',N'974912519',N'Jr. Arequipa 1473, Comas','20240106'),
    (149,N'26212581',N'VALDIVIA',N'MEDINA',N'GRACIELA',N'953283830',N'Av. Las Flores 795, San Juan de Lurigancho','20230619'),
    (150,N'76885298',N'ZAVALETA',N'LEON',N'LUZ MARINA',N'907393353',N'Av. Benavides 781, Miraflores','20231010'),
    (151,N'20966078',N'MENDOZA',N'DE LA CRUZ',N'GLORIA',N'989499352',N'Psje. Junín 340, San Martín de Porres','20240723'),
    (152,N'25276068',N'MAMANI',N'CASTRO',N'FRANCISCO',N'920751583',N'Jr. Los Cipreses 1606, San Martín de Porres','20260104'),
    (153,N'44827796',N'VILCA',N'DELGADO',N'JESUS',N'939614099',N'Psje. Los Cipreses 1087, San Martín de Porres','20260130'),
    (154,N'67321528',N'CRUZ',N'LOPEZ',N'OMAR',N'939131291',N'Av. Los Fresnos 915, La Molina','20260927'),
    (155,N'53105515',N'VEGA',N'MAMANI',N'LIDIA',N'980883374',N'Av. Los Incas 1540, Comas','20261005'),
    (156,N'48607157',N'LEON',N'CORONADO',N'KATHERINE',N'902962177',N'Av. Túpac Amaru 1728, Comas','20230625'),
    (157,N'37495349',N'OLIVERA',N'SALINAS',N'MARLENE',N'900086496',N'Jr. Las Flores 1832, San Juan de Lurigancho','20251128'),
    (158,N'54400813',N'RAMOS',N'REYES',N'GUSTAVO',N'938535248',N'Calle Ayacucho 534, San Martín de Porres','20241220'),
    (159,N'46221200',N'FARFAN',N'DE LA CRUZ',N'SILVIA',N'931702491',N'Psje. Los Jazmines 1066, San Borja','20241113'),
    (160,N'53060004',N'CRUZ',N'VALDIVIA',N'ANA LUCIA',N'909669642',N'Jr. Los Álamos 399, La Molina','20260614'),
    (161,N'29660614',N'MALDONADO',N'FARFAN',N'MANUEL',N'917279170',N'Av. Universitaria 612, Comas','20260910'),
    (162,N'37828753',N'LEON',N'NUÑEZ',N'JOSE LUIS',N'913726030',N'Psje. Los Girasoles 2077, Santiago de Surco','20250507'),
    (163,N'68285145',N'VEGA',N'SILVA',N'LUZ MARINA',N'962067473',N'Av. Tomás Valle 883, San Martín de Porres','20240301'),
    (164,N'14378485',N'CARDENAS',N'CORONADO',N'DIANA CAROLINA',N'912934014',N'Jr. Los Cipreses 417, La Molina','20260421'),
    (165,N'35063063',N'FARFAN',N'DE LA VEGA',N'GABRIELA',N'995700306',N'Av. Alameda del Corregidor 115, La Molina','20231206'),
    (166,N'54572038',N'ESPINOZA',N'ESPINOZA',N'ANDRES',N'946614987',N'Av. Túpac Amaru 1843, Comas','20240416'),
    (167,N'12693757',N'TORRES',N'RODRIGUEZ',N'SANDRA',N'982905955',N'Jr. Los Cedros 393, Santiago de Surco','20240919'),
    (168,N'36292579',N'RAMOS',N'CONDORI',N'INES',N'980831209',N'Psje. Las Orquídeas 2068, San Juan de Lurigancho','20240114'),
    (169,N'20855772',N'SANCHEZ',N'CASTRO',N'OMAR',N'995668353',N'Calle Los Jazmines 1149, San Martín de Porres','20251212'),
    (170,N'36725962',N'LAZO',N'FLORES',N'FLOR DE MARIA',N'946974573',N'Av. Cuba 177, San Borja','20250410'),
    (171,N'58637800',N'LOPEZ',N'GONZALES',N'ELIZABETH',N'993162655',N'Av. Túpac Amaru 1902, Comas','20250329'),
    (172,N'65972462',N'ESTRADA',N'ARIAS',N'OLGA',N'975951250',N'Av. Los Incas 1067, Comas','20230430'),
    (173,N'45932642',N'MALDONADO',N'NAVARRO',N'JULIA ESTHER',N'994342026',N'Jr. Bolognesi 1747, Ate','20241202'),
    (174,N'39734772',N'TORRES',N'DIAZ',N'VICTOR HUGO',N'967993942',N'Jr. San Martín 696, Jesús María','20250711'),
    (175,N'77521126',N'GARCIA',N'YUPANQUI',N'PEDRO PABLO',N'934620645',N'Jr. Los Cedros 946, Ate','20250605'),
    (176,N'66139552',N'CHAVEZ',N'GONZALES',N'GLORIA',N'983700861',N'Av. Canto Grande 585, San Juan de Lurigancho','20260128'),
    (177,N'38601665',N'CARDENAS',N'CRUZ',N'ROXANA',N'958465429',N'Jr. Bolognesi 521, San Juan de Lurigancho','20250324'),
    (178,N'16148560',N'MARTINEZ',N'SALINAS',N'DIEGO ALONSO',N'984642808',N'Av. Brasil 355, Jesús María','20250923'),
    (179,N'64701909',N'CAMPOS',N'DIAZ',N'SILVIA',N'942449783',N'Av. Tomás Valle 845, San Martín de Porres','20250915'),
    (180,N'66703032',N'URBANO',N'HUERTA',N'FERNANDO',N'907280752',N'Jr. San Martín 402, La Molina','20240715'),
    (181,N'58228917',N'RAMOS',N'CONDORI',N'LORENA',N'944922426',N'Calle Los Girasoles 1807, San Juan de Lurigancho','20261006'),
    (182,N'17516769',N'SOTO',N'CHAVEZ',N'CESAR AUGUSTO',N'918602279',N'Av. Los Fresnos 1353, La Molina','20260705'),
    (183,N'70962766',N'BRAVO',N'SOTO',N'MONICA',N'969722966',N'Av. Javier Prado Este 963, Ate','20250619'),
    (184,N'24289836',N'TORRES',N'ROMERO',N'RENATO',N'926863315',N'Psje. Cusco 488, Miraflores','20241213'),
    (185,N'32556969',N'MENDOZA',N'QUISPE',N'ROXANA',N'902505671',N'Av. Tomás Valle 952, San Martín de Porres','20231024'),
    (186,N'54744533',N'VILCA',N'RAMIREZ',N'ANGELICA',N'922763981',N'Av. Wiese 765, San Juan de Lurigancho','20250830'),
    (187,N'38443718',N'ACUÑA',N'CONDORI',N'PILAR',N'906109283',N'Av. Los Incas 1788, Comas','20250119'),
    (188,N'11432233',N'PACHECO',N'GARCIA',N'KATHERINE',N'907974460',N'Calle Las Begonias 1385, Santiago de Surco','20251129'),
    (189,N'66933972',N'GOMEZ',N'YUPANQUI',N'FRANCISCO',N'903188404',N'Psje. Huallaga 1202, Ate','20251117'),
    (190,N'41067506',N'CRUZ',N'BENITES',N'PEDRO PABLO',N'944129668',N'Av. Universitaria 629, Comas','20251004'),
    (191,N'17968489',N'FARFAN',N'NAVARRO',N'FLOR DE MARIA',N'963480978',N'Av. Benavides 431, Santiago de Surco','20230629'),
    (192,N'35567394',N'CABRERA',N'RAMOS',N'OMAR',N'967175607',N'Av. Tomás Marsano 1045, Santiago de Surco','20250914'),
    (193,N'10374680',N'GOMEZ',N'LEON',N'FERNANDO',N'969203635',N'Jr. Los Girasoles 2051, Comas','20260216'),
    (194,N'63703773',N'ESPINOZA',N'VEGA',N'JUANA',N'988433272',N'Calle Los Laureles 1035, San Martín de Porres','20241220'),
    (195,N'26925176',N'NUÑEZ',N'SALINAS',N'KEVIN',N'912521679',N'Psje. Las Begonias 1242, Santiago de Surco','20251224'),
    (196,N'50193307',N'URBANO',N'DELGADO',N'LUIS ENRIQUE',N'902833839',N'Av. Canto Grande 339, San Juan de Lurigancho','20231101'),
    (197,N'68488848',N'SILVA',N'QUISPE',N'SANDRA',N'905064686',N'Calle San Martín 1084, Ate','20250531'),
    (198,N'17873272',N'BRAVO',N'SILVA',N'SILVIA',N'930202092',N'Av. Las Flores 1470, San Juan de Lurigancho','20241225'),
    (199,N'44893952',N'RAMIREZ',N'GUTIERREZ',N'ROCIO',N'965414352',N'Jr. Las Palmeras 1551, La Molina','20251224'),
    (200,N'52964751',N'ALVAREZ',N'HUAMAN',N'ROSA MARIA',N'995705654',N'Av. Benavides 541, Miraflores','20231225'),
    (201,N'61745970',N'RODRIGUEZ',N'BRAVO',N'JULIA ESTHER',N'931477680',N'Av. Aviación 243, San Borja','20240412'),
    (202,N'21984827',N'BRAVO',N'IPARRAGUIRRE',N'GLORIA',N'937017496',N'Av. Javier Prado Oeste 954, Magdalena del Mar','20251022'),
    (203,N'66057004',N'CRUZ',N'ALVAREZ',N'MARIO',N'971805339',N'Av. Brasil 1894, Jesús María','20230519'),
    (204,N'74409158',N'FERNANDEZ',N'VARGAS',N'MARIO',N'990803588',N'Jr. Tacna 872, San Juan de Lurigancho','20251016'),
    (205,N'60487593',N'OLIVERA',N'PEREZ',N'BEATRIZ',N'971228151',N'Av. Tomás Valle 226, San Martín de Porres','20230823'),
    (206,N'38663018',N'ZEGARRA',N'PEREZ',N'ROCIO',N'968187140',N'Av. Nicolás Ayllón 349, Ate','20250902'),
    (207,N'74414951',N'JIMENEZ',N'MENDOZA',N'DIEGO ALONSO',N'913785468',N'Jr. San Martín 1587, San Borja','20250208'),
    (208,N'45907081',N'NAVARRO',N'SILVA',N'KEVIN',N'947982009',N'Calle Tacna 514, Ate','20260321'),
    (209,N'18684426',N'ARIAS',N'DIAZ',N'ELVIRA',N'956464497',N'Av. Próceres de la Independencia 478, San Juan de Lurigancho','20240507'),
    (210,N'66499753',N'HUAMAN',N'VASQUEZ',N'JUANA',N'939419675',N'Jr. Huallaga 1595, Santiago de Surco','20250323'),
    (211,N'39050775',N'CORONADO',N'PALACIOS',N'NELSON',N'968083385',N'Jr. Santa Rosa 1079, Miraflores','20260215'),
    (212,N'54305327',N'FLORES',N'URBANO',N'JESSICA',N'908173954',N'Av. Javier Prado Este 882, Ate','20250913'),
    (213,N'61428603',N'ROJAS',N'DEL AGUILA',N'ROSA MARIA',N'954075785',N'Av. Tomás Marsano 1377, Santiago de Surco','20260723'),
    (214,N'49691643',N'QUISPE',N'GOMEZ',N'JOSE LUIS',N'990010425',N'Psje. Los Cedros 905, San Juan de Lurigancho','20231231'),
    (215,N'32697260',N'DIAZ',N'DIAZ',N'SANDRA',N'960445053',N'Jr. Bolognesi 906, San Martín de Porres','20240729'),
    (216,N'64949806',N'VASQUEZ',N'CAMPOS',N'LUZ MARINA',N'947020276',N'Av. Alfredo Mendiola 1694, San Martín de Porres','20240919'),
    (217,N'56914201',N'MEDINA',N'TORRES',N'ROBERTO CARLOS',N'953283291',N'Av. Universitaria 890, Comas','20241204'),
    (218,N'24696128',N'PACHECO',N'CAMPOS',N'ANA LUCIA',N'948815113',N'Av. Aviación 1685, San Borja','20230810'),
    (219,N'16372812',N'IPARRAGUIRRE',N'CONDORI',N'HUGO',N'917191754',N'Av. Belaúnde 1922, Comas','20250127'),
    (220,N'39328441',N'VILCA',N'URBANO',N'KATHERINE',N'925435810',N'Jr. Las Magnolias 924, Comas','20251227'),
    (221,N'56061576',N'CONDORI',N'CONDORI',N'MANUEL',N'951100876',N'Av. Larco 1269, Miraflores','20240909'),
    (222,N'55115571',N'SANCHEZ',N'CHAVEZ',N'SILVIA',N'954913183',N'Calle Ayacucho 1146, Ate','20240405'),
    (223,N'38702911',N'ROJAS',N'ARCE',N'MANUEL',N'900984894',N'Av. Angamos 1297, Miraflores','20241201'),
    (224,N'17338952',N'CHAVEZ',N'RAMIREZ',N'DANIEL',N'980373868',N'Av. Aviación 968, San Borja','20240814'),
    (225,N'16408342',N'OLIVERA',N'TORRES',N'CARMEN ROSA',N'932805556',N'Av. Javier Prado Oeste 2037, Magdalena del Mar','20240721'),
    (226,N'57003069',N'CARDENAS',N'ALVAREZ',N'EDUARDO',N'988395878',N'Psje. Los Olivos 912, Ate','20260210'),
    (227,N'73182519',N'ACUÑA',N'DEL AGUILA',N'CARLOS ALBERTO',N'950368823',N'Av. Cuba 2087, Jesús María','20260111'),
    (228,N'38237762',N'QUISPE',N'CABRERA',N'DANIEL',N'920829496',N'Psje. Miguel Grau 1622, Miraflores','20240726'),
    (229,N'73227182',N'SOTO',N'MEDINA',N'KATHERINE',N'951285824',N'Av. Pardo 642, Miraflores','20240204'),
    (230,N'62671174',N'NAVARRO',N'RODRIGUEZ',N'LUIS MIGUEL',N'900649317',N'Av. Separadora Industrial 1277, Ate','20260219'),
    (231,N'59803849',N'VARGAS',N'ZAVALETA',N'ELIZABETH',N'956958341',N'Calle Miguel Grau 1848, San Martín de Porres','20250316'),
    (232,N'59996943',N'CARDENAS',N'CHAVEZ',N'OMAR',N'957226355',N'Jr. Los Cipreses 866, Ate','20230704'),
    (233,N'77822400',N'ROJAS',N'CASTRO',N'BEATRIZ',N'925907415',N'Av. Tomás Valle 659, San Martín de Porres','20240308'),
    (234,N'39677506',N'CORONADO',N'QUISPE',N'NANCY',N'992766928',N'Av. Tomás Marsano 821, Santiago de Surco','20260619'),
    (235,N'76415788',N'MAMANI',N'SALINAS',N'ROBERTO CARLOS',N'903615770',N'Av. La Molina 1951, La Molina','20260713'),
    (236,N'29789893',N'OLIVERA',N'PEREZ',N'LORENA',N'979790506',N'Calle Los Girasoles 1603, San Borja','20241005'),
    (237,N'30289791',N'RODRIGUEZ',N'ZEGARRA',N'SONIA PATRICIA',N'984536532',N'Psje. Las Orquídeas 1214, Jesús María','20250411'),
    (238,N'79220323',N'GUTIERREZ',N'GUTIERREZ',N'EDWIN',N'959664971',N'Av. Wiese 1670, San Juan de Lurigancho','20250221'),
    (239,N'47888884',N'MENDOZA',N'SANCHEZ',N'ROBERTO CARLOS',N'980598735',N'Calle Los Olivos 1238, San Juan de Lurigancho','20250316'),
    (240,N'28948673',N'BENITES',N'CASTRO',N'DELIA',N'960133929',N'Av. Alfredo Mendiola 428, San Martín de Porres','20241106'),
    (241,N'27867033',N'VARGAS',N'OROZCO',N'OMAR',N'960872466',N'Calle Las Orquídeas 377, San Borja','20251219'),
    (242,N'62719537',N'BRAVO',N'QUISPE',N'EDUARDO',N'938894353',N'Av. Nicolás Ayllón 1843, Ate','20250217'),
    (243,N'22191593',N'ROMERO',N'CORONADO',N'GLORIA',N'995025012',N'Av. Primavera 353, Santiago de Surco','20240219'),
    (244,N'37519394',N'GARCIA',N'HUERTA',N'ROSA MARIA',N'952848862',N'Av. Las Flores 2013, San Juan de Lurigancho','20250409'),
    (245,N'40377786',N'YUPANQUI',N'VALDIVIA',N'JOSE LUIS',N'968778644',N'Jr. Los Pinos 1546, Comas','20250129'),
    (246,N'53716605',N'CAMPOS',N'GONZALES',N'SONIA PATRICIA',N'968195611',N'Av. Los Chancas 710, Ate','20241116'),
    (247,N'36860383',N'QUISPE',N'CHAVEZ',N'FLOR DE MARIA',N'965585135',N'Jr. Los Eucaliptos 1808, Ate','20260319'),
    (248,N'74637126',N'IPARRAGUIRRE',N'BRAVO',N'DIEGO ALONSO',N'950117503',N'Psje. Arequipa 1768, San Martín de Porres','20231005'),
    (249,N'26753308',N'CAMPOS',N'DE LA VEGA',N'EDWIN',N'917510333',N'Av. Belaúnde 752, Comas','20231031'),
    (250,N'26419779',N'DELGADO',N'CABRERA',N'RENATO',N'980850091',N'Calle Los Girasoles 1507, San Martín de Porres','20240330'),
    (251,N'77942639',N'HUAMAN',N'OROZCO',N'LORENA',N'916171165',N'Av. Aviación 205, San Borja','20260716'),
    (252,N'76604777',N'ESTRADA',N'CRUZ',N'JORGE LUIS',N'923790758',N'Jr. Los Girasoles 1594, Comas','20241201'),
    (253,N'71417100',N'CASTRO',N'VARGAS',N'DANIEL',N'987246338',N'Jr. Los Álamos 812, Santiago de Surco','20260901'),
    (254,N'52622436',N'GONZALES',N'MEDINA',N'MARIA ELENA',N'961302124',N'Jr. Los Pinos 114, Ate','20260827'),
    (255,N'52350164',N'LAZO',N'CHAVEZ',N'HILDA',N'900138262',N'Jr. Los Pinos 303, Magdalena del Mar','20230906'),
    (256,N'28353924',N'PEREZ',N'ALVAREZ',N'PILAR',N'941463965',N'Psje. Los Olivos 295, Ate','20260907'),
    (257,N'70094344',N'ZAVALETA',N'MARTINEZ',N'NANCY',N'981595410',N'Calle Bolognesi 2098, Comas','20261004'),
    (258,N'10569492',N'CONDORI',N'CORONADO',N'JHONATAN',N'944064073',N'Calle Los Olivos 1403, Miraflores','20241021'),
    (259,N'46385312',N'TORRES',N'ARCE',N'JESSICA',N'985685728',N'Av. Benavides 1101, Miraflores','20241231'),
    (260,N'42247313',N'GUTIERREZ',N'DE LA CRUZ',N'PATRICIA',N'996163245',N'Av. Perú 932, San Martín de Porres','20241125'),
    (261,N'76591779',N'SILVA',N'ACUÑA',N'JUAN CARLOS',N'959043878',N'Psje. Arequipa 393, Santiago de Surco','20250216'),
    (262,N'76256491',N'TICONA',N'REYES',N'VICTOR HUGO',N'988398043',N'Av. San Borja Norte 1336, San Borja','20250706'),
    (263,N'59426425',N'PACHECO',N'GUTIERREZ',N'ANA LUCIA',N'973428719',N'Jr. Miguel Grau 201, Magdalena del Mar','20241226'),
    (264,N'74612560',N'BENITES',N'ARIAS',N'LORENA',N'922448787',N'Calle Las Orquídeas 203, Comas','20240704'),
    (265,N'75671636',N'FERNANDEZ',N'LAZO',N'HILDA',N'932227000',N'Av. Túpac Amaru 257, Comas','20260109'),
    (266,N'75239262',N'ZAVALETA',N'LEON',N'ROBERTO CARLOS',N'940328520',N'Psje. Ayacucho 1648, Ate','20250513'),
    (267,N'59028881',N'HUERTA',N'ROMERO',N'KATHERINE',N'977926641',N'Av. San Borja Norte 1799, San Borja','20241018'),
    (268,N'63300462',N'CHAMBI',N'PACHECO',N'GUSTAVO',N'924230391',N'Av. Universitaria 317, Comas','20230521'),
    (269,N'31699451',N'DELGADO',N'LOPEZ',N'IVAN',N'900318493',N'Av. Javier Prado Este 1331, San Borja','20260225'),
    (270,N'17226044',N'RAMIREZ',N'AGUILAR',N'ANDRES',N'903752401',N'Av. Javier Prado Este 1500, Ate','20251126'),
    (271,N'36574152',N'TAPIA',N'CORONADO',N'ELVIRA',N'917479204',N'Av. Aviación 1773, San Borja','20260404'),
    (272,N'75647094',N'LOPEZ',N'ESTRADA',N'SANDRA',N'949107568',N'Jr. Tacna 220, San Martín de Porres','20250622'),
    (273,N'35656927',N'QUISPE',N'REYES',N'SILVIA',N'976691121',N'Calle Los Laureles 540, San Martín de Porres','20240612'),
    (274,N'70137831',N'ESTRADA',N'FERNANDEZ',N'JUAN CARLOS',N'913627241',N'Calle Las Acacias 123, Santiago de Surco','20240711'),
    (275,N'59831833',N'CORONADO',N'ESTRADA',N'EDWIN',N'970948711',N'Av. Alfredo Mendiola 1151, San Martín de Porres','20251225'),
    (276,N'51117751',N'DIAZ',N'VARGAS',N'SERGIO',N'951258594',N'Av. Javier Prado Este 1148, Ate','20250325'),
    (277,N'70903475',N'JIMENEZ',N'JIMENEZ',N'ROCIO',N'991478622',N'Jr. Cusco 1312, Santiago de Surco','20241228'),
    (278,N'55566012',N'CASTILLO',N'ZEGARRA',N'CHRISTIAN',N'908718117',N'Psje. Santa Rosa 126, Jesús María','20250907'),
    (279,N'29673082',N'REYES',N'YUPANQUI',N'JULIA ESTHER',N'924111489',N'Psje. Tacna 354, Comas','20241025'),
    (280,N'53691734',N'OROZCO',N'YUPANQUI',N'PEDRO PABLO',N'913232111',N'Jr. Las Palmeras 353, La Molina','20250508'),
    (281,N'77035821',N'CASTRO',N'IPARRAGUIRRE',N'OSCAR',N'955602806',N'Calle Junín 1192, La Molina','20250928'),
    (282,N'70630649',N'DIAZ',N'FARFAN',N'HECTOR MANUEL',N'946657174',N'Av. Caminos del Inca 417, Santiago de Surco','20241226'),
    (283,N'54688209',N'VASQUEZ',N'DEL AGUILA',N'PATRICIA',N'989489806',N'Calle Huallaga 1679, San Martín de Porres','20240411'),
    (284,N'18930994',N'VALDIVIA',N'NAVARRO',N'NANCY',N'981564252',N'Av. Aviación 556, San Borja','20250428'),
    (285,N'25965976',N'CASTILLO',N'IPARRAGUIRRE',N'ALEXANDER',N'935483691',N'Calle Tacna 1086, San Juan de Lurigancho','20260721'),
    (286,N'61766196',N'SANCHEZ',N'LOPEZ',N'ROSA MARIA',N'989456197',N'Av. Raúl Ferrero 1307, La Molina','20260314'),
    (287,N'13086150',N'MAMANI',N'ZEGARRA',N'OMAR',N'954591754',N'Jr. Arequipa 523, Santiago de Surco','20240716'),
    (288,N'51949964',N'SOTO',N'ARCE',N'FLOR DE MARIA',N'992246922',N'Av. Alameda del Corregidor 1228, La Molina','20230905'),
    (289,N'23645765',N'ARIAS',N'DELGADO',N'SILVIA',N'937159491',N'Jr. Los Girasoles 1290, San Borja','20250718'),
    (290,N'25375175',N'RAMIREZ',N'MEDINA',N'ROSA MARIA',N'914075172',N'Av. Javier Prado Este 1047, Ate','20240827'),
    (291,N'27071065',N'PACHECO',N'SOTO',N'RAUL',N'949701722',N'Psje. Las Begonias 452, Ate','20250422'),
    (292,N'21644472',N'YUPANQUI',N'CABRERA',N'TERESA',N'976264574',N'Jr. Los Girasoles 1852, Jesús María','20241213'),
    (293,N'40181119',N'VEGA',N'ZEGARRA',N'PEDRO PABLO',N'947463081',N'Av. Alfredo Mendiola 330, San Martín de Porres','20260520'),
    (294,N'74474444',N'CAMPOS',N'RAMOS',N'ROCIO',N'939742402',N'Av. Bolívar 1043, Magdalena del Mar','20230514'),
    (295,N'62343309',N'QUISPE',N'CASTILLO',N'VERONICA',N'995490194',N'Psje. Tacna 1446, San Borja','20251017'),
    (296,N'17778326',N'ZAVALETA',N'FARFAN',N'ANA LUCIA',N'950750865',N'Jr. Las Acacias 1584, Comas','20260505'),
    (297,N'42931532',N'CHAMBI',N'ROMERO',N'CARMEN ROSA',N'950778225',N'Av. Raúl Ferrero 1500, La Molina','20240924'),
    (298,N'25706155',N'ALVAREZ',N'CASTRO',N'ROSA MARIA',N'961734080',N'Av. Javier Prado Oeste 1743, Magdalena del Mar','20240831'),
    (299,N'51377678',N'VALDIVIA',N'NUÑEZ',N'KATHERINE',N'998132701',N'Jr. Santa Rosa 1850, La Molina','20251231'),
    (300,N'15743784',N'CAMPOS',N'PEREZ',N'GLORIA',N'956183018',N'Av. Nicolás Ayllón 231, Ate','20241231'),
    (301,N'15017483',N'GUERRA',N'ZEGARRA',N'EDUARDO',N'950428304',N'Av. Cuba 179, San Borja','20251019'),
    (302,N'11840307',N'CONDORI',N'TAPIA',N'ELVIRA',N'968689241',N'Psje. Los Álamos 1627, Comas','20240729'),
    (303,N'32455567',N'CHAVEZ',N'YUPANQUI',N'JESSICA',N'925782650',N'Av. Salaverry 208, Jesús María','20240226'),
    (304,N'49855592',N'VEGA',N'MENDOZA',N'MARLENE',N'902003281',N'Av. Naranjal 1653, San Martín de Porres','20240524'),
    (305,N'20118060',N'LAZO',N'NUÑEZ',N'EDUARDO',N'932852416',N'Jr. Ayacucho 1771, Santiago de Surco','20231111'),
    (306,N'33784571',N'VILCA',N'ACUÑA',N'JAVIER',N'931013266',N'Psje. Miguel Grau 1462, Magdalena del Mar','20240628'),
    (307,N'32807658',N'HUAMAN',N'CONDORI',N'SONIA PATRICIA',N'999583100',N'Av. Naranjal 675, San Martín de Porres','20250304'),
    (308,N'11616589',N'SALINAS',N'BENITES',N'SILVIA',N'906081494',N'Av. Túpac Amaru 833, Comas','20251229'),
    (309,N'49009324',N'VARGAS',N'TICONA',N'LUIS MIGUEL',N'941802389',N'Av. Universitaria 230, Comas','20240908'),
    (310,N'42557428',N'CARDENAS',N'HUAMAN',N'DELIA',N'994366506',N'Av. Canto Grande 1535, San Juan de Lurigancho','20240924'),
    (311,N'37577441',N'TAPIA',N'NUÑEZ',N'PILAR',N'953089190',N'Jr. Cusco 973, San Martín de Porres','20241022'),
    (312,N'29570628',N'RODRIGUEZ',N'ESTRADA',N'LUZ MARINA',N'917979111',N'Av. Las Flores 408, San Juan de Lurigancho','20231004'),
    (313,N'43910362',N'TAPIA',N'CASTRO',N'JHONATAN',N'903871977',N'Psje. Huallaga 758, Comas','20241019'),
    (314,N'69453138',N'DELGADO',N'ESTRADA',N'LUIS ENRIQUE',N'987197638',N'Av. Javier Prado Oeste 920, Magdalena del Mar','20250814'),
    (315,N'56377779',N'TORRES',N'TICONA',N'JESSICA',N'938879305',N'Calle Huallaga 1553, Ate','20251129'),
    (316,N'26823875',N'RAMOS',N'OLIVERA',N'FERNANDO',N'914966445',N'Av. Nicolás Ayllón 2019, Ate','20241020'),
    (317,N'52890766',N'RAMIREZ',N'PALACIOS',N'NANCY',N'903282260',N'Jr. Tacna 1091, San Juan de Lurigancho','20231204'),
    (318,N'67650328',N'GUTIERREZ',N'SOTO',N'CARLOS ALBERTO',N'979894775',N'Calle Las Orquídeas 402, San Borja','20230606'),
    (319,N'74264265',N'BENITES',N'VILCA',N'EDWIN',N'956846217',N'Av. Separadora Industrial 1980, Ate','20240407'),
    (320,N'71620003',N'BENITES',N'AGUILAR',N'FRANCISCO',N'905807284',N'Calle Las Magnolias 525, Comas','20230609'),
    (321,N'48236792',N'PEREZ',N'QUISPE',N'JAVIER',N'987352961',N'Av. Túpac Amaru 2066, Comas','20240711'),
    (322,N'16513835',N'RAMOS',N'SALAZAR',N'NANCY',N'963812287',N'Av. Túpac Amaru 294, Comas','20240430'),
    (323,N'34736313',N'MENDOZA',N'VILCA',N'YESENIA',N'955638820',N'Calle Ayacucho 634, San Juan de Lurigancho','20230715'),
    (324,N'64751698',N'GARCIA',N'SANCHEZ',N'PILAR',N'990737395',N'Psje. San Martín 813, Magdalena del Mar','20250301'),
    (325,N'63877899',N'VARGAS',N'CASTRO',N'WALTER',N'932427813',N'Av. Alfredo Mendiola 1466, San Martín de Porres','20260518'),
    (326,N'64104769',N'VEGA',N'NAVARRO',N'JHONATAN',N'928641348',N'Jr. Los Cipreses 626, San Juan de Lurigancho','20260323'),
    (327,N'12271098',N'SILVA',N'DE LA CRUZ',N'BEATRIZ',N'919201941',N'Av. Pardo 1702, Miraflores','20260705'),
    (328,N'19985300',N'ROJAS',N'GOMEZ',N'KEVIN',N'980867439',N'Av. La Molina 1129, La Molina','20230926'),
    (329,N'50100916',N'TAPIA',N'NAVARRO',N'CARLOS ALBERTO',N'991803523',N'Psje. Huallaga 651, San Juan de Lurigancho','20241213'),
    (330,N'10713936',N'DIAZ',N'MALDONADO',N'DIANA CAROLINA',N'904137025',N'Jr. Las Flores 569, La Molina','20260706'),
    (331,N'71323251',N'TAPIA',N'OLIVERA',N'YESENIA',N'958756586',N'Psje. Los Olivos 185, Ate','20260529'),
    (332,N'67429105',N'DELGADO',N'RODRIGUEZ',N'ROSA MARIA',N'995008765',N'Av. Salaverry 117, Jesús María','20241210'),
    (333,N'20526105',N'ARCE',N'TORRES',N'PILAR',N'979124696',N'Av. San Borja Norte 236, San Borja','20230711'),
    (334,N'74137343',N'YUPANQUI',N'TORRES',N'OLGA',N'956938810',N'Av. Las Flores 2044, San Juan de Lurigancho','20241225'),
    (335,N'31150771',N'VILCA',N'FERNANDEZ',N'ROBERTO CARLOS',N'955012318',N'Jr. Miguel Grau 1651, Ate','20231221'),
    (336,N'69110737',N'SILVA',N'TORRES',N'CARLOS ALBERTO',N'933836310',N'Av. Cuba 612, San Borja','20240324'),
    (337,N'63051978',N'ZAVALETA',N'ZAVALETA',N'DELIA',N'952539704',N'Jr. Tacna 818, San Juan de Lurigancho','20260227'),
    (338,N'52488169',N'QUISPE',N'DE LA VEGA',N'OMAR',N'942493180',N'Av. Brasil 389, Magdalena del Mar','20241030'),
    (339,N'53922301',N'REYES',N'BENITES',N'KEVIN',N'992344161',N'Calle Arequipa 1832, Ate','20250926'),
    (340,N'53078110',N'ALVAREZ',N'CABRERA',N'CESAR AUGUSTO',N'900763605',N'Psje. Las Palmeras 1465, Jesús María','20240818'),
    (341,N'41349952',N'ALVAREZ',N'SANCHEZ',N'ANDRES',N'987711293',N'Psje. Santa Rosa 319, San Martín de Porres','20250720'),
    (342,N'10640688',N'YUPANQUI',N'OROZCO',N'JUAN CARLOS',N'957423625',N'Av. Los Fresnos 1280, La Molina','20240929'),
    (343,N'48317019',N'SALINAS',N'YUPANQUI',N'WALTER',N'947653793',N'Av. Próceres de la Independencia 1127, San Juan de Lurigancho','20260216'),
    (344,N'64169098',N'NUÑEZ',N'BENITES',N'KARINA',N'969491420',N'Calle Tacna 192, Santiago de Surco','20260304'),
    (345,N'55719212',N'YUPANQUI',N'FARFAN',N'ALEXANDER',N'957778305',N'Jr. Arequipa 396, San Juan de Lurigancho','20250511'),
    (346,N'70414162',N'BENITES',N'CASTILLO',N'DIEGO ALONSO',N'940538650',N'Jr. Los Cipreses 1057, Ate','20241012'),
    (347,N'54109713',N'GUTIERREZ',N'DE LA CRUZ',N'RAUL',N'998433246',N'Calle Los Jazmines 938, San Martín de Porres','20250129'),
    (348,N'52525332',N'VARGAS',N'ZEGARRA',N'ROBERTO CARLOS',N'908822053',N'Av. Aviación 1943, San Borja','20251126'),
    (349,N'51725842',N'YUPANQUI',N'VALDIVIA',N'SANDRA',N'933878801',N'Av. Cuba 638, Jesús María','20240304'),
    (350,N'15431999',N'PALACIOS',N'JIMENEZ',N'MILAGROS',N'965223855',N'Calle Arequipa 1394, Jesús María','20260423'),
    (351,N'56906428',N'CHAVEZ',N'NAVARRO',N'IVAN',N'920849890',N'Av. Belaúnde 1124, Comas','20230705'),
    (352,N'37110833',N'GUTIERREZ',N'FERNANDEZ',N'IVAN',N'985338068',N'Psje. Los Olivos 737, Santiago de Surco','20240811'),
    (353,N'55742771',N'GOMEZ',N'NUÑEZ',N'NELSON',N'918290570',N'Calle Los Pinos 164, Santiago de Surco','20260726'),
    (354,N'11052950',N'ALVAREZ',N'QUISPE',N'SONIA PATRICIA',N'991577792',N'Av. Nicolás Ayllón 941, Ate','20251020'),
    (355,N'73855347',N'AGUILAR',N'BENITES',N'ROSA MARIA',N'923154046',N'Av. Canto Grande 1551, San Juan de Lurigancho','20250910'),
    (356,N'42126567',N'VEGA',N'HUERTA',N'GUSTAVO',N'901389123',N'Calle Los Jazmines 2009, San Martín de Porres','20240424'),
    (357,N'19995218',N'PALACIOS',N'ARCE',N'NANCY',N'918626956',N'Jr. Junín 566, San Juan de Lurigancho','20241202'),
    (358,N'59006174',N'RAMIREZ',N'PEREZ',N'DIANA CAROLINA',N'981720891',N'Av. Los Fresnos 1671, La Molina','20231031'),
    (359,N'35548111',N'CORONADO',N'AGUILAR',N'JULIA ESTHER',N'900835766',N'Av. Las Flores 541, San Juan de Lurigancho','20260514'),
    (360,N'67299054',N'TAPIA',N'GARCIA',N'RICARDO',N'926014571',N'Av. Pardo 337, Miraflores','20230727'),
    (361,N'25377814',N'SALINAS',N'FERNANDEZ',N'VERONICA',N'965566024',N'Av. Canto Grande 1568, San Juan de Lurigancho','20240524'),
    (362,N'60470506',N'TICONA',N'VALDIVIA',N'MONICA',N'957351576',N'Calle Las Begonias 1011, Magdalena del Mar','20240423'),
    (363,N'30736673',N'TICONA',N'FERNANDEZ',N'RICARDO',N'913692149',N'Av. Arenales 1236, Jesús María','20240504'),
    (364,N'18745124',N'YUPANQUI',N'QUISPE',N'LUIS ENRIQUE',N'960388823',N'Av. Alameda del Corregidor 719, La Molina','20260303'),
    (365,N'29971964',N'PEREZ',N'RODRIGUEZ',N'LORENA',N'984064592',N'Calle Los Girasoles 231, Ate','20240112'),
    (366,N'59569048',N'PEREZ',N'TAPIA',N'JESSICA',N'994537024',N'Av. Alfredo Mendiola 152, San Martín de Porres','20240614'),
    (367,N'33968729',N'PAREDES',N'PALACIOS',N'JAVIER',N'902906019',N'Psje. Junín 1600, La Molina','20241105'),
    (368,N'58051201',N'ROMERO',N'SALAZAR',N'SANDRA',N'919454360',N'Av. Los Fresnos 1710, La Molina','20250227'),
    (369,N'22556713',N'ALVAREZ',N'VEGA',N'DANIEL',N'971922919',N'Av. Canto Grande 1761, San Juan de Lurigancho','20250518'),
    (370,N'10013105',N'TAPIA',N'CABRERA',N'JUANA',N'987559541',N'Av. Tomás Valle 1868, San Martín de Porres','20240129'),
    (371,N'28492007',N'PAREDES',N'QUISPE',N'RICARDO',N'942954613',N'Av. Los Chancas 1149, Ate','20250423'),
    (372,N'64337456',N'MAMANI',N'YUPANQUI',N'VERONICA',N'916595599',N'Av. Túpac Amaru 1384, Comas','20250527'),
    (373,N'60029895',N'VEGA',N'ESPINOZA',N'MARLENE',N'940925410',N'Calle Los Girasoles 1849, Jesús María','20240717'),
    (374,N'35678389',N'PALACIOS',N'GUERRA',N'MARIA ELENA',N'900778416',N'Psje. Las Acacias 1713, Santiago de Surco','20260308'),
    (375,N'50302233',N'REYES',N'YUPANQUI',N'DANIEL',N'981344983',N'Psje. Tacna 1551, Comas','20241203'),
    (376,N'55925799',N'ARCE',N'HUAMAN',N'PABLO',N'903856224',N'Jr. Los Álamos 829, Miraflores','20231029'),
    (377,N'75686213',N'OROZCO',N'MALDONADO',N'CARMEN ROSA',N'941937508',N'Psje. Los Cipreses 1062, Jesús María','20231122'),
    (378,N'18398391',N'AGUILAR',N'CHAMBI',N'JUAN CARLOS',N'902532131',N'Av. Belaúnde 380, Comas','20250628'),
    (379,N'17909041',N'TICONA',N'ESTRADA',N'NELSON',N'923372446',N'Av. Tomás Valle 317, San Martín de Porres','20230701'),
    (380,N'42436203',N'ESTRADA',N'CONDORI',N'SONIA PATRICIA',N'935550874',N'Psje. Bolognesi 1693, Comas','20261002'),
    (381,N'53476237',N'TICONA',N'QUISPE',N'OLGA',N'973056134',N'Av. Angamos 875, Miraflores','20260224'),
    (382,N'47821988',N'BRAVO',N'HUAMAN',N'CARLOS ALBERTO',N'954509952',N'Calle Las Flores 1413, San Martín de Porres','20260329'),
    (383,N'79413472',N'YUPANQUI',N'NAVARRO',N'VERONICA',N'901875254',N'Av. Cuba 466, San Borja','20251108'),
    (384,N'46689266',N'SALAZAR',N'GARCIA',N'MARLENE',N'981441138',N'Av. Perú 943, San Martín de Porres','20260629'),
    (385,N'19251762',N'DELGADO',N'BENITES',N'OLGA',N'981812713',N'Av. Canto Grande 703, San Juan de Lurigancho','20250709'),
    (386,N'63346839',N'HUAMAN',N'TORRES',N'RENATO',N'933379611',N'Av. Naranjal 1053, San Martín de Porres','20250418'),
    (387,N'14396892',N'SANCHEZ',N'SOTO',N'MANUEL',N'930820076',N'Calle Las Magnolias 412, La Molina','20250109'),
    (388,N'31252930',N'GOMEZ',N'MAMANI',N'FRANCISCO',N'955197497',N'Av. Tomás Valle 1342, San Martín de Porres','20241207'),
    (389,N'59717244',N'PAREDES',N'ARIAS',N'MARIO',N'975028856',N'Av. Canto Grande 1552, San Juan de Lurigancho','20260531'),
    (390,N'17586899',N'SILVA',N'FERNANDEZ',N'RICARDO',N'941595037',N'Calle Los Jazmines 357, San Borja','20241011'),
    (391,N'63711330',N'ARCE',N'QUISPE',N'FRANCISCO',N'955757509',N'Av. Wiese 2041, San Juan de Lurigancho','20251218'),
    (392,N'33460112',N'SILVA',N'REYES',N'SILVIA',N'999822754',N'Av. Separadora Industrial 703, Ate','20260704'),
    (393,N'24858882',N'BRAVO',N'LOPEZ',N'OMAR',N'915253046',N'Jr. San Martín 523, Comas','20260327'),
    (394,N'21528464',N'BENITES',N'DE LA VEGA',N'RICARDO',N'981408651',N'Av. Alfredo Mendiola 1549, San Martín de Porres','20240105'),
    (395,N'72306053',N'MEDINA',N'OLIVERA',N'JUANA',N'904104202',N'Av. Javier Prado Este 1108, Ate','20230729'),
    (396,N'29368390',N'ESPINOZA',N'SILVA',N'FRANCISCO',N'907056432',N'Av. Universitaria 404, Comas','20240228'),
    (397,N'66492993',N'RODRIGUEZ',N'OLIVERA',N'ANA LUCIA',N'966640538',N'Calle Junín 1447, Magdalena del Mar','20240524'),
    (398,N'35790401',N'RAMOS',N'TICONA',N'SILVIA',N'972182522',N'Av. Los Incas 1587, Comas','20260702'),
    (399,N'21613431',N'OLIVERA',N'FARFAN',N'KARINA',N'926649787',N'Av. Los Incas 194, Comas','20250212'),
    (400,N'23524913',N'BRAVO',N'SILVA',N'PILAR',N'906062235',N'Av. Tomás Marsano 1007, Santiago de Surco','20261013'),
    (401,N'40672459',N'ACUÑA',N'PALACIOS',N'MARIO',N'995668123',N'Jr. Los Álamos 649, Comas','20250608'),
    (402,N'53971722',N'VASQUEZ',N'MENDOZA',N'JHONATAN',N'958402895',N'Calle Los Girasoles 1470, Magdalena del Mar','20240423'),
    (403,N'34031162',N'BENITES',N'RODRIGUEZ',N'EDUARDO',N'927424582',N'Av. Tomás Marsano 533, Santiago de Surco','20230813'),
    (404,N'30287293',N'TICONA',N'CASTRO',N'JOSE LUIS',N'958030071',N'Calle Los Laureles 1171, Magdalena del Mar','20240910'),
    (405,N'78149928',N'TAPIA',N'ESTRADA',N'JORGE LUIS',N'994919917',N'Av. Salaverry 1799, Jesús María','20241009'),
    (406,N'24971231',N'ROJAS',N'AGUILAR',N'DANIEL',N'953082447',N'Av. Tomás Marsano 1427, Santiago de Surco','20240915'),
    (407,N'53512462',N'ROMERO',N'GONZALES',N'OSCAR',N'947055125',N'Calle Los Eucaliptos 173, La Molina','20251124'),
    (408,N'43230996',N'REYES',N'SALINAS',N'CARMEN ROSA',N'992092560',N'Psje. Santa Rosa 1815, Jesús María','20260930'),
    (409,N'58800955',N'ACUÑA',N'FERNANDEZ',N'MONICA',N'901390879',N'Av. Aviación 1645, San Borja','20260204'),
    (410,N'63079326',N'ALVAREZ',N'MARTINEZ',N'PILAR',N'941633227',N'Av. San Borja Norte 702, San Borja','20231207'),
    (411,N'38741904',N'GUTIERREZ',N'ROJAS',N'NANCY',N'949612449',N'Av. Belaúnde 513, Comas','20231014'),
    (412,N'32876946',N'SILVA',N'CASTILLO',N'OMAR',N'917485137',N'Av. Perú 350, San Martín de Porres','20241105'),
    (413,N'19556608',N'TICONA',N'QUISPE',N'DANIEL',N'988928215',N'Av. Los Incas 1212, Comas','20231009'),
    (414,N'71603205',N'LAZO',N'LOPEZ',N'OSCAR',N'946049370',N'Psje. Bolognesi 359, San Borja','20260808'),
    (415,N'19668758',N'PACHECO',N'BENITES',N'JORGE LUIS',N'927515140',N'Psje. Las Orquídeas 774, Ate','20230502'),
    (416,N'21429600',N'GARCIA',N'BENITES',N'JULIA ESTHER',N'911239038',N'Av. Belaúnde 1781, Comas','20250518'),
    (417,N'51674644',N'VASQUEZ',N'GOMEZ',N'OSCAR',N'932392466',N'Av. Raúl Ferrero 988, La Molina','20240926'),
    (418,N'25449326',N'TAPIA',N'JIMENEZ',N'HILDA',N'985337920',N'Av. Perú 925, San Martín de Porres','20250111'),
    (419,N'53168610',N'VARGAS',N'PAREDES',N'NANCY',N'978831765',N'Psje. Los Jazmines 273, Jesús María','20230907'),
    (420,N'53879689',N'GOMEZ',N'ARCE',N'VICTOR HUGO',N'930876826',N'Av. Cuba 1936, Jesús María','20250509'),
    (421,N'74112721',N'FARFAN',N'OROZCO',N'HILDA',N'965309891',N'Calle Arequipa 681, Santiago de Surco','20251007'),
    (422,N'72010722',N'FERNANDEZ',N'GUERRA',N'PABLO',N'978960355',N'Av. Alfredo Mendiola 1498, San Martín de Porres','20231027'),
    (423,N'74835983',N'CASTILLO',N'PACHECO',N'DANIEL',N'932857168',N'Av. Bolívar 203, Magdalena del Mar','20250624'),
    (424,N'59301459',N'CORONADO',N'DE LA VEGA',N'FLOR DE MARIA',N'978109167',N'Jr. Huallaga 1940, Magdalena del Mar','20250318'),
    (425,N'37735621',N'TICONA',N'MAMANI',N'WALTER',N'935527685',N'Psje. Las Orquídeas 284, Magdalena del Mar','20231109'),
    (426,N'46559169',N'GOMEZ',N'GONZALES',N'ALEXANDER',N'970929950',N'Psje. Arequipa 864, Santiago de Surco','20250224'),
    (427,N'52228506',N'OROZCO',N'REYES',N'MANUEL',N'936255165',N'Psje. Las Begonias 994, San Juan de Lurigancho','20250102'),
    (428,N'50192178',N'CORONADO',N'MARTINEZ',N'MIGUEL ANGEL',N'915334966',N'Psje. Los Laureles 1557, Comas','20240512'),
    (429,N'22231444',N'GUERRA',N'CASTRO',N'TERESA',N'972578017',N'Jr. Los Cedros 788, La Molina','20240217'),
    (430,N'44693578',N'MEDINA',N'QUISPE',N'MIGUEL ANGEL',N'916506991',N'Av. Salaverry 2032, Jesús María','20241015'),
    (431,N'46526469',N'GARCIA',N'AGUILAR',N'KEVIN',N'960229899',N'Jr. Las Palmeras 1128, Ate','20230916'),
    (432,N'51273753',N'LEON',N'CARDENAS',N'SERGIO',N'944468758',N'Av. Las Flores 2078, San Juan de Lurigancho','20230731'),
    (433,N'46544333',N'SALINAS',N'DEL AGUILA',N'LUIS ENRIQUE',N'972489537',N'Calle Bolognesi 791, San Martín de Porres','20230623'),
    (434,N'24269926',N'CASTRO',N'NUÑEZ',N'ELIZABETH',N'906442463',N'Av. Tomás Marsano 512, Santiago de Surco','20261010'),
    (435,N'56826742',N'TAPIA',N'CARDENAS',N'YESENIA',N'969778324',N'Av. Tomás Valle 1406, San Martín de Porres','20250609'),
    (436,N'31837408',N'TORRES',N'RAMOS',N'JUANA',N'956036486',N'Av. Primavera 1151, Santiago de Surco','20240107'),
    (437,N'10144493',N'TICONA',N'LEON',N'RAUL',N'966433454',N'Jr. Miguel Grau 224, Ate','20260828'),
    (438,N'69046078',N'ARCE',N'CONDORI',N'GLORIA',N'944750776',N'Av. Tomás Marsano 1531, Santiago de Surco','20241128'),
    (439,N'73661760',N'MENDOZA',N'DELGADO',N'EDWIN',N'977762713',N'Av. Benavides 1880, Miraflores','20250805'),
    (440,N'75589105',N'MARTINEZ',N'DE LA VEGA',N'ROXANA',N'995965008',N'Calle Santa Rosa 274, La Molina','20261012'),
    (441,N'59538076',N'CARDENAS',N'CRUZ',N'DIEGO ALONSO',N'963425870',N'Jr. Cusco 717, Magdalena del Mar','20250202'),
    (442,N'62809781',N'MENDOZA',N'GUTIERREZ',N'RAUL',N'942920897',N'Jr. Cusco 491, Santiago de Surco','20260619'),
    (443,N'61857513',N'PEREZ',N'GOMEZ',N'BEATRIZ',N'916697068',N'Psje. Tacna 1805, Santiago de Surco','20230725'),
    (444,N'59766259',N'TAPIA',N'VILCA',N'IVAN',N'937010722',N'Calle Arequipa 140, San Martín de Porres','20260507'),
    (445,N'64151263',N'URBANO',N'SOTO',N'CARMEN ROSA',N'965844184',N'Jr. Los Cedros 499, Santiago de Surco','20250626'),
    (446,N'34182770',N'DELGADO',N'SALINAS',N'INES',N'988340883',N'Av. Sucre 660, Magdalena del Mar','20250414'),
    (447,N'50579707',N'RODRIGUEZ',N'RODRIGUEZ',N'JUAN CARLOS',N'965554183',N'Jr. Los Girasoles 1160, Miraflores','20230902'),
    (448,N'34575486',N'ESPINOZA',N'AGUILAR',N'ROXANA',N'969409037',N'Calle Los Laureles 1764, Ate','20251108'),
    (449,N'58339728',N'AGUILAR',N'DEL AGUILA',N'MIGUEL ANGEL',N'914335318',N'Jr. Las Begonias 920, San Juan de Lurigancho','20240622'),
    (450,N'43322872',N'BENITES',N'ZEGARRA',N'OMAR',N'925590662',N'Calle Las Orquídeas 1405, San Martín de Porres','20240417'),
    (451,N'32853815',N'SALAZAR',N'HUAMAN',N'JHONATAN',N'938695690',N'Av. Wiese 1171, San Juan de Lurigancho','20260629'),
    (452,N'56203698',N'GUTIERREZ',N'MENDOZA',N'OSCAR',N'912103422',N'Psje. Las Acacias 1311, Comas','20260311'),
    (453,N'30604007',N'MAMANI',N'ALVAREZ',N'DELIA',N'946779658',N'Psje. Las Acacias 1458, Magdalena del Mar','20240209'),
    (454,N'78008395',N'VILCA',N'NUÑEZ',N'PABLO',N'927357570',N'Av. Javier Prado Este 264, San Borja','20250525'),
    (455,N'15580650',N'GARCIA',N'CHAMBI',N'VERONICA',N'941256727',N'Av. Próceres de la Independencia 510, San Juan de Lurigancho','20251025'),
    (456,N'64671867',N'TICONA',N'ARCE',N'BEATRIZ',N'954110548',N'Jr. Los Laureles 1483, Santiago de Surco','20260405'),
    (457,N'43626582',N'JIMENEZ',N'CASTILLO',N'FLOR DE MARIA',N'936206634',N'Jr. Santa Rosa 1141, Santiago de Surco','20241123'),
    (458,N'52099908',N'VEGA',N'NUÑEZ',N'GUSTAVO',N'971609078',N'Jr. Los Girasoles 1391, Comas','20260207'),
    (459,N'51517847',N'SANCHEZ',N'FARFAN',N'JESUS',N'932816699',N'Jr. Los Olivos 523, La Molina','20251122'),
    (460,N'45264687',N'FARFAN',N'NUÑEZ',N'KARINA',N'952468989',N'Av. Aviación 440, San Borja','20241211'),
    (461,N'25183208',N'TORRES',N'DE LA CRUZ',N'LUZ MARINA',N'905134725',N'Psje. Los Eucaliptos 1221, Ate','20251215'),
    (462,N'59719658',N'URBANO',N'MENDOZA',N'RAUL',N'917690136',N'Psje. Las Orquídeas 649, Ate','20251022'),
    (463,N'38518046',N'YUPANQUI',N'GONZALES',N'ALEXANDER',N'930400257',N'Jr. Los Girasoles 831, San Borja','20260306'),
    (464,N'20902456',N'GUTIERREZ',N'CASTRO',N'JUANA',N'905432163',N'Psje. Las Palmeras 2075, Ate','20240926'),
    (465,N'19961100',N'ALVAREZ',N'CABRERA',N'ALEXANDER',N'967606951',N'Psje. Los Jazmines 693, San Juan de Lurigancho','20240405'),
    (466,N'26734012',N'CABRERA',N'CASTRO',N'FERNANDO',N'988054946',N'Calle Los Laureles 1353, San Borja','20260425'),
    (467,N'49265947',N'VILCA',N'VARGAS',N'FERNANDO',N'932353760',N'Psje. Los Pinos 1164, Miraflores','20260331'),
    (468,N'13500013',N'JIMENEZ',N'TAPIA',N'ROCIO',N'907833744',N'Av. Cuba 849, Jesús María','20230908'),
    (469,N'67532430',N'CONDORI',N'VILCA',N'ELIZABETH',N'905083583',N'Psje. Las Acacias 323, Comas','20250816'),
    (470,N'75720759',N'PACHECO',N'TAPIA',N'DIEGO ALONSO',N'921242069',N'Calle San Martín 206, San Juan de Lurigancho','20260603'),
    (471,N'26666465',N'CARDENAS',N'CHAVEZ',N'HUGO',N'943468884',N'Calle San Martín 1992, Jesús María','20260109'),
    (472,N'15637712',N'ZAVALETA',N'VILCA',N'CARMEN ROSA',N'956184867',N'Psje. Las Flores 1128, La Molina','20250612'),
    (473,N'72899329',N'BENITES',N'LEON',N'MANUEL',N'952908299',N'Jr. Los Laureles 1917, Ate','20260329'),
    (474,N'22206641',N'BRAVO',N'ARIAS',N'LUIS MIGUEL',N'984458287',N'Calle Las Begonias 531, San Juan de Lurigancho','20241005'),
    (475,N'11671445',N'VASQUEZ',N'GOMEZ',N'JUAN CARLOS',N'932535267',N'Jr. Miguel Grau 1875, La Molina','20251022'),
    (476,N'43608951',N'PALACIOS',N'HUERTA',N'FERNANDO',N'931585192',N'Av. Benavides 1028, Santiago de Surco','20250506'),
    (477,N'46984541',N'LAZO',N'VARGAS',N'JULIA ESTHER',N'981207810',N'Av. Naranjal 113, San Martín de Porres','20241113'),
    (478,N'61296075',N'SANCHEZ',N'HUERTA',N'CESAR AUGUSTO',N'952013561',N'Calle Santa Rosa 406, Santiago de Surco','20240302'),
    (479,N'13559973',N'ESTRADA',N'LAZO',N'PILAR',N'990335252',N'Av. Túpac Amaru 2062, Comas','20231111'),
    (480,N'54618219',N'NUÑEZ',N'CORONADO',N'PATRICIA',N'945242333',N'Av. Javier Prado Este 1320, Ate','20260412'),
    (481,N'38807064',N'SILVA',N'HUAMAN',N'INES',N'917947408',N'Jr. Las Orquídeas 1437, Miraflores','20240807'),
    (482,N'32743777',N'CABRERA',N'HUERTA',N'LUIS ENRIQUE',N'960622638',N'Calle Los Cipreses 1006, San Martín de Porres','20250304'),
    (483,N'13537040',N'RODRIGUEZ',N'ESTRADA',N'ALEXANDER',N'991760985',N'Jr. Cusco 1440, San Juan de Lurigancho','20240326'),
    (484,N'69787068',N'LEON',N'ACUÑA',N'CHRISTIAN',N'955849099',N'Av. Tomás Marsano 1082, Santiago de Surco','20260416'),
    (485,N'62016082',N'FLORES',N'PAREDES',N'JORGE LUIS',N'921053212',N'Calle Los Eucaliptos 360, Magdalena del Mar','20250702'),
    (486,N'54809394',N'TICONA',N'CRUZ',N'LORENA',N'994276450',N'Av. Javier Prado Este 1084, San Borja','20240529'),
    (487,N'49716647',N'NAVARRO',N'JIMENEZ',N'MARLENE',N'925711174',N'Psje. Las Begonias 663, La Molina','20250409'),
    (488,N'76236844',N'SOTO',N'ZAVALETA',N'SILVIA',N'954743683',N'Av. Benavides 1718, Santiago de Surco','20230514'),
    (489,N'41371634',N'ACUÑA',N'ARIAS',N'NELSON',N'908398791',N'Calle Las Flores 522, Santiago de Surco','20231130'),
    (490,N'41462776',N'TAPIA',N'VEGA',N'OMAR',N'908809449',N'Av. Las Flores 1345, San Juan de Lurigancho','20260122'),
    (491,N'63249717',N'PAREDES',N'HUAMAN',N'YESENIA',N'962345809',N'Calle Miguel Grau 163, San Juan de Lurigancho','20250303'),
    (492,N'17301708',N'SANCHEZ',N'IPARRAGUIRRE',N'ALEXANDER',N'908929667',N'Av. Raúl Ferrero 1097, La Molina','20250119'),
    (493,N'78151815',N'ARCE',N'OLIVERA',N'FLOR DE MARIA',N'914613801',N'Av. Túpac Amaru 1893, Comas','20250805'),
    (494,N'41519908',N'ZEGARRA',N'FARFAN',N'MARIO',N'998660670',N'Av. Perú 382, San Martín de Porres','20231219'),
    (495,N'14532760',N'CRUZ',N'FARFAN',N'GABRIELA',N'966784273',N'Psje. Los Cedros 1032, Ate','20250626'),
    (496,N'25807541',N'BRAVO',N'RAMOS',N'OMAR',N'929967006',N'Av. Salaverry 1274, Jesús María','20230904'),
    (497,N'21272134',N'ZAVALETA',N'DE LA VEGA',N'LORENA',N'918330203',N'Av. Nicolás Ayllón 1810, Ate','20240904'),
    (498,N'27773440',N'PALACIOS',N'AGUILAR',N'KEVIN',N'925777695',N'Av. Wiese 632, San Juan de Lurigancho','20230927'),
    (499,N'11850014',N'CASTILLO',N'GUERRA',N'HILDA',N'953841389',N'Psje. Bolognesi 767, San Juan de Lurigancho','20250904'),
    (500,N'21931334',N'SALINAS',N'PALACIOS',N'TEODORO',N'960199168',N'Av. Naranjal 601, San Martín de Porres','20240502'),
    (501,N'52709584',N'BENITES',N'GARCIA',N'VERONICA',N'960661824',N'Calle Cusco 488, San Juan de Lurigancho','20260518'),
    (502,N'54072988',N'ESTRADA',N'CABRERA',N'OSCAR',N'936242132',N'Jr. Los Eucaliptos 1155, San Martín de Porres','20260609'),
    (503,N'55837540',N'IPARRAGUIRRE',N'DE LA VEGA',N'BEATRIZ',N'965402172',N'Calle Arequipa 968, San Juan de Lurigancho','20240118'),
    (504,N'73558850',N'LAZO',N'HUERTA',N'GABRIELA',N'944131664',N'Jr. Los Olivos 949, Jesús María','20230819'),
    (505,N'34482179',N'RODRIGUEZ',N'BRAVO',N'SILVIA',N'921483384',N'Av. Alameda del Corregidor 858, La Molina','20250402'),
    (506,N'50363445',N'VARGAS',N'QUISPE',N'RENATO',N'992524997',N'Av. Perú 582, San Martín de Porres','20230701'),
    (507,N'69119383',N'QUISPE',N'ESPINOZA',N'OMAR',N'910530561',N'Psje. Las Magnolias 2042, Ate','20250421'),
    (508,N'19875249',N'REYES',N'DEL AGUILA',N'JULIA ESTHER',N'916691198',N'Jr. San Martín 1976, San Martín de Porres','20250316'),
    (509,N'22474786',N'SOTO',N'SOTO',N'INES',N'994041590',N'Av. Belaúnde 1881, Comas','20240902'),
    (510,N'35657041',N'SOTO',N'ALVAREZ',N'JHONATAN',N'946304785',N'Av. Próceres de la Independencia 2087, San Juan de Lurigancho','20251231'),
    (511,N'16162308',N'SALINAS',N'AGUILAR',N'DIEGO ALONSO',N'917960356',N'Psje. Las Begonias 346, San Martín de Porres','20230905'),
    (512,N'13241297',N'LAZO',N'HUERTA',N'GLORIA',N'934790884',N'Calle Los Girasoles 506, Ate','20230928'),
    (513,N'28507286',N'ROJAS',N'CONDORI',N'ROCIO',N'906981962',N'Jr. Ayacucho 360, Santiago de Surco','20260427'),
    (514,N'45747626',N'RAMIREZ',N'VARGAS',N'GLORIA',N'944835305',N'Calle Junín 1625, Magdalena del Mar','20250704'),
    (515,N'26297812',N'VARGAS',N'CABRERA',N'JOSE LUIS',N'962411888',N'Av. Belaúnde 768, Comas','20231125'),
    (516,N'65503322',N'ARCE',N'REYES',N'KATHERINE',N'967074180',N'Av. Belaúnde 983, Comas','20240623'),
    (517,N'71207207',N'TAPIA',N'ACUÑA',N'LORENA',N'976270549',N'Calle Junín 489, La Molina','20230812'),
    (518,N'67182398',N'SILVA',N'VARGAS',N'SANDRA',N'923016952',N'Calle Miguel Grau 477, Miraflores','20250123'),
    (519,N'33684231',N'DIAZ',N'FLORES',N'DELIA',N'976975308',N'Av. Canto Grande 194, San Juan de Lurigancho','20250922'),
    (520,N'29670750',N'CORONADO',N'YUPANQUI',N'CARMEN ROSA',N'958289866',N'Av. Canto Grande 1082, San Juan de Lurigancho','20240426'),
    (521,N'61509430',N'FLORES',N'CONDORI',N'JOSE LUIS',N'986376152',N'Psje. Ayacucho 159, Ate','20230911'),
    (522,N'38691854',N'GUTIERREZ',N'VALDIVIA',N'CARMEN ROSA',N'994460517',N'Av. Alfredo Mendiola 591, San Martín de Porres','20241214'),
    (523,N'49119649',N'PALACIOS',N'DE LA CRUZ',N'PEDRO PABLO',N'945633503',N'Av. Belaúnde 575, Comas','20260618'),
    (524,N'14172520',N'CHAMBI',N'PEREZ',N'ROSA MARIA',N'951520123',N'Calle Cusco 442, La Molina','20250729'),
    (525,N'61100472',N'MALDONADO',N'QUISPE',N'MARIO',N'924704031',N'Jr. Los Laureles 1177, San Juan de Lurigancho','20250927'),
    (526,N'72037062',N'LAZO',N'NAVARRO',N'MIGUEL ANGEL',N'974524060',N'Calle Bolognesi 844, La Molina','20250801'),
    (527,N'73667704',N'ESPINOZA',N'LEON',N'ANDRES',N'925520615',N'Av. Los Fresnos 190, La Molina','20250711'),
    (528,N'13429530',N'ROMERO',N'SILVA',N'PABLO',N'970509645',N'Calle Las Palmeras 1295, Miraflores','20230713'),
    (529,N'14651562',N'FARFAN',N'BRAVO',N'DANIEL',N'968440803',N'Psje. Las Begonias 332, Ate','20260105'),
    (530,N'42758335',N'REYES',N'YUPANQUI',N'RAUL',N'977907341',N'Jr. Los Girasoles 1214, Santiago de Surco','20240825'),
    (531,N'17834268',N'ARCE',N'RAMIREZ',N'ANA LUCIA',N'900313076',N'Av. Túpac Amaru 1769, Comas','20241227'),
    (532,N'72953037',N'HUAMAN',N'CASTILLO',N'CARMEN ROSA',N'966286986',N'Av. Túpac Amaru 1957, Comas','20250128'),
    (533,N'32384647',N'YUPANQUI',N'ARCE',N'GRACIELA',N'996540657',N'Jr. Tacna 363, Santiago de Surco','20260906'),
    (534,N'64355710',N'JIMENEZ',N'CASTRO',N'FLOR DE MARIA',N'930628490',N'Psje. Las Acacias 1295, San Borja','20250314'),
    (535,N'57704381',N'ALVAREZ',N'CASTILLO',N'DIEGO ALONSO',N'943919494',N'Av. Universitaria 2065, Comas','20260526'),
    (536,N'66111417',N'CASTRO',N'BRAVO',N'GLORIA',N'938726177',N'Calle Arequipa 841, San Borja','20240822'),
    (537,N'33668261',N'MAMANI',N'BENITES',N'ROXANA',N'904928461',N'Av. Próceres de la Independencia 555, San Juan de Lurigancho','20260109'),
    (538,N'29038246',N'CHAMBI',N'BRAVO',N'HILDA',N'955369248',N'Psje. Las Begonias 1890, Ate','20260921'),
    (539,N'34544583',N'CRUZ',N'CRUZ',N'DANIEL',N'954953211',N'Jr. Los Laureles 1764, Ate','20260123'),
    (540,N'19011623',N'JIMENEZ',N'ROMERO',N'OMAR',N'999163731',N'Jr. Las Acacias 1358, San Juan de Lurigancho','20251027'),
    (541,N'65248947',N'OROZCO',N'DE LA CRUZ',N'DIEGO ALONSO',N'931967849',N'Jr. Santa Rosa 2002, Santiago de Surco','20251214'),
    (542,N'74302115',N'GUTIERREZ',N'CASTILLO',N'PATRICIA',N'952241808',N'Av. Arenales 1968, Jesús María','20251009'),
    (543,N'28432775',N'NAVARRO',N'RAMIREZ',N'GUSTAVO',N'966472855',N'Jr. Las Flores 307, Santiago de Surco','20240321'),
    (544,N'66512412',N'HUERTA',N'NAVARRO',N'GLORIA',N'905237037',N'Av. Tomás Valle 699, San Martín de Porres','20260205'),
    (545,N'31608170',N'MARTINEZ',N'GONZALES',N'HUGO',N'911960947',N'Jr. Los Jazmines 374, San Martín de Porres','20260603'),
    (546,N'52105566',N'ESTRADA',N'MEDINA',N'DANIEL',N'997899773',N'Calle Cusco 1353, Ate','20260424'),
    (547,N'79882916',N'CRUZ',N'VILCA',N'ANDRES',N'917094850',N'Calle San Martín 933, Ate','20260501'),
    (548,N'56908733',N'SILVA',N'DELGADO',N'VICTOR HUGO',N'915676561',N'Psje. Los Laureles 1572, Santiago de Surco','20260907'),
    (549,N'47288941',N'ROJAS',N'VILCA',N'OSCAR',N'974130333',N'Jr. Los Pinos 1174, San Juan de Lurigancho','20260227'),
    (550,N'34651232',N'PACHECO',N'VILCA',N'HECTOR MANUEL',N'936273859',N'Calle Los Álamos 564, San Martín de Porres','20250711')
) v(seq, dni, ap, am, nombre, telefono, direccion, fecha_registro)
WHERE NOT EXISTS (SELECT 1 FROM dbo.CLIENTE c WHERE c.dni = v.dni)
ORDER BY v.seq;

/* MASCOTA: llaves foráneas tomadas de las tablas existentes */
INSERT INTO dbo.MASCOTA (nombre, fecha_nacimiento, id_cliente, id_raza, id_sexo, id_color, id_ubicacion, ESTADO)
SELECT v.nombre, v.fecha_nacimiento, c.id_cliente, r.id_raza, x.id_sexo, co.id_color, u.id_ubicacion, 1
FROM (VALUES
    (1,N'73049233',N'AINOA','20230219',N'Única',N'Gato',N'Hembra',N'Blanco',N'LOS OLIVOS'),
    (2,N'21102353',N'AKIRA','20210422',N'Única',N'Perro',N'Hembra',N'Negro',N'LOS OLIVOS'),
    (3,N'71161158',N'ALEJANDRITA','20211021',N'Única',N'Gato',N'Hembra',N'Marrón',N'LOS OLIVOS'),
    (4,N'53019203',N'ATILA','20200420',N'Boxer Alemán',N'Perro',N'Hembra',N'Gris',N'LOS OLIVOS'),
    (5,N'17804016',N'BLANQUITA','20230304',N'Shitzu',N'Perro',N'Hembra',N'Crema',N'LOS OLIVOS'),
    (6,N'65683365',N'BAMBAM','20151020',N'Schnauzer',N'Perro',N'Macho',N'Beige',N'LOS OLIVOS'),
    (7,N'92473722',N'BELLA','20200818',N'Única',N'Gato',N'Hembra',N'Canela',N'LOS OLIVOS'),
    (8,N'71042911',N'BLACK','20171019',N'Única',N'Perro',N'Macho',N'Dorado',N'LOS OLIVOS'),
    (9,N'31161878',N'BOCKY','20190422',N'Única',N'Perro',N'Macho',N'Chocolate',N'LOS OLIVOS'),
    (10,N'83495146',N'BRANDY','20210418',N'Única',N'Perro',N'Hembra',N'Café',N'LOS OLIVOS'),
    (11,N'20693447',N'CAMIL','20201021',N'Única',N'Gato',N'Hembra',N'Café claro',N'LOS OLIVOS'),
    (12,N'31843366',N'CAMIL','20220519',N'Única',N'Perro',N'Macho',N'Café oscuro',N'LOS OLIVOS'),
    (13,N'24804339',N'CANELA','20221120',N'Shitzu',N'Perro',N'Hembra',N'Miel',N'LOS OLIVOS'),
    (14,N'59580044',N'COOPER','20221120',N'Poodle con Bichón',N'Perro',N'Macho',N'Arena',N'LOS OLIVOS'),
    (15,N'58200384',N'CECHI','20211020',N'Única',N'Gato',N'Macho',N'Marfil',N'LOS OLIVOS'),
    (16,N'77442758',N'COCO','20150419',N'Única',N'Perro',N'Macho',N'Perla',N'LOS OLIVOS'),
    (17,N'35946785',N'CHATO','20170417',N'Pequines Alvino',N'Perro',N'Macho',N'Hueso',N'LOS OLIVOS'),
    (18,N'66490721',N'CHIQUI','20170417',N'Única',N'Gato',N'Macho',N'Champán',N'LOS OLIVOS'),
    (19,N'83010312',N'CHIQUITA BRAVO','20130422',N'Shitzu',N'Perro',N'Hembra',N'Plateado',N'LOS OLIVOS'),
    (20,N'43622481',N'DEYSI','20160420',N'Schnauzer',N'Perro',N'Hembra',N'Cenizo',N'LOS OLIVOS'),
    (21,N'72987366',N'DOLLY','20200420',N'Única',N'Perro',N'Hembra',N'Gris claro',N'LOS OLIVOS'),
    (22,N'40409222',N'DORITA','20220820',N'Única',N'Gato',N'Hembra',N'Gris oscuro',N'LOS OLIVOS'),
    (23,N'18686265',N'DUNGA','20180419',N'Única',N'Perro',N'Macho',N'Gris plata',N'LOS OLIVOS'),
    (24,N'99982179',N'DUQUESITA','20230221',N'Única',N'Perro',N'Hembra',N'Gris humo',N'LOS OLIVOS'),
    (25,N'82171493',N'ESTRELLITA','20190421',N'Shitzu',N'Perro',N'Hembra',N'Gris carbón',N'LOS OLIVOS'),
    (26,N'59631561',N'FELIPE','20110422',N'Labrador',N'Perro',N'Macho',N'Negro azabache',N'LOS OLIVOS'),
    (27,N'77059003',N'FOXY','20170422',N'Schnauzer',N'Perro',N'Macho',N'Negro mate',N'LOS OLIVOS'),
    (28,N'51883468',N'FRESITA','20230222',N'Única',N'Perro',N'Hembra',N'Negro brillante',N'LOS OLIVOS'),
    (29,N'23274785',N'GRECO','20210819',N'Golden',N'Perro',N'Macho',N'Blanco puro',N'LOS OLIVOS'),
    (30,N'22884877',N'GRINGA','20150422',N'Única',N'Perro',N'Hembra',N'Blanco crema',N'LOS OLIVOS'),
    (31,N'65072361',N'GIORGO','20220522',N'Buldog Frances',N'Perro',N'Macho',N'Blanco humo',N'LOS OLIVOS'),
    (32,N'50357259',N'GOYA','20210521',N'Única',N'Perro',N'Hembra',N'Amarillo claro',N'LOS OLIVOS'),
    (33,N'57394899',N'HASS','20190419',N'Única',N'Perro',N'Hembra',N'Naranja',N'LOS OLIVOS'),
    (34,N'96639359',N'HINDI','20211222',N'Única',N'Perro',N'Hembra',N'Naranja claro',N'LOS OLIVOS'),
    (35,N'45449433',N'HOLLY','20210420',N'Única',N'Gato',N'Macho',N'Naranja oscuro',N'LOS OLIVOS'),
    (36,N'87073258',N'HUGO','20150422',N'Única',N'Gato',N'Macho',N'Rojizo',N'LOS OLIVOS'),
    (37,N'43098654',N'KRATOS','20211021',N'Única',N'Perro',N'Macho',N'Cobrizo',N'LOS OLIVOS'),
    (38,N'76113377',N'KILLA','20211020',N'Perro Peruano',N'Perro',N'Hembra',N'Caoba',N'LOS OLIVOS'),
    (39,N'80879931',N'KLIMB','20070418',N'Terrier Tibetano',N'Perro',N'Macho',N'Avellana',N'LOS OLIVOS'),
    (40,N'71323763',N'KOPI','20211019',N'Schnauzer',N'Perro',N'Macho',N'Trigo',N'LOS OLIVOS'),
    (41,N'71578881',N'KUMA','20220519',N'Única',N'Perro',N'Hembra',N'Mostaza claro',N'LOS OLIVOS'),
    (42,N'14255487',N'LETTY','20170419',N'Sharpein',N'Perro',N'Hembra',N'Ocre',N'LOS OLIVOS'),
    (43,N'17095703',N'LARA','20200420',N'Única',N'Perro',N'Hembra',N'Caramelo',N'LOS OLIVOS'),
    (44,N'77707788',N'LEGOLAS','20220422',N'Siberiano',N'Perro',N'Hembra',N'Almendra',N'LOS OLIVOS'),
    (45,N'44978812',N'LEYA','20190422',N'Siberiano',N'Perro',N'Hembra',N'Nuez',N'LOS OLIVOS'),
    (46,N'78043250',N'LUA','20200420',N'Única',N'Perro',N'Hembra',N'Castaño',N'LOS OLIVOS'),
    (47,N'86028611',N'LUANA','20230418',N'Única',N'Perro',N'Hembra',N'Castaño claro',N'LOS OLIVOS'),
    (48,N'10453063',N'LUNA','20170418',N'Shitzu Toy',N'Perro',N'Hembra',N'Castaño oscuro',N'LOS OLIVOS'),
    (49,N'37811251',N'LUNA','20170418',N'Única',N'Perro',N'Hembra',N'Sable',N'LOS OLIVOS'),
    (50,N'67914971',N'LUCKY','20221120',N'Única',N'Perro',N'Macho',N'Sable claro',N'LOS OLIVOS'),
    (51,N'53474998',N'LUZ','20180421',N'Única',N'Perro',N'Hembra',N'Sable oscuro',N'LOS OLIVOS'),
    (52,N'61755938',N'MAYA','20210521',N'Única',N'Perro',N'Hembra',N'Leonado',N'LOS OLIVOS'),
    (53,N'46340188',N'MAGI','20221220',N'Bichon',N'Perro',N'Hembra',N'Leonado claro',N'LOS OLIVOS'),
    (54,N'79976947',N'MAIA','20220421',N'Cocker Americano',N'Perro',N'Hembra',N'Leonado oscuro',N'LOS OLIVOS'),
    (55,N'52722310',N'MANTY','20220418',N'Única',N'Perro',N'Hembra',N'Atigrado',N'LOS OLIVOS'),
    (56,N'43760409',N'MARA','20210420',N'Schnauzer',N'Perro',N'Hembra',N'Atigrado claro',N'LOS OLIVOS'),
    (57,N'58743611',N'MARLEY','20220222',N'Golden / Cocker',N'Perro',N'Hembra',N'Atigrado oscuro',N'LOS OLIVOS'),
    (58,N'94538328',N'MARRÓN','20110420',N'Única',N'Perro',N'Macho',N'Atigrado gris',N'LOS OLIVOS'),
    (59,N'74519257',N'MARVEL','20230420',N'Única',N'Gato',N'Hembra',N'Atigrado marrón',N'LOS OLIVOS'),
    (60,N'23700218',N'MAYA','20160420',N'Única',N'Perro',N'Hembra',N'Atigrado naranja',N'LOS OLIVOS'),
    (61,N'41585435',N'MAYRO','20190420',N'Única',N'Perro',N'Macho',N'Manchado',N'LOS OLIVOS'),
    (62,N'83258857',N'MINIE','20070418',N'Única',N'Gato',N'Hembra',N'Moteado',N'LOS OLIVOS'),
    (63,N'29051955',N'MININA','20210419',N'Única',N'Gato',N'Hembra',N'Jaspeado',N'LOS OLIVOS'),
    (64,N'36079144',N'MINNA','20160422',N'Cocker Ingles',N'Perro',N'Hembra',N'Rayado',N'LOS OLIVOS'),
    (65,N'93021703',N'MISHA','20210422',N'Única',N'Gato',N'Hembra',N'Bicolor',N'LOS OLIVOS'),
    (66,N'30379788',N'MOLLY','20211018',N'American Bully',N'Perro',N'Hembra',N'Tricolor',N'LOS OLIVOS'),
    (67,N'59086363',N'MOLLY','20210420',N'Cocker',N'Perro',N'Hembra',N'Calicó',N'LOS OLIVOS'),
    (68,N'11703235',N'MONKY','20220221',N'Única',N'Perro',N'Macho',N'Carey',N'LOS OLIVOS'),
    (69,N'58839322',N'NALA','20220422',N'Schnauzer',N'Perro',N'Hembra',N'Tabby',N'LOS OLIVOS'),
    (70,N'50143134',N'NILA','20220721',N'Única',N'Perro',N'Hembra',N'Tabby gris',N'LOS OLIVOS'),
    (71,N'47600393',N'NEGRITA','20180421',N'Única',N'Perro',N'Hembra',N'Tabby marrón',N'LOS OLIVOS'),
    (72,N'19397597',N'NALA','20220420',N'Única',N'Perro',N'Hembra',N'Tabby naranja',N'LOS OLIVOS'),
    (73,N'66369156',N'NENE','20181019',N'Shitzu',N'Perro',N'Macho',N'Blanco y negro',N'LOS OLIVOS'),
    (74,N'32357106',N'NICKY','20180419',N'Única',N'Perro',N'Hembra',N'Blanco y marrón',N'LOS OLIVOS'),
    (75,N'48535253',N'NICO','20160418',N'Schnauzer',N'Perro',N'Macho',N'Blanco y gris',N'LOS OLIVOS'),
    (76,N'44598490',N'NINA','20220518',N'Única',N'Perro',N'Hembra',N'Blanco y canela',N'LOS OLIVOS'),
    (77,N'92117808',N'NIÑA','20181018',N'Única',N'Gato',N'Hembra',N'Blanco y crema',N'LOS OLIVOS'),
    (78,N'53258560',N'OREO','20220218',N'Boston Terrier',N'Perro',N'Macho',N'Negro y blanco',N'LOS OLIVOS'),
    (79,N'70081614',N'OSA','20160419',N'Única',N'Perro',N'Hembra',N'Negro y marrón',N'LOS OLIVOS'),
    (80,N'62179698',N'OSO','20160418',N'Única',N'Perro',N'Macho',N'Negro y canela',N'LOS OLIVOS'),
    (81,N'11101735',N'OTTO','20150419',N'Shitzu',N'Perro',N'Macho',N'Marrón y blanco',N'LOS OLIVOS'),
    (82,N'43966135',N'PACO','20230104',N'Única',N'Perro',N'Macho',N'Marrón y negro',N'LOS OLIVOS'),
    (83,N'50069966',N'PACO','20180420',N'Salchicha',N'Perro',N'Macho',N'Gris y blanco',N'LOS OLIVOS'),
    (84,N'37662171',N'PANCHITA','20190420',N'Única',N'Gato',N'Hembra',N'Gris y negro',N'LOS OLIVOS'),
    (85,N'32576233',N'PRINCESA','20190519',N'Única',N'Perro',N'Hembra',N'Crema y blanco',N'LOS OLIVOS'),
    (86,N'44167765',N'PRINCIPE','20221119',N'Única',N'Gato',N'Macho',N'Canela y blanco',N'LOS OLIVOS'),
    (87,N'14512500',N'ROCCO','20180522',N'Bigel',N'Perro',N'Macho',N'Chocolate y blanco',N'LOS OLIVOS'),
    (88,N'87135532',N'ROCCO','20230421',N'Schnauzer',N'Perro',N'Macho',N'Dorado y blanco',N'LOS OLIVOS'),
    (89,N'45141552',N'ROCKY','20080422',N'Schnauzer',N'Perro',N'Macho',N'Roano',N'LOS OLIVOS'),
    (90,N'43731506',N'RICK','20190420',N'Única',N'Perro',N'Macho',N'Roano azul',N'LOS OLIVOS'),
    (91,N'83106100',N'RITO','20150420',N'Única',N'Perro',N'Macho',N'Roano marrón',N'LOS OLIVOS'),
    (92,N'50606432',N'ROCKY','20191118',N'Única',N'Perro',N'Macho',N'Merle',N'LOS OLIVOS'),
    (93,N'85463093',N'SACKY','20230418',N'Pug',N'Perro',N'Hembra',N'Merle gris',N'LOS OLIVOS'),
    (94,N'35087613',N'SANTI','20140419',N'Shitzu',N'Perro',N'Macho',N'Merle marrón',N'LOS OLIVOS'),
    (95,N'77915097',N'SASHA','20211018',N'Única',N'Perro',N'Hembra',N'Arlequín',N'LOS OLIVOS'),
    (96,N'51430602',N'SHIMA','20160418',N'Pequines Alvino',N'Perro',N'Hembra',N'Sal y pimienta',N'LOS OLIVOS'),
    (97,N'27898879',N'SIMBA','20170422',N'Schnauzer',N'Perro',N'Hembra',N'Albino',N'LOS OLIVOS'),
    (98,N'37591160',N'SIRIUS','20210419',N'Única',N'Gato',N'Macho',N'Punto crema',N'LOS OLIVOS'),
    (99,N'33715647',N'TAYLER','20200419',N'Única',N'Gato',N'Macho',N'Punto chocolate',N'LOS OLIVOS'),
    (100,N'36338780',N'TEMY','20190421',N'Única',N'Gato',N'Hembra',N'Punto gris',N'LOS OLIVOS'),
    (101,N'53316884',N'MINNIE','20130401',N'Única',N'Gato',N'Hembra',N'Blanco',N'SAN JUAN DE LURIGANCHO'),
    (102,N'46075844',N'TRUENO','20190206',N'Shitzu',N'Perro',N'Hembra',N'Dorado',N'SAN BORJA'),
    (103,N'16537126',N'LOLA','20200521',N'Única',N'Perro',N'Hembra',N'Café',N'SAN BORJA'),
    (104,N'75874880',N'LASSIE','20140521',N'Shitzu',N'Perro',N'Hembra',N'Marrón',N'LA MOLINA'),
    (105,N'50665804',N'KIRA','20141024',N'Golden',N'Perro',N'Macho',N'Blanco y negro',N'SAN JUAN DE LURIGANCHO'),
    (106,N'73756858',N'SAMY','20181107',N'Cocker',N'Perro',N'Hembra',N'Bicolor',N'COMAS'),
    (107,N'46337525',N'ZEUS','20220807',N'Única',N'Perro',N'Hembra',N'Tricolor',N'SAN MARTIN DE PORRES'),
    (108,N'75598594',N'PRINCESA','20160531',N'Shitzu Toy',N'Perro',N'Hembra',N'Bicolor',N'SAN JUAN DE LURIGANCHO'),
    (109,N'71990332',N'MILO','20240503',N'Shitzu',N'Perro',N'Macho',N'Canela',N'MIRAFLORES'),
    (110,N'58213469',N'COCO','20200214',N'Bigel',N'Perro',N'Hembra',N'Marrón',N'SAN JUAN DE LURIGANCHO'),
    (111,N'77344573',N'NEGRO','20220812',N'American Bully',N'Perro',N'Macho',N'Negro y marrón',N'LA MOLINA'),
    (112,N'70536828',N'TITAN','20140113',N'Única',N'Perro',N'Macho',N'Plateado',N'SAN MARTIN DE PORRES'),
    (113,N'39138767',N'BOBBY','20130517',N'Única',N'Perro',N'Macho',N'Dorado',N'SAN MARTIN DE PORRES'),
    (114,N'47246945',N'COCO','20121027',N'Única',N'Perro',N'Macho',N'Blanco',N'SAN JUAN DE LURIGANCHO'),
    (115,N'57535139',N'THOR','20160222',N'Siberiano',N'Perro',N'Macho',N'Miel',N'LA MOLINA'),
    (116,N'51064536',N'OLIVER','20240708',N'Única',N'Gato',N'Macho',N'Gris claro',N'LA MOLINA'),
    (117,N'31366985',N'LUNA','20241023',N'Única',N'Perro',N'Hembra',N'Chocolate',N'SAN BORJA'),
    (118,N'38386240',N'OSO','20130629',N'Única',N'Perro',N'Hembra',N'Crema',N'LA MOLINA'),
    (119,N'23781600',N'ROCCO','20160204',N'Poodle con Bichón',N'Perro',N'Macho',N'Blanco y marrón',N'SAN MARTIN DE PORRES'),
    (120,N'75149339',N'PANCHO','20190223',N'Única',N'Perro',N'Macho',N'Dorado',N'SAN MARTIN DE PORRES'),
    (121,N'32374940',N'GORDO','20200316',N'Cocker',N'Perro',N'Hembra',N'Atigrado',N'ATE'),
    (122,N'35967986',N'MINNIE','20141022',N'Única',N'Gato',N'Macho',N'Bicolor',N'SAN BORJA'),
    (123,N'43015498',N'MOCHA','20190128',N'Única',N'Perro',N'Macho',N'Tricolor',N'SANTIAGO DE SURCO'),
    (124,N'38320094',N'BOBBY','20230816',N'Siberiano',N'Perro',N'Macho',N'Marrón',N'COMAS'),
    (125,N'39512989',N'COCO','20180308',N'Única',N'Perro',N'Macho',N'Gris',N'SANTIAGO DE SURCO'),
    (126,N'50251342',N'ZEUS','20190521',N'Shitzu',N'Perro',N'Hembra',N'Blanco',N'SAN JUAN DE LURIGANCHO'),
    (127,N'54344343',N'MANCHAS','20250812',N'Shitzu',N'Perro',N'Hembra',N'Manchado',N'SAN JUAN DE LURIGANCHO'),
    (128,N'60693432',N'NALA','20200411',N'Schnauzer',N'Perro',N'Hembra',N'Tricolor',N'SAN MARTIN DE PORRES'),
    (129,N'61283202',N'TYSON','20220805',N'Shitzu',N'Perro',N'Hembra',N'Manchado',N'MIRAFLORES'),
    (130,N'42339214',N'IRIS','20150717',N'Cocker',N'Perro',N'Hembra',N'Bicolor',N'JESUS MARIA'),
    (131,N'35860182',N'GORDO','20161228',N'Única',N'Perro',N'Macho',N'Café claro',N'JESUS MARIA'),
    (132,N'32056535',N'TOMASA','20141001',N'Única',N'Gato',N'Macho',N'Atigrado gris',N'COMAS'),
    (133,N'49176341',N'OLIVER','20200205',N'Única',N'Gato',N'Macho',N'Carey',N'SANTIAGO DE SURCO'),
    (134,N'44353078',N'OLIVER','20210123',N'Única',N'Gato',N'Macho',N'Punto crema',N'SANTIAGO DE SURCO'),
    (135,N'54073127',N'TOÑO','20171208',N'Bigel',N'Perro',N'Macho',N'Negro',N'SAN JUAN DE LURIGANCHO'),
    (136,N'11644275',N'NALA','20170918',N'Pequines Alvino',N'Perro',N'Hembra',N'Sable',N'SAN JUAN DE LURIGANCHO'),
    (137,N'70251498',N'CHISPA','20210123',N'Cocker Ingles',N'Perro',N'Hembra',N'Café claro',N'SAN JUAN DE LURIGANCHO'),
    (138,N'75331516',N'DAISY','20160417',N'Salchicha',N'Perro',N'Hembra',N'Blanco y marrón',N'SAN JUAN DE LURIGANCHO'),
    (139,N'18249549',N'NIEVE','20191002',N'Única',N'Gato',N'Hembra',N'Punto crema',N'MAGDALENA DEL MAR'),
    (140,N'44057414',N'COCO','20240118',N'Única',N'Perro',N'Macho',N'Negro',N'MIRAFLORES'),
    (141,N'27749817',N'PELUCHE','20160413',N'Única',N'Gato',N'Hembra',N'Bicolor',N'LA MOLINA'),
    (142,N'14179958',N'CHIQUI','20161105',N'Única',N'Gato',N'Macho',N'Negro y blanco',N'SAN MARTIN DE PORRES'),
    (143,N'35029611',N'ZEUS','20190708',N'Pequines Alvino',N'Perro',N'Macho',N'Merle',N'COMAS'),
    (144,N'43588550',N'BOBBY','20200308',N'Shitzu',N'Perro',N'Macho',N'Blanco',N'SANTIAGO DE SURCO'),
    (145,N'56162302',N'ANGEL','20171017',N'Única',N'Perro',N'Macho',N'Blanco y negro',N'ATE'),
    (146,N'37855761',N'MOCHA','20181208',N'Única',N'Perro',N'Macho',N'Chocolate',N'SAN BORJA'),
    (147,N'79028178',N'BETO','20210327',N'Única',N'Perro',N'Macho',N'Café claro',N'SAN BORJA'),
    (148,N'53561260',N'LUCKY','20121025',N'Schnauzer',N'Perro',N'Macho',N'Blanco',N'COMAS'),
    (149,N'26212581',N'MICHI','20140218',N'Única',N'Gato',N'Hembra',N'Tabby naranja',N'SAN JUAN DE LURIGANCHO'),
    (150,N'76885298',N'PELUSA','20120802',N'Única',N'Perro',N'Hembra',N'Blanco y marrón',N'MIRAFLORES'),
    (151,N'20966078',N'ANGEL','20190131',N'Salchicha',N'Perro',N'Macho',N'Caramelo',N'SAN MARTIN DE PORRES'),
    (152,N'25276068',N'PANTERA','20211108',N'Única',N'Gato',N'Hembra',N'Calicó',N'SAN MARTIN DE PORRES'),
    (153,N'44827796',N'BRUNO','20191209',N'Única',N'Perro',N'Hembra',N'Arena',N'SAN MARTIN DE PORRES'),
    (154,N'67321528',N'GOKU','20161231',N'Schnauzer',N'Perro',N'Macho',N'Blanco y negro',N'LA MOLINA'),
    (155,N'53105515',N'NEGRO','20200318',N'Única',N'Perro',N'Hembra',N'Atigrado',N'COMAS'),
    (156,N'48607157',N'GOKU','20190214',N'Única',N'Perro',N'Macho',N'Arena',N'COMAS'),
    (157,N'37495349',N'LUNA','20131228',N'Única',N'Perro',N'Hembra',N'Manchado',N'SAN JUAN DE LURIGANCHO'),
    (158,N'54400813',N'DAISY','20140116',N'Única',N'Perro',N'Macho',N'Dorado',N'SAN MARTIN DE PORRES'),
    (159,N'46221200',N'MOMO','20230405',N'Única',N'Gato',N'Hembra',N'Atigrado marrón',N'SAN BORJA'),
    (160,N'53060004',N'OSO','20250224',N'Única',N'Perro',N'Macho',N'Sable',N'LA MOLINA'),
    (161,N'29660614',N'TOBY','20200918',N'Única',N'Perro',N'Hembra',N'Negro',N'COMAS'),
    (162,N'37828753',N'CHIQUI','20230702',N'Única',N'Gato',N'Hembra',N'Gris',N'SANTIAGO DE SURCO'),
    (163,N'68285145',N'ANGEL','20110511',N'Única',N'Perro',N'Hembra',N'Beige',N'SAN MARTIN DE PORRES'),
    (164,N'14378485',N'TOBY','20171226',N'Única',N'Perro',N'Macho',N'Tricolor',N'LA MOLINA'),
    (165,N'35063063',N'GORDO','20190205',N'Pequines Alvino',N'Perro',N'Hembra',N'Manchado',N'LA MOLINA'),
    (166,N'54572038',N'SIMBA','20161011',N'Única',N'Gato',N'Hembra',N'Blanco y gris',N'COMAS'),
    (167,N'12693757',N'TITAN','20160224',N'Pequines Alvino',N'Perro',N'Hembra',N'Blanco y marrón',N'SANTIAGO DE SURCO'),
    (168,N'36292579',N'NEGRO','20200703',N'Pequines Alvino',N'Perro',N'Hembra',N'Blanco y negro',N'SAN JUAN DE LURIGANCHO'),
    (169,N'20855772',N'CHOCOLATE','20220924',N'Única',N'Perro',N'Macho',N'Tricolor',N'SAN MARTIN DE PORRES'),
    (170,N'36725962',N'TOBY','20120824',N'Cocker',N'Perro',N'Hembra',N'Arena',N'SAN BORJA'),
    (171,N'58637800',N'BRUNO','20170819',N'Pequines Alvino',N'Perro',N'Hembra',N'Negro y marrón',N'COMAS'),
    (172,N'65972462',N'OLIVER','20201125',N'Única',N'Gato',N'Macho',N'Blanco',N'COMAS'),
    (173,N'45932642',N'MOCHA','20210607',N'Salchicha',N'Perro',N'Hembra',N'Manchado',N'ATE'),
    (174,N'39734772',N'MILO','20200609',N'Shitzu',N'Perro',N'Hembra',N'Caramelo',N'JESUS MARIA'),
    (175,N'77521126',N'SAMY','20230625',N'Cocker Americano',N'Perro',N'Hembra',N'Blanco y marrón',N'ATE'),
    (176,N'66139552',N'BOBBY','20230301',N'Schnauzer',N'Perro',N'Hembra',N'Manchado',N'SAN JUAN DE LURIGANCHO'),
    (177,N'38601665',N'BRUNO','20211207',N'Schnauzer',N'Perro',N'Hembra',N'Café',N'SAN JUAN DE LURIGANCHO'),
    (178,N'16148560',N'FIRULAIS','20140705',N'Golden / Cocker',N'Perro',N'Macho',N'Manchado',N'JESUS MARIA'),
    (179,N'64701909',N'TYSON','20171227',N'Única',N'Perro',N'Macho',N'Gris',N'SAN MARTIN DE PORRES'),
    (180,N'66703032',N'GARFIELD','20120319',N'Única',N'Gato',N'Macho',N'Tabby naranja',N'LA MOLINA'),
    (181,N'58228917',N'TOBY','20230422',N'Cocker',N'Perro',N'Hembra',N'Beige',N'SAN JUAN DE LURIGANCHO'),
    (182,N'17516769',N'ROCKY','20151124',N'Schnauzer',N'Perro',N'Hembra',N'Arena',N'LA MOLINA'),
    (183,N'70962766',N'CANELA','20220819',N'Perro Peruano',N'Perro',N'Hembra',N'Café',N'ATE'),
    (184,N'24289836',N'BETO','20180409',N'Schnauzer',N'Perro',N'Hembra',N'Marrón',N'MIRAFLORES'),
    (185,N'32556969',N'ROCKY','20171103',N'Única',N'Perro',N'Hembra',N'Bicolor',N'SAN MARTIN DE PORRES'),
    (186,N'54744533',N'LUCKY','20170512',N'Única',N'Perro',N'Macho',N'Plateado',N'SAN JUAN DE LURIGANCHO'),
    (187,N'38443718',N'TOBY','20171030',N'Pequines Alvino',N'Perro',N'Hembra',N'Bicolor',N'COMAS'),
    (188,N'11432233',N'LOLA','20140710',N'Labrador',N'Perro',N'Macho',N'Marrón',N'SANTIAGO DE SURCO'),
    (189,N'66933972',N'GATUBELA','20141010',N'Única',N'Gato',N'Hembra',N'Atigrado naranja',N'ATE'),
    (190,N'41067506',N'JACK','20220528',N'Poodle con Bichón',N'Perro',N'Macho',N'Marrón',N'COMAS'),
    (191,N'17968489',N'CANELA','20220224',N'Sharpein',N'Perro',N'Macho',N'Negro',N'SANTIAGO DE SURCO'),
    (192,N'35567394',N'MOCHA','20200113',N'Cocker Americano',N'Perro',N'Hembra',N'Gris claro',N'SANTIAGO DE SURCO'),
    (193,N'10374680',N'NALA','20190327',N'Única',N'Perro',N'Hembra',N'Merle',N'COMAS'),
    (194,N'63703773',N'BETO','20210918',N'Schnauzer',N'Perro',N'Macho',N'Canela',N'SAN MARTIN DE PORRES'),
    (195,N'26925176',N'NALA','20180618',N'Única',N'Perro',N'Hembra',N'Café',N'SANTIAGO DE SURCO'),
    (196,N'50193307',N'FIONA','20190130',N'Pequines Alvino',N'Perro',N'Macho',N'Blanco',N'SAN JUAN DE LURIGANCHO'),
    (197,N'68488848',N'LUNA','20230920',N'Única',N'Perro',N'Hembra',N'Negro',N'ATE'),
    (198,N'17873272',N'IRIS','20140731',N'Única',N'Perro',N'Hembra',N'Café',N'SAN JUAN DE LURIGANCHO'),
    (199,N'44893952',N'NALA','20220712',N'Schnauzer',N'Perro',N'Macho',N'Caramelo',N'LA MOLINA'),
    (200,N'52964751',N'LUCKY','20171210',N'Única',N'Perro',N'Hembra',N'Gris claro',N'MIRAFLORES'),
    (201,N'61745970',N'OLIVER','20110620',N'Única',N'Gato',N'Hembra',N'Carey',N'SAN BORJA'),
    (202,N'21984827',N'ANGEL','20220329',N'Única',N'Perro',N'Macho',N'Negro y marrón',N'MAGDALENA DEL MAR'),
    (203,N'66057004',N'ROCCO','20170813',N'Terrier Tibetano',N'Perro',N'Macho',N'Bicolor',N'JESUS MARIA'),
    (204,N'74409158',N'NALA','20250614',N'Cocker Ingles',N'Perro',N'Hembra',N'Dorado',N'SAN JUAN DE LURIGANCHO'),
    (205,N'60487593',N'PELUCHE','20190225',N'Única',N'Gato',N'Macho',N'Tabby',N'SAN MARTIN DE PORRES'),
    (206,N'38663018',N'SAMY','20130206',N'Shitzu',N'Perro',N'Macho',N'Negro',N'ATE'),
    (207,N'74414951',N'TOBY','20121104',N'Única',N'Perro',N'Hembra',N'Gris claro',N'SAN BORJA'),
    (208,N'45907081',N'OLIVER','20140227',N'Única',N'Gato',N'Macho',N'Tricolor',N'ATE'),
    (209,N'18684426',N'ANGEL','20160129',N'Shitzu Toy',N'Perro',N'Hembra',N'Café oscuro',N'SAN JUAN DE LURIGANCHO'),
    (210,N'66499753',N'MILO','20170619',N'Única',N'Perro',N'Macho',N'Dorado',N'SANTIAGO DE SURCO'),
    (211,N'39050775',N'GATUBELA','20240807',N'Única',N'Gato',N'Hembra',N'Negro',N'MIRAFLORES'),
    (212,N'54305327',N'SIMBA','20181208',N'Schnauzer',N'Perro',N'Macho',N'Blanco y marrón',N'ATE'),
    (213,N'61428603',N'IRIS','20210530',N'Siberiano',N'Perro',N'Macho',N'Marrón',N'SANTIAGO DE SURCO'),
    (214,N'49691643',N'LOLA','20121009',N'Schnauzer',N'Perro',N'Macho',N'Atigrado',N'SAN JUAN DE LURIGANCHO'),
    (215,N'32697260',N'TITAN','20151211',N'Salchicha',N'Perro',N'Macho',N'Caramelo',N'SAN MARTIN DE PORRES'),
    (216,N'64949806',N'CHISPA','20140507',N'Única',N'Perro',N'Macho',N'Chocolate',N'SAN MARTIN DE PORRES'),
    (217,N'56914201',N'THOR','20160414',N'Única',N'Perro',N'Macho',N'Miel',N'COMAS'),
    (218,N'24696128',N'ZEUS','20171119',N'Boxer Alemán',N'Perro',N'Macho',N'Gris claro',N'SAN BORJA'),
    (219,N'16372812',N'BOLITA','20121111',N'Única',N'Gato',N'Hembra',N'Negro',N'COMAS'),
    (220,N'39328441',N'PRINCESA','20250924',N'Única',N'Perro',N'Hembra',N'Beige',N'COMAS'),
    (221,N'56061576',N'PRINCESA','20171107',N'Schnauzer',N'Perro',N'Hembra',N'Café claro',N'MIRAFLORES'),
    (222,N'55115571',N'MISHI','20130601',N'Única',N'Gato',N'Hembra',N'Tricolor',N'ATE'),
    (223,N'38702911',N'THOR','20231204',N'Salchicha',N'Perro',N'Hembra',N'Miel',N'MIRAFLORES'),
    (224,N'17338952',N'TRUENO','20220904',N'Única',N'Perro',N'Macho',N'Gris',N'SAN BORJA'),
    (225,N'16408342',N'MILO','20140324',N'Única',N'Perro',N'Hembra',N'Beige',N'MAGDALENA DEL MAR'),
    (226,N'57003069',N'KIRA','20131025',N'Shitzu',N'Perro',N'Hembra',N'Gris claro',N'ATE'),
    (227,N'73182519',N'TRUENO','20210911',N'Única',N'Perro',N'Macho',N'Chocolate',N'JESUS MARIA'),
    (228,N'38237762',N'NALA','20111001',N'Única',N'Gato',N'Hembra',N'Negro y blanco',N'MIRAFLORES'),
    (229,N'73227182',N'LASSIE','20211104',N'Única',N'Perro',N'Macho',N'Crema',N'MIRAFLORES'),
    (230,N'62671174',N'THOR','20240715',N'Única',N'Perro',N'Macho',N'Café claro',N'ATE'),
    (231,N'59803849',N'TIGRE','20240816',N'Única',N'Gato',N'Hembra',N'Atigrado marrón',N'SAN MARTIN DE PORRES'),
    (232,N'59996943',N'ROCCO','20221108',N'Única',N'Perro',N'Hembra',N'Marrón',N'ATE'),
    (233,N'77822400',N'NALA','20140109',N'Única',N'Gato',N'Macho',N'Gris',N'SAN MARTIN DE PORRES'),
    (234,N'39677506',N'BRUNO','20201101',N'Shitzu',N'Perro',N'Macho',N'Gris claro',N'SANTIAGO DE SURCO'),
    (235,N'76415788',N'GORDO','20240711',N'Única',N'Perro',N'Macho',N'Crema',N'LA MOLINA'),
    (236,N'29789893',N'LASSIE','20130707',N'Bigel',N'Perro',N'Hembra',N'Marrón y blanco',N'SAN BORJA'),
    (237,N'30289791',N'NIEVE','20210812',N'Única',N'Gato',N'Macho',N'Calicó',N'JESUS MARIA'),
    (238,N'79220323',N'KIRA','20170316',N'Única',N'Perro',N'Macho',N'Merle',N'SAN JUAN DE LURIGANCHO'),
    (239,N'47888884',N'BRUNO','20170612',N'Única',N'Perro',N'Macho',N'Dorado',N'SAN JUAN DE LURIGANCHO'),
    (240,N'28948673',N'ROCKY','20220112',N'Única',N'Perro',N'Macho',N'Marrón y blanco',N'SAN MARTIN DE PORRES'),
    (241,N'27867033',N'BRUNO','20141105',N'Bigel',N'Perro',N'Hembra',N'Blanco y negro',N'SAN BORJA'),
    (242,N'62719537',N'GOKU','20151201',N'Golden / Cocker',N'Perro',N'Macho',N'Manchado',N'ATE'),
    (243,N'22191593',N'DULCE','20210521',N'Schnauzer',N'Perro',N'Macho',N'Beige',N'SANTIAGO DE SURCO'),
    (244,N'37519394',N'TYSON','20191027',N'Shitzu',N'Perro',N'Hembra',N'Blanco y marrón',N'SAN JUAN DE LURIGANCHO'),
    (245,N'40377786',N'LUCKY','20190429',N'Shitzu',N'Perro',N'Hembra',N'Miel',N'COMAS'),
    (246,N'53716605',N'PRINCESA','20170824',N'Única',N'Perro',N'Macho',N'Café claro',N'ATE'),
    (247,N'36860383',N'LUNA','20200109',N'Única',N'Perro',N'Hembra',N'Negro y marrón',N'ATE'),
    (248,N'74637126',N'MOCHA','20111025',N'Shitzu',N'Perro',N'Hembra',N'Negro',N'SAN MARTIN DE PORRES'),
    (249,N'26753308',N'IRIS','20201213',N'Golden / Cocker',N'Perro',N'Macho',N'Marrón',N'COMAS'),
    (250,N'26419779',N'IRIS','20210120',N'Única',N'Perro',N'Hembra',N'Beige',N'SAN MARTIN DE PORRES'),
    (251,N'77942639',N'DULCE','20170611',N'Boston Terrier',N'Perro',N'Macho',N'Café oscuro',N'SAN BORJA'),
    (252,N'76604777',N'PRINCESA','20191012',N'Terrier Tibetano',N'Perro',N'Macho',N'Crema',N'COMAS'),
    (253,N'71417100',N'SIMBA','20231021',N'Única',N'Perro',N'Macho',N'Manchado',N'SANTIAGO DE SURCO'),
    (254,N'52622436',N'COCO','20190127',N'American Bully',N'Perro',N'Macho',N'Negro',N'ATE'),
    (255,N'52350164',N'FRODO','20170418',N'Única',N'Perro',N'Hembra',N'Crema',N'MAGDALENA DEL MAR'),
    (256,N'28353924',N'FIRULAIS','20191015',N'Golden / Cocker',N'Perro',N'Hembra',N'Chocolate',N'ATE'),
    (257,N'70094344',N'OSO','20160325',N'Única',N'Perro',N'Hembra',N'Negro',N'COMAS'),
    (258,N'10569492',N'TITAN','20120613',N'Única',N'Perro',N'Hembra',N'Marrón',N'MIRAFLORES'),
    (259,N'46385312',N'OSO','20151003',N'Única',N'Perro',N'Hembra',N'Crema',N'MIRAFLORES'),
    (260,N'42247313',N'JACK','20240104',N'Única',N'Perro',N'Macho',N'Caramelo',N'SAN MARTIN DE PORRES'),
    (261,N'76591779',N'TOM','20210113',N'Única',N'Gato',N'Hembra',N'Punto chocolate',N'SANTIAGO DE SURCO'),
    (262,N'76256491',N'GORDO','20200521',N'Única',N'Perro',N'Hembra',N'Café oscuro',N'SAN BORJA'),
    (263,N'59426425',N'DULCE','20170515',N'Única',N'Perro',N'Macho',N'Café claro',N'MAGDALENA DEL MAR'),
    (264,N'74612560',N'PRINCESA','20150718',N'Shitzu',N'Perro',N'Hembra',N'Marrón y blanco',N'COMAS'),
    (265,N'75671636',N'BETO','20180915',N'Shitzu',N'Perro',N'Hembra',N'Café claro',N'COMAS'),
    (266,N'75239262',N'ZEUS','20201208',N'Única',N'Perro',N'Hembra',N'Crema',N'ATE'),
    (267,N'59028881',N'MILO','20161010',N'Shitzu',N'Perro',N'Macho',N'Miel',N'SAN BORJA'),
    (268,N'63300462',N'THOR','20120727',N'Única',N'Perro',N'Hembra',N'Gris claro',N'COMAS'),
    (269,N'31699451',N'SAMY','20191218',N'Única',N'Perro',N'Macho',N'Sable',N'SAN BORJA'),
    (270,N'17226044',N'PANCHO','20201004',N'Sharpein',N'Perro',N'Hembra',N'Tricolor',N'ATE'),
    (271,N'36574152',N'ZEUS','20160604',N'Única',N'Perro',N'Macho',N'Arena',N'SAN BORJA'),
    (272,N'75647094',N'NALA','20180214',N'Única',N'Perro',N'Hembra',N'Negro y blanco',N'SAN MARTIN DE PORRES'),
    (273,N'35656927',N'ANGEL','20140408',N'Única',N'Perro',N'Macho',N'Marrón',N'SAN MARTIN DE PORRES'),
    (274,N'70137831',N'IRIS','20181114',N'Única',N'Perro',N'Macho',N'Crema',N'SANTIAGO DE SURCO'),
    (275,N'59831833',N'CHOCOLATE','20211009',N'Única',N'Perro',N'Hembra',N'Café',N'SAN MARTIN DE PORRES'),
    (276,N'51117751',N'LOLA','20180610',N'Schnauzer',N'Perro',N'Hembra',N'Bicolor',N'ATE'),
    (277,N'70903475',N'DAISY','20190825',N'Cocker Americano',N'Perro',N'Macho',N'Blanco',N'SANTIAGO DE SURCO'),
    (278,N'55566012',N'ANGEL','20151213',N'Única',N'Perro',N'Hembra',N'Sable',N'JESUS MARIA'),
    (279,N'29673082',N'LOLA','20190225',N'Perro Peruano',N'Perro',N'Hembra',N'Canela',N'COMAS'),
    (280,N'53691734',N'FRODO','20141018',N'Golden',N'Perro',N'Macho',N'Bicolor',N'LA MOLINA'),
    (281,N'77035821',N'LASSIE','20191212',N'American Bully',N'Perro',N'Hembra',N'Canela',N'LA MOLINA'),
    (282,N'70630649',N'LUCKY','20220602',N'Labrador',N'Perro',N'Hembra',N'Café oscuro',N'SANTIAGO DE SURCO'),
    (283,N'54688209',N'LOLA','20210831',N'Golden / Cocker',N'Perro',N'Hembra',N'Canela',N'SAN MARTIN DE PORRES'),
    (284,N'18930994',N'IRIS','20121020',N'Única',N'Perro',N'Macho',N'Marrón',N'SAN BORJA'),
    (285,N'25965976',N'PELUCHE','20150327',N'Única',N'Gato',N'Macho',N'Punto chocolate',N'SAN JUAN DE LURIGANCHO'),
    (286,N'61766196',N'SALEM','20240521',N'Única',N'Gato',N'Hembra',N'Crema',N'LA MOLINA'),
    (287,N'13086150',N'OLIVER','20111115',N'Única',N'Gato',N'Macho',N'Atigrado gris',N'SANTIAGO DE SURCO'),
    (288,N'51949964',N'DAISY','20180630',N'Única',N'Perro',N'Macho',N'Negro',N'LA MOLINA'),
    (289,N'23645765',N'SALEM','20190607',N'Única',N'Gato',N'Hembra',N'Negro y blanco',N'SAN BORJA'),
    (290,N'25375175',N'ZEUS','20180326',N'Poodle con Bichón',N'Perro',N'Hembra',N'Bicolor',N'ATE'),
    (291,N'27071065',N'MAYA','20170531',N'Shitzu',N'Perro',N'Hembra',N'Dorado',N'ATE'),
    (292,N'21644472',N'TOBY','20120321',N'Única',N'Perro',N'Hembra',N'Negro y marrón',N'JESUS MARIA'),
    (293,N'40181119',N'SIMBA','20151122',N'Schnauzer',N'Perro',N'Hembra',N'Negro y blanco',N'SAN MARTIN DE PORRES'),
    (294,N'74474444',N'CLEO','20120609',N'Única',N'Gato',N'Hembra',N'Atigrado naranja',N'MAGDALENA DEL MAR'),
    (295,N'62343309',N'KOBE','20180717',N'Cocker',N'Perro',N'Hembra',N'Beige',N'SAN BORJA'),
    (296,N'17778326',N'MANCHAS','20160518',N'Pequines Alvino',N'Perro',N'Macho',N'Marrón',N'COMAS'),
    (297,N'42931532',N'BETO','20211109',N'Shitzu',N'Perro',N'Hembra',N'Tricolor',N'LA MOLINA'),
    (298,N'25706155',N'DULCE','20171128',N'Sharpein',N'Perro',N'Macho',N'Marrón',N'MAGDALENA DEL MAR'),
    (299,N'51377678',N'FIRULAIS','20190930',N'Salchicha',N'Perro',N'Macho',N'Bicolor',N'LA MOLINA'),
    (300,N'15743784',N'JACK','20170807',N'Schnauzer',N'Perro',N'Macho',N'Marrón',N'ATE'),
    (301,N'15017483',N'OLIVER','20230110',N'Única',N'Gato',N'Hembra',N'Tabby naranja',N'SAN BORJA'),
    (302,N'11840307',N'LASSIE','20141001',N'Única',N'Perro',N'Macho',N'Manchado',N'COMAS'),
    (303,N'32455567',N'SALEM','20140430',N'Única',N'Gato',N'Hembra',N'Blanco',N'JESUS MARIA'),
    (304,N'49855592',N'MAYA','20120918',N'Sharpein',N'Perro',N'Hembra',N'Sable',N'SAN MARTIN DE PORRES'),
    (305,N'20118060',N'NALA','20180728',N'Única',N'Perro',N'Hembra',N'Café oscuro',N'SANTIAGO DE SURCO'),
    (306,N'33784571',N'RUFO','20110727',N'Labrador',N'Perro',N'Hembra',N'Atigrado',N'MAGDALENA DEL MAR'),
    (307,N'32807658',N'NEGRO','20150701',N'Única',N'Perro',N'Hembra',N'Arena',N'SAN MARTIN DE PORRES'),
    (308,N'11616589',N'IRIS','20171016',N'Única',N'Perro',N'Macho',N'Tricolor',N'COMAS'),
    (309,N'49009324',N'MOMO','20140825',N'Única',N'Gato',N'Hembra',N'Negro',N'COMAS'),
    (310,N'42557428',N'GORDO','20221129',N'Terrier Tibetano',N'Perro',N'Macho',N'Manchado',N'SAN JUAN DE LURIGANCHO'),
    (311,N'37577441',N'CANELA','20231125',N'Única',N'Perro',N'Macho',N'Gris',N'SAN MARTIN DE PORRES'),
    (312,N'29570628',N'MAX','20130612',N'Cocker Americano',N'Perro',N'Macho',N'Gris claro',N'SAN JUAN DE LURIGANCHO'),
    (313,N'43910362',N'PANTERA','20170119',N'Única',N'Gato',N'Hembra',N'Tricolor',N'COMAS'),
    (314,N'69453138',N'OSO','20240902',N'Única',N'Perro',N'Macho',N'Manchado',N'MAGDALENA DEL MAR'),
    (315,N'56377779',N'LOLA','20131021',N'Única',N'Perro',N'Macho',N'Chocolate',N'ATE'),
    (316,N'26823875',N'DAISY','20151129',N'Schnauzer',N'Perro',N'Hembra',N'Arena',N'ATE'),
    (317,N'52890766',N'BOLITA','20110301',N'Única',N'Gato',N'Hembra',N'Gris',N'SAN JUAN DE LURIGANCHO'),
    (318,N'67650328',N'PELUCHE','20140717',N'Única',N'Gato',N'Macho',N'Blanco y gris',N'SAN BORJA'),
    (319,N'74264265',N'ROCKY','20151113',N'Única',N'Perro',N'Hembra',N'Bicolor',N'ATE'),
    (320,N'71620003',N'GARFIELD','20200504',N'Única',N'Gato',N'Hembra',N'Carey',N'COMAS'),
    (321,N'48236792',N'MIA','20190809',N'Única',N'Gato',N'Macho',N'Carey',N'COMAS'),
    (322,N'16513835',N'NUBE','20181227',N'Única',N'Gato',N'Macho',N'Naranja',N'COMAS'),
    (323,N'34736313',N'PELUCHE','20140610',N'Única',N'Gato',N'Macho',N'Punto chocolate',N'SAN JUAN DE LURIGANCHO'),
    (324,N'64751698',N'CHOCOLATE','20140427',N'Única',N'Perro',N'Macho',N'Blanco',N'MAGDALENA DEL MAR'),
    (325,N'63877899',N'MISHI','20220323',N'Única',N'Gato',N'Macho',N'Atigrado marrón',N'SAN MARTIN DE PORRES'),
    (326,N'64104769',N'DAISY','20180917',N'Única',N'Perro',N'Macho',N'Canela',N'SAN JUAN DE LURIGANCHO'),
    (327,N'12271098',N'BOLITA','20240505',N'Única',N'Gato',N'Hembra',N'Crema',N'MIRAFLORES'),
    (328,N'19985300',N'TYSON','20230219',N'Salchicha',N'Perro',N'Hembra',N'Gris',N'LA MOLINA'),
    (329,N'50100916',N'NEGRO','20190404',N'Schnauzer',N'Perro',N'Hembra',N'Marrón',N'SAN JUAN DE LURIGANCHO'),
    (330,N'10713936',N'NUBE','20160408',N'Única',N'Gato',N'Macho',N'Punto chocolate',N'LA MOLINA'),
    (331,N'71323251',N'TRUENO','20130609',N'Única',N'Perro',N'Macho',N'Dorado',N'ATE'),
    (332,N'67429105',N'KIRA','20210226',N'Única',N'Perro',N'Hembra',N'Miel',N'JESUS MARIA'),
    (333,N'20526105',N'FIRULAIS','20201207',N'Única',N'Perro',N'Hembra',N'Beige',N'SAN BORJA'),
    (334,N'74137343',N'TOM','20191121',N'Única',N'Gato',N'Hembra',N'Tricolor',N'SAN JUAN DE LURIGANCHO'),
    (335,N'31150771',N'CANELA','20140510',N'Única',N'Perro',N'Macho',N'Caramelo',N'ATE'),
    (336,N'69110737',N'MICHI','20220703',N'Única',N'Gato',N'Macho',N'Blanco y negro',N'SAN BORJA'),
    (337,N'63051978',N'FRODO','20131024',N'Shitzu',N'Perro',N'Hembra',N'Canela',N'SAN JUAN DE LURIGANCHO'),
    (338,N'52488169',N'ZEUS','20190328',N'Schnauzer',N'Perro',N'Macho',N'Sable',N'MAGDALENA DEL MAR'),
    (339,N'53922301',N'LUNA','20130911',N'Única',N'Gato',N'Macho',N'Carey',N'ATE'),
    (340,N'53078110',N'PEPE','20141119',N'Pequines Alvino',N'Perro',N'Macho',N'Atigrado',N'JESUS MARIA'),
    (341,N'41349952',N'PEPE','20140929',N'Salchicha',N'Perro',N'Macho',N'Negro y marrón',N'SAN MARTIN DE PORRES'),
    (342,N'10640688',N'CHOCOLATE','20220725',N'Shitzu',N'Perro',N'Hembra',N'Atigrado',N'LA MOLINA'),
    (343,N'48317019',N'PRINCESA','20220201',N'Schnauzer',N'Perro',N'Macho',N'Merle',N'SAN JUAN DE LURIGANCHO'),
    (344,N'64169098',N'NALA','20150812',N'Única',N'Gato',N'Macho',N'Bicolor',N'SANTIAGO DE SURCO'),
    (345,N'55719212',N'PANCHO','20191115',N'American Bully',N'Perro',N'Hembra',N'Negro y blanco',N'SAN JUAN DE LURIGANCHO'),
    (346,N'70414162',N'CANELA','20230704',N'Única',N'Perro',N'Hembra',N'Negro',N'ATE'),
    (347,N'54109713',N'NEGRO','20180109',N'Siberiano',N'Perro',N'Macho',N'Negro',N'SAN MARTIN DE PORRES'),
    (348,N'52525332',N'BOBBY','20141130',N'Única',N'Perro',N'Macho',N'Crema',N'SAN BORJA'),
    (349,N'51725842',N'THOR','20190919',N'Golden / Cocker',N'Perro',N'Macho',N'Marrón y blanco',N'JESUS MARIA'),
    (350,N'15431999',N'MOMO','20201018',N'Única',N'Gato',N'Hembra',N'Bicolor',N'JESUS MARIA'),
    (351,N'56906428',N'ROCCO','20201109',N'Única',N'Perro',N'Hembra',N'Chocolate',N'COMAS'),
    (352,N'37110833',N'KOBE','20180815',N'Única',N'Perro',N'Hembra',N'Chocolate',N'SANTIAGO DE SURCO'),
    (353,N'55742771',N'NALA','20210824',N'Bichon',N'Perro',N'Hembra',N'Canela',N'SANTIAGO DE SURCO'),
    (354,N'11052950',N'TOBY','20140223',N'Shitzu',N'Perro',N'Hembra',N'Chocolate',N'ATE'),
    (355,N'73855347',N'TRUENO','20230613',N'Bichon',N'Perro',N'Hembra',N'Negro y marrón',N'SAN JUAN DE LURIGANCHO'),
    (356,N'42126567',N'PRINCESA','20201228',N'Pequines Alvino',N'Perro',N'Hembra',N'Canela',N'SAN MARTIN DE PORRES'),
    (357,N'19995218',N'PELUSA','20190304',N'Shitzu',N'Perro',N'Hembra',N'Café claro',N'SAN JUAN DE LURIGANCHO'),
    (358,N'59006174',N'ANGEL','20191008',N'Única',N'Perro',N'Hembra',N'Chocolate',N'LA MOLINA'),
    (359,N'35548111',N'NALA','20180423',N'Schnauzer',N'Perro',N'Hembra',N'Merle',N'SAN JUAN DE LURIGANCHO'),
    (360,N'67299054',N'KIRA','20170506',N'Única',N'Perro',N'Hembra',N'Tricolor',N'MIRAFLORES'),
    (361,N'25377814',N'OSO','20180812',N'Siberiano',N'Perro',N'Macho',N'Blanco y marrón',N'SAN JUAN DE LURIGANCHO'),
    (362,N'60470506',N'TOÑO','20230323',N'Shitzu',N'Perro',N'Macho',N'Crema',N'MAGDALENA DEL MAR'),
    (363,N'30736673',N'ZEUS','20180408',N'Única',N'Perro',N'Hembra',N'Café oscuro',N'JESUS MARIA'),
    (364,N'18745124',N'OSO','20210330',N'Única',N'Perro',N'Macho',N'Gris claro',N'LA MOLINA'),
    (365,N'29971964',N'SAMY','20150302',N'Pug',N'Perro',N'Hembra',N'Blanco',N'ATE'),
    (366,N'59569048',N'ANGEL','20171120',N'Única',N'Perro',N'Macho',N'Manchado',N'SAN MARTIN DE PORRES'),
    (367,N'33968729',N'CANELA','20190525',N'Perro Peruano',N'Perro',N'Macho',N'Negro y marrón',N'LA MOLINA'),
    (368,N'58051201',N'MAX','20170606',N'Única',N'Perro',N'Hembra',N'Sable',N'LA MOLINA'),
    (369,N'22556713',N'THOR','20240820',N'Shitzu',N'Perro',N'Hembra',N'Café claro',N'SAN JUAN DE LURIGANCHO'),
    (370,N'10013105',N'GARFIELD','20171012',N'Única',N'Gato',N'Hembra',N'Carey',N'SAN MARTIN DE PORRES'),
    (371,N'28492007',N'RUFO','20240712',N'Poodle con Bichón',N'Perro',N'Hembra',N'Blanco',N'ATE'),
    (372,N'64337456',N'PELUSA','20210508',N'Shitzu',N'Perro',N'Macho',N'Gris claro',N'COMAS'),
    (373,N'60029895',N'KOBE','20201221',N'Única',N'Perro',N'Macho',N'Arena',N'JESUS MARIA'),
    (374,N'35678389',N'MANCHAS','20180306',N'Única',N'Perro',N'Macho',N'Atigrado',N'SANTIAGO DE SURCO'),
    (375,N'50302233',N'TOBY','20180518',N'Única',N'Perro',N'Hembra',N'Chocolate',N'COMAS'),
    (376,N'55925799',N'PANCHO','20140516',N'Única',N'Perro',N'Hembra',N'Manchado',N'MIRAFLORES'),
    (377,N'75686213',N'TOM','20190714',N'Única',N'Gato',N'Macho',N'Punto crema',N'JESUS MARIA'),
    (378,N'18398391',N'KOBE','20190613',N'Única',N'Perro',N'Hembra',N'Chocolate',N'COMAS'),
    (379,N'17909041',N'FIRULAIS','20160601',N'Única',N'Perro',N'Hembra',N'Bicolor',N'SAN MARTIN DE PORRES'),
    (380,N'42436203',N'ROCKY','20181224',N'Única',N'Perro',N'Macho',N'Chocolate',N'COMAS'),
    (381,N'53476237',N'PELUSA','20131010',N'Única',N'Perro',N'Hembra',N'Merle',N'MIRAFLORES'),
    (382,N'47821988',N'PANCHO','20140511',N'Única',N'Perro',N'Hembra',N'Canela',N'SAN MARTIN DE PORRES'),
    (383,N'79413472',N'JACK','20191215',N'Única',N'Perro',N'Hembra',N'Canela',N'SAN BORJA'),
    (384,N'46689266',N'COCO','20200825',N'Poodle con Bichón',N'Perro',N'Macho',N'Negro y blanco',N'SAN MARTIN DE PORRES'),
    (385,N'19251762',N'COCO','20181004',N'Única',N'Perro',N'Macho',N'Chocolate',N'SAN JUAN DE LURIGANCHO'),
    (386,N'63346839',N'ROCCO','20190209',N'Schnauzer',N'Perro',N'Macho',N'Blanco',N'SAN MARTIN DE PORRES'),
    (387,N'14396892',N'JACK','20210929',N'Shitzu',N'Perro',N'Macho',N'Café',N'LA MOLINA'),
    (388,N'31252930',N'GATUBELA','20211124',N'Única',N'Gato',N'Hembra',N'Tricolor',N'SAN MARTIN DE PORRES'),
    (389,N'59717244',N'OSO','20160512',N'Pequines Alvino',N'Perro',N'Macho',N'Canela',N'SAN JUAN DE LURIGANCHO'),
    (390,N'17586899',N'CHISPA','20130816',N'Única',N'Perro',N'Macho',N'Sable',N'SAN BORJA'),
    (391,N'63711330',N'SIMBA','20140901',N'Única',N'Perro',N'Macho',N'Gris claro',N'SAN JUAN DE LURIGANCHO'),
    (392,N'33460112',N'LUCKY','20230930',N'Schnauzer',N'Perro',N'Macho',N'Atigrado',N'ATE'),
    (393,N'24858882',N'GOKU','20161023',N'Única',N'Perro',N'Macho',N'Blanco y marrón',N'COMAS'),
    (394,N'21528464',N'NIEVE','20150529',N'Única',N'Gato',N'Hembra',N'Punto chocolate',N'SAN MARTIN DE PORRES'),
    (395,N'72306053',N'SIMBA','20220812',N'Shitzu',N'Perro',N'Macho',N'Blanco',N'ATE'),
    (396,N'29368390',N'FRODO','20120909',N'Bichon',N'Perro',N'Macho',N'Blanco y negro',N'COMAS'),
    (397,N'66492993',N'CANELA','20150111',N'Única',N'Perro',N'Hembra',N'Gris',N'MAGDALENA DEL MAR'),
    (398,N'35790401',N'KOBE','20170921',N'American Bully',N'Perro',N'Hembra',N'Dorado',N'COMAS'),
    (399,N'21613431',N'ZEUS','20220215',N'Schnauzer',N'Perro',N'Macho',N'Arena',N'COMAS'),
    (400,N'23524913',N'JACK','20180703',N'Sharpein',N'Perro',N'Hembra',N'Arena',N'SANTIAGO DE SURCO'),
    (401,N'40672459',N'IRIS','20150814',N'Única',N'Perro',N'Hembra',N'Merle',N'COMAS'),
    (402,N'53971722',N'PEPE','20171117',N'Buldog Frances',N'Perro',N'Hembra',N'Merle',N'MAGDALENA DEL MAR'),
    (403,N'34031162',N'KOBE','20130228',N'Poodle con Bichón',N'Perro',N'Macho',N'Chocolate',N'SANTIAGO DE SURCO'),
    (404,N'30287293',N'SIMBA','20190806',N'Única',N'Gato',N'Hembra',N'Blanco y negro',N'MAGDALENA DEL MAR'),
    (405,N'78149928',N'DAISY','20120321',N'Única',N'Perro',N'Macho',N'Plateado',N'JESUS MARIA'),
    (406,N'24971231',N'GORDO','20171123',N'Única',N'Perro',N'Macho',N'Tricolor',N'SANTIAGO DE SURCO'),
    (407,N'53512462',N'TOMASA','20190206',N'Única',N'Gato',N'Hembra',N'Naranja',N'LA MOLINA'),
    (408,N'43230996',N'PELUSA','20180610',N'Schnauzer',N'Perro',N'Macho',N'Blanco y marrón',N'JESUS MARIA'),
    (409,N'58800955',N'CANELA','20230715',N'Schnauzer',N'Perro',N'Macho',N'Merle',N'SAN BORJA'),
    (410,N'63079326',N'FIRULAIS','20110331',N'Única',N'Perro',N'Hembra',N'Blanco y negro',N'SAN BORJA'),
    (411,N'38741904',N'NUBE','20121225',N'Única',N'Gato',N'Hembra',N'Calicó',N'COMAS'),
    (412,N'32876946',N'LASSIE','20120510',N'Sharpein',N'Perro',N'Hembra',N'Crema',N'SAN MARTIN DE PORRES'),
    (413,N'19556608',N'KOBE','20211209',N'Única',N'Perro',N'Hembra',N'Gris',N'COMAS'),
    (414,N'71603205',N'FIONA','20140317',N'Única',N'Perro',N'Macho',N'Chocolate',N'SAN BORJA'),
    (415,N'19668758',N'TITAN','20170531',N'Pug',N'Perro',N'Macho',N'Atigrado',N'ATE'),
    (416,N'21429600',N'FRODO','20240423',N'Schnauzer',N'Perro',N'Hembra',N'Blanco',N'COMAS'),
    (417,N'51674644',N'RUFO','20200930',N'Shitzu',N'Perro',N'Hembra',N'Plateado',N'LA MOLINA'),
    (418,N'25449326',N'SAMY','20151102',N'Única',N'Perro',N'Hembra',N'Arena',N'SAN MARTIN DE PORRES'),
    (419,N'53168610',N'IRIS','20211203',N'Única',N'Perro',N'Hembra',N'Gris claro',N'JESUS MARIA'),
    (420,N'53879689',N'THOR','20190111',N'Única',N'Perro',N'Macho',N'Café claro',N'JESUS MARIA'),
    (421,N'74112721',N'MINA','20190109',N'Única',N'Gato',N'Macho',N'Naranja',N'SANTIAGO DE SURCO'),
    (422,N'72010722',N'FRODO','20200917',N'Única',N'Perro',N'Hembra',N'Merle',N'SAN MARTIN DE PORRES'),
    (423,N'74835983',N'MANCHAS','20140125',N'Pequines Alvino',N'Perro',N'Hembra',N'Marrón',N'MAGDALENA DEL MAR'),
    (424,N'59301459',N'PELUSA','20190822',N'Pug',N'Perro',N'Hembra',N'Marrón',N'MAGDALENA DEL MAR'),
    (425,N'37735621',N'TRUENO','20230715',N'Única',N'Perro',N'Hembra',N'Chocolate',N'MAGDALENA DEL MAR'),
    (426,N'46559169',N'TOÑO','20220910',N'Labrador',N'Perro',N'Macho',N'Café',N'SANTIAGO DE SURCO'),
    (427,N'52228506',N'SIMBA','20190909',N'Boston Terrier',N'Perro',N'Macho',N'Negro y marrón',N'SAN JUAN DE LURIGANCHO'),
    (428,N'50192178',N'BETO','20120610',N'Shitzu',N'Perro',N'Macho',N'Sable',N'COMAS'),
    (429,N'22231444',N'CHOCOLATE','20160717',N'Única',N'Perro',N'Macho',N'Caramelo',N'LA MOLINA'),
    (430,N'44693578',N'TRUENO','20141222',N'Única',N'Perro',N'Macho',N'Café',N'JESUS MARIA'),
    (431,N'46526469',N'TOBY','20170418',N'Única',N'Perro',N'Macho',N'Miel',N'ATE'),
    (432,N'51273753',N'ROCCO','20140314',N'Única',N'Perro',N'Hembra',N'Café oscuro',N'SAN JUAN DE LURIGANCHO'),
    (433,N'46544333',N'BOLITA','20190909',N'Única',N'Gato',N'Macho',N'Carey',N'SAN MARTIN DE PORRES'),
    (434,N'24269926',N'FIONA','20240216',N'Boxer Alemán',N'Perro',N'Hembra',N'Café claro',N'SANTIAGO DE SURCO'),
    (435,N'56826742',N'FRODO','20241126',N'Siberiano',N'Perro',N'Macho',N'Negro',N'SAN MARTIN DE PORRES'),
    (436,N'31837408',N'ROCKY','20201117',N'Shitzu',N'Perro',N'Hembra',N'Blanco',N'SANTIAGO DE SURCO'),
    (437,N'10144493',N'MANCHAS','20210225',N'Terrier Tibetano',N'Perro',N'Hembra',N'Café oscuro',N'ATE'),
    (438,N'69046078',N'RUFO','20220820',N'Shitzu',N'Perro',N'Macho',N'Sable',N'SANTIAGO DE SURCO'),
    (439,N'73661760',N'HACHI','20180329',N'Única',N'Perro',N'Hembra',N'Canela',N'MIRAFLORES'),
    (440,N'75589105',N'TYSON','20240404',N'Boxer Alemán',N'Perro',N'Macho',N'Merle',N'LA MOLINA'),
    (441,N'59538076',N'OSO','20120908',N'Shitzu',N'Perro',N'Hembra',N'Plateado',N'MAGDALENA DEL MAR'),
    (442,N'62809781',N'BOLITA','20221123',N'Única',N'Gato',N'Macho',N'Bicolor',N'SANTIAGO DE SURCO'),
    (443,N'61857513',N'THOR','20160101',N'Única',N'Perro',N'Hembra',N'Negro',N'SANTIAGO DE SURCO'),
    (444,N'59766259',N'JACK','20231109',N'Única',N'Perro',N'Hembra',N'Negro y marrón',N'SAN MARTIN DE PORRES'),
    (445,N'64151263',N'KOBE','20230106',N'Schnauzer',N'Perro',N'Hembra',N'Blanco y marrón',N'SANTIAGO DE SURCO'),
    (446,N'34182770',N'ROCKY','20120921',N'Única',N'Perro',N'Hembra',N'Crema',N'MAGDALENA DEL MAR'),
    (447,N'50579707',N'NALA','20151130',N'Siberiano',N'Perro',N'Hembra',N'Gris claro',N'MIRAFLORES'),
    (448,N'34575486',N'NEGRO','20180402',N'Sharpein',N'Perro',N'Hembra',N'Dorado',N'ATE'),
    (449,N'58339728',N'CANELA','20151109',N'Schnauzer',N'Perro',N'Macho',N'Gris',N'SAN JUAN DE LURIGANCHO'),
    (450,N'43322872',N'MAX','20170705',N'Shitzu',N'Perro',N'Hembra',N'Tricolor',N'SAN MARTIN DE PORRES'),
    (451,N'32853815',N'KIRA','20160910',N'Buldog Frances',N'Perro',N'Macho',N'Café claro',N'SAN JUAN DE LURIGANCHO'),
    (452,N'56203698',N'ANGEL','20201112',N'Cocker Americano',N'Perro',N'Hembra',N'Negro y marrón',N'COMAS'),
    (453,N'30604007',N'JACK','20191117',N'Golden',N'Perro',N'Macho',N'Blanco y negro',N'MAGDALENA DEL MAR'),
    (454,N'78008395',N'MOMO','20240401',N'Única',N'Gato',N'Hembra',N'Gris',N'SAN BORJA'),
    (455,N'15580650',N'LOLA','20130106',N'Shitzu',N'Perro',N'Macho',N'Gris claro',N'SAN JUAN DE LURIGANCHO'),
    (456,N'64671867',N'LUNA','20160510',N'Única',N'Perro',N'Macho',N'Negro y blanco',N'SANTIAGO DE SURCO'),
    (457,N'43626582',N'CANELA','20141017',N'Única',N'Perro',N'Hembra',N'Marrón y blanco',N'SANTIAGO DE SURCO'),
    (458,N'52099908',N'LUCKY','20170210',N'Schnauzer',N'Perro',N'Hembra',N'Atigrado',N'COMAS'),
    (459,N'51517847',N'FIONA','20160223',N'Única',N'Perro',N'Macho',N'Tricolor',N'LA MOLINA'),
    (460,N'45264687',N'MOMO','20210610',N'Única',N'Gato',N'Macho',N'Atigrado gris',N'SAN BORJA'),
    (461,N'25183208',N'LUNA','20241108',N'Única',N'Gato',N'Macho',N'Atigrado marrón',N'ATE'),
    (462,N'59719658',N'ZEUS','20240911',N'Shitzu',N'Perro',N'Hembra',N'Manchado',N'ATE'),
    (463,N'38518046',N'LASSIE','20230131',N'Única',N'Perro',N'Hembra',N'Sable',N'SAN BORJA'),
    (464,N'20902456',N'IRIS','20130118',N'Única',N'Perro',N'Macho',N'Beige',N'ATE'),
    (465,N'19961100',N'LASSIE','20220918',N'Única',N'Perro',N'Hembra',N'Negro',N'SAN JUAN DE LURIGANCHO'),
    (466,N'26734012',N'COCO','20250509',N'Schnauzer',N'Perro',N'Macho',N'Negro y blanco',N'SAN BORJA'),
    (467,N'49265947',N'LASSIE','20150129',N'Única',N'Perro',N'Macho',N'Marrón',N'MIRAFLORES'),
    (468,N'13500013',N'FELIX','20211004',N'Única',N'Gato',N'Macho',N'Crema',N'JESUS MARIA'),
    (469,N'67532430',N'RUFO','20190419',N'Única',N'Perro',N'Hembra',N'Marrón y blanco',N'COMAS'),
    (470,N'75720759',N'RUFO','20181020',N'Única',N'Perro',N'Macho',N'Gris claro',N'SAN JUAN DE LURIGANCHO'),
    (471,N'26666465',N'ROCKY','20161216',N'American Bully',N'Perro',N'Hembra',N'Bicolor',N'JESUS MARIA'),
    (472,N'15637712',N'ROCKY','20200716',N'Única',N'Perro',N'Hembra',N'Blanco y negro',N'LA MOLINA'),
    (473,N'72899329',N'GOKU','20201023',N'Única',N'Perro',N'Macho',N'Blanco y marrón',N'ATE'),
    (474,N'22206641',N'SIMBA','20120625',N'Única',N'Perro',N'Hembra',N'Bicolor',N'SAN JUAN DE LURIGANCHO'),
    (475,N'11671445',N'CHISPA','20250504',N'Sharpein',N'Perro',N'Macho',N'Negro',N'LA MOLINA'),
    (476,N'43608951',N'ZEUS','20240813',N'Única',N'Perro',N'Hembra',N'Chocolate',N'SANTIAGO DE SURCO'),
    (477,N'46984541',N'BOLITA','20200413',N'Única',N'Gato',N'Macho',N'Atigrado naranja',N'SAN MARTIN DE PORRES'),
    (478,N'61296075',N'DAISY','20111103',N'Siberiano',N'Perro',N'Hembra',N'Blanco',N'SANTIAGO DE SURCO'),
    (479,N'13559973',N'FIONA','20200104',N'Cocker Ingles',N'Perro',N'Macho',N'Caramelo',N'COMAS'),
    (480,N'54618219',N'PRINCESA','20150509',N'Boxer Alemán',N'Perro',N'Hembra',N'Chocolate',N'ATE'),
    (481,N'38807064',N'PELUCHE','20180328',N'Única',N'Gato',N'Macho',N'Punto crema',N'MIRAFLORES'),
    (482,N'32743777',N'ROCCO','20240526',N'Schnauzer',N'Perro',N'Macho',N'Tricolor',N'SAN MARTIN DE PORRES'),
    (483,N'13537040',N'NALA','20170910',N'Cocker Ingles',N'Perro',N'Hembra',N'Blanco',N'SAN JUAN DE LURIGANCHO'),
    (484,N'69787068',N'JACK','20180314',N'Shitzu Toy',N'Perro',N'Hembra',N'Gris',N'SANTIAGO DE SURCO'),
    (485,N'62016082',N'CANELA','20170427',N'Única',N'Perro',N'Hembra',N'Marrón',N'MAGDALENA DEL MAR'),
    (486,N'54809394',N'LUCKY','20200319',N'Poodle con Bichón',N'Perro',N'Macho',N'Canela',N'SAN BORJA'),
    (487,N'49716647',N'OSO','20191022',N'Terrier Tibetano',N'Perro',N'Macho',N'Marrón y blanco',N'LA MOLINA'),
    (488,N'76236844',N'GORDO','20111016',N'Única',N'Perro',N'Hembra',N'Tricolor',N'SANTIAGO DE SURCO'),
    (489,N'41371634',N'MINNIE','20190920',N'Única',N'Gato',N'Hembra',N'Atigrado gris',N'SANTIAGO DE SURCO'),
    (490,N'41462776',N'ROCKY','20160805',N'Schnauzer',N'Perro',N'Macho',N'Negro',N'SAN JUAN DE LURIGANCHO'),
    (491,N'63249717',N'BOLITA','20160517',N'Única',N'Gato',N'Macho',N'Blanco',N'SAN JUAN DE LURIGANCHO'),
    (492,N'17301708',N'CHOCOLATE','20231122',N'Única',N'Perro',N'Hembra',N'Negro y blanco',N'LA MOLINA'),
    (493,N'78151815',N'MANCHAS','20180425',N'Schnauzer',N'Perro',N'Macho',N'Blanco',N'COMAS'),
    (494,N'41519908',N'COCO','20150410',N'Única',N'Perro',N'Macho',N'Plateado',N'SAN MARTIN DE PORRES'),
    (495,N'14532760',N'MAX','20201107',N'Única',N'Perro',N'Hembra',N'Negro y marrón',N'ATE'),
    (496,N'25807541',N'CANELA','20200225',N'Schnauzer',N'Perro',N'Hembra',N'Sable',N'JESUS MARIA'),
    (497,N'21272134',N'CLEO','20220827',N'Única',N'Gato',N'Hembra',N'Tabby',N'ATE'),
    (498,N'27773440',N'PEPE','20210723',N'Cocker Americano',N'Perro',N'Macho',N'Blanco y negro',N'SAN JUAN DE LURIGANCHO'),
    (499,N'11850014',N'COCO','20130410',N'Terrier Tibetano',N'Perro',N'Macho',N'Chocolate',N'SAN JUAN DE LURIGANCHO'),
    (500,N'21931334',N'TOMASA','20201015',N'Única',N'Gato',N'Hembra',N'Bicolor',N'SAN MARTIN DE PORRES'),
    (501,N'52709584',N'DAISY','20150806',N'Boxer Alemán',N'Perro',N'Hembra',N'Caramelo',N'SAN JUAN DE LURIGANCHO'),
    (502,N'54072988',N'ROCCO','20141005',N'Única',N'Perro',N'Hembra',N'Miel',N'SAN MARTIN DE PORRES'),
    (503,N'55837540',N'OLIVER','20201115',N'Única',N'Gato',N'Hembra',N'Bicolor',N'SAN JUAN DE LURIGANCHO'),
    (504,N'73558850',N'NALA','20110605',N'Shitzu',N'Perro',N'Macho',N'Gris',N'JESUS MARIA'),
    (505,N'34482179',N'GORDO','20230908',N'Buldog Frances',N'Perro',N'Hembra',N'Beige',N'LA MOLINA'),
    (506,N'50363445',N'LASSIE','20150331',N'Poodle con Bichón',N'Perro',N'Macho',N'Marrón y blanco',N'SAN MARTIN DE PORRES'),
    (507,N'69119383',N'MISHI','20211118',N'Única',N'Gato',N'Hembra',N'Negro y blanco',N'ATE'),
    (508,N'19875249',N'GORDO','20170314',N'Única',N'Perro',N'Hembra',N'Café',N'SAN MARTIN DE PORRES'),
    (509,N'22474786',N'MISHI','20230717',N'Única',N'Gato',N'Macho',N'Bicolor',N'COMAS'),
    (510,N'35657041',N'TIGRE','20221228',N'Única',N'Gato',N'Macho',N'Crema',N'SAN JUAN DE LURIGANCHO'),
    (511,N'16162308',N'ZEUS','20170614',N'Schnauzer',N'Perro',N'Hembra',N'Tricolor',N'SAN MARTIN DE PORRES'),
    (512,N'13241297',N'SIMBA','20150306',N'Bigel',N'Perro',N'Hembra',N'Atigrado',N'ATE'),
    (513,N'28507286',N'MINA','20241004',N'Única',N'Gato',N'Macho',N'Carey',N'SANTIAGO DE SURCO'),
    (514,N'45747626',N'MINA','20240915',N'Única',N'Gato',N'Macho',N'Bicolor',N'MAGDALENA DEL MAR'),
    (515,N'26297812',N'OSO','20120906',N'Terrier Tibetano',N'Perro',N'Hembra',N'Bicolor',N'COMAS'),
    (516,N'65503322',N'DAISY','20180614',N'Única',N'Perro',N'Hembra',N'Gris',N'COMAS'),
    (517,N'71207207',N'PANCHO','20131029',N'Única',N'Perro',N'Hembra',N'Marrón y blanco',N'LA MOLINA'),
    (518,N'67182398',N'MICHI','20210423',N'Única',N'Gato',N'Macho',N'Tabby naranja',N'MIRAFLORES'),
    (519,N'33684231',N'JACK','20180725',N'Única',N'Perro',N'Macho',N'Merle',N'SAN JUAN DE LURIGANCHO'),
    (520,N'29670750',N'DAISY','20151113',N'Pequines Alvino',N'Perro',N'Macho',N'Marrón y blanco',N'SAN JUAN DE LURIGANCHO'),
    (521,N'61509430',N'NEGRO','20130412',N'Única',N'Perro',N'Hembra',N'Negro y blanco',N'ATE'),
    (522,N'38691854',N'DAISY','20131209',N'Única',N'Perro',N'Macho',N'Miel',N'SAN MARTIN DE PORRES'),
    (523,N'49119649',N'HACHI','20170406',N'Schnauzer',N'Perro',N'Macho',N'Negro',N'COMAS'),
    (524,N'14172520',N'TOM','20220411',N'Única',N'Gato',N'Hembra',N'Naranja',N'LA MOLINA'),
    (525,N'61100472',N'HACHI','20180828',N'Buldog Frances',N'Perro',N'Hembra',N'Blanco y negro',N'SAN JUAN DE LURIGANCHO'),
    (526,N'72037062',N'ROCCO','20151112',N'Shitzu',N'Perro',N'Hembra',N'Merle',N'LA MOLINA'),
    (527,N'73667704',N'NALA','20120829',N'Única',N'Perro',N'Macho',N'Arena',N'LA MOLINA'),
    (528,N'13429530',N'KIRA','20120815',N'Única',N'Perro',N'Macho',N'Negro',N'MIRAFLORES'),
    (529,N'14651562',N'MANCHAS','20150416',N'Única',N'Perro',N'Macho',N'Dorado',N'ATE'),
    (530,N'42758335',N'MAYA','20141205',N'Única',N'Perro',N'Macho',N'Blanco',N'SANTIAGO DE SURCO'),
    (531,N'17834268',N'NIEVE','20180323',N'Única',N'Gato',N'Macho',N'Calicó',N'COMAS'),
    (532,N'72953037',N'PELUCHE','20121203',N'Única',N'Gato',N'Hembra',N'Tricolor',N'COMAS'),
    (533,N'32384647',N'NEGRO','20210216',N'Shitzu Toy',N'Perro',N'Hembra',N'Atigrado',N'SANTIAGO DE SURCO'),
    (534,N'64355710',N'ANGEL','20200419',N'Única',N'Perro',N'Macho',N'Arena',N'SAN BORJA'),
    (535,N'57704381',N'TOÑO','20230723',N'Bigel',N'Perro',N'Macho',N'Manchado',N'COMAS'),
    (536,N'66111417',N'NALA','20230619',N'American Bully',N'Perro',N'Hembra',N'Marrón y blanco',N'SAN BORJA'),
    (537,N'33668261',N'MOCHA','20220215',N'Golden',N'Perro',N'Hembra',N'Negro y blanco',N'SAN JUAN DE LURIGANCHO'),
    (538,N'29038246',N'PEPE','20210205',N'Pug',N'Perro',N'Hembra',N'Arena',N'ATE'),
    (539,N'34544583',N'MINNIE','20130312',N'Única',N'Gato',N'Macho',N'Punto chocolate',N'ATE'),
    (540,N'19011623',N'ROCCO','20250511',N'Schnauzer',N'Perro',N'Hembra',N'Caramelo',N'SAN JUAN DE LURIGANCHO'),
    (541,N'65248947',N'NALA','20220311',N'Única',N'Perro',N'Hembra',N'Miel',N'SANTIAGO DE SURCO'),
    (542,N'74302115',N'NIEVE','20241111',N'Única',N'Gato',N'Hembra',N'Tabby naranja',N'JESUS MARIA'),
    (543,N'28432775',N'BETO','20181226',N'Única',N'Perro',N'Macho',N'Blanco',N'SANTIAGO DE SURCO'),
    (544,N'66512412',N'CANELA','20180208',N'Shitzu',N'Perro',N'Macho',N'Arena',N'SAN MARTIN DE PORRES'),
    (545,N'31608170',N'MOMO','20160726',N'Única',N'Gato',N'Hembra',N'Gris claro',N'SAN MARTIN DE PORRES'),
    (546,N'52105566',N'CHISPA','20251107',N'Labrador',N'Perro',N'Hembra',N'Arena',N'ATE'),
    (547,N'79882916',N'JACK','20160328',N'Única',N'Perro',N'Hembra',N'Negro',N'ATE'),
    (548,N'56908733',N'SIMBA','20160828',N'Schnauzer',N'Perro',N'Hembra',N'Caramelo',N'SANTIAGO DE SURCO'),
    (549,N'47288941',N'TITAN','20230708',N'Boxer Alemán',N'Perro',N'Hembra',N'Blanco y marrón',N'SAN JUAN DE LURIGANCHO'),
    (550,N'34651232',N'MOCHA','20231226',N'Schnauzer',N'Perro',N'Macho',N'Negro',N'SAN MARTIN DE PORRES')
) v(seq, dni, nombre, fecha_nacimiento, raza, especie, sexo, color, distrito)
JOIN dbo.CLIENTE   c  ON c.dni = v.dni
JOIN dbo.ESPECIE   e  ON e.nombre_especie = v.especie
JOIN dbo.RAZA      r  ON r.id_especie = e.id_especie AND r.nombre_raza = v.raza
JOIN dbo.SEXO      x  ON x.descripcion = v.sexo
JOIN dbo.COLOR     co ON co.descripcion = v.color
JOIN dbo.UBICACION u  ON u.distrito = v.distrito AND u.departamento = N'LIMA' AND u.provincia = N'LIMA'
WHERE NOT EXISTS (SELECT 1 FROM dbo.MASCOTA m WHERE m.id_cliente = c.id_cliente AND m.nombre = v.nombre)
ORDER BY v.seq;

/* VACUNA (solo las que faltan; Antirrábica y Quíntuple ya existen) */
IF NOT EXISTS (SELECT 1 FROM dbo.VACUNA WHERE nombre = N'Séxtuple')
    INSERT INTO dbo.VACUNA (nombre, descripcion)
    VALUES (N'Séxtuple', N'Vacuna múltiple para perros (sextuple)');
IF NOT EXISTS (SELECT 1 FROM dbo.VACUNA WHERE nombre = N'Óctuple')
    INSERT INTO dbo.VACUNA (nombre, descripcion)
    VALUES (N'Óctuple', N'Vacuna múltiple para perros (óctuple)');
IF NOT EXISTS (SELECT 1 FROM dbo.VACUNA WHERE nombre = N'Parvovirus')
    INSERT INTO dbo.VACUNA (nombre, descripcion)
    VALUES (N'Parvovirus', N'Vacuna contra parvovirus canino');
IF NOT EXISTS (SELECT 1 FROM dbo.VACUNA WHERE nombre = N'Bordetella')
    INSERT INTO dbo.VACUNA (nombre, descripcion)
    VALUES (N'Bordetella', N'Vacuna contra la tos de las perreras');
IF NOT EXISTS (SELECT 1 FROM dbo.VACUNA WHERE nombre = N'Leptospirosis')
    INSERT INTO dbo.VACUNA (nombre, descripcion)
    VALUES (N'Leptospirosis', N'Vacuna contra leptospirosis');
IF NOT EXISTS (SELECT 1 FROM dbo.VACUNA WHERE nombre = N'Triple Felina')
    INSERT INTO dbo.VACUNA (nombre, descripcion)
    VALUES (N'Triple Felina', N'Vacuna contra rinotraqueítis, calicivirus y panleucopenia felina');
IF NOT EXISTS (SELECT 1 FROM dbo.VACUNA WHERE nombre = N'Leucemia Felina')
    INSERT INTO dbo.VACUNA (nombre, descripcion)
    VALUES (N'Leucemia Felina', N'Vacuna contra la leucemia felina');

/* CITA: 836 citas (atendidas, canceladas y pendientes) asignadas al empleado 'admin' */
DECLARE @id_empleado INT = (SELECT id_empleado FROM dbo.EMPLEADO WHERE usuario = N'admin');
IF @id_empleado IS NULL
    THROW 50002, 'No existe el empleado admin necesario para registrar las citas.', 1;

INSERT INTO dbo.CITA (fecha_cita, hora_cita, motivo, estado, id_mascota, id_empleado, ESTADO_ACTIVO)
SELECT v.fecha, v.hora, v.motivo, v.estado, m.id_mascota, @id_empleado, 1
FROM (VALUES
    (1,N'73049233',N'AINOA','20230426','16:00',N'Limpieza dental',N'Atendida'),
    (2,N'21102353',N'AKIRA','20230509','15:00',N'Vacunación',N'Atendida'),
    (3,N'71161158',N'ALEJANDRITA','20230511','14:00',N'Revisión dermatológica',N'Atendida'),
    (4,N'71161158',N'ALEJANDRITA','20240516','12:00',N'Desparasitación',N'Atendida'),
    (5,N'53019203',N'ATILA','20230506','10:00',N'Revisión por cojera',N'Atendida'),
    (6,N'53019203',N'ATILA','20240523','16:30',N'Control post-operatorio',N'Cancelada'),
    (7,N'17804016',N'BLANQUITA','20230506','10:00',N'Evaluación de esterilización',N'Atendida'),
    (8,N'65683365',N'BAMBAM','20230420','16:30',N'Revisión dermatológica',N'Atendida'),
    (9,N'92473722',N'BELLA','20230421','16:30',N'Chequeo anual',N'Atendida'),
    (10,N'92473722',N'BELLA','20231113','17:30',N'Evaluación de esterilización',N'Atendida'),
    (11,N'71042911',N'BLACK','20230428','17:00',N'Desparasitación',N'Atendida'),
    (12,N'31161878',N'BOCKY','20230501','16:30',N'Revisión por cojera',N'Atendida'),
    (13,N'31161878',N'BOCKY','20261030','13:30',N'Revisión dermatológica',N'Pendiente'),
    (14,N'83495146',N'BRANDY','20230424','10:00',N'Vacunación',N'Atendida'),
    (15,N'83495146',N'BRANDY','20231206','12:00',N'Revisión por cojera',N'Atendida'),
    (16,N'20693447',N'CAMIL','20230503','09:30',N'Limpieza dental',N'Cancelada'),
    (17,N'20693447',N'CAMIL','20230825','15:30',N'Limpieza dental',N'Atendida'),
    (18,N'31843366',N'CAMIL','20230427','10:00',N'Revisión por cojera',N'Atendida'),
    (19,N'31843366',N'CAMIL','20240215','09:00',N'Vacunación',N'Atendida'),
    (20,N'24804339',N'CANELA','20230429','16:30',N'Baño medicado',N'Cancelada'),
    (21,N'59580044',N'COOPER','20230508','15:00',N'Revisión por cojera',N'Atendida'),
    (22,N'59580044',N'COOPER','20231024','15:00',N'Revisión dermatológica',N'Atendida'),
    (23,N'58200384',N'CECHI','20230425','16:30',N'Chequeo anual',N'Atendida'),
    (24,N'58200384',N'CECHI','20240125','14:30',N'Revisión dermatológica',N'Cancelada'),
    (25,N'77442758',N'COCO','20230502','16:00',N'Evaluación de esterilización',N'Atendida'),
    (26,N'35946785',N'CHATO','20230427','11:30',N'Vacunación',N'Atendida'),
    (27,N'66490721',N'CHIQUI','20230506','13:30',N'Control post-operatorio',N'Atendida'),
    (28,N'83010312',N'CHIQUITA BRAVO','20230506','16:30',N'Limpieza dental',N'Atendida'),
    (29,N'83010312',N'CHIQUITA BRAVO','20240127','09:00',N'Desparasitación',N'Atendida'),
    (30,N'43622481',N'DEYSI','20230505','17:30',N'Revisión por cojera',N'Atendida'),
    (31,N'72987366',N'DOLLY','20230426','10:00',N'Revisión por vómitos',N'Atendida'),
    (32,N'72987366',N'DOLLY','20261216','15:30',N'Chequeo anual',N'Pendiente'),
    (33,N'40409222',N'DORITA','20230425','10:30',N'Revisión por cojera',N'Atendida'),
    (34,N'40409222',N'DORITA','20240129','15:00',N'Revisión por cojera',N'Atendida'),
    (35,N'18686265',N'DUNGA','20230508','11:30',N'Desparasitación',N'Atendida'),
    (36,N'18686265',N'DUNGA','20230613','15:30',N'Evaluación de esterilización',N'Atendida'),
    (37,N'99982179',N'DUQUESITA','20230424','14:00',N'Revisión por cojera',N'Atendida'),
    (38,N'99982179',N'DUQUESITA','20240304','17:30',N'Baño medicado',N'Atendida'),
    (39,N'82171493',N'ESTRELLITA','20230424','15:30',N'Desparasitación',N'Atendida'),
    (40,N'82171493',N'ESTRELLITA','20261105','12:30',N'Limpieza dental',N'Pendiente'),
    (41,N'59631561',N'FELIPE','20230508','10:00',N'Consulta general',N'Atendida'),
    (42,N'77059003',N'FOXY','20230424','12:00',N'Control post-operatorio',N'Atendida'),
    (43,N'51883468',N'FRESITA','20230429','13:30',N'Revisión por vómitos',N'Atendida'),
    (44,N'23274785',N'GRECO','20230508','12:30',N'Limpieza dental',N'Atendida'),
    (45,N'22884877',N'GRINGA','20230505','14:30',N'Vacunación',N'Atendida'),
    (46,N'22884877',N'GRINGA','20240527','09:00',N'Revisión por cojera',N'Atendida'),
    (47,N'65072361',N'GIORGO','20230422','13:30',N'Baño medicado',N'Atendida'),
    (48,N'65072361',N'GIORGO','20230909','12:30',N'Vacunación',N'Atendida'),
    (49,N'50357259',N'GOYA','20230429','11:30',N'Vacunación',N'Atendida'),
    (50,N'50357259',N'GOYA','20231122','13:30',N'Control de peso',N'Atendida'),
    (51,N'57394899',N'HASS','20230429','13:30',N'Baño medicado',N'Atendida'),
    (52,N'96639359',N'HINDI','20230512','17:30',N'Consulta general',N'Cancelada'),
    (53,N'45449433',N'HOLLY','20230429','15:30',N'Consulta general',N'Atendida'),
    (54,N'87073258',N'HUGO','20230429','14:30',N'Vacunación',N'Atendida'),
    (55,N'43098654',N'KRATOS','20230425','17:30',N'Control de peso',N'Atendida'),
    (56,N'43098654',N'KRATOS','20231202','11:30',N'Revisión por vómitos',N'Atendida'),
    (57,N'76113377',N'KILLA','20230426','16:30',N'Chequeo anual',N'Atendida'),
    (58,N'76113377',N'KILLA','20240115','14:00',N'Revisión por cojera',N'Atendida'),
    (59,N'80879931',N'KLIMB','20230505','14:00',N'Control de peso',N'Atendida'),
    (60,N'80879931',N'KLIMB','20231106','17:30',N'Revisión dermatológica',N'Atendida'),
    (61,N'80879931',N'KLIMB','20261228','16:30',N'Revisión por cojera',N'Pendiente'),
    (62,N'71323763',N'KOPI','20230428','09:00',N'Chequeo anual',N'Atendida'),
    (63,N'71578881',N'KUMA','20230501','16:30',N'Evaluación de esterilización',N'Atendida'),
    (64,N'71578881',N'KUMA','20261106','16:30',N'Vacunación',N'Pendiente'),
    (65,N'14255487',N'LETTY','20230502','10:00',N'Revisión dermatológica',N'Atendida'),
    (66,N'17095703',N'LARA','20230501','15:00',N'Revisión por cojera',N'Atendida'),
    (67,N'77707788',N'LEGOLAS','20230509','14:30',N'Consulta general',N'Atendida'),
    (68,N'44978812',N'LEYA','20230502','13:30',N'Consulta general',N'Cancelada'),
    (69,N'78043250',N'LUA','20230509','16:30',N'Vacunación',N'Atendida'),
    (70,N'78043250',N'LUA','20240302','15:00',N'Desparasitación',N'Atendida'),
    (71,N'86028611',N'LUANA','20230424','17:00',N'Evaluación de esterilización',N'Atendida'),
    (72,N'86028611',N'LUANA','20230930','10:00',N'Revisión por cojera',N'Atendida'),
    (73,N'10453063',N'LUNA','20230419','10:00',N'Revisión dermatológica',N'Atendida'),
    (74,N'10453063',N'LUNA','20240408','17:30',N'Evaluación de esterilización',N'Cancelada'),
    (75,N'37811251',N'LUNA','20230501','10:00',N'Chequeo anual',N'Atendida'),
    (76,N'37811251',N'LUNA','20261209','09:30',N'Revisión por vómitos',N'Pendiente'),
    (77,N'67914971',N'LUCKY','20230504','15:00',N'Control de peso',N'Cancelada'),
    (78,N'67914971',N'LUCKY','20230727','15:30',N'Limpieza dental',N'Atendida'),
    (79,N'53474998',N'LUZ','20230505','13:00',N'Desparasitación',N'Atendida'),
    (80,N'53474998',N'LUZ','20230717','15:30',N'Revisión por cojera',N'Atendida'),
    (81,N'61755938',N'MAYA','20230426','14:00',N'Evaluación de esterilización',N'Atendida'),
    (82,N'46340188',N'MAGI','20230501','16:30',N'Chequeo anual',N'Atendida'),
    (83,N'46340188',N'MAGI','20230607','13:00',N'Revisión por cojera',N'Atendida'),
    (84,N'79976947',N'MAIA','20230424','16:30',N'Evaluación de esterilización',N'Atendida'),
    (85,N'79976947',N'MAIA','20231107','15:30',N'Consulta general',N'Atendida'),
    (86,N'52722310',N'MANTY','20230508','10:30',N'Control post-operatorio',N'Atendida'),
    (87,N'43760409',N'MARA','20230509','10:00',N'Baño medicado',N'Cancelada'),
    (88,N'43760409',N'MARA','20230824','14:30',N'Baño medicado',N'Atendida'),
    (89,N'58743611',N'MARLEY','20230428','11:00',N'Chequeo anual',N'Cancelada'),
    (90,N'94538328',N'MARRÓN','20230501','17:00',N'Control de peso',N'Atendida'),
    (91,N'74519257',N'MARVEL','20230501','17:30',N'Chequeo anual',N'Atendida'),
    (92,N'23700218',N'MAYA','20230508','13:00',N'Revisión dermatológica',N'Atendida'),
    (93,N'41585435',N'MAYRO','20230501','11:00',N'Control de peso',N'Atendida'),
    (94,N'83258857',N'MINIE','20230501','12:30',N'Vacunación',N'Atendida'),
    (95,N'83258857',N'MINIE','20230915','13:30',N'Desparasitación',N'Atendida'),
    (96,N'29051955',N'MININA','20230420','11:00',N'Control post-operatorio',N'Atendida'),
    (97,N'29051955',N'MININA','20230710','11:30',N'Chequeo anual',N'Cancelada'),
    (98,N'29051955',N'MININA','20261020','17:30',N'Control de peso',N'Pendiente'),
    (99,N'36079144',N'MINNA','20230512','11:00',N'Evaluación de esterilización',N'Atendida'),
    (100,N'93021703',N'MISHA','20230501','12:30',N'Vacunación',N'Atendida'),
    (101,N'93021703',N'MISHA','20231116','15:30',N'Evaluación de esterilización',N'Atendida'),
    (102,N'30379788',N'MOLLY','20230508','09:00',N'Evaluación de esterilización',N'Atendida'),
    (103,N'59086363',N'MOLLY','20230506','13:30',N'Evaluación de esterilización',N'Atendida'),
    (104,N'11703235',N'MONKY','20230426','16:30',N'Consulta general',N'Atendida'),
    (105,N'11703235',N'MONKY','20230725','14:30',N'Vacunación',N'Atendida'),
    (106,N'11703235',N'MONKY','20261126','13:00',N'Revisión por cojera',N'Pendiente'),
    (107,N'58839322',N'NALA','20230508','15:00',N'Control post-operatorio',N'Atendida'),
    (108,N'50143134',N'NILA','20230422','14:30',N'Limpieza dental',N'Atendida'),
    (109,N'47600393',N'NEGRITA','20230422','17:00',N'Chequeo anual',N'Atendida'),
    (110,N'19397597',N'NALA','20230503','14:30',N'Desparasitación',N'Atendida'),
    (111,N'19397597',N'NALA','20261118','14:00',N'Revisión por cojera',N'Pendiente'),
    (112,N'66369156',N'NENE','20230506','12:00',N'Consulta general',N'Atendida'),
    (113,N'32357106',N'NICKY','20230424','16:30',N'Evaluación de esterilización',N'Atendida'),
    (114,N'48535253',N'NICO','20230424','17:00',N'Limpieza dental',N'Atendida'),
    (115,N'48535253',N'NICO','20230701','16:00',N'Baño medicado',N'Atendida'),
    (116,N'44598490',N'NINA','20230424','09:00',N'Vacunación',N'Atendida'),
    (117,N'92117808',N'NIÑA','20230422','09:00',N'Evaluación de esterilización',N'Atendida'),
    (118,N'92117808',N'NIÑA','20230829','12:00',N'Evaluación de esterilización',N'Atendida'),
    (119,N'92117808',N'NIÑA','20261205','13:30',N'Revisión dermatológica',N'Pendiente'),
    (120,N'53258560',N'OREO','20230425','10:00',N'Baño medicado',N'Atendida'),
    (121,N'53258560',N'OREO','20230811','16:30',N'Desparasitación',N'Atendida'),
    (122,N'70081614',N'OSA','20230429','11:00',N'Control de peso',N'Atendida'),
    (123,N'70081614',N'OSA','20261117','09:30',N'Revisión dermatológica',N'Pendiente'),
    (124,N'62179698',N'OSO','20230428','15:30',N'Control post-operatorio',N'Cancelada'),
    (125,N'11101735',N'OTTO','20230424','09:00',N'Revisión por cojera',N'Cancelada'),
    (126,N'43966135',N'PACO','20230426','14:30',N'Vacunación',N'Atendida'),
    (127,N'50069966',N'PACO','20230504','14:00',N'Revisión dermatológica',N'Atendida'),
    (128,N'37662171',N'PANCHITA','20230429','14:30',N'Evaluación de esterilización',N'Atendida'),
    (129,N'37662171',N'PANCHITA','20230724','12:30',N'Vacunación',N'Atendida'),
    (130,N'37662171',N'PANCHITA','20261212','16:30',N'Desparasitación',N'Pendiente'),
    (131,N'32576233',N'PRINCESA','20230501','17:00',N'Control post-operatorio',N'Atendida'),
    (132,N'44167765',N'PRINCIPE','20230424','10:30',N'Control de peso',N'Cancelada'),
    (133,N'14512500',N'ROCCO','20230502','12:30',N'Consulta general',N'Atendida'),
    (134,N'87135532',N'ROCCO','20230503','09:00',N'Chequeo anual',N'Atendida'),
    (135,N'87135532',N'ROCCO','20261028','14:00',N'Desparasitación',N'Pendiente'),
    (136,N'45141552',N'ROCKY','20230422','17:00',N'Revisión dermatológica',N'Atendida'),
    (137,N'45141552',N'ROCKY','20231026','12:30',N'Control post-operatorio',N'Atendida'),
    (138,N'43731506',N'RICK','20230503','14:30',N'Consulta general',N'Atendida'),
    (139,N'83106100',N'RITO','20230428','14:00',N'Limpieza dental',N'Atendida'),
    (140,N'50606432',N'ROCKY','20230425','11:00',N'Desparasitación',N'Atendida'),
    (141,N'85463093',N'SACKY','20230426','09:00',N'Vacunación',N'Atendida'),
    (142,N'85463093',N'SACKY','20261107','11:30',N'Chequeo anual',N'Pendiente'),
    (143,N'35087613',N'SANTI','20230422','17:00',N'Revisión por cojera',N'Atendida'),
    (144,N'35087613',N'SANTI','20240219','10:00',N'Evaluación de esterilización',N'Atendida'),
    (145,N'77915097',N'SASHA','20230508','11:00',N'Consulta general',N'Atendida'),
    (146,N'51430602',N'SHIMA','20230503','16:00',N'Desparasitación',N'Atendida'),
    (147,N'51430602',N'SHIMA','20240527','10:00',N'Chequeo anual',N'Atendida'),
    (148,N'51430602',N'SHIMA','20261214','17:30',N'Revisión por vómitos',N'Pendiente'),
    (149,N'27898879',N'SIMBA','20230501','09:00',N'Evaluación de esterilización',N'Atendida'),
    (150,N'27898879',N'SIMBA','20230714','14:00',N'Control post-operatorio',N'Cancelada'),
    (151,N'27898879',N'SIMBA','20261221','13:00',N'Vacunación',N'Pendiente'),
    (152,N'37591160',N'SIRIUS','20230508','09:00',N'Control de peso',N'Atendida'),
    (153,N'37591160',N'SIRIUS','20230921','12:30',N'Desparasitación',N'Atendida'),
    (154,N'37591160',N'SIRIUS','20261102','14:00',N'Chequeo anual',N'Pendiente'),
    (155,N'33715647',N'TAYLER','20230505','11:30',N'Revisión por vómitos',N'Atendida'),
    (156,N'33715647',N'TAYLER','20230814','12:30',N'Baño medicado',N'Atendida'),
    (157,N'36338780',N'TEMY','20230426','17:30',N'Baño medicado',N'Atendida'),
    (158,N'53316884',N'MINNIE','20251112','15:30',N'Consulta general',N'Atendida'),
    (159,N'53316884',N'MINNIE','20261228','10:00',N'Revisión dermatológica',N'Pendiente'),
    (160,N'46075844',N'TRUENO','20240127','14:00',N'Vacunación',N'Atendida'),
    (161,N'46075844',N'TRUENO','20261021','10:00',N'Limpieza dental',N'Pendiente'),
    (162,N'16537126',N'LOLA','20241111','15:30',N'Chequeo anual',N'Atendida'),
    (163,N'75874880',N'LASSIE','20240311','14:30',N'Control de peso',N'Atendida'),
    (164,N'50665804',N'KIRA','20260529','12:30',N'Desparasitación',N'Atendida'),
    (165,N'73756858',N'SAMY','20260619','11:30',N'Chequeo anual',N'Atendida'),
    (166,N'46337525',N'ZEUS','20240126','14:30',N'Desparasitación',N'Atendida'),
    (167,N'46337525',N'ZEUS','20250217','13:30',N'Revisión por cojera',N'Atendida'),
    (168,N'75598594',N'PRINCESA','20241109','16:30',N'Consulta general',N'Atendida'),
    (169,N'71990332',N'MILO','20251011','17:00',N'Evaluación de esterilización',N'Cancelada'),
    (170,N'58213469',N'COCO','20260808','09:00',N'Consulta general',N'Atendida'),
    (171,N'77344573',N'NEGRO','20240412','10:00',N'Control de peso',N'Atendida'),
    (172,N'77344573',N'NEGRO','20261022','13:00',N'Desparasitación',N'Pendiente'),
    (173,N'70536828',N'TITAN','20240220','11:00',N'Revisión por cojera',N'Cancelada'),
    (174,N'39138767',N'BOBBY','20240229','10:00',N'Desparasitación',N'Atendida'),
    (175,N'39138767',N'BOBBY','20250104','09:00',N'Chequeo anual',N'Cancelada'),
    (176,N'47246945',N'COCO','20231003','14:30',N'Control de peso',N'Atendida'),
    (177,N'47246945',N'COCO','20231227','11:30',N'Chequeo anual',N'Atendida'),
    (178,N'57535139',N'THOR','20260831','11:00',N'Evaluación de esterilización',N'Atendida'),
    (179,N'57535139',N'THOR','20261228','14:00',N'Consulta general',N'Pendiente'),
    (180,N'51064536',N'OLIVER','20250506','12:00',N'Revisión por vómitos',N'Atendida'),
    (181,N'31366985',N'LUNA','20250108','10:30',N'Baño medicado',N'Atendida'),
    (182,N'31366985',N'LUNA','20251204','12:00',N'Chequeo anual',N'Atendida'),
    (183,N'38386240',N'OSO','20260521','11:00',N'Limpieza dental',N'Atendida'),
    (184,N'38386240',N'OSO','20270415','17:30',N'Control post-operatorio',N'Pendiente'),
    (185,N'38386240',N'OSO','20261210','17:30',N'Revisión dermatológica',N'Pendiente'),
    (186,N'23781600',N'ROCCO','20250804','11:30',N'Evaluación de esterilización',N'Atendida'),
    (187,N'23781600',N'ROCCO','20251129','10:00',N'Desparasitación',N'Atendida'),
    (188,N'75149339',N'PANCHO','20250906','13:00',N'Evaluación de esterilización',N'Atendida'),
    (189,N'32374940',N'GORDO','20260615','10:00',N'Consulta general',N'Atendida'),
    (190,N'32374940',N'GORDO','20261008','11:00',N'Revisión dermatológica',N'Atendida'),
    (191,N'35967986',N'MINNIE','20230823','13:00',N'Revisión por vómitos',N'Atendida'),
    (192,N'43015498',N'MOCHA','20240909','11:00',N'Evaluación de esterilización',N'Atendida'),
    (193,N'43015498',N'MOCHA','20250331','15:00',N'Vacunación',N'Atendida'),
    (194,N'38320094',N'BOBBY','20260413','09:30',N'Desparasitación',N'Atendida'),
    (195,N'39512989',N'COCO','20250909','12:00',N'Consulta general',N'Atendida'),
    (196,N'50251342',N'ZEUS','20240828','15:00',N'Vacunación',N'Atendida'),
    (197,N'54344343',N'MANCHAS','20260717','14:30',N'Revisión por cojera',N'Atendida'),
    (198,N'54344343',N'MANCHAS','20261130','11:30',N'Limpieza dental',N'Pendiente'),
    (199,N'60693432',N'NALA','20250430','12:30',N'Evaluación de esterilización',N'Atendida'),
    (200,N'61283202',N'TYSON','20250426','16:30',N'Desparasitación',N'Atendida'),
    (201,N'61283202',N'TYSON','20251009','10:30',N'Evaluación de esterilización',N'Atendida'),
    (202,N'42339214',N'IRIS','20250417','09:00',N'Revisión por cojera',N'Atendida'),
    (203,N'35860182',N'GORDO','20260129','14:00',N'Control post-operatorio',N'Atendida'),
    (204,N'32056535',N'TOMASA','20260706','10:00',N'Revisión por cojera',N'Atendida'),
    (205,N'32056535',N'TOMASA','20270719','13:30',N'Revisión por cojera',N'Pendiente'),
    (206,N'49176341',N'OLIVER','20240504','12:00',N'Revisión por vómitos',N'Atendida'),
    (207,N'49176341',N'OLIVER','20250127','09:00',N'Revisión por vómitos',N'Atendida'),
    (208,N'44353078',N'OLIVER','20261019','17:30',N'Baño medicado',N'Pendiente'),
    (209,N'44353078',N'OLIVER','20270115','15:30',N'Control de peso',N'Pendiente'),
    (210,N'54073127',N'TOÑO','20260529','11:00',N'Desparasitación',N'Cancelada'),
    (211,N'11644275',N'NALA','20251105','11:00',N'Revisión dermatológica',N'Atendida'),
    (212,N'11644275',N'NALA','20260720','09:30',N'Control de peso',N'Atendida'),
    (213,N'70251498',N'CHISPA','20261016','12:30',N'Revisión dermatológica',N'Atendida'),
    (214,N'75331516',N'DAISY','20230525','12:00',N'Evaluación de esterilización',N'Atendida'),
    (215,N'75331516',N'DAISY','20240628','09:00',N'Revisión por cojera',N'Atendida'),
    (216,N'18249549',N'NIEVE','20250523','13:00',N'Desparasitación',N'Atendida'),
    (217,N'18249549',N'NIEVE','20261204','11:30',N'Revisión por vómitos',N'Pendiente'),
    (218,N'44057414',N'COCO','20260317','09:00',N'Control de peso',N'Atendida'),
    (219,N'44057414',N'COCO','20261012','10:30',N'Chequeo anual',N'Atendida'),
    (220,N'27749817',N'PELUCHE','20240621','10:00',N'Revisión dermatológica',N'Atendida'),
    (221,N'27749817',N'PELUCHE','20241101','12:30',N'Revisión por vómitos',N'Cancelada'),
    (222,N'14179958',N'CHIQUI','20240119','17:00',N'Revisión dermatológica',N'Atendida'),
    (223,N'14179958',N'CHIQUI','20261214','11:30',N'Evaluación de esterilización',N'Pendiente'),
    (224,N'35029611',N'ZEUS','20241004','15:00',N'Chequeo anual',N'Atendida'),
    (225,N'35029611',N'ZEUS','20250329','10:00',N'Consulta general',N'Atendida'),
    (226,N'43588550',N'BOBBY','20250325','14:30',N'Control post-operatorio',N'Cancelada'),
    (227,N'56162302',N'ANGEL','20250411','11:00',N'Control post-operatorio',N'Atendida'),
    (228,N'56162302',N'ANGEL','20251104','10:00',N'Chequeo anual',N'Atendida'),
    (229,N'37855761',N'MOCHA','20240116','17:30',N'Baño medicado',N'Atendida'),
    (230,N'79028178',N'BETO','20231227','09:30',N'Revisión por vómitos',N'Atendida'),
    (231,N'79028178',N'BETO','20240217','10:30',N'Chequeo anual',N'Atendida'),
    (232,N'53561260',N'LUCKY','20240126','10:00',N'Baño medicado',N'Atendida'),
    (233,N'53561260',N'LUCKY','20241028','09:30',N'Revisión por vómitos',N'Atendida'),
    (234,N'26212581',N'MICHI','20230626','09:00',N'Consulta general',N'Atendida'),
    (235,N'76885298',N'PELUSA','20231019','12:30',N'Control post-operatorio',N'Atendida'),
    (236,N'20966078',N'ANGEL','20240812','12:00',N'Consulta general',N'Atendida'),
    (237,N'25276068',N'PANTERA','20260107','12:00',N'Revisión por cojera',N'Atendida'),
    (238,N'25276068',N'PANTERA','20261221','15:30',N'Revisión por vómitos',N'Pendiente'),
    (239,N'44827796',N'BRUNO','20260219','17:00',N'Desparasitación',N'Atendida'),
    (240,N'67321528',N'GOKU','20261008','14:00',N'Desparasitación',N'Atendida'),
    (241,N'67321528',N'GOKU','20270612','15:30',N'Baño medicado',N'Pendiente'),
    (242,N'53105515',N'NEGRO','20261026','10:30',N'Control post-operatorio',N'Pendiente'),
    (243,N'48607157',N'GOKU','20230706','13:30',N'Revisión por cojera',N'Atendida'),
    (244,N'48607157',N'GOKU','20240528','15:00',N'Baño medicado',N'Atendida'),
    (245,N'37495349',N'LUNA','20251215','15:30',N'Chequeo anual',N'Atendida'),
    (246,N'37495349',N'LUNA','20260130','15:30',N'Revisión dermatológica',N'Atendida'),
    (247,N'54400813',N'DAISY','20241230','09:00',N'Desparasitación',N'Atendida'),
    (248,N'46221200',N'MOMO','20241129','14:30',N'Baño medicado',N'Atendida'),
    (249,N'53060004',N'OSO','20260622','14:30',N'Vacunación',N'Atendida'),
    (250,N'53060004',N'OSO','20260926','12:00',N'Vacunación',N'Atendida'),
    (251,N'29660614',N'TOBY','20260914','17:00',N'Limpieza dental',N'Atendida'),
    (252,N'29660614',N'TOBY','20270301','12:30',N'Evaluación de esterilización',N'Pendiente'),
    (253,N'37828753',N'CHIQUI','20250515','12:00',N'Desparasitación',N'Atendida'),
    (254,N'37828753',N'CHIQUI','20261105','11:00',N'Desparasitación',N'Pendiente'),
    (255,N'68285145',N'ANGEL','20240309','13:30',N'Revisión por cojera',N'Atendida'),
    (256,N'68285145',N'ANGEL','20241122','15:30',N'Control de peso',N'Cancelada'),
    (257,N'14378485',N'TOBY','20260505','09:30',N'Control de peso',N'Atendida'),
    (258,N'35063063',N'GORDO','20231211','11:00',N'Desparasitación',N'Atendida'),
    (259,N'54572038',N'SIMBA','20240419','10:00',N'Vacunación',N'Atendida'),
    (260,N'12693757',N'TITAN','20240923','17:00',N'Revisión dermatológica',N'Atendida'),
    (261,N'36292579',N'NEGRO','20240115','17:00',N'Vacunación',N'Atendida'),
    (262,N'20855772',N'CHOCOLATE','20251222','15:30',N'Revisión dermatológica',N'Atendida'),
    (263,N'36725962',N'TOBY','20250421','16:00',N'Revisión dermatológica',N'Atendida'),
    (264,N'36725962',N'TOBY','20250617','16:30',N'Control de peso',N'Atendida'),
    (265,N'58637800',N'BRUNO','20250415','09:00',N'Desparasitación',N'Atendida'),
    (266,N'65972462',N'OLIVER','20230518','16:30',N'Desparasitación',N'Atendida'),
    (267,N'65972462',N'OLIVER','20261029','09:00',N'Limpieza dental',N'Pendiente'),
    (268,N'45932642',N'MOCHA','20241216','12:00',N'Limpieza dental',N'Atendida'),
    (269,N'45932642',N'MOCHA','20250801','09:30',N'Vacunación',N'Atendida'),
    (270,N'39734772',N'MILO','20250712','15:30',N'Revisión dermatológica',N'Atendida'),
    (271,N'39734772',N'MILO','20251104','16:30',N'Revisión por cojera',N'Atendida'),
    (272,N'39734772',N'MILO','20261207','17:30',N'Control post-operatorio',N'Pendiente'),
    (273,N'77521126',N'SAMY','20250605','14:30',N'Control post-operatorio',N'Atendida'),
    (274,N'66139552',N'BOBBY','20260213','13:30',N'Consulta general',N'Atendida'),
    (275,N'38601665',N'BRUNO','20250331','12:00',N'Revisión por cojera',N'Atendida'),
    (276,N'16148560',N'FIRULAIS','20250924','16:00',N'Revisión por vómitos',N'Atendida'),
    (277,N'64701909',N'TYSON','20250929','12:00',N'Desparasitación',N'Atendida'),
    (278,N'66703032',N'GARFIELD','20240719','12:00',N'Consulta general',N'Atendida'),
    (279,N'58228917',N'TOBY','20261021','09:00',N'Limpieza dental',N'Pendiente'),
    (280,N'17516769',N'ROCKY','20260718','10:00',N'Desparasitación',N'Atendida'),
    (281,N'70962766',N'CANELA','20250707','15:30',N'Limpieza dental',N'Atendida'),
    (282,N'24289836',N'BETO','20241227','11:30',N'Vacunación',N'Atendida'),
    (283,N'32556969',N'ROCKY','20231110','13:30',N'Revisión por cojera',N'Atendida'),
    (284,N'54744533',N'LUCKY','20250830','11:00',N'Baño medicado',N'Atendida'),
    (285,N'54744533',N'LUCKY','20260907','09:30',N'Consulta general',N'Atendida'),
    (286,N'38443718',N'TOBY','20250123','14:00',N'Vacunación',N'Atendida'),
    (287,N'11432233',N'LOLA','20251208','16:30',N'Baño medicado',N'Atendida'),
    (288,N'11432233',N'LOLA','20260720','16:00',N'Revisión por cojera',N'Atendida'),
    (289,N'66933972',N'GATUBELA','20251126','09:00',N'Vacunación',N'Atendida'),
    (290,N'66933972',N'GATUBELA','20260220','17:00',N'Revisión por cojera',N'Atendida'),
    (291,N'41067506',N'JACK','20251020','11:00',N'Vacunación',N'Atendida'),
    (292,N'41067506',N'JACK','20260402','12:00',N'Baño medicado',N'Atendida'),
    (293,N'17968489',N'CANELA','20230706','10:30',N'Desparasitación',N'Atendida'),
    (294,N'17968489',N'CANELA','20261221','10:30',N'Vacunación',N'Pendiente'),
    (295,N'35567394',N'MOCHA','20250930','09:00',N'Limpieza dental',N'Atendida'),
    (296,N'35567394',N'MOCHA','20260611','10:30',N'Baño medicado',N'Atendida'),
    (297,N'10374680',N'NALA','20260218','14:00',N'Chequeo anual',N'Atendida'),
    (298,N'10374680',N'NALA','20270325','17:30',N'Evaluación de esterilización',N'Pendiente'),
    (299,N'63703773',N'BETO','20250103','11:30',N'Baño medicado',N'Atendida'),
    (300,N'63703773',N'BETO','20251013','17:00',N'Revisión por vómitos',N'Atendida'),
    (301,N'63703773',N'BETO','20261209','11:00',N'Revisión dermatológica',N'Pendiente'),
    (302,N'26925176',N'NALA','20260102','12:00',N'Evaluación de esterilización',N'Cancelada'),
    (303,N'50193307',N'FIONA','20231116','12:00',N'Revisión dermatológica',N'Atendida'),
    (304,N'68488848',N'LUNA','20250619','17:00',N'Chequeo anual',N'Atendida'),
    (305,N'17873272',N'IRIS','20250103','14:30',N'Revisión dermatológica',N'Atendida'),
    (306,N'44893952',N'NALA','20251230','13:00',N'Baño medicado',N'Atendida'),
    (307,N'44893952',N'NALA','20260513','09:00',N'Consulta general',N'Atendida'),
    (308,N'52964751',N'LUCKY','20231229','16:00',N'Control post-operatorio',N'Atendida'),
    (309,N'52964751',N'LUCKY','20240928','14:00',N'Revisión por cojera',N'Cancelada'),
    (310,N'61745970',N'OLIVER','20240502','09:30',N'Vacunación',N'Atendida'),
    (311,N'21984827',N'ANGEL','20251110','15:30',N'Evaluación de esterilización',N'Atendida'),
    (312,N'66057004',N'ROCCO','20230519','17:30',N'Consulta general',N'Atendida'),
    (313,N'66057004',N'ROCCO','20240329','11:30',N'Control de peso',N'Atendida'),
    (314,N'66057004',N'ROCCO','20261028','09:00',N'Revisión dermatológica',N'Pendiente'),
    (315,N'74409158',N'NALA','20251018','11:30',N'Consulta general',N'Atendida'),
    (316,N'74409158',N'NALA','20261116','12:30',N'Control post-operatorio',N'Pendiente'),
    (317,N'60487593',N'PELUCHE','20230906','16:30',N'Revisión por cojera',N'Atendida'),
    (318,N'38663018',N'SAMY','20250917','10:00',N'Desparasitación',N'Atendida'),
    (319,N'38663018',N'SAMY','20261124','13:00',N'Desparasitación',N'Pendiente'),
    (320,N'74414951',N'TOBY','20250222','09:00',N'Baño medicado',N'Atendida'),
    (321,N'74414951',N'TOBY','20251201','11:00',N'Consulta general',N'Atendida'),
    (322,N'45907081',N'OLIVER','20260402','13:30',N'Chequeo anual',N'Atendida'),
    (323,N'45907081',N'OLIVER','20261010','17:30',N'Revisión por cojera',N'Atendida'),
    (324,N'18684426',N'ANGEL','20240510','09:30',N'Vacunación',N'Atendida'),
    (325,N'18684426',N'ANGEL','20240626','12:30',N'Revisión por cojera',N'Atendida'),
    (326,N'66499753',N'MILO','20250402','13:00',N'Consulta general',N'Atendida'),
    (327,N'66499753',N'MILO','20261207','13:30',N'Control post-operatorio',N'Pendiente'),
    (328,N'39050775',N'GATUBELA','20260220','16:00',N'Control post-operatorio',N'Atendida'),
    (329,N'39050775',N'GATUBELA','20260717','16:30',N'Consulta general',N'Atendida'),
    (330,N'54305327',N'SIMBA','20250925','11:00',N'Revisión por vómitos',N'Atendida'),
    (331,N'61428603',N'IRIS','20260805','11:30',N'Chequeo anual',N'Atendida'),
    (332,N'49691643',N'LOLA','20240115','15:30',N'Control post-operatorio',N'Atendida'),
    (333,N'49691643',N'LOLA','20240805','09:30',N'Revisión por cojera',N'Atendida'),
    (334,N'32697260',N'TITAN','20240730','10:30',N'Limpieza dental',N'Cancelada'),
    (335,N'32697260',N'TITAN','20241021','13:00',N'Limpieza dental',N'Atendida'),
    (336,N'64949806',N'CHISPA','20241005','13:00',N'Evaluación de esterilización',N'Atendida'),
    (337,N'64949806',N'CHISPA','20250610','09:00',N'Chequeo anual',N'Atendida'),
    (338,N'56914201',N'THOR','20241209','12:30',N'Revisión dermatológica',N'Atendida'),
    (339,N'56914201',N'THOR','20261120','09:30',N'Control post-operatorio',N'Pendiente'),
    (340,N'24696128',N'ZEUS','20230828','11:30',N'Revisión por cojera',N'Atendida'),
    (341,N'16372812',N'BOLITA','20250207','09:30',N'Control de peso',N'Atendida'),
    (342,N'16372812',N'BOLITA','20250310','13:30',N'Consulta general',N'Atendida'),
    (343,N'39328441',N'PRINCESA','20260112','14:00',N'Control de peso',N'Atendida'),
    (344,N'39328441',N'PRINCESA','20260810','14:00',N'Baño medicado',N'Atendida'),
    (345,N'56061576',N'PRINCESA','20240912','11:30',N'Limpieza dental',N'Atendida'),
    (346,N'55115571',N'MISHI','20240419','09:00',N'Vacunación',N'Atendida'),
    (347,N'55115571',N'MISHI','20240730','14:30',N'Limpieza dental',N'Atendida'),
    (348,N'38702911',N'THOR','20241207','13:00',N'Chequeo anual',N'Atendida'),
    (349,N'38702911',N'THOR','20261212','16:30',N'Evaluación de esterilización',N'Pendiente'),
    (350,N'17338952',N'TRUENO','20240903','14:30',N'Consulta general',N'Cancelada'),
    (351,N'17338952',N'TRUENO','20241116','09:00',N'Control de peso',N'Atendida'),
    (352,N'16408342',N'MILO','20240806','16:00',N'Revisión dermatológica',N'Cancelada'),
    (353,N'16408342',N'MILO','20250110','09:00',N'Evaluación de esterilización',N'Atendida'),
    (354,N'57003069',N'KIRA','20260212','17:00',N'Revisión dermatológica',N'Atendida'),
    (355,N'57003069',N'KIRA','20260414','16:00',N'Revisión por vómitos',N'Atendida'),
    (356,N'73182519',N'TRUENO','20260126','11:30',N'Revisión por vómitos',N'Atendida'),
    (357,N'38237762',N'NALA','20240812','14:00',N'Revisión por cojera',N'Atendida'),
    (358,N'38237762',N'NALA','20250208','13:00',N'Revisión dermatológica',N'Atendida'),
    (359,N'38237762',N'NALA','20261102','10:00',N'Limpieza dental',N'Pendiente'),
    (360,N'73227182',N'LASSIE','20240219','17:30',N'Baño medicado',N'Atendida'),
    (361,N'73227182',N'LASSIE','20241112','09:00',N'Revisión por cojera',N'Atendida'),
    (362,N'62671174',N'THOR','20260307','09:00',N'Revisión por cojera',N'Atendida'),
    (363,N'62671174',N'THOR','20260831','09:30',N'Control post-operatorio',N'Atendida'),
    (364,N'59803849',N'TIGRE','20250401','11:30',N'Revisión por cojera',N'Cancelada'),
    (365,N'59803849',N'TIGRE','20261030','17:00',N'Chequeo anual',N'Pendiente'),
    (366,N'59996943',N'ROCCO','20230721','14:30',N'Revisión dermatológica',N'Atendida'),
    (367,N'59996943',N'ROCCO','20261118','10:00',N'Vacunación',N'Pendiente'),
    (368,N'77822400',N'NALA','20240327','11:30',N'Limpieza dental',N'Atendida'),
    (369,N'77822400',N'NALA','20241016','11:30',N'Limpieza dental',N'Atendida'),
    (370,N'39677506',N'BRUNO','20260629','16:30',N'Revisión por vómitos',N'Atendida'),
    (371,N'76415788',N'GORDO','20260722','13:00',N'Revisión por cojera',N'Atendida'),
    (372,N'76415788',N'GORDO','20270610','11:30',N'Vacunación',N'Pendiente'),
    (373,N'29789893',N'LASSIE','20241022','16:00',N'Revisión por cojera',N'Atendida'),
    (374,N'30289791',N'NIEVE','20250416','09:00',N'Limpieza dental',N'Atendida'),
    (375,N'79220323',N'KIRA','20250306','12:30',N'Desparasitación',N'Atendida'),
    (376,N'79220323',N'KIRA','20250429','11:30',N'Chequeo anual',N'Atendida'),
    (377,N'47888884',N'BRUNO','20250324','14:30',N'Desparasitación',N'Atendida'),
    (378,N'28948673',N'ROCKY','20241126','12:00',N'Revisión dermatológica',N'Atendida'),
    (379,N'27867033',N'BRUNO','20251224','12:00',N'Chequeo anual',N'Atendida'),
    (380,N'62719537',N'GOKU','20250303','10:30',N'Consulta general',N'Atendida'),
    (381,N'62719537',N'GOKU','20250915','15:30',N'Limpieza dental',N'Atendida'),
    (382,N'22191593',N'DULCE','20240311','14:00',N'Revisión por cojera',N'Atendida'),
    (383,N'22191593',N'DULCE','20240514','13:00',N'Evaluación de esterilización',N'Atendida'),
    (384,N'22191593',N'DULCE','20261217','12:00',N'Revisión por cojera',N'Pendiente'),
    (385,N'37519394',N'TYSON','20250422','15:00',N'Control de peso',N'Atendida'),
    (386,N'40377786',N'LUCKY','20250203','17:30',N'Consulta general',N'Atendida'),
    (387,N'53716605',N'PRINCESA','20241118','12:00',N'Chequeo anual',N'Atendida'),
    (388,N'53716605',N'PRINCESA','20250904','10:30',N'Chequeo anual',N'Atendida'),
    (389,N'36860383',N'LUNA','20260321','17:30',N'Revisión dermatológica',N'Cancelada'),
    (390,N'74637126',N'MOCHA','20231024','14:30',N'Consulta general',N'Atendida'),
    (391,N'26753308',N'IRIS','20231106','14:00',N'Vacunación',N'Cancelada'),
    (392,N'26419779',N'IRIS','20240413','17:00',N'Revisión dermatológica',N'Atendida'),
    (393,N'26419779',N'IRIS','20240725','16:30',N'Baño medicado',N'Cancelada'),
    (394,N'77942639',N'DULCE','20260801','11:30',N'Limpieza dental',N'Cancelada'),
    (395,N'76604777',N'PRINCESA','20241209','15:30',N'Desparasitación',N'Cancelada'),
    (396,N'71417100',N'SIMBA','20260921','09:30',N'Revisión por cojera',N'Cancelada'),
    (397,N'52622436',N'COCO','20260910','14:00',N'Control de peso',N'Atendida'),
    (398,N'52622436',N'COCO','20261130','11:30',N'Vacunación',N'Pendiente'),
    (399,N'52350164',N'FRODO','20230923','15:30',N'Desparasitación',N'Atendida'),
    (400,N'52350164',N'FRODO','20240709','16:30',N'Control de peso',N'Atendida')
) v(seq, dni, mascota, fecha, hora, motivo, estado)
JOIN dbo.CLIENTE c ON c.dni = v.dni
JOIN dbo.MASCOTA m ON m.id_cliente = c.id_cliente AND m.nombre = v.mascota
WHERE NOT EXISTS (SELECT 1 FROM dbo.CITA x WHERE x.id_mascota = m.id_mascota AND x.fecha_cita = v.fecha AND x.hora_cita = v.hora)
ORDER BY v.seq;

INSERT INTO dbo.CITA (fecha_cita, hora_cita, motivo, estado, id_mascota, id_empleado, ESTADO_ACTIVO)
SELECT v.fecha, v.hora, v.motivo, v.estado, m.id_mascota, @id_empleado, 1
FROM (VALUES
    (401,N'28353924',N'FIRULAIS','20260921','17:00',N'Revisión dermatológica',N'Atendida'),
    (402,N'70094344',N'OSO','20261014','13:00',N'Evaluación de esterilización',N'Atendida'),
    (403,N'10569492',N'TITAN','20241108','11:00',N'Control de peso',N'Cancelada'),
    (404,N'46385312',N'OSO','20250113','13:00',N'Chequeo anual',N'Atendida'),
    (405,N'46385312',N'OSO','20251208','15:30',N'Control de peso',N'Atendida'),
    (406,N'42247313',N'JACK','20241204','16:30',N'Revisión por vómitos',N'Cancelada'),
    (407,N'76591779',N'TOM','20250219','09:00',N'Revisión dermatológica',N'Atendida'),
    (408,N'76591779',N'TOM','20250507','11:30',N'Control de peso',N'Atendida'),
    (409,N'76256491',N'GORDO','20250707','13:00',N'Revisión por vómitos',N'Atendida'),
    (410,N'76256491',N'GORDO','20260706','11:00',N'Vacunación',N'Atendida'),
    (411,N'59426425',N'DULCE','20241228','11:30',N'Baño medicado',N'Atendida'),
    (412,N'59426425',N'DULCE','20250920','10:30',N'Chequeo anual',N'Cancelada'),
    (413,N'74612560',N'PRINCESA','20240715','11:30',N'Desparasitación',N'Atendida'),
    (414,N'74612560',N'PRINCESA','20250121','12:30',N'Desparasitación',N'Atendida'),
    (415,N'74612560',N'PRINCESA','20261020','17:00',N'Limpieza dental',N'Pendiente'),
    (416,N'75671636',N'BETO','20260120','17:00',N'Revisión por vómitos',N'Atendida'),
    (417,N'75671636',N'BETO','20260406','12:00',N'Control de peso',N'Cancelada'),
    (418,N'75239262',N'ZEUS','20250522','14:00',N'Revisión dermatológica',N'Atendida'),
    (419,N'59028881',N'MILO','20241105','15:00',N'Evaluación de esterilización',N'Atendida'),
    (420,N'59028881',N'MILO','20261103','11:00',N'Revisión dermatológica',N'Pendiente'),
    (421,N'63300462',N'THOR','20230529','16:30',N'Limpieza dental',N'Atendida'),
    (422,N'63300462',N'THOR','20230727','11:00',N'Revisión por cojera',N'Atendida'),
    (423,N'31699451',N'SAMY','20260312','17:30',N'Consulta general',N'Atendida'),
    (424,N'17226044',N'PANCHO','20251202','10:30',N'Limpieza dental',N'Atendida'),
    (425,N'17226044',N'PANCHO','20261020','15:00',N'Revisión por vómitos',N'Pendiente'),
    (426,N'36574152',N'ZEUS','20260422','15:00',N'Desparasitación',N'Atendida'),
    (427,N'75647094',N'NALA','20250702','09:00',N'Revisión por vómitos',N'Atendida'),
    (428,N'35656927',N'ANGEL','20240626','12:00',N'Control de peso',N'Atendida'),
    (429,N'35656927',N'ANGEL','20261215','09:00',N'Evaluación de esterilización',N'Pendiente'),
    (430,N'70137831',N'IRIS','20240716','15:30',N'Limpieza dental',N'Atendida'),
    (431,N'59831833',N'CHOCOLATE','20251227','09:00',N'Consulta general',N'Atendida'),
    (432,N'51117751',N'LOLA','20250328','09:00',N'Baño medicado',N'Atendida'),
    (433,N'70903475',N'DAISY','20241231','09:30',N'Chequeo anual',N'Atendida'),
    (434,N'55566012',N'ANGEL','20250908','13:00',N'Revisión dermatológica',N'Atendida'),
    (435,N'55566012',N'ANGEL','20260202','15:30',N'Revisión dermatológica',N'Atendida'),
    (436,N'29673082',N'LOLA','20241031','09:00',N'Limpieza dental',N'Cancelada'),
    (437,N'29673082',N'LOLA','20251105','09:00',N'Control post-operatorio',N'Atendida'),
    (438,N'53691734',N'FRODO','20250519','14:30',N'Desparasitación',N'Atendida'),
    (439,N'53691734',N'FRODO','20260618','14:30',N'Limpieza dental',N'Atendida'),
    (440,N'77035821',N'LASSIE','20251011','14:30',N'Evaluación de esterilización',N'Atendida'),
    (441,N'70630649',N'LUCKY','20250106','11:30',N'Limpieza dental',N'Atendida'),
    (442,N'70630649',N'LUCKY','20260108','09:30',N'Chequeo anual',N'Atendida'),
    (443,N'70630649',N'LUCKY','20261024','14:30',N'Chequeo anual',N'Pendiente'),
    (444,N'54688209',N'LOLA','20240417','16:00',N'Revisión dermatológica',N'Atendida'),
    (445,N'54688209',N'LOLA','20250418','13:00',N'Revisión dermatológica',N'Atendida'),
    (446,N'18930994',N'IRIS','20250429','16:00',N'Revisión por vómitos',N'Atendida'),
    (447,N'18930994',N'IRIS','20250825','14:30',N'Control de peso',N'Atendida'),
    (448,N'25965976',N'PELUCHE','20260728','10:30',N'Control post-operatorio',N'Atendida'),
    (449,N'61766196',N'SALEM','20260321','09:30',N'Control post-operatorio',N'Atendida'),
    (450,N'13086150',N'OLIVER','20240729','12:00',N'Evaluación de esterilización',N'Atendida'),
    (451,N'13086150',N'OLIVER','20250823','15:00',N'Control de peso',N'Atendida'),
    (452,N'13086150',N'OLIVER','20261104','12:00',N'Evaluación de esterilización',N'Pendiente'),
    (453,N'51949964',N'DAISY','20230919','09:00',N'Limpieza dental',N'Atendida'),
    (454,N'51949964',N'DAISY','20240611','15:00',N'Vacunación',N'Atendida'),
    (455,N'23645765',N'SALEM','20250804','14:30',N'Control de peso',N'Atendida'),
    (456,N'23645765',N'SALEM','20260619','11:30',N'Control de peso',N'Cancelada'),
    (457,N'23645765',N'SALEM','20261109','10:30',N'Control post-operatorio',N'Pendiente'),
    (458,N'25375175',N'ZEUS','20240829','13:30',N'Baño medicado',N'Atendida'),
    (459,N'27071065',N'MAYA','20250430','09:30',N'Control de peso',N'Atendida'),
    (460,N'27071065',N'MAYA','20261219','10:00',N'Evaluación de esterilización',N'Pendiente'),
    (461,N'21644472',N'TOBY','20241216','10:30',N'Limpieza dental',N'Atendida'),
    (462,N'21644472',N'TOBY','20261118','09:00',N'Evaluación de esterilización',N'Pendiente'),
    (463,N'40181119',N'SIMBA','20260527','13:00',N'Control de peso',N'Atendida'),
    (464,N'74474444',N'CLEO','20230515','13:00',N'Vacunación',N'Cancelada'),
    (465,N'74474444',N'CLEO','20230911','10:30',N'Evaluación de esterilización',N'Atendida'),
    (466,N'62343309',N'KOBE','20251103','12:30',N'Revisión por vómitos',N'Atendida'),
    (467,N'62343309',N'KOBE','20260330','17:00',N'Vacunación',N'Cancelada'),
    (468,N'17778326',N'MANCHAS','20260523','16:00',N'Revisión por vómitos',N'Atendida'),
    (469,N'42931532',N'BETO','20241002','16:30',N'Desparasitación',N'Atendida'),
    (470,N'25706155',N'DULCE','20240909','14:00',N'Evaluación de esterilización',N'Atendida'),
    (471,N'51377678',N'FIRULAIS','20260109','09:30',N'Vacunación',N'Atendida'),
    (472,N'51377678',N'FIRULAIS','20260721','17:30',N'Desparasitación',N'Atendida'),
    (473,N'15743784',N'JACK','20250113','14:30',N'Control post-operatorio',N'Atendida'),
    (474,N'15017483',N'OLIVER','20251103','14:30',N'Baño medicado',N'Cancelada'),
    (475,N'15017483',N'OLIVER','20260416','12:30',N'Revisión por cojera',N'Atendida'),
    (476,N'11840307',N'LASSIE','20240813','15:30',N'Revisión por cojera',N'Atendida'),
    (477,N'32455567',N'SALEM','20240312','17:30',N'Control de peso',N'Atendida'),
    (478,N'49855592',N'MAYA','20240527','17:00',N'Control post-operatorio',N'Atendida'),
    (479,N'20118060',N'NALA','20231128','09:00',N'Vacunación',N'Atendida'),
    (480,N'20118060',N'NALA','20261212','17:00',N'Control post-operatorio',N'Pendiente'),
    (481,N'33784571',N'RUFO','20240712','15:00',N'Control de peso',N'Atendida'),
    (482,N'32807658',N'NEGRO','20250308','10:30',N'Chequeo anual',N'Atendida'),
    (483,N'32807658',N'NEGRO','20251223','14:00',N'Desparasitación',N'Atendida'),
    (484,N'11616589',N'IRIS','20260112','14:00',N'Consulta general',N'Atendida'),
    (485,N'49009324',N'MOMO','20240910','12:30',N'Baño medicado',N'Cancelada'),
    (486,N'42557428',N'GORDO','20241014','13:30',N'Evaluación de esterilización',N'Atendida'),
    (487,N'37577441',N'CANELA','20241108','16:30',N'Limpieza dental',N'Atendida'),
    (488,N'29570628',N'MAX','20231007','11:00',N'Revisión dermatológica',N'Atendida'),
    (489,N'29570628',N'MAX','20241023','09:00',N'Vacunación',N'Cancelada'),
    (490,N'43910362',N'PANTERA','20241108','16:30',N'Consulta general',N'Atendida'),
    (491,N'43910362',N'PANTERA','20261103','15:00',N'Chequeo anual',N'Pendiente'),
    (492,N'69453138',N'OSO','20250829','16:30',N'Baño medicado',N'Cancelada'),
    (493,N'56377779',N'LOLA','20251215','10:00',N'Chequeo anual',N'Atendida'),
    (494,N'56377779',N'LOLA','20260611','10:30',N'Baño medicado',N'Atendida'),
    (495,N'26823875',N'DAISY','20241107','14:30',N'Evaluación de esterilización',N'Atendida'),
    (496,N'26823875',N'DAISY','20250102','09:00',N'Control de peso',N'Atendida'),
    (497,N'52890766',N'BOLITA','20231216','09:30',N'Revisión por vómitos',N'Atendida'),
    (498,N'67650328',N'PELUCHE','20230614','17:30',N'Revisión dermatológica',N'Atendida'),
    (499,N'74264265',N'ROCKY','20240420','12:00',N'Baño medicado',N'Atendida'),
    (500,N'71620003',N'GARFIELD','20230619','12:30',N'Evaluación de esterilización',N'Atendida'),
    (501,N'48236792',N'MIA','20240726','16:00',N'Limpieza dental',N'Atendida'),
    (502,N'16513835',N'NUBE','20240518','17:30',N'Revisión por vómitos',N'Atendida'),
    (503,N'16513835',N'NUBE','20240917','16:00',N'Control de peso',N'Atendida'),
    (504,N'34736313',N'PELUCHE','20230720','15:30',N'Consulta general',N'Atendida'),
    (505,N'64751698',N'CHOCOLATE','20250318','16:00',N'Evaluación de esterilización',N'Atendida'),
    (506,N'64751698',N'CHOCOLATE','20261205','10:00',N'Limpieza dental',N'Pendiente'),
    (507,N'63877899',N'MISHI','20260601','16:30',N'Revisión por vómitos',N'Atendida'),
    (508,N'63877899',N'MISHI','20260720','09:00',N'Evaluación de esterilización',N'Atendida'),
    (509,N'63877899',N'MISHI','20261127','10:00',N'Baño medicado',N'Pendiente'),
    (510,N'64104769',N'DAISY','20260408','09:30',N'Revisión por cojera',N'Atendida'),
    (511,N'12271098',N'BOLITA','20260713','11:00',N'Vacunación',N'Cancelada'),
    (512,N'12271098',N'BOLITA','20261125','11:30',N'Consulta general',N'Pendiente'),
    (513,N'19985300',N'TYSON','20231016','13:30',N'Revisión por vómitos',N'Atendida'),
    (514,N'50100916',N'NEGRO','20241231','15:00',N'Limpieza dental',N'Cancelada'),
    (515,N'10713936',N'NUBE','20260713','16:00',N'Evaluación de esterilización',N'Atendida'),
    (516,N'71323251',N'TRUENO','20260601','15:00',N'Evaluación de esterilización',N'Atendida'),
    (517,N'67429105',N'KIRA','20241230','15:00',N'Revisión dermatológica',N'Atendida'),
    (518,N'67429105',N'KIRA','20251118','15:00',N'Revisión dermatológica',N'Atendida'),
    (519,N'20526105',N'FIRULAIS','20230721','15:30',N'Desparasitación',N'Atendida'),
    (520,N'74137343',N'TOM','20250113','17:00',N'Evaluación de esterilización',N'Atendida'),
    (521,N'31150771',N'CANELA','20231223','17:30',N'Consulta general',N'Atendida'),
    (522,N'31150771',N'CANELA','20240221','13:00',N'Limpieza dental',N'Atendida'),
    (523,N'69110737',N'MICHI','20240401','11:30',N'Vacunación',N'Atendida'),
    (524,N'69110737',N'MICHI','20241230','09:30',N'Vacunación',N'Atendida'),
    (525,N'63051978',N'FRODO','20260309','17:00',N'Limpieza dental',N'Atendida'),
    (526,N'63051978',N'FRODO','20260707','15:30',N'Vacunación',N'Atendida'),
    (527,N'52488169',N'ZEUS','20241109','11:00',N'Revisión por cojera',N'Atendida'),
    (528,N'53922301',N'LUNA','20251013','11:30',N'Desparasitación',N'Atendida'),
    (529,N'53922301',N'LUNA','20260318','15:30',N'Control post-operatorio',N'Atendida'),
    (530,N'53078110',N'PEPE','20240819','09:00',N'Revisión dermatológica',N'Atendida'),
    (531,N'41349952',N'PEPE','20250722','15:30',N'Revisión por vómitos',N'Cancelada'),
    (532,N'10640688',N'CHOCOLATE','20241015','13:30',N'Limpieza dental',N'Atendida'),
    (533,N'10640688',N'CHOCOLATE','20241114','16:00',N'Vacunación',N'Atendida'),
    (534,N'48317019',N'PRINCESA','20260302','09:00',N'Evaluación de esterilización',N'Atendida'),
    (535,N'64169098',N'NALA','20260309','10:00',N'Control post-operatorio',N'Atendida'),
    (536,N'55719212',N'PANCHO','20250519','14:00',N'Chequeo anual',N'Atendida'),
    (537,N'70414162',N'CANELA','20241026','14:00',N'Vacunación',N'Atendida'),
    (538,N'70414162',N'CANELA','20241216','17:00',N'Control post-operatorio',N'Atendida'),
    (539,N'54109713',N'NEGRO','20250203','11:30',N'Revisión por cojera',N'Cancelada'),
    (540,N'54109713',N'NEGRO','20251103','09:30',N'Control post-operatorio',N'Atendida'),
    (541,N'52525332',N'BOBBY','20251208','10:30',N'Vacunación',N'Cancelada'),
    (542,N'52525332',N'BOBBY','20261204','17:00',N'Chequeo anual',N'Pendiente'),
    (543,N'51725842',N'THOR','20240316','17:30',N'Limpieza dental',N'Atendida'),
    (544,N'51725842',N'THOR','20250117','12:30',N'Chequeo anual',N'Atendida'),
    (545,N'15431999',N'MOMO','20260427','09:30',N'Desparasitación',N'Atendida'),
    (546,N'56906428',N'ROCCO','20230711','17:00',N'Desparasitación',N'Cancelada'),
    (547,N'56906428',N'ROCCO','20231225','13:00',N'Limpieza dental',N'Atendida'),
    (548,N'37110833',N'KOBE','20240822','16:00',N'Control de peso',N'Atendida'),
    (549,N'37110833',N'KOBE','20250624','09:30',N'Baño medicado',N'Atendida'),
    (550,N'55742771',N'NALA','20260804','16:00',N'Limpieza dental',N'Cancelada'),
    (551,N'55742771',N'NALA','20261207','11:00',N'Evaluación de esterilización',N'Pendiente'),
    (552,N'11052950',N'TOBY','20251103','10:30',N'Revisión por vómitos',N'Atendida'),
    (553,N'73855347',N'TRUENO','20250918','10:00',N'Control de peso',N'Atendida'),
    (554,N'73855347',N'TRUENO','20260704','09:00',N'Baño medicado',N'Atendida'),
    (555,N'73855347',N'TRUENO','20261212','15:00',N'Baño medicado',N'Pendiente'),
    (556,N'42126567',N'PRINCESA','20240503','09:00',N'Control post-operatorio',N'Atendida'),
    (557,N'42126567',N'PRINCESA','20240821','14:00',N'Chequeo anual',N'Atendida'),
    (558,N'19995218',N'PELUSA','20241219','09:00',N'Control post-operatorio',N'Atendida'),
    (559,N'59006174',N'ANGEL','20231103','15:30',N'Baño medicado',N'Atendida'),
    (560,N'35548111',N'NALA','20260602','12:30',N'Desparasitación',N'Atendida'),
    (561,N'67299054',N'KIRA','20230815','16:30',N'Desparasitación',N'Atendida'),
    (562,N'67299054',N'KIRA','20240527','15:30',N'Consulta general',N'Atendida'),
    (563,N'25377814',N'OSO','20240604','17:00',N'Control post-operatorio',N'Atendida'),
    (564,N'25377814',N'OSO','20240726','12:00',N'Desparasitación',N'Atendida'),
    (565,N'60470506',N'TOÑO','20240427','15:30',N'Revisión por cojera',N'Atendida'),
    (566,N'30736673',N'ZEUS','20240506','15:00',N'Revisión dermatológica',N'Atendida'),
    (567,N'30736673',N'ZEUS','20240919','09:00',N'Revisión por vómitos',N'Atendida'),
    (568,N'18745124',N'OSO','20260304','16:30',N'Control de peso',N'Atendida'),
    (569,N'18745124',N'OSO','20260518','09:00',N'Vacunación',N'Atendida'),
    (570,N'29971964',N'SAMY','20240116','09:00',N'Chequeo anual',N'Atendida'),
    (571,N'59569048',N'ANGEL','20240617','13:30',N'Desparasitación',N'Atendida'),
    (572,N'59569048',N'ANGEL','20261116','13:30',N'Revisión por vómitos',N'Pendiente'),
    (573,N'33968729',N'CANELA','20241113','09:00',N'Chequeo anual',N'Atendida'),
    (574,N'58051201',N'MAX','20250304','11:30',N'Revisión por cojera',N'Atendida'),
    (575,N'22556713',N'THOR','20250522','11:30',N'Revisión dermatológica',N'Cancelada'),
    (576,N'22556713',N'THOR','20250623','09:30',N'Control de peso',N'Atendida'),
    (577,N'10013105',N'GARFIELD','20240219','16:30',N'Chequeo anual',N'Cancelada'),
    (578,N'28492007',N'RUFO','20250508','12:30',N'Revisión por vómitos',N'Atendida'),
    (579,N'28492007',N'RUFO','20251013','15:30',N'Desparasitación',N'Atendida'),
    (580,N'64337456',N'PELUSA','20250610','17:00',N'Evaluación de esterilización',N'Cancelada'),
    (581,N'60029895',N'KOBE','20240730','09:00',N'Control de peso',N'Atendida'),
    (582,N'35678389',N'MANCHAS','20260324','09:00',N'Control post-operatorio',N'Atendida'),
    (583,N'35678389',N'MANCHAS','20260817','11:30',N'Consulta general',N'Atendida'),
    (584,N'50302233',N'TOBY','20241209','13:00',N'Vacunación',N'Atendida'),
    (585,N'50302233',N'TOBY','20250804','12:30',N'Chequeo anual',N'Atendida'),
    (586,N'55925799',N'PANCHO','20231116','15:00',N'Control de peso',N'Atendida'),
    (587,N'75686213',N'TOM','20231125','16:30',N'Revisión por cojera',N'Cancelada'),
    (588,N'18398391',N'KOBE','20250703','14:30',N'Vacunación',N'Atendida'),
    (589,N'18398391',N'KOBE','20260605','16:00',N'Baño medicado',N'Atendida'),
    (590,N'17909041',N'FIRULAIS','20230708','11:00',N'Limpieza dental',N'Atendida'),
    (591,N'42436203',N'ROCKY','20261012','16:00',N'Revisión por vómitos',N'Atendida'),
    (592,N'53476237',N'PELUSA','20260303','15:30',N'Limpieza dental',N'Atendida'),
    (593,N'47821988',N'PANCHO','20260410','12:00',N'Vacunación',N'Cancelada'),
    (594,N'47821988',N'PANCHO','20261128','17:00',N'Revisión dermatológica',N'Pendiente'),
    (595,N'79413472',N'JACK','20251126','10:30',N'Chequeo anual',N'Atendida'),
    (596,N'79413472',N'JACK','20260728','11:00',N'Revisión por cojera',N'Atendida'),
    (597,N'46689266',N'COCO','20260714','16:30',N'Baño medicado',N'Atendida'),
    (598,N'19251762',N'COCO','20250714','14:30',N'Chequeo anual',N'Atendida'),
    (599,N'63346839',N'ROCCO','20250505','10:00',N'Desparasitación',N'Atendida'),
    (600,N'63346839',N'ROCCO','20260404','13:00',N'Revisión por vómitos',N'Atendida'),
    (601,N'14396892',N'JACK','20250113','12:30',N'Control post-operatorio',N'Atendida'),
    (602,N'31252930',N'GATUBELA','20241213','09:30',N'Revisión por cojera',N'Atendida'),
    (603,N'59717244',N'OSO','20260613','10:00',N'Control de peso',N'Atendida'),
    (604,N'59717244',N'OSO','20270622','17:00',N'Baño medicado',N'Pendiente'),
    (605,N'17586899',N'CHISPA','20241025','09:30',N'Baño medicado',N'Cancelada'),
    (606,N'17586899',N'CHISPA','20261105','09:30',N'Control de peso',N'Pendiente'),
    (607,N'63711330',N'SIMBA','20260105','09:00',N'Control post-operatorio',N'Atendida'),
    (608,N'33460112',N'LUCKY','20260704','11:30',N'Baño medicado',N'Atendida'),
    (609,N'24858882',N'GOKU','20260414','12:30',N'Control de peso',N'Atendida'),
    (610,N'24858882',N'GOKU','20270405','12:00',N'Desparasitación',N'Pendiente'),
    (611,N'24858882',N'GOKU','20261114','14:30',N'Limpieza dental',N'Pendiente'),
    (612,N'21528464',N'NIEVE','20240124','09:00',N'Desparasitación',N'Atendida'),
    (613,N'72306053',N'SIMBA','20230809','11:00',N'Revisión dermatológica',N'Atendida'),
    (614,N'72306053',N'SIMBA','20240306','11:30',N'Chequeo anual',N'Atendida'),
    (615,N'29368390',N'FRODO','20240314','09:00',N'Consulta general',N'Atendida'),
    (616,N'66492993',N'CANELA','20240527','16:30',N'Revisión por cojera',N'Atendida'),
    (617,N'35790401',N'KOBE','20260710','17:00',N'Revisión por cojera',N'Atendida'),
    (618,N'21613431',N'ZEUS','20250214','16:00',N'Revisión por vómitos',N'Atendida'),
    (619,N'23524913',N'JACK','20261022','14:30',N'Control post-operatorio',N'Pendiente'),
    (620,N'23524913',N'JACK','20270909','17:30',N'Desparasitación',N'Pendiente'),
    (621,N'40672459',N'IRIS','20250620','15:30',N'Chequeo anual',N'Atendida'),
    (622,N'53971722',N'PEPE','20240504','12:30',N'Vacunación',N'Atendida'),
    (623,N'34031162',N'KOBE','20230828','13:00',N'Baño medicado',N'Atendida'),
    (624,N'30287293',N'SIMBA','20240919','09:30',N'Chequeo anual',N'Atendida'),
    (625,N'78149928',N'DAISY','20241019','16:30',N'Desparasitación',N'Atendida'),
    (626,N'24971231',N'GORDO','20240917','13:00',N'Baño medicado',N'Atendida'),
    (627,N'53512462',N'TOMASA','20251204','10:30',N'Limpieza dental',N'Atendida'),
    (628,N'53512462',N'TOMASA','20260319','14:00',N'Desparasitación',N'Atendida'),
    (629,N'53512462',N'TOMASA','20261121','10:30',N'Consulta general',N'Pendiente'),
    (630,N'43230996',N'PELUSA','20261017','14:30',N'Consulta general',N'Atendida'),
    (631,N'58800955',N'CANELA','20260220','09:30',N'Revisión por cojera',N'Atendida'),
    (632,N'63079326',N'FIRULAIS','20231218','10:30',N'Control de peso',N'Atendida'),
    (633,N'63079326',N'FIRULAIS','20250108','15:30',N'Baño medicado',N'Atendida'),
    (634,N'38741904',N'NUBE','20231103','14:00',N'Control post-operatorio',N'Atendida'),
    (635,N'38741904',N'NUBE','20240528','17:00',N'Control de peso',N'Atendida'),
    (636,N'32876946',N'LASSIE','20241111','13:30',N'Baño medicado',N'Cancelada'),
    (637,N'32876946',N'LASSIE','20250808','14:30',N'Desparasitación',N'Atendida'),
    (638,N'32876946',N'LASSIE','20261113','14:30',N'Chequeo anual',N'Pendiente'),
    (639,N'19556608',N'KOBE','20231025','12:30',N'Consulta general',N'Atendida'),
    (640,N'71603205',N'FIONA','20260813','14:30',N'Revisión por vómitos',N'Atendida'),
    (641,N'71603205',N'FIONA','20270524','17:30',N'Chequeo anual',N'Pendiente'),
    (642,N'19668758',N'TITAN','20230506','17:30',N'Revisión por cojera',N'Atendida'),
    (643,N'21429600',N'FRODO','20250528','15:00',N'Control post-operatorio',N'Atendida'),
    (644,N'21429600',N'FRODO','20250801','13:30',N'Chequeo anual',N'Cancelada'),
    (645,N'51674644',N'RUFO','20241014','12:30',N'Chequeo anual',N'Atendida'),
    (646,N'25449326',N'SAMY','20250111','09:30',N'Chequeo anual',N'Atendida'),
    (647,N'53168610',N'IRIS','20230914','14:00',N'Desparasitación',N'Atendida'),
    (648,N'53879689',N'THOR','20250520','14:30',N'Chequeo anual',N'Atendida'),
    (649,N'53879689',N'THOR','20250923','14:30',N'Limpieza dental',N'Atendida'),
    (650,N'74112721',N'MINA','20251024','13:30',N'Evaluación de esterilización',N'Atendida'),
    (651,N'72010722',N'FRODO','20231101','10:00',N'Chequeo anual',N'Atendida'),
    (652,N'74835983',N'MANCHAS','20250625','15:30',N'Baño medicado',N'Atendida'),
    (653,N'59301459',N'PELUSA','20250327','17:00',N'Control post-operatorio',N'Atendida'),
    (654,N'37735621',N'TRUENO','20231120','12:30',N'Revisión por cojera',N'Atendida'),
    (655,N'37735621',N'TRUENO','20241207','15:00',N'Evaluación de esterilización',N'Atendida'),
    (656,N'46559169',N'TOÑO','20250312','17:30',N'Vacunación',N'Atendida'),
    (657,N'46559169',N'TOÑO','20261219','10:30',N'Vacunación',N'Pendiente'),
    (658,N'52228506',N'SIMBA','20250114','15:30',N'Consulta general',N'Atendida'),
    (659,N'50192178',N'BETO','20240522','15:00',N'Evaluación de esterilización',N'Atendida'),
    (660,N'50192178',N'BETO','20250220','12:30',N'Baño medicado',N'Atendida'),
    (661,N'22231444',N'CHOCOLATE','20240228','14:30',N'Revisión por cojera',N'Atendida'),
    (662,N'44693578',N'TRUENO','20241104','12:00',N'Consulta general',N'Atendida'),
    (663,N'44693578',N'TRUENO','20261027','15:30',N'Consulta general',N'Pendiente'),
    (664,N'46526469',N'TOBY','20231004','13:00',N'Desparasitación',N'Cancelada'),
    (665,N'51273753',N'ROCCO','20230814','12:00',N'Revisión por vómitos',N'Atendida'),
    (666,N'46544333',N'BOLITA','20230705','17:00',N'Control post-operatorio',N'Atendida'),
    (667,N'46544333',N'BOLITA','20261026','16:00',N'Limpieza dental',N'Pendiente'),
    (668,N'24269926',N'FIONA','20261019','14:30',N'Vacunación',N'Pendiente'),
    (669,N'56826742',N'FRODO','20250616','12:30',N'Control post-operatorio',N'Cancelada'),
    (670,N'31837408',N'ROCKY','20240116','10:00',N'Control post-operatorio',N'Atendida'),
    (671,N'10144493',N'MANCHAS','20260901','15:00',N'Limpieza dental',N'Atendida'),
    (672,N'69046078',N'RUFO','20241217','16:30',N'Limpieza dental',N'Atendida'),
    (673,N'73661760',N'HACHI','20250818','12:00',N'Limpieza dental',N'Atendida'),
    (674,N'73661760',N'HACHI','20251201','13:00',N'Chequeo anual',N'Atendida'),
    (675,N'75589105',N'TYSON','20261031','15:30',N'Vacunación',N'Pendiente'),
    (676,N'59538076',N'OSO','20250222','16:30',N'Revisión por cojera',N'Atendida'),
    (677,N'62809781',N'BOLITA','20260623','15:30',N'Revisión por cojera',N'Cancelada'),
    (678,N'61857513',N'THOR','20230805','12:00',N'Control post-operatorio',N'Atendida'),
    (679,N'59766259',N'JACK','20260514','16:00',N'Vacunación',N'Atendida'),
    (680,N'64151263',N'KOBE','20250703','13:00',N'Consulta general',N'Atendida'),
    (681,N'34182770',N'ROCKY','20250505','14:00',N'Desparasitación',N'Atendida'),
    (682,N'50579707',N'NALA','20230907','14:00',N'Desparasitación',N'Cancelada'),
    (683,N'34575486',N'NEGRO','20251118','14:00',N'Revisión dermatológica',N'Atendida'),
    (684,N'34575486',N'NEGRO','20261121','13:30',N'Control de peso',N'Pendiente'),
    (685,N'58339728',N'CANELA','20240625','15:30',N'Control de peso',N'Atendida'),
    (686,N'43322872',N'MAX','20240506','16:00',N'Control de peso',N'Atendida'),
    (687,N'32853815',N'KIRA','20260713','13:00',N'Limpieza dental',N'Cancelada'),
    (688,N'32853815',N'KIRA','20270809','09:00',N'Evaluación de esterilización',N'Pendiente'),
    (689,N'32853815',N'KIRA','20261107','14:00',N'Vacunación',N'Pendiente'),
    (690,N'56203698',N'ANGEL','20260313','10:00',N'Vacunación',N'Atendida'),
    (691,N'56203698',N'ANGEL','20270119','09:30',N'Vacunación',N'Pendiente'),
    (692,N'30604007',N'JACK','20240222','13:00',N'Chequeo anual',N'Atendida'),
    (693,N'78008395',N'MOMO','20250527','10:00',N'Baño medicado',N'Atendida'),
    (694,N'15580650',N'LOLA','20251031','13:30',N'Control post-operatorio',N'Atendida'),
    (695,N'64671867',N'LUNA','20260415','12:00',N'Desparasitación',N'Atendida'),
    (696,N'43626582',N'CANELA','20241203','17:00',N'Revisión por cojera',N'Atendida'),
    (697,N'43626582',N'CANELA','20250822','17:00',N'Chequeo anual',N'Atendida'),
    (698,N'52099908',N'LUCKY','20260213','11:00',N'Desparasitación',N'Atendida'),
    (699,N'51517847',N'FIONA','20251206','12:00',N'Baño medicado',N'Atendida'),
    (700,N'45264687',N'MOMO','20241224','14:30',N'Desparasitación',N'Atendida'),
    (701,N'25183208',N'LUNA','20251227','11:30',N'Chequeo anual',N'Atendida'),
    (702,N'25183208',N'LUNA','20260728','14:00',N'Vacunación',N'Cancelada'),
    (703,N'59719658',N'ZEUS','20251029','16:00',N'Consulta general',N'Atendida'),
    (704,N'59719658',N'ZEUS','20260105','16:00',N'Revisión por cojera',N'Atendida'),
    (705,N'38518046',N'LASSIE','20260312','10:00',N'Baño medicado',N'Atendida'),
    (706,N'20902456',N'IRIS','20241002','11:30',N'Revisión por cojera',N'Atendida'),
    (707,N'19961100',N'LASSIE','20240423','09:30',N'Vacunación',N'Atendida'),
    (708,N'19961100',N'LASSIE','20241104','13:30',N'Control post-operatorio',N'Atendida'),
    (709,N'26734012',N'COCO','20260506','14:00',N'Chequeo anual',N'Atendida'),
    (710,N'49265947',N'LASSIE','20260404','13:00',N'Revisión por cojera',N'Atendida'),
    (711,N'49265947',N'LASSIE','20260617','15:30',N'Control de peso',N'Atendida'),
    (712,N'13500013',N'FELIX','20230918','13:30',N'Vacunación',N'Atendida'),
    (713,N'13500013',N'FELIX','20231225','09:30',N'Evaluación de esterilización',N'Atendida'),
    (714,N'67532430',N'RUFO','20250905','15:00',N'Limpieza dental',N'Atendida'),
    (715,N'67532430',N'RUFO','20260820','14:00',N'Consulta general',N'Atendida'),
    (716,N'75720759',N'RUFO','20260609','09:30',N'Chequeo anual',N'Atendida'),
    (717,N'75720759',N'RUFO','20260821','11:30',N'Desparasitación',N'Atendida'),
    (718,N'26666465',N'ROCKY','20260121','12:00',N'Vacunación',N'Atendida'),
    (719,N'15637712',N'ROCKY','20250612','13:30',N'Control post-operatorio',N'Atendida'),
    (720,N'15637712',N'ROCKY','20251119','12:30',N'Revisión por cojera',N'Atendida'),
    (721,N'72899329',N'GOKU','20260414','13:30',N'Revisión por cojera',N'Cancelada'),
    (722,N'22206641',N'SIMBA','20241009','17:30',N'Chequeo anual',N'Atendida'),
    (723,N'22206641',N'SIMBA','20261212','09:30',N'Revisión por vómitos',N'Pendiente'),
    (724,N'11671445',N'CHISPA','20251103','10:30',N'Control de peso',N'Atendida'),
    (725,N'43608951',N'ZEUS','20250524','11:30',N'Control post-operatorio',N'Atendida'),
    (726,N'46984541',N'BOLITA','20241125','09:30',N'Chequeo anual',N'Atendida'),
    (727,N'61296075',N'DAISY','20240307','12:30',N'Revisión dermatológica',N'Atendida'),
    (728,N'13559973',N'FIONA','20231120','11:30',N'Revisión por cojera',N'Cancelada'),
    (729,N'13559973',N'FIONA','20240330','10:30',N'Vacunación',N'Atendida'),
    (730,N'54618219',N'PRINCESA','20260430','13:00',N'Revisión dermatológica',N'Atendida'),
    (731,N'54618219',N'PRINCESA','20270412','09:00',N'Evaluación de esterilización',N'Pendiente'),
    (732,N'38807064',N'PELUCHE','20240822','10:30',N'Baño medicado',N'Atendida'),
    (733,N'38807064',N'PELUCHE','20250131','17:00',N'Evaluación de esterilización',N'Atendida'),
    (734,N'32743777',N'ROCCO','20250322','16:30',N'Vacunación',N'Atendida'),
    (735,N'13537040',N'NALA','20240326','14:00',N'Baño medicado',N'Atendida'),
    (736,N'69787068',N'JACK','20260420','11:30',N'Vacunación',N'Atendida'),
    (737,N'69787068',N'JACK','20260814','09:00',N'Control post-operatorio',N'Atendida'),
    (738,N'62016082',N'CANELA','20250719','14:30',N'Vacunación',N'Atendida'),
    (739,N'62016082',N'CANELA','20251020','09:00',N'Revisión por vómitos',N'Atendida'),
    (740,N'54809394',N'LUCKY','20240601','09:00',N'Baño medicado',N'Atendida'),
    (741,N'54809394',N'LUCKY','20240701','15:00',N'Revisión por vómitos',N'Atendida'),
    (742,N'49716647',N'OSO','20250421','14:30',N'Revisión por vómitos',N'Atendida'),
    (743,N'76236844',N'GORDO','20230522','09:30',N'Revisión por vómitos',N'Atendida'),
    (744,N'76236844',N'GORDO','20230918','12:30',N'Limpieza dental',N'Atendida'),
    (745,N'41371634',N'MINNIE','20231212','11:00',N'Control post-operatorio',N'Atendida'),
    (746,N'41462776',N'ROCKY','20260127','14:30',N'Desparasitación',N'Atendida'),
    (747,N'63249717',N'BOLITA','20250319','16:00',N'Desparasitación',N'Atendida'),
    (748,N'63249717',N'BOLITA','20251128','14:30',N'Chequeo anual',N'Atendida'),
    (749,N'17301708',N'CHOCOLATE','20250127','17:30',N'Baño medicado',N'Cancelada'),
    (750,N'78151815',N'MANCHAS','20250809','17:30',N'Revisión dermatológica',N'Atendida'),
    (751,N'78151815',N'MANCHAS','20260317','13:30',N'Chequeo anual',N'Atendida'),
    (752,N'41519908',N'COCO','20231223','10:00',N'Consulta general',N'Atendida'),
    (753,N'14532760',N'MAX','20250711','12:00',N'Control de peso',N'Atendida'),
    (754,N'14532760',N'MAX','20260804','16:00',N'Vacunación',N'Atendida'),
    (755,N'25807541',N'CANELA','20230913','15:30',N'Revisión dermatológica',N'Atendida'),
    (756,N'21272134',N'CLEO','20240923','12:30',N'Revisión por cojera',N'Atendida'),
    (757,N'21272134',N'CLEO','20251010','14:00',N'Vacunación',N'Cancelada'),
    (758,N'27773440',N'PEPE','20231002','15:30',N'Revisión dermatológica',N'Cancelada'),
    (759,N'27773440',N'PEPE','20241101','15:30',N'Vacunación',N'Atendida'),
    (760,N'11850014',N'COCO','20250913','12:00',N'Baño medicado',N'Atendida'),
    (761,N'11850014',N'COCO','20260507','14:00',N'Consulta general',N'Atendida'),
    (762,N'21931334',N'TOMASA','20240515','13:00',N'Vacunación',N'Atendida'),
    (763,N'52709584',N'DAISY','20260605','14:00',N'Control post-operatorio',N'Atendida'),
    (764,N'52709584',N'DAISY','20261109','10:30',N'Control de peso',N'Pendiente'),
    (765,N'54072988',N'ROCCO','20260615','12:30',N'Control de peso',N'Atendida'),
    (766,N'55837540',N'OLIVER','20240118','13:00',N'Chequeo anual',N'Atendida'),
    (767,N'73558850',N'NALA','20230904','14:00',N'Desparasitación',N'Atendida'),
    (768,N'73558850',N'NALA','20240613','14:30',N'Evaluación de esterilización',N'Cancelada'),
    (769,N'34482179',N'GORDO','20250407','13:30',N'Evaluación de esterilización',N'Atendida'),
    (770,N'34482179',N'GORDO','20260330','12:30',N'Control de peso',N'Atendida'),
    (771,N'50363445',N'LASSIE','20230701','12:00',N'Evaluación de esterilización',N'Atendida'),
    (772,N'69119383',N'MISHI','20250509','13:00',N'Desparasitación',N'Atendida'),
    (773,N'69119383',N'MISHI','20251215','10:00',N'Consulta general',N'Atendida'),
    (774,N'19875249',N'GORDO','20250327','15:00',N'Evaluación de esterilización',N'Cancelada'),
    (775,N'22474786',N'MISHI','20240909','17:00',N'Limpieza dental',N'Atendida'),
    (776,N'35657041',N'TIGRE','20260105','16:00',N'Consulta general',N'Atendida'),
    (777,N'16162308',N'ZEUS','20230918','15:30',N'Evaluación de esterilización',N'Atendida'),
    (778,N'16162308',N'ZEUS','20240420','14:00',N'Revisión dermatológica',N'Atendida'),
    (779,N'13241297',N'SIMBA','20230928','10:30',N'Control post-operatorio',N'Cancelada'),
    (780,N'28507286',N'MINA','20260507','13:30',N'Chequeo anual',N'Atendida'),
    (781,N'28507286',N'MINA','20261218','10:00',N'Control post-operatorio',N'Pendiente'),
    (782,N'45747626',N'MINA','20250712','11:30',N'Revisión por cojera',N'Cancelada'),
    (783,N'45747626',N'MINA','20251222','15:00',N'Consulta general',N'Cancelada'),
    (784,N'26297812',N'OSO','20231206','11:00',N'Revisión por cojera',N'Atendida'),
    (785,N'65503322',N'DAISY','20240704','15:00',N'Revisión por cojera',N'Atendida'),
    (786,N'71207207',N'PANCHO','20230819','17:30',N'Revisión por cojera',N'Atendida'),
    (787,N'71207207',N'PANCHO','20240416','17:00',N'Evaluación de esterilización',N'Atendida'),
    (788,N'67182398',N'MICHI','20250210','14:30',N'Baño medicado',N'Atendida'),
    (789,N'67182398',N'MICHI','20261211','09:00',N'Chequeo anual',N'Pendiente'),
    (790,N'33684231',N'JACK','20250929','15:30',N'Evaluación de esterilización',N'Atendida'),
    (791,N'33684231',N'JACK','20260216','10:30',N'Revisión dermatológica',N'Atendida'),
    (792,N'33684231',N'JACK','20261102','10:30',N'Revisión por cojera',N'Pendiente'),
    (793,N'29670750',N'DAISY','20240429','14:00',N'Control de peso',N'Atendida'),
    (794,N'29670750',N'DAISY','20261022','17:00',N'Limpieza dental',N'Pendiente'),
    (795,N'61509430',N'NEGRO','20230928','12:30',N'Control de peso',N'Atendida'),
    (796,N'61509430',N'NEGRO','20240902','14:00',N'Revisión dermatológica',N'Atendida'),
    (797,N'38691854',N'DAISY','20241227','10:00',N'Vacunación',N'Atendida'),
    (798,N'49119649',N'HACHI','20260622','16:00',N'Chequeo anual',N'Atendida'),
    (799,N'14172520',N'TOM','20250811','13:30',N'Baño medicado',N'Atendida'),
    (800,N'14172520',N'TOM','20251206','17:00',N'Revisión por cojera',N'Atendida')
) v(seq, dni, mascota, fecha, hora, motivo, estado)
JOIN dbo.CLIENTE c ON c.dni = v.dni
JOIN dbo.MASCOTA m ON m.id_cliente = c.id_cliente AND m.nombre = v.mascota
WHERE NOT EXISTS (SELECT 1 FROM dbo.CITA x WHERE x.id_mascota = m.id_mascota AND x.fecha_cita = v.fecha AND x.hora_cita = v.hora)
ORDER BY v.seq;

INSERT INTO dbo.CITA (fecha_cita, hora_cita, motivo, estado, id_mascota, id_empleado, ESTADO_ACTIVO)
SELECT v.fecha, v.hora, v.motivo, v.estado, m.id_mascota, @id_empleado, 1
FROM (VALUES
    (801,N'61100472',N'HACHI','20251003','11:00',N'Chequeo anual',N'Atendida'),
    (802,N'72037062',N'ROCCO','20250818','14:00',N'Chequeo anual',N'Atendida'),
    (803,N'73667704',N'NALA','20250723','11:00',N'Desparasitación',N'Atendida'),
    (804,N'13429530',N'KIRA','20230724','14:00',N'Evaluación de esterilización',N'Cancelada'),
    (805,N'14651562',N'MANCHAS','20260119','16:30',N'Control de peso',N'Cancelada'),
    (806,N'14651562',N'MANCHAS','20260402','14:30',N'Evaluación de esterilización',N'Atendida'),
    (807,N'42758335',N'MAYA','20240912','16:00',N'Chequeo anual',N'Atendida'),
    (808,N'17834268',N'NIEVE','20250106','13:00',N'Desparasitación',N'Atendida'),
    (809,N'72953037',N'PELUCHE','20250214','17:30',N'Revisión por cojera',N'Atendida'),
    (810,N'32384647',N'NEGRO','20260922','12:00',N'Chequeo anual',N'Atendida'),
    (811,N'32384647',N'NEGRO','20270407','16:00',N'Revisión por cojera',N'Pendiente'),
    (812,N'64355710',N'ANGEL','20250328','10:30',N'Consulta general',N'Atendida'),
    (813,N'57704381',N'TOÑO','20260608','09:30',N'Evaluación de esterilización',N'Atendida'),
    (814,N'66111417',N'NALA','20240828','14:00',N'Revisión por cojera',N'Atendida'),
    (815,N'33668261',N'MOCHA','20260116','15:30',N'Baño medicado',N'Atendida'),
    (816,N'29038246',N'PEPE','20260930','10:00',N'Baño medicado',N'Cancelada'),
    (817,N'29038246',N'PEPE','20270728','13:00',N'Revisión por vómitos',N'Pendiente'),
    (818,N'34544583',N'MINNIE','20260130','14:30',N'Vacunación',N'Atendida'),
    (819,N'34544583',N'MINNIE','20260616','11:00',N'Revisión por vómitos',N'Cancelada'),
    (820,N'19011623',N'ROCCO','20251103','14:00',N'Control de peso',N'Atendida'),
    (821,N'19011623',N'ROCCO','20260415','11:30',N'Limpieza dental',N'Atendida'),
    (822,N'65248947',N'NALA','20251229','13:30',N'Control de peso',N'Atendida'),
    (823,N'65248947',N'NALA','20260727','15:00',N'Control post-operatorio',N'Atendida'),
    (824,N'74302115',N'NIEVE','20251023','10:00',N'Control post-operatorio',N'Atendida'),
    (825,N'28432775',N'BETO','20240327','09:30',N'Control post-operatorio',N'Atendida'),
    (826,N'66512412',N'CANELA','20260223','12:00',N'Consulta general',N'Atendida'),
    (827,N'31608170',N'MOMO','20260622','16:30',N'Consulta general',N'Atendida'),
    (828,N'31608170',N'MOMO','20270511','09:30',N'Control de peso',N'Pendiente'),
    (829,N'52105566',N'CHISPA','20260502','12:30',N'Control de peso',N'Cancelada'),
    (830,N'79882916',N'JACK','20260505','14:00',N'Limpieza dental',N'Atendida'),
    (831,N'56908733',N'SIMBA','20260908','09:00',N'Control de peso',N'Atendida'),
    (832,N'56908733',N'SIMBA','20270405','14:00',N'Baño medicado',N'Pendiente'),
    (833,N'56908733',N'SIMBA','20261218','13:30',N'Evaluación de esterilización',N'Pendiente'),
    (834,N'47288941',N'TITAN','20260310','13:00',N'Revisión por vómitos',N'Atendida'),
    (835,N'47288941',N'TITAN','20261130','15:00',N'Consulta general',N'Pendiente'),
    (836,N'34651232',N'MOCHA','20250712','12:00',N'Revisión por vómitos',N'Atendida')
) v(seq, dni, mascota, fecha, hora, motivo, estado)
JOIN dbo.CLIENTE c ON c.dni = v.dni
JOIN dbo.MASCOTA m ON m.id_cliente = c.id_cliente AND m.nombre = v.mascota
WHERE NOT EXISTS (SELECT 1 FROM dbo.CITA x WHERE x.id_mascota = m.id_mascota AND x.fecha_cita = v.fecha AND x.hora_cita = v.hora)
ORDER BY v.seq;

/* VACUNACION: 1062 aplicaciones, posteriores al registro del cliente y a los 60 días de vida de la mascota */
INSERT INTO dbo.VACUNACION (fecha_aplicacion, id_mascota, id_vacuna, ESTADO)
SELECT v.fecha, m.id_mascota, vc.id_vacuna, 1
FROM (VALUES
    (1,N'73049233',N'AINOA',N'Antirrábica','20240327'),
    (2,N'73049233',N'AINOA',N'Triple Felina','20240303'),
    (3,N'21102353',N'AKIRA',N'Antirrábica','20230422'),
    (4,N'21102353',N'AKIRA',N'Séxtuple','20240623'),
    (5,N'71161158',N'ALEJANDRITA',N'Antirrábica','20240227'),
    (6,N'71161158',N'ALEJANDRITA',N'Triple Felina','20230705'),
    (7,N'71161158',N'ALEJANDRITA',N'Leucemia Felina','20240210'),
    (8,N'53019203',N'ATILA',N'Antirrábica','20231029'),
    (9,N'53019203',N'ATILA',N'Séxtuple','20230720'),
    (10,N'17804016',N'BLANQUITA',N'Quíntuple','20230520'),
    (11,N'65683365',N'BAMBAM',N'Antirrábica','20231103'),
    (12,N'92473722',N'BELLA',N'Antirrábica','20231026'),
    (13,N'71042911',N'BLACK',N'Antirrábica','20230425'),
    (14,N'31161878',N'BOCKY',N'Antirrábica','20240207'),
    (15,N'83495146',N'BRANDY',N'Antirrábica','20240331'),
    (16,N'83495146',N'BRANDY',N'Óctuple','20240501'),
    (17,N'20693447',N'CAMIL',N'Antirrábica','20231119'),
    (18,N'20693447',N'CAMIL',N'Triple Felina','20231217'),
    (19,N'31843366',N'CAMIL',N'Antirrábica','20230924'),
    (20,N'31843366',N'CAMIL',N'Óctuple','20230726'),
    (21,N'24804339',N'CANELA',N'Antirrábica','20231209'),
    (22,N'24804339',N'CANELA',N'Quíntuple','20230825'),
    (23,N'59580044',N'COOPER',N'Antirrábica','20240312'),
    (24,N'59580044',N'COOPER',N'Séxtuple','20240116'),
    (25,N'59580044',N'COOPER',N'Bordetella','20240831'),
    (26,N'58200384',N'CECHI',N'Antirrábica','20240413'),
    (27,N'77442758',N'COCO',N'Antirrábica','20231015'),
    (28,N'77442758',N'COCO',N'Séxtuple','20240520'),
    (29,N'35946785',N'CHATO',N'Antirrábica','20240627'),
    (30,N'35946785',N'CHATO',N'Séxtuple','20240708'),
    (31,N'66490721',N'CHIQUI',N'Antirrábica','20240509'),
    (32,N'66490721',N'CHIQUI',N'Triple Felina','20240325'),
    (33,N'83010312',N'CHIQUITA BRAVO',N'Antirrábica','20240613'),
    (34,N'83010312',N'CHIQUITA BRAVO',N'Séxtuple','20240210'),
    (35,N'83010312',N'CHIQUITA BRAVO',N'Bordetella','20230928'),
    (36,N'43622481',N'DEYSI',N'Antirrábica','20230923'),
    (37,N'43622481',N'DEYSI',N'Bordetella','20240331'),
    (38,N'72987366',N'DOLLY',N'Antirrábica','20240827'),
    (39,N'40409222',N'DORITA',N'Antirrábica','20240415'),
    (40,N'40409222',N'DORITA',N'Triple Felina','20240527'),
    (41,N'18686265',N'DUNGA',N'Antirrábica','20231210'),
    (42,N'18686265',N'DUNGA',N'Quíntuple','20240304'),
    (43,N'99982179',N'DUQUESITA',N'Antirrábica','20231009'),
    (44,N'82171493',N'ESTRELLITA',N'Antirrábica','20240602'),
    (45,N'82171493',N'ESTRELLITA',N'Óctuple','20240119'),
    (46,N'59631561',N'FELIPE',N'Antirrábica','20230503'),
    (47,N'59631561',N'FELIPE',N'Óctuple','20230629'),
    (48,N'59631561',N'FELIPE',N'Bordetella','20240414'),
    (49,N'77059003',N'FOXY',N'Óctuple','20240129'),
    (50,N'77059003',N'FOXY',N'Bordetella','20231021'),
    (51,N'51883468',N'FRESITA',N'Antirrábica','20231126'),
    (52,N'51883468',N'FRESITA',N'Quíntuple','20240602'),
    (53,N'23274785',N'GRECO',N'Óctuple','20230429'),
    (54,N'23274785',N'GRECO',N'Bordetella','20230824'),
    (55,N'22884877',N'GRINGA',N'Antirrábica','20240823'),
    (56,N'22884877',N'GRINGA',N'Séxtuple','20231029'),
    (57,N'65072361',N'GIORGO',N'Antirrábica','20240424'),
    (58,N'65072361',N'GIORGO',N'Óctuple','20240717'),
    (59,N'50357259',N'GOYA',N'Antirrábica','20230502'),
    (60,N'50357259',N'GOYA',N'Quíntuple','20240830'),
    (61,N'57394899',N'HASS',N'Óctuple','20240509'),
    (62,N'57394899',N'HASS',N'Bordetella','20240704'),
    (63,N'96639359',N'HINDI',N'Quíntuple','20240210'),
    (64,N'45449433',N'HOLLY',N'Antirrábica','20240610'),
    (65,N'45449433',N'HOLLY',N'Triple Felina','20240122'),
    (66,N'87073258',N'HUGO',N'Antirrábica','20230531'),
    (67,N'87073258',N'HUGO',N'Triple Felina','20230515'),
    (68,N'43098654',N'KRATOS',N'Quíntuple','20230608'),
    (69,N'76113377',N'KILLA',N'Antirrábica','20240203'),
    (70,N'76113377',N'KILLA',N'Bordetella','20230824'),
    (71,N'80879931',N'KLIMB',N'Antirrábica','20240605'),
    (72,N'80879931',N'KLIMB',N'Óctuple','20230624'),
    (73,N'71323763',N'KOPI',N'Antirrábica','20231118'),
    (74,N'71323763',N'KOPI',N'Séxtuple','20240801'),
    (75,N'71578881',N'KUMA',N'Antirrábica','20231014'),
    (76,N'71578881',N'KUMA',N'Quíntuple','20230906'),
    (77,N'14255487',N'LETTY',N'Óctuple','20240821'),
    (78,N'17095703',N'LARA',N'Antirrábica','20240527'),
    (79,N'17095703',N'LARA',N'Séxtuple','20240326'),
    (80,N'77707788',N'LEGOLAS',N'Óctuple','20231202'),
    (81,N'44978812',N'LEYA',N'Antirrábica','20230620'),
    (82,N'44978812',N'LEYA',N'Óctuple','20230831'),
    (83,N'78043250',N'LUA',N'Antirrábica','20230901'),
    (84,N'78043250',N'LUA',N'Quíntuple','20240406'),
    (85,N'86028611',N'LUANA',N'Antirrábica','20240312'),
    (86,N'86028611',N'LUANA',N'Quíntuple','20230927'),
    (87,N'86028611',N'LUANA',N'Bordetella','20231225'),
    (88,N'10453063',N'LUNA',N'Antirrábica','20240615'),
    (89,N'10453063',N'LUNA',N'Quíntuple','20240425'),
    (90,N'37811251',N'LUNA',N'Antirrábica','20231030'),
    (91,N'37811251',N'LUNA',N'Séxtuple','20240204'),
    (92,N'67914971',N'LUCKY',N'Antirrábica','20230721'),
    (93,N'67914971',N'LUCKY',N'Quíntuple','20230902'),
    (94,N'53474998',N'LUZ',N'Quíntuple','20240526'),
    (95,N'61755938',N'MAYA',N'Antirrábica','20240309'),
    (96,N'61755938',N'MAYA',N'Quíntuple','20240812'),
    (97,N'46340188',N'MAGI',N'Antirrábica','20240805'),
    (98,N'46340188',N'MAGI',N'Óctuple','20240227'),
    (99,N'79976947',N'MAIA',N'Antirrábica','20230613'),
    (100,N'79976947',N'MAIA',N'Séxtuple','20240714'),
    (101,N'52722310',N'MANTY',N'Antirrábica','20231019'),
    (102,N'52722310',N'MANTY',N'Quíntuple','20230706'),
    (103,N'43760409',N'MARA',N'Antirrábica','20240625'),
    (104,N'43760409',N'MARA',N'Quíntuple','20231111'),
    (105,N'58743611',N'MARLEY',N'Óctuple','20240221'),
    (106,N'94538328',N'MARRÓN',N'Antirrábica','20230629'),
    (107,N'94538328',N'MARRÓN',N'Óctuple','20230731'),
    (108,N'94538328',N'MARRÓN',N'Bordetella','20240729'),
    (109,N'74519257',N'MARVEL',N'Antirrábica','20231011'),
    (110,N'74519257',N'MARVEL',N'Triple Felina','20230728'),
    (111,N'23700218',N'MAYA',N'Antirrábica','20230502'),
    (112,N'23700218',N'MAYA',N'Óctuple','20240502'),
    (113,N'23700218',N'MAYA',N'Bordetella','20240701'),
    (114,N'41585435',N'MAYRO',N'Antirrábica','20230506'),
    (115,N'41585435',N'MAYRO',N'Óctuple','20240105'),
    (116,N'83258857',N'MINIE',N'Antirrábica','20240215'),
    (117,N'29051955',N'MININA',N'Antirrábica','20240715'),
    (118,N'29051955',N'MININA',N'Triple Felina','20230706'),
    (119,N'36079144',N'MINNA',N'Antirrábica','20230914'),
    (120,N'36079144',N'MINNA',N'Séxtuple','20240418'),
    (121,N'93021703',N'MISHA',N'Triple Felina','20240714'),
    (122,N'30379788',N'MOLLY',N'Antirrábica','20240617'),
    (123,N'59086363',N'MOLLY',N'Antirrábica','20240607'),
    (124,N'59086363',N'MOLLY',N'Séxtuple','20231013'),
    (125,N'11703235',N'MONKY',N'Antirrábica','20240330'),
    (126,N'11703235',N'MONKY',N'Óctuple','20231028'),
    (127,N'58839322',N'NALA',N'Antirrábica','20231112'),
    (128,N'58839322',N'NALA',N'Bordetella','20230820'),
    (129,N'50143134',N'NILA',N'Antirrábica','20240615'),
    (130,N'50143134',N'NILA',N'Quíntuple','20231126'),
    (131,N'47600393',N'NEGRITA',N'Antirrábica','20230614'),
    (132,N'47600393',N'NEGRITA',N'Séxtuple','20240329'),
    (133,N'19397597',N'NALA',N'Antirrábica','20240511'),
    (134,N'19397597',N'NALA',N'Séxtuple','20230629'),
    (135,N'66369156',N'NENE',N'Quíntuple','20230607'),
    (136,N'32357106',N'NICKY',N'Antirrábica','20231108'),
    (137,N'32357106',N'NICKY',N'Séxtuple','20240607'),
    (138,N'48535253',N'NICO',N'Antirrábica','20240722'),
    (139,N'48535253',N'NICO',N'Séxtuple','20240806'),
    (140,N'48535253',N'NICO',N'Bordetella','20230804'),
    (141,N'44598490',N'NINA',N'Antirrábica','20230823'),
    (142,N'44598490',N'NINA',N'Quíntuple','20230630'),
    (143,N'92117808',N'NIÑA',N'Antirrábica','20231227'),
    (144,N'92117808',N'NIÑA',N'Triple Felina','20230915'),
    (145,N'92117808',N'NIÑA',N'Leucemia Felina','20230926'),
    (146,N'53258560',N'OREO',N'Antirrábica','20240227'),
    (147,N'53258560',N'OREO',N'Séxtuple','20231130'),
    (148,N'53258560',N'OREO',N'Bordetella','20240314'),
    (149,N'70081614',N'OSA',N'Antirrábica','20231111'),
    (150,N'70081614',N'OSA',N'Séxtuple','20240815'),
    (151,N'70081614',N'OSA',N'Bordetella','20230709'),
    (152,N'62179698',N'OSO',N'Antirrábica','20231205'),
    (153,N'62179698',N'OSO',N'Séxtuple','20231117'),
    (154,N'62179698',N'OSO',N'Bordetella','20230805'),
    (155,N'11101735',N'OTTO',N'Antirrábica','20230601'),
    (156,N'11101735',N'OTTO',N'Quíntuple','20240618'),
    (157,N'43966135',N'PACO',N'Séxtuple','20231101'),
    (158,N'50069966',N'PACO',N'Antirrábica','20240723'),
    (159,N'50069966',N'PACO',N'Óctuple','20230501'),
    (160,N'37662171',N'PANCHITA',N'Antirrábica','20240821'),
    (161,N'37662171',N'PANCHITA',N'Triple Felina','20230926'),
    (162,N'32576233',N'PRINCESA',N'Antirrábica','20230925'),
    (163,N'32576233',N'PRINCESA',N'Quíntuple','20231130'),
    (164,N'44167765',N'PRINCIPE',N'Antirrábica','20230806'),
    (165,N'44167765',N'PRINCIPE',N'Triple Felina','20240419'),
    (166,N'14512500',N'ROCCO',N'Antirrábica','20230823'),
    (167,N'14512500',N'ROCCO',N'Óctuple','20230719'),
    (168,N'14512500',N'ROCCO',N'Bordetella','20240414'),
    (169,N'87135532',N'ROCCO',N'Antirrábica','20231216'),
    (170,N'87135532',N'ROCCO',N'Séxtuple','20240305'),
    (171,N'45141552',N'ROCKY',N'Antirrábica','20240619'),
    (172,N'45141552',N'ROCKY',N'Quíntuple','20240524'),
    (173,N'43731506',N'RICK',N'Antirrábica','20240414'),
    (174,N'43731506',N'RICK',N'Quíntuple','20230524'),
    (175,N'43731506',N'RICK',N'Bordetella','20240804'),
    (176,N'83106100',N'RITO',N'Antirrábica','20240315'),
    (177,N'83106100',N'RITO',N'Séxtuple','20230826'),
    (178,N'83106100',N'RITO',N'Bordetella','20231025'),
    (179,N'50606432',N'ROCKY',N'Antirrábica','20231108'),
    (180,N'50606432',N'ROCKY',N'Óctuple','20240318'),
    (181,N'85463093',N'SACKY',N'Antirrábica','20240313'),
    (182,N'85463093',N'SACKY',N'Óctuple','20231204'),
    (183,N'35087613',N'SANTI',N'Antirrábica','20240226'),
    (184,N'35087613',N'SANTI',N'Óctuple','20230623'),
    (185,N'77915097',N'SASHA',N'Antirrábica','20240429'),
    (186,N'77915097',N'SASHA',N'Óctuple','20230824'),
    (187,N'51430602',N'SHIMA',N'Antirrábica','20240601'),
    (188,N'51430602',N'SHIMA',N'Bordetella','20240723'),
    (189,N'27898879',N'SIMBA',N'Antirrábica','20230706'),
    (190,N'27898879',N'SIMBA',N'Quíntuple','20230428'),
    (191,N'37591160',N'SIRIUS',N'Antirrábica','20240103'),
    (192,N'37591160',N'SIRIUS',N'Triple Felina','20240627'),
    (193,N'33715647',N'TAYLER',N'Antirrábica','20230706'),
    (194,N'33715647',N'TAYLER',N'Triple Felina','20240813'),
    (195,N'36338780',N'TEMY',N'Antirrábica','20231204'),
    (196,N'36338780',N'TEMY',N'Triple Felina','20230930'),
    (197,N'53316884',N'MINNIE',N'Antirrábica','20260825'),
    (198,N'53316884',N'MINNIE',N'Triple Felina','20251227'),
    (199,N'46075844',N'TRUENO',N'Antirrábica','20250430'),
    (200,N'46075844',N'TRUENO',N'Quíntuple','20240204'),
    (201,N'16537126',N'LOLA',N'Antirrábica','20260122'),
    (202,N'16537126',N'LOLA',N'Óctuple','20260225'),
    (203,N'16537126',N'LOLA',N'Bordetella','20250716'),
    (204,N'75874880',N'LASSIE',N'Antirrábica','20241123'),
    (205,N'75874880',N'LASSIE',N'Quíntuple','20241030'),
    (206,N'75874880',N'LASSIE',N'Bordetella','20250421'),
    (207,N'50665804',N'KIRA',N'Antirrábica','20260822'),
    (208,N'73756858',N'SAMY',N'Antirrábica','20260716'),
    (209,N'73756858',N'SAMY',N'Óctuple','20261005'),
    (210,N'46337525',N'ZEUS',N'Antirrábica','20240711'),
    (211,N'46337525',N'ZEUS',N'Séxtuple','20240511'),
    (212,N'75598594',N'PRINCESA',N'Antirrábica','20241129'),
    (213,N'71990332',N'MILO',N'Antirrábica','20260223'),
    (214,N'71990332',N'MILO',N'Óctuple','20260708'),
    (215,N'58213469',N'COCO',N'Antirrábica','20260924'),
    (216,N'58213469',N'COCO',N'Quíntuple','20261010'),
    (217,N'58213469',N'COCO',N'Bordetella','20260928'),
    (218,N'77344573',N'NEGRO',N'Antirrábica','20240910'),
    (219,N'77344573',N'NEGRO',N'Séxtuple','20240915'),
    (220,N'70536828',N'TITAN',N'Antirrábica','20250131'),
    (221,N'70536828',N'TITAN',N'Quíntuple','20240914'),
    (222,N'39138767',N'BOBBY',N'Antirrábica','20240804'),
    (223,N'39138767',N'BOBBY',N'Séxtuple','20240622'),
    (224,N'47246945',N'COCO',N'Antirrábica','20240723'),
    (225,N'57535139',N'THOR',N'Antirrábica','20260917'),
    (226,N'51064536',N'OLIVER',N'Antirrábica','20250705'),
    (227,N'31366985',N'LUNA',N'Antirrábica','20260330'),
    (228,N'31366985',N'LUNA',N'Quíntuple','20250114'),
    (229,N'31366985',N'LUNA',N'Bordetella','20251121'),
    (230,N'38386240',N'OSO',N'Antirrábica','20260711'),
    (231,N'23781600',N'ROCCO',N'Antirrábica','20260426'),
    (232,N'23781600',N'ROCCO',N'Quíntuple','20260717'),
    (233,N'75149339',N'PANCHO',N'Antirrábica','20260704'),
    (234,N'75149339',N'PANCHO',N'Óctuple','20260131'),
    (235,N'32374940',N'GORDO',N'Antirrábica','20261010'),
    (236,N'32374940',N'GORDO',N'Óctuple','20260726'),
    (237,N'32374940',N'GORDO',N'Bordetella','20260620'),
    (238,N'35967986',N'MINNIE',N'Antirrábica','20230821'),
    (239,N'35967986',N'MINNIE',N'Triple Felina','20231127'),
    (240,N'43015498',N'MOCHA',N'Antirrábica','20241211'),
    (241,N'43015498',N'MOCHA',N'Bordetella','20241017'),
    (242,N'38320094',N'BOBBY',N'Antirrábica','20260708'),
    (243,N'38320094',N'BOBBY',N'Óctuple','20261006'),
    (244,N'38320094',N'BOBBY',N'Bordetella','20260804'),
    (245,N'39512989',N'COCO',N'Antirrábica','20251222'),
    (246,N'39512989',N'COCO',N'Quíntuple','20260416'),
    (247,N'39512989',N'COCO',N'Bordetella','20251001'),
    (248,N'50251342',N'ZEUS',N'Antirrábica','20251203'),
    (249,N'50251342',N'ZEUS',N'Quíntuple','20250213'),
    (250,N'54344343',N'MANCHAS',N'Antirrábica','20260826'),
    (251,N'54344343',N'MANCHAS',N'Séxtuple','20260803'),
    (252,N'54344343',N'MANCHAS',N'Bordetella','20260723'),
    (253,N'60693432',N'NALA',N'Antirrábica','20251113'),
    (254,N'61283202',N'TYSON',N'Antirrábica','20260313'),
    (255,N'42339214',N'IRIS',N'Antirrábica','20250619'),
    (256,N'42339214',N'IRIS',N'Quíntuple','20250713'),
    (257,N'35860182',N'GORDO',N'Antirrábica','20260126'),
    (258,N'35860182',N'GORDO',N'Quíntuple','20260429'),
    (259,N'32056535',N'TOMASA',N'Antirrábica','20260707'),
    (260,N'32056535',N'TOMASA',N'Triple Felina','20260714'),
    (261,N'49176341',N'OLIVER',N'Antirrábica','20250419'),
    (262,N'49176341',N'OLIVER',N'Triple Felina','20250428'),
    (263,N'44353078',N'OLIVER',N'Antirrábica','20261015'),
    (264,N'44353078',N'OLIVER',N'Triple Felina','20261018'),
    (265,N'54073127',N'TOÑO',N'Antirrábica','20260915'),
    (266,N'54073127',N'TOÑO',N'Óctuple','20260825'),
    (267,N'54073127',N'TOÑO',N'Bordetella','20260626'),
    (268,N'11644275',N'NALA',N'Antirrábica','20260930'),
    (269,N'11644275',N'NALA',N'Séxtuple','20260825'),
    (270,N'70251498',N'CHISPA',N'Séxtuple','20261014'),
    (271,N'75331516',N'DAISY',N'Antirrábica','20230608'),
    (272,N'75331516',N'DAISY',N'Séxtuple','20240912'),
    (273,N'18249549',N'NIEVE',N'Antirrábica','20251206'),
    (274,N'18249549',N'NIEVE',N'Triple Felina','20251129'),
    (275,N'44057414',N'COCO',N'Antirrábica','20260829'),
    (276,N'44057414',N'COCO',N'Quíntuple','20260508'),
    (277,N'44057414',N'COCO',N'Bordetella','20260329'),
    (278,N'27749817',N'PELUCHE',N'Triple Felina','20240825'),
    (279,N'27749817',N'PELUCHE',N'Leucemia Felina','20250101'),
    (280,N'14179958',N'CHIQUI',N'Antirrábica','20240314'),
    (281,N'14179958',N'CHIQUI',N'Triple Felina','20240930'),
    (282,N'14179958',N'CHIQUI',N'Leucemia Felina','20240711'),
    (283,N'35029611',N'ZEUS',N'Antirrábica','20251012'),
    (284,N'35029611',N'ZEUS',N'Óctuple','20250813'),
    (285,N'43588550',N'BOBBY',N'Antirrábica','20250410'),
    (286,N'43588550',N'BOBBY',N'Óctuple','20250615'),
    (287,N'56162302',N'ANGEL',N'Antirrábica','20250816'),
    (288,N'56162302',N'ANGEL',N'Séxtuple','20251228'),
    (289,N'37855761',N'MOCHA',N'Antirrábica','20250101'),
    (290,N'37855761',N'MOCHA',N'Óctuple','20240313'),
    (291,N'79028178',N'BETO',N'Antirrábica','20240121'),
    (292,N'79028178',N'BETO',N'Séxtuple','20240414'),
    (293,N'53561260',N'LUCKY',N'Antirrábica','20240711'),
    (294,N'53561260',N'LUCKY',N'Quíntuple','20240325'),
    (295,N'53561260',N'LUCKY',N'Bordetella','20250225'),
    (296,N'26212581',N'MICHI',N'Antirrábica','20240701'),
    (297,N'26212581',N'MICHI',N'Triple Felina','20240521'),
    (298,N'76885298',N'PELUSA',N'Antirrábica','20250111'),
    (299,N'76885298',N'PELUSA',N'Séxtuple','20240424'),
    (300,N'76885298',N'PELUSA',N'Bordetella','20231209'),
    (301,N'20966078',N'ANGEL',N'Antirrábica','20250712'),
    (302,N'20966078',N'ANGEL',N'Quíntuple','20250921'),
    (303,N'20966078',N'ANGEL',N'Bordetella','20251121'),
    (304,N'25276068',N'PANTERA',N'Antirrábica','20260614'),
    (305,N'25276068',N'PANTERA',N'Triple Felina','20260908'),
    (306,N'44827796',N'BRUNO',N'Antirrábica','20260609'),
    (307,N'44827796',N'BRUNO',N'Séxtuple','20260409'),
    (308,N'67321528',N'GOKU',N'Antirrábica','20261009'),
    (309,N'67321528',N'GOKU',N'Quíntuple','20261009'),
    (310,N'53105515',N'NEGRO',N'Antirrábica','20261013'),
    (311,N'53105515',N'NEGRO',N'Quíntuple','20261017'),
    (312,N'53105515',N'NEGRO',N'Bordetella','20261015'),
    (313,N'48607157',N'GOKU',N'Antirrábica','20230830'),
    (314,N'37495349',N'LUNA',N'Antirrábica','20260718'),
    (315,N'37495349',N'LUNA',N'Óctuple','20260719'),
    (316,N'54400813',N'DAISY',N'Antirrábica','20250313'),
    (317,N'54400813',N'DAISY',N'Quíntuple','20250623'),
    (318,N'54400813',N'DAISY',N'Bordetella','20251226'),
    (319,N'46221200',N'MOMO',N'Antirrábica','20260115'),
    (320,N'46221200',N'MOMO',N'Triple Felina','20250518'),
    (321,N'53060004',N'OSO',N'Antirrábica','20260710'),
    (322,N'53060004',N'OSO',N'Quíntuple','20260704'),
    (323,N'29660614',N'TOBY',N'Antirrábica','20260925'),
    (324,N'29660614',N'TOBY',N'Quíntuple','20261004'),
    (325,N'37828753',N'CHIQUI',N'Antirrábica','20260503'),
    (326,N'37828753',N'CHIQUI',N'Triple Felina','20260113'),
    (327,N'37828753',N'CHIQUI',N'Leucemia Felina','20251126'),
    (328,N'68285145',N'ANGEL',N'Antirrábica','20250324'),
    (329,N'68285145',N'ANGEL',N'Óctuple','20240312'),
    (330,N'14378485',N'TOBY',N'Antirrábica','20260727'),
    (331,N'14378485',N'TOBY',N'Óctuple','20260722'),
    (332,N'35063063',N'GORDO',N'Séxtuple','20240505'),
    (333,N'35063063',N'GORDO',N'Bordetella','20250223'),
    (334,N'54572038',N'SIMBA',N'Antirrábica','20240919'),
    (335,N'54572038',N'SIMBA',N'Triple Felina','20250122'),
    (336,N'12693757',N'TITAN',N'Antirrábica','20250711'),
    (337,N'12693757',N'TITAN',N'Bordetella','20250612'),
    (338,N'36292579',N'NEGRO',N'Antirrábica','20240419'),
    (339,N'36292579',N'NEGRO',N'Quíntuple','20240726'),
    (340,N'20855772',N'CHOCOLATE',N'Antirrábica','20260621'),
    (341,N'20855772',N'CHOCOLATE',N'Séxtuple','20251212'),
    (342,N'36725962',N'TOBY',N'Antirrábica','20260226'),
    (343,N'36725962',N'TOBY',N'Óctuple','20260130'),
    (344,N'58637800',N'BRUNO',N'Séxtuple','20251027'),
    (345,N'65972462',N'OLIVER',N'Antirrábica','20230808'),
    (346,N'65972462',N'OLIVER',N'Triple Felina','20230730'),
    (347,N'45932642',N'MOCHA',N'Antirrábica','20251214'),
    (348,N'45932642',N'MOCHA',N'Óctuple','20251106'),
    (349,N'45932642',N'MOCHA',N'Bordetella','20250922'),
    (350,N'39734772',N'MILO',N'Antirrábica','20260714'),
    (351,N'39734772',N'MILO',N'Quíntuple','20260207'),
    (352,N'77521126',N'SAMY',N'Óctuple','20260319'),
    (353,N'38601665',N'BRUNO',N'Antirrábica','20251202'),
    (354,N'38601665',N'BRUNO',N'Quíntuple','20251025'),
    (355,N'16148560',N'FIRULAIS',N'Óctuple','20260423'),
    (356,N'64701909',N'TYSON',N'Antirrábica','20260522'),
    (357,N'66703032',N'GARFIELD',N'Antirrábica','20250923'),
    (358,N'66703032',N'GARFIELD',N'Triple Felina','20250219'),
    (359,N'58228917',N'TOBY',N'Antirrábica','20261009'),
    (360,N'58228917',N'TOBY',N'Quíntuple','20261016'),
    (361,N'17516769',N'ROCKY',N'Antirrábica','20260815'),
    (362,N'17516769',N'ROCKY',N'Séxtuple','20260821'),
    (363,N'17516769',N'ROCKY',N'Bordetella','20260811'),
    (364,N'70962766',N'CANELA',N'Antirrábica','20260729'),
    (365,N'70962766',N'CANELA',N'Séxtuple','20260905'),
    (366,N'24289836',N'BETO',N'Antirrábica','20250705'),
    (367,N'32556969',N'ROCKY',N'Antirrábica','20231201'),
    (368,N'32556969',N'ROCKY',N'Quíntuple','20241029'),
    (369,N'32556969',N'ROCKY',N'Bordetella','20241219'),
    (370,N'54744533',N'LUCKY',N'Antirrábica','20251205'),
    (371,N'54744533',N'LUCKY',N'Séxtuple','20260509'),
    (372,N'38443718',N'TOBY',N'Quíntuple','20251124'),
    (373,N'11432233',N'LOLA',N'Óctuple','20260512'),
    (374,N'11432233',N'LOLA',N'Bordetella','20260522'),
    (375,N'66933972',N'GATUBELA',N'Antirrábica','20260928'),
    (376,N'66933972',N'GATUBELA',N'Triple Felina','20251129'),
    (377,N'41067506',N'JACK',N'Antirrábica','20251212'),
    (378,N'41067506',N'JACK',N'Séxtuple','20260902'),
    (379,N'17968489',N'CANELA',N'Antirrábica','20230914'),
    (380,N'17968489',N'CANELA',N'Quíntuple','20240611'),
    (381,N'35567394',N'MOCHA',N'Antirrábica','20260806'),
    (382,N'35567394',N'MOCHA',N'Óctuple','20260213'),
    (383,N'10374680',N'NALA',N'Antirrábica','20260620'),
    (384,N'10374680',N'NALA',N'Séxtuple','20260718'),
    (385,N'10374680',N'NALA',N'Bordetella','20260316'),
    (386,N'63703773',N'BETO',N'Antirrábica','20251006'),
    (387,N'63703773',N'BETO',N'Óctuple','20250913'),
    (388,N'26925176',N'NALA',N'Antirrábica','20260809'),
    (389,N'26925176',N'NALA',N'Óctuple','20260413'),
    (390,N'26925176',N'NALA',N'Bordetella','20260617'),
    (391,N'50193307',N'FIONA',N'Antirrábica','20240401'),
    (392,N'50193307',N'FIONA',N'Óctuple','20240420'),
    (393,N'68488848',N'LUNA',N'Antirrábica','20260815'),
    (394,N'68488848',N'LUNA',N'Quíntuple','20260728'),
    (395,N'68488848',N'LUNA',N'Bordetella','20250819'),
    (396,N'17873272',N'IRIS',N'Antirrábica','20250126'),
    (397,N'17873272',N'IRIS',N'Óctuple','20250124'),
    (398,N'44893952',N'NALA',N'Antirrábica','20260106'),
    (399,N'52964751',N'LUCKY',N'Antirrábica','20241127'),
    (400,N'52964751',N'LUCKY',N'Bordetella','20250324')
) v(seq, dni, mascota, vacuna, fecha)
JOIN dbo.CLIENTE c  ON c.dni = v.dni
JOIN dbo.MASCOTA m  ON m.id_cliente = c.id_cliente AND m.nombre = v.mascota
JOIN dbo.VACUNA  vc ON vc.nombre = v.vacuna
WHERE NOT EXISTS (SELECT 1 FROM dbo.VACUNACION x WHERE x.id_mascota = m.id_mascota AND x.id_vacuna = vc.id_vacuna AND x.fecha_aplicacion = v.fecha)
ORDER BY v.seq;

INSERT INTO dbo.VACUNACION (fecha_aplicacion, id_mascota, id_vacuna, ESTADO)
SELECT v.fecha, m.id_mascota, vc.id_vacuna, 1
FROM (VALUES
    (401,N'61745970',N'OLIVER',N'Antirrábica','20250803'),
    (402,N'21984827',N'ANGEL',N'Antirrábica','20260805'),
    (403,N'21984827',N'ANGEL',N'Óctuple','20251028'),
    (404,N'66057004',N'ROCCO',N'Antirrábica','20240217'),
    (405,N'66057004',N'ROCCO',N'Quíntuple','20240331'),
    (406,N'74409158',N'NALA',N'Antirrábica','20261013'),
    (407,N'60487593',N'PELUCHE',N'Triple Felina','20231116'),
    (408,N'38663018',N'SAMY',N'Antirrábica','20251110'),
    (409,N'38663018',N'SAMY',N'Óctuple','20251109'),
    (410,N'74414951',N'TOBY',N'Séxtuple','20250429'),
    (411,N'45907081',N'OLIVER',N'Antirrábica','20260423'),
    (412,N'45907081',N'OLIVER',N'Triple Felina','20260906'),
    (413,N'66499753',N'MILO',N'Antirrábica','20250513'),
    (414,N'66499753',N'MILO',N'Séxtuple','20251130'),
    (415,N'39050775',N'GATUBELA',N'Antirrábica','20260330'),
    (416,N'39050775',N'GATUBELA',N'Triple Felina','20260301'),
    (417,N'54305327',N'SIMBA',N'Antirrábica','20260623'),
    (418,N'54305327',N'SIMBA',N'Séxtuple','20251010'),
    (419,N'54305327',N'SIMBA',N'Bordetella','20250916'),
    (420,N'61428603',N'IRIS',N'Antirrábica','20260923'),
    (421,N'61428603',N'IRIS',N'Quíntuple','20261012'),
    (422,N'49691643',N'LOLA',N'Antirrábica','20241209'),
    (423,N'32697260',N'TITAN',N'Antirrábica','20241221'),
    (424,N'32697260',N'TITAN',N'Séxtuple','20250114'),
    (425,N'32697260',N'TITAN',N'Bordetella','20250323'),
    (426,N'64949806',N'CHISPA',N'Antirrábica','20251017'),
    (427,N'64949806',N'CHISPA',N'Séxtuple','20250501'),
    (428,N'56914201',N'THOR',N'Antirrábica','20250312'),
    (429,N'56914201',N'THOR',N'Óctuple','20250627'),
    (430,N'24696128',N'ZEUS',N'Antirrábica','20240104'),
    (431,N'24696128',N'ZEUS',N'Óctuple','20240910'),
    (432,N'16372812',N'BOLITA',N'Antirrábica','20260220'),
    (433,N'16372812',N'BOLITA',N'Triple Felina','20251224'),
    (434,N'39328441',N'PRINCESA',N'Antirrábica','20260908'),
    (435,N'39328441',N'PRINCESA',N'Séxtuple','20260214'),
    (436,N'39328441',N'PRINCESA',N'Bordetella','20260112'),
    (437,N'56061576',N'PRINCESA',N'Antirrábica','20251021'),
    (438,N'55115571',N'MISHI',N'Antirrábica','20240524'),
    (439,N'55115571',N'MISHI',N'Triple Felina','20240803'),
    (440,N'55115571',N'MISHI',N'Leucemia Felina','20250802'),
    (441,N'38702911',N'THOR',N'Séxtuple','20250410'),
    (442,N'17338952',N'TRUENO',N'Séxtuple','20241126'),
    (443,N'17338952',N'TRUENO',N'Bordetella','20250929'),
    (444,N'16408342',N'MILO',N'Antirrábica','20250215'),
    (445,N'16408342',N'MILO',N'Séxtuple','20241016'),
    (446,N'57003069',N'KIRA',N'Antirrábica','20260618'),
    (447,N'57003069',N'KIRA',N'Quíntuple','20260830'),
    (448,N'73182519',N'TRUENO',N'Quíntuple','20260622'),
    (449,N'38237762',N'NALA',N'Antirrábica','20240922'),
    (450,N'38237762',N'NALA',N'Triple Felina','20250710'),
    (451,N'38237762',N'NALA',N'Leucemia Felina','20240910'),
    (452,N'73227182',N'LASSIE',N'Antirrábica','20240710'),
    (453,N'73227182',N'LASSIE',N'Quíntuple','20241127'),
    (454,N'62671174',N'THOR',N'Antirrábica','20260719'),
    (455,N'62671174',N'THOR',N'Séxtuple','20260413'),
    (456,N'59803849',N'TIGRE',N'Triple Felina','20260617'),
    (457,N'59996943',N'ROCCO',N'Quíntuple','20240315'),
    (458,N'77822400',N'NALA',N'Antirrábica','20240509'),
    (459,N'77822400',N'NALA',N'Triple Felina','20241205'),
    (460,N'39677506',N'BRUNO',N'Antirrábica','20260622'),
    (461,N'39677506',N'BRUNO',N'Quíntuple','20260706'),
    (462,N'76415788',N'GORDO',N'Antirrábica','20261007'),
    (463,N'76415788',N'GORDO',N'Quíntuple','20260927'),
    (464,N'29789893',N'LASSIE',N'Antirrábica','20241218'),
    (465,N'29789893',N'LASSIE',N'Óctuple','20251017'),
    (466,N'29789893',N'LASSIE',N'Bordetella','20241007'),
    (467,N'30289791',N'NIEVE',N'Antirrábica','20260818'),
    (468,N'30289791',N'NIEVE',N'Triple Felina','20260307'),
    (469,N'30289791',N'NIEVE',N'Leucemia Felina','20251005'),
    (470,N'79220323',N'KIRA',N'Antirrábica','20260628'),
    (471,N'79220323',N'KIRA',N'Séxtuple','20251014'),
    (472,N'47888884',N'BRUNO',N'Antirrábica','20260625'),
    (473,N'28948673',N'ROCKY',N'Antirrábica','20260109'),
    (474,N'27867033',N'BRUNO',N'Antirrábica','20260524'),
    (475,N'27867033',N'BRUNO',N'Quíntuple','20261005'),
    (476,N'62719537',N'GOKU',N'Antirrábica','20260206'),
    (477,N'22191593',N'DULCE',N'Antirrábica','20250325'),
    (478,N'22191593',N'DULCE',N'Séxtuple','20250119'),
    (479,N'37519394',N'TYSON',N'Óctuple','20250721'),
    (480,N'40377786',N'LUCKY',N'Antirrábica','20260413'),
    (481,N'40377786',N'LUCKY',N'Séxtuple','20250518'),
    (482,N'53716605',N'PRINCESA',N'Antirrábica','20250813'),
    (483,N'36860383',N'LUNA',N'Antirrábica','20260326'),
    (484,N'36860383',N'LUNA',N'Quíntuple','20260618'),
    (485,N'74637126',N'MOCHA',N'Antirrábica','20240102'),
    (486,N'74637126',N'MOCHA',N'Séxtuple','20250131'),
    (487,N'26753308',N'IRIS',N'Antirrábica','20240929'),
    (488,N'26753308',N'IRIS',N'Quíntuple','20231219'),
    (489,N'26419779',N'IRIS',N'Antirrábica','20250731'),
    (490,N'26419779',N'IRIS',N'Séxtuple','20250705'),
    (491,N'77942639',N'DULCE',N'Antirrábica','20261003'),
    (492,N'77942639',N'DULCE',N'Séxtuple','20260825'),
    (493,N'77942639',N'DULCE',N'Bordetella','20261012'),
    (494,N'76604777',N'PRINCESA',N'Séxtuple','20251220'),
    (495,N'71417100',N'SIMBA',N'Antirrábica','20260930'),
    (496,N'52622436',N'COCO',N'Antirrábica','20261007'),
    (497,N'52622436',N'COCO',N'Óctuple','20261016'),
    (498,N'52350164',N'FRODO',N'Óctuple','20241020'),
    (499,N'52350164',N'FRODO',N'Bordetella','20231107'),
    (500,N'28353924',N'FIRULAIS',N'Antirrábica','20261001'),
    (501,N'28353924',N'FIRULAIS',N'Quíntuple','20261008'),
    (502,N'70094344',N'OSO',N'Antirrábica','20261012'),
    (503,N'70094344',N'OSO',N'Séxtuple','20261013'),
    (504,N'70094344',N'OSO',N'Bordetella','20261007'),
    (505,N'10569492',N'TITAN',N'Antirrábica','20260116'),
    (506,N'10569492',N'TITAN',N'Séxtuple','20250818'),
    (507,N'10569492',N'TITAN',N'Bordetella','20251118'),
    (508,N'46385312',N'OSO',N'Antirrábica','20250124'),
    (509,N'46385312',N'OSO',N'Óctuple','20260310'),
    (510,N'42247313',N'JACK',N'Antirrábica','20260306'),
    (511,N'42247313',N'JACK',N'Quíntuple','20250215'),
    (512,N'76591779',N'TOM',N'Triple Felina','20250613'),
    (513,N'76591779',N'TOM',N'Leucemia Felina','20250626'),
    (514,N'76256491',N'GORDO',N'Antirrábica','20250804'),
    (515,N'76256491',N'GORDO',N'Óctuple','20260503'),
    (516,N'76256491',N'GORDO',N'Bordetella','20261014'),
    (517,N'59426425',N'DULCE',N'Antirrábica','20260402'),
    (518,N'59426425',N'DULCE',N'Séxtuple','20251027'),
    (519,N'74612560',N'PRINCESA',N'Antirrábica','20250105'),
    (520,N'74612560',N'PRINCESA',N'Quíntuple','20250301'),
    (521,N'75671636',N'BETO',N'Antirrábica','20260703'),
    (522,N'75239262',N'ZEUS',N'Antirrábica','20260518'),
    (523,N'75239262',N'ZEUS',N'Séxtuple','20260813'),
    (524,N'59028881',N'MILO',N'Quíntuple','20251229'),
    (525,N'31699451',N'SAMY',N'Antirrábica','20261018'),
    (526,N'31699451',N'SAMY',N'Óctuple','20260529'),
    (527,N'17226044',N'PANCHO',N'Antirrábica','20260130'),
    (528,N'17226044',N'PANCHO',N'Óctuple','20260531'),
    (529,N'17226044',N'PANCHO',N'Bordetella','20260725'),
    (530,N'36574152',N'ZEUS',N'Antirrábica','20260702'),
    (531,N'75647094',N'NALA',N'Antirrábica','20260418'),
    (532,N'75647094',N'NALA',N'Óctuple','20260914'),
    (533,N'75647094',N'NALA',N'Bordetella','20260924'),
    (534,N'35656927',N'ANGEL',N'Antirrábica','20250725'),
    (535,N'35656927',N'ANGEL',N'Séxtuple','20240807'),
    (536,N'35656927',N'ANGEL',N'Bordetella','20250204'),
    (537,N'70137831',N'IRIS',N'Antirrábica','20250818'),
    (538,N'70137831',N'IRIS',N'Séxtuple','20241016'),
    (539,N'70137831',N'IRIS',N'Bordetella','20240723'),
    (540,N'59831833',N'CHOCOLATE',N'Óctuple','20260826'),
    (541,N'51117751',N'LOLA',N'Antirrábica','20260512'),
    (542,N'51117751',N'LOLA',N'Óctuple','20250915'),
    (543,N'51117751',N'LOLA',N'Bordetella','20260408'),
    (544,N'70903475',N'DAISY',N'Antirrábica','20260401'),
    (545,N'70903475',N'DAISY',N'Óctuple','20250416'),
    (546,N'55566012',N'ANGEL',N'Antirrábica','20251212'),
    (547,N'55566012',N'ANGEL',N'Óctuple','20260629'),
    (548,N'29673082',N'LOLA',N'Antirrábica','20250727'),
    (549,N'53691734',N'FRODO',N'Antirrábica','20260811'),
    (550,N'53691734',N'FRODO',N'Quíntuple','20260605'),
    (551,N'53691734',N'FRODO',N'Bordetella','20260903'),
    (552,N'77035821',N'LASSIE',N'Antirrábica','20260713'),
    (553,N'70630649',N'LUCKY',N'Quíntuple','20250105'),
    (554,N'54688209',N'LOLA',N'Antirrábica','20250310'),
    (555,N'54688209',N'LOLA',N'Quíntuple','20240914'),
    (556,N'18930994',N'IRIS',N'Antirrábica','20260209'),
    (557,N'18930994',N'IRIS',N'Bordetella','20260905'),
    (558,N'25965976',N'PELUCHE',N'Antirrábica','20260914'),
    (559,N'25965976',N'PELUCHE',N'Triple Felina','20260912'),
    (560,N'61766196',N'SALEM',N'Antirrábica','20260502'),
    (561,N'61766196',N'SALEM',N'Triple Felina','20260724'),
    (562,N'13086150',N'OLIVER',N'Antirrábica','20240726'),
    (563,N'13086150',N'OLIVER',N'Triple Felina','20250428'),
    (564,N'13086150',N'OLIVER',N'Leucemia Felina','20240727'),
    (565,N'51949964',N'DAISY',N'Antirrábica','20240203'),
    (566,N'51949964',N'DAISY',N'Bordetella','20240521'),
    (567,N'23645765',N'SALEM',N'Antirrábica','20251006'),
    (568,N'23645765',N'SALEM',N'Triple Felina','20250917'),
    (569,N'23645765',N'SALEM',N'Leucemia Felina','20260629'),
    (570,N'25375175',N'ZEUS',N'Antirrábica','20250331'),
    (571,N'25375175',N'ZEUS',N'Séxtuple','20250831'),
    (572,N'27071065',N'MAYA',N'Antirrábica','20260415'),
    (573,N'27071065',N'MAYA',N'Quíntuple','20250502'),
    (574,N'21644472',N'TOBY',N'Antirrábica','20250313'),
    (575,N'21644472',N'TOBY',N'Óctuple','20251130'),
    (576,N'40181119',N'SIMBA',N'Antirrábica','20260915'),
    (577,N'40181119',N'SIMBA',N'Óctuple','20260807'),
    (578,N'74474444',N'CLEO',N'Antirrábica','20231213'),
    (579,N'74474444',N'CLEO',N'Triple Felina','20240718'),
    (580,N'62343309',N'KOBE',N'Antirrábica','20260903'),
    (581,N'62343309',N'KOBE',N'Óctuple','20260320'),
    (582,N'62343309',N'KOBE',N'Bordetella','20251219'),
    (583,N'42931532',N'BETO',N'Antirrábica','20250730'),
    (584,N'42931532',N'BETO',N'Quíntuple','20250429'),
    (585,N'25706155',N'DULCE',N'Antirrábica','20240909'),
    (586,N'25706155',N'DULCE',N'Quíntuple','20250302'),
    (587,N'51377678',N'FIRULAIS',N'Antirrábica','20260411'),
    (588,N'51377678',N'FIRULAIS',N'Séxtuple','20260531'),
    (589,N'15743784',N'JACK',N'Antirrábica','20251117'),
    (590,N'15743784',N'JACK',N'Quíntuple','20250322'),
    (591,N'15017483',N'OLIVER',N'Antirrábica','20251224'),
    (592,N'15017483',N'OLIVER',N'Triple Felina','20260617'),
    (593,N'15017483',N'OLIVER',N'Leucemia Felina','20260105'),
    (594,N'11840307',N'LASSIE',N'Antirrábica','20251204'),
    (595,N'32455567',N'SALEM',N'Antirrábica','20240726'),
    (596,N'32455567',N'SALEM',N'Triple Felina','20241229'),
    (597,N'49855592',N'MAYA',N'Antirrábica','20250919'),
    (598,N'49855592',N'MAYA',N'Óctuple','20250619'),
    (599,N'20118060',N'NALA',N'Antirrábica','20250114'),
    (600,N'20118060',N'NALA',N'Quíntuple','20240603'),
    (601,N'20118060',N'NALA',N'Bordetella','20250211'),
    (602,N'33784571',N'RUFO',N'Antirrábica','20251003'),
    (603,N'33784571',N'RUFO',N'Quíntuple','20251015'),
    (604,N'32807658',N'NEGRO',N'Quíntuple','20260609'),
    (605,N'11616589',N'IRIS',N'Antirrábica','20260809'),
    (606,N'11616589',N'IRIS',N'Quíntuple','20260521'),
    (607,N'11616589',N'IRIS',N'Bordetella','20260523'),
    (608,N'49009324',N'MOMO',N'Antirrábica','20250113'),
    (609,N'49009324',N'MOMO',N'Triple Felina','20251104'),
    (610,N'49009324',N'MOMO',N'Leucemia Felina','20250607'),
    (611,N'42557428',N'GORDO',N'Antirrábica','20250119'),
    (612,N'37577441',N'CANELA',N'Antirrábica','20250526'),
    (613,N'29570628',N'MAX',N'Antirrábica','20240505'),
    (614,N'69453138',N'OSO',N'Antirrábica','20251105'),
    (615,N'69453138',N'OSO',N'Quíntuple','20260402'),
    (616,N'56377779',N'LOLA',N'Antirrábica','20251223'),
    (617,N'56377779',N'LOLA',N'Séxtuple','20260705'),
    (618,N'56377779',N'LOLA',N'Bordetella','20260130'),
    (619,N'26823875',N'DAISY',N'Antirrábica','20260217'),
    (620,N'26823875',N'DAISY',N'Séxtuple','20250309'),
    (621,N'52890766',N'BOLITA',N'Antirrábica','20231228'),
    (622,N'52890766',N'BOLITA',N'Leucemia Felina','20241003'),
    (623,N'67650328',N'PELUCHE',N'Antirrábica','20241011'),
    (624,N'67650328',N'PELUCHE',N'Triple Felina','20231119'),
    (625,N'74264265',N'ROCKY',N'Antirrábica','20240516'),
    (626,N'74264265',N'ROCKY',N'Quíntuple','20240514'),
    (627,N'71620003',N'GARFIELD',N'Antirrábica','20240520'),
    (628,N'71620003',N'GARFIELD',N'Triple Felina','20240509'),
    (629,N'48236792',N'MIA',N'Antirrábica','20250705'),
    (630,N'16513835',N'NUBE',N'Antirrábica','20250131'),
    (631,N'34736313',N'PELUCHE',N'Antirrábica','20240404'),
    (632,N'34736313',N'PELUCHE',N'Triple Felina','20241121'),
    (633,N'64751698',N'CHOCOLATE',N'Antirrábica','20250616'),
    (634,N'64751698',N'CHOCOLATE',N'Óctuple','20250419'),
    (635,N'63877899',N'MISHI',N'Antirrábica','20261007'),
    (636,N'63877899',N'MISHI',N'Triple Felina','20260718'),
    (637,N'63877899',N'MISHI',N'Leucemia Felina','20260917'),
    (638,N'64104769',N'DAISY',N'Antirrábica','20260917'),
    (639,N'64104769',N'DAISY',N'Óctuple','20260714'),
    (640,N'12271098',N'BOLITA',N'Antirrábica','20260811'),
    (641,N'19985300',N'TYSON',N'Antirrábica','20240129'),
    (642,N'19985300',N'TYSON',N'Séxtuple','20250101'),
    (643,N'19985300',N'TYSON',N'Bordetella','20241219'),
    (644,N'50100916',N'NEGRO',N'Antirrábica','20251009'),
    (645,N'10713936',N'NUBE',N'Antirrábica','20260815'),
    (646,N'10713936',N'NUBE',N'Triple Felina','20260925'),
    (647,N'71323251',N'TRUENO',N'Quíntuple','20260531'),
    (648,N'67429105',N'KIRA',N'Antirrábica','20250717'),
    (649,N'67429105',N'KIRA',N'Séxtuple','20250316'),
    (650,N'20526105',N'FIRULAIS',N'Antirrábica','20240116'),
    (651,N'20526105',N'FIRULAIS',N'Óctuple','20240411'),
    (652,N'74137343',N'TOM',N'Antirrábica','20250202'),
    (653,N'74137343',N'TOM',N'Triple Felina','20251125'),
    (654,N'31150771',N'CANELA',N'Antirrábica','20240211'),
    (655,N'31150771',N'CANELA',N'Quíntuple','20241226'),
    (656,N'69110737',N'MICHI',N'Antirrábica','20240425'),
    (657,N'69110737',N'MICHI',N'Triple Felina','20250113'),
    (658,N'63051978',N'FRODO',N'Antirrábica','20260612'),
    (659,N'52488169',N'ZEUS',N'Antirrábica','20250426'),
    (660,N'52488169',N'ZEUS',N'Óctuple','20250704'),
    (661,N'53922301',N'LUNA',N'Antirrábica','20260706'),
    (662,N'53922301',N'LUNA',N'Triple Felina','20260406'),
    (663,N'53922301',N'LUNA',N'Leucemia Felina','20260522'),
    (664,N'53078110',N'PEPE',N'Antirrábica','20251010'),
    (665,N'53078110',N'PEPE',N'Séxtuple','20250129'),
    (666,N'41349952',N'PEPE',N'Séxtuple','20260620'),
    (667,N'10640688',N'CHOCOLATE',N'Antirrábica','20250306'),
    (668,N'10640688',N'CHOCOLATE',N'Óctuple','20250406'),
    (669,N'10640688',N'CHOCOLATE',N'Bordetella','20250820'),
    (670,N'48317019',N'PRINCESA',N'Antirrábica','20260228'),
    (671,N'48317019',N'PRINCESA',N'Quíntuple','20260716'),
    (672,N'64169098',N'NALA',N'Antirrábica','20260413'),
    (673,N'64169098',N'NALA',N'Triple Felina','20260808'),
    (674,N'55719212',N'PANCHO',N'Antirrábica','20251216'),
    (675,N'55719212',N'PANCHO',N'Óctuple','20260617'),
    (676,N'70414162',N'CANELA',N'Antirrábica','20250819'),
    (677,N'70414162',N'CANELA',N'Séxtuple','20260121'),
    (678,N'54109713',N'NEGRO',N'Antirrábica','20260422'),
    (679,N'54109713',N'NEGRO',N'Óctuple','20250802'),
    (680,N'54109713',N'NEGRO',N'Bordetella','20251203'),
    (681,N'52525332',N'BOBBY',N'Antirrábica','20260312'),
    (682,N'52525332',N'BOBBY',N'Quíntuple','20260804'),
    (683,N'52525332',N'BOBBY',N'Bordetella','20260708'),
    (684,N'51725842',N'THOR',N'Antirrábica','20250626'),
    (685,N'51725842',N'THOR',N'Óctuple','20240308'),
    (686,N'15431999',N'MOMO',N'Antirrábica','20260810'),
    (687,N'15431999',N'MOMO',N'Triple Felina','20260509'),
    (688,N'15431999',N'MOMO',N'Leucemia Felina','20261012'),
    (689,N'56906428',N'ROCCO',N'Antirrábica','20231027'),
    (690,N'56906428',N'ROCCO',N'Quíntuple','20240318'),
    (691,N'37110833',N'KOBE',N'Antirrábica','20251003'),
    (692,N'37110833',N'KOBE',N'Séxtuple','20250819'),
    (693,N'55742771',N'NALA',N'Antirrábica','20260815'),
    (694,N'55742771',N'NALA',N'Óctuple','20260823'),
    (695,N'11052950',N'TOBY',N'Antirrábica','20260829'),
    (696,N'11052950',N'TOBY',N'Óctuple','20251123'),
    (697,N'73855347',N'TRUENO',N'Quíntuple','20260701'),
    (698,N'42126567',N'PRINCESA',N'Antirrábica','20250519'),
    (699,N'42126567',N'PRINCESA',N'Óctuple','20250617'),
    (700,N'59006174',N'ANGEL',N'Antirrábica','20240116'),
    (701,N'59006174',N'ANGEL',N'Quíntuple','20231202'),
    (702,N'35548111',N'NALA',N'Antirrábica','20260912'),
    (703,N'35548111',N'NALA',N'Bordetella','20260918'),
    (704,N'67299054',N'KIRA',N'Antirrábica','20240403'),
    (705,N'67299054',N'KIRA',N'Bordetella','20240806'),
    (706,N'25377814',N'OSO',N'Séxtuple','20240917'),
    (707,N'60470506',N'TOÑO',N'Antirrábica','20240912'),
    (708,N'60470506',N'TOÑO',N'Séxtuple','20240709'),
    (709,N'30736673',N'ZEUS',N'Antirrábica','20250213'),
    (710,N'30736673',N'ZEUS',N'Séxtuple','20250125'),
    (711,N'18745124',N'OSO',N'Antirrábica','20260531'),
    (712,N'18745124',N'OSO',N'Óctuple','20260613'),
    (713,N'29971964',N'SAMY',N'Antirrábica','20240927'),
    (714,N'29971964',N'SAMY',N'Óctuple','20250504'),
    (715,N'59569048',N'ANGEL',N'Antirrábica','20241123'),
    (716,N'59569048',N'ANGEL',N'Séxtuple','20241116'),
    (717,N'33968729',N'CANELA',N'Antirrábica','20250822'),
    (718,N'33968729',N'CANELA',N'Óctuple','20250822'),
    (719,N'58051201',N'MAX',N'Antirrábica','20250522'),
    (720,N'22556713',N'THOR',N'Antirrábica','20260808'),
    (721,N'22556713',N'THOR',N'Séxtuple','20251029'),
    (722,N'28492007',N'RUFO',N'Antirrábica','20250705'),
    (723,N'28492007',N'RUFO',N'Séxtuple','20260608'),
    (724,N'64337456',N'PELUSA',N'Antirrábica','20260301'),
    (725,N'64337456',N'PELUSA',N'Séxtuple','20260913'),
    (726,N'64337456',N'PELUSA',N'Bordetella','20260927'),
    (727,N'60029895',N'KOBE',N'Antirrábica','20241125'),
    (728,N'60029895',N'KOBE',N'Óctuple','20250802'),
    (729,N'60029895',N'KOBE',N'Bordetella','20251119'),
    (730,N'35678389',N'MANCHAS',N'Antirrábica','20260502'),
    (731,N'35678389',N'MANCHAS',N'Quíntuple','20260308'),
    (732,N'50302233',N'TOBY',N'Óctuple','20251231'),
    (733,N'55925799',N'PANCHO',N'Antirrábica','20250211'),
    (734,N'55925799',N'PANCHO',N'Óctuple','20250302'),
    (735,N'75686213',N'TOM',N'Antirrábica','20250118'),
    (736,N'18398391',N'KOBE',N'Antirrábica','20260403'),
    (737,N'18398391',N'KOBE',N'Quíntuple','20260801'),
    (738,N'17909041',N'FIRULAIS',N'Antirrábica','20231219'),
    (739,N'17909041',N'FIRULAIS',N'Bordetella','20240221'),
    (740,N'42436203',N'ROCKY',N'Antirrábica','20261014'),
    (741,N'53476237',N'PELUSA',N'Antirrábica','20260529'),
    (742,N'53476237',N'PELUSA',N'Óctuple','20260405'),
    (743,N'47821988',N'PANCHO',N'Quíntuple','20260804'),
    (744,N'79413472',N'JACK',N'Antirrábica','20260424'),
    (745,N'79413472',N'JACK',N'Óctuple','20260511'),
    (746,N'79413472',N'JACK',N'Bordetella','20260818'),
    (747,N'46689266',N'COCO',N'Antirrábica','20260811'),
    (748,N'46689266',N'COCO',N'Óctuple','20261012'),
    (749,N'19251762',N'COCO',N'Antirrábica','20261002'),
    (750,N'19251762',N'COCO',N'Séxtuple','20260504'),
    (751,N'19251762',N'COCO',N'Bordetella','20260617'),
    (752,N'63346839',N'ROCCO',N'Antirrábica','20260414'),
    (753,N'63346839',N'ROCCO',N'Bordetella','20251201'),
    (754,N'14396892',N'JACK',N'Antirrábica','20260507'),
    (755,N'14396892',N'JACK',N'Quíntuple','20251115'),
    (756,N'31252930',N'GATUBELA',N'Antirrábica','20251007'),
    (757,N'31252930',N'GATUBELA',N'Triple Felina','20250115'),
    (758,N'59717244',N'OSO',N'Quíntuple','20260721'),
    (759,N'17586899',N'CHISPA',N'Antirrábica','20250122'),
    (760,N'17586899',N'CHISPA',N'Quíntuple','20250729'),
    (761,N'63711330',N'SIMBA',N'Antirrábica','20260307'),
    (762,N'33460112',N'LUCKY',N'Antirrábica','20260919'),
    (763,N'24858882',N'GOKU',N'Antirrábica','20260821'),
    (764,N'24858882',N'GOKU',N'Óctuple','20260815'),
    (765,N'21528464',N'NIEVE',N'Antirrábica','20240827'),
    (766,N'21528464',N'NIEVE',N'Triple Felina','20240917'),
    (767,N'72306053',N'SIMBA',N'Antirrábica','20241120'),
    (768,N'72306053',N'SIMBA',N'Quíntuple','20240109'),
    (769,N'29368390',N'FRODO',N'Séxtuple','20250205'),
    (770,N'66492993',N'CANELA',N'Antirrábica','20240827'),
    (771,N'66492993',N'CANELA',N'Óctuple','20240531'),
    (772,N'66492993',N'CANELA',N'Bordetella','20240622'),
    (773,N'35790401',N'KOBE',N'Antirrábica','20260704'),
    (774,N'35790401',N'KOBE',N'Óctuple','20260822'),
    (775,N'21613431',N'ZEUS',N'Antirrábica','20250903'),
    (776,N'21613431',N'ZEUS',N'Bordetella','20251116'),
    (777,N'23524913',N'JACK',N'Antirrábica','20261013'),
    (778,N'23524913',N'JACK',N'Séxtuple','20261013'),
    (779,N'40672459',N'IRIS',N'Antirrábica','20250629'),
    (780,N'40672459',N'IRIS',N'Quíntuple','20250807'),
    (781,N'53971722',N'PEPE',N'Antirrábica','20240830'),
    (782,N'53971722',N'PEPE',N'Séxtuple','20250216'),
    (783,N'34031162',N'KOBE',N'Antirrábica','20240412'),
    (784,N'34031162',N'KOBE',N'Séxtuple','20231228'),
    (785,N'30287293',N'SIMBA',N'Antirrábica','20251019'),
    (786,N'30287293',N'SIMBA',N'Triple Felina','20250212'),
    (787,N'78149928',N'DAISY',N'Antirrábica','20250205'),
    (788,N'78149928',N'DAISY',N'Bordetella','20250801'),
    (789,N'24971231',N'GORDO',N'Antirrábica','20250602'),
    (790,N'24971231',N'GORDO',N'Séxtuple','20250502'),
    (791,N'53512462',N'TOMASA',N'Antirrábica','20260110'),
    (792,N'53512462',N'TOMASA',N'Triple Felina','20260828'),
    (793,N'53512462',N'TOMASA',N'Leucemia Felina','20251227'),
    (794,N'43230996',N'PELUSA',N'Antirrábica','20260930'),
    (795,N'43230996',N'PELUSA',N'Óctuple','20261013'),
    (796,N'58800955',N'CANELA',N'Antirrábica','20260815'),
    (797,N'58800955',N'CANELA',N'Quíntuple','20261014'),
    (798,N'63079326',N'FIRULAIS',N'Antirrábica','20240304'),
    (799,N'63079326',N'FIRULAIS',N'Quíntuple','20240702'),
    (800,N'38741904',N'NUBE',N'Antirrábica','20250124')
) v(seq, dni, mascota, vacuna, fecha)
JOIN dbo.CLIENTE c  ON c.dni = v.dni
JOIN dbo.MASCOTA m  ON m.id_cliente = c.id_cliente AND m.nombre = v.mascota
JOIN dbo.VACUNA  vc ON vc.nombre = v.vacuna
WHERE NOT EXISTS (SELECT 1 FROM dbo.VACUNACION x WHERE x.id_mascota = m.id_mascota AND x.id_vacuna = vc.id_vacuna AND x.fecha_aplicacion = v.fecha)
ORDER BY v.seq;

INSERT INTO dbo.VACUNACION (fecha_aplicacion, id_mascota, id_vacuna, ESTADO)
SELECT v.fecha, m.id_mascota, vc.id_vacuna, 1
FROM (VALUES
    (801,N'38741904',N'NUBE',N'Triple Felina','20250216'),
    (802,N'32876946',N'LASSIE',N'Antirrábica','20260312'),
    (803,N'32876946',N'LASSIE',N'Séxtuple','20241221'),
    (804,N'32876946',N'LASSIE',N'Bordetella','20260310'),
    (805,N'19556608',N'KOBE',N'Quíntuple','20240319'),
    (806,N'71603205',N'FIONA',N'Antirrábica','20260912'),
    (807,N'71603205',N'FIONA',N'Séxtuple','20260916'),
    (808,N'19668758',N'TITAN',N'Antirrábica','20231117'),
    (809,N'19668758',N'TITAN',N'Quíntuple','20230926'),
    (810,N'21429600',N'FRODO',N'Antirrábica','20251124'),
    (811,N'21429600',N'FRODO',N'Séxtuple','20260302'),
    (812,N'51674644',N'RUFO',N'Antirrábica','20250316'),
    (813,N'51674644',N'RUFO',N'Bordetella','20251020'),
    (814,N'25449326',N'SAMY',N'Antirrábica','20251016'),
    (815,N'25449326',N'SAMY',N'Óctuple','20250808'),
    (816,N'53168610',N'IRIS',N'Antirrábica','20231023'),
    (817,N'53168610',N'IRIS',N'Séxtuple','20241018'),
    (818,N'53879689',N'THOR',N'Antirrábica','20260421'),
    (819,N'53879689',N'THOR',N'Séxtuple','20251020'),
    (820,N'53879689',N'THOR',N'Bordetella','20260311'),
    (821,N'74112721',N'MINA',N'Antirrábica','20260414'),
    (822,N'72010722',N'FRODO',N'Antirrábica','20240603'),
    (823,N'72010722',N'FRODO',N'Óctuple','20231105'),
    (824,N'74835983',N'MANCHAS',N'Antirrábica','20251027'),
    (825,N'74835983',N'MANCHAS',N'Óctuple','20261011'),
    (826,N'59301459',N'PELUSA',N'Antirrábica','20260628'),
    (827,N'59301459',N'PELUSA',N'Óctuple','20260704'),
    (828,N'37735621',N'TRUENO',N'Quíntuple','20250202'),
    (829,N'46559169',N'TOÑO',N'Antirrábica','20260505'),
    (830,N'46559169',N'TOÑO',N'Séxtuple','20250913'),
    (831,N'46559169',N'TOÑO',N'Bordetella','20260524'),
    (832,N'52228506',N'SIMBA',N'Antirrábica','20260109'),
    (833,N'50192178',N'BETO',N'Antirrábica','20241208'),
    (834,N'50192178',N'BETO',N'Quíntuple','20241118'),
    (835,N'22231444',N'CHOCOLATE',N'Antirrábica','20250504'),
    (836,N'22231444',N'CHOCOLATE',N'Quíntuple','20240702'),
    (837,N'44693578',N'TRUENO',N'Antirrábica','20250107'),
    (838,N'44693578',N'TRUENO',N'Óctuple','20251219'),
    (839,N'46526469',N'TOBY',N'Séxtuple','20240502'),
    (840,N'46526469',N'TOBY',N'Bordetella','20231129'),
    (841,N'51273753',N'ROCCO',N'Antirrábica','20240401'),
    (842,N'51273753',N'ROCCO',N'Óctuple','20240815'),
    (843,N'46544333',N'BOLITA',N'Antirrábica','20240118'),
    (844,N'46544333',N'BOLITA',N'Triple Felina','20240211'),
    (845,N'46544333',N'BOLITA',N'Leucemia Felina','20240313'),
    (846,N'24269926',N'FIONA',N'Antirrábica','20261011'),
    (847,N'24269926',N'FIONA',N'Óctuple','20261014'),
    (848,N'31837408',N'ROCKY',N'Óctuple','20240516'),
    (849,N'31837408',N'ROCKY',N'Bordetella','20241031'),
    (850,N'10144493',N'MANCHAS',N'Quíntuple','20260914'),
    (851,N'69046078',N'RUFO',N'Antirrábica','20250507'),
    (852,N'69046078',N'RUFO',N'Quíntuple','20251020'),
    (853,N'69046078',N'RUFO',N'Bordetella','20251129'),
    (854,N'73661760',N'HACHI',N'Antirrábica','20251209'),
    (855,N'75589105',N'TYSON',N'Antirrábica','20261018'),
    (856,N'75589105',N'TYSON',N'Séxtuple','20261015'),
    (857,N'75589105',N'TYSON',N'Bordetella','20261014'),
    (858,N'59538076',N'OSO',N'Antirrábica','20250305'),
    (859,N'59538076',N'OSO',N'Séxtuple','20250622'),
    (860,N'62809781',N'BOLITA',N'Antirrábica','20261009'),
    (861,N'62809781',N'BOLITA',N'Triple Felina','20260801'),
    (862,N'61857513',N'THOR',N'Antirrábica','20241107'),
    (863,N'61857513',N'THOR',N'Séxtuple','20241128'),
    (864,N'59766259',N'JACK',N'Antirrábica','20260603'),
    (865,N'59766259',N'JACK',N'Séxtuple','20260809'),
    (866,N'64151263',N'KOBE',N'Antirrábica','20260723'),
    (867,N'64151263',N'KOBE',N'Óctuple','20250821'),
    (868,N'34182770',N'ROCKY',N'Antirrábica','20250417'),
    (869,N'34182770',N'ROCKY',N'Bordetella','20260203'),
    (870,N'50579707',N'NALA',N'Antirrábica','20240523'),
    (871,N'34575486',N'NEGRO',N'Antirrábica','20260321'),
    (872,N'34575486',N'NEGRO',N'Séxtuple','20260703'),
    (873,N'58339728',N'CANELA',N'Antirrábica','20250110'),
    (874,N'58339728',N'CANELA',N'Séxtuple','20251017'),
    (875,N'58339728',N'CANELA',N'Bordetella','20241011'),
    (876,N'43322872',N'MAX',N'Antirrábica','20250629'),
    (877,N'32853815',N'KIRA',N'Antirrábica','20260908'),
    (878,N'56203698',N'ANGEL',N'Antirrábica','20260724'),
    (879,N'56203698',N'ANGEL',N'Quíntuple','20260414'),
    (880,N'30604007',N'JACK',N'Antirrábica','20250515'),
    (881,N'78008395',N'MOMO',N'Antirrábica','20260305'),
    (882,N'78008395',N'MOMO',N'Triple Felina','20251011'),
    (883,N'78008395',N'MOMO',N'Leucemia Felina','20250701'),
    (884,N'15580650',N'LOLA',N'Antirrábica','20260923'),
    (885,N'64671867',N'LUNA',N'Antirrábica','20260828'),
    (886,N'64671867',N'LUNA',N'Quíntuple','20260911'),
    (887,N'43626582',N'CANELA',N'Antirrábica','20250520'),
    (888,N'43626582',N'CANELA',N'Óctuple','20250905'),
    (889,N'52099908',N'LUCKY',N'Óctuple','20260722'),
    (890,N'51517847',N'FIONA',N'Óctuple','20260727'),
    (891,N'45264687',N'MOMO',N'Triple Felina','20251019'),
    (892,N'45264687',N'MOMO',N'Leucemia Felina','20260127'),
    (893,N'25183208',N'LUNA',N'Antirrábica','20260716'),
    (894,N'25183208',N'LUNA',N'Triple Felina','20261009'),
    (895,N'25183208',N'LUNA',N'Leucemia Felina','20260115'),
    (896,N'59719658',N'ZEUS',N'Antirrábica','20260110'),
    (897,N'38518046',N'LASSIE',N'Antirrábica','20261003'),
    (898,N'38518046',N'LASSIE',N'Séxtuple','20260606'),
    (899,N'20902456',N'IRIS',N'Quíntuple','20250131'),
    (900,N'19961100',N'LASSIE',N'Antirrábica','20240719'),
    (901,N'19961100',N'LASSIE',N'Quíntuple','20240419'),
    (902,N'26734012',N'COCO',N'Antirrábica','20260530'),
    (903,N'26734012',N'COCO',N'Óctuple','20260531'),
    (904,N'49265947',N'LASSIE',N'Antirrábica','20260509'),
    (905,N'49265947',N'LASSIE',N'Séxtuple','20260703'),
    (906,N'13500013',N'FELIX',N'Antirrábica','20230919'),
    (907,N'13500013',N'FELIX',N'Leucemia Felina','20240325'),
    (908,N'67532430',N'RUFO',N'Antirrábica','20260724'),
    (909,N'67532430',N'RUFO',N'Séxtuple','20260407'),
    (910,N'75720759',N'RUFO',N'Antirrábica','20260812'),
    (911,N'26666465',N'ROCKY',N'Antirrábica','20260401'),
    (912,N'26666465',N'ROCKY',N'Óctuple','20260316'),
    (913,N'15637712',N'ROCKY',N'Antirrábica','20260701'),
    (914,N'15637712',N'ROCKY',N'Quíntuple','20260329'),
    (915,N'72899329',N'GOKU',N'Antirrábica','20260501'),
    (916,N'22206641',N'SIMBA',N'Antirrábica','20251023'),
    (917,N'22206641',N'SIMBA',N'Quíntuple','20251030'),
    (918,N'11671445',N'CHISPA',N'Antirrábica','20251210'),
    (919,N'11671445',N'CHISPA',N'Óctuple','20260609'),
    (920,N'43608951',N'ZEUS',N'Antirrábica','20251029'),
    (921,N'46984541',N'BOLITA',N'Antirrábica','20250316'),
    (922,N'46984541',N'BOLITA',N'Triple Felina','20260319'),
    (923,N'61296075',N'DAISY',N'Quíntuple','20240525'),
    (924,N'13559973',N'FIONA',N'Antirrábica','20250202'),
    (925,N'13559973',N'FIONA',N'Quíntuple','20240519'),
    (926,N'13559973',N'FIONA',N'Bordetella','20240829'),
    (927,N'54618219',N'PRINCESA',N'Antirrábica','20260814'),
    (928,N'38807064',N'PELUCHE',N'Triple Felina','20240929'),
    (929,N'32743777',N'ROCCO',N'Antirrábica','20250401'),
    (930,N'32743777',N'ROCCO',N'Óctuple','20250826'),
    (931,N'13537040',N'NALA',N'Antirrábica','20241217'),
    (932,N'13537040',N'NALA',N'Óctuple','20240916'),
    (933,N'69787068',N'JACK',N'Antirrábica','20260722'),
    (934,N'69787068',N'JACK',N'Séxtuple','20260417'),
    (935,N'62016082',N'CANELA',N'Antirrábica','20260630'),
    (936,N'62016082',N'CANELA',N'Séxtuple','20260821'),
    (937,N'54809394',N'LUCKY',N'Antirrábica','20250414'),
    (938,N'54809394',N'LUCKY',N'Séxtuple','20250112'),
    (939,N'49716647',N'OSO',N'Antirrábica','20260529'),
    (940,N'49716647',N'OSO',N'Séxtuple','20260120'),
    (941,N'76236844',N'GORDO',N'Antirrábica','20230916'),
    (942,N'76236844',N'GORDO',N'Óctuple','20240530'),
    (943,N'41371634',N'MINNIE',N'Antirrábica','20241203'),
    (944,N'41371634',N'MINNIE',N'Triple Felina','20241118'),
    (945,N'41462776',N'ROCKY',N'Antirrábica','20260225'),
    (946,N'63249717',N'BOLITA',N'Antirrábica','20250504'),
    (947,N'63249717',N'BOLITA',N'Triple Felina','20260504'),
    (948,N'17301708',N'CHOCOLATE',N'Antirrábica','20251116'),
    (949,N'17301708',N'CHOCOLATE',N'Quíntuple','20250125'),
    (950,N'78151815',N'MANCHAS',N'Antirrábica','20260519'),
    (951,N'78151815',N'MANCHAS',N'Óctuple','20250918'),
    (952,N'41519908',N'COCO',N'Antirrábica','20240822'),
    (953,N'41519908',N'COCO',N'Quíntuple','20241219'),
    (954,N'14532760',N'MAX',N'Antirrábica','20251026'),
    (955,N'25807541',N'CANELA',N'Antirrábica','20240821'),
    (956,N'21272134',N'CLEO',N'Antirrábica','20251103'),
    (957,N'21272134',N'CLEO',N'Triple Felina','20250210'),
    (958,N'21272134',N'CLEO',N'Leucemia Felina','20250520'),
    (959,N'27773440',N'PEPE',N'Antirrábica','20231220'),
    (960,N'27773440',N'PEPE',N'Séxtuple','20231127'),
    (961,N'11850014',N'COCO',N'Antirrábica','20260703'),
    (962,N'11850014',N'COCO',N'Séxtuple','20251230'),
    (963,N'11850014',N'COCO',N'Bordetella','20251106'),
    (964,N'21931334',N'TOMASA',N'Triple Felina','20250525'),
    (965,N'52709584',N'DAISY',N'Antirrábica','20260615'),
    (966,N'52709584',N'DAISY',N'Séxtuple','20260725'),
    (967,N'52709584',N'DAISY',N'Bordetella','20260921'),
    (968,N'54072988',N'ROCCO',N'Quíntuple','20261015'),
    (969,N'54072988',N'ROCCO',N'Bordetella','20260810'),
    (970,N'55837540',N'OLIVER',N'Antirrábica','20241227'),
    (971,N'55837540',N'OLIVER',N'Triple Felina','20240828'),
    (972,N'55837540',N'OLIVER',N'Leucemia Felina','20240708'),
    (973,N'73558850',N'NALA',N'Antirrábica','20230913'),
    (974,N'73558850',N'NALA',N'Quíntuple','20240509'),
    (975,N'34482179',N'GORDO',N'Antirrábica','20260301'),
    (976,N'34482179',N'GORDO',N'Óctuple','20250924'),
    (977,N'34482179',N'GORDO',N'Bordetella','20250922'),
    (978,N'50363445',N'LASSIE',N'Antirrábica','20240329'),
    (979,N'50363445',N'LASSIE',N'Óctuple','20230813'),
    (980,N'69119383',N'MISHI',N'Antirrábica','20250718'),
    (981,N'69119383',N'MISHI',N'Triple Felina','20250924'),
    (982,N'69119383',N'MISHI',N'Leucemia Felina','20260208'),
    (983,N'19875249',N'GORDO',N'Antirrábica','20250818'),
    (984,N'22474786',N'MISHI',N'Triple Felina','20250528'),
    (985,N'35657041',N'TIGRE',N'Antirrábica','20260216'),
    (986,N'35657041',N'TIGRE',N'Triple Felina','20260507'),
    (987,N'35657041',N'TIGRE',N'Leucemia Felina','20260919'),
    (988,N'16162308',N'ZEUS',N'Antirrábica','20240330'),
    (989,N'16162308',N'ZEUS',N'Quíntuple','20230925'),
    (990,N'13241297',N'SIMBA',N'Antirrábica','20241017'),
    (991,N'28507286',N'MINA',N'Antirrábica','20260507'),
    (992,N'28507286',N'MINA',N'Triple Felina','20260527'),
    (993,N'28507286',N'MINA',N'Leucemia Felina','20260817'),
    (994,N'45747626',N'MINA',N'Antirrábica','20260927'),
    (995,N'45747626',N'MINA',N'Triple Felina','20260830'),
    (996,N'45747626',N'MINA',N'Leucemia Felina','20260621'),
    (997,N'65503322',N'DAISY',N'Antirrábica','20250813'),
    (998,N'65503322',N'DAISY',N'Séxtuple','20250320'),
    (999,N'65503322',N'DAISY',N'Bordetella','20250830'),
    (1000,N'71207207',N'PANCHO',N'Antirrábica','20231024'),
    (1001,N'71207207',N'PANCHO',N'Quíntuple','20240702'),
    (1002,N'67182398',N'MICHI',N'Antirrábica','20251029'),
    (1003,N'33684231',N'JACK',N'Antirrábica','20251205'),
    (1004,N'29670750',N'DAISY',N'Antirrábica','20250211'),
    (1005,N'29670750',N'DAISY',N'Óctuple','20250718'),
    (1006,N'61509430',N'NEGRO',N'Antirrábica','20231122'),
    (1007,N'61509430',N'NEGRO',N'Séxtuple','20240703'),
    (1008,N'38691854',N'DAISY',N'Antirrábica','20241225'),
    (1009,N'49119649',N'HACHI',N'Antirrábica','20260930'),
    (1010,N'49119649',N'HACHI',N'Óctuple','20260817'),
    (1011,N'14172520',N'TOM',N'Antirrábica','20251231'),
    (1012,N'14172520',N'TOM',N'Triple Felina','20260325'),
    (1013,N'14172520',N'TOM',N'Leucemia Felina','20261017'),
    (1014,N'61100472',N'HACHI',N'Antirrábica','20251221'),
    (1015,N'61100472',N'HACHI',N'Quíntuple','20251127'),
    (1016,N'61100472',N'HACHI',N'Bordetella','20260308'),
    (1017,N'72037062',N'ROCCO',N'Antirrábica','20260201'),
    (1018,N'72037062',N'ROCCO',N'Quíntuple','20260915'),
    (1019,N'73667704',N'NALA',N'Antirrábica','20251107'),
    (1020,N'73667704',N'NALA',N'Bordetella','20251030'),
    (1021,N'13429530',N'KIRA',N'Bordetella','20240423'),
    (1022,N'14651562',N'MANCHAS',N'Antirrábica','20260519'),
    (1023,N'14651562',N'MANCHAS',N'Quíntuple','20260530'),
    (1024,N'14651562',N'MANCHAS',N'Bordetella','20260602'),
    (1025,N'42758335',N'MAYA',N'Antirrábica','20251014'),
    (1026,N'42758335',N'MAYA',N'Quíntuple','20250503'),
    (1027,N'17834268',N'NIEVE',N'Antirrábica','20250928'),
    (1028,N'17834268',N'NIEVE',N'Triple Felina','20260422'),
    (1029,N'32384647',N'NEGRO',N'Quíntuple','20260913'),
    (1030,N'64355710',N'ANGEL',N'Antirrábica','20260508'),
    (1031,N'64355710',N'ANGEL',N'Quíntuple','20260216'),
    (1032,N'57704381',N'TOÑO',N'Antirrábica','20260630'),
    (1033,N'57704381',N'TOÑO',N'Óctuple','20261003'),
    (1034,N'66111417',N'NALA',N'Antirrábica','20240825'),
    (1035,N'66111417',N'NALA',N'Bordetella','20250227'),
    (1036,N'33668261',N'MOCHA',N'Antirrábica','20260131'),
    (1037,N'33668261',N'MOCHA',N'Séxtuple','20260222'),
    (1038,N'29038246',N'PEPE',N'Antirrábica','20260928'),
    (1039,N'29038246',N'PEPE',N'Quíntuple','20261009'),
    (1040,N'34544583',N'MINNIE',N'Triple Felina','20260508'),
    (1041,N'19011623',N'ROCCO',N'Antirrábica','20260709'),
    (1042,N'19011623',N'ROCCO',N'Óctuple','20260331'),
    (1043,N'65248947',N'NALA',N'Antirrábica','20260626'),
    (1044,N'74302115',N'NIEVE',N'Antirrábica','20260402'),
    (1045,N'74302115',N'NIEVE',N'Triple Felina','20260823'),
    (1046,N'74302115',N'NIEVE',N'Leucemia Felina','20261011'),
    (1047,N'28432775',N'BETO',N'Antirrábica','20250222'),
    (1048,N'28432775',N'BETO',N'Óctuple','20250514'),
    (1049,N'66512412',N'CANELA',N'Séxtuple','20260704'),
    (1050,N'31608170',N'MOMO',N'Antirrábica','20260620'),
    (1051,N'31608170',N'MOMO',N'Triple Felina','20260702'),
    (1052,N'52105566',N'CHISPA',N'Antirrábica','20260920'),
    (1053,N'52105566',N'CHISPA',N'Séxtuple','20260501'),
    (1054,N'79882916',N'JACK',N'Séxtuple','20261009'),
    (1055,N'56908733',N'SIMBA',N'Antirrábica','20261007'),
    (1056,N'56908733',N'SIMBA',N'Quíntuple','20260920'),
    (1057,N'56908733',N'SIMBA',N'Bordetella','20260912'),
    (1058,N'47288941',N'TITAN',N'Antirrábica','20260706'),
    (1059,N'47288941',N'TITAN',N'Quíntuple','20260909'),
    (1060,N'34651232',N'MOCHA',N'Antirrábica','20260214'),
    (1061,N'34651232',N'MOCHA',N'Quíntuple','20260731'),
    (1062,N'34651232',N'MOCHA',N'Bordetella','20260219')
) v(seq, dni, mascota, vacuna, fecha)
JOIN dbo.CLIENTE c  ON c.dni = v.dni
JOIN dbo.MASCOTA m  ON m.id_cliente = c.id_cliente AND m.nombre = v.mascota
JOIN dbo.VACUNA  vc ON vc.nombre = v.vacuna
WHERE NOT EXISTS (SELECT 1 FROM dbo.VACUNACION x WHERE x.id_mascota = m.id_mascota AND x.id_vacuna = vc.id_vacuna AND x.fecha_aplicacion = v.fecha)
ORDER BY v.seq;

COMMIT TRANSACTION;
PRINT 'Datos insertados correctamente.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

SELECT (SELECT COUNT(*) FROM dbo.CLIENTE) AS clientes, (SELECT COUNT(*) FROM dbo.MASCOTA) AS mascotas,
       (SELECT COUNT(*) FROM dbo.VACUNA) AS vacunas, (SELECT COUNT(*) FROM dbo.CITA) AS citas,
       (SELECT COUNT(*) FROM dbo.VACUNACION) AS vacunaciones;
GO


/* ==========================================================================
   AMPLIACION COMERCIAL DE PETYLAB
   Servicios, productos, promociones, pagos, inventario y metas de ventas.
   Se ejecuta despues de cargar clientes, mascotas y citas.
   Es idempotente: se puede ejecutar varias veces sin duplicar datos.
   ========================================================================== */
USE PETYLAB;
GO

SET NOCOUNT ON;
GO

-- ============================================================
-- 1. CATALOGOS
-- ============================================================
IF OBJECT_ID(N'dbo.SERVICIO', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.SERVICIO (
        id_servicio INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_SERVICIO PRIMARY KEY,
        nombre NVARCHAR(80) NOT NULL CONSTRAINT UQ_SERVICIO_NOMBRE UNIQUE,
        categoria NVARCHAR(50) NOT NULL,
        precio_base DECIMAL(10,2) NOT NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.METODO_PAGO', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.METODO_PAGO (
        id_metodo_pago INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_METODO_PAGO PRIMARY KEY,
        descripcion NVARCHAR(50) NOT NULL CONSTRAINT UQ_METODO_PAGO_DESC UNIQUE
    );
END;
GO

-- Productos: medicamentos, alimentos, higiene y accesorios (inventario)
IF OBJECT_ID(N'dbo.PRODUCTO', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PRODUCTO (
        id_producto INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_PRODUCTO PRIMARY KEY,
        nombre NVARCHAR(100) NOT NULL CONSTRAINT UQ_PRODUCTO_NOMBRE UNIQUE,
        categoria NVARCHAR(50) NOT NULL,
        precio_venta DECIMAL(10,2) NOT NULL,
        costo DECIMAL(10,2) NOT NULL,
        stock_minimo INT NOT NULL
    );
END;
GO

-- Promociones: campanas por categoria y periodo
IF OBJECT_ID(N'dbo.PROMOCION', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PROMOCION (
        id_promocion INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_PROMOCION PRIMARY KEY,
        nombre NVARCHAR(100) NOT NULL CONSTRAINT UQ_PROMOCION_NOMBRE UNIQUE,
        categoria_objetivo NVARCHAR(50) NOT NULL,
        porcentaje_descuento DECIMAL(5,2) NOT NULL,
        fecha_inicio DATE NOT NULL,
        fecha_fin DATE NOT NULL,
        CONSTRAINT CK_PROMOCION_FECHAS CHECK (fecha_fin >= fecha_inicio)
    );
END;
GO

-- ============================================================
-- 2. TABLAS TRANSACCIONALES
-- ============================================================
IF OBJECT_ID(N'dbo.DETALLE_CITA', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DETALLE_CITA (
        id_detalle INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DETALLE_CITA PRIMARY KEY,
        id_cita INT NOT NULL,
        id_servicio INT NOT NULL,
        cantidad INT NOT NULL CONSTRAINT DF_DETALLE_CANT DEFAULT (1),
        precio_unitario DECIMAL(10,2) NOT NULL,
        descuento DECIMAL(10,2) NOT NULL CONSTRAINT DF_DETALLE_DESC DEFAULT (0),
        id_promocion INT NULL,
        CONSTRAINT FK_DETALLE_CITA FOREIGN KEY (id_cita) REFERENCES dbo.CITA(id_cita),
        CONSTRAINT FK_DETALLE_SERVICIO FOREIGN KEY (id_servicio) REFERENCES dbo.SERVICIO(id_servicio),
        CONSTRAINT FK_DETALLE_PROMOCION FOREIGN KEY (id_promocion) REFERENCES dbo.PROMOCION(id_promocion)
    );
END;
GO

-- Si DETALLE_CITA ya existia de una version anterior, se le agrega la promocion
IF COL_LENGTH(N'dbo.DETALLE_CITA', N'id_promocion') IS NULL
BEGIN
    ALTER TABLE dbo.DETALLE_CITA ADD id_promocion INT NULL;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_DETALLE_PROMOCION')
BEGIN
    ALTER TABLE dbo.DETALLE_CITA
        ADD CONSTRAINT FK_DETALLE_PROMOCION FOREIGN KEY (id_promocion) REFERENCES dbo.PROMOCION(id_promocion);
END;
GO

IF OBJECT_ID(N'dbo.DETALLE_PRODUCTO', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DETALLE_PRODUCTO (
        id_detalle_producto INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DETALLE_PRODUCTO PRIMARY KEY,
        id_cita INT NOT NULL,
        id_producto INT NOT NULL,
        cantidad INT NOT NULL CONSTRAINT DF_DETPROD_CANT DEFAULT (1),
        precio_unitario DECIMAL(10,2) NOT NULL,
        descuento DECIMAL(10,2) NOT NULL CONSTRAINT DF_DETPROD_DESC DEFAULT (0),
        id_promocion INT NULL,
        CONSTRAINT FK_DETPROD_CITA FOREIGN KEY (id_cita) REFERENCES dbo.CITA(id_cita),
        CONSTRAINT FK_DETPROD_PRODUCTO FOREIGN KEY (id_producto) REFERENCES dbo.PRODUCTO(id_producto),
        CONSTRAINT FK_DETPROD_PROMOCION FOREIGN KEY (id_promocion) REFERENCES dbo.PROMOCION(id_promocion)
    );
END;
GO

IF OBJECT_ID(N'dbo.PAGO', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PAGO (
        id_pago INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_PAGO PRIMARY KEY,
        id_cita INT NOT NULL CONSTRAINT UQ_PAGO_CITA UNIQUE,
        id_metodo_pago INT NOT NULL,
        fecha_pago DATE NOT NULL,
        monto_pagado DECIMAL(10,2) NOT NULL,
        CONSTRAINT FK_PAGO_CITA FOREIGN KEY (id_cita) REFERENCES dbo.CITA(id_cita),
        CONSTRAINT FK_PAGO_METODO FOREIGN KEY (id_metodo_pago) REFERENCES dbo.METODO_PAGO(id_metodo_pago)
    );
END;
GO

-- Movimientos de inventario (entradas por reposicion, salidas por venta)
IF OBJECT_ID(N'dbo.MOVIMIENTO_INVENTARIO', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.MOVIMIENTO_INVENTARIO (
        id_movimiento INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_MOVIMIENTO PRIMARY KEY,
        id_producto INT NOT NULL,
        fecha_movimiento DATE NOT NULL,
        tipo NVARCHAR(10) NOT NULL,
        cantidad INT NOT NULL,
        costo_unitario DECIMAL(10,2) NOT NULL,
        id_cita INT NULL,
        CONSTRAINT CK_MOVIMIENTO_TIPO CHECK (tipo IN (N'Entrada', N'Salida')),
        CONSTRAINT FK_MOVIMIENTO_PRODUCTO FOREIGN KEY (id_producto) REFERENCES dbo.PRODUCTO(id_producto),
        CONSTRAINT FK_MOVIMIENTO_CITA FOREIGN KEY (id_cita) REFERENCES dbo.CITA(id_cita)
    );
END;
GO

-- Meta mensual de ventas por sede (ubicacion)
IF OBJECT_ID(N'dbo.META_VENTA', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.META_VENTA (
        id_meta INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_META_VENTA PRIMARY KEY,
        id_ubicacion INT NOT NULL,
        anio SMALLINT NOT NULL,
        mes TINYINT NOT NULL,
        monto_meta DECIMAL(10,2) NOT NULL,
        CONSTRAINT UQ_META_VENTA UNIQUE (id_ubicacion, anio, mes),
        CONSTRAINT FK_META_UBICACION FOREIGN KEY (id_ubicacion) REFERENCES dbo.UBICACION(id_ubicacion)
    );
END;
GO

-- ============================================================
-- 3. DATOS DE CATALOGO
-- ============================================================
INSERT INTO dbo.SERVICIO (nombre, categoria, precio_base)
SELECT v.nombre, v.categoria, v.precio
FROM (VALUES
    (N'Consulta general',          N'Consulta',     60.00),
    (N'Vacunacion',                N'Prevencion',   80.00),
    (N'Desparasitacion',           N'Prevencion',   45.00),
    (N'Control post operatorio',   N'Consulta',     50.00),
    (N'Bano medicado',             N'Estetica',     70.00),
    (N'Analisis de laboratorio',   N'Diagnostico', 120.00),
    (N'Ecografia',                 N'Diagnostico', 150.00),
    (N'Profilaxis dental',         N'Odontologia', 180.00),
    (N'Cirugia menor',             N'Cirugia',     350.00)
) AS v(nombre, categoria, precio)
WHERE NOT EXISTS (SELECT 1 FROM dbo.SERVICIO s WHERE s.nombre = v.nombre);

INSERT INTO dbo.METODO_PAGO (descripcion)
SELECT v.descripcion
FROM (VALUES (N'Efectivo'), (N'Yape'), (N'Plin'), (N'Tarjeta'), (N'Transferencia')) AS v(descripcion)
WHERE NOT EXISTS (SELECT 1 FROM dbo.METODO_PAGO m WHERE m.descripcion = v.descripcion);

INSERT INTO dbo.PRODUCTO (nombre, categoria, precio_venta, costo, stock_minimo)
SELECT v.nombre, v.categoria, v.precio, v.costo, v.minimo
FROM (VALUES
    (N'Antiparasitario externo (pipeta)',   N'Medicamento',  45.00,  28.00, 10),
    (N'Antibiótico oral (amoxicilina)',     N'Medicamento',  38.00,  22.00, 10),
    (N'Antiinflamatorio (meloxicam)',       N'Medicamento',  42.00,  25.00, 10),
    (N'Suplemento vitamínico',              N'Medicamento',  35.00,  20.00, 10),
    (N'Collar antipulgas',                  N'Medicamento',  55.00,  33.00,  8),
    (N'Alimento premium perro adulto 15 kg',N'Alimento',    220.00, 165.00,  5),
    (N'Alimento premium cachorro 7.5 kg',   N'Alimento',    130.00,  95.00,  6),
    (N'Alimento premium gato adulto 7.5 kg',N'Alimento',    140.00, 100.00,  6),
    (N'Alimento húmedo (lata)',             N'Alimento',      9.00,   5.50, 40),
    (N'Snacks dentales',                    N'Alimento',     18.00,  10.00, 20),
    (N'Shampoo medicado',                   N'Higiene',      40.00,  24.00,  8),
    (N'Toallitas húmedas',                  N'Higiene',      15.00,   8.00, 15),
    (N'Collar isabelino',                   N'Accesorio',    30.00,  17.00,  6),
    (N'Correa reforzada',                   N'Accesorio',    35.00,  20.00,  6)
) AS v(nombre, categoria, precio, costo, minimo)
WHERE NOT EXISTS (SELECT 1 FROM dbo.PRODUCTO p WHERE p.nombre = v.nombre);

-- Campanas (los periodos de una misma categoria no se superponen)
INSERT INTO dbo.PROMOCION (nombre, categoria_objetivo, porcentaje_descuento, fecha_inicio, fecha_fin)
SELECT v.nombre, v.categoria, v.pct, v.inicio, v.fin
FROM (VALUES
    (N'Desparasitación Total 2024',        N'Prevencion',  15.00, CAST('20240401' AS DATE), CAST('20240630' AS DATE)),
    (N'Verano Vacunado 2025',              N'Prevencion',  20.00, CAST('20250101' AS DATE), CAST('20250331' AS DATE)),
    (N'Chequeo Preventivo Otoño 2025',     N'Consulta',    10.00, CAST('20250401' AS DATE), CAST('20250630' AS DATE)),
    (N'Semana del Alimento Premium 2025',  N'Alimento',    12.00, CAST('20250901' AS DATE), CAST('20251031' AS DATE)),
    (N'Verano Estético 2026',              N'Estetica',    25.00, CAST('20260101' AS DATE), CAST('20260331' AS DATE)),
    (N'Cuidado e Higiene 2026',            N'Higiene',     20.00, CAST('20260301' AS DATE), CAST('20260531' AS DATE)),
    (N'Diagnóstico Temprano 2026',         N'Diagnostico', 15.00, CAST('20260401' AS DATE), CAST('20260630' AS DATE))
) AS v(nombre, categoria, pct, inicio, fin)
WHERE NOT EXISTS (SELECT 1 FROM dbo.PROMOCION p WHERE p.nombre = v.nombre);
GO

-- ============================================================
-- 4. VENTAS: servicios de las citas atendidas (determinista)
--    1 servicio por cita atendida; cada 3ra cita lleva un 2do servicio;
--    cada 7ma cita tiene 10% de descuento de cortesia en el 1er servicio.
-- ============================================================
;WITH sv AS (
    SELECT id_servicio, precio_base,
           ROW_NUMBER() OVER (ORDER BY id_servicio) AS rn
    FROM dbo.SERVICIO
),
tot AS (SELECT COUNT(*) AS total FROM dbo.SERVICIO)
INSERT INTO dbo.DETALLE_CITA (id_cita, id_servicio, cantidad, precio_unitario, descuento)
SELECT c.id_cita, sv.id_servicio, 1, sv.precio_base,
       CASE WHEN c.id_cita % 7 = 0 THEN ROUND(sv.precio_base * 0.10, 2) ELSE 0 END
FROM dbo.CITA c
CROSS JOIN tot
JOIN sv ON sv.rn = (c.id_cita % tot.total) + 1
WHERE c.estado = N'Atendida'
  AND NOT EXISTS (SELECT 1 FROM dbo.DETALLE_CITA d WHERE d.id_cita = c.id_cita)
UNION ALL
SELECT c.id_cita, sv.id_servicio, 1, sv.precio_base, 0
FROM dbo.CITA c
CROSS JOIN tot
JOIN sv ON sv.rn = ((c.id_cita + 4) % tot.total) + 1
WHERE c.estado = N'Atendida'
  AND c.id_cita % 3 = 0
  AND NOT EXISTS (SELECT 1 FROM dbo.DETALLE_CITA d WHERE d.id_cita = c.id_cita);
GO

-- ============================================================
-- 5. VENTAS: productos en las citas atendidas
--    Las citas pares compran 1 producto (1 a 3 unidades);
--    las citas multiplo de 5 compran un producto adicional.
-- ============================================================
;WITH pr AS (
    SELECT id_producto, precio_venta,
           ROW_NUMBER() OVER (ORDER BY id_producto) AS rn
    FROM dbo.PRODUCTO
),
tot AS (SELECT COUNT(*) AS total FROM dbo.PRODUCTO)
INSERT INTO dbo.DETALLE_PRODUCTO (id_cita, id_producto, cantidad, precio_unitario, descuento)
SELECT c.id_cita, pr.id_producto, 1 + (c.id_cita % 3), pr.precio_venta, 0
FROM dbo.CITA c
CROSS JOIN tot
JOIN pr ON pr.rn = ((c.id_cita * 7) % tot.total) + 1
WHERE c.estado = N'Atendida'
  AND c.id_cita % 2 = 0
  AND NOT EXISTS (SELECT 1 FROM dbo.DETALLE_PRODUCTO d WHERE d.id_cita = c.id_cita)
UNION ALL
SELECT c.id_cita, pr.id_producto, 1, pr.precio_venta, 0
FROM dbo.CITA c
CROSS JOIN tot
JOIN pr ON pr.rn = ((c.id_cita * 7 + 5) % tot.total) + 1
WHERE c.estado = N'Atendida'
  AND c.id_cita % 5 = 0
  AND NOT EXISTS (SELECT 1 FROM dbo.DETALLE_PRODUCTO d WHERE d.id_cita = c.id_cita);
GO

-- ============================================================
-- 6. PROMOCIONES: se aplican a las lineas cuya categoria y fecha coinciden
-- ============================================================
UPDATE d
SET d.id_promocion = p.id_promocion,
    d.descuento = ROUND(d.cantidad * d.precio_unitario * p.porcentaje_descuento / 100.0, 2)
FROM dbo.DETALLE_CITA d
JOIN dbo.CITA c ON c.id_cita = d.id_cita
JOIN dbo.SERVICIO s ON s.id_servicio = d.id_servicio
JOIN dbo.PROMOCION p ON p.categoria_objetivo = s.categoria
                    AND c.fecha_cita BETWEEN p.fecha_inicio AND p.fecha_fin
WHERE d.id_promocion IS NULL;

UPDATE d
SET d.id_promocion = p.id_promocion,
    d.descuento = ROUND(d.cantidad * d.precio_unitario * p.porcentaje_descuento / 100.0, 2)
FROM dbo.DETALLE_PRODUCTO d
JOIN dbo.CITA c ON c.id_cita = d.id_cita
JOIN dbo.PRODUCTO pr ON pr.id_producto = d.id_producto
JOIN dbo.PROMOCION p ON p.categoria_objetivo = pr.categoria
                    AND c.fecha_cita BETWEEN p.fecha_inicio AND p.fecha_fin
WHERE d.id_promocion IS NULL;
GO

-- ============================================================
-- 7. PAGOS: uno por cita atendida (servicios + productos)
-- ============================================================
;WITH mp AS (
    SELECT id_metodo_pago,
           ROW_NUMBER() OVER (ORDER BY id_metodo_pago) AS rn
    FROM dbo.METODO_PAGO
),
tot AS (SELECT COUNT(*) AS total FROM dbo.METODO_PAGO),
monto AS (
    SELECT id_cita, SUM(importe) AS monto
    FROM (
        SELECT id_cita, cantidad * precio_unitario - descuento AS importe FROM dbo.DETALLE_CITA
        UNION ALL
        SELECT id_cita, cantidad * precio_unitario - descuento FROM dbo.DETALLE_PRODUCTO
    ) x
    GROUP BY id_cita
)
INSERT INTO dbo.PAGO (id_cita, id_metodo_pago, fecha_pago, monto_pagado)
SELECT c.id_cita, mp.id_metodo_pago, c.fecha_cita, m.monto
FROM dbo.CITA c
JOIN monto m ON m.id_cita = c.id_cita
CROSS JOIN tot
JOIN mp ON mp.rn = (c.id_cita % tot.total) + 1
WHERE NOT EXISTS (SELECT 1 FROM dbo.PAGO p WHERE p.id_cita = c.id_cita);

-- Mantiene el monto pagado igual al detalle (por si se agregaron productos o promociones)
UPDATE p
SET p.monto_pagado = m.monto
FROM dbo.PAGO p
JOIN (
    SELECT id_cita, SUM(importe) AS monto
    FROM (
        SELECT id_cita, cantidad * precio_unitario - descuento AS importe FROM dbo.DETALLE_CITA
        UNION ALL
        SELECT id_cita, cantidad * precio_unitario - descuento FROM dbo.DETALLE_PRODUCTO
    ) x
    GROUP BY id_cita
) m ON m.id_cita = p.id_cita
WHERE p.monto_pagado <> m.monto;
GO

-- ============================================================
-- 8. INVENTARIO
--    Salidas: una por cada producto vendido en una cita.
--    Entradas: stock inicial (31/12/2022) + reposicion mensual.
--      producto % 3 = 1 -> repone lo vendido (stock estable)
--      producto % 3 = 2 -> repone 50% de mas (sobrestock)
--      producto % 3 = 0 -> deja de reponer desde 01/07/2026 (stock bajo)
-- ============================================================
INSERT INTO dbo.MOVIMIENTO_INVENTARIO (id_producto, fecha_movimiento, tipo, cantidad, costo_unitario, id_cita)
SELECT d.id_producto, c.fecha_cita, N'Salida', d.cantidad, p.costo, d.id_cita
FROM dbo.DETALLE_PRODUCTO d
JOIN dbo.CITA c ON c.id_cita = d.id_cita
JOIN dbo.PRODUCTO p ON p.id_producto = d.id_producto
WHERE NOT EXISTS (SELECT 1 FROM dbo.MOVIMIENTO_INVENTARIO m
                  WHERE m.id_cita = d.id_cita AND m.id_producto = d.id_producto AND m.tipo = N'Salida');

INSERT INTO dbo.MOVIMIENTO_INVENTARIO (id_producto, fecha_movimiento, tipo, cantidad, costo_unitario, id_cita)
SELECT p.id_producto, CAST('20221231' AS DATE), N'Entrada', p.stock_minimo + 3, p.costo, NULL
FROM dbo.PRODUCTO p
WHERE NOT EXISTS (SELECT 1 FROM dbo.MOVIMIENTO_INVENTARIO m
                  WHERE m.id_producto = p.id_producto
                    AND m.fecha_movimiento = '20221231' AND m.tipo = N'Entrada');

;WITH sal AS (
    SELECT id_producto,
           DATEFROMPARTS(YEAR(fecha_movimiento), MONTH(fecha_movimiento), 1) AS mes_ini,
           SUM(cantidad) AS total
    FROM dbo.MOVIMIENTO_INVENTARIO
    WHERE tipo = N'Salida'
    GROUP BY id_producto, DATEFROMPARTS(YEAR(fecha_movimiento), MONTH(fecha_movimiento), 1)
)
INSERT INTO dbo.MOVIMIENTO_INVENTARIO (id_producto, fecha_movimiento, tipo, cantidad, costo_unitario, id_cita)
SELECT s.id_producto, s.mes_ini, N'Entrada',
       CAST(CEILING(s.total * CASE s.id_producto % 3 WHEN 2 THEN 1.5 ELSE 1.0 END) AS INT),
       p.costo, NULL
FROM sal s
JOIN dbo.PRODUCTO p ON p.id_producto = s.id_producto
WHERE (s.id_producto % 3 <> 0 OR s.mes_ini < '20260701')
  AND NOT EXISTS (SELECT 1 FROM dbo.MOVIMIENTO_INVENTARIO m
                  WHERE m.id_producto = s.id_producto
                    AND m.fecha_movimiento = s.mes_ini AND m.tipo = N'Entrada');
GO

-- ============================================================
-- 9. METAS MENSUALES POR SEDE (ubicacion)
--    Meta = venta real del mes x factor (0.85 a 1.25) para que el
--    cumplimiento varie entre sedes y meses. Datos de prueba.
-- ============================================================
;WITH lineas AS (
    SELECT m.id_ubicacion, YEAR(c.fecha_cita) AS anio, MONTH(c.fecha_cita) AS mes,
           d.cantidad * d.precio_unitario - d.descuento AS monto
    FROM dbo.DETALLE_CITA d
    JOIN dbo.CITA c ON c.id_cita = d.id_cita
    JOIN dbo.MASCOTA m ON m.id_mascota = c.id_mascota
    UNION ALL
    SELECT m.id_ubicacion, YEAR(c.fecha_cita), MONTH(c.fecha_cita),
           d.cantidad * d.precio_unitario - d.descuento
    FROM dbo.DETALLE_PRODUCTO d
    JOIN dbo.CITA c ON c.id_cita = d.id_cita
    JOIN dbo.MASCOTA m ON m.id_mascota = c.id_mascota
),
tot AS (
    SELECT id_ubicacion, anio, mes, SUM(monto) AS ventas
    FROM lineas
    GROUP BY id_ubicacion, anio, mes
)
INSERT INTO dbo.META_VENTA (id_ubicacion, anio, mes, monto_meta)
SELECT t.id_ubicacion, t.anio, t.mes,
       CAST(ROUND(t.ventas * CHOOSE(((t.anio * 12 + t.mes + t.id_ubicacion) % 5) + 1,
                                    0.85, 0.95, 1.05, 1.15, 1.25), 0) AS DECIMAL(10,2))
FROM tot t
WHERE NOT EXISTS (SELECT 1 FROM dbo.META_VENTA mv
                  WHERE mv.id_ubicacion = t.id_ubicacion AND mv.anio = t.anio AND mv.mes = t.mes);
GO

-- ============================================================
-- VERIFICACION
-- ============================================================
SELECT 'SERVICIO' AS Tabla, COUNT(*) AS Total FROM dbo.SERVICIO
UNION ALL SELECT 'PRODUCTO',              COUNT(*) FROM dbo.PRODUCTO
UNION ALL SELECT 'PROMOCION',             COUNT(*) FROM dbo.PROMOCION
UNION ALL SELECT 'METODO_PAGO',           COUNT(*) FROM dbo.METODO_PAGO
UNION ALL SELECT 'DETALLE_CITA',          COUNT(*) FROM dbo.DETALLE_CITA
UNION ALL SELECT 'DETALLE_PRODUCTO',      COUNT(*) FROM dbo.DETALLE_PRODUCTO
UNION ALL SELECT 'PAGO',                  COUNT(*) FROM dbo.PAGO
UNION ALL SELECT 'MOVIMIENTO_INVENTARIO', COUNT(*) FROM dbo.MOVIMIENTO_INVENTARIO
UNION ALL SELECT 'META_VENTA',            COUNT(*) FROM dbo.META_VENTA;

SELECT SUM(monto_pagado) AS IngresoTotal, COUNT(*) AS Pagos FROM dbo.PAGO;

-- Stock actual por producto (origen)
SELECT p.nombre, p.stock_minimo,
       SUM(CASE WHEN m.tipo = N'Entrada' THEN m.cantidad ELSE -m.cantidad END) AS stock_actual
FROM dbo.PRODUCTO p
JOIN dbo.MOVIMIENTO_INVENTARIO m ON m.id_producto = p.id_producto
GROUP BY p.nombre, p.stock_minimo
ORDER BY p.nombre;
GO
