import { LightningElement, track, api, wire } from "lwc";
import { loadScript } from 'lightning/platformResourceLoader';
//import html2canvasResource from '@salesforce/resourceUrl/html2canvas';

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
//const MAX_FILE_SIZE = 5242880; //in bytes 5 MB now

//200 Mb max can go upto 2 Gb 
// Custom labels
import UploadDocContainer_Type_ErrorMessage from '@salesforce/label/c.UploadDocContainer_Type_ErrorMessage';
import UploadDocContainer_Size_ErrorMessage from '@salesforce/label/c.UploadDocContainer_Size_ErrorMessage';
import UploadDocContainer_Name_ErrorMessage from '@salesforce/label/c.UploadDocContainer_Name_ErrorMessage';
import UploadDocContainer_Upload_SuccessMessage from '@salesforce/label/c.UploadDocContainer_Upload_SuccessMessage';
import UploadDocContainer_Upload_ErrorMessage from '@salesforce/label/c.UploadDocContainer_Upload_ErrorMessage';
import UploadDocContainer_SelFile_ErrorMessage from '@salesforce/label/c.UploadDocContainer_SelFile_ErrorMessage';
import UploadDocContainer_SameFile_ErrorMessage from '@salesforce/label/c.UploadDocsConatiner_Different_File_Type';
import UploadDocContainer_SingleFile_ErrorMessage from '@salesforce/label/c.UploadDocsContainer_single_File_Allowed'


//this will return img width and hieght
const loadImage = (file) => {
    return new Promise((resolve, reject) => {
        const img = new Image();
        img.onload = () => {
            resolve({ width: img.width, height: img.height });
        };
        img.onerror = (error) => {
            reject(error);
        };
        img.src = URL.createObjectURL(file);
    });
};


//export default class FileUploadCustomCompRefId extends LightningElement {}
export default class extends NavigationMixin(LightningElement) {
    customLabel = {
        UploadDocContainer_Type_ErrorMessage,
        UploadDocContainer_Size_ErrorMessage,
        UploadDocContainer_Name_ErrorMessage,
        UploadDocContainer_Upload_SuccessMessage,
        UploadDocContainer_Upload_ErrorMessage,
        UploadDocContainer_SelFile_ErrorMessage,
        UploadDocContainer_SameFile_ErrorMessage,
        UploadDocContainer_SingleFile_ErrorMessage

    }
    @api hideAttachButton;

    @api loanAppId;
    @api applicantId;
    @api docName;
    @api docType;
    @api docCategory;

    @api variant;
    @api label;
    @api recordId//={lifeInsDocDetId} 
    //@api allowedFilFormat//={acceptedFormats}
    // @api fileSizeMsz//={fileUploadMsz} disable-mode={disablepFileUpload}
    @api allowMultiple;
    //onpasstoparent={fileUploadFinish}

    @api allowedFilFormat = [".jpg", ".jpeg", ".pdf"];
    @api maxFileSize = 5242880;
    @api fileSizeMsz = "Maximum File Size should be 5Mb. Allowed File Types are  .jpg, .jpeg, .pdf ";
    @api fileTypeError = 'Allowed File Types are : pdf, jpg, jpeg';

    @track isSite = false;
    @track lightningDomainName;
    @track vfUrl;
    @track showSpinner = false;
    @track fileData = [];
    @track fileName = '';
    @track formFactor = formFactorPropertyName;
    @track creadedRecIds;
    @api disableMode;
    files = []
    errorFile;
    //@track html2canvasInitialized;
    @api documentDetaiId;
    @track applicantKycId;
    receiveMessageCallback;
    @api convertToSingleImage;
    @track compressedImageData;
    @api multipleFileUpload;

    fileExtension = [];
    // To get the pge reference 
    @wire(CurrentPageReference) pageRef;

    get iscommunity() {
        return this.pageRef.type;
    }
    extensionSet = []
    canvasWidth;
    canvasHeight;
    maxCanvasWidth = 800; // Set your maximum width
    maxCanvasHeight = 600; // Set your maximum height

    renderedCallback() {
        /*if (!this.html2canvasInitialized) {
            this.html2canvasInitialized = true;

            // Load html2canvas script dynamically
            Promise.all([
                loadScript(this, html2canvasResource + '/html2canvas.js'),
            ])
                .then(() => {
                    // Script loaded successfully
                    console.log('html2canvas library loaded.');
                    //this.compressAndCombineImages();
                })
                .catch(error => {
                    // Handle script load error
                    console.error('Error loading html2canvas library:', error);
                });
        }*/
    }

