import { LightningElement,track,wire,api } from 'lwc';
import getLODDetails from '@salesforce/apex/LODDetailsController.getLODDetails';
import getAppDetails from '@salesforce/apex/LODDetailsController.getAppDetails';
import getTemplate from '@salesforce/apex/LODDetailsController.getTemplate';
import createDocumentDetail from "@salesforce/apex/DocumentDetailController.createDocumentDetail";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PageURLLODForm from '@salesforce/label/c.PageURLLODForm';
import RepamentNach_Update_SuccessMessage from '@salesforce/label/c.RepamentNach_Update_SuccessMessage';
import RepamentNach_DocDetail_ErrorMessage from '@salesforce/label/c.RepamentNach_DocDetail_ErrorMessage';
import LOD_Document from '@salesforce/label/c.LOD_Document';
import generateDocument from "@salesforce/apex/GeneratePDFandAttachToLoanApplication.generateDocument";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import sendEmail from '@salesforce/apex/CommunicationMatrixEmailNotification.sendEmail';
import getUserInfo from '@salesforce/apex/LODDetailsController.getUserInfo';

export default class CaptureLODDetails extends LightningElement {

    @track listgetLODDetails;
    @track getApplicantID;
    @track getTemplateId;
    @track getUserDetails;
    //  recordId='a08C4000007WLDQIA4';

    //  @track _loanAppId='a08C4000007WLDQIA4';
     @api get loanAppId() {
         return this._loanAppId;
     }
     set loanAppId(value) {
         console.log('Loan App Id ! '+value);
         this._loanAppId = value;
         this.setAttribute("loanAppId", value);            
                
     } 

     @api isReadOnly;
     @track disableMode;
     @api hasEditAccess;    
     connectedCallback() {

        // console.log("isReadOnly:::::::: ", this.isReadOnly);
        //console.log("hasEditAccess in lod:::::::: ", this.hasEditAccess);
        //console.log("disableMode in lod::::::::: ", this.disableMode);
        // if (this.hasEditAccess === false) {
        //     this.disableMode = true;
        // }
       this.getLoanAppData();
    }
    @wire(getLODDetails,{ recordId: '$loanAppId'})
    wiredgetLODDetails({ data, error }) {
        if (data) {
            console.log('recordIdForDecision-->'+this.recordId);
            this.listgetLODDetails = data;
           
            console.log('listgetLODDetails-->'+JSON.stringify(this.listgetLODDetails));
           
        } else if (error) {
            console.error('Error loading Decision Summary: ', error);
        }
    }

     //applicant id
     
     @wire(getAppDetails,{ recordId: '$loanAppId'})
     wiredgetAppDetails({ data, error }) {
         if (data) {
             console.log('recordIdForDecision-->'+this.recordId);
             this.getApplicantID = data.Id;
            this.emailAddress=data.EmailId__c;
             console.log('applicant data-->'+JSON.stringify(data));
             console.log('applicant getApplicantID-->'+JSON.stringify(this.getApplicantID));
             console.log('applicant data-->'+JSON.stringify(this.emailAddress));
            
         } else if (error) {
             console.error('Error loading Decision Summary: ', error);
         }
     }
     
     //templateId
     @wire(getTemplate)
     wiredgetTempDetails({ data, error }) {
         if (data) {
            
             this.getTemplateId = data;
            
             console.log('getTemplateId-->'+JSON.stringify(this.getTemplateId));
            
         } else if (error) {
             console.error('Error loading Decision Summary: ', error);
         }
     }

     //User info
     emailAddress
     userID
     @wire(getUserInfo)
     wiredgetUserDetails({ data, error }) {
         if (data) {
            
             this.getUserDetails = data;
           // this.emailAddress=data.Email;
            this.userID=data.Id;
             console.log('getTemplateId-->'+JSON.stringify(this.emailAddress));
            
         } else if (error) {
             console.error('Error loading Decision Summary: ', error);
         }
     }

