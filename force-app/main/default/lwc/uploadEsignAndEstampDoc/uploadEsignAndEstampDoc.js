import { LightningElement,api,track,wire } from 'lwc';
 import fetchAllDocs from '@salesforce/apex/FetchFileToMerge.fetchAllDocs';
 import fetchAllDocsforStamp from '@salesforce/apex/FetchFileToMerge.fetchAllDocsforStamp';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import { getRecord, createRecord, updateRecord, deleteRecord } from 'lightning/uiRecordApi';
import Constitution_Field from '@salesforce/schema/Lead.Constitution__c';
import CustProfile_Field from '@salesforce/schema/Lead.Customer_Profile__c';
import CURRENTUSERID from '@salesforce/user/Id';
import { refreshApex } from '@salesforce/apex';
import QUE_IMAGE from "@salesforce/resourceUrl/QuestionMarkImage";
import uploadOneFile from '@salesforce/label/c.LeadCapture_OTPValidation_Uploadonefile';
import getSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import { FlowNavigationNextEvent, FlowNavigationBackEvent, FlowAttributeChangeEvent } from 'lightning/flowSupport';
import getLightningHostname from "@salesforce/apex/DomainNameProvider.getLightningHostname";
import getVisualforceDomain from "@salesforce/apex/DomainNameProvider.getVisualforceDomain";
import getUploadedFilesByContentVersion from "@salesforce/apex/CreateLeadController.getUploadedFilesByContentVersion";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import { subscribe, publish, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import LEADDATAMC from '@salesforce/messageChannel/LeadDataMessageChannel__c';
import getDatawithoucah from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable';

const Leadfields = [Constitution_Field, CustProfile_Field]
// const MAX_FILE_SIZE = 10485760; //in bytes 10 MB now
const MAX_FILE_SIZE = 5242880; //in bytes 5 MB now
// export default class CaptureLeadDocumentUpload extends LightningElement {
    export default class UploadEsignAndEstampDoc extends NavigationMixin(LightningElement){
    @track _leadRecordId; 
    @track allowedFilFormat = ".pdf";
    @track fileTypeError='Allowed File Types are : pdf'
    @track fileSizeMsz = "Maximum file size should be 25Mb. Allowed file type is .pdf only";
    @api get leadRecordId() {
        return this._leadRecordId;
      }
      set leadRecordId(value) {
        this._leadRecordId= value;
        this.setAttribute("leadRecordId", value);
        this.fetchLeadRecord();
       // this.handleLoanRecordIdChange();
      }
      _applicantId
      @api get applicantId() {
        return this._applicantId;
      }
      set applicantId(value) {
        this._applicantId= value;
        console.log('this._applicantId?????????????'+this._applicantId)
        this.setAttribute("applicantId", value);
      }
    // @track _leadRecordId='00QC4000005jSzmMAE';
    @track contentDocumentType;
    @track contentDocumentId;
    @track showModal = false;
    @track docNameOption = [];
    @track docTypeOption = [];
    @track Constitution;
    @track CustProfile;
    @track apexResult;
    @track documentCatagoeyMap;
    @track docName;
    @track docType;
    @track docCategory;
    @track showUpload = false;
    @track showTable=false;
    @track docIdToDelete;
    acceptedFormats = ['.pdf', '.png', '.jpeg', '.jpg'];
    @track lightningDomainName;
    @track vfUrl;
    @track documentDetailId;
    @track deleteMsg = `Do you want to delete the document?`;
    @track isModalOpen = false;
    @track docId;
    @track hasDocumentId = false;
    @track contVersDataList = []
    @track fileNames = [];
    image = QUE_IMAGE;
   @track _wiredDetails;
   @api hasEditAccess;
   @track disableMode
   @api isEStampDone;
   @api showESignDocuments;
   @api showEStampDocuments;

   
    fetchLeadRecord(){
        let paramForAppDetail={
            ParentObjectName:'LoanAppl__c',
            ChildObjectRelName:'',
            parentObjFields:['Id','Stage__c','E_Sign_Physical_Sign__c','Is_E_Sign_Physical_Done__c','E_Stamp_Physical_Stamp__c','Is_E_Stamp_Done__c'],
            childObjFields:[],        
            queryCriteria: ' where Id= \'' + this.leadRecordId + '\''
        }
    getDatawithoucah({ params: paramForAppDetail })
   .then((result) => {
   
        this.getPicklistValuesofDocuments();
        this.getPicklistValuesofDocumentsForStamp();


    
   })
   .catch((error) => {
            
    console.log("error occured in fetchLeadData", error);

    });
    }

    getPicklistValuesofDocuments(){
        fetchAllDocs({ lanId: this.leadRecordId})
        .then((result) => {
            this.docTypeOption=[]
            console.log("result from apex", result);
            this.apexResult=result;
            Object.keys(result).forEach(key => {
                let doc = { label: key, value: key };
                this.docTypeOption = [...this.docTypeOption, doc];
                this.docTypeOption.sort(this.compareByLabel);
            });
            console.log('this.docTypeOption',JSON.stringify(this.docTypeOption))
            
        })
        .catch((error) => {
            
            console.log("error occured in fetchLeadData", error);

        });
        // this.showSpinner=false;
    }
    docTypeOptionForStamp;
    apexResultForStamp;
    getPicklistValuesofDocumentsForStamp(){
        fetchAllDocsforStamp({ lanId: this.leadRecordId})
        .then((result) => {
            this.docTypeOptionForStamp=[]
            console.log("result from apex", result);
            this.apexResultForStamp=result;
            Object.keys(result).forEach(key => {
                let doc = { label: key, value: key };
                this.docTypeOptionForStamp = [...this.docTypeOptionForStamp, doc];
                this.docTypeOptionForStamp.sort(this.compareByLabel);
            });
            console.log('this.docTypeOption',JSON.stringify(this.docTypeOptionForStamp))
            
        })
        .catch((error) => {
            
            console.log("error occured in fetchLeadData", error);

        });
        // this.showSpinner=false;
    }

    handleChange(event) {
        let name = event.target.name;
        let val = event.target.value;  
        if(this.isEStampDone){
            if (name === 'DocumentType') {     
                this.docNameOption = [];
                this.docType = val;
                this.docName = '';
                // this.docNameOption = this.apexResult[val];        
                this.documentCatagoeyMap = this.apexResult;
                this.documentCatagoeyMap[val].forEach(item => {
                    let doc = { label: item, value: item };
                    this.docNameOption = [...this.docNameOption, doc];
                    this.docNameOption.sort(this.compareByLabel);
                });
                
            }
        }else{
            this.template.querySelector('[data-id="esign"]').value = '';
                this.showToast('Error', 'Please Complete E-Stamp/Physical Stamp First.', 'error');
        }
        
        console.log('this.docNameOption',this.docNameOption)
        if (name === 'DocumentName') {
            let resultRecord=this.fileNames;
            console.log('resultRecord',JSON.stringify(resultRecord))
            for (let i = 0; i < resultRecord.length; i++){
                if(resultRecord[i].docName==val){
                    this.showToastMessage('Error', 'Duplicate Document cannot be upload', 'error', 'sticky');
                    return;
                }}
                this.docName = val;
                
            
        }
        if (this.docName) {
            this.showUpload = true;
            if(this.docName=='Physical-Signed Sanction Letter & KFS Document' || this.docName=='Physical-Signed Application Form' || this.docName=='Physical-Signed NACH Form'  || this.docName=='Physical-Signed BT Draft Part 1' || this.docName=='Physical-Signed BT Draft Part 2' || this.docName=='Physical-Signed DPN Document'){
                    this.docCatogary='Mandatory Post Sanction Documents'
            }else if(this.docName=='Physical-Signed Loan Agreement & Related Annexures'){
                this.docCatogary='Additional Post Sanction Documents'
            }
        } else {
            this.showUpload = false;
        }
    }
    docNameOptionStamp;
    docTypeForStamp
    docNameForStamp
    docCatogaryForStamp
    documentCatagoeyMapForStmap
    handleChangeForstamp(event) {
        debugger
        let name = event.target.name;
        let val = event.target.value;  
        if (name === 'DocumentType') {     
                this.docNameOptionStamp = [];
                this.docTypeForStamp = val;
                this.docNameForStamp = '';
                // this.docNameOption = this.apexResult[val];        
                this.documentCatagoeyMapForStmap = this.apexResultForStamp;
                this.documentCatagoeyMapForStmap[val].forEach(item => {
                    let doc = { label: item, value: item };
                    this.docNameOptionStamp = [...this.docNameOptionStamp, doc];
                    this.docNameOptionStamp.sort(this.compareByLabel);
                });
                
            }
        console.log('this.docNameOption',this.docNameOption)
        if (name === 'DocumentName') {
            let resultRecord=this.fileNames;
            console.log('resultRecord',JSON.stringify(resultRecord))
            for (let i = 0; i < resultRecord.length; i++){
                if(resultRecord[i].docNameForStamp==val){
                    this.showToastMessage('Error', 'Duplicate Document cannot be upload', 'error', 'sticky');
                    return;
                }}
                this.docNameForStamp = val;
                
            
        }
        if (this.docNameForStamp) {
            this.showUploadForStamp = true;
            if(this.docNameForStamp=='Physical-Stamped Loan Agreement' || this.docNameForStamp=='Physical-Stamped Declaration of Loan Agreement' || this.docNameForStamp=='Physical-Stamped Power Of Attonrny' ){
                    this.docCatogaryForStamp='Mandatory Post Sanction Documents'
            }else if(this.docName=='Physical-Signed Loan Agreement & Related Annexures'){
                this.docCatogaryForStamp='Additional Post Sanction Documents'
            }
        } else {
            this.showUploadForStamp = false;
        }
    }
    @track docCatogary;
    @track showUploadForStamp;


    connectedCallback() {
        if(this.hasEditAccess==false){
            this.disableMode=true;
        }
        console.log('applicantId>>>>>>>'+this._applicantId)
        console.log('_leadRecordIdd>>>>>>>'+this._leadRecordId)
     }
     showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    handleUploadCallback(message) {
        console.log('Responve of vf Page ', message.data);

        if (message.data.source === "vf") {
            if (message.data.fileIdList != null || message.data.fileIdList.length > 0) {
                //this.getUploadedFilesByContentVersion(this.leadRecordId);
                this.docName=''
                this.docCategory=''
                this.docType=''
                this.showUpload=false;
                if (this.fileName.trim() != '') {
                    let title = `${this.fileName} uploaded successfully!!`;
                    this.showToastMessage('Success', title, 'success', 'sticky');
                }
            } else {
                this.showToastMessage(
                    "Error!",
                    this.customLabel.LeadOtp_UploadingFile_ErrorMessage,
                    "error",
                    "sticky"
                );
                // this.isLoading = false;
            }

        }
    }
    parentFileChange(event){
       /* if(this.template.querySelector('c-upload-docs-reusable-component')!=''&& this.template.querySelector('c-upload-docs-reusable-component')!=null && typeof this.template.querySelector('c-upload-docs-reusable-component') !=='undefined'){
            this.template.querySelector('c-upload-docs-reusable-component').handleUpload();
        }*/
    }
    documentDetaiId
    loanAppRecord={}
    fromUploadDocsContainer(event){
        let documentDetailId=event.detail.docDetailId;
        this.forLatestDocDetailRec(this.docCatogary,this.docType, this.docName, documentDetailId);
        //this.UpdateEStampField(documentDetailId);
    }
    fromUploadDocsContainerforStamp(event){
        debugger
        let documentDetailId=event.detail.docDetailId;
        this.forLatestDocDetailRec(this.docCatogaryForStamp,this.docTypeForStamp, this.docNameForStamp, documentDetailId);
        //this.UpdateEStampField(documentDetailId);
    }
    UpdateEStampField(documentDetailId) {
        debugger
        this.loanAppRecord["sobjectType"] = "LoanAppl__c";
        this.loanAppRecord["E_Sign_Physical_Sign__c"] = 'Physical Sign';
       // this.loanAppRecord["Is_E_Sign_Physical_Done__c"] = 'true';
        this.loanAppRecord["Id"] = this._leadRecordId;
        let newArray = [];
        if (this.loanAppRecord) {
            newArray.push(this.loanAppRecord);
        }
        if (newArray) {
            upsertMultipleRecord({ params: newArray })
                .then((result) => {
                  
                    
                    
                })
                .catch((error) => {
                    console.log('Error In 1841>>>>>>>>>>>>>>>>> ', error);
                });
        }
    }
    forLatestDocDetailRec(docCat, docTyp, docSubTyp, docId) {
        console.log('document details in forLatestDocDetailRec ###1456', docTyp, docCat, docSubTyp, docId);

        let listOfAllParent = [];
        let paramForIsLatest = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ['Id', 'Appl__c', 'LAN__c', 'DocCatgry__c', 'DocTyp__c', 'DocSubTyp__c', 'IsLatest__c'],
            queryCriteria: ' where IsLatest__c = true AND LAN__c = \'' + this._leadRecordId + '\' AND DocCatgry__c = \'' + docCat + '\' AND DocTyp__c = \'' + docTyp + '\' AND DocSubTyp__c = \'' + docSubTyp + '\''
        }
        getSobjectData({ params: paramForIsLatest })
            .then((result) => {
                console.log('islatestdata 13899999', docId);
                console.log('isLatestFalseRecs>>>>>' + JSON.stringify(result))
                if (result.parentRecords) {
                    listOfAllParent = JSON.parse(JSON.stringify(result.parentRecords))
                    let oldRecords = []
                        oldRecords = listOfAllParent.filter(record => record.Id !== docId);
                    let isLatestFalseRecs = []
                    isLatestFalseRecs = oldRecords.map(record => {
                        return { ...record, IsLatest__c: false };
                    });
                    upsertMultipleRecord({ params: isLatestFalseRecs })
                        .then(result => {
                            const refreshDocTable = new CustomEvent('forrefreshtable', {
                            });
                            this.dispatchEvent(refreshDocTable);
                           
                        }).catch(error => {
                            console.log('errorerrorerror',error);
                        })
                }
                
            })
            .catch((error) => {
                console.log('Error In 1841 ', error);
            });
    }
    
}