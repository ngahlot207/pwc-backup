import { LightningElement,api,track, wire } from 'lwc';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import {subscribe, publish, MessageContext, APPLICATION_SCOPE} from 'lightning/messageService';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import updateData from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import { refreshApex } from '@salesforce/apex';
export default class BankingSummaryData extends LightningElement {
    @api hasEditAccess;
    @api toShowAllDetails;
    @api parentRecord
    @api toEditAllDetails;
    @api monthandYearList;
    @api applicantRecordId
    
    @track totalValueSummationCredit=0;
     @track totalValueSummationDebit=0;
    @track totalCountofDebit=0
    @track totalCountofCredit=0
    @track totalAverageBankBalance=0
    @track totalBalanceAt_25th=0
    @track totalBalanceAt_20th=0
     @track totalBalanceAt_1st=0
    @track totalBalanceAt_5th__c=0
    @track totalBalanceAt_10th=0
    @track totalBalanceAt_15th=0
    @track totalInwardReturnsCount=0
    @track totalOutwardReturnsCount=0
    @track totalStopPaymentCount=0

    @track averageValueSummationCredit=0;
    @track averageValueSummationDebit=0;
    @track averageCountofDebit=0
    @track averageCountofCredit=0
    @track averageAverageBankBalance=0
    @track averageBalanceAt_25th=0
    @track averageBalanceAt_20th=0
    @track averageBalanceAt_1st=0
    @track averageBalanceAt_5th__c=0
    @track averageBalanceAt_10th=0
    @track averageBalanceAt_15th=0
    @track averageInwardReturnsCount=0
    @track averageOutwardReturnsCount=0
    @track averageStopPaymentCount=0

    @track totalAfterChangesSummationCredit=0;
    @track totalAfterChangesSummationDebit=0;
    @track totalAfterChangesCountofDebit=0
    @track totalAfterChangesCountofCredit=0
    @track totalAfterChangesAverageBankBalance=0
    @track totalAfterChangesBalanceAt_25th=0
    @track totalAfterChangesBalanceAt_20th=0
    @track totalAfterChangesBalanceAt_1st=0
    @track totalAfterChangesBalanceAt_5th__c=0
    @track totalAfterChangesBalanceAt_10th=0
    @track totalAfterChangesBalanceAt_15th=0
    @track totalAfterChangesInwardReturnsCount=0
    @track totalAfterChangesOutwardReturnsCount=0
    @track totalAfterChangesStopPaymentCount=0
    @track totalAfterChangesMonthEnd=0
    @track totalAfterChangesDailyBala=0

    @track averageAfterChangesSummationCredit=0;
    @track averageAfterChangesSummationDebit=0;
    @track averageAfterChangesCountofDebit=0
    @track averageAfterChangesCountofCredit=0
    @track averageAfterchangeAverageBankBalance=0
    @track averageAfterChangesBalanceAt_25th=0
    @track averageAfterChangesBalanceAt_20th=0
    @track averageAfterChangesBalanceAt_1st=0
    @track averageAfterChangesBalanceAt_5th__c=0
    @track averageAfterChangesBalanceAt_10th=0
    @track averageAfterChangesBalanceAt_15th=0
    @track averageAfterChangesInwardReturnsCount=0
    @track averageAfterChangesOutwardReturnsCount=0
    @track averageAfterChangesStopPaymentCount=0
    @track averageAfterChangesMonthEnd=0
    @track averageAfterchangeDailyBala=0
    bankingDetailList=[];
    finalOfMiniAver;
    averageOfUtilization;
   
    _foreditableTableData=[];
    oldMonthAndYearList=[];
    oldListforeditableTableData;

    
    @api
    get foreditableTableData(){
        return this._foreditableTableData;
    }

    set foreditableTableData(value){
        if(value){
            
            this._foreditableTableData = JSON.parse(JSON.stringify(value));
            this.oldListforeditableTableData=JSON.parse(JSON.stringify(value));
            this.calculationforsum(this._foreditableTableData);
           // this.ForMonthlyLimit(this._foreditableTableData)
           // this.handleCalculation(this._foreditableTableData,this._foreditableTableData.length);
            this.calForUtilization();
            setTimeout(() => {
                        this.calForTotalAndAverageWIthEdit(this._foreditableTableData,this._foreditableTableData.length);
                    }, 500);
            
        }
    }
    _sourceOfAppliBank;
    @api 
    get sourceOfAppliBank(){
        return this._sourceOfAppliBank;
    }
    set sourceOfAppliBank(value){
        this._sourceOfAppliBank=value
        console.log('this._sourceOfAppliBank'+this._sourceOfAppliBank)
        if(this._sourceOfAppliBank=='Manual'){
            this.ConsiAbbDisMode=false
        }else{
            this.ConsiAbbDisMode=true
        }
    }
    @track ConsiAbbDisMode

    @api
    get bankingDetailDataList(){
        return this.bankingDetailList;
    }

