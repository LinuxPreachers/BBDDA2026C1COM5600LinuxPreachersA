
/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: insertar los tipos de áreas protegidas (parques) y provincias
*/

USE LinuxPreachers;
GO

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

SELECT * FROM parques.TipoParque
------------------------------- Provincias y regiones-------------


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