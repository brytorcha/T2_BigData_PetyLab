
USE PetyLab_DW;
GO
SET LANGUAGE Spanish;
GO

-- ====================================================
-- PASO 1: LIMPIEZA (hechos primero, luego dimensiones)
-- ====================================================
DELETE FROM dbo.Fact_Meta_Venta;
DELETE FROM dbo.Fact_Inventario;
DELETE FROM dbo.Fact_Venta_Producto;
DELETE FROM dbo.Fact_Venta;
DELETE FROM dbo.Fact_Cita;
DELETE FROM dbo.DimTiempo;
DELETE FROM dbo.DimCliente;
DELETE FROM dbo.DimMascota;
DELETE FROM dbo.DimEmpleado;
DELETE FROM dbo.DimUbicacion;
DELETE FROM dbo.DimServicio;
DELETE FROM dbo.DimMetodoPago;
DELETE FROM dbo.DimProducto;
DELETE FROM dbo.DimPromocion;
GO

-- ====================================================
-- PASO 2: CARGA DE DIMENSIONES
-- ====================================================
INSERT INTO dbo.DimCliente (id_Cliente, dni, apellidoMa, apellidoPa, Nombre, Telefono, Direccion, fecha_registro)
SELECT
    c.id_cliente,
    c.dni,
    ISNULL(c.apellido_materno, 'Sin Registro'),
    ISNULL(c.apellido_paterno, 'Sin Registro'),
    c.nombre,
    ISNULL(c.telefono, 'Sin Teléfono'),
    ISNULL(c.direccion, 'Sin Dirección'),
    CAST(c.fecha_registro AS DATE)
FROM PETYLAB.dbo.CLIENTE c;

INSERT INTO dbo.DimMascota (id_Mascota, Nombre, FechaNac, Sexo, Raza, Especie, Color)
SELECT
    m.id_mascota,
    m.nombre,
    CAST(m.fecha_nacimiento AS DATE),
    ISNULL(s.descripcion, 'No Especificado'),
    ISNULL(r.nombre_raza, 'General'),
    ISNULL(e.nombre_especie, 'Mascota'),
    ISNULL(co.descripcion, 'Variado')
FROM PETYLAB.dbo.MASCOTA m
LEFT JOIN PETYLAB.dbo.SEXO s ON m.id_sexo = s.id_sexo
LEFT JOIN PETYLAB.dbo.RAZA r ON m.id_raza = r.id_raza
LEFT JOIN PETYLAB.dbo.ESPECIE e ON r.id_especie = e.id_especie
LEFT JOIN PETYLAB.dbo.COLOR co ON m.id_color = co.id_color;

INSERT INTO dbo.DimEmpleado (Id_Empleado, Nombre, Apellido, Cargo, Usuario)
SELECT id_empleado, nombre, apellido, cargo, usuario
FROM PETYLAB.dbo.EMPLEADO;

INSERT INTO dbo.DimUbicacion (Id_Ubicacion, Departamento, Provincia, Distrito)
SELECT id_ubicacion, departamento, provincia, distrito
FROM PETYLAB.dbo.UBICACION;

INSERT INTO dbo.DimServicio (Id_Servicio, Nombre, Categoria, Precio_Base)
SELECT id_servicio, nombre, categoria, precio_base
FROM PETYLAB.dbo.SERVICIO;

-- Miembro 0 para pagos no registrados
INSERT INTO dbo.DimMetodoPago (Id_MetodoPago, Descripcion)
SELECT id_metodo_pago, descripcion FROM PETYLAB.dbo.METODO_PAGO
UNION ALL
SELECT 0, 'Sin Registro';


INSERT INTO dbo.DimProducto (Id_Producto, Nombre, Categoria, Precio_Venta, Costo, Stock_Minimo)
SELECT id_producto, nombre, categoria, precio_venta, costo, stock_minimo
FROM PETYLAB.dbo.PRODUCTO;

-- Miembro 0 = venta sin promocion
INSERT INTO dbo.DimPromocion (Id_Promocion, Nombre, Categoria_Objetivo, Porcentaje_Descuento, Fecha_Inicio, Fecha_Fin)
SELECT id_promocion, nombre, categoria_objetivo, porcentaje_descuento, fecha_inicio, fecha_fin
FROM PETYLAB.dbo.PROMOCION
UNION ALL
SELECT 0, 'Sin Promocion', 'Todas', 0.00, NULL, NULL;

