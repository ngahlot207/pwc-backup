import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRelatedRecords from '@salesforce/apex/SanctionController.getRelatedRecords';
import deleteRecord from '@salesforce/apex/SanctionController.deleteRecord';
import upsertSanctionConditions from '@salesforce/apex/SanctionController.upsertSanctionConditions';
import getSobjectDataNonCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable';
import { refreshApex } from '@salesforce/apex';

// Custom labels
import SanctionDeatils_ErrorMessage from '@salesforce/label/c.SanctionDeatils_ErrorMessage';
import SanctionDeatils_Del_SuccessMessage from '@salesforce/label/c.SanctionDeatils_Del_SuccessMessage';

export default class CaptureSanctionDetails extends LightningElement {
    label = {
        SanctionDeatils_ErrorMessage,
        SanctionDeatils_Del_SuccessMessage
    }
    @api hasEditAccess;

    @api recordId;

    @track showTable = false;

    @track showButton = true;

    @track createNewRecord = false;


    @track records = [];

    @track isReadOnly = false;

    @api index;

    @track hasRecords = false;

    @api isValid = false;

    @track wiredRecords;

    @track showDeleteConfirmation = false;

    @track showSpinner = false;

    @track orignalArray = [];

    @wire(getRelatedRecords, { loanId: '$recordId' })
    wiredRecordsResult(result) {
        this.records = [];
        this.wiredRecords = result;
        const { data, error } = result;
        if (data) {
            this.records = data.map((record) => ({ ...record, isModified: false }));
            this.hasRecords = this.records.length > 0;
            //console.log('wiredRecords inside wire',JSON.stringify(this.records))
        } else if (error) {
            console.log('error----->', error);
            this.showErrorToast('Error', this.label.SanctionDeatils_ErrorMessage);
        }
    }

    get displayTable() {
        return this.showTable || this.hasRecords;
    }

    get createNewSanctionRecord() {
        return this.createNewRecord || !this.hasRecords;
    }

    @track productType;
    get filterConditionProduct() {
        if (this.productType) {
            return 'ProductType__c includes (\'' + this.productType + '\')'; //'  'ProductType__c includes ' + "'" + this.wrapAddressObj.City__c + "' ";
        }
        return '';

    }

    connectedCallback() {
        if (this.hasEditAccess === false) {
            this.isReadOnly = true;
        }
        refreshApex(this.wiredRecords);
        this.getProductType();
    }

    renderedCallback() {
        refreshApex(this.wiredRecords);
    }
    getProductType() {
        let params_btLoan = {
            ParentObjectName: 'LoanAppl__c',
            ChildObjectRelName: '',
            parentObjFields: ['Id', 'Product__c'],
            childObjFields: [],
            queryCriteria: ' where Id = \'' + this.recordId + '\' limit 1'

        }
        console.log('query  == ', params_btLoan);

        getSobjectDataNonCacheable({ params: params_btLoan })
            .then((result) => {
                if (result.parentRecords[0].Product__c) {
                    this.productType = result.parentRecords[0].Product__c;
                }
            })
            .catch((error) => {
                console.log('Error in getting Loan Data', error);
            });


    }

    handleInputChange(event) {
        const index = event.target.dataset.index;
        let Remark = event.target.value
        this.records[index].Remarks__c = Remark.toUpperCase();
        this.records[index].isModified = true;
    }

