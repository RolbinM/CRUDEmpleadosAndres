-- Procedimiento almacenado Login
CREATE PROCEDURE SP_Login
(
	@username NVARCHAR(50),
    @password NVARCHAR(50),
	@outResultCode INT OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		SET @outResultCode = 1;
		BEGIN TRANSACTION validate_user;
		IF EXISTS (SELECT 1
               FROM [dbo].[Usuario] 
               WHERE Username = @username
               AND Password = @password)
		BEGIN
        -- Si el usuario y contrase�a coinciden, retorna 0
			SET @outResultCode = 0;
		END

		COMMIT TRANSACTION validate_user;
		SELECT @outResultCode AS outResultCode;
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION validate_user;
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

--Procedimiento almacenado Insert empleado
DROP PROCEDURE SP_Insert_Employee;
CREATE PROCEDURE SP_Insert_Employee
(
	@cedula NVARCHAR(50),
    @name NVARCHAR(100),
	@nombrePuesto NVARCHAR(100),
	@fechaContratacion DATE = NULL,
	@outResultCode INT OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		-- Inicializamos el valor de salida
		SET @outResultCode = 0; -- 0 indica que todo bien

		-- Verificar si ya existe un empleado con la misma c�dula o nombre
		IF EXISTS (SELECT 1 FROM [dbo].[Empleado] WHERE ValorDocumentoIdentidad = @cedula)
		BEGIN
			-- C�digo de error 50004 si la c�dula ya existe
			SET @outResultCode = 50004;
			SELECT @outResultCode AS outResultCode;
			RETURN;
		END
    
		IF EXISTS (SELECT 1 FROM [dbo].[Empleado] WHERE Nombre = @name)
		BEGIN
			-- C�digo de error 50005 si el nombre ya existe
			SET @outResultCode = 50005;
			SELECT @outResultCode AS outResultCode;
			RETURN;
		END

    -- Obtener el id del puesto a partir del nombre del puesto
    DECLARE @idPuesto INT;
    SELECT @idPuesto = id FROM [dbo].[Puesto] WHERE [Nombre] = @nombrePuesto;

	IF @idPuesto IS NULL
		BEGIN
			-- C�digo de error 500051 si no se encontr� el puesto
			SET @outResultCode = 500051;
			SELECT @outResultCode AS outResultCode;
			RETURN;
		END

	DECLARE @fechaFinal DATE;
    SET @fechaFinal = ISNULL(@fechaContratacion, GETDATE());

	-- Si las validaciones pasaron, insertamos el nuevo empleado
	BEGIN TRANSACTION validate_user_insertion;
		INSERT INTO Empleado (idPuesto, ValorDocumentoIdentidad, Nombre, FechaContratacion, SaldoVacaciones)
		VALUES (@idPuesto, @cedula, @name, @fechaFinal, 0);
	COMMIT TRANSACTION validate_user_insertion;

	-- Si se insert� correctamente, retornamos 0 (�xito)
	SELECT @outResultCode AS outResultCode;
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION validate_user_insertion;
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



--DECLARE @resultado INT;

-- Ejecutar el procedimiento almacenado con una fecha espec�fica
--EXEC SP_Insert_Employee 
--    @cedula = '12456789', 
--    @name = 'Juan Perez', 
--    @nombrePuesto = 'Ingeniero',
--    @fechaContratacion = '2024-01-01', -- Fecha proporcionada
--    @outResultCode = @resultado OUTPUT;

-- Revisar el resultado
--PRINT @resultado; 