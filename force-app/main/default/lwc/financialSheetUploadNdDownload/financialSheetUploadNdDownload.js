import { LightningElement,api,track,wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import SheetJS1 from '@salesforce/resourceUrl/SheetJS1';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import FINANCIAL_OBJECT from '@salesforce/schema/Applicant_Financial__c';
import { refreshApex } from '@salesforce/apex';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import getSobjectDataNonCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable';
import getMetadataForProfit from '@salesforce/apex/ExcelUploadNdDownForFinancial.getMetadataForProfit';
import getMetadataForProfitTab2 from '@salesforce/apex/ExcelUploadNdDownForFinancial.getMetadataForProfitTab2';
import jsonExcelMetadataForAppliDetail from '@salesforce/apex/ExcelDataToJsonApexClass.MetadataForAppliBankDetail';
export default class FinancialSheetUploadNdDownload extends LightningElement {
    @api hasEditAccess;
    @api layoutSize;
    @track uploadedExcFile;
    @track uploadedFiles=[];
    @track showSpinner;
    @track _applicantId;
    @track recordTypeIdForBalanceSheet;
    @track recordTypeIdForProfitLoss;
    @api showUploadComp
    //@api provisionalYear
    //@api currentYear
    //@api privousYear
    @api provFinYearSeleValue
    @api incrementdecrement
    @api incrementdecrementPro
    @track _provisionalOption
    @api get provisionalOption() {
        return this._provisionalOption;
    }
    set provisionalOption(value) {
        this._provisionalOption = value;
        console.log('this._provisionalOption'+this._provisionalOption)
        this.setAttribute("provisionalOption", value);
        this.checkProvisionalOptionValue();
        this.checkMinMaxProvisionalYear();
    }
    maxprivousYear
    minprivousYear
    maxcurrentyear
    mincurrentyear

    get privousYear() {
        if (this._currentBlock) {
            let [previousfirstPart, previoussecondPart] = this._currentBlock.split('-');
            previousfirstPart = parseInt(previousfirstPart);
            previoussecondPart = parseInt(previoussecondPart);
            const previousYear = `${previousfirstPart - 1}-${previoussecondPart - 1}`;
            this.minprivousYear = (previoussecondPart - 1) + '-04' + '-01';
            var todayDate = new Date();
            var yearValue = (todayDate.getFullYear());
            var monthValue = String(todayDate.getMonth() + 1).padStart(2, '0'); 
            var dayValue = String(todayDate.getDate()).padStart(2, '0');
            const formattedDate = `${yearValue}-${monthValue}-${dayValue}`;
            this.maxprivousYear = formattedDate;

            return previousYear;
        } else {
            return null;
        }
    }

    get currentYear() {
        if (this._currentBlock) {
            let [currentfirstPart, currentsecondPart] = this._currentBlock.split('-');
            currentfirstPart = parseInt(currentfirstPart);
            currentsecondPart = parseInt(currentsecondPart);
            const financialYear = `${currentfirstPart}-${currentsecondPart}`;
            this.mincurrentyear = currentsecondPart + '-04' + '-01';
            var todayDate = new Date();
            var yearValue = (todayDate.getFullYear());
            var monthValue = String(todayDate.getMonth() + 1).padStart(2, '0'); 
            var dayValue = String(todayDate.getDate()).padStart(2, '0');
            const formattedDate = `${yearValue}-${monthValue}-${dayValue}`;
            this.maxcurrentyear = formattedDate;
            return financialYear;
        } else {
            return null;
        }
    }
    _provisionalYear
    @api get provisionalYear() {
        return this._provisionalYear;
    }
    set provisionalYear(value) {
        this._provisionalYear = value;
        this.setAttribute("provisionalYear", value);
        console.log('this._provisionalYear'+this._provisionalYear)
        this.checkProvisionalOptionValue();
        this.checkMinMaxProvisionalYear();
    }
    checkProvisionalOptionValue() {
        if (this._provisionalYear && this._provisionalOption && this._provisionalOption === 'Yes') {
            console.log('inifffff'+this._provisionalYear +'>>>>>>>>'+this._provisionalOption)
            this.provisionalFinancialYearSelectionValue = true;
            this.selectedYear = this._provisionalYear;
            this.provFinYearSeleValue=true
            this.handleApplicantIdChange(null);
        } else {
            console.log('inelseeeeee'+this._provisionalYear +'>>>>>>>>'+this._provisionalOption)
            this.provFinYearSeleValue=false
            this.provisionalFinancialYearSelectionValue = false;
            
        }
    }
    checkMinMaxProvisionalYear() {
        if (this._provisionalYear) {
            let [upcomingfirstPart, upcomingsecondPart] = this._provisionalYear.split('-');
            upcomingfirstPart = parseInt(upcomingfirstPart);
            upcomingsecondPart = parseInt(upcomingsecondPart);
            const upcomingFinancialYear = `${(upcomingfirstPart + 1)}-${(upcomingsecondPart + 1)}`;
            this.minprovisionalYear = (upcomingsecondPart + 1) + '-04' + '-01';
            this.maxprovisionalYear = (upcomingsecondPart + 1) + '-12' + '-31';
            return upcomingFinancialYear;
        } else {
            return null;
        }
    }



    _currentBlock
    @api get currentBlock() {
        return this._currentBlock;
    }set currentBlock(value) {
        this._currentBlock = value;
        this.setAttribute('currentBlock', value);
        this.handleApplicantIdChange(value)
    }
    @api get applicantId() {
        return this._applicantId;
    }
    set applicantId(value) {
        this._applicantId = value;
        this.setAttribute("applicantId", value);
        this.handleApplicantIdChange(value);
    }
    @track _loanAppId;
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);
    }
    handleApplicantIdChange(value) {
        let tempParams = this.financialParamsForBal;
        tempParams.queryCriteria = ' where Loan_Applicant__c = \'' + this._applicantId + '\' AND RecordType.name = \'Balance Sheet\''
        this.financialParamsForBal = { ...tempParams };

        let tempParams1 = this.financialParamsForProfit;
        tempParams.queryCriteria = ' where Loan_Applicant__c = \'' + this._applicantId + '\' AND RecordType.name = \'Profit & Loss\''
        this.financialParamsForProfit = { ...tempParams };
    }
    @track financialParamsForBal = {
        ParentObjectName: 'Applicant_Financial__c ',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Name', 'Income_Documents__c', 'Loan_Applicant__c', 'RecordType.name'],
        childObjFields: [],
        queryCriteria: ' where Loan_Applicant__c = \'' + this._applicantId + '\' AND RecordType.name = \'Balance Sheet\''
    }
    @track financialParamsForProfit = {
        ParentObjectName: 'Applicant_Financial__c ',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Name', 'Income_Documents__c', 'Loan_Applicant__c', 'RecordType.name'],
        childObjFields: [],
        queryCriteria: ' where Loan_Applicant__c = \'' + this._applicantId + '\' AND RecordType.name = \'Profit & Loss\''
    }
    @track summaryParams = {
        ParentObjectName: 'Applicant_Financial_Summary__c ',
        ChildObjectRelName: null,
        parentObjFields: ['Id','Provisional_Financial_Year__c','Previous_Financial_Year__c','Current_Financial_Year__c', 'Share_capital_Partner_s_Capital__c', 'P_L_A_capital__c', 'Revaluation_Reserves_Notional_Reserves__c',
        'Net_worth__c', 'Adavces_to_group_co_friends__c', 'unsecured_Loan_from_promoters_family_m__c', 'Misc_Exp_Not_written_off__c',
        'Adjusted_tangible_Netwroth__c', 'Bank_Borrowing_Working_Capital_OD_CC__c', 'Secured_debts_Banks_Ndfc__c', 'Unsecured_debts_Banks_Ndfc__c',
        'Other_Loans_From_private_parties__c', 'Total_Loan_funds__c', 'Sundry_creditors__c', 'Advances_from_customers__c','Other_current_liabilities__c',
        'Provisions_for_exps_tax_etc__c', 'Deffered_Tax_Liability_Assets__c', 'Net_Tangible_Fixed_Assets_Including_Cap__c',
        'Net_Intangible_Fixed_Assets__c', 'Stock__c', 'Debtors__c', 'LessSix_months__c','Greaterthan6__c', 'Advances_to_Suppliers__c','Investments__c','Other_loans_advances__c',
        'Prepaid_expenses__c', 'Other_current_assets__c', 'Other_Non_Current_assets_Security_Depos__c', 'Cash_Bank_Balances__c','Bank_Balances__c','Total__c',
        'Difference__c', 'Applicant_Financial__c','Applicant_Financial__r.RecordTypeId','Applicant_Financial__r.RecordType.DeveloperName',
        'Applicant_Financial__r.Loan_Applicant__c', 'Financial_Year__c', 'Liabilities_Remarks__c',	'Share_capital_Remarks__c',	'Gross_Profit_Remark__c',
        'Reevaluation_Remark__c','Advances_Remarks__c','Unsecured_Loan_Remarks__c','Other_Indirect_Expenses_Remark__c','Borrowing_Remarks__c',	
        'Secured_Remarks__c',	'Unsecured_Remarks__c',	'Other_Operating_Income_Remark__c',	'Sundry_Remarks__c', 'Purchases_Remark__c',	'Total_Loan_Remarks__c', 
        'Taxes_Remark__c',	'Deferred_Tax_Liability_Remark__c',	'Assets_Remarks__c','Adjustable_Remarks__c','Profit_Before_Tax_Remark__c',	'Opening_Stock_Remark__c',	
        'EBITDA_Remark__c','Less_Six_Months_Remarks__c','Greater_Six_Months_Remarks__c','Office_Administrative_Expenses_Remark__c',	
        'Non_Operating_Expenses_Remark__c',	'Profit_Before_Depreciation_PBDT_Remark__c',	'Direct_Expenses_Remark__c','Depreciation_Remark__c',	
        'Interest_on_CC_OD_limits_Remark__c','PAT_Remark__c', 'Comments_on_Balance_sheet__c'],
        childObjFields: [],
        queryCriteria: ' where Applicant_Financial__c = \'' + this.financialRecordIdForBal + '\''
    }
    @track summaryParamsforProfit = {
        ParentObjectName: 'Applicant_Financial_Summary__c ',
        ChildObjectRelName: null,
        parentObjFields: ['Id','ExportSalesOutOfAboveSalesRemark__c','ExportSalesOutOfAboveSales__c','Income_addition_u_s_40_a_2_b__c','Tax_on_the_above_inc_for_Addition__c','Net_inc_con_for_Eligibility_for_add_Inc__c', 'Type_of_Accounts__c','Provisional_Financial_Year__c','Current_Financial_Year__c','Previous_Financial_Year__c', 'Financial_Year__c', 'Date_of_Filing_ITR__c', 'Total_Sales__c', 'Other_Operating_Income_IncomeIncidental__c', 'Non_Operating_Income__c', 'Non_Business_Income__c', 'Opening_Stock__c', 'Closing_Stock__c', 'Purchases__c', 'Direct_Expenses__c', 'Gross_Profit__c', 'Office_Administrative_Expenses__c', 'Other_Indirect_Expenses__c', 'Non_Operating_Expenses_FxLoss_AssetLoss__c', 'Salary_to_Partner_Directors__c', 'EBITDA__c', 'Interest_on_Term_Loans__c', 'Interest_on_CC_OD_limits__c', 'Interest_on_Partner_Capital__c', 'Profit_Before_Depreciation_and_Tax_PBDT__c', 'Depreciation__c', 'Profit_Before_Tax__c', 'Taxes__c', 'PAT__c', 'Director_Partners_remuneration_Interest__c', 'Tax_on_Above_Income__c', 'Net_Income_Considered_for_Eligibility__c', 'Applicant_Financial__c', 'Total_Sales_Remark__c', 'Other_Operating_Income_Remark__c', 'Non_Operating_Income_Remark__c', 'Non_Business_Income_Remark__c', 'Opening_Stock_Remark__c', 'Closing_Stock_Remark__c', 'Purchases_Remark__c', 'Direct_Expenses_Remark__c', 'Gross_Profit_Remark__c', 'Office_Administrative_Expenses_Remark__c', 'Other_Indirect_Expenses_Remark__c', 'Non_Operating_Expenses_Remark__c', 'Salary_to_Partner_Directors_Remark__c', 'EBITDA_Remark__c', 'Interest_on_Term_Loans_Remark__c', 'Interest_on_CC_OD_limits_Remark__c', 'Interest_on_Partner_Capital_Remark__c', 'Profit_Before_Depreciation_PBDT_Remark__c', 'Depreciation_Remark__c', 'Profit_Before_Tax_Remark__c', 'Taxes_Remark__c', 'PAT_Remark__c', 'Comments_on_Profit_Loss__c', 'ITR_Filing_Gap_Days__c'],
        childObjFields: [],
        queryCriteria: ' where Applicant_Financial__c = \'' + this.finRecordIdForProfit + '\''
    }

   // ' where LoanApplication__c= \'' + this.loanAppId + '\' AND Source__c = \'Manual\' AND RecordType.name = \'Consumer Obligation\'';
    async connectedCallback(){
        await loadScript(this, SheetJS1); // load the library
        // At this point, the library is accessible with the `XLSX` variable
        this.version = XLSX.version;
        console.log('version: '+this.version);  
        this.activeSection = ["A", "C"];
        if(this.hasEditAccess === false){
            this.disableMode = true;
        }else{
            this.disableMode = false;
        }
        
        /*if(this.showUploadComp==false){
            this.downloadExcelFile();
        }*/
    }
    data;

    @api downloadExcelFile(){
       /* console.log('this.privousYear'+this.privousYear)
        console.log('this.currentYear'+this.currentYear)
        console.log('this.provFinYearSeleValue'+this.provFinYearSeleValue)*/
        this.getFinSummRecordForProfit()
        this.getFinSummRecordForBal()
        let blankRec={"Financials Years Data":"","__EMPTY":"","__EMPTY_1":"","__EMPTY_2":"","__EMPTY_3":"","__EMPTY_4":"","__EMPTY_5":""}
        setTimeout(() => {
        if(this.provFinYearSeleValue){
            console.log('iniffff')
            var firstColumn=Object.keys(this.columnMapWithFieldForProfit);
                //console.log('firstColumn'+firstColumn)
                //console.log(this.columnMapWithFieldForProfit[firstColumn[0]])
                this.data = [
                    {"Financials Years Data":"Financial Year","__EMPTY":this.privousYear,"__EMPTY_1":this.currentYear,"__EMPTY_2":this.provisionalYear,"__EMPTY_3":"","__EMPTY_4":"","__EMPTY_5":""},
                    {"Financials Years Data":"Type of Accounts","__EMPTY":this.previousRecForProfit.Type_of_Accounts__c,"__EMPTY_1":this.currentRecForProfit.Type_of_Accounts__c,"__EMPTY_2":"Provisional","__EMPTY_3":"","__EMPTY_4":"","__EMPTY_5":""},
                    {"Financials Years Data":"Date of Filing ITR (DD-MMM-YYYY)","__EMPTY":this.previousRecForProfit.Date_of_Filing_ITR__c,"__EMPTY_1":this.currentRecForProfit.Date_of_Filing_ITR__c,"__EMPTY_3":this.currentRecForProfit.ITR_Filing_Gap_Days__c,"__EMPTY_4":"ITR filing Gap Days","__EMPTY_5":""},
                    {"Financials Years Data":"Profit & Loss A/c", "__EMPTY_2":"Inc/dec%", "__EMPTY_3":this.provisionalYear,"__EMPTY_4":"Inc/dec%", "__EMPTY_5": "Remarks"},
                    ]
                for(let i=0; i<firstColumn.length; i++){
                    var firstVal=this.columnMapWithFieldForProfit[firstColumn[i]][0];
                   var SecVal=this.columnMapWithFieldForProfit[firstColumn[i]][1];
                    var newRow= {"Financials Years Data":firstColumn[i],"__EMPTY":this.previousRecForProfit[firstVal],"__EMPTY_1":this.currentRecForProfit[firstVal],"__EMPTY_2":0,"__EMPTY_3":this.proviRecForProfit[firstVal],"__EMPTY_4":0,"__EMPTY_5":this.currentRecForProfit[SecVal]}
                    this.data.push(newRow);
                }
                let line29Rec={"Financials Years Data":"Financial Year","__EMPTY":this.privousYear, "__EMPTY_1":this.currentYear,"__EMPTY_2":this.provisionalYear}
                this.data.push(line29Rec)
                var firstColumnForTable2=Object.keys(this.columnMapFieldForProfitTab2);
                for(let i=0; i<firstColumnForTable2.length; i++){
                    var firstVal=this.columnMapFieldForProfitTab2[firstColumnForTable2[i]][0];
                    var newRow= {"Financials Years Data":firstColumnForTable2[i],"__EMPTY":this.previousRecForProfit[firstVal],"__EMPTY_1":this.currentRecForProfit[firstVal],"__EMPTY_2":this.proviRecForProfit[firstVal]}
                    this.data.push(newRow);
                    
                }
                this.data.push(blankRec)

                var firstColumnForTable3=Object.keys(this.columnMapWithFieldForTab3Pro);
                for(let i=0; i<firstColumnForTable3.length; i++){
                    var firstVal=this.columnMapWithFieldForTab3Pro[firstColumnForTable3[i]][0];
                    var newRow= {"Financials Years Data":firstColumnForTable3[i],"__EMPTY":this.previousRecForProfit[firstVal],"__EMPTY_1":this.currentRecForProfit[firstVal],"__EMPTY_2":this.proviRecForProfit[firstVal]}
                    this.data.push(newRow);
                    
                }
                this.data.push(blankRec)
                let line34Rec={"Financials Years Data":"Balance Sheet"}
                let line35Rec={"Financials Years Data":"Financial Year","__EMPTY":this.privousYear,"__EMPTY_1":this.currentYear,"__EMPTY_2":"Inc/dec%", "__EMPTY_3":this.provisionalYear,"__EMPTY_4":"Inc/dec%", "__EMPTY_5": "Remarks"}
                let line36Rec={"Financials Years Data":"Liabilities"}
                this.data.push(line34Rec)
                this.data.push(line35Rec)
                this.data.push(line36Rec)
                var firstColumnForBala=Object.keys(this.columnMapWithFieldForBala);
                for(let i=0; i<firstColumnForBala.length; i++){
                    var firstVal=this.columnMapWithFieldForBala[firstColumnForBala[i]][0];
                    var SecVal=this.columnMapWithFieldForBala[firstColumnForBala[i]][1];
                    var newRow= {"Financials Years Data":firstColumnForBala[i],"__EMPTY":this.previousFinanYearBalRec[firstVal],"__EMPTY_1":this.currentFinanYearBalRec[firstVal],"__EMPTY_2":0,"__EMPTY_3":this.proviFinanYearBalRec[firstVal],"__EMPTY_4":0,"__EMPTY_5":this.currentFinanYearBalRec[SecVal]}
                    
                    this.data.push(newRow);
                    
                }
              //  console.log('iniffff1555')
                var recTotal={"Financials Years Data":"Total","__EMPTY":"","__EMPTY_1":"","__EMPTY_2":0,"__EMPTY_3":"","__EMPTY_4":0,"__EMPTY_5":""}
                this.data.push(recTotal);
                let line56Rec={"Financials Years Data":"Asset"}
                this.data.push(line56Rec);
                //for loop
               // console.log('iniffff6')
                var firstColumnForAsset=Object.keys(this.columnMapWithFieldForAsset);
                console.log('firstColumnForAsset'+firstColumnForAsset)
                for(let i=0; i<firstColumnForAsset.length; i++){
                    var firstVal=this.columnMapWithFieldForAsset[firstColumnForAsset[i]][0];
                    var SecVal=this.columnMapWithFieldForAsset[firstColumnForAsset[i]][1];
                    console.log('this.previousFinanYearBalRec[firstVal]'+this.previousFinanYearBalRec[firstVal])
                    var newRow= {"Financials Years Data":firstColumnForAsset[i],"__EMPTY":this.previousFinanYearBalRec[firstVal],"__EMPTY_1":this.currentFinanYearBalRec[firstVal],"__EMPTY_2":0,"__EMPTY_3":this.proviFinanYearBalRec[firstVal],"__EMPTY_4":0,"__EMPTY_5":this.currentFinanYearBalRec[SecVal]}
                    console.log('newRownewRow'+JSON.stringify(newRow))
                    this.data.push(newRow);
                    
                }
                
                /*this.data.push(blankRec)
                let rec79={"Financials Years Data":"Financial ratio analysis (in lakhs)","__EMPTY":"","__EMPTY_1":"","__EMPTY_2":"","__EMPTY_3":"","__EMPTY_4":"","__EMPTY_5":""}
                this.data.push(rec79);
                let line80Rec={"Financials Years Data":"Particulars","__EMPTY":this.privousYear,"__EMPTY_1":this.currentYear, "__EMPTY_2":this.provisionalYear}
                this.data.push(line80Rec);
                let listForThirdTable= ['Turnover','Turnover growth rate', 'EBIDTA/PBDIT','PBDT','PBT','PAT','Cash profit','Gross Profit margin','Net profit Margin','Total Current liabilities','Total current assets','Total Debt','Adjusted Net worth'];
                for(const livar of listForThirdTable){
                    let recForthird={"Financials Years Data":livar,"__EMPTY":"","__EMPTY_1":""}
                    this.data.push(recForthird);
                }
                let rec89={"Financials Years Data":"Working Capital Analysis (In lakhs)","__EMPTY":"","__EMPTY_1":"","__EMPTY_2":"","__EMPTY_3":"","__EMPTY_4":"","__EMPTY_5":""}
                this.data.push(rec89);
                this.data.push(line80Rec);
                let listForWorkCap= ['Debtors','Creditors','Stock Value','Debtors Collection period (Days)','Creditors payment period (Days)','Stock replenishment period (days)','Inventory Turnover', 'Net working Capital','Current ratio','Quick ratio','Interest coverage ratio','Debt Equity Ratio','Leverage Ratio (TOL/ATNW)','MUE (including proposed loan)','MUE / Last 12Months GST TO'];
                for(const livar of listForWorkCap){
                    let recForthird={"Financials Years Data":livar,"__EMPTY":"","__EMPTY_1":""}
                    this.data.push(recForthird);
                }*/


                const worksheet = XLSX.utils.json_to_sheet(this.data);
               // console.log('111>>>>>>>>>>>>>>>>')
                worksheet["A1"].v = "Financials Years Data"; // Change A1 cell (Name column header)
                worksheet["B1"].v = ""; // Change B1 cell (Age column header)
                worksheet["C1"].v = "";
                worksheet["D1"].v = "";
                worksheet["E1"].v = ""; // Change E1 cell
                worksheet["F1"].v = ""; // Change F1 cell
                worksheet["G1"].v = "";
                const merge = [
                    { s: { r: 0, c: 0 }, e: { r: 0, c: 5 } },{ s: { r: 4, c: 0 }, e: { r: 4, c: 2 } }, { s: { r: 38, c: 0 }, e: { r: 38, c: 2 } }];
                  worksheet["!merges"] = merge;
                  /*const headerRow = worksheet.getRow(1); // Assuming headers are in the first row

                  headerRow.eachCell((cell) => {
                      cell.font = { bold: true };
                  });*/
                  //worksheet.getCell('A8').font = { bold: true };

                  
                const formulaD4 = `IF(B4<>"",C4-B4,"")`;
                const columnD4 = `E4`;
                worksheet[columnD4] = { t: "n", f: formulaD4 };

                const formula1 = `(C6 + C7) - (C11 + C13 + C14 - C12)`;
                const columnC15 = `C15`;
                worksheet[columnC15] = { t: "n", f: formula1 };
                const formulb1 = `(B6 + B7) - (B11 + B13 + B14 - B12)`;
                const columnB15 = `B15`;
                worksheet[columnB15] = { t: "n", f: formulb1 };
                const formulE1 = `(E6 + E7) - (E11 + E13 + E14 - E12)`;
                const columnE15 = `E15`;
                worksheet[columnE15] = { t: "n", f: formulE1 };
                //formula for EBITDA
                const cellB15 = `B${15}`;
                const cellB16 = `B${16}`;
                const cellB17 = `B${17}`;
                const cellB19 = `B${19}`;
                // Formula: =B15-B16-B17-B19
                const formulaforEBITDA = `${cellB15} - ${cellB16} - ${cellB17} - ${cellB19}`;
                const columnB = `B${20}`; // Assuming you want to place the result in column C
                worksheet[columnB] = { t: "n", f: formulaforEBITDA };
                const cellC15 = `C${15}`;
                const cellC16 = `C${16}`;
                const cellC17 = `C${17}`;
                const cellC19 = `C${19}`;
                const formulaforCEBITDA = `${cellC15} - ${cellC16} - ${cellC17} - ${cellC19}`;
                const columnC = `C${20}`; // Assuming you want to place the result in column C
                worksheet[columnC] = { t: "n", f: formulaforCEBITDA };

                const formulaforEEBITDA = `E15 - E16 - E17 - E19`;
                const columnE = `E${20}`; // Assuming you want to place the result in column C
                worksheet[columnE] = { t: "n", f: formulaforEEBITDA };

                //formula for Profit Before Depreciation & Tax (PBDT)

                const cellB10 = `B${10}`;
                const cellB18 = `B${18}`;
                const cellB20 = `B${20}`;
                const cellB21 = `B${21}`;
                const cellB22 = `B${22}`;
                const cellB23 = `B${23}`;
                const formulaForprofit = `${cellB20} - ${cellB21} - ${cellB22} - ${cellB23} - ${cellB18} + ${cellB10}`;
                const columnB24 = `B${24}`; // Assuming you want to place the result in column C
                worksheet[columnB24] = { t: "n", f: formulaForprofit };

                const formulaForCprofit = `C20 - C21 - C22 - C23 - C18 + C10`;
                const columnC24 = `C24`; // Assuming you want to place the result in column C
                worksheet[columnC24] = { t: "n", f: formulaForCprofit };

                const formulaForEprofit = `E20 - E21 - E22 - E23 - E18 + E10`;
                const columnE24 = `E24`; // Assuming you want to place the result in column C
                worksheet[columnE24] = { t: "n", f: formulaForEprofit };
                //Profit Before Tax (PBT) =B24-B25
                const formulaPBT = `B24 - B25`;
                const columnB26 = `B26`; // Assuming you want to place the result in column C
                worksheet[columnB26] = { t: "n", f: formulaPBT };

                const formulaForCPBT = `C24 - C25`;
                const columnC26 = `C26`; // Assuming you want to place the result in column C
                worksheet[columnC26] = { t: "n", f: formulaForCPBT };

                const formulaForEPBT = `E24 - E25`;
                const columnE26 = `E26`; // Assuming you want to place the result in column C
                worksheet[columnE26] = { t: "n", f: formulaForEPBT };
               //Pat =+B26-B27
               const formulaPAT = `B26 - B27`;
               const column28b = `B28`; // Assuming you want to place the result in column C
               worksheet[column28b] = { t: "n", f: formulaPAT };

               const formulaForCPAT = `C26 - C27`;
               const columnC28 = `C28`; // Assuming you want to place the result in column C
               worksheet[columnC28] = { t: "n", f: formulaForCPAT };

               const formulaForEPAT = `E26 - E27`;
               const columnE28 = `E28`; // Assuming you want to place the result in column C
               worksheet[columnE28] = { t: "n", f: formulaForEPAT };
               

               // for second table


               const formulaB30 = `B19 + B23`;
               const column30b = `B30`; // Assuming you want to place the result in column C
               worksheet[column30b] = { t: "n", f: formulaB30 };

               const formulaForC30 = `C19 + C23`;
               const columnC30 = `C30`; // Assuming you want to place the result in column C
               worksheet[columnC30] = { t: "n", f: formulaForC30 };

               const formulaForE30 = `E19 + E23`;
               const columnE30 = `E30`; // Assuming you want to place the result in column C
               worksheet[columnE30] = { t: "n", f: formulaForE30 };

               const formula33 = `B30-B31`;
               const column33 = `B32`; // Assuming you want to place the result in column C
               worksheet[column33] = { t: "n", f: formula33 };

               const formulaForC33= `C30 - C31`;
               const columnC33 = `C32`; // Assuming you want to place the result in column C
               worksheet[columnC33] = { t: "n", f: formulaForC33 };

               const formulaFor33 = `D30 - D31`;
               const columnE33 = `D32`; // Assuming you want to place the result in column C
               worksheet[columnE33] = { t: "n", f: formulaFor33 };

               //for third table

               const formula36 = `B34 - B35`;
               const column36 = `B36`; // Assuming you want to place the result in column C
               worksheet[column36] = { t: "n", f: formula36 };

               const formulaForC36 = `C34 - C35`;
               const columnC36 = `C36`; // Assuming you want to place the result in column C
               worksheet[columnC36] = { t: "n", f: formulaForC36 };

               const formulaFor36 = `D34 - D35`;
               const columnE36 = `D36`; // Assuming you want to place the result in column C
               worksheet[columnE36] = { t: "n", f: formulaFor36 };


                // Net worth B37+B38-B43
               const formulaNet = `B41+B42-B47`;
               const columnB40 = `B44`; // Assuming you want to place the result in column C
               worksheet[columnB40] = { t: "n", f: formulaNet };

               const formulaForCNET = `C41 + C42 - C47`;
               const columnC40 = `C44`; // Assuming you want to place the result in column C
               worksheet[columnC40] = { t: "n", f: formulaForCNET };

               const formulaForENET = `E41 + E42 - E47`;
               const columnE40 = `E44`; // Assuming you want to place the result in column C
               worksheet[columnE40] = { t: "n", f: formulaForENET };
                // Adjusted tangible Networth =B40+B42-B41-B58-B62
                const formulaAdj = `B44+B46-B45-B62-B66`;
                const columnB44 = `B48`; // Assuming you want to place the result in column C
                worksheet[columnB44] = { t: "n", f: formulaAdj };
 
                const formulaForCADJ = `C44+C46-C45-C62-C66`;
                const columnC44 = `C48`; // Assuming you want to place the result in column C
                worksheet[columnC44] = { t: "n", f: formulaForCADJ };

                const formulaForEADJ = `E44+E46-E45-E62-E66`;
                const columnE44 = `E48`; // Assuming you want to place the result in column C
                worksheet[columnE44] = { t: "n", f: formulaForEADJ };
                
                //Total Loan funds=SUM(B45+B46+B47+B48)
                const formulaB = `SUM(B49:B52)`;
                const columnB49 = `B53`;
                worksheet[columnB49] = { t: "n", f: formulaB };
                const formulaC = `SUM(C49:C52)`;
                const columnC49 = `C53`;
                worksheet[columnC49] = { t: "n", f: formulaC };

                const formulaE = `SUM(E49:E52)`;
                const columnE49 = `E53`;
                worksheet[columnE49] = { t: "n", f: formulaE };
                //total =SUM(B39+B40+B42+B49+B50+B51+B52+B53+B54)

                const formulaBta = `B43+B44+B46+B53+B54+B55+B56+B57+B58`;
                const columnB55 = `B59`;
                worksheet[columnB55] = { t: "n", f: formulaBta };
                const formulaCto = `C43+C44+C46+C53+C54+C55+C56+C57+C58`;
                const columnC55 = `C59`;
                worksheet[columnC55] = { t: "n", f: formulaCto };

                const formulaEto = `E43+E44+E46+E53+E54+E55+E56+E57+E58`;
                const columnE55 = `E59`;
                worksheet[columnE55] = { t: "n", f: formulaEto };


                //64=65+66
                const formulaBdeabtor = `B65+B66`;
                worksheet[`B64`] = { t: "n", f: formulaBdeabtor };
                const formulaCDeb = `C65+C66`;
                worksheet[`C64`] = { t: "n", f: formulaCDeb };

                const formulaEDeb = `E65+E66`;
                worksheet[`E64`] = { t: "n", f: formulaEto };


                //total SUM(B57:B70)+B41
               /* const formulaBta2 = `SUM(B61:B74)+B45`;
                const columnB71 = `B75`;
                worksheet[columnB71] = { t: "n", f: formulaBta2 };
                const formulaCto2 = `SUM(C61:C74)+C45`;
                const columnC71 = `C75`;
                worksheet[columnC71] = { t: "n", f: formulaCto2 };

                const formulaEto2 = `SUM(E61:E74)+E45`;
                const columnE71 = `E75`;
                worksheet[columnE71] = { t: "n", f: formulaEto2 };*/

                const formulaBta2 = `SUM(B61:B64) + SUM(B67:B74) + B45`;
                const columnB71 = `B75`;
                worksheet[columnB71] = { t: "n", f: formulaBta2 };
                const formulaCto2 = `SUM(C61:C64) + SUM(C67:C74) + C45`;
                const columnC71 = `C75`;
                worksheet[columnC71] = { t: "n", f: formulaCto2 };
                const formulaEto2 = `SUM(E61:E64) + SUM(E67:E74) + E45`;
                const columnE71 = `E75`;
                worksheet[columnE71] = { t: "n", f: formulaEto2 };

                 //Diff SUM(B57:B70)+B41
                 const formulaBdiff = `B59-B75`;
                 const columnB72 = `B76`;
                 worksheet[columnB72] = { t: "n", f: formulaBdiff };
                 const formulaCdiff = `C59-C75`;
                 const columnC72 = `C76`;
                 worksheet[columnC72] = { t: "n", f: formulaCdiff };

                 const formulaEdiff = `E59-E75`;
                 const columnE72 = `E76`;
                 worksheet[columnE72] = { t: "n", f: formulaEdiff };
                for(let i=0; i<firstColumn.length; i++){
                   // const formula = `IFERROR((C${i+6}-B${i+6})*100/B${i+6},"")`;
                   const formula = `IFERROR(ROUND((C${i+6}-B${i+6})*100/B${i+6},2),"")`;
                     worksheet[`D${i+6}`] = { t: "n", f: formula };

                     const formula1 = `IFERROR(ROUND((E${i+6}-C${i+6})*100/C${i+6},2),"")`;
                     worksheet[`F${i+6}`] = { t: "n", f: formula1 };
                }
                let firstColumnForBala1=firstColumnForBala+1
                for(let i=0; i<=firstColumnForBala.length; i++){
                    const formula = `IFERROR(ROUND((C${i+41}-B${i+41})*100/B${i+41},2),"")`;
                     worksheet[`D${i+41}`] = { t: "n", f: formula };

                     const formula1 = `IFERROR(ROUND((E${i+41}-C${i+41})*100/C${i+41},2),"")`;
                     worksheet[`F${i+41}`] = { t: "n", f: formula1 };
                  }
                for(let i=0; i<firstColumnForAsset.length; i++){
                    const formula = `IFERROR(ROUND((C${i+61}-B${i+61})*100/B${i+61},2),"")`;
                     worksheet[`D${i+61}`] = { t: "n", f: formula };

                     const formula1 = `IFERROR(ROUND((E${i+61}-C${i+61})*100/C${i+61},2),"")`;
                     worksheet[`F${i+61}`] = { t: "n", f: formula1 };
                }
                console.log('test1')

                const workbook = XLSX.utils.book_new();
                console.log('test1')
               XLSX.utils.book_append_sheet(workbook, worksheet, 'Sheet1');
               console.log('test1')
                XLSX.writeFile(workbook, 'Financial_Sheet.xlsx');

        }else{
            console.log('inelseeeeeee')
            
                var firstColumn=Object.keys(this.columnMapWithFieldForProfit);
                //console.log('firstColumn'+firstColumn)
                //console.log(this.columnMapWithFieldForProfit[firstColumn[0]])
                this.data = [
                    {"Financials Years Data":"Financial Year","__EMPTY":this.privousYear,"__EMPTY_1":this.currentYear,"__EMPTY_2":"","__EMPTY_3":"","__EMPTY_4":"","__EMPTY_5":""},
                    {"Financials Years Data":"Type of Accounts","__EMPTY":this.previousRecForProfit.Type_of_Accounts__c,"__EMPTY_1":this.currentRecForProfit.Type_of_Accounts__c,"__EMPTY_2":"","__EMPTY_3":"","__EMPTY_4":"","__EMPTY_5":""},
                    {"Financials Years Data":"Date of Filing ITR (DD-MMM-YYYY)","__EMPTY":this.previousRecForProfit.Date_of_Filing_ITR__c,"__EMPTY_1":this.currentRecForProfit.Date_of_Filing_ITR__c,"__EMPTY_2":this.currentRecForProfit.ITR_Filing_Gap_Days__c,"__EMPTY_3":"ITR filing Gap Days","__EMPTY_4":"","__EMPTY_5":""},
                    {"Financials Years Data":"Profit & Loss A/c", "__EMPTY_2":"Inc/dec%", "__EMPTY_3": "Remarks"},
                    ]
                for(let i=0; i<firstColumn.length; i++){
                    var firstVal=this.columnMapWithFieldForProfit[firstColumn[i]][0];
                   var SecVal=this.columnMapWithFieldForProfit[firstColumn[i]][1];
                    //   var newRow= {"Financials Years Data":firstColumn[i],"__EMPTY":this.previousRecForProfit[firstVal],"__EMPTY_1":this.currentRecForProfit[firstVal],"__EMPTY_2":this.incrementdecrement[firstVal],"__EMPTY_3":this.currentRecForProfit[SecVal],"__EMPTY_4":"","__EMPTY_5":""}
                    var newRow= {"Financials Years Data":firstColumn[i],"__EMPTY":this.previousRecForProfit[firstVal],"__EMPTY_1":this.currentRecForProfit[firstVal],"__EMPTY_2":0,"__EMPTY_3":this.currentRecForProfit[SecVal],"__EMPTY_4":"","__EMPTY_5":""}
                    this.data.push(newRow);
                    
                }
                this.data.push(blankRec)
                //for loop for second table of profit or loss
                var firstColumnForTable2=Object.keys(this.columnMapFieldForProfitTab2);
                for(let i=0; i<firstColumnForTable2.length; i++){
                    var firstVal=this.columnMapFieldForProfitTab2[firstColumnForTable2[i]][0];
                    var newRow= {"Financials Years Data":firstColumnForTable2[i],"__EMPTY":this.previousRecForProfit[firstVal],"__EMPTY_1":this.currentRecForProfit[firstVal]}
                    this.data.push(newRow);
                    
                }
                this.data.push(blankRec)
                var firstColumnForTable3=Object.keys(this.columnMapWithFieldForTab3Pro);
                for(let i=0; i<firstColumnForTable3.length; i++){
                    var firstVal=this.columnMapWithFieldForTab3Pro[firstColumnForTable3[i]][0];
                    var newRow= {"Financials Years Data":firstColumnForTable3[i],"__EMPTY":this.previousRecForProfit[firstVal],"__EMPTY_1":this.currentRecForProfit[firstVal],"__EMPTY_2":this.proviRecForProfit[firstVal]}
                    this.data.push(newRow);
                    
                }
                this.data.push(blankRec)
                let line34Rec={"Financials Years Data":"Balance Sheet"}
                let line35Rec={"Financials Years Data":"Financial Year","__EMPTY":this.privousYear,"__EMPTY_1":this.currentYear,"__EMPTY_2":"Inc/dec%","__EMPTY_3":"Remarks","__EMPTY_4":"","__EMPTY_5":""}
                let line36Rec={"Financials Years Data":"Liabilities"}
                this.data.push(line34Rec)
                this.data.push(line35Rec)
                this.data.push(line36Rec)

                var firstColumnForBala=Object.keys(this.columnMapWithFieldForBala);
                for(let i=0; i<firstColumnForBala.length; i++){
                    var firstVal=this.columnMapWithFieldForBala[firstColumnForBala[i]][0];
                    var SecVal=this.columnMapWithFieldForBala[firstColumnForBala[i]][1];
                    var newRow= {"Financials Years Data":firstColumnForBala[i],"__EMPTY":this.previousFinanYearBalRec[firstVal],"__EMPTY_1":this.currentFinanYearBalRec[firstVal],"__EMPTY_2":0,"__EMPTY_3":this.currentFinanYearBalRec[SecVal],"__EMPTY_4":"","__EMPTY_5":""}
                    this.data.push(newRow);
                    
                }
                var recTotal={"Financials Years Data":"Total","__EMPTY":"","__EMPTY_1":"","__EMPTY_2":0,"__EMPTY_3":"","__EMPTY_4":"","__EMPTY_5":""}
                this.data.push(recTotal);
                let line56Rec={"Financials Years Data":"Asset"}
                this.data.push(line56Rec);
                //for loop
                var firstColumnForAsset=Object.keys(this.columnMapWithFieldForAsset);
                for(let i=0; i<firstColumnForAsset.length; i++){
                    var firstVal=this.columnMapWithFieldForAsset[firstColumnForAsset[i]][0];
                    var SecVal=this.columnMapWithFieldForAsset[firstColumnForAsset[i]][1];
                    var newRow= {"Financials Years Data":firstColumnForAsset[i],"__EMPTY":this.previousFinanYearBalRec[firstVal],"__EMPTY_1":this.currentFinanYearBalRec[firstVal],"__EMPTY_2":0,"__EMPTY_3":this.currentFinanYearBalRec[SecVal],"__EMPTY_4":"","__EMPTY_5":""}
                    this.data.push(newRow);
                    
                }
               
                const worksheet = XLSX.utils.json_to_sheet(this.data);
               // console.log('111>>>>>>>>>>>>>>>>')
                worksheet["A1"].v = "Financials Years Data"; // Change A1 cell (Name column header)
                worksheet["B1"].v = ""; // Change B1 cell (Age column header)
                worksheet["C1"].v = "";
                worksheet["D1"].v = "";
                worksheet["E1"].v = ""; // Change E1 cell
                worksheet["F1"].v = ""; // Change F1 cell
                worksheet["G1"].v = "";
                
                const formulaD4 = `IF(B4<>"",C4-B4,"")`;
                const columnD4 = `D4`;
                worksheet[columnD4] = { t: "n", f: formulaD4 };
                const formula1 = `(C6 + C7) - (C11 + C13 + C14 - C12)`;
                const columnC15 = `C15`;
                worksheet[columnC15] = { t: "n", f: formula1 };
                const formulb1 = `(B6 + B7) - (B11 + B13 + B14 - B12)`;
                const columnB15 = `B15`;
                worksheet[columnB15] = { t: "n", f: formulb1 };
                //formula for EBITDA
                const cellB15 = `B${15}`;
                const cellB16 = `B${16}`;
                const cellB17 = `B${17}`;
                const cellB19 = `B${19}`;
                // Formula: =B15-B16-B17-B19
                const formulaforEBITDA = `${cellB15} - ${cellB16} - ${cellB17} - ${cellB19}`;
                const columnB = `B${20}`; // Assuming you want to place the result in column C
                worksheet[columnB] = { t: "n", f: formulaforEBITDA };
                const cellC15 = `C${15}`;
                const cellC16 = `C${16}`;
                const cellC17 = `C${17}`;
                const cellC19 = `C${19}`;
                const formulaforCEBITDA = `${cellC15} - ${cellC16} - ${cellC17} - ${cellC19}`;
                const columnC = `C${20}`; // Assuming you want to place the result in column C
                worksheet[columnC] = { t: "n", f: formulaforCEBITDA };
                //formula for Profit Before Depreciation & Tax (PBDT)

                const cellB10 = `B${10}`;
                const cellB18 = `B${18}`;
                const cellB20 = `B${20}`;
                const cellB21 = `B${21}`;
                const cellB22 = `B${22}`;
                const cellB23 = `B${23}`;

                const merge = [
                    { s: { r: 0, c: 0 }, e: { r: 0, c: 5 } },{ s: { r: 4, c: 0 }, e: { r: 4, c: 2 } }];
                  worksheet["!merges"] = merge;
                                  // Formula: =B20-B21-B22-B23-B18+B10
                const formulaForprofit = `${cellB20} - ${cellB21} - ${cellB22} - ${cellB23} - ${cellB18} + ${cellB10}`;
                const columnB24 = `B${24}`; // Assuming you want to place the result in column C
                worksheet[columnB24] = { t: "n", f: formulaForprofit };

                const formulaForCprofit = `C20 - C21 - C22 - C23 - C18 + C10`;
                const columnC24 = `C24`; // Assuming you want to place the result in column C
                worksheet[columnC24] = { t: "n", f: formulaForCprofit };
                //Profit Before Tax (PBT) =B24-B25
                const formulaPBT = `B24 - B25`;
                const columnB26 = `B26`; // Assuming you want to place the result in column C
                worksheet[columnB26] = { t: "n", f: formulaPBT };

                const formulaForCPBT = `C24 - C25`;
                const columnC26 = `C26`; // Assuming you want to place the result in column C
                worksheet[columnC26] = { t: "n", f: formulaForCPBT };
               //Pat =+B26-B27
               const formulaPAT = `B26 - B27`;
               const column28b = `B28`; // Assuming you want to place the result in column C
               worksheet[column28b] = { t: "n", f: formulaPAT };

               const formulaForCPAT = `C26 - C27`;
               const columnC28 = `C28`; // Assuming you want to place the result in column C
               worksheet[columnC28] = { t: "n", f: formulaForCPAT };

               const formulaB30 = `B19 + B23`;
               const column30b = `B30`; // Assuming you want to place the result in column C
               worksheet[column30b] = { t: "n", f: formulaB30 };

               const formulaForC30 = `C19 + C23`;
               const columnC30 = `C30`; // Assuming you want to place the result in column C
               worksheet[columnC30] = { t: "n", f: formulaForC30 };



               // for second table

               const formula33 = `B30-B31`;
               const column33 = `B32`; // Assuming you want to place the result in column C
               worksheet[column33] = { t: "n", f: formula33 };

               const formulaForC33= `C30 - C31`;
               const columnC33 = `C32`; // Assuming you want to place the result in column C
               worksheet[columnC33] = { t: "n", f: formulaForC33 };

               //for third table

               const formula36 = `B34 - B35`;
               const column36 = `B36`; // Assuming you want to place the result in column C
               worksheet[column36] = { t: "n", f: formula36 };

               const formulaForC36 = `C34 - C35`;
               const columnC36 = `C36`; // Assuming you want to place the result in column C
               worksheet[columnC36] = { t: "n", f: formulaForC36 };
                // Net worth B37+B38-B43
            
                const formulaNet = `B41+B42-B47`;
               const columnB40 = `B44`; // Assuming you want to place the result in column C
               worksheet[columnB40] = { t: "n", f: formulaNet };

               const formulaForCNET = `C41 + C42 - C47`;
               const columnC40 = `C44`; // Assuming you want to place the result in column C
               worksheet[columnC40] = { t: "n", f: formulaForCNET };
                // Adjusted tangible Networth =B40+B42-B41-B58-B62
                const formulaAdj = `B44+B46-B45-B62-B66`;
                const columnB44 = `B48`; // Assuming you want to place the result in column C
                worksheet[columnB44] = { t: "n", f: formulaAdj };
 
                const formulaForCADJ = `C44+C46-C45-C62-C66`;
                const columnC44 = `C48`; // Assuming you want to place the result in column C
                worksheet[columnC44] = { t: "n", f: formulaForCADJ };
                
                //Total Loan funds=SUM(B45+B46+B47+B48)
                const formulaB = `SUM(B49:B52)`;
                const columnB49 = `B53`;
                worksheet[columnB49] = { t: "n", f: formulaB };
                const formulaC = `SUM(C49:C52)`;
                const columnC49 = `C53`;
                worksheet[columnC49] = { t: "n", f: formulaC };

                //total =SUM(B39+B40+B42+B49+B50+B51+B52+B53+B54)

                const formulaBta = `B43+B44+B46+B53+B54+B55+B56+B57+B58`;
                const columnB55 = `B59`;
                worksheet[columnB55] = { t: "n", f: formulaBta };
                const formulaCto = `C43+C44+C46+C53+C54+C55+C56+C57+C58`;
                const columnC55 = `C59`;
                worksheet[columnC55] = { t: "n", f: formulaCto };

                //64=65+66
                const formulaBdeabtor = `B65+B66`;
                worksheet[`B64`] = { t: "n", f: formulaBdeabtor };
                const formulaCDeb = `C65+C66`;
                worksheet[`C64`] = { t: "n", f: formulaCDeb };


                //total SUM(B57:B70)+B41
                const formulaBta2 = `SUM(B61:B64) + SUM(B67:B74) + B45`;
                const columnB71 = `B75`;
                worksheet[columnB71] = { t: "n", f: formulaBta2 };
                const formulaCto2 = `SUM(C61:C64) + SUM(C67:C74) + C45`;
                const columnC71 = `C75`;
                worksheet[columnC71] = { t: "n", f: formulaCto2 };

                 //Diff SUM(B57:B70)+B41
                 const formulaBdiff = `B59-B75`;
                 const columnB72 = `B76`;
                 worksheet[columnB72] = { t: "n", f: formulaBdiff };
                 const formulaCdiff = `C59-C75`;
                 const columnC72 = `C76`;
                 worksheet[columnC72] = { t: "n", f: formulaCdiff };
                
               
                for(let i=0; i<firstColumn.length; i++){
                    const formula = `IFERROR(ROUND((C${i + 6} - B${i + 6}) * 100 / B${i + 6}, 2), "")`;
                     worksheet[`D${i+6}`] = { t: "n", f: formula };
                }
                let firstColumnForBala1=firstColumnForBala+1
                for(let i=0; i<=firstColumnForBala.length; i++){
                    //const formula = `IFERROR((C${i+41}-B${i+41})*100/B${i+41},"")`;
                    const formula = `IFERROR(ROUND((C${i+41}-B${i+41})*100/B${i+41},2),"")`;
                     worksheet[`D${i+41}`] = { t: "n", f: formula };
                  }

                  //console.log('firstColumnForAsset.length')  
                  console.log('firstColumnForAsset.length'+firstColumnForAsset.length)
              /* for(let i=0; i<firstColumnForAsset.length; i++){
                   const formula = `IFERROR((ROUND(C${i+61}-B${i+61})*100/B${i+61},2),"")`;
                    worksheet[`D${i+61}`] = { t: "n", f: formula };
                }*/
                    for(let i=0; i<firstColumnForAsset.length; i++){
                        const formula = `IFERROR(ROUND((C${i+61}-B${i+61})*100/B${i+61},2),"")`;
                         worksheet[`D${i+61}`] = { t: "n", f: formula };
    
                    }
                //worksheet['!cols'] = this.fitToColumn(this.data);
                console.log('test1')
                //worksheet['!cols'] = wscols;
                const workbook = XLSX.utils.book_new();
                console.log('test1')
                XLSX.utils.book_append_sheet(workbook, worksheet, 'Sheet1');
                console.log('test1')
                XLSX.writeFile(workbook, 'Financial_Sheet.xlsx');
           
           
        }
    }, 1000);
    }
    
    columnMapWithFieldForProfit={};
    @wire(getMetadataForProfit)
    wiredJsonToExcelMetadata({ error, data }) {
        if (data) {
            let columnMapWithFieldForProfit = {};
            //console.log('datadatadata'+JSON.stringify(data))
            data.forEach(record => {
                let value=[];
                if(typeof record.FieldName__c !== 'undefined'){
                    value.push(record.FieldName__c);
                }else{
                    value.push("");
                }
                if(typeof record.Remark_for_field__c !== 'undefined'){
                    value.push(record.Remark_for_field__c);
                }else{
                    value.push("");
                }
                columnMapWithFieldForProfit[record.TableColumnName__c] = value;
            });
            this.columnMapWithFieldForProfit=columnMapWithFieldForProfit;
          //console.log('fieldAPIToSourceColumnMap'+JSON.stringify(this.columnMapWithFieldForProfit))

        } else if (error) {
            console.error('Error retrieving metadata: ', error);
        }
    }
    columnMapFieldForProfitTab2={}
    columnMapWithFieldForBala={}
    columnMapWithFieldForAsset={}
    columnMapWithFieldForTab3Pro={}
    @wire(getMetadataForProfitTab2)
    wiredJsonToExcelMetadataFor3List({ error, data }) {
        if (data) {
            let columnMapFieldForProfitTab2 = {};
            let columnMapWithFieldForBala = {};
            let columnMapWithFieldForAsset = {};
            let columnMapWithFieldForTab3Pro={}
           // console.log('datadatadata'+JSON.stringify(data))
            const allKey=Object.keys(data);
            for(const rec of allKey){
               // console.log('recrecrecrecrec'+rec)
                if(rec=='Profit and loss 2 table'){
                    //console.log('data.get(rec)'+data["Profit and loss 2 table"])
                    const fistList =data["Profit and loss 2 table"]
                    fistList.forEach(record => {
                            let value=[];
                            if(typeof record.FieldName__c !== 'undefined'){
                                value.push(record.FieldName__c);
                            }else{
                                value.push("");
                            }
                            columnMapFieldForProfitTab2[record.TableColumnName__c] = value;
                    });
                    this.columnMapFieldForProfitTab2=columnMapFieldForProfitTab2;

                }else if(rec=='Profit and loss 3 table'){
                   // console.log('data.get(rec)'+data["Profit and loss 3 table"])
                    const fistList =data["Profit and loss 3 table"]
                    fistList.forEach(record => {
                            let value=[];
                            if(typeof record.FieldName__c !== 'undefined'){
                                value.push(record.FieldName__c);
                            }else{
                                value.push("");
                            }
                            columnMapWithFieldForTab3Pro[record.TableColumnName__c] = value;
                    });
                    this.columnMapWithFieldForTab3Pro=columnMapWithFieldForTab3Pro;
                }

                else if(rec=='Balance Sheet'){
                    const secList =data["Balance Sheet"]
                    secList.forEach(record => {
                            let value=[];
                            if(typeof record.FieldName__c !== 'undefined'){
                                value.push(record.FieldName__c);
                            }else{
                                value.push("");
                            }if(typeof record.Remark_for_field__c !== 'undefined'){
                                value.push(record.Remark_for_field__c);
                            }else{
                                value.push("");
                            }
                            columnMapWithFieldForBala[record.TableColumnName__c] = value;
                    });
                    this.columnMapWithFieldForBala=columnMapWithFieldForBala;

                }else if(rec=='Asset Sheet'){
                    const thirdList =data["Asset Sheet"]
                    thirdList.forEach(record => {
                            let value=[];
                            if(typeof record.FieldName__c !== 'undefined'){
                                value.push(record.FieldName__c);
                            }else{
                                value.push("");
                            }if(typeof record.Remark_for_field__c !== 'undefined'){
                                value.push(record.Remark_for_field__c);
                            }else{
                                value.push("");
                            }
                            columnMapWithFieldForAsset[record.TableColumnName__c] = value;
                    });
                    this.columnMapWithFieldForAsset=columnMapWithFieldForAsset;
                }
            }
            
        } else if (error) {
            console.error('Error retrieving metadata: ', error);
        }
    }



    @wire(getObjectInfo, {objectApiName: FINANCIAL_OBJECT})
    getObjectData({data, error}){
        if(data){
            for (const key in data.recordTypeInfos) {
                if (data.recordTypeInfos[key].name === 'Balance Sheet') {
                  this.recordTypeIdForBalanceSheet = data.recordTypeInfos[key].recordTypeId;
                }else if(data.recordTypeInfos[key].name === 'Profit & Loss'){
                    this.recordTypeIdForProfitLoss = data.recordTypeInfos[key].recordTypeId;
                }

              }
              //console.log('this.recordTypeIdForProfitLoss'+this.recordTypeIdForProfitLoss)
             // console.log('this.recordTypeIdForBalanceSheet'+this.recordTypeIdForBalanceSheet)
        }else if(error){

        }
    }
    @track finRecordIdForbalSheet;
    actualFinancialDataforBal;
    finanacialRecForBal={};
    @wire(getSobjectData, { params: '$financialParamsForBal' })
    handleFinancialResponse(wiredResultIncome) {
        let { error, data } = wiredResultIncome;
        this.actualFinancialDataforBal = wiredResultIncome;
        if (data) {
           // this.createEmptyWrapObj();
            if (data.parentRecords && data.parentRecords.length > 0) {
                //console.log('data.parentRecords.length'+data.parentRecords.length)
                this.financialRecordIdForBal = data.parentRecords[0].Id;
                if (data.parentRecords[0].Id) {
                    this.financialRecordIdForBal = data.parentRecords[0].Id;
                    this.finanacialRecForBal.Id=data.parentRecords[0].Id
                    let tempParams = this.summaryParams;
                    tempParams.queryCriteria = ' where Applicant_Financial__c = \'' + this.financialRecordIdForBal + '\''
                    this.summaryParams = { ...tempParams };
                   // console.log('this.financialRecordIdForBal'+this.financialRecordIdForBal)
                    this.getFinSummRecordForBal();
                }
            }
            else {
                this.createApplicantFinancialRecord();
            }
        } else if (error) {
            this.showToastMessage("Error in handleFinancialResponse", error.body.message, "error", "sticky");
        }

    }
    createApplicantFinancialRecord() {
        this.showSpinner = true;
        let financialDetails = {
            Loan_Applicant__c: this._applicantId,
            sobjectType: 'Applicant_Financial__c',
            RecordTypeId: this.recordTypeIdForBalanceSheet
        };
        let upsertData = {
            parentRecord: financialDetails,
            ChildRecords: [],
            ParentFieldNameToUpdate: 'Applicant_Financial__c'
        }
        upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
        .then(result => {
            if (result) {
                if (result.parentRecord) {
                    this.financialRecordIdForBal = result.parentRecord.Id;
                    this.finanacialRecForBal.Id= result.parentRecord.Id;
                }
            }
            this.showSpinner = false;
        })
        .catch(error => {
            this.showToastMessage("Error in createApplicantFinancialRecord", error.body.message, "error", "sticky");
            this.showSpinner = false;
        })
    }
    proviFinanYearBalId
    previousFinanYearBalId
    currentFinanYearBalId
    proviFinanYearBalRec={}
    previousFinanYearBalRec={}
    currentFinanYearBalRec={}

    getFinSummRecordForBal() {
        getSobjectDataNonCacheable({ params: this.summaryParams })
        .then(result => {
            if (result) {
               // console.log('result.parentRecords>>>>>>>>>>>'+JSON.stringify(result))
                if (result.parentRecords) {
                    for(const rec of result.parentRecords){
                        if(rec.Current_Financial_Year__c==true){
                            this.currentFinanYearBalId=rec.Id
                            this.currentFinanYearBalRec=rec
                        }else if(rec.Previous_Financial_Year__c==true){
                            this.previousFinanYearBalId=rec.Id
                            this.previousFinanYearBalRec=rec
                        }
                        else if(rec.Provisional_Financial_Year__c==true){
                            this.proviFinanYearBalId=rec.Id
                            this.proviFinanYearBalRec=rec
                        }
                    }
                  //  console.log('result.parentRecords'+result.parentRecords)
                    
                }
            }
        })
        .catch(error => {
            //this.showToastMessage("Error in getFinancialSummaryRecord ", error.body.message, "error", "sticky");
        })
    }
    @track finRecordIdForProfit;
    actualFinancialDataforProf;
    FinanRecForProft={};
    @wire(getSobjectData, { params: '$financialParamsForProfit' })
    handleFinancialResponseForProf(wiredResultIncome) {
        let { error, data } = wiredResultIncome;
        this.actualFinancialDataforProf = wiredResultIncome;
        if (data) {
           // this.createEmptyWrapObj();
            if (data.parentRecords && data.parentRecords.length > 0) {
               // console.log('data.parentRecords.length'+data.parentRecords.length)
                this.FinanRecForProft.Id=data.parentRecords[0].Id
                this.finRecordIdForProfit = data.parentRecords[0].Id;
                if (data.parentRecords[0].Id) {
                    this.finRecordIdForProfit = data.parentRecords[0].Id;
                    let tempParams = this.summaryParamsforProfit;
                    tempParams.queryCriteria = ' where Applicant_Financial__c = \'' + this.finRecordIdForProfit + '\''
                    this.summaryParamsforProfit = { ...tempParams };
                  //  console.log('this.finRecordIdForProfit    '+this.finRecordIdForProfit)
                    this.getFinSummRecordForProfit();
                }
            }
            else {
                this.createApplicantFinRecForProfit();
            }
        } else if (error) {
            this.showToastMessage("Error in handleFinancialResponse", error.body.message, "error", "sticky");
        }

    }
    createApplicantFinRecForProfit() {
        this.showSpinner = true;
        let financialDetails = {
            Loan_Applicant__c: this._applicantId,
            sobjectType: 'Applicant_Financial__c',
            RecordTypeId: this.recordTypeIdForProfitLoss
        };
        let upsertData = {
            parentRecord: financialDetails,
            ChildRecords: [],
            ParentFieldNameToUpdate: 'Applicant_Financial__c'
        }
        upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
        .then(result => {
            if (result) {
                if (result.parentRecord) {
                    this.finRecordIdForProfit = result.parentRecord.Id;
                    this.FinanRecForProft.Id=result.parentRecord.Id;
                }
            }
            this.showSpinner = false;
        })
        .catch(error => {
            this.showToastMessage("Error in createApplicantFinancialRecord", error.body.message, "error", "sticky");
            this.showSpinner = false;
        })
    }
    currentFinanYearProfitId;
    previousFinanYearProfitId;
    proviFinanYearProfitId;
    currentRecForProfit={}
    previousRecForProfit={}
    proviRecForProfit={}
    getFinSummRecordForProfit() {
        getSobjectDataNonCacheable({ params: this.summaryParamsforProfit })
        .then(result => {
            if (result) {
               // console.log('result.getFinSummRecordForProfit231'+JSON.stringify(result))
                if (result.parentRecords) {
                  //  console.log('result.parentRecords233'+JSON.stringify(result.parentRecords))
                    for(const rec of result.parentRecords){
                        if(rec.Current_Financial_Year__c==true){
                            this.currentFinanYearProfitId=rec.Id
                            this.currentRecForProfit=rec
                        }else if(rec.Previous_Financial_Year__c==true){
                            this.previousFinanYearProfitId=rec.Id
                            this.previousRecForProfit=rec
                        }
                        else if(rec.Provisional_Financial_Year__c==true){
                            this.proviFinanYearProfitId=rec.Id
                            this.proviRecForProfit=rec
                        }
                    }
                    
                }
            }
        })
        .catch(error => {
            //this.showToastMessage("Error in getFinancialSummaryRecord ", error.body.message, "error", "sticky");
        })
    }


    showToastMessage(title, variant, message, mode) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
            mode: "sticky",
            
        });
        this.dispatchEvent(evt);
        this.showSpinner =false;
    }
    handleFileRemove(){
        this.uploadedFiles=''
    }
    hideModalBox(){
        this.uploadedFiles=''
        this.showUploadComp=false
        const toClosePopUp = new CustomEvent('toclosepopup', {
        });
        this.dispatchEvent(toClosePopUp);
    }
    handleUploadFinished(event){
        this.uploadedFiles = event.detail.files;
        const file=this.uploadedFiles[0]
        const fileType = '.' + file.name.split('.').pop();
       
        if(fileType=='.xls' ||fileType=='.xlsx'){
           
        }else{
            this.showToastMessage("Error!", "error","You can only upload excel format type file.","sticky"); 
            this.uploadedFiles=[];
        }
    }
    handleExcelUpload(){
        if(this.uploadedFiles.length > 0) {   
        this.ExcelToJSON(this.uploadedFiles[0]);
        }else{
          //  console.log('inelseeeee')
            this.showToastMessage("Error!", "error","please select File First.", "sticky");
        }
    }
    ExcelToJSON(file){
        this.showSpinner=true;
       // console.log('this.uploadedFiles'+this.uploadedFiles.length)
        if (file) {
            const reader = new FileReader();
            reader.onload = () => {
                const workbook = XLSX.read(reader.result, { type: 'binary' });
                const sheetName = workbook.SheetNames[0]; // Assuming the first sheet
                const sheet = workbook.Sheets[sheetName];
                
                const jsonData = XLSX.utils.sheet_to_row_object_array(sheet);
                console.log('jsonData'+JSON.stringify(jsonData)); // Output JSON data to console
                
                var data = JSON.stringify(jsonData);
                const records = JSON.parse(data);
                if(records.length==0 || records.length==1){
                    this.showSpinner=false;
                    this.showToastMessage("Error!", "error","Please Upload correct file format of Financial profit and loss and balance sheet.");
                    const toClosePopUp = new CustomEvent('toclosepopup', {
                    });
                    this.dispatchEvent(toClosePopUp);
                }
                for (const rec of records) {
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
                        if (key === "_6") {
                            rec['__EMPTY_6'] = rec[key];
                            delete rec[key];
                        }
                    }
                }
               // console.log('recordsrecords'+JSON.stringify(records[33]))
               // console.log('recordsrecords'+JSON.stringify(records[67]))
               console.log('Object.keys(records[0])'+records.length)
               if(Object.keys(records[0])[0]=='Financials Years Data' && records.length >=75){
                    console.log('inifiiififif')
                    this.createRecordForSaveForProfit(records);
                    this.createRecordForSaveForBalanceSheet(records)
               }else{
                console.log('inelseeee')
                    this.showToastMessage("Error!", "error","Please Upload correct file format of Financial profit and loss and balance sheet.");
               }
                
                
            };
            reader.readAsBinaryString(file);
            
        }
    }
    get previousPeriod() {
        return `${this.currentPeriodStart - 1}-${this.currentPeriodStart}`;
    }

    get nextPeriod() {
        return `${this.currentPeriodEnd + 1}-${this.currentPeriodEnd + 2}`;
    }
    
    createRecordForSaveForBalanceSheet(records){
        const firstFinanYear=records[0]['__EMPTY'] !=='undefined' ?  this.getDate(records[0]['__EMPTY']): "";
        const secFinanYear=records[0]['__EMPTY_1'] !=='undefined' ?  this.getDate(records[0]['__EMPTY_1']): "";
        console.log('secFinanYear'+secFinanYear)
        if(secFinanYear!=="" && firstFinanYear!==""){
            this.currentPeriodStart=firstFinanYear.split('-')[1]
            this.currentPeriodEnd=secFinanYear.split('-')[1];
        }
        const PreFinaRecForBalance={'Applicant_Financial__c':this.financialRecordIdForBal,'Current_Financial_Year__c':false,'Previous_Financial_Year__c':true,'Provisional_Financial_Year__c':false,'Type_of_Accounts__c':"", 'Financial_Year__c':this.privousYear, 'Date_of_Filing_ITR__c':"", 'Total_Sales__c':"", 'Other_Operating_Income_IncomeIncidental__c':"", 'Non_Operating_Income__c':"", 'Non_Business_Income__c':"", 'Opening_Stock__c':"", 'Closing_Stock__c':"", 'Purchases__c':"", 'Direct_Expenses__c':"", 'Gross_Profit__c':"", 'Office_Administrative_Expenses__c':"", 'Other_Indirect_Expenses__c':"", 'Non_Operating_Expenses_FxLoss_AssetLoss__c':"", 'Salary_to_Partner_Directors__c':"", 'EBITDA__c':"", 'Interest_on_Term_Loans__c':"", 'Interest_on_CC_OD_limits__c':"", 'Interest_on_Partner_Capital__c':"", 'Profit_Before_Depreciation_and_Tax_PBDT__c':"", 'Depreciation__c':"", 'Profit_Before_Tax__c':"", 'Taxes__c':"", 'PAT__c':"", 'Director_Partners_remuneration_Interest__c':"", 'Tax_on_Above_Income__c':"", 'Net_Income_Considered_for_Eligibility__c':"", 'Applicant_Financial__c':"", 'Total_Sales_Remark__c':"", 'Other_Operating_Income_Remark__c':"", 'Non_Operating_Income_Remark__c':"", 'Non_Business_Income_Remark__c':"", 'Opening_Stock_Remark__c':"", 'Closing_Stock_Remark__c':"", 'Purchases_Remark__c':"", 'Direct_Expenses_Remark__c':"", 'Gross_Profit_Remark__c':"", 'Office_Administrative_Expenses_Remark__c':"", 'Other_Indirect_Expenses_Remark__c':"", 'Non_Operating_Expenses_Remark__c':"", 'Salary_to_Partner_Directors_Remark__c':"", 'EBITDA_Remark__c':"", 'Interest_on_Term_Loans_Remark__c':"", 'Interest_on_CC_OD_limits_Remark__c':"", 'Interest_on_Partner_Capital_Remark__c':"", 'Profit_Before_Depreciation_PBDT_Remark__c':"", 'Depreciation_Remark__c':"", 'Profit_Before_Tax_Remark__c':"", 'Taxes_Remark__c':"", 'PAT_Remark__c':"", 'Comments_on_Profit_Loss__c':"", 'ITR_Filing_Gap_Days__c':""};
        const curreFinaRecForBalance={'Applicant_Financial__c':this.financialRecordIdForBal,'Current_Financial_Year__c':true,'Previous_Financial_Year__c':false,'Provisional_Financial_Year__c':false,'Type_of_Accounts__c':"", 'Financial_Year__c':this.currentYear, 'Date_of_Filing_ITR__c':"", 'Total_Sales__c':"", 'Other_Operating_Income_IncomeIncidental__c':"", 'Non_Operating_Income__c':"", 'Non_Business_Income__c':"", 'Opening_Stock__c':"", 'Closing_Stock__c':"", 'Purchases__c':"", 'Direct_Expenses__c':"", 'Gross_Profit__c':"", 'Office_Administrative_Expenses__c':"", 'Other_Indirect_Expenses__c':"", 'Non_Operating_Expenses_FxLoss_AssetLoss__c':"", 'Salary_to_Partner_Directors__c':"", 'EBITDA__c':"", 'Interest_on_Term_Loans__c':"", 'Interest_on_CC_OD_limits__c':"", 'Interest_on_Partner_Capital__c':"", 'Profit_Before_Depreciation_and_Tax_PBDT__c':"", 'Depreciation__c':"", 'Profit_Before_Tax__c':"", 'Taxes__c':"", 'PAT__c':"", 'Director_Partners_remuneration_Interest__c':"", 'Tax_on_Above_Income__c':"", 'Net_Income_Considered_for_Eligibility__c':"", 'Applicant_Financial__c':"", 'Total_Sales_Remark__c':"", 'Other_Operating_Income_Remark__c':"", 'Non_Operating_Income_Remark__c':"", 'Non_Business_Income_Remark__c':"", 'Opening_Stock_Remark__c':"", 'Closing_Stock_Remark__c':"", 'Purchases_Remark__c':"", 'Direct_Expenses_Remark__c':"", 'Gross_Profit_Remark__c':"", 'Office_Administrative_Expenses_Remark__c':"", 'Other_Indirect_Expenses_Remark__c':"", 'Non_Operating_Expenses_Remark__c':"", 'Salary_to_Partner_Directors_Remark__c':"", 'EBITDA_Remark__c':"", 'Interest_on_Term_Loans_Remark__c':"", 'Interest_on_CC_OD_limits_Remark__c':"", 'Interest_on_Partner_Capital_Remark__c':"", 'Profit_Before_Depreciation_PBDT_Remark__c':"", 'Depreciation_Remark__c':"", 'Profit_Before_Tax_Remark__c':"", 'Taxes_Remark__c':"", 'PAT_Remark__c':"", 'Comments_on_Profit_Loss__c':"", 'ITR_Filing_Gap_Days__c':""};
        const ProViFinaRecForBalance={'Applicant_Financial__c':this.financialRecordIdForBal,'Current_Financial_Year__c':false,'Previous_Financial_Year__c':false,'Provisional_Financial_Year__c':true,'Type_of_Accounts__c':"", 'Financial_Year__c':this.provisionalYear, 'Date_of_Filing_ITR__c':"", 'Total_Sales__c':"", 'Other_Operating_Income_IncomeIncidental__c':"", 'Non_Operating_Income__c':"", 'Non_Business_Income__c':"", 'Opening_Stock__c':"", 'Closing_Stock__c':"", 'Purchases__c':"", 'Direct_Expenses__c':"", 'Gross_Profit__c':"", 'Office_Administrative_Expenses__c':"", 'Other_Indirect_Expenses__c':"", 'Non_Operating_Expenses_FxLoss_AssetLoss__c':"", 'Salary_to_Partner_Directors__c':"", 'EBITDA__c':"", 'Interest_on_Term_Loans__c':"", 'Interest_on_CC_OD_limits__c':"", 'Interest_on_Partner_Capital__c':"", 'Profit_Before_Depreciation_and_Tax_PBDT__c':"", 'Depreciation__c':"", 'Profit_Before_Tax__c':"", 'Taxes__c':"", 'PAT__c':"", 'Director_Partners_remuneration_Interest__c':"", 'Tax_on_Above_Income__c':"", 'Net_Income_Considered_for_Eligibility__c':"", 'Applicant_Financial__c':"", 'Total_Sales_Remark__c':"", 'Other_Operating_Income_Remark__c':"", 'Non_Operating_Income_Remark__c':"", 'Non_Business_Income_Remark__c':"", 'Opening_Stock_Remark__c':"", 'Closing_Stock_Remark__c':"", 'Purchases_Remark__c':"", 'Direct_Expenses_Remark__c':"", 'Gross_Profit_Remark__c':"", 'Office_Administrative_Expenses_Remark__c':"", 'Other_Indirect_Expenses_Remark__c':"", 'Non_Operating_Expenses_Remark__c':"", 'Salary_to_Partner_Directors_Remark__c':"", 'EBITDA_Remark__c':"", 'Interest_on_Term_Loans_Remark__c':"", 'Interest_on_CC_OD_limits_Remark__c':"", 'Interest_on_Partner_Capital_Remark__c':"", 'Profit_Before_Depreciation_PBDT_Remark__c':"", 'Depreciation_Remark__c':"", 'Profit_Before_Tax_Remark__c':"", 'Taxes_Remark__c':"", 'PAT_Remark__c':"", 'Comments_on_Profit_Loss__c':"", 'ITR_Filing_Gap_Days__c':""};
        console.log('secFinanYear360'+this.currentFinanYearBalId)
        console.log('secFinanYear360'+this.previousFinanYearBalId)
        if(this.currentFinanYearBalId){
            curreFinaRecForBalance["Id"]=this.currentFinanYearBalId
        }
        if(this.previousFinanYearBalId){
            PreFinaRecForBalance["Id"]=this.previousFinanYearBalId
        }
        if(this.proviFinanYearBalId){
            ProViFinaRecForBalance["Id"]=this.proviFinanYearBalId
        }
        console.log('secFinanYear370'+records[53])
        let firstTabNotMap=['Net worth', 'Adjusted tangible Networth','Total Loan funds','Total','Difference'];
        
        
        for(let i=39; i<61; i++){
            let val=records[i]['Financials Years Data']
            let FieldsToMap=this.columnMapWithFieldForBala[val]
            if(FieldsToMap){
                console.log(FieldsToMap)
                let firstFieldToMap=FieldsToMap[0]
                let secFieldToMap=FieldsToMap[1]
                console.log('secFieldToMap'+secFieldToMap)
                console.log('firstFieldToMap'+firstFieldToMap)
                if(!records[i]['Financials Years Data'].includes(firstTabNotMap)){

                    PreFinaRecForBalance[firstFieldToMap]=records[i]['__EMPTY']
                    curreFinaRecForBalance[firstFieldToMap]=records[i]['__EMPTY_1']
                    if(this.isProvisionalAccountPre){
                        ProViFinaRecForBalance[firstFieldToMap]=records[i]['__EMPTY_3']
                        PreFinaRecForBalance[secFieldToMap]=records[i]['__EMPTY_5']
                    }else{
                        PreFinaRecForBalance[secFieldToMap]=records[i]['__EMPTY_3']
                    }
                }else{
                    if(this.isProvisionalAccountPre=='Provisional'){
                        PreFinaRecForBalance[secFieldToMap]=records[i]['__EMPTY_5']
                    }else{
                        PreFinaRecForBalance[secFieldToMap]=records[i]['__EMPTY_3']
                    }
                }
            }else{
                console.log('valvalvalvalval'+val)
               // this.showToastMessage("Error!", "error","Please Upload correct file format of Financial profit and loss and balance sheet.");

            }
        }

        for(let i=59; i<75; i++){
            let val=records[i]['Financials Years Data']
            let FieldsToMap=this.columnMapWithFieldForAsset[val]
            if(FieldsToMap){
                console.log(FieldsToMap)
                let firstFieldToMap=FieldsToMap[0]
                let secFieldToMap=FieldsToMap[1]
                //console.log('secFieldToMap>>>>>'+secFieldToMap)
                //console.log('firstFieldToMap>>>>>>>>>>>'+firstFieldToMap)
                if(!records[i]['Financials Years Data'].includes(firstTabNotMap)){

                    PreFinaRecForBalance[firstFieldToMap]=records[i]['__EMPTY']
                    curreFinaRecForBalance[firstFieldToMap]=records[i]['__EMPTY_1']
                    if(this.isProvisionalAccountPre){
                        ProViFinaRecForBalance[firstFieldToMap]=records[i]['__EMPTY_3']
                        PreFinaRecForBalance[secFieldToMap]=records[i]['__EMPTY_5']
                    }else{
                        PreFinaRecForBalance[secFieldToMap]=records[i]['__EMPTY_3']
                    }
                }else{
                    if(this.isProvisionalAccountPre){
                        PreFinaRecForBalance[secFieldToMap]=records[i]['__EMPTY_5']
                    }else{
                        PreFinaRecForBalance[secFieldToMap]=records[i]['__EMPTY_3']
                    }
                }
            }else{
                console.log('valvalvalvalval'+val)
               // this.showToastMessage("Error!", "error","Please Upload correct file format of Financial profit and loss and balance sheet.");

            }
        }
        /*console.log('curreFinaRecForBalance'+JSON.stringify(curreFinaRecForBalance))
        console.log('PreFinaRecForBalance'+JSON.stringify(PreFinaRecForBalance))
        console.log('ProViFinaRecForBalance'+JSON.stringify(ProViFinaRecForBalance))*/
        this.ListOfFinanSummforBalance.push(curreFinaRecForBalance)
        this.ListOfFinanSummforBalance.push(PreFinaRecForBalance)
        console.log('this.isProvisionalAccountPre'+this.isProvisionalAccountPre)
        if(this.isProvisionalAccountPre){
            this.ListOfFinanSummforBalance.push(ProViFinaRecForBalance)
        }
        console.log('secFinanYear699')
    

    }
    checkWord(word) {
        let worrd1=''
        if(word){
            worrd1=word.toLowerCase()
        }
        
        console.log('worrd1'+worrd1)
        if (worrd1 === 'unaudited') {
            return 'UnAudited'
        } else if(worrd1 === 'audited') {
            return 'Audited'
        }else if(worrd1 === 'provisional'){
            return 'Provisional'
        }else{
            return ''
        }
    }



    ListOfFinanSummforBalance=[];
    wrapBnkAppBnk;
    ListOfFinanSumm=[];
    currentPeriodEnd;
    currentPeriodStart
    isProvisionalAccountPre;
    createRecordForSaveForProfit(records){
      const wrapBnkAppBnk={};
       wrapBnkAppBnk["Id"]=this._applicantId;
        this.wrapBnkAppBnk=wrapBnkAppBnk
       // console.log('this.wrapBnkAppBnk'+this.finRecordIdForProfit)
        const PreFinaRecForProfit={'Applicant_Financial__c':this.finRecordIdForProfit,'Current_Financial_Year__c':false,'Previous_Financial_Year__c':true,'Provisional_Financial_Year__c':false,'Type_of_Accounts__c':"", 'Financial_Year__c':this.privousYear, 'Date_of_Filing_ITR__c':"", 'Total_Sales__c':"", 'Other_Operating_Income_IncomeIncidental__c':"", 'Non_Operating_Income__c':"", 'Non_Business_Income__c':"", 'Opening_Stock__c':"", 'Closing_Stock__c':"", 'Purchases__c':"", 'Direct_Expenses__c':"", 'Gross_Profit__c':"", 'Office_Administrative_Expenses__c':"", 'Other_Indirect_Expenses__c':"", 'Non_Operating_Expenses_FxLoss_AssetLoss__c':"", 'Salary_to_Partner_Directors__c':"", 'EBITDA__c':"", 'Interest_on_Term_Loans__c':"", 'Interest_on_CC_OD_limits__c':"", 'Interest_on_Partner_Capital__c':"", 'Profit_Before_Depreciation_and_Tax_PBDT__c':"", 'Depreciation__c':"", 'Profit_Before_Tax__c':"", 'Taxes__c':"", 'PAT__c':"", 'Director_Partners_remuneration_Interest__c':"", 'Tax_on_Above_Income__c':"", 'Net_Income_Considered_for_Eligibility__c':"", 'Applicant_Financial__c':"", 'Total_Sales_Remark__c':"", 'Other_Operating_Income_Remark__c':"", 'Non_Operating_Income_Remark__c':"", 'Non_Business_Income_Remark__c':"", 'Opening_Stock_Remark__c':"", 'Closing_Stock_Remark__c':"", 'Purchases_Remark__c':"", 'Direct_Expenses_Remark__c':"", 'Gross_Profit_Remark__c':"", 'Office_Administrative_Expenses_Remark__c':"", 'Other_Indirect_Expenses_Remark__c':"", 'Non_Operating_Expenses_Remark__c':"", 'Salary_to_Partner_Directors_Remark__c':"", 'EBITDA_Remark__c':"", 'Interest_on_Term_Loans_Remark__c':"", 'Interest_on_CC_OD_limits_Remark__c':"", 'Interest_on_Partner_Capital_Remark__c':"", 'Profit_Before_Depreciation_PBDT_Remark__c':"", 'Depreciation_Remark__c':"", 'Profit_Before_Tax_Remark__c':"", 'Taxes_Remark__c':"", 'PAT_Remark__c':"", 'Comments_on_Profit_Loss__c':"", 'ITR_Filing_Gap_Days__c':""};
        const curreFinaRecForProfit={'Applicant_Financial__c':this.finRecordIdForProfit,'Current_Financial_Year__c':true,'Previous_Financial_Year__c':false,'Provisional_Financial_Year__c':false,'Type_of_Accounts__c':"", 'Financial_Year__c':this.currentYear, 'Date_of_Filing_ITR__c':"", 'Total_Sales__c':"", 'Other_Operating_Income_IncomeIncidental__c':"", 'Non_Operating_Income__c':"", 'Non_Business_Income__c':"", 'Opening_Stock__c':"", 'Closing_Stock__c':"", 'Purchases__c':"", 'Direct_Expenses__c':"", 'Gross_Profit__c':"", 'Office_Administrative_Expenses__c':"", 'Other_Indirect_Expenses__c':"", 'Non_Operating_Expenses_FxLoss_AssetLoss__c':"", 'Salary_to_Partner_Directors__c':"", 'EBITDA__c':"", 'Interest_on_Term_Loans__c':"", 'Interest_on_CC_OD_limits__c':"", 'Interest_on_Partner_Capital__c':"", 'Profit_Before_Depreciation_and_Tax_PBDT__c':"", 'Depreciation__c':"", 'Profit_Before_Tax__c':"", 'Taxes__c':"", 'PAT__c':"", 'Director_Partners_remuneration_Interest__c':"", 'Tax_on_Above_Income__c':"", 'Net_Income_Considered_for_Eligibility__c':"", 'Applicant_Financial__c':"", 'Total_Sales_Remark__c':"", 'Other_Operating_Income_Remark__c':"", 'Non_Operating_Income_Remark__c':"", 'Non_Business_Income_Remark__c':"", 'Opening_Stock_Remark__c':"", 'Closing_Stock_Remark__c':"", 'Purchases_Remark__c':"", 'Direct_Expenses_Remark__c':"", 'Gross_Profit_Remark__c':"", 'Office_Administrative_Expenses_Remark__c':"", 'Other_Indirect_Expenses_Remark__c':"", 'Non_Operating_Expenses_Remark__c':"", 'Salary_to_Partner_Directors_Remark__c':"", 'EBITDA_Remark__c':"", 'Interest_on_Term_Loans_Remark__c':"", 'Interest_on_CC_OD_limits_Remark__c':"", 'Interest_on_Partner_Capital_Remark__c':"", 'Profit_Before_Depreciation_PBDT_Remark__c':"", 'Depreciation_Remark__c':"", 'Profit_Before_Tax_Remark__c':"", 'Taxes_Remark__c':"", 'PAT_Remark__c':"", 'Comments_on_Profit_Loss__c':"", 'ITR_Filing_Gap_Days__c':""};
        const ProViFinaRecForProfit={'Applicant_Financial__c':this.finRecordIdForProfit,'Current_Financial_Year__c':false,'Previous_Financial_Year__c':false,'Provisional_Financial_Year__c':true,'Type_of_Accounts__c':"", 'Financial_Year__c':this.provisionalYear, 'Date_of_Filing_ITR__c':"", 'Total_Sales__c':"", 'Other_Operating_Income_IncomeIncidental__c':"", 'Non_Operating_Income__c':"", 'Non_Business_Income__c':"", 'Opening_Stock__c':"", 'Closing_Stock__c':"", 'Purchases__c':"", 'Direct_Expenses__c':"", 'Gross_Profit__c':"", 'Office_Administrative_Expenses__c':"", 'Other_Indirect_Expenses__c':"", 'Non_Operating_Expenses_FxLoss_AssetLoss__c':"", 'Salary_to_Partner_Directors__c':"", 'EBITDA__c':"", 'Interest_on_Term_Loans__c':"", 'Interest_on_CC_OD_limits__c':"", 'Interest_on_Partner_Capital__c':"", 'Profit_Before_Depreciation_and_Tax_PBDT__c':"", 'Depreciation__c':"", 'Profit_Before_Tax__c':"", 'Taxes__c':"", 'PAT__c':"", 'Director_Partners_remuneration_Interest__c':"", 'Tax_on_Above_Income__c':"", 'Net_Income_Considered_for_Eligibility__c':"", 'Applicant_Financial__c':"", 'Total_Sales_Remark__c':"", 'Other_Operating_Income_Remark__c':"", 'Non_Operating_Income_Remark__c':"", 'Non_Business_Income_Remark__c':"", 'Opening_Stock_Remark__c':"", 'Closing_Stock_Remark__c':"", 'Purchases_Remark__c':"", 'Direct_Expenses_Remark__c':"", 'Gross_Profit_Remark__c':"", 'Office_Administrative_Expenses_Remark__c':"", 'Other_Indirect_Expenses_Remark__c':"", 'Non_Operating_Expenses_Remark__c':"", 'Salary_to_Partner_Directors_Remark__c':"", 'EBITDA_Remark__c':"", 'Interest_on_Term_Loans_Remark__c':"", 'Interest_on_CC_OD_limits_Remark__c':"", 'Interest_on_Partner_Capital_Remark__c':"", 'Profit_Before_Depreciation_PBDT_Remark__c':"", 'Depreciation_Remark__c':"", 'Profit_Before_Tax_Remark__c':"", 'Taxes_Remark__c':"", 'PAT_Remark__c':"", 'Comments_on_Profit_Loss__c':"", 'ITR_Filing_Gap_Days__c':""};
       // console.log('records[1][]'+records[1]['__EMPTY']);
        //console.log('curreFinaRecForProfit.Type_of_Accounts__c'+curreFinaRecForProfit.Type_of_Accounts__c)
        PreFinaRecForProfit.Applicant_Financial__c=this.finRecordIdForProfit
        curreFinaRecForProfit.Applicant_Financial__c=this.finRecordIdForProfit
        ProViFinaRecForProfit.Applicant_Financial__c=this.finRecordIdForProfit
        if(this.currentFinanYearProfitId){
            curreFinaRecForProfit["Id"]=this.currentFinanYearProfitId
        }
        if(this.previousFinanYearProfitId){
            PreFinaRecForProfit["Id"]=this.previousFinanYearProfitId
        }
        if(this.proviFinanYearProfitId){
            ProViFinaRecForProfit["Id"]=this.proviFinanYearProfitId
        }
        //console.log('curreFinaRecForProfit.Id'+curreFinaRecForProfit.Id)
        debugger
        console.log('records[1]'+records[1]['__EMPTY'])
        console.log('records[2]['+records[1]['__EMPTY_1'])
       console.log('2records[2]['+records[1]['__EMPTY_2'])
        PreFinaRecForProfit.Type_of_Accounts__c=records[1]['__EMPTY'] !=='undefined' ?  this.checkWord(records[1]['__EMPTY']): "";
        curreFinaRecForProfit.Type_of_Accounts__c=records[1]['__EMPTY_1'] !=='undefined' ?  this.checkWord(records[1]['__EMPTY_1']): "";
        ProViFinaRecForProfit.Type_of_Accounts__c=records[1]['__EMPTY_2'] !=='undefined' ?  this.checkWord(records[1]['__EMPTY_2']): "";
        
       // console.log('3records[2]['+records[2]['__EMPTY_2'])

       if(records[2]['__EMPTY']){
        console.log('this.convertToDate(records[2][])'+this.convertToDate(records[2]['__EMPTY']))
            PreFinaRecForProfit.Date_of_Filing_ITR__c=records[2]['__EMPTY'] !=='undefined' ?  this.convertToDate(records[2]['__EMPTY']): "";
       }
       if(records[2]['__EMPTY_1']){
        console.log('this.convertToDate(records[2][])'+this.convertToDate(records[2]['__EMPTY_1']))
        curreFinaRecForProfit.Date_of_Filing_ITR__c=records[2]['__EMPTY_1'] !=='undefined' ?  this.convertToDate(records[2]['__EMPTY_1']): "";
         }
        
        //console.log('376')
        if(ProViFinaRecForProfit.Type_of_Accounts__c==='Provisional'){
           // ProViFinaRecForProfit.Date_of_Filing_ITR__c=records[2]['__EMPTY_2'] !=='undefined' ?  this.getDateformat(records[2]['__EMPTY_2']): "";
           this.isProvisionalAccountPre=true;
            //curreFinaRecForProfit.ITR_Filing_Gap_Days__c=records[2]['__EMPTY_3'] !=='undefined' ?  records[2]['__EMPTY_1']: "";
        }else{
            this.isProvisionalAccountPre=false;
           // console.log('376')
           // curreFinaRecForProfit.ITR_Filing_Gap_Days__c=records[2]['__EMPTY_2'] !=='undefined' ?  records[2]['__EMPTY_2']: "";
        }
        //console.log('376')
        let firstTabNotMap=['Non Operating Income', 'Gross Profit','EBITDA','Profit Before Depreciation & Tax (PBDT)','Profit Before Tax (PBT)','PAT'];
       // console.log('records[i]records[i]records[i]'+JSON.stringify(records[26]))
        for(let i=4; i<26; i++){
            let val=records[i]['Financials Years Data']
            //console.log('inLine1139'+val)
            //console.log('inLine1139'+this.columnMapWithFieldForProfit["Salary To Partners/Directors"])
             let FieldsToMap=this.columnMapWithFieldForProfit[val]
            if(FieldsToMap){
               // console.log('FieldsToMapFieldsToMap'+FieldsToMap)
                let firstFieldToMap=FieldsToMap[0]
                let secFieldToMap=FieldsToMap[1]
                //console.log('firstFieldToMap'+firstFieldToMap)
                //console.log('secFieldToMap'+secFieldToMap)
                if(!records[i]['Financials Years Data'].includes(firstTabNotMap)){

                    PreFinaRecForProfit[firstFieldToMap]=records[i]['__EMPTY']
                    curreFinaRecForProfit[firstFieldToMap]=records[i]['__EMPTY_1']
                    if(ProViFinaRecForProfit.Type_of_Accounts__c=='Provisional'){
                        ProViFinaRecForProfit[firstFieldToMap]=records[i]['__EMPTY_3']
                        curreFinaRecForProfit[secFieldToMap]=records[i]['__EMPTY_5']
                    }else{
                        curreFinaRecForProfit[secFieldToMap]=records[i]['__EMPTY_3']
                    }
                }else{
                    if(ProViFinaRecForProfit.Type_of_Accounts__c=='Provisional'){
                        curreFinaRecForProfit[secFieldToMap]=records[i]['__EMPTY_5']
                    }else{
                        curreFinaRecForProfit[secFieldToMap]=records[i]['__EMPTY_3']
                    }
                }
            }else{
               // console.log('valvalvalvalval'+val)
                if(records[i]['Financials Years Data'] =='Salary To Partners/Directors'){
                    PreFinaRecForProfit.Salary_to_Partner_Directors__c=records[i]['__EMPTY']
                    curreFinaRecForProfit.Salary_to_Partner_Directors__c=records[i]['__EMPTY_1']
                    if(ProViFinaRecForProfit.Type_of_Accounts__c=='Provisional'){
                        ProViFinaRecForProfit.Salary_to_Partner_Directors__c=records[i]['__EMPTY_3']
                        curreFinaRecForProfit.Salary_to_Partner_Directors_Remark__c=records[i]['__EMPTY_5']
                    }else{
                        curreFinaRecForProfit.Salary_to_Partner_Directors_Remark__c=records[i]['__EMPTY_3']
                    }
                   
                }
            }
        }
       // console.log('in120000')
        for(let i=27; i<30; i++){
            let val=records[i]['Financials Years Data']
            let FieldsToMap=this.columnMapFieldForProfitTab2[val]
            if(FieldsToMap){
               let firstFieldToMap=FieldsToMap[0]
              //  let secFieldToMap=FieldsToMap[1]
                if(!records[i]['Financials Years Data'].includes(firstTabNotMap)){
                    PreFinaRecForProfit[firstFieldToMap]=records[i]['__EMPTY']
                    curreFinaRecForProfit[firstFieldToMap]=records[i]['__EMPTY_1']
                    if(ProViFinaRecForProfit.Type_of_Accounts__c=='Provisional'){
                        ProViFinaRecForProfit[firstFieldToMap]=records[i]['__EMPTY_2']
                       // curreFinaRecForProfit[secFieldToMap]=records[i]['__EMPTY_5']
                    }else{
                       // curreFinaRecForProfit[secFieldToMap]=records[i]['__EMPTY_2']
                    }
                }else{
                    if(ProViFinaRecForProfit.Type_of_Accounts__c=='Provisional'){
                        //curreFinaRecForProfit[secFieldToMap]=records[i]['__EMPTY_5']
                    }else{
                        //curreFinaRecForProfit[secFieldToMap]=records[i]['__EMPTY_3']
                    }
                }
            }else{
              //  console.log('1218'+val)
                
            }
        }

        for(let i=31; i<34; i++){
            let val=records[i]['Financials Years Data']
            let FieldsToMap=this.columnMapWithFieldForTab3Pro[val]
            //console.log('FieldsToMap'+FieldsToMap)
            if(FieldsToMap){
               let firstFieldToMap=FieldsToMap[0]
                let secFieldToMap=FieldsToMap[1]
               // console.log('firstFieldToMap'+firstFieldToMap)
                //console.log('secFieldToMap'+secFieldToMap)
                if(!records[i]['Financials Years Data'].includes(firstTabNotMap)){
                PreFinaRecForProfit[firstFieldToMap]=records[i]['__EMPTY']
                    curreFinaRecForProfit[firstFieldToMap]=records[i]['__EMPTY_1']
                    if(ProViFinaRecForProfit.Type_of_Accounts__c=='Provisional'){
                        ProViFinaRecForProfit[firstFieldToMap]=records[i]['__EMPTY_2']
                        //curreFinaRecForProfit[secFieldToMap]=records[i]['__EMPTY_5']
                    }else{
                        //curreFinaRecForProfit[secFieldToMap]=records[i]['__EMPTY_3']
                    }
                }else{
                    if(ProViFinaRecForProfit.Type_of_Accounts__c=='Provisional'){
                        //curreFinaRecForProfit[secFieldToMap]=records[i]['__EMPTY_5']
                    }else{
                        //curreFinaRecForProfit[secFieldToMap]=records[i]['__EMPTY_3']
                    }
                }
            }else{
              //  console.log('1218'+val)
                
            }
        }
        this.ListOfFinanSumm.push(curreFinaRecForProfit)
        this.ListOfFinanSumm.push(PreFinaRecForProfit)
        if(ProViFinaRecForProfit.Type_of_Accounts__c=='Provisional'){
            this.ListOfFinanSumm.push(ProViFinaRecForProfit)
        }
        /*console.log('ProViFinaRecForProfit'+JSON.stringify(ProViFinaRecForProfit));
        console.log('curreFinaRecForProfit'+JSON.stringify(curreFinaRecForProfit));
        console.log('PreFinaRecForProfit'+JSON.stringify(PreFinaRecForProfit));*/
       this.handleSaveDataForProfit();
    }

    handleSaveDataForProfit(){
        //console.log('669')
        let ChildRecords = [];
        let DataRecords = [];
        let upsertDataList=[];
        let childRecordObj = {};
        //console.log('669'+JSON.stringify(this.FinanRecForProft))
        this.FinanRecForProft["sobjectType"]='Applicant_Financial__c'; 
        //console.log('673')
        if(this.ListOfFinanSumm){
            for(var i=0;i<this.ListOfFinanSumm.length;i++){
            childRecordObj = {...this.ListOfFinanSumm[i]};
            childRecordObj.sobjectType='Applicant_Financial_Summary__c',
            ChildRecords.push(childRecordObj);
           }  
        }
        console.log('ChildRecordsChildRecordsproft'+JSON.stringify(ChildRecords))
        let upsertData={                       
            parentRecord:this.FinanRecForProft,                       
            ChildRecords:ChildRecords,
            ParentFieldNameToUpdate:'Applicant_Financial__c'
        }
       // console.log('687')
        upsertSobjDataWIthRelatedChilds ({upsertData:upsertData})
            .then(result => {  
               // console.log('inhandleSaveeee')
                //this.showSpinner=false;
                this.profitSaved=true
                this.handleSaveDataForBal();
               // this.showToastMessage("Success!", "success","Upload Profit & Loss And Balance Sheet uploded Successfully.", "sticky");

            }).catch(error => {
                this.profitSaved=false
               console.log('errorerrorerrorerror1234'+JSON.stringify(error));
               this.showSpinner=false;
               this.showToastMessage("Error!", "error","Please Upload correct file format of Financial profit and loss and balance sheet. Error:"+error);
                if(error.body && error.body.message.includes("Unable to read SObject")){
                    this.showToastMessage("Error!", "error","Please Upload correct file format of Financial profit and loss and balance sheet.");
                   // this.profitError='Please Upload correct file format of Financial profit and loss and balance sheet.'
                }
                

        })
    }
    profitError;
    profitSaved;
    handleSaveDataForBal(){
        let ChildRecords = [];
        let DataRecords = [];
        let upsertDataList=[];
        let childRecordObj = {};
        
        this.finanacialRecForBal["sobjectType"]='Applicant_Financial__c'; 
        
        if(this.ListOfFinanSummforBalance){
            for(var i=0;i<this.ListOfFinanSummforBalance.length;i++){
            childRecordObj = {...this.ListOfFinanSummforBalance[i]};
            childRecordObj.sobjectType='Applicant_Financial_Summary__c',
            ChildRecords.push(childRecordObj);
           }  
        }
        console.log('ChildRecordsChildRecords'+JSON.stringify(ChildRecords))
        let upsertData={                       
            parentRecord:this.finanacialRecForBal,                       
            ChildRecords:ChildRecords,
            ParentFieldNameToUpdate:'Applicant_Financial__c'
        }
        upsertSobjDataWIthRelatedChilds ({upsertData:upsertData})
            .then(result => {  
                console.log('inhandleSaveeee')
                this.showSpinner=false;
                this.uploadedFiles=''
                this.showUploadComp=false
                const toClosePopUp = new CustomEvent('toclosepopup', {
                });
                this.dispatchEvent(toClosePopUp);
               
                    this.showToastMessage("Success!", "success","Upload Profit & Loss And Balance Sheet uploded Successfully.", "sticky");
            
            }).catch(error => {
                
                console.log('errorerrorerrorerror'+JSON.stringify(error));
                this.showToastMessage("Error!", "error","Please Upload correct file format of Financial profit and loss and balance sheet. Error:"+error);
                this.showSpinner=false;

        })
    }


    convertToDate(input) {
        // Check if input is already in yyyy-mm-dd format
        if (/^\d{4}-\d{2}-\d{2}$/.test(input)) {
            return input; // Return as is
        }
    
        // Check if input is in the format of a number (e.g., 45432)
        if (!isNaN(input) && isFinite(input)) {
            const excelSerialDate = parseInt(input);
            const millisecondsInDay = 24 * 60 * 60 * 1000; // Number of milliseconds in a day
            const dateOffset = (excelSerialDate - 25569) * millisecondsInDay; // Offset from 1/1/1970
            const targetDate = new Date(dateOffset);
            const month = targetDate.getMonth() + 1; // Month is zero-based, so add 1
            const day = targetDate.getDate();
            const year = targetDate.getFullYear();
            const formattedDate = `${month.toString().padStart(2, '0')}/${day.toString().padStart(2, '0')}/${year}`;
            return formattedDate;
        }
    }    
    monthNDyEar;
    getDate(date){
       if(this.isMonthYearFormat(date)){
            this.monthNDyEar=dateOfPeriod
        }else{
            var dateFormat=this.convertDate(date);
            this.monthNDyEar=this.getFormattedDate(dateFormat);
           
        }
        return this.monthNDyEar;
    }
    getDateformat(date){
        if(this.isMonthYearFormat(date)){
            return date; 
        }else{
            var dateFormat=this.convertDate(date);
            return dateFormat; 
         }
         
     }
    isMonthYearFormat(dateString) {
        return /^[A-Z]{3}-\d{4}$/.test(dateString);
    }
    convertDate(originalDate) {
        const excelSerialDate = parseInt(originalDate);
        const millisecondsInDay = 24 * 60 * 60 * 1000; // Number of milliseconds in a day
        const dateOffset = (excelSerialDate - 25569) * millisecondsInDay; // Offset from 1/1/1970
        const targetDate = new Date(dateOffset);
        const month = targetDate.getMonth() + 1; // Month is zero-based, so add 1
        const day = targetDate.getDate();
        const year = targetDate.getFullYear();
        const formattedDate = `${month.toString().padStart(2, '0')}/${day.toString().padStart(2, '0')}/${year}`;
        return formattedDate;
    }
    getFormattedDate(dateFormat) {
        const dateParts = dateFormat.split('/');
        const monthNumber = parseInt(dateParts[0]);
        const year = dateParts[2];
        const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
        const monthAbbreviation = months[monthNumber - 1];
        return `${monthAbbreviation}-${year}`;
    }

}