-- DimTiempo a) fecha + hora de cada cita
INSERT INTO dbo.DimTiempo (fecha, hora, dia, NombreDia, mes, NombreMes, trimestre, bimestre, semestre, año)
SELECT DISTINCT
    CAST(fecha_cita AS DATE),
    CAST(hora_cita AS TIME),
    DAY(fecha_cita),
    DATENAME(WEEKDAY, fecha_cita),
    MONTH(fecha_cita),
    DATENAME(MONTH, fecha_cita),
    DATEPART(QUARTER, fecha_cita),
    CASE
        WHEN MONTH(fecha_cita) IN (1,2)  THEN 1
        WHEN MONTH(fecha_cita) IN (3,4)  THEN 2
        WHEN MONTH(fecha_cita) IN (5,6)  THEN 3
        WHEN MONTH(fecha_cita) IN (7,8)  THEN 4
        WHEN MONTH(fecha_cita) IN (9,10) THEN 5
        ELSE 6
    END,
    CASE WHEN MONTH(fecha_cita) <= 6 THEN 1 ELSE 2 END,
    YEAR(fecha_cita)
FROM PETYLAB.dbo.CITA;

-- DimTiempo b) fechas sin hora: movimientos de inventario y primer dia del mes de cada meta
INSERT INTO dbo.DimTiempo (fecha, hora, dia, NombreDia, mes, NombreMes, trimestre, bimestre, semestre, año)
SELECT
    f.fecha,
    NULL,
    DAY(f.fecha),
    DATENAME(WEEKDAY, f.fecha),
    MONTH(f.fecha),
    DATENAME(MONTH, f.fecha),
    DATEPART(QUARTER, f.fecha),
    CASE
        WHEN MONTH(f.fecha) IN (1,2)  THEN 1
        WHEN MONTH(f.fecha) IN (3,4)  THEN 2
        WHEN MONTH(f.fecha) IN (5,6)  THEN 3
        WHEN MONTH(f.fecha) IN (7,8)  THEN 4
        WHEN MONTH(f.fecha) IN (9,10) THEN 5
        ELSE 6
    END,
    CASE WHEN MONTH(f.fecha) <= 6 THEN 1 ELSE 2 END,
    YEAR(f.fecha)
FROM (
    SELECT CAST(fecha_movimiento AS DATE) AS fecha FROM PETYLAB.dbo.MOVIMIENTO_INVENTARIO
    UNION
    SELECT DATEFROMPARTS(anio, mes, 1) FROM PETYLAB.dbo.META_VENTA
) f
WHERE NOT EXISTS (SELECT 1 FROM dbo.DimTiempo t WHERE t.fecha = f.fecha AND t.hora IS NULL);
GO

-- ====================================================
-- PASO 3A: Fact_Cita (monto = servicios + productos de la cita)
-- ====================================================
INSERT INTO dbo.Fact_Cita (
    Id_Tiempo, Id_Cliente, Id_Mascota, Id_Empleado, Id_Ubicacion,
    Cantidad_Citas, Cantidad_Atenciones, Citas_Canceladas, Monto_Total)
SELECT
    dt.id_Tiempo, dc.id_Cliente, dm.id_Mascota, de.Id_Empleado, du.Id_Ubicacion,
    1,
    CASE WHEN c.estado = 'Atendida'  THEN 1 ELSE 0 END,
    CASE WHEN c.estado = 'Cancelada' THEN 1 ELSE 0 END,
    ISNULL((SELECT SUM(d.cantidad * d.precio_unitario - d.descuento)
            FROM PETYLAB.dbo.DETALLE_CITA d WHERE d.id_cita = c.id_cita), 0.00)
  + ISNULL((SELECT SUM(dp.cantidad * dp.precio_unitario - dp.descuento)
            FROM PETYLAB.dbo.DETALLE_PRODUCTO dp WHERE dp.id_cita = c.id_cita), 0.00)
FROM PETYLAB.dbo.CITA c
INNER JOIN PETYLAB.dbo.MASCOTA m ON c.id_mascota = m.id_mascota
INNER JOIN dbo.DimTiempo dt ON CAST(c.fecha_cita AS DATE) = dt.fecha
                           AND CAST(c.hora_cita AS TIME) = dt.hora
