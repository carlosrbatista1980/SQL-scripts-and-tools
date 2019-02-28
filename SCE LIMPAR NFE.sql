/****************************
	Carlos 05/09/2018
Deleta todas as notas fiscais anteriores
a 6 meses.
*****************************/
USE NFE
BEGIN TRANSACTION
	SET QUOTED_IDENTIFIER ON
	SET ARITHABORT ON
	SET NUMERIC_ROUNDABORT OFF
	SET CONCAT_NULL_YIELDS_NULL ON
	SET ANSI_NULLS ON
	SET ANSI_PADDING ON
	SET ANSI_WARNINGS ON
COMMIT

BEGIN TRANSACTION
GO
ALTER TABLE dbo.NFSe
	DROP CONSTRAINT FK_NFSe_NFe
GO
COMMIT
---------
BEGIN TRANSACTION
GO
ALTER TABLE dbo.NFe
	DROP CONSTRAINT FK_NFe_Lote
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.NFeCloudQueue
	DROP CONSTRAINT FK_NFeCloudQueue_NFe
GO
ALTER TABLE dbo.NFe WITH NOCHECK ADD CONSTRAINT
	FK_NFe_Lote FOREIGN KEY
	(
	IdLote
	) REFERENCES dbo.Lote
	(
	IdLote
	) ON UPDATE  NO ACTION 
	 ON DELETE  CASCADE 
	
GO
ALTER TABLE dbo.NFe
	NOCHECK CONSTRAINT FK_NFe_Lote
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.NFeCloudQueue ADD CONSTRAINT
	FK_NFeCloudQueue_NFe FOREIGN KEY
	(
	IdInternoNFe
	) REFERENCES dbo.NFe
	(
	IdInternoNFe
	) ON UPDATE  NO ACTION 
	 ON DELETE  CASCADE 
	
GO
COMMIT

BEGIN TRANSACTION
GO
ALTER TABLE dbo.NFSe ADD CONSTRAINT
	FK_NFSe_NFe FOREIGN KEY
	(
	IdInternoNFe
	) REFERENCES dbo.NFe
	(
	IdInternoNFe
	) ON UPDATE  NO ACTION 
	 ON DELETE  CASCADE 	
GO
COMMIT
--------------
USE NFE
DECLARE @Deleted_Rows INT;
DECLARE @Deleted_Regs INT;
DECLARE @DATA AS DATETIME;
DECLARE @EMITENTE AS VARCHAR(MAX)
DECLARE @STRING AS VARCHAR(MAX)
SET @DATA = DATEADD(MONTH,-6,GETDATE()); -- pega 6 meses anteriores.
SET @EMITENTE = (SELECT TOP (1) [RazaoSocial] FROM DadosEmitente)
SET @STRING = @EMITENTE + ' DELETANDO NOTAS FISCAIS ANTERIORES A: ' + CONVERT(VARCHAR, @DATA, 103)
SET @Deleted_Rows = 1;
SET @Deleted_Regs = 0;

BEGIN TRANSACTION
	IF EXISTS (SELECT TOP(1) [RazaoSocial] FROM [DadosEmitente] WHERE ([RazaoSocial] LIKE '%LOJAS%CITYCOL%'))
	BEGIN
		RAISERROR ('� CITYCOL!, DELETANDO APENAS NOTAS FISCAIS QUE JA TENHAM SIDO ENVIADAS PARA A NUVEM',0,1) WITH NOWAIT
		BEGIN TRANSACTION		
			WHILE (@Deleted_Rows > 0)
				BEGIN
					DELETE TOP(2000) FROM NFE
					WHERE (NFE.DtEmissaoNFe < @DATA and BackupCloud = 1)
					SET @Deleted_Rows = @@ROWCOUNT; -- Precisa existir para que o WHILE funcione.
					SET @Deleted_Regs = @Deleted_Regs + @Deleted_Rows -- apenas acumula as linhas deletadas (pode apagar).
				END
		COMMIT TRANSACTION
	END
	ELSE	
	BEGIN
		RAISERROR(@STRING, 0, 1) WITH NOWAIT
		BEGIN TRANSACTION		
		SET @Deleted_Rows = 1;
			WHILE (@Deleted_Rows > 0)
				BEGIN
					DELETE TOP(2000) FROM NFE
					WHERE (NFE.DtEmissaoNFe < @DATA)
					SET @Deleted_Rows = @@ROWCOUNT; -- Precisa existir para que o WHILE funcione.
					SET @Deleted_Regs = @Deleted_Regs + @Deleted_Rows -- apenas acumula as linhas deletadas (pode apagar).
				END
		COMMIT TRANSACTION
	END
COMMIT TRANSACTION
GO
-------------
USE NFE
BEGIN TRANSACTION
	SET QUOTED_IDENTIFIER ON
	SET ARITHABORT ON
	SET NUMERIC_ROUNDABORT OFF
	SET CONCAT_NULL_YIELDS_NULL ON
	SET ANSI_NULLS ON
	SET ANSI_PADDING ON
	SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.NFe
	DROP CONSTRAINT FK_NFe_Lote
GO
COMMIT
---
BEGIN TRANSACTION
GO
ALTER TABLE dbo.NFSe
	DROP CONSTRAINT FK_NFSe_NFe
GO
COMMIT
---
BEGIN TRANSACTION
GO
ALTER TABLE dbo.NFeCloudQueue
	DROP CONSTRAINT FK_NFeCloudQueue_NFe
GO
ALTER TABLE dbo.NFe WITH NOCHECK ADD CONSTRAINT
	FK_NFe_Lote FOREIGN KEY
	(
	IdLote
	) REFERENCES dbo.Lote
	(
	IdLote
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 	
GO
ALTER TABLE dbo.NFe
	NOCHECK CONSTRAINT FK_NFe_Lote
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.NFeCloudQueue ADD CONSTRAINT
	FK_NFeCloudQueue_NFe FOREIGN KEY
	(
	IdInternoNFe
	) REFERENCES dbo.NFe
	(
	IdInternoNFe
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 	
GO
COMMIT
----------
BEGIN TRANSACTION
GO
ALTER TABLE dbo.NFSe ADD CONSTRAINT
	FK_NFSe_NFe FOREIGN KEY
	(
	IdInternoNFe
	) REFERENCES dbo.NFe
	(
	IdInternoNFe
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION
GO
COMMIT

