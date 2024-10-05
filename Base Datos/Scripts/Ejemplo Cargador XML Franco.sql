USE BDPlanillaObrera

SET LANGUAGE Spanish;

--EXEC sp_EliminarDatos					-- Vaciar datos de la base


-- Declaracion de Tablas Variable
DECLARE @Operaciones TABLE(				-- Tabla donde iteramos todas las operaciones
	Operacion DATE,
	Datos XML
)

DECLARE @InsercionMarcas TABLE			-- Tabla donde iteramos las Marcas de Asistencia
(
	ValorDocumentoIdentidad INT,
	FechaEntrada DATETIME,
	FechaSalida DATETIME,
	Secuencia INT,
	ProduceError INT
) 

DECLARE @InsercionEmpleados TABLE(		-- Tabla donde ingresamos todos los empleados a insertar
	Fecha DATE,
	Nombre VARCHAR(64),
	ValorDocumentoIdentidad INT,
	FechaNacimiento DATE,
	IdPuesto INT,
	IdTipoDocumentoIdentidad INT,
	IdDepartamento INT,
	Username VARCHAR(64),
	Pwd VARCHAR(64),
	Secuencia INT,
	ProduceError INT
)

DECLARE @EliminarEmpleados TABLE (		-- Tabla donde guardamos todos los empleados a eliminar
	ValorDocumentoIdentidad INT,
	Secuencia INT,
	ProduceError INT
) 

DECLARE @AsociarEmpleados TABLE			-- Tabla donde guardamos todas las asociaciones 
(
	ValorDocumentoIdentidad INT,
	IdDeduccion INT,
	Monto DECIMAL(18,3),
	Secuencia INT,
	ProduceError INT
) 

DECLARE @DesasociarEmpleados TABLE		-- Tabla donde guardamos todas las desasociaciones
(
	ValorDocumentoIdentidad INT,
	IdDeduccion INT,
	Secuencia INT,
	ProduceError INT
) 

DECLARE @IngresarJornada TABLE			-- Tablas donde almacenamos las siguientes jornadas
(
	ValorDocumentoIdentidad INT,
	IdJornada INT,
	Secuencia INT,
	ProduceError INT
) 


-- Declaracion de Variables
DECLARE @catalogo xml			-- Para dividir el xml en la tabla operaciones
DECLARE @primeraFecha DATE
DECLARE @ultimaFecha DATE
DECLARE @i INT;	

DECLARE @Datos xml				-- Para ejecucion de simulacion
DECLARE @Count INT	
DECLARE @Semanas INT
DECLARE @RecorrerSemanas DATE

DECLARE @Secuencia INT
DECLARE @ProduceError INT

DECLARE @Nombre VARCHAR(64)
DECLARE @ValorDocumentoIdentidad INT
DECLARE @FechaNacimiento DATE
DECLARE @IdPuesto INT
DECLARE @IdDepartamento INT
DECLARE @IdTipoDocumentoIdentidad INT
DECLARE @Username VARCHAR(64)
DECLARE @Contraseña VARCHAR(64)

DECLARE @IdDeduccion INT
DECLARE @Monto DECIMAL(18,3)
DECLARE @IdJornada INT

DECLARE @FechaEntrada DATETIME
DECLARE @FechaSalida DATETIME

DECLARE @SecItera INT
DECLARE @SecInicio INT
DECLARE @SecFinal INT
DECLARE @UltimaCorrida INT


-- SIMULACION
-- Carga de Catalogos ------------------------------------------------------------------------------
exec sp_CargarCatalogos			-- Carga los catalogos

-- Simulacion --------------------------------------------------------------------------------------
SELECT @catalogo = CAST(MY_XML AS xml) 
FROM OPENROWSET(BULK 'C:\Datos_Tarea3.xml', SINGLE_BLOB) AS T(MY_XML)

SELECT TOP 1 @primeraFecha = T.Item.value('@Fecha', 'date') 
FROM @catalogo.nodes('Datos/Operacion') AS T(Item)

