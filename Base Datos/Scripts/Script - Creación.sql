--create database BD1_TP2;

use BD1_TP2;

-- Se desactiva el recuento de filas
SET NOCOUNT ON;

-- Resetea las INDENTITIES o IDs
-- (Se usa solo si en vez de DROP TABLE fuera DELETE [dbo].[Empleado];
-- DBCC CHECKIDENT ('[dbo].[Empleado]', RESEED, 0);

-- Limpia las tablas
-- Se puede usar la instrucción IF EXISTS para evitar errores: DROP TABLE IF EXISTS BitacoraEvento;
-- A continuación se usa así para efectos de testing...
DROP TABLE IF EXISTS [dbo].[BitacoraEvento];
DROP TABLE IF EXISTS [dbo].[Movimiento];
DROP TABLE IF EXISTS [dbo].[Empleado];
DROP TABLE IF EXISTS [dbo].[DBError];
DROP TABLE IF EXISTS [dbo].[TipoMovimiento];
DROP TABLE IF EXISTS [dbo].[Usuario];
DROP TABLE IF EXISTS [dbo].[TipoEvento];
DROP TABLE IF EXISTS [dbo].[Puesto];
DROP TABLE IF EXISTS [dbo].[Error];

-- Creación de las tablas
CREATE TABLE Puesto (
    id INT PRIMARY KEY IDENTITY(1,1)
    , Nombre NVARCHAR(100) NOT NULL
    , SalarioxHora DECIMAL(18, 2) NOT NULL
);


CREATE TABLE Empleado (
    id INT PRIMARY KEY IDENTITY(1,1)
    , idPuesto INT FOREIGN KEY REFERENCES Puesto(id)
    , ValorDocumentoIdentidad NVARCHAR(50) NOT NULL
    , Nombre NVARCHAR(100) NOT NULL
    , FechaContratacion DATE NOT NULL
    , SaldoVacaciones DECIMAL(18, 2) NOT NULL
    , EsActivo BIT NOT NULL DEFAULT 1
);


CREATE TABLE TipoMovimiento (
    id INT PRIMARY KEY IDENTITY(1,1)
    , Nombre NVARCHAR(100) NOT NULL
    , TipoAccion NVARCHAR(100) NOT NULL
);


CREATE TABLE Usuario (
    id INT PRIMARY KEY IDENTITY(1,1)
    , Username NVARCHAR(50) NOT NULL
    , [Password] NVARCHAR(50) NOT NULL
);
ALTER TABLE Usuario
ADD 
	userBlocked BIT DEFAULT 0,
    failedAttempts INT NOT NULL DEFAULT 0, -- La cantidad de intentos fallidos comienza en 0
	lastTimeLogin DATETIME NULL; -- La cantidad de intentos fallidos comienza en 0




CREATE TABLE Movimiento (
    id INT PRIMARY KEY IDENTITY(1,1)
    , idEmpleado INT FOREIGN KEY REFERENCES Empleado(id)
    , idTipoMovimiento INT FOREIGN KEY REFERENCES TipoMovimiento(id)
    , Fecha DATE NOT NULL
    , Monto DECIMAL(18, 2) NOT NULL
    , NuevoSaldo DECIMAL(18, 2) NOT NULL
    , idPostByUser INT FOREIGN KEY REFERENCES Usuario(id)
    , PostInIP NVARCHAR(50)
    , PostTime DATETIME NOT NULL
);


CREATE TABLE TipoEvento (
    id INT PRIMARY KEY IDENTITY(1,1)
    , Nombre NVARCHAR(100) NOT NULL
);


CREATE TABLE BitacoraEvento (
    id INT PRIMARY KEY IDENTITY(1,1)
    , idTipoEvento INT FOREIGN KEY REFERENCES TipoEvento(id)
    , Descripcion NVARCHAR(255)
    , idPostByUser INT FOREIGN KEY REFERENCES Usuario(id)
    , PostInIP NVARCHAR(50)
    , PostTime DATETIME NOT NULL
);


CREATE TABLE DBError (
    id INT PRIMARY KEY IDENTITY(1,1)
    , UserName NVARCHAR(100)
    , [Number] INT
    , [State] INT
    , [Severity] INT
    , [Line] INT
    , [Procedure] NVARCHAR(100)
    , [Message] NVARCHAR(255)
    , [DateTime] DATETIME NOT NULL
);


CREATE TABLE Error (
    id INT PRIMARY KEY IDENTITY(1,1)
    , Codigo INT NOT NULL
    , Descripcion NVARCHAR(255)
);