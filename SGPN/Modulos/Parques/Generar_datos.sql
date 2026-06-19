
/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: Generación e inserción de datos para el módulo de parques.
*/

USE LinuxPreachers;
GO

-------------------------------------
-- Tipos de parque
-------------------------------------

BEGIN TRANSACTION;

BEGIN TRY
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Área de Conservación';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Área Marina Protegida';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Área Natural Protegida';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Estación Biológica';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Estancia';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Monumento Natural';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Monumento Provincial';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Paisaje Protegido';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Parque Escolar Rural';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Parque Interjurisdiccional';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Parque Marino Provincial';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Parque Municipal';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Parque Nacional';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Parque Natural Municipal';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Parque Natural Provincial';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Parque Provincial';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Parque Regional, Forestal y Botánico';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Refugio de Vida Silvestre';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Refugio Educativo';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Refugio Privado de Vida Silvestre';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Reserva Botánica';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Reserva Cultural Natural';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Reserva de Biosfera';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Reserva de Fauna y Flora';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Reserva de Recurso';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Reserva de Recursos';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Reserva de Uso Múltiple';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Reserva de Vicuñas y Protección de Ecosistemas';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Reserva Ecológica';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Reserva Forestal';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Reserva Hídrica';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Reserva Micológica';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Reserva Municipal';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Reserva Natural';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Reserva Paisajística';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Reserva Privada';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Reserva Provincial';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Reserva Total';
    EXEC parques.sp_crear_tipo_parque @descripcion = 'Sitio Ramsar';
    COMMIT TRANSACTION;
    PRINT 'Transacción completada: Todos los tipos de parque fueron insertados correctamente.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
END CATCH;
GO

SELECT * FROM parques.TipoParque;
GO

-------------------------------------
-- Provincias y regiones
-------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE @id_region_1 INT;
    DECLARE @id_region_2 INT;
    DECLARE @id_region_3 INT;
    DECLARE @id_region_4 INT;
    DECLARE @id_region_5 INT;
    DECLARE @id_region_6 INT;

    -- Insertar Regiones utilizando el SP parques.sp_crear_region
    EXEC parques.sp_crear_region @nombre = 'Región Centro';
    SELECT @id_region_1 = id FROM parques.Region WHERE nombre = 'Región Centro';

    EXEC parques.sp_crear_region @nombre = 'Región Centro Este';
    SELECT @id_region_2 = id FROM parques.Region WHERE nombre = 'Región Centro Este';

    EXEC parques.sp_crear_region @nombre = 'Región Noreste';
    SELECT @id_region_3 = id FROM parques.Region WHERE nombre = 'Región Noreste';

    EXEC parques.sp_crear_region @nombre = 'Región Noroeste';
    SELECT @id_region_4 = id FROM parques.Region WHERE nombre = 'Región Noroeste';

    EXEC parques.sp_crear_region @nombre = 'Región Patagonia Austral';
    SELECT @id_region_5 = id FROM parques.Region WHERE nombre = 'Región Patagonia Austral';

    EXEC parques.sp_crear_region @nombre = 'Región Patagonia Norte';
    SELECT @id_region_6 = id FROM parques.Region WHERE nombre = 'Región Patagonia Norte';

    -- Insertar Provincias utilizando el SP parques.sp_crear_provincia
    EXEC parques.sp_crear_provincia @nombre = 'Buenos Aires', @id_region = @id_region_2;
    EXEC parques.sp_crear_provincia @nombre = 'Capital Federal', @id_region = @id_region_2;
    EXEC parques.sp_crear_provincia @nombre = 'Catamarca', @id_region = @id_region_4;
    EXEC parques.sp_crear_provincia @nombre = 'Chaco', @id_region = @id_region_3;
    EXEC parques.sp_crear_provincia @nombre = 'Chubut', @id_region = @id_region_6;
    EXEC parques.sp_crear_provincia @nombre = 'Cordoba', @id_region = @id_region_1;
    EXEC parques.sp_crear_provincia @nombre = 'Corrientes', @id_region = @id_region_3;
    EXEC parques.sp_crear_provincia @nombre = 'Entre Rios', @id_region = @id_region_2;
    EXEC parques.sp_crear_provincia @nombre = 'Formosa', @id_region = @id_region_3;
    EXEC parques.sp_crear_provincia @nombre = 'Jujuy', @id_region = @id_region_4;
    EXEC parques.sp_crear_provincia @nombre = 'La Pampa', @id_region = @id_region_6;
    EXEC parques.sp_crear_provincia @nombre = 'La Rioja', @id_region = @id_region_1;
    EXEC parques.sp_crear_provincia @nombre = 'Mendoza', @id_region = @id_region_1;
    EXEC parques.sp_crear_provincia @nombre = 'Misiones', @id_region = @id_region_3;
    EXEC parques.sp_crear_provincia @nombre = 'Neuquen', @id_region = @id_region_6;
    EXEC parques.sp_crear_provincia @nombre = 'Rio Negro', @id_region = @id_region_6;
    EXEC parques.sp_crear_provincia @nombre = 'Salta', @id_region = @id_region_4;
    EXEC parques.sp_crear_provincia @nombre = 'San Juan', @id_region = @id_region_1;
    EXEC parques.sp_crear_provincia @nombre = 'San Luis', @id_region = @id_region_1;
    EXEC parques.sp_crear_provincia @nombre = 'Santa Cruz', @id_region = @id_region_5;
    EXEC parques.sp_crear_provincia @nombre = 'Santa Fe', @id_region = @id_region_3;
    EXEC parques.sp_crear_provincia @nombre = 'Santiago Del Estero', @id_region = @id_region_4;
    EXEC parques.sp_crear_provincia @nombre = 'Tierra Del Fuego', @id_region = @id_region_5;
    EXEC parques.sp_crear_provincia @nombre = 'Tucuman', @id_region = @id_region_4;

    COMMIT TRANSACTION;
    PRINT 'Transacción completada: Regiones y Provincias insertadas correctamente.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
