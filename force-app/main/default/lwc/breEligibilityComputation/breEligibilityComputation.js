import { LightningElement, api, track, wire } from 'lwc';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import fetchPropRecords from '@salesforce/apex/EligibilityScreenPropertyDetails.fetchPropRecords';
import fetchPropRecordsNonCacheable from '@salesforce/apex/EligibilityScreenPropertyDetails.fetchPropRecordsNonCacheable';
import { refreshApex } from '@salesforce/apex';

export default class BreEligibilityComputation extends LightningElement {

  // @api applicantId;
  // @api isvalid;
  @track monthlyBusinessIncomeRowSpace;
  @track wrapPropObj = [];
  @track totalAnnualBaseIncm = [];
  @track totalAvrgAnnualBaseIncm;
  @track averagesOfProfitLoss = {};
  @track eliWrapObj = {};
  @track profitBfrTax;
  @track _applicantId;
  @api get applicantId() {
    return this._applicantId;
  }
  set applicantId(value) {
    this._applicantId = value;
    this.handleBRERecordChange(value);
    // this.handleBRESalaryRecordChange(value);

    // this.setAttribute("applicantId", value);
    // this.handleApplicantIdChange(value);
  }



  // Watch for changes in the isBooleanTrue attribute
  @track previousValue = false;
  @api get isBooleanTrue() {
    return this.previousValue;
  }
  set isBooleanTrue(value) {
    if (value !== this.previousValue) {
      this.previousValue = value;

      // Call your method when the boolean value becomes true
      if (value) {
        this.propertyMethod();
      }
    }
  }
  connectedCallback() {
    // this.propertyMethod();
    console.log('_applicantId>>>>>>>>', this._applicantId);
    console.log('isvalid>>>>>>>>', this.isvalid);
  }
  // @track RecordTypePL = 'Profit & Loss';

  // @track
  // parameter = {
  //   ParentObjectName: 'Applicant_Financial_Summary__c ',
  //   ChildObjectRelName: '',
  //   parentObjFields: [ 'Id','Profit_Before_Tax__c','Depreciation__c','Interest_on_Partner_Capital__c','Interest_on_Term_Loans__c','Taxes__c','FinancialYearFor__c', 'Financial_Year__c','Applicant_Financial__r.RecordType.Name','Applicant_Financial__r.Loan_Applicant__r.LoanAppln__c','Applicant_Financial__r.Loan_Applicant__r.ApplType__c','Applicant_Financial__r.Loan_Applicant__r.FullName__c'],
  //   childObjFields: [],
  //   queryCriteria: ''
  // }
  // //Applicant_Financial__r.RecordType.Name='Profit & Loss' AND Applicant_Financial__r.Loan_Applicant__c='a0AC4000000DwqzMAC'
  // //select id,EligIncome__c, Eligibilityper__c,IncomeProgram__c,Type__c,Applicant__c,LoanApp__c from BRE_Eligibility__c where Type__c='Applicant' AND Applicant__c !=null
  // handleBRERecordChange() {
  //   let tempParams = this.parameter;
  //   tempParams.queryCriteria = 'WHERE Applicant_Financial__r.Loan_Applicant__c=\'' + this._applicantId + '\' AND Applicant_Financial__r.RecordType.Name=\'' + this.RecordTypePL + '\'';
  //   this.parameter = { ...tempParams };
  // //  FROM Applicant_Financial_Summary__c Where Applicant_Financial__r.RecordType.Name='Profit & Loss' AND Applicant_Financial__r.Loan_Applicant__r.LoanAppln__c
  // }

  // @wire(getSobjectData, { params: '$parameter' })
  // handleBREResponse(wiredResultBRE) {
  //   let { error, data } = wiredResultBRE;
  //   if (data) {
  //     console.log('bre data>>>>>>>>>', data.parentRecords.length);
  //     if (data.parentRecords.length > 0) {
  //       console.log('bre response data available>>>>');
  //         this.wrapPropObj.push(data.parentRecords);
  //       let financialArray = data.parentRecords;
  //       console.log('breDataArray>>>>>', financialArray);

