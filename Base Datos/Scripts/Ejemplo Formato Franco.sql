



-- Estandar que usaba franco en mis tiempos

CREATE OR ALTER PROCEDURE [dbo].[sp_InsertarReceta]
	@inNombre NVARCHAR(64),
	@inidArea INT,
	@inidSubArea INT,
	@indescripcion VARCHAR(400),
	@inImagen VARCHAR(MAX),

-- parametros de salida
	@OutResultCode INT OUTPUT
	
	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SELECT
				@OutResultCode=0  -- codigo de ejecucion exitoso

			IF EXISTS (SELECT 1 FROM dbo.departamento WHERE idDepartamento = @inidArea)
			BEGIN
				IF EXISTS (SELECT 1 FROM dbo.subDepartamento WHERE idSubDepartamento = @inidSubArea)
				BEGIN
					INSERT INTO dbo.receta
					(
						nombre,
						idArea,
						idSubarea,
						descripcion,
						imagenes
					)
					VALUES 
					(
						@inNombre,
						@inidArea,
						@inidSubArea,
						@indescripcion,
						@inImagen
					)
				END
			END
		END TRY
		BEGIN CATCH


		INSERT INTO dbo.Errores VALUES(
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_PROCEDURE(),
			ERROR_LINE(),
			ERROR_MESSAGE(),
			GETDATE()
		)

		SET @OutResultCode = 501;				-- No se inserto en la tabla

		END CATCH

		SELECT
				@OutResultCode
	SET NOCOUNT OFF;
END

