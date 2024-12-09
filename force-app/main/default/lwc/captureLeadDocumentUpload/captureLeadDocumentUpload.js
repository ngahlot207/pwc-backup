import { LightningElement,api,track,wire } from 'lwc';
 import fetchAllDocs from '@salesforce/apex/LeadDocumentTypeAndName.fetchAllDocs';
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
import LeadOtp_ReqField_ErrorMessage from '@salesforce/label/c.LeadOtp_ReqField_ErrorMessage';
import LeadOtp_MobileNumber_ErrorMessage from '@salesforce/label/c.LeadOtp_MobileNumber_ErrorMessage';
import LeadOtp_Otp_ErrorMessage from '@salesforce/label/c.LeadOtp_Otp_ErrorMessage';
import LeadOtp_ValidateOtp_ErrorMessage from '@salesforce/label/c.LeadOtp_ValidateOtp_ErrorMessage';
import LeadOtp_FileSize_ErrorMessage from '@salesforce/label/c.LeadOtp_FileSize_ErrorMessage';
import LeadOtp_UploadingFile_ErrorMessage from '@salesforce/label/c.LeadOtp_UploadingFile_ErrorMessage';
import LeadOtp_Has_SuccessMessage from '@salesforce/label/c.LeadOtp_Has_SuccessMessage';
import LeadOtp_Succ_SuccessMessage from '@salesforce/label/c.LeadOtp_Succ_SuccessMessage';
import LeadOtp_leadClouse_ErrorMessage from '@salesforce/label/c.LeadOtp_leadClouse_ErrorMessage';
import LeadOtp_FileType_ErrorMessage from '@salesforce/label/c.LeadOtp_FileType_ErrorMessage';
import LeadOtp_Del_SuccessMessage from '@salesforce/label/c.LeadOtp_Del_SuccessMessage';
import { subscribe, publish, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import LEADDATAMC from '@salesforce/messageChannel/LeadDataMessageChannel__c';
import getDatawithoucah from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable';

const Leadfields = [Constitution_Field, CustProfile_Field]
// const MAX_FILE_SIZE = 10485760; //in bytes 10 MB now
const MAX_FILE_SIZE = 5242880; //in bytes 5 MB now
// export default class CaptureLeadDocumentUpload extends LightningElement {
    export default class CaptureLeadDocumentUpload extends NavigationMixin(LightningElement){
    @track _leadRecordId; 

    @api get leadRecordId() {
        return this._leadRecordId;
      }
      set leadRecordId(value) {
        this._leadRecordId= value;
        this.setAttribute("leadRecordId", value);
        this.fetchLeadRecord();
       // this.handleLoanRecordIdChange();
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
    customLabel = {
        LeadOtp_ReqField_ErrorMessage,
        LeadOtp_MobileNumber_ErrorMessage,
        LeadOtp_Otp_ErrorMessage,
        LeadOtp_ValidateOtp_ErrorMessage,
        LeadOtp_FileSize_ErrorMessage,
        LeadOtp_UploadingFile_ErrorMessage,
        LeadOtp_Has_SuccessMessage,
        LeadOtp_Succ_SuccessMessage,
        LeadOtp_leadClouse_ErrorMessage,
        LeadOtp_FileType_ErrorMessage,
        LeadOtp_Del_SuccessMessage

    }
    image = QUE_IMAGE;
   @track _wiredDetails;

    
    
    //  @wire(getRecord, { recordId: '$leadRecordId', fields: Leadfields })
   
    // wiredData(wiredResultLead) {      
    //   console.log('wiredResultLead:::::::::', wiredResultLead);
    //   let { error, data } = wiredResultLead;     
    //     if (data) {
    //        // 
    //        this.Constitution=data.fields.Constitution__c.value;
    //        this.CustProfile=data.fields.Customer_Profile__c.value;
    //        console.log('this.Constitution: wiredResultLead::::::::', this.Constitution);
    //        console.log('this.CustProfile wiredResultLead:::::::::', this.CustProfile);
    //          if(this.Constitution && this.CustProfile){
    //         //     // this.showSpinner=true;
    //             this.getPicklistValuesofLead();
    //          }
    //   }
    // }

    

    fetchLeadRecord(){
        let paramForAppDetail={
            ParentObjectName:'Lead',
            ChildObjectRelName:'',
            parentObjFields:['Id','Constitution__c','Customer_Profile__c'],
            childObjFields:[],        
            queryCriteria: ' where Id= \'' + this.leadRecordId + '\''
        }
    getDatawithoucah({ params: paramForAppDetail })
   .then((result) => {
   console.log('fetch lead records',JSON.stringify(result))
    this.Constitution=result.parentRecords[0].Constitution__c;
    this.CustProfile=result.parentRecords[0].Customer_Profile__c;
    console.log('this.Constitution: wiredResultLead 1234::::::::', this.Constitution);
    console.log('this.CustProfile wiredResultLead:::::::::', this.CustProfile);
    if(this.Constitution && this.CustProfile){
        this.getPicklistValuesofLead();
    }
   })
   .catch((error) => {
            
    console.log("error occured in fetchLeadData", error);

    });
    }
// @track paramsforlead={
//     ParentObjectName:'Lead',
//     ChildObjectRelName:'',
//     parentObjFields:['Id','Constitution__c','Customer_Profile__c'],
//     childObjFields:[ ],
//     queryCriteria: ' where Id= \'' + this.leadRecordId + '\''
//   }
// getValuesofLead(){
//     getSobjectDataNonCacheable({params: this.paramsforlead}).then((result) => {
//         if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
//           console.log('wiredApplicantRecData>>>>>>1TAB connected',JSON.stringify(result.parentRecords));
//           this.parentRecForLegal=JSON.parse(JSON.stringify(result.parentRecords[0]));
//           if(typeof this.parentRecForLegal.ReportResult__c !== 'undefined'){
//             if(this.parentRecForLegal.ReportResult__c=='Positive' || this.parentRecForLegal.ReportResult__c=='Refer'){
//               this.isLegalStatus=false;
//             }
//             else{
//               this.isLegalStatus=true;
//             }
//        }
//         console.log('this.isLegalStatus connected',this.isLegalStatus);
//         console.log('disableInitiateTSR isLegalStatus',this.disableInitiateTSR);
//         }
//       })
//       .catch((error) => {
//         console.log("TECHNICAL PROP CASE QUERIES #766", error);
//       });
// }

    getPicklistValuesofLead(){
        fetchAllDocs({ constitution: this.Constitution, CustProfile: this.CustProfile})
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

    

//     @wire(fetchAllDocs, { constitution: "$Constitution", CustProfile: "$CustProfile" })
//     fetchAllDocsHandler({ data, error }) {
//     if (data) {
//         this.docTypeOption=[]
//         console.log("result from apex", data);
//         this.apexResult=data;
        
//         Object.keys(data).forEach(key => {
//             let doc = { label: key, value: key };
//             this.docTypeOption = [...this.docTypeOption, doc];
//             this.docTypeOption.sort(this.compareByLabel);
//         });
//         console.log('this.docTypeOption',JSON.stringify(this.docTypeOption))
        
//     }
//     if (error) {
//       console.log("ERROR::::::: #376", error);
//     }
//   }

    handleChange(event) {
        let name = event.target.name;
        let val = event.target.value;  
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
            if(this.docType=='PAN'){
                this.docCategory='PAN Documents';
            }else{
                this.docCategory='KYC Documents';
            }
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
            
        } else {
            this.showUpload = false;
        }
    }

    //file upload
    
    @track fileData;
    @track fileName = '';
    @track documentDetaildId = '';
    openfileUpload(event) {
        // this.isManual = false;
        const file = event.target.files[0];
        let fileNameParts = event.detail.files[0].name.split('.');
        let extension = '.' + fileNameParts[fileNameParts.length - 1].toLowerCase();
        this.fileName = file.name;
        // this.isLoading = true;
        if (!this.acceptedFormats.includes(extension)) {
            this.showToastMessage('Error', this.customLabel.LeadOtp_FileType_ErrorMessage, 'error', 'sticky');
        }
        else if (file.size > MAX_FILE_SIZE) {
            this.showToastMessage(
                "Error!",
                this.customLabel.LeadOtp_FileSize_ErrorMessage,
                "error",
                "sticky"
            );
            // this.isLoading = false;

        }
        else {
            let reader = new FileReader();
            reader.onload = () => {
                try {
                    this.fileData = new Array();
                    let fileContents = reader.result.split(",")[1];
                    this.fileData.length = 0;
                    this.fileData = [{
                        'fileName': file.name + "  ",
                        'fileContent': fileContents,
                        'docType': this.docType,
                        'docCategory': this.docCategory,
                        'docName':this.docName,
                        'additionalParams': true
                    }];
                    this.uploadFileLargeVf(this.leadRecordId);
                }
                catch (error) {
                    // console.log(JSON.stringify(error) + 'Error in creating list');
                }

            };
            reader.readAsDataURL(file);

            this.uploadFileAndShowToast(event);
        }

        setTimeout(() => {
            // this.isManual = true;
            // console.log('this.isManual after', this.isManual);
        }, 500);
    }

    uploadFileLargeVf(leadRecordId) {
        try {
            this.template.querySelector("iframe").contentWindow.postMessage(
                JSON.parse(
                    JSON.stringify({
                        source: "lwc",
                        files: this.fileData,
                        parameters: leadRecordId,
                        lightningDomain: this.lightningDomainName
                        
                    })
                ),
                this.vfUrl
            );
        }
        catch (error) {
             console.log('Error while trying to process selected file' + error);
            this.showToastMessage(
                "Error!",
                this.customLabel.LeadOtp_UploadingFile_ErrorMessage,
                "error",
                "sticky"
            );
            // this.isLoading = false;
        }
        // this.getUploadedFilesByContentVersion(recId);
    }

    uploadFileAndShowToast(event) {
        try {
            let tempFileNames = this.fileNames;
            // Get the list of uploaded files
            // const uploadedFiles = event.detail.files;
            const fileNames = [];
            console.log('No. of files uploaded : ');
            if (this.fileData) {
                // console.log('filedata----' + this.fileData);
                this.fileData.forEach(item => {
                    tempFileNames.push({ name: item.name, size: item.size, cDId: item.documentId });
                    console.log('item.name--' + item.name);
                    console.log('item.size--' + item.size);
                });
                this.fileNames = [];
                this.fileNames = tempFileNames;
                this.isError = false;
                // this.getUploadedFilesByContentVersion(recId);
            }
            // console.log(JSON.stringify(this.fileNames), 'fileNamesfileNames')
        } catch (error) {
            console.error(error);
            this.showToastMessage(
                "Error!",
                this.customLabel.LeadOtp_UploadingFile_ErrorMessage,
                "error",
                "sticky"
            );
            // this.isLoading = false;
        }
    }

    connectedCallback() {

        getLightningHostname({}).then((result) => {
            this.lightningDomainName = result;
            // console.log("lightning page Domain Name ==>", this.lightningDomainName);
        });
        
        getVisualforceDomain({}).then((result) => {
            this.vfUrl = result;
        });

        window.addEventListener(
            "message",
            this.handleUploadCallback.bind(this)
        );
        var recId = this.leadRecordId;
        this.getUploadedFilesByContentVersion(recId);

        let parameter1 = {
            ParentObjectName: 'TeamHierarchy__c',
            ChildObjectRelName: null,
            parentObjFields: ['Id', 'Employee__c', 'EmpRole__c'],
            childObjFields: [],
            queryCriteria: ' where Employee__c  = \'' + CURRENTUSERID + '\' LIMIT 1'
        }
    
        getSobjDataWIthRelatedChilds({ params: parameter1 })
            .then(result => {
                // console.log('result of team TeamHierarchy:', JSON.stringify(result));
                if (result.parentRecord.EmpRole__c === 'RM' || result.parentRecord.EmpRole__c === 'SM') {
                    // console.log('RM SM');
                    this.isRoleRMSM = true;
                }
                else if(result.parentRecord.EmpRole__c === 'DSA')
                    this.isRoleDSA = true;
            })
            this.subscribeHandler();
           
            // console.log('lead id in connected',this.leadRecordId);
            // setTimeout(() => {
            //     this.fetchLeadRecord();
            // }, 2000);
            

    }

    handleUploadCallback(message) {
        console.log('Responve of vf Page ', message.data);

        if (message.data.source === "vf") {
            if (message.data.fileIdList != null || message.data.fileIdList.length > 0) {
                this.getUploadedFilesByContentVersion(this.leadRecordId);
                this.docName=''
                this.docCategory=''
                this.docType=''
                this.showUpload=false;
                if (this.fileName.trim() != '') {
                    let title = `${this.fileName} uploaded successfully!!`;
                    this.showToastMessage('Success', title, 'success', 'sticky');
                }
                //refreshApex(this.wiredFilesList);
                //  this.getUploadedFilesByContentVersion(this.leadRecordId);
                // this.consentType = 'Physical Consent Upload';
                // var leadData = {
                //     Id: this.leadRecordId,
                //     //OTP_Verified__c:true,
                //     MobilePhone: this.mobileNumberValue,
                //     Disposition_Status__c: this.dispositionStatus,
                //     ConsentType__c: this.consentType,
                //     Comments__c: this.commentsEntered,
                //     RationaleUsingPhyConsent__c: this.rationaleValue
                // };
                // updateLead({ leadData: leadData }).then(response => {
                //     // console.log('##response from update Lead##' + response);
                // })
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

    //retriving uploaded files

    // @wire(getUploadedFilesByContentVersion, { recordId: '$leadRecordId' })
    // wiredFiles(result) {
    //     this.wiredFilesList = result;
    //     if (result.data) {
    //         console.log('data--->' + result.data);
    //         //this.wiredFilesList = result.data;
    //         let tempFiles = []
    //         tempFiles = result.data.map(file => ({
    //             name: file.Title,
    //             size: file.ContentSize,
    //             cDId: file.Id,
    //             fileType:file.FileType,
    //             docType:file.Document_Type__c,
    //             docName:file.Document_Name__c,
    //             docCategory:file.Document_Category__c

    //         }));
    //         this.fileNames = [...tempFiles];
    //         if (this.fileNames.length > 0) {
    //            console.log('this.fileNames',this.fileNames)
    //         }
    //     } else if (result.error) {
    //         // Handle error
    //     }
    // }

    getUploadedFilesByContentVersion(recId) {
        getUploadedFilesByContentVersion({ recordId: recId})
            .then(data => {
                this.contentDocuments = data;
                console.log('this.fileNames data 1',JSON.stringify(data))
                // console.log('response from getUploadedFiles//306' + JSON.stringify(data));

                this.fileNames = data.map(file => ({
                    name: file.Title,
                    size: file.ContentSize,
                    cDId: file.ContentDocument.Id,
                    fileType:file.ContentDocument.FileType,
                    docType:file.Document_Type__c,
                    docName:file.Document_Name__c,
                    docCategory:file.Document_Category__c,
                    createDate:this.formatDateTime(file.ContentDocument.CreatedDate)
                }));
                // let tempArray = data.map(file => ({
                //     name: file.Title,
                //     size: file.ContentSize,
                //     cDId: file.ContentDocument.Id,
                //     fileType:file.ContentDocument.FileType,
                //     docType:file.Document_Type__c,
                //     docName:file.Document_Name__c,
                //     docCategory:file.Document_Category__c,
                //     createDate:this.formatDateTime(file.ContentDocument.CreatedDate)
                // })).filter(file => file.docType !== '' && file.docName !== '' && file.docCategory !== '');
                // this.fileNames = [...tempArray];
                // // for(let i = 0; i < tempArray.length; i++){
                // //     if(tempArray[i].Document_Category__c!='' && tempArray[i].Document_Type__c!='' && tempArray[i].Document_Name__c!=''){
                // //         this.fileNames.push({
                // //             name: tempArray[i].Title,
                // //             size: tempArray[i].ContentSize,
                // //             cDId: tempArray[i].ContentDocument.Id,
                // //             fileType:tempArray[i].ContentDocument.FileType,
                // //             docType:tempArray[i].Document_Type__c,
                // //             docName:tempArray[i].Document_Name__c,
                // //             docCategory:tempArray[i].Document_Category__c,
                // //             createDate:this.formatDateTime(tempArray[i].ContentDocument.CreatedDate)
                // //         });
                // //     }
                // // }
                console.log('this.fileNames data 2',JSON.stringify(this.fileNames))
                if (this.fileNames.length > 0) {
                    this.showTable=true;
                   // this.showConvertButton = true;

                    console.log('this.fileNames conn',this.fileNames)
                }
            });
    }

     //Date format   
    formatDateTime(dateTimeValue){
        if (!dateTimeValue) {
            return '';
        }
        const dateTime = new Date(dateTimeValue);
        const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        const options = { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' };
        // const formattedDate = dateTime.toLocaleDateString('en-US', options);
        // const formattedDate = `${dateTime.getMonth() + 1}/${dateTime.getDate()}/${dateTime.getFullYear()}`;
        const formattedDate = `${dateTime.getDate()}-${monthNames[dateTime.getMonth()]}-${dateTime.getFullYear()}`;
        const ampm = dateTime.getHours() >= 12 ? 'PM' : 'AM';
        const hours = dateTime.getHours() % 12 || 12;
        const minutes = ('0' + dateTime.getMinutes()).slice(-2);
        return `${formattedDate}, ${hours}:${minutes} ${ampm}`;
    }

    //Delete Action
    handleDocumentDelete(event) {

        let cdToDelete = event.currentTarget.dataset.id; // to delete individual file
        this.docIdToDelete = event.currentTarget.dataset.documentid;
        this.cdlIdToDelete = event.currentTarget.dataset.cdlid;
       
        this.docId= event.currentTarget.dataset.id;
        this.isModalOpen = true;
        
    }

    closeConsentModal() {
        this.isModalOpen = false;
    }

    handleRemoveRecord(event) {
        // console.log("delete file called");
        // console.log("id is ==> " + this.docId);
        let cdToDelete = this.docId;
        let tempFileNames = this.fileNames;
        console.log('tempFileNames',JSON.stringify(tempFileNames));
        this.fileNames = [];
        const index = tempFileNames.findIndex(file => file.cDId === cdToDelete);
        // console.log("index###" + index);
        deleteRecord(cdToDelete)
            .then(() => {
                // if (index !== -1) {
                //     tempFileNames.splice(index, 1);
                //     // console.log("fileNames###" + tempFileNames);
                //     this.fileNames = tempFileNames;
                //     if (this.fileNames.length == 0) {
                //         this.otpVerified = false;
                //     }
                //     this.getUploadedFilesByContentVersion(recId)
                //     console.log('this.fileNames length-->' + this.fileNames.length);
                // }
                this.getUploadedFilesByContentVersion(this.leadRecordId)
                const toastEvent = new ShowToastEvent({
                    title: "",
                    message: this.customLabel.LeadOtp_Del_SuccessMessage,
                    variant: "success"
                });
                this.dispatchEvent(toastEvent);
                // this.dispatchEvent(new RefreshEvent());
            })
            .catch((error) => {
                console.log(
                    "Unable to delete record due to " + error.body.message
                );
            });
        this.isModalOpen = false
    }
    //preview Action
    handleDocumentView(event) {
        console.log("ID is ==> " + event.currentTarget.dataset.id);
        console.log("View file called", event.currentTarget.dataset);
        console.log("View: " + JSON.stringify(this.fileNames));
    
        let itemId = event.currentTarget.dataset.id;  // Get the file ID from dataset
        let fileType = event.currentTarget.dataset.fileType;  // Get the file type from dataset
        
        console.log("File ID from dataset: ", itemId);
        console.log("File Type from dataset: ", fileType);
    
        const recordMap = new Map(this.fileNames.map(record => [record.cDId, record]));
        let recorddata = recordMap.get(itemId);
    
        if (recorddata) {
            this.contentDocumentId = recorddata.cDId;  // Assign content document ID
            this.contentDocumentType = fileType;  // Assign content document type
        }
    
        console.log('Record data:', JSON.stringify(recorddata));
    
        if (this.isRoleDSA !== true) {
            console.log("View file called");
        try {
            this[NavigationMixin.Navigate]({
                type: "standard__namedPage",
                attributes: {
                    pageName: "filePreview"
                },
                state: {
                        selectedRecordId: itemId
                }
            });
        } catch (e) {
                console.error("Error navigating to file preview:", e);
            }
        } else {
            this.filePreview(event);
            console.log("Preview file called");
        }
    }
    
    filePreview(event) {
        console.log("Preview file called");
    
        let fileId = event.currentTarget.dataset.id;  // Get the file ID from dataset
        let fileType = event.currentTarget.dataset.fileType;  // Get the file type from dataset
    
        console.log("File ID from dataset: ", fileId);
        console.log("File Type from dataset: ", fileType);
    
        // Ensure values are correctly assigned
        this.contentDocumentId = fileId;  
        this.contentDocumentType = fileType;
    
        console.log('Content Document ID:', this.contentDocumentId);
        console.log('Content Document Type:', this.contentDocumentType);
        console.log('Before setting showModal:', this.showModal);
        
        this.showModal = true;
        console.log('After setting showModal:', this.showModal);
    }
    

handleCloseModalEvent(){
    this.showModal = false;
}


closeModal() {
this.showModal = false;
    console.log('Close image:');
    }

    //toast
    showToastMessage(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant,
            mode
        });
        this.dispatchEvent(evt);
    }

    //footer

    handleCancel() {
        this.navigateToListView();
    }

    navigateToListView() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Lead',
                actionName: 'list'
            },
        })
    }
    handlePrevious() {
       // this.OTPPreviousValue = true;
        // console.log('FlowAttributeChangeEvent mobileNumberValue--' + this.mobileNumberValue);
        // console.log('FlowAttributeChangeEvent rationaleValue--' + this.rationaleValue);
        // console.log('FlowAttributeChangeEvent commentsEntered--' + this.commentsEntered);
        // console.log('FlowAttributeChangeEvent city & channel--' + this.pvCityVerified + '----' + this.pvChannelVerified);
        // console.log('FlowAttributeChangeEvent city_Bkp & channel_Bkp--' + this.CityValue_Bkp + '----' + this.pvChannelVerChannelValue_Bkpified);
        // this.dispatchEvent(new FlowAttributeChangeEvent('mobile', this.mobileNumberValue));
        // this.dispatchEvent(new FlowAttributeChangeEvent('VarRationaleValue', this.rationaleValue));
        // this.dispatchEvent(new FlowAttributeChangeEvent('VarRationaleCommentsValue', this.commentsEntered));
        // this.dispatchEvent(new FlowAttributeChangeEvent('pvCityVerified', this.pvCityVerified));
        // this.dispatchEvent(new FlowAttributeChangeEvent('pvChannelVerified', this.pvChannelVerified));
        // this.dispatchEvent(new FlowAttributeChangeEvent('CityValue_Bkp', this.CityValue_Bkp));
        // this.dispatchEvent(new FlowAttributeChangeEvent('ChannelValue_Bkp', this.ChannelValue_Bkp));
        // this.dispatchEvent(new FlowAttributeChangeEvent('valRationale',this.rationaleValue));
        // this.dispatchEvent(new FlowAttributeChangeEvent('valRationalComments',this.commentsEntered));
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }

    showConvertButton = true;  
    isRoleRMSM = false;
    isRoleDSA = false;
    
    
    get _showConvertButton() {
        return this.showConvertButton && (this.isRoleRMSM||this.isRoleDSA);
    }

    async handleNext() {
        // console.log('this.fileName size on convert btn--->' + this.fileNames.length);
        // console.log(this.mobileNumberValue + 'handle next event called' + this.updatedMobileNumber);
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
       
             
    }

    //close lead
    @track closureReason;
    showAdditionalComments = false;
    addCommentsEntered;
    handleSubmit(event) {
        // console.log('Enterd Handle submit');
        event.preventDefault();
        const fields = event.detail.fields;
        if (this.closureReason) {
            fields.Disposition_Status__c = 'Lead closed'
        }
        console.log('fields--->' + fields);
        if (fields.Lead_Closure_Reason__c != '' && fields.Lead_Closure_Reason__c != undefined) {
            fields.Status = 'Closed';
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.leadRecordId,
                    objectApiName: 'Lead',
                    actionName: 'view'
                },
            });
            this.template.querySelector('lightning-record-edit-form').submit(fields);
            this.showToastMessage('Success', this.customLabel.LeadOtp_Has_SuccessMessage + fields.Status + this.customLabel.LeadOtp_Succ_SuccessMessage, 'success', 'sticky');
        } else {
            console.log('Enterd into else submit');
            this.showToastMessage('Error', this.customLabel.LeadOtp_leadClouse_ErrorMessage, 'error', 'sticky');
        }
    }

    handlePicklistChange(event) {
        // console.log('####CR###' + event.target.value);
        this.closureReason = event.target.value;
        if (this.closureReason === 'Others') {
            this.showAdditionalComments = true;
        } else {
            this.showAdditionalComments = false;
        }
    }

    onChangeAdditionalComments(event) {
        // console.log('Additional comments-->' + event.target.value);
        this.addCommentsEntered = event.target.value;
        if (this.addCommentsEntered.trim().length < 1) {
            this.template.querySelector("lightning-input[data-id=addCommentsInput]").setCustomValidity('Please update additional comments when Other Lead Closure Reason value is selected');
            this.template.querySelector("lightning-input[data-id=addCommentsInput]").reportValidity();
        } else {
            this.template.querySelector("lightning-input[data-id=addCommentsInput]").setCustomValidity('');
            this.template.querySelector("lightning-input[data-id=addCommentsInput]").reportValidity()
        }
        this.addCommentsEntered = this.addCommentsEntered.trim();
    }
    closeModal() {
        this.isShowModal = false;
        this.resetForm();
    }
    @track isShowModal = false;

    @wire(MessageContext)
    context

    subscribeHandler() {
        // console.log('######subscriber called#########');
        subscribe(this.context, LEADDATAMC, (message) => { this.handleMessage(message) }, { scope: APPLICATION_SCOPE })
    }
    handleMessage(message) {
        console.log('######handleMessage called#########' + message.lmsData.value);
        if (message.lmsData.value === 'Close Lead') {
            this.isShowModal = true;
        }
    }
    resetForm() {
        // Clear the form fields
        this.template.querySelectorAll('lightning-input-field').forEach((field) => {
            field.reset();
        });
        // Reset any other state variables or flags
        this.showAdditionalComments = false;
    }
}