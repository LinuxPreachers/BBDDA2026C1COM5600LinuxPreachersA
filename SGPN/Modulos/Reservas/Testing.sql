/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: Testing ABM módulo reservas
*/

/*
 * Consideraciones a tener en cuenta:
 *
 * Cada test es autocontenido, es decir, genera los datos que necesita para poder realizar la prueba, 
 * no depende de datos ya cargados. Esto se realiza con SP especiales que se podrán encontrar a medida 
 * que se avanza por el script.
 *
 * La información insertada, modificada o eliminada por cada test se revierte automáticamente al finalizar
 * cada uno utilizando transacciones, evitando datos basura.
 *
 * En cada test, se asume que los demás SP utilizados (salvo el que se quiere probar) funcionan.
 *
 * Para los tests de IDs inexistente, se utilizan los valores -1 en campos INT y 0 en TINYINT (dado que
 * no admite negativos). Estos valores no son utilizados por registros normalmente, por lo que es seguro
 * utilizarlos.
*/

USE LinuxPreachers;
GO

-- ==============================================================================
-- 1. EstadoItem
-- ==============================================================================

---------------------------------------------------------
-- 1.1 ALTA EXITOSA
---------------------------------------------------------
BEGIN TRANSACTION;

BEGIN TRY

    IF EXISTS (SELECT 1 FROM reservas.EstadoItem WHERE nombre = 'TEST_1')
        EXEC reservas.sp_eliminar_estado_item_por_nombre
            @nombre = 'TEST_1';

    PRINT 'NOMBRE VALIDO, SE ESPERA QUE EL ALTA SEA EXITOSA';

    EXEC reservas.sp_crear_estado_item
        @nombre = 'TEST_1',
        @descripcion = 'Descripcion de prueba';

    SELECT
        id,
        nombre,
        descripcion
    FROM reservas.EstadoItem
    WHERE nombre = 'TEST_1';

END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 1.2 ALTA FALLIDA (NOMBRE NULL)
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    PRINT 'NOMBRE NULL, SE ESPERA ERROR';

    EXEC reservas.sp_crear_estado_item
        @nombre = NULL,
        @descripcion = 'Descripcion';

    PRINT 'SI EJECUTO ESTO, EL SP PERMITIO UN NOMBRE NULL';

END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 1.3 ALTA FALLIDA (NOMBRE VACIO)
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    PRINT 'NOMBRE VACIO, SE ESPERA ERROR';

    EXEC reservas.sp_crear_estado_item
        @nombre = '',
        @descripcion = 'Descripcion';

    PRINT 'SI EJECUTO ESTO, EL SP PERMITIO UN NOMBRE VACIO';

END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 1.4 ALTA FALLIDA (NOMBRE DUPLICADO)
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    IF NOT EXISTS (SELECT 1 FROM reservas.EstadoItem WHERE nombre = 'TEST_1')
        EXEC reservas.sp_crear_estado_item
            @nombre = 'TEST_1';

    PRINT 'NOMBRE DUPLICADO, SE ESPERA ERROR';

    EXEC reservas.sp_crear_estado_item
        @nombre = 'TEST_1';

    PRINT 'SI EJECUTO ESTO, EL SP PERMITIO NOMBRES DUPLICADOS';

END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 1.5 MODIFICACION EXITOSA
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE @id_estado TINYINT;

    IF EXISTS (SELECT 1 FROM reservas.EstadoItem WHERE nombre = 'TEST_1')
        EXEC reservas.sp_eliminar_estado_item_por_nombre
            @nombre = 'TEST_1';

    IF EXISTS (SELECT 1 FROM reservas.EstadoItem WHERE nombre = 'TEST_2')
        EXEC reservas.sp_eliminar_estado_item_por_nombre
            @nombre = 'TEST_2';

    EXEC reservas.sp_crear_estado_item
        @nombre = 'TEST_1',
        @descripcion = 'Descripcion original';

    SELECT @id_estado = id
    FROM reservas.EstadoItem
    WHERE nombre = 'TEST_1';

    PRINT 'DATOS VALIDOS, SE ESPERA MODIFICACION EXITOSA';

    EXEC reservas.sp_modificar_estado_item
        @id = @id_estado,
        @nombre = 'TEST_2',
        @descripcion = 'Descripcion modificada';

    SELECT
        id,
        nombre,
        descripcion
    FROM reservas.EstadoItem
    WHERE id = @id_estado;

END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 1.6 MODIFICACION FALLIDA (ID INEXISTENTE)
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    PRINT 'ID INEXISTENTE, SE ESPERA ERROR';

    EXEC reservas.sp_modificar_estado_item
        @id = 0, -- No se puede utilizar -1 por ser un TINYINT
        @nombre = 'TEST_1';

    PRINT 'SI EJECUTO ESTO, EL SP PERMITIO MODIFICAR UN ID INEXISTENTE';

END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 1.7 MODIFICACION FALLIDA (NOMBRE INVALIDO)
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE @id_estado TINYINT;

    IF NOT EXISTS (SELECT 1 FROM reservas.EstadoItem WHERE nombre = 'TEST_1')
        EXEC reservas.sp_crear_estado_item
            @nombre = 'TEST_1';

    SELECT @id_estado = id
    FROM reservas.EstadoItem
    WHERE nombre = 'TEST_1';

    PRINT 'NOMBRE INVALIDO, SE ESPERA ERROR';

    EXEC reservas.sp_modificar_estado_item
        @id = @id_estado,
        @nombre = '';

    PRINT 'SI EJECUTO ESTO, EL SP PERMITIO UN NOMBRE INVALIDO';

END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 1.8 MODIFICACION FALLIDA (ID INEXISTENTE Y NOMBRE INVALIDO)
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    PRINT 'ID INEXISTENTE Y NOMBRE INVALIDO, SE ESPERA ERROR';

    EXEC reservas.sp_modificar_estado_item
        @id = 0, -- No se puede utilizar -1 por ser un TINYINT
        @nombre = NULL;

    PRINT 'SI EJECUTO ESTO, EL SP NO INFORMO LOS ERRORES CORRESPONDIENTES';

END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 1.9 MODIFICACION FALLIDA (NOMBRE DUPLICADO)
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE @id_estado TINYINT;

    IF NOT EXISTS (SELECT 1 FROM reservas.EstadoItem WHERE nombre = 'TEST_1')
        EXEC reservas.sp_crear_estado_item
            @nombre = 'TEST_1';

    IF NOT EXISTS (SELECT 1 FROM reservas.EstadoItem WHERE nombre = 'TEST_2')
        EXEC reservas.sp_crear_estado_item
            @nombre = 'TEST_2';

    SELECT @id_estado = id
    FROM reservas.EstadoItem
    WHERE nombre = 'TEST_2';

    PRINT 'NOMBRE DUPLICADO, SE ESPERA ERROR';

    EXEC reservas.sp_modificar_estado_item
        @id = @id_estado,
        @nombre = 'TEST_1';

    PRINT 'SI EJECUTO ESTO, EL SP PERMITIO DUPLICAR NOMBRES';

