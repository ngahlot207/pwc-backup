import { LightningElement, api, wire, track } from 'lwc';
//import getPdfFilesWithIdsAsBase64 from '@salesforce/apex/FetchFileToMerge.getPdfFilesWithIdsAsBase64';
import getContentDocumentId from '@salesforce/apex/FetchFileToMerge.getContentDocumentId';
//import pdfLib from '@salesforce/resourceUrl/pdfLibFile';
import pdfLib from '@salesforce/resourceUrl/pdfLib';
import { loadScript } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
//import pdflib from "@salesforce/resourceUrl/pdflib";
//import getData from '@salesforce/apex/FetchFileToMerge.getData';
import getDocPdfData from '@salesforce/apex/FetchFileToMerge.getDocPdfData';
//import getRecordsId from '@salesforce/apex/FetchFileToMerge.getRecordsId';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, MessageContext } from 'lightning/messageService';
import { createRecord } from 'lightning/uiRecordApi';
import checkAllESignStampDoc from '@salesforce/apex/FetchFileToMerge.checkAllESignStampDoc';
import CONTENT_VERSION_OBJECT from '@salesforce/schema/ContentVersion';
import TITLE_FIELD from '@salesforce/schema/ContentVersion.Title';
import VERSION_DATA_FIELD from '@salesforce/schema/ContentVersion.VersionData';
import PATH_ON_CLIENT_FIELD from '@salesforce/schema/ContentVersion.PathOnClient';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CONTENT_DOCUMENT_LINK_OBJECT from '@salesforce/schema/ContentDocumentLink';
import LINKED_ENTITY_ID_FIELD from '@salesforce/schema/ContentDocumentLink.LinkedEntityId';
import CONTENT_DOCUMENT_ID_FIELD from '@salesforce/schema/ContentDocumentLink.ContentDocumentId';
import SHARE_TYPE_FIELD from '@salesforce/schema/ContentDocumentLink.ShareType';
import getDataForFilterChild from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithFilterRelatedRecords';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import { getObjectInfo,getPicklistValues,getPicklistValuesByRecordType} from "lightning/uiObjectInfoApi";
import LOANAPP_OBJECT from '@salesforce/schema/LoanAppl__c';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import { refreshApex } from '@salesforce/apex';
export default class MergePdf extends NavigationMixin(LightningElement)  {
    @track isReadOnly = false;
    @track hideUploadButton = false;
    //@api recordId;
    /*isLibLoaded = false;
    mergedPdfUrl;
    pdfLibInstance;

    renderedCallback() {
        if (this.isLibLoaded) {
            return;
        }
        loadScript(this, pdfLib).then(() => {
            if (window['pdfLib'] || window['PDFLib']) {
                console.error('PDF-LIB  loaded correctly.');
                this.isLibLoaded = true;
                this.pdfLibInstance = window['pdfLib'] || window['PDFLib'];
                //this.loadPdfs();
            } else {
                console.error('PDF-LIB not loaded correctly.');
            }
        });
        loadScript(this, pdfLib + '/pdf-lib.min.js')
            .then(() => {
                if (window['pdfLib'] || window['PDFLib']) {
                    this.isLibLoaded = true;
                    this.pdfLibInstance = window['pdfLib'] || window['PDFLib'];
                    this.loadPdfs();
                } else {
                    console.error('PDF-LIB not loaded correctly.');
                }
            })
            .catch(error => {
                console.error('Error loading PDF-LIB:', error);
            });
    }

    @wire(getPdfFilesWithIdsAsBase64, { AccountId: '$recordId' })
    wiredPdfs({ error, data }) {
        console.log('datadatadata1'+data)
        if (this.isLibLoaded && data) {
            console.log('datadatadata2'+data)
            this.mergePDFs(data);
        } else if (error) {
            console.error('Error fetching PDFs:', error);
        }
    }

    async mergePDFs(pdfFiles) {
        debugger
        if (!this.pdfLibInstance) {
            console.error('PDF-LIB instance is not defined.');
            return;
        }

        const { PDFDocument } = this.pdfLibInstance;

        const mergedPdf = await PDFDocument.create();
        for (let pdfFile of pdfFiles) {
            const pdfBytes = Uint8Array.from(atob(pdfFile.Base64Data), c => c.charCodeAt(0));
            const pdfDoc = await PDFDocument.load(pdfBytes);
            const copiedPages = await mergedPdf.copyPages(pdfDoc, pdfDoc.getPageIndices());
            copiedPages.forEach(page => mergedPdf.addPage(page));
        }

        const mergedPdfBytes = await mergedPdf.save();
        this.mergedPdfUrl = URL.createObjectURL(new Blob([mergedPdfBytes], { type: 'application/pdf' }));
    }*/
       docData = []
        error
        ids ='' 
    
    
        renderedCallback() {
            loadScript(this, pdfLib).then(() => {
            });
    
            console.log('recode ud  ' + this.recordId)
            /*if (this.recordId) {
                getData({ accountId: this.recordId })
                    .then((result) => {
                        this.docData = JSON.parse(JSON.stringify(result));
                        console.log('Size of File are ' + this.docData.length)
                        this.error = undefined;
                      // this.createPdf()
                    })
                    .catch((error) => {
                        console.log('error while calling ' + error)
                    }
                    )
            }*/
        }
    
