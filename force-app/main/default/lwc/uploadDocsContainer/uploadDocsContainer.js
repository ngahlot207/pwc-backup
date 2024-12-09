import { LightningElement, track, api, wire } from "lwc";

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";

import getLightningHostname from "@salesforce/apex/DomainNameProvider.getLightningHostname";
import getVisualforceDomain from "@salesforce/apex/DomainNameProvider.getVisualforceDomain";

import createAppkycDd from "@salesforce/apex/DocumentDetailController.createAppkycDd";

// //1. Import the method "createRecord" which is a named import
// import { createRecord } from "lightning/uiRecordApi";

// //2. Import the reference to Object and Fields
// import APPL_KYC from "@salesforce/schema/ApplKyc__c";
// import INTG_MSG from "@salesforce/schema/IntgMsg__c";

// import DOCUMENT_DETAIL from "@salesforce/schema/ApplKyc__c.Document_Detail__c";
// import KYC_DOC from "@salesforce/schema/ApplKyc__c.kycDoc__c";
// import APPLICANT from "@salesforce/schema/ApplKyc__c.Applicant__c";

// import NAME from "@salesforce/schema/IntgMsg__c.Name";
// import REF_ID from "@salesforce/schema/IntgMsg__c.RefId__c";
// import BU from "@salesforce/schema/IntgMsg__c.BU__c";
// import IS_ACTIVE from "@salesforce/schema/IntgMsg__c.IsActive__c";
// import SVC from "@salesforce/schema/IntgMsg__c.Svc__c";
// import EXUC_TYPE from "@salesforce/schema/IntgMsg__c.ExecType__c";
// import STATUS from "@salesforce/schema/IntgMsg__c.Status__c";
// import REF_OBJ from "@salesforce/schema/IntgMsg__c.RefObj__c";
// import DOC_API from "@salesforce/schema/IntgMsg__c.DocApi__c";
// import OUTBOUND from "@salesforce/schema/IntgMsg__c.Outbound__c";
// import TRIGGER_PLATFORM_EVENT from "@salesforce/schema/IntgMsg__c.Trigger_Platform_Event__c";
// import PARENT_REF_ID from "@salesforce/schema/IntgMsg__c.ParentRefId__c";
// import PARENT_REF_OBJ from "@salesforce/schema/IntgMsg__c.ParentRefObj__c";



import formFactorPropertyName from "@salesforce/client/formFactor";
const MAX_FILE_SIZE = 5242880; //in bytes 5 MB now

//200 Mb max can go upto 2 Gb 
// Custom labels
import UploadDocContainer_Type_ErrorMessage from '@salesforce/label/c.UploadDocContainer_Type_ErrorMessage';
import UploadDocContainer_Size_ErrorMessage from '@salesforce/label/c.UploadDocContainer_Size_ErrorMessage';
import UploadDocContainer_Name_ErrorMessage from '@salesforce/label/c.UploadDocContainer_Name_ErrorMessage';
import UploadDocContainer_Upload_SuccessMessage from '@salesforce/label/c.UploadDocContainer_Upload_SuccessMessage';
import UploadDocContainer_Upload_ErrorMessage from '@salesforce/label/c.UploadDocContainer_Upload_ErrorMessage';
import UploadDocContainer_SelFile_ErrorMessage from '@salesforce/label/c.UploadDocContainer_SelFile_ErrorMessage';

//export default class UploadDocsContainer extends LightningElement {}
export default class extends NavigationMixin(LightningElement) {
    customLabel = {
        UploadDocContainer_Type_ErrorMessage,
        UploadDocContainer_Size_ErrorMessage,
        UploadDocContainer_Name_ErrorMessage,
        UploadDocContainer_Upload_SuccessMessage,
        UploadDocContainer_Upload_ErrorMessage,
        UploadDocContainer_SelFile_ErrorMessage

    }
    @api loanAppId;
    @api applicantId;
    @api docName;
    @api docType;
    @api docCategory;
    @api allowedFilFormat = [".jpg", ".jpeg", ".pdf"];

    @api fileSizeMsz = "Maximum File Size should be 5Mb. Allowed File Types are  .jpg, .jpeg, .pdf ";

    @track isSite = false;
    @track lightningDomainName;
    @track vfUrl;
    @track showSpinner = false;
    @track fileData = [];
    @track fileName = '';
    @track formFactor = formFactorPropertyName;
    @track creadedRecIds;
    @api disableMode;



    @track documentDetaiId;
    @track applicantKycId;
    receiveMessageCallback;

    // To get the pge reference 
    @wire(CurrentPageReference) pageRef;

    get iscommunity() {
        return this.pageRef.type;
    }

    connectedCallback() {
        console.log('disableMode', this.disableMode)
        console.log('this  component is running  on ', JSON.stringify(this.pageRef));
        getVisualforceDomain({}).then((result) => {
            this.vfUrl = result;
            console.log("vf page domain==>", this.vfUrl, this.iscommunity);
        });

        getLightningHostname({}).then((result) => {
            this.lightningDomainName = result;
            console.log("lightning page Domain Name ==>", this.lightningDomainName);
        });
        this.receiveMessageCallback = this.handleUploadCallback.bind(this);
        window.addEventListener(
            "message",
            this.receiveMessageCallback
        );
    }

