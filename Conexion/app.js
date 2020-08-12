const sql = require("mssql");
const express = require('express');
const bodyparser = require('body-parser');
const app = express();
app.use(bodyparser.json());

var dbConfig = {
    server: "localhost",
    database: "AdventureWorks2017",
    user: "sa",
    password: "0123456789",
    port: 1433
};

const conn = new sql.ConnectionPool(dbConfig);

//check connection
conn.connect(error=>{
	if (error){
		console.log(error);
	}
	else{
		console.log("Database server running");
	}
});

app.listen(3000, () => console.log("Server on"));

//obtenerTodosClientes
app.get('/obtenerTodosClientes',(req,res)=>{
	const {id} = req.params;
    conn.connect().then(function(conn) {
        var request = new sql.Request(conn);
        request.execute('obtenerTodosClientes').then(function(recordset) {
            res.json(recordset);
        }).catch(function(err) {
            res.send("Not result");
        });
    });
});

//Módulo: Clientes
app.get('/conseguirCliente/:id',(req,res)=>{
	const {id} = req.params;
    conn.connect().then(function(conn) {
        var request = new sql.Request(conn);
        request.input('nombreEspecifico', sql.VarChar(500), id);
        request.execute('conseguirClientes').then(function(recordset) {
            res.json(recordset);
        }).catch(function(err) {
            res.send("Not result");
        });
    });
});

//Módulo: Clientes
app.get('/conseguirInfoClienteXId/:id',(req,res)=>{
	const {id} = req.params;
    conn.connect().then(function(conn) {
        var req = new sql.Request(conn);
        req.input('id', sql.Int, id);//Poner el id del cliente que se desea buscar
        req.execute('conseguirInfoClienteXId').then(function(recordset) {
            res.json(recordset);
        }).catch(function(err) {
            res.send("Not result");
        });
    });
});

//Módulo: Clientes
app.get('/conseguirTransaccionesXCliented/:id',(req,res)=>{
	const {id} = req.params;
    conn.connect().then(function(conn) {
        var request = new sql.Request(conn);
        request.input('id', sql.Int, id);
        request.execute('conseguirTransaccionesXCliente').then(function(recordset) {
            res.json(recordset);
        }).catch(function(err) {
            res.send("Not result");
        });
    });
});

//Modulo: Productos
app.get('/getProductos',(req,res)=>{
	conn.connect().then(function () {
        var request = new sql.Request(conn);
        request.query("SELECT Production.Product.ProductID, Product.Name FROM production.product where Product.ProductModelID is not null and ProductSubcategoryID is not null and ProductID in (select ProductID from Production.ProductInventory)").then(function(recordset) {
        	res.json(recordset);
        })
        .catch(function (err) {
        	res.send("Not result");
        });
    })
    .catch(function (err) {
    	res.send("Not result");
    });
});

app.get('/conseguirProductos/:id',(req,res)=>{
	const {id} = req.params;
    conn.connect().then(function(conn) {
        var request = new sql.Request(conn);
        request.input('nombreEspecifico', sql.VarChar(500), id);
        request.execute('conseguirProductos').then(function(recordset) {
            res.json(recordset);
        }).catch(function(err) {
            res.send("Not result");
        });
    });
});

app.get('/conseguirInfoProductoEspecifico/:id',(req,res)=>{
	const {id} = req.params;
	conn.connect().then(function(conn) {
        var request = new sql.Request(conn);
        request.input('id', sql.Int, id);
        request.execute('conseguirInfoProductoEspecifico').then(function(recordset) {
            res.json(recordset);
        }).catch(function(err) {
            res.send(err);
        });
    });
});

app.get('/conseguirTransacciones/:id',(req,res)=>{
	const {id} = req.params;
	conn.connect().then(function(conn) {
        var request = new sql.Request(conn);
        request.input('id', sql.Int, id);
        request.execute('conseguirTransacciones').then(function(recordset) {
            res.json(recordset);
        }).catch(function(err) {
            res.send("Not result");
        });
    });
});

app.get('/getProveedores',(req,res)=>{
    conn.connect().then(function () {
        var request = new sql.Request(conn);
        request.query("select  [Purchasing].[Vendor].BusinessEntityID,Name from [Purchasing].[Vendor]").then(function(recordset) {
        	res.json(recordset);
        })
        .catch(function (err) {
        	res.send("Not result");
        });
    })
    .catch(function (err) {
    	res.send("Not result");
    });
});