INNER JOIN dbo.DimCliente dc ON m.id_cliente = dc.id_Cliente
INNER JOIN dbo.DimMascota dm ON m.id_mascota = dm.id_Mascota
INNER JOIN dbo.DimEmpleado de ON c.id_empleado = de.Id_Empleado
INNER JOIN dbo.DimUbicacion du ON m.id_ubicacion = du.Id_Ubicacion;
GO

-- ====================================================
-- PASO 3B: Fact_Venta (una fila por servicio vendido)
-- ====================================================
INSERT INTO dbo.Fact_Venta (
    Id_Tiempo, Id_Cliente, Id_Mascota, Id_Empleado, Id_Ubicacion,
    Id_Servicio, Id_MetodoPago, Id_Promocion,
    Cantidad, Precio_Unitario, Descuento, Monto_Bruto, Monto_Neto)
SELECT
    dt.id_Tiempo, dc.id_Cliente, dm.id_Mascota, de.Id_Empleado, du.Id_Ubicacion,
    ds.Id_Servicio,
    dmp.Id_MetodoPago,
    dpr.Id_Promocion,
    d.cantidad, d.precio_unitario, d.descuento,
    d.cantidad * d.precio_unitario,
    d.cantidad * d.precio_unitario - d.descuento
FROM PETYLAB.dbo.DETALLE_CITA d
INNER JOIN PETYLAB.dbo.CITA c ON d.id_cita = c.id_cita
INNER JOIN PETYLAB.dbo.MASCOTA m ON c.id_mascota = m.id_mascota
LEFT  JOIN PETYLAB.dbo.PAGO p ON p.id_cita = c.id_cita
INNER JOIN dbo.DimTiempo dt ON CAST(c.fecha_cita AS DATE) = dt.fecha
                           AND CAST(c.hora_cita AS TIME) = dt.hora
INNER JOIN dbo.DimCliente dc ON m.id_cliente = dc.id_Cliente
INNER JOIN dbo.DimMascota dm ON m.id_mascota = dm.id_Mascota
INNER JOIN dbo.DimEmpleado de ON c.id_empleado = de.Id_Empleado
INNER JOIN dbo.DimUbicacion du ON m.id_ubicacion = du.Id_Ubicacion
INNER JOIN dbo.DimServicio ds ON d.id_servicio = ds.Id_Servicio
INNER JOIN dbo.DimMetodoPago dmp ON dmp.Id_MetodoPago = ISNULL(p.id_metodo_pago, 0)
INNER JOIN dbo.DimPromocion dpr ON dpr.Id_Promocion = ISNULL(d.id_promocion, 0);
GO

-- ====================================================
-- PASO 3C: Fact_Venta_Producto (una fila por producto vendido)
-- ====================================================
INSERT INTO dbo.Fact_Venta_Producto (
    Id_Tiempo, Id_Cliente, Id_Mascota, Id_Empleado, Id_Ubicacion,
    Id_Producto, Id_MetodoPago, Id_Promocion,
    Cantidad, Precio_Unitario, Costo_Unitario, Descuento,
    Monto_Bruto, Monto_Neto, Margen_Bruto)
SELECT
    dt.id_Tiempo, dc.id_Cliente, dm.id_Mascota, de.Id_Empleado, du.Id_Ubicacion,
    dpd.Id_Producto,
    dmp.Id_MetodoPago,
    dpr.Id_Promocion,
    d.cantidad, d.precio_unitario, pr.costo, d.descuento,
    d.cantidad * d.precio_unitario,
    d.cantidad * d.precio_unitario - d.descuento,
    (d.cantidad * d.precio_unitario - d.descuento) - d.cantidad * pr.costo
FROM PETYLAB.dbo.DETALLE_PRODUCTO d
INNER JOIN PETYLAB.dbo.PRODUCTO pr ON d.id_producto = pr.id_producto
INNER JOIN PETYLAB.dbo.CITA c ON d.id_cita = c.id_cita
INNER JOIN PETYLAB.dbo.MASCOTA m ON c.id_mascota = m.id_mascota
LEFT  JOIN PETYLAB.dbo.PAGO p ON p.id_cita = c.id_cita
INNER JOIN dbo.DimTiempo dt ON CAST(c.fecha_cita AS DATE) = dt.fecha
                           AND CAST(c.hora_cita AS TIME) = dt.hora
