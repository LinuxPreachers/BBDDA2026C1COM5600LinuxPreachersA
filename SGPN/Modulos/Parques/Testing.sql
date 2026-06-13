USE LinuxPreachers;
GO

SET NOCOUNT ON;
GO

/*
    Modo de uso:
    - Ejecutar lote por lote.
    - Despues de cada lote, comparar manualmente con el comentario "Resultado Esperado".
    IMPORTANTE: Este script es destructivo sobre las tablas del modulo parques de parques. Ejecutalo en una base de pruebas.
    Requiere que ya existan: parques.sp_eliminar_modulo_parques, parques.sp_crear_modulo_parques, todos los SP de ABM del modulo parques.
*/

PRINT 'Reiniciando modulo parques para ejecutar tests manuales...';
EXEC parques.sp_eliminar_modulo_parques;
EXEC parques.sp_crear_modulo_parques;
GO


------------------------------------------------------------
-- Region
------------------------------------------------------------

-- Test: sp_leer_region - error si no se informa id ni nombre
EXEC parques.sp_leer_region;
-- Resultado Esperado: error que contenga 'Debe ingresar un id o un nombre'.
GO


-- Test: sp_crear_region - error nombre vacio
EXEC parques.sp_crear_region @nombre = '   ';
-- Resultado Esperado: error que contenga 'El nombre de la region no puede estar vacio'.
GO


-- Test: sp_crear_region - alta feliz 1
EXEC parques.sp_crear_region @nombre = 'TEST_REGION_1';
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.Region WHERE nombre = 'TEST_REGION_1') THEN 1 ELSE 0 END;
SELECT * FROM parques.Region WHERE nombre = 'TEST_REGION_1'
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_crear_region - alta feliz 2
EXEC parques.sp_crear_region @nombre = 'TEST_REGION_2';
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.Region WHERE nombre = 'TEST_REGION_2') THEN 1 ELSE 0 END;
SELECT * FROM parques.Region WHERE nombre = 'TEST_REGION_2'
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_crear_region - alta feliz 3
EXEC parques.sp_crear_region @nombre = 'TEST_REGION_3';
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.Region WHERE nombre = 'TEST_REGION_3') THEN 1 ELSE 0 END;
SELECT * FROM parques.Region WHERE nombre = 'TEST_REGION_3'
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_leer_region - lectura por id
DECLARE @id INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_1');
DECLARE @r TABLE (id INT, nombre VARCHAR(100));
INSERT INTO @r EXEC parques.sp_leer_region @id = @id;
SELECT * FROM @r WHERE id = @id AND nombre = 'TEST_REGION_1'
IF NOT EXISTS (SELECT 1 FROM @r WHERE id = @id AND nombre = 'TEST_REGION_1')
    RAISERROR('La lectura por id no devolvio la region esperada.', 16, 1);
-- Resultado Esperado: se ejecuta sin errores.
GO


-- Test: sp_leer_region - lectura por nombre
DECLARE @r TABLE (id INT, nombre VARCHAR(100));
INSERT INTO @r EXEC parques.sp_leer_region @nombre = 'TEST_REGION_2';
SELECT * FROM @r WHERE nombre = 'TEST_REGION_2'
IF NOT EXISTS (SELECT 1 FROM @r WHERE nombre = 'TEST_REGION_2')
    RAISERROR('La lectura por nombre no devolvio la region esperada.', 16, 1);
-- Resultado Esperado: se ejecuta sin errores.
GO


-- Test: sp_leer_region - lectura por id y nombre
DECLARE @id INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_3');
DECLARE @r TABLE (id INT, nombre VARCHAR(100));
INSERT INTO @r EXEC parques.sp_leer_region @id = @id, @nombre = 'TEST_REGION_3';
SELECT * FROM @r WHERE id = @id AND nombre = 'TEST_REGION_3'
IF NOT EXISTS (SELECT 1 FROM @r WHERE id = @id AND nombre = 'TEST_REGION_3')
    RAISERROR('La lectura por id y nombre no devolvio la region esperada.', 16, 1);
-- Resultado Esperado: se ejecuta sin errores.
GO


-- Test: sp_modificar_region - error id inexistente
EXEC parques.sp_modificar_region @id = -1, @nombreNuevo = 'NO_EXISTE';
-- Resultado Esperado: error que contenga 'Region con el ID'.
GO


-- Test: sp_modificar_region - error nombre nuevo vacio
DECLARE @id INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_1');
EXEC parques.sp_modificar_region @id = @id, @nombreNuevo = '';
-- Resultado Esperado: error que contenga 'nombre nuevo'.
GO


-- Test: sp_modificar_region - modificacion feliz 1
DECLARE @id INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_1');
EXEC parques.sp_modificar_region @id = @id, @nombreNuevo = 'TEST_REGION_1_MOD';
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.Region WHERE nombre = 'TEST_REGION_1_MOD') THEN 1 ELSE 0 END;
SELECT * FROM parques.Region WHERE nombre = 'TEST_REGION_1_MOD'
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_modificar_region - modificacion feliz 2
DECLARE @id INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2');
EXEC parques.sp_modificar_region @id = @id, @nombreNuevo = 'TEST_REGION_2_MOD';
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT * FROM parques.Region WHERE id = @id -- otra verif
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_modificar_region - modificacion feliz 3
DECLARE @id INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_3');
EXEC parques.sp_modificar_region @id = @id, @nombreNuevo = 'TEST_REGION_3_MOD';
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.Region WHERE nombre = 'TEST_REGION_3_MOD') THEN 1 ELSE 0 END;
SELECT * FROM parques.Region WHERE nombre = 'TEST_REGION_3_MOD'
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_region - error id inexistente
EXEC parques.sp_eliminar_region @id = -1;
-- Resultado Esperado: error que contenga 'Region con el ID'.
GO


-- Test: preparacion - provincia asociada a region
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_1_MOD');
EXEC parques.sp_crear_provincia @nombre = 'TEST_PROV_DEP_REGION', @id_region = @id_region;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.Provincia WHERE nombre = 'TEST_PROV_DEP_REGION') THEN 1 ELSE 0 END;
SELECT * FROM parques.Provincia WHERE nombre = 'TEST_PROV_DEP_REGION'
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_region - error con provincias asociadas
DECLARE @id INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_1_MOD');
EXEC parques.sp_eliminar_region @id = @id;
-- Resultado Esperado: error que contenga 'provincias asociadas'.
GO


-- Test: preparacion - estadistica asociada a region
EXEC parques.sp_crear_region @nombre = 'TEST_REGION_DEP_EST';
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_DEP_EST');
EXEC parques.sp_crear_estadistica_visitantes
    @periodo = '2026-M01',
    @periodo_inicio = '20260101',
    @periodo_fin = '20260131',
    @cantidad = 100,
    @id_region = @id_region;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.EstadisticaVisitantes EV INNER JOIN parques.Region R ON R.id = EV.id_region WHERE R.nombre = 'TEST_REGION_DEP_EST') THEN 1 ELSE 0 END;
SELECT * FROM parques.EstadisticaVisitantes EV INNER JOIN parques.Region R ON R.id = EV.id_region WHERE R.nombre = 'TEST_REGION_DEP_EST'
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_region - error con estadisticas asociadas
DECLARE @id INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_DEP_EST');
EXEC parques.sp_eliminar_region @id = @id;
-- Resultado Esperado: error que contenga 'estadisticas de visitantes asociadas'.
GO


-- Test: sp_eliminar_region - baja feliz 1
EXEC parques.sp_crear_region @nombre = 'TEST_REGION_DEL_1';
DECLARE @id INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_DEL_1');
EXEC parques.sp_eliminar_region @id = @id;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM parques.Region WHERE nombre = 'TEST_REGION_DEL_1') THEN 1 ELSE 0 END;
SELECT * FROM parques.Region WHERE nombre = 'TEST_REGION_DEL_1'
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_region - baja feliz 2
EXEC parques.sp_crear_region @nombre = 'TEST_REGION_DEL_2';
DECLARE @id INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_DEL_2');
EXEC parques.sp_eliminar_region @id = @id;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM parques.Region WHERE nombre = 'TEST_REGION_DEL_2') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_region - baja feliz 3
EXEC parques.sp_crear_region @nombre = 'TEST_REGION_DEL_3';
DECLARE @id INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_DEL_3');
EXEC parques.sp_eliminar_region @id = @id;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM parques.Region WHERE nombre = 'TEST_REGION_DEL_3') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO



------------------------------------------------------------
-- Provincia
------------------------------------------------------------

-- Test: sp_crear_provincia - error nombre vacio
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD');
EXEC parques.sp_crear_provincia @nombre = '', @id_region = @id_region;
-- Resultado Esperado: error que contenga 'nombre de la provincia'.
GO


-- Test: sp_crear_provincia - error region inexistente
EXEC parques.sp_crear_provincia @nombre = 'TEST_PROV_ERROR_REGION', @id_region = -1;
-- Resultado Esperado: error que contenga 'ID de Region'.
GO


-- Test: sp_crear_provincia - alta feliz 1
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD');
EXEC parques.sp_crear_provincia @nombre = 'TEST_PROV_1', @id_region = @id_region;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.Provincia WHERE nombre = 'TEST_PROV_1') THEN 1 ELSE 0 END;
SELECT * FROM parques.Provincia WHERE nombre = 'TEST_PROV_1'
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_crear_provincia - alta feliz 2
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD');
EXEC parques.sp_crear_provincia @nombre = 'TEST_PROV_2', @id_region = @id_region;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.Provincia WHERE nombre = 'TEST_PROV_2') THEN 1 ELSE 0 END;
SELECT * FROM parques.Provincia WHERE nombre = 'TEST_PROV_2'
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_crear_provincia - alta feliz 3
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD');
EXEC parques.sp_crear_provincia @nombre = 'TEST_PROV_3', @id_region = @id_region;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.Provincia WHERE nombre = 'TEST_PROV_3') THEN 1 ELSE 0 END;
SELECT * FROM parques.Provincia WHERE nombre = 'TEST_PROV_3'
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_leer_provincia - lectura general
DECLARE @r TABLE (id INT, nombre VARCHAR(100), id_region INT);
INSERT INTO @r EXEC parques.sp_leer_provincia;
IF NOT EXISTS (SELECT 1 FROM @r WHERE nombre = 'TEST_PROV_1')
    RAISERROR('La lectura general no devolvio provincias.', 16, 1);