END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 1.10 MODIFICACION EXITOSA (MISMO NOMBRE)
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE @id_estado TINYINT;

    IF EXISTS (SELECT 1 FROM reservas.EstadoItem WHERE nombre = 'TEST_1')
        EXEC reservas.sp_eliminar_estado_item_por_nombre
            @nombre = 'TEST_1';

    EXEC reservas.sp_crear_estado_item
        @nombre = 'TEST_1',
        @descripcion = 'Descripcion original';

    SELECT @id_estado = id
    FROM reservas.EstadoItem
    WHERE nombre = 'TEST_1';

    PRINT 'MISMO NOMBRE, SE ESPERA MODIFICACION EXITOSA';

    EXEC reservas.sp_modificar_estado_item
        @id = @id_estado,
        @nombre = 'TEST_1',
        @descripcion = 'Descripcion modificada';

    SELECT
        id,
        nombre,
        descripcion
    FROM reservas.EstadoItem
    WHERE id = @id_estado;

END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 1.11 BAJA EXITOSA (POR ID)
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE @id_estado TINYINT;

    IF NOT EXISTS (SELECT 1 FROM reservas.EstadoItem WHERE nombre = 'TEST_1')
        EXEC reservas.sp_crear_estado_item
            @nombre = 'TEST_1';

    SELECT @id_estado = id
    FROM reservas.EstadoItem
    WHERE nombre = 'TEST_1';

    PRINT 'ID EXISTENTE SIN DEPENDENCIAS, SE ESPERA BAJA EXITOSA';

    EXEC reservas.sp_eliminar_estado_item
        @id = @id_estado;

    SELECT *
    FROM reservas.EstadoItem
    WHERE id = @id_estado;

END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 1.12 BAJA FALLIDA (ID INEXISTENTE)
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    PRINT 'ID INEXISTENTE, SE ESPERA ERROR';

    EXEC reservas.sp_eliminar_estado_item
        @id = 0; -- No se puede utilizar -1 por ser un TINYINT

    PRINT 'SI EJECUTO ESTO, EL SP PERMITIO ELIMINAR UN ID INEXISTENTE';

END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 1.13 BAJA EXITOSA (POR NOMBRE)
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    IF NOT EXISTS (SELECT 1 FROM reservas.EstadoItem WHERE nombre = 'TEST_1')
        EXEC reservas.sp_crear_estado_item
            @nombre = 'TEST_1';

    PRINT 'NOMBRE EXISTENTE SIN DEPENDENCIAS, SE ESPERA BAJA EXITOSA';

    EXEC reservas.sp_eliminar_estado_item_por_nombre
        @nombre = 'TEST_1';

    SELECT *
    FROM reservas.EstadoItem
    WHERE nombre = 'TEST_1';

END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 1.14 BAJA FALLIDA (NOMBRE NULL)
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    PRINT 'NOMBRE NULL, SE ESPERA ERROR';

    EXEC reservas.sp_eliminar_estado_item_por_nombre
        @nombre = NULL;

    PRINT 'SI EJECUTO ESTO, EL SP PERMITIO UN NOMBRE NULL';

END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 1.15 BAJA FALLIDA (NOMBRE VACIO)
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    PRINT 'NOMBRE VACIO, SE ESPERA ERROR';

    EXEC reservas.sp_eliminar_estado_item_por_nombre
        @nombre = '';

    PRINT 'SI EJECUTO ESTO, EL SP PERMITIO UN NOMBRE VACIO';

END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 1.16 BAJA FALLIDA (NOMBRE INEXISTENTE)
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    PRINT 'NOMBRE INEXISTENTE, SE ESPERA ERROR';

    EXEC reservas.sp_eliminar_estado_item_por_nombre
        @nombre = 'TEST_INEX';

    PRINT 'SI EJECUTO ESTO, EL SP PERMITIO ELIMINAR UN NOMBRE INEXISTENTE';

END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 1.17 BAJA FALLIDA (ESTADO ASOCIADO A ITEMS DE RESERVA)
---------------------------------------------------------

-- Creación de registros auxiliares
CREATE OR ALTER PROCEDURE reservas.sp_crear_registros_baja_aux 
    @id_estado TINYINT
AS 
BEGIN
    DECLARE
        @id_tipo_parque INT,
        @id_parque INT,
        @id_tipo_visitante INT,
        @id_reserva INT;

    EXEC parques.sp_crear_tipo_parque
        @descripcion = 'TIPO_PARQUE_TEST_ESTADO_ITEM';

    SELECT @id_tipo_parque = id
    FROM parques.TipoParque
    WHERE descripcion = 'TIPO_PARQUE_TEST_ESTADO_ITEM';

    EXEC parques.sp_crear_parque
        @nombre = 'PARQUE_TEST_ESTADO_ITEM',
        @id_tipo_parque = @id_tipo_parque;

    SELECT @id_parque = id
    FROM parques.Parque
    WHERE nombre = 'PARQUE_TEST_ESTADO_ITEM';

    EXEC parques.sp_crear_tipo_visitante
        @nombre = 'TIPO_VISITANTE_TEST_ESTADO_ITEM';

    SELECT @id_tipo_visitante = id
    FROM parques.TipoVisitante
    WHERE nombre = 'TIPO_VISITANTE_TEST_ESTADO_ITEM';

    IF NOT EXISTS (SELECT 1 FROM reservas.EstadoItem WHERE nombre = 'Reservada')
        EXEC reservas.sp_crear_estado_item
            @nombre = 'Reservada'

    EXEC parques.sp_crear_parque_tipo_visitante
        @id_parque, @id_tipo_visitante, 1000;

    -- En este caso, no se poseen SPs particulares para directamente asignarle un estado a un item reserva,
    -- se hace mediante la logica de negocio. Por simplicidad (y ya que es un test, algo interno del sistema)
    -- se decidió hacer la carga directa.
    INSERT INTO reservas.Reserva (fecha_y_hora) VALUES (GETDATE());

    SET @id_reserva = SCOPE_IDENTITY();
    
    INSERT INTO reservas.ItemReserva (precio, id_reserva, id_estado) VALUES
    (1000, @id_reserva, @id_estado);

END;
GO

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE @id_estado TINYINT;

    IF NOT EXISTS (SELECT 1 FROM reservas.EstadoItem WHERE nombre = 'TEST_1')
        EXEC reservas.sp_crear_estado_item
            @nombre = 'TEST_1';

    SELECT @id_estado = id
    FROM reservas.EstadoItem
    WHERE nombre = 'TEST_1';

    -- Se crean los registros necesarios para asociar un ItemReserva al estado.
    EXEC reservas.sp_crear_registros_baja_aux @id_estado;

    PRINT 'ESTADO ASOCIADO A ITEMS DE RESERVA, SE ESPERA ERROR';

    EXEC reservas.sp_eliminar_estado_item
        @id = @id_estado;

    PRINT 'SI EJECUTO ESTO, EL SP PERMITIO ELIMINAR UN ESTADO ASOCIADO';

END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

ROLLBACK TRANSACTION;
GO

-- ==============================================================================
-- 2. Motivos de cancelación
-- ==============================================================================

-- PENDIENTE

-- ==============================================================================
-- 3. Reservas
-- ==============================================================================

-- Creación de registros auxiliares (Solo parques)
CREATE OR ALTER PROCEDURE reservas.sp_crear_registros_entrada_aux 
    @id_parque INT OUTPUT,
    @id_tipo_visitante INT OUTPUT
