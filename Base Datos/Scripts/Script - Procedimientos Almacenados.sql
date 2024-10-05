
USE BD1_TP2 

GO


-- Querys con procedimientos almacenados

-- Obtener Puestos
CREATE OR ALTER PROCEDURE dbo.proc_ObtenerPuestos
AS
BEGIN

	SELECT
		Id,
		Nombre,
		SalarioxHora
	FROM dbo.Puesto

END


GO


CREATE OR ALTER PROCEDURE dbo.proc_ObtenerEmpleados    -- Agregar Filtros
AS
BEGIN
		
	SELECT
		EMP.id,
		P.id,
		P.Nombre,
		P.SalarioxHora,
		EMP.ValorDocumentoIdentidad,
		EMP.Nombre,
		EMP.FechaContratacion,
		EMP.SaldoVacaciones,
		EMP.EsActivo
	FROM dbo.Empleado EMP
	INNER JOIN dbo.Puesto P
	ON P.id = EMP.idPuesto

END