SELECT * FROM @r WHERE nombre = 'TEST_PROV_1'
-- Resultado Esperado: se ejecuta sin errores.
GO


-- Test: sp_leer_provincia - lectura por id
DECLARE @id INT = (SELECT id FROM parques.Provincia WHERE nombre = 'TEST_PROV_2');
DECLARE @r TABLE (id INT, nombre VARCHAR(100), id_region INT);
INSERT INTO @r EXEC parques.sp_leer_provincia @id = @id;
IF NOT EXISTS (SELECT 1 FROM @r WHERE id = @id AND nombre = 'TEST_PROV_2')
    RAISERROR('La lectura por id no devolvio la provincia esperada.', 16, 1);
SELECT * FROM @r WHERE id = @id AND nombre = 'TEST_PROV_2'
-- Resultado Esperado: se ejecuta sin errores.
GO


-- Test: sp_leer_provincia - lectura por region
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD');
DECLARE @r TABLE (id INT, nombre VARCHAR(100), id_region INT);
INSERT INTO @r EXEC parques.sp_leer_provincia @id_region = @id_region;
IF (SELECT COUNT(1) FROM @r WHERE id_region = @id_region) < 3
    RAISERROR('La lectura por region no devolvio las provincias esperadas.', 16, 1);
SELECT * FROM @r WHERE id_region = @id_region
-- Resultado Esperado: se ejecuta sin errores.
GO


-- Test: sp_modificar_provincia - error id inexistente
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD');
EXEC parques.sp_modificar_provincia @id = -1, @nombre = 'NO_EXISTE', @id_region = @id_region;
-- Resultado Esperado: error que contenga 'Provincia con el ID'.
GO


-- Test: sp_modificar_provincia - error nombre vacio
DECLARE @id INT = (SELECT id FROM parques.Provincia WHERE nombre = 'TEST_PROV_1');
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD');
EXEC parques.sp_modificar_provincia @id = @id, @nombre = '', @id_region = @id_region;
-- Resultado Esperado: error que contenga 'nombre de la provincia'.
GO


-- Test: sp_modificar_provincia - error region inexistente
DECLARE @id INT = (SELECT id FROM parques.Provincia WHERE nombre = 'TEST_PROV_1');
EXEC parques.sp_modificar_provincia @id = @id, @nombre = 'TEST_PROV_ERR', @id_region = -1;
-- Resultado Esperado: error que contenga 'ID de Region'.
GO


-- Test: sp_modificar_provincia - modificacion feliz 1
DECLARE @id INT = (SELECT id FROM parques.Provincia WHERE nombre = 'TEST_PROV_1');
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_3_MOD');
EXEC parques.sp_modificar_provincia @id = @id, @nombre = 'TEST_PROV_1_MOD', @id_region = @id_region;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.Provincia P INNER JOIN parques.Region R ON R.id = P.id_region WHERE P.nombre = 'TEST_PROV_1_MOD' AND R.nombre = 'TEST_REGION_3_MOD') THEN 1 ELSE 0 END;
SELECT * FROM parques.Provincia P INNER JOIN parques.Region R ON R.id = P.id_region WHERE P.nombre = 'TEST_PROV_1_MOD' AND R.nombre = 'TEST_REGION_3_MOD'
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_modificar_provincia - modificacion feliz 2
DECLARE @id INT = (SELECT id FROM parques.Provincia WHERE nombre = 'TEST_PROV_2');
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_3_MOD');
EXEC parques.sp_modificar_provincia @id = @id, @nombre = 'TEST_PROV_2_MOD', @id_region = @id_region;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.Provincia P INNER JOIN parques.Region R ON R.id = P.id_region WHERE P.nombre = 'TEST_PROV_2_MOD' AND R.nombre = 'TEST_REGION_3_MOD') THEN 1 ELSE 0 END;
SELECT * FROM parques.Provincia P INNER JOIN parques.Region R ON R.id = P.id_region WHERE P.nombre = 'TEST_PROV_2_MOD' AND R.nombre = 'TEST_REGION_3_MOD'
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_modificar_provincia - modificacion feliz 3
DECLARE @id INT = (SELECT id FROM parques.Provincia WHERE nombre = 'TEST_PROV_3');
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_3_MOD');
EXEC parques.sp_modificar_provincia @id = @id, @nombre = 'TEST_PROV_3_MOD', @id_region = @id_region;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.Provincia P INNER JOIN parques.Region R ON R.id = P.id_region WHERE P.nombre = 'TEST_PROV_3_MOD' AND R.nombre = 'TEST_REGION_3_MOD') THEN 1 ELSE 0 END;
SELECT * FROM parques.Provincia P INNER JOIN parques.Region R ON R.id = P.id_region WHERE P.nombre = 'TEST_PROV_3_MOD' AND R.nombre = 'TEST_REGION_3_MOD'
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_provincia - error id inexistente
EXEC parques.sp_eliminar_provincia @id = -1;
-- Resultado Esperado: error que contenga 'Provincia con el ID'.
GO


-- Test: preparacion - parque asociado a provincia
EXEC parques.sp_crear_tipo_parque @descripcion = 'TEST_TIPO_PARQUE_DEP_PROV';
DECLARE @id_tipo INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_DEP_PROV');
EXEC parques.sp_crear_parque @nombre = 'TEST_PARQUE_DEP_PROV', @superficie_km2 = 10, @latitud = -34.1, @longitud = -58.1, @id_tipo_parque = @id_tipo;
DECLARE @id_prov INT = (SELECT id FROM parques.Provincia WHERE nombre = 'TEST_PROV_1_MOD');
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PARQUE_DEP_PROV');
EXEC parques.sp_crear_provincia_parque @id_provincia = @id_prov, @id_parque = @id_parque, @direccion = 'Direccion test';
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.ProvinciaParque PP INNER JOIN parques.Parque P ON P.id = PP.id_parque WHERE P.nombre = 'TEST_PARQUE_DEP_PROV') THEN 1 ELSE 0 END;
SELECT * FROM parques.ProvinciaParque PP INNER JOIN parques.Parque P ON P.id = PP.id_parque WHERE P.nombre = 'TEST_PARQUE_DEP_PROV'
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_provincia - error con parques asociados
DECLARE @id INT = (SELECT id FROM parques.Provincia WHERE nombre = 'TEST_PROV_1_MOD');
EXEC parques.sp_eliminar_provincia @id = @id;
-- Resultado Esperado: error que contenga 'parques asociados'.
GO


-- Test: sp_eliminar_provincia - baja feliz 1
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD');
EXEC parques.sp_crear_provincia @nombre = 'TEST_PROV_DEL_1', @id_region = @id_region;
DECLARE @id INT = (SELECT id FROM parques.Provincia WHERE nombre = 'TEST_PROV_DEL_1');
EXEC parques.sp_eliminar_provincia @id = @id;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM parques.Provincia WHERE nombre = 'TEST_PROV_DEL_1') THEN 1 ELSE 0 END;
SELECT * FROM parques.Provincia WHERE nombre = 'TEST_PROV_DEL_1'
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_provincia - baja feliz 2
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD');
EXEC parques.sp_crear_provincia @nombre = 'TEST_PROV_DEL_2', @id_region = @id_region;
DECLARE @id INT = (SELECT id FROM parques.Provincia WHERE nombre = 'TEST_PROV_DEL_2');
EXEC parques.sp_eliminar_provincia @id = @id;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM parques.Provincia WHERE nombre = 'TEST_PROV_DEL_2') THEN 1 ELSE 0 END;
SELECT * FROM parques.Provincia WHERE nombre = 'TEST_PROV_DEL_2'
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_provincia - baja feliz 3
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD');
EXEC parques.sp_crear_provincia @nombre = 'TEST_PROV_DEL_3', @id_region = @id_region;
DECLARE @id INT = (SELECT id FROM parques.Provincia WHERE nombre = 'TEST_PROV_DEL_3');
EXEC parques.sp_eliminar_provincia @id = @id;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM parques.Provincia WHERE nombre = 'TEST_PROV_DEL_3') THEN 1 ELSE 0 END;
SELECT 1 FROM parques.Provincia WHERE nombre = 'TEST_PROV_DEL_3'
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_provincias_de_region - error region inexistente
EXEC parques.sp_eliminar_provincias_de_region @id_region = -1;
-- Resultado Esperado: error que contenga 'Region con el ID'.
GO


-- Test: preparacion - region sin provincias
EXEC parques.sp_crear_region @nombre = 'TEST_REGION_SIN_PROV';
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.Region WHERE nombre = 'TEST_REGION_SIN_PROV') THEN 1 ELSE 0 END;
SELECT * FROM parques.Region WHERE nombre = 'TEST_REGION_SIN_PROV'
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_provincias_de_region - error sin provincias
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_SIN_PROV');
EXEC parques.sp_eliminar_provincias_de_region @id_region = @id_region;
-- Resultado Esperado: error que contenga 'No hay ninguna provincia'.
GO


-- Test: sp_eliminar_provincias_de_region - error provincias con parques
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_3_MOD');
EXEC parques.sp_eliminar_provincias_de_region @id_region = @id_region;
-- Resultado Esperado: error que contenga 'Parques asociados'.
GO