AS 
BEGIN
    DECLARE
        @id_tipo_parque INT,
        @id_reserva INT;

    EXEC parques.sp_crear_tipo_parque
        @descripcion = 'TIPO_PARQUE_TEST_RESERVA';

    SELECT @id_tipo_parque = id
    FROM parques.TipoParque
    WHERE descripcion = 'TIPO_PARQUE_TEST_RESERVA';

    EXEC parques.sp_crear_parque
        @nombre = 'PARQUE_TEST_RESERVA',
        @id_tipo_parque = @id_tipo_parque;

    SELECT @id_parque = id
    FROM parques.Parque
    WHERE nombre = 'PARQUE_TEST_RESERVA';

    EXEC parques.sp_crear_tipo_visitante
        @nombre = 'TIPO_VISITANTE_TEST_RESERVA';

    SELECT @id_tipo_visitante = id
    FROM parques.TipoVisitante
    WHERE nombre = 'TIPO_VISITANTE_TEST_RESERVA';

    IF NOT EXISTS (SELECT 1 FROM reservas.EstadoItem WHERE nombre = 'Reservada')
        EXEC reservas.sp_crear_estado_item
            @nombre = 'Reservada'

    IF NOT EXISTS (SELECT 1 FROM reservas.EstadoItem WHERE nombre = 'Utilizada')
        EXEC reservas.sp_crear_estado_item
            @nombre = 'Utilizada'

    IF NOT EXISTS (SELECT 1 FROM reservas.EstadoItem WHERE nombre = 'Cancelada')
        EXEC reservas.sp_crear_estado_item
            @nombre = 'Cancelada'

    EXEC parques.sp_crear_parque_tipo_visitante
        @id_parque, @id_tipo_visitante, 1000;

END;
GO

-- Creación de registros auxiliares (Parques y actividades)
CREATE OR ALTER PROCEDURE reservas.sp_crear_registros_participacion_aux
    @id_parque INT OUTPUT,
    @id_tipo_visitante INT OUTPUT,
    @cupo_maximo INT = 10,
    @hora_inicio TIME = '10:00',
    @hora_fin TIME = '11:00',
    @precio_actividad DECIMAL(18,2) = 500,
    @id_horario INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @id_tipo_parque INT,
        @id_tipo_actividad INT,
        @id_actividad INT;

    ---------------------------------------------------------
    -- Parques, tipos de visitantes, precios
    ---------------------------------------------------------

    EXEC reservas.sp_crear_registros_entrada_aux
        @id_parque OUTPUT, @id_tipo_visitante OUTPUT

    ---------------------------------------------------------
    -- Actividad y Horario
    ---------------------------------------------------------

    EXEC actividades.sp_crear_tipo_actividad
            @nombre = 'TIPO_ACTIVIDAD_TEST_RESERVA';

    SELECT @id_tipo_actividad = id
    FROM actividades.TipoActividad
    WHERE nombre = 'TIPO_ACTIVIDAD_TEST_RESERVA';

    EXEC actividades.sp_crear_actividad
        @nombre = 'ACTIVIDAD_TEST_RESERVA',
        @descripcion = NULL,
        @cupo_maximo = @cupo_maximo,
        @duracion_minutos = 60,
        @precio = @precio_actividad,
        @id_parque = @id_parque,
        @id_tipo_actividad = @id_tipo_actividad;

    SELECT @id_actividad = id
    FROM actividades.Actividad
    WHERE nombre = 'ACTIVIDAD_TEST_RESERVA';

    DECLARE @fecha_actual DATE = CAST(GETDATE() AS DATE);

    EXEC actividades.sp_crear_horario
        @hora_inicio = @hora_inicio,
        @hora_fin = @hora_fin,
        @dia_semana = 1,
        @fecha_vigencia_ini = @fecha_actual,
        @id_actividad = @id_actividad;

    SELECT @id_horario = id
    FROM actividades.Horario
    WHERE id_actividad = @id_actividad;
END;
GO

---------------------------------------------------------
-- 3.1 REGISTRO FALLIDO (SIN ENTRADAS NI PARTICIPACIONES)
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE @entradas reservas.TVP_Entradas;
    DECLARE @participaciones reservas.TVP_Participaciones;

    PRINT 'SIN ENTRADAS NI PARTICIPACIONES, SE ESPERA ERROR';

    EXEC reservas.sp_registrar_reserva
        @entradas = @entradas,
        @participaciones = @participaciones,
        @id_reserva = NULL;

    PRINT 'SI EJECUTO ESTO, EL SP PERMITIO REGISTRAR UNA RESERVA SIN ITEMS';

END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;
GO


---------------------------------------------------------
-- 3.2 REGISTRO EXITOSO (ENTRADAS CON CANTIDAD > 1)
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE
        @id_parque INT,
        @id_tipo_visitante INT;

    DECLARE @entradas reservas.TVP_Entradas;
    DECLARE @participaciones reservas.TVP_Participaciones;

    EXEC reservas.sp_crear_registros_entrada_aux
        @id_parque = @id_parque OUTPUT,
        @id_tipo_visitante = @id_tipo_visitante OUTPUT;

    INSERT INTO @entradas (
        id_parque,
        id_tipo_visitante,
        fecha_acceso,
        cantidad
    )
    VALUES (
        @id_parque,
        @id_tipo_visitante,
        DATEADD(DAY, 1, CAST(GETDATE() AS DATE)),
        3
    );

    PRINT 'ENTRADAS CON CANTIDAD > 1, NO SE ESPERAN ERRORES';

    EXEC reservas.sp_registrar_reserva
        @entradas = @entradas,
        @participaciones = @participaciones,
        @id_reserva = NULL;

    IF (
        SELECT COUNT(*)
        FROM reservas.Entrada e
        INNER JOIN reservas.ItemReserva ir
            ON ir.id = e.id_item_reserva
        WHERE e.id_parque = @id_parque
          AND e.id_tipo_visitante = @id_tipo_visitante
          AND ir.precio = 1000
    ) = 3
        PRINT 'OPERACION EXITOSA';
    ELSE
        PRINT 'SI EJECUTO ESTO, EL SP NO REGISTRO LA CANTIDAD ESPERADA DE ENTRADAS';

END TRY
BEGIN CATCH

    PRINT 'ERROR NO ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 3.3 REGISTRO EXITOSO (MULTIPLES FILAS DE ENTRADAS)
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE
        @id_parque INT,
        @id_tipo_visitante INT,
        @id_reserva INT;

    DECLARE @entradas reservas.TVP_Entradas;
    DECLARE @participaciones reservas.TVP_Participaciones;

    EXEC reservas.sp_crear_registros_entrada_aux
        @id_parque = @id_parque OUTPUT,
        @id_tipo_visitante = @id_tipo_visitante OUTPUT;

    INSERT INTO @entradas (
        id_parque,
        id_tipo_visitante,
        fecha_acceso,
        cantidad
    )
    VALUES
    (
        @id_parque,
        @id_tipo_visitante,
        DATEADD(DAY, 1, CAST(GETDATE() AS DATE)),
        1
    ),
    (
        @id_parque,
        @id_tipo_visitante,
        DATEADD(DAY, 2, CAST(GETDATE() AS DATE)),
        2
    );

    PRINT 'MULTIPLES FILAS DE ENTRADAS, NO SE ESPERAN ERRORES';

    EXEC reservas.sp_registrar_reserva
        @entradas = @entradas,
        @participaciones = @participaciones,
        @id_reserva = @id_reserva OUTPUT;

    IF (
        SELECT COUNT(*)
        FROM reservas.ItemReserva
        WHERE id_reserva = @id_reserva
    ) = 3
        PRINT 'OPERACION EXITOSA';
    ELSE
        PRINT 'SI EJECUTO ESTO, EL SP NO REGISTRO TODAS LAS ENTRADAS ESPERADAS';

