/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: Creación de SP ABM módulo reservas
*/

USE LinuxPreachers;
GO



---------------------------------------------------------
-- ABM: EstadoItem
---------------------------------------------------------

-- Alta
CREATE OR ALTER PROCEDURE reservas.sp_crear_estado_item
    @nombre VARCHAR(10),
    @descripcion VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        THROW 50301, 'El nombre ingresado para el estado del item no es válido.', 1;

    IF EXISTS (
        SELECT 1
        FROM reservas.EstadoItem
        WHERE nombre = @nombre
    )
        THROW 50302, 'Ya existe un estado de item con el nombre indicado.', 1;

    INSERT INTO reservas.EstadoItem (nombre, descripcion)
    VALUES (@nombre, @descripcion);
END;
GO

-- Modificación
CREATE OR ALTER PROCEDURE reservas.sp_modificar_estado_item
    @id TINYINT,
    @nombre VARCHAR(10),
    @descripcion VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @msj_errores VARCHAR(1000) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM reservas.EstadoItem
        WHERE id = @id
    )
        SET @msj_errores += '- El estado del item con el ID provisto no existe. ';

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @msj_errores += '- El nombre ingresado para el estado del item no es válido. ';

    IF (LEN(@msj_errores) > 0)
        THROW 50303, @msj_errores, 1

    IF EXISTS (
        SELECT 1
        FROM reservas.EstadoItem
        WHERE nombre = @nombre
          AND id <> @id
    )
        THROW 50304, 'Ya existe otro estado de item con el nombre indicado.', 1;

    UPDATE reservas.EstadoItem
    SET nombre = @nombre, descripcion = @descripcion
    WHERE id = @id;
END;
GO

-- Baja
CREATE OR ALTER PROCEDURE reservas.sp_eliminar_estado_item
    @id TINYINT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM reservas.EstadoItem
        WHERE id = @id
    )
        THROW 50305, 'El estado del item con el ID provisto no existe.', 1;

    IF EXISTS (
        SELECT 1
        FROM reservas.ItemReserva
        WHERE id_estado = @id
    )
        THROW 50306, 'No es posible eliminar el estado del item porque se encuentra asociado a items de reserva.', 1;

    DELETE FROM reservas.EstadoItem
    WHERE id = @id;
END;
GO

-- Baja (por nombre)
CREATE OR ALTER PROCEDURE reservas.sp_eliminar_estado_item_por_nombre
    @nombre VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_estado TINYINT;

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        THROW 50307, 'El nombre ingresado para el estado del item no es válido.', 1;

    SELECT @id_estado = id
    FROM reservas.EstadoItem
    WHERE nombre = @nombre;

    IF @id_estado IS NULL
        THROW 50308, 'El estado del item con el nombre provisto no existe.', 1;

    EXEC reservas.sp_eliminar_estado_item
        @id = @id_estado;
END;
GO

---------------------------------------------------------
-- ABM: MotivoCancelacion
---------------------------------------------------------

-- Alta
CREATE OR ALTER PROCEDURE reservas.sp_crear_motivo_cancelacion
    @nombre VARCHAR(10),
    @descripcion VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        THROW 50309, 'El nombre ingresado para el motivo de cancelación no es válido.', 1;

    IF EXISTS (
        SELECT 1
        FROM reservas.MotivoCancelacion
        WHERE nombre = @nombre
    )
        THROW 50310, 'Ya existe un motivo de cancelación con el nombre indicado.', 1;

    INSERT INTO reservas.MotivoCancelacion (nombre, descripcion)
    VALUES (@nombre, @descripcion);
END;
GO

-- Modificación
CREATE OR ALTER PROCEDURE reservas.sp_modificar_motivo_cancelacion
    @id INT,
    @nombre VARCHAR(10),
    @descripcion VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @msj_errores VARCHAR(1000) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM reservas.MotivoCancelacion
        WHERE id = @id
    )
        SET @msj_errores += '- El motivo de cancelación con el ID provisto no existe. ';

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @msj_errores += '- El nombre ingresado para el motivo de cancelación no es válido. ';

    IF (LEN(@msj_errores) > 0)
        THROW 50311, @msj_errores, 1

    IF EXISTS (
        SELECT 1
        FROM reservas.MotivoCancelacion
        WHERE nombre = @nombre
          AND id <> @id
    )
        THROW 50312, 'Ya existe otro motivo de cancelación con el nombre indicado.', 1;

    UPDATE reservas.MotivoCancelacion
    SET nombre = @nombre, descripcion = @descripcion
    WHERE id = @id;
END;
GO

