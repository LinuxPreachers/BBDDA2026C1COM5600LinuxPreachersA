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

DROP DATABASE LinuxPreachers;
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

-- Pendiente: Ejecutar scripts de creación