-- Test: sp_eliminar_provincias_de_region - baja masiva feliz 1
DELETE FROM parques.Region where nombre = 'TEST_REGION_BULK_PROV_1'
EXEC parques.sp_crear_region @nombre = 'TEST_REGION_BULK_PROV_1';
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_BULK_PROV_1');
EXEC parques.sp_crear_provincia @nombre = 'TEST_BULK_PROV_1_A', @id_region = @id_region;
EXEC parques.sp_crear_provincia @nombre = 'TEST_BULK_PROV_1_B', @id_region = @id_region;
SELECT * FROM parques.Provincia WHERE nombre LIKE 'TEST_BULK_PROV_1_%' -- antes
EXEC parques.sp_eliminar_provincias_de_region @id_region = @id_region;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM parques.Provincia WHERE nombre LIKE 'TEST_BULK_PROV_1_%') THEN 1 ELSE 0 END;
SELECT * FROM parques.Provincia WHERE nombre LIKE 'TEST_BULK_PROV_1_%' -- despues
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_provincias_de_region - baja masiva feliz 2
EXEC parques.sp_crear_region @nombre = 'TEST_REGION_BULK_PROV_2';
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_BULK_PROV_2');
EXEC parques.sp_crear_provincia @nombre = 'TEST_BULK_PROV_2_A', @id_region = @id_region;
EXEC parques.sp_crear_provincia @nombre = 'TEST_BULK_PROV_2_B', @id_region = @id_region;
EXEC parques.sp_eliminar_provincias_de_region @id_region = @id_region;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM parques.Provincia WHERE nombre LIKE 'TEST_BULK_PROV_2_%') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_provincias_de_region - baja masiva feliz 3
EXEC parques.sp_crear_region @nombre = 'TEST_REGION_BULK_PROV_3';
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_BULK_PROV_3');
EXEC parques.sp_crear_provincia @nombre = 'TEST_BULK_PROV_3_A', @id_region = @id_region;
EXEC parques.sp_crear_provincia @nombre = 'TEST_BULK_PROV_3_B', @id_region = @id_region;
EXEC parques.sp_eliminar_provincias_de_region @id_region = @id_region;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM parques.Provincia WHERE nombre LIKE 'TEST_BULK_PROV_3_%') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO



------------------------------------------------------------
-- TipoVisitante
------------------------------------------------------------

-- Test: sp_crear_tipo_visitante - error nombre vacio
EXEC parques.sp_crear_tipo_visitante @nombre = '', @descripcion = 'desc';
-- Resultado Esperado: error que contenga 'nombre del tipo de visitante'.
GO

-- Test: sp_crear_tipo_visitante - alta feliz 1
EXEC parques.sp_crear_tipo_visitante @nombre = 'TEST_TV_1', @descripcion = 'Descripcion 1';
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.TipoVisitante WHERE nombre = 'TEST_TV_1') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_crear_tipo_visitante - alta feliz 2
EXEC parques.sp_crear_tipo_visitante @nombre = 'TEST_TV_2', @descripcion = 'Descripcion 2';
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.TipoVisitante WHERE nombre = 'TEST_TV_2') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_crear_tipo_visitante - alta feliz 3
EXEC parques.sp_crear_tipo_visitante @nombre = 'TEST_TV_3', @descripcion = 'Descripcion 3';
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.TipoVisitante WHERE nombre = 'TEST_TV_3') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_leer_tipo_visitante - lectura general
DECLARE @r TABLE (id INT, nombre VARCHAR(100), descripcion VARCHAR(255));
INSERT INTO @r EXEC parques.sp_leer_tipo_visitante;
IF NOT EXISTS (SELECT 1 FROM @r WHERE nombre = 'TEST_TV_1')
    RAISERROR('La lectura general no devolvio tipos de visitante.', 16, 1);
-- Resultado Esperado: se ejecuta sin errores.
GO


-- Test: sp_leer_tipo_visitante - lectura por id 1
DECLARE @id INT = (SELECT id FROM parques.TipoVisitante WHERE nombre = 'TEST_TV_1');
DECLARE @r TABLE (id INT, nombre VARCHAR(100), descripcion VARCHAR(255));
INSERT INTO @r EXEC parques.sp_leer_tipo_visitante @id = @id;
IF NOT EXISTS (SELECT 1 FROM @r WHERE id = @id AND nombre = 'TEST_TV_1')
    RAISERROR('La lectura por id no devolvio el tipo de visitante esperado.', 16, 1);
-- Resultado Esperado: se ejecuta sin errores.
GO


-- Test: sp_leer_tipo_visitante - lectura por id 2
DECLARE @id INT = (SELECT id FROM parques.TipoVisitante WHERE nombre = 'TEST_TV_2');
DECLARE @r TABLE (id INT, nombre VARCHAR(100), descripcion VARCHAR(255));
INSERT INTO @r EXEC parques.sp_leer_tipo_visitante @id = @id;
IF NOT EXISTS (SELECT 1 FROM @r WHERE id = @id AND nombre = 'TEST_TV_2')
    RAISERROR('La lectura por id no devolvio el tipo de visitante esperado.', 16, 1);
-- Resultado Esperado: se ejecuta sin errores.
GO


-- Test: sp_modificar_tipo_visitante - error id inexistente
EXEC parques.sp_modificar_tipo_visitante @id = -1, @nombre = 'NO_EXISTE', @descripcion = 'x';
-- Resultado Esperado: error que contenga 'TipoVisitante con el ID'.
GO


-- Test: sp_modificar_tipo_visitante - error nombre vacio
DECLARE @id INT = (SELECT id FROM parques.TipoVisitante WHERE nombre = 'TEST_TV_1');
EXEC parques.sp_modificar_tipo_visitante @id = @id, @nombre = '', @descripcion = 'x';
-- Resultado Esperado: error que contenga 'nombre del tipo de visitante'.
GO


-- Test: sp_modificar_tipo_visitante - modificacion feliz 1
DECLARE @id INT = (SELECT id FROM parques.TipoVisitante WHERE nombre = 'TEST_TV_1');
EXEC parques.sp_modificar_tipo_visitante @id = @id, @nombre = 'TEST_TV_1_MOD', @descripcion = 'Descripcion modificada 1';
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.TipoVisitante WHERE nombre = 'TEST_TV_1_MOD' AND descripcion = 'Descripcion modificada 1') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_modificar_tipo_visitante - modificacion feliz 2
DECLARE @id INT = (SELECT id FROM parques.TipoVisitante WHERE nombre = 'TEST_TV_2');
EXEC parques.sp_modificar_tipo_visitante @id = @id, @nombre = 'TEST_TV_2_MOD', @descripcion = 'Descripcion modificada 2';
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.TipoVisitante WHERE nombre = 'TEST_TV_2_MOD' AND descripcion = 'Descripcion modificada 2') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_modificar_tipo_visitante - modificacion feliz 3
DECLARE @id INT = (SELECT id FROM parques.TipoVisitante WHERE nombre = 'TEST_TV_3');
EXEC parques.sp_modificar_tipo_visitante @id = @id, @nombre = 'TEST_TV_3_MOD', @descripcion = 'Descripcion modificada 3';
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.TipoVisitante WHERE nombre = 'TEST_TV_3_MOD' AND descripcion = 'Descripcion modificada 3') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_tipo_visitante - error id inexistente
EXEC parques.sp_eliminar_tipo_visitante @id = -1;
-- Resultado Esperado: error que contenga 'TipoVisitante con el ID'.
GO


-- Test: preparacion - tipo visitante asociado a parque
EXEC parques.sp_crear_tipo_visitante @nombre = 'TEST_TV_DEP_PTV', @descripcion = 'dep';
DECLARE @id_tv INT = (SELECT id FROM parques.TipoVisitante WHERE nombre = 'TEST_TV_DEP_PTV');
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PARQUE_DEP_PROV');
EXEC parques.sp_crear_parque_tipo_visitante @id_parque = @id_parque, @id_tipo_visitante = @id_tv, @precio = 100;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.ParqueTipoVisitante PTV INNER JOIN parques.TipoVisitante TV ON TV.id = PTV.id_tipo_visitante WHERE TV.nombre = 'TEST_TV_DEP_PTV') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_tipo_visitante - error asociado a parque
DECLARE @id INT = (SELECT id FROM parques.TipoVisitante WHERE nombre = 'TEST_TV_DEP_PTV');
EXEC parques.sp_eliminar_tipo_visitante @id = @id;
-- Resultado Esperado: error que contenga 'asociado'.
GO


-- Test: sp_eliminar_tipo_visitante - baja feliz 1
EXEC parques.sp_crear_tipo_visitante @nombre = 'TEST_TV_DEL_1', @descripcion = 'del';
DECLARE @id INT = (SELECT id FROM parques.TipoVisitante WHERE nombre = 'TEST_TV_DEL_1');
EXEC parques.sp_eliminar_tipo_visitante @id = @id;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM parques.TipoVisitante WHERE nombre = 'TEST_TV_DEL_1') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_tipo_visitante - baja feliz 2
EXEC parques.sp_crear_tipo_visitante @nombre = 'TEST_TV_DEL_2', @descripcion = 'del';
DECLARE @id INT = (SELECT id FROM parques.TipoVisitante WHERE nombre = 'TEST_TV_DEL_2');
EXEC parques.sp_eliminar_tipo_visitante @id = @id;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM parques.TipoVisitante WHERE nombre = 'TEST_TV_DEL_2') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_tipo_visitante - baja feliz 3
EXEC parques.sp_crear_tipo_visitante @nombre = 'TEST_TV_DEL_3', @descripcion = 'del';
DECLARE @id INT = (SELECT id FROM parques.TipoVisitante WHERE nombre = 'TEST_TV_DEL_3');
EXEC parques.sp_eliminar_tipo_visitante @id = @id;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM parques.TipoVisitante WHERE nombre = 'TEST_TV_DEL_3') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO



------------------------------------------------------------
-- TipoParque
------------------------------------------------------------

-- Test: sp_crear_tipo_parque - error descripcion vacia
EXEC parques.sp_crear_tipo_parque @descripcion = '';
-- Resultado Esperado: error que contenga 'descripcion del tipo de parque'.
GO


-- Test: sp_crear_tipo_parque - alta feliz 1
EXEC parques.sp_crear_tipo_parque @descripcion = 'TEST_TIPO_PARQUE_1';
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_1') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_crear_tipo_parque - alta feliz 2
EXEC parques.sp_crear_tipo_parque @descripcion = 'TEST_TIPO_PARQUE_2';
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_2') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_crear_tipo_parque - alta feliz 3
EXEC parques.sp_crear_tipo_parque @descripcion = 'TEST_TIPO_PARQUE_3';
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_3') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_leer_tipo_parque - lectura general
DECLARE @r TABLE (id INT, descripcion VARCHAR(255));
INSERT INTO @r EXEC parques.sp_leer_tipo_parque;
IF NOT EXISTS (SELECT 1 FROM @r WHERE descripcion = 'TEST_TIPO_PARQUE_1')
    RAISERROR('La lectura general no devolvio tipos de parque.', 16, 1);
-- Resultado Esperado: se ejecuta sin errores.
GO


