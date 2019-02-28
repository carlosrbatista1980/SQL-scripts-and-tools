
/************************************
        CARLOS 10/10/2016
************************************/

USE NFe -- mude o nome do banco como quiser
--select * from sys.objects where name = '#temp'
--DROP TABLE #temp

Print N'Inicio do processo: '+ convert(Varchar(100), (getdate()), 121)
IF EXISTS (select * from sys.objects where name = '#temp')
BEGIN
DROP TABLE #temp
END

declare @ini as DATETIME set @ini = Getdate()
declare @fin as DATETIME 
CREATE TABLE #temp (
table_name sysname,
row_count INT,
reserved_size VARCHAR(50),
data_size VARCHAR(50),
index_size VARCHAR(50),
unused_size VARCHAR(50)
) SET NOCOUNT ON
INSERT #temp
EXEC sp_msforeachtable 'sp_spaceused ''?'''
SELECT a.table_name as [Nome da Tabela],
a.row_count [Numero de Linhas],
COUNT(*) AS [Numero de Colunas],
a.data_size as [Tamanho em KB]
FROM #temp a
INNER JOIN information_schema.columns b ON a.table_name collate database_default = b.table_name collate database_default
GROUP BY a.table_name, a.row_count, a.data_size
ORDER BY CAST(REPLACE((a.data_size), ' KB', '') AS integer) DESC
--SET @fin = Getdate()
--Print N'Duração: '+ convert(Varchar(100), (Getdate() - @ini), 121)
Print N'Duração em millisegundos: '+ Convert(Varchar(1000),Datediff(ms,@ini, Getdate()))
DROP TABLE #temp
