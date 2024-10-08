



CREATE OR ALTER PROCEDURE insertarMovimiento
(
@inValorDocIdentidad NVARCHAR(50)
, @inTipoMovimiento NVARCHAR(100)
, @inMonto DECIMAL(18, 2)
, @inUsername NVARCHAR(50) 
, @inPostInIP NVARCHAR(50)
, @outResultCode INT OUTPUT
)
AS
BEGIN
    -- Buena práctica: Evitar el envío de mensajes de recuento de filas
    SET NOCOUNT ON;

BEGIN TRY
	
	DECLARE @TipoAccion VARCHAR(16)
	DECLARE @SaldoVacaciones DECIMAL

	SELECT
		@outResultCode = 0


	-- Obtenemos Tipo de Accion
	SELECT 
		@TipoAccion = TipoAccion
	FROM dbo.TipoMovimiento
	WHERE
		Nombre = @inTipoMovimiento
	
	-- Obtenemos Saldo Vacaciones del empleado
	SELECT 
		@SaldoVacaciones = SaldoVacaciones
	FROM dbo.Empleado
	WHERE
		ValorDocumentoIdentidad = @inValorDocIdentidad

	-- Retornamos 50011 si el monto de vacaciones - el monto solicitado es negativo
	SELECT
		@outResultCode = 50011
	WHERE
		@TipoAccion = 'Debito'
		AND @SaldoVacaciones - @inMonto <0
	
	IF @outResultCode = 0
	BEGIN
		BEGIN TRANSACTION CargarMovimiento

			-- Seccion que resta el valor del monto si el tipo es Debito
			INSERT INTO [dbo].[Movimiento] (
					idEmpleado,
					idTipoMovimiento,
					Fecha,
					Monto,
					NuevoSaldo,
					idPostByUser,
					PostInIP,
					PostTime
			)
			SELECT
					E.id AS idEmpleado,
					T.id AS idTipoMovimiento,
					GETDATE() AS Fecha,
					@inMonto AS Monto,
					E.SaldoVacaciones - @inMonto AS NuevoSaldo,
					U.id AS idPostByUser,
					@inPostInIP AS PostInIP,
					GETDATE() AS PostTime
			FROM [dbo].[Empleado] E
			INNER JOIN [dbo].[TipoMovimiento] T ON T.Nombre = @inTipoMovimiento
			INNER JOIN [dbo].[Usuario] U ON U.Username = @inUsername
			WHERE E.ValorDocumentoIdentidad = @inValorDocIdentidad
			AND @TipoAccion = 'Debito'

			UPDATE Empleado
			SET SaldoVacaciones -= @inMonto
			WHERE ValorDocumentoIdentidad = @inValorDocIdentidad
			AND @TipoAccion = 'Debito'
	




			-- Seccion que suma el saldo al movimiento y empleado si es de tipo Credito
			INSERT INTO [dbo].[Movimiento] (
					idEmpleado,
					idTipoMovimiento,
					Fecha,
					Monto,
					NuevoSaldo,
					idPostByUser,
					PostInIP,
					PostTime
			)
			SELECT
					E.id AS idEmpleado,
					T.id AS idTipoMovimiento,
					GETDATE() AS Fecha,
					@inMonto AS Monto,
					E.SaldoVacaciones + @inMonto AS NuevoSaldo,
					U.id AS idPostByUser,
					@inPostInIP AS PostInIP,
					GETDATE() AS PostTime
			FROM [dbo].[Empleado] E
			INNER JOIN [dbo].[TipoMovimiento] T ON T.Nombre = @inTipoMovimiento
			INNER JOIN [dbo].[Usuario] U ON U.Username = @inUsername
			WHERE E.ValorDocumentoIdentidad = @inValorDocIdentidad
			AND @TipoAccion = 'Credito'

			UPDATE Empleado
			SET SaldoVacaciones += @inMonto
			WHERE ValorDocumentoIdentidad = @inValorDocIdentidad
			AND @TipoAccion = 'Credito'
		
			SET @outResultCode = 0

		COMMIT TRANSACTION CargarMovimiento
	END

	SELECT @outResultCode AS outResultCode;
END TRY

BEGIN CATCH
	IF @@TRANCOUNT > 0
	BEGIN
		ROLLBACK TRANSACTION CargarMovimiento;
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

/*

SELECT * FROM Empleado WHERE VALORDOCUMENTOIDENTIDAD = '123465'
SELECT * FROM Movimiento WHERE idEmpleado = 1

EXEC insertarMovimiento '123465', 'Cumplir mes', 5, 'zkelly', 0, 0;



*/

