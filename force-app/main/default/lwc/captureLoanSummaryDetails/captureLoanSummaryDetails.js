import { LightningElement, track, api, wire } from 'lwc';
// import { getRecord, createRecord, updateRecord, deleteRecord } from 'lightning/uiRecordApi';
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import getCombinedObjData from '@salesforce/apex/DataCaptureSummaryController.getCombinedObjData';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import Interest_Type_FIELD from '@salesforce/schema/LoanAppl__c.ReqInterestType__c';
import LOANAPPL_OBJECT from '@salesforce/schema/LoanAppl__c';
// //Applicant and Co-Applicant Details fields
import FirstName_Field from '@salesforce/schema/Applicant__c.FName__c';
import ApplType_Field from '@salesforce/schema/Applicant__c.ApplType__c';
// import InsuranceAmount_Field from '@salesforce/schema/LoanAppl__c.InsAmt__c';
// import SanctionedLoanAmount_Field from '@salesforce/schema/LoanAppl__c.SanLoanAmt__c';
// const LoanApplicantionfields = [isAssessedIncomeProgram_Field, SanctionedLoanAmount_Field, InsuranceAmount_Field];
//const ApplicantFields =[FirstName_Field,ApplType_Field];

export default class CaptureLoanSummaryDetails extends LightningElement {