        /*async createPdf() {
            const pdfDoc = await PDFLib.PDFDocument.create();
            console.log('pdfDoc is ', pdfDoc)
            if (this.docData.length < 1){
                return
            }
                
    
    
            var tempBytes = Uint8Array.from(atob(this.docData[0]), (c) => c.charCodeAt(0));
            console.log('tempBytes', tempBytes)
            const [firstPage] = await pdfDoc.embedPdf(tempBytes);
            const americanFlagDims = firstPage.scale(0.99);
            var page = pdfDoc.addPage();
            console.log('page is ', page)
    
            page.drawPage(firstPage, {
                ...americanFlagDims,
                x: page.getWidth() - americanFlagDims.width,
                y: page.getHeight() - americanFlagDims.height - 10,
            });
    
    
            if (this.docData.length > 1) {
                for (let i = 1; i < this.docData.length; i++) {
                    tempBytes = Uint8Array.from(atob(this.docData[i]), (c) => c.charCodeAt(0));
                    console.log('tempBtes>> ', tempBytes)
                    page = pdfDoc.addPage();
                    const usConstitutionPdf = await PDFLib.PDFDocument.load(tempBytes);
                    console.log('After ', usConstitutionPdf, usConstitutionPdf.getPages())
                    const preamble = await pdfDoc.embedPage(usConstitutionPdf.getPages()[0]);
                    console.log(' Inside page is ', page)
    
                    const preambleDims = preamble.scale(0.95);
    
                    page.drawPage(preamble, {
                        ...preambleDims,
                        x: page.getWidth() - americanFlagDims.width,
                        y: page.getHeight() - americanFlagDims.height - 10,
                    });
                }
    
            }
            const pdfBytes = await pdfDoc.save();
            this.saveByteArray("My PDF", pdfBytes);
        }*/
           /* async createPdf() {
                // Create a new PDF document to hold the merged result
                const pdfDoc = await PDFLib.PDFDocument.create();
                console.log('pdfDoc is ', pdfDoc);
                
                // Check if there's any data to process
                if (this.docData.length < 1) {
                    return;
                }
            
                // Loop through each PDF data in the `docData` array
                for (let i = 0; i < this.docData.length; i++) {
                    // Convert base64 string to byte array
                    const tempBytes = Uint8Array.from(atob(this.docData[i]), (c) => c.charCodeAt(0));
                    console.log('tempBytes', tempBytes);
                    
                    // Load the PDF document from the byte array
                    const pdfToMerge = await PDFLib.PDFDocument.load(tempBytes);
                    const pages = await pdfDoc.copyPages(pdfToMerge, pdfToMerge.getPageIndices());  // Get all pages
            
                    // Add all the pages from this document to the final merged PDF
                    pages.forEach((page) => {
                        pdfDoc.addPage(page);
                    });
                }
            
                // Save the merged PDF
                const pdfBytes = await pdfDoc.save();
                this.createContentVersionREec(pdfBytes);
                this.saveByteArray("MergedPDF", pdfBytes);
            }


        createContentVersionREec(pdfBytes){
            const base64String = this.arrayBufferToBase64(pdfBytes);

            // Create ContentVersion record in Salesforce
            const contentVersionFields = {
                [TITLE_FIELD.fieldApiName]: 'Merged PDF Document', // Set a title for the document
                [VERSION_DATA_FIELD.fieldApiName]: base64String, // Base64-encoded data
                [PATH_ON_CLIENT_FIELD.fieldApiName]: 'MergedDocument.pdf' // Optional: set a file name
            };
        
            const contentVersionRecordInput = {
                apiName: CONTENT_VERSION_OBJECT.objectApiName,
                fields: contentVersionFields
            };
        
            createRecord(contentVersionRecordInput)
                .then((contentVersionRecord) => {
                    console.log('ContentVersion created with Id: ' + contentVersionRecord.id);
                    // Retrieve the ContentDocumentId from the created ContentVersion record
                    this.linkContentVersionToRecord(contentVersionRecord.id);
                })
                .catch((error) => {
                    console.error('Error creating ContentVersion: ' + error);
                    this.showToast('Error', 'Error creating ContentVersion', 'error');
                });
        } 
        
        linkContentVersionToRecord(contentVersionId) {
            // Query to get the ContentDocumentId associated with the ContentVersion
            getContentDocumentId({ contentVersionId: contentVersionId })
                .then((contentDocumentId) => {
                    // Create the ContentDocumentLink record
                    const contentDocumentLinkFields = {
                        [LINKED_ENTITY_ID_FIELD.fieldApiName]: this.recordId, // Record to link to (e.g., Account, Opportunity)
                        [CONTENT_DOCUMENT_ID_FIELD.fieldApiName]: contentDocumentId, // Retrieved ContentDocumentId
                        [SHARE_TYPE_FIELD.fieldApiName]: 'V' // View permission
                    };
        
                    const contentDocumentLinkRecordInput = {
                        apiName: CONTENT_DOCUMENT_LINK_OBJECT.objectApiName,
                        fields: contentDocumentLinkFields
                    };
        
                    createRecord(contentDocumentLinkRecordInput)
                        .then(() => {
                            console.log('ContentDocumentLink created successfully');
                            this.showToast('Success', 'Document linked to record', 'success');
                        })
                        .catch((error) => {
                            console.error('Error creating ContentDocumentLink: ' + error);
                            this.showToast('Error', 'Error linking document to record', 'error');
                        });
                })
                .catch((error) => {
                    console.error('Error retrieving ContentDocumentId: ' + error);
                    this.showToast('Error', 'Error retrieving ContentDocumentId', 'error');
                });
        }*/
        
