/*
 * Universidad: UNLaM
 * Materia: Bases de Datos Aplicada
 * Comision: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha: 2026-06-13
 * Script: Entrega 7 - Reportes.
 * Objetivo: Crear un SP por cada reporte pedido.
 */

USE LinuxPreachers;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'reportes')
BEGIN
    EXEC('CREATE SCHEMA reportes');
END;
GO

/* =========================================================
   1) Visitas por semana, mes y anio, por parque
   ========================================================= */
CREATE OR ALTER PROCEDURE reportes.sp_visitas
AS
BEGIN
    SET NOCOUNT ON;

    WITH Datos AS (
        SELECT
            p.id AS parque_id,
            e.id_item_reserva AS entrada_id,
            e.fecha_acceso AS fecha,
            e.id_tipo_visitante AS tipoVisitante_id
        FROM reservas.Entrada e
        INNER JOIN parques.Parque p ON p.id = e.id_parque
    ), Resultado AS (
        SELECT
            'SEMANA' AS periodo,
            parque_id,
            tipoVisitante_id,
            YEAR(fecha) AS anio,
            MONTH(fecha) AS mes,
            DATEPART(ISO_WEEK, fecha) AS semana,
            COUNT(entrada_id) AS visitas
        FROM Datos
        GROUP BY parque_id, tipoVisitante_id, YEAR(fecha), MONTH(fecha), DATEPART(ISO_WEEK, fecha)

        UNION ALL

        SELECT
            'MES' AS periodo,
            parque_id,
            tipoVisitante_id,
            YEAR(fecha) AS anio,
            MONTH(fecha) AS mes,
            NULL AS semana,
            COUNT(entrada_id) AS visitas
        FROM Datos
        GROUP BY parque_id, tipoVisitante_id, YEAR(fecha), MONTH(fecha)

        UNION ALL

        SELECT
            'ANIO' AS periodo,
            parque_id,
            tipoVisitante_id,
            YEAR(fecha) AS anio,
            NULL AS mes,
            NULL AS semana,
            COUNT(entrada_id) AS visitas
        FROM Datos
        GROUP BY parque_id, tipoVisitante_id, YEAR(fecha)
    ), ResultadoMostrable AS (
        SELECT 
            R.parque_id as parque_id, 
            P.nombre as parque_nombre,
            R.tipoVisitante_id as tipoVisitante_id,
            TV.nombre as tipoVisitante_nombre,
            R.periodo,
            R.anio, R.mes, R.semana,
            R.visitas
        FROM Resultado R
        LEFT JOIN parques.Parque P on R.parque_id = P.id
        LEFT JOIN parques.TipoVisitante TV on R.tipoVisitante_id = TV.id
    )
    SELECT *
    FROM ResultadoMostrable
END;
GO

CREATE OR ALTER PROCEDURE reportes.sp_visitas_filt
    @fechaInicio date,
    @fechaFin date,
    @periodo varchar(10),
    @idParque int
AS
BEGIN
    SET NOCOUNT ON;

    WITH Datos AS (
        SELECT
            p.id AS parque_id,
            e.id_item_reserva AS entrada_id,
            e.fecha_acceso AS fecha,
            e.id_tipo_visitante AS tipoVisitante_id
        FROM reservas.Entrada e
        INNER JOIN parques.Parque p ON p.id = e.id_parque
        WHERE (@fechaInicio is null or e.fecha_acceso > @fechaInicio)
            AND (@fechaFin is null or e.fecha_acceso < @fechaFin)
            AND (@idParque is null or p.id = @idParque)
    ), Resultado AS (
        SELECT
            'SEMANA' AS periodo,
            parque_id,
            tipoVisitante_id,
            YEAR(fecha) AS anio,
            MONTH(fecha) AS mes,
            DATEPART(ISO_WEEK, fecha) AS semana,
            COUNT(entrada_id) AS visitas
        FROM Datos
        GROUP BY parque_id, tipoVisitante_id, YEAR(fecha), MONTH(fecha), DATEPART(ISO_WEEK, fecha)

        UNION ALL

        SELECT
            'MES' AS periodo,
            parque_id,
            tipoVisitante_id,
            YEAR(fecha) AS anio,
            MONTH(fecha) AS mes,
            NULL AS semana,
            COUNT(entrada_id) AS visitas
        FROM Datos
        GROUP BY parque_id, tipoVisitante_id, YEAR(fecha), MONTH(fecha)

        UNION ALL

        SELECT
            'ANIO' AS periodo,
            parque_id,
            tipoVisitante_id,
            YEAR(fecha) AS anio,
            NULL AS mes,
            NULL AS semana,
            COUNT(entrada_id) AS visitas
        FROM Datos
        GROUP BY parque_id, tipoVisitante_id, YEAR(fecha)
    ), ResultadoMostrable AS (
        SELECT 
            R.parque_id as parque_id, 
            P.nombre as parque_nombre,
            R.tipoVisitante_id as tipoVisitante_id,
            TV.nombre as tipoVisitante_nombre,
            R.periodo,
            R.anio, R.mes, R.semana,
            R.visitas
        FROM Resultado R
        LEFT JOIN parques.Parque P on R.parque_id = P.id
        LEFT JOIN parques.TipoVisitante TV on R.tipoVisitante_id = TV.id
        WHERE (@periodo is null or R.periodo = @periodo)
    )
    SELECT *
    FROM ResultadoMostrable
