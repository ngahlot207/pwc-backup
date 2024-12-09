import { LightningElement, api, track, wire } from 'lwc';

import { refreshApex } from '@salesforce/apex';
import deleteDocDet from "@salesforce/apex/FileUploadController.deleteDocDetail";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getDataWithChilds from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import { deleteRecord, updateRecord } from "lightning/uiRecordApi";
import deleteRec from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';
import deleteDocRecord from '@salesforce/apex/DocumentDetailController.deleteDocDetWithCdl';
import getSobjectDataNonCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable';
import APPALLDOCNAMES_FIELD from "@salesforce/schema/ApplBanking__c.AllDocumentNames__c";
import AVAI_IN_FILE_FIELD from "@salesforce/schema/ApplBanking__c.FileAvalbl__c";
import getDataWithoutCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataWithoutCacheable';
import BankingDetails_ApplicantBanking_ErrorMessage from '@salesforce/label/c.BankingDetails_ApplicantBanking_ErrorMessage';
import APPID_FIELD from "@salesforce/schema/ApplBanking__c.Id";
import DOCDETAIL_FIELD from "@salesforce/schema/ApplBanking__c.DocumentDetail__c";
import { NavigationMixin } from "lightning/navigation";
import updateData from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import getData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import formFactorPropertyName from "@salesforce/client/formFactor";
import getDataForFilterChild from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithFilterRelatedRecords';
import upsertMultipleRecord from "@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord";
import createSMSTask from "@salesforce/apex/PerfiosGenerateLinkResponseProcessor.createSMSTask";

// Custom labels
import BankDataTable_updateAcc_ErrorMessage from '@salesforce/label/c.BankDataTable_updateAcc_ErrorMessage';
import BankDataTable_SepMonLimitReq_Error from '@salesforce/label/c.BankDataTable_SepMonLimitReq_Error';
import BankDataTable_periodOfBankingReq_Error from '@salesforce/label/c.BankDataTable_periodOfBankingReq_Error';
import BankDataTable_LimitReq_Error from '@salesforce/label/c.BankDataTable_LimitReq_Error';
import BankDataTable_PendingStatus_ErrorMessage from '@salesforce/label/c.BankDataTable_PendingStatus_ErrorMessage';
import BankDataTable_perfiosStarted_Success from '@salesforce/label/c.BankDataTable_perfiosStarted_Success';
import BankDataTable_SalaryAcc_Error from '@salesforce/label/c.BankDataTable_SalaryAcc_Error';
import BankDataTable_InstitutionID_Error from '@salesforce/label/c.BankDataTable_InstitutionID_Error';
import BankDataTable_NoFileInititatePer_Error from '@salesforce/label/c.BankDataTable_NoFileInititatePer_Error';
import showAllDetailsNoFileError from '@salesforce/label/c.showAllDetailsNoFileError';
import Id from "@salesforce/user/Id";
export default class BankDataTable extends NavigationMixin(LightningElement) {
    label = {
        BankDataTable_updateAcc_ErrorMessage,
        BankDataTable_SepMonLimitReq_Error,
        BankDataTable_periodOfBankingReq_Error,
        BankDataTable_LimitReq_Error,
        BankDataTable_PendingStatus_ErrorMessage,
        BankDataTable_perfiosStarted_Success,
        BankingDetails_ApplicantBanking_ErrorMessage,
        BankDataTable_SalaryAcc_Error,
        BankDataTable_NoFileInititatePer_Error,
        BankDataTable_InstitutionID_Error,
        showAllDetailsNoFileError
    }
    @api layoutSize
    @api hasEditAccess;
    @track paramsforOwner
    @track _loanApplicantId;
    @api get loanApplicantId() {
        return this._loanApplicantId;
    }
    set loanApplicantId(value) {
        this._loanApplicantId = value;
        console.log('this._loanApplicantId' + this._loanApplicantId)
        this.paramsforOwner = {
            ParentObjectName: 'LoanAppl__c',
            ChildObjectRelName: 'Applicant_Banking1__r',
            parentObjFields: ['Id', 'SubStage__c', 'Stage__c', 'OwnerId'],
            childObjFields: ['Id', 'Appl__c', 'eNACHFeasible__c', 'SFDC_Bank_Master_Name__c', 'NACHFeasible__c', 'SFDCBankMaster__r.BankName__c', 'LoanAppl__c', 'IFSC_Code__c', 'Limit__c', 'Name_of_the_Primary_Account_Holder_s__c', 'OtherBankName__c', 'AccountType__c', 'FileType__c', 'SalaryAccount__c', 'DocumentDetail__c', 'BankName__c', 'BankId__c', 'JointAccountHoldersName__c', 'AC_No__c', 'IsThereChangeInLimitDuringThePeri__c', 'AverageLimitDuringThePeriod__c', 'LatestMonthForWhichBankStatementIs__c', 'PeriodOfBankingStart__c', 'PeriodOfBankingEnd__c', 'Bank_City__c', 'Repayment_bank_A_c__c', 'Bank_Branch__c', 'MICR_Code__c', 'Appl__r.CustProfile__c', 'eNACH_feasible__c'],
            queryCriteria: ' where Id= \'' + this._loanApplicantId + '\''
        }
    }
    @api mode = false;
    @api bankCreditFlag;
    @track modeDis = true;
    @track isModalOpen = false;
    @track docIdToDelete;
    @track cdlIdToDelete;
    @track removeModalMessage = "Do you really want to delete this file.";
    @track showSpinner = false;
    @track applicantRecoId;
    @track disabledMode;
    @api loginAcceDate
    @api fileAcceptanceDate
    _stageOfLoanApp
    @track showSalaryAccount = false;
    @track _customerProfile;
    @api get customerProfile() {
        return this._customerProfile;
    }
    set customerProfile(value) {
        console.log('Loan App Id ! ' + value);
        this._customerProfile = value;
        if (this._customerProfile == 'SALARIED') {
            this.showSalaryAccount = true;
        } else {
            this.showSalaryAccount = false;
        }
        this.setAttribute("customerProfile", value);
    }

    @api captureAllDocuments = false;

    _custProfile
    @api get custProfile() {
        return this._custProfile;
    }
    set custProfile(value) {
        this._custProfile = value;
    }
    @api get stageOfLoanApp() {
        return this._stageOfLoanApp;
    }
    set stageOfLoanApp(value) {
        this._stageOfLoanApp = value
        if (this._stageOfLoanApp == 'QDE') {
            this.showAndIntegrationCol = false;
            this.showSpinner = false;
        } else {
            this.showAndIntegrationCol = true;
            this.showSpinner = false;
        }
    }

