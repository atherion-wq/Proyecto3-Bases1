import { Component, OnInit, ViewEncapsulation } from '@angular/core';
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { HttpClient, HttpHeaders} from '@angular/common/http';
import {map} from 'rxjs/operators';

@Component({
  selector: 'app-productos',
  templateUrl: './productos.component.html',
  styleUrls: ['./productos.component.scss'],
  encapsulation: ViewEncapsulation.None
})
export class ProductosComponent implements OnInit {

  
  listData: any;
  espeficData: any;
  listTransact: any;
  dataWrite:string;
  indexData:number;
  constructor(private modalService: NgbModal, private http:HttpClient) { }

  ngOnInit(): void {
    this.getProducts();
  }

  getProducts(){
    var url = "http://localhost:3000/getProductos";
    this.http.get(url).subscribe(res=>{
      this.listData=res["recordset"];
    });
  }

  openPopup(index:number,content){
    var url = "http://localhost:3000/conseguirInfoProductoEspecifico/"+index;
    this.http.get(url).subscribe(res=>{
      this.espeficData=res["recordset"][0];
    });
    var url2 = "http://localhost:3000/conseguirTransacciones/"+index;
    this.http.get(url2).subscribe(res=>{
      this.listTransact=res["recordset"];
    });
    this.modalService.open(content, { centered: true,size: 'lg'  });
  }

  modelChange(event){
    if (this.dataWrite==="" || this.dataWrite===undefined){
      this.getProducts();
    }
    else{
      var url = "http://localhost:3000/conseguirProductos/"+this.dataWrite;
      this.http.get(url).subscribe(res=>{
        this.listData=res["recordset"];
      });
    }
  }

}
