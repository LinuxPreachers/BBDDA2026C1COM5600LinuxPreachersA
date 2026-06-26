/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Script: Creación de logins y usuarios para cada rol
 */

USE master
GO

CREATE LOGIN [login_admin_pagos]
WITH PASSWORD = N'AdminPagos123&', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
GO

CREATE LOGIN [login_admin_actividades]
WITH PASSWORD = N'AdminActividades123&', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
GO

CREATE LOGIN [login_admin_parques]
WITH PASSWORD = N'AdminParques123&', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
GO

CREATE LOGIN [login_admin_empleados]
WITH PASSWORD = N'AdminEmpleados123&', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
GO

CREATE LOGIN [login_rrhh]
WITH PASSWORD = N'Rrhh123&', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
GO

CREATE LOGIN [login_admin_concesiones]
WITH PASSWORD = N'AdminConcesiones123&', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
GO

CREATE LOGIN [login_admin_reservas]
WITH PASSWORD = N'AdminReservas123&', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
GO

CREATE LOGIN [login_user_web]
WITH PASSWORD = N'UserWeb123&', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
GO

CREATE LOGIN [login_auditor_concesion]
WITH PASSWORD = N'AuditorConcesion123&', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
GO

CREATE LOGIN [login_auditor_finanzas]
WITH PASSWORD = N'AuditorFinanzas123&', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
GO

CREATE LOGIN [login_director_gral]
WITH PASSWORD = N'DirectorGral123&', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
GO

CREATE LOGIN [login_importador_datos]
WITH PASSWORD = N'ImportadorDatos123&', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
GO


USE [ LinuxPreachers]
GO

CREATE USER [user_admin_pagos] FOR LOGIN [login_admin_pagos]
GO
ALTER ROLE [admin_pagos] ADD MEMBER [user_admin_pagos]
GO

CREATE USER [user_admin_actividades] FOR LOGIN [login_admin_actividades]
GO
ALTER ROLE [admin_actividades] ADD MEMBER [user_admin_actividades]
GO

CREATE USER [user_admin_parques] FOR LOGIN [login_admin_parques]
GO
ALTER ROLE [admin_parques] ADD MEMBER [user_admin_parques]
GO

CREATE USER [user_admin_empleados] FOR LOGIN [login_admin_empleados]
GO
ALTER ROLE [admin_empleados] ADD MEMBER [user_admin_empleados]
GO

CREATE USER [user_rrhh] FOR LOGIN [login_rrhh]
GO
ALTER ROLE [rrhh] ADD MEMBER [user_rrhh]
GO

CREATE USER [user_admin_concesiones] FOR LOGIN [login_admin_concesiones]
GO
ALTER ROLE [admin_concesiones] ADD MEMBER [user_admin_concesiones]
GO

CREATE USER [user_admin_reservas] FOR LOGIN [login_admin_reservas]
GO
ALTER ROLE [admin_reservas] ADD MEMBER [user_admin_reservas]
GO

CREATE USER [user_web_login] FOR LOGIN [login_user_web]
GO
ALTER ROLE [user_web] ADD MEMBER [user_web_login]
GO

CREATE USER [user_auditor_concesion] FOR LOGIN [login_auditor_concesion]
GO
ALTER ROLE [auditor_concesion] ADD MEMBER [user_auditor_concesion]
GO

CREATE USER [user_auditor_finanzas] FOR LOGIN [login_auditor_finanzas]
GO
ALTER ROLE [auditor_finanzas] ADD MEMBER [user_auditor_finanzas]
GO

CREATE USER [user_director_gral] FOR LOGIN [login_director_gral]
GO
ALTER ROLE [director_gral] ADD MEMBER [user_director_gral]
GO

CREATE USER [user_importador_datos] FOR LOGIN [login_importador_datos]
GO
ALTER ROLE [importador_datos] ADD MEMBER [user_importador_datos]
GO