    @api get childData() {
        return this._childData;
    }
    set childData(value) {
        this._childData = [...value];
        this._childData = JSON.parse(JSON.stringify(this._childData))
        setTimeout(() => {
            this._childData.forEach((item, index) => {
                if (item.Initiate_Perfios_Status__c != 'Pending') {
                    console.log('item.Initiate_Perfios_Status__c' + item.Initiate_Perfios_Status__c)
                    item.isCanDis = this.hasEditAccess === false ? true : item.Source_Type__c == 'Fetch Online Perfios' ? true : false;
                    if (item.Initiate_Perfios_Status__c == 'Failure') {
                        item.FetchDis = this.hasEditAccess === false ? true : item.Source_Type__c == 'Fetch Online Perfios' ? false : true;
                    } else {
                        item.FetchDis = this.hasEditAccess === false ? true : item.Source_Type__c == 'Fetch Online Perfios' ? true : true;
                    }

                } else {
                    item.isCanDis = this.hasEditAccess === false ? true : true;
                    // item.FetchDis = this.hasEditAccess===false ? true : true;
                    item.FetchDis = this.hasEditAccess === false ? true : item.Source_Type__c == 'Fetch Online Perfios' ? false : true;
                }
                if (item.Source_Type__c == 'Fetch Online Perfios') {
                    item.UploadDis = this.hasEditAccess === false ? true : true;

                } else {
                    item.UploadDis = this.hasEditAccess === false ? true : false;
                }

                if (item.AllDocumentNames__c != null && item.AllDocumentNames__c != '' && item.AllDocumentNames__c !== 'undefined') {
                    item.isFileDis = false;
                } else {
                    item.isFileDis = true;
                }
                if(item.SFDC_Bank_Master_Name__c == 'OTHERS'){
                    item.SFDC_Bank_Master_Name__c=item.OtherBankName__c;
                }



            });
        }, 1500);


    }
    @api handleDisable() {
        this._childData.forEach((item, index) => {
            if (item.Initiate_Perfios_Status__c != 'Pending') {
                console.log('item.Initiate_Perfios_Status__c' + item.Initiate_Perfios_Status__c)
                item.isCanDis = this.hasEditAccess === false ? true : item.Source_Type__c == 'Fetch Online Perfios' ? true : false;
                if (item.Initiate_Perfios_Status__c == 'Failure') {
                    item.FetchDis = this.hasEditAccess === false ? true : item.Source_Type__c == 'Fetch Online Perfios' ? false : true;
                } else {
                    item.FetchDis = this.hasEditAccess === false ? true : item.Source_Type__c == 'Fetch Online Perfios' ? true : true;
                }

            } else {
                item.isCanDis = this.hasEditAccess === false ? true : true;
                item.FetchDis = this.hasEditAccess === false ? true : true;
            }
            if (item.Source_Type__c == 'Fetch Online Perfios') {
                item.UploadDis = this.hasEditAccess === false ? true : true;

            } else {
                item.UploadDis = this.hasEditAccess === false ? true : false;
            }
            if (item.AllDocumentNames__c != null && item.AllDocumentNames__c != '' && item.AllDocumentNames__c !== 'undefined') {
                item.isFileDis = false;
            } else {
                item.isFileDis = true;
            }
        });
    }


    _applicantBnkId;
    @api get applicantBnkId() {
        return this._applicantBnkId;
    }
    set applicantBnkId(value) {
        this._applicantBnkId = value

    }
    @track _applicantRecId;
    @api get applicantRecId() {
        return this._applicantRecId;
    }
    set applicantRecId(value) {
        this._applicantRecId = value
        //this.handleRecordIdChange(); 


    }
    @track _childData;
    @track lstAllFiles = [];
    @track formFactor = formFactorPropertyName;
    desktopBoolean = false;
    phoneBolean = false;
    showAndIntegrationCol = true;
    @api reqLoanAmount;
    @api assessedIncApp;
    perfiosDisabled = false
    /*get disableModeforPerfios() {
        return this.perfiosDisabled || this.disableMode;
    }*/
    disableModeforPerfios(row) {

    }
    connectedCallback() {
        console.log('JSON.stringify(this._childData)--->', JSON.stringify(this._childData));
        console.log('fileAcceptanceDate', this.fileAcceptanceDate);
        if (this.hasEditAccess === false) {
            this.disableMode = true;
        } else {
            this.disableMode = false;
        }

        console.log("this.getDataFromParent---->", this.childData);
        console.log("Form Factor Property Name ", this.formFactor);
        console.log("formFactorPropertyName ", formFactorPropertyName);
        if (this.formFactor == "Large") {
            this.desktopBoolean = true;
            this.phoneBolean = false;
        } else if (this.formFactor == "Small") {
            this.desktopBoolean = false;
            this.phoneBolean = true;
        } else {
            this.desktopBoolean = false;
            this.phoneBolean = true;
        }
        this.showSpinner = true;
        setTimeout(() => {
            console.log('#######', this.stageOfLoanApp + ' $$$$$$$' + this.loginAcceDate);
            if (this._stageOfLoanApp == 'QDE') {
                this.showAndIntegrationCol = false;
                this.showSpinner = false;
            } else {
                this.showAndIntegrationCol = true;
                this.showSpinner = false;
            }
        }, 1000);
        this._childData.forEach((item, index) => {
            console.log('itemmm' + item.Initiate_Perfios_Status__c)
            if (item.Initiate_Perfios_Status__c != 'Pending') {

                item.isCanDis = this.hasEditAccess === false ? true : false;
                // console.log('iscancel',item.isCanDis);
            } else {
                // console.log('inelseeee')
                item.isCanDis = this.hasEditAccess === false ? true : true;
            }

            if (item.AllDocumentNames__c != null && item.AllDocumentNames__c != '' && item.AllDocumentNames__c !== 'undefined') {
                // item.isFileDis = this.hasEditAccess===false?true:false;
                item.isFileDis = false;
                console.log('inifffffff');
            } else {
                console.log('inelseeeeee');
                item.isFileDis = true
                // item.isFileDis = this.hasEditAccess===false ? true : true;
            }


        });
    }
    bankingRec;
    @track bankingDetailRecord;
    handleDocumentDelete(event) {
        console.log('handle document delete12333-->');
        let bankingDetailRecord = this._childData[event.target.dataset.index];
        this.bankingDetailRecord = bankingDetailRecord;
        this.bankingRec = bankingDetailRecord;
        this.docIdToDelete = bankingDetailRecord.Id;
        this.cdlIdToDelete = bankingDetailRecord.DocumentDetail__c;
        this.isModalOpen = true;
        console.log('this.bankingRecthis.bankingRec', JSON.stringify(this.bankingRec))

    }


    @track toShowappliBankData = false;
    @api toCloseViewButtonData() {
        console.log('toCloseViewButtonData');
        this.toShowappliBankData = false;
    }

