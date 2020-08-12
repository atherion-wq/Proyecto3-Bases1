Use AdventureWorks2017

-----------------------------------------------------------------------------------------------------------------------------------Inicio de triggers
--------------------Creacion de la tabla auditoria usada en los triggers
create table Auditoria(
idAuditoria int identity(1,1) primary key,
tabla varchar(50),
Accion varchar(20),
fecha datetime,
Mensaje varchar(500)
);

---------------------Primero trigger activado en la tabla Person.Address
select * from Person.Address;

go
create trigger triggerAfterUpdate
on Person.Address
after update
as 
begin
	declare @Mensaje varchar(500)
	declare @id varchar(10)
	declare @valorViejo varchar(500)
	declare @valorNuevo varchar(500)
	declare @sqlstring nvarchar(500)

	DECLARE @Cambio as varchar(20);
	SET @Cambio = (CASE WHEN Update([AddressLine1])
						THEN 'AddressLine1'  
						WHEN Update([AddressLine2])
						THEN 'AddressLine2'
						WHEN Update([City])
						THEN 'City'
						WHEN Update([StateProvinceID])
						THEN 'StateProvinceID'
						WHEN Update([PostalCode])
						THEN 'PostalCode'
						WHEN Update([SpatialLocation])
						THEN 'SpatialLocation'
						WHEN Update([rowguid])
						THEN 'rowguid'
						WHEN Update([ModifiedDate])
						THEN 'ModifiedDate'
	END)
	select @id = [AddressID] from inserted
	select @valorViejo = @Cambio from deleted
	select @valorNuevo = @Cambio from inserted

	set @Mensaje = 'Se realizó un cambio en '+@Cambio+' se cambio el dato '+@valorNuevo+' por '+@valorNuevo+' en el fila con el identificador: '+@id+'.'
	insert into Auditoria
	values('Person.Address','Update',GETDATE(),@Mensaje)
end;



UPDATE Person.Address
SET City = 'San Jose'
WHERE [AddressID] = 1;

select * from person.Address
where [AddressID] = 1
select * from Auditoria



---------------------------------------------------------Segundo trigger activado en la tabla

go
create trigger triggerInteadOfDelete
on dbo.Auditoria
instead of delete
as 
begin
	declare @Mensaje varchar(500)
	declare @id varchar(10)
	select @id = [idAuditoria] from inserted
	set @Mensaje = 'Se intento borrar la fila con el identificador:'+@id+ ' no se realizo el borrado'
	insert into Auditoria
	values('Auditoria','Delete',GETDATE(),@Mensaje)
end;

delete 
from Auditoria
where idAuditoria = 1


---------------------------------------------------------------------------------------------------------------------------------------------------------------Cierre de triggers



---------------------------------------------------------------------------------------------------------------------------------------------------------------Inicio de cursos y tabla temporal


go
CREATE PROCEDURE getInfoProduct
AS BEGIN
		declare @id int,@Name varchar(50),@Cantidad int,@Ganancia int, @Negocios int
		declare ProductCursor cursor for 

			select Production.Product.ProductID,Production.Product.Name, Sum(quantity), (Sum(quantity)*ActualCost),
			count(Purchasing.PurchaseOrderDetail.[PurchaseOrderID]) as NegociasSinFinalizar
			from Production.Product
			inner join Production.TransactionHistory on Production.Product.ProductID = Production.TransactionHistory.ProductID
			inner join Purchasing.ProductVendor on Purchasing.ProductVendor.ProductID = Production.Product.ProductID
			inner join [Purchasing].[PurchaseOrderDetail] on [Purchasing].[PurchaseOrderDetail].ProductID = Production.Product.ProductID
			group by Production.Product.ProductID,Production.Product.Name, ActualCost

		open ProductCursor 
		fetch next from ProductCursor into @id, @Name, @Cantidad, @Ganancia,@Negocios

		CREATE TABLE #TempProducts (Id int, Nombre varchar(50), Vendidos int, GananciaTotal int, NegociosPendientes int)
		while @@FETCH_STATUS = 0

		
		begin 
			insert into #TempProducts
			values(@id, @Name, @Cantidad, @Ganancia,@Negocios)
			fetch next from ProductCursor into @id, @Name, @Cantidad, @Ganancia,@Negocios
		end 	
		close ProductCursor
		deallocate ProductCursor	

		select * 
		from #TempProducts
