import { LightningElement, track, api, wire } from 'lwc';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import { refreshApex } from '@salesforce/apex';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import FINANCIAL_OBJECT from '@salesforce/schema/Applicant_Financial__c';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import deleteRecord_Data from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';
import processDefunctRecordsFinancial from '@salesforce/apex/FinancialRecordProcessor.processDefunctRecordsFinancial';


export default class DownloadUtility extends LightningElement {
    
    @track lastFinancialRecord={};
    @track currentFinancialRecord={};
    @track provisionalFinancialRecord={};
    @api loanAppId;
    @api hasEditAccess;
    @track financialType = 'Balance_Sheet';
    @track _applicantId ;
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
        if(this.hasEditAccess && this.hasEditAccess === true){
            return false;
        }else{
            return true;
        }
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
    connectedCallback() {
        setTimeout(() => {
            //console.log('this.sharePartnerPercentage'+this.sharePartnerPercentage)
        }, 2000);
        
    }
    get incDecForBala() {
        var incDecForBalaobj={'Share_capital_Partner_s_Capital__c': this.sharePartnerPercentage,'P_L_A_capital__c': this.plaPercentage, 'Revaluation_Reserves_Notional_Reserves__c': this.revolutionPercentage,'Net_worth__c':this.networthPercentage, 'Adavces_to_group_co_friends__c':this.advancePercentage,'unsecured_Loan_from_promoters_family_m__c':this.loanpromotorsPercentage,'Misc_Exp_Not_written_off__c':this.miscExppercentage, 'Adjusted_tangible_Netwroth__c':""}
        return incDecForBalaobj
        
    }
    get incDecForBala1() {
        var incDecForBalaobj1={'Share_capital_Partner_s_Capital__c': this.sharePartnerPercentage1,'P_L_A_capital__c': this.plaPercentage1, 'Revaluation_Reserves_Notional_Reserves__c': this.revolutionPercentage1,'Net_worth__c':this.networthPercentage1, 'Adavces_to_group_co_friends__c':this.advancePercentage1,'unsecured_Loan_from_promoters_family_m__c':this.loanpromotorsPercentage1,'Misc_Exp_Not_written_off__c':this.miscExppercentage1}
        return incDecForBalaobj1;
        
    }



    @track applicantBalanceSheetData ;
    @wire(getSobjectData, { params: '$parameter' })
    handleIncomeResponse(wiredResultBS) {
        let { error, data } = wiredResultBS;
        this.applicantBalanceSheetData = wiredResultBS;
        if (data) {
            if(data.parentRecords && data.parentRecords.length>0){
                console.log('Financial Data!! '+JSON.stringify(data.parentRecords));
                this.formFinancialData(data.parentRecords);
            }else{
                this.formFinancialData(null);
            }
        } else if (error) {
            console.error('Error BS ------------->', error);
        }
    }

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

 