INNER JOIN dbo.DimCliente dc ON m.id_cliente = dc.id_Cliente
INNER JOIN dbo.DimMascota dm ON m.id_mascota = dm.id_Mascota
INNER JOIN dbo.DimEmpleado de ON c.id_empleado = de.Id_Empleado
INNER JOIN dbo.DimUbicacion du ON m.id_ubicacion = du.Id_Ubicacion
INNER JOIN dbo.DimProducto dpd ON d.id_producto = dpd.Id_Producto
INNER JOIN dbo.DimMetodoPago dmp ON dmp.Id_MetodoPago = ISNULL(p.id_metodo_pago, 0)
INNER JOIN dbo.DimPromocion dpr ON dpr.Id_Promocion = ISNULL(d.id_promocion, 0);
GO

-- ====================================================
-- PASO 3D: Fact_Inventario (entradas y salidas de stock)
-- ====================================================
INSERT INTO dbo.Fact_Inventario (
    Id_Tiempo, Id_Producto, Tipo_Movimiento, Cantidad, Cantidad_Neta,
    Costo_Unitario, Valor_Movimiento)
SELECT
    dt.id_Tiempo,
    dp.Id_Producto,
    mi.tipo,
    mi.cantidad,
    CASE WHEN mi.tipo = N'Entrada' THEN mi.cantidad ELSE -mi.cantidad END,
    mi.costo_unitario,
    mi.cantidad * mi.costo_unitario
FROM PETYLAB.dbo.MOVIMIENTO_INVENTARIO mi
INNER JOIN dbo.DimTiempo dt ON dt.fecha = CAST(mi.fecha_movimiento AS DATE) AND dt.hora IS NULL
INNER JOIN dbo.DimProducto dp ON dp.Id_Producto = mi.id_producto;
GO

-- ====================================================
-- PASO 3E: Fact_Meta_Venta (meta mensual por sede)
-- ====================================================
INSERT INTO dbo.Fact_Meta_Venta (Id_Tiempo, Id_Ubicacion, Monto_Meta)
SELECT dt.id_Tiempo, du.Id_Ubicacion, mv.monto_meta
FROM PETYLAB.dbo.META_VENTA mv
INNER JOIN dbo.DimTiempo dt ON dt.fecha = DATEFROMPARTS(mv.anio, mv.mes, 1) AND dt.hora IS NULL
INNER JOIN dbo.DimUbicacion du ON du.Id_Ubicacion = mv.id_ubicacion;
GO

-- ====================================================
-- COMPROBACIONES DE CARGA
-- ====================================================
SELECT 'DimCliente' AS Tabla, COUNT(*) AS TotalRegistros FROM dbo.DimCliente
UNION ALL SELECT 'DimMascota',          COUNT(*) FROM dbo.DimMascota
UNION ALL SELECT 'DimEmpleado',         COUNT(*) FROM dbo.DimEmpleado
UNION ALL SELECT 'DimUbicacion',        COUNT(*) FROM dbo.DimUbicacion
UNION ALL SELECT 'DimServicio',         COUNT(*) FROM dbo.DimServicio
UNION ALL SELECT 'DimMetodoPago',       COUNT(*) FROM dbo.DimMetodoPago
UNION ALL SELECT 'DimProducto',         COUNT(*) FROM dbo.DimProducto
UNION ALL SELECT 'DimPromocion',        COUNT(*) FROM dbo.DimPromocion
UNION ALL SELECT 'DimTiempo',           COUNT(*) FROM dbo.DimTiempo
UNION ALL SELECT 'Fact_Cita',           COUNT(*) FROM dbo.Fact_Cita
UNION ALL SELECT 'Fact_Venta',          COUNT(*) FROM dbo.Fact_Venta
UNION ALL SELECT 'Fact_Venta_Producto', COUNT(*) FROM dbo.Fact_Venta_Producto
UNION ALL SELECT 'Fact_Inventario',     COUNT(*) FROM dbo.Fact_Inventario
UNION ALL SELECT 'Fact_Meta_Venta',     COUNT(*) FROM dbo.Fact_Meta_Venta;
GO

-- ====================================================
-- VALIDACION DE LA CARGA (cada par debe ser igual)
-- ====================================================
-- 1. Citas
SELECT (SELECT COUNT(*) FROM PETYLAB.dbo.CITA) AS CitasOrigen,
       (SELECT COUNT(*) FROM dbo.Fact_Cita)    AS FilasFactCita;

