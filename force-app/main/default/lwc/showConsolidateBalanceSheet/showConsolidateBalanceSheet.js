import { LightningElement, track, wire, api } from 'lwc';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import FINANCIAL_OBJECT from '@salesforce/schema/Applicant_Financial__c';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import deleteRecord_Data from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';
import processDefunctRecordsFinancial from '@salesforce/apex/FinancialRecordProcessor.processDefunctRecordsFinancial';
import fetchRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getAllSobjectDatawithRelatedRecords';

// Custom labels
import BalanceSheet_save_SuccessMessage from '@salesforce/label/c.BalanceSheet_save_SuccessMessage';
import BalanceSheet_ErrorMessage from '@salesforce/label/c.BalanceSheet_ErrorMessage';
import BalanceSheet_Data_ErrorMessage from '@salesforce/label/c.BalanceSheet_Data_ErrorMessage';
import BalanceSheet_Value_ErrorMessage from '@salesforce/label/c.BalanceSheet_Value_ErrorMessage';

export default class ShowConsolidateBalanceSheet extends LightningElement {
    customLabel = {
        BalanceSheet_save_SuccessMessage,
        BalanceSheet_ErrorMessage,
        BalanceSheet_Data_ErrorMessage,
        BalanceSheet_Value_ErrorMessage

    }
    @track wrapObj1={};
    @track wrapObj2={};
    @track wrapObj3={};
    //@api loanAppId;
    @api hasEditAccess;
    @track financialType = 'Balance_Sheet';
    @track _applicantId ;
    @track _loanAppId;
    @track provisionalFinancialSelection;

    //@track provisionalFinancialOptions =[{label: 'Yes', value:'Yes'}, {label:'No', value:'No'}];
    @track _currentBlock;

    @track _provisionalOption;
    @track _provisionalYear;

