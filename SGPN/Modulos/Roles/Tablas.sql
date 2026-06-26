/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: Creación de SP para crear el schema y la tabla donde se almacenaran los diferentes roles
*/

USE LinuxPreachers;
GO

-- Validamos si el esquema 'roles' NO existe
IF SCHEMA_ID('roles') IS NULL
BEGIN
    -- Ejecutamos la creación como una cadena de texto aislada
    EXEC('CREATE SCHEMA roles');
    PRINT 'El schema "roles" fue creado exitosamente.';
END
ELSE
BEGIN
    PRINT 'El schema "roles" ya existía, se omitió la creación.';
END
GO

CREATE OR ALTER PROCEDURE roles.sp_crear_tabla_rol
AS
BEGIN 
    BEGIN TRY
        IF OBJECT_ID('roles.Rol', 'U') IS NOT NULL
            THROW 60000,'La tabla que desea crear ya existe',1;

        CREATE TABLE roles.Rol(
            id INT IDENTITY(1,1),
            nombre VARCHAR(50),
            descripcion VARCHAR (200)
        )
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH 
END 
GO

CREATE OR ALTER PROCEDURE roles.sp_eliminar_tabla_rol
AS
BEGIN 
    DROP TABLE  IF EXISTS roles.Rol; 
END
GO

EXEC roles.sp_crear_tabla_rol;

--EXEC roles.sp_eliminar_tabla_rol