    formFinancialData(dataRecord){
        this.currentFinancialRecord = null;
        this.lastFinancialRecord = null;
        this.provisionalFinancialRecord = null;
        if(dataRecord && dataRecord.length>0){
            for(var i=0; i<dataRecord.length; i++){

                let objectData = {
                    Id: dataRecord[i].Id,
                    Share_capital_Partner_s_Capital__c: dataRecord[i].Share_capital_Partner_s_Capital__c ?  dataRecord[i].Share_capital_Partner_s_Capital__c : 0,
                    P_L_A_capital__c: dataRecord[i].P_L_A_capital__c  ?  dataRecord[i].P_L_A_capital__c : 0,
                    Revaluation_Reserves_Notional_Reserves__c: dataRecord[i].Revaluation_Reserves_Notional_Reserves__c ? dataRecord[i].Revaluation_Reserves_Notional_Reserves__c : 0,
                    Adavces_to_group_co_friends__c: dataRecord[i].Adavces_to_group_co_friends__c  ?  dataRecord[i].Adavces_to_group_co_friends__c : 0,
                    unsecured_Loan_from_promoters_family_m__c: dataRecord[i].unsecured_Loan_from_promoters_family_m__c ? dataRecord[i].unsecured_Loan_from_promoters_family_m__c : 0,
                    Misc_Exp_Not_written_off__c: dataRecord[i].Misc_Exp_Not_written_off__c ? dataRecord[i].Misc_Exp_Not_written_off__c : 0,
                    Bank_Borrowing_Working_Capital_OD_CC__c: dataRecord[i].Bank_Borrowing_Working_Capital_OD_CC__c ? dataRecord[i].Bank_Borrowing_Working_Capital_OD_CC__c : 0,
                    Secured_debts_Banks_Ndfc__c: dataRecord[i].Secured_debts_Banks_Ndfc__c ? dataRecord[i].Secured_debts_Banks_Ndfc__c : 0,
                    Unsecured_debts_Banks_Ndfc__c: dataRecord[i].Unsecured_debts_Banks_Ndfc__c ? dataRecord[i].Unsecured_debts_Banks_Ndfc__c : 0,
                    Other_Loans_From_private_parties__c: dataRecord[i].Other_Loans_From_private_parties__c ? dataRecord[i].Other_Loans_From_private_parties__c : 0,
                    Sundry_creditors__c: dataRecord[i].Sundry_creditors__c ? dataRecord[i].Sundry_creditors__c : 0,
                    Advances_from_customers__c: dataRecord[i].Advances_from_customers__c ? dataRecord[i].Advances_from_customers__c : 0,
                    Other_current_liabilities__c: dataRecord[i].Other_current_liabilities__c ? dataRecord[i].Other_current_liabilities__c : 0,
                    Provisions_for_exps_tax_etc__c: dataRecord[i].Provisions_for_exps_tax_etc__c ? dataRecord[i].Provisions_for_exps_tax_etc__c : 0,
                    Deffered_Tax_Liability_Assets__c: dataRecord[i].Deffered_Tax_Liability_Assets__c ? dataRecord[i].Deffered_Tax_Liability_Assets__c : 0,
                    Net_Tangible_Fixed_Assets_Including_Cap__c: dataRecord[i].Net_Tangible_Fixed_Assets_Including_Cap__c ? dataRecord[i].Net_Tangible_Fixed_Assets_Including_Cap__c : 0,
                    Net_Intangible_Fixed_Assets__c: dataRecord[i].Net_Intangible_Fixed_Assets__c ? dataRecord[i].Net_Intangible_Fixed_Assets__c : 0,
                    Stock__c: dataRecord[i].Stock__c ? dataRecord[i].Stock__c : 0,
                    Debtors__c: dataRecord[i].Debtors__c ? dataRecord[i].Debtors__c : 0,
                    LessSix_months__c: dataRecord[i].LessSix_months__c ? dataRecord[i].LessSix_months__c : 0,
                    Greaterthan6__c: dataRecord[i].Greaterthan6__c ? dataRecord[i].Greaterthan6__c : 0,
                    Advances_to_Suppliers__c: dataRecord[i].Advances_to_Suppliers__c ? dataRecord[i].Advances_to_Suppliers__c : 0,
                    Investments__c: dataRecord[i].Investments__c ? dataRecord[i].Investments__c : 0,
                    Other_loans_advances__c: dataRecord[i].Other_loans_advances__c ? dataRecord[i].Other_loans_advances__c : 0,
                    Prepaid_expenses__c: dataRecord[i].Prepaid_expenses__c ? dataRecord[i].Prepaid_expenses__c : 0,
                    Other_current_assets__c: dataRecord[i].Other_current_assets__c ? dataRecord[i].Other_current_assets__c : 0,
                    Other_Non_Current_assets_Security_Depos__c: dataRecord[i].Other_Non_Current_assets_Security_Depos__c ? dataRecord[i].Other_Non_Current_assets_Security_Depos__c : 0,
                    Cash_Bank_Balances__c: dataRecord[i].Cash_Bank_Balances__c ? dataRecord[i].Cash_Bank_Balances__c : 0,
                    Net_worth__c: dataRecord[i].Net_worth__c ? dataRecord[i].Net_worth__c : 0,
                    Adjusted_tangible_Netwroth__c: dataRecord[i].Adjusted_tangible_Netwroth__c ? dataRecord[i].Adjusted_tangible_Netwroth__c : 0,
                    Total_Loan_funds__c: dataRecord[i].Total_Loan_funds__c ? dataRecord[i].Total_Loan_funds__c : 0,
                    Total__c: dataRecord[i].Total__c ? dataRecord[i].Total__c : 0,
                    Difference__c: dataRecord[i].Difference__c ? dataRecord[i].Difference__c : 0,
                    Liabilities_Remarks__c: dataRecord[i].Liabilities_Remarks__c ? dataRecord[i].Liabilities_Remarks__c : '',
                    Share_capital_Remarks__c: dataRecord[i].Share_capital_Remarks__c ? dataRecord[i].Share_capital_Remarks__c : '',
                    Gross_Profit_Remark__c: dataRecord[i].Gross_Profit_Remark__c ? dataRecord[i].Gross_Profit_Remark__c : '',
                    Reevaluation_Remark__c: dataRecord[i].Reevaluation_Remark__c ? dataRecord[i].Reevaluation_Remark__c : '',
                    Advances_Remarks__c: dataRecord[i].Advances_Remarks__c ? dataRecord[i].Advances_Remarks__c : '',
                    Unsecured_Loan_Remarks__c: dataRecord[i].Unsecured_Loan_Remarks__c ? dataRecord[i].Unsecured_Loan_Remarks__c : '',
                    Other_Indirect_Expenses_Remark__c: dataRecord[i].Other_Indirect_Expenses_Remark__c ? dataRecord[i].Other_Indirect_Expenses_Remark__c : '',
                    Borrowing_Remarks__c: dataRecord[i].Borrowing_Remarks__c ? dataRecord[i].Borrowing_Remarks__c : '',
                    Secured_Remarks__c: dataRecord[i].Secured_Remarks__c ? dataRecord[i].Secured_Remarks__c : '',
                    Unsecured_Remarks__c: dataRecord[i].Unsecured_Remarks__c ? dataRecord[i].Unsecured_Remarks__c : '',
                    Other_Operating_Income_Remark__c: dataRecord[i].Other_Operating_Income_Remark__c ? dataRecord[i].Other_Operating_Income_Remark__c : '',
                    Sundry_Remarks__c: dataRecord[i].Sundry_Remarks__c ? dataRecord[i].Sundry_Remarks__c : '',
                    Purchases_Remark__c: dataRecord[i].Purchases_Remark__c ? dataRecord[i].Purchases_Remark__c : '',
                    Total_Loan_Remarks__c: dataRecord[i].Total_Loan_Remarks__c ? dataRecord[i].Total_Loan_Remarks__c : '',
                    Taxes_Remark__c: dataRecord[i].Taxes_Remark__c ? dataRecord[i].Taxes_Remark__c : '',
                    Deferred_Tax_Liability_Remark__c: dataRecord[i].Deferred_Tax_Liability_Remark__c ? dataRecord[i].Deferred_Tax_Liability_Remark__c : '',
                    Assets_Remarks__c: dataRecord[i].Assets_Remarks__c ? dataRecord[i].Assets_Remarks__c : '',
                    Adjustable_Remarks__c: dataRecord[i].Adjustable_Remarks__c ? dataRecord[i].Adjustable_Remarks__c : '',
                    Profit_Before_Tax_Remark__c: dataRecord[i].Profit_Before_Tax_Remark__c ? dataRecord[i].Profit_Before_Tax_Remark__c : '',
                    Opening_Stock_Remark__c: dataRecord[i].Opening_Stock_Remark__c ? dataRecord[i].Opening_Stock_Remark__c : '',
                    EBITDA_Remark__c: dataRecord[i].EBITDA_Remark__c ? dataRecord[i].EBITDA_Remark__c : '',
                    Less_Six_Months_Remarks__c: dataRecord[i].Less_Six_Months_Remarks__c ? dataRecord[i].Less_Six_Months_Remarks__c : '',
                    Greater_Six_Months_Remarks__c: dataRecord[i].Greater_Six_Months_Remarks__c ? dataRecord[i].Greater_Six_Months_Remarks__c : '',
                    Office_Administrative_Expenses_Remark__c: dataRecord[i].Office_Administrative_Expenses_Remark__c ? dataRecord[i].Office_Administrative_Expenses_Remark__c : '',
                    Non_Operating_Expenses_Remark__c: dataRecord[i].Non_Operating_Expenses_Remark__c ? dataRecord[i].Non_Operating_Expenses_Remark__c : '',
                    Profit_Before_Depreciation_PBDT_Remark__c: dataRecord[i].Profit_Before_Depreciation_PBDT_Remark__c ? dataRecord[i].Profit_Before_Depreciation_PBDT_Remark__c : '',
                    Direct_Expenses_Remark__c: dataRecord[i].Direct_Expenses_Remark__c ? dataRecord[i].Direct_Expenses_Remark__c : '',
                    Depreciation_Remark__c: dataRecord[i].Depreciation_Remark__c ? dataRecord[i].Depreciation_Remark__c : '',
                    Interest_on_CC_OD_limits_Remark__c: dataRecord[i].Interest_on_CC_OD_limits_Remark__c ? dataRecord[i].Interest_on_CC_OD_limits_Remark__c : '',
                    PAT_Remark__c: dataRecord[i].PAT_Remark__c ? dataRecord[i].PAT_Remark__c : '',
                    Comments_on_Balance_sheet__c: dataRecord[i].Comments_on_Balance_sheet__c ? dataRecord[i].Comments_on_Balance_sheet__c : '',
                }
                

                if(dataRecord[i].Financial_Year__c && dataRecord[i].Financial_Year__c === this.currentFinancialYear){
                    
                    objectData.Financial_Year__c = dataRecord[i].Financial_Year__c ? dataRecord[i].Financial_Year__c : this.currentFinancialYear;
                    
                    objectData.Current_Financial_Year__c=true;
                    objectData.Previous_Financial_Year__c=false;
                    objectData.Provisional_Financial_Year__c=false;

                    this.currentFinancialRecord = objectData;
                }else if(dataRecord[i].Financial_Year__c && dataRecord[i].Financial_Year__c === this.previousFinancialYear){
                    objectData.Financial_Year__c = dataRecord[i].Financial_Year__c ? dataRecord[i].Financial_Year__c : this.previousFinancialYear;
                    
                    objectData.Current_Financial_Year__c=false;
                    objectData.Previous_Financial_Year__c=true;
                    objectData.Provisional_Financial_Year__c=false;
                    
                    this.lastFinancialRecord = objectData;
                }else if(dataRecord[i].Financial_Year__c && dataRecord[i].Financial_Year__c === this.provisionalFinancialYear){
                    objectData.Financial_Year__c = dataRecord[i].Financial_Year__c ? dataRecord[i].Financial_Year__c : this.provisionalFinancialYear;
                    objectData.Current_Financial_Year__c=false;
                    objectData.Previous_Financial_Year__c=false;
                    objectData.Provisional_Financial_Year__c=true;
                    
                    this.provisionalFinancialRecord = objectData;
                    //this.provisionalFinancialSelection = 'Yes';
                    this.provisionalFinancialYearSelectionValue = this.provisionalFinancialYear;
                }
            }
        }


        if(!this.currentFinancialRecord || (Object.keys(this.currentFinancialRecord).length == 0)){
            this.currentFinancialRecord = this.emptyRecord;
            
            this.currentFinancialRecord.Current_Financial_Year__c=true;
            this.currentFinancialRecord.Previous_Financial_Year__c=false;
            this.currentFinancialRecord.Provisional_Financial_Year__c=false;

            this.currentFinancialRecord.Financial_Year__c = this.currentFinancialYear;

        }
        if(!this.lastFinancialRecord || (Object.keys(this.lastFinancialRecord).length == 0)){
            this.lastFinancialRecord = this.emptyRecord;
            
            this.lastFinancialRecord.Current_Financial_Year__c=false;
            this.lastFinancialRecord.Previous_Financial_Year__c=true;
            this.lastFinancialRecord.Provisional_Financial_Year__c=false;
            
            this.lastFinancialRecord.Financial_Year__c = this.previousFinancialYear;
        }
        if(!this.provisionalFinancialRecord || (Object.keys(this.provisionalFinancialRecord).length == 0)){
            this.provisionalFinancialRecord = this.emptyRecord;
           
            this.provisionalFinancialRecord.Current_Financial_Year__c=false;
            this.provisionalFinancialRecord.Previous_Financial_Year__c=false;
            this.provisionalFinancialRecord.Provisional_Financial_Year__c=true;
            
            this.provisionalFinancialRecord.Financial_Year__c = this.provisionalFinancialYear;
        }  
    }

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

    @track showSpinner = false;
    @track del_recIds = [];

    get sharePartnerPercentage() {
        return (parseFloat(this.currentFinancialRecord.Share_capital_Partner_s_Capital__c ?  this.currentFinancialRecord.Share_capital_Partner_s_Capital__c : 0) - 
        parseFloat(this.lastFinancialRecord.Share_capital_Partner_s_Capital__c ?  this.lastFinancialRecord.Share_capital_Partner_s_Capital__c : 0)) / parseFloat(this.lastFinancialRecord.Share_capital_Partner_s_Capital__c ?  this.lastFinancialRecord.Share_capital_Partner_s_Capital__c : 0)
    }

