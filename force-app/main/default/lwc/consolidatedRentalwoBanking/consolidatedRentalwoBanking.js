import { LightningElement, track, api, wire } from 'lwc';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import { createRecord, updateRecord, deleteRecord } from "lightning/uiRecordApi";
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import deleteIncomeRecord from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';
import getSobjectDataWithMultipleChildRelation from '@salesforce/apex/incomeDetailsController.getSobjectDataWithMultipleChildRelation';
// Custom labels
import RentalIncWithoutBank_Del_SuccessMessage from '@salesforce/label/c.RentalIncWithoutBank_Del_SuccessMessage';
import RentalIncWithoutBank_FileAccptdate_ErrorMessage from '@salesforce/label/c.RentalIncWithoutBank_FileAccptdate_ErrorMessage';
import RentalIncWithoutBank_Address_ErrorMessage from '@salesforce/label/c.RentalIncWithoutBank_Address_ErrorMessage';
import RentalIncWithoutBank_Save_SuccessMessage from '@salesforce/label/c.RentalIncWithoutBank_Save_SuccessMessage';
import RentalIncWithoutBank_ReqFields_ErrorMessage from '@salesforce/label/c.RentalIncWithoutBank_ReqFields_ErrorMessage';
import RentalIncWithoutBank_multRecords_ErrorMessage from '@salesforce/label/c.RentalIncWithoutBank_multRecords_ErrorMessage';

export default class ConsolidatedRentalwoBanking extends LightningElement {
    label = {
        RentalIncWithoutBank_Del_SuccessMessage,
        RentalIncWithoutBank_FileAccptdate_ErrorMessage,
        RentalIncWithoutBank_Address_ErrorMessage,
        RentalIncWithoutBank_Save_SuccessMessage,
        RentalIncWithoutBank_ReqFields_ErrorMessage,
        RentalIncWithoutBank_multRecords_ErrorMessage

    }
    @track properties = [];
    @track deletedRecord = [];
    @track updatedRecord = [];
    @api layoutSize;
    @api hasEditAccess;
    @track disableMode;

    @track _isSelected;
    @api get isSelected() {
        return this._isSelected;
    }
    set isSelected(value) {
        this._isSelected = value;
        this.setAttribute("isSelected", value);
    }

    @track _recordTypeName;
    @api get recordTypeName() {
        return this._recordTypeName;
    }
    set recordTypeName(value) {

        this._recordTypeName = value;
        this.setAttribute("recordTypeName", value);

        this.handlerecordTypeNameChange(value);
    }

    @track _applicantId;
    @api get applicantId() {
        return this._applicantId;
    }
    set applicantId(value) {
        this._applicantId = value;
        this.setAttribute("applicantId", value);
        this.handleAddrRecordChange(value);
        this.handleApplicantIdChange(value);
    }