-- Baja
CREATE OR ALTER PROCEDURE reservas.sp_eliminar_motivo_cancelacion
    @id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM reservas.MotivoCancelacion
        WHERE id = @id
    )
        THROW 50313, 'El motivo de cancelación con el ID provisto no existe.', 1;

    IF EXISTS (
        SELECT 1
        FROM reservas.Cancelacion
        WHERE id_motivo = @id
    )
        THROW 50314, 'No es posible eliminar el motivo de cancelación porque se encuentra asociado a cancelaciones existentes.', 1;

    DELETE FROM reservas.MotivoCancelacion
    WHERE id = @id;
END;
GO

-- Baja (por nombre)
CREATE OR ALTER PROCEDURE reservas.sp_eliminar_motivo_cancelacion_por_nombre
    @nombre VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_motivo TINYINT;

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        THROW 50307, 'El nombre ingresado para el motivo de cancelación no es válido.', 1;

    SELECT @id_motivo = id
    FROM reservas.MotivoCancelacion
    WHERE nombre = @nombre;

    IF @id_motivo IS NULL
        THROW 50308, 'El motivo de cancelación con el nombre provisto no existe.', 1;

    EXEC reservas.sp_eliminar_motivo_cancelacion
        @id = @id_motivo;
END;
GO


--Lectura Reservas

CREATE OR ALTER VIEW reservas.vw_leer_reservas AS
SELECT 
    id, 
    fecha_y_hora 
FROM reservas.Reserva;
GO

-- Lectura Participacion

CREATE OR ALTER VIEW reservas.vw_leer_participaciones AS
SELECT 
    p.id_item_reserva, 
    p.fecha_realizacion, 
    p.id_horario,
    ir.precio,
    ir.id_reserva,
    ir.id_estado,
    e.nombre AS estado
FROM reservas.Participacion p
INNER JOIN reservas.ItemReserva ir ON p.id_item_reserva = ir.id
INNER JOIN reservas.EstadoItem e ON ir.id_estado = e.id;
GO

-- Lectura Entradas
CREATE OR ALTER VIEW reservas.vw_leer_entradas AS
SELECT 
    en.id_item_reserva, 
    en.fecha_acceso, 
    en.id_parque, 
    en.id_tipo_visitante,
    ir.precio,
    ir.id_reserva,
    ir.id_estado,
    e.nombre AS estado
FROM reservas.Entrada en
INNER JOIN reservas.ItemReserva ir ON en.id_item_reserva = ir.id
INNER JOIN reservas.EstadoItem e ON ir.id_estado = e.id;
GO

--Lectura Motivo Cancelacion

CREATE OR ALTER VIEW reservas.vw_leer_motivo_cancelacion AS
SELECT 
    id, 
    nombre, 
    descripcion 
FROM reservas.MotivoCancelacion;
GO

-- Lectura Reembolsos

CREATE OR ALTER VIEW reservas.vw_leer_reembolsos AS
SELECT 
    r.id, 
    r.fecha_y_hora, 
    r.cvu_cuenta_destino, 
    r.id_cancelacion,
    c.id_motivo
FROM reservas.Reembolso r
INNER JOIN reservas.Cancelacion c ON r.id_cancelacion = c.id;
GO



--------------------------------------------------------------------------------------
-- Logica de negocio: Reservas, entradas, participaciones, cancelaciones y reembolsos
--------------------------------------------------------------------------------------