    get sharePartnerPercentage1() {
        return (parseFloat(this.provisionalFinancialRecord.Share_capital_Partner_s_Capital__c ?  this.provisionalFinancialRecord.Share_capital_Partner_s_Capital__c : 0) - 
        parseFloat(this.currentFinancialRecord.Share_capital_Partner_s_Capital__c ?  this.currentFinancialRecord.Share_capital_Partner_s_Capital__c : 0)) / parseFloat(this.currentFinancialRecord.Share_capital_Partner_s_Capital__c ?  this.currentFinancialRecord.Share_capital_Partner_s_Capital__c : 0)
    }

    get plaPercentage() {
        return (parseFloat(this.currentFinancialRecord.P_L_A_capital__c ?  this.currentFinancialRecord.P_L_A_capital__c : 0) - 
        parseFloat(this.lastFinancialRecord.P_L_A_capital__c ?  this.lastFinancialRecord.P_L_A_capital__c : 0)) / parseFloat(this.lastFinancialRecord.P_L_A_capital__c ?  this.lastFinancialRecord.P_L_A_capital__c : 0)
    }

    get plaPercentage1() {
        return (parseFloat(this.provisionalFinancialRecord.P_L_A_capital__c ?  this.provisionalFinancialRecord.P_L_A_capital__c : 0) - 
        parseFloat(this.currentFinancialRecord.P_L_A_capital__c ?  this.currentFinancialRecord.P_L_A_capital__c : 0)) / parseFloat(this.currentFinancialRecord.P_L_A_capital__c ?  this.currentFinancialRecord.P_L_A_capital__c : 0)
    }

    get revolutionPercentage() {
        return (parseFloat(this.currentFinancialRecord.Revaluation_Reserves_Notional_Reserves__c ?  this.currentFinancialRecord.Revaluation_Reserves_Notional_Reserves__c : 0) - 
        parseFloat(this.lastFinancialRecord.Revaluation_Reserves_Notional_Reserves__c ?  this.lastFinancialRecord.Revaluation_Reserves_Notional_Reserves__c : 0)) / parseFloat(this.lastFinancialRecord.Revaluation_Reserves_Notional_Reserves__c ?  this.lastFinancialRecord.Revaluation_Reserves_Notional_Reserves__c : 0)
    }

    get revolutionPercentage1() {
        return (parseFloat(this.provisionalFinancialRecord.Revaluation_Reserves_Notional_Reserves__c ?  this.provisionalFinancialRecord.Revaluation_Reserves_Notional_Reserves__c : 0) - 
        parseFloat(this.currentFinancialRecord.Revaluation_Reserves_Notional_Reserves__c ?  this.currentFinancialRecord.Revaluation_Reserves_Notional_Reserves__c : 0)) / parseFloat(this.currentFinancialRecord.Revaluation_Reserves_Notional_Reserves__c ?  this.currentFinancialRecord.Revaluation_Reserves_Notional_Reserves__c : 0)
    }
    
    get recordNetWorthValue1() {
        return (parseFloat(this.lastFinancialRecord.Share_capital_Partner_s_Capital__c  ?  this.lastFinancialRecord.Share_capital_Partner_s_Capital__c : 0)+ 
        parseFloat(this.lastFinancialRecord.P_L_A_capital__c  ?  this.lastFinancialRecord.P_L_A_capital__c : 0 )) - parseFloat(this.lastFinancialRecord.Misc_Exp_Not_written_off__c  ?  this.lastFinancialRecord.Misc_Exp_Not_written_off__c : 0 );
    }

    get recordNetWorthValue2() {
        return (parseFloat(this.currentFinancialRecord.Share_capital_Partner_s_Capital__c  ?  this.currentFinancialRecord.Share_capital_Partner_s_Capital__c : 0)+ 
        parseFloat(this.currentFinancialRecord.P_L_A_capital__c  ?  this.currentFinancialRecord.P_L_A_capital__c : 0 )) - parseFloat(this.currentFinancialRecord.Misc_Exp_Not_written_off__c  ?  this.currentFinancialRecord.Misc_Exp_Not_written_off__c : 0 );
    }

    get recordNetWorthValue3() {
        return (parseFloat(this.provisionalFinancialRecord.Share_capital_Partner_s_Capital__c  ?  this.provisionalFinancialRecord.Share_capital_Partner_s_Capital__c : 0)+ 
        parseFloat(this.provisionalFinancialRecord.P_L_A_capital__c  ?  this.provisionalFinancialRecord.P_L_A_capital__c : 0 )) - parseFloat(this.provisionalFinancialRecord.Misc_Exp_Not_written_off__c  ?  this.provisionalFinancialRecord.Misc_Exp_Not_written_off__c : 0 );
    }

    get networthPercentage() {
        return ((this.recordNetWorthValue2 ? this.recordNetWorthValue2:0) - (this.recordNetWorthValue1 ? this.recordNetWorthValue1:0))/(this.recordNetWorthValue1 ? this.recordNetWorthValue1:0);
    }

    get networthPercentage1() {
        return ((this.recordNetWorthValue3 ? this.recordNetWorthValue3:0) - (this.recordNetWorthValue2 ? this.recordNetWorthValue2:0))/(this.recordNetWorthValue2 ? this.recordNetWorthValue2:0);
    }

    get advancePercentage() {
        return (parseFloat(this.currentFinancialRecord.Adavces_to_group_co_friends__c ?  this.currentFinancialRecord.Adavces_to_group_co_friends__c : 0) - 
        parseFloat(this.lastFinancialRecord.Adavces_to_group_co_friends__c ?  this.lastFinancialRecord.Adavces_to_group_co_friends__c: 0)) / parseFloat(this.lastFinancialRecord.Adavces_to_group_co_friends__c ?  this.lastFinancialRecord.Adavces_to_group_co_friends__c : 0)
    }

    get advancePercentage1() {
        return (parseFloat(this.provisionalFinancialRecord.Adavces_to_group_co_friends__c ?  this.provisionalFinancialRecord.Adavces_to_group_co_friends__c : 0) - 
        parseFloat(this.currentFinancialRecord.Adavces_to_group_co_friends__c ?  this.currentFinancialRecord.Adavces_to_group_co_friends__c: 0)) / parseFloat(this.currentFinancialRecord.Adavces_to_group_co_friends__c ?  this.currentFinancialRecord.Adavces_to_group_co_friends__c : 0)
    }

    get loanpromotorsPercentage() {
        return (parseFloat(this.currentFinancialRecord.unsecured_Loan_from_promoters_family_m__c ?  this.currentFinancialRecord.unsecured_Loan_from_promoters_family_m__c : 0) - 
        parseFloat(this.lastFinancialRecord.unsecured_Loan_from_promoters_family_m__c ?  this.lastFinancialRecord.unsecured_Loan_from_promoters_family_m__c : 0)) / parseFloat(this.lastFinancialRecord.unsecured_Loan_from_promoters_family_m__c ?  this.lastFinancialRecord.unsecured_Loan_from_promoters_family_m__c : 0)
    }

    get loanpromotorsPercentage1() {
        return (parseFloat(this.provisionalFinancialRecord.unsecured_Loan_from_promoters_family_m__c ?  this.provisionalFinancialRecord.unsecured_Loan_from_promoters_family_m__c : 0) - 
        parseFloat(this.currentFinancialRecord.unsecured_Loan_from_promoters_family_m__c ?  this.currentFinancialRecord.unsecured_Loan_from_promoters_family_m__c : 0)) / parseFloat(this.currentFinancialRecord.unsecured_Loan_from_promoters_family_m__c ?  this.currentFinancialRecord.unsecured_Loan_from_promoters_family_m__c : 0)
    }

    get miscExppercentage() {
        return (parseFloat(this.currentFinancialRecord.Misc_Exp_Not_written_off__c ?  this.currentFinancialRecord.Misc_Exp_Not_written_off__c : 0) - 
        parseFloat(this.lastFinancialRecord.Misc_Exp_Not_written_off__c ?  this.lastFinancialRecord.Misc_Exp_Not_written_off__c : 0)) / parseFloat(this.lastFinancialRecord.Misc_Exp_Not_written_off__c ?  this.lastFinancialRecord.Misc_Exp_Not_written_off__c : 0)
    }