    handleRemoveRecord() {
        console.log('cdlIdToDelete in popo yes', this.cdlIdToDelete);
        console.log('docIdToDelete in popo up yes ', this.docIdToDelete);
        this.showSpinner = true;
        this.toShowappliBankData = false;
        if (this.bankingDetailRecord.DocumentDetail__r && this.bankingDetailRecord.DocumentDetail__r.RCUInitiated__c) {
            let tempApplArr = []
            let objApp = {};
            objApp.sobjectType = 'ApplBanking__c';
            objApp.Id = this.docIdToDelete;
            objApp.IsDeleted__c = true;
            objApp.DelDateTime__c = new Date().toISOString();;
            objApp.DeletedBy__c = Id;
            tempApplArr.push(objApp);

            let objDoc = {};
            objDoc.sobjectType = 'DocDtl__c';
            objDoc.Id = this.cdlIdToDelete;
            objDoc.IsDeleted__c = true;
            objDoc.DelDateTime__c = new Date().toISOString();;
            objDoc.DeletedBy__c = Id;
            tempApplArr.push(objDoc);
            if (tempApplArr && tempApplArr.length > 0) {
                this.upsertDataApplBanking(tempApplArr);
            }

        } else {
            let docList = [];
            let docRecord1 = {};
            docRecord1['sobjectType'] = 'ApplBanking__c';
            docRecord1['Id'] = this.docIdToDelete;
            docList.push(docRecord1);
            if(this.cdlIdToDelete){
                let docRecord2 = {};
                docRecord2['sobjectType'] = 'DocDtl__c';
                docRecord2['Id'] = this.cdlIdToDelete;
                docList.push(docRecord2);
            }
            
            deleteRec({ rcrds: docList })
                .then(() => {
                    this.showSpinner = false;
                    console.log('deletedBanking-->');
                    const deleteEvent = new CustomEvent('delete', {
                        detail: this.cdlIdToDelete
                    });
                    this.dispatchEvent(deleteEvent);
                    this.isModalOpen = false;
                })
                .catch((error) => {
                    console.error('error on deleting', error)
                    this.showSpinner = false;
                });
        }
    }

    upsertDataApplBanking(obj) {
        if (obj) {
            console.log('Appl Banking Records Update ##2891', obj);
            upsertMultipleRecord({ params: obj })
                .then(result => {
                    console.log('Appl Banking and Doc Details  Records updated ##2895', result);
                    this.showToastMessage('Success', 'Appl Banking & Doc Details Deleted Successfully', 'success', 'sticky');
                    const deleteEvent = new CustomEvent('delete', {
                        detail: this.cdlIdToDelete
                    });
                    this.dispatchEvent(deleteEvent);
                    this.isModalOpen = false;
                    this.showSpinner = false;

                })
                .catch(error => {
                    this.showSpinner = false;
                    console.error('Line no RCU DETAILS ##2538', error)
                })
        }
    }
    isCloseModal() {
        console.log('isModalOpen ', this.isModalOpen);
        this.isModalOpen = false;
    }

    /*deleteDocDet(docIdToDelete) {
         console.log('docIdToDelete ', docIdToDelete)
         deleteDocDet({ docId: docIdToDelete })
             .then((result) => {
                 console.log(result);
                 this.handleFilesUploaded();
             })
             .catch((error) => { });
         this.isModalOpen = false;
     }*/

    cvId;
    contDocType;
    contDocId;
    showModalForFilePre = false;
    @track documentDetailId
    @track contVersDataList;
    @track hasDocumentId = false
    handleDocumentView(event) {
        // this.openModal();
        // console.log("view button called");
        this.hasDocumentId = true
        let bankingDetailRecord = this._childData[event.target.dataset.index];
        console.log('bankingDetailRecord>>>>' + JSON.stringify(bankingDetailRecord));
        let contentVersionId = bankingDetailRecord.DocumentDetail__r.Content_Document_Id__c;
        this.documentDetailId = bankingDetailRecord.DocumentDetail__r.Id
        console.log('documentDetailId' + this.documentDetailId)
        console.log('this.documentIdYes' + this.hasDocumentId)
        this.showModalForFilePre = true


    }
    handleCloseModalEvent(event) {
        this.showModalForFilePre = false;
    }



    handleInputChange(event) {
        event.preventDefault();
        try {
            let bankingDetailRecord = Object.assign({}, this._childData[event.target.dataset.index]);
            let isSalaryAccount = false;

            if (event.target.checked) {
                var temp1 = bankingDetailRecord;
                console.log('temp1.AccountType__c' + temp1.AccountType__c)
                if (temp1.AccountType__c == 'OVERDRAFT' || temp1.AccountType__c == 'CC' || temp1.AccountType__c == 'JOINT') {
                    event.target.checked = false;
                    this.showToastMessage('Error', this.label.BankDataTable_SalaryAcc_Error, 'error', 'sticky');
                } else {
                    for (var i = 0; i < this._childData.length; i++) {

                        if (this._childData[i].SalaryAccount__c) {
                            isSalaryAccount = true;
                        }
                    }
                    if (isSalaryAccount) {
                        event.target.checked = false;
                        this.showToastMessage('Error', this.label.BankDataTable_updateAcc_ErrorMessage, 'error', 'sticky');

                        // this.showToast("Error", "error", "You can only update one bank account as salary account.");
                        return;
                    } else {
                        var temp = bankingDetailRecord;
                        temp.SalaryAccount__c = true;
                        bankingDetailRecord = { ...temp };

                    }
                }



            } else {
                bankingDetailRecord.SalaryAccount__c = false;
            }


            var tempArray = [...this._childData];
            tempArray[event.target.dataset.index] = bankingDetailRecord;
            this._childData = [...tempArray];

            //trigger event to parent
            const bankdetailupdate = new CustomEvent('bankdetailupdate', {
                detail: this._childData
            });
            this.dispatchEvent(bankdetailupdate);

            //this._childData[event.target.dataset.index] = bankingDetailRecord;
        } catch (error) {
            console.log(error);
        }

    }
    //showModal = false;

    openModal() {
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
    }

