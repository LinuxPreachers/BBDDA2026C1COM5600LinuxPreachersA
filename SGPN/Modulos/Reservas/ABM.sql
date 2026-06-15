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

--------------------------------------------------------------------------------------
-- Logica de negocio: Reservas, entradas, participaciones, cancelaciones y reembolsos
--------------------------------------------------------------------------------------

-- SP para registrar múltiples entradas y participaciones.
CREATE OR ALTER PROCEDURE reservas.sp_registrar_reserva
    @entradas reservas.TVP_Entradas READONLY,
    @participaciones reservas.TVP_Participaciones READONLY,
    @id_reserva INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    /*
     * Se utiliza SERIALIZABLE para el manejo de participaciones. Una participación antes de procesarse debe
     * verificar que haya cupos disponibles para esa actividad en el horario solicitado (verificando la cantidad
     * de participaciones registradas para la misma actividad en el mismo horario. Si se tiene otra transacción
     * cargando participaciones, si solo se usa REPEATABLE READ se le permitirá a la otra transacción insertar
     * participaciones como también a esta, generando reservas de participaciones por sobre el cupo máximo.
    */
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

    BEGIN TRY

        BEGIN TRANSACTION;

        ------------------------------------------------------
        -- Validar que exista algo para comprar
        ------------------------------------------------------

        IF NOT EXISTS (SELECT 1 FROM @entradas) AND NOT EXISTS (SELECT 1 FROM @participaciones)
            THROW 50315, 'Debe especificar al menos una entrada o participación.', 1;

        ------------------------------------------------------
        -- Crear Reserva
        ------------------------------------------------------

        INSERT INTO reservas.Reserva(fecha_y_hora)
        VALUES (GETDATE());

        SET @id_reserva = SCOPE_IDENTITY();

        ------------------------------------------------------
        -- Obtener estado inicial
        ------------------------------------------------------

        DECLARE @id_estado_reservada INT;

        SELECT @id_estado_reservada = id
        FROM reservas.EstadoItem
        WHERE nombre = 'Reservada';

        IF @id_estado_reservada IS NULL
            THROW 50316, 'No existe el estado Reservada.', 1;

        ------------------------------------------------------
        -- Variables para entradas
        ------------------------------------------------------

        DECLARE
            @id_item_reserva INT,
            @precio DECIMAL(10,2),
            @cantidad TINYINT,
            @contador TINYINT,

            @fila_entrada TINYINT = 1,
            @total_entradas TINYINT,

            @id_parque INT,
            @id_tipo_visitante INT,
            @fecha_acceso DATE;

        ------------------------------------------------------
        -- Procesar Entradas
        ------------------------------------------------------

        SELECT @total_entradas = COUNT(*)
        FROM @entradas;

        -- No se cargarán muchas filas de entradas por compra.
        -- El impacto del procesamiento iterativo será mínimo.

        WHILE @fila_entrada <= @total_entradas
        BEGIN

            SELECT
                @id_parque = id_parque,
                @id_tipo_visitante = id_tipo_visitante,
                @fecha_acceso = fecha_acceso,
                @cantidad = cantidad
            FROM @entradas
            WHERE fila = @fila_entrada;

            --------------------------------------------------
            -- Obtener precio de la entrada
            --------------------------------------------------

            SELECT @precio = precio
            FROM parques.ParqueTipoVisitante
            WHERE id_parque = @id_parque
              AND id_tipo_visitante = @id_tipo_visitante;

            IF @precio IS NULL
                THROW 50317, 'No existe un precio configurado para la entrada.', 1;

            --------------------------------------------------
            -- Crear tantas entradas como indique cantidad
            --------------------------------------------------

            SET @contador = 1;

            WHILE @contador <= @cantidad
            BEGIN

                INSERT INTO reservas.ItemReserva
                (precio, id_estado, id_reserva)
                VALUES
                (@precio, @id_estado_reservada, @id_reserva);

                SET @id_item_reserva = SCOPE_IDENTITY();

                INSERT INTO reservas.Entrada
                (id_item_reserva, fecha_acceso, id_parque, id_tipo_visitante)
                VALUES
                (@id_item_reserva, @fecha_acceso, @id_parque, @id_tipo_visitante);

                SET @contador += 1;
            END;

            SET @fila_entrada += 1;
        END;

        ------------------------------------------------------
        -- Variables para participaciones
        ------------------------------------------------------

        DECLARE
            @fila_participacion TINYINT = 1,
            @total_participaciones TINYINT,

            @id_horario INT,
            @fecha_realizacion DATE,

            @cupo_maximo SMALLINT,
            @cupos_utilizados INT;

        ------------------------------------------------------
        -- Procesar Participaciones
        ------------------------------------------------------

        SELECT
            @total_participaciones = COUNT(*)
        FROM @participaciones;

        WHILE @fila_participacion <= @total_participaciones
        BEGIN

            SELECT
                @id_horario = id_horario,
                @fecha_realizacion = fecha_realizacion,
                @cantidad = cantidad
            FROM @participaciones
            WHERE fila = @fila_participacion;

            --------------------------------------------------
            -- Obtener precio y cupo máximo
            --------------------------------------------------

            SELECT @precio = a.precio, @cupo_maximo = a.cupo_maximo
            FROM actividades.Horario h
            INNER JOIN actividades.Actividad a
            ON a.id = h.id_actividad
            WHERE h.id = @id_horario;

            IF @precio IS NULL
                THROW 50318, 'No existe el horario especificado.', 1;

            --------------------------------------------------
            -- Calcular cupos utilizados
            --------------------------------------------------

            SELECT @cupos_utilizados = COUNT(*)
            FROM reservas.Participacion p
            WHERE p.id_horario = @id_horario AND p.fecha_realizacion = @fecha_realizacion;

            SET @cupos_utilizados = ISNULL(@cupos_utilizados, 0);

            --------------------------------------------------
            -- Validar disponibilidad
            --------------------------------------------------

            IF @cupos_utilizados + @cantidad > @cupo_maximo
                THROW 50319, 'No hay cupos suficientes para la actividad seleccionada.', 1;

            ------------------------------------------------------
            -- Crear tantas participaciones como indique cantidad
            ------------------------------------------------------

            SET @contador = 1;

            WHILE @contador <= @cantidad
            BEGIN

                INSERT INTO reservas.ItemReserva
                (precio, id_estado, id_reserva)
                VALUES
                (@precio, @id_estado_reservada, @id_reserva);

                SET @id_item_reserva = SCOPE_IDENTITY();

                INSERT INTO reservas.Participacion
                (id_item_reserva, fecha_realizacion, id_horario)
                VALUES
                (@id_item_reserva, @fecha_realizacion, @id_horario);

                SET @contador += 1;
            END;

            SET @fila_participacion += 1;
        END;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH;

    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

END;
GO

-- SP para registrar el uso de una entrada a un parque.
CREATE OR ALTER PROCEDURE reservas.sp_utilizar_entrada
    @id_item_reserva INT,
    @id_parque_lector INT
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

    IF @fecha_acceso <> CAST(GETDATE() AS DATE)
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
    @id_actividad_lectora INT
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
            @estado_utilizada INT;

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

        IF @fecha_realizacion <> CAST(GETDATE() AS DATE)
            THROW 50313, 'La participación solo puede utilizarse en su fecha programada.', 1;

        ------------------------------------------------------
        -- Verificar horario
        ------------------------------------------------------

        IF CAST(GETDATE() AS TIME) < @hora_inicio
            THROW 50314, 'La actividad aún no ha comenzado.', 1;

        IF CAST(GETDATE() AS TIME) > @hora_fin
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
    @id_cancelacion INT OUTPUT
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