    get miscExppercentage1() {
        return (parseFloat(this.provisionalFinancialRecord.Misc_Exp_Not_written_off__c ?  this.provisionalFinancialRecord.Misc_Exp_Not_written_off__c : 0) - 
        parseFloat(this.currentFinancialRecord.Misc_Exp_Not_written_off__c ?  this.currentFinancialRecord.Misc_Exp_Not_written_off__c : 0)) / parseFloat(this.currentFinancialRecord.Misc_Exp_Not_written_off__c ?  this.currentFinancialRecord.Misc_Exp_Not_written_off__c : 0)
    }

    get adjustedNetworthValue1() {
        return ((this.recordNetWorthValue1 ? this.recordNetWorthValue1:0) + parseFloat(this.lastFinancialRecord.unsecured_Loan_from_promoters_family_m__c  ?  this.lastFinancialRecord.unsecured_Loan_from_promoters_family_m__c : 0)) -
        (parseFloat(this.lastFinancialRecord.Adavces_to_group_co_friends__c  ?  this.lastFinancialRecord.Adavces_to_group_co_friends__c : 0 ) +
        (parseFloat(this.lastFinancialRecord.Net_Intangible_Fixed_Assets__c ? this.lastFinancialRecord.Net_Intangible_Fixed_Assets__c : 0)) +
        (parseFloat(this.lastFinancialRecord.Greaterthan6__c ? this.lastFinancialRecord.Greaterthan6__c : 0)));
    }

    get adjustedNetworthValue2() {
        return ((this.recordNetWorthValue2 ? this.recordNetWorthValue2:0) + parseFloat(this.currentFinancialRecord.unsecured_Loan_from_promoters_family_m__c  ?  this.currentFinancialRecord.unsecured_Loan_from_promoters_family_m__c : 0)) -
        (parseFloat(this.currentFinancialRecord.Adavces_to_group_co_friends__c  ?  this.currentFinancialRecord.Adavces_to_group_co_friends__c : 0 ) +
        (parseFloat(this.currentFinancialRecord.Net_Intangible_Fixed_Assets__c ? this.currentFinancialRecord.Net_Intangible_Fixed_Assets__c : 0)) +
        (parseFloat(this.currentFinancialRecord.Greaterthan6__c ? this.currentFinancialRecord.Greaterthan6__c : 0)));
    }

    get adjustedPercentage() {
        return ((this.adjustedNetworthValue2 ? this.adjustedNetworthValue2:0) - (this.adjustedNetworthValue1 ? this.adjustedNetworthValue1:0))/(this.adjustedNetworthValue1 ? this.adjustedNetworthValue1:0);
    }

    get adjustedNetworthValue3() {
        return ((this.recordNetWorthValue3 ? this.recordNetWorthValue3:0) + parseFloat(this.provisionalFinancialRecord.unsecured_Loan_from_promoters_family_m__c  ?  this.provisionalFinancialRecord.unsecured_Loan_from_promoters_family_m__c : 0)) -
        (parseFloat(this.provisionalFinancialRecord.Adavces_to_group_co_friends__c  ?  this.provisionalFinancialRecord.Adavces_to_group_co_friends__c : 0 ) +
        (parseFloat(this.provisionalFinancialRecord.Net_Intangible_Fixed_Assets__c ? this.provisionalFinancialRecord.Net_Intangible_Fixed_Assets__c : 0)) +
        (parseFloat(this.provisionalFinancialRecord.Greaterthan6__c ? this.provisionalFinancialRecord.Greaterthan6__c : 0)));
    }

    get adjustedPercentage1() {
        return ((this.adjustedNetworthValue3 ? this.adjustedNetworthValue3:0) - (this.adjustedNetworthValue2 ? this.adjustedNetworthValue2:0))/(this.adjustedNetworthValue2 ? this.adjustedNetworthValue2:0);
    }

    get borrowPercentage() {
        return (parseFloat(this.currentFinancialRecord.Bank_Borrowing_Working_Capital_OD_CC__c ?  this.currentFinancialRecord.Bank_Borrowing_Working_Capital_OD_CC__c : 0) - 
        parseFloat(this.lastFinancialRecord.Bank_Borrowing_Working_Capital_OD_CC__c ?  this.lastFinancialRecord.Bank_Borrowing_Working_Capital_OD_CC__c: 0)) / parseFloat(this.lastFinancialRecord.Bank_Borrowing_Working_Capital_OD_CC__c ?  this.lastFinancialRecord.Bank_Borrowing_Working_Capital_OD_CC__c : 0)
    }

    get borrowPercentage1() {
        return (parseFloat(this.provisionalFinancialRecord.Bank_Borrowing_Working_Capital_OD_CC__c ?  this.provisionalFinancialRecord.Bank_Borrowing_Working_Capital_OD_CC__c : 0) - 
        parseFloat(this.currentFinancialRecord.Bank_Borrowing_Working_Capital_OD_CC__c ?  this.currentFinancialRecord.Bank_Borrowing_Working_Capital_OD_CC__c: 0)) / parseFloat(this.currentFinancialRecord.Bank_Borrowing_Working_Capital_OD_CC__c ?  this.currentFinancialRecord.Bank_Borrowing_Working_Capital_OD_CC__c : 0)
    }

    get unsecuredPercentage() {
        return (parseFloat(this.currentFinancialRecord.Secured_debts_Banks_Ndfc__c ?  this.currentFinancialRecord.Secured_debts_Banks_Ndfc__c : 0) - 
        parseFloat(this.lastFinancialRecord.Secured_debts_Banks_Ndfc__c ?  this.lastFinancialRecord.Secured_debts_Banks_Ndfc__c : 0)) / parseFloat(this.lastFinancialRecord.Secured_debts_Banks_Ndfc__c ?  this.lastFinancialRecord.Secured_debts_Banks_Ndfc__c : 0)
    }

    get unsecuredPercentage1() {
        return (parseFloat(this.provisionalFinancialRecord.Secured_debts_Banks_Ndfc__c ?  this.provisionalFinancialRecord.Secured_debts_Banks_Ndfc__c : 0) - 
        parseFloat(this.currentFinancialRecord.Secured_debts_Banks_Ndfc__c ?  this.currentFinancialRecord.Secured_debts_Banks_Ndfc__c : 0)) / parseFloat(this.currentFinancialRecord.Secured_debts_Banks_Ndfc__c ?  this.currentFinancialRecord.Secured_debts_Banks_Ndfc__c : 0)
    }

    get otherExppercentage() {
        return (parseFloat(this.currentFinancialRecord.Unsecured_debts_Banks_Ndfc__c ?  this.currentFinancialRecord.Unsecured_debts_Banks_Ndfc__c : 0) - 
        parseFloat(this.lastFinancialRecord.Unsecured_debts_Banks_Ndfc__c ?  this.lastFinancialRecord.Unsecured_debts_Banks_Ndfc__c : 0)) / parseFloat(this.lastFinancialRecord.Unsecured_debts_Banks_Ndfc__c ?  this.lastFinancialRecord.Unsecured_debts_Banks_Ndfc__c : 0)
    }

    get otherExppercentage1() {
        return (parseFloat(this.provisionalFinancialRecord.Unsecured_debts_Banks_Ndfc__c ?  this.provisionalFinancialRecord.Unsecured_debts_Banks_Ndfc__c : 0) - 
        parseFloat(this.currentFinancialRecord.Unsecured_debts_Banks_Ndfc__c ?  this.currentFinancialRecord.Unsecured_debts_Banks_Ndfc__c : 0)) / parseFloat(this.currentFinancialRecord.Unsecured_debts_Banks_Ndfc__c ?  this.currentFinancialRecord.Unsecured_debts_Banks_Ndfc__c : 0)
    }

    get totalExppercentage() {
        return (parseFloat(this.currentFinancialRecord.Other_Loans_From_private_parties__c ?  this.currentFinancialRecord.Other_Loans_From_private_parties__c : 0) - 
        parseFloat(this.lastFinancialRecord.Other_Loans_From_private_parties__c ?  this.lastFinancialRecord.Other_Loans_From_private_parties__c : 0)) / parseFloat(this.lastFinancialRecord.Other_Loans_From_private_parties__c ?  this.lastFinancialRecord.Other_Loans_From_private_parties__c : 0)
    }

    get totalExppercentage1() {
        return (parseFloat(this.provisionalFinancialRecord.Other_Loans_From_private_parties__c ?  this.provisionalFinancialRecord.Other_Loans_From_private_parties__c : 0) - 
        parseFloat(this.currentFinancialRecord.Other_Loans_From_private_parties__c ?  this.currentFinancialRecord.Other_Loans_From_private_parties__c : 0)) / parseFloat(this.currentFinancialRecord.Other_Loans_From_private_parties__c ?  this.currentFinancialRecord.Other_Loans_From_private_parties__c : 0)
    }

