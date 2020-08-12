import { Component, OnInit, ViewEncapsulation } from '@angular/core';
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-clientes',
  templateUrl: './clientes.component.html',
  styleUrls: ['./clientes.component.scss'],
  encapsulation: ViewEncapsulation.None
})
export class ClientesComponent implements OnInit {

  listData: any;
  espeficData:any;
  listTransact:any;
  dataWrite:string;
  indexData:number;
  constructor(private modalService: NgbModal,private http:HttpClient) { }

  ngOnInit(): void {
    this.getCustomers();
  }

  getCustomers(){
    var url = "http://localhost:3000/obtenerTodosClientes";
    this.http.get(url).subscribe(res=>{
      this.listData=res["recordset"];
    });
  }

  openPopup(index:number,content){
    var url = "http://localhost:3000/conseguirInfoClienteXId/"+index;
    this.http.get(url).subscribe(res=>{
      this.espeficData=res["recordset"][0];
    });
    var url2 = "http://localhost:3000/conseguirTransaccionesXCliented/"+index;
    this.http.get(url2).subscribe(res=>{
      this.listTransact=res["recordset"];
    });
    this.modalService.open(content, { centered: true,size: 'lg'  });
  }

  modelChange(event){
    if (this.dataWrite==="" || this.dataWrite===undefined){
      this.getCustomers();
    }
    else{
      var url = "http://localhost:3000/conseguirCliente/"+this.dataWrite;
      this.http.get(url).subscribe(res=>{
        this.listData=res["recordset"];
      });
    }
  }

}
