import { Component, OnInit, ViewEncapsulation } from '@angular/core';
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-proveedores',
  templateUrl: './proveedores.component.html',
  styleUrls: ['./proveedores.component.scss'],
  encapsulation: ViewEncapsulation.None
})
export class ProveedoresComponent implements OnInit {

  listData:any;
  espeficData:any;
  listTransact:any;
  dataWrite:string;
  indexData:number;
  constructor(private modalService: NgbModal,private http:HttpClient) { }

  ngOnInit(): void {
    this.getSuppliers();
  }

  getSuppliers(){
    var url = "http://localhost:3000/getProveedores";
    this.http.get(url).subscribe(res=>{
      this.listData=res["recordset"];
    });
  }

  openPopup(index:number,content){
    var url = "http://localhost:3000/conseguirPedidosXProvedor/"+index;
    this.http.get(url).subscribe(res=>{
      this.espeficData=res["recordset"];
    });
    var url2 = "http://localhost:3000/conseguirProductosXProvedor/"+index;
    this.http.get(url2).subscribe(res=>{
      this.listTransact=res["recordset"];
    });
    this.modalService.open(content, { centered: true,size: 'lg'  });
  }

  modelChange(event){
    if (this.dataWrite==="" || this.dataWrite===undefined){
      this.getSuppliers();
    }
    else{
      var url = "http://localhost:3000/conseguirProvedor/"+this.dataWrite;
      this.http.get(url).subscribe(res=>{
        this.listData=res["recordset"];
      });
    }
  }

}