    set bankingDetailDataList(value){
        if(value){
            console.log('953333')
            this.bankingDetailList = JSON.parse(JSON.stringify(value));
        }
    }
    _accountTypeCcNdOd=false;
    @api
    get accountTypeCcNdOd(){
        return this._accountTypeCcNdOd;
    }

    set accountTypeCcNdOd(value){
            this._accountTypeCcNdOd = value
            console.log('this._accountTypeCcNdOd'+this._accountTypeCcNdOd)
    }

    @api
    get limitValue(){
        return this._limitValue;
    }

    set limitValue(value){
            this._limitValue = value
            console.log('this._limitValue'+this._limitValue)
            this.ForMonthlyLimit(this._foreditableTableData)
    }
    _changeLimitInPeriVal
    disabledForAvLimit=true;
    @api
    get changeLimitInPeriVal(){
        return this._changeLimitInPeriVal;
    }

    set changeLimitInPeriVal(value){
            this._changeLimitInPeriVal = value
            console.log('this._changeLimitInPeriVal'+this._changeLimitInPeriVal);
            if(this._changeLimitInPeriVal=='Yes'){
                console.log('136'+this._changeLimitInPeriVal);
                this.disabledForAvLimit=false;
            }else{
                console.log('139'+this._changeLimitInPeriVal);
                this.disabledForAvLimit=true;
            }
            
    }


    customSort(a, b) {
        const months = {
            JAN: 1, FEB: 2, MAR: 3, APR: 4, MAY: 5, JUN: 6,
            JUL: 7, AUG: 8, SEP: 9, OCT: 10, NOV: 11, DEC: 12
    
        };
        const yearA = parseInt(a.Year__c);
        const yearB = parseInt(b.Year__c);
        const monthA = months[a.Month__c];
        const monthB = months[b.Month__c];
        if (yearA !== yearB) {
            return yearB - yearA;
        }
        return monthB - monthA;
    
      }
    
     

    get options() {
        return [
            { label: 'Y', value: 'Y' },
            { label: 'N', value: 'N' },
           
        ];
    }
    oldMainListofAppliDetailRec;
    oldMainListOfMonYear;
    connectedCallback(){
        console.log("updated code");
        const inputAligncenter = document.createElement('style');
        inputAligncenter .innerText = `.input-text-align_right input{ text-align: right!important; }`;
        document.body.appendChild(inputAligncenter);

        this._foreditableTableData.sort(this.customSort);
        console.log('this.hasEditAccess>>>>'+this.hasEditAccess)
        if(this.hasEditAccess === false){
            this.disableMode = true;
            this.disabledForAvLimit= this._changeLimitInPeriVal=='Yes' ? true:true;
      }else{
             this.disableMode = false;
             this.disabledForAvLimit= this._changeLimitInPeriVal=='No' ? true:false;
      }
      
      if(this._sourceOfAppliBank=='Perfios'){
           this.ConsiAbbDisMode = this.hasEditAccess===false?true:true;
           
           // this.ConsiAbbDisMode=true
        }else{
           // this.ConsiAbbDisMode=false
           this.ConsiAbbDisMode = this.hasEditAccess===false?true:false;
        }
        /*console.log('shortingggggggg'+this._foreditableTableData);
        let yearAndMonthList=[];

        for (const record of this.foreditableTableData){
            yearAndMonthList.push(record.Month__c+'-'+record.Year__c);

        }
        this.yearAndMonthList=yearAndMonthList;
        console.log('this.monthandYearList'+this.monthandYearList);
        this.addAppliBankRow(this.applicantRecordId, this.monthandYearList);*/
        this.scribeToMessageChannel();
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
        this.handleSaveV(values.validateBeforeSave);

    }
    handleSaveV(validate) {
        if(this._foreditableTableData.length>0){
           setTimeout(() => {
                console.log('intimeoute>>>>>>');
                //this.handleSave();
            }, 1000);
                
        }    
    }
    
