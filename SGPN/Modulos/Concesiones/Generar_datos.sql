/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: 
*/

USE LinuxPreachers;
GO

-----------------------------------
-- 1. Actividades Empresariales
-----------------------------------

BEGIN TRANSACTION;

BEGIN TRY

	EXEC concesiones.sp_crear_actividad_empresarial
        @nombre = 'Gastronomia',
		@descripcion = 'Restaurantes, kioscos';

	EXEC concesiones.sp_crear_actividad_empresarial
        @nombre = 'Limpieza',
		@descripcion = 'Sanitizacion de oficinas, limpieza del parque';

	COMMIT TRANSACTION;
	
	SELECT * FROM concesiones.ActividadEmpresarial;

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
END CATCH;
GO
-----------------------------------
-- 2. Empresas
-----------------------------------

BEGIN TRANSACTION;

BEGIN TRY

	DECLARE @id_act INT;

	SELECT TOP 1 @id_act = id FROM concesiones.ActividadEmpresarial ORDER BY id ASC;


	EXEC concesiones.sp_crear_empresa_concesionaria

    @nombre = 'Panchos Pepito',
    @descripcion = 'Los mejores panchos de la Zona',
    @cuit = 20897897899,
    @razon_social ='Pepito SRL',
    @id_actividad_empresarial = @id_act;


	SELECT TOP 1 @id_act = id FROM concesiones.ActividadEmpresarial ORDER BY id DESC;

	EXEC concesiones.sp_crear_empresa_concesionaria

    @nombre = 'Limpieza Juan',
    @descripcion = 'Excelencia',
    @cuit = 20897897888,
    @razon_social ='JUAN SA',
    @id_actividad_empresarial = @id_act;


	COMMIT TRANSACTION;

	SELECT * FROM concesiones.EmpresaConcesionaria;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
END CATCH;
GO

-----------------------------------
-- 3. Concesiones Y Canon
-----------------------------------

BEGIN TRANSACTION;

BEGIN TRY

	DECLARE @id_emp INT;
	DECLARE @id_par INT;

	SELECT TOP 1 @id_emp = id FROM concesiones.EmpresaConcesionaria ORDER BY id ASC;
	SELECT TOP 1 @id_par = id FROM parques.Parque ORDER BY id ASC;

	EXEC concesiones.sp_generar_concesion_y_canon
	@descripcion = 'Registro inicial',
    @fecha_inicio ='2026-01-01',
    @fecha_fin = '2026-12-01',
    @id_empresa_concesionaria = @id_emp,
    @id_parque = @id_par,
    @monto_canon = 1000000,
    @cantidad_dias_vencimiento = 5;

	SELECT TOP 1 @id_emp = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;
	SELECT TOP 1 @id_par = id FROM parques.Parque ORDER BY id DESC;

	EXEC concesiones.sp_generar_concesion_y_canon
	@descripcion = 'Registro inicial',
    @fecha_inicio ='2027-01-01',
    @fecha_fin = '2027-12-01',
    @id_empresa_concesionaria = @id_emp,
    @id_parque = @id_par,
    @monto_canon = 2000000,
    @cantidad_dias_vencimiento = 5;




	COMMIT TRANSACTION;

	SELECT * FROM concesiones.Concesion;
	SELECT * FROM concesiones.Canon;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
END CATCH;
GO