END CATCH;
GO

SELECT * FROM parques.Provincia
SELECT * FROM parques.Region
GO

-------------------------------------
-- Parques (ficticios)
-------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE
        @id_area_conservacion INT,
        @id_parque_nacional INT,
        @id_parque_provincial INT,
        @id_parque_natural_provincial INT,
        @id_parque_interjurisdiccional INT,
        @id_paisaje_protegido INT,
        @id_refugio_vida_silvestre INT,
        @id_reserva_biosfera INT,
        @id_reserva_ecologica INT,
        @id_reserva_natural INT;

    SELECT @id_area_conservacion = id
    FROM parques.TipoParque
    WHERE descripcion = 'Área de Conservación';

    SELECT @id_parque_nacional = id
    FROM parques.TipoParque
    WHERE descripcion = 'Parque Nacional';

    SELECT @id_parque_provincial = id
    FROM parques.TipoParque
    WHERE descripcion = 'Parque Provincial';

    SELECT @id_parque_natural_provincial = id
    FROM parques.TipoParque
    WHERE descripcion = 'Parque Natural Provincial';

    SELECT @id_parque_interjurisdiccional = id
    FROM parques.TipoParque
    WHERE descripcion = 'Parque Interjurisdiccional';

    SELECT @id_paisaje_protegido = id
    FROM parques.TipoParque
    WHERE descripcion = 'Paisaje Protegido';

    SELECT @id_refugio_vida_silvestre = id
    FROM parques.TipoParque
    WHERE descripcion = 'Refugio de Vida Silvestre';

    SELECT @id_reserva_biosfera = id
    FROM parques.TipoParque
    WHERE descripcion = 'Reserva de Biosfera';

    SELECT @id_reserva_ecologica = id
    FROM parques.TipoParque
    WHERE descripcion = 'Reserva Ecológica';

    SELECT @id_reserva_natural = id
    FROM parques.TipoParque
    WHERE descripcion = 'Reserva Natural';

    EXEC parques.sp_crear_parque
        @nombre = 'Parque Nacional Valle del Cristal',
        @superficie_km2 = 742.80,
        @latitud = -26.458300,
        @longitud = -66.128500,
        @id_tipo_parque = @id_parque_nacional;

    EXEC parques.sp_crear_parque
        @nombre = 'Reserva Natural Arroyo Esmeralda',
        @superficie_km2 = 118.45,
        @latitud = -27.912600,
        @longitud = -55.643700,
        @id_tipo_parque = @id_reserva_natural;

    EXEC parques.sp_crear_parque
        @nombre = 'Parque Provincial Sierra del Cóndor',
        @superficie_km2 = 956.30,
        @latitud = -32.775200,
        @longitud = -66.184900,
        @id_tipo_parque = @id_parque_provincial;

    EXEC parques.sp_crear_parque
        @nombre = 'Reserva Ecológica Laguna del Alba',
        @superficie_km2 = 83.20,
        @latitud = -31.482100,
        @longitud = -60.413800,
        @id_tipo_parque = @id_reserva_ecologica;

    EXEC parques.sp_crear_parque
        @nombre = 'Refugio de Vida Silvestre Monte Dorado',
        @superficie_km2 = 265.70,
        @latitud = -24.891600,
        @longitud = -64.527400,
        @id_tipo_parque = @id_refugio_vida_silvestre;

    EXEC parques.sp_crear_parque
        @nombre = 'Parque Interjurisdiccional Bahía del Viento',
        @superficie_km2 = 1485.60,
        @latitud = -46.983200,
        @longitud = -67.915700,
        @id_tipo_parque = @id_parque_interjurisdiccional;

    EXEC parques.sp_crear_parque
        @nombre = 'Paisaje Protegido Quebrada Azul',
        @superficie_km2 = 321.40,
        @latitud = -28.774100,
        @longitud = -67.583300,
        @id_tipo_parque = @id_paisaje_protegido;

    EXEC parques.sp_crear_parque
        @nombre = 'Reserva de Biosfera Bosques del Horizonte',
        @superficie_km2 = 2147.90,
        @latitud = -39.118500,
        @longitud = -70.284600,
        @id_tipo_parque = @id_reserva_biosfera;

    EXEC parques.sp_crear_parque
        @nombre = 'Área de Conservación Esteros del Amanecer',
        @superficie_km2 = 412.80,
        @latitud = -27.364900,
        @longitud = -58.912400,
        @id_tipo_parque = @id_area_conservacion;

    EXEC parques.sp_crear_parque
        @nombre = 'Parque Natural Provincial Cerro del Viento',
        @superficie_km2 = 689.10,
        @latitud = -43.256800,
        @longitud = -71.108300,
        @id_tipo_parque = @id_parque_natural_provincial;

    COMMIT TRANSACTION;
    
    SELECT * FROM parques.Parque;

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH;
GO