-- 2. Lineas de servicio y de producto
SELECT (SELECT COUNT(*) FROM PETYLAB.dbo.DETALLE_CITA)     AS ServiciosOrigen,
       (SELECT COUNT(*) FROM dbo.Fact_Venta)               AS FilasFactVenta,
       (SELECT COUNT(*) FROM PETYLAB.dbo.DETALLE_PRODUCTO) AS ProductosOrigen,
       (SELECT COUNT(*) FROM dbo.Fact_Venta_Producto)      AS FilasFactVentaProducto;

-- 3. Movimientos y metas
SELECT (SELECT COUNT(*) FROM PETYLAB.dbo.MOVIMIENTO_INVENTARIO) AS MovimientosOrigen,
       (SELECT COUNT(*) FROM dbo.Fact_Inventario)               AS FilasFactInventario,
       (SELECT COUNT(*) FROM PETYLAB.dbo.META_VENTA)            AS MetasOrigen,
       (SELECT COUNT(*) FROM dbo.Fact_Meta_Venta)               AS FilasFactMeta;

-- 4. Cuadre de facturacion: Fact_Cita = Fact_Venta + Fact_Venta_Producto = pagos del origen
SELECT (SELECT SUM(Monto_Total) FROM dbo.Fact_Cita) AS Facturacion_FactCita,
       (SELECT SUM(Monto_Neto) FROM dbo.Fact_Venta)
     + (SELECT ISNULL(SUM(Monto_Neto),0) FROM dbo.Fact_Venta_Producto) AS Facturacion_Ventas,
       (SELECT SUM(monto_pagado) FROM PETYLAB.dbo.PAGO) AS Pagos_Origen;

-- 5. Huerfanos en Fact_Cita (esperado = 0)
SELECT COUNT(*) AS HuerfanosFactCita
FROM dbo.Fact_Cita f
WHERE NOT EXISTS (SELECT 1 FROM dbo.DimTiempo    WHERE id_Tiempo    = f.Id_Tiempo)
   OR NOT EXISTS (SELECT 1 FROM dbo.DimCliente   WHERE id_Cliente   = f.Id_Cliente)
   OR NOT EXISTS (SELECT 1 FROM dbo.DimMascota   WHERE id_Mascota   = f.Id_Mascota)
   OR NOT EXISTS (SELECT 1 FROM dbo.DimEmpleado  WHERE Id_Empleado  = f.Id_Empleado)
   OR NOT EXISTS (SELECT 1 FROM dbo.DimUbicacion WHERE Id_Ubicacion = f.Id_Ubicacion);

-- 6. Nulos en dimensiones (esperado = 0)
SELECT COUNT(*) AS TelefonosNulos FROM dbo.DimCliente WHERE Telefono IS NULL;
GO

-- ====================================================
-- CONSULTAS DE KPIs
-- ====================================================
-- 1. KPIs globales (citas, tasas, facturacion y ticket)
SELECT SUM(Cantidad_Citas) AS TotalCitas,
       CAST(100.0 * SUM(Cantidad_Atenciones) / NULLIF(SUM(Cantidad_Citas),0) AS DECIMAL(5,2)) AS TasaAtenciones,
       CAST(100.0 * SUM(Citas_Canceladas)    / NULLIF(SUM(Cantidad_Citas),0) AS DECIMAL(5,2)) AS TasaCancelacion,
       SUM(Monto_Total) AS FacturacionTotal,
       CAST(SUM(Monto_Total) / NULLIF(SUM(Cantidad_Atenciones),0) AS DECIMAL(10,2)) AS TicketPromedio
FROM dbo.Fact_Cita;

-- 2. Ventas de servicios por categoria
SELECT s.Categoria, s.Nombre, SUM(v.Cantidad) AS Unidades, SUM(v.Monto_Neto) AS Ventas
FROM dbo.Fact_Venta v JOIN dbo.DimServicio s ON v.Id_Servicio = s.Id_Servicio
GROUP BY s.Categoria, s.Nombre ORDER BY Ventas DESC;