        // Helper function to show toast notifications
        showToast(title, message, variant) {
            const evt = new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            });
            this.dispatchEvent(evt);
        }
        
        // Helper function to convert byte array to base64
        arrayBufferToBase64(buffer) {
            let binary = '';
            const bytes = new Uint8Array(buffer);
            const len = bytes.byteLength;
            for (let i = 0; i < len; i++) {
                binary += String.fromCharCode(bytes[i]);
            }
            return btoa(binary);
        }
            
            
        saveByteArray(pdfName, byte) {
            var blob = new Blob([byte], { type: "application/pdf" });
            var link = document.createElement("a");
            link.href = window.URL.createObjectURL(blob);
            var fileName = pdfName;
            link.download = fileName;
            link.click();
        }
    
         

    @track eSignSelected;
    @track eStampSelected;  
    @track showEsignPhysicalDoc
    @track tableHeadingforSign;
    @track tableHeadingForStamp
    @api layoutSize;
    @api hasEditAccess
    @api recordId
    @track loanAppRecord;
    @track docType
    @track subType
    @track docCategory
    @track docTypeSign
    @track subTypeSign
    @track docCategorySign
    @track wrapBankObj ={};
    @track showEstampPhysicalDoc
    @track allDocPdfData;
    @track allowedFilFormat = ".pdf";
    @track fileTypeError='Allowed File Types are : pdf'
    @track fileSizeMsz = "Maximum file size should be 25Mb. Allowed file type is .pdf only";
    @track disableMode;
    
    @track _loanAppId;
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);
        console.log(' this._loanAppIdthis._loanAppIdthis._loanAppId', this._loanAppId, this.loanAppId);
         setTimeout(() => {
            this.handleLoanAppRecordIdChange();
        }, 300);

    }
    @track ESignOptions;
    @track regiDisabled;
    @track EStampOptions;
    @wire(getObjectInfo, { objectApiName:  LOANAPP_OBJECT})
    objectInfo
    @wire(getPicklistValuesByRecordType, {
        objectApiName: LOANAPP_OBJECT,
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
    })picklistHandler({ data, error }){
        console.log(
            "DATA IN LOAN DETAILS COMPONENT PICKLIST HANDLER METHOD:::#918",
            data
          );
        if(data){
            this.EStampOptions = [...this.generatePicklist(data.picklistFieldValues.E_Stamp_Physical_Stamp__c)]
            this.ESignOptions = [...this.generatePicklist(data.picklistFieldValues.E_Sign_Physical_Sign__c)]
         }
        if (error) {
           console.log('errorerrorerror'+error);
        }
    }
    generatePicklist(data) {
        return data.values.map(item => ({ "label": item.label, "value": item.value }))
    }
    handleLoanAppRecordIdChange(){        
        let tempParams1 = this.paramsForLoanAppRec;
        tempParams1.queryCriteria = ' where Id = \'' + this._loanAppId + '\'';
        this.paramsForLoanAppRec = {...tempParams1};
        console.log('Applicantid-->', this.paramsForLoanAppRec );
    }
    @track paramsForLoanAppRec={
        ParentObjectName:'LoanAppl__c',
        parentObjFields:['Id','BrchCode__c','Sub_Registrar_Office_Salesforce_Code__c','District_Salesforce_Code__c','EStamp_District__c','EStamp_Sub_Registrar_Office__c','Applicant__c','Stage__c','E_Sign_Physical_Sign__c','Is_E_Sign_Physical_Done__c','E_Stamp_Physical_Stamp__c','Is_E_Stamp_Done__c'],
        queryCriteria: ' where Id = \'' + this._loanAppId + '\''

    }
    _wiredLoanApplication
    isEStampDone;
    @wire(getDataForFilterChild,{params:'$paramsForLoanAppRec'})
    loanApplicationRecords(wiredLoanApplication) {
        const { data, error } = wiredLoanApplication;
        this._wiredLoanApplication = wiredLoanApplication;
        console.log('this._wiredLoanApplication',this._wiredLoanApplication);
        this.loanAppRecord={}
        if (data) {
            this.loanAppRecord=JSON.parse(JSON.stringify(data.parentRecord)); 
            this.applicantId=this.loanAppRecord.Applicant__c;
            this.isEStampDone=this.loanAppRecord.Is_E_Stamp_Done__c;
            if(this.loanAppRecord.E_Stamp_Physical_Stamp__c){
                if(this.loanAppRecord.E_Stamp_Physical_Stamp__c=='E-stamp'){
                    this.eStampSelected=true;
                    this.showEstampPhysicalDoc=false;
                    this.showEstampTable=true;
                    this.tableHeadingForStamp=' E-Stamp Documents'
                    this.docTypeSign = ['Disbursal Documents'];
                    this.subTypeSign = ['Loan Agreement'];
                    this.docCategorySign = ['System Generated Documents']
                }else if(this.loanAppRecord.E_Stamp_Physical_Stamp__c=='Physical Stamp'){
                    this.showEstampPhysicalDoc=true
                    this.eStampSelected=false;
                    this.showEstampTable=true;
                    this.tableHeadingForStamp='Physical Stamp Documents'
                    this.docTypeSign1 = ['Disbursal Documents','Loan Agreement','Power Of Attonrny','Declaration of Loan Agreement'];
                    this.subTypeSign1 = ['Loan Agreement', 'Stamped Loan Agreement','Declaration of Loan Agreement', 'Power Of Attonrny','Physical-Stamped Loan Agreement','Physical-Stamped Declaration of Loan Agreement', 'Physical-Stamped Power Of Attonrny'];
                    this.docCategorySign1 = ['Mandatory Post Sanction Documents','System Generated Documents','Stamped Loan Agreement','Stamped Power Of Attonrny','Stamped Declaration']
                
                }
                
            }
            if(this.loanAppRecord.E_Sign_Physical_Sign__c){
                this.showEsignPhysicalDoc=true
                if(this.loanAppRecord.E_Sign_Physical_Sign__c=='E-Sign'){
                    this.docType = ['Loan Agreement & Related Annexure','Disbursal Documents', 'Sanction Letter', 'NACH Form', 'Application Form',  'Sanction Letter & KFS Document', 'BT Draft', 'DPN Document'];
                    this.subType = ['Loan Agreement & Related Annexures', 'NACH Form', 'Term Sheet', 'Application Form',  'Sanction Letter & KFS Document', 'BT Draft Part 2', 'BT Draft Part 1', 'DPN Document'];
                    this.docCategory = ['Additional Post Sanction Documents','KYC Documents', 'Sanction Letter', 'NACH Form', 'Term Sheet', 'Application Form', 'Sanction Letter & KFS Document', 'BT Draft', 'System Generated Documents']
                    this.eSignSelected=true;
                    this.physicalSignSelected=false;
                }else if(this.loanAppRecord.E_Sign_Physical_Sign__c=='Physical Sign'){
                    this.eSignSelected=false;
                    this.physicalSignSelected=true;
                    this.docType = ['Loan Agreement & Related Annexure','Disbursal Documents', 'Sanction Letter', 'NACH Form', 'Application Form',  'Sanction Letter & KFS Document', 'BT Draft', 'DPN Document'];
                    this.subType = ['Physical-Signed Loan Agreement & Related Annexures','Physical-Signed Sanction Letter & KFS Document','Physical-Signed DPN Document','Physical-Signed BT Draft Part 2','Physical-Signed BT Draft Part 1','Physical-Signed NACH Form','Physical-Signed Application Form','Loan Agreement & Related Annexures', 'NACH Form', 'Term Sheet', 'Application Form',   'Sanction Letter & KFS Document', 'BT Draft Part 2', 'BT Draft Part 1', 'DPN Document'];
                    this.docCategory = ['Mandatory Post Sanction Documents','Additional Post Sanction Documents','KYC Documents', 'Sanction Letter', 'NACH Form', 'Term Sheet', 'Application Form', 'Sanction Letter & KFS Document', 'BT Draft', 'System Generated Documents']
    
                }
            }
            if(this.loanAppRecord.District_Salesforce_Code__c){
                this.serchMasterIdForDistric();
            }
            if(this.loanAppRecord.Sub_Registrar_Office_Salesforce_Code__c){
                this.serchMasterIdForReg();
            }
            if(this.loanAppRecord.BrchCode__c){
                this.getStateName();
            }
            
        } else if (error) {
            console.log(error);
        }
    }
    isStateMaharas;
    getStateName(){
       
        let branchNameparams = {
            ParentObjectName: 'BankBrchMstr__c',
            ChildObjectRelName: '',
            parentObjFields: ['Id','LocationMaster__r.State__c', 'BrchCode__c'],
            childObjFields: [],
            queryCriteria: ' where BrchCode__c = \'' + this.loanAppRecord.BrchCode__c + '\''  + ' LIMIT 1'
        }
        getSobjectData({params: branchNameparams})
        .then((result)=>{
            
           if (result.parentRecords && result.parentRecords.length>0) {
                let stateOfBranch=result.parentRecords[0].LocationMaster__r.State__c;
                if(stateOfBranch == 'MAHARASHTRA'){
                    this.isStateMaharas=true;
                }
                
            }
        })
        .catch((error)=>{
            console.error('Error in line ##385',error)
        })
      }
    @track physicalSignSelected;
    handleEsignData(event){
        this.loanAppRecord[event.target.dataset.field] = event.target.value;
        if(event.target.dataset.field=='E_Sign_Physical_Sign__c'){
            if(this.loanAppRecord.Is_E_Stamp_Done__c==false){
                this.template.querySelector('[data-id="esign"]').value = '';
                this.showToast('Error', 'Please Complete E-Stamp/Physical Stamp First.', 'error');
            }else{
                //'Interest Bearing Letter',
                
                this.showEsignPhysicalDoc=false
                const selectedVal=event.target.value;
                if(selectedVal=='E-Sign'){
                    this.docType = ['Loan Agreement & Related Annexure','Disbursal Documents', 'Sanction Letter', 'NACH Form', 'Application Form',  'Sanction Letter & KFS Document', 'BT Draft', 'DPN Document'];
                    this.subType = ['Loan Agreement & Related Annexures', 'NACH Form', 'Term Sheet', 'Application Form',  'Sanction Letter & KFS Document', 'BT Draft Part 2', 'BT Draft Part 1', 'DPN Document'];
                    this.docCategory = ['Additional Post Sanction Documents','KYC Documents', 'Sanction Letter', 'NACH Form', 'Term Sheet', 'Application Form', 'Sanction Letter & KFS Document', 'BT Draft', 'System Generated Documents']
                    this.eSignSelected=true;
                    this.physicalSignSelected=false;
                }else if(selectedVal=='Physical Sign'){
                    this.eSignSelected=false;
                    this.physicalSignSelected=true;
                    this.docType = ['Loan Agreement & Related Annexure','Disbursal Documents', 'Sanction Letter', 'NACH Form', 'Application Form',  'Sanction Letter & KFS Document', 'BT Draft', 'DPN Document'];
                    this.subType = ['Physical-Signed Loan Agreement & Related Annexures','Physical-Signed Sanction Letter & KFS Document','Physical-Signed DPN Document','Physical-Signed BT Draft Part 2','Physical-Signed BT Draft Part 1','Physical-Signed NACH Form','Physical-Signed Application Form','Loan Agreement & Related Annexures', 'NACH Form', 'Term Sheet', 'Application Form',   'Sanction Letter & KFS Document', 'BT Draft Part 2', 'BT Draft Part 1', 'DPN Document'];
                    this.docCategory = ['Mandatory Post Sanction Documents','Additional Post Sanction Documents','KYC Documents', 'Sanction Letter', 'NACH Form', 'Term Sheet', 'Application Form', 'Sanction Letter & KFS Document', 'BT Draft', 'System Generated Documents']
    
                }
                setTimeout(() => {
                    this.showEsignPhysicalDoc=true
                }, 2000);
                
                
            }
        }
    }
    docCategorySign1
    subTypeSign1
    docTypeSign1

    handleEStampData(event){
       this.loanAppRecord[event.target.dataset.field] = event.target.value;
        const selectedVal=event.target.value;
       
        if(event.target.dataset.field=='E_Stamp_Physical_Stamp__c'){
            if(selectedVal=='E-stamp'){
                this.eStampSelected=true;
                this.showEstampPhysicalDoc=false
                this.tableHeadingForStamp=' E-Stamp Documents'
                this.docTypeSign = ['Disbursal Documents'];
                this.subTypeSign = ['Loan Agreement','Declaration of Loan Agreement', 'Power Of Attonrny'];
                this.docCategorySign = ['System Generated Documents']
            }else if(selectedVal=='Physical Stamp'){
                this.showEstampPhysicalDoc=true
                this.eStampSelected=false;
                this.tableHeadingForStamp='Physical Stamp Documents'
                this.docTypeSign1 = ['Disbursal Documents','Loan Agreement','Power Of Attonrny','Declaration of Loan Agreement'];
                this.subTypeSign1 = ['Loan Agreement', 'Stamped Loan Agreement','Declaration of Loan Agreement', 'Power Of Attonrny','Physical-Stamped Loan Agreement','Physical-Stamped Declaration of Loan Agreement', 'Physical-Stamped Power Of Attonrny'];
                this.docCategorySign1 = ['Mandatory Post Sanction Documents','System Generated Documents','Stamped Loan Agreement','Stamped Power Of Attonrny','Stamped Declaration']
                
            }
        }
        //this.checkDocShowforEStamp(selectedVal);
        
    }
    
    filterCondnForDistrict
    connectedCallback(){
        this.regiDisabled=true
        this.filterCondnForDistrict="Type__c = 'Estamp District'";
        if(this.hasEditAccess==false){
            this.disableMode=true;
        }
       this.scribeToMessageChannel();
        if(this.loanAppRecord.Is_E_Sign_Physical_Done__c==true || this.loanAppRecord.E_Sign_Physical_Sign__c){
            //this.createMergedDisbKit();
        }
        //this.createMergedDisbKit();        
    }
    @wire(MessageContext)
    MessageContext;
    scribeToMessageChannel() {

        this.subscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveThroughLms(values)
        );
    }
    handleSaveThroughLms(values) {
        console.log('values to save through Lms ', JSON.stringify(values));
        this.handlevSubmit(values.validateBeforeSave);

    }
    handlevSubmit(validate) {
        if (validate) {
            let valid = this.validateForm(); //LAK-7917
            checkAllESignStampDoc({ lanId: this._loanAppId})
                .then((result) => {
                    
                    console.log("result from apex", result);
                    if(result.length==0){
                        this.loanAppRecord["Is_E_Sign_Physical_Done__c"] = 'true';
                    }
                    if(result.length >0 || valid==false){
                        this.showToast('Error', 'Please Complete E-stamped/Physical Stamped and E-Sign/ Physical Sign.', 'error');
                    }else{
                        this.saveLoanData('save');
                    }
                    
        })
        .catch((error) => {
            
            console.log("error occured in fetchLeadData", error);

        });
            
        }else{
            this.saveLoanData('save');
        }
    }
    validateForm() {
        let isValid = true;
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed');
            } else {
                isValid = false;
            }
        });

       /* this.template.querySelectorAll('lightning-combobox').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed');
            } else {
                
                isValid = false;
            }

        });*/
        let allChilds = this.template.querySelectorAll("c-custom-lookup");
        allChilds.forEach((child) => {
            if (!child.checkValidityLookup()) {
                child.checkValidityLookup();
                isValid = false;
                
            }
      
        
        });
        return isValid;
    }
    saveLoanData(saveVal){
        debugger
        console.log(' this.paymentGateWay ', this.loanAppRecord);
        this.loanAppRecord["sobjectType"] = "LoanAppl__c";
        // this.loanAppRecord["Is_E_Sign_Physical_Done__c"] = 'true';
        let newArray = [];
        if (this.loanAppRecord) {
            newArray.push(this.loanAppRecord);
        }
        if (newArray) {
            upsertMultipleRecord({ params: newArray })
                .then((result) => {
                    this.showToast('Success', 'EStmap/physical Stamp and ESign/physical Sign Details Saved Successfully.', 'success');
                    
                    
                })
                .catch((error) => {
                    console.log('Error In 1841>>>>>>>>>>>>>>>>> ', error);
                });
        }
    }

    handleSendEStampLink(){
        if(this.loanAgrementPresent){
           
        }else{
            this.showToast('Error', 'For E-Stamp/ Physical Stamp Please Generate Disbursal Documents first.', 'error');
        }
    }
    uploadSignedDocModel
    uploadedDocList=[];
    loanAgrementPresent
    handleUploadEStamp(){
        debugger
        if(this.loanAgrementPresent){
            this.uploadSignedDocModel=true
        }else{
            this.showToast('Error', 'For E-Stamp/ Physical Stamp Please Generate Disbursal Documents first.', 'error');
        }
        
    }
    uploadedDocument(event){
        if (event.detail){
            /*this.uploadedDocList = event.detail;
            for(const record of this.uploadedDocList){
                if(record.docDetName=="Loan Agreement"){
                    this.loanAgrementPresent=true
                }
            }*/
        }
    }
    updateEStampField;
    uploadedDocumentForStamp(event){
        if (event.detail){
            console.log('event.detail',event.detail)
            this.uploadedDocList = event.detail;
            for(const record of this.uploadedDocList){
                if(record.docDetName=="Loan Agreement"){
                    this.loanAgrementPresent=true
                }
            }
            if(this.updateEStampFieldFoStamp && this.uploadedDocList.length==6){
                this.UpdateEStampField();
            }
        }
    }
    closeModal() {
        this.uploadSignedDocModel=false
    }
    handleSendESignLink(){
        const docSubTyp=['Stamped Loan Agreement','End Use, Pre EMI and PF Deduction Letter']
        const docTyp=['Stamped Loan Agreement', 'Disbursal Documents']
        const docCat=['Stamped Loan Agreement', 'System Generated Documents']
        let paramForDoc = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ['id'],
           queryCriteria: ' where IsLatest__c = true AND LAN__c = \'' + this._loanAppId + '\' AND Appl__c = \'' + this.applicantId + '\' AND DocCatgry__c IN (\''+docCat.join('\', \'') + '\')  AND DocTyp__c IN (\''+docTyp.join('\', \'') + '\') AND DocSubTyp__c IN (\''+docSubTyp.join('\', \'') + '\') ORDER BY CreatedDate DESC'
        }
        getSobjectData({ params: paramForDoc })
            .then((result) => {
                console.log('resultresult'+JSON.stringify(result))
                let docIdsList=[];
                if(result.parentRecords){
                    let docDetailRec=result.parentRecords;
                    docDetailRec.forEach(docId => {
                        docIdsList.push(docId.Id);
                    });
                }
                if(docIdsList.length>0){
                    getDocPdfData({ docDetailIds: docIdsList })
                    .then((result) => {
                        this.allDocPdfData = JSON.parse(JSON.stringify(result));
                        //console.log('Size of File are ' + this.docData.length)
                        this.error = undefined;
                        this.createPdfForPDF()
                    })
                    .catch((error) => {
                        console.log('error while calling ' + error)
                    }
                    )
                }
            })
            .catch((error) => {
                console.log('Error In getting 13899999 ', error);
            });
    }
    async createPdfForPDF() {
        const pdfDoc = await PDFLib.PDFDocument.create();
        if (this.allDocPdfData.length < 1) {
            return;
        }
        for (let i = 0; i < this.allDocPdfData.length; i++) {
            const tempBytes = Uint8Array.from(atob(this.allDocPdfData[i]), (c) => c.charCodeAt(0));
            const pdfToMerge = await PDFLib.PDFDocument.load(tempBytes);
            const pages = await pdfDoc.copyPages(pdfToMerge, pdfToMerge.getPageIndices()); 
            pages.forEach((page) => {
                pdfDoc.addPage(page);
            });
        }
        const pdfBytes = await pdfDoc.save();
        this.createConVerRecForMerge(pdfBytes);
    }
    createConVerRecForMerge(pdfBytes){
        const base64String = this.arrayBufferToBase64(pdfBytes);
        const contentVersionFields = {
            [TITLE_FIELD.fieldApiName]: 'Loan Agreement & Related Annexures', 
            [VERSION_DATA_FIELD.fieldApiName]: base64String, 
            [PATH_ON_CLIENT_FIELD.fieldApiName]: 'Loan Agreement & Related Annexures.pdf'
        };
    
        const contentVersionRecordInput = {
            apiName: CONTENT_VERSION_OBJECT.objectApiName,
            fields: contentVersionFields
        };
    
        createRecord(contentVersionRecordInput)
            .then((contentVersionRecord) => {
                console.log('ContentVersion created with Id: ' + contentVersionRecord.id);
                this.linkContentVersionToDocDetail(contentVersionRecord.id);
            })
            .catch((error) => {
                console.error('Error creating ContentVersion: ' + error);
                this.showToast('Error', 'Error creating ContentVersion', 'error');
            });
    } 
    
    linkContentVersionToDocDetail(contentVersionId) {
         getContentDocumentId({ contentVersionId: contentVersionId })
            .then((contentDocumentId) => {
                const contentDocumentLinkFields = {
                    [LINKED_ENTITY_ID_FIELD.fieldApiName]: this.loanAgreeStampKitId, // Record to link to (e.g., Account, Opportunity)
                    [CONTENT_DOCUMENT_ID_FIELD.fieldApiName]: contentDocumentId, // Retrieved ContentDocumentId
                    [SHARE_TYPE_FIELD.fieldApiName]: 'V' // View permission
                };
                const contentDocumentLinkRecordInput = {
                    apiName: CONTENT_DOCUMENT_LINK_OBJECT.objectApiName,
                    fields: contentDocumentLinkFields
                };
                createRecord(contentDocumentLinkRecordInput)
                    .then(() => {
                        console.log('ContentDocumentLink created successfully');
                        this.showToast('Success', 'Document linked to record', 'success');
                    })
                    .catch((error) => {
                        console.error('Error creating ContentDocumentLink: ' + error);
                        this.showToast('Error', 'Error linking document to record', 'error');
                    });
            })
            .catch((error) => {
                console.error('Error retrieving ContentDocumentId: ' + error);
                this.showToast('Error', 'Error retrieving ContentDocumentId', 'error');
            });
    }
    loanAgreeStampKitId
    createMergedDisbKit(){
        const docSubTyp=['Loan Agreement & Related Annexures' ]
        const docTyp=['Loan Agreement & Related Annexure']
        const docCat=['Additional Post Sanction Documents']
        let paramForSignLanAgg = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ['id'],
           queryCriteria: ' where IsLatest__c = true AND LAN__c = \'' + this._loanAppId + '\' AND DocCatgry__c IN (\''+docCat.join('\', \'') + '\')  AND DocTyp__c IN (\''+docTyp.join('\', \'') + '\') AND DocSubTyp__c IN (\''+docSubTyp.join('\', \'') + '\')'
        }
        getSobjectData({ params: paramForSignLanAgg })
            .then((result) => {
                console.log('58666666'+JSON.stringify(result))
                let listOfAllParent=[];
                if (result.parentRecords) {
                    listOfAllParent = JSON.parse(JSON.stringify(result.parentRecords))
                    let isLatestOlRecs = []
                    isLatestOlRecs = listOfAllParent.map(record => {
                        return { ...record, IsLatest__c: false };
                    });
                    upsertMultipleRecord({ params: isLatestOlRecs })
                        .then(result => {
                        }).catch(error => {
                            console.log('errorerrorerror',error);
                        })
                }
                //if(result.parentRecords && result.parentRecords.length>0){
                    //this.loanAgreeStampKitId=result.parentRecords[0]
                //}else{
                    const fields = {
                        "LAN__c": this._loanAppId,
                        "DocCatgry__c": 'Additional Post Sanction Documents',
                        "DocSubTyp__c": 'Loan Agreement & Related Annexures',
                        "DocTyp__c": 'Loan Agreement & Related Annexure',
                        "IsLatest__c": true,
                        "Appl__c":  this.applicantId
                        };
                    const DocDetail={apiName : "DocDtl__c", fields : fields};
                    createRecord(DocDetail)
                    .then((record) => {
                        this.loanAgreeStampKitId=record.id;
                        console.log('this.loanAgreeStampKitId'+this.loanAgreeStampKitId)
                        this.handleSendESignLink();
                        })
                        .catch((err) => {
                            console.log('errerrerr'+JSON.stringify(err))
                            
                        });
                //}
            })
            .catch((error) => {
                console.log('Error In getting 13899999 ', error);
            });
    }
    fromUploadDocsContainer(event){
        console.log('paramparam',event.detail.docDetailId);
        this.uploadSignedDocModel=false;
        let documentDetailId=event.detail.docDetailId;
       // this.UpdateEStampField(documentDetailId);
    }
    parentFileChange(event){

    }
    UpdateEStampField() {

        this.loanAppRecord["sobjectType"] = "LoanAppl__c";
        this.loanAppRecord["Is_E_Stamp_Done__c"] = true;
        this.loanAppRecord["Is_E_Sign_Physical_Done__c"] = false;
        console.log('this.loanAppRecord',this.loanAppRecord)
        let newArray = [];
        if (this.loanAppRecord) {
            newArray.push(this.loanAppRecord);
        }
        if (newArray) {
            upsertMultipleRecord({ params: newArray })
                .then((result) => {
                    refreshApex(this._wiredLoanApplication); 
                    this.updateEStampFieldFoStamp=false;
                    //this.forLatestDocDetailRec('Stamped Loan Agreement','Stamped Loan Agreement', 'Stamped Loan Agreement', documentDetailId);
                    //this.UpdateStampedLoanAgreeESignFalse('Additional Post Sanction Documents', 'Loan Agreement & Related Annexure','Physical-Signed Loan Agreement & Related Annexures');
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
            queryCriteria: ' where IsLatest__c = true AND LAN__c = \'' + this._loanAppId + '\' AND DocCatgry__c = \'' + docCat + '\' AND DocTyp__c = \'' + docTyp + '\' AND DocSubTyp__c = \'' + docSubTyp + '\''
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
                            this.createMergedDisbKit();
                        }).catch(error => {
                            console.log('errorerrorerror',error);
                        })
                }
                setTimeout(() => {
                    if(this.template.querySelector('c-uploded-document-display') != null){
                        this.template.querySelector('c-uploded-document-display').handleFilesUploaded( '');
                    }
                }, 2000);
            })
            .catch((error) => {
                console.log('Error In 1841 ', error);
            });
    }
    UpdateStampedLoanAgreeESignFalse(docCat, docTyp, docSubTyp){
        let listOfAllParent = [];
        let paramForIsLatest = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ['Id', 'Appl__c', 'LAN__c', 'DocCatgry__c', 'DocTyp__c', 'DocSubTyp__c', 'IsLatest__c'],
            queryCriteria: ' where IsLatest__c = true AND LAN__c = \'' + this._loanAppId + '\' AND DocCatgry__c = \'' + docCat + '\' AND DocTyp__c = \'' + docTyp + '\' AND DocSubTyp__c = \'' + docSubTyp + '\''
        }
        getSobjectData({ params: paramForIsLatest })
            .then((result) => {
                console.log('isLatestFalseRecs>>>>>' + JSON.stringify(result))
                if (result.parentRecords) {
                    listOfAllParent = JSON.parse(JSON.stringify(result.parentRecords))
                    let isLatestFalseRecs = []
                    isLatestFalseRecs = listOfAllParent.map(record => {
                        return { ...record, IsLatest__c: false };
                    });
                   
                    upsertMultipleRecord({ params: isLatestFalseRecs })
                        .then(result => {
                            this.showEsignPhysicalDoc ==true
                        }).catch(error => {
                            console.log('errorerrorerror',error);
                        })
                }
                
            })
            .catch((error) => {
                console.log('Error In 1841 ', error);
            });
    }
    toRefreshDocumentTable(event){
        this.showEsignPhysicalDoc=false
        refreshApex(this._wiredLoanApplication); 
        setTimeout(() => {
            this.showEsignPhysicalDoc=true
            if(this.template.querySelector('c-uploded-document-display') != null){
                this.template.querySelector('c-uploded-document-display').handleFilesUploaded( '');
            }
            
        }, 2000);
    }
    toRefreshDocumentTableforStamp(event){
        this.showEstampPhysicalDoc=false
        this.updateEStampFieldFoStamp=true;
        refreshApex(this._wiredLoanApplication); 
        setTimeout(() => {
            this.showEstampPhysicalDoc=true
            if(this.template.querySelector('c-uploded-document-display') != null){
                this.template.querySelector('c-uploded-document-display').handleFilesUploaded( '');
            }
            
        }, 2000);
    }
    @track filterConditionForSubReg;
    handleDistricVal(event){
        console.log('inside handleValueForSDFCBnk1'+JSON.stringify(event.detail));
        let districRecId=event.detail.id;
        if(districRecId!=null){
            this.regiDisabled=false
        }
        
        this.serchMasterData(districRecId);
    }
    serchMasterData(districRecId){
       
        let branchNameparams = {
            ParentObjectName: 'MasterData__c',
            ChildObjectRelName: '',
            parentObjFields: ['Id','SalesforceCode__c', 'Name'],
            childObjFields: [],
            queryCriteria: ' where Id = \'' + districRecId + '\''  + ' LIMIT 1'
        }
        getSobjectData({params: branchNameparams})
        .then((result)=>{
           

            if (result.parentRecords && result.parentRecords.length>0) {
                this.loanAppRecord.EStamp_District__c=result.parentRecords[0].Name;
                this.loanAppRecord.District_Salesforce_Code__c=result.parentRecords[0].SalesforceCode__c;
                this.filterConditionForSubReg=" Master_Data__c = '" + districRecId + "' AND Type__c = 'Estamp Sub Registrar'"
                
            }
        })
        .catch((error)=>{
            console.error('Error in line ##385',error)
        })
      }
      handleValueSubReg(event){
        console.log('inside handleValueForSDFCBnk1'+JSON.stringify(event.detail));
        let districRecId=event.detail.id;
        this.serchMasterDataSubReg(districRecId);
      }
      serchMasterDataSubReg(districRecId){
       
        let branchNameparams = {
            ParentObjectName: 'MasterData__c',
            ChildObjectRelName: '',
            parentObjFields: ['Id','SalesforceCode__c', 'Name'],
            childObjFields: [],
            queryCriteria: ' where Id = \'' + districRecId + '\''  + ' LIMIT 1'
        }
        getSobjectData({params: branchNameparams})
        .then((result)=>{
           

            if (result.parentRecords && result.parentRecords.length>0) {
                this.loanAppRecord.EStamp_Sub_Registrar_Office__c=result.parentRecords[0].Name;
                this.loanAppRecord.Sub_Registrar_Office_Salesforce_Code__c=result.parentRecords[0].SalesforceCode__c;
            }
        })
        .catch((error)=>{
            console.error('Error in line ##385',error)
        })
      }
      selectedRecId
      serchMasterIdForReg(){
       
        let branchNameparams = {
            ParentObjectName: 'MasterData__c',
            ChildObjectRelName: '',
            parentObjFields: ['Id','SalesforceCode__c', 'Name'],
            childObjFields: [],
            queryCriteria: ' where SalesforceCode__c = \'' + this.loanAppRecord.Sub_Registrar_Office_Salesforce_Code__c + '\' AND Name = \'' + this.loanAppRecord.EStamp_Sub_Registrar_Office__c + '\' Limit 1'
        }
        getSobjectData({params: branchNameparams})
        .then((result)=>{
           if (result.parentRecords && result.parentRecords.length>0) {
            this.selectedRecId=result.parentRecords[0].Id;
            console.error('this.selectedRecId',this.selectedRecId)
             
                
            }
        })
        .catch((error)=>{
            console.error('Error in line ##385',error)
        })
    }
    selectedDistrictRecId
    serchMasterIdForDistric(){
       
        let branchNameparams = {
            ParentObjectName: 'MasterData__c',
            ChildObjectRelName: '',
            parentObjFields: ['Id','SalesforceCode__c', 'Name'],
            childObjFields: [],
            queryCriteria: ' where SalesforceCode__c = \'' + this.loanAppRecord.District_Salesforce_Code__c + '\' AND Name = \'' + this.loanAppRecord.EStamp_District__c + '\' Limit 1'
        }
        getSobjectData({params: branchNameparams})
        .then((result)=>{
           if (result.parentRecords && result.parentRecords.length>0) {
            this.selectedDistrictRecId=result.parentRecords[0].Id;
            console.error('this.selectedRecId',this.selectedRecId)
             
                
            }
        })
        .catch((error)=>{
            console.error('Error in line ##385',error)
        })
    }
    serchMasterIdForDistrict(districRecId){
       
        let branchNameparams = {
            ParentObjectName: 'MasterData__c',
            ChildObjectRelName: '',
            parentObjFields: ['Id','SalesforceCode__c', 'Name'],
            childObjFields: [],
            queryCriteria: ' where Id = \'' + districRecId + '\''  + ' LIMIT 1'
        }
        getSobjectData({params: branchNameparams})
        .then((result)=>{
           

            if (result.parentRecords && result.parentRecords.length>0) {
                this.loanAppRecord.EStamp_Sub_Registrar_Office__c=result.parentRecords[0].Name;
                this.loanAppRecord.Sub_Registrar_Office_Salesforce_Code__c=result.parentRecords[0].SalesforceCode__c;
            }
        })
        .catch((error)=>{
            console.error('Error in line ##385',error)
        })
      }

    
}