-- Test: sp_leer_tipo_parque - lectura por id 1
DECLARE @id INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_1');
DECLARE @r TABLE (id INT, descripcion VARCHAR(255));
INSERT INTO @r EXEC parques.sp_leer_tipo_parque @id = @id;
IF NOT EXISTS (SELECT 1 FROM @r WHERE id = @id AND descripcion = 'TEST_TIPO_PARQUE_1')
    RAISERROR('La lectura por id no devolvio el tipo de parque esperado.', 16, 1);
-- Resultado Esperado: se ejecuta sin errores.
GO


-- Test: sp_leer_tipo_parque - lectura por id 2
DECLARE @id INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_2');
DECLARE @r TABLE (id INT, descripcion VARCHAR(255));
INSERT INTO @r EXEC parques.sp_leer_tipo_parque @id = @id;
IF NOT EXISTS (SELECT 1 FROM @r WHERE id = @id AND descripcion = 'TEST_TIPO_PARQUE_2')
    RAISERROR('La lectura por id no devolvio el tipo de parque esperado.', 16, 1);
-- Resultado Esperado: se ejecuta sin errores.
GO


-- Test: sp_modificar_tipo_parque - error id inexistente
EXEC parques.sp_modificar_tipo_parque @id = -1, @descripcion = 'NO_EXISTE';
-- Resultado Esperado: error que contenga 'TipoParque con el ID'.
GO


-- Test: sp_modificar_tipo_parque - error descripcion vacia
DECLARE @id INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_1');
EXEC parques.sp_modificar_tipo_parque @id = @id, @descripcion = '';
-- Resultado Esperado: error que contenga 'descripcion del tipo de parque'.
GO


-- Test: sp_modificar_tipo_parque - modificacion feliz 1
DECLARE @id INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_1');
EXEC parques.sp_modificar_tipo_parque @id = @id, @descripcion = 'TEST_TIPO_PARQUE_1_MOD';
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_1_MOD') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_modificar_tipo_parque - modificacion feliz 2
DECLARE @id INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_2');
EXEC parques.sp_modificar_tipo_parque @id = @id, @descripcion = 'TEST_TIPO_PARQUE_2_MOD';
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_2_MOD') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_modificar_tipo_parque - modificacion feliz 3
DECLARE @id INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_3');
EXEC parques.sp_modificar_tipo_parque @id = @id, @descripcion = 'TEST_TIPO_PARQUE_3_MOD';
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_3_MOD') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_tipo_parque - error id inexistente
EXEC parques.sp_eliminar_tipo_parque @id = -1;
-- Resultado Esperado: error que contenga 'TipoParque con el ID'.
GO


-- Test: sp_eliminar_tipo_parque - error con parques asociados
DECLARE @id INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_DEP_PROV');
EXEC parques.sp_eliminar_tipo_parque @id = @id;
-- Resultado Esperado: error que contenga 'parques asociados'.
GO


-- Test: sp_eliminar_tipo_parque - baja feliz 1
EXEC parques.sp_crear_tipo_parque @descripcion = 'TEST_TIPO_PARQUE_DEL_1';
DECLARE @id INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_DEL_1');
EXEC parques.sp_eliminar_tipo_parque @id = @id;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_DEL_1') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_tipo_parque - baja feliz 2
EXEC parques.sp_crear_tipo_parque @descripcion = 'TEST_TIPO_PARQUE_DEL_2';
DECLARE @id INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_DEL_2');
EXEC parques.sp_eliminar_tipo_parque @id = @id;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_DEL_2') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_tipo_parque - baja feliz 3
EXEC parques.sp_crear_tipo_parque @descripcion = 'TEST_TIPO_PARQUE_DEL_3';
DECLARE @id INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_DEL_3');
EXEC parques.sp_eliminar_tipo_parque @id = @id;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_DEL_3') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO



------------------------------------------------------------
-- Parque
------------------------------------------------------------

-- Test: sp_crear_parque - error nombre vacio
DECLARE @id_tipo INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_1_MOD');
EXEC parques.sp_crear_parque @nombre = '', @superficie_km2 = 1, @latitud = 0, @longitud = 0, @id_tipo_parque = @id_tipo;
-- Resultado Esperado: error que contenga 'nombre del parque'.
GO


-- Test: sp_crear_parque - error superficie no positiva
DECLARE @id_tipo INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_1_MOD');
EXEC parques.sp_crear_parque @nombre = 'TEST_PARQUE_ERR_SUP', @superficie_km2 = 0, @latitud = 0, @longitud = 0, @id_tipo_parque = @id_tipo;
-- Resultado Esperado: error que contenga 'superficie'.
GO


-- Test: sp_crear_parque - error latitud fuera de rango
DECLARE @id_tipo INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_1_MOD');
EXEC parques.sp_crear_parque @nombre = 'TEST_PARQUE_ERR_LAT', @superficie_km2 = 1, @latitud = 91, @longitud = 0, @id_tipo_parque = @id_tipo;
-- Resultado Esperado: error que contenga 'latitud'.
GO


-- Test: sp_crear_parque - error longitud fuera de rango
DECLARE @id_tipo INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_1_MOD');
EXEC parques.sp_crear_parque @nombre = 'TEST_PARQUE_ERR_LON', @superficie_km2 = 1, @latitud = 0, @longitud = 181, @id_tipo_parque = @id_tipo;
-- Resultado Esperado: error que contenga 'longitud'.
GO


-- Test: sp_crear_parque - error tipo parque inexistente
EXEC parques.sp_crear_parque @nombre = 'TEST_PARQUE_ERR_TIPO', @superficie_km2 = 1, @latitud = 0, @longitud = 0, @id_tipo_parque = -1;
-- Resultado Esperado: error que contenga 'Tipo de Parque'.
GO


-- Test: sp_crear_parque - alta feliz 1
DECLARE @id_tipo INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_1_MOD');
EXEC parques.sp_crear_parque @nombre = 'TEST_PARQUE_1', @superficie_km2 = 10.50, @latitud = -31.123456, @longitud = -51.123456, @id_tipo_parque = @id_tipo;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.Parque WHERE nombre = 'TEST_PARQUE_1') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_crear_parque - alta feliz 2
DECLARE @id_tipo INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_2_MOD');
EXEC parques.sp_crear_parque @nombre = 'TEST_PARQUE_2', @superficie_km2 = 20.50, @latitud = -32.123456, @longitud = -52.123456, @id_tipo_parque = @id_tipo;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.Parque WHERE nombre = 'TEST_PARQUE_2') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_crear_parque - alta feliz 3
DECLARE @id_tipo INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_3_MOD');
EXEC parques.sp_crear_parque @nombre = 'TEST_PARQUE_3', @superficie_km2 = 30.50, @latitud = -33.123456, @longitud = -53.123456, @id_tipo_parque = @id_tipo;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.Parque WHERE nombre = 'TEST_PARQUE_3') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_leer_parque - lectura general
DECLARE @r TABLE (id INT, nombre VARCHAR(100), superficie_km2 DECIMAL(10,2), latitud DECIMAL(9,6), longitud DECIMAL(9,6), id_tipo_parque INT);
INSERT INTO @r EXEC parques.sp_leer_parque;
IF NOT EXISTS (SELECT 1 FROM @r WHERE nombre = 'TEST_PARQUE_1')
    RAISERROR('La lectura general no devolvio parques.', 16, 1);
SELECT * FROM @r
-- Resultado Esperado: se ejecuta sin errores.
GO


-- Test: sp_leer_parque - lectura por id
DECLARE @id INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PARQUE_2');
DECLARE @r TABLE (id INT, nombre VARCHAR(100), superficie_km2 DECIMAL(10,2), latitud DECIMAL(9,6), longitud DECIMAL(9,6), id_tipo_parque INT);
INSERT INTO @r EXEC parques.sp_leer_parque @id = @id;
IF NOT EXISTS (SELECT 1 FROM @r WHERE id = @id AND nombre = 'TEST_PARQUE_2')
    RAISERROR('La lectura por id no devolvio el parque esperado.', 16, 1);
-- Resultado Esperado: se ejecuta sin errores.
GO


-- Test: sp_leer_parque - lectura por tipo parque
DECLARE @id_tipo INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_3_MOD');
DECLARE @r TABLE (id INT, nombre VARCHAR(100), superficie_km2 DECIMAL(10,2), latitud DECIMAL(9,6), longitud DECIMAL(9,6), id_tipo_parque INT);
INSERT INTO @r EXEC parques.sp_leer_parque @id_tipo_parque = @id_tipo;
IF NOT EXISTS (SELECT 1 FROM @r WHERE nombre = 'TEST_PARQUE_3' AND id_tipo_parque = @id_tipo)
    RAISERROR('La lectura por tipo parque no devolvio el parque esperado.', 16, 1);
-- Resultado Esperado: se ejecuta sin errores.
GO


-- Test: sp_modificar_parque - error id inexistente
DECLARE @id_tipo INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_1_MOD');
EXEC parques.sp_modificar_parque @id = -1, @nombre = 'NO_EXISTE', @superficie_km2 = 10, @latitud = 0, @longitud = 0, @id_tipo_parque = @id_tipo;
-- Resultado Esperado: error que contenga 'Parque con el ID'.
GO


-- Test: sp_modificar_parque - error nombre vacio
DECLARE @id INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PARQUE_1');
DECLARE @id_tipo INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_1_MOD');
EXEC parques.sp_modificar_parque @id = @id, @nombre = '', @superficie_km2 = 10, @latitud = 0, @longitud = 0, @id_tipo_parque = @id_tipo;
-- Resultado Esperado: error que contenga 'nombre del parque'.
GO


-- Test: sp_modificar_parque - error superficie negativa
DECLARE @id INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PARQUE_1');
DECLARE @id_tipo INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_1_MOD');
EXEC parques.sp_modificar_parque @id = @id, @nombre = 'TEST_PARQUE_ERR', @superficie_km2 = -1, @latitud = 0, @longitud = 0, @id_tipo_parque = @id_tipo;
-- Resultado Esperado: error que contenga 'superficie'.
GO


