import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getLightningHostname from "@salesforce/apex/DomainNameProvider.getLightningHostname";
import getVisualforceDomain from "@salesforce/apex/DomainNameProvider.getVisualforceDomain";

const MAX_FILE_SIZE = 5242880; //in bytes 5 MB now
// Custom labels
import NdcUpload_SuccessMessage from '@salesforce/label/c.NdcUpload_SuccessMessage';
import NdcUpload_ErrorMessage from '@salesforce/label/c.NdcUpload_ErrorMessage';
import NdcUpload_Size_ErrorMessage from '@salesforce/label/c.NdcUpload_Size_ErrorMessage';
import NdcUpload_Type_ErrorMessage from '@salesforce/label/c.NdcUpload_Type_ErrorMessage';
import NdcUpload_DocExist_ErrorMessage from '@salesforce/label/c.NdcUpload_DocExist_ErrorMessage';
import NdcUpload_File_ErrorMessage from '@salesforce/label/c.NdcUpload_File_ErrorMessage';


export default class NdcUploadDocument extends LightningElement {
    customLabel = {
        NdcUpload_SuccessMessage,
        NdcUpload_ErrorMessage,
        NdcUpload_Size_ErrorMessage,
        NdcUpload_Type_ErrorMessage,
        NdcUpload_DocExist_ErrorMessage,
        NdcUpload_File_ErrorMessage

    }

    @api loanAppId;
    @api docDtlId;

    @track vfUrl;
    @track lightningDomainName;
    @track fileData = [];
    @track allowedFilFormat = [".jpg", ".jpeg", ".pdf"];
    @track fileSizeMsz = "Maximum File Size should be 5Mb. Allowed File Types are  .jpg, .jpeg, .pdf ";
    @track fileName;

    connectedCallback() {
        getVisualforceDomain().then((result) => {
            this.vfUrl = result;
            console.log("vf page domain==>", this.vfUrl);
        });

        getLightningHostname().then((result) => {
            this.lightningDomainName = result;

            console.log("lightningDomainName ==>", this.lightningDomainName);
        });

        window.addEventListener(
            "message",
            this.handleUploadCallback.bind(this)
        );
    }

    handleUploadCallback(message) {
        console.log('responve from vf 111 ', JSON.stringify(message.data));
        if (message.data.source === "vf") {
            if (message.data.fileIdList != null) {
                this.fileData = [];
                const selectEvent = new CustomEvent('uploaddoc', {
                    detail: true
                });
                this.dispatchEvent(selectEvent);

                this.showToast(
                    "Success",
                    "success",
                    this.customLabel.NdcUpload_SuccessMessage
                );
                this.showSpinner = false;
                // this.refreshDocTable();
            } else {
                this.showSpinner = false;
                this.showToast("Error", "error", this.customLabel.NdcUpload_ErrorMessage);
            }
        }
    }

    handleFileChange(event) {
        console.log('docuemnt detail id #66 ', this.docDtlId);
        if (
            event.target.files.length > 0
        ) {
            this.showSpinner = true;
            let dt = [];
            console.log('event.target.files.length ', event.target.files.length);
            for (var i = 0; i < event.target.files.length; i++) {
                console.log('file size  for ', i, '  ', event.target.files[i].size);
                if (event.target.files[i].size > MAX_FILE_SIZE) {
                    this.showToast(
                        "Error!",
                        "error",
                        this.customLabel.NdcUpload_Size_ErrorMessage
                    );
                    this.showSpinner = false;
                    return;
                }

                let file = event.target.files[i];
                this.fileName = this.fileName + " " + file.name;
                let extension = this.fileName.split('.').pop();
                if (!this.allowedFilFormat.includes('.' + extension)) {
                    this.showToast("Error!", "error", this.customLabel.NdcUpload_Type_ErrorMessage);
                    this.showSpinner = false;
                    this.fileName = "";
                    return;
                }
                let reader = new FileReader();
                let self = this;
                reader.onload = (e) => {
                    let fileContents = reader.result.split(",")[1];
                    let data = {
                        fileName: file.name + "  ",
                        fileContent: fileContents
                    };
                    dt = [...dt, data];
                    self.fileData = [...self.fileData, data];
                    self.fileData = [...self.fileData, dt];
                    self.fileUploadHandleer();
                };
                reader.readAsDataURL(file);
            }


        } else {

            this.showToast("Error!", "error", this.customLabel.NdcUpload_DocExist_ErrorMessage);
        }
    }

    fileUploadHandleer() {
        console.log('fileData ', this.fileData);
        if (this.fileData === [] || this.fileData.length === 0) {
            this.showSpinner = false;
            this.showToast("Error", "error", this.customLabel.NdcUpload_File_ErrorMessage);
            return;
        } else {
            this.uploadFileLargeVf();
        }
    }

    uploadFileLargeVf() {
        console.log("domain name=====>", this.lightningDomainName);
        this.template.querySelector("iframe").contentWindow.postMessage(
            JSON.parse(
                JSON.stringify({
                    source: "lwc",
                    files: this.fileData,
                    parameters: this.docDtlId,
                    lightningDomain: this.lightningDomainName
                })
            ),
            this.vfUrl
        );
        console.log("upload called vfurl",
            " files:", this.fileData,
            " parameters:", this.docDtlId,
            "  lightningDomain:", this.lightningDomainName);
    }

    showToast(title, variant, message) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message
        });
        this.dispatchEvent(evt);
    }
}