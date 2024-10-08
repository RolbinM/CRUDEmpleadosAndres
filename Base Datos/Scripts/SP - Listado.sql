CREATE OR ALTER PROCEDURE listadoEmpleados
(
	@inValorDocIdentidad NVARCHAR(50) = NULL
	, @inNombre NVARCHAR(100) = NULL
	, @outResultCode INT OUTPUT
)
AS
BEGIN
    -- Buena pr�ctica: Evitar el env�o de mensajes de recuento de filas
    SET NOCOUNT ON;

    -- Manejo de excepciones
    BEGIN TRY
		SET @outResultCode = 0;

		SELECT
			  [id]
			, [idPuesto]
			, [ValorDocumentoIdentidad]
			, [Nombre]
			, [FechaContratacion]
			, [SaldoVacaciones]
			, [EsActivo]
		  FROM [dbo].[Empleado]
		  WHERE 
            (@inValorDocIdentidad IS NULL OR [ValorDocumentoIdentidad] = @inValorDocIdentidad)
            AND (@inNombre IS NULL OR [Nombre] LIKE '%' + @inNombre + '%');


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

-- C�digo que debe invocar la capa l�gica
-- EXEC listadoEmpleados @inNombre='Kait', @outResultCode=50008;

-- SELECT * FROM [dbo].[Empleado] WHERE ValorDocumentoIdentidad = '6993943';