-- Test: sp_modificar_parque - error latitud fuera de rango
DECLARE @id INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PARQUE_1');
DECLARE @id_tipo INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_1_MOD');
EXEC parques.sp_modificar_parque @id = @id, @nombre = 'TEST_PARQUE_ERR', @superficie_km2 = 10, @latitud = -91, @longitud = 0, @id_tipo_parque = @id_tipo;
-- Resultado Esperado: error que contenga 'latitud'.
GO


-- Test: sp_modificar_parque - error longitud fuera de rango
DECLARE @id INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PARQUE_1');
DECLARE @id_tipo INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_1_MOD');
EXEC parques.sp_modificar_parque @id = @id, @nombre = 'TEST_PARQUE_ERR', @superficie_km2 = 10, @latitud = 0, @longitud = -181, @id_tipo_parque = @id_tipo;
-- Resultado Esperado: error que contenga 'longitud'.
GO


-- Test: sp_modificar_parque - error tipo parque inexistente
DECLARE @id INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PARQUE_1');
EXEC parques.sp_modificar_parque @id = @id, @nombre = 'TEST_PARQUE_ERR', @superficie_km2 = 10, @latitud = 0, @longitud = 0, @id_tipo_parque = -1;
-- Resultado Esperado: error que contenga 'TipoParque'.
GO


-- Test: sp_modificar_parque - modificacion feliz 1
DECLARE @id INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PARQUE_1');
DECLARE @id_tipo INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_1_MOD');
EXEC parques.sp_modificar_parque @id = @id, @nombre = 'TEST_PARQUE_1_MOD', @superficie_km2 = 100.25, @latitud = -40.1, @longitud = -60.1, @id_tipo_parque = @id_tipo;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.Parque WHERE nombre = 'TEST_PARQUE_1_MOD' AND superficie_km2 = 100.25) THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_modificar_parque - modificacion feliz 2
DECLARE @id INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PARQUE_2');
DECLARE @id_tipo INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_1_MOD');
EXEC parques.sp_modificar_parque @id = @id, @nombre = 'TEST_PARQUE_2_MOD', @superficie_km2 = 200.25, @latitud = -40.2, @longitud = -60.2, @id_tipo_parque = @id_tipo;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.Parque WHERE nombre = 'TEST_PARQUE_2_MOD' AND superficie_km2 = 200.25) THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_modificar_parque - modificacion feliz 3
DECLARE @id INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PARQUE_3');
DECLARE @id_tipo INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_1_MOD');
EXEC parques.sp_modificar_parque @id = @id, @nombre = 'TEST_PARQUE_3_MOD', @superficie_km2 = 300.25, @latitud = -40.3, @longitud = -60.3, @id_tipo_parque = @id_tipo;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.Parque WHERE nombre = 'TEST_PARQUE_3_MOD' AND superficie_km2 = 300.25) THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_parque - error id inexistente
EXEC parques.sp_eliminar_parque @id = -1;
-- Resultado Esperado: error que contenga 'Parque con el ID'.
GO


-- Test: sp_eliminar_parque - baja feliz 1
DECLARE @id_tipo INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_1_MOD');
EXEC parques.sp_crear_parque @nombre = 'TEST_PARQUE_DEL_1', @superficie_km2 = 1, @latitud = 0, @longitud = 0, @id_tipo_parque = @id_tipo;
DECLARE @id INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PARQUE_DEL_1');
EXEC parques.sp_eliminar_parque @id = @id;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM parques.Parque WHERE nombre = 'TEST_PARQUE_DEL_1') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_parque - baja feliz 2
DECLARE @id_tipo INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_1_MOD');
EXEC parques.sp_crear_parque @nombre = 'TEST_PARQUE_DEL_2', @superficie_km2 = 1, @latitud = 0, @longitud = 0, @id_tipo_parque = @id_tipo;
DECLARE @id INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PARQUE_DEL_2');
EXEC parques.sp_eliminar_parque @id = @id;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM parques.Parque WHERE nombre = 'TEST_PARQUE_DEL_2') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_parque - baja feliz 3
DECLARE @id_tipo INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_1_MOD');
EXEC parques.sp_crear_parque @nombre = 'TEST_PARQUE_DEL_3', @superficie_km2 = 1, @latitud = 0, @longitud = 0, @id_tipo_parque = @id_tipo;
DECLARE @id INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PARQUE_DEL_3');
EXEC parques.sp_eliminar_parque @id = @id;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM parques.Parque WHERE nombre = 'TEST_PARQUE_DEL_3') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO



------------------------------------------------------------
-- EstadisticaVisitantes
------------------------------------------------------------

-- Test: sp_crear_estadistica_visitantes - error periodo vacio
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD');
EXEC parques.sp_crear_estadistica_visitantes @periodo = '', @periodo_inicio = '20260101', @periodo_fin = '20260131', @cantidad = 10, @id_region = @id_region;
-- Resultado Esperado: error que contenga 'periodo'.
GO


-- Test: sp_crear_estadistica_visitantes - error inicio nulo
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD');
EXEC parques.sp_crear_estadistica_visitantes @periodo = 'ERR', @periodo_inicio = NULL, @periodo_fin = '20260131', @cantidad = 10, @id_region = @id_region;
-- Resultado Esperado: error que contenga 'inicio'.
GO


-- Test: sp_crear_estadistica_visitantes - error fin nulo
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD');
EXEC parques.sp_crear_estadistica_visitantes @periodo = 'ERR', @periodo_inicio = '20260101', @periodo_fin = NULL, @cantidad = 10, @id_region = @id_region;
-- Resultado Esperado: error que contenga 'fin'.
GO


-- Test: sp_crear_estadistica_visitantes - error fin anterior a inicio
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD');
EXEC parques.sp_crear_estadistica_visitantes @periodo = 'ERR', @periodo_inicio = '20260131', @periodo_fin = '20260101', @cantidad = 10, @id_region = @id_region;
-- Resultado Esperado: error que contenga 'anterior'.
GO


-- Test: sp_crear_estadistica_visitantes - error cantidad negativa
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD');
EXEC parques.sp_crear_estadistica_visitantes @periodo = 'ERR', @periodo_inicio = '20260101', @periodo_fin = '20260131', @cantidad = -1, @id_region = @id_region;
-- Resultado Esperado: error que contenga 'cantidad'.
GO


-- Test: sp_crear_estadistica_visitantes - error region inexistente
EXEC parques.sp_crear_estadistica_visitantes @periodo = 'ERR', @periodo_inicio = '20260101', @periodo_fin = '20260131', @cantidad = 1, @id_region = -1;
-- Resultado Esperado: error que contenga 'ID de Region'.
GO


-- Test: sp_crear_estadistica_visitantes - alta feliz 1
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD');
EXEC parques.sp_crear_estadistica_visitantes @periodo = 'TEST_EST_1', @periodo_inicio = '20260101', @periodo_fin = '20260128', @cantidad = 100, @id_region = @id_region;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.EstadisticaVisitantes WHERE periodo = 'TEST_EST_1' AND cantidad = 100) THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_crear_estadistica_visitantes - alta feliz 2
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD');
EXEC parques.sp_crear_estadistica_visitantes @periodo = 'TEST_EST_2', @periodo_inicio = '20260201', @periodo_fin = '20260228', @cantidad = 200, @id_region = @id_region;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.EstadisticaVisitantes WHERE periodo = 'TEST_EST_2' AND cantidad = 200) THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_crear_estadistica_visitantes - alta feliz 3
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD');
EXEC parques.sp_crear_estadistica_visitantes @periodo = 'TEST_EST_3', @periodo_inicio = '20260301', @periodo_fin = '20260328', @cantidad = 300, @id_region = @id_region;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.EstadisticaVisitantes WHERE periodo = 'TEST_EST_3' AND cantidad = 300) THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_leer_estadistica_visitantes - lectura general
DECLARE @r TABLE (id INT, periodo VARCHAR(50), periodo_inicio DATETIME, periodo_fin DATETIME, cantidad INT, id_region INT);
INSERT INTO @r EXEC parques.sp_leer_estadistica_visitantes;
IF NOT EXISTS (SELECT 1 FROM @r WHERE periodo = 'TEST_EST_1')
    RAISERROR('La lectura general no devolvio estadisticas.', 16, 1);
-- Resultado Esperado: se ejecuta sin errores.
GO


-- Test: sp_leer_estadistica_visitantes - lectura por id 1
DECLARE @id INT = (SELECT id FROM parques.EstadisticaVisitantes WHERE periodo = 'TEST_EST_1');
DECLARE @r TABLE (id INT, periodo VARCHAR(50), periodo_inicio DATETIME, periodo_fin DATETIME, cantidad INT, id_region INT);
INSERT INTO @r EXEC parques.sp_leer_estadistica_visitantes @id = @id;
IF NOT EXISTS (SELECT 1 FROM @r WHERE id = @id AND periodo = 'TEST_EST_1')
    RAISERROR('La lectura por id no devolvio la estadistica esperada.', 16, 1);
-- Resultado Esperado: se ejecuta sin errores.
GO


-- Test: sp_leer_estadistica_visitantes - lectura por id 2
DECLARE @id INT = (SELECT id FROM parques.EstadisticaVisitantes WHERE periodo = 'TEST_EST_2');
DECLARE @r TABLE (id INT, periodo VARCHAR(50), periodo_inicio DATETIME, periodo_fin DATETIME, cantidad INT, id_region INT);
INSERT INTO @r EXEC parques.sp_leer_estadistica_visitantes @id = @id;
IF NOT EXISTS (SELECT 1 FROM @r WHERE id = @id AND periodo = 'TEST_EST_2')
    RAISERROR('La lectura por id no devolvio la estadistica esperada.', 16, 1);
-- Resultado Esperado: se ejecuta sin errores.
GO


-- Test: sp_modificar_estadistica_visitantes - error id inexistente
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD'); EXEC parques.sp_modificar_estadistica_visitantes @id = -1, @periodo = 'ERR', @periodo_inicio = '20260101', @periodo_fin = '20260131', @cantidad = 1, @id_region = @id_region;
-- Resultado Esperado: error que contenga 'EstadisticaVisitantes con el ID'.
GO