-- 3. Ventas por metodo de pago (servicios + productos)
SELECT x.Descripcion, COUNT(*) AS Lineas, SUM(x.Monto) AS Ventas
FROM (
    SELECT m.Descripcion, v.Monto_Neto AS Monto
    FROM dbo.Fact_Venta v JOIN dbo.DimMetodoPago m ON v.Id_MetodoPago = m.Id_MetodoPago
    UNION ALL
    SELECT m.Descripcion, v.Monto_Neto
    FROM dbo.Fact_Venta_Producto v JOIN dbo.DimMetodoPago m ON v.Id_MetodoPago = m.Id_MetodoPago
) x
GROUP BY x.Descripcion ORDER BY Ventas DESC;

-- 4. Ventas por distrito
SELECT u.Distrito, SUM(x.Monto) AS Ventas
FROM (
    SELECT Id_Ubicacion, Monto_Neto AS Monto FROM dbo.Fact_Venta
    UNION ALL
    SELECT Id_Ubicacion, Monto_Neto FROM dbo.Fact_Venta_Producto
) x JOIN dbo.DimUbicacion u ON x.Id_Ubicacion = u.Id_Ubicacion
GROUP BY u.Distrito ORDER BY Ventas DESC;

-- 5. Ventas por veterinario
SELECT e.Nombre, e.Apellido, SUM(x.Monto) AS Ventas
FROM (
    SELECT Id_Empleado, Monto_Neto AS Monto FROM dbo.Fact_Venta
    UNION ALL
    SELECT Id_Empleado, Monto_Neto FROM dbo.Fact_Venta_Producto
) x JOIN dbo.DimEmpleado e ON x.Id_Empleado = e.Id_Empleado
GROUP BY e.Nombre, e.Apellido ORDER BY Ventas DESC;

-- 6. Ventas por especie
SELECT m.Especie, SUM(x.Monto) AS Ventas
FROM (
    SELECT Id_Mascota, Monto_Neto AS Monto FROM dbo.Fact_Venta
    UNION ALL
    SELECT Id_Mascota, Monto_Neto FROM dbo.Fact_Venta_Producto
) x JOIN dbo.DimMascota m ON x.Id_Mascota = m.id_Mascota
GROUP BY m.Especie ORDER BY Ventas DESC;

-- 7. Evolucion mensual de ventas (servicios + productos)
SELECT t.año, t.mes, t.NombreMes, SUM(x.Monto) AS Ventas
FROM (
    SELECT Id_Tiempo, Monto_Neto AS Monto FROM dbo.Fact_Venta
    UNION ALL
    SELECT Id_Tiempo, Monto_Neto FROM dbo.Fact_Venta_Producto
) x JOIN dbo.DimTiempo t ON x.Id_Tiempo = t.id_Tiempo
GROUP BY t.año, t.mes, t.NombreMes ORDER BY t.año, t.mes;

-- 8. Descuento otorgado vs. venta bruta
SELECT SUM(Bruto) AS VentaBruta, SUM(Desc_) AS Descuentos,
       CAST(100.0 * SUM(Desc_) / NULLIF(SUM(Bruto),0) AS DECIMAL(5,2)) AS PctDescuento
FROM (
    SELECT Monto_Bruto AS Bruto, Descuento AS Desc_ FROM dbo.Fact_Venta
    UNION ALL
    SELECT Monto_Bruto, Descuento FROM dbo.Fact_Venta_Producto
) x;

-- ----------------------------------------------------
-- INVENTARIO
-- ----------------------------------------------------
-- 9. Ventas y margen por producto
SELECT p.Categoria, p.Nombre,
       SUM(v.Cantidad) AS UnidadesVendidas,
       SUM(v.Monto_Neto) AS Ventas,
       SUM(v.Margen_Bruto) AS MargenBruto,
       CAST(100.0 * SUM(v.Margen_Bruto) / NULLIF(SUM(v.Monto_Neto),0) AS DECIMAL(5,2)) AS PctMargen
FROM dbo.Fact_Venta_Producto v
JOIN dbo.DimProducto p ON v.Id_Producto = p.Id_Producto
GROUP BY p.Categoria, p.Nombre ORDER BY Ventas DESC;

-- 10. Stock actual vs. stock minimo (alerta de reposicion) y valor del inventario
SELECT p.Categoria, p.Nombre,
       SUM(i.Cantidad_Neta) AS StockActual,
       p.Stock_Minimo,
       CASE WHEN SUM(i.Cantidad_Neta) < p.Stock_Minimo THEN 'REPONER'
            WHEN SUM(i.Cantidad_Neta) > p.Stock_Minimo * 3 THEN 'SOBRESTOCK'
            ELSE 'OK' END AS Estado,
       CAST(SUM(i.Cantidad_Neta) * p.Costo AS DECIMAL(12,2)) AS ValorInventario