//Módulo: Proveedores
app.get('/conseguirProvedor/:id',(req,res)=>{
    const {id} = req.params;
    conn.connect().then(function(conn) {
        var request = new sql.Request(conn);
        request.input('nombreEspecifico', sql.VarChar(500), id);
        request.execute('conseguirProvedores').then(function(recordset) {
            res.json(recordset);
        }).catch(function(err) {
            res.send("Not result")
        });
    });
});


//Modulo: Proveedores
app.get('/conseguirPedidosXProvedor/:id',(req,res)=>{
    const {id} = req.params;
    conn.connect().then(function(conn) {
        var request = new sql.Request(conn);
        request.input('id', sql.Int, id);
        request.execute('conseguirPedidosXProvedor').then(function(recordset) {
            res.json(recordset);
        }).catch(function(err) {
            res.send("Not result");
        });
    });
});

//Modulo: Proveedores
app.get('/conseguirProductosXProvedor/:id',(req,res)=>{
    const {id} = req.params;
    conn.connect().then(function(conn) {
        var request = new sql.Request(conn);
        request.input('id', sql.Int, id);
        request.execute('conseguirProductosXProvedor').then(function(recordset) {
            res.json(recordset);
        }).catch(function(err) {
            res.send("Not result");
        });
    });
});

//Modulo: Vendedores
app.get('/getSales',(req,res)=>{
    conn.connect().then(function () {
        var request = new sql.Request(conn);
        request.query("select  Sales.SalesPerson.BusinessEntityID,(person.Person.FirstName +' '+ Person.Person.LastName) as Vendedor from [Sales].[SalesPerson] inner join Person.Person on Person.Person.BusinessEntityID = Sales.SalesPerson.BusinessEntityID").then(function(recordset) {
        	res.json(recordset);
        })
        .catch(function (err) {
        	res.send("Not result");
        });
    })
    .catch(function (err) {
    	res.send("Not result");
    });
});

app.get('/conseguirVendedor/:id',(req,res)=>{
    const {id} = req.params;
    conn.connect().then(function(conn) {
        var request = new sql.Request(conn);
        request.input('nombreEspecifico', sql.VarChar(500), id);
        request.execute('conseguirVendedor').then(function(recordset) {
            res.json(recordset);
        }).catch(function(err) {
            res.send("Not result");
        });
    });
});

//Modulo: Vendedores
app.get('/conseguirInfoVendedor/:id',(req,res)=>{
    const {id} = req.params;
    conn.connect().then(function(conn) {
        var request = new sql.Request(conn);
        request.input('id', sql.Int, id);
        request.execute('conseguirInfoVendedor').then(function(recordset) {
            res.json(recordset);
        }).catch(function(err) {
            res.send(err);
        });
    });
});

//Modulo: Vendedores
app.get('/conseguirVentasxVendedor/:id',(req,res)=>{
    const {id} = req.params;
    conn.connect().then(function(conn) {
        var request = new sql.Request(conn);
        request.input('id', sql.Int, id);
        request.execute('conseguirVentasxVendedor').then(function(recordset) {
            res.json(recordset);
        }).catch(function(err) {
            res.send("Not result");
        });
    });
});

//Modulo: Ventas
app.get('/getVentas',(req,res)=>{
    conn.connect().then(function(conn) {
        var request = new sql.Request(conn);
        request.execute('getVentas').then(function(recordset) {
            res.json(recordset);
        }).catch(function(err) {
            res.send("Not result");
        });
    });
});

app.get('/conseguirVentas/:id',(req,res)=>{
    const {id} = req.params;
    conn.connect().then(function(conn) {
        var request = new sql.Request(conn);
        request.input('nombreEspecifico', sql.VarChar(500), id);
        request.execute('conseguirVentas').then(function(recordset) {
            res.json(recordset);
        }).catch(function(err) {
            res.send(err);
        });
    });
});

//Modulo: Ventas
app.get('/conseguirInfoVenta/:id',(req,res)=>{
    const {id} = req.params;
    conn.connect().then(function(conn) {
        var request = new sql.Request(conn);
        request.input('id', sql.Int, id);
        request.execute('conseguirInfoVenta').then(function(recordset) {
            res.json(recordset);
        }).catch(function(err) {
            res.send(err);
        });
    });
});

//Modulo: Ventas
app.get('/conseguirProductosPorVenta/:id',(req,res)=>{
    const {id} = req.params;
    conn.connect().then(function(conn) {
        var request = new sql.Request(conn);
        request.input('id', sql.Int, id);
        request.execute('conseguirProductosPorVenta').then(function(recordset) {
            res.json(recordset);
        }).catch(function(err) {
            res.send("Not resutlt");
        });
    });
});