END TRY
BEGIN CATCH

    PRINT 'ERROR NO ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 3.4 REGISTRO FALLIDO (PRECIO INEXISTENTE)
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE
        @id_parque INT,
        @id_tipo_visitante INT;

    DECLARE @entradas reservas.TVP_Entradas;
    DECLARE @participaciones reservas.TVP_Participaciones;

    EXEC reservas.sp_crear_registros_entrada_aux
        @id_parque = @id_parque OUTPUT,
        @id_tipo_visitante = @id_tipo_visitante OUTPUT;

    EXEC parques.sp_eliminar_parque_tipo_visitante
        @id_parque, @id_tipo_visitante;

    INSERT INTO @entradas (
        id_parque,
        id_tipo_visitante,
        fecha_acceso,
        cantidad
    )
    VALUES (
        @id_parque,
        @id_tipo_visitante,
        DATEADD(DAY, 1, CAST(GETDATE() AS DATE)),
        1
    );

    PRINT 'PRECIO INEXISTENTE, SE ESPERA ERROR';

    EXEC reservas.sp_registrar_reserva
        @entradas = @entradas,
        @participaciones = @participaciones,
        @id_reserva = NULL;

    PRINT 'SI EJECUTO ESTO, EL SP PERMITIO REGISTRAR UNA ENTRADA SIN PRECIO';

END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 3.5 PARTICIPACIÓN VÁLIDA (CANTIDAD > 1)
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE
        @id_parque INT,
        @id_tipo_visitante INT,
        @id_horario INT,
        @participaciones reservas.TVP_Participaciones,
        @entradas reservas.TVP_Entradas;

    EXEC reservas.sp_crear_registros_participacion_aux
        @id_parque = @id_parque OUTPUT,
        @id_tipo_visitante = @id_tipo_visitante OUTPUT,
        @id_horario = @id_horario OUTPUT;

    INSERT INTO @participaciones
    (
        id_horario,
        fecha_realizacion,
        cantidad
    )
    VALUES
    (
        @id_horario,
        DATEADD(DAY, 1, CAST(GETDATE() AS DATE)),
        3
    );

    PRINT 'PARTICIPACION CON CANTIDAD > 1, SE ESPERA EXITO';

    EXEC reservas.sp_registrar_reserva
        @entradas = @entradas,
        @participaciones = @participaciones,
        @id_reserva = NULL;

    PRINT 'RESERVA REGISTRADA CORRECTAMENTE';

END TRY
BEGIN CATCH

    PRINT 'ERROR NO ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 3.6 PARTICIPACIONES VÁLIDAS (MÚLTIPLES FILAS)
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE
        @id_parque INT,
        @id_tipo_visitante INT,
        @id_horario INT,
        @participaciones reservas.TVP_Participaciones,
        @entradas reservas.TVP_Entradas;

    EXEC reservas.sp_crear_registros_participacion_aux
        @id_parque = @id_parque OUTPUT,
        @id_tipo_visitante = @id_tipo_visitante OUTPUT,
        @id_horario = @id_horario OUTPUT;

    INSERT INTO @participaciones
    (
        id_horario,
        fecha_realizacion,
        cantidad
    )
    VALUES
    (
        @id_horario,
        DATEADD(DAY, 1, CAST(GETDATE() AS DATE)),
        1
    ),
    (
        @id_horario,
        DATEADD(DAY, 2, CAST(GETDATE() AS DATE)),
        2
    );

    PRINT 'MULTIPLES FILAS DE PARTICIPACIONES, SE ESPERA EXITO';

    EXEC reservas.sp_registrar_reserva
        @entradas = @entradas,
        @participaciones = @participaciones,
        @id_reserva = NULL;

    PRINT 'RESERVA REGISTRADA CORRECTAMENTE';

END TRY
BEGIN CATCH

    PRINT 'ERROR NO ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 3.7 PARTICIPACIÓN FALLIDA (HORARIO INEXISTENTE)
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE
        @id_parque INT,
        @id_tipo_visitante INT,
        @id_horario INT,
        @participaciones reservas.TVP_Participaciones,
        @entradas reservas.TVP_Entradas;

    EXEC reservas.sp_crear_registros_participacion_aux
        @id_parque = @id_parque OUTPUT,
        @id_tipo_visitante = @id_tipo_visitante OUTPUT,
        @id_horario = @id_horario OUTPUT;

    INSERT INTO @participaciones
    (
        id_horario,
        fecha_realizacion,
        cantidad
    )
    VALUES
    (
        -1,
        DATEADD(DAY, 1, CAST(GETDATE() AS DATE)),
        1
    );

    PRINT 'HORARIO INEXISTENTE, SE ESPERA ERROR';

    EXEC reservas.sp_registrar_reserva
        @entradas = @entradas,
        @participaciones = @participaciones,
        @id_reserva = NULL;

    PRINT 'SI EJECUTO ESTO, EL SP PERMITIO UN HORARIO INEXISTENTE';

END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 3.8 PARTICIPACIÓN FALLIDA (CUPO INSUFICIENTE)
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE
        @id_parque INT,
        @id_tipo_visitante INT,
        @id_horario INT,
        @participaciones reservas.TVP_Participaciones,
        @entradas reservas.TVP_Entradas;

    EXEC reservas.sp_crear_registros_participacion_aux
        @id_parque = @id_parque OUTPUT,
        @id_tipo_visitante = @id_tipo_visitante OUTPUT,
        @cupo_maximo = 2,
        @id_horario = @id_horario OUTPUT;

    INSERT INTO @participaciones
    (
        id_horario,
        fecha_realizacion,
        cantidad
    )
    VALUES
    (
        @id_horario,
        DATEADD(DAY, 1, CAST(GETDATE() AS DATE)),
        3
    );

    PRINT 'CUPO INSUFICIENTE, SE ESPERA ERROR';

    EXEC reservas.sp_registrar_reserva
        @entradas = @entradas,
        @participaciones = @participaciones,
        @id_reserva = NULL;

    PRINT 'SI EJECUTO ESTO, EL SP PERMITIO SUPERAR EL CUPO';

END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 3.9 ENTRADAS Y PARTICIPACIONES VÁLIDAS
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE
        @id_parque INT,
        @id_tipo_visitante INT,
        @id_horario INT,
        @entradas reservas.TVP_Entradas,
        @participaciones reservas.TVP_Participaciones;

    EXEC reservas.sp_crear_registros_participacion_aux
        @id_parque = @id_parque OUTPUT,
        @id_tipo_visitante = @id_tipo_visitante OUTPUT,
        @id_horario = @id_horario OUTPUT;

    INSERT INTO @entradas
    (
        id_parque,
        id_tipo_visitante,
        fecha_acceso,
        cantidad
    )
    VALUES
    (
        @id_parque,
        @id_tipo_visitante,
        DATEADD(DAY, 1, CAST(GETDATE() AS DATE)),
        2
    );

    INSERT INTO @participaciones
    (
        id_horario,
        fecha_realizacion,
        cantidad
    )
    VALUES
    (
        @id_horario,
        DATEADD(DAY, 1, CAST(GETDATE() AS DATE)),
        2
    );

    PRINT 'ENTRADAS Y PARTICIPACIONES VALIDAS, SE ESPERA EXITO';

    EXEC reservas.sp_registrar_reserva
        @entradas = @entradas,
        @participaciones = @participaciones,
        @id_reserva = NULL;

    PRINT 'RESERVA REGISTRADA CORRECTAMENTE';