FROM dbo.Fact_Inventario i
JOIN dbo.DimProducto p ON i.Id_Producto = p.Id_Producto
GROUP BY p.Categoria, p.Nombre, p.Stock_Minimo, p.Costo
ORDER BY Estado, p.Categoria, p.Nombre;

-- 11. Rotacion: unidades vendidas por mes y producto
SELECT t.año, t.mes, p.Nombre, SUM(-i.Cantidad_Neta) AS UnidadesSalida
FROM dbo.Fact_Inventario i
JOIN dbo.DimProducto p ON i.Id_Producto = p.Id_Producto
JOIN dbo.DimTiempo t   ON i.Id_Tiempo = t.id_Tiempo
WHERE i.Tipo_Movimiento = N'Salida'
GROUP BY t.año, t.mes, p.Nombre ORDER BY t.año, t.mes, UnidadesSalida DESC;

-- ----------------------------------------------------
-- CAMPANAS / PROMOCIONES
-- ----------------------------------------------------
-- 12. Desempeno por promocion (servicios + productos)
SELECT pr.Nombre AS Promocion, pr.Categoria_Objetivo, pr.Porcentaje_Descuento,
       COUNT(*) AS Lineas,
       COUNT(DISTINCT x.Id_Cliente) AS ClientesDistintos,
       SUM(x.Bruto) AS VentaBruta,
       SUM(x.Descuento) AS DescuentoOtorgado,
       SUM(x.Neto) AS VentaNeta
FROM (
    SELECT Id_Promocion, Id_Cliente, Monto_Bruto AS Bruto, Descuento, Monto_Neto AS Neto FROM dbo.Fact_Venta
    UNION ALL
    SELECT Id_Promocion, Id_Cliente, Monto_Bruto, Descuento, Monto_Neto FROM dbo.Fact_Venta_Producto
) x
JOIN dbo.DimPromocion pr ON x.Id_Promocion = pr.Id_Promocion
WHERE pr.Id_Promocion <> 0
GROUP BY pr.Nombre, pr.Categoria_Objetivo, pr.Porcentaje_Descuento
ORDER BY VentaNeta DESC;

-- 13. Venta con promocion vs. sin promocion
SELECT CASE WHEN x.Id_Promocion = 0 THEN 'Sin promocion' ELSE 'Con promocion' END AS Tipo,
       COUNT(*) AS Lineas, SUM(x.Neto) AS VentaNeta,
       CAST(AVG(x.Neto) AS DECIMAL(10,2)) AS TicketLinea
FROM (
    SELECT Id_Promocion, Monto_Neto AS Neto FROM dbo.Fact_Venta
    UNION ALL
    SELECT Id_Promocion, Monto_Neto FROM dbo.Fact_Venta_Producto
) x
GROUP BY CASE WHEN x.Id_Promocion = 0 THEN 'Sin promocion' ELSE 'Con promocion' END;

-- ----------------------------------------------------
-- META DE VENTAS: REAL vs META POR SEDE Y MES
-- ----------------------------------------------------
-- 14. Cumplimiento de meta
WITH Real_ AS (
    SELECT t.año, t.mes, x.Id_Ubicacion, SUM(x.Monto) AS Venta_Real
    FROM (
        SELECT Id_Tiempo, Id_Ubicacion, Monto_Neto AS Monto FROM dbo.Fact_Venta
        UNION ALL
        SELECT Id_Tiempo, Id_Ubicacion, Monto_Neto FROM dbo.Fact_Venta_Producto
    ) x JOIN dbo.DimTiempo t ON x.Id_Tiempo = t.id_Tiempo
    GROUP BY t.año, t.mes, x.Id_Ubicacion
)
SELECT t.año, t.mes, u.Distrito,
       m.Monto_Meta,
       ISNULL(r.Venta_Real, 0) AS Venta_Real,
       ISNULL(r.Venta_Real, 0) - m.Monto_Meta AS Diferencia,
       CAST(100.0 * ISNULL(r.Venta_Real, 0) / NULLIF(m.Monto_Meta, 0) AS DECIMAL(6,2)) AS PctCumplimiento,
       CASE WHEN ISNULL(r.Venta_Real, 0) >= m.Monto_Meta THEN 'Meta cumplida' ELSE 'Bajo la meta' END AS Estado