    @api handleCalculation(listOfRecord,lengthOfData){
        console.log('handleCalculation')
        this.calculationforsum(listOfRecord);
        this.calForUtilization();
        this.calForTotalAndAverageWIthEdit(listOfRecord,lengthOfData);
        
        
    }
    rowIndex;
    handleRowClick(event) {
        const rowIndex = event.currentTarget.dataset.rowIndex;
        this.rowIndex1 = rowIndex;
        console.log('this.rowIndex'+this.rowIndex);
    }
    handleInputChange(event){
         const fieldName = event.target.dataset.field;
        this.rowIndex= event.target.dataset.index
        console.log('this.rowIndexthis.rowIndexthis.rowIndex'+event.target.dataset.index);
        if (fieldName === 'ValueSummationDebit__c') {
           //var ValueSummationDebitField = Number(event.target.value);
           var ValueSummationDebitField= (event.target.value== undefined || event.target.value =='' || event.target.value==null)?null: Number(event.target.value);
           this.UpdateListWithNewValue(this.rowIndex, ValueSummationDebitField, fieldName);
        } else if (fieldName === 'ValueSummationCredit__c') {
           // var valueSummationCreditField = Number(event.target.value);
           var valueSummationCreditField= (event.target.value== undefined || event.target.value =='' || event.target.value==null)?null: Number(event.target.value);
            this.UpdateListWithNewValue(this.rowIndex, valueSummationCreditField, fieldName);
        }
        else if (fieldName === 'CountofDebit__c') {
            //var CountofDebitField = Number(event.target.value);
            var CountofDebitField =(event.target.value== undefined || event.target.value =='' || event.target.value==null)?null: Number(event.target.value);
            this.UpdateListWithNewValue(this.rowIndex, CountofDebitField, fieldName);
        } else if (fieldName === 'CountofCredit__c') {
            //var CountofCreditField = Number(event.target.value);
            var CountofCreditField = (event.target.value== undefined || event.target.value =='' || event.target.value==null)?null: Number(event.target.value);
            this.UpdateListWithNewValue(this.rowIndex, CountofCreditField, fieldName);
        }
        else if (fieldName === 'InwardReturnsCount__c') {
            //var InwardReturnsCountField = Number(event.target.value);
            var InwardReturnsCountField =(event.target.value== undefined || event.target.value =='' || event.target.value==null)?null: Number(event.target.value);
            this.UpdateListWithNewValue(this.rowIndex, InwardReturnsCountField, fieldName);
            
        }else if (fieldName === 'MinBalanceCharges__c') {
            var miniBanceCharge = event.target.value;
            const rowIndex111 = event.target.getAttribute('data-row-index');
           console.log('miniBanceCharge>>>>'+rowIndex111);
           console.log('miniBanceCharge>>>>'+this.rowIndex);
            this.UpdateListWithNewValue(rowIndex111, miniBanceCharge, fieldName);
            
        }
         else if (fieldName === 'OutwardReturnsCount__c') {
            //var OutwardReturnsCountField = Number(event.target.value);
            var OutwardReturnsCountField =(event.target.value== undefined || event.target.value =='' || event.target.value==null)?null: Number(event.target.value);
            this.UpdateListWithNewValue(this.rowIndex, OutwardReturnsCountField, fieldName);
        }
        else if (fieldName === 'StopPaymentCount__c') {
            //var StopPaymentCountField = Number(event.target.value);
            var StopPaymentCountField = (event.target.value== undefined || event.target.value =='' || event.target.value==null)?null: Number(event.target.value);
            this.UpdateListWithNewValue(this.rowIndex, StopPaymentCountField, fieldName);
        } else if (fieldName === 'BalanceAt_1st__c') {
           // var BalanceAt_1stField = Number(event.target.value);
           var BalanceAt_1stField = (event.target.value== undefined || event.target.value =='' || event.target.value==null)?null: Number(event.target.value);
            this.UpdateListWithNewValue(this.rowIndex, BalanceAt_1stField, fieldName);
        }
        else if (fieldName === 'BalanceAt_5th__c') {
           // var BalanceAt_5thField = Number(event.target.value);
           var BalanceAt_5thField = (event.target.value== undefined || event.target.value =='' || event.target.value==null)?null: Number(event.target.value);
            this.UpdateListWithNewValue(this.rowIndex, BalanceAt_5thField, fieldName);
        } else if (fieldName === 'BalanceAt_10th__c') {
           // var BalanceAt_10thField= Number(event.target.value);
           var BalanceAt_10thField= (event.target.value== undefined || event.target.value =='' || event.target.value==null)?null: Number(event.target.value);
            this.UpdateListWithNewValue(this.rowIndex, BalanceAt_10thField, fieldName);
        }
        else if (fieldName === 'BalanceAt_15th__c') {
            //var BalanceAt_15thField = Number(event.target.value);
            var BalanceAt_15thField = (event.target.value== undefined || event.target.value =='' || event.target.value==null)?null: Number(event.target.value);
            this.UpdateListWithNewValue(this.rowIndex, BalanceAt_15thField, fieldName);
        }
        else if (fieldName === 'BalanceAt_20th__c') {
            //var BalanceAt_20thField = Number(event.target.value);
            var BalanceAt_20thField = (event.target.value== undefined || event.target.value =='' || event.target.value==null)?null: Number(event.target.value);
            this.UpdateListWithNewValue(this.rowIndex, BalanceAt_20thField, fieldName);
        } else if (fieldName === 'BalanceAt_25th__c') {
           // var BalanceAt_25thField = Number(event.target.value);
           var BalanceAt_25thField =(event.target.value== undefined || event.target.value =='' || event.target.value==null)?null: Number(event.target.value);
            this.UpdateListWithNewValue(this.rowIndex, BalanceAt_25thField, fieldName);
        }
        else if (fieldName === 'DailyABBBalance__c') {
            var DailyABBBalance = (event.target.value== undefined || event.target.value =='' || event.target.value==null)?null: Number(event.target.value);
            this.UpdateListWithNewValue(this.rowIndex, DailyABBBalance, fieldName);
        }
        else if (fieldName === 'MonthlyLimit__c') {
           // var MonthlyLimitField = Number(event.target.value);
           var MonthlyLimitField =(event.target.value== undefined || event.target.value =='' || event.target.value==null)?null: Number(event.target.value);
            this.UpdateListWithNewValue(this.rowIndex, MonthlyLimitField, fieldName);
        }
        else if (fieldName === 'Average_Daily_Bank_Balance__c') {
            var dailyBnkBal =(event.target.value== undefined || event.target.value =='' || event.target.value==null)?null: Number(event.target.value);
             this.UpdateListWithNewValue(this.rowIndex, dailyBnkBal, fieldName);
         }else if (fieldName === 'Monthend__c') {
            var monthEnd =(event.target.value== undefined || event.target.value =='' || event.target.value==null)?null: Number(event.target.value);
             this.UpdateListWithNewValue(this.rowIndex, monthEnd, fieldName);
         }

    }
    
