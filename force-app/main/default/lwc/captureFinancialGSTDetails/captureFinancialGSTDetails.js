import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import getDataForFilterChild from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithFilterRelatedRecords';
import { refreshApex } from '@salesforce/apex';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import deleteFinancialRecord from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';
import getAllChildWithAllParent from '@salesforce/apex/SObjectDynamicRecordProvider.getAllSobjectDatawithRelatedRecords';
import FinancialGSTDetails_Login_Acceptence_Date_Warning_Message from '@salesforce/label/c.FinancialGSTDetails_Login_Acceptence_Date_Warning_Message';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import getSobjectDataNonCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable';
import getFilterRelRecordsWithOutCache from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataWithoutCacheable';
import upsertManualRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleParentsWithMultipleChilds';
const LOANAPPFIELDS = ['LoanAppl__c.LoginAcceptDate__c'];
import { createRecord,updateRecord } from "lightning/uiRecordApi";
import APPL_OBJECT from '@salesforce/schema/Applicant__c';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import SheetJS1 from '@salesforce/resourceUrl/SheetJS1';
import { getObjectInfo, getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import APP_FIN_OBJECT from "@salesforce/schema/Applicant_Financial__c";
let XLS = {};
export default class CaptureFinancialGSTDetails extends LightningElement {

    label = {
        FinancialGSTDetails_Login_Acceptence_Date_Warning_Message
    }

    @api hasEditAccess;
    @track selectedMonth;
    @track selectedYear;
    @track months = [];
    @track years = [];
    gstFinDetails = [];
    @track FinancialRecordId;
    employmentFinancialGSTDetails = [];
    @api tempArray = [];
    showGST = false;
    dateFileVal;
    @api dateFile;
    @track wiredDataFinancial;
    @track wiredDataLoan;
    @track showSpinner = false;
    showUI = false;
    disableMode = false;
    @api last18Months = [];
    @track monthNdYear
    @track monthNdYearForGSTWise
    @track showLocationGST=true;
    @track showConsolidateGST
    @track showConsolidateLANGST
    @track GSTlast12months;
    monthss = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

    @track _applId;
    @api get applId() {
        return this._applId;
    }
    set applId(value) {
        this._applId = value;
        this.setAttribute("applId", value);
        console.log('this._applIdthis._applId'+this._applId)
        this.handleRecordAppId(value);
    }

    @track loanParams = {
        ParentObjectName: 'LoanAppl__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id','LoginAcceptDate__c'],
        childObjFields: [],
        queryCriteria: ' where Id = \'' + this.loanAppId + '\''
    }; 

    /*@track
    parametersAppGST = {
        ParentObjectName: 'ApplGST__c ',
        ChildObjectRelName: 'Applicant_Financials__r',
        parentObjFields: ['Id','GSTIN__c','Applicant__r.Month_Year_For_Location_Wise_GST__c'],
        childObjFields: ['Id','TypeOfFinancial__c','Applicant_GST__c'],
        //queryCriteriaForChild: ' where Type__c = \'Location GST\'',
        queryCriteriaForChild: '',
        queryCriteria: ' where Applicant__c = \'' + this._applId + '\''
    }*/

    @track parametersAppGST = {
        ParentObjectName: 'ApplGST__c ',
        ChildObjectRelName: 'Applicant_Financials__r',
        parentObjFields: ['Id','GSTIN__c','Applicant__r.Month_Year_For_Location_Wise_GST__c'],
        childObjFields: ['Id','TypeOfFinancial__c','Applicant_GST__c'],
        queryCriteriaForChild: '',
        queryCriteria: ' where Applicant__c = \'' + this._applId + '\''
    }
    /*@track paramAppGSTForConsolidate = {
        ParentObjectName: 'ApplGST__c ',
        ChildObjectRelName: 'Applicant_Financials__r',
        parentObjFields: ['Id','GSTIN__c','Applicant__r.Month_Year_For_Location_Wise_GST__c','Type__c'],
        childObjFields: ['Id','TypeOfFinancial__c','Applicant_GST__c'],
        //queryCriteriaForChild: ' where Type__c = \'Location GST\'',
        queryCriteriaForChild: '',
        queryCriteria: ' where Applicant__c = \'' + this._applId + '\' and Type__c = \'Consolidate GST\''
    }*/
        @track paramAppGSTForConsolidate = {
            ParentObjectName: 'Applicant_Financial__c ',
            ChildObjectRelName: 'Applicant_Financial_Summary_s__r',
            parentObjFields: ['Id', 'Loan_Application__c','Applicant_GST__r.GSTIN__c','TypeOfFinancial__c','Loan_Applicant__c','Loan_Applicant__r.FullName__c'],
            childObjFields: ['Id', 'Gross_Turnover_as_per_GST_excl_taxes__c', 'GST_Month_Year__c','Gross_TO_NIL_Rated__c','FilingDate__c', 'Index__c'],
            queryCriteria: ' where Loan_Applicant__c = \'' + this._applId + '\' and Type__c = \'Consolidate GST\''
        }
        @track paramAppGSTForConLAN = {
            ParentObjectName: 'Applicant_Financial__c ',
            ChildObjectRelName: 'Applicant_Financial_Summary_s__r',
            parentObjFields: ['Id', 'Loan_Application__c','Applicant_GST__r.GSTIN__c','TypeOfFinancial__c','Loan_Applicant__c','Loan_Applicant__r.FullName__c'],
            childObjFields: ['Id', 'Gross_Turnover_as_per_GST_excl_taxes__c', 'GST_Month_Year__c','Gross_TO_NIL_Rated__c','FilingDate__c', 'Index__c'],
            queryCriteria: ' where Loan_Application__c = \'' + this._loanAppId + '\' and Type__c = \'LAN Consolidate GST\''
        }
        // to delete extra applicant financial records
     @track paramExtraAppliFinan = {
        ParentObjectName: 'Applicant_Financial__c ',
        ChildObjectRelName: 'Applicant_Financial_Summary_s__r',
        parentObjFields: ['Id', 'Loan_Application__c','Applicant_GST__r.GSTIN__c','TypeOfFinancial__c','Loan_Applicant__c','Loan_Applicant__r.FullName__c'],
        childObjFields: ['Id', 'Gross_Turnover_as_per_GST_excl_taxes__c', 'GST_Month_Year__c', 'Index__c'],
        queryCriteria: ' where Loan_Applicant__c = \'' + this._applId + '\' and Type__c = \'Location GST\' and Applicant_GST__c = \'\''
    }  
    
    @track
    parametersAppFinancialGST = {
        ParentObjectName: 'Applicant_Financial__c ',
        ChildObjectRelName: 'Applicant_Financial_Summary_s__r',
        parentObjFields: ['Id'],
        childObjFields: ['Id', 'Gross_Turnover_as_per_GST_excl_taxes__c', 'GST_Month_Year__c', 'Index__c'],
        queryCriteriaForChild: ' order by Index__c asc',
        queryCriteria: ' where Loan_Applicant__c = \'' + this.applId + '\' and RecordType.DeveloperName = \'GST\''
    }
    financialParentGSTRecId;

    handleRecordAppId(value) {
        let tempParams1 = this.parametersAppFinancialGST;
        tempParams1.queryCriteria = ' where Loan_Applicant__c = \'' + this._applId + '\' and RecordType.DeveloperName = \'GST\' and Type__c = \'\''
        this.parametersAppFinancialGST = {
            ...tempParams1
        };

        let tempParams2 = this.parametersAppGST;
        tempParams2.queryCriteria = ' where Applicant__c = \'' + this._applId + '\''
        this.parametersAppGST = {
            ...tempParams2
        };
        
        let tempParams = this.loanParams;
        tempParams.queryCriteria = ' where Id = \'' + this._loanAppId + '\''
        this.loanParams = {
            ...tempParams
        };

        let tempParamsForCon = this.paramAppGSTForConsolidate;
        tempParamsForCon.queryCriteria = ' where Loan_Applicant__c = \'' + this._applId + '\' and Type__c = \'Consolidate GST\''
        this.paramAppGSTForConsolidate = {
            ...tempParamsForCon
        };

        let tempParamsForConLAN = this.paramAppGSTForConLAN;
        tempParamsForConLAN.queryCriteria = ' where Loan_Application__c = \'' + this._loanAppId + '\' and Type__c = \'LAN Consolidate GST\''
        this.paramAppGSTForConLAN = {
            ...tempParamsForConLAN
        };

        let paramExtraAppliFinan1 = this.paramExtraAppliFinan;
        paramExtraAppliFinan1.queryCriteria = ' where Loan_Applicant__c = \'' + this._applId + '\' and Type__c = \'Location GST\' and Applicant_GST__c = \'\''
        this.paramExtraAppliFinan = {
            ...paramExtraAppliFinan1
        };
        //refreshApex(this.wiredForFinaDataConsolidate);


    }

    arrayForFirstTable;
    async connectedCallback() {
        
        await loadScript(this, SheetJS1); 
        this.version = XLSX.version;
        console.log('version: '+this.version);  
        this.activeSection = ["A", "C"];
        
        if (this.hasEditAccess === false) {
            this.disableMode = true;
        } else {
            refreshApex(this.wiredDataFinancial);
            //refreshApex(this.wiredForFinaDataConsolidate);

            this.disableMode = false;
            if(this.tempArray.length >0){
               
            }else{
                // this.tempArray = [{
                //     'GST_Month_Year__c': '',
                //     'Gross_Turnover_as_per_GST_excl_taxes__c': '',
                //     'Index__c': 1,
                //     'disabled': false
                // }];
                this.arrayForFirstTable = [{
                    'GST_Month_Year__c': '',
                    'Gross_Turnover_as_per_GST_excl_taxes__c': '',
                    'Index__c': 1,
                    'disabled': false
                }];
            }
            /*this.tempArray = [{
                'GST_Month_Year__c': '',
                'Gross_Turnover_as_per_GST_excl_taxes__c': '',
                'Index__c': 1,
                'disabled': false
            }];
            this.arrayForFirstTable = [{
                'GST_Month_Year__c': '',
                'Gross_Turnover_as_per_GST_excl_taxes__c': '',
                'Index__c': 1,
                'disabled': false
            }];)*/

        }
        getSobjectData({ params: this.loanParams })
        .then((result) => {
            console.log('result.parentRecords[0].LoginAcceptDate__c',JSON.stringify(result))
            if (result) {
                if(result.parentRecords && result.parentRecords[0].LoginAcceptDate__c && result.parentRecords[0].LoginAcceptDate__c !== undefined){
                    this.dateFileVal = result.parentRecords[0].LoginAcceptDate__c;
                if (this.dateFileVal !== null) {
                    this.showSpinner = true;
                    this.handleOptions(this.dateFileVal);
                    this.showSpinner = false;
                    
                    setTimeout(() => {
                        refreshApex(this.wiredDataFinancial);
                        this.showUI = true;
                    }, 500);
                    
                }
                }
                 else {
                    this.showToastMessage("Warning", this.label.FinancialGSTDetails_Login_Acceptence_Date_Warning_Message , "warning", "dismissible");
                }
    
            }
        })
        .catch(error =>{
            this.showToastMessage('Error', 'An unexpected error occurred. Please try again.', 'error', 'sticky');
            console.log('Error In FetchGSTRecord---------->',JSON.stringify(error));
          
        });

            console.log('inside connected callback:tempArray 1',JSON.stringify(this.tempArray))

            refreshApex(this.wiredDataFinancial);
            
    }

    @track _loanAppId;
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);
        this.handleRecordAppId(value);
    }

    // getMonthNumber method is used to return the index of month from an monthss array
    getMonthNumber(monthName) {
        const formattedMonthName = monthName.charAt(0).toUpperCase() + monthName.slice(1).toLowerCase();
        const monthIndex = this.monthss.indexOf(formattedMonthName);
        return monthIndex !== -1 ? monthIndex + 1 : -1;
    }

    // handleOptions Method returns data to form options for months selection from Loign Acceptence Date
    async handleOptions(dateValue) {
        const uniqueMonths = new Set();
        this.last18Months = []; 
    
        const currentDate = new Date(dateValue);
        currentDate.setDate(1);
    
        for (let i = 0; i < 18; i++) {
            const date = new Date(currentDate);
            date.setMonth(date.getMonth() - i);
    
            const month = this.monthss[date.getMonth()];
            const year = date.getFullYear().toString().slice(-2);
            const label = `${month} - ${year}`;
    
            if (!uniqueMonths.has(label)) {
                uniqueMonths.add(label);
                this.last18Months.push({
                    label: label,
                    value: label
                });
            }
        }
    }

    getPrevious12Months(startMonthYear) {
        const months = [];
        const monthNames = [
            "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ];
    
        // Split "December - 2023" into month and year
        const [monthName, year] = startMonthYear.split(" - ");
        let currentMonth = monthNames.indexOf(monthName.trim());
        let currentYear = parseInt(year);
    
        for (let i = 0; i < 12; i++) {
            months.push({Index__c : i+1,
                Month__c : `${monthNames[currentMonth]} - ${currentYear}`});
    
            // Move to the previous month
            currentMonth--;
            if (currentMonth < 0) {
                currentMonth = 11;
                currentYear--;
            }
        }
    
        return months;
    }


    // extra record to delete 
    listForDelete=[]
    listForDelete1=[]
    @wire(getAllChildWithAllParent, {
        params: '$paramExtraAppliFinan'
    })
    handleFinancialRecExtra(wiredDeleteRecords) {
        let {error,data } = wiredDeleteRecords;
        this.wiredDeleteRecords = wiredDeleteRecords;
        if (data) {
            console.log('datadatadata>>>>>>>'+JSON.stringify(data))
            if (data.length>0 && data[0].parentRecord) {
                for(const rec of data){
                    const pareRec={"Id":rec.parentRecord.Id

                    }
                    this.listForDelete1.push(pareRec);
                    
                    if(rec.parentRecord.Applicant_Financial_Summary_s__r){
                        for(const rec1 of rec.parentRecord.Applicant_Financial_Summary_s__r){
                            this.listForDelete.push(rec1);
                        }
                    }
                }
                
            }
            
            if(this.listForDelete.length>0){
                console.log('indeletete')
                deleteFinancialRecord({
                    rcrds: this.listForDelete
                })
                .then(result => {
                   console.log('afterdeletetetet')
                    
                })
                .catch(error => {
                    
                })
            }
            if(this.listForDelete1.length>0){
                console.log('indeletete1')
                deleteFinancialRecord({
                    rcrds: this.listForDelete1
                })
                .then(result => {
                   console.log('afterdeletetetet')
                    
                })
                .catch(error => {
                    
                })
            }
            console.log('this.listForDelete'+JSON.stringify(this.listForDelete))
           
        }
        if (error) {
            console.log('Error employmentFinancialGSTDetails-->' + error);
        }
    }
    GSTrecordTypeId;
    @wire(getObjectInfo, { objectApiName: APP_FIN_OBJECT })
    getObjectInfo({ error, data }) {
        if (data) {
        console.log("DATA in RECORD TYPE ID IN TECHINCAL PROP DET #332", data);
        for (let key in data.recordTypeInfos) {
            let recordType = data.recordTypeInfos[key];
            if (recordType.name === "GST") {
            this.GSTrecordTypeId = key;
            //this.wrapLegalCaseObj.RecordTypeId=this.legalRecordTypeId;
            }
        }
        } else if (error) {
        console.error("Error fetching record type Id", error);
        }
    }
    


    mapOfMonWithVal={}
    // Wire Method to fetch Applicant Financial Object for GST Details
    @wire(getDataForFilterChild, {
        params: '$parametersAppFinancialGST'
    })
    handleFinancialResponseGST(wiredFinancialGST) {
        let {error,data } = wiredFinancialGST;
        this.wiredDataFinancial = wiredFinancialGST;
        //this.tempArray=[]
        let tempArray=[]
        if (data) {
            if (data.parentRecord && data.parentRecord.Id) {
                this.financialParentGSTRecId = data.parentRecord.Id;
                //this.getGSTRecords();

            }
            if (data.ChildReords != '' && data.ChildReords != null && typeof data.ChildReords !== 'undefined') {
                this.employmentFinancialGSTDetails = data.ChildReords;
                let mapOfMonWithVal={};
                
                //this.tempArray = [...this.employmentFinancialGSTDetails];
                tempArray = [...this.employmentFinancialGSTDetails];
                this.tempArray=tempArray
                for(const rec of this.tempArray){
                    console.log('recrecrec'+JSON.stringify(rec))
                    mapOfMonWithVal[rec.GST_Month_Year__c]=rec.Gross_Turnover_as_per_GST_excl_taxes__c
                }
                this.mapOfMonWithVal=mapOfMonWithVal
                this.total_Turnover_as_per_GST = this.calculateSum(this.tempArray).toLocaleString();
                let disabledVal;
                this.tempArray = this.employmentFinancialGSTDetails.map(x => {
                    if (x.Index__c === 1 && this.disableMode === false) {
                        disabledVal = false;
                    } else {
                        disabledVal = true;
                    }
                    return {
                        ...x,
                        disabled: disabledVal,
                    };
                });
            }
        }
        if (error) {
            console.log('Error employmentFinancialGSTDetails-->' + error);
        }
    }
    listOfappFinanRecForLoca;
    _wiredForFinancialData
    allGSTrecList=[]
    parentOfGST;
    mapofGSTWithSumm={};
    listOfAllFinana;
    @track appFinanRecForLoca={"sobjectType":"Applicant_Financial__c","Loan_Applicant__c":this._applId, "TypeOfFinancial__c": "Location GST", "Applicant_GST__c":""};
   listOfAllFinana;
    @wire(getAllChildWithAllParent, {
        params: '$parametersAppGST'
    })
    getGSTRecords(wiredForFinancialData) {
        let {error,data } = wiredForFinancialData;
        this._wiredForFinancialData = wiredForFinancialData;
        this.parentOfGST={}
        if (data) {
            const listOfappFinanRecForLoca=[];
            console.log('data.parentRecord111'+JSON.stringify(data))
            if(data && data.length > 0){
            if(data[0].parentRecord && data[0].parentRecord.Applicant__r.Month_Year_For_Location_Wise_GST__c){
                this.monthNdYearForGSTWise=data[0].parentRecord.Applicant__r.Month_Year_For_Location_Wise_GST__c
                this.GSTlast12months = this.getPrevious12Months(this.monthNdYearForGSTWise);
            }
            
            if (data[0].parentRecord) {
                this.parentOfGST=data
                console.log('data.parentRecord1')
                var count=0
                for (const rec of data) {
                    console.log('countcount'+count)
                    count++;
                    console.log('countcount11'+count)
                    if (rec.parentRecord.Applicant_Financials__r) {
                        this.allGSTrecList.push(rec.parentRecord.Applicant_Financials__r);
                    } else {
                        console.log('repeat ' + rec.parentRecord.Id);
                        const appFinanRecForLoca = {
                            "sobjectType": "Applicant_Financial__c",
                            "Loan_Applicant__c": this._applId,
                            "TypeOfFinancial__c": "Location -" + count.toString(),
                            "Applicant_GST__c": rec.parentRecord.Id,
                            "Type__c": "Location GST",
                            "Loan_Application__c": this._loanAppId,
                            "RecordTypeId": this.GSTrecordTypeId
                        };
                        console.log('appFinanRecForLoca', appFinanRecForLoca);
                        listOfappFinanRecForLoca.push(appFinanRecForLoca);
                    }
                }
                /*for(const rec of data){
                    count++
                    if(rec.parentRecord.Applicant_Financials__r){
                        this.allGSTrecList.push(rec.parentRecord.Applicant_Financials__r);
                    }else{
                        console.log('repeat'+rec.parentRecord.Id)
                        const appFinanRecForLoca={"sobjectType":"Applicant_Financial__c","Loan_Applicant__c":this._applId, "Type__c": "Location -"+count, "Applicant_GST__c":rec.parentRecord.Id};
                        //this.appFinanRecForLoca.Applicant_GST__c=rec.parentRecord.Id;
                        console.log('appFinanRecForLoca'+appFinanRecForLoca)
                        listOfappFinanRecForLoca.push(appFinanRecForLoca);
                    }
                }*/
                this.listOfappFinanRecForLoca=listOfappFinanRecForLoca;
                if(this.listOfappFinanRecForLoca.length>0){
                    this.insertAppliFinanRecs();
                }
                setTimeout(() => {
                    refreshApex(this._wiredForFinancialData);
                    //this.addIndexInRec();
                    console.log('this.parentOfGST'+JSON.stringify(this.parentOfGST))
                    let listOfAllFinana=[]
                    for(const rec of this.parentOfGST){
                        console.log('rec'+rec)
                        if(rec.parentRecord.Applicant_Financials__r){
                            listOfAllFinana.push(rec.parentRecord.Applicant_Financials__r[0].Id);
                        }
                        
                    }
                    console.log('this.listOfAllFinana.length'+listOfAllFinana)
                    if(listOfAllFinana.length>0){
                        this.listOfAllFinana=listOfAllFinana
                        console.log('275')
                        const parametersAppFinSumm = {
                            ParentObjectName: 'Applicant_Financial__c ',
                            ChildObjectRelName: 'Applicant_Financial_Summary_s__r',
                            parentObjFields: ['Id','Type__c', 'Applicant_GST__r.GSTIN__c','TypeOfFinancial__c'],
                            childObjFields: ['Id', 'Gross_Turnover_as_per_GST_excl_taxes__c', 'GST_Month_Year__c', 'Index__c'],
                           // queryCriteriaForChild: ' order by Index__c asc',
                            queryCriteria: ' WHERE ID IN (\''+listOfAllFinana.join('\', \'') + '\') and Type__c = \'Location GST\''
                            
                        }
                        this.getFinancialsRecs(parametersAppFinSumm);

                    }
                    

                    
                }, 1000);
                
            }
        }
            
        }
        if (error) {
            console.log('Error employmentFinancialGSTDetails-->' + error);
        }
    }
    @api gstRecsForAllLoca;
    mapofAppliWithSumm={};
    oldListOfGSTrecs=[];
    listOfSummOfAppFin=[];
    getFinancialsRecs(parametersAppFinSumm){
        console.log('this.listOfAllFinana.length')
        this.gstRecsForAllLoca=[]
        getFilterRelRecordsWithOutCache({ params: parametersAppFinSumm })

            .then((data) => {
               console.log('datadatadatadata'+JSON.stringify(data))
                const mapofAppliWithSumm={}
                let count=0
                let listOfSummOfAppFin=[];
                if(data.length>0){
                    this.arrangeRecords(data);
                    for (let i = 0; i < data.length; i++) {
                        if (data[i].parentRecord && data[i].parentRecord.Applicant_GST__r) {
                            console.log('data[i].parentRecord.TypeOfFinancial__c'+data[i].parentRecord.TypeOfFinancial__c)
                            mapofAppliWithSumm[data[i].parentRecord.TypeOfFinancial__c] = data[i].parentRecord.Id;
                        }
                    }

                    for(const rec of data){
                        if(rec.parentRecord.Applicant_Financial_Summary_s__r){
                            for(const rec1 of rec.parentRecord.Applicant_Financial_Summary_s__r){
                                listOfSummOfAppFin.push(rec1);
                            }
                        }
                    }
                }
                this.listOfSummOfAppFin=listOfSummOfAppFin
                console.log('mapofAppliWithSumm>>>>>'+Object.keys(mapofAppliWithSumm))
                console.log('this.listOfSummOfAppFin>>>>>'+JSON.stringify(this.listOfSummOfAppFin))
                this.mapofAppliWithSumm=mapofAppliWithSumm
                this.oldListOfGSTrecs=JSON.parse(JSON.stringify(data))
                this.gstRecsForAllLoca=JSON.parse(JSON.stringify(data))
                this.sortAndReindex(this.gstRecsForAllLoca);
                console.log('this.listOfSummOfAppFin>>>>>'+JSON.stringify(this.listOfSummOfAppFin))
                this.calculationOfParcentage();
               // this.consolidateData();
             })
            .catch(error => {
                console.log('Errorured:-999 '+JSON.stringify(error));
            });
    
    }
    arrangeRecords(records){
        records.sort((a, b) => {
            const aLocation = parseInt(a.parentRecord.TypeOfFinancial__c.split(' -')[1], 10);
            const bLocation = parseInt(b.parentRecord.TypeOfFinancial__c.split(' -')[1], 10);
            return aLocation - bLocation;
        });
        
        // Output the sorted records to the console
        console.log('Sorted Records:', records);
    }
    
    insertAppliFinanRecs(){
        console.log('ininsertAppliFinanRecs'+JSON.stringify(this.listOfappFinanRecForLoca))
        let applicantDetails = {
            Id: this._applId,
            sobjectType: 'Applicant__c',
        };
        let upsertData = {
            parentRecord: applicantDetails,
            ChildRecords: this.listOfappFinanRecForLoca,
            ParentFieldNameToUpdate: 'Loan_Applicant__c'
        }
        upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
        .then(result => {
            if (result) {
                console.log('result'+JSON.stringify(result.ChildReords))
                for(const rec of result.ChildReords){
                    this.allGSTrecList.push(rec);
                }
               // return result.ChildReords;
            }
           
        })
        .catch(error => {
            this.showToastMessage("Error in createApplicantFinancialRecord", error.body.message, "error", "sticky");
            this.showSpinner = false;
        })
    }

    

    // getIndex to return the index no. in an array
    getIndex(array, label) {
        for (let i = 0; i < array.length; i++) {
            if (array[i].label === label) {
                return i; // Return the index if label matches
            }
        }
        return -1; // Return -1 if label is not found
    }

    // calculateSum Method to calculate the summation of Gross_Turnover_as_per_GST_excl_taxes__c
    calculateSum(data) {
        let sum = 0;
        for (let i = 0; i < data.length; i++) {
            const value = parseFloat(data[i].Gross_Turnover_as_per_GST_excl_taxes__c);
            if (!isNaN(value)) {
                sum += value;
            }
        }
        return sum;
    }
    filteredRec = [];
    handleInputChange(event) {
        // if (event.target.dataset.fieldname === 'GST_Month_Year__c') {
        //     this.tempArray[event.target.accessKey - 1].GST_Month_Year__c = event.target.value;
        //     console.log('event.target.accessKey - 1'+event.target.accessKey - 1)
        //     console.log('event.target.accessKey - 11111'+this.mapOfMonWithVal[event.target.value])
        //     this.tempArray[event.target.accessKey - 1].Gross_Turnover_as_per_GST_excl_taxes__c = typeof this.mapOfMonWithVal[event.target.value] !=='undefined' ? this.mapOfMonWithVal[event.target.value] : ''
        //     console.log('this.tempArray'+JSON.stringify(this.tempArray))
        //     let indexofVal = this.getIndex(this.last18Months, event.target.value);
        //     let getMonthNum = event.target.value.split(' - ');
        //     let monthNum = this.getMonthNumber(getMonthNum[0]);
        //     let yearNum = getMonthNum[1];
        //     this.tempArray = [this.tempArray[event.target.accessKey - 1]];
        //     let monthLop = monthNum + 1;
        //     let yearLop = yearNum;
        //     let count = 1;
        //     for (let i = indexofVal - 1; i >= 0; i--) {
        //         this.tempArray.push({
        //             'GST_Month_Year__c': this.last18Months[i].value,
        //             'Gross_Turnover_as_per_GST_excl_taxes__c': typeof this.mapOfMonWithVal[this.last18Months[i].value] !=='undefined' ? this.mapOfMonWithVal[this.last18Months[i].value] : '',
        //             'Index__c': count + 1,
        //             'disabled': 'false'
        //         });
        //         count++;
        //         if (count === 12) {
        //             break;
        //         }
        //     }
        //     this.total_Turnover_as_per_GST = this.calculateSum(this.tempArray).toLocaleString();
        // }
        if (event.target.dataset.fieldname === 'Gross_Turnover_as_per_GST_excl_taxes__c') {
            this.tempArray[event.target.accessKey - 1].Gross_Turnover_as_per_GST_excl_taxes__c = event.target.value;
            this.total_Turnover_as_per_GST = this.calculateSum(this.tempArray).toLocaleString();

        }


    }
    listOfRec;
    last18MonthsforGST
    handleInputChangeForLoc(event){
        this.monthNdYearForGSTWise=event.target.value;
        console.log('this.monthNdYearForGSTWise'+JSON.stringify(this.monthNdYearForGSTWise))
       console.log('this.oldListOfGSTrecs'+JSON.stringify(this.oldListOfGSTrecs))
       console.log('this.gstRecsForAllLoca'+JSON.stringify(this.gstRecsForAllLoca))
       this.GSTlast12months = this.getPrevious12Months(this.monthNdYearForGSTWise);
       console.log('this.GSTlast12months: '+JSON.stringify(this.GSTlast12months))

        this.gstRecsForAllLoca=JSON.parse(JSON.stringify(this.oldListOfGSTrecs))
        for(const record of this.gstRecsForAllLoca){
            if(record.parentRecord.Applicant_Financial_Summary_s__r){
                console.log('iniffffff')
                const mapOfMonthWithTax1={}
                //let mapOfChild={}
                console.log('482')
                for(const rec of record.parentRecord.Applicant_Financial_Summary_s__r){
                    console.log('484')
                    mapOfMonthWithTax1[rec.GST_Month_Year__c]=rec.Gross_Turnover_as_per_GST_excl_taxes__c
                   // mapOfChild[rec.GST_Month_Year__c]=rec
                }
               // let listofkeys=Object.keys(mapOfMonthWithTax)
                //console.log('mapOfMonthWithTax'+Object.keys(mapOfMonthWithTax))
               // record.parentRecord.Applicant_Financial_Summary_s__r[0].GST_Month_Year__c = event.target.value;
                //record.parentRecord.Applicant_Financial_Summary_s__r[0].Gross_Turnover_as_per_GST_excl_taxes__c = typeof mapOfMonthWithTax1[event.target.value] !=='undefined' ? mapOfMonthWithTax1[event.target.value] : '';
                const mapOfMonthWithTax={}
                let mapOfChild={}
                console.log('482')
                for(const rec of record.parentRecord.Applicant_Financial_Summary_s__r){
                    console.log('484')
                    mapOfMonthWithTax[rec.GST_Month_Year__c]=rec.Gross_Turnover_as_per_GST_excl_taxes__c
                    mapOfChild[rec.GST_Month_Year__c]=rec
                }
                let listofkeys=Object.keys(mapOfMonthWithTax)
                console.log('mapOfMonthWithTax'+Object.keys(mapOfMonthWithTax))
                let indexofVal = this.getIndex(this.last18Months, event.target.value);
                let getMonthNum = event.target.value.split(' - ');
                let monthNum = this.getMonthNumber(getMonthNum[0]);
                let yearNum = getMonthNum[1];
               // this.tempArray = [record.parentRecord.Applicant_Financial_Summary_s__r[0]];
                let monthLop = monthNum + 1;
                let yearLop = yearNum;
                let count = 1;
                let listToShow=[]
                for (let i = indexofVal ; i >= 0; i--) {
                    let index=1
                    const taxVal=mapOfMonthWithTax[this.last18Months[i].value]
                    listToShow.push(this.last18Months[i].value)
                    console.log('monthval'+this.last18Months[i].value)
                    
                   console.log('record.parentRecord.Applicant_Financial_Summary_s__r[0]'+mapOfMonthWithTax[this.last18Months[i].value])
                    if(listofkeys.includes(this.last18Months[i].value)){
                       // console.log('inincludeskeyyyy')
                        //record.parentRecord.Applicant_Financial_Summary_s__r.push(mapOfChild[this.last18Months[i].value])
                    }else{
                        console.log('inelseeekeyyyy'+index)
                        record.parentRecord.Applicant_Financial_Summary_s__r.push({
                            'GST_Month_Year__c': this.last18Months[i].value,
                            'Gross_Turnover_as_per_GST_excl_taxes__c': typeof mapOfMonthWithTax[this.last18Months[i].value] !=='undefined' ? mapOfMonthWithTax[this.last18Months[i].value] : '',
                            'Index__c': index,
                            'Applicant_Financial__c': record.parentRecord.Id,
                            'disabled': 'false',
                            
                        });
                    }
                    index++
                    count++;
                    console.log('4133')
                    if (count === 13) {
                        break;
                    }
                }
                let mapofNewRec={}
                for(const rec1 of record.parentRecord.Applicant_Financial_Summary_s__r){
                    mapofNewRec[rec1.GST_Month_Year__c]=rec1
                }
                let listofkeysforNewRec=Object.keys(mapofNewRec)
                console.log('listofkeysforNewRec'+listofkeysforNewRec)
                let listToSplice=[]
                for(const recc of listofkeys){
                    if(listToShow.includes(recc)){

                    }else{
                       const childRecord = mapOfChild[recc];
                       const index = record.parentRecord.Applicant_Financial_Summary_s__r.indexOf(childRecord);
                        if (index !== -1) {
                            record.parentRecord.Applicant_Financial_Summary_s__r.splice(index, 1);
                        }
                    }
                }
                
                console.log('listToSplice'+JSON.stringify(listToSplice))
                console.log('listToSplice'+JSON.stringify(listToSplice.length))
                

            }else{
                console.log('iniffffff')
                record.parentRecord.Applicant_Financial_Summary_s__r = [];
                record.parentRecord.Applicant_Financial_Summary_s__r.push({
                    'GST_Month_Year__c': event.target.value,
                    'Gross_Turnover_as_per_GST_excl_taxes__c': '',
                    'Index__c': 1,
                    'Applicant_Financial__c': record.parentRecord.Id,
                    'disabled': 'false'
                });

                console.log('New Applicant_Financial_Summary_s__r record created');
                let indexofVal = this.getIndex(this.last18Months, event.target.value);
                let getMonthNum = event.target.value.split(' - ');
                let monthNum = this.getMonthNumber(getMonthNum[0]);
                let yearNum = getMonthNum[1];
                let monthLop = monthNum + 1;
                let yearLop = yearNum;
                let count = 1;

                for (let i = indexofVal - 1; i >= 0; i--) {
                    record.parentRecord.Applicant_Financial_Summary_s__r.push({
                        'GST_Month_Year__c': this.last18Months[i].value,
                        'Gross_Turnover_as_per_GST_excl_taxes__c': '',
                        'Index__c': count + 1,
                        'Applicant_Financial__c': record.parentRecord.Id,
                        'disabled': 'false'
                    });
                    count++;
                    if (count === 12) {
                        break;
                    }
                }
            }
        }
        this.sortAndReindex(this.gstRecsForAllLoca);
        this.calculationOfParcentage();


        ////
        //if (event.target.dataset.fieldname === 'GST_Month_Year__c') {
            // this.tempArray[event.target.accessKey - 1].GST_Month_Year__c = event.target.value;
            // console.log('event.target.accessKey - 1'+event.target.accessKey - 1)
            console.log('event.target.accessKey - '+this.mapOfMonWithVal[event.target.value])
            //this.tempArray[event.target.accessKey - 1].Gross_Turnover_as_per_GST_excl_taxes__c = typeof this.mapOfMonWithVal[event.target.value] !=='undefined' ? this.mapOfMonWithVal[event.target.value] : ''
            console.log('this.tempArray'+JSON.stringify(this.tempArray))
            let indexofVal = this.getIndex(this.last18Months, event.target.value);
            // let getMonthNum = event.target.value.split(' - ');
            // let monthNum = this.getMonthNumber(getMonthNum[0]);
            // let yearNum = getMonthNum[1];
            // //this.tempArray = [this.tempArray[event.target.accessKey - 1]];
            // let monthLop = monthNum + 1;
            // let yearLop = yearNum;
            this.tempArray =[]
            let count = 1;
            for (let i = indexofVal ; i >= 0; i--) {
                this.tempArray.push({
                    'GST_Month_Year__c': this.last18Months[i].value,
                    'Gross_Turnover_as_per_GST_excl_taxes__c': typeof this.mapOfMonWithVal[this.last18Months[i].value] !=='undefined' ? this.mapOfMonWithVal[this.last18Months[i].value] : '',
                    'Index__c': count,
                    'disabled': 'false'
                });
                count++;
                if (count === 12) {
                    break;
                }
            }
            this.total_Turnover_as_per_GST = this.calculateSum(this.tempArray).toLocaleString();
        //}
        ////

    }
    sortAndReindex(records) {
        records.forEach(record => {
            if(record.parentRecord.Applicant_Financial_Summary_s__r){
                let financialSummary = record.parentRecord.Applicant_Financial_Summary_s__r;
    
            // Convert GST_Month_Year__c to Date for sorting
            financialSummary.sort((a, b) => {
                let dateA = this.convertToDate(a.GST_Month_Year__c);
                let dateB = this.convertToDate(b.GST_Month_Year__c);
                return dateA - dateB;
            });
    
            // Update Index__c based on sorted order
            financialSummary.forEach((item, index) => {
                item.Index__c = index + 1;
            });
            }
            
        });
        return records;
    }
    
    convertToDate(gstMonthYear) {
        let [month, year] = gstMonthYear.split(' - ');
        let dateStr = `01 ${month} 20${year}`;
        return new Date(dateStr);
    }
    calculationOfParcentage(){
        console.log('this.gstRecsForAllLoca calculationOfParcentage:: ',JSON.stringify(this.gstRecsForAllLoca))
        this.gstRecsForAllLoca = this.gstRecsForAllLoca.map((item) => {
            // Calculate total of Gross_Turnover_as_per_GST_excl_taxes__c
            const totalGrossTurnover = item.parentRecord.Applicant_Financial_Summary_s__r.reduce((acc, summary) => {
                const turnover = parseFloat(summary.Gross_Turnover_as_per_GST_excl_taxes__c) || 0;
                return acc + turnover;
            }, 0);
            // Add total to parentRecord
            item.parentRecord.Total_Gross_Turnover__c = totalGrossTurnover;
            if(item.parentRecord.Total_Gross_Turnover__c !==0){
                item.parentRecord.Percentage_Total_Gross_Turnover__c= 100
            }else{
                item.parentRecord.Percentage_Total_Gross_Turnover__c= 0
            }
            // Calculate percentage and add to each Applicant_Financial_Summary_s__r
            item.parentRecord.Applicant_Financial_Summary_s__r = item.parentRecord.Applicant_Financial_Summary_s__r.map(summary => {
                const turnover = parseFloat(summary.Gross_Turnover_as_per_GST_excl_taxes__c) || 0;
                const percentage = totalGrossTurnover ? (turnover * 100 / totalGrossTurnover) : 0;
                return {
                    ...summary,
                    Percentage_of_Total_Turnover__c: percentage.toFixed(2) // To limit the decimal places to 2
                };
            });

            return item;
        });
        console.log('this.gstRecsForAllLoca'+JSON.stringify(this.gstRecsForAllLoca))
    }
    handleInputChangeForTaxGst(event){
        if (event.target.dataset.fieldname === 'Gross_Turnover_as_per_GST_excl_taxes__c') {
            console.log('event.target.accessKey'+event.target.accessKey)
            let parentIndex = event.target.dataset.parentIndex;
            let childIndex = event.target.dataset.cloumnIndex;
            let fullParentRecord = this.gstRecsForAllLoca[parentIndex];
            console.log('parentRecord'+JSON.stringify(fullParentRecord))
            let childRecords = fullParentRecord.parentRecord.Applicant_Financial_Summary_s__r[childIndex];
            let fieldName = event.target.dataset.fieldname;
            childRecords[fieldName] = event.target.value;
        }
        this.calculationOfParcentage();
    }

    

    total_Turnover_as_per_GST = 0;

    @api handleUpsert(validate) {
        this.filteredRec = this.tempArray.map(item => {
            return {
                sobjectType: 'Applicant_Financial_Summary__c',
                Id: item.Id,
                Index__c: item.Index__c ? item.Index__c : '',
                GST_Month_Year__c: item.GST_Month_Year__c ? item.GST_Month_Year__c : '',
                Gross_Turnover_as_per_GST_excl_taxes__c: item.Gross_Turnover_as_per_GST_excl_taxes__c ? item.Gross_Turnover_as_per_GST_excl_taxes__c : '',
                Applicant_Financial__c: this.financialParentGSTRecId
            };
        });

        const newArray = this.employmentFinancialGSTDetails.filter(item1 => !this.tempArray.find(item2 => item2.Id === item1.Id));
        console.log('newArraynewArray'+JSON.stringify(newArray))
        if (newArray.length > 0) {
            deleteFinancialRecord({
                    rcrds: newArray
                })
                .then(result => {
                    refreshApex(this.wiredDataFinancial);
                })
                .catch(error => {
                    this.showToastMessage("Error In handleDeleteAction ", error.body.message, "error", "sticky");
                    this.showDeleteConfirmation = false;
                })
        }

        let fields = {};
        fields = {
            Id: this.applId,
            Total_Turnover_as_per_GST__c: this.total_Turnover_as_per_GST,
            Month_Year_For_Location_Wise_GST__c: this.monthNdYearForGSTWise
        }
        this.filteredRec = [...this.filteredRec, fields];
        console.log('filteredRecfilteredRec'+JSON.stringify(this.filteredRec))
        console.log('financialParentGSTRecId'+this.financialParentGSTRecId)
        if (this.financialParentGSTRecId) {
            upsertMultipleRecord({
                    params: this.filteredRec
                })
                .then(result => {
                    this.showToastMessage('Success', ' Details Saved Successfully.', 'success', 'sticky');
                    this.handleSaveForGSTdata();
                    refreshApex(this.wiredDataFinancial);
                    refreshApex(this._wiredForFinancialData);
                }).catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: error.body.message,
                            variant: 'error',
                            mode: 'sticky'
                        })

                    );
                    console.log('Error 267-->' + JSON.stringify(error))
                })

        }
        refreshApex(this.wiredDataFinancial);
        this.template.querySelector('c-location-wise-g-s-t-table-data').handleUpsertLocWise(validate);
    }
    saveApplicantRec(){
        const fields = {};        
        fields.Id = this._applId;
        fields.Month_Year_For_Location_Wise_GST__c = this.monthNdYearForGSTWise;
         const recordInput = {
            apiName: APPL_OBJECT.objectApiName,
            fields: fields
          };

          updateRecord(recordInput)
        .then((record) => {
            console.log('recordrecordrecord')

        })
        .catch((err) => {
            this.showToast("Error", "error",this.label.BankingDetails_CreateRecord_ErrorMessage + JSON.stringify(err));
        });
    }
    GSTRecForDelete;
    handleSaveForGSTdata(){
      // console.log('this.gstRecsForAllLoca'+JSON.stringify(this.gstRecsForAllLoca))
        const ListOfDelete=[];
        const oldDataMap = this.createDataMap(this.oldListOfGSTrecs);
        const newDataMap = this.createDataMap(this.gstRecsForAllLoca);
        this.gstRecsForAllLoca.forEach(newRecord => {
            const oldRecord = oldDataMap[newRecord.parentRecord.Id];
            if (oldRecord) {
                const newSummaryMap = this.createSummaryMap(newRecord.parentRecord.Applicant_Financial_Summary_s__r);
                if(oldRecord.Applicant_Financial_Summary_s__r){
                    oldRecord.Applicant_Financial_Summary_s__r.forEach(oldSummary => {
                        if (!newSummaryMap[oldSummary.GST_Month_Year__c]) {
                            ListOfDelete.push(oldSummary);
                           // newRecord.parentRecord.Applicant_Financial_Summary_s__r.push(oldSummary);
                        }
                    });
                }
                
            }
        });
        this.GSTRecForDelete=ListOfDelete;
        this.methodForDeleteGSTRecords(this.GSTRecForDelete)
        let DataRecords = [];
        let DataRecordObj = {};
        let ChildRecordObj = {};
        for(var i=0;i<this.gstRecsForAllLoca.length;i++){
            DataRecordObj = {};
            ChildRecordObj = {};
            DataRecordObj.parentRecord=this.gstRecsForAllLoca[i].parentRecord;
            DataRecordObj.parentRecord.sobjectType ='Applicant_Financial__c';
            let ChildRecordArr= [];
            if(this.gstRecsForAllLoca[i].parentRecord.Applicant_Financial_Summary_s__r){
                for(var j=0; j<this.gstRecsForAllLoca[i].parentRecord.Applicant_Financial_Summary_s__r.length; j++){
                    ChildRecordObj = this.gstRecsForAllLoca[i].parentRecord.Applicant_Financial_Summary_s__r[j];
                    ChildRecordObj.sobjectType='Applicant_Financial_Summary__c';
                    ChildRecordArr.push(ChildRecordObj);
                }
            }

            DataRecordObj.ChildRecords= ChildRecordArr;                    
            DataRecordObj.ParentFieldNameToUpdate='Applicant_Financial__c';
            
            DataRecords.push(DataRecordObj);
        }
        console.log('DataRecordsDataRecords'+JSON.stringify(DataRecords))
        upsertManualRecord({upsertData:DataRecords})
        .then(result => {                     
        console.log('resultresult'+result)
        setTimeout(() => {
            this.consolidateData() 
            this.consolidateDataForLAN();
        }, 1500);
        
        refreshApex(this._wiredForFinancialData);
        }).catch(error => {
            console.log('739'+JSON.stringify(error));
        })
            
    }
    methodForDeleteGSTRecords(recordsToDelete){
        console.log('recordsToDelete'+JSON.stringify(recordsToDelete))
        if (recordsToDelete.length > 0) {
            deleteFinancialRecord({
                    rcrds: recordsToDelete
                })
                .then(result => {
                    setTimeout(() => {
                        refreshApex(this._wiredForFinancialData);
                    }, 500);
                    setTimeout(() => {
                        this.consolidateData() 
                        this.consolidateDataForLAN();
                    }, 1500);
                    
                })
                .catch(error => {
                    
                })
        }else{
            refreshApex(this._wiredForFinancialData);
        }

    }
    createDataMap(data) {
        const dataMap = {};
        data.forEach(record => {
            dataMap[record.parentRecord.Id] = record.parentRecord;
        });
        return dataMap;
    }

    createSummaryMap(summaries) {
        const summaryMap = {};
        summaries.forEach(summary => {
            summaryMap[summary.GST_Month_Year__c] = summary;
        });
        return summaryMap;
    }

    @api validateForm() {
        const isInputCorrect = [
            ...this.template.querySelectorAll("lightning-input"),
            ...this.template.querySelectorAll("lightning-combobox")
        ].reduce((validSoFar, inputField) => {

            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
        if (isInputCorrect === false) {
            this.showToastMessage("Error", 'Please provide correct input to all fields.', "error", "sticky");

        }
        return isInputCorrect;
    }
    

    renderedCallBack(){
        refreshApex(this.wiredDataFinancial);
        refreshApex(this._wiredForFinancialData);
    }

    showToastMessage(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
    @track showUploadWind
    @track uploadedFiles=[];
    @track acceptedFormats = ['.xls', '.xlsx'];
    data;
    handleUploadExcelSheet(){
        this.showConsolidateGST=false
        this.showLocationGST=true
        this.showConsolidateLANGST=false
        this.showUploadWind=true
    }
    hideManualUplModalBox(){
        this.showUploadWind=false;
        this.uploadedFiles='';
    }
    handleFileRemove(){
        this.uploadedFiles=''
    }
    handleUploadFinished(event){
        this.uploadedFiles = event.detail.files;
        const file=this.uploadedFiles[0]
        const fileType = '.' + file.name.split('.').pop();
        console.log('fileTypefileTypefileType>>>>'+fileType);
        if(fileType=='.xls' ||fileType=='.xlsx'){
           
        }else{
            this.showToastMessage('Error', 'You can only upload excel format type file.', 'error', 'sticky');
           // this.showToastMessage("Error!", "error","You can only upload excel format type file."); 
            this.uploadedFiles=[];
        }
    }
    handleExcelUpload(){
        // console.log('inhandleExcelUpload'+this.uploadedFiles)
        if(this.uploadedFiles.length > 0) {   
        //  console.log('uploadedFiles.length'+this.uploadedFiles.length)
            this.ExcelToJSON(this.uploadedFiles[0]);
        }else{
            console.log('inelseeeee')
            this.showToastMessage("Error!", "error","please select File First.");
        }
    }
    records
    ExcelToJSON(file){
        this.showSpinner=true;
        console.log('this.uploadedFiles'+this.uploadedFiles.length)
        this.records=[];
        if (file) {
            const reader = new FileReader();
            reader.onload = () => {
                const workbook = XLSX.read(reader.result, { type: 'binary' });
                const sheetName = workbook.SheetNames[0]; // Assuming the first sheet
                const sheet = workbook.Sheets[sheetName];
                const jsonData = XLSX.utils.sheet_to_row_object_array(sheet);
                console.log('jsonData'+JSON.stringify(jsonData)); // Output JSON data to console
                var data = JSON.stringify(jsonData);
                
                this.records = JSON.parse(data);
                console.log('objobjobjobj>>>>>>>>>jsonStr',JSON.stringify(this.records));
                for (const rec of this.records){
                    for (const key of Object.keys(rec)) {
                        if (key === "") {
                            rec['__EMPTY'] = rec[key];
                            delete rec[key];
                        } if (key === "_1") {
                            rec['__EMPTY_1'] = rec[key];
                            delete rec[key];
                        }
                        if (key === "_2") {
                            rec['__EMPTY_2'] = rec[key];
                            delete rec[key];
                        }
                        if (key === "_3") {
                            rec['__EMPTY_3'] = rec[key];
                            delete rec[key];
                        }
                        
                        if (key === "_4") {
                            rec['__EMPTY_4'] = rec[key];
                            delete rec[key];
                        }
                        if (key === "_5") {
                            rec['__EMPTY_5'] = rec[key];
                            delete rec[key];
                        }
                        
                    }
                }
                this.data=this.records;
                this.parseJsonData();
               // this.createRecordForSave(records);
                    
            };
            reader.readAsBinaryString(file);
            
        }
    }
    locationRecords=[];
    monthNames=[];
    monthYear
    parseJsonData() {
        console.log('parseJsonData'+JSON.stringify(this.data))
        let currentLocation = null;
        let locationSummaries = [];
        this.locationRecords=[];


        this.data.forEach(record => {
           // console.log('record["__EMPTY"]'+record["__EMPTY"])
            let slNo = record["GST summary"];
            if (typeof slNo === 'string' && slNo.startsWith("Location")) {
                if (currentLocation) {
                    this.locationRecords.push({
                        location: currentLocation,
                        summaries: locationSummaries
                    });
                }
                currentLocation = slNo;
                locationSummaries = [];
            } else if (typeof slNo === 'number') {
                let monthSerial = record["__EMPTY"];
                console.log('monthSerial'+typeof monthSerial)
                let grossToExclTaxes = record["__EMPTY_1"];
                let percentage = record["__EMPTY_2"] || 0;
                let monthYear;
                if(typeof monthSerial ==='number'){
                    monthYear = this.convertExcelDate(monthSerial);
                }else{
                    monthYear=monthSerial
                }
                
                //console.log('monthYearmonthYear'+monthYear)
                locationSummaries.push({
                    SlNo: slNo,
                    Month: monthYear,
                    GrossToExclTaxes: grossToExclTaxes
                    //Percentage: percentage
                });
            }
        });

        console.log('locationSummaries'+JSON.stringify(locationSummaries))
        console.log('currentLocation'+JSON.stringify(currentLocation))

        if (currentLocation) {
            this.locationRecords.push({
                location: currentLocation,
                summaries: locationSummaries
            });
        }
       console.log('Object.keys(this.data[0])[0]'+Object.keys(this.data[0])[0])
       // if(Object.keys(this.data[0])[0]!='GST summary for FY 2022-23'){
       if(!Object.keys(this.data[0])[0].includes('GST summary')){
            this.showSpinner=false       
            this.showToastMessage('Error', 'Please Upload correct format of file.', 'error', 'sticky');

        }else{
            this.createApplicantFinancialRecords();
        }
        
    }
    

    convertExcelDate(serial) {
        //const baseDate = new Date(1899, 11, 30);
        //const excelDate = new Date(baseDate.getTime() + serial * 24 * 60 * 60 * 1000);
        //return excelDate.toLocaleString('default', { month: 'long', year: '2-digit' });
        const baseDate = new Date(1899, 11, 30);
        const excelDate = new Date(baseDate.getTime() + serial * 24 * 60 * 60 * 1000);
        const month = excelDate.toLocaleString('default', { month: 'long' });
        const year = excelDate.getFullYear(); // Get the full 4-digit year
        return `${month} - ${year}`;
    }

    createApplicantFinancialRecords() {
        let listOfAppliFinanRec=Object.keys(this.mapofAppliWithSumm)
        console.log('listOfAppliFinanRec'+listOfAppliFinanRec)
        console.log('this.locationRecords'+JSON.stringify(this.locationRecords))
        let count=0
        let applicantFinancialRecords = this.locationRecords.map(location => {
            let applicantFinancialRecord = {
                //Applicant_Financial__c: location.location,
                    Applicant_Financial__c: this.mapofAppliWithSumm[listOfAppliFinanRec[count]],
                    Applicant_Financial_Summary__c: location.summaries.map(summary => ({
                    GST_Month_Year__c: summary.Month,
                    Gross_Turnover_as_per_GST_excl_taxes__c: summary.GrossToExclTaxes,
                    Index__c:summary.SlNo
                }))
            };
            count++;
            return applicantFinancialRecord;
        });
        this.applicantFinancialRecords=applicantFinancialRecords;
        console.log('applicantFinancialRecords'+JSON.stringify(applicantFinancialRecords))
        this.showSpinner=false  
        this.saveRecords();
    }
    applicantFinancialRecords;
    saveRecords() {
        console.log('saveRecordssaveRecords')
        let DataRecords = [];
        let DataRecordObj = {};
        let ChildRecordObj = {};
        console.log('saveRecordssaveRecords11')
        for(var i=0;i<this.applicantFinancialRecords.length;i++){
            console.log('saveRecordssaveRecords12')
            DataRecordObj = {};
            ChildRecordObj = {};
            console.log('saveRecordssaveRecords13'+JSON.stringify(DataRecordObj))
            let parentObj={"Id": this.applicantFinancialRecords[i].Applicant_Financial__c}
            DataRecordObj.parentRecord=parentObj;
            console.log('saveRecordssaveRecords14'+JSON.stringify(DataRecordObj))
            DataRecordObj.parentRecord.sobjectType ='Applicant_Financial__c';
            console.log('DataRecordObj'+JSON.stringify(DataRecordObj))
            let ChildRecordArr= [];
            if(this.applicantFinancialRecords[i].Applicant_Financial_Summary__c){
                console.log('DataRecordObj11111')
                for(var j=0; j<this.applicantFinancialRecords[i].Applicant_Financial_Summary__c.length; j++){
                    console.log('DataRecordObj'+JSON.stringify(this.applicantFinancialRecords[i].Applicant_Financial_Summary__c[j]))
                    ChildRecordObj = this.applicantFinancialRecords[i].Applicant_Financial_Summary__c[j];
                    ChildRecordObj.sobjectType='Applicant_Financial_Summary__c';
                    console.log('DataRecordObj222'+JSON.stringify(ChildRecordObj))
                    ChildRecordArr.push(ChildRecordObj);
                }
            }
            DataRecordObj.ChildRecords= ChildRecordArr;                    
            DataRecordObj.ParentFieldNameToUpdate='Applicant_Financial__c';
            DataRecords.push(DataRecordObj);
        }
        console.log('DataRecordObjDataRecordObj'+JSON.stringify(DataRecords))

        upsertManualRecord({upsertData:DataRecords})
        .then(result => {          
            this.showSpinner=false           
            console.log('resultresult'+result)
            this.methodForDeleteGSTRecords(this.listOfSummOfAppFin)
            refreshApex(this._wiredForFinancialData);
            this.records=[];
            this.uploadedFiles=[];
            this.showUploadWind=false
            this.locationRecords=[]
            setTimeout(() => {
                if(this.listOfAllFinana.length>0){
                    const parametersAppFinSumm = {
                        ParentObjectName: 'Applicant_Financial__c ',
                        ChildObjectRelName: 'Applicant_Financial_Summary_s__r',
                        parentObjFields: ['Id', 'Loan_Application__c','Applicant_GST__r.GSTIN__c','TypeOfFinancial__c'],
                        childObjFields: ['Id', 'Gross_Turnover_as_per_GST_excl_taxes__c', 'GST_Month_Year__c', 'Index__c'],
                    // queryCriteriaForChild: ' order by Index__c asc',
                        queryCriteria: ' WHERE ID IN (\''+this.listOfAllFinana.join('\', \'') + '\')'
                        
                    }
                    this.getFinancialsRecs(parametersAppFinSumm);
        
                }
            }, 1000);
        /*if(this.listOfAllFinana.length>0){
            const parametersAppFinSumm = {
                ParentObjectName: 'Applicant_Financial__c ',
                ChildObjectRelName: 'Applicant_Financial_Summary_s__r',
                parentObjFields: ['Id', 'Applicant_GST__r.GSTIN__c','TypeOfFinancial__c'],
                childObjFields: ['Id', 'Gross_Turnover_as_per_GST_excl_taxes__c', 'GST_Month_Year__c', 'Index__c'],
               // queryCriteriaForChild: ' order by Index__c asc',
                queryCriteria: ' WHERE ID IN (\''+this.listOfAllFinana.join('\', \'') + '\')'
                
            }
            this.getFinancialsRecs(parametersAppFinSumm);

        }*/
        this.showToastMessage('Success', 'Manual GST file uploaded successfully.', 'success', 'sticky');
        
        //this.showMessage();
        //refreshApex(this._wiredManualData);
                    
        
        }).catch(error => {
            if(this.showSpinner==true){
                this.showSpinner=false    
                this.showToastMessage('Error', 'Please Upload correct format of file.', 'error', 'sticky');  
                console.log('739'+JSON.stringify(error));
            }
            
        })
    }
    dataForExcel=[];
    handleDownExcelSheet(){
        console.log('1')
        this.showConsolidateGST=false
        this.showLocationGST=true
        this.showConsolidateLANGST=false
        console.log('2')
        let headingRec={"GST summary":"Sl.no","__EMPTY":"Month","__EMPTY_1":"Gross TO excl taxes","__EMPTY_2":"%","__EMPTY_3":""}
        let blankRec={"GST summary":"","__EMPTY":"","__EMPTY_1":"","__EMPTY_2":"","__EMPTY_3":""}
        let totalRec={"GST summary":"Total","__EMPTY":"","__EMPTY_1":"","__EMPTY_2":"","__EMPTY_3":""}
        console.log('1')
        this.dataForExcel.push(headingRec);
        console.log('1')
        console.log('this.gstRecsForAllLoca[0].parentRecord'+JSON.stringify(this.gstRecsForAllLoca[0].parentRecord))
        if(this.gstRecsForAllLoca[0].parentRecord && this.gstRecsForAllLoca[0].parentRecord.Applicant_Financial_Summary_s__r && this.gstRecsForAllLoca[0].parentRecord.Applicant_Financial_Summary_s__r.length>0){
           /* for(let i=0; i<this.gstRecsForAllLoca[0].parentRecord.Applicant_Financial_Summary_s__r.length; i++){
                const childRec=this.gstRecsForAllLoca[0].parentRecord.Applicant_Financial_Summary_s__r[i]
                const conRec={"GST summary":childRec.Index__c,"__EMPTY":childRec.GST_Month_Year__c,"__EMPTY_1":"","__EMPTY_2":"","__EMPTY_3":""}               
                this.dataForExcel.push(conRec)
            }
            
            this.dataForExcel.push(totalRec);
            this.dataForExcel.push(blankRec);*/
            let merge=[];
            const firstRec={ s: { r: 0, c: 0 }, e: { r: 0, c: 3 } }
            merge.push(firstRec)
            let numberOfRecList=[];
            this.gstRecsForAllLoca.forEach(record => {
                const parent = record.parentRecord;
                const locationRec={"GST summary":parent.TypeOfFinancial__c+"(GST NUMBER- "+parent.Applicant_GST__r.GSTIN__c+")","__EMPTY":"","__EMPTY_1":"","__EMPTY_2":"","__EMPTY_3":""} 
                
                this.dataForExcel.push(locationRec);
                const lengthofrec=this.dataForExcel.length
                const rectomerge={ s: { r: lengthofrec, c: 0 }, e: { r: lengthofrec, c: 3 } }
                merge.push(rectomerge)
                numberOfRecList.push(record.parentRecord.Applicant_Financial_Summary_s__r.length)
                record.parentRecord.Applicant_Financial_Summary_s__r.forEach(child => {
                    
                    const recsForLoca={"GST summary":child.Index__c,"__EMPTY":child.GST_Month_Year__c,"__EMPTY_1":child.Gross_Turnover_as_per_GST_excl_taxes__c,"__EMPTY_2":"","__EMPTY_3":""} 
                    this.dataForExcel.push(recsForLoca);
                });
                this.dataForExcel.push(totalRec);
                this.dataForExcel.push(blankRec);
            });

           console.log('numberOfRecList'+numberOfRecList)
            const worksheet = XLSX.utils.json_to_sheet(this.dataForExcel);
            console.log('datadatadata11')
            worksheet["A1"].v = "GST summary"; // Change A1 cell (Name column header)
            worksheet["B1"].v = ""; // Change B1 cell (Age column header)
            worksheet["C1"].v = "";
            worksheet["D1"].v = "";
            worksheet["E1"].v = ""; // Change E1 cell
            const lenthofsheet=this.dataForExcel.length
           // const merge = [
              //  { s: { r: 0, c: 0 }, e: { r: 0, c: 5 } }, { s: { r: lenthofsheet, c: 0 }, e: { r: lenthofsheet, c: 5 } }];
            worksheet["!merges"] = merge;
            
            let numberOfRecs=this.gstRecsForAllLoca[0].parentRecord.Applicant_Financial_Summary_s__r.length
            for (let i = 0; i < this.gstRecsForAllLoca[0].parentRecord.Applicant_Financial_Summary_s__r.length; i++) {
                const rangeForC = `C4:C${3+numberOfRecs}`;
                XLSX.utils.sheet_set_array_formula(worksheet, `C${4+numberOfRecs}`, `SUM(${rangeForC})`);
                const rangeForD = `IFERROR(C${4+numberOfRecs}*100/C${4+numberOfRecs},"")`;
                XLSX.utils.sheet_set_array_formula(worksheet, `D${4+numberOfRecs}`, rangeForD);
            }
            let k=0
            console.log('this.gstRecsForAllLoca'+JSON.stringify(this.gstRecsForAllLoca))
            for(let i = 0; i < this.gstRecsForAllLoca.length; i++){
                debugger
                for(let j=0; j<this.gstRecsForAllLoca[i].parentRecord.Applicant_Financial_Summary_s__r.length; j++){
                    const formulaForParentage= `IFERROR(ROUND(C${4+j+k}*100/C${4+numberOfRecs+k},2),"")`;
                    const cellForD = `D${4+j+k}`;
                    XLSX.utils.sheet_set_array_formula(worksheet, cellForD, formulaForParentage); 
                }
                //onst cellForCtotal = `C${3+numberOfRecs+k}`;
                //const totalForForC=`C${3+k}:C${2+numberOfRecs+k}`;
                const cellForDtotal = `D${4+numberOfRecs+k}`;
                const perentageForD=`IFERROR(ROUND(C${4+numberOfRecs+k}*100/C${4+numberOfRecs+k},2),"")`;
               // XLSX.utils.sheet_set_array_formula(worksheet, cellForCtotal, `SUM(${totalForForC})`);
                XLSX.utils.sheet_set_array_formula(worksheet, cellForDtotal, perentageForD);
                k=k+4
                console.log('kkkkkkkkk'+k)
            }
            

            /*
            for (let i = 0; i < this.gstRecsForAllLoca[0].parentRecord.Applicant_Financial_Summary_s__r.length; i++) {
                const rangeForC = `C3:C${2+numberOfRecs}`;
                XLSX.utils.sheet_set_array_formula(worksheet, `C${3+numberOfRecs}`, `SUM(${rangeForC})`);
                const rangeForD = `IFERROR(C${3+numberOfRecs}*100/C${3+numberOfRecs},"")`;
                XLSX.utils.sheet_set_array_formula(worksheet, `D${3+numberOfRecs}`, rangeForD);
            }

            //`IFERROR(B15/(B7+B6),"")`;
            for (let i = 0; i < this.gstRecsForAllLoca[0].parentRecord.Applicant_Financial_Summary_s__r.length; i++) {
                let k=0
                let formulaParts = [];
                for (const rec of numberOfRecList) {
                    k=k+rec+3
                    console.log('kkkkkk>>>>'+k)
                    formulaParts.push(`C${i + 3 + k}`);
                }
                const formula = `SUM(${formulaParts.join(",")})`;
                const cell = `C${i+3}`;
                XLSX.utils.sheet_set_array_formula(worksheet, cell, formula);
                const formulaForParentage = `IFERROR(ROUND(C${i+3}*100/C${3+numberOfRecs},2),"")`;
                const cellForD = `D${i+3}`;
                XLSX.utils.sheet_set_array_formula(worksheet, cellForD, formulaForParentage);
            }
            //FOR PERCENTANGE AND FORMULA OF TOTAL
            let k=0
            console.log('this.gstRecsForAllLoca'+JSON.stringify(this.gstRecsForAllLoca))
            for(let i = 0; i < this.gstRecsForAllLoca.length; i++){
                k=k+numberOfRecs+3
                for(let j=0; j<this.gstRecsForAllLoca[i].parentRecord.Applicant_Financial_Summary_s__r.length; j++){
                    const formulaForParentage= `IFERROR(ROUND(C${3+j+k}*100/C${3+numberOfRecs+k},2),"")`;
                    const cellForD = `D${3+j+k}`;
                    XLSX.utils.sheet_set_array_formula(worksheet, cellForD, formulaForParentage); 
                }
                const cellForCtotal = `C${3+numberOfRecs+k}`;
                const totalForForC=`C${3+k}:C${2+numberOfRecs+k}`;
                const cellForDtotal = `D${3+numberOfRecs+k}`;
                const perentageForD=`IFERROR(ROUND(C${3+numberOfRecs+k}*100/C${3+numberOfRecs+k},2),"")`;
                XLSX.utils.sheet_set_array_formula(worksheet, cellForCtotal, `SUM(${totalForForC})`);
                XLSX.utils.sheet_set_array_formula(worksheet, cellForDtotal, perentageForD);
            }
*/
            
            
            const workbook = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(workbook, worksheet, 'Sheet1');
            XLSX.writeFile(workbook, 'GST_Detail_Sheet.xlsx');
            this.dataForExcel=[];
        }else{
            this.showToastMessage('Error', 'Please Add Month-Year First For Download Excel.', 'error', 'sticky');
        }
    
    }

    // CODE FOR CONSOLIDATE GST DATA APPLICANT AND CO-APPLICANT WISE
    newConsolidateFinanList=[];
    consolidateData() {
        const dataMap = new Map();
        let listForConsolidate=JSON.parse(JSON.stringify(this.gstRecsForAllLoca))
        listForConsolidate.forEach(record => {
            record.parentRecord.Applicant_Financial_Summary_s__r.forEach(summary => {
                if (!dataMap.has(summary.GST_Month_Year__c)) {
                    if(typeof this.mapOfMonthWithTaxConsol[summary.GST_Month_Year__c] !=='undefined'){
                        dataMap.set(summary.GST_Month_Year__c, {
                            Id:typeof this.mapOfMonthWithTaxConsol[summary.GST_Month_Year__c] !=='undefined' ? this.mapOfMonthWithTaxConsol[summary.GST_Month_Year__c].Id : '',
                            GST_Month_Year__c: summary.GST_Month_Year__c,
                            Gross_Turnover_as_per_GST_excl_taxes__c: 0,
                            Index__c: summary.Index__c
                        });
                    }else{
                        dataMap.set(summary.GST_Month_Year__c, {
                            GST_Month_Year__c: summary.GST_Month_Year__c,
                            Gross_Turnover_as_per_GST_excl_taxes__c: 0,
                            Index__c: summary.Index__c
                        });
                    }
                    
                }
                
                const existingData = dataMap.get(summary.GST_Month_Year__c);
                existingData.Gross_Turnover_as_per_GST_excl_taxes__c += Number(summary.Gross_Turnover_as_per_GST_excl_taxes__c) || 0;
               // existingData.percentageOfTotalTurnover += parseFloat(summary.Percentage_of_Total_Turnover__c) || 0;
            });
        });

        this.consolidatedData = Array.from(dataMap.values());
        const parentRecord={"Id":this.appliFinancialConRec[0].parentRecord.Id}
        const MainRec={"parentRecord":parentRecord}
        this.newConsolidateFinanList.push(MainRec)
        this.newConsolidateFinanList[0].parentRecord.Applicant_Financial_Summary_s__r = this.consolidatedData;
        this.handleSaveDataConsolidate();
        console.log('this.this.newConsolidateFinanList'+JSON.stringify(this.newConsolidateFinanList)); // Check the target record with consolidated summary

    }
    wiredForFinaDataConsolidate;
    consolidateGSTData;
    listOfConsGST
    consolidateGSTId;
    conAppliFinancia
    appliFinancialConRec;
    @wire(getAllChildWithAllParent, {
        params: '$paramAppGSTForConsolidate'
    })
    getGSTConsolidateRecords(wiredForFinaDataConsolidate) {
        let {error,data } = wiredForFinaDataConsolidate;
        this.wiredForFinaDataConsolidate = wiredForFinaDataConsolidate;
        if (data) {
           // console.log('datalengthhhhh'+data.length)
            if(data.length >0){
                this.conAppliFinancia=data[0].parentRecord.Id;
                this.SummDataOfCons()
            }else{
           // console.log('inelsecondition')
            let parentRec;
            const fields = {
                "Loan_Applicant__c": this._applId,
                "Type__c": "Consolidate GST",
                "Loan_Application__c": this._loanAppId

            };
            const consAppliFinan={apiName : "Applicant_Financial__c", fields : fields};
            //console.log('consAppliGST', consAppliFinan);
            createRecord(consAppliFinan)
            .then((record) => {
               // console.log('record.id'+record.id)
                refreshApex(this.wiredForFinaDataConsolidate)
                this.conAppliFinancia=record.id
                this.SummDataOfCons()
                })
                .catch((err) => {
                    console.log('errerrerr'+JSON.stringify(err))
                    
                });
            }
        }
        if (error) {
            console.log('Error employmentFinancialGSTDetails-->' + error);
        }
    } 
    
    mapOfMonthWithTaxConsol;
    OldConaolidateList
    ConsoliGSTRecForDelete
    SummDataOfCons(){
        const parametersAppFinCon = {
            ParentObjectName: 'Applicant_Financial__c ',
            ChildObjectRelName: 'Applicant_Financial_Summary_s__r',
            parentObjFields: ['Id', 'Loan_Application__c','Applicant_GST__r.GSTIN__c','TypeOfFinancial__c','Loan_Applicant__r.FullName__c', 'Loan_Applicant__c'],
            childObjFields: ['Id', 'Gross_Turnover_as_per_GST_excl_taxes__c', 'GST_Month_Year__c', 'Index__c'],
           // queryCriteriaForChild: ' order by Index__c asc',
            queryCriteria: ' where Id = \'' + this.conAppliFinancia + '\''
            
        }
        getFilterRelRecordsWithOutCache({ params: parametersAppFinCon })
            .then((data) => {
                this.appliFinancialConRec=data
                this.OldConaolidateList=data
                let mapOfMonthWithTaxConsol={}
                for(const record of this.appliFinancialConRec){
                    if(record.parentRecord.Applicant_Financial_Summary_s__r){
                        for(const rec of record.parentRecord.Applicant_Financial_Summary_s__r){
                            mapOfMonthWithTaxConsol[rec.GST_Month_Year__c]=rec
                        }
                        let listofkeys=Object.keys(mapOfMonthWithTaxConsol)
                       // console.log('listofkeys'+Object.keys(mapOfMonthWithTaxConsol))
                    }
                }
              //  console.log('mapOfMonthWithTaxConsol'+mapOfMonthWithTaxConsol)
                this.mapOfMonthWithTaxConsol=mapOfMonthWithTaxConsol
                this.sortAndReindex(this.appliFinancialConRec);
                this.calculationOfParcentageForCon(this.appliFinancialConRec)
            })
            .catch(error => {
                console.log('Errorured:-999 '+JSON.stringify(error));
            });
    }
    handleSaveDataConsolidate(){
         // console.log('this.appliFinancialConRec'+JSON.stringify(this.newConsolidateFinanList))
          const ListOfDelete=[];
          let OldConaolidateList1=JSON.parse(JSON.stringify(this.OldConaolidateList))
          const oldDataMap = this.createDataMap(OldConaolidateList1);
          
          const newDataMap = this.createDataMap(this.newConsolidateFinanList);
          this.newConsolidateFinanList.forEach(newRecord => {
            const oldRecord = oldDataMap[newRecord.parentRecord.Id];
           
            if (oldRecord) {
                const newSummaryMap = this.createSummaryMap(newRecord.parentRecord.Applicant_Financial_Summary_s__r);
                if(oldRecord.Applicant_Financial_Summary_s__r){
                    
                    oldRecord.Applicant_Financial_Summary_s__r.forEach(oldSummary => {
                        if (!newSummaryMap[oldSummary.GST_Month_Year__c]) {
                            ListOfDelete.push(oldSummary);
                        }
                    });
                }
            }
          });
          this.ConsoliGSTRecForDelete=ListOfDelete;
         this.methodForDeleteGSTRecords(this.ConsoliGSTRecForDelete)
          let DataRecords = [];
          let DataRecordObj = {};
          let ChildRecordObj = {};
          for(var i=0;i<this.newConsolidateFinanList.length;i++){
              DataRecordObj = {};
              ChildRecordObj = {};
              DataRecordObj.parentRecord=this.newConsolidateFinanList[i].parentRecord;
              DataRecordObj.parentRecord.sobjectType ='Applicant_Financial__c';
              let ChildRecordArr= [];
              if(this.newConsolidateFinanList[i].parentRecord.Applicant_Financial_Summary_s__r){
                  for(var j=0; j<this.newConsolidateFinanList[i].parentRecord.Applicant_Financial_Summary_s__r.length; j++){
                      ChildRecordObj = this.newConsolidateFinanList[i].parentRecord.Applicant_Financial_Summary_s__r[j];
                      ChildRecordObj.sobjectType='Applicant_Financial_Summary__c';
                      ChildRecordArr.push(ChildRecordObj);
                  }
              }
  
              DataRecordObj.ChildRecords= ChildRecordArr;                    
              DataRecordObj.ParentFieldNameToUpdate='Applicant_Financial__c';
              
              DataRecords.push(DataRecordObj);
          }
        upsertManualRecord({upsertData:DataRecords})
          .then(result => {                     
         this.newConsolidateFinanList=[]
          refreshApex(this.wiredForFinaDataConsolidate);
       }).catch(error => {
              console.log('739'+JSON.stringify(error));
          })
    }   

    // CODE FOR CONSOLIDATE GST DATA LOAN APPLICANTION WISE(LAN)
    wiredForFinaDataConsLAN
    conAppliFinanciaLAN
    appliFinancialConRecLAN
    OldConaolidateListLAN
    mapOfMonthWithTaxConsolLAN
    @wire(getAllChildWithAllParent, {
        params: '$paramAppGSTForConLAN'
    })
    getGSTConsolidateRecordsLAN(wiredForFinaDataConsLAN) {
        let {error,data } = wiredForFinaDataConsLAN;
        this.wiredForFinaDataConsLAN = wiredForFinaDataConsLAN;
        if (data) {
            console.log('datalengthhhhh'+data.length)
            if(data.length >0){
                this.conAppliFinanciaLAN=data[0].parentRecord.Id;
                this.SummDataOfConsLAN()
            }else{
            console.log('inelseconditionLAN')
            let parentRec;
            const fields = {
                "Loan_Applicant__c": this._applId,
              "Type__c": "LAN Consolidate GST",
                "Loan_Application__c": this._loanAppId
            };
            const consAppliFinan={apiName : "Applicant_Financial__c", fields : fields};
            console.log('consAppliGST', consAppliFinan);
            createRecord(consAppliFinan)
            .then((record) => {
                console.log('record.id'+record.id)
                refreshApex(this.wiredForFinaDataConsLAN)
                this.conAppliFinanciaLAN=record.id
                this.SummDataOfConsLAN()
                })
                .catch((err) => {
                    console.log('errerrerr'+JSON.stringify(err))
                    
                });
            }
        }
        if (error) {
            console.log('Error employmentFinancialGSTDetails-->' + error);
        }
    } 
    SummDataOfConsLAN(){
        const parametersAppFinConLAN = {
            ParentObjectName: 'Applicant_Financial__c ',
            ChildObjectRelName: 'Applicant_Financial_Summary_s__r',
            parentObjFields: ['Id', 'Loan_Application__c','Applicant_GST__r.GSTIN__c','TypeOfFinancial__c'],
            childObjFields: ['Id', 'Gross_Turnover_as_per_GST_excl_taxes__c', 'GST_Month_Year__c', 'Index__c'],
            queryCriteria: ' where Id = \'' + this.conAppliFinanciaLAN + '\''
            
        }
        getFilterRelRecordsWithOutCache({ params: parametersAppFinConLAN })
            .then((data) => {
                this.appliFinancialConRecLAN=data
                this.OldConaolidateListLAN=data
                console.log('inSummDataOfConsLAN')
                let mapOfMonthWithTaxConsolLAN={}
                for(const record of this.appliFinancialConRecLAN){
                    if(record.parentRecord.Applicant_Financial_Summary_s__r){
                        for(const rec of record.parentRecord.Applicant_Financial_Summary_s__r){
                            mapOfMonthWithTaxConsolLAN[rec.GST_Month_Year__c]=rec
                        }
                        let listofkeys=Object.keys(mapOfMonthWithTaxConsolLAN)
                       // console.log('listofkeys'+Object.keys(mapOfMonthWithTaxConsol))
                    }
                }
              //  console.log('mapOfMonthWithTaxConsol'+mapOfMonthWithTaxConsol)
                this.mapOfMonthWithTaxConsolLAN=mapOfMonthWithTaxConsolLAN
                this.sortAndReindex(this.appliFinancialConRecLAN);
                this.calculationOfParcentageForCon(this.appliFinancialConRecLAN)

            })
            .catch(error => {
                console.log('Errorured:-999 '+JSON.stringify(error));
            });
    }
    newConsolidateFinanListLAN=[];
    consolidatedDataLAN
    ConsoliGSTRecForDeleteLAN=[]
    consolidateDataForLAN() {
        const parametersAllAppFin = {
            ParentObjectName: 'Applicant_Financial__c ',
            ChildObjectRelName: 'Applicant_Financial_Summary_s__r',
            parentObjFields: ['Id', 'Loan_Application__c','Applicant_GST__r.GSTIN__c','TypeOfFinancial__c'],
            childObjFields: ['Id', 'Gross_Turnover_as_per_GST_excl_taxes__c', 'GST_Month_Year__c', 'Index__c'],
            queryCriteria: ' where Loan_Application__c = \'' + this._loanAppId + '\' and Type__c = \'Location GST\''
            
        }
        getFilterRelRecordsWithOutCache({ params: parametersAllAppFin })
            .then((data) => {
                console.log('inSummDataOfConsLAN'+data.length)
                if(data.length>0){
                    const dataMap = new Map();
                    let listForConsolidateLAN=JSON.parse(JSON.stringify(data))
                    console.log('this.this.newConsolidateFinanList>>>>>'+JSON.stringify(listForConsolidateLAN));
                    listForConsolidateLAN.forEach(record => {
                        console.log('record.parentRecord.Applicant_Financial_Summary_s__r>>>>>'+JSON.stringify(record.parentRecord.Applicant_Financial_Summary_s__r));
                        record.parentRecord.Applicant_Financial_Summary_s__r.forEach(summary => {
                            if (!dataMap.has(summary.GST_Month_Year__c)) {
                                if(typeof this.mapOfMonthWithTaxConsolLAN[summary.GST_Month_Year__c] !=='undefined'){
                                    console.log('inifffff')
                                    dataMap.set(summary.GST_Month_Year__c, {
                                        Id:typeof this.mapOfMonthWithTaxConsolLAN[summary.GST_Month_Year__c] !=='undefined' ? this.mapOfMonthWithTaxConsolLAN[summary.GST_Month_Year__c].Id : '',
                                        GST_Month_Year__c: summary.GST_Month_Year__c,
                                        Gross_Turnover_as_per_GST_excl_taxes__c: 0,
                                        Index__c: summary.Index__c
                                    });
                                }else{
                                    console.log('inelse')
                                    dataMap.set(summary.GST_Month_Year__c, {
                                        GST_Month_Year__c: summary.GST_Month_Year__c,
                                        Gross_Turnover_as_per_GST_excl_taxes__c: 0,
                                        Index__c: summary.Index__c
                                    });
                                }
                                
                            }
                            
                            const existingData = dataMap.get(summary.GST_Month_Year__c);
                            existingData.Gross_Turnover_as_per_GST_excl_taxes__c += Number(summary.Gross_Turnover_as_per_GST_excl_taxes__c) || 0;
                        // existingData.percentageOfTotalTurnover += parseFloat(summary.Percentage_of_Total_Turnover__c) || 0;
                        });
                    });

                    this.consolidatedDataLAN = Array.from(dataMap.values());
                    console.log('this.this.consolidatedDataLAN'+JSON.stringify(this.consolidatedDataLAN));
                    const parentRecord={"Id":this.appliFinancialConRecLAN[0].parentRecord.Id}
                    const MainRec={"parentRecord":parentRecord}
                    this.newConsolidateFinanListLAN.push(MainRec)
                    this.newConsolidateFinanListLAN[0].parentRecord.Applicant_Financial_Summary_s__r = this.consolidatedDataLAN;
                    this.sortAndReindex(this.newConsolidateFinanListLAN);
                    this.handleSaveDataConsolidateLAN();
                }
                
                
            })
            
            .catch(error => {
                console.log('Errorured:-999 '+JSON.stringify(error));
            });
            
            
    }
    handleSaveDataConsolidateLAN(){
        console.log('this.newConsolidateFinanListLAN'+JSON.stringify(this.newConsolidateFinanListLAN))
         const ListOfDelete=[];
         let OldConaolidateListLAN1=JSON.parse(JSON.stringify(this.OldConaolidateListLAN))
         const oldDataMap = this.createDataMap(OldConaolidateListLAN1);
        
         const newDataMap = this.createDataMap(this.newConsolidateFinanListLAN);
         this.newConsolidateFinanListLAN.forEach(newRecord => {
           const oldRecord = oldDataMap[newRecord.parentRecord.Id];
          
           if (oldRecord) {
               const newSummaryMap = this.createSummaryMap(newRecord.parentRecord.Applicant_Financial_Summary_s__r);
               if(oldRecord.Applicant_Financial_Summary_s__r){
                  
                   oldRecord.Applicant_Financial_Summary_s__r.forEach(oldSummary => {
                       if (!newSummaryMap[oldSummary.GST_Month_Year__c]) {
                           ListOfDelete.push(oldSummary);
                       }
                   });
               }
           }
         });
         this.ConsoliGSTRecForDeleteLAN=ListOfDelete;
        this.methodForDeleteGSTRecords(this.ConsoliGSTRecForDeleteLAN)
         let DataRecords = [];
         let DataRecordObj = {};
         let ChildRecordObj = {};
         for(var i=0;i<this.newConsolidateFinanListLAN.length;i++){
             DataRecordObj = {};
             ChildRecordObj = {};
             DataRecordObj.parentRecord=this.newConsolidateFinanListLAN[i].parentRecord;
             DataRecordObj.parentRecord.sobjectType ='Applicant_Financial__c';
             let ChildRecordArr= [];
             if(this.newConsolidateFinanListLAN[i].parentRecord.Applicant_Financial_Summary_s__r){
                 for(var j=0; j<this.newConsolidateFinanListLAN[i].parentRecord.Applicant_Financial_Summary_s__r.length; j++){
                     ChildRecordObj = this.newConsolidateFinanListLAN[i].parentRecord.Applicant_Financial_Summary_s__r[j];
                     ChildRecordObj.sobjectType='Applicant_Financial_Summary__c';
                     ChildRecordArr.push(ChildRecordObj);
                 }
             }
 
             DataRecordObj.ChildRecords= ChildRecordArr;                    
             DataRecordObj.ParentFieldNameToUpdate='Applicant_Financial__c';
             
             DataRecords.push(DataRecordObj);
         }
       upsertManualRecord({upsertData:DataRecords})
         .then(result => {                     
        this.newConsolidateFinanListLAN=[]
         refreshApex(this.wiredForFinaDataConsLAN);
      }).catch(error => {
             console.log('739'+JSON.stringify(error));
         })
   }
   handleApplicantConsiData(){
        if(this.showConsolidateGST){
            this.showConsolidateGST=false
            this.showLocationGST=true
            this.showConsolidateLANGST=false
        }else{
            this.showConsolidateGST=true
            this.showLocationGST=false
            this.showConsolidateLANGST=false
        }
   }
   handleAppConsiDataLAN(){
    if(this.showConsolidateLANGST){
        this.showConsolidateGST=false
        this.showLocationGST=true
        this.showConsolidateLANGST=false
    }else{
        this.showConsolidateLANGST=true
        this.showLocationGST=false
        this.showConsolidateGST=false
    }
   }
   calculationOfParcentageForCon(listOfRecords){
        listOfRecords = listOfRecords.map((item) => {
            // Calculate total of Gross_Turnover_as_per_GST_excl_taxes__c
            const totalGrossTurnover = item.parentRecord.Applicant_Financial_Summary_s__r.reduce((acc, summary) => {
                const turnover = parseFloat(summary.Gross_Turnover_as_per_GST_excl_taxes__c) || 0;
                return acc + turnover;
            }, 0);
            // Add total to parentRecord
            item.parentRecord.Total_Gross_Turnover__c = totalGrossTurnover;
            if(item.parentRecord.Total_Gross_Turnover__c !==0){
                item.parentRecord.Percentage_Total_Gross_Turnover__c= 100
            }else{
                item.parentRecord.Percentage_Total_Gross_Turnover__c= 0
            }
            // Calculate percentage and add to each Applicant_Financial_Summary_s__r
            item.parentRecord.Applicant_Financial_Summary_s__r = item.parentRecord.Applicant_Financial_Summary_s__r.map(summary => {
                const turnover = parseFloat(summary.Gross_Turnover_as_per_GST_excl_taxes__c) || 0;
                const percentage = totalGrossTurnover ? (turnover * 100 / totalGrossTurnover) : 0;
                return {
                    ...summary,
                    Percentage_of_Total_Turnover__c: percentage.toFixed(2) // To limit the decimal places to 2
                };
            });

            return item;
        });
    }

    

   /*
    @track showLocationGST=true;
    @track showConsolidateGST
    @track showConsolidateLANGST */
   //select id, FullName__c, from Applicant__c where LoanAppln__c ='a08C40000082ahBIAQ'
   //select id, Loan_Application__c, type__c from Applicant_Financial__c where Loan_Application__c ='a08C40000082ahBIAQ'
   //select id, Loan_Application__c, type__c from Applicant_Financial__c where Loan_Applicant__c  ='a0AC4000000JTcbMAG'
   //select id, GST_Month_Year__c, Gross_Turnover_as_per_GST_excl_taxes__c, Index__c from Applicant_Financial_Summary__c where Applicant_Financial__c ='a0cC4000000I0PlIAK'
}