END TRY
BEGIN CATCH

    PRINT 'ERROR NO ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 3.10 PARTICIPACIÓN INVÁLIDA + ENTRADA INVÁLIDA
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE
        @id_parque INT,
        @id_tipo_visitante INT,
        @id_horario INT,
        @cantidad_reservas_antes INT,
        @cantidad_items_antes INT,
        @cantidad_reservas_despues INT,
        @cantidad_items_despues INT,
        @entradas reservas.TVP_Entradas,
        @participaciones reservas.TVP_Participaciones;

    EXEC reservas.sp_crear_registros_participacion_aux
        @id_parque = @id_parque OUTPUT,
        @id_tipo_visitante = @id_tipo_visitante OUTPUT,
        @id_horario = @id_horario OUTPUT;

    SELECT @cantidad_reservas_antes = COUNT(*)
    FROM reservas.Reserva;

    SELECT @cantidad_items_antes = COUNT(*)
    FROM reservas.ItemReserva;

    INSERT INTO @entradas
    (
        id_parque,
        id_tipo_visitante,
        fecha_acceso,
        cantidad
    )
    VALUES
    (
        -1, -- ID inexistente
        -1, -- ID inexistente
        DATEADD(DAY, 1, CAST(GETDATE() AS DATE)),
        1
    );

    INSERT INTO @participaciones
    (
        id_horario,
        fecha_realizacion,
        cantidad
    )
    VALUES
    (
        -1, -- ID inexistente
        DATEADD(DAY, 1, CAST(GETDATE() AS DATE)),
        1
    );

    PRINT 'ENTRADA Y PARTICIPACION INVALIDAS, SE ESPERA ERROR Y ROLLBACK TOTAL';

    EXEC reservas.sp_registrar_reserva
        @entradas = @entradas,
        @participaciones = @participaciones,
        @id_reserva = NULL;

    PRINT 'SI EJECUTO ESTO, EL SP PERMITIO REGISTRAR DATOS INVALIDOS';

END TRY
BEGIN CATCH

    /*
     * A considerar: El SP procesa primero las entradas y luego las participaciones. Cuando encuentre el primer error
     * en entradas cortará la ejecución y dará el error correspondiente.
    */
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;
GO


-- ==============================================================================
-- 4. Utilización de entradas
-- ==============================================================================

-- Creación de registros auxiliares (entrada válida)
CREATE OR ALTER PROCEDURE reservas.sp_crear_entrada_utilizable_aux
    @id_item_reserva INT OUTPUT,
    @id_parque INT OUTPUT,
    @fecha_acceso DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @fecha_acceso IS NULL
        SET @fecha_acceso = CAST(GETDATE() AS DATE);

    DECLARE
        @id_tipo_visitante INT,
        @id_reserva INT;

    DECLARE @entradas reservas.TVP_Entradas;
    DECLARE @participaciones reservas.TVP_Participaciones;

    ---------------------------------------------------------
    -- Datos auxiliares
    ---------------------------------------------------------

    EXEC reservas.sp_crear_registros_entrada_aux
        @id_parque = @id_parque OUTPUT,
        @id_tipo_visitante = @id_tipo_visitante OUTPUT;

    ---------------------------------------------------------
    -- Registrar reserva con una entrada válida
    ---------------------------------------------------------

    INSERT INTO @entradas
    (
        id_parque,
        id_tipo_visitante,
        fecha_acceso,
        cantidad
    )
    VALUES
    (
        @id_parque,
        @id_tipo_visitante,
        @fecha_acceso,
        1
    );

    EXEC reservas.sp_registrar_reserva
        @entradas = @entradas,
        @participaciones = @participaciones,
        @id_reserva = @id_reserva OUTPUT;

    ---------------------------------------------------------
    -- Obtener ItemReserva generado
    ---------------------------------------------------------

    SELECT
        @id_item_reserva = id
    FROM reservas.ItemReserva
    WHERE id_reserva = @id_reserva;
END;
GO

---------------------------------------------------------
-- 4.1 UTILIZACION EXITOSA
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE
        @id_item_reserva INT,
        @id_parque INT,
        @id_estado_utilizada TINYINT,
        @id_estado_actual TINYINT;

    EXEC reservas.sp_crear_entrada_utilizable_aux
        @id_item_reserva = @id_item_reserva OUTPUT,
        @id_parque = @id_parque OUTPUT;

    SELECT @id_estado_utilizada = id
    FROM reservas.EstadoItem
    WHERE nombre = 'Utilizada';

    PRINT 'UTILIZACION EXITOSA, SE ESPERA CAMBIO DE ESTADO';

    EXEC reservas.sp_utilizar_entrada
        @id_item_reserva = @id_item_reserva,
        @id_parque_lector = @id_parque;

    SELECT @id_estado_actual = id_estado
    FROM reservas.ItemReserva
    WHERE id = @id_item_reserva;

    IF @id_estado_actual = @id_estado_utilizada
        PRINT 'PRUEBA EXITOSA';
    ELSE
        PRINT 'EL ESTADO NO FUE ACTUALIZADO CORRECTAMENTE';

END TRY
BEGIN CATCH

    PRINT 'ERROR NO ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 4.2 ITEM RESERVA INEXISTENTE
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    PRINT 'ITEM RESERVA INEXISTENTE, SE ESPERA ERROR';

    EXEC reservas.sp_utilizar_entrada
        @id_item_reserva = -1,
        @id_parque_lector = 1;

    PRINT 'SI EJECUTO ESTO, EL SP PERMITIO UTILIZAR UN ITEM INEXISTENTE';

END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 4.3 ITEM QUE NO CORRESPONDE A UNA ENTRADA
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE
        @id_parque INT,
        @id_tipo_visitante INT,
        @id_horario INT,
        @id_reserva INT,
        @id_item_reserva INT;

    DECLARE @participaciones reservas.TVP_Participaciones;
    DECLARE @entradas reservas.TVP_Entradas;

    EXEC reservas.sp_crear_registros_participacion_aux
        @id_parque = @id_parque OUTPUT,
        @id_tipo_visitante = @id_tipo_visitante OUTPUT,
        @id_horario = @id_horario OUTPUT;

    INSERT INTO @participaciones
    VALUES (@id_horario, CAST(GETDATE() AS DATE), 1);

    EXEC reservas.sp_registrar_reserva
        @entradas = @entradas,
        @participaciones = @participaciones,
        @id_reserva = @id_reserva OUTPUT;

    SELECT TOP 1
        @id_item_reserva = id
    FROM reservas.ItemReserva
    WHERE id_reserva = @id_reserva;

    PRINT 'ITEM QUE NO ES UNA ENTRADA, SE ESPERA ERROR';

    EXEC reservas.sp_utilizar_entrada
        @id_item_reserva = @id_item_reserva,
        @id_parque_lector = @id_parque;

    PRINT 'SI EJECUTO ESTO, EL SP PERMITIO UTILIZAR UN ITEM QUE NO ES UNA ENTRADA';

