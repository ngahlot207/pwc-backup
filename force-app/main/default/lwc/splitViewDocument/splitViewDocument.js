import { LightningElement,track,api,wire } from 'lwc';
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";
import { formattedDateTimeWithoutSeconds } from 'c/dateUtility';
import fetchId from "@salesforce/apex/FileUploadController.fetchId";
export default class SplitViewDocument extends LightningElement {



@api loanAppId='a08C4000007x0uSIAQ'

@track contDocId;
@track cvId;
@track docId;
@track cDFileType;
@track viewDoc;
@track type= ['Identity Proof','Vetting Photos','TSR Photos','Employment Proof','Office Address','Residence Address'];
@track category= ['Identity Proof','Vetting Photos','Employment Proof','Office Address','Residence Address','Case Documents'];

connectedCallback(){
    this.fetchDoc();
}

@track lstAllFiles=[];
   
fetchDoc(){
    
    fetchId({ applicantId: this.loanAppId, category: this.category, docType: this.type, subType: this.subType })
    .then((result) => {

        this.lstAllFiles = result;
        console.log('this.lstAllFiles',JSON.stringify(this.lstAllFiles))
        let checkOCVAll = true;
        if (this.lstAllFiles && this.lstAllFiles.length > 0) {


            ///LAK-5588
            this.lstAllFiles.forEach(item => {
                if(item.cDcrtdDate){
                item.cDcrtdDate = formattedDateTimeWithoutSeconds(item.cDcrtdDate);
                }
            })                        
        }
        this.checkAllValue = checkOCVAll;
       
        this.showSpinnerChild = false;

    })
    .catch((error) => {
        this.error = error;
        this.lstAllFiles = undefined;
        this.showSpinnerChild = false;
        console.log("error occured in fetchId", this.error);
        console.log("handlefileUploaded");
    });
}


      handlebutton(event){
        let dataValue = event.target.dataset.name;
        if (dataValue === "View") {
            //this.contDocId = event.target.dataset.cdId;
            // this.cvId=event.target.dataset.cvId;
            // this.docId=event.target.dataset.docId;
            // this.cDFileType=event.target.dataset.cDFileType
            // console.log("contDocId ", this.contDocId);
            // console.log("docId ", this.docId);
            this.viewDoc = false;
            if(!this.docId){
                this.docId = event.target.dataset.docId;
                console.log("docId ", this.docId);
                this.viewDoc = true;
              }else {
                if(this.docId === event.target.dataset.docId){
                  this.viewDoc = false;
                  this.docId=null
                }else{
                    this.docId = event.target.dataset.docId;
                  this.viewDoc = true;
                }
              }
            
          
      }
    }
    
    handleCloseModalEvent() {
        this.viewDoc = false;
      }
      closeModal() {
        this.viewDoc = false;
      }
}