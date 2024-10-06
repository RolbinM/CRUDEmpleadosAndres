CREATE OR ALTER PROCEDURE listadoEmpleados
(
	@inValorDocIdentidad NVARCHAR(50) = NULL
	, @inNombre NVARCHAR(100) = NULL
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
			  emp.[id]
			, emp.[idPuesto]
			, p.Nombre as NombrePuesto
			, p.SalarioxHora as SalarioxHora
			, emp.[ValorDocumentoIdentidad]
			, emp.[Nombre]
			, emp.[FechaContratacion]
			, emp.[SaldoVacaciones]
			, emp.[EsActivo]
		  FROM [dbo].[Empleado] emp
		  INNER JOIN [dbo].[Puesto] p
		  on p.id = emp.idPuesto
		  WHERE 
            (@inValorDocIdentidad IS NULL OR emp.ValorDocumentoIdentidad = @inValorDocIdentidad)
            AND (@inNombre IS NULL OR emp.Nombre LIKE '%' + @inNombre + '%');


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

-- Código que debe invocar la capa lógica
-- EXEC listadoEmpleados @inNombre='Kait', @outResultCode=50008;

-- SELECT * FROM [dbo].[Empleado] WHERE ValorDocumentoIdentidad = '6993943';