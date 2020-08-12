import { Component, OnInit, ViewEncapsulation } from '@angular/core';
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-ventas',
  templateUrl: './ventas.component.html',
  styleUrls: ['./ventas.component.scss'],
  encapsulation: ViewEncapsulation.None
})
export class VentasComponent implements OnInit {

  listData:any;
  espeficData:any;
  listTransact:any;
  dataWrite:string;
  indexData:number;

  constructor(private modalService: NgbModal,private http:HttpClient) { }

  ngOnInit(): void {
    this.getVentas();
  }

  getVentas(){
    var url = "http://localhost:3000/getVentas";
    this.http.get(url).subscribe(res=>{
      this.listData=res["recordset"];
    });
  }

  openPopup(index:number,content){
    var url = "http://localhost:3000/conseguirInfoVenta/"+index;
    this.http.get(url).subscribe(res=>{
      this.espeficData=res["recordset"][0];
    });
    var url2 = "http://localhost:3000/conseguirProductosPorVenta/"+index;
    this.http.get(url2).subscribe(res=>{
      this.listTransact=res["recordset"];
    });
    this.modalService.open(content, { centered: true,size: 'lg'  });
  }

  modelChange(event){
    if (this.dataWrite==="" || this.dataWrite===undefined){
      this.getVentas();
    }
    else{
      var url = "http://localhost:3000/conseguirVentas/"+this.dataWrite;
      this.http.get(url).subscribe(res=>{
        this.listData=res["recordset"];
      });
    }
  }

}
