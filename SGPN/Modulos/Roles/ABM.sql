/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: ABM para los roles (Alta, Baja y Modificacion)
*/


-- CREACION DE ROL

CREATE OR ALTER PROCEDURE roles.sp_crear_rol
	@nombre VARCHAR(50),
	@descripcion VARCHAR(200) NULL
AS
BEGIN 
	DECLARE @msj_error VARCHAR (200)='';
	BEGIN TRY
		IF (@nombre IS NULL OR RTRIM(LTRIM(@nombre))='')
			SET @msj_error+= '- El nombre no es valido';

		IF EXISTS (SELECT 1 FROM roles.Rol WHERE nombre=@nombre)
			SET @msj_error+= '- El nombre del rol ingresado ya existe';

		IF(LEN(@msj_error)>0)
			THROW 60010,@msj_error,1;

		INSERT INTO roles.Rol(nombre,descripcion) VALUES (@nombre,@descripcion)
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END

-- MODIFICACION DE ROL

CREATE OR ALTER PROCEDURE roles.sp_modificar_rol
	@id INT,
	@nombre VARCHAR(50),
	@descripcion VARCHAR(200) NULL
AS
BEGIN 
	DECLARE @msj_error VARCHAR (200)='';
	BEGIN TRY
		IF (@nombre IS NULL OR RTRIM(LTRIM(@nombre))='')
			SET @msj_error+= '- El nombre no es valido';

		IF NOT EXISTS (SELECT 1 FROM roles.Rol WHERE id=@id)
			SET @msj_error+= '- El rol ingresado no existe';

		IF(LEN(@msj_error)>0)
			THROW 60011,@msj_error,1;

		UPDATE roles.Rol SET nombre=@nombre,descripcion=@descripcion WHERE id=@id
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END


CREATE OR ALTER PROCEDURE roles.sp_eliminar_rol
	@id INT
AS 
BEGIN 
	BEGIN TRY
		IF NOT EXISTS(SELECT 1 FROM roles.Rol WHERE id=@id)
			THROW 60012,'- El id no existe',1;

			DELETE FROM roles.Rol WHERE id=@id;
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END