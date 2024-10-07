

-- Obtener Tipos Movimientos
CREATE OR ALTER PROCEDURE dbo.SP_Listar_Tipos_Movimientos
AS
BEGIN

	SELECT
		Nombre,
		TipoAccion
	FROM dbo.TipoMovimiento

END
