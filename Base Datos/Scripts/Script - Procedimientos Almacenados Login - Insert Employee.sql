DROP PROCEDURE SP_AumentarIntentosFallidos
CREATE PROCEDURE SP_AumentarIntentosFallidos
(
	@username NVARCHAR(50),
	@lastTimeLogin DATETIME
)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY;

	DECLARE @failedAttempts INT
	
	SET @failedAttempts = (SELECT failedAttempts from Usuario where Username = @username) + 1

	IF @lastTimeLogin IS NOT NULL
	BEGIN
		IF @failedAttempts >= 5 AND DATEDIFF(MINUTE, @lastTimeLogin, GETDATE()) < 30
		BEGIN
			BEGIN TRANSACTION validate_attempt
			UPDATE Usuario
				SET userBlocked = 1
            WHERE Username = @username;
			COMMIT TRANSACTION validate_attempt
			RETURN
		END
	END

	BEGIN TRANSACTION validate_attempt
		UPDATE Usuario
            SET failedAttempts = failedAttempts + 1,
			lastTimeLogin = GETDATE()
            WHERE Username = @username;
	COMMIT TRANSACTION validate_attempt

	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION validate_attempt;
		END
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
	END CATCH
	SET NOCOUNT OFF;
END

CREATE PROCEDURE SP_Desbloquear_Usuario
(
	@username NVARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY;

		BEGIN TRANSACTION unlock_user
			UPDATE Usuario
					SET failedAttempts = 0,
					lastTimeLogin = GETDATE(),
					userBlocked = 0
					WHERE Username = @username;
			COMMIT TRANSACTION unlock_user
			RETURN

	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION unlock_user;
		END
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
	END CATCH
	SET NOCOUNT OFF;
END

select * from Usuario
DECLARE @resultado INT;

EXEC SP_Login 
    @username = 'Rolbin', 
    @password = 'password1', 
    @outResultCode = @resultado OUTPUT;

-- Imprimir el resultado del código de salida
PRINT @resultado;
select * from Usuario

select DATEDIFF(MINUTE, (select lastTimeLogin from Usuario where Username = 'Rolbin'), GETDATE()) 
-- Procedimiento almacenado Login
DROP PROCEDURE SP_Login
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
		IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Username = @username)
		BEGIN
			SET @outResultCode = 50001; --Usuario no existe
			SELECT @outResultCode AS outResultCode;
			RETURN

		END

		DECLARE @userBlocked BIT
		DECLARE @lastTimeLogin DATETIME
		SET @userBlocked = (SELECT userBlocked from Usuario where Username = @username)
		SET @lastTimeLogin = (SELECT lastTimeLogin from Usuario where Username = @username)

		IF @userBlocked = 1 AND (DATEDIFF(MINUTE, @lastTimeLogin, GETDATE())) >= 1
		BEGIN
			exec SP_Desbloquear_Usuario @username
			set @userBlocked = (SELECT userBlocked from Usuario where Username = @username)
		END

		IF @userBlocked = 1
		BEGIN
			SET @outResultCode = 50003; --User blocked
			SELECT @outResultCode AS outResultCode;
			RETURN
		END

		IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Password = @password and Username = @username)
		BEGIN
			SET @outResultCode = 50002; --Password no existe
			exec SP_AumentarIntentosFallidos @username = @username, @lastTimeLogin = @lastTimeLogin
			SELECT @outResultCode AS outResultCode;
			RETURN

		END

        -- Si el usuario y contraseña coinciden, retorna 0
		SET @outResultCode = 0;
		exec SP_Desbloquear_Usuario @username
		SELECT @outResultCode AS outResultCode;
		RETURN
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION validate_user;
			ROLLBACK TRANSACTION validate_unlock_user;
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

		-- Verificar si ya existe un empleado con la misma cédula o nombre
		IF EXISTS (SELECT 1 FROM [dbo].[Empleado] WHERE ValorDocumentoIdentidad = @cedula)
		BEGIN
			-- Código de error 50004 si la cédula ya existe
			SET @outResultCode = 50004;
			SELECT @outResultCode AS outResultCode;
			RETURN;
		END
    
		IF EXISTS (SELECT 1 FROM [dbo].[Empleado] WHERE Nombre = @name)
		BEGIN
			-- Código de error 50005 si el nombre ya existe
			SET @outResultCode = 50005;
			SELECT @outResultCode AS outResultCode;
			RETURN;
		END

    -- Obtener el id del puesto a partir del nombre del puesto
    DECLARE @idPuesto INT;
    SELECT @idPuesto = id FROM [dbo].[Puesto] WHERE [Nombre] = @nombrePuesto;

	IF @idPuesto IS NULL
		BEGIN
			-- Código de error 500051 si no se encontró el puesto
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

	-- Si se insertó correctamente, retornamos 0 (éxito)
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

-- Ejecutar el procedimiento almacenado con una fecha específica
--EXEC SP_Insert_Employee 
--    @cedula = '12456789', 
--    @name = 'Juan Perez', 
--    @nombrePuesto = 'Ingeniero',
--    @fechaContratacion = '2024-01-01', -- Fecha proporcionada
--    @outResultCode = @resultado OUTPUT;

-- Revisar el resultado
--PRINT @resultado; 


--Procedimiento almacenado Update Employee
DROP PROCEDURE SP_Update_Employee