END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 4.4 ENTRADA DE OTRO PARQUE
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE
        @id_item_reserva INT,
        @id_parque INT;

    EXEC reservas.sp_crear_entrada_utilizable_aux
        @id_item_reserva = @id_item_reserva OUTPUT,
        @id_parque = @id_parque OUTPUT;

    PRINT 'ENTRADA DE OTRO PARQUE, SE ESPERA ERROR';

    SET @id_parque = @id_parque + 1;

    EXEC reservas.sp_utilizar_entrada
        @id_item_reserva = @id_item_reserva,
        @id_parque_lector = @id_parque;

    PRINT 'SI EJECUTO ESTO, EL SP PERMITIO UTILIZAR UNA ENTRADA EN OTRO PARQUE';

END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 4.5 ENTRADA YA UTILIZADA
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE
        @id_item_reserva INT,
        @id_parque INT;

    EXEC reservas.sp_crear_entrada_utilizable_aux
        @id_item_reserva = @id_item_reserva OUTPUT,
        @id_parque = @id_parque OUTPUT;

    EXEC reservas.sp_utilizar_entrada
        @id_item_reserva = @id_item_reserva,
        @id_parque_lector = @id_parque;

    PRINT 'ENTRADA YA UTILIZADA, SE ESPERA ERROR';

    EXEC reservas.sp_utilizar_entrada
        @id_item_reserva = @id_item_reserva,
        @id_parque_lector = @id_parque;

    PRINT 'SI EJECUTO ESTO, EL SP PERMITIO UTILIZAR UNA ENTRADA YA UTILIZADA';

END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 4.6 FECHA DE ACCESO DISTINTA A HOY
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE
        @id_item_reserva INT,
        @id_parque INT,
        @fecha_acceso DATE = DATEADD(DAY, 1, CAST(GETDATE() AS DATE));

    EXEC reservas.sp_crear_entrada_utilizable_aux
        @id_item_reserva = @id_item_reserva OUTPUT,
        @id_parque = @id_parque OUTPUT,
        @fecha_acceso = @fecha_acceso;

    PRINT 'FECHA DISTINTA A HOY, SE ESPERA ERROR';

    EXEC reservas.sp_utilizar_entrada
        @id_item_reserva = @id_item_reserva,
        @id_parque_lector = @id_parque;

    PRINT 'SI EJECUTO ESTO, EL SP PERMITIO UTILIZAR UNA ENTRADA FUERA DE FECHA';

END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;

ROLLBACK TRANSACTION;
GO

-- ==============================================================================
-- 5. Utilización de participaciones
-- ==============================================================================

-- Creación de registros auxiliares (participacion válida)
CREATE OR ALTER PROCEDURE reservas.sp_crear_participacion_utilizable_aux
    @id_item_reserva INT OUTPUT,
    @id_horario INT OUTPUT,
    @id_actividad INT OUTPUT,
    @fecha_realizacion DATE = NULL,
    @hora_inicio TIME = '10:00',
    @hora_fin TIME = '11:00'
AS
BEGIN
    SET NOCOUNT ON;

    IF @fecha_realizacion IS NULL
        SET @fecha_realizacion = CAST(GETDATE() AS DATE);

    DECLARE @id_reserva INT;

    DECLARE @entradas reservas.TVP_Entradas;
    DECLARE @participaciones reservas.TVP_Participaciones;

    ---------------------------------------------------------
    -- Datos base
    ---------------------------------------------------------

    EXEC reservas.sp_crear_registros_participacion_aux
        @id_parque = NULL,
        @id_tipo_visitante = NULL,
        @id_horario = @id_horario OUTPUT,
        @hora_inicio = @hora_inicio,
        @hora_fin = @hora_fin;

    ---------------------------------------------------------
    -- Obtener actividad directamente (evita joins en tests)
    ---------------------------------------------------------

    SELECT @id_actividad = id_actividad
    FROM actividades.Horario
    WHERE id = @id_horario;

    ---------------------------------------------------------
    -- Reserva
    ---------------------------------------------------------

    INSERT INTO @participaciones
    (
        id_horario,
        fecha_realizacion,
        cantidad
    )
    VALUES
    (
        @id_horario,
        @fecha_realizacion,
        1
    );

    EXEC reservas.sp_registrar_reserva
        @entradas = @entradas,
        @participaciones = @participaciones,
        @id_reserva = @id_reserva OUTPUT;

    ---------------------------------------------------------
    -- Item
    ---------------------------------------------------------

    SELECT @id_item_reserva = id
    FROM reservas.ItemReserva
    WHERE id_reserva = @id_reserva;
END;
GO

---------------------------------------------------------
-- 5.1 UTILIZACION EXITOSA
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE
        @id_item_reserva INT,
        @id_horario INT,
        @id_actividad INT,
        @estado_utilizada INT,
        @estado_actual INT,
        @hora_inicio TIME = CAST(DATEADD(HOUR, -1, GETDATE()) AS TIME),
        @hora_fin TIME = CAST(DATEADD(HOUR,  1, GETDATE()) AS TIME);

    EXEC reservas.sp_crear_participacion_utilizable_aux
        @id_item_reserva = @id_item_reserva OUTPUT,
        @id_horario = @id_horario OUTPUT,
        @id_actividad = @id_actividad OUTPUT,
        @hora_inicio = @hora_inicio,
        @hora_fin = @hora_fin;

    SELECT @estado_utilizada = id
    FROM reservas.EstadoItem
    WHERE nombre = 'Utilizada';

    PRINT 'SE ESPERA UTILIZACION EXITOSA';

    EXEC reservas.sp_utilizar_participacion
        @id_item_reserva = @id_item_reserva,
        @id_actividad_lectora = @id_actividad;

    SELECT @estado_actual = id_estado
    FROM reservas.ItemReserva
    WHERE id = @id_item_reserva;

    IF @estado_actual = @estado_utilizada
        PRINT 'PRUEBA EXITOSA';
    ELSE
        PRINT 'ERROR: NO SE ACTUALIZO EL ESTADO';

END TRY
BEGIN CATCH
    PRINT 'ERROR NO ESPERADO: ' + ERROR_MESSAGE();

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

END CATCH;
GO

---------------------------------------------------------
-- 5.2 ITEM INEXISTENTE
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    PRINT 'SE ESPERA ERROR POR ITEM INEXISTENTE';

    EXEC reservas.sp_utilizar_participacion
        @id_item_reserva = -1,
        @id_actividad_lectora = 1;

    PRINT 'ERROR: PERMITIO ITEM INEXISTENTE';

END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH;
GO

---------------------------------------------------------
-- 5.3 ITEM NO ES PARTICIPACION
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE
        @id_item_reserva INT,
        @id_parque INT,
        @fecha_actual DATE = CAST(GETDATE() AS DATE);

    EXEC reservas.sp_crear_entrada_utilizable_aux
        @id_parque = @id_parque OUTPUT,
        @id_item_reserva = @id_item_reserva OUTPUT,
        @fecha_acceso = @fecha_actual;

    PRINT 'SE ESPERA ERROR POR TIPO INCORRECTO';

    EXEC reservas.sp_utilizar_participacion
        @id_item_reserva = @id_item_reserva,
        @id_actividad_lectora = 1;

    PRINT 'ERROR: PERMITIO USAR ENTRADA COMO PARTICIPACION';

END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH;

GO