    @track _loanAppId;
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);

        this.handleRecordAppIdChange(value);
        //  this.loanSummaryData();
        // this.handleLeadRecord(value);

    }
    @api hasEditAccess;
    @api layoutSize;
    @track allCoApplNames = [];
    @track propertDataArray = [];
    @track sanctionCondtnDataArray = [];
    @track daviationDataArray = [];
    @track primaryApplName;
    @track CommaSeparatesCoappl;

    @track maxLoanAmtSanc;
    @track maxLoanAmtSancWoIns;
    @track maxInsPremiumSanc;

    @track totalLoanAmountSanc;
    @track maxLoanAmntWOIns;
    @track maxInsPremium;


    @track appvedTenure;
    @track insterestType;
    @track EffectiveROI;
    @track PFAmount;
    @track propsedEMILoan;
    @track RepaymentMode;
    @track repayACHolderName;
    @track repayACBankName;
    @track repayACNumber;
    @track ENACHPossibleRepayAC;
    @track NACHPossible;
    @track ApprovedFOIR;
    @track ApprovedLTV;
    @track employeeLevel;
    @track approvalDteUW;
    @track ApprovedValidTill

    @track isLoanSummaryDetails;
    @track interestTypeOptions = [];


    // This code is used for checking Stage and Substage of the loan application ended here
    connectedCallback() {
        console.log('this._loanAppId:::::', this._loanAppId);
        this.loanSummaryData();
    }

    @track
    param = {
        ParentObjectName: 'LoanAppl__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Name', 'Product__c', 'Stage__c', 'SubStage__c', 'ProductSubType__c'],
        childObjFields: [],
        queryCriteria: ''
    }

    handleRecordAppIdChange() {
        let tempParams = this.param;
        tempParams.queryCriteria = ' where Id = \'' + this._loanAppId + '\''
        this.param = { ...tempParams };
        console.log('loan appl data ', this.param);
    }

    @wire(getSobjectDatawithRelatedRecords, { params: '$param' })
    handleResponse(data) {
        console.log('product from parent 1', data);
    }



    generatePicklist(data) {
        return data.values.map(item => ({ label: item.label, value: item.value }))
    }

    @wire(getObjectInfo, { objectApiName: LOANAPPL_OBJECT })
    objInfo

    @wire(getPicklistValues, { recordTypeId: '$objInfo.data.defaultRecordTypeId', fieldApiName: Interest_Type_FIELD })
    customerProfilePicklistHandler({ data, error }) {
        if (data) {
            this.interestTypeOptions = [...this.generatePicklist(data)]
            // console.log('this.interestTypeOptions',this.interestTypeOptions)
        }
        if (error) {
            console.log(error)
        }
    }
    @track ProductWiseVisibility=true;
    loanSummaryData() {

        getCombinedObjData({ params: this._loanAppId })
            .then((data) => {
                console.log('Line ##208', data)
                if (data) {
                    // console.log('Data Applicant__c!!',data);

                    if (data) {
                        console.log('data.applTypeData>>>', data);

                        //Applicant and Co-applicant details code started here..

                        if (data.applTypeData != null) {
                            // console.log('data.applTypeData::50:::::::>>>', data.applTypeData);
                            let applicantDataArry = data.applTypeData;

                            applicantDataArry.forEach(element => {

                                //  console.log('element>>>>>>>>', element.ApplType__c);
                                if (element.ApplType__c == 'P') {
                                    this.primaryApplName = element.FullName__c;
                                    // console.log('primaryApplname>>>>', this.primaryApplName);
                                }
                                if (element.ApplType__c == 'G' || element.ApplType__c == 'C') {
                                    let coApplName = element.FullName__c;
                                    this.allCoApplNames.push(coApplName);
                                }

                            });
                        }
                        //  console.log('allcoapplicant data:::', this.allCoApplNames);

                        this.CommaSeparatesCoappl = this.allCoApplNames.join(", ");
                        //  console.log('CommaSeparatesCoappl>>>>>', this.CommaSeparatesCoappl);

                        //Applicant and Co-applicant details code Ended here

                        if (data.loanApplData) {
                            let loanDataArry = data.loanApplData;

                            loanDataArry.forEach(element => {

                                //  console.log('element>>>>>>>>', element);
                                if (element.Product__c !== undefined) {
                                    let productType = element.Product__c ;
                                    if(productType=='Business Loan' || productType=='Personal Loan'){
                                        this.ProductWiseVisibility=false;
                                    }
                                    console.log('this.ProductWiseVisibility>>>>>>>>', this.ProductWiseVisibility);

                                }
                                if (element.OrgSanctionLoanAmount__c !== undefined && element.OrgInsAmountLoanAppl__c !== undefined) {
                                    this.maxLoanAmtSanc = element.OrgSanctionLoanAmount__c + element.OrgInsAmountLoanAppl__c ;

                                }
                                if (element.OrgSanctionLoanAmount__c !== undefined) {
                                    this.maxLoanAmtSancWoIns = element.OrgSanctionLoanAmount__c;

                                }
                                if (element.OrgInsAmountLoanAppl__c !== undefined) {
                                    this.maxInsPremiumSanc = element.OrgInsAmountLoanAppl__c; // 

                                }



                                if (element.TotalLoanAmtInclInsurance__c !== undefined) {
                                    this.totalLoanAmountSanc = element.TotalLoanAmtInclInsurance__c;

                                }
                                if (element.SanLoanAmt__c !== undefined) {
                                    this.maxLoanAmntWOIns = element.SanLoanAmt__c;

                                }
                                if (element.InsAmt__c !== undefined) {
                                    this.maxInsPremium = element.InsAmt__c;

                                }
                                if (element.Loan_Tenure_Months__c !== undefined) {
                                    this.appvedTenure = element.Loan_Tenure_Months__c;

                                }
                                if (element.ReqInterestType__c !== undefined) {
                                    this.insterestType = element.ReqInterestType__c;

                                }
                                if (element.EffectiveROI__c !== undefined) {
                                    this.EffectiveROI = element.EffectiveROI__c;

                                }

                                if (element.Total_PF_Amount__c !== undefined) {
                                    this.PFAmount = element.Total_PF_Amount__c;

                                }

                                if (element.ApprovedValidTill__c !== undefined) {
                                    this.ApprovedValidTill = element.ApprovedValidTill__c;

                                }


                                // if (element.EMI_Proposed_Loan__c !== undefined) {
                                //     this.propsedEMILoan = element.EMI_Proposed_Loan__c;

                                // }

                                // if (element.Actual_FOIR__c !== undefined) {
                                //     this.ApprovedFOIR = element.Actual_FOIR__c;

                                // }
                                // if (element.Actual_LTV__c !== undefined) {
                                //     this.ApprovedLTV = element.Actual_LTV__c;

                                // }


                            });
                        }

                        if (data.loanBREData) {
                            let loanBREDataArry = data.loanBREData;

                            loanBREDataArry.forEach(element => {

                                console.log('element loanBREDataArry>>>>>>>>', element);

                                if (element.Actual_FOIR__c !== undefined) {
                                    this.ApprovedFOIR = element.Actual_FOIR__c;

                                }
                                if (element.Actual_LTV__c !== undefined) {
                                    this.ApprovedLTV = element.Actual_LTV__c.toFixed(2);

                                }
                                if (element.EMI__c !== undefined) {
                                    this.propsedEMILoan = element.EMI__c.toFixed(2);

                                }



                            });
                        }
                        if (data.repaymentData && data.repaymentData.length > 0) {
                            let repaymentDataArry = data.repaymentData;

                            // if(repaymentDataArry.Applicant_Banking__r!=undefined ||repaymentDataArry.Applicant_Banking__r!=null){
                            //     console.log('repaymentDataArry.Applicant_Banking__r',repaymentDataArry.Applicant_Banking__r);
                            // if(repaymentDataArry[0].Applicant_Banking__r.Name_of_the_Primary_Account_Holder_s__c!== undefined){
                            this.repayACHolderName = repaymentDataArry[0].Applicant_Banking__r.Name_of_the_Primary_Account_Holder_s__c;

                            // }
                            if (repaymentDataArry[0].Applicant_Banking__r.BankName__c !== undefined) {
                                this.repayACBankName = repaymentDataArry[0].Applicant_Banking__r.BankName__c;
                            }

                            if (repaymentDataArry[0].Applicant_Banking__r.AC_No__c !== undefined) {
                                this.repayACNumber = repaymentDataArry[0].Applicant_Banking__r.AC_No__c;

                            }
                            if (repaymentDataArry[0].Applicant_Banking__r.eNACHFeasible__c !== undefined) {
                                this.ENACHPossibleRepayAC = repaymentDataArry[0].Applicant_Banking__r.eNACHFeasible__c;

                            }
                            if (repaymentDataArry[0].Applicant_Banking__r.NACHFeasible__c !== undefined) {
                                this.NACHPossible = repaymentDataArry[0].Applicant_Banking__r.NACHFeasible__c;

                            }
                            // }
                            //    console.log('repaymentDataArry',repaymentDataArry);
                            //     if (repaymentDataArry.length > 0 && repaymentDataArry[0].Applicant_Banking__r) {
                            //         let applicantBanking = repaymentDataArry[0].Applicant_Banking__r;

                            //         if (applicantBanking.Name_of_the_Primary_Account_Holder_s__c !== undefined) {
                            //             this.repayACHolderName = applicantBanking.Name_of_the_Primary_Account_Holder_s__c;
                            //         }

                            //         if (applicantBanking.BankName__c !== undefined) {
                            //             this.repayACBankName = applicantBanking.BankName__c;
                            //         }

                            //         if (applicantBanking.AC_No__c !== undefined) {
                            //             this.repayACNumber = applicantBanking.AC_No__c;
                            //         }

                            //         if (applicantBanking.eNACH_feasible__c !== undefined) {
                            //             this.ENACHPossibleRepayAC = applicantBanking.eNACH_feasible__c;
                            //         }
                            //     }


                            repaymentDataArry.forEach(element => {

                                //  console.log('element>>>>>>>>', element)  repaymentData[0].Applicant_Banking__r.eNACH_feasible__c;
                                // if (element.Repayment_Mode__c !== undefined) {
                                //     this.RepaymentMode = element.Repayment_Mode__c;

                                // }
                                // if (element.AccHolderName__c !== undefined) {
                                //     this.repayACHolderName = element.AccHolderName__c;

                                // }
                                // if (element.Bank_Name__c !== undefined) {
                                //     this.repayACBankName = element.Bank_Name__c;

                                // }
                                // if (element.Account_Number__c !== undefined) {
                                //     this.repayACNumber = element.Account_Number__c;

                                // }
                                // if (element.Repayment_Mode__c !==undefined) {
                                //     this.PFAmount = element.Repayment_Mode__c;

                                // }


                            });
                        }

                        if (data.RepaymentModeData) {
                            let repaymentModeData = data.RepaymentModeData;
                            console.log('element repaymentModeData>>>>>>>>', repaymentModeData);
                            repaymentModeData.forEach(element => {

                                if (element.Repayment_Mode__c !== undefined) {
                                    if (element.Repayment_Mode__c !== "NACH") {
                                        this.RepaymentMode = element.Repayment_Mode__c;
                                    }
                                    if (element.Repayment_Mode__c === 'NACH') {
                                        if (element.NACH__r && element.NACH__r[0].Mandate_Type__c != undefined) {
                                            this.RepaymentMode = element.NACH__r[0].Mandate_Type__c;
                                        }

                                    }
                                }
                                // console.log('element loanBREDataArry>>>>>>>>', element);

                            });
                        }
                        if (data.applAssetData) {

                            // this.propertyDataArray = data.applAssetData.map(item => {
                            //     if (!item.PropAddrs__c || item.PropAddrs__c.trim() === '') {
                            //         return {
                            //             ...item,
                            //             PropAddrs__c: 'no property found',
                            //         };
                            //     } else {
                            //         return {
                            //             ...item,
                            //             PropAddrs__c: item.PropAddrs__c.replace(/,/g, '').trim() // Cleaning the address field
                            //         };
                            //     }
                            // });

                            this.propertDataArray = data.applAssetData.map(item => {
                                return {
                                    ...item,
                                    PropAddrs__c: item.PropAddrs__c.replace(/,/g, '').trim(), // Cleaning the address field


                                };
                            });
                            console.log('this.propertDataArray>>>>>>', this.propertDataArray);
                        }

                        if (data.sancCondtnData) {
                            this.sanctionCondtnDataArray = [...data.sancCondtnData];
                            // .map(item,index => {
                            //     return {
                            //         ...item,
                            //         dynamicLabels: `Condition ${index + 1}`, // Cleaning the address field
                            //     };
                            // });
                            // console.log('this.propertDataArray>>>>>>',this.propertDataArray);
                        }
                        if (data.deviationData) {
                            this.daviationDataArray = [...data.deviationData];
                            console.log(' this.daviationDataArray>>>', this.daviationDataArray);
                        }

                        if (data.uwDecisionDate) {
                            let uwDecisionData = data.uwDecisionDate;
                            console.log('uwDecisionData>>', uwDecisionData);
                            if (uwDecisionData && uwDecisionData.length > 0 && uwDecisionData[0].LastModifiedDate !== undefined) {
                                this.approvalDteUW = uwDecisionData[0].LastModifiedDate;
                            }

                            // this.daviationDataArray = [...data.deviationData];
                        }


                        if (data.empRoleLevel) {
                            let employeeLevel = data.empRoleLevel;
                            if (employeeLevel[0].Dev_Level__c !== undefined) {
                                this.employeeLevel = employeeLevel[0].Dev_Level__c;
                            }

                            // this.daviationDataArray = [...data.deviationData];
                        }
                    }
                }

                else if (error) {
                    console.log(error)
                }
            })
            .catch((error) => {
                console.error('Error in line ##213', error)
            })
    }



}