  //       const { length } = financialArray;

  //       financialArray.forEach(obj => {
  //         Object.keys(obj).forEach(key => {
  //           if (typeof obj[key] === 'number') {
  //             this.averagesOfProfitLoss[key] = (this.averagesOfProfitLoss[key] || 0) + obj[key] / length;
  //           }
  //         });
  //       });
  //       console.log('averages of>>>>', this.averagesOfProfitLoss);



  //       financialArray.forEach(obj => {
  //         // Calculate the total for each property
  //         const total = (
  //           obj.Profit_Before_Tax__c +
  //           obj.Depreciation__c +
  //           obj.Interest_on_Partner_Capital__c +
  //           obj.Interest_on_Term_Loans__c
  //         );

  //         // Subtract Taxes__c
  //         const result = total - obj.Taxes__c;
  //         console.log('result>>>>>>', result);
  //         // Add the result to the object
  //         this.totalAnnualBaseIncm.push(result);
  //       });
  //       console.log('this.totalResult>>>>>>', this.totalAnnualBaseIncm);


  //       const sum = Object.keys(this.averagesOfProfitLoss)
  //         .filter(key => key !== "Taxes__c")
  //         .reduce((acc, key) => acc + this.averagesOfProfitLoss[key], 0);

  //       // Subtract Taxes__c from the sum
  //       const resultOfAverage = sum - this.averagesOfProfitLoss["Taxes__c"];
  //       this.totalAvrgAnnualBaseIncm = resultOfAverage;

  //     }
  //   } else if (error) {
  //     console.error('Error BRE data ------------->', error);
  //   }
  // }