-- Test: sp_modificar_estadistica_visitantes - error periodo vacio
DECLARE @id INT = (SELECT id FROM parques.EstadisticaVisitantes WHERE periodo = 'TEST_EST_1'); DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD'); EXEC parques.sp_modificar_estadistica_visitantes @id = @id, @periodo = '', @periodo_inicio = '20260101', @periodo_fin = '20260131', @cantidad = 1, @id_region = @id_region;
-- Resultado Esperado: error que contenga 'periodo'.
GO


-- Test: sp_modificar_estadistica_visitantes - error inicio nulo
DECLARE @id INT = (SELECT id FROM parques.EstadisticaVisitantes WHERE periodo = 'TEST_EST_1'); DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD'); EXEC parques.sp_modificar_estadistica_visitantes @id = @id, @periodo = 'ERR', @periodo_inicio = NULL, @periodo_fin = '20260131', @cantidad = 1, @id_region = @id_region;
-- Resultado Esperado: error que contenga 'inicio'.
GO


-- Test: sp_modificar_estadistica_visitantes - error fin nulo
DECLARE @id INT = (SELECT id FROM parques.EstadisticaVisitantes WHERE periodo = 'TEST_EST_1'); DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD'); EXEC parques.sp_modificar_estadistica_visitantes @id = @id, @periodo = 'ERR', @periodo_inicio = '20260101', @periodo_fin = NULL, @cantidad = 1, @id_region = @id_region;
-- Resultado Esperado: error que contenga 'fin'.
GO


-- Test: sp_modificar_estadistica_visitantes - error fin anterior a inicio
DECLARE @id INT = (SELECT id FROM parques.EstadisticaVisitantes WHERE periodo = 'TEST_EST_1'); DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD'); EXEC parques.sp_modificar_estadistica_visitantes @id = @id, @periodo = 'ERR', @periodo_inicio = '20260131', @periodo_fin = '20260101', @cantidad = 1, @id_region = @id_region;
-- Resultado Esperado: error que contenga 'anterior'.
GO


-- Test: sp_modificar_estadistica_visitantes - error cantidad negativa
DECLARE @id INT = (SELECT id FROM parques.EstadisticaVisitantes WHERE periodo = 'TEST_EST_1'); DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD'); EXEC parques.sp_modificar_estadistica_visitantes @id = @id, @periodo = 'ERR', @periodo_inicio = '20260101', @periodo_fin = '20260131', @cantidad = -1, @id_region = @id_region;
-- Resultado Esperado: error que contenga 'cantidad'.
GO


-- Test: sp_modificar_estadistica_visitantes - error region inexistente
DECLARE @id INT = (SELECT id FROM parques.EstadisticaVisitantes WHERE periodo = 'TEST_EST_1'); EXEC parques.sp_modificar_estadistica_visitantes @id = @id, @periodo = 'ERR', @periodo_inicio = '20260101', @periodo_fin = '20260131', @cantidad = 1, @id_region = -1;
-- Resultado Esperado: error que contenga 'ID de Region'.
GO


-- Test: sp_modificar_estadistica_visitantes - modificacion feliz 1
DECLARE @id INT = (SELECT id FROM parques.EstadisticaVisitantes WHERE periodo = 'TEST_EST_1');
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_3_MOD');
EXEC parques.sp_modificar_estadistica_visitantes @id = @id, @periodo = 'TEST_EST_1_MOD', @periodo_inicio = '20261201', @periodo_fin = '20261231', @cantidad = 1000, @id_region = @id_region;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.EstadisticaVisitantes WHERE periodo = 'TEST_EST_1_MOD' AND cantidad = 1000) THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_modificar_estadistica_visitantes - modificacion feliz 2
DECLARE @id INT = (SELECT id FROM parques.EstadisticaVisitantes WHERE periodo = 'TEST_EST_2');
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_3_MOD');
EXEC parques.sp_modificar_estadistica_visitantes @id = @id, @periodo = 'TEST_EST_2_MOD', @periodo_inicio = '20261201', @periodo_fin = '20261231', @cantidad = 2000, @id_region = @id_region;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.EstadisticaVisitantes WHERE periodo = 'TEST_EST_2_MOD' AND cantidad = 2000) THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_modificar_estadistica_visitantes - modificacion feliz 3
DECLARE @id INT = (SELECT id FROM parques.EstadisticaVisitantes WHERE periodo = 'TEST_EST_3');
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_3_MOD');
EXEC parques.sp_modificar_estadistica_visitantes @id = @id, @periodo = 'TEST_EST_3_MOD', @periodo_inicio = '20261201', @periodo_fin = '20261231', @cantidad = 3000, @id_region = @id_region;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.EstadisticaVisitantes WHERE periodo = 'TEST_EST_3_MOD' AND cantidad = 3000) THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_estadistica_visitantes - error id inexistente
EXEC parques.sp_eliminar_estadistica_visitantes @id = -1;
-- Resultado Esperado: error que contenga 'EstadisticaVisitantes'.
GO


-- Test: sp_eliminar_estadistica_visitantes - baja feliz 1
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD');
EXEC parques.sp_crear_estadistica_visitantes @periodo = 'TEST_EST_DEL_1', @periodo_inicio = '20261101', @periodo_fin = '20261130', @cantidad = 1, @id_region = @id_region;
DECLARE @id INT = (SELECT id FROM parques.EstadisticaVisitantes WHERE periodo = 'TEST_EST_DEL_1');
EXEC parques.sp_eliminar_estadistica_visitantes @id = @id;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM parques.EstadisticaVisitantes WHERE periodo = 'TEST_EST_DEL_1') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_estadistica_visitantes - baja feliz 2
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD');
EXEC parques.sp_crear_estadistica_visitantes @periodo = 'TEST_EST_DEL_2', @periodo_inicio = '20261101', @periodo_fin = '20261130', @cantidad = 1, @id_region = @id_region;
DECLARE @id INT = (SELECT id FROM parques.EstadisticaVisitantes WHERE periodo = 'TEST_EST_DEL_2');
EXEC parques.sp_eliminar_estadistica_visitantes @id = @id;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM parques.EstadisticaVisitantes WHERE periodo = 'TEST_EST_DEL_2') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_estadistica_visitantes - baja feliz 3
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD');
EXEC parques.sp_crear_estadistica_visitantes @periodo = 'TEST_EST_DEL_3', @periodo_inicio = '20261101', @periodo_fin = '20261130', @cantidad = 1, @id_region = @id_region;
DECLARE @id INT = (SELECT id FROM parques.EstadisticaVisitantes WHERE periodo = 'TEST_EST_DEL_3');
EXEC parques.sp_eliminar_estadistica_visitantes @id = @id;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM parques.EstadisticaVisitantes WHERE periodo = 'TEST_EST_DEL_3') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO



------------------------------------------------------------
-- ProvinciaParque
------------------------------------------------------------

-- Test: sp_crear_provincia_parque - error provincia inexistente
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PARQUE_1_MOD');
EXEC parques.sp_crear_provincia_parque @id_provincia = -1, @id_parque = @id_parque, @direccion = 'x';
-- Resultado Esperado: error que contenga 'ID de Provincia'.
GO


-- Test: sp_crear_provincia_parque - error parque inexistente
DECLARE @id_prov INT = (SELECT id FROM parques.Provincia WHERE nombre = 'TEST_PROV_2_MOD');
EXEC parques.sp_crear_provincia_parque @id_provincia = @id_prov, @id_parque = -1, @direccion = 'x';
-- Resultado Esperado: error que contenga 'ID de Parque'.
GO


-- Test: sp_crear_provincia_parque - alta feliz 1
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD');
EXEC parques.sp_crear_provincia @nombre = 'TEST_PP_PROV_1', @id_region = @id_region;

DECLARE @id_tipo INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_1_MOD');
EXEC parques.sp_crear_parque @nombre = 'TEST_PP_PARQUE_1', @superficie_km2 = 1, @latitud = 0, @longitud = 0, @id_tipo_parque = @id_tipo;

DECLARE @id_prov INT = (SELECT id FROM parques.Provincia WHERE nombre = 'TEST_PP_PROV_1');
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PP_PARQUE_1');
EXEC parques.sp_crear_provincia_parque @id_provincia = @id_prov, @id_parque = @id_parque, @direccion = 'Direccion PP 1';
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.ProvinciaParque PP INNER JOIN parques.Provincia P ON P.id = PP.id_provincia INNER JOIN parques.Parque Pa ON Pa.id = PP.id_parque WHERE P.nombre = 'TEST_PP_PROV_1' AND Pa.nombre = 'TEST_PP_PARQUE_1') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_crear_provincia_parque - alta feliz 2
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD');
EXEC parques.sp_crear_provincia @nombre = 'TEST_PP_PROV_2', @id_region = @id_region;

DECLARE @id_tipo INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_1_MOD');
EXEC parques.sp_crear_parque @nombre = 'TEST_PP_PARQUE_2', @superficie_km2 = 1, @latitud = 0, @longitud = 0, @id_tipo_parque = @id_tipo;

DECLARE @id_prov INT = (SELECT id FROM parques.Provincia WHERE nombre = 'TEST_PP_PROV_2');
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PP_PARQUE_2');
EXEC parques.sp_crear_provincia_parque @id_provincia = @id_prov, @id_parque = @id_parque, @direccion = 'Direccion PP 2';
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.ProvinciaParque PP INNER JOIN parques.Provincia P ON P.id = PP.id_provincia INNER JOIN parques.Parque Pa ON Pa.id = PP.id_parque WHERE P.nombre = 'TEST_PP_PROV_2' AND Pa.nombre = 'TEST_PP_PARQUE_2') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_crear_provincia_parque - alta feliz 3
DECLARE @id_region INT = (SELECT id FROM parques.Region WHERE nombre = 'TEST_REGION_2_MOD');
EXEC parques.sp_crear_provincia @nombre = 'TEST_PP_PROV_3', @id_region = @id_region;

DECLARE @id_tipo INT = (SELECT id FROM parques.TipoParque WHERE descripcion = 'TEST_TIPO_PARQUE_1_MOD');
EXEC parques.sp_crear_parque @nombre = 'TEST_PP_PARQUE_3', @superficie_km2 = 1, @latitud = 0, @longitud = 0, @id_tipo_parque = @id_tipo;