-- SP para registrar múltiples entradas y participaciones.
-- Nota: Este SP permite registrar no solo reservas en el momento, si no también cargar históricos.
CREATE OR ALTER PROCEDURE reservas.sp_registrar_reserva
    @entradas reservas.TVP_Entradas READONLY,
    @participaciones reservas.TVP_Participaciones READONLY,
    @fecha_y_hora_operacion DATETIME = NULL, -- Para reservas historicas
    @id_reserva INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @fecha_actual DATE = CAST(GETDATE() AS DATE);

        ------------------------------------------------------
        -- Validación de estados
        ------------------------------------------------------
        IF NOT EXISTS (SELECT 1 FROM @entradas) AND NOT EXISTS (SELECT 1 FROM @participaciones)
            THROW 50315, 'Debe especificar al menos una entrada o participación.', 1;

        DECLARE 
            @id_estado_reservada TINYINT,
            @id_estado_utilizada TINYINT;

        SELECT @id_estado_reservada = id FROM reservas.EstadoItem WHERE nombre = 'Reservada';
        SELECT @id_estado_utilizada = id FROM reservas.EstadoItem WHERE nombre = 'Utilizada';

        IF @id_estado_reservada IS NULL OR @id_estado_utilizada IS NULL
            THROW 50316, 'No existe alguno de los estados necesarios para registrar la reserva.', 1;

        ------------------------------------------------------
        -- Validación de existencia de precios
        ------------------------------------------------------
        IF EXISTS
        (
            SELECT 1
            FROM @entradas e
            LEFT JOIN parques.ParqueTipoVisitante ptv
                ON ptv.id_parque = e.id_parque
               AND ptv.id_tipo_visitante = e.id_tipo_visitante
            WHERE ptv.id_parque IS NULL
        )
            THROW 50317, 'No existe un precio configurado para una o más entradas.', 1;

        ------------------------------------------------------
        -- Validación de existencia de horarios
        ------------------------------------------------------

        IF EXISTS
        (
            SELECT 1
            FROM @participaciones p
            LEFT JOIN actividades.Horario h
                ON h.id = p.id_horario
            WHERE h.id IS NULL
        )
            THROW 50318, 'Uno o más horarios no existen.', 1;

        ------------------------------------------------------
        -- Validación de cupos
        ------------------------------------------------------
        IF EXISTS (
            SELECT 1
            FROM (
                -- Subconsulta 1: Sumamos lo que el usuario está pidiendo en este momento (Equivalente a CTE_Solicitado)
                SELECT id_horario, fecha_realizacion, SUM(cantidad) AS cantidad_solicitada
                FROM @participaciones
                GROUP BY id_horario, fecha_realizacion
            ) s
            INNER JOIN actividades.Horario h ON h.id = s.id_horario
            INNER JOIN actividades.Actividad a ON a.id = h.id_actividad
            LEFT JOIN (
                -- Subconsulta 2: Contamos lo ya reservado en la Base de Datos (Equivalente a CTE_Ocupado)
                SELECT p.id_horario, p.fecha_realizacion, COUNT(*) AS cantidad_ocupada
                FROM reservas.ItemReserva i
                INNER JOIN reservas.Participacion p ON i.id = p.id_item_reserva
                WHERE i.id_cancelacion IS NULL
                GROUP BY p.id_horario, p.fecha_realizacion
            ) o ON o.id_horario = s.id_horario AND o.fecha_realizacion = s.fecha_realizacion
            -- Comparamos si la suma supera el cupo máximo
            WHERE (ISNULL(o.cantidad_ocupada, 0) + s.cantidad_solicitada) > a.cupo_maximo
        )
        BEGIN;
            THROW 50319, 'No hay cupos suficientes para una o más de las actividades seleccionadas.', 1;
        END;

        ------------------------------------------------------
        -- Crear la reserva
        ------------------------------------------------------
        SET @fecha_y_hora_operacion = ISNULL(@fecha_y_hora_operacion, GETDATE());

        INSERT INTO reservas.Reserva (fecha_y_hora)
        VALUES (@fecha_y_hora_operacion);

        SET @id_reserva = SCOPE_IDENTITY();

        ------------------------------------------------------
        -- GENERADOR DE NÚMEROS (Para multiplicar filas)
        -- Esta CTE genera una lista del 1 al 100 de forma instantánea
        ------------------------------------------------------
        ;WITH L0 AS (SELECT 1 AS c UNION ALL SELECT 1), -- 2 filas
              L1 AS (SELECT 1 AS c FROM L0 AS a CROSS JOIN L0 AS b), -- 4 filas
              L2 AS (SELECT 1 AS c FROM L1 AS a CROSS JOIN L1 AS b), -- 16 filas
              L3 AS (SELECT 1 AS c FROM L2 AS a CROSS JOIN L2 AS b), -- 256 filas
              Numeros AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N FROM L3)
        ------------------------------------------------------
        -- Procesar entradas
        ------------------------------------------------------
        -- Desglosamos las entradas multiplicando las filas mediante el JOIN con "Numeros"
        SELECT
        ptv.precio,
        e.fecha_acceso,
        e.id_parque,
        e.id_tipo_visitante,
        CASE
            WHEN e.fecha_acceso < @fecha_actual -- Si la entrada es para una fecha anterior a hoy, ya se marca como utilizada.
                THEN @id_estado_utilizada
            ELSE @id_estado_reservada
        END AS id_estado

        INTO #EntradasAbiertas
        FROM @entradas e
        INNER JOIN parques.ParqueTipoVisitante ptv 
        ON ptv.id_parque = e.id_parque AND ptv.id_tipo_visitante = e.id_tipo_visitante
        INNER JOIN Numeros n 
        ON n.N <= e.cantidad; -- Si cantidad es 3, hace match con N=1, N=2 y N=3 (duplica la fila)

        IF EXISTS (SELECT 1 FROM #EntradasAbiertas)
        BEGIN
            -- Tabla para capturar los IDs que va a generar el INSERT masivo
            CREATE TABLE #IdsEntradasGenerados (
                fila_id INT IDENTITY(1,1),
                id_item_reserva INT
            );

            INSERT INTO reservas.ItemReserva (precio, id_estado, id_reserva)
            OUTPUT inserted.id INTO #IdsEntradasGenerados(id_item_reserva)
            SELECT precio, id_estado, @id_reserva
            FROM #EntradasAbiertas;

            -- Numeramos nuestras entradas desglosadas para poder unirlas con sus IDs correspondientes
            ;WITH CTE_EntradasConFila AS (
                SELECT *, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS fila_id
                FROM #EntradasAbiertas
            )
            INSERT INTO reservas.Entrada (id_item_reserva, fecha_acceso, id_parque, id_tipo_visitante)
            SELECT id.id_item_reserva, ea.fecha_acceso, ea.id_parque, ea.id_tipo_visitante
            FROM CTE_EntradasConFila ea
            INNER JOIN #IdsEntradasGenerados id ON ea.fila_id = id.fila_id;
        END;

        ------------------------------------------------------
        -- RE-GENERAR EL GENERADOR DE NÚMEROS (Para las participaciones)
        ------------------------------------------------------
        ;WITH L0 AS (SELECT 1 AS c UNION ALL SELECT 1), 
              L1 AS (SELECT 1 AS c FROM L0 AS a CROSS JOIN L0 AS b), 
              L2 AS (SELECT 1 AS c FROM L1 AS a CROSS JOIN L1 AS b), 
              L3 AS (SELECT 1 AS c FROM L2 AS a CROSS JOIN L2 AS b), 
              Numeros AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N FROM L3)

        ------------------------------------------------------
        -- Procesar las participaciones
        ------------------------------------------------------
        -- Desglosamos las participaciones de la misma manera
        SELECT 
            a.precio, 
            p.fecha_realizacion, 
            p.id_horario,
        CASE
            WHEN p.fecha_realizacion < @fecha_actual -- Si la participacion es para una fecha anterior a hoy, ya se marca como utilizada.
                THEN @id_estado_utilizada
            ELSE @id_estado_reservada
        END AS id_estado

        INTO #ParticipacionesAbiertas
        FROM @participaciones p
        INNER JOIN actividades.Horario h ON h.id = p.id_horario
        INNER JOIN actividades.Actividad a ON a.id = h.id_actividad
        INNER JOIN Numeros n ON n.N <= p.cantidad;

        IF EXISTS (SELECT 1 FROM #ParticipacionesAbiertas)
        BEGIN
            CREATE TABLE #IdsPartGenerados (id_item_reserva INT, fila_id INT IDENTITY(1,1));

            INSERT INTO reservas.ItemReserva (precio, id_estado, id_reserva)
            OUTPUT inserted.id INTO #IdsPartGenerados(id_item_reserva)
            SELECT precio, id_estado, @id_reserva
            FROM #ParticipacionesAbiertas;

            ;WITH CTE_ParticipacionesConFila AS (
                SELECT *, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS fila_id
                FROM #ParticipacionesAbiertas
            )
            INSERT INTO reservas.Participacion (id_item_reserva, fecha_realizacion, id_horario)
            SELECT id.id_item_reserva, pa.fecha_realizacion, pa.id_horario
            FROM CTE_ParticipacionesConFila pa
            INNER JOIN #IdsPartGenerados id ON pa.fila_id = id.fila_id;
        END;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
END;
GO

-- SP para registrar una reserva con su pago y ticket factura.
CREATE OR ALTER PROCEDURE reservas.sp_registrar_reserva_con_pago
    @entradas AS reservas.TVP_Entradas READONLY,
    @participaciones AS reservas.TVP_Participaciones READONLY,
    @fecha_y_hora_operacion DATETIME = NULL,
    @id_forma_pago TINYINT,
    @id_punto_venta SMALLINT,
    @id_reserva INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @msj_errores VARCHAR(1000) = '';

        ------------------------------------------------------
        -- 1. Validar ids de forma de pago, punto de venta e items reserva.
        -----------------------------------------------------

        --IF NOT EXISTS (SELECT 1 FROM pagos.FormaPago WHERE id = @id_forma_pago)
        --     SET @msj_errores += '- Forma de pago inexistente';

        --IF NOT EXISTS (SELECT 1 FROM pagos.PuntoVenta WHERE id = @id_punto_venta)
        --     SET @msj_errores += '- Punto de venta inexistente';

        --IF NOT EXISTS (SELECT 1 FROM @entradas) AND NOT EXISTS (SELECT 1 FROM @participaciones)
        --    SET @msj_errores += '- Debe especificar al menos una entrada o participación.';

        --IF (LEN(@msj_errores) > 0)
        --    THROW 50309, @msj_errores, 1

        ------------------------------------------------------
        -- 2. Generación de la Reserva.
        ------------------------------------------------------

        SET @fecha_y_hora_operacion = ISNULL(@fecha_y_hora_operacion, GETDATE());

        EXEC reservas.sp_registrar_reserva        
            @entradas = @entradas,
            @participaciones = @participaciones,
            @fecha_y_hora_operacion = @fecha_y_hora_operacion,
            @id_reserva = @id_reserva OUTPUT;

        ------------------------------------------------------
        -- 3. Registro del Pago.
        ------------------------------------------------------

        DECLARE @importe_total DECIMAL(15,2);
        DECLARE @id_pago_generado INT;
    
        -- Calculamos el monto total para el pago
        SELECT @importe_total = ISNULL(SUM(precio), 0)
        FROM reservas.ItemReserva
        WHERE id_reserva = @id_reserva;

        IF @importe_total > 0
        BEGIN
            EXEC pagos.sp_crear_pago        
                @fecha_y_hora = @fecha_y_hora_operacion,
                @id_reserva = @id_reserva,
                @id_forma_pago = @id_forma_pago,
                @importe = @importe_total,
                @id_pago = @id_pago_generado OUTPUT;

            ------------------------------------------------------
            -- 4. Emisión del Ticket Factura.
            ------------------------------------------------------

            EXEC pagos.sp_crear_ticket_factura        
                @fecha_y_hora = @fecha_y_hora_operacion,
                @id_punto_venta = @id_punto_venta,
                @id_pago = @id_pago_generado;
        END;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
    END CATCH;

END;
GO

-- SP para generar el historial de reservas (ficticio).
CREATE OR ALTER PROCEDURE reservas.sp_generar_reservas_historicas
    @id_parque INT,
    @fecha_inicio DATE,
    @fecha_fin DATE,
    @reservas_por_dia TINYINT = 3
AS
BEGIN
    SET NOCOUNT ON;

    -----------------------------------------------------
    -- Validaciones
    -----------------------------------------------------

    IF @fecha_fin < @fecha_inicio
        THROW 50000, 'La fecha de fin debe ser mayor o igual a la fecha de inicio.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM parques.Parque
        WHERE id = @id_parque
    )
        THROW 50000, 'El parque indicado no existe.', 1;

    IF @reservas_por_dia <= 0
        THROW 50000, 'Debe especificarse una cantidad positiva de reservas por día', 1;

    -----------------------------------------------------
    -- Variables
    -----------------------------------------------------

    DECLARE
        @fecha_actual DATE,
        @reserva_del_dia TINYINT,
        @modo TINYINT,
        @entradas reservas.TVP_Entradas,
        @participaciones reservas.TVP_Participaciones;

    SET @fecha_actual = @fecha_inicio;

    -----------------------------------------------------
    -- Carga datos auxiliares
    -----------------------------------------------------

    -- Formas de pago
    DECLARE @formas_pago TABLE (
        fila INT PRIMARY KEY,
        id TINYINT
    );

    INSERT INTO @formas_pago
    SELECT ROW_NUMBER() OVER (ORDER BY id), id
    FROM pagos.FormaPago
    WHERE estado = 1;

    -- Puntos de venta
    DECLARE @puntos_venta TABLE (
        fila INT PRIMARY KEY,
        id SMALLINT
    );

    INSERT INTO @puntos_venta
    SELECT ROW_NUMBER() OVER (ORDER BY id), id
    FROM pagos.PuntoVenta WHERE estado = 1;

    -- Tipos de visitante
    DECLARE @tipos_visitante TABLE (
        fila INT PRIMARY KEY,
        id TINYINT
    );

    INSERT INTO @tipos_visitante
    SELECT ROW_NUMBER() OVER (ORDER BY id_tipo_visitante), id_tipo_visitante
    FROM parques.ParqueTipoVisitante
    WHERE id_parque = @id_parque;

    -- Horarios
    DECLARE @horarios TABLE (
        fila INT PRIMARY KEY,
        id_horario INT,
        dia_semana TINYINT,
        fecha_ini DATE,
        fecha_fin DATE
    );

    INSERT INTO @horarios
    SELECT
        ROW_NUMBER() OVER(ORDER BY h.id),
        h.id,
        h.dia_semana,
        h.fecha_vigencia_ini,
        h.fecha_vigencia_fin
    FROM actividades.Horario h
    JOIN actividades.Actividad a
        ON a.id = h.id_actividad
    WHERE a.id_parque = @id_parque;

    -----------------------------------------------------
    -- Generación de reservas
    -----------------------------------------------------

    WHILE @fecha_actual <= @fecha_fin
    BEGIN

        SET @reserva_del_dia = 1;

        WHILE @reserva_del_dia <= @reservas_por_dia
        BEGIN

            DECLARE
                @id_tipo_visitante TINYINT = (SELECT TOP 1 id FROM @tipos_visitante ORDER BY NEWID()),
                @id_horario INT,
                @dias_offset TINYINT = CAST((RAND() * 180) AS TINYINT),
                @cantidad TINYINT = CAST(((RAND() * 3) +1) AS TINYINT),
                @id_forma_pago TINYINT = (SELECT TOP 1 id FROM @formas_pago ORDER BY NEWID()),
                @id_punto_venta SMALLINT = (SELECT TOP 1 id FROM @puntos_venta ORDER BY NEWID());

            DECLARE @fecha_utilizacion DATE = DATEADD(DAY, @dias_offset, @fecha_actual);

            /*
            * Se distribuye el porcentaje entre entradas solas, con participaciones o participaciones solas:
            * 70% de entradas solas.
            * 20% de entradas con participaciones.
            * 10% de participaciones solas.
            */
            SET @modo = CAST(RAND(CHECKSUM(NEWID())) * 10 AS TINYINT);

            IF @modo <= 8
            BEGIN
                INSERT INTO @entradas(id_parque, id_tipo_visitante, fecha_acceso, cantidad)
                VALUES(@id_parque, @id_tipo_visitante, @fecha_utilizacion, @cantidad);
            END;

            IF @modo >= 7
            BEGIN

                -- Calcula que día de la semana le corresponde a la fecha de utilización.
                DECLARE @dia_semana TINYINT = ((DATEDIFF(DAY, '19000101', @fecha_utilizacion) % 7) + 1);

                -- Con ese día de la semana, obtiene un horario aleatorio.
                SELECT TOP 1 @id_horario = h.id_horario
                FROM @horarios h
                WHERE h.dia_semana = @dia_semana
                AND @fecha_utilizacion >= h.fecha_ini
                AND (
                        h.fecha_fin IS NULL
                        OR @fecha_utilizacion <= h.fecha_fin
                )
                ORDER BY NEWID();

                -- Si encontró un horario válido, carga la participación.
                IF @id_horario IS NOT NULL
                BEGIN
                    INSERT INTO @participaciones (id_horario, fecha_realizacion, cantidad)
                    VALUES (@id_horario, @fecha_utilizacion, 1);
                END
            END;

            -- Valida que realmente se haya cargado algo, 
            -- podría ocurrir que solo se necesite una participación pero no encuentre un horario, y no cargue nada.
            IF EXISTS (SELECT 1 FROM @entradas) OR EXISTS (SELECT 1 FROM @participaciones)
            BEGIN

                EXEC reservas.sp_registrar_reserva_con_pago
                    @entradas = @entradas,
                    @participaciones = @participaciones,
                    @fecha_y_hora_operacion = @fecha_actual,
                    @id_forma_pago = @id_forma_pago,
                    @id_punto_venta = @id_punto_venta;

                -- Limpia las tablas variables para la proxima iteración.
                DELETE FROM @entradas;
                DELETE FROM @participaciones;

                SET @reserva_del_dia += 1;
            END            
        END;

        SET @fecha_actual = DATEADD(DAY, 1, @fecha_actual);
    END;