    get otherWorthValue1() {
        return (parseFloat(this.lastFinancialRecord.Bank_Borrowing_Working_Capital_OD_CC__c  ?  this.lastFinancialRecord.Bank_Borrowing_Working_Capital_OD_CC__c : 0)+ 
        parseFloat(this.lastFinancialRecord.Secured_debts_Banks_Ndfc__c  ?  this.lastFinancialRecord.Secured_debts_Banks_Ndfc__c : 0 )) +
        (parseFloat(this.lastFinancialRecord.Other_Loans_From_private_parties__c  ?  this.lastFinancialRecord.Other_Loans_From_private_parties__c : 0 )) +
        (parseFloat(this.lastFinancialRecord.Unsecured_debts_Banks_Ndfc__c  ?  this.lastFinancialRecord.Unsecured_debts_Banks_Ndfc__c : 0 ));
    }

    get otherWorthValue2() {
        return (parseFloat(this.currentFinancialRecord.Bank_Borrowing_Working_Capital_OD_CC__c  ?  this.currentFinancialRecord.Bank_Borrowing_Working_Capital_OD_CC__c : 0)+ 
        parseFloat(this.currentFinancialRecord.Secured_debts_Banks_Ndfc__c  ?  this.currentFinancialRecord.Secured_debts_Banks_Ndfc__c : 0 )) +
        (parseFloat(this.currentFinancialRecord.Other_Loans_From_private_parties__c  ?  this.currentFinancialRecord.Other_Loans_From_private_parties__c : 0 )) + 
        (parseFloat(this.currentFinancialRecord.Unsecured_debts_Banks_Ndfc__c  ?  this.currentFinancialRecord.Unsecured_debts_Banks_Ndfc__c : 0 )) ;
    }

    get totalPercentage() {
        return ((this.otherWorthValue2 ? this.otherWorthValue2:0) - (this.otherWorthValue1 ? this.otherWorthValue1:0))/(this.otherWorthValue1 ? this.otherWorthValue1:0);
    }

    get otherWorthValue3() {
        return (parseFloat(this.provisionalFinancialRecord.Bank_Borrowing_Working_Capital_OD_CC__c  ?  this.provisionalFinancialRecord.Bank_Borrowing_Working_Capital_OD_CC__c : 0)+ 
        parseFloat(this.provisionalFinancialRecord.Secured_debts_Banks_Ndfc__c  ?  this.provisionalFinancialRecord.Secured_debts_Banks_Ndfc__c : 0 )) +
        (parseFloat(this.provisionalFinancialRecord.Other_Loans_From_private_parties__c  ?  this.provisionalFinancialRecord.Other_Loans_From_private_parties__c : 0 )) + 
        (parseFloat(this.provisionalFinancialRecord.Unsecured_debts_Banks_Ndfc__c  ?  this.provisionalFinancialRecord.Unsecured_debts_Banks_Ndfc__c : 0 )) ;
    }

    get totalPercentage1() {
        return ((this.otherWorthValue3 ? this.otherWorthValue3:0) - (this.otherWorthValue2 ? this.otherWorthValue2:0))/(this.otherWorthValue2 ? this.otherWorthValue2:0);
    }

    get creditorsPercentage() {
        return (parseFloat(this.currentFinancialRecord.Sundry_creditors__c ?  this.currentFinancialRecord.Sundry_creditors__c : 0) - 
        parseFloat(this.lastFinancialRecord.Sundry_creditors__c ?  this.lastFinancialRecord.Sundry_creditors__c: 0)) / parseFloat(this.lastFinancialRecord.Sundry_creditors__c ?  this.lastFinancialRecord.Sundry_creditors__c : 0)
    }

    get creditorsPercentage1() {
        return (parseFloat(this.provisionalFinancialRecord.Sundry_creditors__c ?  this.provisionalFinancialRecord.Sundry_creditors__c : 0) - 
        parseFloat(this.currentFinancialRecord.Sundry_creditors__c ?  this.currentFinancialRecord.Sundry_creditors__c: 0)) / parseFloat(this.currentFinancialRecord.Sundry_creditors__c ?  this.currentFinancialRecord.Sundry_creditors__c : 0)
    }

    get advPercentage() {
        return (parseFloat(this.currentFinancialRecord.Advances_from_customers__c ?  this.currentFinancialRecord.Advances_from_customers__c : 0) - 
        parseFloat(this.lastFinancialRecord.Advances_from_customers__c ?  this.lastFinancialRecord.Advances_from_customers__c : 0)) / parseFloat(this.lastFinancialRecord.Advances_from_customers__c ?  this.lastFinancialRecord.Advances_from_customers__c : 0)
    }

    get advPercentage1() {
        return (parseFloat(this.provisionalFinancialRecord.Advances_from_customers__c ?  this.provisionalFinancialRecord.Advances_from_customers__c : 0) - 
        parseFloat(this.currentFinancialRecord.Advances_from_customers__c ?  this.currentFinancialRecord.Advances_from_customers__c : 0)) / parseFloat(this.currentFinancialRecord.Advances_from_customers__c ?  this.currentFinancialRecord.Advances_from_customers__c : 0)
    }

    get otherLiapercentage() {
        return (parseFloat(this.currentFinancialRecord.Other_current_liabilities__c ?  this.currentFinancialRecord.Other_current_liabilities__c : 0) - 
        parseFloat(this.lastFinancialRecord.Other_current_liabilities__c ?  this.lastFinancialRecord.Other_current_liabilities__c : 0)) / parseFloat(this.lastFinancialRecord.Other_current_liabilities__c ?  this.lastFinancialRecord.Other_current_liabilities__c : 0)
    }

    get otherLiapercentage1() {
        return (parseFloat(this.provisionalFinancialRecord.Other_current_liabilities__c ?  this.provisionalFinancialRecord.Other_current_liabilities__c : 0) - 
        parseFloat(this.currentFinancialRecord.Other_current_liabilities__c ?  this.currentFinancialRecord.Other_current_liabilities__c : 0)) / parseFloat(this.currentFinancialRecord.Other_current_liabilities__c ?  this.currentFinancialRecord.Other_current_liabilities__c : 0)
    }

    get provExppercentage() {
        return (parseFloat(this.currentFinancialRecord.Provisions_for_exps_tax_etc__c ?  this.currentFinancialRecord.Provisions_for_exps_tax_etc__c : 0) - 
        parseFloat(this.lastFinancialRecord.Provisions_for_exps_tax_etc__c ?  this.lastFinancialRecord.Provisions_for_exps_tax_etc__c : 0)) / parseFloat(this.lastFinancialRecord.Provisions_for_exps_tax_etc__c ?  this.lastFinancialRecord.Provisions_for_exps_tax_etc__c : 0)
    }

    get provExppercentage1() {
        return (parseFloat(this.provisionalFinancialRecord.Provisions_for_exps_tax_etc__c ?  this.provisionalFinancialRecord.Provisions_for_exps_tax_etc__c : 0) - 
        parseFloat(this.currentFinancialRecord.Provisions_for_exps_tax_etc__c ?  this.currentFinancialRecord.Provisions_for_exps_tax_etc__c : 0)) / parseFloat(this.currentFinancialRecord.Provisions_for_exps_tax_etc__c ?  this.currentFinancialRecord.Provisions_for_exps_tax_etc__c : 0)
    }

    get DifftaxExppercentage() {
        return (parseFloat(this.currentFinancialRecord.Deffered_Tax_Liability_Assets__c ?  this.currentFinancialRecord.Deffered_Tax_Liability_Assets__c : 0) - 
        parseFloat(this.lastFinancialRecord.Deffered_Tax_Liability_Assets__c ?  this.lastFinancialRecord.Deffered_Tax_Liability_Assets__c : 0)) / parseFloat(this.lastFinancialRecord.Deffered_Tax_Liability_Assets__c ?  this.lastFinancialRecord.Deffered_Tax_Liability_Assets__c : 0)
    }

    get DifftaxExppercentage1() {
        return (parseFloat(this.provisionalFinancialRecord.Deffered_Tax_Liability_Assets__c ?  this.provisionalFinancialRecord.Deffered_Tax_Liability_Assets__c : 0) - 
        parseFloat(this.currentFinancialRecord.Deffered_Tax_Liability_Assets__c ?  this.currentFinancialRecord.Deffered_Tax_Liability_Assets__c : 0)) / parseFloat(this.currentFinancialRecord.Deffered_Tax_Liability_Assets__c ?  this.currentFinancialRecord.Deffered_Tax_Liability_Assets__c : 0)
    }