END;
exec getInfoProduct 

-------------------------------------------------------------------------------------------------------------------------------------------Ciere de la tabla temporal y el cursor.


-------------------------------------------------------------------------------------------------------------------------------------------Consultas dinamicas.

-----------------------------------------------------------------Primera consulta Dinamica
go 
create procedure obtenerDireccionPorCuidad(
@city varchar(75)
)
as begin
	DECLARE @sqlCommand nvarchar(1000)
	DECLARE @listaColumnas varchar(500)
	SET @listaColumnas = 'AddressID, AddressLine1, City'
	SET @sqlCommand = 'SELECT ' + @listaColumnas + ' FROM Person.Address WHERE City = @city'

	EXECUTE sp_executesql @sqlCommand, N'@city nvarchar(75)', @city = @city
end;

go
exec obtenerDireccionPorCuidad  @city = 'London'


----------------------------------------------------------------------Segunda consulta Dinamica.

go 
create procedure obtenerInfoEmpleado
as begin

	DECLARE @sqlCommand nvarchar(1000)
	DECLARE @listaColumnas varchar(500)
	declare @innerJoinHaciaPersonPerson varchar(500)
	set @innerJoinHaciaPersonPerson = ' inner join Person.Person on Person.Person.BusinessEntityID = HumanResources.Employee.BusinessEntityID'

	declare @innerJoinHaciaEmployeeDepartmentHistory varchar(500)
	set @innerJoinHaciaEmployeeDepartmentHistory = ' inner join [HumanResources].[EmployeeDepartmentHistory] on [HumanResources].[EmployeeDepartmentHistory].BusinessEntityID = HumanResources.Employee.BusinessEntityID'

	declare @innerJoinHaciaDepartment varchar(500)
	set @innerJoinHaciaDepartment = ' inner join [HumanResources].[Department] on [HumanResources].[Department].[DepartmentID] = [HumanResources].[EmployeeDepartmentHistory].DepartmentID'

	SET @listaColumnas = 'FirstName,LastName,JobTitle,Name,GroupName'
	SET @sqlCommand = 'SELECT ' + @listaColumnas + ' FROM HumanResources.Employee '+@innerJoinHaciaPersonPerson +@innerJoinHaciaEmployeeDepartmentHistory +@innerJoinHaciaDepartment
	EXECUTE sp_executesql @sqlCommand
end;

go
exec obtenerInfoEmpleado  
-------------------------------------------------------------------------Tercera Consulta Dinamica.


go 
create procedure obtenerInfoFacturasPorCliente(@idComprador int)
as begin
	DECLARE @sqlCommand nvarchar(1000)
	DECLARE @listaColumnas varchar(500)
	SET @listaColumnas = 'CustomerID,OnlineOrderFlag,SalesPersonID,TotalDue'
	SET @sqlCommand = 'SELECT ' + @listaColumnas + ' FROM Sales.SalesOrderHeader WHERE CustomerID = @idComprador'
	EXECUTE sp_executesql @sqlCommand, N'@idComprador int', @idComprador = @idComprador
end;


go
exec obtenerInfoFacturasPorCliente @idComprador = 29497
-----------------------------------------------------------------------Cuarta Consulta Dinamica.

