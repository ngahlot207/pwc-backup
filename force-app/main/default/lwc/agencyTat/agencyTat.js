import { LightningElement, track, api, wire } from 'lwc';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import { formattedDateTimeWithoutSeconds } from 'c/dateUtility';
export default class AgencyTat extends LightningElement {

caseData = [];
groupedData = [];
@track _recordId;
@api get recordId() {
    return this._recordId;
}

@api loanAppId;
set recordId(value) {
    this._recordId = value;
    console.log('setter method')
    this.setAttribute("recordId", value);
    this.handleRecordIdChange(value);
    }

@track error;
@track caseTatParams = {
    ParentObjectName: 'Case',
    ChildObjectRelName: '',
    parentObjFields: ['Id','Account.Name','accountId','DateTimeInitiation__c','Date_Time_of_Submission__c','Loan_Application__c','CaseType__c','CaseNumber','TAT__c','Status'],
    childObjFields: [],
    queryCriteria: ''
};

//where Loan_Application__c = \'' + 'a08C4000007x0uSIAQ' + '\' AND accountId != null order by CaseNumber desc

handleRecordIdChange() {
    let tempParams = this.caseTatParams;
    tempParams.queryCriteria = ' where Loan_Application__c = \'' + this._recordId + '\' AND accountId != null order by CaseNumber desc' ;
    this.caseTatParams = { ...tempParams };
    console.log('setter method call')
}


@wire(getSobjectData,{params : '$caseTatParams'})
floatingRateHandler({data,error}){
    if(data){
        console.log('this._recordId:'+this._recordId);
        const options = {
            year: 'numeric',
            month: 'numeric',
            day: 'numeric',
            hour: 'numeric',
            minute: 'numeric'
            };
            
            
        let arrayOfCase = [];
       // console.log('DATA of case data legth ::::>>>>',data.parentRecords.length);
        console.log('DATA of case data  ::::>>>>',JSON.stringify(data.parentRecords));
        if(data.parentRecords){
        data.parentRecords.forEach(row1 => {
        let objValue = {}
        const dateTime1 = new Date(row1.DateTimeInitiation__c);
        const dateTime2 = new Date(row1.Date_Time_of_Submission__c);

        //const formattedDate1 = dateTime1.toLocaleDateString('en-US', options);
        //const formattedDate2 = dateTime2.toLocaleDateString('en-US', options);

        const formattedDate1 = formattedDateTimeWithoutSeconds(dateTime1); 
        const formattedDate2 = formattedDateTimeWithoutSeconds(dateTime2);

        const dateOfIntiation1 = `${formattedDate1}`;
        const dateOfIntiation2 = `${formattedDate2}`;
        console.log('finalFormat:'+dateOfIntiation1);
        console.log('formattedDate2:'+dateOfIntiation2);
        console.log('row1 status:'+row1.Status);
        objValue.CaseNumber = row1.CaseNumber;
        objValue.DateTimeInitiation__c = dateOfIntiation1;
        if(dateOfIntiation2 != 'Invalid Date'){
            objValue.Date_Time_of_Submission__c = dateOfIntiation2;
        }
        
        objValue.CaseType__c = row1.CaseType__c;
        objValue.accountId = row1.accountId;
        objValue.accName = row1.Account.Name;
        objValue.Id = row1.Id;
        if(row1.Status === 'Closed' || row1.Status === 'Cancelled'){
            objValue.TAT__c = row1.TAT__c;
        }
        arrayOfCase.push(objValue);
        });
        this.caseData = arrayOfCase;
        console.log('arrayOfCase:',JSON.stringify(arrayOfCase));
        console.log('DATA of case data json ::::>>>>',JSON.stringify(this.caseData));
        this.groupData();
    }  
    }
    if(error){
        console.error(error);
        this.error = error;
    }
}

groupData() {
    const grouped = {};
    console.log('this.caseData:'+JSON.stringify(this.caseData));
    this.caseData.forEach(record => {
        const caseType = record.CaseType__c;
        const accountName = record.accName;
        console.log('record:',record);

        if (!grouped[caseType]) {
            console.log('Ist If');
            grouped[caseType] = {};
        }
        if (!grouped[caseType][accountName]) {
            grouped[caseType][accountName] = [];
            console.log('2nd If');
        }
        grouped[caseType][accountName].push(record);
        console.log('grouped inside loop:',JSON.stringify(grouped));
    });

    console.log('grouped:',JSON.stringify(grouped));
    this.groupedData = Object.entries(grouped).map(([caseType, accountRecords]) => ({
        caseType,
        accountRecords: Object.entries(accountRecords).map(([accountName, cases]) => ({
            accountName,
            cases,
        })),
    }));
    console.log('this.groupedData:',JSON.stringify(this.groupedData));
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


handlemouseup(e) {
this._tableThColumn = undefined;
this._tableThInnerDiv = undefined;
this._pageX = undefined;
this._tableThWidth = undefined;
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