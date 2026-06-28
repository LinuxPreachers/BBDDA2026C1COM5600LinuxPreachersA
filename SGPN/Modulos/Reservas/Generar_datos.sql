/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: Generación e inserción de datos para el módulo de reservas.
*/

USE LinuxPreachers;
GO

-----------------------------------
-- 1. Estados de items reserva
-----------------------------------

BEGIN TRY

	BEGIN TRANSACTION;

	EXEC reservas.sp_crear_estado_item @nombre = 'Reservada', @descripcion = 'Ítem comprado y pendiente de uso.';
	EXEC reservas.sp_crear_estado_item @nombre = 'Utilizada', @descripcion = 'Ítem ya utilizado.';
	EXEC reservas.sp_crear_estado_item @nombre = 'Cancelada', @descripcion = 'Ítem cancelado.';

	COMMIT TRANSACTION;

	SELECT * FROM reservas.EstadoItem;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
END CATCH;
GO

-----------------------------------
-- 2. Motivos de cancelación
-----------------------------------

BEGIN TRY
	
	BEGIN TRANSACTION;

	EXEC reservas.sp_crear_motivo_cancelacion @nombre = 'Cliente', @descripcion = 'Cancelado por cliente';
	EXEC reservas.sp_crear_motivo_cancelacion @nombre = 'Parque', @descripcion = 'Cancelado por parque';

	COMMIT TRANSACTION;
	
	SELECT * FROM reservas.MotivoCancelacion;

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
END CATCH;
GO

-----------------------------------
-- 3. Reservas (histórico)
-----------------------------------

BEGIN TRY

	BEGIN TRANSACTION;

	DECLARE
        @id_parque_valle_cristal INT,
        @id_parque_arroyo_esmeralda INT;

    SELECT @id_parque_valle_cristal = id
    FROM parques.Parque
    WHERE nombre = 'Parque Nacional Valle del Cristal';

    SELECT @id_parque_arroyo_esmeralda = id
    FROM parques.Parque
    WHERE nombre = 'Reserva Natural Arroyo Esmeralda';

	EXEC reservas.sp_generar_reservas_historicas
		@id_parque = @id_parque_valle_cristal,
		@fecha_inicio = '2025-12-01',
		@fecha_fin = '2026-06-01';

	EXEC reservas.sp_generar_reservas_historicas
		@id_parque = @id_parque_arroyo_esmeralda,
		@fecha_inicio = '2025-12-01',
		@fecha_fin = '2026-06-01';

	COMMIT TRANSACTION;

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
END CATCH;
GO