    get totWorthValue1() {
        return (parseFloat(this.lastFinancialRecord.Revaluation_Reserves_Notional_Reserves__c ? this.lastFinancialRecord.Revaluation_Reserves_Notional_Reserves__c : 0)) +
               this.recordNetWorthValue1 +
               parseFloat(this.lastFinancialRecord.unsecured_Loan_from_promoters_family_m__c  ?  this.lastFinancialRecord.unsecured_Loan_from_promoters_family_m__c : 0 ) +
               this.otherWorthValue1 + 
               parseFloat(this.lastFinancialRecord.Sundry_creditors__c  ?  this.lastFinancialRecord.Sundry_creditors__c : 0 ) +
               parseFloat(this.lastFinancialRecord.Advances_from_customers__c  ?  this.lastFinancialRecord.Advances_from_customers__c : 0 ) +
               parseFloat(this.lastFinancialRecord.Other_current_liabilities__c  ?  this.lastFinancialRecord.Other_current_liabilities__c : 0 ) +
               parseFloat(this.lastFinancialRecord.Provisions_for_exps_tax_etc__c  ?  this.lastFinancialRecord.Provisions_for_exps_tax_etc__c : 0 ) +
               parseFloat(this.lastFinancialRecord.Deffered_Tax_Liability_Assets__c  ?  this.lastFinancialRecord.Deffered_Tax_Liability_Assets__c : 0 );
        }

    get totWorthValue2() {
        return (parseFloat(this.currentFinancialRecord.Revaluation_Reserves_Notional_Reserves__c ? this.currentFinancialRecord.Revaluation_Reserves_Notional_Reserves__c : 0)) +
               this.recordNetWorthValue2 +
               parseFloat(this.currentFinancialRecord.unsecured_Loan_from_promoters_family_m__c  ?  this.currentFinancialRecord.unsecured_Loan_from_promoters_family_m__c : 0 ) +
               this.otherWorthValue2 + 
               parseFloat(this.currentFinancialRecord.Sundry_creditors__c  ?  this.currentFinancialRecord.Sundry_creditors__c : 0 ) +
               parseFloat(this.currentFinancialRecord.Advances_from_customers__c  ?  this.currentFinancialRecord.Advances_from_customers__c : 0 ) +
               parseFloat(this.currentFinancialRecord.Other_current_liabilities__c  ?  this.currentFinancialRecord.Other_current_liabilities__c : 0 ) +
               parseFloat(this.currentFinancialRecord.Provisions_for_exps_tax_etc__c  ?  this.currentFinancialRecord.Provisions_for_exps_tax_etc__c : 0 ) +
               parseFloat(this.currentFinancialRecord.Deffered_Tax_Liability_Assets__c  ?  this.currentFinancialRecord.Deffered_Tax_Liability_Assets__c : 0 );
    }

    get totWorthPercentage() {
        return ((this.totWorthValue2 ? this.totWorthValue2:0) - (this.totWorthValue1 ? this.totWorthValue1:0))/(this.totWorthValue1 ? this.totWorthValue1:0);
    }

    get totWorthValue3() {
        return (parseFloat(this.provisionalFinancialRecord.Revaluation_Reserves_Notional_Reserves__c ? this.provisionalFinancialRecord.Revaluation_Reserves_Notional_Reserves__c : 0)) +
               this.recordNetWorthValue3 +
               parseFloat(this.provisionalFinancialRecord.unsecured_Loan_from_promoters_family_m__c  ?  this.provisionalFinancialRecord.unsecured_Loan_from_promoters_family_m__c : 0 ) +
               this.otherWorthValue3 + 
               parseFloat(this.provisionalFinancialRecord.Sundry_creditors__c  ?  this.provisionalFinancialRecord.Sundry_creditors__c : 0 ) +
               parseFloat(this.provisionalFinancialRecord.Advances_from_customers__c  ?  this.provisionalFinancialRecord.Advances_from_customers__c : 0 ) +
               parseFloat(this.provisionalFinancialRecord.Other_current_liabilities__c  ?  this.provisionalFinancialRecord.Other_current_liabilities__c : 0 ) +
               parseFloat(this.provisionalFinancialRecord.Provisions_for_exps_tax_etc__c  ?  this.provisionalFinancialRecord.Provisions_for_exps_tax_etc__c : 0 ) +
               parseFloat(this.provisionalFinancialRecord.Deffered_Tax_Liability_Assets__c  ?  this.provisionalFinancialRecord.Deffered_Tax_Liability_Assets__c : 0 );
    }

    get totWorthPercentage1() {
        return ((this.totWorthValue3 ? this.totWorthValue3:0) - (this.totWorthValue2 ? this.totWorthValue2:0))/(this.totWorthValue2 ? this.totWorthValue2:0);
    }

    // get assetsPercentage() {
    //     return (parseFloat(this.currentFinancialRecord.Assets__c ?  this.currentFinancialRecord.Assets__c : 0) - 
    //     parseFloat(this.lastFinancialRecord.Assets__c ?  this.lastFinancialRecord.Assets__c: 0)) / parseFloat(this.currentFinancialRecord.Assets__c ?  this.currentFinancialRecord.Assets__c : 0)
    // }

    get nettangPercentage() {
        return (parseFloat(this.currentFinancialRecord.Net_Tangible_Fixed_Assets_Including_Cap__c ?  this.currentFinancialRecord.Net_Tangible_Fixed_Assets_Including_Cap__c : 0) - 
        parseFloat(this.lastFinancialRecord.Net_Tangible_Fixed_Assets_Including_Cap__c ?  this.lastFinancialRecord.Net_Tangible_Fixed_Assets_Including_Cap__c : 0)) / parseFloat(this.lastFinancialRecord.Net_Tangible_Fixed_Assets_Including_Cap__c ?  this.lastFinancialRecord.Net_Tangible_Fixed_Assets_Including_Cap__c : 0)
    }

    get nettangPercentage1() {
        return (parseFloat(this.provisionalFinancialRecord.Net_Tangible_Fixed_Assets_Including_Cap__c ?  this.provisionalFinancialRecord.Net_Tangible_Fixed_Assets_Including_Cap__c : 0) - 
        parseFloat(this.currentFinancialRecord.Net_Tangible_Fixed_Assets_Including_Cap__c ?  this.currentFinancialRecord.Net_Tangible_Fixed_Assets_Including_Cap__c : 0)) / parseFloat(this.currentFinancialRecord.Net_Tangible_Fixed_Assets_Including_Cap__c ?  this.currentFinancialRecord.Net_Tangible_Fixed_Assets_Including_Cap__c : 0)
    }

    get fixedLiapercentage() {
        return (parseFloat(this.currentFinancialRecord.Net_Intangible_Fixed_Assets__c ?  this.currentFinancialRecord.Net_Intangible_Fixed_Assets__c : 0) - 
        parseFloat(this.lastFinancialRecord.Net_Intangible_Fixed_Assets__c ?  this.lastFinancialRecord.Net_Intangible_Fixed_Assets__c : 0)) / parseFloat(this.lastFinancialRecord.Net_Intangible_Fixed_Assets__c ?  this.lastFinancialRecord.Net_Intangible_Fixed_Assets__c : 0)
    }

    get fixedLiapercentage1() {
        return (parseFloat(this.provisionalFinancialRecord.Net_Intangible_Fixed_Assets__c ?  this.provisionalFinancialRecord.Net_Intangible_Fixed_Assets__c : 0) - 
        parseFloat(this.currentFinancialRecord.Net_Intangible_Fixed_Assets__c ?  this.currentFinancialRecord.Net_Intangible_Fixed_Assets__c : 0)) / parseFloat(this.currentFinancialRecord.Net_Intangible_Fixed_Assets__c ?  this.currentFinancialRecord.Net_Intangible_Fixed_Assets__c : 0)
    }

    get stockppercentage() {
        return (parseFloat(this.currentFinancialRecord.Stock__c ?  this.currentFinancialRecord.Stock__c : 0) - 
        parseFloat(this.lastFinancialRecord.Stock__c ?  this.lastFinancialRecord.Stock__c : 0)) / parseFloat(this.lastFinancialRecord.Stock__c ?  this.lastFinancialRecord.Stock__c : 0)
    }

    get stockppercentage1() {
        return (parseFloat(this.provisionalFinancialRecord.Stock__c ?  this.provisionalFinancialRecord.Stock__c : 0) - 
        parseFloat(this.currentFinancialRecord.Stock__c ?  this.currentFinancialRecord.Stock__c : 0)) / parseFloat(this.currentFinancialRecord.Stock__c ?  this.currentFinancialRecord.Stock__c : 0)
    }