    disconnectedCallback() {
        window.removeEventListener('message', this.receiveMessageCallback);
    }

    handleFileChange(event) {
        if (
            event.target.files.length > 0
            &&
            this.docName &&
            this.docType
        ) {
            let dt = [];

            for (var i = 0; i < event.target.files.length; i++) {
                console.log('file size  for ', i, '  ', event.target.files[i].size);




                let file = event.target.files[i];
                this.fileName = this.fileName + " " + file.name;
                let extension = this.fileName.split('.').pop();
                if (!this.allowedFilFormat.includes('.' + extension)) {
                    this.showToast("Error!", "error", this.customLabel.UploadDocContainer_Type_ErrorMessage, "sticky");
                    this.showSpinner = false;
                    this.fileName = "";
                    return;
                }


                let reader = new FileReader();
                let self = this;
                let fSize = MAX_FILE_SIZE
                reader.onload = (e) => {
                    let fileContents;

                    if (extension.includes('jpg') || extension.includes('jpeg')) {
                        var img = new Image();

                        img.src = reader.result;

                        img.onload = function () {
                            let canvas = document.createElement('canvas');
                            let width = img.width;
                            let height = img.height;
                            canvas.width = width;
                            canvas.height = height;
                            let ctx = canvas.getContext("2d");
                            ctx.drawImage(img, 0, 0, width, height);

                            let compressedImage = canvas.toDataURL('image/jpeg', 0.5);
                            //var imgFileSize = data_url.length;
                            console.log(compressedImage.length);
                            fileContents = compressedImage.split(',')[1];
                            let data = {
                                fileName: file.name + "  ",
                                fileContent: fileContents
                            };

                            var head = 'data:image/jpeg;base64,';
                            var imgFileSize = Math.round((compressedImage.length - head.length) * 3 / 4);
                            console.log(imgFileSize);
                            dt = [...dt, data];
                            self.fileData = [...self.fileData, data];
                            self.fileData = [...self.fileData, dt];

                            //check for compressed filesize
                            if (imgFileSize > MAX_FILE_SIZE) {
                                this.showToast(
                                    "Error!",
                                    "error",
                                    this.customLabel.UploadDocContainer_Size_ErrorMessage,
                                    "sticky"
                                );
                                return;
                            }
                            self.createDocumentDetailRecord();

                        };
                    }
                    // else if(extension.includes('jpg')){

                    // }
                    else {

                        if (file.size > fSize) {
                            self.showToast(
                                "Error!",
                                "error",
                                this.customLabel.UploadDocContainer_Size_ErrorMessage,
                                "sticky"
                            );
                            return;
                        }
                        fileContents = reader.result.split(",")[1];
                        let data = {
                            fileName: file.name + "  ",
                            fileContent: fileContents
                        };

                        dt = [...dt, data];
                        self.fileData = [...self.fileData, data];
                        self.fileData = [...self.fileData, dt];
                        self.createDocumentDetailRecord();
                    }









                    /*let data = {
                        fileName: file.name + "  ",
                        fileContent: fileContents
                    };

                    dt = [...dt, data];
                    self.fileData = [...self.fileData, data];
                    self.fileData = [...self.fileData, dt];*/
                };

                reader.readAsDataURL(file);

            }
            //this.createDocumentDetailRecord();
            // console.log("File Ready For Upload   ", reader, "creating AppKyc And Document Detail ");



        } else {
            this.showToast("Error!", "error", this.customLabel.UploadDocContainer_Name_ErrorMessage, "sticky");
        }
    }


    handleUploadCallback(message) {

        console.log('Responve of vf Page ', message.data);

        if (message.data.source === "vf") {
            let param = {};
            if (message.data.fileIdList != null || message.data.fileIdList.length > 0) {
                //  console.log('Responve from vf Page ', message.data.fileIdList);
                this.showToast(
                    "Success",
                    "success",
                    this.customLabel.UploadDocContainer_Upload_SuccessMessage,
                    "sticky"
                );

                param = {
                    fileUploaded: true,
                    uploadedFileId: message.data.fileIdList,
                    appKycId: this.applicantKycId,
                    docDetailId: this.documentDetaiId,
                    docName: this.docName
                };

                console.log('File Uploaded Succcess   ', param);
                this.fileData = [];
                //  this.spinnerStatus(false);
            } else {
                // this.spinnerStatus(false);
                param = {
                    fileUploaded: false,
                    uploadedFileId: message.data,
                    appKycId: this.applicantKycId,
                    docDetailId: this.documentDetaiId,
                    docName: this.docName
                }
                console.log('File Uploaded Error   ', param);
                this.showToast("Error", "error ", this.customLabel.UploadDocContainer_Upload_ErrorMessage, "sticky");
            }
            this.passToParent(param);

        }
    }

