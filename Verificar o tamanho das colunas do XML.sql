/************************************
        CARLOS 10/02/2011
************************************/


USE	NFe
/*
Select SUM(DATALENGTH(XmlProcNFe)) / 1024 AS XmlProcNFe_KB
,SUM(DATALENGTH(xmlRetornoLote)) / 1024 AS xmlRetornoLote_KB
,SUM(DATALENGTH(xmlRetornoConfirmacao)) / 1024 AS xmlRetornoConfirmacao_KB
FROM NFe
INNER JOIN Lote as l ON NFe.IdLote = l.IdLote
*/

Select 
CAST(SUM(DATALENGTH(XmlProcNFe)) /1024 AS DECIMAL(18,2)) AS [NFe.XmlProcNFe em KB]
FROM NFe

Select 
CAST(SUM(DATALENGTH(xmlRetornoLote)) / 1024 AS DECIMAL(18,2)) AS [Lote_xmlRetornoLote em KB]
,CAST(SUM(DATALENGTH(xmlRetornoConfirmacao)) / 1024 AS DECIMAL(18,2)) AS [Lote_xmlRetornoConfirmacao em KB] 
,CAST(SUM(DATALENGTH(xmlLote)) / 1024 AS DECIMAL(18,2)) AS [Lote_xmlLote em KB]
FROM Lote