DECLARE @id_prov INT = (SELECT id FROM parques.Provincia WHERE nombre = 'TEST_PP_PROV_3');
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PP_PARQUE_3');
EXEC parques.sp_crear_provincia_parque @id_provincia = @id_prov, @id_parque = @id_parque, @direccion = 'Direccion PP 3';
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.ProvinciaParque PP INNER JOIN parques.Provincia P ON P.id = PP.id_provincia INNER JOIN parques.Parque Pa ON Pa.id = PP.id_parque WHERE P.nombre = 'TEST_PP_PROV_3' AND Pa.nombre = 'TEST_PP_PARQUE_3') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_crear_provincia_parque - error relacion duplicada
DECLARE @id_prov INT = (SELECT id FROM parques.Provincia WHERE nombre = 'TEST_PP_PROV_1');
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PP_PARQUE_1');
EXEC parques.sp_crear_provincia_parque @id_provincia = @id_prov, @id_parque = @id_parque, @direccion = 'duplicada';
-- Resultado Esperado: error que contenga 'Ya existe'.
GO


-- Test: sp_leer_provincia_parque - lectura general
DECLARE @r TABLE (id_provincia INT, id_parque INT, direccion VARCHAR(255));
INSERT INTO @r EXEC parques.sp_leer_provincia_parque;
IF NOT EXISTS (
    SELECT 1 FROM @r R
    INNER JOIN parques.Provincia P ON P.id = R.id_provincia
    INNER JOIN parques.Parque Pa ON Pa.id = R.id_parque
    WHERE P.nombre = 'TEST_PP_PROV_1' AND Pa.nombre = 'TEST_PP_PARQUE_1'
)
    RAISERROR('La lectura general no devolvio relaciones ProvinciaParque.', 16, 1);
-- Resultado Esperado: se ejecuta sin errores.
GO


-- Test: sp_leer_provincia_parque - lectura por provincia
DECLARE @id_prov INT = (SELECT id FROM parques.Provincia WHERE nombre = 'TEST_PP_PROV_2');
DECLARE @r TABLE (id_provincia INT, id_parque INT, direccion VARCHAR(255));
INSERT INTO @r EXEC parques.sp_leer_provincia_parque @id_provincia = @id_prov;
IF NOT EXISTS (SELECT 1 FROM @r WHERE id_provincia = @id_prov)
    RAISERROR('La lectura por provincia no devolvio la relacion esperada.', 16, 1);
-- Resultado Esperado: se ejecuta sin errores.
GO


-- Test: sp_leer_provincia_parque - lectura por parque
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PP_PARQUE_3');
DECLARE @r TABLE (id_provincia INT, id_parque INT, direccion VARCHAR(255));
INSERT INTO @r EXEC parques.sp_leer_provincia_parque @id_parque = @id_parque;
IF NOT EXISTS (SELECT 1 FROM @r WHERE id_parque = @id_parque)
    RAISERROR('La lectura por parque no devolvio la relacion esperada.', 16, 1);
-- Resultado Esperado: se ejecuta sin errores.
GO


-- Test: sp_modificar_provincia_parque - error relacion inexistente
EXEC parques.sp_modificar_provincia_parque @id_provincia = -1, @id_parque = -1, @direccion = 'x';
-- Resultado Esperado: error que contenga 'ProvinciaParque'.
GO


-- Test: sp_modificar_provincia_parque - modificacion feliz 1
DECLARE @id_prov INT = (SELECT id FROM parques.Provincia WHERE nombre = 'TEST_PP_PROV_1');
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PP_PARQUE_1');
EXEC parques.sp_modificar_provincia_parque @id_provincia = @id_prov, @id_parque = @id_parque, @direccion = 'Direccion PP 1 MOD';
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.ProvinciaParque PP INNER JOIN parques.Provincia P ON P.id = PP.id_provincia INNER JOIN parques.Parque Pa ON Pa.id = PP.id_parque WHERE P.nombre = 'TEST_PP_PROV_1' AND Pa.nombre = 'TEST_PP_PARQUE_1' AND PP.direccion = 'Direccion PP 1 MOD') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_modificar_provincia_parque - modificacion feliz 2
DECLARE @id_prov INT = (SELECT id FROM parques.Provincia WHERE nombre = 'TEST_PP_PROV_2');
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PP_PARQUE_2');
EXEC parques.sp_modificar_provincia_parque @id_provincia = @id_prov, @id_parque = @id_parque, @direccion = 'Direccion PP 2 MOD';
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.ProvinciaParque PP INNER JOIN parques.Provincia P ON P.id = PP.id_provincia INNER JOIN parques.Parque Pa ON Pa.id = PP.id_parque WHERE P.nombre = 'TEST_PP_PROV_2' AND Pa.nombre = 'TEST_PP_PARQUE_2' AND PP.direccion = 'Direccion PP 2 MOD') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_modificar_provincia_parque - modificacion feliz 3
DECLARE @id_prov INT = (SELECT id FROM parques.Provincia WHERE nombre = 'TEST_PP_PROV_3');
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PP_PARQUE_3');
EXEC parques.sp_modificar_provincia_parque @id_provincia = @id_prov, @id_parque = @id_parque, @direccion = 'Direccion PP 3 MOD';
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.ProvinciaParque PP INNER JOIN parques.Provincia P ON P.id = PP.id_provincia INNER JOIN parques.Parque Pa ON Pa.id = PP.id_parque WHERE P.nombre = 'TEST_PP_PROV_3' AND Pa.nombre = 'TEST_PP_PARQUE_3' AND PP.direccion = 'Direccion PP 3 MOD') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_provincia_parque - error relacion inexistente
EXEC parques.sp_eliminar_provincia_parque @id_provincia = -1, @id_parque = -1;
-- Resultado Esperado: error que contenga 'ProvinciaParque'.
GO


-- Test: sp_eliminar_provincia_parque - baja feliz 1
DECLARE @id_prov INT = (SELECT id FROM parques.Provincia WHERE nombre = 'TEST_PP_PROV_1');
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PP_PARQUE_1');
EXEC parques.sp_eliminar_provincia_parque @id_provincia = @id_prov, @id_parque = @id_parque;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM parques.ProvinciaParque PP INNER JOIN parques.Provincia P ON P.id = PP.id_provincia INNER JOIN parques.Parque Pa ON Pa.id = PP.id_parque WHERE P.nombre = 'TEST_PP_PROV_1' AND Pa.nombre = 'TEST_PP_PARQUE_1') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_provincia_parque - baja feliz 2
DECLARE @id_prov INT = (SELECT id FROM parques.Provincia WHERE nombre = 'TEST_PP_PROV_2');
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PP_PARQUE_2');
EXEC parques.sp_eliminar_provincia_parque @id_provincia = @id_prov, @id_parque = @id_parque;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM parques.ProvinciaParque PP INNER JOIN parques.Provincia P ON P.id = PP.id_provincia INNER JOIN parques.Parque Pa ON Pa.id = PP.id_parque WHERE P.nombre = 'TEST_PP_PROV_2' AND Pa.nombre = 'TEST_PP_PARQUE_2') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_provincia_parque - baja feliz 3
DECLARE @id_prov INT = (SELECT id FROM parques.Provincia WHERE nombre = 'TEST_PP_PROV_3');
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PP_PARQUE_3');
EXEC parques.sp_eliminar_provincia_parque @id_provincia = @id_prov, @id_parque = @id_parque;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM parques.ProvinciaParque PP INNER JOIN parques.Provincia P ON P.id = PP.id_provincia INNER JOIN parques.Parque Pa ON Pa.id = PP.id_parque WHERE P.nombre = 'TEST_PP_PROV_3' AND Pa.nombre = 'TEST_PP_PARQUE_3') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO



------------------------------------------------------------
-- ParqueTipoVisitante
------------------------------------------------------------

-- Test: sp_crear_parque_tipo_visitante - error parque inexistente
DECLARE @id_tv INT = (SELECT TOP 1 id FROM parques.TipoVisitante WHERE nombre LIKE 'TEST_TV_%');
EXEC parques.sp_crear_parque_tipo_visitante @id_parque = -1, @id_tipo_visitante = @id_tv, @precio = 10;
-- Resultado Esperado: error que contenga 'ID de Parque'.
GO


-- Test: sp_crear_parque_tipo_visitante - error tipo visitante inexistente
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PP_PARQUE_1');
EXEC parques.sp_crear_parque_tipo_visitante @id_parque = @id_parque, @id_tipo_visitante = -1, @precio = 10;
-- Resultado Esperado: error que contenga 'ID de TipoVisitante'.
GO


-- Test: sp_crear_parque_tipo_visitante - error precio negativo
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PP_PARQUE_1');
DECLARE @id_tv INT = (SELECT TOP 1 id FROM parques.TipoVisitante WHERE nombre LIKE 'TEST_TV_%');
EXEC parques.sp_crear_parque_tipo_visitante @id_parque = @id_parque, @id_tipo_visitante = @id_tv, @precio = -1;
-- Resultado Esperado: error que contenga 'precio'.
GO