END;
GO

CREATE OR ALTER PROCEDURE reportes.sp_visitas_xml
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #visitas (
        parque_id INT,
        parque_nombre VARCHAR(100),
        tipoVisitante_id INT,
        tipoVisitante_nombre VARCHAR(100),
        periodo VARCHAR(20),
        anio INT,
        mes INT NULL,
        semana INT NULL,
        visitas INT
    );

    INSERT INTO #visitas
    EXEC reportes.sp_visitas;

    SELECT *
    FROM #visitas
    --FOR XML PATH('visita'), ROOT('reporte_visitas'), TYPE;
    FOR XML RAW('visita'), ROOT('reporte_visitas'), ELEMENTS XSINIL;
END;
GO

CREATE OR ALTER PROCEDURE reportes.sp_visitas_xml_filt
    @fechaInicio date,
    @fechaFin date,
    @periodo varchar(10),
    @idParque int
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #visitas (
        parque_id INT,
        parque_nombre VARCHAR(100),
        tipoVisitante_id INT,
        tipoVisitante_nombre VARCHAR(100),
        periodo VARCHAR(20),
        anio INT,
        mes INT NULL,
        semana INT NULL,
        visitas INT
    );

    INSERT INTO #visitas
    EXEC reportes.sp_visitas_filt @fechaInicio, @fechaFin, @periodo, @idParque;

    SELECT *
    FROM #visitas
    --FOR XML PATH('visita'), ROOT('reporte_visitas'), TYPE;
    FOR XML RAW('visita'), ROOT('reporte_visitas'), ELEMENTS XSINIL;
END;
GO


/* =========================================================
   2) Ingresos por parque por semana, mes y anio
   ========================================================= */