---------------------------------------------------------
-- 5.4 ACTIVIDAD INCORRECTA
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE
        @id_item_reserva INT,
        @id_horario INT,
        @id_actividad INT,
        @id_actividad_lectora INT;

    EXEC reservas.sp_crear_participacion_utilizable_aux
        @id_item_reserva = @id_item_reserva OUTPUT,
        @id_horario = @id_horario OUTPUT,
        @id_actividad = @id_actividad OUTPUT;

    PRINT 'SE ESPERA ERROR POR ACTIVIDAD INVALIDA';

    SET @id_actividad_lectora = @id_actividad + 10;

    EXEC reservas.sp_utilizar_participacion
        @id_item_reserva = @id_item_reserva,
        @id_actividad_lectora = @id_actividad_lectora;

    PRINT 'ERROR: PERMITIO ACTIVIDAD INCORRECTA';

END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH;

GO

---------------------------------------------------------
-- 5.5 PARTICIPACION YA UTILIZADA
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE
        @id_item_reserva INT,
        @id_horario INT,
        @id_actividad INT,
        @hora_inicio TIME = CAST(DATEADD(HOUR, -1, GETDATE()) AS TIME),
        @hora_fin TIME = CAST(DATEADD(HOUR,  1, GETDATE()) AS TIME);

    EXEC reservas.sp_crear_participacion_utilizable_aux
        @id_item_reserva = @id_item_reserva OUTPUT,
        @id_horario = @id_horario OUTPUT,
        @id_actividad = @id_actividad OUTPUT,
        @hora_inicio = @hora_inicio,
        @hora_fin = @hora_fin;

    EXEC reservas.sp_utilizar_participacion
        @id_item_reserva = @id_item_reserva,
        @id_actividad_lectora = @id_actividad;

    PRINT 'PRIMER USO OK';

    EXEC reservas.sp_utilizar_participacion
        @id_item_reserva = @id_item_reserva,
        @id_actividad_lectora = @id_actividad;

    PRINT 'ERROR: PERMITIO DOBLE USO';

END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH;
GO

---------------------------------------------------------
-- 5.6 FECHA DISTINTA A HOY
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE
        @id_item_reserva INT,
        @id_horario INT,
        @id_actividad INT,
        @fecha DATE = DATEADD(DAY, 1, GETDATE());

    EXEC reservas.sp_crear_participacion_utilizable_aux
        @id_item_reserva = @id_item_reserva OUTPUT,
        @id_horario = @id_horario OUTPUT,
        @id_actividad = @id_actividad OUTPUT,
        @fecha_realizacion = @fecha;

    PRINT 'SE ESPERA ERROR POR FECHA INVALIDA';

    EXEC reservas.sp_utilizar_participacion
        @id_item_reserva = @id_item_reserva,
        @id_actividad_lectora = @id_actividad;

    PRINT 'ERROR: PERMITIO USO FUERA DE FECHA';

END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH;
GO

-- ==============================================================================
-- 6. Cancelación de items reserva
-- ==============================================================================

-- Creación de registros auxiliares (participacion válida)
CREATE OR ALTER PROCEDURE reservas.sp_crear_cancelacion_aux
    @id_reserva INT OUTPUT,
    @id_motivo_cliente INT OUTPUT,
    @id_motivo_parque INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    ---------------------------------------------------------
    -- Variables
    ---------------------------------------------------------

    DECLARE
        @id_tipo_visitante INT,
        @id_parque INT;

    DECLARE
        @entradas reservas.TVP_Entradas,
        @participaciones reservas.TVP_Participaciones;

    ---------------------------------------------------------
    -- 1. Crear motivos (catálogo de test)
    ---------------------------------------------------------

    IF NOT EXISTS (SELECT 1 FROM reservas.MotivoCancelacion WHERE nombre = 'CLIENTE')
        EXEC reservas.sp_crear_motivo_cancelacion
            @nombre = 'CLIENTE',
            @descripcion = 'Cancelación por cliente';

    IF NOT EXISTS (SELECT 1 FROM reservas.MotivoCancelacion WHERE nombre = 'PARQUE')
        EXEC reservas.sp_crear_motivo_cancelacion
            @nombre = 'PARQUE',
            @descripcion = 'Cancelación por parque';

    SELECT @id_motivo_cliente = id
    FROM reservas.MotivoCancelacion
    WHERE nombre = 'CLIENTE';

    SELECT @id_motivo_parque = id
    FROM reservas.MotivoCancelacion
    WHERE nombre = 'PARQUE';

    ---------------------------------------------------------
    -- 2. Crear contexto base (parque + tipo visitante)
    ---------------------------------------------------------

    EXEC reservas.sp_crear_registros_entrada_aux
        @id_parque = @id_parque OUTPUT,
        @id_tipo_visitante = @id_tipo_visitante OUTPUT;

    ---------------------------------------------------------
    -- 3. Crear múltiples entradas en la misma reserva
    ---------------------------------------------------------

    INSERT INTO @entradas
    (
        id_parque,
        id_tipo_visitante,
        fecha_acceso,
        cantidad
    )
    VALUES
    (@id_parque, @id_tipo_visitante, CAST(GETDATE() AS DATE), 1),
    (@id_parque, @id_tipo_visitante, CAST(GETDATE() AS DATE), 1),
    (@id_parque, @id_tipo_visitante, CAST(GETDATE() AS DATE), 1);

    ---------------------------------------------------------
    -- 4. Registrar reserva
    ---------------------------------------------------------

    EXEC reservas.sp_registrar_reserva
        @entradas = @entradas,
        @participaciones = @participaciones,
        @id_reserva = @id_reserva OUTPUT;
END;
GO

---------------------------------------------------------
-- 6.1 CANCELACION EXITOSA
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE
        @id_reserva INT,
        @id_motivo_cliente INT,
        @id_motivo_parque INT;

    DECLARE @items reservas.TVP_ItemsReserva;

    EXEC reservas.sp_crear_cancelacion_aux
        @id_reserva = @id_reserva OUTPUT,
        @id_motivo_cliente = @id_motivo_cliente OUTPUT,
        @id_motivo_parque = @id_motivo_parque OUTPUT;

    INSERT INTO @items
    SELECT id
    FROM reservas.ItemReserva
    WHERE id_reserva = @id_reserva;

    PRINT 'SE ESPERA CANCELACION EXITOSA';

    EXEC reservas.sp_cancelar_items_reserva
        @items = @items,
        @id_motivo = @id_motivo_cliente,
        @id_cancelacion = NULL;

    PRINT 'PRUEBA EXITOSA';

END TRY
BEGIN CATCH
    PRINT 'ERROR NO ESPERADO: ' + ERROR_MESSAGE();

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH;
GO

---------------------------------------------------------
-- 6.2 CANCELACIÓN FALLIDA (NO SE LE INDICARON ÍTEMS)
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE @items reservas.TVP_ItemsReserva;
    DECLARE @id_motivo INT = 1;

    PRINT 'SE ESPERA ERROR POR FALTA DE ITEMS';

    EXEC reservas.sp_cancelar_items_reserva
        @items = @items,
        @id_motivo = @id_motivo,
        @id_cancelacion = NULL;

    PRINT 'ERROR: PERMITIO CANCELACIÓN CON FALTA DE ITEMS';

END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

END CATCH;
GO