    UpdateListWithNewValue(rowIndex, newValue, fieldName){
        console.log('297')
        if (this._foreditableTableData[rowIndex].hasOwnProperty(fieldName)) {
            this._foreditableTableData[rowIndex][fieldName] = newValue;
            console.log('rowIndexrowIndexrowIndex'+rowIndex)
            console.log('this._foreditableTableData[rowIndex]302'+JSON.stringify(this._foreditableTableData))
            var lengthOfData = this._foreditableTableData.length;
            this.calculationforsum(this._foreditableTableData);
            this.calForUtilization();
            this.calForTotalAndAverageWIthEdit(this._foreditableTableData,lengthOfData);
        } else{
            console.log('delpoyed>>>>1')
            var x = {}
            x[fieldName] = newValue;
            this._foreditableTableData[rowIndex] = {...this._foreditableTableData[rowIndex],...x};
            var lengthOfData = this._foreditableTableData.length;
            this.calculationforsum(this._foreditableTableData);
            this.calForUtilization();
            setTimeout(() => {
                this.calForTotalAndAverageWIthEdit(this._foreditableTableData,lengthOfData);
            }, 200);
        }
    }
    

    calForUtilization(){
        
        this._foreditableTableData = this._foreditableTableData.map((record) => {
            console.log(this.limitValue)
            if (this.limitValue!='' && this.limitValue!=null && typeof this.limitValue!='undefined' && this.disabledForAvLimit==true) {
                console.log('record.AverageBankBalance__c'+record.AverageBankBalance__c)
                record["Utilization__c"] = Math.floor(((record.AverageBankBalance__c * 100) /this.limitValue ).toFixed(2));
            }else if(record.MonthlyLimit__c !=''&&record.MonthlyLimit__c !=null &&record.MonthlyLimit__c !=='undefined' && record.MonthlyLimit__c !==0){
               console.log('record.MonthlyLimit__c'+record.MonthlyLimit__c)
                record["Utilization__c"] = Math.floor(((record.AverageBankBalance__c * 100) /record.MonthlyLimit__c ).toFixed(2));
            }
             else {
                record["Utilization__c"] = (0.00).toFixed(2); // Handle cases where AverageBankBalance__c is 0 or null
            }
            return record;
            
        });
        console.log('incalForUtilization'+JSON.stringify( this._foreditableTableData));

    }
    ForMonthlyLimit(listOfRec){
        console.log('inForMonthlyLimit>>>>>>>>>>>'+this._limitValue);
        this._foreditableTableData=listOfRec
        var count=0;
        for(const record of this._foreditableTableData){
            if(record.MonthlyLimit__c !=''&&record.MonthlyLimit__c !=null &&record.MonthlyLimit__c !=='undefined'){
                count++
            }
        }
        this._foreditableTableData = this._foreditableTableData.map((record) => {
            if (this._limitValue!='' && this._limitValue!=null && typeof this._limitValue!='undefined') {
                console.log('norequired'+count)
                if(this.disabledForAvLimit==false && record.MonthlyLimit__c !=''&&record.MonthlyLimit__c !=null &&record.MonthlyLimit__c !=='undefined'){
                    
                }else if(this.disabledForAvLimit==false && count>0){
                    
                }
                else{
                    record["MonthlyLimit__c"] = Number(this._limitValue);
                }
                
            } else {
               // record["MonthlyLimit__c"] = ''; // Handle cases where AverageBankBalance__c is 0 or null
               record["MonthlyLimit__c"] = record.MonthlyLimit__c !='' && record.MonthlyLimit__c !=null && record.MonthlyLimit__c !=='undefined' ? record.MonthlyLimit__c:'';
            }
            return record;
             
             

        });
        //console.log('this._foreditableTableData.length34999'+this._foreditableTableData)
        if(this._foreditableTableData.length>0){
                this.totalOfMonthLimit=0
                //console.log('this._foreditableTableData348'+JSON.stringify(this._foreditableTableData))
                this._foreditableTableData.forEach(record => {
                this.totalOfMonthLimit += record.MonthlyLimit__c!='' &&record.MonthlyLimit__c!=null && typeof record.MonthlyLimit__c!=='undefined' ? record.MonthlyLimit__c:0 ;
            });
            this.MonthlyLimit=0
            this.monthlyLimit=0
            this.monthlyLimit=(this.totalOfMonthLimit/this._foreditableTableData.length).toFixed(2)
            this.MonthlyLimit=(this.totalOfMonthLimit/this._foreditableTableData.length).toFixed(2)
            console.log(' this.MonthlyLimit>>>>>>>'+  this.monthlyLimit)
        }
        
        this.calForUtilization();
        const monthLimit = new CustomEvent('monthlylimit', {
            detail:  this.monthlyLimit
        });
        console.log('before dispatch')
        this.dispatchEvent(monthLimit);
        
    }

