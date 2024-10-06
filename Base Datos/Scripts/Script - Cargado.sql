CREATE PROCEDURE CargarXML
(
	@outResultCode INT OUTPUT
	, @inRutaXML NVARCHAR(500)
)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		SET @outResultCode = 0;
		BEGIN TRANSACTION Cargado;
			
			DECLARE @Datos xml

			-- Variables para la carga del XML
			DECLARE @Comando NVARCHAR(500)= 'SELECT @Datos = D FROM OPENROWSET (BULK '  + CHAR(39) + @inRutaXML + CHAR(39) + ', SINGLE_BLOB) AS Datos(D)';
			DECLARE @Parametros NVARCHAR(500);
			DECLARE @hdoc INT;

			SET @Parametros = N'@Datos xml OUTPUT';

			EXEC sp_executesql @Comando, @Parametros, @Datos OUTPUT;
    		EXEC sp_xml_preparedocument @hdoc OUTPUT, @Datos;


			-- Cargado de tabla Puesto
			INSERT INTO [dbo].[Puesto] ([Nombre], [SalarioxHora])
			SELECT *
				FROM OPENXML (@hdoc, '/Datos/Puestos/Puesto', 1)
				WITH(
					Nombre VARCHAR(100)
					, SalarioxHora DECIMAL(18, 2)
				)

			-- Cargado de tabla Empleado
			INSERT INTO [dbo].[Empleado] ([idPuesto], [ValorDocumentoIdentidad], [Nombre], [FechaContratacion], [SaldoVacaciones])
			SELECT
				P.id
				, TempEmpleado.ValorDocumentoIdentidad
				, TempEmpleado.Nombre
				, TempEmpleado.FechaContratacion
				, TempEmpleado.SaldoVacaciones
			FROM (
				SELECT
					Puesto
					, ValorDocumentoIdentidad
					, Nombre
					, FechaContratacion
					, 0 AS SaldoVacaciones
					FROM OPENXML (@hdoc, '/Datos/Empleados/empleado', 1)
					WITH(
						Puesto NVARCHAR(100) -- Temporalmente se obtiene el puesto por el nombre
						, ValorDocumentoIdentidad NVARCHAR(50)
						, Nombre NVARCHAR(100)
						, FechaContratacion DATE
					)
			) AS TempEmpleado
			-- Realizamos el INNER JOIN para obtener el idPuesto correcto
			INNER JOIN Puesto P ON TempEmpleado.Puesto = P.Nombre;

			-- Cargado de tabla TipoMovimiento
			INSERT INTO [dbo].[TipoMovimiento] ([Nombre], [TipoAccion])
			SELECT *
				FROM OPENXML (@hdoc, '/Datos/TiposMovimientos/TipoMovimiento', 1)
				WITH(
					Nombre NVARCHAR(100)
					, TipoAccion NVARCHAR(100)
				)

			-- Cargado de tabla Usuario
			INSERT INTO [dbo].[Usuario] ([Username], [Password])
			SELECT *
				FROM OPENXML (@hdoc, '/Datos/Usuarios/usuario', 1)
				WITH(
					Nombre NVARCHAR(50)
					, Pass NVARCHAR(50)
				)

			-- Cargado de tabla Movimiento
			INSERT INTO [dbo].[Movimiento] (
				[idEmpleado]
				, [idTipoMovimiento]
				, [Fecha]
				, [Monto]
				, [NuevoSaldo]
				, [idPostByUser]
				, [PostInIP]
				, PostTime
			)
				-- TODO: Se debe hacer un update para el campo NuevoSaldo
				SELECT
					E.id AS idEmpleado
					, T.id AS idTipoMovimiento
					, TempMovimiento.Fecha
					, TempMovimiento.Monto
					, TempMovimiento.NuevoSaldo
					, U.id
					, TempMovimiento.PostInIP
					, TempMovimiento.PostTime
				FROM (
					SELECT
						ValorDocId
						, IdTipoMovimiento
						, Fecha
						, Monto
						, 0 AS NuevoSaldo
						, PostByUser
						, PostInIP
						, PostTime
					FROM OPENXML (@hdoc, '/Datos/Movimientos/movimiento', 1)
					WITH(
						ValorDocId NVARCHAR(50)
						, IdTipoMovimiento NVARCHAR(100)
						, Fecha DATE
						, Monto DECIMAL(18,2)
						, PostByUser NVARCHAR(50)
						, PostInIP NVARCHAR(50)
						, PostTime DATETIME
					)
				) AS TempMovimiento
				INNER JOIN Empleado E ON E.ValorDocumentoIdentidad = TempMovimiento.ValorDocId
				INNER JOIN TipoMovimiento T ON T.Nombre = TempMovimiento.idTipoMovimiento
				INNER JOIN Usuario U ON U.Username = TempMovimiento.PostByUser

			-- Cargado de tabla TipoEvento
			INSERT INTO [dbo].[TipoEvento] ([Nombre])
			SELECT *
				FROM OPENXML (@hdoc, '/Datos/TiposEvento/TipoEvento', 1)
				WITH(
					Nombre NVARCHAR(100)
				)

			-- Cargado de tabla Error
			INSERT INTO [dbo].[Error] ([Codigo], [Descripcion])
			SELECT *
				FROM OPENXML (@hdoc, '/Datos/Error/error', 1)
				WITH(
					Codigo INT
					, Descripcion NVARCHAR(255)
				)

			EXEC sp_xml_removedocument @hdoc
		COMMIT TRANSACTION Cargado;
		SELECT @outResultCode AS outResultCode;
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION Cargado;
		END
		SET @outResultCode = 50008; -- Error en base de datos
		INSERT INTO [dbo].[DBError] VALUES (
			SUSER_NAME()
			, ERROR_NUMBER()
			, ERROR_STATE()
			, ERROR_SEVERITY()
			, ERROR_LINE()
			, ERROR_PROCEDURE()
			, ERROR_MESSAGE()
			, GETDATE()
			);
		SELECT @outResultCode AS outResultCode;
	END CATCH
	SET NOCOUNT OFF;
END


-- DROP PROCEDURE IF EXISTS CargarXML;

-- EXEC CargarXML @outResultCode=50008, @inRutaXML='C:\Proyectos\CRUDEmpleadosAndres\Base Datos\Scripts\Datos.xml';

-- La consulta a Movimiento debe siempre hacerse con: ORDER BY PostTime ASC
-- SELECT * FROM [dbo].[Movimiento] ORDER BY PostTime ASC

-- SELECT * FROM [dbo].[Usuario]

-- SELECT * FROM [dbo].[DBError]