CREATE OR ALTER PROCEDURE reportes.sp_ingresos
AS
BEGIN
    SET NOCOUNT ON;

    WITH Datos AS (
        -- Entradas
        SELECT
            e.id_parque AS parque_id,
            e.fecha_acceso AS fecha,
            1 AS cantidad_entradas,
            CAST(ir.precio AS DECIMAL(20,4)) AS ingresos_entradas,
            0 AS cantidad_tours,
            CAST(0 AS DECIMAL(20,4)) AS ingresos_tours,
            0 AS canones_cobrados,
            CAST(0 AS DECIMAL(20,4)) AS ingresos_concesiones
        FROM reservas.Entrada e
        LEFT JOIN reservas.ItemReserva ir ON ir.id = e.id_item_reserva

        UNION ALL

        SELECT
            a.id_parque AS parque_id,
            pa.fecha_realizacion AS fecha,
            0 AS cantidad_entradas,
            CAST(0 AS DECIMAL(20,4)) AS ingresos_entradas,
            1 AS cantidad_tours,
            CAST(ir.precio AS DECIMAL(20,4)) AS ingresos_tours,
            0 AS canones_cobrados,
            CAST(0 AS DECIMAL(20,4)) AS ingresos_concesiones
        FROM reservas.Participacion pa
        LEFT JOIN reservas.ItemReserva ir ON ir.id = pa.id_item_reserva
        LEFT JOIN actividades.Horario h ON h.id = pa.id_horario
        LEFT JOIN actividades.Actividad a ON a.id = h.id_actividad

        UNION ALL

        SELECT
            co.id_parque AS parque_id,
            c.fecha_pago AS fecha,
            0 AS cantidad_entradas,
            CAST(0 AS DECIMAL(20,4)) AS ingresos_entradas,
            0 AS cantidad_tours,
            CAST(0 AS DECIMAL(20,4)) AS ingresos_tours,
            1 AS canones_cobrados,
            CAST(c.monto AS DECIMAL(20,4)) AS ingresos_concesiones
        FROM concesiones.Canon c
        LEFT JOIN concesiones.Concesion co ON co.id = c.id_concesion
        WHERE c.fecha_pago IS NOT NULL
    ), Resultado AS (
        SELECT
            'SEMANA' AS periodo,
            parque_id,
            YEAR(fecha) AS anio,
            MONTH(fecha) AS mes,
            DATEPART(ISO_WEEK, fecha) AS semana,
            SUM(cantidad_entradas) AS cantidad_entradas,
            SUM(ingresos_entradas) AS ingresos_entradas,
            SUM(cantidad_tours) AS cantidad_tours,
            SUM(ingresos_tours) AS ingresos_tours,
            SUM(canones_cobrados) AS canones_cobrados,
            SUM(ingresos_concesiones) AS ingresos_concesiones,
            SUM(ingresos_entradas + ingresos_tours + ingresos_concesiones) AS ingresos_totales
        FROM Datos
        GROUP BY parque_id, YEAR(fecha), MONTH(fecha), DATEPART(ISO_WEEK, fecha)

        UNION ALL

        SELECT
            'MES' AS periodo,
            parque_id,
            YEAR(fecha) AS anio,
            MONTH(fecha) AS mes,
            NULL AS semana,
            SUM(cantidad_entradas) AS cantidad_entradas,
            SUM(ingresos_entradas) AS ingresos_entradas,
            SUM(cantidad_tours) AS cantidad_tours,
            SUM(ingresos_tours) AS ingresos_tours,
            SUM(canones_cobrados) AS canones_cobrados,
            SUM(ingresos_concesiones) AS ingresos_concesiones,
            SUM(ingresos_entradas + ingresos_tours + ingresos_concesiones) AS ingresos_totales
        FROM Datos
        GROUP BY parque_id, YEAR(fecha), MONTH(fecha)

        UNION ALL

        SELECT
            'ANIO' AS periodo,
            parque_id,
            YEAR(fecha) AS anio,
            NULL AS mes,
            NULL AS semana,
            SUM(cantidad_entradas) AS cantidad_entradas,
            SUM(ingresos_entradas) AS ingresos_entradas,
            SUM(cantidad_tours) AS cantidad_tours,
            SUM(ingresos_tours) AS ingresos_tours,
            SUM(canones_cobrados) AS canones_cobrados,
            SUM(ingresos_concesiones) AS ingresos_concesiones,
            SUM(ingresos_entradas + ingresos_tours + ingresos_concesiones) AS ingresos_totales
        FROM Datos
        GROUP BY parque_id, YEAR(fecha)
    ), ResultadoMostrable AS (
        SELECT
            R.parque_id AS parque_id,
            P.nombre AS parque_nombre,
            R.periodo,
            R.anio, R.mes, R.semana,
            R.cantidad_entradas,
            R.ingresos_entradas,
            R.cantidad_tours,
            R.ingresos_tours,
            R.canones_cobrados,
            R.ingresos_concesiones,
            R.ingresos_totales
        FROM Resultado R
        LEFT JOIN parques.Parque P ON R.parque_id = P.id
    )
    SELECT *
    FROM ResultadoMostrable
END;
GO

CREATE OR ALTER PROCEDURE reportes.sp_ingresos_filt
    @fechaInicio date,
    @fechaFin date,
    @periodo varchar(10),
    @idParque int
