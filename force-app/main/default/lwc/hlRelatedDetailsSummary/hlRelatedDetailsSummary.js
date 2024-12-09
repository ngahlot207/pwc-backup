import { LightningElement,wire,track,api } from 'lwc';
import getHLRelatedData from '@salesforce/apex/ObligationDetailsSummaryController.getHLRelatedDetailsData';
import getConstructionRelatedData from '@salesforce/apex/ObligationDetailsSummaryController.getConstructionRelatedDetailData';
export default class HlRelatedDetailsSummary extends LightningElement {

    @track listHLRelatedData =[];
    @track listConstructionRelatedData =[];
    @track isHomeLoanTrue = false;
    @track isConstructionTrue = false;
    @api recordId;
    @track listOfData=[];
    @track listOfDataConstruction=[];

    connectedCallback(){
        console.log('recordIdForSanction-->'+this.recordId);

    }
    @wire(getHLRelatedData,{ recordId: '$recordId'})
    wiredgetgetHLRelatedData({ data, error }) {
        if (data) {
          //  console.log('this.isHomeLoanTrue-->'+this.isHomeLoanTrue);
            
           // console.log('data-->'+JSON.stringify(data));
            this.listHLRelatedData = data;
            console.log('listHLRelatedData-->'+JSON.stringify(this.listHLRelatedData));

            this.listOfData =[];
            
            for (let key in data) {
                this.listOfData.push({key:key, value:data[key]});
             }
            // console.log('this.listOfData-->'+this.listOfData)
            // console.log('this.listOfData[0].value.isHomeLoan-->'+this.listOfData[0].value.isHomeLoan);
             if(this.listOfData.length>0){
                console.log('this.listOfData[0].value.isHomeLoan-->'+this.listOfData[0].value.isHomeLoan);
             this.isHomeLoanTrue =  this.listOfData[0].value.isHomeLoan;
             
             } 
             console.log('this.isHomeLoanTrue-->'+this.isHomeLoanTrue);
           
          
           // console.log('listHLRelatedData-->'+JSON.stringify(this.listHLRelatedData));
           
            
        } else if (error) {
            console.error('Error loading HL related additional Data: ', error);
        }
    }

    @wire(getConstructionRelatedData,{ recordId: '$recordId'})
    wiredgetConstructionRelatedData({ data, error }) {
        if (data) {
            //console.log('this.isConstructionTrue-->'+this.isConstructionTrue);
           // console.log('data-->'+JSON.stringify(data));
            this.listConstructionRelatedData = data;
            console.log('listConstructionRelatedData-->'+JSON.stringify(this.listConstructionRelatedData));
            
            this.listOfDataConstruction =[];
            for (let key in data) {
                this.listOfDataConstruction.push({key:key, value:data[key]});
             }
             if(this.listOfDataConstruction.length>0){
                console.log('this.listOfDataConstruction[0].value.isConstructionTrue-->'+this.listOfDataConstruction[0].value.isConstruction);
             this.isConstructionTrue =  this.listOfDataConstruction[0].value.isConstruction; 
            }

           // this.isConstructionTrue = this.listHLRelatedData.isConstruction;
            console.log('this.isConstructionTrue-->'+this.isConstructionTrue);
         //   console.log('listConstructionRelatedData-->'+JSON.stringify(this.listConstructionRelatedData));
           
            
        } else if (error) {
            console.error('Error loading Consrtuction related addtional Data: ', error);
        }
    }
}