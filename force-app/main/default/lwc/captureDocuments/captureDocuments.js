import { LightningElement, api, track, wire } from 'lwc';

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { subscribe, MessageContext } from 'lightning/messageService';
import SaveBtnChannel from "@salesforce/messageChannel/SaveBtnChannel__c";
import { updateRecord, getRecord } from "lightning/uiRecordApi";
import getAssetPropType from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import getValidationReport from "@salesforce/apex/ValidateRequiredFieldsAndDoc.getValidationReport";
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import getLightningHostname from "@salesforce/apex/DomainNameProvider.getLightningHostname";
import getVisualforceDomain from "@salesforce/apex/DomainNameProvider.getVisualforceDomain";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import addAppkycDd from "@salesforce/apex/DocumentDetailController.addAppkycDd";
import findRequiredDoc from "@salesforce/apex/DocumentDetailController.findRequiredDoc";
import createDocumentDetail from "@salesforce/apex/DocumentDetailController.createDocDetailwithApplicantAsset";
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";

//ApplicantFields
import CPA_REMARK_APLCNT_FIELD from "@salesforce/schema/Applicant__c.REMARK__c";
import RM_REMARK_APLCNT_FIELD from "@salesforce/schema/Applicant__c.RM_Remarks__c";
import { refreshApex } from '@salesforce/apex';


//LAK-3223
import CURRENT_USER_ID from '@salesforce/user/Id';

const MAX_FILE_SIZE = 5242880; //in bytes 5 MB now
const MAX_FILE_SIZE_FOR_BANK = 26214400;
import { NavigationMixin } from "lightning/navigation";

// Custom labels
import Documents_OSV_ErrorMessage from '@salesforce/label/c.Documents_OSV_ErrorMessage';
import Documents_Validate_SuccessMessage from '@salesforce/label/c.Documents_Validate_SuccessMessage';
import Documents_ErrorMessage from '@salesforce/label/c.Documents_ErrorMessage';
import Documents_LAN_ErrorMessage from '@salesforce/label/c.Documents_LAN_ErrorMessage';
import Documents_Owner_ErrorMessage from '@salesforce/label/c.Documents_Owner_ErrorMessage';
import Documents_DocUpload_SuccessMessage from '@salesforce/label/c.Documents_DocUpload_SuccessMessage';
import Documents_File_ErrorMessage from '@salesforce/label/c.Documents_File_ErrorMessage';
import Documents_DocName_ErrorMessage from '@salesforce/label/c.Documents_DocName_ErrorMessage';
import Documents_DocTypeErrorMessage from '@salesforce/label/c.Documents_DocTypeErrorMessage';
import Documents_Status_ErrorMessage from '@salesforce/label/c.Documents_Status_ErrorMessage';
import Documents_DocSize25_ErrorMessage from '@salesforce/label/c.Documents_DocSize25_ErrorMessage';
import Documents_DocSize5_ErrorMessage from '@salesforce/label/c.Documents_DocSize5_ErrorMessage';
import Documents_FileType_ErrorMessage from '@salesforce/label/c.Documents_FileType_ErrorMessage';
import Documents_DocDetails_SuccessMessage from '@salesforce/label/c.Documents_DocDetails_SuccessMessage';
import Documents_DocDetails_ErrorMessage from '@salesforce/label/c.Documents_DocDetails_ErrorMessage';
import Documents_SelectFile_ErrorMessage from '@salesforce/label/c.Documents_SelectFile_ErrorMessage';
import Documents_LAN_SuccessMessage from '@salesforce/label/c.Documents_LAN_SuccessMessage';
import UploadDocDisply_Remarks_SuccessMessage from '@salesforce/label/c.UploadDocDisply_Remarks_SuccessMessage';
import Property_Save_Of_Document_Message from '@salesforce/label/c.Property_Save_Of_Document_Message';
import Id from "@salesforce/user/Id";
export default class CaptureDocuments extends NavigationMixin(LightningElement) {

    @track userId = Id;
    label = {
        Documents_OSV_ErrorMessage,
        Documents_Validate_SuccessMessage,
        Documents_ErrorMessage,
        Documents_LAN_ErrorMessage,
        Documents_Owner_ErrorMessage,
        Documents_DocUpload_SuccessMessage,
        Documents_File_ErrorMessage,
        Documents_DocName_ErrorMessage,
        Documents_DocTypeErrorMessage,
        Documents_Status_ErrorMessage,
        Documents_DocSize25_ErrorMessage,
        Documents_DocSize5_ErrorMessage,
        Documents_FileType_ErrorMessage,
        Documents_DocDetails_SuccessMessage,
        Documents_DocDetails_ErrorMessage,
        Documents_SelectFile_ErrorMessage,
        Documents_LAN_SuccessMessage,
        UploadDocDisply_Remarks_SuccessMessage

    }

    @api applicantId //= 'a0AC4000000DyETMA0';
    @api loanAppId //= 'a08C4000005ynpNIAQ';
    @api productType //= 'Home Loan';
    @api stage //= 'QDE';
    @api subStage //= 'RM Data Entry';
    @api layoutSize;
    @api allowedFilFormat = [".jpeg", ".jpg", ".pdf"];
    @api docCategory = "KYC Documents";
    @api documentCatagory;
    @api applicantIdOnTabset;
    @api hasEditAccess;
    @api isCpa = false;
    @api appAsserId = '';
    @api stepperName = '';
    @track disableMode = false;
    @api stageName = '';
    @api isProperty = false;
    @api stagenm
    @track lanStatus;
    //a0ZC4000000AsTlMAK
    @track isotherDocuments = false;
    @track showSpinner = false;
    @track referedDocLink;
    @track documentCatagoeyMap;
    @track docNameOption = [];
    @track docTypeOption = [];
    @track lstOfFiles = null;
    @track docType;
    @track docName;
    @track DocumentDetaiId;
    @track DocMasterId;
    @track showAvailable = false;
    @track hildUplButton = false;
    @track message = Property_Save_Of_Document_Message;
    // @track DocumentType;
    // @track DocumentDetailName;
    @track vfUrl;
    @track lightningDomainName;
    @track isSite = false;
    // @track typeWithSubtypesMap;
    @track fileData = [];
    @track availableInFile = false;
    @track showUpload = false;
    @track showAddDoc = false;
    typeWithSubtypesMap = new Map();

