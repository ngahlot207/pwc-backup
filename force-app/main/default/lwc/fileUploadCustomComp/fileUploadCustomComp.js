import { LightningElement, track, api, wire } from "lwc";

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";

import getLightningHostname from "@salesforce/apex/DomainNameProvider.getLightningHostname";
import getVisualforceDomain from "@salesforce/apex/DomainNameProvider.getVisualforceDomain";

//import createAppkycDd from "@salesforce/apex/DocumentDetailController.createAppkycDd";

import formFactorPropertyName from "@salesforce/client/formFactor";
const MAX_FILE_SIZE = 5242880; //in bytes 5 MB now

//200 Mb max can go upto 2 Gb 
// Custom labels
import FileUploadcustomComp_Type_Errormessage from '@salesforce/label/c.FileUploadcustomComp_Type_Errormessage';
import FileUploadcustomComp_Size_Errormessage from '@salesforce/label/c.FileUploadcustomComp_Size_Errormessage';
import FileUploadcustomComp_Parentid_Errormessage from '@salesforce/label/c.FileUploadcustomComp_Parentid_Errormessage';
import FileUploadcustomComp_SuccessMessage from '@salesforce/label/c.FileUploadcustomComp_SuccessMessage';
import FileUploadcustomComp_Upload_Errormessage from '@salesforce/label/c.FileUploadcustomComp_Upload_Errormessage';
import FileUploadcustomComp_SelFile_Errormessage from '@salesforce/label/c.FileUploadcustomComp_SelFile_Errormessage';

export default class FileUploadCustomComp extends NavigationMixin(LightningElement) {
    @track toastLabel = {
        FileUploadcustomComp_Type_Errormessage,
        FileUploadcustomComp_Size_Errormessage,
        FileUploadcustomComp_Parentid_Errormessage,
        FileUploadcustomComp_SuccessMessage,
        FileUploadcustomComp_Upload_Errormessage,
        FileUploadcustomComp_SelFile_Errormessage

    }
    @api loanAppId;
    @api applicantId;
    @api docName;
    @api docType;
    @api docCategory;

    @api variant;
    @api label = '';
    @api recordId;
    @api allowedFilFormat;
    @api fileSizeMsz = "Maximum File Size should be 5Mb. Allowed File Types are  .jpg, .jpeg, .pdf ";
    @api disableMode;
    @api allowMultiple;
    @api maxFileSize;





    @track isSite = false;
    @track lightningDomainName;
    @track vfUrl;
    @track showSpinner = false;
    @track fileData = [];
    @track fileName = '';
    @track formFactor = formFactorPropertyName;
    @track creadedRecIds;
    receiveMessageCallback;



    // @track recordId;
    @track applicantKycId;

    // To get the pge reference 
    @wire(CurrentPageReference) pageRef;

    get iscommunity() {
        return this.pageRef.type;
    }

    connectedCallback() {
        console.log('FileUpload Comp', this.disableMode, this.allowMultiple, this.allowedFilFormat);
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
        // window.addEventListener(
        //     "message",
        //     this.handleUploadCallback.bind(this)
        // );
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
            this.recordId
        ) {
            let dt = [];

            for (var i = 0; i < event.target.files.length; i++) {
                console.log('file size  for ', i, '  ', event.target.files[i].size);




                let file = event.target.files[i];
                this.fileName = this.fileName + " " + file.name;
                let extension = this.fileName.split('.').pop();
                console.log(this.allowedFilFormat, extension, this.allowedFilFormat.includes('.' + extension));
                if (!this.allowedFilFormat.includes('.' + extension)) {
                    console.log('this.allowedFilFormat ', this.allowedFilFormat);
                    this.showToast("Error!", "error", this.toastLabel.FileUploadcustomComp_Type_Errormessage);
                    this.showSpinner = false;
                    this.fileName = "";
                    return;
                }

                let reader = new FileReader();
                let self = this;
                let fSize = MAX_FILE_SIZE
                if (this.maxFileSize) {
                    fSize = this.maxFileSize
                }

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
                            console.log('compressedImage', compressedImage.length);
                            fileContents = compressedImage.split(',')[1];
                            let data = {
                                fileName: file.name + "  ",
                                fileContent: fileContents
                            };

                            var head = 'data:image/jpeg;base64,';
                            var imgFileSize = Math.round((compressedImage.length - head.length) * 3 / 4);
                            console.log('imgFileSize', imgFileSize);
                            dt = [...dt, data];
                            self.fileData = [...self.fileData, data];
                            self.fileData = [...self.fileData, dt];

                            //check for compressed filesize
                            if (imgFileSize > MAX_FILE_SIZE) {
                                this.showToast(
                                    "Error!",
                                    "error",
                                    this.toastLabel.FileUploadcustomComp_Size_Errormessage
                                );
                                return;
                            }
                            // self.fileUploadHandleer();

                        };
                    }
                    // else if(extension.includes('jpg')){

