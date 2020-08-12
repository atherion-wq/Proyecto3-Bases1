import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { MenuComponent } from './menu/menu.component';
import {ProductosComponent} from './productos/productos.component';
import {VentasComponent} from './ventas/ventas.component';
import {VendedoresComponent} from './vendedores/vendedores.component';
import {ClientesComponent} from './clientes/clientes.component';
import {ProveedoresComponent} from './proveedores/proveedores.component';
import {InicioComponent} from  './inicio/inicio.component'

const routes: Routes = [
  {path: '', component: InicioComponent },
  {path: 'inicio', component: InicioComponent },
  {path: 'productos',component:ProductosComponent},
  {path: 'ventas',component:VentasComponent},
  {path: 'vendedores',component:VendedoresComponent},
  {path: 'clientes',component:ClientesComponent},
  {path: 'proveedores',component:ProveedoresComponent}
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