---------------------------------------------------------
-- 6.3 ITEM INEXISTENTE
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE @items reservas.TVP_ItemsReserva;
    DECLARE @id_motivo INT = 1;

    INSERT INTO @items VALUES (-1);

    PRINT 'SE ESPERA ERROR POR ITEM INEXISTENTE';

    EXEC reservas.sp_cancelar_items_reserva
        @items = @items,
        @id_motivo = @id_motivo,
        @id_cancelacion = NULL;

    PRINT 'ERROR: PERMITIO ITEM INEXISTENTE';

END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH;
GO

---------------------------------------------------------
-- 6.4 ITEMS DE DISTINTA RESERVA
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE
        @id_reserva_1 INT,
        @id_reserva_2 INT,
        @id_motivo INT;

    DECLARE @items reservas.TVP_ItemsReserva;

    EXEC reservas.sp_crear_cancelacion_aux
        @id_reserva = @id_reserva_1 OUTPUT,
        @id_motivo_cliente = @id_motivo OUTPUT,
        @id_motivo_parque = @id_motivo OUTPUT;

    -- simulamos segundo item de otra reserva
    EXEC reservas.sp_crear_cancelacion_aux
        @id_reserva = @id_reserva_2 OUTPUT,
        @id_motivo_cliente = @id_motivo OUTPUT,
        @id_motivo_parque = @id_motivo OUTPUT;

    INSERT INTO @items
    SELECT id FROM reservas.ItemReserva WHERE id_reserva = @id_reserva_1;

    INSERT INTO @items
    SELECT id FROM reservas.ItemReserva WHERE id_reserva = @id_reserva_2;

    PRINT 'SE ESPERA ERROR POR DISTINTA RESERVA';

    EXEC reservas.sp_cancelar_items_reserva
        @items = @items,
        @id_motivo = @id_motivo,
        @id_cancelacion = NULL;

    PRINT 'ERROR: PERMITIO ITEMS DE DISTINTA RESERVA';

END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH;
GO

---------------------------------------------------------
-- 6.5 ESTADO INVALIDO
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE
        @id_reserva INT,
        @id_motivo INT;

    DECLARE @items reservas.TVP_ItemsReserva;

    EXEC reservas.sp_crear_cancelacion_aux
        @id_reserva = @id_reserva OUTPUT,
        @id_motivo_cliente = @id_motivo OUTPUT,
        @id_motivo_parque = @id_motivo OUTPUT;

    -- cancelación previa (para generar estado inválido)
    INSERT INTO @items
    SELECT id FROM reservas.ItemReserva WHERE id_reserva = @id_reserva;

    EXEC reservas.sp_cancelar_items_reserva
        @items = @items,
        @id_motivo = @id_motivo,
        @id_cancelacion = NULL;

    PRINT 'PRIMERA CANCELACION OK';

    PRINT 'SE ESPERA ERROR POR ESTADO INVALIDO';

    EXEC reservas.sp_cancelar_items_reserva
        @items = @items,
        @id_motivo = @id_motivo,
        @id_cancelacion = NULL;

    PRINT 'ERROR: PERMITIO CANCELAR DOS VECES';

END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH;
GO

-- ==============================================================================
-- 7. Reembolso de una cancelación
-- ==============================================================================

-- Creación de registros auxiliares (cancelación)
CREATE OR ALTER PROCEDURE reservas.sp_crear_reembolso_aux
    @id_cancelacion INT OUTPUT
AS
BEGIN

    DECLARE
        @id_reserva INT,
        @id_motivo_cliente INT,
        @id_motivo_parque INT;

    DECLARE @items reservas.TVP_ItemsReserva;

    EXEC reservas.sp_crear_cancelacion_aux
        @id_reserva = @id_reserva OUTPUT,
        @id_motivo_cliente = @id_motivo_cliente OUTPUT,
        @id_motivo_parque = @id_motivo_parque OUTPUT;

    INSERT INTO @items
    SELECT id
    FROM reservas.ItemReserva
    WHERE id_reserva = @id_reserva;

    EXEC reservas.sp_cancelar_items_reserva
        @items = @items,
        @id_motivo = @id_motivo_cliente,
        @id_cancelacion = @id_cancelacion OUTPUT
END;
GO

---------------------------------------------------------
-- 7.1 REEMBOLSO EXITOSO
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE @id_cancelacion INT;

    EXEC reservas.sp_crear_reembolso_aux
        @id_cancelacion = @id_cancelacion OUTPUT;

    PRINT 'SE ESPERA REEMBOLSO EXITOSO';

    EXEC reservas.sp_registrar_reembolso
        @id_cancelacion = @id_cancelacion,
        @cvu_cuenta_destino = '1234567890123456789012';

    IF EXISTS (
        SELECT 1
        FROM reservas.Reembolso
        WHERE id_cancelacion = @id_cancelacion
    )
        PRINT 'PRUEBA EXITOSA';
    ELSE
        PRINT 'ERROR: NO SE REGISTRO REEMBOLSO';

END TRY
BEGIN CATCH
    PRINT 'ERROR NO ESPERADO: ' + ERROR_MESSAGE();
END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 7.2 CANCELACION INEXISTENTE
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    PRINT 'SE ESPERA ERROR POR CANCELACION INEXISTENTE';

    EXEC reservas.sp_registrar_reembolso
        @id_cancelacion = -1,
        @cvu_cuenta_destino = '1234567890123456789012';

    PRINT 'ERROR: PERMITIO CANCELACION INEXISTENTE';

END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();
END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 7.3 REEMBOLSO DUPLICADO
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE @id_cancelacion INT;

    EXEC reservas.sp_crear_reembolso_aux
        @id_cancelacion = @id_cancelacion OUTPUT;

    EXEC reservas.sp_registrar_reembolso
        @id_cancelacion = @id_cancelacion,
        @cvu_cuenta_destino = '1234567890123456789012';

    PRINT 'PRIMER REEMBOLSO OK';

    PRINT 'SE ESPERA ERROR POR DUPLICACION';

    EXEC reservas.sp_registrar_reembolso
        @id_cancelacion = @id_cancelacion,
        @cvu_cuenta_destino = '1234567890123456789012';

    PRINT 'ERROR: PERMITIO REEMBOLSO DUPLICADO';

END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();
END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 7.4 CVU INVALIDO
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE @id_cancelacion INT;

    EXEC reservas.sp_crear_reembolso_aux
        @id_cancelacion = @id_cancelacion OUTPUT;

    PRINT 'SE ESPERA ERROR POR CVU INVALIDO';

    EXEC reservas.sp_registrar_reembolso
        @id_cancelacion = @id_cancelacion,
        @cvu_cuenta_destino = 'ABC123';

    PRINT 'ERROR: PERMITIO CVU INVALIDO';

END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();
END CATCH;

ROLLBACK TRANSACTION;
GO

---------------------------------------------------------
-- 7.5 CVU INVALIDO POR LONGITUD
---------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE @id_cancelacion INT;

    EXEC reservas.sp_crear_reembolso_aux
        @id_cancelacion = @id_cancelacion OUTPUT;

    PRINT 'SE ESPERA ERROR POR LONGITUD CVU';

    EXEC reservas.sp_registrar_reembolso
        @id_cancelacion = @id_cancelacion,
        @cvu_cuenta_destino = '12345678901234567890123';

    PRINT 'ERROR: PERMITIO CVU INVALIDO';

END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();
END CATCH;

ROLLBACK TRANSACTION;
GO