    connectedCallback() {
        this.multipleFileUpload = true;
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
        // will do only validation and create a final file.
        const uploadedFiles = event.target.files;
        /*for (var i = 0; i < event.target.files.length; i++) {
            alert(event.target.files[i].name);
            var extensionName = event.target.files[i].name.toLowerCase().slice(-4);
            alert(extensionName);
        }*/
        let extension = this.fileName.split('.').pop();
        const isMixFiles = Array.from(uploadedFiles).some(file =>

            !this.allowedFilFormat.includes('.' + file.name.toLowerCase().split('.').pop())
        );
        if (isMixFiles) {
            this.errorFile = 'Error: Mixed file types are not allowed.';
            this.showToast("Error!", "error", this.fileTypeError, "sticky");
            this.files = []; // Clear the files array if there's an error
        } else {
            this.errorFile = ''; // Clear any previous error
            if (this.multipleFileUpload) {
                this.files = [];
            }
            let tempFileArray = [...this.files, ...uploadedFiles];
            // Filter files based on allowed formats
            const filteredFiles = Array.from(uploadedFiles).filter(file =>
                this.allowedFilFormat.includes('.' + file.name.split('.').pop())
            );
            this.fileExtension = [];
            for (var i = 0; i < tempFileArray.length; i++) {
                var extensionName = '.' + tempFileArray[i].name.toLowerCase().split('.').pop();
                if (extensionName == '.jpeg' || extensionName == '.jpg') {
                    extensionName = '.jpeg';
                }
                this.fileExtension.push(extensionName);
                if (extensionName != '.jpg' && extensionName != '.jpeg' && tempFileArray[i].size > this.maxFileSize) {
                    let maxSize = this.maxFileSize / 1048576;
                    this.showToast(
                        "Error!",
                        "error",
                        // this.customLabel.UploadDocContainer_Size_ErrorMessage,Maximum File Size should be 5 Mb
                        "Maximum File Size should be " + maxSize + " Mb",
                        "sticky"
                    );
                    //this.files = [];
                    return;
                }
            }
            this.extensionSet = [...new Set(this.fileExtension)]
            if (this.convertToSingleImage == true && this.extensionSet.length > 1) {
                this.showToast("Error!", "error", this.customLabel.UploadDocContainer_SameFile_ErrorMessage, "sticky");
                //this.files = [];
                return;
            } else if (this.convertToSingleImage == true && this.extensionSet.length == 1 && this.extensionSet[0] == '.pdf' && tempFileArray.length > 1) {
                this.showToast("Error!", "error", this.customLabel.UploadDocContainer_SingleFile_ErrorMessage, "sticky");
                //this.files = [];
                return;
            }

            // Update the files array
            //let tempFileArray = [...this.files, ...filteredFiles];
            /*if(this.convertToSingleImage == true && tempFileArray.length>1){
                this.showToast("Error!", "error", this.customLabel.UploadDocContainer_SingleFile_ErrorMessage, "sticky");
                return;
                this.files = [];
            }*/
            this.files = tempFileArray;

            // You can now use the 'this.files' array as needed, for example, display the list in the component
            console.log('File List:', this.files);
            if (this.convertToSingleImage === true && this.extensionSet[0] == '.jpeg') {
                this.calculateCanvasDimensions();
            }
            var param = {
                fileList: this.files
            }
            const selectEvent = new CustomEvent('changefiles', {
                detail: param
            });
            // Fire the custom event
            this.dispatchEvent(selectEvent);


        }


    }


