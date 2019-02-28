/*******************************************
            CARLOS 29-10-2014
	Recupera Banco Suspect
*******************************************/

--SELECT TOP(1) database_id, name, user_access_desc, state_desc, recovery_model_desc from sys.databases WHERE name = 'NFE'
-- 

RAISERROR ('Processo iniciado em:',0,1)  
PRINT N''+RTRIM(CAST(GETDATE() AS NVARCHAR(30))) 
WAITFOR DELAY '00:00:02'

IF EXISTS (SELECT TOP(1) name from sys.databases WHERE name = 'NFE')
BEGIN
EXEC sp_resetstatus NFe;
ALTER DATABASE NFe SET EMERGENCY
--
RAISERROR ('Banco de dados em Emergencia',0,1) 
--
ALTER DATABASE NFe SET SINGLE_USER WITH ROLLBACK IMMEDIATE
--
DBCC CheckDB ('NFe', REPAIR_ALLOW_DATA_LOSS)
RAISERROR ('Checando o Banco',0,1) 
WAITFOR DELAY '00:00:02'
--
END
GO
ALTER DATABASE NFe SET MULTI_USER
-----------------------------------
IF (Select DATABASEPROPERTYEX ( 'NFE' , 'UserAccess' )) <> 'MULTI_USER'
BEGIN
ALTER DATABASE NFE SET MULTI_USER;
RAISERROR ('Processo finalizado em:',0,1)  
PRINT N''+RTRIM(CAST(GETDATE() AS NVARCHAR(30))) 
WAITFOR DELAY '00:00:02'
END
GO
DBCC SHRINKDATABASE('NFe', TRUNCATEONLY)
GO
PRINT N'Processo Finalizado!' + RTRIM(CAST(GETDATE() AS NVARCHAR(30)))