    showToast(title, variant, message) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message
        });
        this.dispatchEvent(evt);
        this.showSpinner = false;
    }


    @track toShowAllDetails = false;
    @track toEditAllDetails = false;
    handleShowAllDetails(event) {
        console.log('this.reqLoanAmount===>', this.reqLoanAmount);
        console.log('this.hasEditAccess===>', this.assessedIncApp);
        let bankingDetailRecord = this._childData[event.target.dataset.index];
        this.applicantRecoId = bankingDetailRecord.Id;
        this.toEditAllDetails = true;
        this.toShowAllDetails = false;
        this.toShowappliBankData = this.toShowappliBankData ? false : true;
        console.log('this.applicantRecoId@@@@  ' + this.applicantRecoId);

        var selectedEvent = new CustomEvent('closeconsolidatetable', {
            detail: this.toShowappliBankData
        });
        this.dispatchEvent(selectedEvent);
        if (this.template.querySelector('c-show-all-bank-details') != null) {

            this.template.querySelector('c-show-all-bank-details').toRefreshApexMethod();
        }


    }

    params;
    parentRecord
    ChildRecsAppliBnkSumm
    _wiredApplicantBanking
    @wire(getDataWithChilds, { params: '$params' })
    loadApplicantBanking(wiredApplicantBanking) {
        const { data, error } = wiredApplicantBanking;
        this._wiredApplicantBanking = wiredApplicantBanking;
        this.parentRecord = {}

        if (data) {
            this.parentRecord = JSON.parse(JSON.stringify(data.parentRecord));
            if (data.ChildReords && data.ChildReords != undefined) {
                this.ChildRecsAppliBnkSumm = JSON.parse(JSON.stringify(data.ChildReords));
            } else {
                this.ChildRecsAppliBnkSumm = [];
            }
            console.log('this.parentRecord.allDocumentName' + this.parentRecord.AllDocumentNames__c)
            if (this.perfiosInitiate && this.checkDocumentIsPresent() && this.checkDocumentIspassword()) {
                if (this.perfiosInitiate && this.checkInitiatePerfiosStatus() && this.checkInstitutionIdForBnk()) {
                    if (this.checkPerBnkForJoint()) {
                        let fieldsOfIntMess = {};
                        fieldsOfIntMess['sobjectType'] = 'IntgMsg__c';
                        fieldsOfIntMess['Name'] = 'Initiate Perfios'; //serviceName;//'KYC OCR'
                        fieldsOfIntMess['BU__c'] = 'HL / STL';
                        fieldsOfIntMess['IsActive__c'] = true;
                        fieldsOfIntMess['Svc__c'] = 'Initiate Transaction'; //serviceName;
                        fieldsOfIntMess['Status__c'] = 'New';
                        fieldsOfIntMess['Outbound__c'] = true;
                        fieldsOfIntMess['RefObj__c'] = 'DocDtl__c';
                        fieldsOfIntMess['ParentRefObj__c'] = 'ApplBanking__c';
                        fieldsOfIntMess['ParentRefId__c'] = this.bankingDetailRecord.Id;
                        fieldsOfIntMess['RefId__c'] = this.bankingDetailRecord.DocumentDetail__c;

                        let ChildRecords = [];
                        let upsertData = {
                            parentRecord: fieldsOfIntMess,
                            ChildRecords: ChildRecords,
                            ParentFieldNameToUpdate: ''
                        }
                        console.log('record of message createddddd')
                        updateData({ upsertData: upsertData })
                            .then(result => {
                                console.log('resultresultresultresultresult' + JSON.stringify(result))
                                this.showToastMessage('Success', this.label.BankDataTable_perfiosStarted_Success, 'success', 'sticky');
                                fieldsOfIntMess = {};
                                let bankingDetailRecord = this._childData[this.indexOfPerfios];
                                var temp = bankingDetailRecord;
                                temp.isCanDis = true;
                                bankingDetailRecord = { ...temp };
                                var tempArray = [...this._childData];
                                tempArray[this.indexOfPerfios] = bankingDetailRecord;
                                this._childData = [...tempArray];

                                const deleteEvent = new CustomEvent('fileupload', {
                                });
                                this.dispatchEvent(deleteEvent);


                            }).catch(error => {

                                console.log(error);
                            })

                    } else {
                        console.log('record of message nottt createddddd')
                    }
                }
            }



        } else if (error) {
            console.log(error);
        }
    }
    checkDocumentIsPresent() {
        if (typeof this.parentRecord.AllDocumentNames__c !== 'undefined') {
            return true;
        } else {
            this.showToastMessage('Error', this.label.BankDataTable_NoFileInititatePer_Error, 'error', 'sticky');
            return false;
        }
    }
    checkDocumentIspassword() {
        if (this.parentRecord.Is_Statement_password_protected__c == 'No') {
            return true;
        } else if (this.parentRecord.Is_Statement_password_protected__c == 'Yes' && typeof this.parentRecord.Password__c !== 'undefined') {
            return true;
        }
        else {
            this.showToastMessage('Error', 'Please fill password of the document for Initiate Perfios.', 'error', 'sticky');
            return false;
        }
    }
    toRefreshApex(event) {
        console.log('toRefreshApex')
        this.perfiosInitiate = false
        var params = {
            ParentObjectName: 'ApplBanking__c',
            ChildObjectRelName: 'Applicant_Banking_Detail__r',
            parentObjFields: ['Id', 'AllDocumentNames__c', 'Password__c', 'Is_Statement_password_protected__c', 'SFDCBankMaster__r.InstitutionId__c', 'Appl__c', 'Initiate_Perfios_Status__c', 'AccountOpenDate__c', 'ConsideredForABBProgram__c', 'Bank_Code__c', 'MICRId__c', 'PDC_by_Name__c', 'eNACHFeasible__c', 'SFDC_Bank_Master_Name__c', 'NACHFeasible__c', 'SFDCBankMaster__r.BankName__c', 'LoanAppl__c', 'IFSC_Code__c', 'Limit__c', 'Name_of_the_Primary_Account_Holder_s__c', 'OtherBankName__c', 'AccountType__c', 'FileType__c', 'SalaryAccount__c', 'DocumentDetail__c', 'BankName__c', 'BankId__c', 'JointAccountHoldersName__c', 'AC_No__c', 'IsThereChangeInLimitDuringThePeri__c', 'AverageLimitDuringThePeriod__c', 'LatestMonthForWhichBankStatementIs__c', 'PeriodOfBankingStart__c', 'PeriodOfBankingEnd__c', 'Bank_City__c', 'Repayment_bank_A_c__c', 'Bank_Branch__c', 'MICR_Code__c', 'Appl__r.CustProfile__c', 'eNACH_feasible__c'],
            childObjFields: ['ApplBanking__c', 'MonthlyLimit__c', 'Utilization__c', 'Id', 'Name', 'Month__c', 'Year__c', 'ValueSummationCredit__c', 'ValueSummationDebit__c', 'CountofCredit__c', 'CountofDebit__c', 'InwardReturnsCount__c', 'OutwardReturnsCount__c', 'StopPaymentCount__c', 'MinBalanceCharges__c', 'BalanceAt_1st__c', 'BalanceAt_5th__c', 'BalanceAt_10th__c', 'BalanceAt_15th__c', 'BalanceAt_20th__c', 'BalanceAt_25th__c', 'AverageBankBalance__c'],
            queryCriteria: ' where Id= \'' + this.applicantRecoId + '\''
        }
        this.params = params
        refreshApex(this._wiredApplicantBanking);
        const toRefreshApex = new CustomEvent('torefreshapex', {
        });
        console.log('@@@@>>>>>bforedispatchbankdatatable')
        this.dispatchEvent(toRefreshApex);
    }
    checkInitiatePerfiosStatus() {
        // console.log('this.parentRecord.Initiate_Perfios_Status__c'+this.parentRecord.Initiate_Perfios_Status__c)
        if (this.parentRecord.Initiate_Perfios_Status__c == 'Pending') {
            this.showToastMessage('Error', this.label.BankDataTable_PendingStatus_ErrorMessage, 'error', 'sticky');
            return false
        } else {
            return true;
        }
    }

    checkInstitutionIdForBnk() {
        if (this.parentRecord.FileType__c == 'Scanned Documents') {
            if (this.parentRecord.SFDCBankMaster__r.InstitutionId__c != '' && this.parentRecord.SFDCBankMaster__r.InstitutionId__c !== 'undefined' && this.parentRecord.SFDCBankMaster__r.InstitutionId__c != null) {
                console.log('>>>>>>>>' + this.parentRecord.SFDCBankMaster__r.InstitutionId__c)
                return true
            } else {
                this.showToastMessage('Error', this.label.BankDataTable_InstitutionID_Error, 'error', 'sticky');
                return false
            }
        } else {
            return true
        }

    }
    checkPerBnkForJoint() {
        console.log('>>>>>>>1')
        if (this.parentRecord.PeriodOfBankingStart__c != '' && this.parentRecord.PeriodOfBankingStart__c !== 'undefined' && this.parentRecord.PeriodOfBankingStart__c != null && this.parentRecord.PeriodOfBankingEnd__c != '' && this.parentRecord.PeriodOfBankingEnd__c !== 'undefined' && this.parentRecord.PeriodOfBankingEnd__c != null) {
            if (this.parentRecord.AccountType__c == 'CC' || this.parentRecord.AccountType__c == 'OVERDRAFT') {
                console.log('>>>>>>>>')
                if (this.parentRecord.IsThereChangeInLimitDuringThePeri__c == 'Yes') {
                    var count = 0;
                    console.log('this.ChildRecsAppliBnkSumm' + this.ChildRecsAppliBnkSumm.length)
                    for (const record of this.ChildRecsAppliBnkSumm) {
                        if (record.MonthlyLimit__c != null && record.MonthlyLimit__c != '' && record.MonthlyLimit__c !== 'undefined') {

                        } else {
                            count++;
                        }
                    }
                    console.log('countcountcountcount' + count)
                    if (count > 0) {
                        this.showToastMessage('Error', this.label.BankDataTable_SepMonLimitReq_Error, 'error', 'sticky');
                        return false
                    } else {
                        return true
                    }

                } else {
                    console.log('innnnnnNOOOOOOOOO')
                    if (this.parentRecord.Limit__c != '' && this.parentRecord.Limit__c !== 'undefined' && this.parentRecord.Limit__c != null) {
                        return true
                    } else {
                        this.showToastMessage('Error', this.label.BankDataTable_LimitReq_Error, 'error', 'sticky');
                        return false
                    }

                }
            } else {
                return true
            }

        } else {
            console.log('iiiiii')
            this.showToastMessage('Error', this.label.BankDataTable_periodOfBankingReq_Error, 'error', 'sticky');
            return false
        }
    }

    bankingDetailRecord;
    perfiosInitiate = false
    indexOfPerfios;
    handleForIntegration(event) {
        this.toShowappliBankData = false
        this.perfiosInitiate = true
        this.bankingDetailRecord = this._childData[event.target.dataset.index];
        this.indexOfPerfios = event.target.dataset.index;
        console.log('this.indexOfPerfios' + this.indexOfPerfios);
        this.applicantRecoId = this.bankingDetailRecord.Id;
        var params = {
            ParentObjectName: 'ApplBanking__c',
            ChildObjectRelName: 'Applicant_Banking_Detail__r',
            parentObjFields: ['Id', 'Is_Statement_password_protected__c', 'Password__c', 'AllDocumentNames__c', 'SFDCBankMaster__r.InstitutionId__c', 'Appl__c', 'Initiate_Perfios_Status__c', 'AccountOpenDate__c', 'ConsideredForABBProgram__c', 'Bank_Code__c', 'MICRId__c', 'PDC_by_Name__c', 'eNACHFeasible__c', 'SFDC_Bank_Master_Name__c', 'NACHFeasible__c', 'SFDCBankMaster__r.BankName__c', 'LoanAppl__c', 'IFSC_Code__c', 'Limit__c', 'Name_of_the_Primary_Account_Holder_s__c', 'OtherBankName__c', 'AccountType__c', 'FileType__c', 'SalaryAccount__c', 'DocumentDetail__c', 'BankName__c', 'BankId__c', 'JointAccountHoldersName__c', 'AC_No__c', 'IsThereChangeInLimitDuringThePeri__c', 'AverageLimitDuringThePeriod__c', 'LatestMonthForWhichBankStatementIs__c', 'PeriodOfBankingStart__c', 'PeriodOfBankingEnd__c', 'Bank_City__c', 'Repayment_bank_A_c__c', 'Bank_Branch__c', 'MICR_Code__c', 'Appl__r.CustProfile__c', 'eNACH_feasible__c'],
            childObjFields: ['ApplBanking__c', 'MonthlyLimit__c', 'Utilization__c', 'Id', 'Name', 'Month__c', 'Year__c', 'ValueSummationCredit__c', 'ValueSummationDebit__c', 'CountofCredit__c', 'CountofDebit__c', 'InwardReturnsCount__c', 'OutwardReturnsCount__c', 'StopPaymentCount__c', 'MinBalanceCharges__c', 'BalanceAt_1st__c', 'BalanceAt_5th__c', 'BalanceAt_10th__c', 'BalanceAt_15th__c', 'BalanceAt_20th__c', 'BalanceAt_25th__c', 'AverageBankBalance__c'],
            queryCriteria: ' where Id= \'' + this.applicantRecoId + '\''
        }
        this.params = params
        refreshApex(this._wiredApplicantBanking);

    }

    showToastMessage(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant,
            mode
        });
        this.dispatchEvent(evt);
    }
    @track openFileUploadModel = false;
    @track hideAttachButton;
    @track fileSizeMsz
    @track MAX_FILE_SIZE = 25000000;
    @track documentDetaiId
    @track allFilesNames;
    @track oldFilesName
    @track files
    @track applicantBankingId
    @api docName = 'Bank Statement';
    @api docType = 'Bank Statement';
    @api docCategory = 'Banking Documents';
    handleFileUpload(event) {
        let appliBnkRec = this._childData[event.target.dataset.index];
        console.log('appliBnkRec' + JSON.stringify(appliBnkRec))
        if (typeof appliBnkRec.AllDocumentNames__c !== 'undefined') {
            this.oldFilesName = appliBnkRec.AllDocumentNames__c
        } else {
            this.oldFilesName = ''
        }
        this.documentDetaiId = appliBnkRec.DocumentDetail__c
        console.log('this.documentDetaiId' + this.documentDetaiId)
        this.openFileUploadModel = true
        this.applicantBankingId = appliBnkRec.Id

        if (appliBnkRec.FileType__c == 'ePDF') {
            this.allowedFilFormat = ".pdf";
            this.fileTypeError = 'Allowed File Types are : pdf'
            this.fileSizeMsz = "Maximum file size should be 25Mb. Allowed file type is .pdf only";
        } else {
            this.allowedFilFormat = ".docx, .pdf, .doc ";
            this.fileTypeError = 'Allowed File Types are : pdf, doc, docx'
            this.fileSizeMsz = "Maximum file size should be 25Mb. Allowed file types are .doc, .docx, .pdf";
        }

        this.hideAttachButton = false;

    }
    parentFileChange(event) {
        this.files = event.detail.fileList
        console.log('in parentFileChange' + JSON.stringify(this.files))
        var allFilesNames = '';
        for (const record of this.files) {
            console.log('recordrecordrecord' + record.name)
            allFilesNames += record.name + ', '
        }
        this.allFilesNames = allFilesNames.replace(/,\s*$/, "");
        this.allFilesNames = this.allFilesNames + ', ' + this.oldFilesName
    }
    closeModal(event) {
        this.openFileUploadModel = false
    }
    fromUploadDocsContainer(event) {
        this.openFileUploadModel = false
        var documentDeatilData = event.detail
        const fields = {};
        fields[APPID_FIELD.fieldApiName] = this.applicantBankingId;
        fields[DOCDETAIL_FIELD.fieldApiName] = documentDeatilData.docDetailId;
        fields[APPALLDOCNAMES_FIELD.fieldApiName] = this.allFilesNames

        // Add this line for LAK-6320
        fields[AVAI_IN_FILE_FIELD.fieldApiName] = false;

        const recordInput = { fields };
        console.log('recordInput--->6666', recordInput);
        updateRecord(recordInput)
            .then((result) => {
                console.log('resultresultresult')

                const deleteEvent = new CustomEvent('fileupload', {
                });
                this.dispatchEvent(deleteEvent);
                console.log('>>>>>>>>>>>>>>>>')
                this.perfiosInitiate = false;
                refreshApex(this._wiredApplicantBanking);
                if (this.template.querySelector('c-show-all-bank-details') != null) {

                    this.template.querySelector('c-show-all-bank-details').toRefreshApexMethod();
                }
                this.openFileUploadModel = false

            })
            .catch(error => {
                console.log('inerrrprrr')
                this.showToast("Error", "error", this.label.BankingDetails_ApplicantBanking_ErrorMessage + error);
                console.log(error);
                //this.showToast('Error!!', error.body.message, 'error', 'dismissable');
            });
    }
    // to add download file column in the table 
    _wiredApplicantRecData;
    downloadFileDis
    userId = Id;
    @wire(getDataWithChilds, { params: '$paramsforOwner' })
    applicanRecorDataBanking(wiredApplicantRecData) {
        const { data, error } = wiredApplicantRecData;
        this._wiredApplicantRecData = wiredApplicantRecData;
        if (data) {
            const parentRecord = JSON.parse(JSON.stringify(data.parentRecord));
            console.log('this.userId' + this.userId);
            console.log('this.parentRecord.OwnerId' + parentRecord.OwnerId);
            this.downloadFileDis = this.userId != parentRecord.OwnerId ? true : false;
        } else if (error) {
            console.log('inerrrporrr' + JSON.stringify(error))
        }
    }
    fileToDownload;
    parentRecsOfConVer
    ContentDocumentId
    DocDetailRecLat
    handlePerfiosDownloadFile(event) {

        let bankingDetailRecord = this._childData[event.target.dataset.index];
        console.log('inerrrporrr>>>>>>' + JSON.stringify(bankingDetailRecord))
        this.applicantRecoId = bankingDetailRecord.Id;
        let applicantRec=bankingDetailRecord.Appl__c;
        let paramForLatDoc;
        if(bankingDetailRecord.Source_Type__c=='Account Aggregator'){
            paramForLatDoc = {
                ParentObjectName: 'DocDtl__C',
                ChildObjectRelName: null,
                parentObjFields: ['Id', 'DocSubTyp__c', 'DocCatgry__c', 'IsLatest__c'],
                childObjFields: [],
                queryCriteria: ' where Appl__c= \'' + applicantRec + '\' AND DocCatgry__c = \'Perfios Report\' AND DocSubTyp__c = \'Perfios Account Aggregator Report\' AND IsLatest__c  = True'
            }
        }else{
            paramForLatDoc = {
                ParentObjectName: 'DocDtl__C',
                ChildObjectRelName: null,
                parentObjFields: ['Id', 'ApplBanking__c', 'DocCatgry__c', 'IsLatest__c'],
                childObjFields: [],
                queryCriteria: ' where ApplBanking__c= \'' + this.applicantRecoId + '\' AND DocCatgry__c = \'Perfios Report\' AND IsLatest__c  = True'
            }
        }
        getDataWithoutCacheable({ params: paramForLatDoc })
            .then((data) => {
                console.log('inifffffffffff')
                console.log('test' + JSON.stringify(data))
                if (data.length > 0 && typeof data[0].parentRecord.Id !== 'undefined') {
                    this.DocDetailRecLat = JSON.parse(JSON.stringify(data[0].parentRecord));
                    console.log('this.DocDetailRecLat' + JSON.stringify(this.DocDetailRecLat))
                    debugger
                    var docDetailId = this.DocDetailRecLat.Id
                    let params = {
                        ParentObjectName: 'ContentDocumentLink',
                        ChildObjectRelName: '',
                        parentObjFields: ['ContentDocumentId', 'LinkedEntityId'],
                        childObjFields: [],
                        queryCriteria: ' where LinkedEntityId= \'' + docDetailId + '\''
                    }
                    getSobjectDataNonCacheable({ params: params })
                        .then((data) => {
                            console.log('test11' + JSON.stringify(data))
                            var docDeailReConDoc = JSON.parse(JSON.stringify(data.parentRecords));
                            console.log('test12' + JSON.stringify(docDeailReConDoc))
                            var listOfContentDocumentIds = []
                            for (const record of docDeailReConDoc) {
                                console.log('test12' + JSON.stringify(record))
                                listOfContentDocumentIds.push(record.ContentDocumentId);
                            }
                            console.log('test12' + listOfContentDocumentIds)
                            if (listOfContentDocumentIds.length > 0) {
                                this.contentVerRecords(listOfContentDocumentIds)
                            }
                        })
                        .catch(error => {
                        });
                } else {
                    console.log('indddddddd')
                    this.fileToDownload = false
                    this.showToastMessage('Error', this.label.showAllDetailsNoFileError, 'error', 'sticky');

                }
            })
            .catch(error => {
                console.log('errrrrr' + JSON.stringify(error))
                this.showToastMessage('Error', this.label.showAllDetailsNoFileError, 'error', 'sticky');
            });

    }
    getSalesforceBaseUrl() {
        // Use window.location.origin to get the protocol, hostname, and port
        const { protocol, hostname, port } = window.location;

        // Construct the Salesforce base URL
        let baseUrl = `${protocol}//${hostname}`;

        // Check if the port is not the default HTTP/HTTPS port (80/443)
        if (port && !['80', '443'].includes(port)) {
            baseUrl += `:${port}`;
        }

        return baseUrl;
    }
    parentRecsOfConVer;
    ContentDocumentId;
    contentVerRecords(listOfContentDocumentIds) {
        let paramsForCon = {
            ParentObjectName: 'ContentVersion',
            ChildObjectRelName: '',
            parentObjFields: ['Id', 'ContentDocumentId', 'FileExtension'],
            childObjFields: [],
            queryCriteria: ' WHERE ContentDocumentId IN (\'' + listOfContentDocumentIds.join('\', \'') + '\')'
        }
        getSobjectDataNonCacheable({ params: paramsForCon })
            .then((data) => {
                console.log('test13' + JSON.stringify(data))
                this.parentRecsOfConVer = JSON.parse(JSON.stringify(data.parentRecords));
                if (this.parentRecsOfConVer.length > 0) {
                    this.ContentDocumentId = this.parentRecsOfConVer[0].ContentDocumentId;
                    this.fileToDownload = true;

                }
                if (this.fileToDownload) {
                    const salesforceBaseUrl = this.getSalesforceBaseUrl();
                    var downloadUrl = salesforceBaseUrl + '/sfc/servlet.shepherd/document/download/' + encodeURIComponent(this.ContentDocumentId);
                    // Use the NavigationMixin to open the PDF URL in a new tab
                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url: downloadUrl
                        }
                    });
                } else {
                    this.showToastMessage('Error', this.label.showAllDetailsNoFileError, 'error', 'sticky');
                }
            })
            .catch(error => {

            });
    }
    handleForFetchStatement(event) {
        this.toShowappliBankData = false
        this.bankingDetailRecord = this._childData[event.target.dataset.index];
        this.indexOfPerfios = event.target.dataset.index;
        debugger
        console.log('this.indexOfPerfios' + this.indexOfPerfios);
        this.applicantRecoId = this.bankingDetailRecord.Id;
        var params = {
            ParentObjectName: 'ApplBanking__c',
            ChildObjectRelName: 'Applicant_Banking_Detail__r',
            parentObjFields: ['Id', 'TransactionExpiryDate__c', 'Is_Statement_password_protected__c', 'Password__c', 'AllDocumentNames__c', 'SFDCBankMaster__r.InstitutionId__c', 'Appl__c', 'Initiate_Perfios_Status__c', 'AccountOpenDate__c', 'ConsideredForABBProgram__c', 'Bank_Code__c', 'MICRId__c', 'PDC_by_Name__c', 'eNACHFeasible__c', 'SFDC_Bank_Master_Name__c', 'NACHFeasible__c', 'SFDCBankMaster__r.BankName__c', 'LoanAppl__c', 'IFSC_Code__c', 'Limit__c', 'Name_of_the_Primary_Account_Holder_s__c', 'OtherBankName__c', 'AccountType__c', 'FileType__c', 'SalaryAccount__c', 'DocumentDetail__c', 'BankName__c', 'BankId__c', 'JointAccountHoldersName__c', 'AC_No__c', 'IsThereChangeInLimitDuringThePeri__c', 'AverageLimitDuringThePeriod__c', 'LatestMonthForWhichBankStatementIs__c', 'PeriodOfBankingStart__c', 'PeriodOfBankingEnd__c', 'Bank_City__c', 'Repayment_bank_A_c__c', 'Bank_Branch__c', 'MICR_Code__c', 'Appl__r.CustProfile__c', 'eNACH_feasible__c'],
            childObjFields: ['ApplBanking__c', 'MonthlyLimit__c', 'Utilization__c', 'Id', 'Name', 'Month__c', 'Year__c', 'ValueSummationCredit__c', 'ValueSummationDebit__c', 'CountofCredit__c', 'CountofDebit__c', 'InwardReturnsCount__c', 'OutwardReturnsCount__c', 'StopPaymentCount__c', 'MinBalanceCharges__c', 'BalanceAt_1st__c', 'BalanceAt_5th__c', 'BalanceAt_10th__c', 'BalanceAt_15th__c', 'BalanceAt_20th__c', 'BalanceAt_25th__c', 'AverageBankBalance__c'],
            queryCriteria: ' where Id= \'' + this.applicantRecoId + '\''
        }
        getDataWithoutCacheable({ params: params }).then((result) => {
            if (result[0].parentRecord !== undefined) {
                this.parentRecord = result[0].parentRecord
                if (result.ChildReords && result.ChildReords != undefined) {
                    this.ChildRecsAppliBnkSumm = JSON.parse(JSON.stringify(data.ChildReords));
                } else {
                    this.ChildRecsAppliBnkSumm = [];
                }

                const currentDateTime1 = new Date(this.parentRecord.TransactionExpiryDate__c);
                const currentDateTime = new Date();
                if (currentDateTime1 > currentDateTime && this.parentRecord.Initiate_Perfios_Status__c == 'Pending') {
                    debugger
                    createSMSTask({ referenceId: this.parentRecord.Id })
                        .then((result) => {
                            console.log('resultresultresult>>>>>>>' + JSON.stringify(result))
                            this.showToastMessage('Success', "SMS/email sent to the borrower to fetch bank statement Successfully.", 'success', 'sticky');
                        })
                        .catch((error) => {
                            this.showSpinner = false;
                        });

                } else {


                    if (this.checkInstitutionIdForBnk() && this.checkLimitField()) {
                        let fieldsOfIntMess = {};
                        fieldsOfIntMess['sobjectType'] = 'IntgMsg__c';
                        fieldsOfIntMess['Name'] = 'Generate Link'; //serviceName;//'KYC OCR'
                        fieldsOfIntMess['BU__c'] = 'HL / STL';
                        fieldsOfIntMess['Status__c'] = 'New';
                        fieldsOfIntMess['IsActive__c'] = true;
                        fieldsOfIntMess['Svc__c'] = 'Generate Link'; //serviceName;
                        fieldsOfIntMess['MStatus__c'] = 'Blank';
                        fieldsOfIntMess['RefObj__c'] = 'ApplBanking__c';
                        fieldsOfIntMess['RefId__c'] = this.applicantRecoId;

                        let ChildRecords = [];
                        let upsertData = {
                            parentRecord: fieldsOfIntMess,
                            ChildRecords: ChildRecords,
                            ParentFieldNameToUpdate: ''
                        }
                        console.log('record of message createddddd')
                        updateData({ upsertData: upsertData })
                            .then(result => {
                                console.log('resultresultresultresultresult' + JSON.stringify(result))
                                this.showToastMessage('Success', "SMS/email sent to the borrower to fetch bank statement Successfully.", 'success', 'sticky');
                                //this.showToastMessage('Success', "Integration to Fetch Online Perfio Started Successfully.", 'success', 'sticky');

                                let bankingDetailRecord = this._childData[this.indexOfPerfios];
                                var temp = bankingDetailRecord;
                                temp.FetchDis = true;
                                bankingDetailRecord = { ...temp };
                                var tempArray = [...this._childData];
                                tempArray[this.indexOfPerfios] = bankingDetailRecord;
                                this._childData = [...tempArray];
                            }).catch(error => {

                                console.log(error);
                            })
                    }
                }
            }
        })
            .catch((error) => {
                console.log("TECHNICAL PROP LOAN DETAILS #731", error);
            });

    }
    checkLimitField() {
        if (this.parentRecord.AccountType__c == 'CC' || this.parentRecord.AccountType__c == 'OVERDRAFT') {
            if (this.parentRecord.IsThereChangeInLimitDuringThePeri__c == 'Yes') {
                var count = 0;
                if (this.ChildRecsAppliBnkSumm.length > 0) {
                    for (const record of this.ChildRecsAppliBnkSumm) {
                        if (record.MonthlyLimit__c != null && record.MonthlyLimit__c != '' && record.MonthlyLimit__c !== 'undefined') {

                        } else {
                            count++;
                        }
                    }
                } else {
                    this.showToastMessage('Error', this.label.BankDataTable_LimitReq_Error, 'error', 'sticky');
                    return false
                }
                if (count > 0) {
                    this.showToastMessage('Error', this.label.BankDataTable_SepMonLimitReq_Error, 'error', 'sticky');
                    return false
                } else {
                    return true
                }

            } else {
                if (this.parentRecord.Limit__c != '' && this.parentRecord.Limit__c !== 'undefined' && this.parentRecord.Limit__c != null) {
                    return true
                } else {
                    this.showToastMessage('Error', this.label.BankDataTable_LimitReq_Error, 'error', 'sticky');
                    return false
                }

            }
        } else {
            return true
        }
    }

    // to make table elastic

    //******************************* RESIZABLE COLUMNS *************************************//
    handlemouseup(e) {
        this._tableThColumn = undefined;
        this._tableThInnerDiv = undefined;
        this._pageX = undefined;
        this._tableThWidth = undefined;
    }

    handlemousedown(e) {
        if (!this._initWidths) {
            this._initWidths = [];
            let tableThs = this.template.querySelectorAll(
                "table thead .dv-dynamic-width"
            );
            tableThs.forEach((th) => {
                this._initWidths.push(th.style.width);
            });
        }

        this._tableThColumn = e.target.parentElement;
        this._tableThInnerDiv = e.target.parentElement;
        while (this._tableThColumn.tagName !== "TH") {
            this._tableThColumn = this._tableThColumn.parentNode;
        }
        while (!this._tableThInnerDiv.className.includes("slds-cell-fixed")) {
            this._tableThInnerDiv = this._tableThInnerDiv.parentNode;
        }
        console.log(
            "handlemousedown._tableThColumn.tagName => ",
            this._tableThColumn.tagName
        );
        this._pageX = e.pageX;

        this._padding = this.paddingDiff(this._tableThColumn);

        this._tableThWidth = this._tableThColumn.offsetWidth - this._padding;
        console.log(
            "handlemousedown._tableThColumn.tagName => ",
            this._tableThColumn.tagName
        );
    }

    handlemousemove(e) {
        // console.log("mousemove._tableThColumn => ", this._tableThColumn);
        if (this._tableThColumn && this._tableThColumn.tagName === "TH") {
            this._diffX = e.pageX - this._pageX;

            this.template.querySelector("table").style.width =
                this.template.querySelector("table") - this._diffX + "px";

            this._tableThColumn.style.width = this._tableThWidth + this._diffX + "px";
            this._tableThInnerDiv.style.width = this._tableThColumn.style.width;

            let tableThs = this.template.querySelectorAll(
                "table thead .dv-dynamic-width"
            );
            let tableBodyRows = this.template.querySelectorAll("table tbody tr");
            let tableBodyTds = this.template.querySelectorAll(
                "table tbody .dv-dynamic-width"
            );
            tableBodyRows.forEach((row) => {
                let rowTds = row.querySelectorAll(".dv-dynamic-width");
                rowTds.forEach((td, ind) => {
                    rowTds[ind].style.width = tableThs[ind].style.width;
                });
            });
        }
    }

    handledblclickresizable() {
        let tableThs = this.template.querySelectorAll(
            "table thead .dv-dynamic-width"
        );
        let tableBodyRows = this.template.querySelectorAll("table tbody tr");
        tableThs.forEach((th, ind) => {
            th.style.width = this._initWidths[ind];
            th.querySelector(".slds-cell-fixed").style.width = this._initWidths[ind];
        });
        tableBodyRows.forEach((row) => {
            let rowTds = row.querySelectorAll(".dv-dynamic-width");
            rowTds.forEach((td, ind) => {
                rowTds[ind].style.width = this._initWidths[ind];
            });
        });
    }

    paddingDiff(col) {
        if (this.getStyleVal(col, "box-sizing") === "border-box") {
            return 0;
        }

        this._padLeft = this.getStyleVal(col, "padding-left");
        this._padRight = this.getStyleVal(col, "padding-right");
        return parseInt(this._padLeft, 10) + parseInt(this._padRight, 10);
    }

    getStyleVal(elm, css) {
        return window.getComputedStyle(elm, null).getPropertyValue(css);
    }

}