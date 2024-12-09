import { LightningElement,api,wire,track} from 'lwc';
import getfinancialSatement from '@salesforce/apex/ObligationDetailsSummaryController.getfinancialSatement';
import getFilterRelRecordsWithOutCache from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataWithoutCacheable';
import { refreshApex } from '@salesforce/apex';

export default class FinancialStatements extends LightningElement {
  
     @track listFinancialYearRecord=[];
     @track showFinancialData = false;
     @api applicantId;
     @track _activeFinancialTab;
     @track refreshKey = 0;
     @api get activeFinancialTab() {
          return this._activeFinancialTab;
      }
      set activeFinancialTab(value) {
          this._activeFinancialTab = value; 
          this.setAttribute("activeFinancialTab", value);
          this.refreshKey += 1;  
      }

    @track _recordId;
     @api get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        this._recordId = value;
        this.setAttribute("recordId", value);
        
    }

    @track _isBlPl;
    @api get isBlPl() {
        return this._isBlPl;
    }
    set isBlPl(value) {
        this._isBlPl = value;
        this.setAttribute("isBlPl", value);
        
    }
   

    @track financialStatementData;
     @wire(getfinancialSatement,{ recordId: '$_recordId', activeTab:'$refreshKey'})
    wiredFinancialSummarie(financialStatemData) {
        console.log('Wire Financial statement----------->');
        let {data,error}  = financialStatemData;
        this.financialStatementData = financialStatemData;
        
        if (data) {
            console.log('Wire Financial statement Data---------->'+JSON.stringify(data));
            this.listFinancialYearRecord =[];
            for (let key in data) {
                this.listFinancialYearRecord.push({key:key, value:data[key]});
            }
            if(this.listFinancialYearRecord.length>0){
                this.showFinancialData = true;                 
            }
            this.applicantId='a0AC4000000gGDF';
            // this.SummDataOfCons();
      
         
        } else if (error) {
            console.error('Error loading financial summaries: ', error);
        }
    } 

  
    //Debtors Collection Period
    get debtCollPerCurrYrColCode(){
        if(this.listFinancialYearRecord[0].value.currentFinancialYear.debtorsCollectionPeriod 
        && this.listFinancialYearRecord[0].value.currentFinancialYear.debtorsCollectionPeriod >= 90){
            return true;
        }else{
            return false;
        }
    }

    get debtCollPerPrevYrColrCode(){
       if( this.listFinancialYearRecord[0].value.lastFinancialYear.debtorsCollectionPeriod 
        && this.listFinancialYearRecord[0].value.lastFinancialYear.debtorsCollectionPeriod >= 90){
            return true;
        }else{
            return false;
        }
    }

    get debtCollPerProvYrColrCode(){
        if(this.listFinancialYearRecord[0].value.provisionalFinancialYear.debtorsCollectionPeriod 
        && this.listFinancialYearRecord[0].value.provisionalFinancialYear.debtorsCollectionPeriod >= 90){
            return true;
        }else{
            return false;
        }
    }

    //Creditors Payement Period
    get credPayPerCurrYrColrCode(){
        if(this.listFinancialYearRecord[0].value.currentFinancialYear.creditorsPayementPeriod 
        && this.listFinancialYearRecord[0].value.currentFinancialYear.creditorsPayementPeriod >= 90){
            return true;
        }else{
            return false;
        }
    }

    get credPayPerPrevYrColrCode(){
        if(this.listFinancialYearRecord[0].value.lastFinancialYear.creditorsPayementPeriod 
        && this.listFinancialYearRecord[0].value.lastFinancialYear.creditorsPayementPeriod >= 90){
            return true;
        }else{
            return false;
        }
    }

    get credPayPerProvYrColrCode(){
        if(this.listFinancialYearRecord[0].value.provisionalFinancialYear.creditorsPayementPeriod 
        && this.listFinancialYearRecord[0].value.provisionalFinancialYear.creditorsPayementPeriod >= 90){
            return true;
        }else{
            return false;
        }
    }

     // Stock Replenishnent Period
    get stockReplPerCurrYrColrCode(){
        if(this.listFinancialYearRecord[0].value.currentFinancialYear.stockReplenishnentPeriod 
        && this.listFinancialYearRecord[0].value.currentFinancialYear.stockReplenishnentPeriod >= 90){
            return true;
        }else{
            return false;
        }
    }

    get stockReplPerPrevYrColrCode(){
        if(this.listFinancialYearRecord[0].value.lastFinancialYear.stockReplenishnentPeriod 
        && this.listFinancialYearRecord[0].value.lastFinancialYear.stockReplenishnentPeriod >= 90){
            return true;
        }else{
            return false;
        }
    }

    get stockReplPerProvYrColrCode(){
        if(this.listFinancialYearRecord[0].value.provisionalFinancialYear.stockReplenishnentPeriod 
        && this.listFinancialYearRecord[0].value.provisionalFinancialYear.stockReplenishnentPeriod >= 90){
            return true;
        }else{
            return false;
        }
    }

    // Inventry Turn Over
    get invtrTurnOverCurrYrColrCode(){
        if(this.listFinancialYearRecord[0].value.currentFinancialYear.inventryTorunOver 
        && this.listFinancialYearRecord[0].value.currentFinancialYear.inventryTorunOver < 4){
            return true;
        }else{
            return false;
        }
    }

    get invtrTurnOverPrevYrColrCode(){
        if(this.listFinancialYearRecord[0].value.lastFinancialYear.inventryTorunOver 
        && this.listFinancialYearRecord[0].value.lastFinancialYear.inventryTorunOver < 4){
            return true;
        }else{
            return false;
        }
    }

    get invtrTurnOverProvYrColrCode(){
        if(this.listFinancialYearRecord[0].value.provisionalFinancialYear.inventryTorunOver 
        && this.listFinancialYearRecord[0].value.provisionalFinancialYear.inventryTorunOver < 4){
            return true;
        }else{
            return false;
        }
    }
