/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: Reinicio de base de datos.
*/

/* 
 * IMPORTANTE:
 *
 * Este script elimina y crea nuevamente toda la DB. Para ello llama a los scripts de creación de tablas, ABM
 * generación de datos, importaciones y demás de forma automática. Para ejecutarlo correctamente se debe
 * configurar el modo SQLCMD en la pestaña "Consulta" de Management Studio.
*/

USE master;
GO

PRINT 'Reinciando base de datos...';

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

PRINT 'Creando schemas...';
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
CREATE SCHEMA seguridad;
GO
CREATE SCHEMA roles;
GO
CREATE SCHEMA api;
GO

SET NOCOUNT ON;

PRINT 'Creando modulos...';

-- Creacion de modulos
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Parques\0101-Tablas.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Actividades\0301-Tablas.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Empleados\0201-Tablas.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Reservas\0401-Tablas.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Pagos\0501-Tablas.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Concesiones\0601-Tablas.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Roles\0701-Tablas.sql"

EXEC parques.sp_crear_modulo_parques;
EXEC actividades.sp_crear_modulo_actividades;
EXEC empleados.sp_crear_modulo_empleados;
EXEC reservas.sp_crear_modulo_reservas;
EXEC pagos.sp_crear_modulo_pagos;
EXEC concesiones.sp_crear_modulo_concesiones;
EXEC roles.sp_crear_tabla_rol;
GO

PRINT 'Generando datos de modulos...';

-- Creacion de scripts ABM para los modulos
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Parques\0102-ABM.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Actividades\0302-ABM.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Empleados\0202-ABM.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Pagos\0502-ABM.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Reservas\0402-ABM.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Concesiones\0602-ABM.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Roles\0702-ABM.sql"

-- Generacion de datos
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Parques\0104-Generar_datos.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Actividades\0304-Generar_datos.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Empleados\0204-Generar_datos.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Pagos\0504-Generar_datos.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Reservas\0404-Generar_datos.sql"

-- Importaciones
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Parques\0105-Importacion.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Empleados\0205-Importacion.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Concesiones\0605-Importacion.sql"

-- Roles y logins
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Roles\0704-1-CreacionRoles.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Roles\0704-2-CrearLogins.sql"

-- Reportes
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\0800-APIs.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\0804-Reportes.sql"

PRINT 'Importando datos de modulos...';

--EXEC empleados.sp_importar_guias 
--    @ruta = '\\DESKTOP-KOIKGVK\Users\Carpeta publica\ArchivosImportacion\registro-de-guias-de-turismo.csv'
--GO

--EXEC concesiones.sp_importar_directorio_empresas
--    @ruta = '\\DESKTOP-KOIKGVK\Users\Carpeta publica\ArchivosImportacion\registro-organizaciones-distinguidas-sact.csv',
--    @id_parque = 1;
--GO

--PRINT 'Creando configuraciones de seguridad...';

--:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\0901-CreacionPass.sql"
--:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\0902-Cifrado.sql"

PRINT 'Reinicio completo.';