  @api propertyMethod() {
    console.log('property method called');
    this.wrapPropObj = [];
    this.totalAnnualBaseIncm =[]
    fetchPropRecordsNonCacheable({ applId: this._applicantId })
      .then(result => {
        console.log('Result of list property', result);

        let allPropWrapDataa = JSON.parse(result);
        console.log('allEligibiltyWrapDataa>>>>', allPropWrapDataa);
        this.wrapPropObj = { ...allPropWrapDataa };
        console.log('this.wrapPropObj>>>>', this.wrapPropObj);

        let propetyArray = allPropWrapDataa.propertyList;
        console.log('propetyArray>>>>>', propetyArray);



        const totalsProperty = propetyArray.reduce((accumulator, item) => {
          // Check if the variables are not null and are valid numbers
          if (item.ApproxValue !== null && !isNaN(item.ApproxValue)) {
            accumulator.Apprvalue = (accumulator.ApproxValue || 0) + item.ApproxValue;
          } else {
            accumulator.Apprvalue = 0;
          }

          if (item.AddLTVBsdEliIns !== null && !isNaN(item.AddLTVBsdEliIns)) {
            accumulator.AddLTVBsdEliIns = (accumulator.AddLTVBsdEliIns || 0) + item.AddLTVBsdEliIns;
          } else {
            accumulator.AddLTVBsdEliIns = 0;
          }


          return accumulator;
        }, {});

        if (totalsProperty.Apprvalue != undefined) {
          this.totalApproxValue = totalsProperty.Apprvalue;
        } else {
          this.totalApproxValue = 0;
        }
        if (totalsProperty.AddLTVBsdEliIns != undefined) {
          this.totalAddLTVBsdEliIns = totalsProperty.AddLTVBsdEliIns;
        } else {
          this.totalAddLTVBsdEliIns = 0;
        }

        console.log('totalsProperty>>>>>>', totalsProperty);
        console.log('  this.totalApproxValue value >>>>', totalsProperty.Apprvalue);

        // for profit and loss table code started 
        if (this.wrapPropObj && this.wrapPropObj.applFinanacialObj && this.wrapPropObj.applFinanacialObj.length > 0) {
          this.monthlyBusinessIncomeRowSpace = (this.wrapPropObj.applFinanacialObj.length) + 2;
        } else {
          this.monthlyBusinessIncomeRowSpace = 2;
        }

        console.log('this.monthlyBusinessIncomeRowSpace', this.monthlyBusinessIncomeRowSpace);
        if (this.wrapPropObj && this.wrapPropObj.applFinanacialObj && this.wrapPropObj.applFinanacialObj.length > 0) {
          this.applName = this.wrapPropObj.applFinanacialObj[0].Applicant_Financial__r.Loan_Applicant__r.FullName__c;
        }

        console.log('this.applName>>>>', this.applName);
        let financialArray = allPropWrapDataa.applFinanacialObj;

        console.log('financialArray>>>>>>>>>', financialArray);
        const { length } = financialArray;

        if (financialArray.length > 0) {
          const filteredArray = financialArray.filter(obj => obj.Provisional_Financial_Year__c === false);

          console.log('filteredArray>>>>>>>>>', JSON.stringify(filteredArray));

          if (filteredArray.length > 0) {
            filteredArray.forEach(obj => {
              Object.keys(obj).forEach(key => {
                if (typeof obj[key] === 'number') {
                  // Calculate the average and round to 2 decimal places
                  const average = ((this.averagesOfProfitLoss[key] || 0) + obj[key] / filteredArray.length);
                  this.averagesOfProfitLoss[key] = parseFloat(average.toFixed(2));
                }
              });
            });
          }
        }

        console.log('averages of>>>>', this.averagesOfProfitLoss);
        if (this.averagesOfProfitLoss === null || Object.keys(this.averagesOfProfitLoss).length === 0) {
          this.averagesOfProfitLoss.Profit_Before_Tax__c = 0;
          this.averagesOfProfitLoss.Depreciation__c = 0;
          this.averagesOfProfitLoss.Interest_on_Partner_Capital__c = 0;
          this.averagesOfProfitLoss.Interest_on_Term_Loans__c = 0;
          this.averagesOfProfitLoss.Taxes__c = 0;

        }
        console.log('this.averagesOfProfitLoss >>>>>>', this.averagesOfProfitLoss);

        if (financialArray.length > 0) {
          financialArray.forEach(obj => {
            // Calculate the total for each property
            let total = (
              obj.Profit_Before_Tax__c +
              obj.Depreciation__c +
              obj.Interest_on_Partner_Capital__c +
              obj.Interest_on_Term_Loans__c
            );
            console.log('total annualbaseincome', total);
            // Subtract Taxes__c
            let result = total - obj.Taxes__c;
            console.log('result>>>>>>', result);
            // Add the result to the object
            this.totalAnnualBaseIncm.push(result);
          });
        }

        console.log('this.totalResult>>>>>>', this.totalAnnualBaseIncm);


        const sum = Object.keys(this.averagesOfProfitLoss)
          .filter(key => key !== "Taxes__c")
          .reduce((acc, key) => acc + this.averagesOfProfitLoss[key], 0);

        // Subtract Taxes__c from the sum
        const resultOfAverage = sum - this.averagesOfProfitLoss["Taxes__c"];
        console.log('resultOfAverage>>>>>>', resultOfAverage);
        if (!isNaN(resultOfAverage)) {
          this.totalAvrgAnnualBaseIncm = resultOfAverage.toFixed(2);
        } else {
          this.totalAvrgAnnualBaseIncm = 0;
        }


      })
      .catch(error => {
        console.error('Error:', error);
      });
  }

  @track eligibilityType = 'Applicant';
  @track islatestTrue = true;
  //   this._applicantId 
  // @track applic = 'a0AC4000000Gq13MAC'