-------------------------------------
-- Tipos de visitante
-------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    EXEC parques.sp_crear_tipo_visitante
        @nombre = 'Residente',
        @descripcion = 'Visitante con residencia dentro de la provincia o jurisdicción correspondiente.';

    EXEC parques.sp_crear_tipo_visitante
        @nombre = 'No residente',
        @descripcion = 'Visitante sin residencia dentro de la provincia o jurisdicción correspondiente.';

    EXEC parques.sp_crear_tipo_visitante
        @nombre = 'Jubilado',
        @descripcion = 'Persona jubilada que puede acceder a beneficios o tarifas diferenciales.';

    EXEC parques.sp_crear_tipo_visitante
        @nombre = 'Niño',
        @descripcion = 'Menor de edad comprendido dentro del rango etario definido por el parque.';

    EXEC parques.sp_crear_tipo_visitante
        @nombre = 'Estudiante',
        @descripcion = 'Estudiante que acredita su condición mediante documentación vigente.';

    EXEC parques.sp_crear_tipo_visitante
        @nombre = 'Veterano de Malvinas',
        @descripcion = 'Excombatiente de la Guerra de Malvinas con acreditación correspondiente.';

    EXEC parques.sp_crear_tipo_visitante
        @nombre = 'Persona con discapacidad',
        @descripcion = 'Visitante que acredita una discapacidad mediante certificado vigente.';

    COMMIT TRANSACTION;
    
    SELECT * FROM parques.TipoVisitante

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH;
GO

