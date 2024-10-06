CREATE OR ALTER PROCEDURE listadoMovimientos
(
	@inValorDocIdentidad NVARCHAR(50) = NULL
	, @outResultCode INT OUTPUT
)
AS
BEGIN
    -- Buena práctica: Evitar el envío de mensajes de recuento de filas
    SET NOCOUNT ON;

    -- Manejo de excepciones
    BEGIN TRY
		SET @outResultCode = 0;

		SELECT
			[idEmpleado]
			, E.Nombre
			, E.ValorDocumentoIdentidad
			, [Fecha]
			, [Monto]
			, T.Nombre
			, [NuevoSaldo]
			, U.Username
			, [PostInIP]
			, [PostTime]
		  FROM [dbo].[Movimiento]
		  INNER JOIN Empleado E ON @inValorDocIdentidad = E.ValorDocumentoIdentidad
		  INNER JOIN TipoMovimiento T ON idTipoMovimiento = T.id
		  INNER JOIN Usuario U ON idPostByUser = U.id
		  WHERE idEmpleado = E.id
		  ORDER BY PostTime DESC;


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

EXEC listadoMovimientos @inValorDocIdentidad='6993943', @outResultCode=50008;

*/