  @track
  parameter = {
    ParentObjectName: 'BRE_Eligibility__c ',
    ChildObjectRelName: '',
    parentObjFields: ['Id', 'EligIncome__c', 'Eligibilityper__c', 'IncomeProgram__c', 'Type__c', 'Applicant__c', 'LoanApp__c', 'IsLatest__c'],
    childObjFields: [],
    queryCriteria: ''
  }
  //Applicant_Financial__r.RecordType.Name='Profit & Loss' AND Applicant_Financial__r.Loan_Applicant__c='a0AC4000000DwqzMAC'
  //select id,EligIncome__c, Eligibilityper__c,IncomeProgram__c,Type__c,Applicant__c,LoanApp__c from BRE_Eligibility__c where Type__c='Applicant' AND Applicant__c !=null
  //  @api
  handleBRERecordChange() {
    console.log('bre method called');
    let tempParams = this.parameter;
    tempParams.queryCriteria = 'WHERE Applicant__c=\'' + this._applicantId + '\' AND Type__c=\'' + this.eligibilityType + '\'AND IsLatest__c=' + this.islatestTrue;
    this.parameter = { ...tempParams };
    //  FROM Applicant_Financial_Summary__c Where Applicant_Financial__r.RecordType.Name='Profit & Loss' AND Applicant_Financial__r.Loan_Applicant__r.LoanAppln__c
  }

  @track breAllData;
  @wire(getSobjectData, { params: '$parameter' })
  handleBREResponse(wiredResultBRE) {
    let { error, data } = wiredResultBRE;
    this.breAllData = wiredResultBRE;
    //console.log('Called------>'+JSON.stringify(wiredResultBRE));
    if (data) {
      console.log('bre data>>>>>>>>>', JSON.stringify(data));
      if (Object.keys(data).length > 0) {


        if (data.parentRecords && (data.parentRecords.length > 0 || data.parentRecords != undefined)) {
          let breEligibilityIncome = data.parentRecords;
          console.log('breEligibilityIncome>>', breEligibilityIncome);
          breEligibilityIncome.forEach(element => {
            if (element.IncomeProgram__c == 'Profit Before Tax') {
              this.eliWrapObj.eliPercentageProfBTax = element.Eligibilityper__c != null ? element.Eligibilityper__c : 0;
              this.eliWrapObj.eliIncomeProfBTax = element.EligIncome__c != null ? parseFloat(element.EligIncome__c).toFixed(2) : 0;
            }
            if (element.IncomeProgram__c == 'Depreciation') {
              this.eliWrapObj.eliPercentageDepr = element.Eligibilityper__c != null ? element.Eligibilityper__c : 0;
              this.eliWrapObj.eliIncomeDepr = element.EligIncome__c != null ? parseFloat(element.EligIncome__c).toFixed(2) : 0;
            }
            if (element.IncomeProgram__c == 'Interest on Partners Capital & Renumeration Income') {
              this.eliWrapObj.eliPercentageInsCap = element.Eligibilityper__c != null ? element.Eligibilityper__c : 0;
              this.eliWrapObj.eliIncomeInsCap = element.EligIncome__c != null ? parseFloat(element.EligIncome__c).toFixed(2) : 0;
            }
            if (element.IncomeProgram__c == 'Interest on Loan') {
              this.eliWrapObj.eliPercentageInsLn = element.Eligibilityper__c != null ? element.Eligibilityper__c : 0;
              this.eliWrapObj.eliIncomeInsLn = element.EligIncome__c != null ? parseFloat(element.EligIncome__c).toFixed(2) : 0;
            }
            if (element.IncomeProgram__c == 'Tax') {

              this.eliWrapObj.eliPercentageTax = element.Eligibilityper__c != null ? element.Eligibilityper__c : 0;
              this.eliWrapObj.eliIncomeTax = element.EligIncome__c != null ? parseFloat(element.EligIncome__c).toFixed(2) : 0;

            }
            if (element.IncomeProgram__c == 'Annual Business income - Regular Income Program (P&L) - ₹') {
              this.eliWrapObj.eliIncomeRegIncmPrgm = element.EligIncome__c != null ? parseFloat(element.EligIncome__c).toFixed(2) : 0;
            }
            if (element.IncomeProgram__c == 'Monthly Business income - Regular Income Program (P&L) - ₹') {
              this.eliWrapObj.eliIncomeMonthBussIncmPrgm = element.EligIncome__c != null ? parseFloat(element.EligIncome__c).toFixed(2) : 0;
            }

          });
        }
      } else {
        this.eliWrapObj.eliPercentageProfBTax = 0;
        this.eliWrapObj.eliIncomeProfBTax = 0
        this.eliWrapObj.eliPercentageDepr = 0;
        this.eliWrapObj.eliIncomeDepr = 0;
        this.eliWrapObj.eliPercentageInsCap = 0;
        this.eliWrapObj.eliIncomeInsCap = 0;
        this.eliWrapObj.eliPercentageInsLn = 0;
        this.eliWrapObj.eliIncomeInsLn = 0
        this.eliWrapObj.eliPercentageTax = 0
        this.eliWrapObj.eliIncomeTax = 0;
        this.eliWrapObj.eliIncomeRegIncmPrgm = 0
        this.eliWrapObj.eliIncomeMonthBussIncmPrgm = 0
      }


      // }
    } else if (error) {
      console.error('Error BRE data ------------->', error);
    }
  }
  @api refreshBREData() {
    refreshApex(this.breAllData);
  }