-- Test: sp_crear_parque_tipo_visitante - alta feliz 1
EXEC parques.sp_crear_tipo_visitante @nombre = 'TEST_PTV_TV_1', @descripcion = 'ptv';
DECLARE @id_tv INT = (SELECT id FROM parques.TipoVisitante WHERE nombre = 'TEST_PTV_TV_1');
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PP_PARQUE_1');
EXEC parques.sp_crear_parque_tipo_visitante @id_parque = @id_parque, @id_tipo_visitante = @id_tv, @precio = 10.50;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.ParqueTipoVisitante PTV INNER JOIN parques.TipoVisitante TV ON TV.id = PTV.id_tipo_visitante INNER JOIN parques.Parque P ON P.id = PTV.id_parque WHERE TV.nombre = 'TEST_PTV_TV_1' AND P.nombre = 'TEST_PP_PARQUE_1') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_crear_parque_tipo_visitante - alta feliz 2
EXEC parques.sp_crear_tipo_visitante @nombre = 'TEST_PTV_TV_2', @descripcion = 'ptv';
DECLARE @id_tv INT = (SELECT id FROM parques.TipoVisitante WHERE nombre = 'TEST_PTV_TV_2');
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PP_PARQUE_2');
EXEC parques.sp_crear_parque_tipo_visitante @id_parque = @id_parque, @id_tipo_visitante = @id_tv, @precio = 20.50;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.ParqueTipoVisitante PTV INNER JOIN parques.TipoVisitante TV ON TV.id = PTV.id_tipo_visitante INNER JOIN parques.Parque P ON P.id = PTV.id_parque WHERE TV.nombre = 'TEST_PTV_TV_2' AND P.nombre = 'TEST_PP_PARQUE_2') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_crear_parque_tipo_visitante - alta feliz 3
EXEC parques.sp_crear_tipo_visitante @nombre = 'TEST_PTV_TV_3', @descripcion = 'ptv';
DECLARE @id_tv INT = (SELECT id FROM parques.TipoVisitante WHERE nombre = 'TEST_PTV_TV_3');
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PP_PARQUE_3');
EXEC parques.sp_crear_parque_tipo_visitante @id_parque = @id_parque, @id_tipo_visitante = @id_tv, @precio = 30.50;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.ParqueTipoVisitante PTV INNER JOIN parques.TipoVisitante TV ON TV.id = PTV.id_tipo_visitante INNER JOIN parques.Parque P ON P.id = PTV.id_parque WHERE TV.nombre = 'TEST_PTV_TV_3' AND P.nombre = 'TEST_PP_PARQUE_3') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_crear_parque_tipo_visitante - error relacion duplicada
DECLARE @id_tv INT = (SELECT id FROM parques.TipoVisitante WHERE nombre = 'TEST_PTV_TV_1');
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PP_PARQUE_1');
EXEC parques.sp_crear_parque_tipo_visitante @id_parque = @id_parque, @id_tipo_visitante = @id_tv, @precio = 99;
-- Resultado Esperado: error que contenga 'Ya existe'.
GO


-- Test: sp_leer_parque_tipo_visitante - lectura general
DECLARE @r TABLE (id_parque INT, id_tipo_visitante INT, precio DECIMAL(10,2));
INSERT INTO @r EXEC parques.sp_leer_parque_tipo_visitante;
IF NOT EXISTS (
    SELECT 1 FROM @r R
    INNER JOIN parques.Parque P ON P.id = R.id_parque
    INNER JOIN parques.TipoVisitante TV ON TV.id = R.id_tipo_visitante
    WHERE P.nombre = 'TEST_PP_PARQUE_1' AND TV.nombre = 'TEST_PTV_TV_1'
)
    RAISERROR('La lectura general no devolvio relaciones ParqueTipoVisitante.', 16, 1);
-- Resultado Esperado: se ejecuta sin errores.
GO


-- Test: sp_leer_parque_tipo_visitante - lectura por parque
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PP_PARQUE_2');
DECLARE @r TABLE (id_parque INT, id_tipo_visitante INT, precio DECIMAL(10,2));
INSERT INTO @r EXEC parques.sp_leer_parque_tipo_visitante @id_parque = @id_parque;
IF NOT EXISTS (SELECT 1 FROM @r WHERE id_parque = @id_parque)
    RAISERROR('La lectura por parque no devolvio la relacion esperada.', 16, 1);
-- Resultado Esperado: se ejecuta sin errores.
GO


-- Test: sp_leer_parque_tipo_visitante - lectura por tipo visitante
DECLARE @id_tv INT = (SELECT id FROM parques.TipoVisitante WHERE nombre = 'TEST_PTV_TV_3');
DECLARE @r TABLE (id_parque INT, id_tipo_visitante INT, precio DECIMAL(10,2));
INSERT INTO @r EXEC parques.sp_leer_parque_tipo_visitante @id_tipo_visitante = @id_tv;
IF NOT EXISTS (SELECT 1 FROM @r WHERE id_tipo_visitante = @id_tv)
    RAISERROR('La lectura por tipo visitante no devolvio la relacion esperada.', 16, 1);
-- Resultado Esperado: se ejecuta sin errores.
GO


-- Test: sp_modificar_parque_tipo_visitante - error relacion inexistente
EXEC parques.sp_modificar_parque_tipo_visitante @id_parque = -1, @id_tipo_visitante = -1, @precio = 1;
-- Resultado Esperado: error que contenga 'ParqueTipoVisitante'.
GO


-- Test: sp_modificar_parque_tipo_visitante - error precio negativo
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PP_PARQUE_1');
DECLARE @id_tv INT = (SELECT id FROM parques.TipoVisitante WHERE nombre = 'TEST_PTV_TV_1');
EXEC parques.sp_modificar_parque_tipo_visitante @id_parque = @id_parque, @id_tipo_visitante = @id_tv, @precio = -1;
-- Resultado Esperado: error que contenga 'precio'.
GO


-- Test: sp_modificar_parque_tipo_visitante - modificacion feliz 1
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PP_PARQUE_1');
DECLARE @id_tv INT = (SELECT id FROM parques.TipoVisitante WHERE nombre = 'TEST_PTV_TV_1');
EXEC parques.sp_modificar_parque_tipo_visitante @id_parque = @id_parque, @id_tipo_visitante = @id_tv, @precio = 100.75;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.ParqueTipoVisitante PTV INNER JOIN parques.TipoVisitante TV ON TV.id = PTV.id_tipo_visitante INNER JOIN parques.Parque P ON P.id = PTV.id_parque WHERE TV.nombre = 'TEST_PTV_TV_1' AND P.nombre = 'TEST_PP_PARQUE_1' AND PTV.precio = 100.75) THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_modificar_parque_tipo_visitante - modificacion feliz 2
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PP_PARQUE_2');
DECLARE @id_tv INT = (SELECT id FROM parques.TipoVisitante WHERE nombre = 'TEST_PTV_TV_2');
EXEC parques.sp_modificar_parque_tipo_visitante @id_parque = @id_parque, @id_tipo_visitante = @id_tv, @precio = 200.75;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.ParqueTipoVisitante PTV INNER JOIN parques.TipoVisitante TV ON TV.id = PTV.id_tipo_visitante INNER JOIN parques.Parque P ON P.id = PTV.id_parque WHERE TV.nombre = 'TEST_PTV_TV_2' AND P.nombre = 'TEST_PP_PARQUE_2' AND PTV.precio = 200.75) THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_modificar_parque_tipo_visitante - modificacion feliz 3
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PP_PARQUE_3');
DECLARE @id_tv INT = (SELECT id FROM parques.TipoVisitante WHERE nombre = 'TEST_PTV_TV_3');
EXEC parques.sp_modificar_parque_tipo_visitante @id_parque = @id_parque, @id_tipo_visitante = @id_tv, @precio = 300.75;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN EXISTS (SELECT 1 FROM parques.ParqueTipoVisitante PTV INNER JOIN parques.TipoVisitante TV ON TV.id = PTV.id_tipo_visitante INNER JOIN parques.Parque P ON P.id = PTV.id_parque WHERE TV.nombre = 'TEST_PTV_TV_3' AND P.nombre = 'TEST_PP_PARQUE_3' AND PTV.precio = 300.75) THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_parque_tipo_visitante - error relacion inexistente
EXEC parques.sp_eliminar_parque_tipo_visitante @id_parque = -1, @id_tipo_visitante = -1;
-- Resultado Esperado: error que contenga 'ParqueTipoVisitante'.
GO


-- Test: sp_eliminar_parque_tipo_visitante - baja feliz 1
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PP_PARQUE_1');
DECLARE @id_tv INT = (SELECT id FROM parques.TipoVisitante WHERE nombre = 'TEST_PTV_TV_1');
EXEC parques.sp_eliminar_parque_tipo_visitante @id_parque = @id_parque, @id_tipo_visitante = @id_tv;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM parques.ParqueTipoVisitante PTV INNER JOIN parques.TipoVisitante TV ON TV.id = PTV.id_tipo_visitante INNER JOIN parques.Parque P ON P.id = PTV.id_parque WHERE TV.nombre = 'TEST_PTV_TV_1' AND P.nombre = 'TEST_PP_PARQUE_1') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_parque_tipo_visitante - baja feliz 2
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PP_PARQUE_2');
DECLARE @id_tv INT = (SELECT id FROM parques.TipoVisitante WHERE nombre = 'TEST_PTV_TV_2');
EXEC parques.sp_eliminar_parque_tipo_visitante @id_parque = @id_parque, @id_tipo_visitante = @id_tv;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM parques.ParqueTipoVisitante PTV INNER JOIN parques.TipoVisitante TV ON TV.id = PTV.id_tipo_visitante INNER JOIN parques.Parque P ON P.id = PTV.id_parque WHERE TV.nombre = 'TEST_PTV_TV_2' AND P.nombre = 'TEST_PP_PARQUE_2') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO


-- Test: sp_eliminar_parque_tipo_visitante - baja feliz 3
DECLARE @id_parque INT = (SELECT id FROM parques.Parque WHERE nombre = 'TEST_PP_PARQUE_3');
DECLARE @id_tv INT = (SELECT id FROM parques.TipoVisitante WHERE nombre = 'TEST_PTV_TV_3');
EXEC parques.sp_eliminar_parque_tipo_visitante @id_parque = @id_parque, @id_tipo_visitante = @id_tv;
-- Resultado Esperado: se ejecuta sin errores.
-- Para verificar:
SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM parques.ParqueTipoVisitante PTV INNER JOIN parques.TipoVisitante TV ON TV.id = PTV.id_tipo_visitante INNER JOIN parques.Parque P ON P.id = PTV.id_parque WHERE TV.nombre = 'TEST_PTV_TV_3' AND P.nombre = 'TEST_PP_PARQUE_3') THEN 1 ELSE 0 END;
-- Resultado Esperado de la validacion: 1.
GO



------------------------------------------------------------
-- Inspeccion final opcional
------------------------------------------------------------

SELECT * FROM parques.Region ORDER BY id;
SELECT * FROM parques.Provincia ORDER BY id;
SELECT * FROM parques.TipoVisitante ORDER BY id;
SELECT * FROM parques.TipoParque ORDER BY id;
SELECT * FROM parques.Parque ORDER BY id;
SELECT * FROM parques.EstadisticaVisitantes ORDER BY id;
SELECT * FROM parques.ProvinciaParque ORDER BY id_provincia, id_parque;
SELECT * FROM parques.ParqueTipoVisitante ORDER BY id_parque, id_tipo_visitante;
-- Resultado Esperado: permite revisar el estado final de las tablas luego de los tests.
GO