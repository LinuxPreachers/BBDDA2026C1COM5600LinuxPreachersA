/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: Creación de tablas módulo reservas
*/

USE LinuxPreachers;
GO

-- Schema
IF NOT EXISTS ( SELECT 1 FROM sys.schemas WHERE name = 'reservas' )
BEGIN 
    EXEC('CREATE SCHEMA reservas'); 
END; 
GO

-- Este SP Asume que no existe ninguna tabla
CREATE OR ALTER PROCEDURE reservas.sp_crear_tablas_modulo_reservas
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE reservas.Reserva (
        id INT IDENTITY(1,1) NOT NULL,
        fecha_y_hora DATETIME NOT NULL DEFAULT GETDATE(),

        CONSTRAINT PK_Reserva PRIMARY KEY (id)
    );

    CREATE TABLE reservas.EstadoItem (
        id INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(10) NOT NULL,
        descripcion VARCHAR(255) NULL,

        CONSTRAINT PK_EstadoItem PRIMARY KEY (id),
        CONSTRAINT UQ_EstadoItem_Nombre UNIQUE (nombre)
    );

    CREATE TABLE reservas.ItemReserva (
        id INT IDENTITY(1,1) NOT NULL,
        precio DECIMAL(10,2) NOT NULL,
        id_estado INT NOT NULL,
        id_reserva INT NOT NULL,

        CONSTRAINT PK_ItemReserva PRIMARY KEY (id),

        CONSTRAINT FK_ItemReserva_Estado
            FOREIGN KEY (id_estado)
            REFERENCES reservas.EstadoItem(id),

        CONSTRAINT FK_ItemReserva_Reserva
            FOREIGN KEY (id_reserva)
            REFERENCES reservas.Reserva(id),

        CONSTRAINT CK_ItemReserva_Precio CHECK (precio >= 0)
    );

    CREATE TABLE reservas.Reembolso (
        id INT IDENTITY(1,1) NOT NULL,
        fecha_y_hora DATETIME NOT NULL DEFAULT GETDATE(),

        cvu_cuenta_destino CHAR(22) NOT NULL,

        CONSTRAINT PK_Reembolso PRIMARY KEY (id),

        CONSTRAINT CK_Reembolso_CVU
            CHECK (
                LEN(cvu_cuenta_destino) = 22
                AND cvu_cuenta_destino NOT LIKE '%[^0-9]%'
            )
    );

    CREATE TABLE reservas.MotivoCancelacion (
        id INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(10) NOT NULL,
        descripcion VARCHAR(255) NULL,

        CONSTRAINT PK_MotivoCancelacion PRIMARY KEY (id),
        CONSTRAINT UQ_MotivoCancelacion_Nombre UNIQUE (nombre)
    );

    CREATE TABLE reservas.Cancelacion (
        id_item_reserva INT NOT NULL,
        id_motivo INT NOT NULL,
        id_reembolso INT NOT NULL,

        CONSTRAINT PK_Cancelacion PRIMARY KEY (id_item_reserva, id_motivo),

        CONSTRAINT FK_Cancelacion_ItemReserva
            FOREIGN KEY (id_item_reserva)
            REFERENCES reservas.ItemReserva(id),

        CONSTRAINT FK_Cancelacion_Motivo
            FOREIGN KEY (id_motivo)
            REFERENCES reservas.MotivoCancelacion(id),

        CONSTRAINT FK_Cancelacion_Reembolso
            FOREIGN KEY (id_reembolso)
            REFERENCES reservas.Reembolso(id),
    );

    CREATE TABLE reservas.Entrada (
        id_item_reserva INT NOT NULL,
        fecha_acceso DATE NOT NULL,
        id_parque INT NOT NULL,
        id_tipo_visitante INT NOT NULL,

        CONSTRAINT PK_Entrada PRIMARY KEY (id_item_reserva),

        CONSTRAINT FK_Entrada_ItemReserva
            FOREIGN KEY (id_item_reserva)
            REFERENCES reservas.ItemReserva(id),

        CONSTRAINT FK_Entrada_Parque
            FOREIGN KEY (id_parque)
            REFERENCES parques.Parque(id),

        CONSTRAINT FK_Entrada_TipoVisitante
            FOREIGN KEY (id_tipo_visitante)
            REFERENCES parques.TipoVisitante(id)
    );

    CREATE TABLE reservas.Participacion (
        id_item_reserva INT NOT NULL,
        fecha DATE NOT NULL,
        id_horario INT NOT NULL,

        CONSTRAINT PK_Participacion
            PRIMARY KEY (id_item_reserva),

        CONSTRAINT FK_Participacion_ItemReserva
            FOREIGN KEY (id_item_reserva)
            REFERENCES reservas.ItemReserva(id),

        CONSTRAINT FK_Participacion_Horario
            FOREIGN KEY (id_horario)
            REFERENCES actividades.Horario(id)
    );

END;
GO

-- SP Wrapper con verificaciones
CREATE OR ALTER PROCEDURE reservas.sp_crear_modulo_reservas
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @tablas_existentes TABLE (
        nombre VARCHAR(128)
    );

    INSERT INTO @tablas_existentes (nombre)
    SELECT t.name
    FROM sys.tables t
    INNER JOIN sys.schemas s
        ON s.schema_id = t.schema_id
    WHERE s.name = 'reservas'
      AND t.name IN (
            'Reserva',
            'EstadoItem',
            'ItemReserva',
            'Reembolso',
            'MotivoCancelacion',
            'Cancelacion',
            'Entrada',
            'Participacion'
      );

    IF EXISTS (SELECT 1 FROM @tablas_existentes)
    BEGIN
        RAISERROR(
            'No se puede crear el modulo: ya existe al menos una tabla del modulo reservas en el esquema reservas.',
            16,
            1
        );
        RETURN;
    END;

    EXEC reservas.sp_crear_tablas_modulo_reservas;

END;
GO

-- SP para destruir el módulo (respetando orden de integridad referencial)
CREATE OR ALTER PROCEDURE reservas.sp_eliminar_modulo_reservas
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

            DROP TABLE IF EXISTS reservas.Participacion;
            DROP TABLE IF EXISTS reservas.Entrada;
            DROP TABLE IF EXISTS reservas.Cancelacion;

            DROP TABLE IF EXISTS reservas.Reembolso;
            DROP TABLE IF EXISTS reservas.MotivoCancelacion;

            DROP TABLE IF EXISTS reservas.ItemReserva;

            DROP TABLE IF EXISTS reservas.EstadoItem;
            DROP TABLE IF EXISTS reservas.Reserva;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @mensaje_error VARCHAR(4000);

        SET @mensaje_error = ERROR_MESSAGE();

        RAISERROR(@mensaje_error, 16, 1);

        RETURN;
    END CATCH;
END;
GO

-- Ejecucion (Comentado para evitar ejecución accidental si copiás el script de corrido)
/*
EXEC reservas.sp_crear_modulo_reservas;
select * from sys.tables
GO

-- Autodestruccion (Comentado para evitar ejecución accidental)
EXEC reservas.sp_eliminar_modulo_reservas;
select * from sys.tables
GO

-- Otra verif
SELECT * 
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'reservas';
*/