AS
BEGIN
    SET NOCOUNT ON;

    WITH DatosCrudos AS (
        -- Entradas
        SELECT
            e.id_parque AS parque_id,
            e.fecha_acceso AS fecha,
            1 AS cantidad_entradas,
            CAST(ir.precio AS DECIMAL(20,4)) AS ingresos_entradas,
            0 AS cantidad_tours,
            CAST(0 AS DECIMAL(20,4)) AS ingresos_tours,
            0 AS canones_cobrados,
            CAST(0 AS DECIMAL(20,4)) AS ingresos_concesiones
        FROM reservas.Entrada e
        LEFT JOIN reservas.ItemReserva ir ON ir.id = e.id_item_reserva

        UNION ALL

        -- Actividades
        SELECT
            a.id_parque AS parque_id,
            pa.fecha_realizacion AS fecha,
            0 AS cantidad_entradas,
            CAST(0 AS DECIMAL(20,4)) AS ingresos_entradas,
            1 AS cantidad_tours,
            CAST(ir.precio AS DECIMAL(20,4)) AS ingresos_tours,
            0 AS canones_cobrados,
            CAST(0 AS DECIMAL(20,4)) AS ingresos_concesiones
        FROM reservas.Participacion pa
        LEFT JOIN reservas.ItemReserva ir ON ir.id = pa.id_item_reserva
        LEFT JOIN actividades.Horario h ON h.id = pa.id_horario
        LEFT JOIN actividades.Actividad a ON a.id = h.id_actividad

        UNION ALL

        -- Canones
        SELECT
            co.id_parque AS parque_id,
            c.fecha_pago AS fecha,
            0 AS cantidad_entradas,
            CAST(0 AS DECIMAL(20,4)) AS ingresos_entradas,
            0 AS cantidad_tours,
            CAST(0 AS DECIMAL(20,4)) AS ingresos_tours,
            1 AS canones_cobrados,
            CAST(c.monto AS DECIMAL(20,4)) AS ingresos_concesiones
        FROM concesiones.Canon c
        LEFT JOIN concesiones.Concesion co ON co.id = c.id_concesion
        WHERE c.fecha_pago IS NOT NULL
    ), Datos AS (
        SELECT * FROM DatosCrudos
        WHERE (@fechaInicio is null or fecha > @fechaInicio)
            AND (@fechaFin is null or fecha < @fechaFin)
            AND (@idParque is null or parque_id = @idParque)
    ), Resultado AS (
        SELECT
            'SEMANA' AS periodo,
            parque_id,
            YEAR(fecha) AS anio,
            MONTH(fecha) AS mes,
            DATEPART(ISO_WEEK, fecha) AS semana,
            SUM(cantidad_entradas) AS cantidad_entradas,
            SUM(ingresos_entradas) AS ingresos_entradas,
            SUM(cantidad_tours) AS cantidad_tours,
            SUM(ingresos_tours) AS ingresos_tours,
            SUM(canones_cobrados) AS canones_cobrados,
            SUM(ingresos_concesiones) AS ingresos_concesiones,
            SUM(ingresos_entradas + ingresos_tours + ingresos_concesiones) AS ingresos_totales
        FROM Datos
        GROUP BY parque_id, YEAR(fecha), MONTH(fecha), DATEPART(ISO_WEEK, fecha)

        UNION ALL

        SELECT
            'MES' AS periodo,
            parque_id,
            YEAR(fecha) AS anio,
            MONTH(fecha) AS mes,
            NULL AS semana,
            SUM(cantidad_entradas) AS cantidad_entradas,
            SUM(ingresos_entradas) AS ingresos_entradas,
            SUM(cantidad_tours) AS cantidad_tours,
            SUM(ingresos_tours) AS ingresos_tours,
            SUM(canones_cobrados) AS canones_cobrados,
            SUM(ingresos_concesiones) AS ingresos_concesiones,
            SUM(ingresos_entradas + ingresos_tours + ingresos_concesiones) AS ingresos_totales
        FROM Datos
        GROUP BY parque_id, YEAR(fecha), MONTH(fecha)

        UNION ALL

        SELECT
            'ANIO' AS periodo,
            parque_id,
            YEAR(fecha) AS anio,
            NULL AS mes,
            NULL AS semana,
            SUM(cantidad_entradas) AS cantidad_entradas,
            SUM(ingresos_entradas) AS ingresos_entradas,
            SUM(cantidad_tours) AS cantidad_tours,
            SUM(ingresos_tours) AS ingresos_tours,
            SUM(canones_cobrados) AS canones_cobrados,
            SUM(ingresos_concesiones) AS ingresos_concesiones,
            SUM(ingresos_entradas + ingresos_tours + ingresos_concesiones) AS ingresos_totales
        FROM Datos
        GROUP BY parque_id, YEAR(fecha)
    ), ResultadoMostrable AS (
        SELECT
            R.parque_id AS parque_id,
            P.nombre AS parque_nombre,
            R.periodo,
            R.anio, R.mes, R.semana,
            R.cantidad_entradas,
            R.ingresos_entradas,
            R.cantidad_tours,
            R.ingresos_tours,
            R.canones_cobrados,
            R.ingresos_concesiones,
            R.ingresos_totales
        FROM Resultado R
        LEFT JOIN parques.Parque P ON R.parque_id = P.id
        WHERE (@periodo is null or @periodo = R.periodo)
    )
    SELECT *
    FROM ResultadoMostrable
END;
GO

CREATE OR ALTER PROCEDURE reportes.sp_ingresos_xml
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #ingresos (
        parque_id INT,
        parque_nombre VARCHAR(100),
        periodo VARCHAR(20),
        anio INT,
        mes INT NULL,
        semana INT NULL,
        cantidad_entradas INT,
        ingresos_entradas DECIMAL(38,4),
        cantidad_tours INT,
        ingresos_tours DECIMAL(38,4),
        canones_cobrados INT,
        ingresos_concesiones DECIMAL(38,4),
        ingresos_totales DECIMAL(38,4)
    );

    INSERT INTO #ingresos
    EXEC reportes.sp_ingresos;

    SELECT *
    FROM #ingresos
    FOR XML RAW('ingreso'), ROOT('reporte_ingresos'), ELEMENTS XSINIL;
END;
GO

CREATE OR ALTER PROCEDURE reportes.sp_ingresos_xml_filt
    @fechaInicio date,
    @fechaFin date,
    @periodo varchar(10),
    @idParque int
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #ingresos (
        parque_id INT,
        parque_nombre VARCHAR(100),
        periodo VARCHAR(20),
        anio INT,
        mes INT NULL,
        semana INT NULL,
        cantidad_entradas INT,
        ingresos_entradas DECIMAL(38,4),
        cantidad_tours INT,
        ingresos_tours DECIMAL(38,4),
        canones_cobrados INT,
        ingresos_concesiones DECIMAL(38,4),
        ingresos_totales DECIMAL(38,4)
    );

    INSERT INTO #ingresos
    EXEC reportes.sp_ingresos_filt @fechaInicio, @fechaFin, @periodo, @idParque;

    SELECT *
    FROM #ingresos
    FOR XML RAW('ingreso'), ROOT('reporte_ingresos'), ELEMENTS XSINIL;
END;
GO


/* =========================================================
   3) Deudores: Concesiones atrasadas en los pagos
   ========================================================= */
CREATE OR ALTER PROCEDURE reportes.sp_deudores
AS
BEGIN
    SET NOCOUNT ON;

    WITH Resultado AS (
        SELECT
            p.id AS parque_id,
            p.nombre AS parque_nombre,
            co.id AS concesion_id,
            ec.id AS empresa_id,
            ec.nombre AS empresa_nombre,
            ae.nombre AS actividad_empresa,
            MONTH(c.periodo) AS mes_adeudado,
            YEAR(c.periodo) AS anio_correspondiente,
            c.monto AS monto,
            DATEDIFF(MONTH, c.periodo, CAST(GETDATE() AS DATE)) AS meses_atraso,
            SUM(c.monto) OVER (PARTITION BY co.id) AS deuda_total_concesion
        FROM concesiones.Canon c
        INNER JOIN concesiones.Concesion co ON co.id = c.id_concesion
        INNER JOIN concesiones.EmpresaConcesionaria ec ON ec.id = co.id_empresa_concesionaria
        INNER JOIN concesiones.ActividadEmpresarial ae ON ae.id = ec.id_actividad_empresarial
        INNER JOIN parques.Parque p ON p.id = co.id_parque
        WHERE c.fecha_pago IS NULL
          AND c.fecha_lim_pago < CAST(GETDATE() AS DATE) -- TODO: fecha_lim_pago
    )
    SELECT *
    FROM Resultado
END;
GO

CREATE OR ALTER PROCEDURE reportes.sp_deudores_filt
    @fechaFin date,
    @idParque int