go 
create procedure obtenerInfoFactura
as begin
	DECLARE @sqlCommand nvarchar(2000)
	DECLARE @listaColumnas varchar(1000)

	declare @innerJoinHaciaSalesCustomer varchar(500)
	set @innerJoinHaciaSalesCustomer = ' inner join Sales.Customer on Sales.SalesOrderHeader.CustomerID = Sales.Customer.CustomerID'

	declare @innerJoinHaciaSalesSalesTerritory varchar(500)
	set @innerJoinHaciaSalesSalesTerritory = ' inner join  Sales.SalesTerritory on  Sales.SalesTerritory.TerritoryID = Sales.Customer.TerritoryID'

	declare @innerJoinHaciaPersonBusinessEntityContact varchar(500)
	set @innerJoinHaciaPersonBusinessEntityContact = ' inner join  Person.BusinessEntityContact on Person.BusinessEntityContact.PersonID = sales.Customer.PersonID'

	declare @innerJoinHaciaPersonPerson varchar(500)
	set @innerJoinHaciaPersonPerson = ' inner join Person.Person on Person.Person.BusinessEntityID = Person.BusinessEntityContact.PersonID'

	declare @innerJoinHaciaPurchasingShipMethod varchar(500)
	set @innerJoinHaciaPurchasingShipMethod = ' inner join Purchasing.ShipMethod on Purchasing.ShipMethod.ShipMethodID = Sales.SalesOrderHeader.ShipMethodId'

	SET @listaColumnas = 'Purchasing.ShipMethod.Name as MetodoDeEnvio,SalesOrderNumber,SubTotal,TaxAmt, Sales.SalesTerritory.Name as Territorio,(person.Person.FirstName + Person.Person.LastName) as Clente'
	SET @sqlCommand = 'SELECT ' + @listaColumnas + ' FROM Sales.SalesOrderHeader'+@innerJoinHaciaSalesCustomer +@innerJoinHaciaSalesSalesTerritory+@innerJoinHaciaPersonBusinessEntityContact+
	@innerJoinHaciaPersonPerson+@innerJoinHaciaPurchasingShipMethod
	EXECUTE sp_executesql @sqlCommand
end;

go
exec obtenerInfoFactura 



-------------------------------------------------------------------------------------------------------------------------------------------------Fin de las consultas dinamicas
-------------------------------------------------------------------------------------------------------------------------------------------------Comienzo de las Funciones

-----------------------------------------------------------------------------Primera Función (tabla)
go
create function DatosDelProducto()
 returns @TablaARetornar table
 (ProductID int,
  Name varchar(100),
  ProductNumber varchar(100),
  Color varchar(50),
  SafetyStockLevel money,
  StandardCost money,
  ListPrice money,
  Size varchar(5),
  Weight decimal,
  DaysToManufacture int
 )
 as
 begin
	insert into @TablaARetornar
		select Production.Product.ProductID ,Production.Product.Name,Production.Product.ProductNumber,Production.Product.Color,Production.Product.SafetyStockLevel,
		Production.Product.StandardCost, Production.Product.ListPrice,
		Production.Product.Size,Production.Product.Weight,Production.Product.DaysToManufacture
		from Production.Product
		where (Size is not null and color is not null and Weight  is not null)
		order by Production.Product.Name asc
   RETURN 
 end

----------------------------------------------------------------------------Segunda Función

go
create function CantidadPorVeentaPorProducto(@idProducto int)
 returns int
 as
 begin
	declare @resultado int
	select @resultado = AVG([Quantity]) from [Production].[TransactionHistory] where ProductID = @idProducto
	return @resultado
 end

----------------------------------------------------------------------------------------------------------------------------------------------------Fin de las funciones

----------------------------------------------------------------------------------------------------------------------------------------------------Consultas desde la aplicacion web
--------------------------------------------------------------------------------------modelo de productos



------------------------------Consulta que devuelve unicamente nombre y id con un filtro like

go 
create procedure conseguirProductos(@nombreEspecifico varchar(500))
as begin
	select Production.Product.ProductID, Product.Name
	from Production.Product
	where Product.Name like '%' +@nombreEspecifico +'%' 
end;



go
exec conseguirProductos @nombreEspecifico = 'LL';

---------------------------Consulta que devuelve todos los datos que pide el usuario

go 
create procedure conseguirInfoProductoEspecifico(@id int)
as begin
	select Production.Product.ProductID, Product.Name,ProductSubcategory.Name as Subcategoria,ProductCategory.Name as Categoria,ListPrice, ProductDescription.Description,ProductInventory.Quantity,
	SellStartDate,SellEndDate,Production.ProductModel.Name as modelo
	from Production.Product
	inner join Production.ProductSubcategory on Production.Product.ProductSubcategoryID = Production.ProductSubcategory.ProductSubcategoryID
	inner join Production.ProductCategory on Production.ProductSubcategory.ProductCategoryID = Production.ProductCategory.ProductCategoryID
	inner join Production.ProductModelProductDescriptionCulture on Production.ProductModelProductDescriptionCulture.ProductModelID = Product.ProductModelID
	inner join Production.ProductDescription on Production.ProductModelProductDescriptionCulture.ProductDescriptionID = Production.ProductDescription.ProductDescriptionID
	inner join Production.ProductInventory on Production.ProductInventory.ProductID = Product.ProductID
	inner join Production.ProductModel on Production.ProductModel.ProductModelID = Product.ProductModelID
	
	where Production.Product.ProductID = @id 