    handleUploadCallback(message) {
        try {
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
                        // appKycId: this.applicantKycId,
                        docDetailId: this.documentDetaiId,
                        docName: this.docName
                    }
                    console.log('File Uploaded Error   ', param);
                    this.showToast("Error", "error ", this.customLabel.UploadDocContainer_Upload_ErrorMessage, "sticky");
                }
                this.passToParent(param);

            }
        } catch (error) {
            console.error('Error in event handling:', error);
        }

    }

    createDocumentDetailRecord() {
        this.documentDetaiId = this.recordId;
        // this.applicantKycId = result.appKycId;
        this.fileUploadHandleer();
        // createAppkycDd({ applicantId: this.applicantId, loanAppId: this.loanAppId, docCategory: this.docCategory, docType: this.docType, docSubType: this.docName })
        //     .then((result) => {
        //         console.log('DocumantDetail And AppKyc  Created   ', result);
        //         this.creadedRecIds = result;
        //         this.documentDetaiId = result.docDetId;
        //         this.applicantKycId = result.appKycId;
        //         this.fileUploadHandleer();

        //     })
        //     .catch((err) => {
        //         this.showToast("Error", "error", err, "sticky");
        //         console.log(" createDocumentDetailRecord error===", err);
        //     });

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



    uploadFileLargeVf() {
        console.log('this.fileData---' + JSON.stringify(this.fileData));
        console.log('this.this.documentDetaiId---' + this.documentDetaiId);
        console.log('this.lightningDomainName---' + this.lightningDomainName);
        console.log('iframe--' + this.template.querySelector("iframe"));
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

    }



    passToParent(param) {
        try {
            console.log('passToParent 0 ');
            this.documentDetaiId = "";
            this.applicantKycId = "";
            this.fileName = "";
            this.files = [];
            console.log('passToParent 1 ');
            const selectEvent = new CustomEvent('passtoparent', {
                detail: param
            });
            // Fire the custom event
            this.dispatchEvent(selectEvent);
        } catch (error) {
            console.log(error);
        }


    }


    @api spinnerStatus(event) {
        try {
            this.showSpinner = event;
            const selectEvent1 = new CustomEvent('spinnerstatus', {
                detail: event
            });
            // Fire the custom event
            this.dispatchEvent(selectEvent1);
        } catch (error) {
            console.log(error);
        }

    }
    @api
    handleUpload(event) {
        console.log('FIles----' + JSON.stringify(this.files));
        this.spinnerStatus(true);
        if (this.files.length > 0) {
            if (this.convertToSingleImage == true && (this.extensionSet[0] == '.jpeg' || this.extensionSet[0] == '.jpg')) {
                this.combineImages();
            } else {
                this.normalFileUpload();
            }
        } else {
            this.spinnerStatus(false);
            this.showToast("Error", "error", this.customLabel.UploadDocContainer_SelFile_ErrorMessage, "sticky");
        }

    }

    normalFileUpload() {

        this.readFiles();
    }

    readFile(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();

            reader.onload = (event) => {
                resolve({
                    fileName: file.name,
                    dataUrl: event.target.result
                });
                //resolve(event.target.result);
            };

            reader.onerror = (error) => {
                reject(error);
            };

            reader.readAsDataURL(file);
        });
    }

    readFiles() {

        let imageFiles = [];
        let docFiles = [];
        for (var i = 0; i < this.files.length; i++) {
            var extensionName = '.' + this.files[i].name.toLowerCase().split('.').pop();
            if (extensionName == '.jpg' || extensionName == '.jpeg') {
                imageFiles.push(this.files[i]);
            } else {
                docFiles.push(this.files[i]);
            }
        }

        let promisesArr = [];
        let promise1 = [], promise2 = [];
        if (imageFiles.length > 0) {
            promise1 = imageFiles.map(this.compressImage);

        }
        if (docFiles.length > 0) {
            promise2 = docFiles.map(this.readFile);
        }
        promisesArr = [...promise1, ...promise2]

        Promise.all(promisesArr)
            .then((fileDataUrls) => {
                // All files have been read successfully, and you have an array of data URLs
                console.log('File Data URLs:', fileDataUrls);

                // Update the component property to render in the template
                let tempFileData = []
                for (var i = 0; i < fileDataUrls.length; i++) {
                    var fileContents = fileDataUrls[i].dataUrl.split(',')[1];
                    var fileData = {
                        fileName: this.removeDotsFromFileName(fileDataUrls[i].fileName),
                        fileContent: fileContents
                    };
                    tempFileData.push(fileData);
                }

                this.fileData = tempFileData;
                if (this.documentDetaiId) {
                    this.fileUploadHandleer();
                } else {
                    this.createDocumentDetailRecord();
                }

            })
            .catch((error) => {
                // Handle errors during file reading
                console.error('Error reading files:', error);
            });
    }

    loadImage(file) {
        return new Promise((resolve, reject) => {
            const img = new Image();
            img.onload = () => {
                resolve(img);
            };
            img.onerror = (error) => {
                reject(error);
            };
            img.src = URL.createObjectURL(file);
        });
    }



    compressImages(images) {
        Promise.all(images.map(this.compressImage))
            .then((compressedImages) => {
                // You now have an array of compressed image data URLs
                console.log('Compressed Images:', compressedImages);

                // For simplicity, just display the first compressed image
                //this.compressedImageData = compressedImages.length > 0 ? compressedImages[0] : null;

                let tempFileData = [];
                for (var i = 0; i < images.length; i++) {
                    var fileContents = compressedImages[0].split(',')[1];
                    var fileData = {
                        fileName: images[i].name + '.jpeg',
                        fileContent: fileContents
                    };
                    tempFileData.push(fileData);
                }
                this.fileData = tempFileData;


                if (this.documentDetaiId) {
                    this.fileUploadHandleer();
                } else {
                    this.createDocumentDetailRecord();
                }

            })
            .catch((error) => {
                // Handle errors during image compression
                console.error('Error compressing images:', error);
            });
    }



    combineImages() {
        Promise.all(this.files.map(this.loadImage))
            .then((images) => {
                const canvas = document.createElement('canvas');
                const ctx = canvas.getContext('2d');

                // Set the canvas dimensions based on the first image
                const firstImage = images[0];
                canvas.width = this.maxCanvasWidth
                canvas.height = this.maxCanvasHeight;

                // Draw images onto the canvas
                let imagePosition = 0;
                images.forEach((image) => {

                    ctx.drawImage(image, 0, imagePosition, this.maxCanvasWidth, image.height);
                    imagePosition = imagePosition + image.height;
                });

                // Get the combined image data as a data URL
                //const combinedImageDataUrl = canvas.toDataURL('image/png'); // Adjust format as needed
                this.compressedImageData = canvas.toDataURL('image/jpeg', 0.7);

                let fileContents = this.compressedImageData.split(',')[1];
                let data = {
                    fileName: this.docSubType + '.jpeg',
                    fileContent: fileContents
                };

                this.fileData = [...this.fileData, data];
                if (this.documentDetaiId) {
                    this.fileUploadHandleer();
                } else {
                    this.createDocumentDetailRecord();
                }
                // Set the combined image data to be rendered in HTML
                //this.combinedImageData = combinedImageDataUrl;
            })
            .catch((error) => {
                // Handle errors during image loading
                console.error('Error loading images:', error);
            });
    }



    calculateCanvasDimensions() {

        Promise.all(this.files.map(loadImage))
            .then((imageDimensions) => {

                this.maxCanvasHeight = 0;
                this.maxCanvasWidth = 0;
                // All images have been loaded successfully, and you have an array of image dimensions


                imageDimensions.reduce((accumulator, { width, height }) => {
                    this.maxCanvasHeight = this.maxCanvasHeight + height;
                    if (width > this.maxCanvasWidth) {
                        this.maxCanvasWidth = width;
                    }
                    //return accumulator + width / height;
                }, 0);

                // Calculate canvas dimensions based on the total aspect ratio

            })
            .catch((error) => {
                // Handle errors during image loading
                console.error('Error loading images:', error);
            });

    }

    compressImage(file) {
        return new Promise((resolve, reject) => {
            const img = new Image();

            img.onload = () => {
                const canvas = document.createElement('canvas');
                const ctx = canvas.getContext('2d');

                // Set the canvas dimensions based on the image
                canvas.width = img.width;
                canvas.height = img.height;

                // Draw the image onto the canvas with compression
                ctx.drawImage(img, 0, 0, canvas.width, canvas.height);

                // Get the compressed image data as a data URL
                const compressedImageDataUrl = canvas.toDataURL('image/jpeg', 0.7); // Adjust compression quality as needed

                resolve({
                    fileName: file.name,
                    dataUrl: compressedImageDataUrl
                });
            };

            img.onerror = (error) => {
                reject(error.message || error);
            };

            img.src = URL.createObjectURL(file);
        });
    }
    handleFileRemove(event) {
        var index = event.target.dataset.index;
        if (this.files.length == 1) {
            this.files = []
        } else {
            let temparray = this.files;
            temparray.splice(index, 1);
            this.files = [...temparray];
        }
        var param = {
            fileList: this.files
        }
        const selectEvent = new CustomEvent('changefiles', {
            detail: param
        });
        // Fire the custom event
        this.dispatchEvent(selectEvent);

    }
    removeDotsFromFileName(fileName) {
        // To remove dots in string excluding last dot in the string
        const lastDotIndex = fileName.lastIndexOf('.');
        if (lastDotIndex === -1) return fileName;
        const beforeLastDot = fileName.substring(0, lastDotIndex);
        const afterLastDot = fileName.substring(lastDotIndex);
        const newBeforeLastDot = beforeLastDot.replace(/\./g, '');
        const newFileName = newBeforeLastDot + afterLastDot;
        return newFileName;
    }


}