/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: Creación de Roles definidos en la documentacion
*/

USE LinuxPreachers;
GO

-- Schema
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'roles')
BEGIN 
    EXEC('CREATE SCHEMA roles'); 
END;
GO

-- Este SP Asume que no existe ningún rol
CREATE OR ALTER PROCEDURE roles.sp_crear_roles AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        CREATE ROLE admin_pagos;
        CREATE ROLE admin_actividades;
        CREATE ROLE admin_parques;
        CREATE ROLE admin_empleados;
        CREATE ROLE rrhh;
        CREATE ROLE admin_concesiones;
        CREATE ROLE admin_reservas;
        CREATE ROLE user_web;
        CREATE ROLE auditor_concesion;
        CREATE ROLE auditor_finanzas;
        CREATE ROLE director_gral;
        CREATE ROLE importador_datos;
    
        EXEC roles.sp_crear_rol 
            @nombre='admin_pagos', 
            @descripcion='Encargado del ABM referido a Pagos';

        EXEC roles.sp_crear_rol 
            @nombre='admin_actividades', 
            @descripcion=' Encargado del ABM referido a actividades';

        EXEC roles.sp_crear_rol 
            @nombre='admin_parques', 
            @descripcion='Encargado del ABM referido a parques';

        EXEC roles.sp_crear_rol 
            @nombre='admin_empleados',
            @descripcion='Encargado del ABM referido a empleados';

        EXEC roles.sp_crear_rol 
            @nombre='admin_concesiones',
            @descripcion='Encargado del ABM referido a concesiones';

        EXEC roles.sp_crear_rol 
            @nombre='admin_reservas',
            @descripcion='Encargado del ABM referido a reservas (entradas,participaciones y pagos)';

        EXEC roles.sp_crear_rol 
            @nombre='rrhh',
            @descripcion='Encargado de consultas referido a empleados';

        EXEC roles.sp_crear_rol 
            @nombre='user_web',
            @descripcion='Utilizado para ABM de la tabla X'; -- X siendo la tabla que elegimos para la entrega 9

        EXEC roles.sp_crear_rol 
            @nombre='auditor_concesion',
            @descripcion='Utilizado para consultar las actividades del modulo concesiones';

        EXEC roles.sp_crear_rol 
            @nombre='auditor_finanzas', 
            @descripcion='Utilizado para consultar las actividades referida a pagos y reservas';

        EXEC roles.sp_crear_rol 
            @nombre='director_gral',
            @descripcion='Utilizado para consultar todos los modulos de la base de datos';

        EXEC roles.sp_crear_rol 
            @nombre='importador_datos',
            @descripcion='Utilizado para ejecutar sps de importacion';

    END TRY
    BEGIN CATCH
	    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
    END CATCH;

    SELECT * FROM roles.Rol;
END;
GO

-- SP Wrapper con verificaciones
CREATE OR ALTER PROCEDURE roles.sp_crear_modulo_roles AS
BEGIN

    DECLARE @roles_existentes TABLE (
        nombre VARCHAR(128)
    );

    INSERT INTO @roles_existentes (nombre)
    SELECT name
    FROM sys.database_principals
    WHERE type = 'R'
        AND name IN (
            'admin_pagos',
            'admin_actividades',
            'admin_parques',
            'admin_empleados',
            'rrhh',
            'admin_concesiones',
            'admin_reservas',
            'user_web',
            'auditor_concesion',
            'auditor_finanzas',
            'director_gral',
            'importador_datos'
    );

    IF EXISTS (SELECT 1 FROM @roles_existentes)
    BEGIN;
        THROW 60000, 'No se puede crear el modulo: ya existe al menos un rol.', 1;
    END;

    EXEC roles.sp_crear_modulo_roles;
END;
GO

EXEC roles.sp_crear_modulo_roles;



-------------------------------------------------- PARA ROL DE Administrador de Pagos--------------------------------------------------
-- Permisos sobre esquema pagos (puede ver, insertar, eliminar y modificar registros de la tabla mediante procedimientos almacenados pero sin alterar la tabla)

-- Le asignamos permiso para ejecutar los sps del schema pagos
GRANT EXECUTE ON SCHEMA::pagos TO admin_pagos
-- GRANT EXECUTE ON OBJECT::reservas.vw_leer_reservas TO admin_pagos --- FALTA CREARLO
-- Le denegamos el permiso a ejecutar los sps de creacion y eliminacion del modulo
DENY EXECUTE ON OBJECT::pagos.sp_crear_tablas_modulo_pagos TO admin_pagos
DENY EXECUTE ON OBJECT::pagos.sp_crear_modulo_pagos TO admin_pagos
DENY EXECUTE ON OBJECT::pagos.sp_eliminar_modulo_pagos TO admin_pagos
-----------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------- PARA ROL DE Administrador de Actividades--------------------------------------------------
-- Permisos sobre esquema actividades (puede ver, insertar, eliminar y modificar registros de la tabla mediante procedimientos almacenados pero sin alterar la tabla)