end;


go
exec conseguirInfoProductoEspecifico @id = 994


select * from Production.ProductDescription
select * from Production.ProductSubcategory








-------------------------Consulta que devuelve informacion de las transacciones de un producto especifico
go 
create procedure conseguirTransacciones(@id int)
as begin
	select TransactionID,[TransactionDate], [Quantity]
	from [Production].[TransactionHistory]
	where [ProductID] = @id 
end;
go
exec conseguirTransacciones @id=707
----------------------------------------------------------------------------------------------------------------------------------Modelo de Clientes

go
------------------------------------------------------------ Consulta que solo devolverá nombre y id
create procedure obtenerTodosClientes
as
begin
	select  Sales.Customer.CustomerID,(person.Person.FirstName +' '+ Person.Person.LastName) as Customer
	from Sales.Customer
	inner join  Person.BusinessEntityContact on Person.BusinessEntityContact.PersonID = sales.Customer.PersonID
	inner join Person.Person on Person.Person.BusinessEntityID = Person.BusinessEntityContact.PersonID
end;

go 
create procedure conseguirClientes(@nombreEspecifico varchar(500))
as begin
	select  Sales.Customer.CustomerID,(person.Person.FirstName +' '+ Person.Person.LastName) as Customer
	from Sales.Customer
	inner join  Person.BusinessEntityContact on Person.BusinessEntityContact.PersonID = sales.Customer.PersonID
	inner join Person.Person on Person.Person.BusinessEntityID = Person.BusinessEntityContact.PersonID
	where person.Person.FirstName like '%' +@nombreEspecifico +'%'  or person.Person.LastName like '%' +@nombreEspecifico +'%'  
end;


-----------------------------------------------------------------Consulta que retorna todos los datos de un cliente en especifico
go 
create procedure conseguirInfoClienteXId(@id int)
as begin
	select  Sales.Customer.CustomerID,(person.Person.FirstName +' '+ Person.Person.LastName) as Nombre, EmailAddress,PhoneNumber,Person.Person.BusinessEntityID,Sales.SalesTerritory.Name as Territorio,
	Person.CountryRegion.Name as Pais
	from Sales.Customer
	inner join  Person.BusinessEntityContact on Person.BusinessEntityContact.PersonID = sales.Customer.PersonID
	inner join Person.Person on Person.Person.BusinessEntityID = Person.BusinessEntityContact.PersonID
	inner join person.EmailAddress on EmailAddress.BusinessEntityID = Person.Person.BusinessEntityID
	inner join person.PersonPhone on PersonPhone.BusinessEntityID = Person.Person.BusinessEntityID
	inner join Sales.SalesTerritory on Sales.customer.TerritoryID = Sales.SalesTerritory.TerritoryID
	inner join Person.CountryRegion on Person.CountryRegion.CountryRegionCode = Sales.SalesTerritory.CountryRegionCode
	where sales.Customer.CustomerID = @id  
end;

go
exec conseguirInfoClienteXId @id = 29485;
----------------------------------------------------------------------------Pedir transacciones de cliente en base a id


go 
create procedure conseguirTransaccionesXCliente(@id int)
as begin
	select SalesOrderID,Sales.SalesTerritory.Name as Territorio, Purchasing.ShipMethod.Name, (SubTotal+TaxAmt) as TotalOrder
	from Sales.SalesOrderHeader
	inner join Sales.Customer on Sales.SalesOrderHeader.CustomerID = Sales.Customer.CustomerID
	inner join  Sales.SalesTerritory on  Sales.SalesTerritory.TerritoryID = Sales.Customer.TerritoryID
	inner join  Person.BusinessEntityContact on Person.BusinessEntityContact.PersonID = sales.Customer.PersonID
	inner join Person.Person on Person.Person.BusinessEntityID = Person.BusinessEntityContact.PersonID
	inner join Purchasing.ShipMethod on Purchasing.ShipMethod.ShipMethodID = Sales.SalesOrderHeader.ShipMethodID
	where Sales.Customer.CustomerID = @id
