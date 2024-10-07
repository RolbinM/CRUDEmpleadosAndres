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

    -- Se realiza el INSERT solo si el NuevoSaldo es positivo
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
        AND (E.SaldoVacaciones + @inMonto) > 0; -- Verifica que el nuevo saldo sea positivo
		UPDATE Empleado
			SET SaldoVacaciones += @inMonto
			WHERE ValorDocumentoIdentidad = @inValorDocIdentidad;
		 

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

/*

SELECT * FROM Empleado;

EXEC insertarMovimiento '6993943', 'Cumplir mes', -40, 'zkelly', 0, 0;

SELECT * FROM Movimiento WHERE idEmpleado = 1;

*/