--------------------------------------------------------------------------
-- Tipos de visitante en parques (precios, pero solo de 2 parques)
--------------------------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY

    DECLARE
        @id_parque_valle_cristal INT,
        @id_parque_arroyo_esmeralda INT,
        @id_residente INT,
        @id_no_residente INT,
        @id_jubilado INT,
        @id_nino INT,
        @id_estudiante INT,
        @id_veterano INT,
        @id_discapacidad INT;

    SELECT @id_parque_valle_cristal = id
    FROM parques.Parque
    WHERE nombre = 'Parque Nacional Valle del Cristal';

    SELECT @id_parque_arroyo_esmeralda = id
    FROM parques.Parque
    WHERE nombre = 'Reserva Natural Arroyo Esmeralda';

    SELECT @id_residente = id
    FROM parques.TipoVisitante
    WHERE nombre = 'Residente';

    SELECT @id_no_residente = id
    FROM parques.TipoVisitante
    WHERE nombre = 'No residente';

    SELECT @id_jubilado = id
    FROM parques.TipoVisitante
    WHERE nombre = 'Jubilado';

    SELECT @id_nino = id
    FROM parques.TipoVisitante
    WHERE nombre = 'Niño';

    SELECT @id_estudiante = id
    FROM parques.TipoVisitante
    WHERE nombre = 'Estudiante';

    SELECT @id_veterano = id
    FROM parques.TipoVisitante
    WHERE nombre = 'Veterano de Malvinas';

    SELECT @id_discapacidad = id
    FROM parques.TipoVisitante
    WHERE nombre = 'Persona con discapacidad';

    -- Parque Nacional Valle del Cristal
    EXEC parques.sp_crear_parque_tipo_visitante @id_parque_valle_cristal, @id_residente,    12000.00;
    EXEC parques.sp_crear_parque_tipo_visitante @id_parque_valle_cristal, @id_no_residente, 18000.00;
    EXEC parques.sp_crear_parque_tipo_visitante @id_parque_valle_cristal, @id_jubilado,      6000.00;
    EXEC parques.sp_crear_parque_tipo_visitante @id_parque_valle_cristal, @id_nino,          5000.00;
    EXEC parques.sp_crear_parque_tipo_visitante @id_parque_valle_cristal, @id_estudiante,    8000.00;
    EXEC parques.sp_crear_parque_tipo_visitante @id_parque_valle_cristal, @id_veterano,         0.00;
    EXEC parques.sp_crear_parque_tipo_visitante @id_parque_valle_cristal, @id_discapacidad,     0.00;

    -- Reserva Natural Arroyo Esmeralda
    EXEC parques.sp_crear_parque_tipo_visitante @id_parque_arroyo_esmeralda, @id_residente,    7000.00;
    EXEC parques.sp_crear_parque_tipo_visitante @id_parque_arroyo_esmeralda, @id_no_residente, 10000.00;
    EXEC parques.sp_crear_parque_tipo_visitante @id_parque_arroyo_esmeralda, @id_jubilado,      3500.00;
    EXEC parques.sp_crear_parque_tipo_visitante @id_parque_arroyo_esmeralda, @id_nino,          3000.00;
    EXEC parques.sp_crear_parque_tipo_visitante @id_parque_arroyo_esmeralda, @id_estudiante,    4500.00;
    EXEC parques.sp_crear_parque_tipo_visitante @id_parque_arroyo_esmeralda, @id_veterano,         0.00;
    EXEC parques.sp_crear_parque_tipo_visitante @id_parque_arroyo_esmeralda, @id_discapacidad,     0.00;

    COMMIT TRANSACTION;
    PRINT 'Precios de tipos de visitante creados correctamente.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO