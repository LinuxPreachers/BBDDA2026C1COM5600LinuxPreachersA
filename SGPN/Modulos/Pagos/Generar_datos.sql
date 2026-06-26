/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: Generación e inserción de datos para el módulo de pagos.
*/

USE LinuxPreachers;
GO

-----------------------------------
-- 1. Formas de pago
-----------------------------------

BEGIN TRANSACTION;

BEGIN TRY

	EXEC pagos.sp_crear_forma_pago @nombre = 'Tarjeta de Credito';

	COMMIT TRANSACTION;

	SELECT * FROM pagos.FormaPago;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
END CATCH;
GO

-----------------------------------
-- 2. Puntos de venta
-----------------------------------

BEGIN TRANSACTION;

BEGIN TRY

	EXEC pagos.sp_crear_punto_venta @nombre = 'Boleteria Zona Norte';

	COMMIT TRANSACTION;
	
	SELECT * FROM pagos.PuntoVenta;

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
END CATCH;
GO