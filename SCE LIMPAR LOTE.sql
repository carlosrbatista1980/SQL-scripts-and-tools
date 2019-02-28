
/*******************************************
            CARLOS 17-01-2018
Limpa as tabelas de Lote e LoteInutNFe
Compacta o banco de dados automaticamente
*******************************************/
USE NFE

-- CONTADOR DE LINHAS DELETADAS
DECLARE @Deleted_Rows INT;
SET @Deleted_Rows = 1;

-- PEGA A DATA MENOR QUE 3 MESES 
DECLARE @DATA AS DATETIME;
SET @DATA = DATEADD(MONTH,-3,GETDATE());

-- SE EXISTIR REGISTROS ÁPTOS EU APAGO, SENÃO NEM PERCO TEMPO
IF EXISTS (SELECT TOP(1) DtTransmissao FROM Lote WHERE (Lote.DtTransmissao < @DATA))
BEGIN
BEGIN TRANSACTION
	WHILE (@Deleted_Rows > 0)
		BEGIN
			DELETE TOP(2000) FROM Lote -- APAGO 2000 LINHAS POR VEZ 
			WHERE (Lote.DtTransmissao < @DATA AND Lote.fgTransmitido = 1 AND Lote.fgConfirmado = 1) OR (Lote.DtTransmissao < @DATA AND Lote.fgTransmitido = 0)
			SET @Deleted_Rows = @@ROWCOUNT;
		END
COMMIT TRANSACTION
END

-- DELETANDO APENAS REGISTROS COM INUTILIZAÇÃO REJEITADA
SET @Deleted_Rows = 1;
BEGIN TRANSACTION		
	WHILE (@Deleted_Rows > 0)
		BEGIN
			DELETE TOP(2000) FROM LoteInutNFe -- 
			WHERE (LoteInutNFe.fgInut = 1 AND [cStat] <> 102)
			SET @Deleted_Rows = @@ROWCOUNT;						
		END
COMMIT TRANSACTION