END;
GO

-- SP para registrar el uso de una entrada a un parque.
CREATE OR ALTER PROCEDURE reservas.sp_utilizar_entrada
    @id_item_reserva INT,
    @id_parque_lector INT,
    @modo_historico BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @id_estado TINYINT,
        @fecha_acceso DATE,
        @estado_reservada TINYINT,
        @estado_utilizada TINYINT,
        @id_parque_destino INT;

    ------------------------------------------------------
    -- Verificar existencia del ItemReserva
    ------------------------------------------------------

    SELECT @id_estado = id_estado
    FROM reservas.ItemReserva
    WHERE id = @id_item_reserva;

    IF @id_estado IS NULL
        THROW 50317, 'El item de reserva indicado no existe.', 1;

    ------------------------------------------------------
    -- Verificar que corresponda a una entrada
    ------------------------------------------------------

    SELECT @fecha_acceso = fecha_acceso, @id_parque_destino = id_parque
    FROM reservas.Entrada
    WHERE id_item_reserva = @id_item_reserva;

    IF @id_parque_destino IS NULL
        THROW 50318, 'El item indicado no corresponde a una entrada.', 1;

    ------------------------------------------------------------------------------------
    -- Verificar que corresponda a una entrada del parque que se intenta acceder.
    ------------------------------------------------------------------------------------

    IF @id_parque_destino <> @id_parque_lector
        THROW 50319, 'La entrada indicada no corresponde al parque que se intenta acceder.', 1;

    ------------------------------------------------------
    -- Obtener estados
    ------------------------------------------------------

    SELECT @estado_reservada = id
    FROM reservas.EstadoItem
    WHERE nombre = 'Reservada';

    SELECT @estado_utilizada = id
    FROM reservas.EstadoItem
    WHERE nombre = 'Utilizada';

    ------------------------------------------------------
    -- Verificar estado
    ------------------------------------------------------

    IF @estado_reservada IS NULL OR @estado_utilizada IS NULL
        THROW 50320, 'No existe el estado Reservada o Utilizada.', 1;

    IF @id_estado <> @estado_reservada
        THROW 50321, 'La entrada ya fue utilizada o cancelada.', 1;

    ------------------------------------------------------
    -- Verificar fecha
    ------------------------------------------------------

    IF @modo_historico = 0 AND @fecha_acceso <> CAST(GETDATE() AS DATE)
        THROW 50322, 'La entrada solo puede utilizarse en su fecha de acceso.', 1;

    ------------------------------------------------------
    -- Actualizar estado
    ------------------------------------------------------

    UPDATE reservas.ItemReserva
    SET id_estado = @estado_utilizada
    WHERE id = @id_item_reserva;