FROM dbo.Fact_Meta_Venta m
JOIN dbo.DimTiempo t    ON m.Id_Tiempo = t.id_Tiempo
JOIN dbo.DimUbicacion u ON m.Id_Ubicacion = u.Id_Ubicacion
LEFT JOIN Real_ r ON r.año = t.año AND r.mes = t.mes AND r.Id_Ubicacion = m.Id_Ubicacion
ORDER BY t.año, t.mes, u.Distrito;

-- ----------------------------------------------------
-- RANKING DE CLIENTES (solo consultas sobre los hechos de venta)
-- ----------------------------------------------------
-- 15. Ranking: frecuentes e inactivos
--     Fecha de referencia = ultima fecha de cita cargada en el DW (no GETDATE, para que
--     el resultado sea reproducible con datos de prueba).
--     Frecuente: 5 o mas atenciones | Inactivo: mas de 180 dias sin comprar
DECLARE @FechaRef DATE = (SELECT MAX(t.fecha) FROM dbo.Fact_Cita f JOIN dbo.DimTiempo t ON f.Id_Tiempo = t.id_Tiempo);

WITH Compras AS (
    SELECT Id_Cliente, Id_Tiempo, Monto_Neto AS Monto FROM dbo.Fact_Venta
    UNION ALL
    SELECT Id_Cliente, Id_Tiempo, Monto_Neto FROM dbo.Fact_Venta_Producto
),
Resumen AS (
    SELECT c.Id_Cliente,
           SUM(c.Monto) AS Gasto_Total,
           MAX(t.fecha) AS Ultima_Compra
    FROM Compras c JOIN dbo.DimTiempo t ON c.Id_Tiempo = t.id_Tiempo
    GROUP BY c.Id_Cliente
),
Visitas AS (
    SELECT Id_Cliente, SUM(Cantidad_Atenciones) AS Atenciones
    FROM dbo.Fact_Cita GROUP BY Id_Cliente
)
SELECT TOP 50
       DENSE_RANK() OVER (ORDER BY r.Gasto_Total DESC) AS Ranking,
       dc.Nombre, dc.apellidoPa, dc.apellidoMa,
       v.Atenciones,
       r.Gasto_Total,
       r.Ultima_Compra,
       DATEDIFF(DAY, r.Ultima_Compra, @FechaRef) AS DiasSinComprar,
       CASE WHEN v.Atenciones >= 5 THEN 'Frecuente'
            WHEN DATEDIFF(DAY, r.Ultima_Compra, @FechaRef) > 180 THEN 'Inactivo'
            ELSE 'Regular' END AS Segmento
FROM Resumen r
JOIN Visitas v     ON v.Id_Cliente = r.Id_Cliente
JOIN dbo.DimCliente dc ON dc.id_Cliente = r.Id_Cliente
ORDER BY Ranking;

-- 16. Cantidad de clientes por segmento
WITH Compras AS (
    SELECT Id_Cliente, Id_Tiempo FROM dbo.Fact_Venta
    UNION ALL
    SELECT Id_Cliente, Id_Tiempo FROM dbo.Fact_Venta_Producto
),
Ult AS (
    SELECT c.Id_Cliente, MAX(t.fecha) AS Ultima_Compra
    FROM Compras c JOIN dbo.DimTiempo t ON c.Id_Tiempo = t.id_Tiempo
    GROUP BY c.Id_Cliente
),
Vis AS (
    SELECT Id_Cliente, SUM(Cantidad_Atenciones) AS Atenciones
    FROM dbo.Fact_Cita GROUP BY Id_Cliente
),
Seg AS (
    SELECT u.Id_Cliente,
           CASE WHEN v.Atenciones >= 5 THEN 'Frecuente'
                WHEN DATEDIFF(DAY, u.Ultima_Compra,
                     (SELECT MAX(t.fecha) FROM dbo.Fact_Cita f JOIN dbo.DimTiempo t ON f.Id_Tiempo = t.id_Tiempo)) > 180 THEN 'Inactivo'
                ELSE 'Regular' END AS Segmento
    FROM Ult u JOIN Vis v ON v.Id_Cliente = u.Id_Cliente
)
SELECT Segmento, COUNT(*) AS Clientes FROM Seg GROUP BY Segmento ORDER BY Clientes DESC;
GO