    createDocumentDetailRecord() {

        createAppkycDd({ applicantId: this.applicantId, loanAppId: this.loanAppId, docCategory: this.docCategory, docType: this.docType, docSubType: this.docName })
            .then((result) => {
                console.log('DocumantDetail And AppKyc  Created   ', result);
                this.creadedRecIds = result;
                this.documentDetaiId = result.docDetId;
                this.applicantKycId = result.appKycId;
                this.fileUploadHandleer();

            })
            .catch((err) => {
                this.showToast("Error", "error", err, "sticky");
                console.log(" createDocumentDetailRecord error===", err);
            });

    }


    fileUploadHandleer() {
        if (this.fileData == [] || this.fileData.length == 0) {
            this.spinnerStatus(false);
            this.showToast("Error", "error", this.customLabel.UploadDocContainer_SelFile_ErrorMessage, "sticky");
            return;
        } else {
            this.spinnerStatus(true);
            this.uploadFileLargeVf();


        }
    }
    showToast(title, variant, message, mode) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    // //update the record page
    // updateRecordView() {
    //     setTimeout(() => {
    //         eval("$A.get('e.force:refreshView').fire();");
    //     }, 1000);
    // }

    // //Handling file uploaded once uplaoding is finished
    // handleUploadFinished(event) {
    //     console.log('after update called  ');  //new
    //     // Get the list of uploaded files
    //     const uploadedFiles = event.detail.files;
    //     let uploadedFileNames = "";
    //     for (let i = 0; i < uploadedFiles.length; i++) {
    //         uploadedFileNames += uploadedFiles[i].name + ", ";
    //     }
    //     this.dispatchEvent(
    //         new ShowToastEvent({
    //             title: "Success",
    //             message:
    //                 uploadedFiles.length +
    //                 " Files uploaded Successfully: " +
    //                 uploadedFileNames,
    //             variant: "success"
    //         })
    //     );
    // }

    uploadFileLargeVf() {
        this.template.querySelector("iframe").contentWindow.postMessage(
            JSON.parse(
                JSON.stringify({
                    source: "lwc",
                    files: this.fileData,
                    parameters: this.documentDetaiId,
                    lightningDomain: this.lightningDomainName
                })
            ),
            this.vfUrl
        );
        // console.log("upload called vfurl",
        //     " files:", this.fileData,
        //     " parameters:", this.documentDetaiId,
        //     "  lightningDomain:", this.lightningDomainName);
    }

    // createApplicantKycObj() {
    //     const fields = {};
    //     fields[DOCUMENT_DETAIL.fieldApiName] = this.documentDetaiId;
    //     fields[KYC_DOC.fieldApiName] = this.docName;
    //     fields[APPLICANT.fieldApiName] = this.applicantId;

    //     const recordInput = {
    //         apiName: APPL_KYC.objectApiName,
    //         fields: fields
    //     };

    //     createRecord(recordInput).then((record) => {
    //         console.log("createApplicantKycObj", record);
    //         this.createIntegrationMsg(record.id);
    //     });
    // }

    passToParent(param) {
        console.log('passToParent 0 ');
        this.documentDetaiId = "";
        this.applicantKycId = "";
        this.fileName = "";
        console.log('passToParent 1 ');
        const selectEvent = new CustomEvent('refreshdoctable', {
            detail: param
        });
        // Fire the custom event
        this.dispatchEvent(selectEvent);

    }

    // createIntegrationMsg(appKycId, ddId) {
    //     let serviceName = 'KYC OCR';
    //     const fields = {};
    //     fields[NAME.fieldApiName] = serviceName; //serviceName;//'KYC OCR'
    //     fields[REF_ID.fieldApiName] = ddId;
    //     fields[BU.fieldApiName] = 'HL / STL';
    //     fields[IS_ACTIVE.fieldApiName] = true;
    //     fields[SVC.fieldApiName] = serviceName; //serviceName;
    //     fields[EXUC_TYPE.fieldApiName] = 'Async';
    //     fields[STATUS.fieldApiName] = 'New';
    //     fields[REF_OBJ.fieldApiName] = 'DocDtl__c';
    //     fields[DOC_API.fieldApiName] = true;
    //     fields[OUTBOUND.fieldApiName] = true;
    //     fields[TRIGGER_PLATFORM_EVENT.fieldApiName] = true;
    //     fields[PARENT_REF_OBJ.fieldApiName] = "ApplKyc__c";
    //     fields[PARENT_REF_ID.fieldApiName] = appKycId;


    //     //4. Prepare config object with object and field API names 
    //     const recordInput = {
    //         apiName: INTG_MSG.objectApiName,
    //         fields: fields
    //     };

    //     //5. Invoke createRecord by passing the config object
    //     createRecord(recordInput).then((record) => {
    //         console.log("createIntegrationMsg", record);
    //         this.integratMsgId = record.id;
    //         //this.passToParent();
    //     });
    // }
    @api spinnerStatus(event) {
        this.showSpinner = event;
        const selectEvent = new CustomEvent('spinnerstatus', {
            detail: event
        });
        // Fire the custom event
        this.dispatchEvent(selectEvent);
    }

}