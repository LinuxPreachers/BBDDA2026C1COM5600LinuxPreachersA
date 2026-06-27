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
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Parques\Tablas.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Actividades\Tablas.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Empleados\Tablas.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Reservas\Tablas.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Pagos\Tablas.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Concesiones\Tablas.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Roles\Tablas.sql"

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
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Parques\ABM.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Actividades\ABM.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Empleados\ABM.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Reservas\ABM.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Pagos\ABM.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Concesiones\ABM.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Roles\ABM.sql"

-- Generacion de datos
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Parques\Generar_datos.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Actividades\Generar_datos.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Empleados\Generar_datos.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Reservas\Generar_datos.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Pagos\Generar_datos.sql"

-- Importaciones
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Parques\Importacion.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Empleados\Importacion.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Concesiones\Importacion.sql"

-- Roles y logins
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Roles\CreacionRoles.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Modulos\Roles\CrearLogins.sql"

-- Reportes
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\APIs.sql"
:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Reportes.sql"

PRINT 'Importando datos de modulos...';

EXEC parques.sp_importar_parques 
	@ruta = '\\DESKTOP-KOIKGVK\Users\Carpeta publica\ArchivosImportacion\Áreas protegidas de Argentina - Sistema de Información de Biodiversidad.xlsx'
GO

EXEC empleados.sp_importar_guias 
    @ruta = '\\DESKTOP-KOIKGVK\Users\Carpeta publica\ArchivosImportacion\registro-de-guias-de-turismo.csv'
GO

EXEC concesiones.sp_importar_directorio_empresas
    @ruta = '\\DESKTOP-KOIKGVK\Users\Carpeta publica\ArchivosImportacion\registro-organizaciones-distinguidas-sact.csv',
    @id_parque = 1;
GO

--PRINT 'Creando configuraciones de seguridad...';

--:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\CreacionPass.sql"
--:r "D:\Facultad\TP-BDA\BBDDA2026C1COM5600LinuxPreachersA\SGPN\Cifrado.sql"

PRINT 'Reinicio completo.';

SELECT * 
FROM INFORMATION_SCHEMA.TABLES
ORDER BY TABLE_SCHEMA
GO