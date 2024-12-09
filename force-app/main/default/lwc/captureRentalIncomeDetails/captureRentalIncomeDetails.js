import { LightningElement, track, api, wire } from 'lwc';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import { createRecord, updateRecord, deleteRecord } from "lightning/uiRecordApi";
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import getSobjectDataWithMultipleChildRelation from '@salesforce/apex/incomeDetailsController.getSobjectDataWithMultipleChildRelation';
// Custom labels
import deleteIncomeRecord from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';
import RentalIncome_Del_SuccessMessage from '@salesforce/label/c.RentalIncome_Del_SuccessMessage';
import RentalIncome_FileAccptdate_ErrorMessage from '@salesforce/label/c.RentalIncome_FileAccptdate_ErrorMessage';
import RentalIncome_Address_ErrorMessage from '@salesforce/label/c.RentalIncome_Address_ErrorMessage';
import RentalIncome_Save_SuccessMessage from '@salesforce/label/c.RentalIncome_Save_SuccessMessage';
import RentalIncome_PropDetails_ErrorMessage from '@salesforce/label/c.RentalIncome_PropDetails_ErrorMessage';
import RentalIncome_ReqFields_ErrorMessage from '@salesforce/label/c.RentalIncome_ReqFields_ErrorMessage';
import RentalIncome_MultRecords_ErrorMessage from '@salesforce/label/c.RentalIncome_MultRecords_ErrorMessage';

