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

BEGIN TRANSACTION;

BEGIN TRY

	EXEC reservas.sp_crear_estado_item @nombre = 'Reservada', @descripcion = 'Ítem comprado y pendiente de uso.';
	EXEC reservas.sp_crear_estado_item @nombre = 'Utilizada', @descripcion = 'Ítem comprado cancelada.';
	EXEC reservas.sp_crear_estado_item @nombre = 'Cancelada', @descripcion = 'Ítem comprado cancelada.';

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

BEGIN TRANSACTION;

BEGIN TRY

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