    @api validateForm() {
        let isValid = true
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (element.reportValidity()) {
            } else {
                isValid = false;
            }
        });

        if (!this.checkSanctionLookupValidity()) {
            isValid = false;
        }
        return isValid;
    }

    checkSanctionLookupValidity() {
        let isInputCorrect = true;
        let allChilds = this.template.querySelectorAll("c-custom-lookup");
        allChilds.forEach((child) => {
            if (!child.checkValidityLookup()) {
                child.checkValidityLookup();
                isInputCorrect = false;
            }
        });
        return isInputCorrect;
    }

    //LAK-8266- Filter Unique Records
    @track filtrArry;
    getUniqueIds(array1, array2) {
        const array2Ids = new Set(array2.map(item => item.Id));
        this.filtrArry = array1.filter(item => !array2Ids.has(item.Id)).map(item => item.Id)

    }

    //LAK-8266- Get Duplicate Sanction Records
    getSanctionConditions() {
        getRelatedRecords({ loanId: this.recordId })
            .then((result) => {
                console.log('Loan getSanctionConditons', JSON.stringify(result));
                this.orignalArray = result;
                this.getUniqueIds(this.orignalArray, this.records);
                if (this.filtrArry) {
                    let formatArry = this.filtrArry.map(id => ({ Id: id }));
                    this.deleteRecordDuplicate(formatArry);
                    refreshApex(this.wiredRecords);
                }

            })
            .catch((error) => {
                console.log('Unique Error:', error);
            });
    }


    @api handleSaveClick() {
        //this.extractUniqueIds();
        this.showSpinner = true;
        var modifiedRecords = [];
        var recordsToUpsert = [];
        //LAK-8266
        this.getSanctionConditions();
        modifiedRecords = this.records.filter((record) => record.isModified);
        if (modifiedRecords && modifiedRecords.length > 0) {
            recordsToUpsert = modifiedRecords.map((record) => ({
                sobjectType: 'Sanction_Conditions__c',
                Id: record.Id,
                Sanction_Con_Master__c: record.Sanction_Con_Master__c,
                Remarks__c: record.Remarks__c,
                Condition__c: record.Condition__c,
                Loan_Application__c: this.recordId
            }));
        }
        let saveStatus = true;
        if (recordsToUpsert && recordsToUpsert.length > 0) {
            upsertSanctionConditions({ records: recordsToUpsert })
                .then(() => {
                    modifiedRecords = [];
                    recordsToUpsert = [];
                    //this.records = [];
                    refreshApex(this.wiredRecords); // Refresh the data
                    this.showSpinner = false;
                    //saveStatus = true;
                })
                .catch((error) => {
                    console.error('Error Received: ', error);
                    this.showSpinner = false;
                    this.showErrorToast('Error', this.label.SanctionDeatils_ErrorMessage);
                    saveStatus = false;
                });
        } else {
            this.showSpinner = false;
        }
        return saveStatus;
    }

    handlebuttonClick() {
        this.showTable = true;
        this.showButton = false;
        this.displayNewRecord = !this.showButton;
        this.addMoreButton();
    }

    //LAK-8266- Delete Duplicate Sanction Conditions
    deleteRecordDuplicate(filtrRec) {
        for (var i = 0; i < filtrRec.length; i++) {
            deleteRecord({ recordId: filtrRec[i].Id })

                .then(() => {
                    refreshApex(this.wiredRecords);
                    console.log('Delete Success in deleteRecordDuplicate ')
                })
        }
    }

    addMoreButton() {

        this.records.push({
            Sanction_Con_Master__c: '',
            Remarks__c: '',
            Condition__c: ''
        });
    }

    TempArray = []
    @track tempArr = []
    handleValueSelect(event) {
        this.tempArr = [];
        var selectedSanctionId;
        const index = event.target.dataset.index;
        let tempFlag = true;
        let TempRecord = JSON.parse(JSON.stringify(this.records));

        if (event.detail.mainField != 'Other -') {
            for (var i = 0; i < TempRecord.length; i++) {
                if (TempRecord[i].Condition__c == event.detail.mainField) {
                    this.showErrorToast('Error', 'Condition cannot be repeat.');
                    event.detail.mainField = '';
                    this.records[index].isModified = false;
                    tempFlag = false;
                }
            }
        }
        if (event.detail) {
            selectedSanctionId = event.detail.id;
            this.records[index].Sanction_Con_Master__c = selectedSanctionId;
            this.records[index].Condition__c = event.detail.mainField;
            this.records[index].isModified = true;
            this.records.forEach(item => {

                if (item.Condition__c != "") {
                    let obj = { ...item }
                    this.tempArr.push(obj);
                }
            })
            this.records = [];
            this.records = [...this.tempArr]
        }
    }

    @track currentRowIndex;
    @track currentRowId;

    handleRowAction(event) {
        this.showDeleteConfirmation = true;
        this.currentRowIndex = event.currentTarget.dataset.index;
        this.currentRowId = event.currentTarget.dataset.id;
    }


    hideModalBox() {
        this.showDeleteConfirmation = false;
    }

    handleConfirmDelete() {
        this.records.splice(this.currentRowIndex, 1);
        this.deleteRecord(this.currentRowId);
    }

    deleteRecord(recordId) {

        deleteRecord({ recordId: recordId })

            .then(() => {
                this.showSuccessToast('Success', this.label.SanctionDeatils_Del_SuccessMessage);
                this.showDeleteConfirmation = false;
                return refreshApex(this.wiredRecords);
            })

            .catch(error => {
                this.showErrorToast('Error', this.label.SanctionDeatils_ErrorMessage);
            });
    }


    showSuccessToast(title, message) {

        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: 'success',
            mode: 'sticky',
        });
        this.dispatchEvent(evt);
    }


    showErrorToast(title, message) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: 'error',
            mode: 'sticky',
        });

        this.dispatchEvent(evt);
    }
}