/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: Reinicio de base de datos.
*/

USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'LinuxPreachers')
BEGIN
	ALTER DATABASE LinuxPreachers 
	SET SINGLE_USER 
	WITH ROLLBACK IMMEDIATE;
	
	DROP DATABASE LinuxPreachers;
END;
GO

CREATE DATABASE LinuxPreachers;
GO

USE LinuxPreachers;
GO

CREATE SCHEMA parques;
GO
CREATE SCHEMA actividades;
GO
CREATE SCHEMA empleados;
GO
CREATE SCHEMA reservas;
GO
CREATE SCHEMA pagos;
GO
CREATE SCHEMA concesiones;
GO

:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Parques\Tablas.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Actividades\Tablas.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Empleados\Tablas.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Reservas\Tablas.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Pagos\Tablas.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Concesiones\Tablas.sql"

EXEC parques.sp_crear_modulo_parques;
EXEC actividades.sp_crear_modulo_actividades;
EXEC empleados.sp_crear_modulo_empleados;
EXEC reservas.sp_crear_modulo_reservas;
EXEC pagos.sp_crear_modulo_pagos;
EXEC concesiones.sp_crear_modulo_concesiones;

SELECT * 
FROM INFORMATION_SCHEMA.TABLES
ORDER BY TABLE_SCHEMA
GO