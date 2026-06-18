/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: Generación e inserción de datos para el módulo de empleados.
*/

USE LinuxPreachers;
GO

-----------------------------------
-- 1. TipoDocumento
-----------------------------------

BEGIN TRANSACTION;

BEGIN TRY
	EXEC empleados.sp_crear_tipo_documento @nombre = 'DNI';
	EXEC empleados.sp_crear_tipo_documento @nombre = 'LC';
	EXEC empleados.sp_crear_tipo_documento @nombre = 'LE';

	COMMIT TRANSACTION;

	SELECT * FROM empleados.TipoDocumento;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
END CATCH;
GO

-----------------------------------
-- 2. Especialidad
-----------------------------------

BEGIN TRANSACTION;

BEGIN TRY

	EXEC empleados.sp_crear_especialidad
		@nombre = 'GUIA DE TURISMO',
		@descripcion = 'Acompaña, informa y asiste visitantes en recorridos turísticos de baja dificultad en áreas habilitadas.';

	EXEC empleados.sp_crear_especialidad
		@nombre = 'GUIA DE TREKKING',
		@descripcion = 'Conduce excursiones de trekking por senderos autorizados de hasta grado II de dificultad.';

	EXEC empleados.sp_crear_especialidad
		@nombre = 'GUIA DE TREKKING EN SIERRA',
		@descripcion = 'Guía excursiones de trekking en terrenos de sierra, bajo 3000 msnm y sin terreno nevado.';

	EXEC empleados.sp_crear_especialidad
		@nombre = 'GUIA DE TREKKING EN CORDILLERA',
		@descripcion = 'Guía excursiones de trekking en ambientes cordilleranos por senderos autorizados.';

	EXEC empleados.sp_crear_especialidad
		@nombre = 'GUIA DE MONTAÑA',
		@descripcion = 'Conduce actividades de montaña en terrenos de mayor complejidad técnica y ambiental.';

	EXEC empleados.sp_crear_especialidad
		@nombre = 'GUIA DE ESQUI DE MONTAÑA',
		@descripcion = 'Guía actividades de travesía y progresión en montaña utilizando esquí como medio principal.';

	EXEC empleados.sp_crear_especialidad
		@nombre = 'GUIA DE ALTA MONTAÑA',
		@descripcion = 'Conduce ascensiones y actividades en alta montaña que requieren conocimientos técnicos avanzados.';

	EXEC empleados.sp_crear_especialidad
		@nombre = 'GUIA DE CABALGATAS Y/O ACTIVIDADES ECUESTRES',
		@descripcion = 'Guía excursiones y actividades turísticas realizadas a caballo o mediante medios ecuestres.';

	EXEC empleados.sp_crear_especialidad
		@nombre = 'GUIA DE ACTIVIDADES EN BICICLETA',
		@descripcion = 'Conduce recorridos y excursiones turísticas en bicicleta por circuitos habilitados.';

	EXEC empleados.sp_crear_especialidad
		@nombre = 'GUIA DE OBSERVACION DE FLORA Y FAUNA',
		@descripcion = 'Interpreta y guía actividades orientadas a la observación del patrimonio natural y biodiversidad.';

	EXEC empleados.sp_crear_especialidad
		@nombre = 'GUIA DE CAZA DEPORTIVA',
		@descripcion = 'Guía actividades de caza deportiva en áreas habilitadas y conforme a la normativa vigente.';

	EXEC empleados.sp_crear_especialidad
		@nombre = 'GUIA DE PESCA',
		@descripcion = 'Conduce actividades de pesca recreativa y deportiva en ambientes autorizados.';

	EXEC empleados.sp_crear_especialidad
		@nombre = 'GUIA DE RAFTING',
		@descripcion = 'Guía descensos en embarcaciones neumáticas por ríos de aguas rápidas y entornos fluviales.';

	EXEC empleados.sp_crear_especialidad
		@nombre = 'GUIA DE KAYAK DE TRAVESIA',
		@descripcion = 'Conduce travesías en kayak por ambientes acuáticos habilitados.';

	EXEC empleados.sp_crear_especialidad
		@nombre = 'GUIA DE CANOA',
		@descripcion = 'Guía excursiones recreativas y turísticas en canoa en cuerpos de agua autorizados.';

	EXEC empleados.sp_crear_especialidad
		@nombre = 'GUIA DE BOTE A REMO',
		@descripcion = 'Conduce actividades y recorridos turísticos utilizando embarcaciones impulsadas a remo.';

	EXEC empleados.sp_crear_especialidad
		@nombre = 'GUIA DE SITIO LOCAL',
		@descripcion = 'Acompaña e interpreta contenidos culturales, históricos o naturales de un sitio específico.';

	EXEC empleados.sp_crear_especialidad
		@nombre = 'GUIA DE SITIO DE TURISMO SUPLEMENTARIO',
		@descripcion = 'Brinda asistencia e interpretación en actividades turísticas complementarias de un sitio.';

	EXEC empleados.sp_crear_especialidad
		@nombre = 'GUIA DE TURISMO LOCAL',
		@descripcion = 'Guía de turismo habilitado para ejercer dentro de una jurisdicción específica, con conocimientos especializados sobre sus atractivos, historia y patrimonio.'

	COMMIT TRANSACTION;
	
	SELECT * FROM empleados.Especialidad;

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
END CATCH;
GO