AS
BEGIN
    SET NOCOUNT ON;

    WITH Resultado AS (
        SELECT
            p.id AS parque_id,
            p.nombre AS parque_nombre,
            co.id AS concesion_id,
            ec.id AS empresa_id,
            ec.nombre AS empresa_nombre,
            ae.nombre AS actividad_empresa,
            MONTH(c.periodo) AS mes_adeudado,
            YEAR(c.periodo) AS anio_correspondiente,
            c.monto AS monto,
            DATEDIFF(MONTH, c.periodo, CAST(GETDATE() AS DATE)) AS meses_atraso,
            SUM(c.monto) OVER (PARTITION BY co.id) AS deuda_total_concesion
        FROM concesiones.Canon c
        INNER JOIN concesiones.Concesion co ON co.id = c.id_concesion
        INNER JOIN concesiones.EmpresaConcesionaria ec ON ec.id = co.id_empresa_concesionaria
        INNER JOIN concesiones.ActividadEmpresarial ae ON ae.id = ec.id_actividad_empresarial
        INNER JOIN parques.Parque p ON p.id = co.id_parque
        WHERE c.fecha_pago IS NULL
          AND c.fecha_lim_pago < @fechaFin
          AND (@idParque is null or p.id = @idParque)
    )
    SELECT *
    FROM Resultado
END;
GO

CREATE OR ALTER PROCEDURE reportes.sp_deudores_xml
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #deudores (
        parque_id INT,
        parque_nombre VARCHAR(100),
        concesion_id INT,
        empresa_id INT,
        empresa_nombre VARCHAR(100),
        actividad_empresa VARCHAR(100),
        mes_adeudado TINYINT,
        anio_correspondiente TINYINT,
        monto DECIMAL(15,2),
        meses_atraso INT,
        deuda_total_concesion DECIMAL(38,2)
    );

    INSERT INTO #deudores
    EXEC reportes.sp_deudores;

    SELECT *
    FROM #deudores
    FOR XML RAW('deuda'), ROOT('reporte_deudores'), ELEMENTS XSINIL;
END;
GO

CREATE OR ALTER PROCEDURE reportes.sp_deudores_xml_filt
    @fechaFin date,
    @idParque int
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #deudores (
        parque_id INT,
        parque_nombre VARCHAR(100),
        concesion_id INT,
        empresa_id INT,
        empresa_nombre VARCHAR(100),
        actividad_empresa VARCHAR(100),
        mes_adeudado TINYINT,
        anio_correspondiente TINYINT,
        monto DECIMAL(15,2),
        meses_atraso INT,
        deuda_total_concesion DECIMAL(38,2)
    );

    INSERT INTO #deudores
    EXEC reportes.sp_deudores_filt @fechaFin, @idParque;

    SELECT *
    FROM #deudores
    FOR XML RAW('deuda'), ROOT('reporte_deudores'), ELEMENTS XSINIL;
END;
GO

/* =========================================================
   4) Matriz de visitas: tabla cruzada mostrando visitas por mes y parque
   ========================================================= */
CREATE OR ALTER PROCEDURE reportes.sp_matriz_visitas
    @anio TINYINT
AS
BEGIN
    SET NOCOUNT ON;

    WITH Datos AS (
        SELECT
            p.id AS parque_id,
            MONTH(e.fecha_acceso) AS mes,
            e.id_item_reserva AS entrada_id
        FROM parques.Parque p
        LEFT JOIN reservas.Entrada e ON e.id_parque = p.id
        WHERE YEAR(e.fecha_acceso) = @anio
    ), Pivoteado AS (
        SELECT *
        FROM Datos
        PIVOT(count(entrada_id) FOR mes in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])) aliasPivot
    )
    select piv.parque_id as parque_id, parq.nombre as parque_nombre, 
        piv.[1] as 'Enero', 
        piv.[2] as 'Febrero', 
        piv.[3] as 'Marzo', 
        piv.[4] as 'Abril', 
        piv.[5] as 'Mayo',
        piv.[6] as 'Junio', 
        piv.[7] as 'Julio', 
        piv.[8] as 'Agosto', 
        piv.[9] as 'Septiembre', 
        piv.[10] as 'Octubre', 
        piv.[11] as 'Noviembre', 
        piv.[12] as 'Diciembre'
    from Pivoteado piv
    left join parques.Parque parq on piv.parque_id = parq.id

END;
GO

CREATE OR ALTER PROCEDURE reportes.sp_matriz_visitas_xml
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #matriz_visitas (
        parque_id INT,
        parque_nombre VARCHAR(100),
        Enero INT,
        Febrero INT,
        Marzo INT,
        Abril INT,
        Mayo INT,
        Junio INT,
        Julio INT,
        Agosto INT,
        Septiembre INT,
        Octubre INT,
        Noviembre INT,
        Diciembre INT,
    );

    INSERT INTO #matriz_visitas
    EXEC reportes.sp_matriz_visitas;

    SELECT *
    FROM #matriz_visitas
    FOR XML RAW('parque'), ROOT('reporte_matriz_visitas'), ELEMENTS XSINIL;