    typeWithCategory = new Map();
    @track typeWithSubtypeOptions;
    @track docTypeOptionNew = [];
    @track fileName;
    @track totalResult;
    @track docNameOptionNew = [];
    @track catValue;
    @track disableAvialbleInFile = false;
    @track disableFileUpload = false;
    @track themeType;
    @track isReadOnly;
    @track helperText;
    @track isReturnToRM = false;
    @track returnToRmMessage = "Do you want to return this Application to RM?";
    @track loanAppData;
    @track disableSaveRemarks = false;
    @track disableRemarks = false;
    @track fileAcceptance;
    @track currentSubStage;
    @track catgryDocs = [];
    @track convertToSingleImage;
    @track showNote = false
    @api isObligation=false;
    _isobligation="Maximum File Size should be 5Mb. Allowed File Types are  .jpg, .jpeg, .pdf ";
    _fileTypeError='Allowed File Types are : pdf, jpg, jpeg';
    // @wire(getSobjectDatawithRelatedRecords, { params: '$params' })
    // handleResponse(result) {
    //     this.isCoApplicant = false;
    //     this.wiredData = result
    //     if (result.data) {
    //         // this.wrapObj = { ...result.data.parentRecord , Age__c : this.getNumber(result.data.parentRecord.DOB__c) , InceptionYears__c : this.getNumber(result.data.parentRecord.DOI__c) , Nationality__c : 'INDIA' , Type_of_Borrower__c : this.typeOfBorrower }

    //     }
    //     if (result.error) {
    //         console.error(result.error);
    //     }
    // }
    get disableSave() {
        return this.lanStatus === 'BRE Hard Reject';
}

    //LAK-3223
    @track isNotRm;

    // @track
    // parameterforTeam = {
    //     ParentObjectName: 'TeamHierarchy__c ',
    //     ChildObjectRelName: '',
    //     parentObjFields: ['Id', 'EmpRole__c '],
    //     childObjFields: [],
    //     queryCriteria: 'WHERE Employee__c=\'' + CURRENT_USER_ID + '\'' + 'ORDER BY LastModifiedDate DESC'
    // }

    // @wire(getSobjectData, { params: '$parameterforTeam' })
    // handleResponseTeamHierarchy(wiredResultTeam) {
    //     let { error, data } = wiredResultTeam;
    //     if (data) {
    //         if (data.parentRecords.length > 0) {
    //             let userTeamRole = data.parentRecords[0].EmpRole__c;
    //             if (userTeamRole === 'RM') {
    //                 this.isNotRm = false;
    //             }
    //             else {
    //                 this.isNotRm = true;
    //             }

    //         }
    //     } else if (error) {
    //         console.error('Error Team ------------->', error);
    //     }
    // }

    @wire(MessageContext)
    MessageContext;
    subscription;

    connectedCallback() {
        console.log('hasEditAccess', this.hasEditAccess)
        if (this.hasEditAccess === false) {

            this.disableMode = true;
            this.disableFileUpload = true;
            this.isReadOnly = true;
            this.disableRemarks = true;
        }
        this.sunscribeToMessageChannel();
        // this.isCpa = true;
        console.log('layoutSize ', this.layoutSize);
        // if (!this.isReadOnly) {
        //     this.isReadOnly = false
        // }

        if (this.hasEditAccess === true || this.hasEditAccess === undefined) {
            this.isReadOnly = false;

        }
        else {
            this.isReadOnly = true;
            this.disableAvialbleInFile = true;
            this.disableFileUpload = true;
            this.disableRemarks = true;
            this.disableSaveRemarks = true;
            this.hildUplButton = true
        }

        this.getLoanApplicationData();

        console.log('loan app id from parent to catpure docu 0', this.loanAppId);
        if (this.applicantIdOnTabset) {
            this.applicantId = this.applicantIdOnTabset;
        }
        console.log('loan app id from parent to catpure docu 1', this.loanAppId);

        // getVisualforceDomain().then((result) => {
        //     this.vfUrl = result;
        //     console.log("vf page domain==>", this.vfUrl);
        // });

        // getLightningHostname().then((result) => {
        //     this.lightningDomainName = result;

        //     console.log("lightningDomainName ==>", this.lightningDomainName);
        // });

        // window.addEventListener(
        //     "message",
        //     this.handleUploadCallback.bind(this)
        // );

        this.fetchRequiredDoc();
        console.log('applicant asset id is ', this.appAsserId);
        console.log('stepper name from applicant asset is ', this.stepperName);
        // FOR LAK-5087
        if (this.stepperName == 'propertyDetails' && this.appAsserId == 'new') {
            this.disableMode = true;
            this.showNote = true;
        }
        // FOR LAK-5087

        this.getSalesHierMetadat();

         //LAK-9807
         this.fetchApplRelook();

    }

