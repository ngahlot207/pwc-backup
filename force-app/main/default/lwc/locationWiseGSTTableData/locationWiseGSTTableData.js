import { LightningElement, api, wire, track } from 'lwc';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import APP_FIN_OBJECT from "@salesforce/schema/Applicant_Financial__c";
import { getObjectInfo, getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import getAllSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getAllSobjectDatawithRelatedRecords';
import saveApplicantFinancialData from '@salesforce/apex/SaveApplicantGSTData.saveApplicantFinancialData';

export default class LocationWiseGSTTableData extends LightningElement {
    // @api gstRecsForAllLoca;
    // get gstRecsForAllLoca(){
    //     return this.gstRecsForAllLoca;
    // }
    tempArray = Array.from({ length: 10 }, (_, i) => i + 1);
    @api gstRecsForAllGST;
    @api gstTabName;
    @track dataGST = [];
    @track _gstRecsForAllLoca;
    @track picklistOptions;
    @track lastThreeFinancialYears =[];
    @track GSTdata =[];
    @track Financialdata = [];
    @api get gstRecsForAllLoca() {
        return this._gstRecsForAllLoca;
    }
    set gstRecsForAllLoca(value) {
        this._gstRecsForAllLoca = value;
        this.setAttribute("gstRecsForAllLoca", value);
        console.log('this._applIdthis._applId'+this._gstRecsForAllLoca)
        //this.handleRecordAppId(value);
    }

    @api get applId() {
        return this._applId;
    }
    set applId(value) {
        this._applId = value;
        this.setAttribute("applId", value);
        console.log('this._applIdthis._applId'+this._applId)
        this.handleRecordAppId(value);
    }

    handleRecordAppId(value) {

        
        let tempParams2 = this.parametersAppGST;
        tempParams2.queryCriteria = ' where Applicant__c = \'' + this._applId + '\''
        this.parametersAppGST = { ...tempParams2 };
    }
    // @api get gstTabName(){
    //     return this.gstTabName;
    // }

    // set gstTabName(value) {
    //     this.setAttribute("gstTabName", value);
    //     //this.handleRecordAppId(value);
    // }

    @track
    paramExtraAppliFinan = {
        ParentObjectName: 'Applicant_Financial__c ',
        ChildObjectRelName: 'Applicant_Financial_Summary_s__r',
        parentObjFields: ['Id','Type__c', 'Applicant_GST__r.GSTIN__c','TypeOfFinancial__c'],
        childObjFields: ['Id', 'Gross_Turnover_as_per_GST_excl_taxes__c', 'GST_Month_Year__c', 'Index__c'],
       // queryCriteriaForChild: ' order by Index__c asc',
        queryCriteria: ' WHERE Type__c = \'Location GST\''
        
    }

    @track parametersAppGST = {
        ParentObjectName: 'ApplGST__c ',
        ChildObjectRelName: '',
        parentObjFields: ['Id','GSTIN__c'],
        childObjFields: [],
        queryCriteria: ' where Applicant__c = \'' + this._applId + '\''
    }

    @track wiredGSTRecords =[];
    @track ApplGSTData =[];
    @wire(getSobjectData, {
        params: '$parametersAppGST'
    })
    handleGST(wiredRecords) {
        let {error, data } = wiredRecords;
        this.wiredGSTRecords = wiredRecords;
        if (data) {
            this.ApplGSTData = data;
            console.log('GSTDATA :: ..>> ', JSON.stringify(data));
    
            // Call getFinancialGSTData after getting GST data
            this.getFinancialGSTData();
        }
        if (error) {
            console.log('Error handleGST-->' + JSON.stringify(error));
        }
    }
    
    // handleGST(wiredDeleteRecords) {
    //     let {error,data } = wiredDeleteRecords;
    //     this.wiredDeleteRecords = wiredDeleteRecords;
    //     if (data) {
    //         this.ApplGSTData = data;
    //        console.log('GSTDATA :: ..>> ',JSON.stringify(data))
    //        this.getFinancialGSTData();
    //     }
    //     if (error) {
    //         console.log('Error handleGST-->' + JSON.stringify(error));
    //     }
    // }
    
    getFinancialGSTData(){

        let parametersAppFinancial = {
            ParentObjectName: 'Applicant_Financial__c ',
            ChildObjectRelName: 'Applicant_Financial_Summary_s__r',
            parentObjFields: ['Id', 'Loan_Application__c','Applicant_GST__r.GSTIN__c','TypeOfFinancial__c','Loan_Applicant__c','Loan_Applicant__r.FullName__c'],
            childObjFields: ['Id', 'Type__c', 'DueDt__c', 'Index__c','FilingDate__c','GST_Month_Year__c'],
            queryCriteriaForChild: ' WHERE Type__c = \'Filing Details - GSTR 3B\'',
            queryCriteria: ' where Loan_Applicant__c = \'' + this._applId + '\' and Type__c = \'Finfort GST\' and RecordType.DeveloperName =\'GST\' and IsLatest__c =true order by CreatedDate desc'
        }

    getAllSobjectDatawithRelatedRecords({
        params: parametersAppFinancial
        })
        .then(result => {
                this.GSTdata = [];
                this.Financialdata = result;
                if(this.Financialdata.length === 0){
                    
                    try{
                    this.ApplGSTData.parentRecords.forEach(record => {
                        this.GSTdata.push(this.formData(record));
                    })
                }catch(error){
                    console.log('Error in formData: ',JSON.stringify(error))
                }

                    console.log('formData this.Financialdata: ',JSON.stringify(this.GSTdata))
                }
                else{
                    this.GSTdata = result;
                }
                // this.GSTdata.forEach(record => {
                //     this.Financialdata.push(record.parentRecord);
                // });

                this.GSTdata = this.GSTdata.map(record => {
                    return {
                        ...record,
                        parentRecord: {
                            ...record.parentRecord,
                            Applicant_Financial_Summary_s__r: this.generatePreviousMonthsAndFY(this._monthNdYear)
                        }
                    };
                });

            // Map each GSTdata record with ApplGSTData based on GSTIN__c
            //this.mapGSTDataWithApplGST();
        
                console.log('Assume GSTdata:: ', JSON.stringify(this.GSTdata)); 
        
            
            console.log('dataGST handleLast18MonthsChange:: ', JSON.stringify(this.GSTdata)); 
    
                //this.handleLast18MonthsChange();
    
                console.log('this.Financialdata>>> '+JSON.stringify(this.Financialdata))
                console.log('datadatadata>>>>>>> Finfort GST '+JSON.stringify(result))
                console.log('dataGST:: ', JSON.stringify(this.GSTdata)); 
        })
        .catch(error => {
            console.log('error>>> '+JSON.stringify(error));
        })
    }
    //handleFinancialRecExtra(wiredDeleteRecords) {
    //}
//}

formData(gstRecord){


    return {
          "parentRecord": {
            "Loan_Application__c": "",
            "Applicant_GST__c": gstRecord.Id,
            "Loan_Applicant__c": this.applId,
            "RecordTypeId": "012C4000000ZhrhIAC",
            "Applicant_GST__r": {
              "GSTIN__c": gstRecord.GSTIN__c,
              "Id": gstRecord.Id
            }
            // ,
            // "Applicant_Financial_Summary_s__r": [
            //     this.generatePreviousMonthsAndFY(this._monthNdYear)
            // ]
          }
        }
    
}

    @track _last18Months;
    @track _monthNdYear;
    @api 
    get last18Months() {
        return this._last18Months;
    }
    
    set last18Months(value) {
        this._last18Months = value;
        //this.handleLast18MonthsChange(); // Respond to new data
    }

    @api 
    get monthNdYear() {
        return this.monthNdYear;
    }
    
    set monthNdYear(value) {
        this._monthNdYear = value;
        this.setAttribute("monthNdYear", value);
        this.handleLast18MonthsChange(); // Respond to new data
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

    //@api last18Months;
    connectedCallback(){
        console.log('connnect gstTabName:: ',JSON.stringify(this.gstTabName));
        console.log('gstRecsForAllLoca:: ',JSON.stringify(this.gstRecsForAllLoca));
        console.log('last18Months:: ',JSON.stringify(this.last18Months));
        console.log('monthNdYear:: ',JSON.stringify(this._monthNdYear));
    }

    handleLast18MonthsChange() {
        this.getFinancialGSTData();
        // Handle the data update, e.g., fetch or recalculate based on the new data
        console.log('Updated monthNdYear:', JSON.stringify(this._monthNdYear));
    
        this.picklistOptions = this.generatePreviousMonthsAndFY(this._monthNdYear)
        this.lastThreeFinancialYears = this.getLastThreeFY(this._monthNdYear);
        console.log(this.lastThreeFinancialYears); // Output: ["FY 2023-24", "FY 2022-23", "FY 2021-22"]

        
        console.log('picklistOptions:: ', JSON.stringify(this.picklistOptions)); 
    }
    

    generatePreviousMonthsAndFY(baseMonthYear, monthsBack = 36) {
                
        const previousMonthsWithFY = [];
        if(baseMonthYear){
        console.log('this.gstTabName:: ',this.gstTabName)
        const [monthStr, yearStr] = baseMonthYear.split(" - ");
        const months = [
            "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ];
    
        let monthIndex = months.indexOf(monthStr);
        let year = parseInt("20" + yearStr, 10); // Assuming "23" means "2023"

        for (let i = 0; i < monthsBack; i++) {
            // Calculate the financial year based on the month
            let financialYear;
            if (monthIndex < 3) { // Jan, Feb, March are in the previous FY
                financialYear = `${year - 1}-${year}`;
            } else {
                financialYear = `${year}-${(year + 1)}`;
            }
    
            previousMonthsWithFY.push({
                //label: `${months[monthIndex]} - ${year} (${financialYear})`,
                GST_Month_Year__c: `${months[monthIndex]} - ${year}`,
                Financial_Year__c: `${financialYear}`,
                DueDt__c: '',
                FilingDate__c:'',
                DelayedDays__c:'',
                Index__c: i+1,
                Type__c : 'Filing Details - GSTR 3B'
            });
    
            // Move to the previous month
            monthIndex--;
            if (monthIndex < 0) {
                monthIndex = 11; // Wrap back to December
                year--; // Move to the previous year
            }
        }
    }
    
        return previousMonthsWithFY;
    }


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
             })
            .catch(error => {
                console.log('Errorured:-999 '+JSON.stringify(error));
            });
    
    }

    handleInputChange(event) {
        // // Get the name of the field and index from the data attributes
        // const fieldName = event.target.dataset.fieldname;
        // const index = event.target.dataset.index;
        // const newValue = event.target.value;
    
        // // Split the field path and retrieve the field name
        // const fieldPath = fieldName.split('.');
        // const fieldKey = fieldPath[fieldPath.length - 1];
    
        // // Find the specific record in GSTdata to update
        // const targetRecord = this.GSTdata.find((record) => {
        //     return record.parentRecord.Applicant_Financial_Summary_s__r && 
        //            record.parentRecord.Applicant_Financial_Summary_s__r[index];
        // });
    
        // if (targetRecord) {
        //     const financialSummary = targetRecord.parentRecord.Applicant_Financial_Summary_s__r;
    
        //     if (financialSummary[index]) {
        //         // Update the specific field with the new value
        //         financialSummary[index][fieldKey] = newValue;
    
        //         // Check if we can calculate the delay days
        //         const dueDate = financialSummary[index].DueDt__c;
        //         const filingDate = financialSummary[index].FilingDate__c;
    
        //         if (dueDate && filingDate) {
        //             // Calculate delay days as the difference in days
        //             const delayDays = this.calculateDelayDays(dueDate, filingDate);
        //             financialSummary[index].DelayedDays__c = delayDays;
        //         }
        //     }
        // }

        if (event.target.dataset.fieldname === 'DueDt__c' || event.target.dataset.fieldname === 'FilingDate__c') {
            console.log('event.target.accessKey'+event.target.accessKey)
            let parentIndex = event.target.dataset.parentIndex;
            let childIndex = event.target.dataset.cloumnIndex;
            let fullParentRecord = this.GSTdata[parentIndex];
            console.log('parentRecord fullParentRecord: '+JSON.stringify(fullParentRecord))
            let childRecords = fullParentRecord.parentRecord.Applicant_Financial_Summary_s__r[childIndex];
            let fieldName = event.target.dataset.fieldname;
            childRecords[fieldName] = event.target.value;
            const dueDate = new Date(childRecords.DueDt__c);
            const filingDate = new Date(childRecords.FilingDate__c);
    
            if (dueDate && filingDate) {
                const delayDays = this.calculateDelayDays(dueDate, filingDate);
                childRecords.DelayedDays__c = delayDays;
            }
        }
        console.log("Updated GSTdata:", JSON.stringify(this.GSTdata));
    }

    calculateDelayDays(dueDate, filingDate) {
        const dueDateObj = new Date(dueDate);
        const filingDateObj = new Date(filingDate);

        // Calculate the difference in milliseconds and convert to days
        const differenceInTime = filingDateObj - dueDateObj;
        const differenceInDays = Math.ceil(differenceInTime / (1000 * 3600 * 24));

        return differenceInDays > 0 ? differenceInDays : 0; // Ensure non-negative delay days
    }

    
    @track lastThreeFY = [];
    getLastThreeFY(monthYear) {
        this.lastThreeFY=[];
        if(monthYear){
        // Extract the year part from monthYear (e.g., "August - 23" -> 23)
        const inputYear = parseInt(monthYear.split('-')[1].trim(), 10) + 2000;
    
        // Determine the current FY start year
        const fiscalYearStart = monthYear.startsWith("January") || monthYear.startsWith("February") || monthYear.startsWith("March") ? inputYear - 1 : inputYear;
    
        // Calculate last three financial years
        for (let i = 0; i < 3; i++) {
            this.lastThreeFY.push(`FY ${fiscalYearStart - i}-${(fiscalYearStart - i + 1).toString().slice(-2)}`);
        }
    }
    
        return this.lastThreeFY.reverse();
    }

    @api handleUpsertLocWise(validate) {
        console.log('this.GSTdata ',validate);
        console.log('this.GSTdata handleUpsertLocWise ',JSON.stringify(this.GSTdata));
        if(validate){
            // console.log('validate: ',validate);
            // saveApplicantFinancialData({
            //     data: this.GSTdata
            //     })
            //     .then(result => {

            //         console.log('result: ',result);

            //     }).catch(error => {
            //     console.log('Error 267-->' + JSON.stringify(error))
            //     })

            
        }
    }

    mapGSTDataWithApplGST() {
        // Assuming this.GSTdata is already populated from getFinancialGSTData()
        if (this.GSTdata.length > 0 && this.ApplGSTData.length > 0) {
            this.GSTdata = this.GSTdata.map(gstRecord => {
                // Find matching ApplGSTData record based on GSTIN__c
                const matchingGST = this.ApplGSTData.parentRecords.find(applGST => applGST.GSTIN__c === gstRecord.parentRecord.Applicant_GST__r.GSTIN__c);
    
                if (matchingGST) {
                    // Add relevant ApplGSTData fields to the gstRecord
                    return {
                        ...gstRecord,
                        parentRecord: {
                            ...gstRecord.parentRecord,
                            Applicant_GST__r: matchingGST
                        }
                    };
                } else {
                    // No match found, return the original gstRecord
                    return gstRecord;
                }
            });
        } else {
            console.log('No GSTdata or ApplGSTData available for mapping.');
        }
    }
    

}