end;

------------------------------------------------------------------------------------------------------Modulo de ventas.

go
-------------------------------------------------------------Consulta que retorna el id de la venta y el nombre del cliente
create procedure getVentas
as begin 
	select  [SalesOrderID],(person.Person.FirstName +' '+ Person.Person.LastName) as Comprador	
	from Sales.SalesOrderHeader
	inner join Sales.Customer on Sales.Customer.CustomerID = Sales.SalesOrderHeader.CustomerID
	inner join  Person.BusinessEntityContact on Person.BusinessEntityContact.PersonID = sales.Customer.PersonID
	inner join Person.Person on Person.Person.BusinessEntityID = Person.BusinessEntityContact.PersonID
end;


go
exec getVentas

go 
create procedure conseguirVentas(@nombreEspecifico varchar(500))
as begin
	select [SalesOrderID],(person.Person.FirstName +' '+ Person.Person.LastName) as Comprador	
	from Sales.SalesOrderHeader
	inner join Sales.Customer on Sales.Customer.CustomerID = Sales.SalesOrderHeader.CustomerID
	inner join  Person.BusinessEntityContact on Person.BusinessEntityContact.PersonID = sales.Customer.PersonID
	inner join Person.Person on Person.Person.BusinessEntityID = Person.BusinessEntityContact.PersonID
	where person.Person.FirstName like '%' +@nombreEspecifico +'%'  or person.Person.LastName like '%' +@nombreEspecifico +'%'  
end;



------------------------------------------------------------Consulta que retorna los datos par aun cliente en especifico.

go 
create procedure conseguirInfoVenta(@id int)
as begin

	select SalesOrderID,(person.Person.FirstName +' '+ Person.Person.LastName) As Cliente,OrderDate,ShipDate,Sales.SalesTerritory.Name as Territorio,
	CountryRegion.Name as Pais,Purchasing.ShipMethod.Name as MetodoEnvio, (SubTotal+TaxAmt) as TotalOrder,Sales.Store.Name as Tienda
	from Sales.SalesOrderHeader
	inner join Sales.Customer on Sales.SalesOrderHeader.CustomerID = Sales.Customer.CustomerID
	inner join  Sales.SalesTerritory on  Sales.SalesTerritory.TerritoryID = Sales.Customer.TerritoryID
	inner join  Person.BusinessEntityContact on Person.BusinessEntityContact.PersonID = sales.Customer.PersonID
	inner join Person.Person on Person.Person.BusinessEntityID = Person.BusinessEntityContact.PersonID
	inner join Purchasing.ShipMethod on Purchasing.ShipMethod.ShipMethodID = Sales.SalesOrderHeader.ShipMethodID
	inner join Person.CountryRegion on Person.CountryRegion.CountryRegionCode = Sales.SalesTerritory.CountryRegionCode
	inner join Sales.Store on Sales.Customer.StoreID = Sales.Store.BusinessEntityID
	where sales.SalesOrderHeader.SalesOrderID = @id
end;

go
exec conseguirInfoVenta @id=44132
-------------------------------------------------------------Productos por venta

go 
create procedure conseguirProductosPorVenta(@id int)
as begin
	select  Product.Name,Sales.SalesOrderDetail.OrderQty, (ListPrice*OrderQty) as Total
	from Sales.SalesOrderDetail
	inner join Production.Product on Product.ProductID = Sales.SalesOrderDetail.ProductID
	where Sales.SalesOrderDetail.SalesOrderID = @id
end;

go
exec conseguirProductosPorVenta @id=44132;


---------------------------------------------------------------------------------------------------------------------------Consulta para el modulo de Vendedores


---------------------------------------------------------------Consulta que devuelve el id y el nombre del vendedor.