END;
GO

-- SP para registrar el uso de una participación a un parque.
CREATE OR ALTER PROCEDURE reservas.sp_utilizar_participacion
    @id_item_reserva INT,
    @id_actividad_lectora INT,
    @modo_historico BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        DECLARE
            @id_estado INT,
            @id_actividad_destino INT,
            @fecha_realizacion DATE,
            @id_horario INT,
            @hora_inicio TIME,
            @hora_fin TIME,
            @estado_reservada INT,
            @estado_utilizada INT,
            @hora_actual TIME;

        ------------------------------------------------------
        -- Verificar ItemReserva
        ------------------------------------------------------

        SELECT @id_estado = id_estado
        FROM reservas.ItemReserva
        WHERE id = @id_item_reserva;

        IF @id_estado IS NULL
            THROW 50310, 'El item de reserva indicado no existe.', 1;

        ------------------------------------------------------
        -- Obtener participación
        ------------------------------------------------------

        SELECT
            @fecha_realizacion = fecha_realizacion,
            @id_horario = id_horario
        FROM reservas.Participacion
        WHERE id_item_reserva = @id_item_reserva;

        IF @id_horario IS NULL
            THROW 50311, 'El item indicado no corresponde a una participación.', 1;

         ------------------------------------------------------
        -- Obtener horario
        ------------------------------------------------------

        SELECT 
            @id_actividad_destino = id_actividad,
            @hora_inicio = hora_inicio,
            @hora_fin = hora_fin
        FROM actividades.Horario
        WHERE id = @id_horario

        ------------------------------------------------------
        -- Obtener horario
        ------------------------------------------------------

        IF @id_actividad_destino <> @id_actividad_lectora
            THROW 50319, 'La participación indicada no corresponde a la actividad que se intenta acceder.', 1;

        ------------------------------------------------------
        -- Obtener estados
        ------------------------------------------------------

        SELECT @estado_reservada = id
        FROM reservas.EstadoItem
        WHERE nombre = 'Reservada';

        SELECT @estado_utilizada = id
        FROM reservas.EstadoItem
        WHERE nombre = 'Utilizada';

        ------------------------------------------------------
        -- Verificar estado
        ------------------------------------------------------

        IF @id_estado <> @estado_reservada
            THROW 50312, 'La participación ya fue utilizada o cancelada.', 1;

        ------------------------------------------------------
        -- Verificar fecha
        ------------------------------------------------------

        IF @modo_historico = 0 AND @fecha_realizacion <> CAST(GETDATE() AS DATE)
            THROW 50313, 'La participación solo puede utilizarse en su fecha programada.', 1;

        ------------------------------------------------------
        -- Verificar horario
        ------------------------------------------------------

        SET @hora_actual = CAST(GETDATE() AS TIME);

        IF @modo_historico = 0 AND @hora_actual < @hora_inicio
            THROW 50314, 'La actividad aún no ha comenzado.', 1;

        IF @modo_historico = 0 AND @hora_actual > @hora_fin
            THROW 50315, 'La actividad ya ha finalizado.', 1;

        ------------------------------------------------------
        -- Actualizar estado
        ------------------------------------------------------

        UPDATE reservas.ItemReserva
        SET id_estado = @estado_utilizada
        WHERE id = @id_item_reserva;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH
END;
GO

-- SP para cancelar 1 o N ítems de reserva.
CREATE OR ALTER PROCEDURE reservas.sp_cancelar_items_reserva
    @items reservas.TVP_ItemsReserva READONLY,
    @id_motivo INT,
    @id_cancelacion INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        DECLARE
            @id_reserva INT,
            @cantidad_items INT,
            @cantidad_existentes INT,
            @estado_reservada INT,
            @estado_cancelada INT,
            @msj_errores VARCHAR(1000) = '';

        ------------------------------------------------------
        -- Verificar que haya items
        ------------------------------------------------------

        IF NOT EXISTS (SELECT 1 FROM @items)
            THROW 50320, 'Debe indicar al menos un item a cancelar.', 1;

        ------------------------------------------------------
        -- Verificar existencia
        ------------------------------------------------------

        SELECT @cantidad_items = COUNT(*)
        FROM @items;

        SELECT @cantidad_existentes = COUNT(*)
        FROM reservas.ItemReserva ir
        INNER JOIN @items i
            ON i.id_item_reserva = ir.id;

        IF @cantidad_items <> @cantidad_existentes
            THROW 50321, 'Uno o más items indicados no existen.', 1;

        ------------------------------------------------------
        -- Verificar misma reserva
        ------------------------------------------------------

        IF (
            SELECT COUNT(DISTINCT id_reserva)
            FROM reservas.ItemReserva ir
            INNER JOIN @items i
                ON i.id_item_reserva = ir.id
        ) > 1
            SET @msj_errores += '- Los items a cancelar deben pertenecer a la misma reserva. ';

        ------------------------------------------------------
        -- Obtener estados
        ------------------------------------------------------

        SELECT @estado_reservada = id
        FROM reservas.EstadoItem
        WHERE nombre = 'Reservada';

        SELECT @estado_cancelada = id
        FROM reservas.EstadoItem
        WHERE nombre = 'Cancelada';

        ------------------------------------------------------
        -- Verificar estados
        ------------------------------------------------------

        IF EXISTS (
            SELECT 1
            FROM reservas.ItemReserva ir
            INNER JOIN @items i
                ON i.id_item_reserva = ir.id
            WHERE ir.id_estado <> @estado_reservada
        )
            SET @msj_errores += '- Existen items que ya fueron utilizados o cancelados. ';

        IF (LEN(@msj_errores) > 0)
            THROW 50323, @msj_errores, 1

        ------------------------------------------------------
        -- Crear cancelación
        ------------------------------------------------------

        INSERT INTO reservas.Cancelacion
        (fecha_y_hora, id_motivo)
        VALUES
        (GETDATE(), @id_motivo);

        SET @id_cancelacion = SCOPE_IDENTITY();

        ------------------------------------------------------
        -- Actualizar items
        ------------------------------------------------------

        UPDATE ir
        SET
            ir.id_estado = @estado_cancelada,
            ir.id_cancelacion = @id_cancelacion
        FROM reservas.ItemReserva ir
        INNER JOIN @items i
            ON i.id_item_reserva = ir.id;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH
END;
GO

-- SP para registrar el reembolso referido a una cancelación.
CREATE OR ALTER PROCEDURE reservas.sp_registrar_reembolso
    @id_cancelacion INT,
    @cvu_cuenta_destino VARCHAR(23) -- Permite hasta 1 caracter para poder validar si se pasó de largo
AS
BEGIN
    SET NOCOUNT ON;

    ------------------------------------------------------
    -- Verificar existencia cancelación
    ------------------------------------------------------

    IF NOT EXISTS (
        SELECT 1
        FROM reservas.Cancelacion
        WHERE id = @id_cancelacion
    )
        THROW 50330, 'La cancelación indicada no existe.', 1;

    ------------------------------------------------------
    -- Verificar reembolso previo
    ------------------------------------------------------

    IF EXISTS (
        SELECT 1
        FROM reservas.Reembolso
        WHERE id_cancelacion = @id_cancelacion
    )
        THROW 50331, 'Ya existe un reembolso para esta cancelación.', 1;

    ------------------------------------------------------
    -- Verificar formato CVU
    ------------------------------------------------------

    IF (LEN(LTRIM(RTRIM(@cvu_cuenta_destino))) <> 22 OR @cvu_cuenta_destino LIKE '%[^0-9]%')
        THROW 50332, 'El CVU debe seguir el formato de 22 números.', 1;

    ------------------------------------------------------
    -- Registrar reembolso
    ------------------------------------------------------

    INSERT INTO reservas.Reembolso
    (fecha_y_hora, cvu_cuenta_destino, id_cancelacion)
    VALUES
    (GETDATE(), @cvu_cuenta_destino, @id_cancelacion);
END;
GO