END;
GO

/* =========================================================
   5) Parques y concesiones: listado de parques con concesiones
   ========================================================= */
CREATE OR ALTER PROCEDURE reportes.sp_parques_concesiones_inicial
AS
BEGIN
    SET NOCOUNT ON;

    WITH ResultadoMostrable AS (
        SELECT
            p.id AS parque_id,
            p.nombre AS parque_nombre,
            co.id AS concesion_id,
            co.fecha_inicio AS fecha_inicio,
            co.fecha_fin AS fecha_fin,
            ec.id AS titular_id,
            ec.nombre AS titular_nombre,
            ae.nombre AS servicio_prestado,
            co.descripcion AS descripcion,
            CASE
                WHEN co.id IS NULL THEN 'Sin concesion'
                WHEN co.fecha_fin < CAST(GETDATE() AS DATE) THEN 'Vencida'
                ELSE 'Vigente'
            END AS estado
        FROM parques.Parque p
        LEFT JOIN concesiones.Concesion co ON co.id_parque = p.id
        LEFT JOIN concesiones.EmpresaConcesionaria ec ON ec.id = co.id_empresa_concesionaria
        LEFT JOIN concesiones.ActividadEmpresarial ae ON ae.id = ec.id_actividad_empresarial
    )
    SELECT *
    FROM ResultadoMostrable
END;
GO

CREATE OR ALTER PROCEDURE reportes.sp_parques_concesiones
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #parques_concesiones (
        parque_id INT,
        parque_nombre VARCHAR(100),
        concesion_id INT NULL,
        fecha_inicio DATE NULL,
        fecha_fin DATE NULL,
        titular_id INT NULL,
        titular_nombre VARCHAR(100) NULL,
        servicio_prestado VARCHAR(100) NULL,
        descripcion VARCHAR(255) NULL,
        estado VARCHAR(20)
    );

    INSERT INTO #parques_concesiones
    EXEC reportes.sp_parques_concesiones_inicial;

    SELECT
        P.parque_id,
        P.parque_nombre,
        (
            SELECT
                C.concesion_id,
                C.fecha_inicio,
                C.fecha_fin,
                C.titular_id,
                C.titular_nombre,
                C.servicio_prestado,
                C.descripcion,
                C.estado
            FROM #parques_concesiones C
            WHERE C.parque_id = P.parque_id
              AND C.concesion_id IS NOT NULL
            FOR XML RAW('concesion'), ELEMENTS XSINIL, TYPE
        ) AS concesiones
    FROM (
        SELECT DISTINCT
            parque_id,
            parque_nombre
        FROM #parques_concesiones
    ) P
END;
GO

CREATE OR ALTER PROCEDURE reportes.sp_parques_concesiones_xml
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #parques_concesiones (
        parque_id INT,
        parque_nombre VARCHAR(100),
        concesion_id INT NULL,
        fecha_inicio DATE NULL,
        fecha_fin DATE NULL,
        titular_id INT NULL,
        titular_nombre VARCHAR(100) NULL,
        servicio_prestado VARCHAR(100) NULL,
        descripcion VARCHAR(255) NULL,
        estado VARCHAR(20)
    );

    INSERT INTO #parques_concesiones
    EXEC reportes.sp_parques_concesiones_inicial;

    SELECT
        P.parque_id,
        P.parque_nombre,
        (
            SELECT
                C.concesion_id,
                C.fecha_inicio,
                C.fecha_fin,
                C.titular_id,
                C.titular_nombre,
                C.servicio_prestado,
                C.descripcion,
                C.estado
            FROM #parques_concesiones C
            WHERE C.parque_id = P.parque_id
              AND C.concesion_id IS NOT NULL
            FOR XML RAW('concesion'), ELEMENTS XSINIL, TYPE
        ) AS concesiones
    FROM (
        SELECT DISTINCT
            parque_id,
            parque_nombre
        FROM #parques_concesiones
    ) P
    FOR XML RAW('parque'), ROOT('reporte_parques_concesiones'), ELEMENTS XSINIL;
END;
GO