go 
create procedure conseguirVendedor(@nombreEspecifico varchar(500))
as begin
	select  Sales.SalesPerson.BusinessEntityID,(person.Person.FirstName +' '+ Person.Person.LastName) as Vendedor	
	from [Sales].[SalesPerson]
	inner join Person.Person on Person.Person.BusinessEntityID = Sales.SalesPerson.BusinessEntityID
	where person.Person.FirstName like '%' +@nombreEspecifico +'%'  or person.Person.LastName like '%' +@nombreEspecifico +'%'  
end;

-----------------------------------------------------------------------Consulta que retorna la informacion especifica de un id
go 
create procedure conseguirInfoVendedor(@id int)
as begin
	select  Sales.SalesPerson.BusinessEntityID,(person.Person.FirstName +' '+ Person.Person.LastName) as Vendedor,
	Sales.SalesPerson.CommissionPct, HumanResources.Employee.HireDate,HumanResources.Employee.JobTitle,HumanResources.Department.Name,HumanResources.Department.GroupName
	from Sales.SalesPerson
	inner join Person.Person on Sales.SalesPerson.BusinessEntityID = Person.Person.BusinessEntityID
	inner join HumanResources.Employee on HumanResources.Employee.BusinessEntityID = Sales.SalesPerson.BusinessEntityID
	inner join HumanResources.EmployeeDepartmentHistory on HumanResources.EmployeeDepartmentHistory.BusinessEntityID = Sales.SalesPerson.BusinessEntityID
	inner join HumanResources.Department on HumanResources.EmployeeDepartmentHistory.DepartmentID = HumanResources.Department.DepartmentID
	where  Sales.SalesPerson.BusinessEntityID = @id
end;
go

exec conseguirInfoVendedor @id = 285
---------------------------------------------------------------------Ventas realizadas por vendedor

go 
create procedure conseguirVentasxVendedor(@id int)
as begin
	select  sales.SalesOrderHeader.SalesOrderID, sales.SalesOrderHeader.OrderDate,sales.SalesOrderHeader.ShipDate, 
	SubTotal as total,(person.Person.FirstName +' '+ Person.Person.LastName) As Cliente
	from [Sales].[SalesPerson]
	inner join Sales.SalesOrderHeader on Sales.SalesOrderHeader.SalesPersonID = Sales.SalesPerson.BusinessEntityID
	inner join Sales.Customer on Sales.SalesOrderHeader.CustomerID = Sales.Customer.CustomerID
	inner join  Person.BusinessEntityContact on Person.BusinessEntityContact.PersonID = sales.Customer.PersonID
	inner join Person.Person on Person.Person.BusinessEntityID = Person.BusinessEntityContact.PersonID
	where  Sales.SalesPerson.BusinessEntityID = @id
end;


--------------------------------------------------------------------------------------------------------------------------------------------------------------Modulo de proovedores.
go 
--------------------------------------------------------------------------------------------Consulta que devuelve el id y el nombre del provedor.
create procedure conseguirProvedores(@nombreEspecifico varchar(500))
as begin
	select  [Purchasing].[Vendor].BusinessEntityID,Name	
	from [Purchasing].[Vendor]
	where [Purchasing].[Vendor].Name like '%' +@nombreEspecifico +'%'  
end;


-----------------------------------------------------------------------------------------Consulta que muestra la compra por provedor.

go
create procedure conseguirPedidosXProvedor(@id int)
as begin
	select  PurchaseOrderID, (FirstName+' '+LastName) as Encargado, (SubTotal+TaxAmt) as Total
	from Purchasing.PurchaseOrderHeader
	inner join Person.Person on  Person.Person.BusinessEntityID = EmployeeID
	where VendorID = @id
end;
exec conseguirPedidosXProvedor @id=1492
----------------------------------------------------------------------------------------------Consulta que devuelve los productos por factura

go
create procedure conseguirProductosXProvedor(@id int)
as begin
	select  PurchaseOrderID, Production.Product.Name as Producto, OrderQty, OrderQty*UnitPrice as PrecioTotal
	from [Purchasing].[PurchaseOrderDetail]
	inner join Production.Product on Product.ProductID = Purchasing.PurchaseOrderDetail.ProductID
	where [PurchaseOrderID] = @id
end;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------Fin de las modificaciones.
