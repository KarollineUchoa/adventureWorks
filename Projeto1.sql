--Apagando a tabela anterior par adição de novas colunas
DROP TABLE IF EXISTS tabela_final;

--criando a cte
WITH 
tabela_sales as (
	SELECT
		SalesOrderNumber,
		Quantity,
		EmployeeKey,
		ResellerKey,
		SalesTerritoryKey,
		ProductKey,
		CAST(REPLACE(REPLACE(Unit_Price, '$', ''), ',', '') AS float) as Unit_Price,
		CAST(REPLACE(REPLACE(Sales, '$', ''), ',', '') AS float) as Sales,
		CAST(REPLACE(REPLACE(Cost, '$', ''), ',', '') AS float) as Cost,
		CAST(CAST(REPLACE(REPLACE(Sales, '$', ''), ',', '') AS float) - 
			CAST(REPLACE(REPLACE(Cost, '$', ''), ',', '') AS float) AS float) AS Lucro,
		CAST(OrderDate AS DATE) as OrderDate,
		CAST(FORMAT(OrderDate, 'yyyyMM') as int) as Ano_Mes_Sale
	FROM Sales
),

tabela_sales_person as (
	SELECT
		Salesperson,
		Title,
		EmployeeID,
		CAST(EmployeeKey AS INT) as EmployeeKey
	FROM  Salesperson
),

tabela_targets as (
	SELECT
		CAST(EmployeeID AS INT) as EmployeeID,
		CAST(REPLACE(REPLACE(REPLACE(Target, '$', ''), '.', ''), ',', '') AS int) as Target,
		CAST(TargetMonth AS DATE) as TargetMonth,
		CAST(FORMAT(TargetMonth, 'yyyyMM') as int) as Ano_Mes_Target
	FROM Targets
),

tabela_reseller as (
	SELECT *
	FROM Reseller
),

tabela_region as (
	SELECT
		Region,
		CAST(SalesTerritoryKey AS int) as SalesTerritoryKey
	FROM Region
),

tabela_product as (
	SELECT
		ProductKey,
		REPLACE(REPLACE(Product, Color, ''),'-', '') AS Product,
		Color,
		Subcategory,
		Category,
		CAST(REPLACE(REPLACE(Standard_Cost, '$', ''), ',', '') AS float) as Standard_Cost
	FROM Product
),

cte_tabela_final as(
SELECT
	ts.*,
	tsp.EmployeeID,
	tsp.Salesperson,
	tsp.Title,
	tt.Target,
	tt.TargetMonth,
	tt.Ano_Mes_Target,
	tab_ress.Business_Type,
	tab_ress.Reseller,
	tab_ress.City,
	tab_ress.State_Province,
	tab_ress.Country_Region,	
	treg.Region,
	tp.Product,
	tp.Standard_Cost,
	tp.Color,
	tp.Subcategory,
	tp.Category
FROM tabela_sales ts
LEFT JOIN tabela_sales_person tsp
ON ts.EmployeeKey = tsp.EmployeeKey
LEFT JOIN tabela_targets tt
ON tsp.EmployeeID = tt.EmployeeID AND
	ts.Ano_Mes_Sale = tt.Ano_Mes_Target
LEFT JOIN tabela_reseller tab_ress
ON ts.ResellerKey = tab_ress.ResellerKey
LEFT JOIN tabela_region treg
ON ts.SalesTerritoryKey = treg.SalesTerritoryKey
LEFT JOIN tabela_product tp
ON ts.ProductKey = tp.ProductKey
)

--criando novamente a tabela_final a partir da CTE
SELECT * INTO tabela_final FROM cte_tabela_final