    @track _loanAppId;
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);
        this.handleRecordAppIdChange(value);
    }


    @api applicantIdOnTabset;
    @track addressOptions = [];
    @track addressTypeOptions = [];
    monthOptions = [];
    month1Options = [];
    month2Options = [];
    month3Options = [];
    YesNoOptions = [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' }
    ];
    fileacceptdate;
    labelmonth1;
    labelmonth2;
    labelmonth3;

    @track appID;
    @track withBank = false;

    @track recTypeId;
    @track month1AvgAmount = 0;
    @track month2AvgAmount = 0;
    @track month3AvgAmount = 0;
    @track allAvgAmount = 0;
    @track showSpinner = false;

    @track
    parameterApplication = {
        ParentObjectName: 'LoanAppl__c ',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'FileAcceptDate__c'],
        childObjFields: [],
        queryCriteria: 'WHERE Id=\'' + this._loanAppId + '\''
    }

    @track
    parameter = {
        ParentObjectName: 'ApplAddr__c ',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'AddrLine1__c', 'AddrLine2__c', 'City__c', 'Country__c', 'Pincode__c', 'State__c', 'LoanAppl__r.FileAcceptDate__c', 'AddrTyp__c'],
        childObjFields: [],
        queryCriteria: 'WHERE Applicant__c=\'' + this._applicantId + '\''
    }


    @track
    Incomeparams = {
        ParentObjectName: 'Applicant_Income__c ',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Property_Name__c', 'Index__c', 'Address__c', 'Rental_Month_1__c', 'Month1_Rental_Credit_Bank_Name__c', 'Month1_Rental_Credited_Amount__c',
            'Rental_Month_2__c', 'Month2_Rental_Credit_Bank_Name__c', 'Month2_Rental_Credited_Amount__c', 'Rental_Month_3__c', 'Month3_Rental_Credit_Bank_Name__c',
            'Month3_Rental_Credited_Amount__c', 'Multi_Tenanted__c', 'No_of_Tenants__c', 'Annual_Net_Rental_Current_Year_ITR__c', 'Annual_Net_Rental_Previous_Year_ITR__c',
            'Rent_agreement_documented__c', 'Property_ownership_proof_documented__c', 'Rental_Verification_done__c', 'Applicant__c', 'RecordTypeId', 'Average_Monthly_Rental__c',
            'Address_Type__c', 'Other_Address__c'],
        childObjFields: [],
        queryCriteria: ' where Applicant__c = \'' + this.applicantId + '\'' + ' AND Applicant__c!=null AND RecordTypeId = \'' + this.recTypeId + '\''
    }



    handlerecordTypeNameChange(event) {
        this.recTypeId = this._recordTypeName;
        this.handleAddrRecordChange();
    }

    get formCombinedQueryData() {
        if (this._applicantId && this._recordTypeName) {
            var combinedQuery = 'SELECT Id, Average_Monthly_Rental_No_Bank_Credit__c,  ' +
                '(SELECT Id, AddrLine1__c, AddrLine2__c, City__c, Country__c, Pincode__c, State__c, LoanAppl__r.FileAcceptDate__c, AddrTyp__c FROM Applicant_Addresses__r), ' +
                '(SELECT Id, Property_Name__c, Index__c, Address__c, Rental_Month_1__c, Month1_Rental_Credit_Bank_Name__c, Month1_Rental_Credited_Amount__c, ' +
                'Rental_Month_2__c, Month2_Rental_Credit_Bank_Name__c, Month2_Rental_Credited_Amount__c, Rental_Month_3__c, Month3_Rental_Credit_Bank_Name__c, ' +
                'Month3_Rental_Credited_Amount__c, Multi_Tenanted__c, No_of_Tenants__c, Annual_Net_Rental_Current_Year_ITR__c, Annual_Net_Rental_Previous_Year_ITR__c, ' +
                'Rent_agreement_documented__c, Property_ownership_proof_documented__c, Rental_Verification_done__c, Applicant__c, RecordTypeId, Average_Monthly_Rental__c, ' +
                'Address_Type__c, Other_Address__c FROM Applicant_Income__r WHERE RecordTypeId=\'' + this._recordTypeName + '\') ' +
                'FROM Applicant__c ' +
                'WHERE Id = \'' + this._applicantId + '\'';

            return combinedQuery;
        } else {
            return '';
        }
    }

    handleAddrRecordChange(event) {
        let tempParams = this.Incomeparams;
        tempParams.queryCriteria = ' where Applicant__c = \'' + this._applicantId + '\'' + ' AND Applicant__c!=null AND RecordTypeId = \'' + this.recTypeId + '\''
        this.Incomeparams = { ...tempParams };
    }



    handleRecordAppIdChange(value) {
        let tempParams = this.parameterApplication;
        tempParams.queryCriteria = 'WHERE Id=\'' + this._loanAppId + '\''
        this.parameterApplication = { ...tempParams };
    }


    addProperty() {
        let numberofProperty = this.properties.length + 1;
        this.properties.push({
            Index__c: numberofProperty,
            Property_Name__c: 'Property ' + numberofProperty,
            Address__c: '',
            Rental_Month_1__c: this.labelmonth1,
            Month1_Rental_Credit_Bank_Name__c: '',
            Month1_Rental_Credited_Amount__c: '0',
            Rental_Month_2__c: this.labelmonth2,
            Month2_Rental_Credit_Bank_Name__c: '',
            Month2_Rental_Credited_Amount__c: '0',
            Rental_Month_3__c: this.labelmonth3,
            Month3_Rental_Credit_Bank_Name__c: '',
            Month3_Rental_Credited_Amount__c: '0',
            Multi_Tenanted__c: '',
            No_of_Tenants__c: '0',
            Annual_Net_Rental_Current_Year_ITR__c: '0',
            Annual_Net_Rental_Previous_Year_ITR__c: '0',
            Rent_agreement_documented__c: '',
            Property_ownership_proof_documented__c: '',
            Rental_Verification_done__c: '',
            RecordTypeId: this.recTypeId,
            sobjectType: 'Applicant_Income__c',
            Average_Monthly_Rental__c: '0',
            Address_Type__c: '',
            Other_Address__c: '',
            showOtherAddress: false,
            disableAddress: true
        });

    }

    handleDeleteAction(event) {
        if (this.properties.length > 1) {
            const recordDelId = this.properties[event.target.accessKey - 1].Id;
            if (recordDelId) {
                // deleteRecord(recordDelId)
                //     .then(() => {
                //         this.showToastMessage("Success", this.label.RentalIncWithoutBank_Del_SuccessMessage, "success", "dismissible");
                //     });
                let deleteRecord = [
                    {
                        Id: recordDelId,
                        sobjectType: 'Applicant_Income__c'
                    }
                ]
                deleteIncomeRecord({ rcrds: deleteRecord })
                .then(result => {
                   console.log('Delete result----------->'+JSON.stringify(result));
                   this.showToastMessage("Success", this.label.RentalIncWithoutBank_Del_SuccessMessage, "success", "dismissible");

                })
                .catch(error => {
                    this.showToastMessage("Error in handleDeleteAction", error.body.message, "error", "sticky");
                })

                console.log('deleteRecord--------------->'+deleteRecord);

            }
            else {
                this.showToastMessage("Success", this.label.RentalIncWithoutBank_Del_SuccessMessage, "success", "dismissible");
            }
            this.properties.splice(event.target.accessKey - 1, 1);
            for (let i = 0; i < this.properties.length; i++) {
                let numberofProperty = i + 1;
                this.properties[i].Index__c = numberofProperty;
                this.properties[i].Property_Name__c = 'Property ' + numberofProperty;
            }
        }
    }

    inputChangeHandler(event) {

        if (event.target.dataset.fieldname == 'Average_Monthly_Rental__c') {
        }

        if (event.target.dataset.fieldname == 'labelmonth1') {
            this.labelmonth1 = event.target.value;
            let tempmonth = this.monthOptions.filter(eachmonth => eachmonth.name == event.target.value);
            let monthtemp1 = { label: this.getMonthName(tempmonth[0].number - 2), value: this.getMonthName(tempmonth[0].number - 2) };
            this.month2Options.push(monthtemp1);
            this.labelmonth2 = this.getMonthName(tempmonth[0].number - 2);

            let monthtemp2 = { label: this.getMonthName(tempmonth[0].number - 3), value: this.getMonthName(tempmonth[0].number - 3) };
            this.month3Options.push(monthtemp2);
            this.labelmonth3 = this.getMonthName(tempmonth[0].number - 3);
            if (this.properties.length > 0) {

                for (let i = 0; i < this.properties.length; i++) {
                    this.properties[i].Rental_Month_1__c = this.labelmonth1;
                    this.properties[i].Rental_Month_2__c = this.labelmonth2;
                    this.properties[i].Rental_Month_3__c = this.labelmonth3;
                }
            }
        }

        // if (event.target.dataset.fieldname == 'Address__c') {
        //     this.properties[event.target.accessKey - 1].Address__c = event.target.value;
        // }

        if (event.target.dataset.fieldname == "Address_Type__c") {
            this.properties[event.target.accessKey - 1].Address_Type__c = event.target.value;
            if (event.target.value) {
                if (event.target.value === 'Other Address') {
                    this.properties[event.target.accessKey - 1].showOtherAddress = true;
                    this.properties[event.target.accessKey - 1].disableAddress = false;
                    this.properties[event.target.accessKey - 1].Address__c = null;
                } else {
                    this.properties[event.target.accessKey - 1].Other_Address__c = null;
                    this.properties[event.target.accessKey - 1].showOtherAddress = false;
                    this.properties[event.target.accessKey - 1].disableAddress = true;
                    for (var i = 0; i < this.addressOptions.length; i++) {
                        if (this.addressOptions[i].addressType === event.target.value) {
                            this.properties[event.target.accessKey - 1].Address__c = this.addressOptions[i].value;
                            break;
                        }
                    }
                }
            }
        }

        if (event.target.dataset.fieldname == "Other_Address__c") {
            this.properties[event.target.accessKey - 1].Other_Address__c = event.target.value;

        }

        if (event.target.dataset.fieldname == 'Month1_Rental_Credit_Bank_Name__c') {
            this.properties[event.target.accessKey - 1].Month1_Rental_Credit_Bank_Name__c = event.target.value;

        }

        if (event.target.dataset.fieldname == 'Month1_Rental_Credited_Amount__c') {

            let amount = event.target.value
            if (amount > 0) {
                this.properties[event.target.accessKey - 1].Month1_Rental_Credited_Amount__c = event.target.value;

                this.calculateAverageMonthlyRental(event.target.accessKey);

                this.calculateMonthAvg1();

            }
            else {
                this.properties[event.target.accessKey - 1].Month1_Rental_Credited_Amount__c = '0';
                this.calculateMonthAvg1();
                this.calculateAverageMonthlyRental(event.target.accessKey);
            }

        }

        if (event.target.dataset.fieldname == 'Month2_Rental_Credit_Bank_Name__c') {
            this.properties[event.target.accessKey - 1].Month2_Rental_Credit_Bank_Name__c = event.target.value;

        }
        if (event.target.dataset.fieldname == 'Month2_Rental_Credited_Amount__c') {

            let amount = event.target.value
            if (amount != 0) {
                this.properties[event.target.accessKey - 1].Month2_Rental_Credited_Amount__c = event.target.value;
                this.calculateAverageMonthlyRental(event.target.accessKey);
                this.calculateMonthAvg2();
            }
            else {
                this.properties[event.target.accessKey - 1].Month2_Rental_Credited_Amount__c = '0';
                this.calculateMonthAvg2();
                this.calculateAverageMonthlyRental(event.target.accessKey);
            }

        }

        if (event.target.dataset.fieldname == 'Month3_Rental_Credit_Bank_Name__c') {
            this.properties[event.target.accessKey - 1].Month3_Rental_Credit_Bank_Name__c = event.target.value;

        }

        if (event.target.dataset.fieldname == 'Month3_Rental_Credited_Amount__c') {

            let amount = event.target.value
            if (amount != 0) {
                this.properties[event.target.accessKey - 1].Month3_Rental_Credited_Amount__c = event.target.value;
                this.calculateAverageMonthlyRental(event.target.accessKey);
                this.calculateMonthAvg3();
            }
            else {
                this.properties[event.target.accessKey - 1].Month3_Rental_Credited_Amount__c = '0';
                this.calculateMonthAvg3();
                this.calculateAverageMonthlyRental(event.target.accessKey);
            }

        }
        if (event.target.dataset.fieldname == 'Multi_Tenanted__c') {
            this.properties[event.target.accessKey - 1].Multi_Tenanted__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'No_of_Tenants__c') {
            this.properties[event.target.accessKey - 1].No_of_Tenants__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Annual_Net_Rental_Current_Year_ITR__c') {
            this.properties[event.target.accessKey - 1].Annual_Net_Rental_Current_Year_ITR__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Annual_Net_Rental_Previous_Year_ITR__c') {
            this.properties[event.target.accessKey - 1].Annual_Net_Rental_Previous_Year_ITR__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Rent_agreement_documented__c') {
            this.properties[event.target.accessKey - 1].Rent_agreement_documented__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Property_ownership_proof_documented__c') {
            this.properties[event.target.accessKey - 1].Property_ownership_proof_documented__c = event.target.value;
        }
        if (event.target.dataset.fieldname == 'Rental_Verification_done__c') {
            this.properties[event.target.accessKey - 1].Rental_Verification_done__c = event.target.value;
        }

    }

    calculateMonthAvg1() {
        let totalamount = 0;
        for (let i = 0; i < this.properties.length; i++) {

            if (parseInt(this.properties[i].Month1_Rental_Credited_Amount__c) > 0) {
                totalamount = parseFloat(totalamount) + parseFloat(this.properties[i].Month1_Rental_Credited_Amount__c);
            }
        }
        this.month1AvgAmount = totalamount;

    }

    calculateMonthAvg2() {
        let totalamount = 0;
        for (let i = 0; i < this.properties.length; i++) {

            if (parseInt(this.properties[i].Month2_Rental_Credited_Amount__c) > 0) {
                totalamount = parseFloat(totalamount) + parseFloat(this.properties[i].Month2_Rental_Credited_Amount__c);
            }
        }
        this.month2AvgAmount = totalamount;

    }

    calculateMonthAvg3() {
        let totalamount = 0;
        for (let i = 0; i < this.properties.length; i++) {

            if (parseInt(this.properties[i].Month3_Rental_Credited_Amount__c) > 0) {
                totalamount = parseFloat(totalamount) + parseFloat(this.properties[i].Month3_Rental_Credited_Amount__c);
            }
        }
        this.month3AvgAmount = totalamount;

    }

    calculateAverageMonthlyRental(accesskey) {
        let totalamount = 0;
        let count = 0;
        if (parseFloat(this.properties[accesskey - 1].Month1_Rental_Credited_Amount__c) > 0) {
            totalamount = totalamount + parseFloat(this.properties[accesskey - 1].Month1_Rental_Credited_Amount__c);
            count++;
        }
        if (parseFloat(this.properties[accesskey - 1].Month2_Rental_Credited_Amount__c) > 0) {
            totalamount = totalamount + parseFloat(this.properties[accesskey - 1].Month2_Rental_Credited_Amount__c);
            count++;
        }
        if (parseFloat(this.properties[accesskey - 1].Month3_Rental_Credited_Amount__c) > 0) {
            totalamount = totalamount + parseFloat(this.properties[accesskey - 1].Month3_Rental_Credited_Amount__c);
            count++;
        }
        if (totalamount > 0) {
            this.properties[accesskey - 1].Average_Monthly_Rental__c = parseFloat(totalamount / count).toFixed(2);
        } else {
            this.properties[accesskey - 1].Average_Monthly_Rental__c = '0';
        }

        let totalamountaverage = 0;
        for (let i = 0; i < this.properties.length; i++) {

            if (parseInt(this.properties[i].Average_Monthly_Rental__c) > 0) {
                totalamountaverage = parseFloat(totalamountaverage) + parseFloat(this.properties[i].Average_Monthly_Rental__c);
            }
        }
        this.allAvgAmount = totalamountaverage;




    }






    handleApplicantIdChange(value) {
        let tempParams = this.parameter;
        tempParams.queryCriteria = ' where Applicant__c = \'' + this._applicantId + '\''
        this.parameter = { ...tempParams };
    }

    @track applicationData;
    @track noFileAcceptance = false;

    @wire(getSobjectData, { params: '$parameterApplication' })
    handleApplicationResponse(wiredDataApplication) {
        let { error, data } = wiredDataApplication;
        this.applicationData = wiredDataApplication;
        this.noFileAcceptance = false;
        if (error) {
            console.error('Error ------------->', error);
            return;
        }

        if (!data || !data.parentRecords || data.parentRecords.length === 0) {
            this.noFileAcceptance = true;
            this.showToastMessage("Error", this.label.RentalIncWithoutBank_FileAccptdate_ErrorMessage, "error", "dismissible");
            return;
        }

        let dateFile = data.parentRecords[data.parentRecords.length - 1].FileAcceptDate__c;

        if (!dateFile) {
            this.noFileAcceptance = true;
            this.showToastMessage("Error", this.label.RentalIncWithoutBank_FileAccptdate_ErrorMessage, "error", "dismissible");
            return;
        }

        const monthOptions = [];
        const currentMonth = new Date(dateFile).getMonth();

        for (let i = currentMonth; i > currentMonth - 3; i--) {
            monthOptions[i] = { name: this.getMonthName(i), number: i + 1 };

            if (!this.month1Options.some(eachmonth => eachmonth.label === this.getMonthName(i))) {
                this.month1Options.push({ label: this.getMonthName(i), value: this.getMonthName(i) });
            }
        }

        this.month1Options = this.month1Options.filter(element => element !== null);
        this.monthOptions = monthOptions.filter(element => element !== null);

        if (this.labelmonth1 == null || this.labelmonth1 == '' || this.labelmonth1 == undefined) {
            console.log('month1Options[0].value-------------->' + this.month1Options[0].value);
            this.labelmonth1 = this.month1Options[0].value;
            this.labelmonth2 = this.month1Options[1].value;
            this.labelmonth3 = this.month1Options[2].value;
        }
    }


    get monthsSelectionDisabled() {
        if (this.noFileAcceptance === true || this.disableMode === true) {
            return true;
        } else {
            return false;
        }
    }

    get disableMode() {
        if (this.hasEditAccess === false) {
            return true;
        } else {
            return false;
        }
    }

    getMonthName(monthNumber) {
        const date = new Date();
        date.setMonth(monthNumber);
        return date.toLocaleString('en-US', { month: 'long' });
    }
    @track actualIncomeData;

    @track applicantAllData;
    @wire(getSobjectDataWithMultipleChildRelation, { query: '$formCombinedQueryData' })
    handleMultipleResponse(wiredResultAllData) {
        let { error, data } = wiredResultAllData;
        this.applicantAllData = wiredResultAllData;
        //console.log('Applicant All Data Received!! '+JSON.stringify(this.applicantAllData) +this._applicantId);
        if (data) {

            this.handleAddressData(data);
        } else if (error) {
            console.error('Error Team ------------->', error);
        }
    }

    handleAddressData(data) {
        this.addressTypeOptions = [];
        if (data.Applicant_Addresses__r && data.Applicant_Addresses__r.length > 0) {
            for (let i = 0; i < data.Applicant_Addresses__r.length; i++) {
                if (data.Applicant_Addresses__r[i].AddrTyp__c) {
                    let addressTypeValue = { label: data.Applicant_Addresses__r[i].AddrTyp__c, value: data.Applicant_Addresses__r[i].AddrTyp__c, addressType: data.Applicant_Addresses__r[i].AddrTyp__c };
                    this.addressTypeOptions.push(addressTypeValue);
                }
                const addressParts = [
                    data.Applicant_Addresses__r[i].AddrLine1__c,
                    data.Applicant_Addresses__r[i].AddrLine2__c,
                    data.Applicant_Addresses__r[i].City__c,
                    data.Applicant_Addresses__r[i].Pincode__c
                ];
                // Join non-empty address parts with commas
                const address = addressParts.filter(part => part).join(',');
                if (address) {
                    //const tempAdd = this.addressOptions.some(eachAddress => eachAddress.label === address);
                   // if (!tempAdd) {
                        this.addressOptions.push({ label: address, value: data.Applicant_Addresses__r[i].Id, addressType: (data.Applicant_Addresses__r[i].AddrTyp__c ? data.Applicant_Addresses__r[i].AddrTyp__c : '') });
                   // }
                }
            }
        } else {
            this.showToastMessage("Warning", this.label.RentalIncWithoutBank_Address_ErrorMessage, "warning", "dismissible");
        }

        if (this.addressTypeOptions.length === 0) {
            var otherAddressType = { label: 'Other Address', value: 'Other Address', "addressType": "Other Address" };
            this.addressTypeOptions.push(otherAddressType);
        } else {
            const otherAddressExists = this.addressTypeOptions.some(option => option.label === 'Other Address');
            if (!otherAddressExists) {
                this.addressTypeOptions.push({ "label": "Other Address", "value": "Other Address", "addressType": "Other Address" });
            }
        }

        if (this.addressTypeOptions && this.addressTypeOptions.length > 0) {
            if (data.Applicant_Income__r) {
                this.actualIncomeData = data.Applicant_Income__r;
                this.handleIncomeData(this.actualIncomeData);
            }
            // else{
            //     this.addProperty();
            // }
        }
    }

    handleIncomeData() {
        if (this.actualIncomeData && this.actualIncomeData.length > 0) {
            this.properties = [];
            this.month1AvgAmount = '0';
            this.month2AvgAmount = '0';
            this.month3AvgAmount = '0';
            this.allAvgAmount = '0';

            this.actualIncomeData.forEach(newItem => {

                if (newItem.Rental_Month_1__c != '' || newItem.Rental_Month_1__c != null) {
                    let tempMonth = this.month1Options.filter(eachmonth => eachmonth.label == newItem.Rental_Month_1__c);
                    if (tempMonth == null || tempMonth == '') {
                        let monthOptions = { label: newItem.Rental_Month_1__c, value: newItem.Rental_Month_1__c };
                        this.month1Options.push(monthOptions);
                    }
                }

                this.month1AvgAmount = parseFloat(this.month1AvgAmount) + parseFloat(newItem.Month1_Rental_Credited_Amount__c);
                this.month2AvgAmount = parseFloat(this.month2AvgAmount) + parseFloat(newItem.Month2_Rental_Credited_Amount__c);
                this.month3AvgAmount = parseFloat(this.month3AvgAmount) + parseFloat(newItem.Month3_Rental_Credited_Amount__c);
                this.allAvgAmount = parseFloat(this.allAvgAmount) + parseFloat(newItem.Average_Monthly_Rental__c);




                this.labelmonth1 = newItem.Rental_Month_1__c;
                this.labelmonth2 = newItem.Rental_Month_2__c;
                this.labelmonth3 = newItem.Rental_Month_3__c;
                let newObj = {
                    Id: newItem.Id,
                    Index__c: newItem.Index__c,
                    Property_Name__c: newItem.Property_Name__c,
                    Address_Type__c: newItem.Address_Type__c ? newItem.Address_Type__c : '',
                    Address__c: newItem.Address__c ? newItem.Address__c : '',
                    Other_Address__c: newItem.Other_Address__c ? newItem.Other_Address__c : '',
                    Rental_Month_1__c: newItem.Rental_Month_1__c ? newItem.Rental_Month_1__c : '',
                    Month1_Rental_Credit_Bank_Name__c: newItem.Month1_Rental_Credit_Bank_Name__c ? newItem.Month1_Rental_Credit_Bank_Name__c : '',
                    Month1_Rental_Credited_Amount__c: newItem.Month1_Rental_Credited_Amount__c ? newItem.Month1_Rental_Credited_Amount__c : '0',
                    Rental_Month_2__c: newItem.Rental_Month_2__c ? newItem.Rental_Month_2__c : '',
                    Month2_Rental_Credit_Bank_Name__c: newItem.Month2_Rental_Credit_Bank_Name__c ? newItem.Month2_Rental_Credit_Bank_Name__c : '',
                    Month2_Rental_Credited_Amount__c: newItem.Month2_Rental_Credited_Amount__c ? newItem.Month2_Rental_Credited_Amount__c : '0',
                    Rental_Month_3__c: newItem.Rental_Month_3__c ? newItem.Rental_Month_3__c : '',
                    Month3_Rental_Credit_Bank_Name__c: newItem.Month3_Rental_Credit_Bank_Name__c ? newItem.Month3_Rental_Credit_Bank_Name__c : '',
                    Month3_Rental_Credited_Amount__c: newItem.Month3_Rental_Credited_Amount__c ? newItem.Month3_Rental_Credited_Amount__c : '0',
                    Multi_Tenanted__c: newItem.Multi_Tenanted__c ? newItem.Multi_Tenanted__c : '',
                    No_of_Tenants__c: newItem.No_of_Tenants__c ? newItem.No_of_Tenants__c : '0',
                    Annual_Net_Rental_Current_Year_ITR__c: newItem.Annual_Net_Rental_Current_Year_ITR__c ? newItem.Annual_Net_Rental_Current_Year_ITR__c : '0',
                    Annual_Net_Rental_Previous_Year_ITR__c: newItem.Annual_Net_Rental_Previous_Year_ITR__c ? newItem.Annual_Net_Rental_Previous_Year_ITR__c : '0',
                    Rent_agreement_documented__c: newItem.Rent_agreement_documented__c ? newItem.Rent_agreement_documented__c : '',
                    Property_ownership_proof_documented__c: newItem.Property_ownership_proof_documented__c ? newItem.Property_ownership_proof_documented__c : '',
                    Rental_Verification_done__c: newItem.Rental_Verification_done__c ? newItem.Rental_Verification_done__c : '',
                    Applicant__c: newItem.Applicant__c ? newItem.Applicant__c : '',
                    RecordTypeId: newItem.RecordTypeId ? newItem.RecordTypeId : '',
                    Average_Monthly_Rental__c: newItem.Average_Monthly_Rental__c ? newItem.Average_Monthly_Rental__c : '',
                    showOtherAddress: false,
                    disableAddress: true
                };

                if ((newItem.Address_Type__c && newItem.Address_Type__c === 'Other Address')) {
                    newObj.showOtherAddress = true;
                    newObj.disableAddress = this.disableMode === false ? false : true ;
                } else {
                    newObj.showOtherAddress = false;
                    newObj.disableAddress = true;
                }

                this.properties.push(newObj);
            });

        }
        this.index++;

    }

    // getApplicantAddressRecords(){

    //     getSobjectData({params : this.parameter})
    //     .then(data =>{
    //         if(data.parentRecords  && data.parentRecords.length > 0){
    //             for (let i = 0; i < data.parentRecords.length; i++) {
    //                 if(data.parentRecords[i].AddrTyp__c){
    //                     let addressTypeValue = { label: data.parentRecords[i].AddrTyp__c, value: data.parentRecords[i].AddrTyp__c};
    //                     this.addressTypeOptions.push(addressTypeValue);
    //                 }
    //                 const addressParts = [
    //                     data.parentRecords[i].AddrLine1__c,
    //                     data.parentRecords[i].AddrLine2__c,
    //                     data.parentRecords[i].City__c,
    //                     data.parentRecords[i].Pincode__c
    //                 ];
    //                 // Join non-empty address parts with commas
    //                 const address = addressParts.filter(part => part).join(',');
    //                 if (address) {
    //                     const tempAdd = this.addressOptions.some(eachAddress => eachAddress.label === address);
    //                     if (!tempAdd) {
    //                         this.addressOptions.push({ label: address, value: data.parentRecords[i].Id, addressType: (data.parentRecords[i].AddrTyp__c ? data.parentRecords[i].AddrTyp__c: '')});
    //                     }
    //                 }
    //             }
    //         }else{
    //             this.showToastMessage("Warning", 'Address details missing for the Applicant/Co-Applicant. Only "Other Address" will be available for selection. Please add the addresses from Applicant/Co-Applicant details screen first to view all options.', "warning", "dismissible");
    //         }

    //         if(this.addressTypeOptions.length === 0){
    //             var otherAddressType ={label: 'Other Address', value: 'Other Address', "addressType": "Other Address"};
    //             this.addressTypeOptions.push(otherAddressType);
    //         }else{
    //             const otherAddressExists = this.addressTypeOptions.some(option => option.addressType === 'Other Address');
    //             if (!otherAddressExists) {
    //                 this.addressTypeOptions.push({"label": "Other Address", "value": "Other Address", "addressType": "Other Address"});
    //             }
    //         }
    //     })
    // }




    connectedCallback() {
        if (this.hasEditAccess === false) {
            this.disableMode = true;
        }
        this.handleRefreshAllData();
    }


    // @track applicantIncomeData = {};
    // @wire(getSobjectData, { params: '$Incomeparams' })
    // handleIncomeResponse(wiredResultIncome) {

    //     let { error, data } = wiredResultIncome;
    //     this.applicantIncomeData = wiredResultIncome;

    //     if (data) {
    //         this.actualIncomeData = data.parentRecords;
    //         this.handleIncomeData();
    //     } else if (error) {
    //         console.error('Error Team ------------->', error);
    //     }

    // }



    showToastMessage(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant,
            mode
        });
        this.dispatchEvent(evt);
    }

    @api handleUpsert() {
        this.showSpinner = true;

        var countOfRecords = 0;
        var sumOfAmount = 0;
        var keysToSum = ['Month1_Rental_Credited_Amount__c', 'Month2_Rental_Credited_Amount__c', 'Month3_Rental_Credited_Amount__c'];
        if (this.properties && this.properties.length > 0) {
            this.properties.forEach(obj => {
                
                keysToSum.forEach(key => {
                    sumOfAmount =parseFloat(sumOfAmount) + parseFloat(obj[key] || 0)
                });
                countOfRecords++;
            });
        }

        var averageRentalAmount = 0;
        averageRentalAmount = countOfRecords > 0 ? (sumOfAmount / (3)) : 0;
        if(averageRentalAmount){
            averageRentalAmount = Math.round(averageRentalAmount * 100) / 100;
        }
        

        this.applicantDetails = {
            LoanAppl__c: this.loanAppId,
            Id: this.applicantId,
            sobjectType: 'Applicant__c',
            Average_Monthly_Rental_No_Bank_Credit__c: averageRentalAmount
        };


        var valueUpdate;
        if (this.properties.length > 0 && this.isSelected == true) {
            valueUpdate = this.properties;
            valueUpdate = valueUpdate.map(item => {
                const { showOtherAddress, disableAddress, ...rest } = item;
                return rest;
            });

            let upsertData = {
                parentRecord: this.applicantDetails,
                ChildRecords: valueUpdate,
                ParentFieldNameToUpdate: 'Applicant__c'
            }
            upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
                .then(result => {
                    this.showToastMessage("Success", this.label.RentalIncWithoutBank_Save_SuccessMessage, "success", "dismissible");
                    this.handleRefreshAllData();
                    this.showSpinner = false;
                    return true;
                })
                .catch(error => {
                    console.log('upsert error -', JSON.stringify(error))
                    this.showToastMessage("Error in handleUpsert", error.body.message, "error", "sticky");
                    this.showSpinner = false;
                    return true;
                })
            return true;
        } else {
            this.showSpinner = false;
        }
        return true;
    }

    handleRefreshAllData() {
        refreshApex(this.applicationData);
        //refreshApex(this.applicantIncomeData);
        refreshApex(this.applicantAllData);
        console.log('inside handle refresh all data');

    }

    disconnectedCallback() {
        this.handleRefreshAllData();
        console.log('inside handle refresh disconnected callback');
    }


    renderedCallback() {
        this.handleRefreshAllData();
    }


    @api validateForm() {
        let isValid = true
        //LAK-5541 - combined validation
        const elements = [...this.template.querySelectorAll('lightning-combobox'), ...this.template.querySelectorAll('lightning-input')];

        elements.forEach(element => {
            if (element.reportValidity()) {
            } else {
                isValid = false;
                this.showToastMessage("Error", this.label.RentalIncWithoutBank_ReqFields_ErrorMessage, "error", "dismissible");
            }
        });

        /*8this.template.querySelectorAll('lightning-combobox').forEach(element => {
            if (element.reportValidity()) {

            } else {
                isValid = false;
                this.showToastMessage("Error", this.label.RentalIncWithoutBank_ReqFields_ErrorMessage, "error", "dismissible");
            }
        });

        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (element.reportValidity()) {
            } else {
                isValid = false;
                this.showToastMessage("Error", this.label.RentalIncWithoutBank_ReqFields_ErrorMessage, "error", "dismissible");
            }
        });*/

        if (this.properties.length > 1) {
            const addressTypeCountMap = {};
            this.properties.forEach((item) => {
                const addressType = item.Address_Type__c;
                if (addressType != 'Other Address') {
                    if (addressTypeCountMap[addressType]) {
                        isValid = false;
                        this.showToastMessage("Error", this.label.RentalIncWithoutBank_multRecords_ErrorMessage, "error", "dismissible");
                    } else {
                        addressTypeCountMap[addressType] = 1;
                    }
                }
            })
        }



        return isValid;
    }
}