    @api get provisionalOption(){
        return this._provisionalOption;
    }
    set provisionalOption(value) {
        this._provisionalOption = value;
        this.setAttribute("provisionalOption", value);
        this.checkProvisionalOptionValue();
    }

    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);
        this.handleLoanIdChange(value);
    }

    @api get provisionalYear(){
        return this._provisionalYear;
    }
    set provisionalYear(value) {
        this._provisionalYear = value;
        this.setAttribute("provisionalYear", value);
        this.checkProvisionalOptionValue();
    }

    @track provisionalFinancialYear;

    checkProvisionalOptionValue(){

        if(this._provisionalYear && this._provisionalOption && this._provisionalOption === 'Yes'){
            this.provisionalFinancialYearSelectionValue = this._provisionalYear;
            this.provisionalFinancialYear = this._provisionalYear;
            this.handleRecordAppIdChange(null);
        }else{
            this.provisionalFinancialYearSelectionValue = undefined;
            this.provisionalFinancialYear = undefined;
        }
    }


    @api get applicantId(){
        return this._applicantId;
    }

    set applicantId(value){
        this._applicantId = value;
        this.setAttribute('applicantId', value);
        this.handleRecordAppIdChange(value)
    }

    @api get currentBlock(){
        return this._currentBlock;
    }

    set currentBlock(value){
        this._currentBlock = value;
        this.setAttribute('currentBlock', value);
        //this.provisionalFinancialYearSelectionValue = undefined;
        //this.provisionalFinancialSelection = undefined;
        this.handleRecordAppIdChange(value)
    }


    get disableMode(){
        return true
    }

    @track
    parameter = {
        ParentObjectName: 'Applicant_Financial_Summary__c ',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Share_capital_Partner_s_Capital__c', 'P_L_A_capital__c', 'Revaluation_Reserves_Notional_Reserves__c',
                         'Net_worth__c', 'Adavces_to_group_co_friends__c', 'unsecured_Loan_from_promoters_family_m__c', 'Misc_Exp_Not_written_off__c',
                         'Adjusted_tangible_Netwroth__c', 'Bank_Borrowing_Working_Capital_OD_CC__c', 'Secured_debts_Banks_Ndfc__c', 'Unsecured_debts_Banks_Ndfc__c',
                         'Other_Loans_From_private_parties__c', 'Total_Loan_funds__c', 'Sundry_creditors__c', 'Advances_from_customers__c','Other_current_liabilities__c',
                         'Provisions_for_exps_tax_etc__c', 'Deffered_Tax_Liability_Assets__c', 'Net_Tangible_Fixed_Assets_Including_Cap__c',
                         'Net_Intangible_Fixed_Assets__c', 'Stock__c', 'Debtors__c', 'LessSix_months__c','Greaterthan6__c', 'Advances_to_Suppliers__c','Investments__c','Other_loans_advances__c',
                         'Prepaid_expenses__c', 'Other_current_assets__c', 'Other_Non_Current_assets_Security_Depos__c', 'Cash_Bank_Balances__c','Total__c',
                         'Difference__c', 'Applicant_Financial__c','Applicant_Financial__r.RecordTypeId','Applicant_Financial__r.RecordType.DeveloperName',
                         'Applicant_Financial__r.Loan_Applicant__c', 'Financial_Year__c', 'Liabilities_Remarks__c',	'Share_capital_Remarks__c',	'Gross_Profit_Remark__c',
                         'Reevaluation_Remark__c','Advances_Remarks__c','Unsecured_Loan_Remarks__c','Other_Indirect_Expenses_Remark__c','Borrowing_Remarks__c',	
                         'Secured_Remarks__c',	'Unsecured_Remarks__c',	'Other_Operating_Income_Remark__c',	'Sundry_Remarks__c', 'Purchases_Remark__c',	'Total_Loan_Remarks__c', 
                         'Taxes_Remark__c',	'Deferred_Tax_Liability_Remark__c',	'Assets_Remarks__c','Adjustable_Remarks__c','Profit_Before_Tax_Remark__c',	'Opening_Stock_Remark__c',	
                         'EBITDA_Remark__c','Less_Six_Months_Remarks__c','Greater_Six_Months_Remarks__c','Office_Administrative_Expenses_Remark__c',	
                         'Non_Operating_Expenses_Remark__c',	'Profit_Before_Depreciation_PBDT_Remark__c',	'Direct_Expenses_Remark__c','Depreciation_Remark__c',	
                         'Interest_on_CC_OD_limits_Remark__c','PAT_Remark__c', 'Comments_on_Balance_sheet__c'],
        childObjFields: [],
        queryCriteria: 'WHERE Applicant_Financial__c !=null AND Applicant_Financial__r.RecordTypeId !=null AND '+
                       ' Applicant_Financial__r.RecordType.DeveloperName=\''+ this.financialType +'\' AND Applicant_Financial__r.Loan_Applicant__c=\''+this._applicantId+'\' '+
                       ' AND Financial_Year__c IN (\''+this.currentFinancialYear+'\',\''+this.previousFinancialYear+'\',\''+this.provisionalFinancialYear+'\')'
    }

    // Add filter for Financial Year

    handleRecordAppIdChange(value) {
        let tempParams = this.parameter;
        tempParams.queryCriteria = 'WHERE Applicant_Financial__c !=null AND Applicant_Financial__r.RecordTypeId !=null AND '+
                                   ' Applicant_Financial__r.RecordType.DeveloperName=\''+ this.financialType +'\' AND Applicant_Financial__r.Loan_Applicant__c=\''+this._applicantId+'\''+
                                   ' AND Financial_Year__c IN (\''+this.currentFinancialYear+'\',\''+this.previousFinancialYear+'\',\''+this.provisionalFinancialYear+'\')'
        this.parameter = { ...tempParams };

        let tempParams1 = this.parameterApplicant;
        tempParams1.queryCriteria = 'WHERE ID=\''+this._applicantId+'\' ';
        this.parameterApplicant = { ...tempParams1 };

    }



    @track applicantBalanceSheetData ;
    // @wire(getSobjectData, { params: '$parameter' })
    // handleIncomeResponse(wiredResultBS) {
    //     let { error, data } = wiredResultBS;
    //     this.applicantBalanceSheetData = wiredResultBS;
    //     if (data) {
    //         if(data.parentRecords && data.parentRecords.length>0){
    //             console.log('Financial Data!! '+JSON.stringify(data.parentRecords));
    //             this.formFinancialData(data.parentRecords);
    //         }else{
    //             this.formFinancialData(null);
    //         }
    //     } else if (error) {
    //         console.error('Error BS ------------->', error);
    //     }
    // }

    @track parameterApplicant = {
        ParentObjectName: 'Applicant__c ',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'LatestyearforwhichITRisavailable__c', 'Provisional_Financials_Available__c', 'Provisional_Financials_Year__c'],
        childObjFields: [],
        queryCriteria: 'WHERE ID=\''+this._applicantId+'\' '
    }

    @track applicantDataResponse;

    @wire(getSobjectData, { params: '$parameterApplicant' })
    handleApplicantResponse(wiredResultApp) {
        let { error, data } = wiredResultApp;
        this.applicantDataResponse = wiredResultApp;
        if (data) {
        } else if (error) {
            console.error('Error App ------------->', error);
        }
    }

 

    // formFinancialData(dataRecord){
    //     this.wrapObj2 = null;
    //     this.wrapObj1 = null;
    //     this.wrapObj3 = null;
    //     if(dataRecord && dataRecord.length>0){
    //         for(var i=0; i<dataRecord.length; i++){

    //             let objectData = {
    //                 Id: dataRecord[i].Id,
    //                 Share_capital_Partner_s_Capital__c: dataRecord[i].Share_capital_Partner_s_Capital__c ?  dataRecord[i].Share_capital_Partner_s_Capital__c : 0,
    //                 P_L_A_capital__c: dataRecord[i].P_L_A_capital__c  ?  dataRecord[i].P_L_A_capital__c : 0,
    //                 Revaluation_Reserves_Notional_Reserves__c: dataRecord[i].Revaluation_Reserves_Notional_Reserves__c ? dataRecord[i].Revaluation_Reserves_Notional_Reserves__c : 0,
    //                 Adavces_to_group_co_friends__c: dataRecord[i].Adavces_to_group_co_friends__c  ?  dataRecord[i].Adavces_to_group_co_friends__c : 0,
    //                 unsecured_Loan_from_promoters_family_m__c: dataRecord[i].unsecured_Loan_from_promoters_family_m__c ? dataRecord[i].unsecured_Loan_from_promoters_family_m__c : 0,
    //                 Misc_Exp_Not_written_off__c: dataRecord[i].Misc_Exp_Not_written_off__c ? dataRecord[i].Misc_Exp_Not_written_off__c : 0,
    //                 Bank_Borrowing_Working_Capital_OD_CC__c: dataRecord[i].Bank_Borrowing_Working_Capital_OD_CC__c ? dataRecord[i].Bank_Borrowing_Working_Capital_OD_CC__c : 0,
    //                 Secured_debts_Banks_Ndfc__c: dataRecord[i].Secured_debts_Banks_Ndfc__c ? dataRecord[i].Secured_debts_Banks_Ndfc__c : 0,
    //                 Unsecured_debts_Banks_Ndfc__c: dataRecord[i].Unsecured_debts_Banks_Ndfc__c ? dataRecord[i].Unsecured_debts_Banks_Ndfc__c : 0,
    //                 Other_Loans_From_private_parties__c: dataRecord[i].Other_Loans_From_private_parties__c ? dataRecord[i].Other_Loans_From_private_parties__c : 0,
    //                 Sundry_creditors__c: dataRecord[i].Sundry_creditors__c ? dataRecord[i].Sundry_creditors__c : 0,
    //                 Advances_from_customers__c: dataRecord[i].Advances_from_customers__c ? dataRecord[i].Advances_from_customers__c : 0,
    //                 Other_current_liabilities__c: dataRecord[i].Other_current_liabilities__c ? dataRecord[i].Other_current_liabilities__c : 0,
    //                 Provisions_for_exps_tax_etc__c: dataRecord[i].Provisions_for_exps_tax_etc__c ? dataRecord[i].Provisions_for_exps_tax_etc__c : 0,
    //                 Deffered_Tax_Liability_Assets__c: dataRecord[i].Deffered_Tax_Liability_Assets__c ? dataRecord[i].Deffered_Tax_Liability_Assets__c : 0,
    //                 Net_Tangible_Fixed_Assets_Including_Cap__c: dataRecord[i].Net_Tangible_Fixed_Assets_Including_Cap__c ? dataRecord[i].Net_Tangible_Fixed_Assets_Including_Cap__c : 0,
    //                 Net_Intangible_Fixed_Assets__c: dataRecord[i].Net_Intangible_Fixed_Assets__c ? dataRecord[i].Net_Intangible_Fixed_Assets__c : 0,
    //                 Stock__c: dataRecord[i].Stock__c ? dataRecord[i].Stock__c : 0,
    //                 Debtors__c: dataRecord[i].Debtors__c ? dataRecord[i].Debtors__c : 0,
    //                 LessSix_months__c: dataRecord[i].LessSix_months__c ? dataRecord[i].LessSix_months__c : 0,
    //                 Greaterthan6__c: dataRecord[i].Greaterthan6__c ? dataRecord[i].Greaterthan6__c : 0,
    //                 Advances_to_Suppliers__c: dataRecord[i].Advances_to_Suppliers__c ? dataRecord[i].Advances_to_Suppliers__c : 0,
    //                 Investments__c: dataRecord[i].Investments__c ? dataRecord[i].Investments__c : 0,
    //                 Other_loans_advances__c: dataRecord[i].Other_loans_advances__c ? dataRecord[i].Other_loans_advances__c : 0,
    //                 Prepaid_expenses__c: dataRecord[i].Prepaid_expenses__c ? dataRecord[i].Prepaid_expenses__c : 0,
    //                 Other_current_assets__c: dataRecord[i].Other_current_assets__c ? dataRecord[i].Other_current_assets__c : 0,
    //                 Other_Non_Current_assets_Security_Depos__c: dataRecord[i].Other_Non_Current_assets_Security_Depos__c ? dataRecord[i].Other_Non_Current_assets_Security_Depos__c : 0,
    //                 Cash_Bank_Balances__c: dataRecord[i].Cash_Bank_Balances__c ? dataRecord[i].Cash_Bank_Balances__c : 0,
    //                 Net_worth__c: dataRecord[i].Net_worth__c ? dataRecord[i].Net_worth__c : 0,
    //                 Adjusted_tangible_Netwroth__c: dataRecord[i].Adjusted_tangible_Netwroth__c ? dataRecord[i].Adjusted_tangible_Netwroth__c : 0,
    //                 Total_Loan_funds__c: dataRecord[i].Total_Loan_funds__c ? dataRecord[i].Total_Loan_funds__c : 0,
    //                 Total__c: dataRecord[i].Total__c ? dataRecord[i].Total__c : 0,
    //                 Difference__c: dataRecord[i].Difference__c ? dataRecord[i].Difference__c : 0,
    //                 Liabilities_Remarks__c: dataRecord[i].Liabilities_Remarks__c ? dataRecord[i].Liabilities_Remarks__c : '',
    //                 Share_capital_Remarks__c: dataRecord[i].Share_capital_Remarks__c ? dataRecord[i].Share_capital_Remarks__c : '',
    //                 Gross_Profit_Remark__c: dataRecord[i].Gross_Profit_Remark__c ? dataRecord[i].Gross_Profit_Remark__c : '',
    //                 Reevaluation_Remark__c: dataRecord[i].Reevaluation_Remark__c ? dataRecord[i].Reevaluation_Remark__c : '',
    //                 Advances_Remarks__c: dataRecord[i].Advances_Remarks__c ? dataRecord[i].Advances_Remarks__c : '',
    //                 Unsecured_Loan_Remarks__c: dataRecord[i].Unsecured_Loan_Remarks__c ? dataRecord[i].Unsecured_Loan_Remarks__c : '',
    //                 Other_Indirect_Expenses_Remark__c: dataRecord[i].Other_Indirect_Expenses_Remark__c ? dataRecord[i].Other_Indirect_Expenses_Remark__c : '',
    //                 Borrowing_Remarks__c: dataRecord[i].Borrowing_Remarks__c ? dataRecord[i].Borrowing_Remarks__c : '',
    //                 Secured_Remarks__c: dataRecord[i].Secured_Remarks__c ? dataRecord[i].Secured_Remarks__c : '',
    //                 Unsecured_Remarks__c: dataRecord[i].Unsecured_Remarks__c ? dataRecord[i].Unsecured_Remarks__c : '',
    //                 Other_Operating_Income_Remark__c: dataRecord[i].Other_Operating_Income_Remark__c ? dataRecord[i].Other_Operating_Income_Remark__c : '',
    //                 Sundry_Remarks__c: dataRecord[i].Sundry_Remarks__c ? dataRecord[i].Sundry_Remarks__c : '',
    //                 Purchases_Remark__c: dataRecord[i].Purchases_Remark__c ? dataRecord[i].Purchases_Remark__c : '',
    //                 Total_Loan_Remarks__c: dataRecord[i].Total_Loan_Remarks__c ? dataRecord[i].Total_Loan_Remarks__c : '',
    //                 Taxes_Remark__c: dataRecord[i].Taxes_Remark__c ? dataRecord[i].Taxes_Remark__c : '',
    //                 Deferred_Tax_Liability_Remark__c: dataRecord[i].Deferred_Tax_Liability_Remark__c ? dataRecord[i].Deferred_Tax_Liability_Remark__c : '',
    //                 Assets_Remarks__c: dataRecord[i].Assets_Remarks__c ? dataRecord[i].Assets_Remarks__c : '',
    //                 Adjustable_Remarks__c: dataRecord[i].Adjustable_Remarks__c ? dataRecord[i].Adjustable_Remarks__c : '',
    //                 Profit_Before_Tax_Remark__c: dataRecord[i].Profit_Before_Tax_Remark__c ? dataRecord[i].Profit_Before_Tax_Remark__c : '',
    //                 Opening_Stock_Remark__c: dataRecord[i].Opening_Stock_Remark__c ? dataRecord[i].Opening_Stock_Remark__c : '',
    //                 EBITDA_Remark__c: dataRecord[i].EBITDA_Remark__c ? dataRecord[i].EBITDA_Remark__c : '',
    //                 Less_Six_Months_Remarks__c: dataRecord[i].Less_Six_Months_Remarks__c ? dataRecord[i].Less_Six_Months_Remarks__c : '',
    //                 Greater_Six_Months_Remarks__c: dataRecord[i].Greater_Six_Months_Remarks__c ? dataRecord[i].Greater_Six_Months_Remarks__c : '',
    //                 Office_Administrative_Expenses_Remark__c: dataRecord[i].Office_Administrative_Expenses_Remark__c ? dataRecord[i].Office_Administrative_Expenses_Remark__c : '',
    //                 Non_Operating_Expenses_Remark__c: dataRecord[i].Non_Operating_Expenses_Remark__c ? dataRecord[i].Non_Operating_Expenses_Remark__c : '',
    //                 Profit_Before_Depreciation_PBDT_Remark__c: dataRecord[i].Profit_Before_Depreciation_PBDT_Remark__c ? dataRecord[i].Profit_Before_Depreciation_PBDT_Remark__c : '',
    //                 Direct_Expenses_Remark__c: dataRecord[i].Direct_Expenses_Remark__c ? dataRecord[i].Direct_Expenses_Remark__c : '',
    //                 Depreciation_Remark__c: dataRecord[i].Depreciation_Remark__c ? dataRecord[i].Depreciation_Remark__c : '',
    //                 Interest_on_CC_OD_limits_Remark__c: dataRecord[i].Interest_on_CC_OD_limits_Remark__c ? dataRecord[i].Interest_on_CC_OD_limits_Remark__c : '',
    //                 PAT_Remark__c: dataRecord[i].PAT_Remark__c ? dataRecord[i].PAT_Remark__c : '',
    //                 Comments_on_Balance_sheet__c: dataRecord[i].Comments_on_Balance_sheet__c ? dataRecord[i].Comments_on_Balance_sheet__c : '',
    //             }
                

    //             if(dataRecord[i].Financial_Year__c && dataRecord[i].Financial_Year__c === this.currentFinancialYear){
                    
    //                 objectData.Financial_Year__c = dataRecord[i].Financial_Year__c ? dataRecord[i].Financial_Year__c : this.currentFinancialYear;
                    
    //                 objectData.Current_Financial_Year__c=true;
    //                 objectData.Previous_Financial_Year__c=false;
    //                 objectData.Provisional_Financial_Year__c=false;

    //                 this.wrapObj2 = objectData;
    //             }else if(dataRecord[i].Financial_Year__c && dataRecord[i].Financial_Year__c === this.previousFinancialYear){
    //                 objectData.Financial_Year__c = dataRecord[i].Financial_Year__c ? dataRecord[i].Financial_Year__c : this.previousFinancialYear;
                    
    //                 objectData.Current_Financial_Year__c=false;
    //                 objectData.Previous_Financial_Year__c=true;
    //                 objectData.Provisional_Financial_Year__c=false;
                    
    //                 this.wrapObj1 = objectData;
    //             }else if(dataRecord[i].Financial_Year__c && dataRecord[i].Financial_Year__c === this.provisionalFinancialYear){
    //                 objectData.Financial_Year__c = dataRecord[i].Financial_Year__c ? dataRecord[i].Financial_Year__c : this.provisionalFinancialYear;
    //                 objectData.Current_Financial_Year__c=false;
    //                 objectData.Previous_Financial_Year__c=false;
    //                 objectData.Provisional_Financial_Year__c=true;
                    
    //                 this.wrapObj3 = objectData;
    //                 //this.provisionalFinancialSelection = 'Yes';
    //                 this.provisionalFinancialYearSelectionValue = this.provisionalFinancialYear;
    //             }
    //         }
    //     }


    //     if(!this.wrapObj2 || (Object.keys(this.wrapObj2).length == 0)){
    //         this.wrapObj2 = this.emptyRecord;
            
    //         this.wrapObj2.Current_Financial_Year__c=true;
    //         this.wrapObj2.Previous_Financial_Year__c=false;
    //         this.wrapObj2.Provisional_Financial_Year__c=false;

    //         this.wrapObj2.Financial_Year__c = this.currentFinancialYear;

    //     }
    //     if(!this.wrapObj1 || (Object.keys(this.wrapObj1).length == 0)){
    //         this.wrapObj1 = this.emptyRecord;
            
    //         this.wrapObj1.Current_Financial_Year__c=false;
    //         this.wrapObj1.Previous_Financial_Year__c=true;
    //         this.wrapObj1.Provisional_Financial_Year__c=false;
            
    //         this.wrapObj1.Financial_Year__c = this.previousFinancialYear;
    //     }
    //     if(!this.wrapObj3 || (Object.keys(this.wrapObj3).length == 0)){
    //         this.wrapObj3 = this.emptyRecord;
           
    //         this.wrapObj3.Current_Financial_Year__c=false;
    //         this.wrapObj3.Previous_Financial_Year__c=false;
    //         this.wrapObj3.Provisional_Financial_Year__c=true;
            
    //         this.wrapObj3.Financial_Year__c = this.provisionalFinancialYear;
    //     }  
    // }

    get emptyRecord() {
        return {
            Share_capital_Partner_s_Capital__c: 0,
            P_L_A_capital__c: 0,
            Revaluation_Reserves_Notional_Reserves__c: 0,
            Adavces_to_group_co_friends__c: 0,
            unsecured_Loan_from_promoters_family_m__c: 0,
            Misc_Exp_Not_written_off__c: 0,
            Bank_Borrowing_Working_Capital_OD_CC__c: 0,
            Secured_debts_Banks_Ndfc__c: 0,
            Unsecured_debts_Banks_Ndfc__c: 0,
            Other_Loans_From_private_parties__c: 0,
            Sundry_creditors__c: 0,
            Advances_from_customers__c: 0,
            Other_current_liabilities__c: 0,
            Provisions_for_exps_tax_etc__c: 0,
            Deffered_Tax_Liability_Assets__c: 0,
            Net_Tangible_Fixed_Assets_Including_Cap__c: 0,
            Net_Intangible_Fixed_Assets__c: 0,
            Stock__c: 0,
            Debtors__c: 0,
            LessSix_months__c: 0,
            Greaterthan6__c: 0,
            Advances_to_Suppliers__c: 0,
            Investments__c: 0,
            Other_loans_advances__c: 0,
            Prepaid_expenses__c: 0,
            Other_current_assets__c: 0,
            Other_Non_Current_assets_Security_Depos__c: 0,
            Cash_Bank_Balances__c: 0,
            Net_worth__c: 0,
            Adjusted_tangible_Netwroth__c: 0,
            Total_Loan_funds__c: 0,
            Total__c: 0,
            Difference__c: 0,
            Liabilities_Remarks__c: '',
            Share_capital_Remarks__c: '',
            Gross_Profit_Remark__c: '',
            Reevaluation_Remark__c: '',
            Advances_Remarks__c: '',
            Unsecured_Loan_Remarks__c: '',
            Other_Indirect_Expenses_Remark__c: '',
            Borrowing_Remarks__c: '',
            Secured_Remarks__c: '',
            Unsecured_Remarks__c: '',
            Other_Operating_Income_Remark__c: '',
            Sundry_Remarks__c: '',
            Purchases_Remark__c: '',
            Total_Loan_Remarks__c: '',
            Taxes_Remark__c: '',
            Deferred_Tax_Liability_Remark__c: '',
            Assets_Remarks__c: '',
            Adjustable_Remarks__c: '',
            Profit_Before_Tax_Remark__c: '',
            Opening_Stock_Remark__c: '',
            EBITDA_Remark__c: '',
            Less_Six_Months_Remarks__c: '',
            Greater_Six_Months_Remarks__c: '',
            Office_Administrative_Expenses_Remark__c: '',
            Non_Operating_Expenses_Remark__c: '',
            Profit_Before_Depreciation_PBDT_Remark__c: '',
            Direct_Expenses_Remark__c: '',
            Depreciation_Remark__c: '',
            Interest_on_CC_OD_limits_Remark__c: '',
            PAT_Remark__c: '',
            Comments_on_Balance_sheet__c: ''
        };
    }

    get currentFinancialYear(){
        // const today = new Date();
        // const currentMonth = today.getMonth() + 1;
        // const currentYear = today.getFullYear();
        // let startYear, endYear;
        // if (currentMonth >= 4) {
        //     // Financial year has started in the current calendar year
        //     startYear = currentYear;
        //     endYear = currentYear + 1;
        // } else {
        //     // Financial year starts in the previous calendar year
        //     startYear = currentYear - 1;
        //     endYear = currentYear;
        // }
        // const financialYear = `${startYear}-${endYear}`;
        // return financialYear;

        if(this._currentBlock){
            let [currentfirstPart, currentsecondPart] = this._currentBlock.split('-');
            currentfirstPart = parseInt(currentfirstPart);
            currentsecondPart = parseInt(currentsecondPart);
            const financialYear = `${currentfirstPart}-${currentsecondPart}`;
            return financialYear;
        }else{
            return null;
        }
    }


    get previousFinancialYear(){
        // const today = new Date();
        // const currentMonth = today.getMonth() + 1; // Months are zero-based
        // const currentYear = today.getFullYear();
      
        // let startYear, endYear;
      
        // if (currentMonth >= 4) {
        //   // Financial year has started in the current calendar year
        //   startYear = currentYear - 1;
        //   endYear = currentYear;
        // } else {
        //   // Financial year starts in the previous calendar year
        //   startYear = currentYear - 2;
        //   endYear = currentYear - 1;
        // }
      
        // const previousYear = `${startYear}-${endYear}`;
        // return previousYear;

        if(this._currentBlock){
            let [previousfirstPart, previoussecondPart] = this._currentBlock.split('-');
            previousfirstPart = parseInt(previousfirstPart);
            previoussecondPart = parseInt(previoussecondPart);
            const previousYear = `${previousfirstPart-1}-${previoussecondPart-1}`;
            return previousYear;
        }else{
            return null;
        }
    }


    // get provisionalFinancialYear(){

    //     if(this._currentBlock){
    //         let [upcomingfirstPart, upcomingsecondPart] = this._currentBlock.split('-');
    //         upcomingfirstPart = parseInt(upcomingfirstPart);
    //         upcomingsecondPart = parseInt(upcomingsecondPart);
    //         const upcomingFinancialYear = `${(upcomingfirstPart+1)}-${(upcomingsecondPart+1)}`;
    //         return upcomingFinancialYear;
    //     }else{
    //         return null;
    //     }
    // }

    @track _recordTypeIdForBalanceSheet;

    get recordTypeIdForBalanceSheet(){
        return this._recordTypeIdForBalanceSheet;
    }

    set recordTypeIdForBalanceSheet(value){
        this._recordTypeIdForBalanceSheet = value;
        this.setAttribute("recordTypeIdForBalanceSheet", value);
        if(value){
            this.handleParamsChange(value);
        }
    }

    @wire(getObjectInfo, {objectApiName: FINANCIAL_OBJECT})
    getObjectData({data, error}){
        if(data){
            for (const key in data.recordTypeInfos) {
                if (data.recordTypeInfos[key].name === 'Balance Sheet') {
                  this.recordTypeIdForBalanceSheet = data.recordTypeInfos[key].recordTypeId;
                  break;
                }
              }
        }else if(error){

        }
    }



    connectedCallback(){
        refreshApex(this.wiredactualData);
        //this.getFinancialData();
    }

    renderedCallback(){
        refreshApex(this.wiredactualData);
    }
    @api handleRefreshAllData() {
        refreshApex(this.wiredactualData);
}

    @track
    applicantFinancialParams = {
        ParentObjectName: 'Applicant_Financial__c ',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Loan_Applicant__c', 'RecordTypeId'],
        childObjFields: [],
        queryCriteria: ' where Loan_Applicant__c = \'' + this._applicantId + '\' AND RecordTypeId=\''+this._recordTypeIdForBalanceSheet+'\''
    }

    handleParamsChange(value){
        let tempParams = this.applicantFinancialParams;
        tempParams.queryCriteria = ' where Loan_Applicant__c = \'' + this._applicantId + '\' AND RecordTypeId=\''+value+'\''
        this.applicantFinancialParams = { ...tempParams };
    }
    @track actualFinancialData;
    @track applicantFinancialRecordId;
    @wire(getSobjectData, { params: '$applicantFinancialParams' })
    getFinancialData(allFinancialdata){
        let { error, data } = allFinancialdata;
        this.actualFinancialData = allFinancialdata;
        if(data){
            if(data && data.parentRecords && data.parentRecords.length>0){
                this.applicantFinancialRecordId = data.parentRecords[0].Id;
            }else{
                this.createApplicantFinancialRecord();
            }
        }else if(error){

        }
    } 


    createApplicantFinancialRecord() {

        let financialDetails = {
            Loan_Applicant__c: this._applicantId,
            sobjectType: 'Applicant_Financial__c',
            RecordTypeId: this._recordTypeIdForBalanceSheet
        };

        let upsertData = {
            parentRecord: financialDetails,
            ChildRecords: [],
            ParentFieldNameToUpdate: 'Applicant_Financial__c'
        }

        upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
        .then(result => {
            if (result) {
                if (result.parentRecord && result.parentRecord.Id) {
                    this.applicantFinancialRecordId = result.parentRecord.Id;
                }
            }

        })
        .catch(error => {
            console.error(error)
        })
    }
    
    

    handleInputChange(event) {
        const fieldName = event.target.name;
        const fieldValue = event.target.value;
        const fnYear = event.target.dataset.fnyear;
    
        if (fnYear === 'prev') {
            this.wrapObj1[fieldName] = fieldValue;
        } else if (fnYear === 'current') {
            this.wrapObj2[fieldName] = fieldValue;
        }else if(fnYear === 'provisional'){
            this.wrapObj3[fieldName] = fieldValue;
        }

        if((fieldName === 'LessSix_months__c') || (fieldName === 'Greaterthan6__c')){
            var lessthanValue = 0;
            var greaterthanValue = 0;
            if(fnYear === 'prev'){
                lessthanValue = this.wrapObj1.LessSix_months__c ? parseFloat(this.wrapObj1.LessSix_months__c) : 0;
                greaterthanValue = this.wrapObj1.Greaterthan6__c ? parseFloat(this.wrapObj1.Greaterthan6__c) : 0;
                this.wrapObj1.Debtors__c = lessthanValue + greaterthanValue;
            }else if(fnYear === 'current'){
                lessthanValue = this.wrapObj2.LessSix_months__c ? parseFloat(this.wrapObj2.LessSix_months__c) : 0;
                greaterthanValue = this.wrapObj2.Greaterthan6__c ? parseFloat(this.wrapObj2.Greaterthan6__c) : 0;
                this.wrapObj2.Debtors__c = lessthanValue + greaterthanValue;
            }else if(fnYear === 'provisional'){
                lessthanValue = this.wrapObj3.LessSix_months__c ? parseFloat(this.wrapObj3.LessSix_months__c) : 0;
                greaterthanValue = this.wrapObj3.Greaterthan6__c ? parseFloat(this.wrapObj3.Greaterthan6__c) : 0;
                this.wrapObj3.Debtors__c = lessthanValue + greaterthanValue;
            }
        }
    }

    @track showSpinner = false;
    @track del_recIds = [];

    @api handleUpsert(validate){
        this.showSpinner = true;
        if(this.wrapObj2 && !this.wrapObj2.Applicant_Financial__c){
            this.wrapObj2.Applicant_Financial__c = this.applicantFinancialRecordId;
        }
        if(this.wrapObj1 && !this.wrapObj1.Applicant_Financial__c){
            this.wrapObj1.Applicant_Financial__c = this.applicantFinancialRecordId;
        }
        if(this.wrapObj3 && !this.wrapObj3.Applicant_Financial__c){
            this.wrapObj3.Applicant_Financial__c = this.applicantFinancialRecordId;
        }
        
        if(this.wrapObj1){
            this.wrapObj1.Net_worth__c = this.recordNetWorthValue1;
            this.wrapObj1.Adjusted_tangible_Netwroth__c = this.adjustedNetworthValue1;
            this.wrapObj1.Total_Loan_funds__c = this.otherWorthValue1;
            this.wrapObj1.Total__c = this.allTotalValue1;
            this.wrapObj1.Difference__c = this.diff1;
        }
        if(this.wrapObj2){
            this.wrapObj2.Net_worth__c = this.recordNetWorthValue2;
            this.wrapObj2.Adjusted_tangible_Netwroth__c = this.adjustedNetworthValue2;
            this.wrapObj2.Total_Loan_funds__c = this.otherWorthValue2;
            this.wrapObj2.Total__c = this.allTotalValue2;
            this.wrapObj2.Difference__c = this.diff2;
        }
        if(this.wrapObj3){
            this.wrapObj3.Net_worth__c = this.recordNetWorthValue3;
            this.wrapObj3.Adjusted_tangible_Netwroth__c = this.adjustedNetworthValue3;
            this.wrapObj3.Total_Loan_funds__c = this.otherWorthValue3;
            this.wrapObj3.Total__c = this.allTotalValue3;
            this.wrapObj3.Difference__c = this.diff3;
        }
        // if(this._currentBlock){
        //     var applicantData;
        //     applicantData.sobjectType = 'Applicant__c';
        //     applicantData.LatestyearforwhichITRisavailable__c = this._currentBlock;
        //     tempRecs.push(applicantData);
        // }

        let tempRecs = [];
        if(this.wrapObj2){
            var currentData = this.wrapObj2;
            currentData.sobjectType = 'Applicant_Financial_Summary__c';
            tempRecs.push(currentData);
        }
        if(this.wrapObj1){
            var lastData = this.wrapObj1;
            lastData.sobjectType = 'Applicant_Financial_Summary__c';
            tempRecs.push(lastData);
        }
        if(this.provisionalFinancialYearSelectionValue && this.wrapObj3){
            var provisionalData = this.wrapObj3;
            provisionalData.sobjectType = 'Applicant_Financial_Summary__c';
            tempRecs.push(provisionalData);
        }else if(!this.provisionalFinancialYearSelectionValue){
            if(this.wrapObj3 && this.wrapObj3.Id){
                let fields = {};
                fields['Id'] = this.wrapObj3.Id
                this.del_recIds = [];
                this.del_recIds.push(fields)
                deleteRecord_Data({ rcrds: this.del_recIds }).then((result) => {
                    //console.log("Record Delete Successfully", JSON.stringify(result));
                });
            }else{
                for (let key in this.wrapObj3) {
                    if (key !== 'Financial_Year__c' && key !== 'Applicant_Financial__c') {
                        this.wrapObj3[key] = 0;
                    }
                }
            }
        }

        if(this._currentBlock){
            var latestYearValue;
            if(this._provisionalOption && this._provisionalOption === 'No'){
                latestYearValue = '';
            }else if(this._provisionalOption && this._provisionalOption === 'Yes'){
                latestYearValue = this._provisionalYear;
            }else{
                latestYearValue = '';
            }

            var applicantDataSObject = {};
            applicantDataSObject.sobjectType = 'Applicant__c';
            applicantDataSObject.LatestyearforwhichITRisavailable__c = this._currentBlock;
            applicantDataSObject.Provisional_Financials_Available__c = this._provisionalOption ? this._provisionalOption : '';
            applicantDataSObject.Provisional_Financials_Year__c = latestYearValue ;
            applicantDataSObject.Id = this._applicantId;
            tempRecs.push(applicantDataSObject);
        }

        if(validate ===false){
            if (tempRecs.length > 0){
                upsertMultipleRecord({ params: tempRecs })
                .then(result => {
                    this.deleteAdditionalRecords(this.previousFinancialYear, this.currentFinancialYear, this._provisionalOption, this.provisionalFinancialYear);
                }).catch(error => {
                    console.log('error ==>>>' + error);
                    this.showSpinner = false;
                    this.showToastMessage("Error", this.customLabel.BalanceSheet_ErrorMessage, "error", "sticky");
                })
            }else{
                this.showSpinner = false;
            }
        }else{
            if((this.sixMonthsError === true)){
                this.showSpinner = false;
                this.showToastMessage("Error", this.customLabel.BalanceSheet_Data_ErrorMessage, "error", "sticky");
            }else if(this.sixMonthsError === false){
                if (tempRecs.length > 0){
                    upsertMultipleRecord({ params: tempRecs })
                    .then(result => {
                        this.deleteAdditionalRecords(this.previousFinancialYear, this.currentFinancialYear, this._provisionalOption, this.provisionalFinancialYear);
                    }).catch(error => {
                        console.log('error ==>>>' + error);
                        this.showSpinner = false;
                        this.showToastMessage("Error", this.customLabel.BalanceSheet_ErrorMessage, "error", "sticky");
                    })
                }else{
                    this.showSpinner = false;
                }
            }
        }
    }

    deleteAdditionalRecords(previousYear, currentFinYear, provisonalAvailable, provisionalYear){
        processDefunctRecordsFinancial({ previousFinYear: previousYear, currentFinYear: currentFinYear, provisionalAvailable : provisonalAvailable, provisionalYear : provisionalYear, applicantId: this._applicantId})
        .then(result => {
            if(result){
                this.handleRefreshAllData();
                this.fireCustomEvent();
                this.showSpinner = false;
                this.showToastMessage("Success", this.customLabel.BalanceSheet_save_SuccessMessage, "success", "sticky");
            }
        }).catch(error => {
            console.log('error ==>>>' + JSON.stringify(error));
            this.showSpinner = false;
            this.showToastMessage("Error", this.customLabel.BalanceSheet_ErrorMessage, "error", "sticky");
        })
    }

    fireCustomEvent(){
        const intimateParentChange = new CustomEvent('parentapplicantupdate', {
            detail: 'Data Changed'
        });
        this.dispatchEvent(intimateParentChange);
    }

    @api validateForm() {
        const isInputCorrect = [
            ...this.template.querySelectorAll("lightning-input"),
            ...this.template.querySelectorAll("lightning-combobox")
        ].reduce((validSoFar, inputField) => {

            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);

        if(isInputCorrect && isInputCorrect === false){
            // Pratap Move the toast message to the main component
            //this.showToastMessage("Error", 'Please provide correct input to all fields.', "error", "sticky");

        }
        return isInputCorrect;
    }

    // get liablitiesPercentage() {
    //     return (parseFloat(this.wrapObj2.Liabilities__c ?  this.wrapObj2.Liabilities__c : 0) - 
    //     parseFloat(this.wrapObj1.Liabilities__c ?  this.wrapObj1.Liabilities__c: 0)) / parseFloat(this.wrapObj2.Liabilities__c ?  this.wrapObj2.Liabilities__c : 0)
    // }

    get sharePartnerPercentage() {
        return (parseFloat(this.wrapObj2.Share_capital_Partner_s_Capital__c ?  this.wrapObj2.Share_capital_Partner_s_Capital__c : 0) - 
        parseFloat(this.wrapObj1.Share_capital_Partner_s_Capital__c ?  this.wrapObj1.Share_capital_Partner_s_Capital__c : 0)) / parseFloat(this.wrapObj1.Share_capital_Partner_s_Capital__c ?  this.wrapObj1.Share_capital_Partner_s_Capital__c : 0)
    }

    get sharePartnerPercentage1() {
        return (parseFloat(this.wrapObj3.Share_capital_Partner_s_Capital__c ?  this.wrapObj3.Share_capital_Partner_s_Capital__c : 0) - 
        parseFloat(this.wrapObj2.Share_capital_Partner_s_Capital__c ?  this.wrapObj2.Share_capital_Partner_s_Capital__c : 0)) / parseFloat(this.wrapObj2.Share_capital_Partner_s_Capital__c ?  this.wrapObj2.Share_capital_Partner_s_Capital__c : 0)
    }

    get plaPercentage() {
        return (parseFloat(this.wrapObj2.P_L_A_capital__c ?  this.wrapObj2.P_L_A_capital__c : 0) - 
        parseFloat(this.wrapObj1.P_L_A_capital__c ?  this.wrapObj1.P_L_A_capital__c : 0)) / parseFloat(this.wrapObj1.P_L_A_capital__c ?  this.wrapObj1.P_L_A_capital__c : 0)
    }

    get plaPercentage1() {
        return (parseFloat(this.wrapObj3.P_L_A_capital__c ?  this.wrapObj3.P_L_A_capital__c : 0) - 
        parseFloat(this.wrapObj2.P_L_A_capital__c ?  this.wrapObj2.P_L_A_capital__c : 0)) / parseFloat(this.wrapObj2.P_L_A_capital__c ?  this.wrapObj2.P_L_A_capital__c : 0)
    }

    get revolutionPercentage() {
        return (parseFloat(this.wrapObj2.Revaluation_Reserves_Notional_Reserves__c ?  this.wrapObj2.Revaluation_Reserves_Notional_Reserves__c : 0) - 
        parseFloat(this.wrapObj1.Revaluation_Reserves_Notional_Reserves__c ?  this.wrapObj1.Revaluation_Reserves_Notional_Reserves__c : 0)) / parseFloat(this.wrapObj1.Revaluation_Reserves_Notional_Reserves__c ?  this.wrapObj1.Revaluation_Reserves_Notional_Reserves__c : 0)
    }

    get revolutionPercentage1() {
        return (parseFloat(this.wrapObj3.Revaluation_Reserves_Notional_Reserves__c ?  this.wrapObj3.Revaluation_Reserves_Notional_Reserves__c : 0) - 
        parseFloat(this.wrapObj2.Revaluation_Reserves_Notional_Reserves__c ?  this.wrapObj2.Revaluation_Reserves_Notional_Reserves__c : 0)) / parseFloat(this.wrapObj2.Revaluation_Reserves_Notional_Reserves__c ?  this.wrapObj2.Revaluation_Reserves_Notional_Reserves__c : 0)
    }
    
    get recordNetWorthValue1() {
        return (parseFloat(this.wrapObj1.Share_capital_Partner_s_Capital__c  ?  this.wrapObj1.Share_capital_Partner_s_Capital__c : 0)+ 
        parseFloat(this.wrapObj1.P_L_A_capital__c  ?  this.wrapObj1.P_L_A_capital__c : 0 )) - parseFloat(this.wrapObj1.Misc_Exp_Not_written_off__c  ?  this.wrapObj1.Misc_Exp_Not_written_off__c : 0 );
    }

    get recordNetWorthValue2() {
        return (parseFloat(this.wrapObj2.Share_capital_Partner_s_Capital__c  ?  this.wrapObj2.Share_capital_Partner_s_Capital__c : 0)+ 
        parseFloat(this.wrapObj2.P_L_A_capital__c  ?  this.wrapObj2.P_L_A_capital__c : 0 )) - parseFloat(this.wrapObj2.Misc_Exp_Not_written_off__c  ?  this.wrapObj2.Misc_Exp_Not_written_off__c : 0 );
    }

    get recordNetWorthValue3() {
        return (parseFloat(this.wrapObj3.Share_capital_Partner_s_Capital__c  ?  this.wrapObj3.Share_capital_Partner_s_Capital__c : 0)+ 
        parseFloat(this.wrapObj3.P_L_A_capital__c  ?  this.wrapObj3.P_L_A_capital__c : 0 )) - parseFloat(this.wrapObj3.Misc_Exp_Not_written_off__c  ?  this.wrapObj3.Misc_Exp_Not_written_off__c : 0 );
    }

    get networthPercentage() {
        return ((this.recordNetWorthValue2 ? this.recordNetWorthValue2:0) - (this.recordNetWorthValue1 ? this.recordNetWorthValue1:0))/(this.recordNetWorthValue1 ? this.recordNetWorthValue1:0);
    }

    get networthPercentage1() {
        return ((this.recordNetWorthValue3 ? this.recordNetWorthValue3:0) - (this.recordNetWorthValue2 ? this.recordNetWorthValue2:0))/(this.recordNetWorthValue2 ? this.recordNetWorthValue2:0);
    }

    get advancePercentage() {
        return (parseFloat(this.wrapObj2.Adavces_to_group_co_friends__c ?  this.wrapObj2.Adavces_to_group_co_friends__c : 0) - 
        parseFloat(this.wrapObj1.Adavces_to_group_co_friends__c ?  this.wrapObj1.Adavces_to_group_co_friends__c: 0)) / parseFloat(this.wrapObj1.Adavces_to_group_co_friends__c ?  this.wrapObj1.Adavces_to_group_co_friends__c : 0)
    }

    get advancePercentage1() {
        return (parseFloat(this.wrapObj3.Adavces_to_group_co_friends__c ?  this.wrapObj3.Adavces_to_group_co_friends__c : 0) - 
        parseFloat(this.wrapObj2.Adavces_to_group_co_friends__c ?  this.wrapObj2.Adavces_to_group_co_friends__c: 0)) / parseFloat(this.wrapObj2.Adavces_to_group_co_friends__c ?  this.wrapObj2.Adavces_to_group_co_friends__c : 0)
    }

    get loanpromotorsPercentage() {
        return (parseFloat(this.wrapObj2.unsecured_Loan_from_promoters_family_m__c ?  this.wrapObj2.unsecured_Loan_from_promoters_family_m__c : 0) - 
        parseFloat(this.wrapObj1.unsecured_Loan_from_promoters_family_m__c ?  this.wrapObj1.unsecured_Loan_from_promoters_family_m__c : 0)) / parseFloat(this.wrapObj1.unsecured_Loan_from_promoters_family_m__c ?  this.wrapObj1.unsecured_Loan_from_promoters_family_m__c : 0)
    }

    get loanpromotorsPercentage1() {
        return (parseFloat(this.wrapObj3.unsecured_Loan_from_promoters_family_m__c ?  this.wrapObj3.unsecured_Loan_from_promoters_family_m__c : 0) - 
        parseFloat(this.wrapObj2.unsecured_Loan_from_promoters_family_m__c ?  this.wrapObj2.unsecured_Loan_from_promoters_family_m__c : 0)) / parseFloat(this.wrapObj2.unsecured_Loan_from_promoters_family_m__c ?  this.wrapObj2.unsecured_Loan_from_promoters_family_m__c : 0)
    }

    get miscExppercentage() {
        return (parseFloat(this.wrapObj2.Misc_Exp_Not_written_off__c ?  this.wrapObj2.Misc_Exp_Not_written_off__c : 0) - 
        parseFloat(this.wrapObj1.Misc_Exp_Not_written_off__c ?  this.wrapObj1.Misc_Exp_Not_written_off__c : 0)) / parseFloat(this.wrapObj1.Misc_Exp_Not_written_off__c ?  this.wrapObj1.Misc_Exp_Not_written_off__c : 0)
    }

    get miscExppercentage1() {
        return (parseFloat(this.wrapObj3.Misc_Exp_Not_written_off__c ?  this.wrapObj3.Misc_Exp_Not_written_off__c : 0) - 
        parseFloat(this.wrapObj2.Misc_Exp_Not_written_off__c ?  this.wrapObj2.Misc_Exp_Not_written_off__c : 0)) / parseFloat(this.wrapObj2.Misc_Exp_Not_written_off__c ?  this.wrapObj2.Misc_Exp_Not_written_off__c : 0)
    }

    get adjustedNetworthValue1() {
        return ((this.recordNetWorthValue1 ? this.recordNetWorthValue1:0) + parseFloat(this.wrapObj1.unsecured_Loan_from_promoters_family_m__c  ?  this.wrapObj1.unsecured_Loan_from_promoters_family_m__c : 0)) -
        (parseFloat(this.wrapObj1.Adavces_to_group_co_friends__c  ?  this.wrapObj1.Adavces_to_group_co_friends__c : 0 ) +
        (parseFloat(this.wrapObj1.Net_Intangible_Fixed_Assets__c ? this.wrapObj1.Net_Intangible_Fixed_Assets__c : 0)) +
        (parseFloat(this.wrapObj1.Greaterthan6__c ? this.wrapObj1.Greaterthan6__c : 0)));
    }

    get adjustedNetworthValue2() {
        return ((this.recordNetWorthValue2 ? this.recordNetWorthValue2:0) + parseFloat(this.wrapObj2.unsecured_Loan_from_promoters_family_m__c  ?  this.wrapObj2.unsecured_Loan_from_promoters_family_m__c : 0)) -
        (parseFloat(this.wrapObj2.Adavces_to_group_co_friends__c  ?  this.wrapObj2.Adavces_to_group_co_friends__c : 0 ) +
        (parseFloat(this.wrapObj2.Net_Intangible_Fixed_Assets__c ? this.wrapObj2.Net_Intangible_Fixed_Assets__c : 0)) +
        (parseFloat(this.wrapObj2.Greaterthan6__c ? this.wrapObj2.Greaterthan6__c : 0)));
    }

    get adjustedPercentage() {
        return ((this.adjustedNetworthValue2 ? this.adjustedNetworthValue2:0) - (this.adjustedNetworthValue1 ? this.adjustedNetworthValue1:0))/(this.adjustedNetworthValue1 ? this.adjustedNetworthValue1:0);
    }

    get adjustedNetworthValue3() {
        return ((this.recordNetWorthValue3 ? this.recordNetWorthValue3:0) + parseFloat(this.wrapObj3.unsecured_Loan_from_promoters_family_m__c  ?  this.wrapObj3.unsecured_Loan_from_promoters_family_m__c : 0)) -
        (parseFloat(this.wrapObj3.Adavces_to_group_co_friends__c  ?  this.wrapObj3.Adavces_to_group_co_friends__c : 0 ) +
        (parseFloat(this.wrapObj3.Net_Intangible_Fixed_Assets__c ? this.wrapObj3.Net_Intangible_Fixed_Assets__c : 0)) +
        (parseFloat(this.wrapObj3.Greaterthan6__c ? this.wrapObj3.Greaterthan6__c : 0)));
    }

    get adjustedPercentage1() {
        return ((this.adjustedNetworthValue3 ? this.adjustedNetworthValue3:0) - (this.adjustedNetworthValue2 ? this.adjustedNetworthValue2:0))/(this.adjustedNetworthValue2 ? this.adjustedNetworthValue2:0);
    }

    get borrowPercentage() {
        return (parseFloat(this.wrapObj2.Bank_Borrowing_Working_Capital_OD_CC__c ?  this.wrapObj2.Bank_Borrowing_Working_Capital_OD_CC__c : 0) - 
        parseFloat(this.wrapObj1.Bank_Borrowing_Working_Capital_OD_CC__c ?  this.wrapObj1.Bank_Borrowing_Working_Capital_OD_CC__c: 0)) / parseFloat(this.wrapObj1.Bank_Borrowing_Working_Capital_OD_CC__c ?  this.wrapObj1.Bank_Borrowing_Working_Capital_OD_CC__c : 0)
    }

    get borrowPercentage1() {
        return (parseFloat(this.wrapObj3.Bank_Borrowing_Working_Capital_OD_CC__c ?  this.wrapObj3.Bank_Borrowing_Working_Capital_OD_CC__c : 0) - 
        parseFloat(this.wrapObj2.Bank_Borrowing_Working_Capital_OD_CC__c ?  this.wrapObj2.Bank_Borrowing_Working_Capital_OD_CC__c: 0)) / parseFloat(this.wrapObj2.Bank_Borrowing_Working_Capital_OD_CC__c ?  this.wrapObj2.Bank_Borrowing_Working_Capital_OD_CC__c : 0)
    }

    get unsecuredPercentage() {
        return (parseFloat(this.wrapObj2.Secured_debts_Banks_Ndfc__c ?  this.wrapObj2.Secured_debts_Banks_Ndfc__c : 0) - 
        parseFloat(this.wrapObj1.Secured_debts_Banks_Ndfc__c ?  this.wrapObj1.Secured_debts_Banks_Ndfc__c : 0)) / parseFloat(this.wrapObj1.Secured_debts_Banks_Ndfc__c ?  this.wrapObj1.Secured_debts_Banks_Ndfc__c : 0)
    }

    get unsecuredPercentage1() {
        return (parseFloat(this.wrapObj3.Secured_debts_Banks_Ndfc__c ?  this.wrapObj3.Secured_debts_Banks_Ndfc__c : 0) - 
        parseFloat(this.wrapObj2.Secured_debts_Banks_Ndfc__c ?  this.wrapObj2.Secured_debts_Banks_Ndfc__c : 0)) / parseFloat(this.wrapObj2.Secured_debts_Banks_Ndfc__c ?  this.wrapObj2.Secured_debts_Banks_Ndfc__c : 0)
    }

    get otherExppercentage() {
        return (parseFloat(this.wrapObj2.Unsecured_debts_Banks_Ndfc__c ?  this.wrapObj2.Unsecured_debts_Banks_Ndfc__c : 0) - 
        parseFloat(this.wrapObj1.Unsecured_debts_Banks_Ndfc__c ?  this.wrapObj1.Unsecured_debts_Banks_Ndfc__c : 0)) / parseFloat(this.wrapObj1.Unsecured_debts_Banks_Ndfc__c ?  this.wrapObj1.Unsecured_debts_Banks_Ndfc__c : 0)
    }

    get otherExppercentage1() {
        return (parseFloat(this.wrapObj3.Unsecured_debts_Banks_Ndfc__c ?  this.wrapObj3.Unsecured_debts_Banks_Ndfc__c : 0) - 
        parseFloat(this.wrapObj2.Unsecured_debts_Banks_Ndfc__c ?  this.wrapObj2.Unsecured_debts_Banks_Ndfc__c : 0)) / parseFloat(this.wrapObj2.Unsecured_debts_Banks_Ndfc__c ?  this.wrapObj2.Unsecured_debts_Banks_Ndfc__c : 0)
    }

    get totalExppercentage() {
        return (parseFloat(this.wrapObj2.Other_Loans_From_private_parties__c ?  this.wrapObj2.Other_Loans_From_private_parties__c : 0) - 
        parseFloat(this.wrapObj1.Other_Loans_From_private_parties__c ?  this.wrapObj1.Other_Loans_From_private_parties__c : 0)) / parseFloat(this.wrapObj1.Other_Loans_From_private_parties__c ?  this.wrapObj1.Other_Loans_From_private_parties__c : 0)
    }

    get totalExppercentage1() {
        return (parseFloat(this.wrapObj3.Other_Loans_From_private_parties__c ?  this.wrapObj3.Other_Loans_From_private_parties__c : 0) - 
        parseFloat(this.wrapObj2.Other_Loans_From_private_parties__c ?  this.wrapObj2.Other_Loans_From_private_parties__c : 0)) / parseFloat(this.wrapObj2.Other_Loans_From_private_parties__c ?  this.wrapObj2.Other_Loans_From_private_parties__c : 0)
    }

    get otherWorthValue1() {
        return (parseFloat(this.wrapObj1.Bank_Borrowing_Working_Capital_OD_CC__c  ?  this.wrapObj1.Bank_Borrowing_Working_Capital_OD_CC__c : 0)+ 
        parseFloat(this.wrapObj1.Secured_debts_Banks_Ndfc__c  ?  this.wrapObj1.Secured_debts_Banks_Ndfc__c : 0 )) +
        (parseFloat(this.wrapObj1.Other_Loans_From_private_parties__c  ?  this.wrapObj1.Other_Loans_From_private_parties__c : 0 )) +
        (parseFloat(this.wrapObj1.Unsecured_debts_Banks_Ndfc__c  ?  this.wrapObj1.Unsecured_debts_Banks_Ndfc__c : 0 ));
    }

    get otherWorthValue2() {
        return (parseFloat(this.wrapObj2.Bank_Borrowing_Working_Capital_OD_CC__c  ?  this.wrapObj2.Bank_Borrowing_Working_Capital_OD_CC__c : 0)+ 
        parseFloat(this.wrapObj2.Secured_debts_Banks_Ndfc__c  ?  this.wrapObj2.Secured_debts_Banks_Ndfc__c : 0 )) +
        (parseFloat(this.wrapObj2.Other_Loans_From_private_parties__c  ?  this.wrapObj2.Other_Loans_From_private_parties__c : 0 )) + 
        (parseFloat(this.wrapObj2.Unsecured_debts_Banks_Ndfc__c  ?  this.wrapObj2.Unsecured_debts_Banks_Ndfc__c : 0 )) ;
    }

    get totalPercentage() {
        return ((this.otherWorthValue2 ? this.otherWorthValue2:0) - (this.otherWorthValue1 ? this.otherWorthValue1:0))/(this.otherWorthValue1 ? this.otherWorthValue1:0);
    }

    get otherWorthValue3() {
        return (parseFloat(this.wrapObj3.Bank_Borrowing_Working_Capital_OD_CC__c  ?  this.wrapObj3.Bank_Borrowing_Working_Capital_OD_CC__c : 0)+ 
        parseFloat(this.wrapObj3.Secured_debts_Banks_Ndfc__c  ?  this.wrapObj3.Secured_debts_Banks_Ndfc__c : 0 )) +
        (parseFloat(this.wrapObj3.Other_Loans_From_private_parties__c  ?  this.wrapObj3.Other_Loans_From_private_parties__c : 0 )) + 
        (parseFloat(this.wrapObj3.Unsecured_debts_Banks_Ndfc__c  ?  this.wrapObj3.Unsecured_debts_Banks_Ndfc__c : 0 )) ;
    }

    get totalPercentage1() {
        return ((this.otherWorthValue3 ? this.otherWorthValue3:0) - (this.otherWorthValue2 ? this.otherWorthValue2:0))/(this.otherWorthValue2 ? this.otherWorthValue2:0);
    }

    get creditorsPercentage() {
        return (parseFloat(this.wrapObj2.Sundry_creditors__c ?  this.wrapObj2.Sundry_creditors__c : 0) - 
        parseFloat(this.wrapObj1.Sundry_creditors__c ?  this.wrapObj1.Sundry_creditors__c: 0)) / parseFloat(this.wrapObj1.Sundry_creditors__c ?  this.wrapObj1.Sundry_creditors__c : 0)
    }

    get creditorsPercentage1() {
        return (parseFloat(this.wrapObj3.Sundry_creditors__c ?  this.wrapObj3.Sundry_creditors__c : 0) - 
        parseFloat(this.wrapObj2.Sundry_creditors__c ?  this.wrapObj2.Sundry_creditors__c: 0)) / parseFloat(this.wrapObj2.Sundry_creditors__c ?  this.wrapObj2.Sundry_creditors__c : 0)
    }

    get advPercentage() {
        return (parseFloat(this.wrapObj2.Advances_from_customers__c ?  this.wrapObj2.Advances_from_customers__c : 0) - 
        parseFloat(this.wrapObj1.Advances_from_customers__c ?  this.wrapObj1.Advances_from_customers__c : 0)) / parseFloat(this.wrapObj1.Advances_from_customers__c ?  this.wrapObj1.Advances_from_customers__c : 0)
    }

    get advPercentage1() {
        return (parseFloat(this.wrapObj3.Advances_from_customers__c ?  this.wrapObj3.Advances_from_customers__c : 0) - 
        parseFloat(this.wrapObj2.Advances_from_customers__c ?  this.wrapObj2.Advances_from_customers__c : 0)) / parseFloat(this.wrapObj2.Advances_from_customers__c ?  this.wrapObj2.Advances_from_customers__c : 0)
    }

    get otherLiapercentage() {
        return (parseFloat(this.wrapObj2.Other_current_liabilities__c ?  this.wrapObj2.Other_current_liabilities__c : 0) - 
        parseFloat(this.wrapObj1.Other_current_liabilities__c ?  this.wrapObj1.Other_current_liabilities__c : 0)) / parseFloat(this.wrapObj1.Other_current_liabilities__c ?  this.wrapObj1.Other_current_liabilities__c : 0)
    }

    get otherLiapercentage1() {
        return (parseFloat(this.wrapObj3.Other_current_liabilities__c ?  this.wrapObj3.Other_current_liabilities__c : 0) - 
        parseFloat(this.wrapObj2.Other_current_liabilities__c ?  this.wrapObj2.Other_current_liabilities__c : 0)) / parseFloat(this.wrapObj2.Other_current_liabilities__c ?  this.wrapObj2.Other_current_liabilities__c : 0)
    }

    get provExppercentage() {
        return (parseFloat(this.wrapObj2.Provisions_for_exps_tax_etc__c ?  this.wrapObj2.Provisions_for_exps_tax_etc__c : 0) - 
        parseFloat(this.wrapObj1.Provisions_for_exps_tax_etc__c ?  this.wrapObj1.Provisions_for_exps_tax_etc__c : 0)) / parseFloat(this.wrapObj1.Provisions_for_exps_tax_etc__c ?  this.wrapObj1.Provisions_for_exps_tax_etc__c : 0)
    }

    get provExppercentage1() {
        return (parseFloat(this.wrapObj3.Provisions_for_exps_tax_etc__c ?  this.wrapObj3.Provisions_for_exps_tax_etc__c : 0) - 
        parseFloat(this.wrapObj2.Provisions_for_exps_tax_etc__c ?  this.wrapObj2.Provisions_for_exps_tax_etc__c : 0)) / parseFloat(this.wrapObj2.Provisions_for_exps_tax_etc__c ?  this.wrapObj2.Provisions_for_exps_tax_etc__c : 0)
    }

    get DifftaxExppercentage() {
        return (parseFloat(this.wrapObj2.Deffered_Tax_Liability_Assets__c ?  this.wrapObj2.Deffered_Tax_Liability_Assets__c : 0) - 
        parseFloat(this.wrapObj1.Deffered_Tax_Liability_Assets__c ?  this.wrapObj1.Deffered_Tax_Liability_Assets__c : 0)) / parseFloat(this.wrapObj1.Deffered_Tax_Liability_Assets__c ?  this.wrapObj1.Deffered_Tax_Liability_Assets__c : 0)
    }

    get DifftaxExppercentage1() {
        return (parseFloat(this.wrapObj3.Deffered_Tax_Liability_Assets__c ?  this.wrapObj3.Deffered_Tax_Liability_Assets__c : 0) - 
        parseFloat(this.wrapObj2.Deffered_Tax_Liability_Assets__c ?  this.wrapObj2.Deffered_Tax_Liability_Assets__c : 0)) / parseFloat(this.wrapObj2.Deffered_Tax_Liability_Assets__c ?  this.wrapObj2.Deffered_Tax_Liability_Assets__c : 0)
    }

    get totWorthValue1() {
        return (parseFloat(this.wrapObj1.Revaluation_Reserves_Notional_Reserves__c ? this.wrapObj1.Revaluation_Reserves_Notional_Reserves__c : 0)) +
               this.recordNetWorthValue1 +
               parseFloat(this.wrapObj1.unsecured_Loan_from_promoters_family_m__c  ?  this.wrapObj1.unsecured_Loan_from_promoters_family_m__c : 0 ) +
               this.otherWorthValue1 + 
               parseFloat(this.wrapObj1.Sundry_creditors__c  ?  this.wrapObj1.Sundry_creditors__c : 0 ) +
               parseFloat(this.wrapObj1.Advances_from_customers__c  ?  this.wrapObj1.Advances_from_customers__c : 0 ) +
               parseFloat(this.wrapObj1.Other_current_liabilities__c  ?  this.wrapObj1.Other_current_liabilities__c : 0 ) +
               parseFloat(this.wrapObj1.Provisions_for_exps_tax_etc__c  ?  this.wrapObj1.Provisions_for_exps_tax_etc__c : 0 ) +
               parseFloat(this.wrapObj1.Deffered_Tax_Liability_Assets__c  ?  this.wrapObj1.Deffered_Tax_Liability_Assets__c : 0 );
        // return (parseFloat(this.wrapObj1.Deffered_Tax_Liability_Assets__c  ?  this.wrapObj1.Deffered_Tax_Liability_Assets__c : 0)+ 
        // parseFloat(this.wrapObj1.Provisions_for_exps_tax_etc__c  ?  this.wrapObj1.Provisions_for_exps_tax_etc__c : 0 )) +
        // (parseFloat(this.wrapObj1.Other_current_liabilities__c  ?  this.wrapObj1.Other_current_liabilities__c : 0 )) +
        // (parseFloat(this.wrapObj1.Advances_from_customers__c  ?  this.wrapObj1.Advances_from_customers__c : 0 )) +
        // (parseFloat(this.wrapObj1.Sundry_creditors__c  ?  this.wrapObj1.Sundry_creditors__c : 0 )) + this.otherWorthValue1;
    }

    get totWorthValue2() {
        return (parseFloat(this.wrapObj2.Revaluation_Reserves_Notional_Reserves__c ? this.wrapObj2.Revaluation_Reserves_Notional_Reserves__c : 0)) +
               this.recordNetWorthValue2 +
               parseFloat(this.wrapObj2.unsecured_Loan_from_promoters_family_m__c  ?  this.wrapObj2.unsecured_Loan_from_promoters_family_m__c : 0 ) +
               this.otherWorthValue2 + 
               parseFloat(this.wrapObj2.Sundry_creditors__c  ?  this.wrapObj2.Sundry_creditors__c : 0 ) +
               parseFloat(this.wrapObj2.Advances_from_customers__c  ?  this.wrapObj2.Advances_from_customers__c : 0 ) +
               parseFloat(this.wrapObj2.Other_current_liabilities__c  ?  this.wrapObj2.Other_current_liabilities__c : 0 ) +
               parseFloat(this.wrapObj2.Provisions_for_exps_tax_etc__c  ?  this.wrapObj2.Provisions_for_exps_tax_etc__c : 0 ) +
               parseFloat(this.wrapObj2.Deffered_Tax_Liability_Assets__c  ?  this.wrapObj2.Deffered_Tax_Liability_Assets__c : 0 );
    }

    get totWorthPercentage() {
        return ((this.totWorthValue2 ? this.totWorthValue2:0) - (this.totWorthValue1 ? this.totWorthValue1:0))/(this.totWorthValue1 ? this.totWorthValue1:0);
    }

    get totWorthValue3() {
        return (parseFloat(this.wrapObj3.Revaluation_Reserves_Notional_Reserves__c ? this.wrapObj3.Revaluation_Reserves_Notional_Reserves__c : 0)) +
               this.recordNetWorthValue3 +
               parseFloat(this.wrapObj3.unsecured_Loan_from_promoters_family_m__c  ?  this.wrapObj3.unsecured_Loan_from_promoters_family_m__c : 0 ) +
               this.otherWorthValue3 + 
               parseFloat(this.wrapObj3.Sundry_creditors__c  ?  this.wrapObj3.Sundry_creditors__c : 0 ) +
               parseFloat(this.wrapObj3.Advances_from_customers__c  ?  this.wrapObj3.Advances_from_customers__c : 0 ) +
               parseFloat(this.wrapObj3.Other_current_liabilities__c  ?  this.wrapObj3.Other_current_liabilities__c : 0 ) +
               parseFloat(this.wrapObj3.Provisions_for_exps_tax_etc__c  ?  this.wrapObj3.Provisions_for_exps_tax_etc__c : 0 ) +
               parseFloat(this.wrapObj3.Deffered_Tax_Liability_Assets__c  ?  this.wrapObj3.Deffered_Tax_Liability_Assets__c : 0 );
    }

    get totWorthPercentage1() {
        return ((this.totWorthValue3 ? this.totWorthValue3:0) - (this.totWorthValue2 ? this.totWorthValue2:0))/(this.totWorthValue2 ? this.totWorthValue2:0);
    }

    // get assetsPercentage() {
    //     return (parseFloat(this.wrapObj2.Assets__c ?  this.wrapObj2.Assets__c : 0) - 
    //     parseFloat(this.wrapObj1.Assets__c ?  this.wrapObj1.Assets__c: 0)) / parseFloat(this.wrapObj2.Assets__c ?  this.wrapObj2.Assets__c : 0)
    // }

    get nettangPercentage() {
        return (parseFloat(this.wrapObj2.Net_Tangible_Fixed_Assets_Including_Cap__c ?  this.wrapObj2.Net_Tangible_Fixed_Assets_Including_Cap__c : 0) - 
        parseFloat(this.wrapObj1.Net_Tangible_Fixed_Assets_Including_Cap__c ?  this.wrapObj1.Net_Tangible_Fixed_Assets_Including_Cap__c : 0)) / parseFloat(this.wrapObj1.Net_Tangible_Fixed_Assets_Including_Cap__c ?  this.wrapObj1.Net_Tangible_Fixed_Assets_Including_Cap__c : 0)
    }

    get nettangPercentage1() {
        return (parseFloat(this.wrapObj3.Net_Tangible_Fixed_Assets_Including_Cap__c ?  this.wrapObj3.Net_Tangible_Fixed_Assets_Including_Cap__c : 0) - 
        parseFloat(this.wrapObj2.Net_Tangible_Fixed_Assets_Including_Cap__c ?  this.wrapObj2.Net_Tangible_Fixed_Assets_Including_Cap__c : 0)) / parseFloat(this.wrapObj2.Net_Tangible_Fixed_Assets_Including_Cap__c ?  this.wrapObj2.Net_Tangible_Fixed_Assets_Including_Cap__c : 0)
    }

    get fixedLiapercentage() {
        return (parseFloat(this.wrapObj2.Net_Intangible_Fixed_Assets__c ?  this.wrapObj2.Net_Intangible_Fixed_Assets__c : 0) - 
        parseFloat(this.wrapObj1.Net_Intangible_Fixed_Assets__c ?  this.wrapObj1.Net_Intangible_Fixed_Assets__c : 0)) / parseFloat(this.wrapObj1.Net_Intangible_Fixed_Assets__c ?  this.wrapObj1.Net_Intangible_Fixed_Assets__c : 0)
    }

    get fixedLiapercentage1() {
        return (parseFloat(this.wrapObj3.Net_Intangible_Fixed_Assets__c ?  this.wrapObj3.Net_Intangible_Fixed_Assets__c : 0) - 
        parseFloat(this.wrapObj2.Net_Intangible_Fixed_Assets__c ?  this.wrapObj2.Net_Intangible_Fixed_Assets__c : 0)) / parseFloat(this.wrapObj2.Net_Intangible_Fixed_Assets__c ?  this.wrapObj2.Net_Intangible_Fixed_Assets__c : 0)
    }

    get stockppercentage() {
        return (parseFloat(this.wrapObj2.Stock__c ?  this.wrapObj2.Stock__c : 0) - 
        parseFloat(this.wrapObj1.Stock__c ?  this.wrapObj1.Stock__c : 0)) / parseFloat(this.wrapObj1.Stock__c ?  this.wrapObj1.Stock__c : 0)
    }

    get stockppercentage1() {
        return (parseFloat(this.wrapObj3.Stock__c ?  this.wrapObj3.Stock__c : 0) - 
        parseFloat(this.wrapObj2.Stock__c ?  this.wrapObj2.Stock__c : 0)) / parseFloat(this.wrapObj2.Stock__c ?  this.wrapObj2.Stock__c : 0)
    }

    get debtorsExppercentage() {
        return (parseFloat(this.wrapObj2.Debtors__c ?  this.wrapObj2.Debtors__c : 0) - 
        parseFloat(this.wrapObj1.Debtors__c ?  this.wrapObj1.Debtors__c : 0)) / parseFloat(this.wrapObj1.Debtors__c ?  this.wrapObj1.Debtors__c : 0)
    }

    get debtorsExppercentage1() {
        return (parseFloat(this.wrapObj3.Debtors__c ?  this.wrapObj3.Debtors__c : 0) - 
        parseFloat(this.wrapObj2.Debtors__c ?  this.wrapObj2.Debtors__c : 0)) / parseFloat(this.wrapObj2.Debtors__c ?  this.wrapObj2.Debtors__c : 0)
    }

    get sixmonthPercentage() {
        return (parseFloat(this.wrapObj2.LessSix_months__c ?  this.wrapObj2.LessSix_months__c : 0) - 
        parseFloat(this.wrapObj1.LessSix_months__c ?  this.wrapObj1.LessSix_months__c: 0)) / parseFloat(this.wrapObj1.LessSix_months__c ?  this.wrapObj1.LessSix_months__c : 0)
    }

    get sixmonthPercentage1() {
        return (parseFloat(this.wrapObj3.LessSix_months__c ?  this.wrapObj3.LessSix_months__c : 0) - 
        parseFloat(this.wrapObj2.LessSix_months__c ?  this.wrapObj2.LessSix_months__c: 0)) / parseFloat(this.wrapObj2.LessSix_months__c ?  this.wrapObj2.LessSix_months__c : 0)
    }

    get Greaterthan6months() {
        return (parseFloat(this.wrapObj2.Greaterthan6__c ?  this.wrapObj2.Greaterthan6__c : 0) - 
        parseFloat(this.wrapObj1.Greaterthan6__c ?  this.wrapObj1.Greaterthan6__c: 0)) / parseFloat(this.wrapObj1.Greaterthan6__c ?  this.wrapObj1.Greaterthan6__c : 0)
    }

    get Greaterthan6months1() {
        return (parseFloat(this.wrapObj3.Greaterthan6__c ?  this.wrapObj3.Greaterthan6__c : 0) - 
        parseFloat(this.wrapObj2.Greaterthan6__c ?  this.wrapObj2.Greaterthan6__c: 0)) / parseFloat(this.wrapObj2.Greaterthan6__c ?  this.wrapObj2.Greaterthan6__c : 0)
    }

    get advsupPercentage() {
        return (parseFloat(this.wrapObj2.Advances_to_Suppliers__c ?  this.wrapObj2.Advances_to_Suppliers__c : 0) - 
        parseFloat(this.wrapObj1.Advances_to_Suppliers__c ?  this.wrapObj1.Advances_to_Suppliers__c : 0)) / parseFloat(this.wrapObj1.Advances_to_Suppliers__c ?  this.wrapObj1.Advances_to_Suppliers__c : 0)
    }

    get advsupPercentage1() {
        return (parseFloat(this.wrapObj3.Advances_to_Suppliers__c ?  this.wrapObj3.Advances_to_Suppliers__c : 0) - 
        parseFloat(this.wrapObj2.Advances_to_Suppliers__c ?  this.wrapObj2.Advances_to_Suppliers__c : 0)) / parseFloat(this.wrapObj2.Advances_to_Suppliers__c ?  this.wrapObj2.Advances_to_Suppliers__c : 0)
    }

    get invpercentage() {
        return (parseFloat(this.wrapObj2.Investments__c ?  this.wrapObj2.Investments__c : 0) - 
        parseFloat(this.wrapObj1.Investments__c ?  this.wrapObj1.Investments__c : 0)) / parseFloat(this.wrapObj1.Investments__c ?  this.wrapObj1.Investments__c : 0)
    }

    get invpercentage1() {
        return (parseFloat(this.wrapObj3.Investments__c ?  this.wrapObj3.Investments__c : 0) - 
        parseFloat(this.wrapObj2.Investments__c ?  this.wrapObj2.Investments__c : 0)) / parseFloat(this.wrapObj2.Investments__c ?  this.wrapObj2.Investments__c : 0)
    }

    get oLoanspercentage() {
        return (parseFloat(this.wrapObj2.Other_loans_advances__c ?  this.wrapObj2.Other_loans_advances__c : 0) - 
        parseFloat(this.wrapObj1.Other_loans_advances__c ?  this.wrapObj1.Other_loans_advances__c : 0)) / parseFloat(this.wrapObj1.Other_loans_advances__c ?  this.wrapObj1.Other_loans_advances__c : 0)
    }

    get oLoanspercentage1() {
        return (parseFloat(this.wrapObj3.Other_loans_advances__c ?  this.wrapObj3.Other_loans_advances__c : 0) - 
        parseFloat(this.wrapObj2.Other_loans_advances__c ?  this.wrapObj2.Other_loans_advances__c : 0)) / parseFloat(this.wrapObj2.Other_loans_advances__c ?  this.wrapObj2.Other_loans_advances__c : 0)
    }

    get prepaidpercentage() {
        return (parseFloat(this.wrapObj2.Prepaid_expenses__c ?  this.wrapObj2.Prepaid_expenses__c : 0) - 
        parseFloat(this.wrapObj1.Prepaid_expenses__c ?  this.wrapObj1.Prepaid_expenses__c : 0)) / parseFloat(this.wrapObj1.Prepaid_expenses__c ?  this.wrapObj1.Prepaid_expenses__c : 0)
    }

    get prepaidpercentage1() {
        return (parseFloat(this.wrapObj3.Prepaid_expenses__c ?  this.wrapObj3.Prepaid_expenses__c : 0) - 
        parseFloat(this.wrapObj2.Prepaid_expenses__c ?  this.wrapObj2.Prepaid_expenses__c : 0)) / parseFloat(this.wrapObj2.Prepaid_expenses__c ?  this.wrapObj2.Prepaid_expenses__c : 0)
    }

    get othercurrentassetspercentage() {
        return (parseFloat(this.wrapObj2.Other_current_assets__c ?  this.wrapObj2.Other_current_assets__c : 0) - 
        parseFloat(this.wrapObj1.Other_current_assets__c ?  this.wrapObj1.Other_current_assets__c : 0)) / parseFloat(this.wrapObj1.Other_current_assets__c ?  this.wrapObj1.Other_current_assets__c : 0)
    }

    get othercurrentassetspercentage1() {
        return (parseFloat(this.wrapObj3.Other_current_assets__c ?  this.wrapObj3.Other_current_assets__c : 0) - 
        parseFloat(this.wrapObj2.Other_current_assets__c ?  this.wrapObj2.Other_current_assets__c : 0)) / parseFloat(this.wrapObj2.Other_current_assets__c ?  this.wrapObj2.Other_current_assets__c : 0)
    }

    get currentExppercentage() {
        return (parseFloat(this.wrapObj2.Other_Non_Current_assets_Security_Depos__c ?  this.wrapObj2.Other_Non_Current_assets_Security_Depos__c : 0) - 
        parseFloat(this.wrapObj1.Other_Non_Current_assets_Security_Depos__c ?  this.wrapObj1.Other_Non_Current_assets_Security_Depos__c : 0)) / parseFloat(this.wrapObj1.Other_Non_Current_assets_Security_Depos__c ?  this.wrapObj1.Other_Non_Current_assets_Security_Depos__c : 0)
    }

    get currentExppercentage1() {
        return (parseFloat(this.wrapObj3.Other_Non_Current_assets_Security_Depos__c ?  this.wrapObj3.Other_Non_Current_assets_Security_Depos__c : 0) - 
        parseFloat(this.wrapObj2.Other_Non_Current_assets_Security_Depos__c ?  this.wrapObj2.Other_Non_Current_assets_Security_Depos__c : 0)) / parseFloat(this.wrapObj2.Other_Non_Current_assets_Security_Depos__c ?  this.wrapObj2.Other_Non_Current_assets_Security_Depos__c : 0)
    }

    get balancespercentage() {
        return (parseFloat(this.wrapObj2.Cash_Bank_Balances__c ?  this.wrapObj2.Cash_Bank_Balances__c : 0) - 
        parseFloat(this.wrapObj1.Cash_Bank_Balances__c ?  this.wrapObj1.Cash_Bank_Balances__c : 0)) / parseFloat(this.wrapObj1.Cash_Bank_Balances__c ?  this.wrapObj1.Cash_Bank_Balances__c : 0)
    }

    get balancespercentage1() {
        return (parseFloat(this.wrapObj3.Cash_Bank_Balances__c ?  this.wrapObj3.Cash_Bank_Balances__c : 0) - 
        parseFloat(this.wrapObj2.Cash_Bank_Balances__c ?  this.wrapObj2.Cash_Bank_Balances__c : 0)) / parseFloat(this.wrapObj2.Cash_Bank_Balances__c ?  this.wrapObj2.Cash_Bank_Balances__c : 0)
    }

    get allTotalValue1() {
        return (parseFloat(this.wrapObj1.Adavces_to_group_co_friends__c  ?  this.wrapObj1.Adavces_to_group_co_friends__c : 0)+ 
        parseFloat(this.wrapObj1.Net_Tangible_Fixed_Assets_Including_Cap__c  ?  this.wrapObj1.Net_Tangible_Fixed_Assets_Including_Cap__c : 0 )) +
        (parseFloat(this.wrapObj1.Net_Intangible_Fixed_Assets__c  ?  this.wrapObj1.Net_Intangible_Fixed_Assets__c : 0 )) +
        (parseFloat(this.wrapObj1.Stock__c  ?  this.wrapObj1.Stock__c : 0 )) +
        (parseFloat(this.wrapObj1.LessSix_months__c  ?  this.wrapObj1.LessSix_months__c : 0)+ 
        parseFloat(this.wrapObj1.Advances_to_Suppliers__c  ?  this.wrapObj1.Advances_to_Suppliers__c : 0 )) +
        (parseFloat(this.wrapObj1.Other_loans_advances__c  ?  this.wrapObj1.Other_loans_advances__c : 0 )) +
        (parseFloat(this.wrapObj1.Prepaid_expenses__c  ?  this.wrapObj1.Prepaid_expenses__c : 0 )) +
        (parseFloat(this.wrapObj1.Other_Non_Current_assets_Security_Depos__c  ?  this.wrapObj1.Other_Non_Current_assets_Security_Depos__c : 0 )) +
        (parseFloat(this.wrapObj1.Cash_Bank_Balances__c  ?  this.wrapObj1.Cash_Bank_Balances__c : 0 )) +
        (parseFloat(this.wrapObj1.Investments__c  ?  this.wrapObj1.Investments__c : 0 ))+
        (parseFloat(this.wrapObj1.Greaterthan6__c  ?  this.wrapObj1.Greaterthan6__c : 0 ))+
        (parseFloat(this.wrapObj1.Other_current_assets__c  ?  this.wrapObj1.Other_current_assets__c : 0 ));
    }

    get allTotalValue2() {
        return (parseFloat(this.wrapObj2.Adavces_to_group_co_friends__c  ?  this.wrapObj2.Adavces_to_group_co_friends__c : 0)+ 
        parseFloat(this.wrapObj2.Net_Tangible_Fixed_Assets_Including_Cap__c  ?  this.wrapObj2.Net_Tangible_Fixed_Assets_Including_Cap__c : 0 )) +
        (parseFloat(this.wrapObj2.Net_Intangible_Fixed_Assets__c  ?  this.wrapObj2.Net_Intangible_Fixed_Assets__c : 0 )) +
        (parseFloat(this.wrapObj2.Stock__c  ?  this.wrapObj2.Stock__c : 0 )) +
        (parseFloat(this.wrapObj2.LessSix_months__c  ?  this.wrapObj2.LessSix_months__c : 0)+ 
        parseFloat(this.wrapObj2.Advances_to_Suppliers__c  ?  this.wrapObj2.Advances_to_Suppliers__c : 0 )) +
        (parseFloat(this.wrapObj2.Other_loans_advances__c  ?  this.wrapObj2.Other_loans_advances__c : 0 )) +
        (parseFloat(this.wrapObj2.Prepaid_expenses__c  ?  this.wrapObj2.Prepaid_expenses__c : 0 )) +
        (parseFloat(this.wrapObj2.Other_Non_Current_assets_Security_Depos__c  ?  this.wrapObj2.Other_Non_Current_assets_Security_Depos__c : 0 )) +
        (parseFloat(this.wrapObj2.Cash_Bank_Balances__c  ?  this.wrapObj2.Cash_Bank_Balances__c : 0 )) +
        (parseFloat(this.wrapObj2.Investments__c  ?  this.wrapObj2.Investments__c : 0 ))+
        (parseFloat(this.wrapObj2.Greaterthan6__c  ?  this.wrapObj2.Greaterthan6__c : 0 ))+
        (parseFloat(this.wrapObj2.Other_current_assets__c  ?  this.wrapObj2.Other_current_assets__c : 0 ));
    }

    get allTotalValue3() {
        return (parseFloat(this.wrapObj3.Adavces_to_group_co_friends__c  ?  this.wrapObj3.Adavces_to_group_co_friends__c : 0)+ 
        parseFloat(this.wrapObj3.Net_Tangible_Fixed_Assets_Including_Cap__c  ?  this.wrapObj3.Net_Tangible_Fixed_Assets_Including_Cap__c : 0 )) +
        (parseFloat(this.wrapObj3.Net_Intangible_Fixed_Assets__c  ?  this.wrapObj3.Net_Intangible_Fixed_Assets__c : 0 )) +
        (parseFloat(this.wrapObj3.Stock__c  ?  this.wrapObj3.Stock__c : 0 )) +
        (parseFloat(this.wrapObj3.LessSix_months__c  ?  this.wrapObj3.LessSix_months__c : 0)+ 
        parseFloat(this.wrapObj3.Advances_to_Suppliers__c  ?  this.wrapObj3.Advances_to_Suppliers__c : 0 )) +
        (parseFloat(this.wrapObj3.Other_loans_advances__c  ?  this.wrapObj3.Other_loans_advances__c : 0 )) +
        (parseFloat(this.wrapObj3.Prepaid_expenses__c  ?  this.wrapObj3.Prepaid_expenses__c : 0 )) +
        (parseFloat(this.wrapObj3.Other_Non_Current_assets_Security_Depos__c  ?  this.wrapObj3.Other_Non_Current_assets_Security_Depos__c : 0 )) +
        (parseFloat(this.wrapObj3.Cash_Bank_Balances__c  ?  this.wrapObj3.Cash_Bank_Balances__c : 0 )) +
        (parseFloat(this.wrapObj3.Investments__c  ?  this.wrapObj3.Investments__c : 0 ))+
        (parseFloat(this.wrapObj3.Greaterthan6__c  ?  this.wrapObj3.Greaterthan6__c : 0 ))+
        (parseFloat(this.wrapObj3.Other_current_assets__c  ?  this.wrapObj3.Other_current_assets__c : 0 ));
    }

    get allWorthPercentage() {
        return ((this.allTotalValue2 ? this.allTotalValue2:0) - (this.allTotalValue1 ? this.allTotalValue1:0))/(this.allTotalValue1 ? this.allTotalValue1:0);
    }

    get allWorthPercentage1() {
        return ((this.allTotalValue3 ? this.allTotalValue3:0) - (this.allTotalValue2 ? this.allTotalValue2:0))/(this.allTotalValue2 ? this.allTotalValue2:0);
    }

    get diff1() {
        return ((this.totWorthValue1 ? this.totWorthValue1:0) - (this.allTotalValue1 ? this.allTotalValue1:0));
    }

    get diff2() {
        return ((this.totWorthValue2 ? this.totWorthValue2:0) - (this.allTotalValue2 ? this.allTotalValue2:0));
    }

    get diff3() {
        return ((this.totWorthValue3 ? this.totWorthValue3 : 0) - (this.allTotalValue3 ? this.allTotalValue3 : 0));
    }

    get sixMonthsError(){
        // if(this.wrapObj1 && this.wrapObj1.LessSix_months__c && this.wrapObj1.LessSix_months__c > 0 && 
        // this.wrapObj1.Greaterthan6__c && this.wrapObj1.Greaterthan6__c > 0){
        //     this.showToastMessage("Error", this.customLabel.BalanceSheet_Value_ErrorMessage +this.previousFinancialYear, "error", "sticky");
        //     return true;
        // }else if(this.wrapObj2 && this.wrapObj2.LessSix_months__c && this.wrapObj2.LessSix_months__c > 0 && 
        //     this.wrapObj2.Greaterthan6__c && this.wrapObj2.Greaterthan6__c > 0){
        //     this.showToastMessage("Error", this.customLabel.BalanceSheet_Value_ErrorMessage +this.currentFinancialYear, "error", "sticky");
        //     return true;
        // }else if(this.wrapObj3 && this.wrapObj3.LessSix_months__c && this.wrapObj3.LessSix_months__c > 0 && 
        //     this.wrapObj3.Greaterthan6__c && this.wrapObj3.Greaterthan6__c > 0){
        //     this.showToastMessage("Error", this.customLabel.BalanceSheet_Value_ErrorMessage +this.provisionalFinancialYear, "error", "sticky");
        //     return true;
        // }else{
        //     return false;
        // }
        return false;
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

    // inputChangeHandler(event){
    //     if(event.detail.value){
    //         this.provisionalFinancialSelection = event.detail.value;
    //     }
    //     if(this.provisionalFinancialSelection && this.provisionalFinancialSelection === 'No'){
    //         this.provisionalFinancialYearSelectionValue = undefined;
    //     }



    // }

    // inputChangeHandlerYear(event){
    //     if(event.detail.value){
    //         this.provisionalFinancialYearSelectionValue = event.detail.value;
    //     }
    // }

    @track provisionalFinancialYearOptions = [];
    @track provisionalFinancialYearSelectionValue;

    // get provisionalFinancialYearSelection(){
    //     if(this.provisionalFinancialSelection && this.provisionalFinancialSelection === 'Yes'){
    //         this.provisionalFinancialYearOptions = [{label: this.provisionalFinancialYear , value: this.provisionalFinancialYear}];
    //         return true;
    //     }else{
    //         return false;
    //     }
    // }


    @track params = {
        ParentObjectName: 'Applicant_Financial__c ',
        ChildObjectRelName: 'Applicant_Financial_Summary_s__r',
        parentObjFields: ['Id','Loan_Applicant__r.LoanAppln__c','Loan_Applicant__r.FullName__c'],
        childObjFields:['Id', 'Share_capital_Partner_s_Capital__c', 'P_L_A_capital__c', 'Revaluation_Reserves_Notional_Reserves__c',
                         'Net_worth__c', 'Adavces_to_group_co_friends__c', 'unsecured_Loan_from_promoters_family_m__c', 'Misc_Exp_Not_written_off__c',
                         'Adjusted_tangible_Netwroth__c', 'Bank_Borrowing_Working_Capital_OD_CC__c', 'Secured_debts_Banks_Ndfc__c', 'Unsecured_debts_Banks_Ndfc__c',
                         'Other_Loans_From_private_parties__c', 'Total_Loan_funds__c', 'Sundry_creditors__c', 'Advances_from_customers__c','Other_current_liabilities__c',
                         'Provisions_for_exps_tax_etc__c', 'Deffered_Tax_Liability_Assets__c', 'Net_Tangible_Fixed_Assets_Including_Cap__c',
                         'Net_Intangible_Fixed_Assets__c', 'Stock__c', 'Debtors__c', 'LessSix_months__c','Greaterthan6__c', 'Advances_to_Suppliers__c','Investments__c','Other_loans_advances__c',
                         'Prepaid_expenses__c', 'Other_current_assets__c', 'Other_Non_Current_assets_Security_Depos__c', 'Cash_Bank_Balances__c','Total__c',
                         'Difference__c', 'Applicant_Financial__c','Applicant_Financial__r.RecordTypeId','Applicant_Financial__r.RecordType.DeveloperName',
                         'Applicant_Financial__r.Loan_Applicant__c', 'Financial_Year__c', 'Liabilities_Remarks__c',	'Share_capital_Remarks__c',	'Gross_Profit_Remark__c',
                         'Reevaluation_Remark__c','Advances_Remarks__c','Unsecured_Loan_Remarks__c','Other_Indirect_Expenses_Remark__c','Borrowing_Remarks__c',	
                         'Secured_Remarks__c',	'Unsecured_Remarks__c',	'Other_Operating_Income_Remark__c',	'Sundry_Remarks__c', 'Purchases_Remark__c',	'Total_Loan_Remarks__c', 
                         'Taxes_Remark__c',	'Deferred_Tax_Liability_Remark__c',	'Assets_Remarks__c','Adjustable_Remarks__c','Profit_Before_Tax_Remark__c',	'Opening_Stock_Remark__c',	
                         'EBITDA_Remark__c','Less_Six_Months_Remarks__c','Greater_Six_Months_Remarks__c','Office_Administrative_Expenses_Remark__c',	
                         'Non_Operating_Expenses_Remark__c',	'Profit_Before_Depreciation_PBDT_Remark__c',	'Direct_Expenses_Remark__c','Depreciation_Remark__c',	
                         'Interest_on_CC_OD_limits_Remark__c','PAT_Remark__c', 'Comments_on_Balance_sheet__c'],
                         queryCriteria: ' where Loan_Applicant__r.LoanAppln__c = \'' + this.loanAppId + '\'' + ' AND RecordType.Name = \'Balance Sheet\''
    }

    handleLoanIdChange(value){
        
        let tempParams = this.params;
        tempParams.queryCriteria = ' where Loan_Applicant__r.LoanAppln__c = \'' + this.loanAppId + '\'' + ' AND RecordType.Name = \'Balance Sheet\''
        this.params = { ...tempParams };
    }

    @track wiredactualData;

    @track wrapConsData1 = [];
    @track wrapConsData2 = [];
    @track finalData =[];
    @wire(fetchRecords, { params: '$params' })
    handleConsolidateData(wiredResultIncome) {
        let { error, data } = wiredResultIncome;
        this.wiredactualData = wiredResultIncome;
        if (data) {  
            console.log('handleConsolidateData ',JSON.stringify(data));
            for(let i = 0 ; i< data.length;i++){
                console.log('handleConsolidateData inside I');
                if(data[i].ChildReords){
                for(let j=0; j<data[i].ChildReords.length;j++){
                    console.log('handleConsolidateData inside J');
                    this.wrapConsData2 = [...this.wrapConsData2,data[i].ChildReords[j]];
                }
            }
                //this.wrapConsData1 = [...this.wrapConsData1, data[i].ChildReords];
                //console.log('handleConsolidateData childData loop',JSON.stringify(data[i].ChildReords));
            }
            console.log('wrapConsData2 ',JSON.stringify(this.wrapConsData2));
            this.finalData = this.summarizedData(this.wrapConsData2);
            console.log('finalData ',JSON.stringify(this.finalData));
            console.log('wrapConsData1 ',JSON.stringify(this.wrapConsData1));
            this.financialRecordProcessor(this.finalData);

        } else if (error) {
            this.showToastMessage("Error in handleConsolidateData", error.body.message, "error", "sticky");
        }
    }

    summarizedData(wrapConsData1) {
        let financialData = wrapConsData1;
        let groupedData = {};

        financialData.forEach(record => {
            let year = record.Financial_Year__c;
            if (!groupedData[year]) {
                groupedData[year] = {
                    Share_capital_Partner_s_Capital__c:0,
                    P_L_A_capital__c:0,
                    Revaluation_Reserves_Notional_Reserves__c:0,
                    Net_worth__c:0,
                    Adavces_to_group_co_friends__c:0,
                    unsecured_Loan_from_promoters_family_m__c:0,
                    Misc_Exp_Not_written_off__c:0,
                    Bank_Borrowing_Working_Capital_OD_CC__c:0,
                    Secured_debts_Banks_Ndfc__c:0,
                    Unsecured_debts_Banks_Ndfc__c:0,
                    Other_Loans_From_private_parties__c:0,
                    Sundry_creditors__c:0,
                    Advances_from_customers__c:0,
                    Other_current_liabilities__c:0,
                    Provisions_for_exps_tax_etc__c:0,
                    Deffered_Tax_Liability_Assets__c:0,
                    Net_Tangible_Fixed_Assets_Including_Cap__c:0,
                    Net_Intangible_Fixed_Assets__c:0,
                    Stock__c:0,
                    Debtors__c:0,
                    LessSix_months__c:0,
                    Greaterthan6__c:0,
                    Advances_to_Suppliers__c:0,
                    Other_current_assets__c:0,
                    Other_loans_advances__c:0,
                    Prepaid_expenses__c:0,
                    Other_Non_Current_assets_Security_Depos__c:0,
                    Cash_Bank_Balances__c:0,
                    Investments__c:0

                };
            }

            groupedData[year].Share_capital_Partner_s_Capital__c += record.Share_capital_Partner_s_Capital__c;
            groupedData[year].P_L_A_capital__c += record.P_L_A_capital__c;
            groupedData[year].ExportSalesOutOfAboveSales__c += record.ExportSalesOutOfAboveSales__c;
            groupedData[year].Revaluation_Reserves_Notional_Reserves__c += record.Revaluation_Reserves_Notional_Reserves__c;
            groupedData[year].Non_Business_Income__c += record.Non_Business_Income__c;
            groupedData[year].Opening_Stock__c += record.Opening_Stock__c;
            groupedData[year].Closing_Stock__c += record.Closing_Stock__c;
            groupedData[year].Purchases__c += record.Purchases__c;
            groupedData[year].Direct_Expenses__c += record.Direct_Expenses__c;
            groupedData[year].Net_worth__c += record.Net_worth__c;
            groupedData[year].Office_Administrative_Expenses__c += record.Office_Administrative_Expenses__c;
            groupedData[year].Other_Indirect_Expenses__c += record.Other_Indirect_Expenses__c;
            groupedData[year].Non_Operating_Expenses_FxLoss_AssetLoss__c += record.Non_Operating_Expenses_FxLoss_AssetLoss__c;
            groupedData[year].Salary_to_Partner_Directors__c += record.Salary_to_Partner_Directors__c;
            groupedData[year].Adavces_to_group_co_friends__c += record.Adavces_to_group_co_friends__c;
            groupedData[year].Interest_on_Term_Loans__c += record.Interest_on_Term_Loans__c;
            groupedData[year].Interest_on_CC_OD_limits__c += record.Interest_on_CC_OD_limits__c;
            groupedData[year].Interest_on_Partner_Capital__c += record.Interest_on_Partner_Capital__c;
            groupedData[year].unsecured_Loan_from_promoters_family_m__c += record.unsecured_Loan_from_promoters_family_m__c;
            groupedData[year].Depreciation__c += record.Depreciation__c;
            groupedData[year].Misc_Exp_Not_written_off__c += record.Misc_Exp_Not_written_off__c;
            groupedData[year].Taxes__c += record.Taxes__c;
            groupedData[year].Bank_Borrowing_Working_Capital_OD_CC__c += record.Bank_Borrowing_Working_Capital_OD_CC__c;
            groupedData[year].Secured_debts_Banks_Ndfc__c += record.Secured_debts_Banks_Ndfc__c;
            groupedData[year].Unsecured_debts_Banks_Ndfc__c += record.Unsecured_debts_Banks_Ndfc__c;
            groupedData[year].Other_Loans_From_private_parties__c += record.Other_Loans_From_private_parties__c;
            
            groupedData[year].Sundry_creditors__c += record.Sundry_creditors__c;
            groupedData[year].Advances_from_customers__c += record.Advances_from_customers__c;
            groupedData[year].Other_current_liabilities__c += record.Other_current_liabilities__c;
            groupedData[year].Provisions_for_exps_tax_etc__c += record.Provisions_for_exps_tax_etc__c;

            groupedData[year].Deffered_Tax_Liability_Assets__c += record.Deffered_Tax_Liability_Assets__c;
            groupedData[year].Net_Tangible_Fixed_Assets_Including_Cap__c += record.Net_Tangible_Fixed_Assets_Including_Cap__c;
            groupedData[year].Net_Intangible_Fixed_Assets__c += record.Net_Intangible_Fixed_Assets__c;
            groupedData[year].Stock__c += record.Stock__c;

            groupedData[year].Debtors__c += record.Debtors__c;
            groupedData[year].LessSix_months__c += record.LessSix_months__c;
            groupedData[year].Greaterthan6__c += record.Greaterthan6__c;
            groupedData[year].Advances_to_Suppliers__c += record.Advances_to_Suppliers__c;

            
            groupedData[year].Other_current_assets__c += record.Other_current_assets__c;
            groupedData[year].Other_loans_advances__c += record.Other_loans_advances__c;
            groupedData[year].Prepaid_expenses__c += record.Prepaid_expenses__c;
            groupedData[year].Other_Non_Current_assets_Security_Depos__c += record.Other_Non_Current_assets_Security_Depos__c;
            groupedData[year].Cash_Bank_Balances__c += record.Cash_Bank_Balances__c;
            groupedData[year].Investments__c += record.Investments__c;
            
            });

        return Object.keys(groupedData).map(year => ({
            Financial_Year__c: year,
            ...groupedData[year]
        }));
    }

    financialRecordProcessor(financialDataProcess) {
        //this.createEmptyWrapObj();
        if (financialDataProcess) {
            let calculatePercent = false;
            if (financialDataProcess) {
                financialDataProcess.forEach(newItem => {
                    let year1 = this.previousFinancialYear;
                    let year2 = this.currentFinancialYear;
                    let year3 = this._provisionalYear;

                    if (newItem.Financial_Year__c == year1) {
                        this.wrapObj1.Financial_Year__c = newItem.Financial_Year__c;
                        this.wrapObj1.Id = newItem.Id;
                        this.wrapObj1.Share_capital_Partner_s_Capital__c = newItem.Share_capital_Partner_s_Capital__c ? newItem.Share_capital_Partner_s_Capital__c : '';
                        this.wrapObj1.P_L_A_capital__c = newItem.P_L_A_capital__c ? newItem.P_L_A_capital__c : '';
                        this.wrapObj1.Total_Sales__c = newItem.Total_Sales__c ? newItem.Total_Sales__c : '0';
                        this.wrapObj1.Other_Operating_Income_IncomeIncidental__c = newItem.Other_Operating_Income_IncomeIncidental__c ? newItem.Other_Operating_Income_IncomeIncidental__c : '0';
                        this.wrapObj1.ExportSalesOutOfAboveSales__c = newItem.ExportSalesOutOfAboveSales__c ? newItem.ExportSalesOutOfAboveSales__c : '0';
                        this.wrapObj1.Revaluation_Reserves_Notional_Reserves__c = newItem.Revaluation_Reserves_Notional_Reserves__c ? newItem.Revaluation_Reserves_Notional_Reserves__c : '0';
                        this.wrapObj1.Non_Business_Income__c = newItem.Non_Business_Income__c ? newItem.Non_Business_Income__c : '0';
                        this.wrapObj1.Opening_Stock__c = newItem.Opening_Stock__c ? newItem.Opening_Stock__c : '0';
                        this.wrapObj1.Closing_Stock__c = newItem.Closing_Stock__c ? newItem.Closing_Stock__c : '0';
                        this.wrapObj1.Purchases__c = newItem.Purchases__c ? newItem.Purchases__c : '0';
                        this.wrapObj1.Direct_Expenses__c = newItem.Direct_Expenses__c ? newItem.Direct_Expenses__c : '0';
                        this.wrapObj1.Net_worth__c = newItem.Net_worth__c ? newItem.Net_worth__c : '0';
                        this.wrapObj1.Office_Administrative_Expenses__c = newItem.Office_Administrative_Expenses__c ? newItem.Office_Administrative_Expenses__c : '0';
                        this.wrapObj1.Other_Indirect_Expenses__c = newItem.Other_Indirect_Expenses__c ? newItem.Other_Indirect_Expenses__c : '0';
                        this.wrapObj1.Non_Operating_Expenses_FxLoss_AssetLoss__c = newItem.Non_Operating_Expenses_FxLoss_AssetLoss__c ? newItem.Non_Operating_Expenses_FxLoss_AssetLoss__c : '0';
                        this.wrapObj1.Salary_to_Partner_Directors__c = newItem.Salary_to_Partner_Directors__c ? newItem.Salary_to_Partner_Directors__c : '0';
                        this.wrapObj1.Adavces_to_group_co_friends__c = newItem.Adavces_to_group_co_friends__c ? newItem.Adavces_to_group_co_friends__c : '0';
                        this.wrapObj1.Interest_on_Term_Loans__c = newItem.Interest_on_Term_Loans__c ? newItem.Interest_on_Term_Loans__c : '0';
                        this.wrapObj1.Interest_on_CC_OD_limits__c = newItem.Interest_on_CC_OD_limits__c ? newItem.Interest_on_CC_OD_limits__c : '0';
                        this.wrapObj1.Interest_on_Partner_Capital__c = newItem.Interest_on_Partner_Capital__c ? newItem.Interest_on_Partner_Capital__c : '0';
                        this.wrapObj1.unsecured_Loan_from_promoters_family_m__c = newItem.unsecured_Loan_from_promoters_family_m__c ? newItem.unsecured_Loan_from_promoters_family_m__c : '0';
                        this.wrapObj1.Depreciation__c = newItem.Depreciation__c ? newItem.Depreciation__c : '0';
                        this.wrapObj1.Misc_Exp_Not_written_off__c = newItem.Misc_Exp_Not_written_off__c ? newItem.Misc_Exp_Not_written_off__c : '0';
                        this.wrapObj1.Taxes__c = newItem.Taxes__c ? newItem.Taxes__c : '0';
                        this.wrapObj1.Bank_Borrowing_Working_Capital_OD_CC__c = newItem.Bank_Borrowing_Working_Capital_OD_CC__c ? newItem.Bank_Borrowing_Working_Capital_OD_CC__c : '0';
                        this.wrapObj1.Secured_debts_Banks_Ndfc__c = newItem.Secured_debts_Banks_Ndfc__c ? newItem.Secured_debts_Banks_Ndfc__c : '0';
                        this.wrapObj1.Unsecured_debts_Banks_Ndfc__c = newItem.Unsecured_debts_Banks_Ndfc__c ? newItem.Unsecured_debts_Banks_Ndfc__c : '0';
                        this.wrapObj1.Other_Loans_From_private_parties__c = newItem.Other_Loans_From_private_parties__c ? newItem.Other_Loans_From_private_parties__c : '0';
                        
                        this.wrapObj1.Sundry_creditors__c = newItem.Sundry_creditors__c ? newItem.Sundry_creditors__c : '0';
                        this.wrapObj1.Advances_from_customers__c = newItem.Advances_from_customers__c ? newItem.Advances_from_customers__c : '0';
                        this.wrapObj1.Other_current_liabilities__c = newItem.Other_current_liabilities__c ? newItem.Other_current_liabilities__c : '0';
                        
                        this.wrapObj1.Applicant_Financial__c = newItem.Applicant_Financial__c;
                        // Replace 'Field_Name__c' and 'Field_Name_Remark__c' with the actual field names
                        this.wrapObj1.Provisions_for_exps_tax_etc__c = newItem.Provisions_for_exps_tax_etc__c ? newItem.Provisions_for_exps_tax_etc__c : '';
                        this.wrapObj1.Other_Operating_Income_Remark__c = newItem.Other_Operating_Income_Remark__c ? newItem.Other_Operating_Income_Remark__c : '';
                        this.wrapObj1.Deffered_Tax_Liability_Assets__c = newItem.Deffered_Tax_Liability_Assets__c ? newItem.Deffered_Tax_Liability_Assets__c : '';
                        this.wrapObj1.Net_Tangible_Fixed_Assets_Including_Cap__c = newItem.Net_Tangible_Fixed_Assets_Including_Cap__c ? newItem.Net_Tangible_Fixed_Assets_Including_Cap__c : '';
                        this.wrapObj1.Net_Intangible_Fixed_Assets__c = newItem.Net_Intangible_Fixed_Assets__c ? newItem.Net_Intangible_Fixed_Assets__c : '';
                        this.wrapObj1.Opening_Stock_Remark__c = newItem.Opening_Stock_Remark__c ? newItem.Opening_Stock_Remark__c : '';
                        this.wrapObj1.Stock__c = newItem.Stock__c ? newItem.Stock__c : '';
                        this.wrapObj1.Purchases_Remark__c = newItem.Purchases_Remark__c ? newItem.Purchases_Remark__c : '';
                        this.wrapObj1.Direct_Expenses_Remark__c = newItem.Direct_Expenses_Remark__c ? newItem.Direct_Expenses_Remark__c : '';
                        this.wrapObj1.Gross_Profit_Remark__c = newItem.Gross_Profit_Remark__c ? newItem.Gross_Profit_Remark__c : '';
                        this.wrapObj1.Office_Administrative_Expenses_Remark__c = newItem.Office_Administrative_Expenses_Remark__c ? newItem.Office_Administrative_Expenses_Remark__c : '';
                        this.wrapObj1.Other_Indirect_Expenses_Remark__c = newItem.Other_Indirect_Expenses_Remark__c ? newItem.Other_Indirect_Expenses_Remark__c : '';
                        this.wrapObj1.Non_Operating_Expenses_Remark__c = newItem.Non_Operating_Expenses_Remark__c ? newItem.Non_Operating_Expenses_Remark__c : '';
                        this.wrapObj1.Debtors__c = newItem.Debtors__c ? newItem.Debtors__c : '';
                        this.wrapObj1.EBITDA_Remark__c = newItem.EBITDA_Remark__c ? newItem.EBITDA_Remark__c : '';
                        this.wrapObj1.LessSix_months__c = newItem.LessSix_months__c ? newItem.LessSix_months__c : '';
                        this.wrapObj1.Interest_on_CC_OD_limits_Remark__c = newItem.Interest_on_CC_OD_limits_Remark__c ? newItem.Interest_on_CC_OD_limits_Remark__c : '';
                        this.wrapObj1.Greaterthan6__c = newItem.Greaterthan6__c ? newItem.Greaterthan6__c : '';
                        this.wrapObj1.Profit_Before_Depreciation_PBDT_Remark__c = newItem.Profit_Before_Depreciation_PBDT_Remark__c ? newItem.Profit_Before_Depreciation_PBDT_Remark__c : '';
                        this.wrapObj1.Depreciation_Remark__c = newItem.Depreciation_Remark__c ? newItem.Depreciation_Remark__c : '';
                        this.wrapObj1.Profit_Before_Tax_Remark__c = newItem.Profit_Before_Tax_Remark__c ? newItem.Profit_Before_Tax_Remark__c : '';
                        this.wrapObj1.Taxes_Remark__c = newItem.Taxes_Remark__c ? newItem.Taxes_Remark__c : '';
                        this.wrapObj1.PAT_Remark__c = newItem.PAT_Remark__c ? newItem.PAT_Remark__c : '';
                        this.wrapObj1.Advances_to_Suppliers__c = newItem.Advances_to_Suppliers__c ? newItem.Advances_to_Suppliers__c : '';
                        this.wrapObj1.Investments__c = newItem.Investments__c ? newItem.Investments__c : '';
                        this.wrapObj1.Other_loans_advances__c = newItem.Other_loans_advances__c ? newItem.Other_loans_advances__c : '';
                        this.wrapObj1.Prepaid_expenses__c = newItem.Prepaid_expenses__c ? newItem.Prepaid_expenses__c : '';
                        this.wrapObj1.Other_current_assets__c = newItem.Other_current_assets__c ? newItem.Other_current_assets__c : '';
                        this.wrapObj1.Other_Non_Current_assets_Security_Depos__c = newItem.Other_Non_Current_assets_Security_Depos__c ? newItem.Other_Non_Current_assets_Security_Depos__c : '';
                        this.wrapObj1.Cash_Bank_Balances__c = newItem.Cash_Bank_Balances__c ? newItem.Cash_Bank_Balances__c : '';


                        this.wrapObj1.Previous_Financial_Year__c = true;
                        this.wrapObj1.Current_Financial_Year__c = false;
                        this.wrapObj1.Provisional_Financial_Year__c = false;

                        calculatePercent = true;
                    }
                    if (newItem.Financial_Year__c == year2) {
                        this.wrapObj2.Financial_Year__c = newItem.Financial_Year__c;
                        this.wrapObj2.Id = newItem.Id;
                        this.wrapObj2.Share_capital_Partner_s_Capital__c = newItem.Share_capital_Partner_s_Capital__c ? newItem.Share_capital_Partner_s_Capital__c : '';
                        this.wrapObj2.P_L_A_capital__c = newItem.P_L_A_capital__c ? newItem.P_L_A_capital__c : '';
                        this.wrapObj2.Total_Sales__c = newItem.Total_Sales__c ? newItem.Total_Sales__c : '0';
                        this.wrapObj2.Other_Operating_Income_IncomeIncidental__c = newItem.Other_Operating_Income_IncomeIncidental__c ? newItem.Other_Operating_Income_IncomeIncidental__c : '0';
                        this.wrapObj2.ExportSalesOutOfAboveSales__c = newItem.ExportSalesOutOfAboveSales__c ? newItem.ExportSalesOutOfAboveSales__c : '0';
                        this.wrapObj2.Revaluation_Reserves_Notional_Reserves__c = newItem.Revaluation_Reserves_Notional_Reserves__c ? newItem.Revaluation_Reserves_Notional_Reserves__c : '0';
                        this.wrapObj2.Non_Business_Income__c = newItem.Non_Business_Income__c ? newItem.Non_Business_Income__c : '0';
                        this.wrapObj2.Opening_Stock__c = newItem.Opening_Stock__c ? newItem.Opening_Stock__c : '0';
                        this.wrapObj2.Closing_Stock__c = newItem.Closing_Stock__c ? newItem.Closing_Stock__c : '0';
                        this.wrapObj2.Purchases__c = newItem.Purchases__c ? newItem.Purchases__c : '0';
                        this.wrapObj2.Direct_Expenses__c = newItem.Direct_Expenses__c ? newItem.Direct_Expenses__c : '0';
                        this.wrapObj2.Net_worth__c = newItem.Net_worth__c ? newItem.Net_worth__c : '0';
                        this.wrapObj2.Office_Administrative_Expenses__c = newItem.Office_Administrative_Expenses__c ? newItem.Office_Administrative_Expenses__c : '0';
                        this.wrapObj2.Other_Indirect_Expenses__c = newItem.Other_Indirect_Expenses__c ? newItem.Other_Indirect_Expenses__c : '0';
                        this.wrapObj2.Non_Operating_Expenses_FxLoss_AssetLoss__c = newItem.Non_Operating_Expenses_FxLoss_AssetLoss__c ? newItem.Non_Operating_Expenses_FxLoss_AssetLoss__c : '0';
                        this.wrapObj2.Salary_to_Partner_Directors__c = newItem.Salary_to_Partner_Directors__c ? newItem.Salary_to_Partner_Directors__c : '0';
                        this.wrapObj2.Adavces_to_group_co_friends__c = newItem.Adavces_to_group_co_friends__c ? newItem.Adavces_to_group_co_friends__c : '0';
                        this.wrapObj2.Interest_on_Term_Loans__c = newItem.Interest_on_Term_Loans__c ? newItem.Interest_on_Term_Loans__c : '0';
                        this.wrapObj2.Interest_on_CC_OD_limits__c = newItem.Interest_on_CC_OD_limits__c ? newItem.Interest_on_CC_OD_limits__c : '0';
                        this.wrapObj2.Interest_on_Partner_Capital__c = newItem.Interest_on_Partner_Capital__c ? newItem.Interest_on_Partner_Capital__c : '0';
                        this.wrapObj2.unsecured_Loan_from_promoters_family_m__c = newItem.unsecured_Loan_from_promoters_family_m__c ? newItem.unsecured_Loan_from_promoters_family_m__c : '0';
                        this.wrapObj2.Depreciation__c = newItem.Depreciation__c ? newItem.Depreciation__c : '0';
                        this.wrapObj2.Misc_Exp_Not_written_off__c = newItem.Misc_Exp_Not_written_off__c ? newItem.Misc_Exp_Not_written_off__c : '0';
                        this.wrapObj2.Taxes__c = newItem.Taxes__c ? newItem.Taxes__c : '0';
                        this.wrapObj2.Bank_Borrowing_Working_Capital_OD_CC__c = newItem.Bank_Borrowing_Working_Capital_OD_CC__c ? newItem.Bank_Borrowing_Working_Capital_OD_CC__c : '0';
                        this.wrapObj2.Secured_debts_Banks_Ndfc__c = newItem.Secured_debts_Banks_Ndfc__c ? newItem.Secured_debts_Banks_Ndfc__c : '0';
                        this.wrapObj2.Unsecured_debts_Banks_Ndfc__c = newItem.Unsecured_debts_Banks_Ndfc__c ? newItem.Unsecured_debts_Banks_Ndfc__c : '0';
                        this.wrapObj2.Other_Loans_From_private_parties__c = newItem.Other_Loans_From_private_parties__c ? newItem.Other_Loans_From_private_parties__c : '0';
                        
                        this.wrapObj2.Sundry_creditors__c = newItem.Sundry_creditors__c ? newItem.Sundry_creditors__c : '0';
                        this.wrapObj2.Advances_from_customers__c = newItem.Advances_from_customers__c ? newItem.Advances_from_customers__c : '0';
                        this.wrapObj2.Other_current_liabilities__c = newItem.Other_current_liabilities__c ? newItem.Other_current_liabilities__c : '0';
                        
                        
                        // Replace 'Field_Name__c' and 'Field_Name_Remark__c' with the actual field names
                        this.wrapObj2.Provisions_for_exps_tax_etc__c = newItem.Provisions_for_exps_tax_etc__c ? newItem.Provisions_for_exps_tax_etc__c : '';
                        this.wrapObj2.Other_Operating_Income_Remark__c = newItem.Other_Operating_Income_Remark__c ? newItem.Other_Operating_Income_Remark__c : '';
                        this.wrapObj2.Deffered_Tax_Liability_Assets__c = newItem.Deffered_Tax_Liability_Assets__c ? newItem.Deffered_Tax_Liability_Assets__c : '';
                        this.wrapObj2.Net_Tangible_Fixed_Assets_Including_Cap__c = newItem.Net_Tangible_Fixed_Assets_Including_Cap__c ? newItem.Net_Tangible_Fixed_Assets_Including_Cap__c : '';
                        this.wrapObj2.Net_Intangible_Fixed_Assets__c = newItem.Net_Intangible_Fixed_Assets__c ? newItem.Net_Intangible_Fixed_Assets__c : '';
                        this.wrapObj2.Opening_Stock_Remark__c = newItem.Opening_Stock_Remark__c ? newItem.Opening_Stock_Remark__c : '';
                        this.wrapObj2.Stock__c = newItem.Stock__c ? newItem.Stock__c : '';
                        this.wrapObj2.Purchases_Remark__c = newItem.Purchases_Remark__c ? newItem.Purchases_Remark__c : '';
                        this.wrapObj2.Direct_Expenses_Remark__c = newItem.Direct_Expenses_Remark__c ? newItem.Direct_Expenses_Remark__c : '';
                        this.wrapObj2.Gross_Profit_Remark__c = newItem.Gross_Profit_Remark__c ? newItem.Gross_Profit_Remark__c : '';
                        this.wrapObj2.Office_Administrative_Expenses_Remark__c = newItem.Office_Administrative_Expenses_Remark__c ? newItem.Office_Administrative_Expenses_Remark__c : '';
                        this.wrapObj2.Other_Indirect_Expenses_Remark__c = newItem.Other_Indirect_Expenses_Remark__c ? newItem.Other_Indirect_Expenses_Remark__c : '';
                        this.wrapObj2.Non_Operating_Expenses_Remark__c = newItem.Non_Operating_Expenses_Remark__c ? newItem.Non_Operating_Expenses_Remark__c : '';
                        this.wrapObj2.Debtors__c = newItem.Debtors__c ? newItem.Debtors__c : '';
                        this.wrapObj2.EBITDA_Remark__c = newItem.EBITDA_Remark__c ? newItem.EBITDA_Remark__c : '';
                        this.wrapObj2.LessSix_months__c = newItem.LessSix_months__c ? newItem.LessSix_months__c : '';
                        this.wrapObj2.Interest_on_CC_OD_limits_Remark__c = newItem.Interest_on_CC_OD_limits_Remark__c ? newItem.Interest_on_CC_OD_limits_Remark__c : '';
                        this.wrapObj2.Greaterthan6__c = newItem.Greaterthan6__c ? newItem.Greaterthan6__c : '';
                        this.wrapObj2.Profit_Before_Depreciation_PBDT_Remark__c = newItem.Profit_Before_Depreciation_PBDT_Remark__c ? newItem.Profit_Before_Depreciation_PBDT_Remark__c : '';
                        this.wrapObj2.Depreciation_Remark__c = newItem.Depreciation_Remark__c ? newItem.Depreciation_Remark__c : '';
                        this.wrapObj2.Profit_Before_Tax_Remark__c = newItem.Profit_Before_Tax_Remark__c ? newItem.Profit_Before_Tax_Remark__c : '';
                        this.wrapObj2.Taxes_Remark__c = newItem.Taxes_Remark__c ? newItem.Taxes_Remark__c : '';
                        this.wrapObj2.PAT_Remark__c = newItem.PAT_Remark__c ? newItem.PAT_Remark__c : '';
                        this.wrapObj2.Advances_to_Suppliers__c = newItem.Advances_to_Suppliers__c ? newItem.Advances_to_Suppliers__c : '';
                        this.wrapObj2.ITR_Filing_Gap_Days__c = newItem.ITR_Filing_Gap_Days__c ? newItem.ITR_Filing_Gap_Days__c : '0';
                        this.wrapObj2.Investments__c = newItem.Investments__c ? newItem.Investments__c : '';
                        this.wrapObj2.Other_loans_advances__c = newItem.Other_loans_advances__c ? newItem.Other_loans_advances__c : '';
                        this.wrapObj2.Prepaid_expenses__c = newItem.Prepaid_expenses__c ? newItem.Prepaid_expenses__c : '';
                        this.wrapObj2.Other_current_assets__c = newItem.Other_current_assets__c ? newItem.Other_current_assets__c : '';
                        this.wrapObj2.Other_Non_Current_assets_Security_Depos__c = newItem.Other_Non_Current_assets_Security_Depos__c ? newItem.Other_Non_Current_assets_Security_Depos__c : '';
                        this.wrapObj2.Cash_Bank_Balances__c = newItem.Cash_Bank_Balances__c ? newItem.Cash_Bank_Balances__c : '';

                        this.wrapObj2.Previous_Financial_Year__c = false;
                        this.wrapObj2.Current_Financial_Year__c = true;
                        this.wrapObj2.Provisional_Financial_Year__c = false;

                        calculatePercent = true;
                    }
                    if (newItem.Financial_Year__c == year3) {
                        this.hasProvisionalId = true;
                        this.wrapObj3.Financial_Year__c = newItem.Financial_Year__c;
                        this.wrapObj3.Id = newItem.Id;
                        this.wrapObj3.Share_capital_Partner_s_Capital__c = newItem.Share_capital_Partner_s_Capital__c ? newItem.Share_capital_Partner_s_Capital__c : '';
                        this.wrapObj3.P_L_A_capital__c = newItem.P_L_A_capital__c ? newItem.P_L_A_capital__c : '';
                        this.wrapObj3.Total_Sales__c = newItem.Total_Sales__c ? newItem.Total_Sales__c : '0';
                        this.wrapObj3.Other_Operating_Income_IncomeIncidental__c = newItem.Other_Operating_Income_IncomeIncidental__c ? newItem.Other_Operating_Income_IncomeIncidental__c : '0';
                        this.wrapObj3.ExportSalesOutOfAboveSales__c = newItem.ExportSalesOutOfAboveSales__c ? newItem.ExportSalesOutOfAboveSales__c : '0';
                        this.wrapObj3.Revaluation_Reserves_Notional_Reserves__c = newItem.Revaluation_Reserves_Notional_Reserves__c ? newItem.Revaluation_Reserves_Notional_Reserves__c : '0';
                        this.wrapObj3.Non_Business_Income__c = newItem.Non_Business_Income__c ? newItem.Non_Business_Income__c : '0';
                        this.wrapObj3.Opening_Stock__c = newItem.Opening_Stock__c ? newItem.Opening_Stock__c : '0';
                        this.wrapObj3.Closing_Stock__c = newItem.Closing_Stock__c ? newItem.Closing_Stock__c : '0';
                        this.wrapObj3.Purchases__c = newItem.Purchases__c ? newItem.Purchases__c : '0';
                        this.wrapObj3.Direct_Expenses__c = newItem.Direct_Expenses__c ? newItem.Direct_Expenses__c : '0';
                        this.wrapObj3.Net_worth__c = newItem.Net_worth__c ? newItem.Net_worth__c : '0';
                        this.wrapObj3.Office_Administrative_Expenses__c = newItem.Office_Administrative_Expenses__c ? newItem.Office_Administrative_Expenses__c : '0';
                        this.wrapObj3.Other_Indirect_Expenses__c = newItem.Other_Indirect_Expenses__c ? newItem.Other_Indirect_Expenses__c : '0';
                        this.wrapObj3.Non_Operating_Expenses_FxLoss_AssetLoss__c = newItem.Non_Operating_Expenses_FxLoss_AssetLoss__c ? newItem.Non_Operating_Expenses_FxLoss_AssetLoss__c : '0';
                        this.wrapObj3.Salary_to_Partner_Directors__c = newItem.Salary_to_Partner_Directors__c ? newItem.Salary_to_Partner_Directors__c : '0';
                        this.wrapObj3.Adavces_to_group_co_friends__c = newItem.Adavces_to_group_co_friends__c ? newItem.Adavces_to_group_co_friends__c : '0';
                        this.wrapObj3.Interest_on_Term_Loans__c = newItem.Interest_on_Term_Loans__c ? newItem.Interest_on_Term_Loans__c : '0';
                        this.wrapObj3.Interest_on_CC_OD_limits__c = newItem.Interest_on_CC_OD_limits__c ? newItem.Interest_on_CC_OD_limits__c : '0';
                        this.wrapObj3.Interest_on_Partner_Capital__c = newItem.Interest_on_Partner_Capital__c ? newItem.Interest_on_Partner_Capital__c : '0';
                        this.wrapObj3.unsecured_Loan_from_promoters_family_m__c = newItem.unsecured_Loan_from_promoters_family_m__c ? newItem.unsecured_Loan_from_promoters_family_m__c : '0';
                        this.wrapObj3.Depreciation__c = newItem.Depreciation__c ? newItem.Depreciation__c : '0';
                        this.wrapObj3.Misc_Exp_Not_written_off__c = newItem.Misc_Exp_Not_written_off__c ? newItem.Misc_Exp_Not_written_off__c : '0';
                        this.wrapObj3.Taxes__c = newItem.Taxes__c ? newItem.Taxes__c : '0';
                        this.wrapObj3.Bank_Borrowing_Working_Capital_OD_CC__c = newItem.Bank_Borrowing_Working_Capital_OD_CC__c ? newItem.Bank_Borrowing_Working_Capital_OD_CC__c : '0';
                        this.wrapObj3.Secured_debts_Banks_Ndfc__c = newItem.Secured_debts_Banks_Ndfc__c ? newItem.Secured_debts_Banks_Ndfc__c : '0';
                        this.wrapObj3.Unsecured_debts_Banks_Ndfc__c = newItem.Unsecured_debts_Banks_Ndfc__c ? newItem.Unsecured_debts_Banks_Ndfc__c : '0';
                        this.wrapObj3.Other_Loans_From_private_parties__c = newItem.Other_Loans_From_private_parties__c ? newItem.Other_Loans_From_private_parties__c : '0';
                        
                        this.wrapObj3.Sundry_creditors__c = newItem.Sundry_creditors__c ? newItem.Sundry_creditors__c : '0';
                        this.wrapObj3.Advances_from_customers__c = newItem.Advances_from_customers__c ? newItem.Advances_from_customers__c : '0';
                        this.wrapObj3.Other_current_liabilities__c = newItem.Other_current_liabilities__c ? newItem.Other_current_liabilities__c : '0';
                        
                        
                        // Replace 'Field_Name__c' and 'Field_Name_Remark__c' with the actual field names
                        this.wrapObj3.Provisions_for_exps_tax_etc__c = newItem.Provisions_for_exps_tax_etc__c ? newItem.Provisions_for_exps_tax_etc__c : '';
                        this.wrapObj3.Other_Operating_Income_Remark__c = newItem.Other_Operating_Income_Remark__c ? newItem.Other_Operating_Income_Remark__c : '';
                        this.wrapObj3.Deffered_Tax_Liability_Assets__c = newItem.Deffered_Tax_Liability_Assets__c ? newItem.Deffered_Tax_Liability_Assets__c : '';
                        this.wrapObj3.Net_Tangible_Fixed_Assets_Including_Cap__c = newItem.Net_Tangible_Fixed_Assets_Including_Cap__c ? newItem.Net_Tangible_Fixed_Assets_Including_Cap__c : '';
                        this.wrapObj3.Net_Intangible_Fixed_Assets__c = newItem.Net_Intangible_Fixed_Assets__c ? newItem.Net_Intangible_Fixed_Assets__c : '';
                        this.wrapObj3.Opening_Stock_Remark__c = newItem.Opening_Stock_Remark__c ? newItem.Opening_Stock_Remark__c : '';
                        this.wrapObj3.Stock__c = newItem.Stock__c ? newItem.Stock__c : '';
                        this.wrapObj3.Purchases_Remark__c = newItem.Purchases_Remark__c ? newItem.Purchases_Remark__c : '';
                        this.wrapObj3.Direct_Expenses_Remark__c = newItem.Direct_Expenses_Remark__c ? newItem.Direct_Expenses_Remark__c : '';
                        this.wrapObj3.Gross_Profit_Remark__c = newItem.Gross_Profit_Remark__c ? newItem.Gross_Profit_Remark__c : '';
                        this.wrapObj3.Office_Administrative_Expenses_Remark__c = newItem.Office_Administrative_Expenses_Remark__c ? newItem.Office_Administrative_Expenses_Remark__c : '';
                        this.wrapObj3.Other_Indirect_Expenses_Remark__c = newItem.Other_Indirect_Expenses_Remark__c ? newItem.Other_Indirect_Expenses_Remark__c : '';
                        this.wrapObj3.Non_Operating_Expenses_Remark__c = newItem.Non_Operating_Expenses_Remark__c ? newItem.Non_Operating_Expenses_Remark__c : '';
                        this.wrapObj3.Debtors__c = newItem.Debtors__c ? newItem.Debtors__c : '';
                        this.wrapObj3.EBITDA_Remark__c = newItem.EBITDA_Remark__c ? newItem.EBITDA_Remark__c : '';
                        this.wrapObj3.LessSix_months__c = newItem.LessSix_months__c ? newItem.LessSix_months__c : '';
                        this.wrapObj3.Interest_on_CC_OD_limits_Remark__c = newItem.Interest_on_CC_OD_limits_Remark__c ? newItem.Interest_on_CC_OD_limits_Remark__c : '';
                        this.wrapObj3.Greaterthan6__c = newItem.Greaterthan6__c ? newItem.Greaterthan6__c : '';
                        this.wrapObj3.Profit_Before_Depreciation_PBDT_Remark__c = newItem.Profit_Before_Depreciation_PBDT_Remark__c ? newItem.Profit_Before_Depreciation_PBDT_Remark__c : '';
                        this.wrapObj3.Depreciation_Remark__c = newItem.Depreciation_Remark__c ? newItem.Depreciation_Remark__c : '';
                        this.wrapObj3.Profit_Before_Tax_Remark__c = newItem.Profit_Before_Tax_Remark__c ? newItem.Profit_Before_Tax_Remark__c : '';
                        this.wrapObj3.Taxes_Remark__c = newItem.Taxes_Remark__c ? newItem.Taxes_Remark__c : '';
                        this.wrapObj3.PAT_Remark__c = newItem.PAT_Remark__c ? newItem.PAT_Remark__c : '';
                        this.wrapObj3.Advances_to_Suppliers__c = newItem.Advances_to_Suppliers__c ? newItem.Advances_to_Suppliers__c : '';
                        this.wrapObj3.Investments__c = newItem.Investments__c ? newItem.Investments__c : '';
                        this.wrapObj3.Other_loans_advances__c = newItem.Other_loans_advances__c ? newItem.Other_loans_advances__c : '';
                        this.wrapObj3.Prepaid_expenses__c = newItem.Prepaid_expenses__c ? newItem.Prepaid_expenses__c : '';
                        this.wrapObj3.Other_current_assets__c = newItem.Other_current_assets__c ? newItem.Other_current_assets__c : '';
                        this.wrapObj3.Other_Non_Current_assets_Security_Depos__c = newItem.Other_Non_Current_assets_Security_Depos__c ? newItem.Other_Non_Current_assets_Security_Depos__c : '';
                        this.wrapObj3.Cash_Bank_Balances__c = newItem.Cash_Bank_Balances__c ? newItem.Cash_Bank_Balances__c : '';

                        this.wrapObj3.Previous_Financial_Year__c = false;
                        this.wrapObj3.Current_Financial_Year__c = false;
                        this.wrapObj3.Provisional_Financial_Year__c = true;

                        calculatePercent = true;
                    }
                })
            }
            // if (calculatePercent) {
            //     this.incrementdecrement1.Total_Sales__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Total_Sales__c, this.wrapObj3.Total_Sales__c);
            //     this.incrementdecrement1.Other_Operating_Income_IncomeIncidental__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Other_Operating_Income_IncomeIncidental__c, this.wrapObj3.Other_Operating_Income_IncomeIncidental__c);
            //     this.incrementdecrement1.ExportSalesOutOfAboveSales__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.ExportSalesOutOfAboveSales__c, this.wrapObj3.ExportSalesOutOfAboveSales__c);
            //     this.incrementdecrement1.Non_Business_Income__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Non_Business_Income__c, this.wrapObj3.Non_Business_Income__c);
            //     this.incrementdecrement1.Opening_Stock__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Opening_Stock__c, this.wrapObj3.Opening_Stock__c);
            //     this.incrementdecrement1.Closing_Stock__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Closing_Stock__c, this.wrapObj3.Closing_Stock__c);
            //     this.incrementdecrement1.Purchases__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Purchases__c, this.wrapObj3.Purchases__c);
            //     this.incrementdecrement1.Direct_Expenses__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Direct_Expenses__c, this.wrapObj3.Direct_Expenses__c);
            //     this.incrementdecrement1.Office_Administrative_Expenses__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Office_Administrative_Expenses__c, this.wrapObj3.Office_Administrative_Expenses__c);
            //     this.incrementdecrement1.Other_Indirect_Expenses__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Other_Indirect_Expenses__c, this.wrapObj3.Other_Indirect_Expenses__c);
            //     this.incrementdecrement1.Non_Operating_Expenses_FxLoss_AssetLoss__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Non_Operating_Expenses_FxLoss_AssetLoss__c, this.wrapObj3.Non_Operating_Expenses_FxLoss_AssetLoss__c);
            //     this.incrementdecrement1.Salary_to_Partner_Directors__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Salary_to_Partner_Directors__c, this.wrapObj3.Salary_to_Partner_Directors__c);
            //     this.incrementdecrement1.Interest_on_Term_Loans__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Interest_on_Term_Loans__c, this.wrapObj3.Interest_on_Term_Loans__c);
            //     this.incrementdecrement1.Interest_on_CC_OD_limits__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Interest_on_CC_OD_limits__c, this.wrapObj3.Interest_on_CC_OD_limits__c);
            //     this.incrementdecrement1.Interest_on_Partner_Capital__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Interest_on_Partner_Capital__c, this.wrapObj3.Interest_on_Partner_Capital__c);
            //     this.incrementdecrement1.Depreciation__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Depreciation__c, this.wrapObj3.Depreciation__c);
            //     this.incrementdecrement1.Taxes__c = this.calculateIncrementDecrementPercentage(this.wrapObj2.Taxes__c, this.wrapObj3.Taxes__c);
            //     this.incrementdecrement.Total_Sales__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Total_Sales__c, this.wrapObj2.Total_Sales__c);
            //     this.incrementdecrement.Other_Operating_Income_IncomeIncidental__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Other_Operating_Income_IncomeIncidental__c, this.wrapObj2.Other_Operating_Income_IncomeIncidental__c);

            //     this.incrementdecrement.Non_Business_Income__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Non_Business_Income__c, this.wrapObj2.Non_Business_Income__c);
            //     this.incrementdecrement.Opening_Stock__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Opening_Stock__c, this.wrapObj2.Opening_Stock__c);
            //     this.incrementdecrement.Closing_Stock__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Closing_Stock__c, this.wrapObj2.Closing_Stock__c);
            //     this.incrementdecrement.Purchases__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Purchases__c, this.wrapObj2.Purchases__c);
            //     this.incrementdecrement.Direct_Expenses__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Direct_Expenses__c, this.wrapObj2.Direct_Expenses__c);
            //     this.incrementdecrement.Office_Administrative_Expenses__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Office_Administrative_Expenses__c, this.wrapObj2.Office_Administrative_Expenses__c);
            //     this.incrementdecrement.Other_Indirect_Expenses__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Other_Indirect_Expenses__c, this.wrapObj2.Other_Indirect_Expenses__c);
            //     this.incrementdecrement.Non_Operating_Expenses_FxLoss_AssetLoss__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Non_Operating_Expenses_FxLoss_AssetLoss__c, this.wrapObj2.Non_Operating_Expenses_FxLoss_AssetLoss__c);
            //     this.incrementdecrement.Salary_to_Partner_Directors__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Salary_to_Partner_Directors__c, this.wrapObj2.Salary_to_Partner_Directors__c);
            //     this.incrementdecrement.Interest_on_Term_Loans__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Interest_on_Term_Loans__c, this.wrapObj2.Interest_on_Term_Loans__c);
            //     this.incrementdecrement.Interest_on_CC_OD_limits__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Interest_on_CC_OD_limits__c, this.wrapObj2.Interest_on_CC_OD_limits__c);
            //     this.incrementdecrement.Interest_on_Partner_Capital__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Interest_on_Partner_Capital__c, this.wrapObj2.Interest_on_Partner_Capital__c);
            //     this.incrementdecrement.Depreciation__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Depreciation__c, this.wrapObj2.Depreciation__c);
            //     this.incrementdecrement.Taxes__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.Taxes__c, this.wrapObj2.Taxes__c);
            //     this.incrementdecrement.ExportSalesOutOfAboveSales__c = this.calculateIncrementDecrementPercentage(this.wrapObj1.ExportSalesOutOfAboveSales__c, this.wrapObj2.ExportSalesOutOfAboveSales__c);
                
            //     this.calculateGrossProfit1();
            //     this.calculateGrossProfit2();
            //     this.calculateGrossProfit3();
            // }
            //this.checkDateValueIssue();
        }
    }
    calculateIncrementDecrementPercentage(x, y) {
        let per = ((parseFloat(y) - parseFloat(x)) / parseFloat(x));
        if (per != Infinity) {
            return parseFloat(per);
        }
        else {
            return 0;
        }
    }
}