SELECT @ultimaFecha = T.Item.value('@Fecha', 'date') 
FROM @catalogo.nodes('Datos/Operacion') AS T(Item)

SELECT @i = 1;

-- Recorre todas las operaciones dividiendolas
WHILE(@primeraFecha <= @ultimaFecha)
BEGIN
	INSERT INTO @Operaciones
	VALUES(@primeraFecha, @catalogo.query('/Datos/Operacion[sql:variable("@i")]'))
	SET @primeraFecha = DATEADD(DAY,1,@primeraFecha);
	SELECT @i = @i + 1;
END

-- Reinicia la fecha de la primera operacion
SELECT TOP 1 @primeraFecha = T.Item.value('@Fecha', 'date')
FROM @catalogo.nodes('Datos/Operacion') AS T(Item)


-- Inicia Simulacion ---------------------------------------------------------------
WHILE(@primeraFecha <= @ultimaFecha)
BEGIN
	INSERT INTO dbo.Corrida(
		FechaOperacion,
		TipoRegistro,
		PostTime
	)
	VALUES(
		@primeraFecha,
		1,
		GETDATE()
	)

	SELECT
		@UltimaCorrida = (SELECT MAX(Id) FROM dbo.Corrida)

	SELECT @Datos = CONVERT(XML, Datos)
	FROM @Operaciones
	WHERE Operacion = @primeraFecha

	-- Calculo de la semana y mes 
	IF DATEPART(WEEKDAY, @primeraFecha) = 4
	BEGIN
		IF(DATENAME(MONTH,DATEADD(DAY,1,@primeraFecha)) <> DATENAME(MONTH,DATEADD(DAY,-6,@primeraFecha)))
		BEGIN
			SELECT @Semanas = 0
			SELECT @RecorrerSemanas = (SELECT DATEADD(DAY,1,@primeraFecha))
			WHILE (DATENAME(MONTH,DATEADD(DAY,1,@primeraFecha)) = (DATENAME(MONTH,@RecorrerSemanas)))
			BEGIN
				SET @RecorrerSemanas = (SELECT DATEADD(WEEK,1,@RecorrerSemanas))
				SET @Semanas = @Semanas+1
			END
			INSERT INTO dbo.MesPlanilla
			VALUES((SELECT DATEADD(DAY,1,@primeraFecha)), (SELECT DATEADD(DAY,7*@Semanas,@primeraFecha)))
		END
		
		INSERT INTO dbo.SemanaPlanilla
		VALUES((SELECT DATEADD(DAY,1,@primeraFecha)), (SELECT DATEADD(DAY,7,@primeraFecha)), (SELECT MAX(Id) AS Id FROM dbo.MesPlanilla))
	END



		-- Ingreso de la Marca Asistencia 
	IF((SELECT mt.Datos.exist('Operacion/MarcaDeAsistencia') FROM @Operaciones mt WHERE mt.Operacion = @primeraFecha) = 1)
	BEGIN
		INSERT INTO Bitacora
		VALUES
		(
			'Nueva iteracion procesando Marca Asistencia',
			@primeraFecha
		)

		INSERT INTO @InsercionMarcas
			SELECT * FROM dbo.CargarInsercionMarca(@Datos)

		SELECT 
			@SecInicio = MIN(Secuencia), 
			@SecFinal = MAX(Secuencia) 
		FROM @InsercionMarcas;
                   
		SELECT 
			@SecItera = @SecInicio;

        WHILE @SecItera <= @SecFinal
		BEGIN
			SELECT
				@ValorDocumentoIdentidad = Emp.ValorDocumentoIdentidad, 
				@FechaEntrada = Emp.FechaEntrada, 
				@FechaSalida = Emp.FechaSalida,
				@Secuencia = Emp.Secuencia,
				@ProduceError = Emp.ProduceError
			FROM @InsercionMarcas AS Emp
			WHERE Emp.Secuencia = @SecItera

			EXEC sp_InsertarMarca
				@ValorDocumentoIdentidad
                , @FechaEntrada
				, @FechaSalida,
				0
			
			IF @ProduceError = 1
			BEGIN
				INSERT INTO Bitacora
				VALUES
				(
					'Hubo error en registro numero '+ CONVERT(VARCHAR(5),@SecItera) +' procesando Marcas Asistencia',
					@primeraFecha
				)

				INSERT INTO DetalleCorrida
				VALUES 
				(
					@UltimaCorrida,
					6,
					@SecItera
				)
			END
			ELSE IF @SecItera = @SecFinal
			BEGIN
				INSERT INTO DetalleCorrida
				VALUES 
				(
					@UltimaCorrida,
					6,
					@SecItera
				)
			END

			SELECT @SecItera = @SecItera + 1
		END

		DELETE FROM @InsercionMarcas
	END


	-- Ingreso de los empleados nuevos 
	IF((SELECT mt.Datos.exist('Operacion/NuevoEmpleado') FROM @Operaciones mt WHERE mt.Operacion = @primeraFecha) = 1)
	BEGIN
		INSERT INTO Bitacora
		VALUES
		(
			'Nueva iteracion procesando Nuevos empleados',
			@primeraFecha
		)

		INSERT INTO @InsercionEmpleados
			SELECT * FROM dbo.CargarInsercionEmpleados(@Datos)

		SELECT 
			@SecInicio = MIN(Secuencia), 
			@SecFinal = MAX(Secuencia) 
		FROM @InsercionEmpleados;
                   
		SELECT 
			@SecItera = @SecInicio;

        WHILE @SecItera <= @SecFinal
		BEGIN
			SELECT
				@Nombre = Emp.Nombre, 
				@ValorDocumentoIdentidad = Emp.ValorDocumentoIdentidad, 
				@FechaNacimiento = Emp.FechaNacimiento, 
				@IdPuesto = Emp.IdPuesto, 
				@IdDepartamento = Emp.IdDepartamento, 
				@IdTipoDocumentoIdentidad = Emp.IdTipoDocumentoIdentidad, 
				@Username = Emp.Username, 
				@Contraseña = Emp.Pwd,
				@Secuencia = Emp.Secuencia,
				@ProduceError = Emp.ProduceError
			FROM @InsercionEmpleados AS Emp
			WHERE Emp.Secuencia = @SecItera


			EXEC sp_InsertarEmpleado
				@Nombre
				, @ValorDocumentoIdentidad
                , @FechaNacimiento
                , @IdPuesto
                , @IdDepartamento
                , @IdTipoDocumentoIdentidad
                , @Username
                , @Contraseña
			
			IF @ProduceError = 1
			BEGIN
				INSERT INTO Bitacora
				VALUES
				(
					'Hubo error en registro numero '+ CONVERT(VARCHAR(5),@SecItera) +' procesando Nuevos Empleados',
					@primeraFecha
				)

				INSERT INTO DetalleCorrida
				VALUES 
				(
					@UltimaCorrida,
					1,
					@SecItera
				)
			END
			ELSE IF @SecItera = @SecFinal
			BEGIN
				INSERT INTO DetalleCorrida
				VALUES 
				(
					@UltimaCorrida,
					1,
					@SecItera
				)
			END
			
			SELECT @SecItera = @SecItera + 1
		END
		DELETE FROM @InsercionEmpleados
	END


	
	-- Eliminacion de empleados 
	IF((SELECT mt.Datos.exist('Operacion/EliminarEmpleado') FROM @Operaciones mt WHERE mt.Operacion = @primeraFecha) = 1)
	BEGIN
		INSERT INTO Bitacora
		VALUES
		(
			'Nueva iteracion procesando Eliminar empleados',
			@primeraFecha
		)
		INSERT INTO @EliminarEmpleados
			SELECT * FROM dbo.CargarEliminarEmpleados(@Datos)
		
        SELECT 
			@SecInicio = MIN(Secuencia), 
			@SecFinal = MAX(Secuencia) 
		FROM @EliminarEmpleados;
                   
		SELECT 
			@SecItera = @SecInicio;

        WHILE @SecItera <= @SecFinal
		BEGIN
            SELECT
				@ValorDocumentoIdentidad = Emp.ValorDocumentoIdentidad  ,
				@Secuencia = Emp.Secuencia,
				@ProduceError = Emp.ProduceError
			FROM @EliminarEmpleados AS Emp
			WHERE Emp.Secuencia = @SecItera

			EXEC sp_EliminarEmpleado
				@ValorDocumentoIdentidad

			IF @ProduceError = 1
			BEGIN
				INSERT INTO Bitacora
				VALUES
				(
					'Hubo error en registro numero '+ CONVERT(VARCHAR(5),@SecItera) +' procesando Eliminar Empleados',
					@primeraFecha
				)

				INSERT INTO DetalleCorrida
				VALUES 
				(
					@UltimaCorrida,
					2,
					@SecItera
				)
			END
			ELSE IF @SecItera = @SecFinal
			BEGIN
				INSERT INTO DetalleCorrida
				VALUES 
				(
					@UltimaCorrida,
					2,
					@SecItera
				)
			END

			SELECT @SecItera = @SecItera + 1
		END
		DELETE FROM @EliminarEmpleados
	END
	
	-- Asociacion de empleado a una Deduccion 
	IF((SELECT mt.Datos.exist('Operacion/AsociaEmpleadoConDeduccion') FROM @Operaciones mt WHERE mt.Operacion = @primeraFecha) = 1)
	BEGIN
		INSERT INTO Bitacora
		VALUES
		(
			'Nueva iteracion procesando Asociar Deducciones',
			@primeraFecha
		)
		INSERT INTO @AsociarEmpleados
			SELECT * FROM dbo.CargarAsociarEmpleados(@Datos)

        SELECT 
			@SecInicio = MIN(Secuencia), 
			@SecFinal = MAX(Secuencia) 
		FROM @AsociarEmpleados;
                   
		SELECT 
			@SecItera = @SecInicio;

        WHILE @SecItera <= @SecFinal
		BEGIN
            SELECT 
				@ValorDocumentoIdentidad = Emp.ValorDocumentoIdentidad,
				@IdDeduccion = Emp.IdDeduccion,
				@Monto = Emp.Monto,
				@Secuencia = Emp.Secuencia,
				@ProduceError = Emp.ProduceError
			FROM @AsociarEmpleados AS Emp
			WHERE Emp.Secuencia = @SecItera

			EXEC sp_AsociarDeduccion
				@primeraFecha,
				@ValorDocumentoIdentidad,
				@IdDeduccion,
				@Monto

			IF @ProduceError = 1
			BEGIN
				INSERT INTO Bitacora
				VALUES
				(
					'Hubo error en registro numero '+ CONVERT(VARCHAR(5),@SecItera) +' procesando Asociar Deducciones',
					@primeraFecha
				)

				INSERT INTO DetalleCorrida
				VALUES 
				(
					@UltimaCorrida,
					3,
					@SecItera
				)
			END
			ELSE IF @SecItera = @SecFinal
			BEGIN
				INSERT INTO DetalleCorrida
				VALUES 
				(
					@UltimaCorrida,
					3,
					@SecItera
				)
			END

			SELECT @SecItera = @SecItera + 1
		END
		DELETE FROM @AsociarEmpleados
	END


	-- Desasociacion de empleado a una Deduccion 
	IF((SELECT mt.Datos.exist('Operacion/DesasociaEmpleadoConDeduccion') FROM @Operaciones mt WHERE mt.Operacion = @primeraFecha) = 1)
	BEGIN
		INSERT INTO Bitacora
		VALUES
		(
			'Nueva iteracion procesando Desasociar Deducciones',
			@primeraFecha
		)
		INSERT INTO @DesasociarEmpleados
			SELECT * FROM dbo.CargarDesasociarEmpleados(@Datos)

        SELECT 
			@SecInicio = MIN(Secuencia), 
			@SecFinal = MAX(Secuencia) 
		FROM @DesasociarEmpleados;
                   
		SELECT 
			@SecItera = @SecInicio;

        WHILE @SecItera <= @SecFinal
		BEGIN
            SELECT
				@ValorDocumentoIdentidad = Emp.ValorDocumentoIdentidad,
				@IdDeduccion = Emp.IdDeduccion,
				@Secuencia = Emp.Secuencia,
				@ProduceError = Emp.ProduceError
			FROM @DesasociarEmpleados AS Emp
			WHERE Emp.Secuencia = @SecItera

			EXEC sp_DesasociarDeduccion
				@primeraFecha,
				@ValorDocumentoIdentidad,
				@IdDeduccion

			IF @ProduceError = 1
			BEGIN
				INSERT INTO Bitacora
				VALUES
				(
					'Hubo error en registro numero '+ CONVERT(VARCHAR(5),@SecItera) +' procesando Desasociar Deducciones',
					@primeraFecha
				)

				INSERT INTO DetalleCorrida
				VALUES 
				(
					@UltimaCorrida,
					4,
					@SecItera
				)
			END
			ELSE IF @SecItera = @SecFinal
			BEGIN
				INSERT INTO DetalleCorrida
				VALUES 
				(
					@UltimaCorrida,
					4,
					@SecItera
				)
			END

			SELECT @SecItera = @SecItera + 1
		END
		DELETE FROM @DesasociarEmpleados
	END
	
	-- Asignar Tipos de Jornada
	IF((SELECT mt.Datos.exist('Operacion/TipoDeJornadaProximaSemana') FROM @Operaciones mt WHERE mt.Operacion = @primeraFecha) = 1)
	BEGIN
		INSERT INTO Bitacora
		VALUES
		(
			'Nueva iteracion procesando Nuevas Jornadas',
			@primeraFecha
		)
		INSERT INTO @IngresarJornada
			SELECT * FROM dbo.CargarIngresarJornada(@Datos)

        SELECT 
			@SecInicio = MIN(Secuencia), 
			@SecFinal = MAX(Secuencia) 
		FROM @IngresarJornada;
                   
		SELECT 
			@SecItera = @SecInicio;

        WHILE @SecItera <= @SecFinal
		BEGIN
            SELECT
				@ValorDocumentoIdentidad = Emp.ValorDocumentoIdentidad,
				@IdJornada = Emp.IdJornada,
				@Secuencia = Emp.Secuencia,
				@ProduceError = Emp.ProduceError
			FROM @IngresarJornada AS Emp
			WHERE Emp.Secuencia = @SecItera
			
			EXEC sp_IngresarJornada
				@ValorDocumentoIdentidad,
				@IdJornada
			
			IF @ProduceError = 1
			BEGIN
				INSERT INTO Bitacora
				VALUES
				(
					'Hubo error en registro numero '+ CONVERT(VARCHAR(5),@SecItera) +' procesando Nuevas Jornadas',
					@primeraFecha
				)

				INSERT INTO DetalleCorrida
				VALUES 
				(
					@UltimaCorrida,
					5,
					@SecItera
				)
			END
			ELSE IF @SecItera = @SecFinal
			BEGIN
				INSERT INTO DetalleCorrida
				VALUES 
				(
					@UltimaCorrida,
					5,
					@SecItera
				)
			END

			SELECT @SecItera = @SecItera + 1
		END
		DELETE FROM @IngresarJornada
	END

	INSERT INTO dbo.Corrida
	(
		FechaOperacion,
		TipoRegistro,
		PostTime
	)
	VALUES(
		@primeraFecha,
		2,
		GETDATE()
	)

	SET @primeraFecha = DATEADD(DAY,1,@primeraFecha);
END