//Gap Days
    get isGapDaysGreaterThan180(){
        if(this.listFinancialYearRecord[0].value.currentFinancialYear.gapDays 
        && Number(this.listFinancialYearRecord[0].value.currentFinancialYear.gapDays) >= 180){
            return true;
        }else{
            return false;
        }
    }

        // Current Ratio
    get currRatioCurrYrColrCode(){
        if(this.listFinancialYearRecord[0].value.currentFinancialYear.currentRatio 
        && this.listFinancialYearRecord[0].value.currentFinancialYear.currentRatio >= 1.30 ){
            return false;
        }else{
            return true;
        }
    }

    get currRatioPrevYrColrCode(){
        if(this.listFinancialYearRecord[0].value.lastFinancialYear.currentRatio 
        && this.listFinancialYearRecord[0].value.lastFinancialYear.currentRatio >= 1.30){
            return false;
        }else{
            return true;
        }
    }

    get currRatioProvYrColrCode(){
        if(this.listFinancialYearRecord[0].value.provisionalFinancialYear.currentRatio 
        && this.listFinancialYearRecord[0].value.provisionalFinancialYear.currentRatio >= 1.30){
            return false;
        }else{
            return true;
        }
    }

    // Quick Ratio
    get quickRatioCurrYrColrCode(){
        if(this.listFinancialYearRecord[0].value.currentFinancialYear.quickRatio 
        && this.listFinancialYearRecord[0].value.currentFinancialYear.quickRatio >= 1){
            return false;
        }else{
            return true;
        }
    }

    get quickRatioPrevYrColrCode(){
        if(this.listFinancialYearRecord[0].value.lastFinancialYear.quickRatio 
        && this.listFinancialYearRecord[0].value.lastFinancialYear.quickRatio >= 1){
            return false;
        }else{
            return true;
        }
    }

    get quickRatioProvYrColrCode(){
        if(this.listFinancialYearRecord[0].value.provisionalFinancialYear.quickRatio 
        && this.listFinancialYearRecord[0].value.provisionalFinancialYear.quickRatio >= 1){
            return false;
        }else{
            return true;
        }
    }

     // Interest Coverage Ratio
     get intrstCovrgRatioCurrYrColrCode(){
        if(this.listFinancialYearRecord[0].value.currentFinancialYear.interestCoverageRatio 
        && this.listFinancialYearRecord[0].value.currentFinancialYear.interestCoverageRatio >= 2){
            return false;
        }else{
            return true;
        }
    }

    get intrstCovrgRatioPrevYrColrCode(){
        if(this.listFinancialYearRecord[0].value.lastFinancialYear.interestCoverageRatio 
        && this.listFinancialYearRecord[0].value.lastFinancialYear.interestCoverageRatio >= 2){
            return false;
        }else{
            return true;
        }
    }

    get intrstCovrgRatioProvYrColrCode(){
        if(this.listFinancialYearRecord[0].value.provisionalFinancialYear.interestCoverageRatio 
        && this.listFinancialYearRecord[0].value.provisionalFinancialYear.interestCoverageRatio >= 2){
            return false;
        }else{
            return true;
        }
    }

       // Debt Equity Ratio
       get debtEqtyRatioCurrYrColrCode(){
        if(this.listFinancialYearRecord[0].value.currentFinancialYear.debtEquityRatio 
        && this.listFinancialYearRecord[0].value.currentFinancialYear.debtEquityRatio > 3){
            return true;
        }else{
            return false;
        }
    }

    get debtEqtyRatioPrevYrColrCode(){
        if(this.listFinancialYearRecord[0].value.lastFinancialYear.debtEquityRatio 
        && this.listFinancialYearRecord[0].value.lastFinancialYear.debtEquityRatio > 3){
            return true;
        }else{
            return false;
        }
    }

    get debtEqtyRatioProvYrColrCode(){
        if(this.listFinancialYearRecord[0].value.provisionalFinancialYear.debtEquityRatio 
        && this.listFinancialYearRecord[0].value.provisionalFinancialYear.debtEquityRatio > 3){
            return true;
        }else{
            return false;
        }
    }

        //leverage Ratio
        get levrageRatioCurrYrColrCode(){
            if(this.listFinancialYearRecord[0].value.currentFinancialYear.laverageRatio 
            && this.listFinancialYearRecord[0].value.currentFinancialYear.laverageRatio > 7){
                return true;
            }else{
                return false;
            }
        }
    
        get levrageRatioPrevYrColrCode(){
            if(this.listFinancialYearRecord[0].value.lastFinancialYear.laverageRatio 
            && this.listFinancialYearRecord[0].value.lastFinancialYear.laverageRatio > 7){
                return true;
            }else{
                return false;
            }
        }
    
        get levrageRatioProvYrColrCode(){
            if(this.listFinancialYearRecord[0].value.provisionalFinancialYear.laverageRatio 
            && this.listFinancialYearRecord[0].value.provisionalFinancialYear.laverageRatio > 7){
                return true;
            }else{
                return false;
            }
        }

    // @track financialGstDetails;
    // @track showFinancialGstDetails = false;
    // mapOfMonthWithTaxConsol;
    // OldConaolidateList
    // ConsoliGSTRecForDelete
    // SummDataOfCons(){
    //     const parametersAppFinCon = {
    //         ParentObjectName: 'Applicant_Financial__c ',
    //         ChildObjectRelName: 'Applicant_Financial_Summary_s__r',
    //         parentObjFields: ['Id', 'Loan_Application__c','Applicant_GST__r.GSTIN__c','TypeOfFinancial__c','Loan_Applicant__r.FullName__c', 'Loan_Applicant__c'],
    //         childObjFields: ['Id', 'Gross_Turnover_as_per_GST_excl_taxes__c', 'GST_Month_Year__c', 'Index__c','FilingDate__c','Gross_TO_NIL_Rated__c'],
    //        // queryCriteriaForChild: ' order by Index__c asc',
    //         queryCriteria: ' where Loan_Applicant__c = \'' + this.applicantId + '\' and Type__c = \'Consolidate GST\''
            
    //     }
    //     getFilterRelRecordsWithOutCache({ params: parametersAppFinCon })
    //         .then((data) => {
    //             this.financialGstDetails=data
    //             this.OldConaolidateList=data
    //             let mapOfMonthWithTaxConsol={}
    //             for(const record of this.financialGstDetails){
    //                 if(record.parentRecord.Applicant_Financial_Summary_s__r){
    //                     this.showFinancialGstDetails = true;
    //                     for(const rec of record.parentRecord.Applicant_Financial_Summary_s__r){
    //                         mapOfMonthWithTaxConsol[rec.GST_Month_Year__c]=rec
    //                     }
    //                     // let listofkeys=Object.keys(mapOfMonthWithTaxConsol)
    //                    // console.log('listofkeys'+Object.keys(mapOfMonthWithTaxConsol))
    //                 }
    //             }
    //           //  console.log('mapOfMonthWithTaxConsol'+mapOfMonthWithTaxConsol)
    //             this.mapOfMonthWithTaxConsol=mapOfMonthWithTaxConsol
    //             console.log('this.appliFinancialConRec 352', this.appliFinancialConRec);
    //             this.sortAndReindex(this.appliFinancialConRec);
    //         })
    //         .catch(error => {
    //             console.log('Errorured:-999 '+JSON.stringify(error));
    //         });
    // }
    // sortAndReindex(records) {
    //     records.forEach(record => {
    //         if(record.parentRecord.Applicant_Financial_Summary_s__r){
    //             let financialSummary = record.parentRecord.Applicant_Financial_Summary_s__r;
    
    //         // Convert GST_Month_Year__c to Date for sorting
    //         financialSummary.sort((a, b) => {
    //             let dateA = this.convertToDate(a.GST_Month_Year__c);
    //             let dateB = this.convertToDate(b.GST_Month_Year__c);
    //             return dateA - dateB;
    //         });
    
    //         // Update Index__c based on sorted order
    //         financialSummary.forEach((item, index) => {
    //             item.Index__c = index + 1;
    //         });
    //         }
            
    //     });
    //     return records;
    // }
 
    renderedCallback(){
        refreshApex(this.financialStatementData);
       
    }
        
}