    get debtorsExppercentage() {
        return (parseFloat(this.currentFinancialRecord.Debtors__c ?  this.currentFinancialRecord.Debtors__c : 0) - 
        parseFloat(this.lastFinancialRecord.Debtors__c ?  this.lastFinancialRecord.Debtors__c : 0)) / parseFloat(this.lastFinancialRecord.Debtors__c ?  this.lastFinancialRecord.Debtors__c : 0)
    }

    get debtorsExppercentage1() {
        return (parseFloat(this.provisionalFinancialRecord.Debtors__c ?  this.provisionalFinancialRecord.Debtors__c : 0) - 
        parseFloat(this.currentFinancialRecord.Debtors__c ?  this.currentFinancialRecord.Debtors__c : 0)) / parseFloat(this.currentFinancialRecord.Debtors__c ?  this.currentFinancialRecord.Debtors__c : 0)
    }

    get sixmonthPercentage() {
        return (parseFloat(this.currentFinancialRecord.LessSix_months__c ?  this.currentFinancialRecord.LessSix_months__c : 0) - 
        parseFloat(this.lastFinancialRecord.LessSix_months__c ?  this.lastFinancialRecord.LessSix_months__c: 0)) / parseFloat(this.lastFinancialRecord.LessSix_months__c ?  this.lastFinancialRecord.LessSix_months__c : 0)
    }

    get sixmonthPercentage1() {
        return (parseFloat(this.provisionalFinancialRecord.LessSix_months__c ?  this.provisionalFinancialRecord.LessSix_months__c : 0) - 
        parseFloat(this.currentFinancialRecord.LessSix_months__c ?  this.currentFinancialRecord.LessSix_months__c: 0)) / parseFloat(this.currentFinancialRecord.LessSix_months__c ?  this.currentFinancialRecord.LessSix_months__c : 0)
    }

    get Greaterthan6months() {
        return (parseFloat(this.currentFinancialRecord.Greaterthan6__c ?  this.currentFinancialRecord.Greaterthan6__c : 0) - 
        parseFloat(this.lastFinancialRecord.Greaterthan6__c ?  this.lastFinancialRecord.Greaterthan6__c: 0)) / parseFloat(this.lastFinancialRecord.Greaterthan6__c ?  this.lastFinancialRecord.Greaterthan6__c : 0)
    }

    get Greaterthan6months1() {
        return (parseFloat(this.provisionalFinancialRecord.Greaterthan6__c ?  this.provisionalFinancialRecord.Greaterthan6__c : 0) - 
        parseFloat(this.currentFinancialRecord.Greaterthan6__c ?  this.currentFinancialRecord.Greaterthan6__c: 0)) / parseFloat(this.currentFinancialRecord.Greaterthan6__c ?  this.currentFinancialRecord.Greaterthan6__c : 0)
    }

    get advsupPercentage() {
        return (parseFloat(this.currentFinancialRecord.Advances_to_Suppliers__c ?  this.currentFinancialRecord.Advances_to_Suppliers__c : 0) - 
        parseFloat(this.lastFinancialRecord.Advances_to_Suppliers__c ?  this.lastFinancialRecord.Advances_to_Suppliers__c : 0)) / parseFloat(this.lastFinancialRecord.Advances_to_Suppliers__c ?  this.lastFinancialRecord.Advances_to_Suppliers__c : 0)
    }

    get advsupPercentage1() {
        return (parseFloat(this.provisionalFinancialRecord.Advances_to_Suppliers__c ?  this.provisionalFinancialRecord.Advances_to_Suppliers__c : 0) - 
        parseFloat(this.currentFinancialRecord.Advances_to_Suppliers__c ?  this.currentFinancialRecord.Advances_to_Suppliers__c : 0)) / parseFloat(this.currentFinancialRecord.Advances_to_Suppliers__c ?  this.currentFinancialRecord.Advances_to_Suppliers__c : 0)
    }

    get invpercentage() {
        return (parseFloat(this.currentFinancialRecord.Investments__c ?  this.currentFinancialRecord.Investments__c : 0) - 
        parseFloat(this.lastFinancialRecord.Investments__c ?  this.lastFinancialRecord.Investments__c : 0)) / parseFloat(this.lastFinancialRecord.Investments__c ?  this.lastFinancialRecord.Investments__c : 0)
    }

    get invpercentage1() {
        return (parseFloat(this.provisionalFinancialRecord.Investments__c ?  this.provisionalFinancialRecord.Investments__c : 0) - 
        parseFloat(this.currentFinancialRecord.Investments__c ?  this.currentFinancialRecord.Investments__c : 0)) / parseFloat(this.currentFinancialRecord.Investments__c ?  this.currentFinancialRecord.Investments__c : 0)
    }

    get oLoanspercentage() {
        return (parseFloat(this.currentFinancialRecord.Other_loans_advances__c ?  this.currentFinancialRecord.Other_loans_advances__c : 0) - 
        parseFloat(this.lastFinancialRecord.Other_loans_advances__c ?  this.lastFinancialRecord.Other_loans_advances__c : 0)) / parseFloat(this.lastFinancialRecord.Other_loans_advances__c ?  this.lastFinancialRecord.Other_loans_advances__c : 0)
    }

    get oLoanspercentage1() {
        return (parseFloat(this.provisionalFinancialRecord.Other_loans_advances__c ?  this.provisionalFinancialRecord.Other_loans_advances__c : 0) - 
        parseFloat(this.currentFinancialRecord.Other_loans_advances__c ?  this.currentFinancialRecord.Other_loans_advances__c : 0)) / parseFloat(this.currentFinancialRecord.Other_loans_advances__c ?  this.currentFinancialRecord.Other_loans_advances__c : 0)
    }

    get prepaidpercentage() {
        return (parseFloat(this.currentFinancialRecord.Prepaid_expenses__c ?  this.currentFinancialRecord.Prepaid_expenses__c : 0) - 
        parseFloat(this.lastFinancialRecord.Prepaid_expenses__c ?  this.lastFinancialRecord.Prepaid_expenses__c : 0)) / parseFloat(this.lastFinancialRecord.Prepaid_expenses__c ?  this.lastFinancialRecord.Prepaid_expenses__c : 0)
    }

    get prepaidpercentage1() {
        return (parseFloat(this.provisionalFinancialRecord.Prepaid_expenses__c ?  this.provisionalFinancialRecord.Prepaid_expenses__c : 0) - 
        parseFloat(this.currentFinancialRecord.Prepaid_expenses__c ?  this.currentFinancialRecord.Prepaid_expenses__c : 0)) / parseFloat(this.currentFinancialRecord.Prepaid_expenses__c ?  this.currentFinancialRecord.Prepaid_expenses__c : 0)
    }

    get othercurrentassetspercentage() {
        return (parseFloat(this.currentFinancialRecord.Other_current_assets__c ?  this.currentFinancialRecord.Other_current_assets__c : 0) - 
        parseFloat(this.lastFinancialRecord.Other_current_assets__c ?  this.lastFinancialRecord.Other_current_assets__c : 0)) / parseFloat(this.lastFinancialRecord.Other_current_assets__c ?  this.lastFinancialRecord.Other_current_assets__c : 0)
    }

    get othercurrentassetspercentage1() {
        return (parseFloat(this.provisionalFinancialRecord.Other_current_assets__c ?  this.provisionalFinancialRecord.Other_current_assets__c : 0) - 
        parseFloat(this.currentFinancialRecord.Other_current_assets__c ?  this.currentFinancialRecord.Other_current_assets__c : 0)) / parseFloat(this.currentFinancialRecord.Other_current_assets__c ?  this.currentFinancialRecord.Other_current_assets__c : 0)
    }

    get currentExppercentage() {
        return (parseFloat(this.currentFinancialRecord.Other_Non_Current_assets_Security_Depos__c ?  this.currentFinancialRecord.Other_Non_Current_assets_Security_Depos__c : 0) - 
        parseFloat(this.lastFinancialRecord.Other_Non_Current_assets_Security_Depos__c ?  this.lastFinancialRecord.Other_Non_Current_assets_Security_Depos__c : 0)) / parseFloat(this.lastFinancialRecord.Other_Non_Current_assets_Security_Depos__c ?  this.lastFinancialRecord.Other_Non_Current_assets_Security_Depos__c : 0)
    }

