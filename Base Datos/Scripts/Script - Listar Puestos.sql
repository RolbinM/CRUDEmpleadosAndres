
-- Obtener Puestos
CREATE OR ALTER PROCEDURE dbo.SP_Listar_Puestos
AS
BEGIN

	SELECT
		Id,
		Nombre,
		SalarioxHora
	FROM dbo.Puesto

END










