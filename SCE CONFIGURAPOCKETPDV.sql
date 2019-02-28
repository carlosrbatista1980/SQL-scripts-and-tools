/*******************************************
            CARLOS 29-10-2014
	Configurar o Banco PocketPDV
*******************************************/

USE [master]
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = N'sce')
	BEGIN
		CREATE LOGIN [sce] WITH PASSWORD=N'627311', DEFAULT_DATABASE=[master],DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
		EXEC master..sp_addsrvrolemember @loginame = N'sce', @rolename = N'sysadmin'
	END
ELSE
	BEGIN
		EXEC master..sp_addsrvrolemember @loginame = N'sce', @rolename = N'sysadmin'
	END
GO
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = N'PocketPDV')
	BEGIN
		CREATE LOGIN [PocketPDV] WITH PASSWORD=N'627311', DEFAULT_DATABASE=[PocketPDV],DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
		EXEC master..sp_addsrvrolemember @loginame = N'PocketPDV', @rolename = N'sysadmin'
		EXEC sp_addrolemember N'db_owner', N'PocketPDV'
	END
	


----- Habilitar o Linked server (O SERVIÇO MSSQLSERVER DEVE ESTAR CONFIGURADO COMO CONTA LOCAL)
USE MASTER

DECLARE @IsX64 VARCHAR(255)
DECLARE @amfdados varchar(255) SET @amfdados = '4.1\Database\amfdados 2000.mdb'
DECLARE @datapath varchar(255)
DECLARE @systemdb varchar(255) SET @systemdb = '4.1\Support\ArquivosComuns\Sysamg.mdw'

IF NOT EXISTS (SELECT name FROM sys.servers where name = 'AMFDADOS')
	BEGIN	
		--EXEC sp_dropserver @server=N'AMFDADOS', @droplogins='droplogins'		
		EXEC master..xp_regread
		'HKEY_LOCAL_MACHINE',
		'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
		'PROCESSOR_ARCHITECTURE',
		@IsX64 OUTPUT
				
		IF @IsX64 = 'X86'
			BEGIN
				EXEC master..xp_regread
				'HKEY_LOCAL_MACHINE',
				'SOFTWARE\SCE\SCEExec\AutoMagazine', --'SOFTWARE\Wow6432Node\SCE\SCEExec\AutoMagazine',
				'NetworkDir',
				@datapath OUTPUT

				DECLARE @fullpathX86 varchar(255) SET @fullpathX86 = @datapath + @amfdados				
				DECLARE @fullsystemdbPathX86 varchar(255) SET @fullsystemdbPathX86 = @datapath + @systemdb
				
				EXEC sp_addlinkedserver 
				   @server = 'AMFDADOS',
				   @provider = 'Microsoft.Jet.OLEDB.4.0', 
				   @srvproduct = 'OLE DB Provider for Jet',
				   @datasrc = @fullpathX86

				--(O SERVIÇO MSSQLSERVER DEVE ESTAR CONFIGURADO COMO CONTA LOCAL)
				EXEC master..xp_regwrite
					 @rootkey='HKEY_LOCAL_MACHINE',
					 @key='SOFTWARE\Microsoft\Jet\4.0\Engines', --@key='SOFTWARE\Wow6432Node\Microsoft\Jet\4.0\Engines',
					 @value_name='SystemDB',
					 @type='REG_SZ',
					 @value= @fullsystemdbPathX86
			END
		ELSE
			BEGIN
				EXEC master..xp_regread
				'HKEY_LOCAL_MACHINE',
				'SOFTWARE\Wow6432Node\SCE\SCEExec\AutoMagazine',
				'NetworkDir',
				@datapath OUTPUT

				DECLARE @fullpathX64 varchar(255) SET @fullpathX64 = @datapath + @amfdados				
				DECLARE @fullsystemdbPathX64 varchar(255) SET @fullsystemdbPathX64 = @datapath + @systemdb
				
				EXEC sp_addlinkedserver 
				   @server = 'AMFDADOS',
				   @provider = 'Microsoft.Jet.OLEDB.4.0', 
				   @srvproduct = 'OLE DB Provider for Jet',
				   @datasrc = @fullpathX64

				--(O SERVIÇO MSSQLSERVER DEVE ESTAR CONFIGURADO COMO CONTA LOCAL)
				EXEC master..xp_regwrite
					 @rootkey='HKEY_LOCAL_MACHINE',
					 @key='SOFTWARE\Wow6432Node\Microsoft\Jet\4.0\Engines',
					 @value_name='SystemDB',
					 @type='REG_SZ',
					 @value= @fullsystemdbPathX64
			END

END

IF EXISTS (SELECT name FROM sys.servers where name = 'AMFDADOS')
	BEGIN
		EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'AMFDADOS', @locallogin = NULL , @useself = N'False', @rmtuser = N'sce leitura', @rmtpassword = N''
		GO
		EXEC master.dbo.sp_serveroption @server=N'AMFDADOS', @optname=N'collation name', @optvalue=N'Latin1_General_CI_AS'
		GO
		EXEC master.dbo.sp_serveroption @server=N'AMFDADOS', @optname=N'collation compatible', @optvalue=N'false'
		GO
		EXEC master.dbo.sp_serveroption @server=N'AMFDADOS', @optname=N'data access', @optvalue=N'true'
		GO
		EXEC master.dbo.sp_serveroption @server=N'AMFDADOS', @optname=N'rpc', @optvalue=N'false'
		GO
		EXEC master.dbo.sp_serveroption @server=N'AMFDADOS', @optname=N'rpc out', @optvalue=N'false'
		GO
		EXEC master.dbo.sp_serveroption @server=N'AMFDADOS', @optname=N'connect timeout', @optvalue=N'0'
		GO
		EXEC master.dbo.sp_serveroption @server=N'AMFDADOS', @optname=N'query timeout', @optvalue=N'0'
		GO
		EXEC master.dbo.sp_serveroption @server=N'AMFDADOS', @optname=N'use remote collation', @optvalue=N'true'		
	END
     