    calculationforsum(ListOfRecords){
        console.log('hhhhhhhhh');
        ListOfRecords.forEach(record => {
            const sumFields = ['BalanceAt_1st__c','BalanceAt_25th__c', 'BalanceAt_20th__c', 'BalanceAt_15th__c', 'BalanceAt_10th__c', 'BalanceAt_5th__c', 'Monthend__c'];
            let sum = 0;
            sumFields.forEach(field => {
                if (record[field] !== null && !isNaN(record[field])) {
                    var numberasvar=Number(record[field])
                     sum += parseFloat(numberasvar);
                }
            });
                var sumWithAver=Math.floor((sum/7).toFixed(2))
                if(!isNaN(sumWithAver)){
                    record.AverageBankBalance__c = sumWithAver;
                }else{
                    record.AverageBankBalance__c=0.00;
                }
            
            });
        this._foreditableTableData=ListOfRecords
     }
     totalOfMonthLimit=0
     monthlyLimit=0
     @track totalAfterChangesAbbCon=0;
     @track AverAfterChangesAbbCon=0
    calForTotalAndAverageWIthEdit(ListOfRecords,lengthOfData){

        console.log('gaaaaaaaaaaaaa'+JSON.stringify(ListOfRecords));
        let i=0;
        this.totalAfterChangesAbbCon=0;
        this.totalAfterChangesSummationCredit=0;
           this.totalAfterChangesSummationDebit =0;
           this.totalAfterChangesCountofCredit =0;
           this.totalAfterChangesCountofDebit =0;
           this.totalAfterChangesInwardReturnsCount =0;
            this.totalAfterChangesOutwardReturnsCount =0;
            this.totalAfterChangesStopPaymentCount =0;
            this.totalAfterChangesBalanceAt_1st =0;
            this.totalAfterChangesBalanceAt_5th__c =0;
            this.totalAfterChangesBalanceAt_10th =0;
            this.totalAfterChangesBalanceAt_15th =0;
            this.totalAfterChangesBalanceAt_20th =0;
            this.totalAfterChangesBalanceAt_25th =0;
            this.totalAfterChangesAverageBankBalance =0;
            this.totalAfterChangesMonthEnd =0;
            this.totalAfterChangesDailyBala =0;

            this.finalOfMiniAver='N'
            this.averageAfterChangesSummationCredit =0;
           this.averageAfterChangesSummationDebit  =0;
           this.averageAfterChangesCountofCredit  =0;
           this.averageAfterChangesCountofDebit  =0;
           this.averageAfterChangesOutwardReturnsCount =0;
            this.averageAfterChangesInwardReturnsCount  =0;
            this.averageAfterChangesStopPaymentCount  =0;
            this.averageAfterChangesBalanceAt_1st  =0;
            this.averageAfterChangesBalanceAt_5th__c  =0;
            this.averageAfterChangesBalanceAt_10th  =0;
            this.averageAfterChangesBalanceAt_15th  =0;
            this.averageAfterChangesBalanceAt_20th  =0;
            this.averageAfterChangesBalanceAt_25th  =0;
            this.averageAfterchangeAverageBankBalance =0;
            this.averageAfterChangesMonthEnd  =0;
            this.averageAfterChangesMonthEnd =0;
            this.averageOfUtilization
            this.totalOfMonthLimit=0;
            this.monthlyLimit=0
            ListOfRecords=this._foreditableTableData;
        for (const record of ListOfRecords) {
           // console.log('record'+JSON.stringify(record))

            this.totalAfterChangesSummationCredit += record.ValueSummationCredit__c == '' ||  record.ValueSummationCredit__c == null ||  record.ValueSummationCredit__c == undefined ? 0 :  record.ValueSummationCredit__c;
           this.totalAfterChangesSummationDebit += record.ValueSummationDebit__c == '' ||  record.ValueSummationDebit__c == null ||  record.ValueSummationDebit__c == undefined ? 0 :  record.ValueSummationDebit__c;
           this.totalAfterChangesCountofCredit +=   record.CountofCredit__c == '' ||  record.CountofCredit__c == null ||  record.CountofCredit__c == undefined ? 0 :  record.CountofCredit__c;
           this.totalAfterChangesCountofDebit +=  record.CountofDebit__c == '' ||  record.CountofDebit__c == null ||  record.CountofDebit__c == undefined ? 0 :  record.CountofDebit__c;
           this.totalAfterChangesInwardReturnsCount +=   record.InwardReturnsCount__c == '' ||  record.InwardReturnsCount__c == null ||  record.InwardReturnsCount__c == undefined ? 0 :  record.InwardReturnsCount__c;
            this.totalAfterChangesOutwardReturnsCount +=  record.OutwardReturnsCount__c == '' ||  record.OutwardReturnsCount__c == null ||  record.OutwardReturnsCount__c == undefined ? 0 :  record.OutwardReturnsCount__c;
            this.totalAfterChangesStopPaymentCount += record.StopPaymentCount__c == '' ||  record.StopPaymentCount__c == null ||  record.StopPaymentCount__c == undefined ? 0 :  record.StopPaymentCount__c;
            this.totalAfterChangesBalanceAt_1st += record.BalanceAt_1st__c == '' ||  record.BalanceAt_1st__c == null ||  record.BalanceAt_1st__c == undefined ? 0 :  record.BalanceAt_1st__c;
            this.totalAfterChangesBalanceAt_5th__c += record.BalanceAt_5th__c == '' ||  record.BalanceAt_5th__c == null ||  record.BalanceAt_5th__c == undefined ? 0 :  record.BalanceAt_5th__c;
            this.totalAfterChangesBalanceAt_10th +=  record.BalanceAt_10th__c == '' ||  record.BalanceAt_10th__c == null ||  record.BalanceAt_10th__c == undefined ? 0 :  record.BalanceAt_10th__c;
            this.totalAfterChangesBalanceAt_15th +=  record.BalanceAt_15th__c == '' ||  record.BalanceAt_15th__c == null ||  record.BalanceAt_15th__c == undefined ? 0 :  record.BalanceAt_15th__c;
            this.totalAfterChangesBalanceAt_20th += record.BalanceAt_20th__c == '' ||  record.BalanceAt_20th__c == null ||  record.BalanceAt_20th__c == undefined ? 0 :  record.BalanceAt_20th__c;
            this.totalAfterChangesBalanceAt_25th +=  record.BalanceAt_25th__c == '' ||  record.BalanceAt_25th__c == null ||  record.BalanceAt_25th__c == undefined ? 0 :  record.BalanceAt_25th__c;
            this.totalAfterChangesMonthEnd += record.Monthend__c == '' ||  record.Monthend__c == null ||  record.Monthend__c == undefined ? 0 :  record.Monthend__c;
            this.totalAfterChangesDailyBala +=  record.Average_Daily_Bank_Balance__c == '' ||  record.Average_Daily_Bank_Balance__c == null ||  record.Average_Daily_Bank_Balance__c == undefined ? 0 :  record.Average_Daily_Bank_Balance__c;
            this.totalAfterChangesAverageBankBalance +=    record.AverageBankBalance__c == '' ||  record.AverageBankBalance__c == null ||  record.AverageBankBalance__c == undefined ? Number(0) :  Number(record.AverageBankBalance__c);
            this.totalAfterChangesAbbCon += record.DailyABBBalance__c == '' ||  record.DailyABBBalance__c == null ||  record.DailyABBBalance__c == undefined ? Number(0) :  Number(record.DailyABBBalance__c);
            this.totalOfMonthLimit += record.MonthlyLimit__c == '' ||  record.MonthlyLimit__c == null ||  record.MonthlyLimit__c == undefined ? 0 :  record.MonthlyLimit__c;
            if(this.finalOfMiniAver ==undefined || this.finalOfMiniAver =='N' || this.finalOfMiniAver ==''){
                console.log('this.finalOfMiniAver'+this.finalOfMiniAver)
                this.finalOfMiniAver =record.MinBalanceCharges__c == '' ||  record.MinBalanceCharges__c == null ||  record.MinBalanceCharges__c == undefined ? 'N' :  record.MinBalanceCharges__c;
            }

            

            this.averageAfterChangesSummationCredit =Math.floor((this.totalAfterChangesSummationCredit / lengthOfData).toFixed(2))
           this.averageAfterChangesSummationDebit =Math.floor((this.totalAfterChangesSummationDebit / lengthOfData).toFixed(2))
           this.averageAfterChangesCountofCredit = Math.floor((this.totalAfterChangesCountofCredit / lengthOfData).toFixed(2))
           this.averageAfterChangesCountofDebit =Math.floor((this.totalAfterChangesCountofDebit/ lengthOfData).toFixed(2))
           this.averageAfterChangesOutwardReturnsCount =Math.floor((this.totalAfterChangesOutwardReturnsCount / lengthOfData).toFixed(2))
            this.averageAfterChangesInwardReturnsCount =Math.floor((this.totalAfterChangesInwardReturnsCount / lengthOfData).toFixed(2))
            this.averageAfterChangesStopPaymentCount =Math.floor((this.totalAfterChangesStopPaymentCount / lengthOfData).toFixed(2))
            this.averageAfterChangesBalanceAt_1st =Math.floor((this.totalAfterChangesBalanceAt_1st / lengthOfData).toFixed(2))
            this.averageAfterChangesBalanceAt_5th__c =Math.floor((this.totalAfterChangesBalanceAt_5th__c / lengthOfData).toFixed(2))
            this.averageAfterChangesBalanceAt_10th =Math.floor((this.totalAfterChangesBalanceAt_10th  / lengthOfData).toFixed(2))
            this.averageAfterChangesBalanceAt_15th =Math.floor((this.totalAfterChangesBalanceAt_15th / lengthOfData).toFixed(2))
            this.averageAfterChangesBalanceAt_20th =Math.floor((this.totalAfterChangesBalanceAt_20th / lengthOfData).toFixed(2))
            this.averageAfterChangesBalanceAt_25th = Math.floor((this.totalAfterChangesBalanceAt_25th / lengthOfData).toFixed(2))
            this.averageAfterchangeAverageBankBalance =Math.floor((this.totalAfterChangesAverageBankBalance / lengthOfData).toFixed(2))

            this.averageAfterChangesMonthEnd =Math.floor((this.totalAfterChangesMonthEnd / lengthOfData).toFixed(2))
            this.averageAfterchangeDailyBala = Math.floor((this.totalAfterChangesDailyBala / lengthOfData).toFixed(2))
            this.AverAfterChangesAbbCon=Math.floor((this.totalAfterChangesAbbCon / lengthOfData).toFixed(2))
             this.monthlyLimit=this.totalOfMonthLimit !=''&& this.totalOfMonthLimit !=null && typeof this.totalOfMonthLimit !==undefined ? Math.floor((this.totalOfMonthLimit/lengthOfData).toFixed(2)) :0
            this.averageOfUtilization= this.averageAfterchangeAverageBankBalance !=''&& this.averageAfterchangeAverageBankBalance !=null && typeof this.averageAfterchangeAverageBankBalance !==undefined && this.monthlyLimit!='' && this.monthlyLimit!=null && typeof this.monthlyLimit!='undefined' ? Math.floor(((this.averageAfterchangeAverageBankBalance * 100) /this.monthlyLimit ).toFixed(2)) : ''
           // this.monthlyLimit=this.totalOfMonthLimit !=''&& this.totalOfMonthLimit !=null && typeof this.totalOfMonthLimit !==undefined ? Math.floor((this.totalOfMonthLimit/lengthOfData).toFixed(2)) :0
        }
        let listOfAllTotal=[];
        let listOfAllAverage=[];
        listOfAllTotal.push(this.totalAfterChangesSummationDebit, this.totalAfterChangesSummationCredit, this.totalAfterChangesCountofDebit, this.totalAfterChangesCountofCredit, this.totalAfterChangesInwardReturnsCount, this.totalAfterChangesOutwardReturnsCount, this.totalAfterChangesStopPaymentCount, this.finalOfMiniAver, this.totalAfterChangesBalanceAt_1st, this.totalAfterChangesBalanceAt_5th__c, this.totalAfterChangesBalanceAt_10th,this.totalAfterChangesBalanceAt_15th, this.totalAfterChangesBalanceAt_20th,this.totalAfterChangesBalanceAt_25th,this.totalAfterChangesAverageBankBalance, this.averageOfUtilization)
        listOfAllAverage.push(this.averageAfterChangesSummationDebit, this.averageAfterChangesSummationCredit, this.averageAfterChangesCountofDebit, this.averageAfterChangesCountofCredit, this.averageAfterChangesInwardReturnsCount, this.averageAfterChangesOutwardReturnsCount, this.averageAfterChangesStopPaymentCount, this.finalOfMiniAver, this.averageAfterChangesBalanceAt_1st, this.averageAfterChangesBalanceAt_5th__c, this.averageAfterChangesBalanceAt_10th,this.averageAfterChangesBalanceAt_15th, this.averageAfterChangesBalanceAt_20th,this.averageAfterChangesBalanceAt_25th,this.averageAfterchangeAverageBankBalance, this.monthlyLimit)
        console.log('listOfAllTotallistOfAllTotal'+listOfAllTotal)
        if(this._foreditableTableData.length>0){
            console.log('inchildddddddddd');
            const bankDetailChildUpdate = new CustomEvent('bankdetailchildupdate', {
                //detail: this._foreditableTableData
                detail: { variable1: this._foreditableTableData, variable2: this.monthlyLimit, listForDelete: this.listForDeleteRe, diabledMonLimit: this.disabledForAvLimit, listOfAllAverage: listOfAllAverage, listOfAllTotal:listOfAllTotal }
            });
            console.log('before dispatch'+JSON.stringify(this._foreditableTableData))
            this.dispatchEvent(bankDetailChildUpdate);
        }

    }
    @track yearAndMonthList
    @track listForDeleteRe=[];
    @api addAppliBankRow(applicantBankingId, newMonthAndYearList){
        this._foreditableTableData=this.oldListforeditableTableData
        console.log('newMonthAndYearList>>>>>'+newMonthAndYearList);
         var listForDeleteRe=[];
        var fileredList=[];
        var records=this._foreditableTableData
        const filteredRecords = records.filter(record => {
            const recordMonthYear = `${record.Month__c}-${record.Year__c}`;
            //return if(!newMonthAndYearList.includes(recordMonthYear);
            if(!newMonthAndYearList.includes(recordMonthYear)){
                listForDeleteRe.push(record)
            }else{
                fileredList.push(record)
            }
        });
        this.listForDeleteRe=listForDeleteRe
        this._foreditableTableData=fileredList;
        console.log('listForDeleteRe'+JSON.stringify(this.listForDeleteRe))
        console.log('fileredList'+JSON.stringify(this._foreditableTableData))


        let yearAndMonthList=[];
        for (const record of this._foreditableTableData){
            yearAndMonthList.push(record.Month__c+'-'+record.Year__c);
        }
        this.yearAndMonthList=yearAndMonthList

        //console.log('newMonthAndYearList.length>0'+this.foreditableTableData.length)
        //this.oldMainListofAppliDetailRec=this._foreditableTableData
            let blankListForNewDetailRec = [{"ApplBanking__c":"","Month__c":"","Year__c":"","ValueSummationCredit__c":'',"ValueSummationDebit__c":'',"CountofCredit__c":'',"CountofDebit__c":'',"InwardReturnsCount__c":'',"OutwardReturnsCount__c":'',"StopPaymentCount__c":'',"MinBalanceCharges__c":"","BalanceAt_1st__c":'',"BalanceAt_5th__c":'',"BalanceAt_10th__c":'',"BalanceAt_15th__c":'',"BalanceAt_20th__c":'',"BalanceAt_25th__c":'',"AverageBankBalance__c":'',"isDummy":true, "Monthend__c":'', "Average_Daily_Bank_Balance__c":''}];
            if(newMonthAndYearList !=undefined && newMonthAndYearList != null && newMonthAndYearList!=''){
                var UpdatedList = [];
               // console.log('newMonthAndYearList.length>0'+this.foreditableTableData.length)
                for(let i=0;i<this._foreditableTableData.length;i++){
                    if(typeof this._foreditableTableData[i].isDummy !== 'undefined' && this._foreditableTableData[i].isDummy){
                       
                       // console.log('test>>>'+this._foreditableTableData[i].Month__c+'-'+this._foreditableTableData[i].Year__c);
                        this.yearAndMonthList.splice(this.yearAndMonthList.indexOf(this._foreditableTableData[i].Month__c+'-'+this._foreditableTableData[i].Year__c),1);
                        
                    }else {
                        UpdatedList.push(this._foreditableTableData[i]);
                    }
                }
                this._foreditableTableData = JSON.parse(JSON.stringify(UpdatedList));
               // console.log(' this._foreditableTableData>>>>>>>>>>>>'+ this._foreditableTableData);
                for (const record of newMonthAndYearList) {
                    const [month, year] = record.split('-');
                    const newRecord = { ...blankListForNewDetailRec[0], Month__c: month, Year__c: year, ApplBanking__c:applicantBankingId};
                    if (!this.yearAndMonthList.includes(record)) {
                        console.log('in push'+record);
                        this.yearAndMonthList.push(record);
                        this._foreditableTableData.push(newRecord);
                       // console.log(' this.ForMonthlyLimit this.ForMonthlyLimit'+JSON.stringify(this._foreditableTableData));
                    } else {
                        console.log('no'+record);

                    }
                }
                let uniqueMonthYearSet = new Set();
                let uniqueRecords = [];

                this._foreditableTableData.forEach(record => {
                    let monthYearKey = record.Month__c + '-' + record.Year__c; // Combine month and year
                    if (!uniqueMonthYearSet.has(monthYearKey)) {
                        uniqueMonthYearSet.add(monthYearKey); // Add unique combination
                        uniqueRecords.push(record); // Add record to unique list
                    }
                });
                this._foreditableTableData=uniqueRecords;
                console.log('this._foreditableTableData488'+JSON.stringify(this._foreditableTableData));
                this._foreditableTableData.sort(this.customSort);
                this.calculationforsum(this._foreditableTableData);
                this.calForUtilization();
                this.ForMonthlyLimit(this._foreditableTableData);
                this.calForTotalAndAverageWIthEdit(this._foreditableTableData,this._foreditableTableData.length);
              //console.log('this.yearAndMonthList'+this.yearAndMonthList)
            
            }else{
                console.log('inelseeee');
           // this._foreditableTableData=this.oldMainListofAppliDetailRec;
            var testList=[];
            for (const record of this._foreditableTableData){
                testList.push(record.Month__c+'-'+record.Year__c);
                //var applicantBankingId = record.ApplBanking__c
            }
            this.yearAndMonthList=testList;
            console.log('ifEndMonthOsnull'+this._foreditableTableData +  '>>>>>>'+this.yearAndMonthList)
        }
        console.log('inmethodenddd')
     }
     
    @api validateForm(){
        let isValid = true
    
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if(element.reportValidity()){
                //console.log('element passed');
            }else{
                isValid = false;
                //element.setCustomValidity('Please fill the valid value')
            }
            

        });
        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            if(element.reportValidity()){
                //console.log('element passed');
            }else{
                isValid = false;
                //element.setCustomValidity('Please fill the valid value')
            }
            
        }); 

       return isValid
    }
}