CREATE PROCEDURE SP_Update_Employee
(
    @cedula NVARCHAR(50) = NULL, -- Opcional, si no se pasa se mantiene el valor actual
	@cedula_updated NVARCHAR(50) = NULL, -- Opcional, si no se pasa se mantiene el valor actual
    @name_updated NVARCHAR(100) = NULL, -- Opcional, si no se pasa se mantiene el valor actual
    @nombrePuesto_updated NVARCHAR(100) = NULL, -- Opcional, si no se pasa se mantiene el valor actual
	@isActive BIT = NULL,
    @outResultCode INT OUTPUT -- Parámetro de salida para el estado del request
)
AS
BEGIN
    -- Inicializamos el estado con un valor que indique que no se ha completado
    SET @outResultCode = 1; -- Por defecto: No se realizaron cambios

    BEGIN TRY
		DECLARE @idEmpleado INT
		SET @idEmpleado = (SELECT id FROM Empleado WHERE ValorDocumentoIdentidad = @cedula)
        -- Verificamos que el empleado exista
        IF  @idEmpleado IS NULL
        BEGIN
            SET @outResultCode = 50002; -- Empleado no encontrado
			SELECT @outResultCode AS outResultCode;
            RETURN;
        END

		IF EXISTS (SELECT 1 FROM Empleado WHERE ValorDocumentoIdentidad = @cedula_updated)
        BEGIN
            SET @outResultCode = 50006; -- Cedula de identidad ya existe
			SELECT @outResultCode AS outResultCode;
            RETURN;
        END

		IF EXISTS (SELECT 1 FROM Empleado WHERE Nombre = @name_updated)
        BEGIN
            SET @outResultCode = 50007; -- Nombre ya existe
			SELECT @outResultCode AS outResultCode;
            RETURN;
        END

		DECLARE @idPuesto INT;
		SELECT @idPuesto = id FROM [dbo].[Puesto] WHERE Nombre = @nombrePuesto_updated

		IF @idPuesto IS NULL AND @nombrePuesto_updated IS NOT NULL
			BEGIN
				-- Código de error 500051 si no se encontró el puesto
				SET @outResultCode = 500051;
				SELECT @outResultCode AS outResultCode;
				RETURN;
			END

        -- Actualizar solo si se proporciona al menos un campo
        IF @cedula_updated IS NOT NULL OR @name_updated IS NOT NULL OR @idPuesto IS NOT NULL OR @isActive IS NOT NULL
        BEGIN
			BEGIN TRANSACTION update_employee;
            UPDATE [dbo].[Empleado]
            SET 
                ValorDocumentoIdentidad = COALESCE(@cedula_updated, ValorDocumentoIdentidad), -- Si @cedula no es NULL, actualiza
                Nombre = COALESCE(@name_updated, Nombre), -- Si @name no es NULL, actualiza
                idPuesto = COALESCE(@idPuesto, idPuesto), -- Si @idPuesto no es NULL, actualiza
				EsActivo = COALESCE(@isActive, EsActivo) 
            WHERE id = @idEmpleado;

            -- Si la actualización fue exitosa, retornamos éxito
            SET @outResultCode = 0; -- Éxito
			SELECT @outResultCode AS outResultCode;
			COMMIT TRANSACTION update_employee;
        END
        
    END TRY
    BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION update_employee;
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
END;

--DECLARE @resultado INT;

--EXEC SP_Update_Employee 
--    @cedula = '1234567829', -- Cédula actual del empleado
    --@cedula_updated = '1234567829', -- Nueva cédula, si deseas actualizarla
    --@name_updated = 'Juan Gerardo', -- Nuevo nombre, si deseas actualizarlo
--	@nombrePuesto_updated = 'ls', -- Nuevo puesto, si deseas actualizarlo
--    @outResultCode = @resultado OUTPUT;

-- Imprimir el código de resultado
--PRINT @resultado;


--Procedimiento almacenado Delete Employee
CREATE PROCEDURE SP_Delete_Employee
(
    @cedulaDeleted NVARCHAR(50), 
    @outResultCode INT OUTPUT -- Parámetro de salida para el estado del request
)
AS
BEGIN
	EXEC SP_Update_Employee 
		@cedula = @cedulaDeleted,
		@isActive = 0,
		@outResultCode = @outResultCode OUTPUT;
	SELECT @outResultCode
END;


--DECLARE @resultado INT;
--EXEC SP_Delete_Employee 
--    @cedulaDeleted = '987654321', 
--    @outResultCode = @resultado OUTPUT;
--PRINT @resultado;

--Procedimiento almacenado consultar empleado
CREATE PROCEDURE SP_Get_Employee
(
    @cedula NVARCHAR(50), -- Parámetro de entrada: Valor del documento de identidad (cédula)
    @outResultCode INT OUTPUT -- Parámetro de salida para el estado del request
)
AS
BEGIN
    BEGIN TRY
        -- Seleccionamos los detalles del empleado
        SELECT 
            e.ValorDocumentoIdentidad AS Cedula,
            e.Nombre AS NombreEmpleado,
            p.Nombre AS NombrePuesto,
            e.SaldoVacaciones
        FROM Empleado e
        INNER JOIN Puesto p ON e.idPuesto = p.id
        WHERE e.ValorDocumentoIdentidad = @cedula;

        SET @outResultCode = 0; -- 0: Éxito
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION update_employee;
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
END;

--DECLARE @resultado INT;
--EXEC SP_Get_Employee 
--    @cedula = '987654321', 
--    @outResultCode = @resultado OUTPUT;
--PRINT @resultado;