    @track nextSubStage;
    @track queueName;    
    getStageTransitionMetadat() {
        
        let paramsLoanApp = {
            ParentObjectName: 'StageTransition__mdt',
            parentObjFields: ['Product__c', 'Current_SubStage__c', 'IsActive__c','Next_SubStage__c', 'Queue_Name__c', 'Next_Stage__c','Current_Stage__c'],
            queryCriteria: ' where Current_Stage__c = \'' + this.loanStage + '\' AND Current_SubStage__c = \'' + this.currentSubStage + '\' AND Product__c = \'' + this.loanProduct + '\' AND IsActive__c = true'
        }
        getSobjectDatawithRelatedRecords({ params: paramsLoanApp })
            .then((result) => {
                console.log('Stage Trans metadata is', JSON.stringify(result));
                if (result.parentRecord) {
                    this.nextSubStage=result.parentRecord.Next_SubStage__c;
                    this.queueName=result.parentRecord.Queue_Name__c;
                    console.log('Stage Trans metadata is', this.nextSubStage,this.queueName);
    }
            })
            .catch((error) => {
                console.log('Error In getting sales hierarchy details ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }



    @track salesHierNewArr = [];
    getSalesHierMetadat() {
        let salesLable = 'Sales';
        let paramsLoanApp = {
            ParentObjectName: 'SharingHierarchy__mdt',
            parentObjFields: ['Id', 'BrchRoleSharing__c', 'SupervisoreRoleSharing__c'],
            queryCriteria: ' where DeveloperName  = \'' + salesLable + '\''
        }
        getSobjectDatawithRelatedRecords({ params: paramsLoanApp })
            .then((result) => {
                console.log('sales hierarchy metadata is', JSON.stringify(result.parentRecord));
                if (result.parentRecord) {
                    let arrayFromString = result.parentRecord.BrchRoleSharing__c.split(',');
                    let arrayFromStringNew = result.parentRecord.SupervisoreRoleSharing__c.split(',');
                    let setFromArray = new Set([...arrayFromString, ...arrayFromStringNew]);
                    this.salesHierNewArr = Array.from(setFromArray);
                    console.log('this.salesHierNewArr', this.salesHierNewArr);
                    this.getTeamHierarchyData();
                }
            })
            .catch((error) => {
                console.log('Error In getting sales hierarchy details ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    @track empRole;
    getTeamHierarchyData() {
        let paramsLoanApp = {
            ParentObjectName: 'TeamHierarchy__c',
            parentObjFields: ['Id', 'Employee__c', 'EmpRole__c'],
            queryCriteria: ' where Employee__c = \'' + this.userId + '\' ORDER BY LastModifiedDate DESC'
        }
        getSobjectDatawithRelatedRecords({ params: paramsLoanApp })
            .then((result) => {
                console.log('team hierarchy data is', JSON.stringify(result.parentRecord));
                if (result.parentRecord) {
                    this.empRole = result.parentRecord.EmpRole__c;
                }
                if (this.empRole) {
                    if (this.empRole !== 'CBO') {
                        if (this.salesHierNewArr.includes(this.empRole)|| this.empRole == 'DSA') {
                            this.isNotRm = false;
                        } else {
                            this.isNotRm = true;
                        }
                    } else {
                        this.isNotRm = true;
                    }
                }
            })
            .catch((error) => {
                console.log('Error In getting team hierarchy details ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }
    @track loanProduct;
    @track loanStage;
    getLoanApplicationData() {
        let paramsLoanApp = {
            ParentObjectName: 'LoanAppl__c',
            parentObjFields: ['FileAcceptance__c', 'Stage__c', 'SubStage__c', 'OwnerId', 'Product__c', 'Status__c'],
            queryCriteria: ' where id = \'' + this.loanAppId + '\''
        }
        getSobjectDatawithRelatedRecords({ params: paramsLoanApp })
            .then((result) => {
                this.loanAppData = result;
                console.log('result of loan application is', result);
                if (result.parentRecord) {
                    console.log('parent record is===>', result.parentRecord);
                    this.fileAcceptance = result.parentRecord.FileAcceptance__c;
                    this.currentSubStage = result.parentRecord.SubStage__c;
                    this.loanStage = result.parentRecord.Stage__c;
                    this.lanStatus = result.parentRecord.Status__c;
                    this.loanProduct = result.parentRecord.Product__c;
                    if (result.parentRecord.Stage__c === 'QDE' && (result.parentRecord.SubStage__c === 'Additional Data Entry' || result.parentRecord.SubStage__c === 'Additional Data Entry Vendor Processing')) {
                        this.isReadOnly = false;
                        //FOR LAK-4112 
                        console.log('user id is ', this.userId, 'owner id is  ', result.parentRecord.OwnerId);
                        if (this.hasEditAccess &&(this.userId === result.parentRecord.OwnerId) ){
                            this.disableRemarks = false;
                            this.disableSaveRemarks = false;
                        }

                        // if (this.hasEditAccess) {
                        //     this.isReadOnly = false;
                        // } else {
                        //     this.isReadOnly = true;
                        //     this.disableSaveRemarks = true;
                        //     this.disableRemarks = true;
                        // }    
                    } else {
                        this.disableSaveRemarks = true;
                        this.disableRemarks = true;
                    }

                    //if (result.parentRecord.Stage__c === 'QDE' && result.parentRecord.SubStage__c === 'Additional Data Entry Pool') {
                     //   this.disableSaveRemarks = true;
                   // }
                    ///LAK-6477 START
                    if (result.parentRecord.Stage__c === 'Post Sanction' && (result.parentRecord.SubStage__c == 'Data Entry' || result.parentRecord.SubStage__c == 'Ops Query' || result.parentRecord.SubStage__c == 'UW Approval' || result.parentRecord.SubStage__c == 'UW Approval Pool')) {
                        this.isReadOnly = false;
                        this.disableMode = false;
                    }
                    ///LAK-6477 END
                    if (this.loanStage && this.loanProduct) {
                        this.getDocumenDisMetadata();
                       
                    }
                    if (this.loanStage && this.loanProduct && this.currentSubStage) {
                    this.getStageTransitionMetadat();
                    }
                }
            })
            .catch((error) => {
                console.log("error occured in fetchId", error);
            });
    }

    @track docCate = [];
    @track showTable = false;
    getDocumenDisMetadata() {
        this.showSpinner = true;
        console.log('this.loanStage  ', this.loanStage);
        console.log('this.loanProduct  ', this.loanProduct);
        let scrName = 'Document Details';
        // let paramsApp = {
        //     ParentObjectName: 'DocDisplay__mdt',
        //     ChildObjectRelName: '',
        //     parentObjFields: ['Id', 'DocConfig__c', 'SubStage__c', 'IsActive__c', 'Product_Type__c', 'ScrnName__c', 'Stage__c'],
        //     childObjFields: [],
        //     queryCriteria: ' where Stage__c = \'' + this.loanStage + '\' AND ScrnName__c = \'' + scrName + '\' AND Product_Type__c = \'' + this.loanProduct + '\' AND IsActive__c = true'
        // }
        this.paramsApp = {
            ParentObjectName: 'DocDisplay__mdt',
            ChildObjectRelName: '',
            parentObjFields: ['Id', 'DocConfig__c', 'SubStage__c', 'IsActive__c', 'Product_Type__c', 'ScrnName__c', 'Stage__c'],
            childObjFields: [],
            queryCriteria: ' where Stage__c = \'' + this.loanStage + '\' AND ScrnName__c = \'' + scrName + '\' AND Product_Type__c = \'' + this.loanProduct + '\' AND IsActive__c = true'
        }
        if(this.isObligation){
            this.screenName='Obligation Details';
            this.paramsApp = {
                ParentObjectName: 'DocDisplay__mdt',
                ChildObjectRelName: '',
                parentObjFields: ['Id', 'DocConfig__c', 'SubStage__c', 'IsActive__c', 'Product_Type__c', 'ScrnName__c', 'Stage__c'],
                childObjFields: [],
                queryCriteria: ' where  ScrnName__c = \'' + this.screenName + '\'  AND IsActive__c = true'
            }
        }

        //  console.log('getCoApplicantAvailable', paramsApp);
        getAssetPropType({ params: paramsApp })
            .then((result) => {
                if (result.parentRecords && result.parentRecords.length > 0) {
                    console.log('Documents Display Metadata is  ', result.parentRecords);
                    let docConfig = JSON.parse(result.parentRecords[0].DocConfig__c);
                    if (docConfig.DocCat && docConfig.DocCat.length > 0) {
                        this.docCate = docConfig.DocCat;
                        console.log('this.docCate is  ', this.docCate);
                    }
                }
                this.showTable = true;
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log("error occured in document display metadata", error);

            });

    }
    sunscribeToMessageChannel() {
        this.subscription = subscribe(
            this.MessageContext,
            SaveBtnChannel,
            (values) => this.getOsvData(values)
        );

    }
    getOsvData(values) {
        //select Id,  LAN__c, Appl__r.TabName__c,  DocMstr__r.OSVReq__c,   OSV__c  from DocDtl__c where LAN__c ='a08C4000007UVTlIAO'
        let paramsApp = {
            ParentObjectName: 'DocDtl__c',
            ChildObjectRelName: '',
            parentObjFields: ["Id", "LAN__c", "Appl__r.TabName__c", " DocSubTyp__c", "DocMstr__r.OSVReq__c", "OSV__c"],
            childObjFields: [],
            queryCriteria: ' where LAN__c = \'' + this.loanAppId + '\''
        }
        //  console.log('getCoApplicantAvailable', paramsApp);
        getAssetPropType({ params: paramsApp })
            .then((result) => {

                console.log('result for co-applicant ', result);
                let checkReqDoc = true;
                if (result.parentRecords && result.parentRecords.length > 0) {
                    console.log(' Document found', result.parentRecords);
                    result.parentRecords.forEach(element => {
                        if (element.DocMstr__r && element.DocMstr__r.OSVReq__c && !element.OSV__c) {
                            checkReqDoc = false;
                            console.log(' missing Osv Check ', element.Appl__r.TabName__c + ' : Please check OSV for ' + element.DocSubTyp__c);
                            this.showToast("Error", "error", element.Appl__r.TabName__c + this.label.Documents_OSV_ErrorMessage + element.DocSubTyp__c);
                        }
                    });
                } else {

                    console.log('No Document found');
                }
                if (checkReqDoc) {
                    //LAK-9807
                    if(this.lanStatus === 'BRE Hard Reject'){
                        this.showToast("Error", "error", 'Loan Application Status is Hard Reject. You can not submit LAN.');
                    } else if(this.lanStatus === 'BRE Soft Reject'){
                        if(!this.relookData){
                            this.showToast("Error", "error", 'Loan Application Status is BRE Soft Reject. Please Initiate for Application Relook Case.');
                        }else if(this.relookData && this.relookData.length>0 && this.loanAppealStatus !== 'Approved'){
                            this.showToast("Error", "error", 'Loan Application Status is BRE Soft Reject. Loan Appeal is not approved yet.');
                        }    
                    }else{
                        console.log('handleSubmit initiated');
                        this.handleSubmitThroughLms(values);
                    }
                    
                }
            })
            .catch((error) => {
                console.log("error occured in checking osv", error);

            });

    }
    handleSubmitThroughLms(event) {
        this.showSpinner = true;
        // console.log("submit button clicked in CaptureDocuments  ", event, " applicant Id  ==", this.applicantId);
        if (event.buttonClicked === "Submit" && event.Id === this.applicantId) {

            getValidationReport({ loanAppId: this.loanAppId })
                .then((result) => {

                    let positiveResp = false;
                    if (result && result.length > 0) {
                        console.log('resp of validation  ', result, JSON.stringify(result));
                        result.forEach(res => {
                            if (res.validated === true) {
                                positiveResp = true;
                                if (res.missingSubDocValue) {
                                    const subDocList = Object.entries(res.missingSubDocValue).map(([subDocName, subDocValues]) => {
                                        return { subDocName, subDocValues };
                                    });
                                    console.log(subDocList);
                                }



                                // this.showToast("Success", "success", "Validated");
                                //  this.changeSubStage();
                                // this.showSpinner = false;                          
                            } else {
                                let resp = '';
                                if (res.missingDoc === true && res.missingSubDocValue) {
                                    const subDocList = Object.entries(res.missingSubDocValue).map(([subDocName, subDocValues]) => {
                                        return { subDocName, subDocValues };
                                    });

                                    let respVal = '';
                                    if (subDocList) {
                                        subDocList.forEach(element => {
                                            let res = '';
                                            if (element.subDocValues.length > 0) {
                                                res = element.subDocName + ' : ( ' + element.subDocValues.join(' ,') + ') ,';
                                            } else {
                                                res = element.subDocName + ' , ';
                                            }
                                            respVal = respVal + res;
                                        });
                                    }

                                    if (respVal.length >= 2) {
                                        // Remove the last two characters using Substring
                                        respVal = respVal.substring(0, respVal.length - 2);
                                    }


                                    console.log('subDocList ', subDocList, JSON.stringify(subDocList));
                                    // resp = res.applicantName + ' : ' + res.errorMessage + ' : [ ' + res.missingValue + ' ]';
                                    resp = res.applicantName + ' : ' + res.errorMessage + ' : [ ' + respVal + ' ]';
                                } else {
                                    resp = res.applicantName + ' : ' + res.errorMessage;
                                }
                                positiveResp = false;
                                //resp = res.applicantName + ' : ' + res.errorMessage;
                                this.showToast("Error", "error", resp);
                            }
                        })
                    } else {
                        positiveResp = true;
                    }

                    if (positiveResp) {
                        this.showToast("Success", "success", this.label.Documents_Validate_SuccessMessage);
                        this.changeSubStage();
                        // this.showSpinner = false;
                    }
                    this.showSpinner = false;
                    console.log('resp of validation   last line ', this.showSpinner);

                })
                .catch((err) => {
                    this.showToast("Error", "error", this.label.Documents_ErrorMessage + err.body.message);
                    console.log(" Error occured in getValidationReport   ", err.body.message);
                    this.showSpinner = false;
                });

        }

    }
    changeSubStage() {
        //LAK-9517 - Jayesh
        if (this.subStage === 'RM Data Entry' || this.subStage === 'Pre login Query' || this.subStage === 'DSA Data Entry' || this.subStage === 'DSA Pre Login Query') {
           // let grpName = 'CPA POOL';
           let grpName = this.queueName;
            let params = {
                ParentObjectName: 'Group',
                parentObjFields: ["Id", "Name"],

                queryCriteria: ' where name = \'' + grpName + '\''
            };
            console.log("params", params);
            getSobjectDatawithRelatedRecords({ params: params })
                .then((res) => {
                    console.log(" getSobjectDatawithRelatedRecords res", res.parentRecord);
                    const loanAppFields = {};
                    loanAppFields['OwnerId'] = res.parentRecord.Id;
                    loanAppFields['Id'] = this.loanAppId;
                    let dt = new Date().toISOString().substring(0, 10);
                    loanAppFields['LoanApplSubDt__c'] = dt;
                    // if (this.currentSubStage === 'RM Data Entry' || this.currentSubStage === 'DSA Data Entry') {
                    //     loanAppFields['SubStage__c'] = "Additional Data Entry Pool";
                    // } else if (this.currentSubStage === 'Pre login Query' || this.currentSubStage === 'DSA Pre Login Query') {
                    //     loanAppFields['SubStage__c'] = "Pre login Query Pool";
                    // }
                    //This substage is controlled by Stage Transition metadata
                       loanAppFields['SubStage__c'] = this.nextSubStage;
                         
                    const recordInput = {
                        fields: loanAppFields
                    };
                    console.log("LoanApplication recordInput ", recordInput);

                    let upsertDataFile = {
                        parentRecord: loanAppFields,
                        ChildRecords: null,
                        ParentFieldNameToUpdate: ''
                    }
                    console.log('upsertData ==>', JSON.stringify(upsertDataFile));

                    upsertSobjDataWIthRelatedChilds({ upsertData: upsertDataFile })
                        .then(result => {
                            console.log("LoanApplication Updated ", result);
                            this.showToast("Success", "success", this.label.Documents_LAN_SuccessMessage);
                            this.showSpinner = false;
                            this.navigateToListView();

                        }).catch(error => {
                            this.showToast("Error", "error", error.body.message);
                            console.log(" Error occured in Updating LoanApplication === ", error);
                            this.showSpinner = false;


                        })

                    // updateRecord(recordInput)
                    //     .then((record) => {
                    //         console.log("LoanApplication Updated ", record);
                    //         this.showToast("Success", "success", "Loan Submited SuccessFully");
                    //         this.showSpinner = false;
                    //         this.navigateToListView();

                    //     }).catch((err) => {
                    //         this.showToast("Error", "error", "Error occured in Updating LoanApplication  " + err.message);
                    //         console.log(" Error occured in Updating LoanApplication Err=== ", err);
                    //         this.showSpinner = false;
                    //     });

                })
                .catch((err) => {
                    this.showToast("Error", "error", err.message);
                    console.log(" Error occured in Updating Owner  Err=== ", err);
                    this.showSpinner = false;
                });
        }
    }
    navigateToListView() {
        console.log('navigateToListView called ');
        // Navigate to the Contact object's Recent list view.
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: "LoanAppl__c",
                actionName: "list"
            },
            state: {
                // 'filterName' is a property on the page 'state'
                // and identifies the target list view.
                // It may also be an 18 character list view id.
                filterName: "Recent" // or by 18 char '00BT0000002TONQMA4'
            }
        });
    }


    closeModal() {
        console.log('isModalOpen ', this.isModalOpen);
        this.isReturnToRM = false;
    }

    //method to sort array of objects alphabetically
    compareByLabel(a, b) {
        const nameA = a.label.toUpperCase();
        const nameB = b.label.toUpperCase();

        if (nameA < nameB) {
            return -1;
        }
        if (nameA > nameB) {
            return 1;
        }
        return 0;
    }

    handleUploadCallback(message) {
        console.log('responve from vf 111 ', JSON.stringify(message.data));
        if (message.data.source === "vf") {
            if (message.data.fileIdList != null) {
                //this.createApplicantKycObj();
                this.fileData = [];
                this.showSpinner = false;
                this.showToast(
                    "Success",
                    "success",
                    this.label.Documents_DocUpload_SuccessMessage
                );
                this.docName = "";
                this.docNameOptionNew = "";
                this.docType = "";
                this.helperText = '';
                this.showUpload = false;
                this.showAvailable = false;
                this.refreshDocTable();
            } else {
                this.showSpinner = false;
                this.showToast("Error", "error", result);
            }
            this.DocumentDetaiId = "";
            // this.DocumentType = "";
            // this.DocumentDetailName = "";
            this.DocMasterId = "";
            this.fileName = "";
        }
    }

    fetchRequiredDoc() {
        //this.docTypeOptionNew = "";
        findRequiredDoc({ applicantId: this.applicantId, loanAppId: this.loanAppId, productType: this.productType, stage: this.stage, subStage: this.subStage })
            .then((result) => {
                console.log(
                    'result for options', result
                );
                console.log('keys of result ');
                if (this.appAsserId) {
                    this.catgryDocs = ['Collateral Documents']
                } else if(this.isObligation){
                    this.catgryDocs = ['Loan Obligation']
                   this._isobligation="Maximum File Size should be 5Mb. Allowed File Types are  .xlsx ";
                   this._fileTypeError='Allowed File Types are : xlsx';
                   
                }else {
                    this.catgryDocs = ['Application Form', 'Banking Documents', 'Income Documents', 'KYC Documents', 'Other Documents', 'Constitution wise Mandatory documents'];
                }
                //'Collateral Documents'
                //new implementation
                this.totalResult = result;
                Object.keys(result).forEach(key => {
                    // this.typeWithSubtypeOptions = { ...this.typeWithSubtypeOptions, keyOptons }
                    if (this.catgryDocs.includes(key)) {
                        Object.keys(result[key]).forEach(keyty => {

                            this.typeWithCategory.set(keyty, key);
                            if (keyty != 'Bank Statement' && keyty != 'Financials - P&L and BL' && keyty != 'Income Tax Returns' && keyty != 'GST Returns') {
                                let docc = { label: keyty, value: keyty };
                                this.docTypeOptionNew = [...this.docTypeOptionNew, docc];
                                this.docTypeOptionNew.sort(this.compareByLabel);
                            }
                        });
                    }
                });
                console.log('docTypeOptionNew new is===> ', this.docTypeOptionNew);
                console.log('typeWithSubtypeOptions ==> ', this.typeWithSubtypeOptions);
                console.log('typeWithCategory map ==> ', this.typeWithCategory);
            })
            .catch((err) => {
                this.showToast(
                    "Error!!",
                    "error",
                    err.body.message
                );
            })
            .finally(() => { });
    }


    handleChange(event) {
        let name = event.target.name;
        let val = event.target.value;
        console.log('name', name, 'val', val);
        if (name === 'DocumentType') {
            this.docType = val;
            this.docName = '';
            this.docNameOptionNew = [];
            this.catValue = this.typeWithCategory.get(val);
            if (this.catValue === 'KYC Documents' || this.catValue === 'PAN Documents') {
                this.convertToSingleImage = true;
            } else {
                this.convertToSingleImage = false;
            }
            console.log('catValue', this.catValue);
            console.log('before loop', this.totalResult[this.catValue][val]);
            this.totalResult[this.catValue][val].forEach(item => {
                let docc = { label: item, value: item };
                this.docNameOptionNew = [...this.docNameOptionNew, docc];
                this.docNameOptionNew.sort(this.compareByLabel);
            });
            console.log('docNameOptionNew ==>  ', this.docNameOptionNew);
            //added for LAK-2411
            if (this.docType == 'Other Income Documents' || this.docType == 'Additional documents') {
                this.isotherDocuments = true;
            } else {
                this.isotherDocuments = false;
            }
            //Ended For LAK-2411
            this.showUpload = false;
            this.showAddDoc = false;
            // this.docNameOption = [];
            // this.documentCatagoeyMap[val].forEach(item => {
            //     let doc = { label: item, value: item };
            //     this.docNameOption = [...this.docNameOption, doc];
            // });
            // if (this.docType && this.docName) {
            //     this.getAvailableInFile(this.docType, this.docName);
            // }
            this.showAvailable = false;
        }
        if (name === 'DocumentName') {
            this.docName = '';
            console.log('document name ', this.docName);
            // this.docName = val;
            if (this.docType == 'Other Income Documents' || this.docType == 'Additional documents') {
                this.docName = val.toUpperCase();
            } else {
                this.docName = val;
            }

            let conditionForIntMsg = ['Passport', 'Aadhaar', 'Voter ID', 'Driving license', 'PAN'];
            if (conditionForIntMsg.includes(this.docName) && this.docType && this.docName) {
                console.log('inside condition');
                if (this.lstOfFiles) {
                    let searchDoc = this.lstOfFiles.find((doc) => doc.docDetName.toLowerCase() == this.docName.toLowerCase());
                    console.log('searchDoc ', this.searchDoc);
                    if (searchDoc && searchDoc.cdlId) {
                        console.log('inside searchDoc');
                        this.showUpload = false;
                        this.showAddDoc = true;
                        this.disableAvialbleInFile = true;
                        this.availableInFile = false;
                        let index = this.lstOfFiles.findIndex((doc) => doc.docDetName == this.docName);
                        this.referedDocLink = this.lstOfFiles[index].LinkedEntityId;
                        console.log('referedDocLink ', this.referedDocLink);


                    } else {
                        this.showUpload = true;
                        this.disableFileUpload = false;
                        this.showAddDoc = false;
                        this.disableAvialbleInFile = false;
                    }
                } else {
                    this.showUpload = true;
                    this.disableFileUpload = false;
                    this.showAddDoc = false;
                    this.disableAvialbleInFile = false;
                }

                if (this.docType && this.docName) {
                    this.getAvailableInFile(this.docType, this.docName);
                }
            } else {
                this.showUpload = true;
                this.disableFileUpload = false;
                this.disableAvialbleInFile = false;
                if (this.docType && this.docName) {
                    this.getAvailableInFile(this.docType, this.docName);
                }
            }

            if (this.catValue === 'KYC Documents' || this.catValue === 'PAN Documents') {
                if (this.typeWithSubtypesMap.has(this.docType)) {
                    console.log('inside');
                    let values = this.typeWithSubtypesMap.get(this.docType);
                    console.log('inside docName change ', values);
                    if (values.includes(this.docName)) {
                        console.log('inside values change ');
                        this.showUpload = false;
                        this.showAddDoc = false;
                        // this.docName = '';
                        this.disableAvialbleInFile = true;
                        this.disableFileUpload = true;

                        this.showToast(
                            "Error!",
                            "error",
                            this.label.Documents_File_ErrorMessage
                        );
                        this.docName = null;
                        this.docType = '';
                        return;
                        console.log('this.docName ', this.docName);
                    }
                    else {
                        if (this.showAddDoc == false) {
                            this.showUpload = true;
                            this.showAddDoc = false;
                            this.disableFileUpload = false;
                            this.disableAvialbleInFile = false;
                        }
                    }
                }
            } else {
                if (this.lstOfFiles) {
                    let searchDoc = this.lstOfFiles.find((doc) => doc.docDetName.toLowerCase() == this.docName.toLowerCase());
                    console.log('searchDoc ', this.searchDoc);
                    if (searchDoc) {
                        this.showAvailable = false;
                        this.disableAvialbleInFile = true;
                        this.DocumentDetaiId = searchDoc.docId;
                    } else {
                        this.DocumentDetaiId = '';
                        if (this.docType && this.docName) {
                            this.getAvailableInFile(this.docType, this.docName);
                        }
                    }
                    this.showUpload = true;
                }


            }
        }
        if (name == 'availableInFile') {
            console.log('availabeinfile checked ', event.target.checked);
            console.log('availableInFile', this.availableInFile);
            this.availableInFile = event.target.checked;
            if (this.docType) {
                if (this.docName) {
                    if (this.availableInFile) {
                        // const result = await LightningConfirm.open({
                        //     message: 'Are You Sure This Document Available in Files ?',
                        //     variant: 'headerless',
                        //     label: 'Are You Sure This Document Available in Files ?',
                        // });
                        // console.log('result from confirm is', result);
                        // if (result) {
                        //     this.showUpload = false;
                        //     this.availableInFile = true;
                        //     this.refreshChekcbox = true;
                        //     this.showAddDoc = false;
                        //     this.createDocumentDetailRecord(true);
                        // } else {
                        //     this.availableInFile = false;
                        //     this.showUpload = true;
                        //     console.log('showUpload ', this.showUpload);
                        //     console.log('availableInFile ', this.availableInFile);
                        // }
                        this.createDocumentDetailRecord(true);
                    }
                    //  else {
                    //     this.showUpload = true;
                    // }

                } else {
                    this.availableInFile = false;
                    this.showToast(
                        "Error!",
                        "error",
                        this.label.Documents_DocName_ErrorMessage
                    );
                }

            } else {
                this.availableInFile = false;
                this.showToast(
                    "Error!",
                    "error",
                    this.label.Documents_DocTypeErrorMessage
                );
            }

        }
        // this.checkValidityOfDocument();
    }

    getAvailableInFile(docType, docName) {
        console.log('data in document master fetch ', docType + 'doc subtype ', docName);
        let docNamee = docName.replace(/'/g, "\\'");
        console.log("doc nameee ", docNamee);
        let params = {
            ParentObjectName: 'DocMstr__c',
            parentObjFields: ["Id", "AvlInFile__c", "DocHelpText__c"],

            queryCriteria: ' where DocTyp__c = \'' + docType + '\' AND DocSubTyp__c = \'' + docNamee + '\''
        };
        getSobjectDatawithRelatedRecords({ params: params })
            .then((res) => {
                let result = res.parentRecord;
                console.log('result from document master is ', result);
                if (result && result.AvlInFile__c) {
                    this.showAvailable = true;
                } else {
                    this.showAvailable = false;
                }
                if (result && result.DocHelpText__c) {
                    this.helperText = result.DocHelpText__c;

                } else {
                    this.helperText = '';

                }
                if (this.isCpa == true) {
                    this.disableAvialbleInFile = false;
                }
                if (this.docType == 'Other Income Documents' || this.docType == 'Additional documents') {
                    this.showAvailable = true;
                    console.log('showAvailable in other documents ', this.showAvailable);
                }
            })
            .catch((err) => {
                this.showToast("Error", "error", err.message);
                console.log(" getSobjectDatawithRelatedRecords error===", err);
            });
    }
    handleFileChange(event) {
        this.showSpinner = true;

        if (
            event.target.files.length > 0
            &&
            this.docName &&
            this.docType
        ) {
            let dt = [];
            for (var i = 0; i < event.target.files.length; i++) {
                console.log('file size is for ', i, '  ', event.target.files[i].size);
                if (this.docType == 'Bank Statement') {
                    if (event.target.files[i].size > MAX_FILE_SIZE_FOR_BANK) {
                        this.showToast(
                            "Error!",
                            "error",
                            this.label.Documents_DocSize25_ErrorMessage
                        );
                        this.showSpinner = false;
                        return;
                    }
                } else {
                    if (event.target.files[i].size > MAX_FILE_SIZE) {
                        this.showToast(
                            "Error!",
                            "error",
                            this.label.Documents_DocSize5_ErrorMessage
                        );
                        this.showSpinner = false;
                        return;
                    }
                }

                let file = event.target.files[i];
                this.fileName = file.name;
                let extension = this.fileName.split('.').pop();
                console.log('file extension==>>>>', extension);
                console.log('file name is ', this.fileName);
                console.log("filechange details 0", file);
                console.log("filechange details 1", file.name);

                //  let fileName = file.name + "  ";
                if (!this.allowedFilFormat.includes('.' + extension)) {
                    this.showToast("Error!", "error", this.label.Documents_FileType_ErrorMessage);
                    this.showSpinner = false;
                    this.fileName = "";
                    return;
                }
                let reader = new FileReader();
                console.log("filechange FILE IS", file);
                console.log(" filechange READER IS", reader);
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
                };
                reader.readAsDataURL(file);

            }
            this.createDocumentDetailRecord(false);

        } else {
            this.showToast("Error!", "error", this.label.Documents_DocName_ErrorMessage);
        }
    }

    @api checkValidityOfDocument() {

        let isInputCorrect
        const docArrayList = this.lstOfFiles
        if (docArrayList !== null) {
            return true;
        } else {
            isInputCorrect = [...this.template.querySelectorAll("lightning-combobox")].reduce((validSoFar, inputField) => {
                console.log('doc array ');
                if (this.docName !== undefined || this.docType !== undefined) {
                    inputField.setCustomValidity("Please Enter Valid Input");
                }
                inputField.reportValidity();


                return validSoFar && inputField.checkValidity();
            }, true);

            return isInputCorrect;
        }


    }

    createDocumentDetailRecord(param) {
        console.log('param to this methods is ' + param);
        console.log('createDocumentDetailRecord applicantId:', this.applicantId, "loanAppId: ", this.loanAppId, "docCategory:", this.catValue, "docType:", this.docType, "docSubType:", this.docName, 'applicantAssetId ', this.appAsserId);
        createDocumentDetail({ applicantId: this.applicantId, loanAppId: this.loanAppId, docCategory: this.catValue, docType: this.docType, docSubType: this.docName, availableInFile: param, applicantAssetId: this.appAsserId })
            .then((result) => {
                console.log('createDocumentDetailRecord result ', result);
                this.DocumentDetaiId = result;
                console.log('createDocumentDetailRecord DocumentDetaiId ', this.DocumentDetaiId);
                if (!param) {
                    console.log('inside upload hanlder');
                    this.fileUploadHandleer();
                } else {
                    console.log('insidedocument Creation', this.DocumentDetaiId);
                    this.showToast("Success", "Success", this.label.Documents_DocDetails_SuccessMessage);
                    this.docType = null;
                    this.helperText = ''
                    this.docName = null;
                    this.availableInFile = false;
                    this.showAddDoc = false;
                    this.showUpload = false;
                    this.refreshDocTable();
                    this.showSpinner = false;
                    this.showAvailable = false;
                }
            })
            .catch((err) => {
                this.showSpinner = false;
                this.showToast("Error", "error", err);
                console.log(" createDocumentDetailRecord error===", err);
            });
    }


    fileUploadHandleer() {
        if (this.fileData == [] || this.fileData.length == 0) {
            this.showSpinner = false;
            this.showToast("Error", "error", this.label.Documents_SelectFile_ErrorMessage);
            return;
        } else {
            this.uploadFileLargeVf();

            this.showSpinner = true;
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
        console.log("domain name=====>", this.lightningDomainName);
        this.template.querySelector("iframe").contentWindow.postMessage(
            JSON.parse(
                JSON.stringify({
                    source: "lwc",
                    files: this.fileData,
                    parameters: this.DocumentDetaiId,
                    lightningDomain: this.lightningDomainName
                })
            ),
            this.vfUrl
        );
        console.log("upload called vfurl",
            " files:", this.fileData,
            " parameters:", this.DocumentDetaiId,
            "  lightningDomain:", this.lightningDomainName);
    }

    getDocuments(event) {
        this.typeWithSubtypesMap = new Map();
        console.log('typeWithSubtypesMap ==> ', this.typeWithSubtypesMap);
        // Create a map with keys as strings and values as lists of strings
        console.log('files from child is ', JSON.stringify(event.detail));
        this.lstOfFiles = event.detail;
        console.log('files from child is 22 ', this.lstOfFiles);
        this.docName = '';
        this.docType = '';
        this.showUpload = false;
        this.showAddDoc = false;
        if (this.lstOfFiles) {
            this.lstOfFiles.forEach((item) => {
                let key = item.docDetType;
                console.log('files from child is 33', key, this.typeWithSubtypesMap.get(key));

                if (this.typeWithSubtypesMap.has(key)) {
                    const existingList = this.typeWithSubtypesMap.get(key);
                    // existingList.push(item.docDetName);
                    this.typeWithSubtypesMap.set(key, [...existingList, item.docDetName]);
                } else {
                    // If the key doesn't exist, create a new list with the value
                    this.typeWithSubtypesMap.set(key, [item.docDetName]);
                }
                console.log('files from child is 44 ', this.typeWithSubtypesMap);
            });

            this.docId = this.lstOfFiles[0].docId;
        }
        // let searchDoc = this.lstOfFiles.find((doc) => doc.docDetName.toLowerCase() == this.docName.toLowerCase() && doc.docDetTypetoLowerCase() == this.docType.toLowerCase());
        // if (!searchDoc) {
        //     this.showUpload = true;
        // }

    }

    handleAddDocClick() {
        console.log('handleAddDocClick clicked with docId  parent', this.referedDocLink);
        // let child = this.template.querySelector('c-upload-docs-container');
        // child.addDocToExistingFile(this.referedDocLink);
        this.showSpinner = true;
        this.showAddDoc = false;
        addAppkycDd({ applicantId: this.applicantId, loanAppId: this.loanAppId, docCategory: this.catValue, docType: this.docType, docSubType: this.docName, linkedEntityId: this.referedDocLink })
            .then((result) => {
                this.showSpinner = false;
                this.docName = "";
                this.docType = "";
                this.refreshDocTable();

                console.log('DocumantDetail And AppKyc  Created   ', result);
            })
            .catch((err) => {
                this.showSpinner = false;
                this.showToast("Error", "error", err);
                console.log(" createDocumentDetailRecord error===", err);
            });
    }


    spinnerStatus(event) {
        console.log('spinner value ', event.detail);
        this.showSpinner = event.detail;
    }
    fromUploadDocsContainer(event) {
        console.log('event after uplaoding is ', event.detail);
        this.showAvailable = false;
        let docIdToUpdate = event.detail.docDetailId;
        console.log('docIdToUpdate 2656' + JSON.stringify(docIdToUpdate));
        if (this.appAsserId) {
            let obj = {
                sobjectType: "DocDtl__c",
                Id: docIdToUpdate,
                ApplAsset__c: this.appAsserId
            }
            this.upsertIntRecord(obj);
            // this.checkValidityOfDocument();
        } else {
            this.refreshDocTable();
        }

    }
    @track docId
    upsertIntRecord(obj) {
        let newArray = [];
        if (obj) {
            newArray.push(obj);
        }
        if (newArray) {
            upsertMultipleRecord({ params: newArray })
                .then((result) => {
                    console.log('Result after Updating Document Detail ', JSON.stringify(result));
                    this.docId = result[0].Id;
                    let documentUplValue = new CustomEvent('documentid', { detail: this.docId });
                    this.dispatchEvent(documentUplValue);
                    // this.checkValidityOfDocument();
                    this.refreshDocTable();
                })
                .catch((error) => {
                    this.showSpinner = false;
                    console.log('Error In in updating Document Detail Record', error);
                });
        }
    }
    refreshDocTable() {
        this.showSpinner = false;
        let child = this.template.querySelector('c-uploded-document-display');
        child.handleFilesUploaded();

    }

    handlebuttonclicked(event) {
        let name = event.target.dataset.name;
        console.log('name selected is==>>>', name);
        // if (name == 'Return To RM') {
        //     let child = this.template.querySelector('c-uploded-document-display');
        //     child.handleReturntoRm();
        // }
        // if (name == 'File Acceptance') {
        //     let child = this.template.querySelector('c-uploded-document-display');
        //     child.handleFileAcceptance();
        // }
        if (name == 'Save Remarks') {
            let child = this.template.querySelector('c-uploded-document-display');
            child.updateRemarks();
        }
        this.saveRemarks();
    }

    
    get displayCpaRemarks() {
        if (this.stage && this.subStage && !this.isNotRm && !this.isNotCpa && this.stage === 'QDE' && this.currentSubStage === 'DSA Data Entry'&& this.currentSubStage === 'Additional Data Entry') {
            return false;  // Don't display CPA remarks when the substage is 'DSA Data Entry'
        } else {
            return true;  // Display CPA remarks for other substages
        }
    }   

    get disableCpaRemarks() {
       // if (this.stage && this.subStage  && this.stage === 'QDE' && this.currentSubStage === 'DSA Pre Login Query') {
            return (this.stage === 'QDE' && this.currentSubStage === 'DSA Pre Login Query');
     //   }
       
    }
    get disableRMRemarks() {
        if (this.hasEditAccess && this.stage && this.subStage && !this.isNotRm && this.stage === 'QDE' && (this.currentSubStage === 'RM Data Entry' || this.currentSubStage === 'Pre login Query')) {
            return false;
        }
        else {
            return true;
        }
    }

   
    
       

    get reqDocFlag() {
        console.log('stepper Name print  ', this.stepperName);

        if (this.stagenm && this.stagenm !== 'QDE' && this.stepperName == 'propertyDetails') {
            console.log('stage print if ', this.stagenm);
            return true;
        }
        else {
            console.log('stage print else', this.stagenm);
            return false;
        }
    }
    applicantRecordInfo;
    cpaRemarks;
    rmRemarks;
    isRemarksChanged = false;


    @wire(getRecord, {
        recordId: '$applicantId',
        fields: [CPA_REMARK_APLCNT_FIELD, RM_REMARK_APLCNT_FIELD]
    })
    applicantInfo(value) {
        this.applicantRecordInfo = value;
        let { error, data } = value;
        if (data) {
            this.cpaRemarks = data.fields.REMARK__c.value;
            this.rmRemarks = data.fields.RM_Remarks__c.value;
        }
        else {
            console.log('Error occured in applicant info ' + JSON.stringify(error));
        }
    }

    handleApplicantRemarks(event) {
        let dataField = event.target.dataset.fieldname;
        if (dataField === 'REMARK__c') {
            let strValCPA = event.target.value;
            this.cpaRemarks = strValCPA.toUpperCase();
        }

        if (dataField === 'RM_Remarks__c') {
            let strValRM = event.target.value;
            this.rmRemarks = strValRM.toUpperCase();
        }
        this.isRemarksChanged = true;

    }

    saveRemarks() {
        if (this.isRemarksChanged) {
            let applicantRecord = {};
            applicantRecord['Id'] = this.applicantId;
            applicantRecord['REMARK__c'] = this.cpaRemarks;
            applicantRecord['RM_Remarks__c'] = this.rmRemarks;
            applicantRecord.sobjectType = 'Applicant__c';
            let applicantUpsertData = {
                parentRecord: applicantRecord,
                ChildRecords: null,
                ParentFieldNameToUpdate: ''
            }

            upsertSobjDataWIthRelatedChilds({ upsertData: applicantUpsertData })
                .then(result => {
                    this.isRemarksChanged = false;
                    refreshApex(this.applicantRecordInfo);
                    this.showToast("Success", "success", this.label.UploadDocDisply_Remarks_SuccessMessage);
                }).catch(error => {
                    this.showToast("Error", "error", error.body.message);
                    console.log(error);
                });
        }
    }

    //LAK-9807 
    @track loanAppealStatus;
    @track relookData=[];
    fetchApplRelook() {
        let loanAppealType='Reject Relook'
        let loanAppealDetParams = {
          ParentObjectName: "LoanAppeal__c",
          ChildObjectRelName: "",
          parentObjFields: [
            "Id","Name","LoanAppl__c","Status__c","RecordType.Name","CreatedDate"
          ],
          childObjFields: [],
          queryCriteria: ' where LoanAppl__c = \'' + this.loanAppId + '\' AND RecordType.name = \'' + loanAppealType + '\' order by LastModifiedDate desc'
        };
        getSobjectDataNonCacheable({ params: loanAppealDetParams })
          .then((result) => {
            console.log(" RESULT CAPTURE DOCUMENTS FOR RELOOK DETAILS #163", result);
            this.relookData=result.parentRecords;
            if (
              result.parentRecords !== undefined &&
              result.parentRecords.length > 0
            ) {
             this.loanAppealStatus=result.parentRecords[0].Status__c;          
             console.log(" RESULT CAPTURE DOCUMENTS FOR RELOOK DETAILS #1410",  this.relookData);
            }
          })
          .catch((error) => {
            console.log(" ERROR IN CAPTURE DOCUMENTS FOR RELOOK DETAILS #1414", error);
          });
      }
    
}