                    // }
                    else {

                        if (file.size > fSize) {
                            self.showToast(
                                "Error!",
                                "error",
                                this.fileSizeMsz
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
                        // self.createDocumentDetailRecord();
                        //self.fileUploadHandleer();
                    }

                };

                reader.readAsDataURL(file);

                let fileLength = event.target.files.length;
                console.log("File Ready For Upload 0", fileLength, i);
                if (fileLength) {
                    console.log("File Ready For Upload ");
                    setTimeout(() => { this.fileUploadHandleer(); }, 2000);
                    //this.fileUploadHandleer();
                }
            }
            // console.log("File Ready For Upload ", this.fileData);
            // this.fileUploadHandleer();
            //this.createDocumentDetailRecord();
            // console.log("File Ready For Upload   ", reader, "creating AppKyc And Document Detail ");



        } else {
            console.log('Error in File Upload ', this.toastLabel);
            this.showToast("Error!", "error", this.toastLabel.FileUploadcustomComp_Parentid_Errormessage, 'sticky');
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
                    this.toastLabel.FileUploadcustomComp_SuccessMessage
                );

                param = {
                    fileUploaded: true,
                    uploadedFileId: message.data.fileIdList,
                    // appKycId: this.applicantKycId,
                    docDetailId: this.recordId,
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
                    // appKycId: this.applicantKycId,
                    docDetailId: this.recordId,
                    docName: this.docName
                }
                console.log('File Uploaded Error   ', param);
                this.showToast("Error", "error ", this.toastLabel.FileUploadcustomComp_Upload_Errormessage);
            }
            this.spinnerStatus(false);
            this.passToParent(param);

        }
    }

    fileUploadHandleer() {
        if (this.fileData == [] || this.fileData.length == 0) {
            this.spinnerStatus(false);
            //this.showToast("Error", "error", this.label.FileUploadcustomComp_SelFile_Errormessage);
            return;
        } else {
            this.spinnerStatus(true);
            this.uploadFileLargeVf();
        }
    }
    showToast(title, variant, message) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
    }

    uploadFileLargeVf() {
        this.template.querySelector("iframe").contentWindow.postMessage(
            JSON.parse(
                JSON.stringify({
                    source: "lwc",
                    files: this.fileData,
                    parameters: this.recordId,
                    lightningDomain: this.lightningDomainName
                })
            ),
            this.vfUrl
        );

    }

    passToParent(param) {
        console.log('passToParent 0 ');
        const selectEvent = new CustomEvent('passtoparent', {
            detail: param
        });
        // Fire the custom event
        this.dispatchEvent(selectEvent);
        this.recordId = "";
        //  this.applicantKycId = "";
        this.fileName = "";
        console.log('fileUploadCustom ');
    }

    @api spinnerStatus(event) {
        this.showSpinner = event;
        console.log('spinnerStatus called ', event, this.showSpinner);
        const selectEvent = new CustomEvent('spinnerstatus', {
            detail: event
        });
        // Fire the custom event
        this.dispatchEvent(selectEvent);
    }

}