    //generate doc button
    @track disableMode;
    @track showSpinner = false;
    showDocList=false;
    docType = ['LOD'];
    subType = ['LOD'];
    docCategory = ['LOD']
    showToast(titleVal, variantVal, messageVal,mode) {
        const evt = new ShowToastEvent({
            title: titleVal,
            variant: variantVal,
            message: messageVal,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    customlabel ={
        RepamentNach_Update_SuccessMessage,
        RepamentNach_DocDetail_ErrorMessage,
        LOD_Document       

    }

    label = {
        PageURLLODForm
    };

    handleGenerateDocuments(){
        this.showSpinner = true;
        this.showDocList = false;
        createDocumentDetail({  applicantId: this.getApplicantID, loanAppId: this.loanAppId, docCategory: 'LOD', docType: 'LOD', docSubType: 'LOD',availableInFile : false })
            .then((result) => {
                console.log('createDocumentDetailRecord result ', result);
                this.DocumentDetaiId = result;
                console.log('createDocumentDetailRecord DocumentDetaiId ', this.DocumentDetaiId);
                
                //here we need to use correct label based on if condition
                //this.label.sanctionLetter;
                //this.label.sanctionLetterBT
                //this.repaymentAccountId
                console.log('loanAppId-->'+this.loanAppId);
                let pageUrl = this.label.PageURLLODForm+ this.loanAppId;
                const pdfData = {
                    pageUrl : pageUrl,
                    docDetailId : this.DocumentDetaiId,
                    fileName : 'LOD.pdf'
                }
                this.generateDocument(pdfData);
                this.showToast("Success", "Success", this.customlabel.LOD_Document,"sticky");
                
                //this.updateApplicantBanking();
                //this.fileUploadHandler();

            })
            .catch((err) => {
                this.showToast("Error", "error", this.customlabel.RepamentNach_DocDetail_ErrorMessage + err,"sticky");
                console.log(" createDocumentDetailRecord error===", err);
            });  
    }

    generateDocument(pdfData){
        generateDocument({ wrapObj: pdfData })
            .then((result) => {
                this.showSpinner = false;
                if(result == 'success'){
                    // this.refreshDocTable();
                    this.forLatestDocDetailRec();
                }else{
                    console.log(result);
                }
                

            })
            .catch((err) => {
                this.showToast("Error", "error", this.customlabel.RepamentNach_DocDetail_ErrorMessage + err,"sticky");
                console.log(" createDocumentDetailRecord error===", err);
            }); 
    }

    forLatestDocDetailRec() {
        var listOfAllParent = [];
        var paramForIsLatest = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ['Id', 'Appl__c', 'LAN__c', 'DocCatgry__c', 'DocTyp__c', 'DocSubTyp__c', 'IsLatest__c'],
            queryCriteria: ' where IsLatest__c = true AND LAN__c = \'' + this.loanAppId + '\' AND DocCatgry__c = \'LOD\' AND DocTyp__c = \'LOD\' AND DocSubTyp__c = \'LOD\''   //AND Appl__c = \'' + this.loanApplicationRecord.Applicant__c + '\'
        }
        getSobjectData({ params: paramForIsLatest })
            .then((result) => {
               // console.log('islatestdata 13899999', this.DocumentDetaiId);
                if (result.parentRecords) {
                    listOfAllParent = JSON.parse(JSON.stringify(result.parentRecords))
                }
                let oldRecords = []
                oldRecords = listOfAllParent.filter(record => record.Id !== this.DocumentDetaiId);
                //console.log('oldRecords>>>>>'+JSON.stringify(oldRecords))
                let isLatestFalseRecs = []
                isLatestFalseRecs = oldRecords.map(record => {
                    return { ...record, IsLatest__c: false };
                    return record;
                });
                let obj = {
                    Id: this.DocumentDetaiId,
                    NDCDataEntry__c: 'Completed'
                }
                isLatestFalseRecs.push(obj);
                console.log('isLatestFalseRecs>>>>>' + JSON.stringify(isLatestFalseRecs))
                upsertMultipleRecord({ params: isLatestFalseRecs })
                    .then(result => {
                        console.log('resultresultresultresultresult' + JSON.stringify(result));
                        this.refreshDocTable();
                        //this.showDocList = true;               

                    }).catch(error => {
                        console.log('778' + error)
                    })

            })
            .catch((error) => {
                console.log('Error In getting 13899999 ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }
    
    refreshDocTable(){
        this.showDocList = true;
    }

    //get table on refresh
    getLoanAppData() {
        var listOfAllParent = [];
        var paramForIsLatest = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ['Id', 'Appl__c', 'LAN__c', 'DocCatgry__c', 'DocTyp__c', 'DocSubTyp__c', 'IsLatest__c'],
            queryCriteria: ' where IsLatest__c = true AND LAN__c = \'' + this.loanAppId + '\' AND DocCatgry__c = \'LOD\' AND DocTyp__c = \'LOD\' AND DocSubTyp__c = \'LOD\''   //AND Appl__c = \'' + this.loanApplicationRecord.Applicant__c + '\'
        }
        getSobjectData({ params: paramForIsLatest })
            .then((result) => {
                console.log('islatestdata 13899999 connected', JSON.stringify(result.parentRecords));
                if (result.parentRecords) {
                    //listOfAllParent = JSON.parse(JSON.stringify(result.parentRecords))
                    // this.forLatestDocDetailRec()
                    //this.showDocList=true;
                    let isLatestFalseRecs = JSON.parse(JSON.stringify(result.parentRecords))
                    upsertMultipleRecord({ params: isLatestFalseRecs })
                    .then(result => {
                        console.log('resultresultresultresultresult connected' + JSON.stringify(result));
                        this.refreshDocTable();
                        //this.showDocList = true;               

                    }).catch(error => {
                        console.log('778' + error)
                    })
                }
                
            })
            .catch((error) => {
                console.log('Error In getting 13899999 ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }
    //send email
    handleSendEmail(){
        if(this.emailAddress){
        sendEmail({  templateId: this.getTemplateId, recipientIDList: this.userID, reciepientEmailAddressList: this.emailAddress, ccreciepientEmailAddressList:'' , relatedID: this.loanAppId,recipientType : 'Applicant' })
        .then((result) => {
            this.showToast("Success", "Success",'Email Send Successfully',"sticky");

    })
    .catch((error) => {
        console.log('Error In getting 13899999 ', error);
        //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
    });
    }
    else{
        this.showToast("Error", "Error",'Applicant has no Email Address',"sticky");
    }
    }
   
         
}