  // @api refreshAllData(){
  //   console.log('Called refresh'+JSON.stringify(this.breAllData));
  //   this.breAllData=null;
  //   refreshApex(this.breAllData);
  // }
  //this code will be moved to salary with bank credit income
  //select id,Applicant__c, GrossSalMon__c, VarComMon__c, AnulbenLTA_Mon__c, PrfBonMon__c, TaxMon__c, OtrDedMon__c,Consideration__c,EligIncome__c,IsLatest__c from BRE_Eligibility__c where IsLatest__c=true AND Applicant__c='a0AC4000000Gq13MAC'
  // @track SalaryEligibilityType = 'Applicant';
  // @track islatestTrue = true;
  // //   this._applicantId 
  // @track applic = 'a0AC4000000Gq13MAC'
  // @track
  // salaryparameter = {
  //   ParentObjectName: 'BRE_Eligibility__c ',
  //   ChildObjectRelName: '',
  //   parentObjFields: ['Id', 'GrossSalMon__c', 'VarComMon__c', 'AnulbenLTA_Mon__c','PrfBonMon__c', 'Type__c','TaxMon__c', 'OtrDedMon__c','Consideration__c','Applicant__c', 'LoanApp__c', 'IsLatest__c'],
  //   childObjFields: [],
  //   queryCriteria: ''
  // }
  // //Applicant_Financial__r.RecordType.Name='Profit & Loss' AND Applicant_Financial__r.Loan_Applicant__c='a0AC4000000DwqzMAC'
  // //select id,EligIncome__c, Eligibilityper__c,IncomeProgram__c,Type__c,Applicant__c,LoanApp__c from BRE_Eligibility__c where Type__c='Applicant' AND Applicant__c !=null
  // handleBRESalaryRecordChange() {
  //   let tempParams = this.salaryparameter;
  //   tempParams.queryCriteria = 'WHERE Applicant__c=\'' + this._applicantId + '\' AND Type__c=\'' + this.SalaryEligibilityType + '\'AND IsLatest__c=' + this.islatestTrue;
  //   this.salaryparameter = { ...tempParams };
  //   //  FROM Applicant_Financial_Summary__c Where Applicant_Financial__r.RecordType.Name='Profit & Loss' AND Applicant_Financial__r.Loan_Applicant__r.LoanAppln__c
  // }

  // @wire(getSobjectData, { params: '$salaryparameter' })
  // handleBREResponse(wiredResultBRE) {
  //   let { error, data } = wiredResultBRE;
  //   if (data) {
  //     console.log('bre  salary data>>>>>>>>>',data);
  //   } else if (error) {
  //     console.error('Error BRE data ------------->', error);
  //   }
  // }

}