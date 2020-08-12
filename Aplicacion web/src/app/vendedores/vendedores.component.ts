import { Component, OnInit, ViewEncapsulation } from '@angular/core';
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-vendedores',
  templateUrl: './vendedores.component.html',
  styleUrls: ['./vendedores.component.scss'],
  encapsulation: ViewEncapsulation.None
})
export class VendedoresComponent implements OnInit {

  listData:any;
  espeficData:any;
  listTransact:any;
  dataWrite:string;
  indexData:number;
  constructor(private modalService: NgbModal,private http:HttpClient) { }

  ngOnInit(): void {
    this.getSales();
  }

  getSales(){
    var url = "http://localhost:3000/getSales";
    this.http.get(url).subscribe(res=>{
      this.listData=res["recordset"];
    });
  }

  openPopup(index:number,content){
    console.log(index)
    var url = "http://localhost:3000/conseguirInfoVendedor/"+index;
    this.http.get(url).subscribe(res=>{
      this.espeficData=res["recordset"][0];
    });


    var url2 = "http://localhost:3000/conseguirVentasxVendedor/"+index;
    this.http.get(url2).subscribe(res=>{
      this.listTransact=res["recordset"];
    });
    this.modalService.open(content, { centered: true,size: 'lg'  });
  }

  modelChange(event){
    if (this.dataWrite==="" || this.dataWrite===undefined){
      this.getSales();
    }
    else{
      var url = "http://localhost:3000/conseguirVendedor/"+this.dataWrite;
      this.http.get(url).subscribe(res=>{
        this.listData=res["recordset"];
      });
    }
  }

}