    get currentExppercentage1() {
        return (parseFloat(this.provisionalFinancialRecord.Other_Non_Current_assets_Security_Depos__c ?  this.provisionalFinancialRecord.Other_Non_Current_assets_Security_Depos__c : 0) - 
        parseFloat(this.currentFinancialRecord.Other_Non_Current_assets_Security_Depos__c ?  this.currentFinancialRecord.Other_Non_Current_assets_Security_Depos__c : 0)) / parseFloat(this.currentFinancialRecord.Other_Non_Current_assets_Security_Depos__c ?  this.currentFinancialRecord.Other_Non_Current_assets_Security_Depos__c : 0)
    }

    get balancespercentage() {
        return (parseFloat(this.currentFinancialRecord.Cash_Bank_Balances__c ?  this.currentFinancialRecord.Cash_Bank_Balances__c : 0) - 
        parseFloat(this.lastFinancialRecord.Cash_Bank_Balances__c ?  this.lastFinancialRecord.Cash_Bank_Balances__c : 0)) / parseFloat(this.lastFinancialRecord.Cash_Bank_Balances__c ?  this.lastFinancialRecord.Cash_Bank_Balances__c : 0)
    }

    get balancespercentage1() {
        return (parseFloat(this.provisionalFinancialRecord.Cash_Bank_Balances__c ?  this.provisionalFinancialRecord.Cash_Bank_Balances__c : 0) - 
        parseFloat(this.currentFinancialRecord.Cash_Bank_Balances__c ?  this.currentFinancialRecord.Cash_Bank_Balances__c : 0)) / parseFloat(this.currentFinancialRecord.Cash_Bank_Balances__c ?  this.currentFinancialRecord.Cash_Bank_Balances__c : 0)
    }

    get allTotalValue1() {
        return (parseFloat(this.lastFinancialRecord.Adavces_to_group_co_friends__c  ?  this.lastFinancialRecord.Adavces_to_group_co_friends__c : 0)+ 
        parseFloat(this.lastFinancialRecord.Net_Tangible_Fixed_Assets_Including_Cap__c  ?  this.lastFinancialRecord.Net_Tangible_Fixed_Assets_Including_Cap__c : 0 )) +
        (parseFloat(this.lastFinancialRecord.Net_Intangible_Fixed_Assets__c  ?  this.lastFinancialRecord.Net_Intangible_Fixed_Assets__c : 0 )) +
        (parseFloat(this.lastFinancialRecord.Stock__c  ?  this.lastFinancialRecord.Stock__c : 0 )) +
        (parseFloat(this.lastFinancialRecord.LessSix_months__c  ?  this.lastFinancialRecord.LessSix_months__c : 0)+ 
        parseFloat(this.lastFinancialRecord.Advances_to_Suppliers__c  ?  this.lastFinancialRecord.Advances_to_Suppliers__c : 0 )) +
        (parseFloat(this.lastFinancialRecord.Other_loans_advances__c  ?  this.lastFinancialRecord.Other_loans_advances__c : 0 )) +
        (parseFloat(this.lastFinancialRecord.Prepaid_expenses__c  ?  this.lastFinancialRecord.Prepaid_expenses__c : 0 )) +
        (parseFloat(this.lastFinancialRecord.Other_Non_Current_assets_Security_Depos__c  ?  this.lastFinancialRecord.Other_Non_Current_assets_Security_Depos__c : 0 )) +
        (parseFloat(this.lastFinancialRecord.Cash_Bank_Balances__c  ?  this.lastFinancialRecord.Cash_Bank_Balances__c : 0 )) +
        (parseFloat(this.lastFinancialRecord.Investments__c  ?  this.lastFinancialRecord.Investments__c : 0 ))+
        (parseFloat(this.lastFinancialRecord.Greaterthan6__c  ?  this.lastFinancialRecord.Greaterthan6__c : 0 ))+
        (parseFloat(this.lastFinancialRecord.Other_current_assets__c  ?  this.lastFinancialRecord.Other_current_assets__c : 0 ));
    }

    get allTotalValue2() {
        return (parseFloat(this.currentFinancialRecord.Adavces_to_group_co_friends__c  ?  this.currentFinancialRecord.Adavces_to_group_co_friends__c : 0)+ 
        parseFloat(this.currentFinancialRecord.Net_Tangible_Fixed_Assets_Including_Cap__c  ?  this.currentFinancialRecord.Net_Tangible_Fixed_Assets_Including_Cap__c : 0 )) +
        (parseFloat(this.currentFinancialRecord.Net_Intangible_Fixed_Assets__c  ?  this.currentFinancialRecord.Net_Intangible_Fixed_Assets__c : 0 )) +
        (parseFloat(this.currentFinancialRecord.Stock__c  ?  this.currentFinancialRecord.Stock__c : 0 )) +
        (parseFloat(this.currentFinancialRecord.LessSix_months__c  ?  this.currentFinancialRecord.LessSix_months__c : 0)+ 
        parseFloat(this.currentFinancialRecord.Advances_to_Suppliers__c  ?  this.currentFinancialRecord.Advances_to_Suppliers__c : 0 )) +
        (parseFloat(this.currentFinancialRecord.Other_loans_advances__c  ?  this.currentFinancialRecord.Other_loans_advances__c : 0 )) +
        (parseFloat(this.currentFinancialRecord.Prepaid_expenses__c  ?  this.currentFinancialRecord.Prepaid_expenses__c : 0 )) +
        (parseFloat(this.currentFinancialRecord.Other_Non_Current_assets_Security_Depos__c  ?  this.currentFinancialRecord.Other_Non_Current_assets_Security_Depos__c : 0 )) +
        (parseFloat(this.currentFinancialRecord.Cash_Bank_Balances__c  ?  this.currentFinancialRecord.Cash_Bank_Balances__c : 0 )) +
        (parseFloat(this.currentFinancialRecord.Investments__c  ?  this.currentFinancialRecord.Investments__c : 0 ))+
        (parseFloat(this.currentFinancialRecord.Greaterthan6__c  ?  this.currentFinancialRecord.Greaterthan6__c : 0 ))+
        (parseFloat(this.currentFinancialRecord.Other_current_assets__c  ?  this.currentFinancialRecord.Other_current_assets__c : 0 ));
    }

    get allTotalValue3() {
        return (parseFloat(this.provisionalFinancialRecord.Adavces_to_group_co_friends__c  ?  this.provisionalFinancialRecord.Adavces_to_group_co_friends__c : 0)+ 
        parseFloat(this.provisionalFinancialRecord.Net_Tangible_Fixed_Assets_Including_Cap__c  ?  this.provisionalFinancialRecord.Net_Tangible_Fixed_Assets_Including_Cap__c : 0 )) +
        (parseFloat(this.provisionalFinancialRecord.Net_Intangible_Fixed_Assets__c  ?  this.provisionalFinancialRecord.Net_Intangible_Fixed_Assets__c : 0 )) +
        (parseFloat(this.provisionalFinancialRecord.Stock__c  ?  this.provisionalFinancialRecord.Stock__c : 0 )) +
        (parseFloat(this.provisionalFinancialRecord.LessSix_months__c  ?  this.provisionalFinancialRecord.LessSix_months__c : 0)+ 
        parseFloat(this.provisionalFinancialRecord.Advances_to_Suppliers__c  ?  this.provisionalFinancialRecord.Advances_to_Suppliers__c : 0 )) +
        (parseFloat(this.provisionalFinancialRecord.Other_loans_advances__c  ?  this.provisionalFinancialRecord.Other_loans_advances__c : 0 )) +
        (parseFloat(this.provisionalFinancialRecord.Prepaid_expenses__c  ?  this.provisionalFinancialRecord.Prepaid_expenses__c : 0 )) +
        (parseFloat(this.provisionalFinancialRecord.Other_Non_Current_assets_Security_Depos__c  ?  this.provisionalFinancialRecord.Other_Non_Current_assets_Security_Depos__c : 0 )) +
        (parseFloat(this.provisionalFinancialRecord.Cash_Bank_Balances__c  ?  this.provisionalFinancialRecord.Cash_Bank_Balances__c : 0 )) +
        (parseFloat(this.provisionalFinancialRecord.Investments__c  ?  this.provisionalFinancialRecord.Investments__c : 0 ))+
        (parseFloat(this.provisionalFinancialRecord.Greaterthan6__c  ?  this.provisionalFinancialRecord.Greaterthan6__c : 0 ))+
        (parseFloat(this.provisionalFinancialRecord.Other_current_assets__c  ?  this.provisionalFinancialRecord.Other_current_assets__c : 0 ));
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
        return false;
    }


    @track provisionalFinancialYearOptions = [];
    @track provisionalFinancialYearSelectionValue;
}