-- Le asignamos permiso para ejecutar los sps del schema actividades
GRANT EXECUTE ON SCHEMA::actividades TO admin_actividades
-- GRANT EXECUTE ON OBJECT::reservas.vw_leer_participaciones TO admin_actividades
-- GRANT EXECUTE ON OBJECT::parques.vw_leer_parques TO admin_actividades
-- GRANT EXECUTE ON OBJECT::empleados.vw_leer_guia_en_actividad TO admin_actividades
-- GRANT EXECUTE ON OBJECT::empleados.vw_leer_guia_posee_habilitacion TO admin_actividades

-- Le denegamos el permiso a ejecutar los sps de creacion y eliminacion del modulo
DENY EXECUTE ON OBJECT::actividades.sp_crear_tablas_modulo_actividades TO admin_actividades
DENY EXECUTE ON OBJECT::actividades.sp_crear_modulo_actividades TO admin_actividades
DENY EXECUTE ON OBJECT::actividades.sp_eliminar_modulo_actividades TO admin_actividades



-------------------------------------------------- PARA ROL DE Administrador de Parques--------------------------------------------------
-- Permisos sobre esquema parques (puede ver, insertar, eliminar y modificar registros de la tabla mediante procedimientos almacenados pero sin alterar la tabla)

--Le asignamos permiso para ejecutar los sps del schema parques
GRANT EXECUTE ON SCHEMA::parques TO admin_parques
-- GRANT EXECUTE ON OBJECT::reservas.vw_leer_entradas TO admin_parques
-- GRANT EXECUTE ON OBJECT::reservas.vw_leer_concesiones TO admin_parques
-- GRANT EXECUTE ON OBJECT::reservas.vw_leer_guardaparques_asignados_a_parque TO admin_parques
-- GRANT EXECUTE ON OBJECT::reservas.vw_leer_actividades TO admin_parques

-- Le denegamos el permiso para ejecutar los sps de creacion y eliminacion del modulo
DENY EXECUTE ON OBJECT::parques.sp_crear_tablas_modulo_parques TO admin_parques
DENY EXECUTE ON OBJECT::parques.sp_crear_modulo_parques TO admin_parques
DENY EXECUTE ON OBJECT::parques.sp_eliminar_modulo_parques TO admin_parques

-------------------------------------------------- PARA ROL DE Administrador de Empleados--------------------------------------------------
-- Permisos sobre esquema empleados (puede ver, insertar, eliminar y modificar registros de la tabla mediante procedimientos almacenados pero sin alterar la tabla)
GRANT EXECUTE ON SCHEMA::empleados TO admin_empleados
-- GRANT EXECUTE ON OBJECT::parques.vw_leer_parques TO admin_empleados
-- GRANT EXECUTE ON OBJECT::actividades.vw_leer_actividades TO admin_empleados
-- GRANT EXECUTE ON OBJECT::actividades.vw_leer_habilitaciones TO admin_empleados

-- Le denegamos el permiso para ejecutar los sps de creacion y eliminacion del modulo
DENY EXECUTE ON OBJECT::empleados.sp_crear_tablas_modulo_empleados TO admin_empleados
DENY EXECUTE ON OBJECT::empleados.sp_crear_modulo_empleados TO admin_empleados
DENY EXECUTE ON OBJECT::empleados.sp_eliminar_modulo_empleados TO admin_empleados


-------------------------------------------------- PARA ROL DE Administrador de Concesiones--------------------------------------------------
-- Permisos sobre esquema concesiones (puede ver, insertar, eliminar y modificar registros de la tabla mediante procedimientos almacenados pero sin alterar la tabla)


GRANT EXECUTE ON SCHEMA::concesiones TO admin_concesiones
-- GRANT EXECUTE ON OBJECT::parques.vw_leer_parques TO admin_concesiones
-- GRANT EXECUTE ON OBJECT::pagos.vw_leer_forma_pagos TO admin_concesiones