export default class captureRentalIncomeDetails extends LightningElement {
    label ={
        RentalIncome_Del_SuccessMessage,
        RentalIncome_FileAccptdate_ErrorMessage,
        RentalIncome_Address_ErrorMessage,
        RentalIncome_Save_SuccessMessage,
        RentalIncome_PropDetails_ErrorMessage,
        RentalIncome_ReqFields_ErrorMessage,
        RentalIncome_MultRecords_ErrorMessage

    }
    @track properties = [];
    @track deletedRecord = [];
    @track updatedRecord = [];
    @api layoutSize;
    @api hasEditAccess;
    @track reantalAverage=0;
    @track totalRent=[];
    @track disableMode;
    ;
    

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
        parentObjFields: ['Id', 'AddrLine1__c', 'AddrLine2__c', 'City__c', 'Country__c', 'Pincode__c', 'State__c', 'LoanAppl__r.FileAcceptDate__c','AddrTyp__c'],
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
                          'Rent_agreement_documented__c', 'Property_ownership_proof_documented__c', 'Rental_Verification_done__c', 'Applicant__c', 'RecordTypeId','Average_Monthly_Rental__c',
                          'Address_Type__c', 'Other_Address__c'],
        childObjFields: [],
        queryCriteria: ' where Applicant__c = \'' + this.applicantId + '\'' + ' AND Applicant__c!=null AND RecordTypeId = \'' + this.recTypeId + '\''
    }

    handlerecordTypeNameChange(event) {
        this.recTypeId =this._recordTypeName ;
        this.handleAddrRecordChange();
    }


    get formCombinedQueryData(){
        if(this._applicantId && this._recordTypeName){
            var combinedQuery = 'SELECT Id, Average_Monthly_Rental_With_Bank_Credit__c, ' +
                            '(SELECT Id, AddrLine1__c, AddrLine2__c, City__c, Country__c, Pincode__c, State__c, LoanAppl__r.FileAcceptDate__c, AddrTyp__c FROM Applicant_Addresses__r), ' +
                            '(SELECT Id, Property_Name__c, Index__c, Address__c, Rental_Month_1__c, Month1_Rental_Credit_Bank_Name__c, Month1_Rental_Credited_Amount__c, ' +
                            'Rental_Month_2__c, Month2_Rental_Credit_Bank_Name__c, Month2_Rental_Credited_Amount__c, Rental_Month_3__c, Month3_Rental_Credit_Bank_Name__c, ' +
                            'Month3_Rental_Credited_Amount__c, Multi_Tenanted__c, No_of_Tenants__c, Annual_Net_Rental_Current_Year_ITR__c, Annual_Net_Rental_Previous_Year_ITR__c, ' +
                            'Rent_agreement_documented__c, Property_ownership_proof_documented__c, Rental_Verification_done__c, Applicant__c, RecordTypeId, Average_Monthly_Rental__c, ' +
                            'Address_Type__c, Other_Address__c FROM Applicant_Income__r WHERE RecordTypeId=\''+this._recordTypeName + '\') ' +
                            'FROM Applicant__c ' +
                            'WHERE Id = \'' + this._applicantId + '\'';

            return combinedQuery;
        }else{
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

    handleApplicantIdChange(value){
        let tempParams = this.parameter;
        tempParams.queryCriteria = ' where Applicant__c = \'' + this._applicantId + '\''
        this.parameter = { ...tempParams };
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
            Average_Monthly_Rental__c:'0',
            Address_Type__c: '',
            Other_Address__c: '',
            showOtherAddress: false,
            disableAddress: true
        });
    }
    
    // Logic added for delete confirmation pop up message DG 
    @track showDeleteConfirmation = false;
    @track recordDelId;
    @track accessKeyForDeletion;
    
    deleteHandler(event) {
        // if (this.disableMode) {
        //     return;
        // }
        this.showDeleteConfirmation = true;
    
        this.recordDelId = this.properties[event.target.accessKey - 1].Id;
        this.accessKeyForDeletion = event.target.accessKey;
    }

    hideModalBox(){
        this.showDeleteConfirmation = false;
    }
    
    handleConfirmDelete() {
        this.handleDeleteAction();
        this.showDeleteConfirmation = false;
    }
    handleCancelDelete() {
        this.showDeleteConfirmation = false;
    }
    handleDeleteAction() {
       
            if (this.recordDelId) {
                // deleteRecord(this.recordDelId)
                // .then(() => {
                    
                //     this.showToastMessage("Success", this.label.RentalIncome_Del_SuccessMessage, "success", "dismissible");
                // });

                let deleteRecord = [
                    {
                        Id: this.recordDelId,
                        sobjectType: 'Applicant_Income__c'
                    }
                ]
                deleteIncomeRecord({ rcrds: deleteRecord })
                .then(result => {
                   console.log('Delete result----------->'+JSON.stringify(result));
                   this.showToastMessage("Success", this.label.RentalIncome_Del_SuccessMessage, "success", "dismissible");
                   this.showDeleteConfirmation = false;
                })
                .catch(error => {
                    
                    this.showToastMessage("Error in handleDeleteAction", error.body.message, "error", "sticky");
                    this.showDeleteConfirmation = false;
                })
            }
            else {
                this.showToastMessage("Success", this.label.RentalIncome_Del_SuccessMessage, "success", "dismissible");
                this.showDeleteConfirmation = false;
            }
            
            if (this.properties.length >= 1) {
            this.properties.splice(this.accessKeyForDeletion-1, 1);
            for (let i = 0; i < this.properties.length; i++) {
                console.log('deleted properties::',JSON.stringify(this.properties));
                
                let numberofProperty = i + 1;
                this.properties[i].Index__c = i + 1;
                this.properties[i].Property_Name__c = 'Property ' + numberofProperty;

                console.log('deleted properties length numberofProperty', numberofProperty);
            }
            this.calculateMonthAvg1();
            this.calculateMonthAvg2();
            this.calculateMonthAvg3();
            this.calculateAverageMonthlyRental(this.accessKeyForDeletion);
        }
        console.log('deleted properties:::: after delete',JSON.stringify(this.properties));
        
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


        if (event.target.dataset.fieldname == "Address_Type__c") {
            this.properties[event.target.accessKey - 1].Address_Type__c = event.target.value;
            if(event.target.value){
                if(event.target.value ==='Other Address'){
                    this.properties[event.target.accessKey - 1].showOtherAddress = true;
                    this.properties[event.target.accessKey - 1].disableAddress = false;
                    this.properties[event.target.accessKey - 1].Address__c = null;
                }else{
                    this.properties[event.target.accessKey - 1].Other_Address__c = null;
                    this.properties[event.target.accessKey - 1].showOtherAddress = false;
                    this.properties[event.target.accessKey - 1].disableAddress = true;
                    console.log('this.addressOptions##',JSON.stringify(this.addressOptions));
                    for(var i=0; i<this.addressOptions.length; i++){
                        if(this.addressOptions[i].addressType === event.target.value){
                            this.properties[event.target.accessKey - 1].Address__c =this.addressOptions[i].value;
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
        let totalamountaverage = 0;

        if(this.properties.length > 0){
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

       
        console.log('totalamountaverage:::',totalamountaverage);
        for (let i = 0; i < this.properties.length; i++) {

            if (parseInt(this.properties[i].Average_Monthly_Rental__c) > 0) {
                totalamountaverage = parseFloat(totalamountaverage) + parseFloat(this.properties[i].Average_Monthly_Rental__c);
            }
        }
        console.log('totalamountaverage:::2',totalamountaverage);
        this.allAvgAmount = totalamountaverage;
    }
    else{
        this.allAvgAmount = 0;
    }

    

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




    @track applicationData;
    @track noFileAcceptance = false;

    @wire(getSobjectData, { params: '$parameterApplication' })
    handleApplicationResponse(wiredDataApplication){
        let { error, data } = wiredDataApplication;
        this.applicationData = wiredDataApplication;
        this.noFileAcceptance = false;
        if (error) {
            console.error('Error ------------->', error);
            return;
        }

        if (!data || !data.parentRecords || data.parentRecords.length === 0) {
            this.noFileAcceptance = true;
            this.showToastMessage("Error", this.label.RentalIncome_FileAccptdate_ErrorMessage, "error", "dismissible");
            return;
        }

        let dateFile = data.parentRecords[data.parentRecords.length - 1].FileAcceptDate__c;

        if (!dateFile) {
            this.noFileAcceptance = true;
            this.showToastMessage("Error", this.label.RentalIncome_FileAccptdate_ErrorMessage, "error", "dismissible");
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

        console.log('this.labelmonth1------------>'+this.labelmonth1);
        if(this.labelmonth1==null || this.labelmonth1=='' || this.labelmonth1==undefined)
        {
            console.log('month1Options[0].value-------------->'+this.month1Options[0].value);
            this.labelmonth1=this.month1Options[0].value;
            this.labelmonth2=this.month1Options[1].value;
            this.labelmonth3=this.month1Options[2].value;
        }
        
    }


    get monthsSelectionDisabled(){
        if(this.noFileAcceptance === true || this.disableMode === true){
            return true;
        }else{
            return false;
        }
    }

    get disableMode(){
        if(this.hasEditAccess === false){
            return true;
        }else{
            return false;
        }
    }

    

    getMonthName(monthNumber) {
        const date = new Date();
        date.setMonth(monthNumber);
        return date.toLocaleString('en-US', { month: 'long' });
    }


    // @track applicantAddressData;
    // @wire(getSobjectData, { params: '$parameter' })
    // handleAddressResponse(wiredResultAddress) {
    //     let { error, data } = wiredResultAddress;
    //     this.applicantAddressData = wiredResultAddress;
    //     console.log('Applicant Data Received!! '+JSON.stringify(this.applicantAddressData));
    //     if (data) {
    //         this.handleAddressData(data);
    //     } else if (error) {
    //         console.error('Error Team ------------->', error);
    //     }

    // }


    
    @track actualIncomeData;

    @track applicantAllData;
    @wire(getSobjectDataWithMultipleChildRelation, {query : '$formCombinedQueryData'})
    handleMultipleResponse(wiredResultAllData){
        let { error, data } = wiredResultAllData;
        this.applicantAllData = wiredResultAllData;
        if (data) {
            //console.log('Applicant All Data Received!! '+JSON.stringify(data));
            this.handleAddressData(data);
        } else if (error) {
            console.error('Error Team ------------->', error);
        }
    }

    handleAddressData(data){
        this.addressTypeOptions = [];
        if(data.Applicant_Addresses__r  && data.Applicant_Addresses__r.length > 0){
            for (let i = 0; i < data.Applicant_Addresses__r.length; i++) {
                console.log('data.Applicant_Addresses__r[i].AddrTyp__c## ', data.Applicant_Addresses__r[i].AddrTyp__c);
                if(data.Applicant_Addresses__r[i].AddrTyp__c){
                    let addressTypeValue = { label: data.Applicant_Addresses__r[i].AddrTyp__c, value: data.Applicant_Addresses__r[i].AddrTyp__c, addressType: data.Applicant_Addresses__r[i].AddrTyp__c};

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
                console.log('address------>',address);
                if (address) {
                    //const tempAdd = this.addressOptions.some(eachAddress => eachAddress.label === address);
                   // if (!tempAdd) {
                        this.addressOptions.push({ label: address, value: data.Applicant_Addresses__r[i].Id, addressType: (data.Applicant_Addresses__r[i].AddrTyp__c ? data.Applicant_Addresses__r[i].AddrTyp__c: '')});
                    //}
                }
            }
            console.log('this.addressTypeOptions------>',JSON.stringify(this.addressTypeOptions));
            console.log('address Options------>',JSON.stringify(this.addressOptions));
        }else{
            this.showToastMessage("Warning", this.label.RentalIncome_Address_ErrorMessage, "warning", "dismissible");
        }

        if(this.addressTypeOptions.length === 0){
            var otherAddressType ={label: 'Other Address', value: 'Other Address', "addressType": "Other Address"};
            this.addressTypeOptions.push(otherAddressType);
        }else{
            const otherAddressExists = this.addressTypeOptions.some(option => option.label === 'Other Address');
            if (!otherAddressExists) {
                this.addressTypeOptions.push({"label": "Other Address", "value": "Other Address", "addressType": "Other Address"});
            }
        }

        //console.log('OOOOOOOO!! Address Apex1'+JSON.stringify(this.addressOptions));
        //console.log('OOOOOOOO!! Address Apex11'+JSON.stringify(this.addressTypeOptions));
        //console.log('OOOOOOOO!! Address'+JSON.stringify(this.addressOptions));
        if(this.addressTypeOptions && this.addressTypeOptions.length>0){
            if(data.Applicant_Income__r){
                this.actualIncomeData = data.Applicant_Income__r;
                this.handleIncomeData(this.actualIncomeData);
            }
            // else{
            //     this.addProperty();
            // }
            
        }
    }


    
    // @track applicantIncomeData;
    // @wire(getSobjectData, { params: '$Incomeparams' })
    // handleIncomeResponse(wiredResultIncome) {
    //     let { error, data } = wiredResultIncome;
    //     this.applicantIncomeData = wiredResultIncome;
    //     if (data) {
    //         //console.log('OOOOOOOO!! In wire'+JSON.stringify(data));
    //         this.actualIncomeData = data.parentRecords;
    //         this.handleIncomeData();
    //     } else if (error) {
    //         console.error('Error Team ------------->', error);
    //     }

    // }


    handleIncomeData() {
        if (this.actualIncomeData && this.actualIncomeData.length > 0) {
            this.properties = [];
            this.month1AvgAmount = '0';
            this.month2AvgAmount ='0';
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

                let numberofProperty = this.properties.length + 1;
        
                let newObj = {
                    Id: newItem.Id,
                    Index__c: newItem.Index__c,
                    Property_Name__c: 'Property ' + numberofProperty,
                    Address_Type__c: newItem.Address_Type__c  ?  newItem.Address_Type__c : '',
                    Address__c: newItem.Address__c ? newItem.Address__c : '',
                    Other_Address__c: newItem.Other_Address__c  ?  newItem.Other_Address__c : '',
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

                if((newItem.Address_Type__c && newItem.Address_Type__c === 'Other Address')){
                    newObj.showOtherAddress = true;
                    newObj.disableAddress = this.disableMode === false ? false : true ;
                }else{
                    newObj.showOtherAddress = false;
                    newObj.disableAddress = true;
                }

                this.properties.push(newObj);
            });

        }
        
        this.index++;
    }

    connectedCallback() {
        if (this.hasEditAccess === false) {
            this.disableMode = true;
        }
        this.handleRefreshAllData();
    }

    disconnectedCallback(){
        this.handleRefreshAllData();
        console.log('inside handle refresh disconnected callback r with banking');
    }

    @api handleUpsert() {
        this.showSpinner = true;

        let countOfRecords = 0;
        let sumOfAmount = 0;
        const keysToSum = ['Month1_Rental_Credited_Amount__c', 'Month2_Rental_Credited_Amount__c', 'Month3_Rental_Credited_Amount__c'];
        if(this.properties && this.properties.length>0){
            this.properties.forEach(obj =>{
                keysToSum.forEach(key =>{
                    sumOfAmount =parseFloat(sumOfAmount) + parseFloat(obj[key] || 0)
                });
                countOfRecords++;
            });
        }

        let averageRentalAmount = 0;
        averageRentalAmount = countOfRecords > 0 ? (sumOfAmount/(3)) : 0;
        if(averageRentalAmount){
            averageRentalAmount = Math.round(averageRentalAmount * 100) / 100;
        }

        this.applicantDetails = {
            LoanAppl__c: this.loanAppId,
            Id: this.applicantId,
            sobjectType: 'Applicant__c',
            Average_Monthly_Rental_With_Bank_Credit__c : averageRentalAmount
        };



        var valueUpdate;
        if(this.properties && this.properties.length > 0 || this.isSelected == true) {
            valueUpdate = this.properties;
            valueUpdate = valueUpdate.map(item =>{
                const { showOtherAddress, disableAddress, ...rest } = item;
                return rest;
            });

            let upsertData = {
                parentRecord: this.applicantDetails,
                ChildRecords: valueUpdate,
                ParentFieldNameToUpdate: 'Applicant__c'
            }
            console.log('sfgdgfdg!!! '+JSON.stringify(upsertData));
            upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
            .then(result => {
                this.showToastMessage("Success", this.label.RentalIncome_Save_SuccessMessage, "success", "dismissible");
                this.handleRefreshAllData();
                this.showSpinner = false;
            })
            .catch(error => {
                console.error(error)
                console.log('upsert error -', JSON.stringify(error))
                this.showToastMessage("Error in handleUpsert", error.body.message, "error", "sticky");
                this.showSpinner = false;
            })
        }else{
            this.showToastMessage("Error", this.label.RentalIncome_PropDetails_ErrorMessage, "error", "dismissible");
            this.showSpinner = false;
        }
    }

    handleRefreshAllData(){
        refreshApex(this.applicationData);
        // refreshApex(this.applicantAddressData);
        // refreshApex(this.applicantIncomeData);
        refreshApex(this.applicantAllData);
    }


    @api validateForm() {
        let isValid = true

        /*this.template.querySelectorAll('lightning-combobox').forEach(element => {
            if (element.reportValidity()) {

            } else {
                isValid = false;
                this.showToastMessage("Error", this.label.RentalIncome_ReqFields_ErrorMessage, "error", "dismissible");
            }
        });*/
        //LAK-5541 - combined validation
        const elements = [...this.template.querySelectorAll('lightning-combobox'), ...this.template.querySelectorAll('lightning-input')];

        elements.forEach(element => {
            if (element.reportValidity()) {
            } else {
                isValid = false;
                this.showToastMessage("Error", this.label.RentalIncome_ReqFields_ErrorMessage, "error", "dismissible");
            }
        });

        if (!this.checkBankLookupValidity()) {
            isValid = false;
        }

        if(this.properties.length > 1){
            const addressTypeCountMap = {};
            this.properties.forEach((item) =>{
                const addressType = item.Address_Type__c;
                if(addressType != 'Other Address'){
                    if(addressTypeCountMap[addressType]){
                        isValid = false;
                        this.showToastMessage("Error", this.label.RentalIncome_MultRecords_ErrorMessage, "error", "dismissible");   
                    }else{
                        addressTypeCountMap[addressType] = 1;
                    }
                }
            })
        }

        return isValid;
    }

    checkBankLookupValidity(){
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


    renderedCallback(){
        this.handleRefreshAllData();
    }

    handleValueSelect(event){
        var bankIdSelected;
        if(event.detail){
            bankIdSelected = event.detail.id;
        }

        if (event.target.dataset && event.target.dataset.fieldname === "Month1_Rental_Credit_Bank_Name__c") { 
            this.properties[event.target.dataset.indexid-1].Month1_Rental_Credit_Bank_Name__c = bankIdSelected;
        }else if (event.target.dataset && event.target.dataset.fieldname === "Month2_Rental_Credit_Bank_Name__c") { 
            this.properties[event.target.dataset.indexid-1].Month2_Rental_Credit_Bank_Name__c = bankIdSelected;
        }else if (event.target.dataset && event.target.dataset.fieldname === "Month3_Rental_Credit_Bank_Name__c") { 
            this.properties[event.target.dataset.indexid-1].Month3_Rental_Credit_Bank_Name__c = bankIdSelected;
        }
    }
}