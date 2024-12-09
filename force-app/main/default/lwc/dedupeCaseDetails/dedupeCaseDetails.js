import { LightningElement,api,track,wire } from 'lwc';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import upsertSObjectRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import LEAD_OBJECT from '@salesforce/schema/Lead';
import LEAD_CLOSURE_REASON from '@salesforce/schema/Lead.Lead_Closure_Reason__c';
import { getObjectInfo, getPicklistValues, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import caseSubmitMsgApproved from '@salesforce/label/c.caseSubmitMsg_Approved';
import caseSubmitMsgReject from '@salesforce/label/c.caseSubmitMsg_Reject';
import { refreshApex } from '@salesforce/apex';

export default class DedupeCaseDetails extends NavigationMixin(LightningElement) {
    // Define columns for the table
    //@api recordId;

    @track label = {
          caseSubmitMsgApproved,
            caseSubmitMsgReject
        }
    caseData;
    columns = [
        
        { label: 'Previous Application No', fieldName: 'previousAppNo' },
        // { label: 'Lead no', fieldName: 'LeadNo' },
        // { label: 'Lead creation date', fieldName: 'leadCreationDate' },
        { label: 'View Details', fieldName: 'viewDetails' },
        { label: 'Action', fieldName: 'action' },
        { label: 'Sourcing branch name', fieldName: 'sourcingBranchName' },
        { label: 'Match found Name', fieldName: 'matchFoundName' },
        { label: 'Match found Mobile no', fieldName: 'matchFoundMobileNo' },
        { label: 'Current stage', fieldName: 'currentStage' },
        { label: 'Current sub stage', fieldName: 'currentSubStage' },
        { label: 'Sanction date / Disbursement / rejection date / cancelation date', fieldName: 'sanctionDisbursementDate' },
        { label: 'Sanction / Disbursement amount', fieldName: 'sanctionDisbursementAmount' },
        { label: 'Property address', fieldName: 'propertyAddress' },
        { label: 'Rationale', fieldName: 'rationale' }
    ];
    LeadNo;
    LeadCreatedDate;
    leadClosureOptions;
    LeadRecId;
    buttndisable = true;
    caseStatus;
    latestSanctionDate;
    rejectDate;
    firstApprovalDate;
    sanctionAmount;
    currentSubStage;
    currentStage;
    matchFoundMobile;
    matchFoundName;
    sourceBranch;
    loanStatus;
    sanctionOrRejectDate;
    loanId;
    ApplAsset;
    loanAdd2;
    loanAdd1;
    loanPropPin;
    loanPropCity;
    loanPropState;
    propAdd;
    previousAppNo;
    dispStatus;
    ApplId;
    rationale;
    @track wiredCDataResult;
    @track showSpinner = false;

    generatePicklist(data) {
        return data.values.map(item => ({ label: item.label, value: item.value }))
    }
    @wire(getObjectInfo, { objectApiName: LEAD_OBJECT })
    objInfo

    @wire(getPicklistValues, { recordTypeId: '$objInfo.data.defaultRecordTypeId', fieldApiName: LEAD_CLOSURE_REASON })
    leadClosurePicklistHandler({ data, error }) {
        if (data) {
            this.leadClosureOptions = [...this.generatePicklist(data)]
            console.log ('customerProfileOptions',this.leadClosureOptions)
        }
        if (error) {
            console.error('PicklistError',JSON.stringify(error))
        }
    }

    @track _recordId
    @api get recordId() {
        return this._recordId;
    }
            //@api loanAppId;
    set recordId(value) {
    this._recordId = value;
    this.setAttribute("recordId", value);
    console.log('RecordId ##1 ::::>>>>',value);
    this.handleRecordIdChange(value);
    }


    handleRecordIdChange(){
        
        let tempParams = this.Params;
        tempParams.queryCriteria = ' where Id= \''+this.recordId+'\'';
        this.Params = { ...tempParams };
        console.log('RecordId ::::>>>>',this._recordId);
    }


// JavaScript function to format the date
formatDate(dateString) {
    if(dateString){
    const date = new Date(dateString);
    const day = date.getUTCDate().toString().padStart(2, '0');
    const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    const month = monthNames[date.getUTCMonth()];
    const year = date.getUTCFullYear().toString().slice(-2); // Get last two digits of the year
    return `${day}-${month}-${year}`;
}
}


    actionPicklist = [
        { label: 'Approve', value: 'Approved' },
        { label: 'Reject', value: 'Rejected' }
    ];
    connectedCallback() {
        //this.getCaseData();
}

//getCaseData(){

    @track Params = {
        ParentObjectName: 'Case',
        ChildObjectRelName: '',
        parentObjFields: ['id','Applicant__c','status','Lead__r.Lead_Id__c','Lead__r.CreatedDate', 'Lead__r.Branch_Name__c','Applicant__r.FullName__c','Applicant__r.MobNumber__c','Loan_Application__r.Stage__c', 'Loan_Application__r.SubStage__c','Loan_Application__r.SanLoanAmt__c','Loan_Application__r.FirstApprovalDate__c','Loan_Application__r.Rejected_date__c','Loan_Application__r.LatestSanctionDate__c','Loan_Application__r.Status__c','Loan_Application__r.Name','Rationale__c'],
        childObjFields: [],
        queryCriteria: ' where Id= \''+this.recordId+'\''
    }


    @wire(getSobjectData, { params: '$Params' })
    handleCaseData(wiredCaseData) {
        let { error, data } = wiredCaseData;
        this.wiredCDataResult = wiredCaseData;
        if(data){
        console.log('Inside Case Details', JSON.stringify(data))
        this.caseData = data;
        if(this.caseData.parentRecords.length >0){
            this.rationale = this.caseData.parentRecords[0].Rationale__c?this.caseData.parentRecords[0].Rationale__c:'';
            if(this.caseData.parentRecords[0].Lead__r){
        this.LeadNo = this.caseData.parentRecords[0].Lead__r.Lead_Id__c?this.caseData.parentRecords[0].Lead__r.Lead_Id__c:'';
        this.LeadCreatedDate = this.caseData.parentRecords[0].Lead__r.CreatedDate?this.formatDate(this.caseData.parentRecords[0].Lead__r.CreatedDate):'';
        this.sourceBranch = this.caseData.parentRecords[0].Lead__r.Branch_Name__c?this.caseData.parentRecords[0].Lead__r.Branch_Name__c:'';
        this.LeadRecId = this.caseData.parentRecords[0].Lead__r.Id?this.caseData.parentRecords[0].Lead__r.Id:'';
        }
        this.caseStatus = this.caseData.parentRecords[0].Status?this.caseData.parentRecords[0].Status:'';
        if(this.caseData.parentRecords[0].Applicant__r){
        this.matchFoundName = this.caseData.parentRecords[0].Applicant__r.FullName__c?this.caseData.parentRecords[0].Applicant__r.FullName__c:'';
        this.matchFoundMobile = this.caseData.parentRecords[0].Applicant__r.MobNumber__c?this.caseData.parentRecords[0].Applicant__r.MobNumber__c:'';
        }
        if(this.caseData.parentRecords[0].Loan_Application__r){
        this.loanStatus = this.caseData.parentRecords[0].Loan_Application__r.Status__c?this.caseData.parentRecords[0].Loan_Application__r.Status__c:'';
        this.currentStage = this.caseData.parentRecords[0].Loan_Application__r.Stage__c?this.caseData.parentRecords[0].Loan_Application__r.Stage__c:'';
        this.currentSubStage = this.caseData.parentRecords[0].Loan_Application__r.SubStage__c?this.caseData.parentRecords[0].Loan_Application__r.SubStage__c:'';
        this.sanctionAmount = this.caseData.parentRecords[0].Loan_Application__r.SanLoanAmt__c?this.caseData.parentRecords[0].Loan_Application__r.SanLoanAmt__c:'';
        this.firstApprovalDate = this.caseData.parentRecords[0].Loan_Application__r.FirstApprovalDate__c?this.caseData.parentRecords[0].Loan_Application__r.FirstApprovalDate__c:'';
        this.rejectDate = this.caseData.parentRecords[0].Loan_Application__r.Rejected_date__c?this.caseData.parentRecords[0].Loan_Application__r.Rejected_date__c:'';
        this.latestSanctionDate = this.caseData.parentRecords[0].Loan_Application__r.LatestSanctionDate__c?this.caseData.parentRecords[0].Loan_Application__r.LatestSanctionDate__c:'';
        this.previousAppNo = this.caseData.parentRecords[0].Loan_Application__r.Name?this.caseData.parentRecords[0].Loan_Application__r.Name:'';
        }
        this.ApplId = this.caseData.parentRecords[0].Applicant__c?this.caseData.parentRecords[0].Applicant__c:'';
            if(this.loanStatus && this.loanStatus != 'Rejected'){
                this.sanctionOrRejectDate = this.formatDate(this.latestSanctionDate);
            }
            else{
                this.sanctionOrRejectDate = this.formatDate(this.rejectDate);
            }
        if(this.caseStatus === 'Closed') {
            this.buttndisable = true;
        }else{
            this.buttndisable = false;
        }
        if(this.caseData.parentRecords[0].Loan_Application__r){
        this.loanId = this.caseData.parentRecords[0].Loan_Application__r.Id?this.caseData.parentRecords[0].Loan_Application__r.Id:'';
        }
        console.log('this.loanId',this.loanId)
        this.getLoanData();
        }
        
    }
    if(error){
        console.log('Error in Case Data fetch!',JSON.stringify(error))
    }
        }
//}

getLoanData(){

    let Params1 = {
        ParentObjectName: 'ApplAsset__c',
        ChildObjectRelName: '',
        parentObjFields: ['id','LoanAppln__c','State__c','City__c','Pin_Code__c','AddrLn1__c', 'AddrLn2__c','LastModifiedDate'],
        childObjFields: [],
        queryCriteria: ' where LoanAppln__c= \''+ this.loanId +'\'order by LastModifiedDate desc'
    }

    if(this.loanId){

    console.log('this.loanId',this.loanId)
    getSobjectData({
        params: Params1
    })
    .then((result) => {
        console.log('ApplAsset__c :',JSON.stringify(result))
        this.ApplAsset = result;
        if(this.ApplAsset){
        this.loanPropState = this.ApplAsset.parentRecords[0].State__c?this.ApplAsset.parentRecords[0].State__c:'';
        this.loanPropCity = this.ApplAsset.parentRecords[0].City__c?this.ApplAsset.parentRecords[0].City__c:'';
        this.loanPropPin = this.ApplAsset.parentRecords[0].Pin_Code__c?this.ApplAsset.parentRecords[0].Pin_Code__c:'';
        this.loanAdd1 = this.ApplAsset.parentRecords[0].AddrLn1__c?this.ApplAsset.parentRecords[0].AddrLn1__c:'';
        this.loanAdd2 = this.ApplAsset.parentRecords[0].AddrLn2__c?this.ApplAsset.parentRecords[0].AddrLn2__c:'';
        }
        this.propAdd = this.loanAdd1+' '+this.loanAdd2+' '+this.loanPropCity+' '+this.loanPropState+' '+this.loanPropPin;
    })
    .catch((error) => {
        console.log('Error in method 2', JSON.stringify(error))
    })
}
}
    // Example method to demonstrate using the recordId
    handleClick() {
        console.log('Handling click for record ID:', this.recordId);
        // Perform some action with the recordId
    }
    showAction = false;
    actionVal;
    rejectReason;
    actionReject = false;
    rationalVal;
    handleInputChange(event){
        if(event.target.label === 'Approve/Reject'){
            this.actionVal = event.target.value;
        if(this.actionVal === 'Rejected'){
            this.actionReject = true;
        }
        else{
            this.actionReject = false;
        }
        }
        if(event.target.label === 'Reject Reason'){
            this.rejectReason = event.target.value;
        }
        if(event.target.label === 'Rationale'){
            this.rationalVal = event.target.value;
        }
    }

    isValid = true;
    validateForm() {

    this.template.querySelectorAll('lightning-combobox, lightning-input').forEach(element => {
    if (!element.reportValidity()) {
        isValid = false;
    }
    });
        return this.isValid;
    }

    casefields;
    leadfields;
    leadStaus;
    Datafied=[];
    handleSave(){
        if (this.validateForm()){
            this.showSpinner = true;
        const currentDate = new Date();
        if (this.recordId) {
            this.casefields = {
                Id: this.recordId,
                Approved_Rejected__c: this.actionVal,
                Reject_Reason__c: this.rejectReason,
                Status : 'Closed',
                Date_of_Report__c : currentDate,
                TAT_of_Technical_Report__c: currentDate,
                Rationale__c: this.rationalVal
            }
            this.Datafied = [this.casefields];
            console.log('CaseData :',JSON.stringify(this.Datafied ))

            if(this.LeadRecId){
                if(this.actionVal === 'Approved'){
                    this.leadStaus = 'In Progress'
                    this.dispStatus = 'New'
                }
                else{
                    this.leadStaus = 'Rejected'
                    this.dispStatus = 'Lead closed'
                }
                this.leadfields = {
                    Id: this.LeadRecId,
                    Approved_Rejected__c: this.actionVal,
                    Status : this.leadStaus,
                    Disposition_Status__c: this.dispStatus

                }
                this.Datafied = [this.casefields, this.leadfields];
                console.log('LeadData :',JSON.stringify(this.Datafied ))
            }
            this.buttndisable = true;
            this.showAction = false;
        upsertSObjectRecord({
            params: this.Datafied
        })
        .then((result) => {
            console.log('upsert success')
            refreshApex(this.wiredCaseData);
            this.showSpinner = false;
            this.navigateToListView();
        })
        .catch((error) => {
            console.log('Error In creating Record', error);
            this.showSpinner = false;
        });
    }
}

this.buttndisable = true;
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

    closeShowAction() {
        this.showAction = false;
    }
    openAction(){
        this.showAction = true;
    }

    actionReject(){
    }

    tableOuterDivScrolled(event) {
        this._tableViewInnerDiv = this.template.querySelector(".tableViewInnerDiv");
        if (this._tableViewInnerDiv) {
            if (!this._tableViewInnerDivOffsetWidth || this._tableViewInnerDivOffsetWidth === 0) {
                this._tableViewInnerDivOffsetWidth = this._tableViewInnerDiv.offsetWidth;
            }
            this._tableViewInnerDiv.style = 'width:' + (event.currentTarget.scrollLeft + this._tableViewInnerDivOffsetWidth) + "px;" + this.tableBodyStyle;
        }
        this.tableScrolled(event);
    }

    tableScrolled(event) {
        if (this.enableInfiniteScrolling) {
            if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
                this.dispatchEvent(new CustomEvent('showmorerecords', {
                    bubbles: true
                }));
            }
        }
        if (this.enableBatchLoading) {
            if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
                this.dispatchEvent(new CustomEvent('shownextbatch', {
                    bubbles: true
                }));
            }
        }
    }


    navigateToListView(){
        this.buttndisable = true;
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'list'
            },
        });
        if(this.actionVal === 'Approved'){
        this.showToastMessage('Success', this.label.caseSubmitMsgApproved , 'Success', 'sticky');
        }
        else{
            this.showToastMessage('Error', this.label.caseSubmitMsgReject , 'Error', 'sticky');
        }
    }
    @track showDetails = false;
    handlebutton(){
        if(this.showDetails === true){
            this.showDetails = false;
        }
        else{
            this.showDetails = true;
        }
    }

    renderedCallback() {
         refreshApex(this.wiredCDataResult);
     }
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
        let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
        tableThs.forEach(th => {
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
    console.log("handlemousedown._tableThColumn.tagName => ", this._tableThColumn.tagName);
    this._pageX = e.pageX;

    this._padding = this.paddingDiff(this._tableThColumn);

    this._tableThWidth = this._tableThColumn.offsetWidth - this._padding;
    console.log("handlemousedown._tableThColumn.tagName => ", this._tableThColumn.tagName);
}

handlemousemove(e) {
    console.log("mousemove._tableThColumn => ", this._tableThColumn);
    if (this._tableThColumn && this._tableThColumn.tagName === "TH") {
        this._diffX = e.pageX - this._pageX;

        this.template.querySelector("table").style.width = (this.template.querySelector("table") - (this._diffX)) + 'px';

        this._tableThColumn.style.width = (this._tableThWidth + this._diffX) + 'px';
        this._tableThInnerDiv.style.width = this._tableThColumn.style.width;

        let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
        let tableBodyRows = this.template.querySelectorAll("table tbody tr");
        let tableBodyTds = this.template.querySelectorAll("table tbody .dv-dynamic-width");
        tableBodyRows.forEach(row => {
            let rowTds = row.querySelectorAll(".dv-dynamic-width");
            rowTds.forEach((td, ind) => {
                rowTds[ind].style.width = tableThs[ind].style.width;
            });
        });
    }
}

handledblclickresizable() {
    let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
    let tableBodyRows = this.template.querySelectorAll("table tbody tr");
    tableThs.forEach((th, ind) => {
        th.style.width = this._initWidths[ind];
        th.querySelector(".slds-cell-fixed").style.width = this._initWidths[ind];
    });
    tableBodyRows.forEach(row => {
        let rowTds = row.querySelectorAll(".dv-dynamic-width");
        rowTds.forEach((td, ind) => {
            rowTds[ind].style.width = this._initWidths[ind];
        });
    });
}

paddingDiff(col) {

    if (this.getStyleVal(col, 'box-sizing') === 'border-box') {
        return 0;
    }

    this._padLeft = this.getStyleVal(col, 'padding-left');
    this._padRight = this.getStyleVal(col, 'padding-right');
    return (parseInt(this._padLeft, 10) + parseInt(this._padRight, 10));

}

getStyleVal(elm, css) {
    return (window.getComputedStyle(elm, null).getPropertyValue(css))
}

}