-- Le denegamos el permiso para ejecutar los sps de creacion y eliminacion del modulo
DENY EXECUTE ON OBJECT::concesiones.sp_crear_tablas_modulo_concesiones TO admin_concesiones
DENY EXECUTE ON OBJECT::concesiones.sp_crear_modulo_concesiones TO admin_concesiones
DENY EXECUTE ON OBJECT::concesiones.sp_eliminar_modulo_concesiones TO admin_concesiones


-------------------------------------------------- PARA ROL DE Administrador de Reservas--------------------------------------------------
-- Permisos sobre esquema reservas (puede ver, insertar, eliminar y modificar registros de la tabla mediante procedimientos almacenados pero sin alterar la tabla)  y permiso para ver e insertar en tabla pago

GRANT EXECUTE ON SCHEMA::reservas TO admin_reservas
GRANT EXECUTE ON OBJECT::pagos.sp_crear_pago TO admin_reservas
-- GRANT EXECUTE ON OBJECT::pagos.vw_leer_pagos TO admin_reservas
-- GRANT EXECUTE ON OBJECT::actividades.vw_leer_horarios TO admin_reservas
-- GRANT EXECUTE ON OBJECT::parques.vw_leer_parques TO admin_reservas

-- Le denegamos el permiso para ejecutar los sps de creacion y eliminacion del modulo
DENY EXECUTE ON OBJECT::reservas.sp_crear_tablas_modulo_reservas TO admin_reservas
DENY EXECUTE ON OBJECT::reservas.sp_crear_modulo_reservas TO admin_reservas
DENY EXECUTE ON OBJECT::reservas.sp_eliminar_modulo_reservas TO admin_reservas


-------------------------------------------------- PARA ROL DE Recursos Humanos (RRHH)--------------------------------------------------
-- Permisos sobre sps de consultas sobre empleados (puede unicamente ver informacion del esquema empleados)

-- GRANT EXECUTE ON OBJECT::empleados.vw_leer_guia TO rrhh
-- GRANT EXECUTE ON OBJECT::empleados.vw_leer_guia_em_actividad TO rrhh
-- GRANT EXECUTE ON OBJECT::empleados.vw_leer_guia_posee_habilitacion TO rrhh
-- GRANT EXECUTE ON OBJECT::empleados.vw_leer_guardaparque TO rrhh
-- GRANT EXECUTE ON OBJECT::empleados.vw_leer_guardaparque_asignado_parque TO rrhh


-------------------------------------------------- PARA ROL DE Usuario Web--------------------------------------------------
-- FALTARIA DEFINIR SOBRE QUE TABLA REALIZAREMOS EL ABM DESDE LA PAGINA 


-------------------------------------------------- PARA ROL DE Auditor de Concesones--------------------------------------------------
-- Permisos para consultar la informacion del modulo concesiones

--GRANT EXECUTE ON OBJECT::concesiones.vw_leer_concesiones TO auditor_concesion
--GRANT EXECUTE ON OBJECT::concesiones.vw_leer_empresa_concesionaria TO auditor_concesion
--GRANT EXECUTE ON OBJECT::concesiones.vw_leer_actividad_empresarial TO auditor_concesion
--GRANT EXECUTE ON OBJECT::concesiones.vw_leer_canon TO auditor_concesion

-------------------------------------------------- PARA ROL DE Auditor de Finanzas--------------------------------------------------
-- Permisos para consultar la informacion del modulo reservas y del modulo pagos

--GRANT EXECUTE ON OBJECT::reservas.vw_leer_reservas TO auditor_finanzas
--GRANT EXECUTE ON OBJECT::reservas.vw_leer_reembolsos TO auditor_finanzas
--GRANT EXECUTE ON OBJECT::reservas.vw_leer_motivo_cancelacion TO auditor_finanzas
--GRANT EXECUTE ON OBJECT::pagos.vw_leer_pagos TO auditor_finanzas
--GRANT EXECUTE ON OBJECT::pagos_vw_leer_tickets_factura TO auditor_finanzas


-------------------------------------------------- PARA ROL DE Director General--------------------------------------------------
-- FALTARIA DEFINIR LAS VISTAS DE LECTURAS Y COMO MANEJAREMOS ESTE ROL


-------------------------------------------------- PARA ROL DE Importacion de Datos--------------------------------------------------
--Permisos para ejecutar procedimientos almacenados para exportar archivos anteriormente definidos

GRANT EXECUTE ON OBJECT::parques.sp_importar_parques TO importador_datos
GRANT EXECUTE ON OBJECT::empleados.sp_importar_guias TO importador_datos
GRANT EXECUTE ON OBJECT::concesiones.sp_importar_directorio_empresas TO importador_datos

