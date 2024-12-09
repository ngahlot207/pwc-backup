import { LightningElement, api, track, wire } from 'lwc';

import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import formFactorPropertyName from "@salesforce/client/formFactor";

import getAssetPropType from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import getInsuranceDet from '@salesforce/apex/insuranceController.getInsuranceDet';
import addNomineeList from '@salesforce/apex/insuranceController.addNomineeList';
import saveNomineeDet from '@salesforce/apex/insuranceController.saveNomineeDet';
import getAvailabeApplicants from '@salesforce/apex/insuranceController.getAvailabeApplicants';
import createDocDetailForIns from '@salesforce/apex/insuranceController.createDocDetail';

import getFilePreviewDataList from "@salesforce/apex/GetDocumentDetails.getFilePreviewDataList";
import deleteDocRecord from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';

import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, publish, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// Custom labels
import Insurance_ReqFields_ErrorMessage from '@salesforce/label/c.Insurance_ReqFields_ErrorMessage';
import Insurance_Save_SuccessMessage from '@salesforce/label/c.Insurance_Save_SuccessMessage';

import Nominee_percentage_ErrorMessage from '@salesforce/label/c.Nominee_percentage_ErrorMessage';
import Deviation_Code_For_Insurance from '@salesforce/label/c.Deviation_Code_For_Insurance';
import Nominee_mandatory_General_Insurance_ErrorMessage from '@salesforce/label/c.Nominee_mandatory_General_Insurance_ErrorMessage';
import Nominee_mandatory_Life_Insurance_ErrorMessage from '@salesforce/label/c.Nominee_mandatory_Life_Insurance_ErrorMessage';
import getMasterDataDet from '@salesforce/apex/insuranceController.getMasterDataDet';
//At least one nominee is mandatory for General Insurance


export default class InsuranceDetail extends LightningElement {
    customLabel = {
        Insurance_ReqFields_ErrorMessage,
        Insurance_Save_SuccessMessage,
        Deviation_Code_For_Insurance

    }
    @api recordId;
    @api loanAppId;
    @api applicantIdOnTabset;
    @api hasEditAccess;
    @api layoutSize;

    @wire(MessageContext)
    MessageContext;

    @track removeModalMessage = "Do you want to delete the document ?";
    @track isLifeInsurance = "No";
    @track isGeneralInsurance = "No";
    @track showSpinner = false;
    @track alowDelete = false;
    @track formFactor = formFactorPropertyName;
    @track phoneBolean = false;
    @track desktopBoolean = false;
    @track disablepFileUpload = false;
    get showRational() {
        if (this.isLifeInsurance == "No") {

            return true;
        } else {
            return false;
        }
    }
    @track planNameOptions = [];
    @wire(getObjectInfo, { objectApiName: 'Insurance__c' })
    objectInfo;

    @wire(getPicklistValuesByRecordType, {
        objectApiName: 'Insurance__c',
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
    })
    insurancePicklistHandler({ data, error }) {
        if (data) {
            console.log('data in insurancePicklistHandler', JSON.stringify(data));
            this.planNameOptions = [...this.generatePicklist(data.picklistFieldValues.Plan_Name__c)]
            // this.paymentGateWayOptions = [...this.generatePicklist(data.picklistFieldValues.Payment_Gaterway__c)]
        }
        if (error) {
            console.error('error im getting picklist values are', error)
        }
    }
    generatePicklist(data) {
        if (data && data.values) {
            return data.values.map(item => ({ label: item.label, value: item.value }))
        }
        return null;
    }

    @track showLifeInsurance = false;
    @track showGeneralInsurance = false;
    @track rational;
    @track showAddBorrower = false;
    get showAddBorrowerLife() {
        if (this.lifeInsRec && this.lifeInsRec.isCoBorrNominee__c === 'Yes') {
            return true;
        } else {
            return false;
        }

    }
    get showAddBorrowerGeneral() {
        if (this.generalInsRec && this.generalInsRec.isCoBorrNominee__c === 'Yes') {
            return true;
        } else {
            return false;
        }

    }

    get lifeInsurancePartnerVal() {
        if (this.lifeInsRec.InsProvider__c && this.lifeInsRec.InsProvider__r.Id) {
            return this.lifeInsRec.InsProvider__r.Id;
        }
        return '';
    };
    get generalInsurancePartnerVal() {
        if (this.generalInsRec.InsProvider__c && this.generalInsRec.InsProvider__r.Id) {
            return this.generalInsRec.InsProvider__r.Id;
        }
        return '';
    };
    get lifeMasterPolicyHolderVal() {
        if (this.lifeInsRec.InsProvider__c && this.lifeInsRec.InsProvider__r.MPHnm__c) {
            return this.lifeInsRec.InsProvider__r.MPHnm__c;
        }
        return '';
    };
    get generalMasterPolicyHolderVal() {
        if (this.generalInsRec.InsProvider__c && this.generalInsRec.InsProvider__r.MPHnm__c) {
            return this.generalInsRec.InsProvider__r.MPHnm__c;
        }
        return '';
    };


    @track isGeneralInsuranceReq;
    @track isLifeInsuranceReq;
    @track optonTitle = [
        {
            "label": "Mr.",
            "value": "Mr."
        },
        {
            "label": "Mrs.",
            "value": "Mrs."
        },
        {
            "label": "Ms.",
            "value": "Ms."
        },
        {
            "label": "Mx.",
            "value": "Mx."
        }
    ]
    @track optonGender = [
        {
            "label": "Male",
            "value": "M"
        },
        {
            "label": "Female",
            "value": "F"
        },
        {
            "label": "Transgender",
            "value": "T"
        }
    ]
    @track relationOptions = [
        {
            "label": "SPOUSE",
            "value": "SPOUSE"
        },
        {
            "label": "MOTHER",
            "value": "MOTHER"
        },
        {
            "label": "FATHER",
            "value": "FATHER"
        },
        {
            "label": "BROTHER",
            "value": "BROTHER"
        },
        {
            "label": "SISTER IN LAW",
            "value": "SISTER IN LAW"
        },
        {
            "label": "BROTHER IN LAW",
            "value": "BROTHER IN LAW"
        },
        {
            "label": "SISTER",
            "value": "SISTER"
        },
        {
            "label": "SON",
            "value": "SON"
        },
        {
            "label": "DAUGHTER",
            "value": "DAUGHTER"
        },
        {
            "label": "SON IN LAW",
            "value": "SON IN LAW"
        },
        {
            "label": "DAUGHTER IN LAW",
            "value": "DAUGHTER IN LAW"
        },
        {
            "label": "BUSINESS ASSOCIATE",
            "value": "BUSINESS ASSOCIATE"
        },
        {
            "label": "UNCLE",
            "value": "UNCLE"
        },
        {
            "label": "AUNT",
            "value": "AUNT"
        },
        {
            "label": "FRIEND",
            "value": "FRIEND"
        },
        {
            "label": "GRAND FATHER",
            "value": "GRAND FATHER"
        },
        {
            "label": "GRAND MOTHER",
            "value": "GRAND MOTHER"
        },
        {
            "label": "PARTNER'S RELATIVE",
            "value": "PARTNER'S RELATIVE"
        },
        {
            "label": "BUSINESS ASSOCIATE'S RELATIVE",
            "value": "BUSINESS ASSOCIATE'S RELATIVE"
        },
        {
            "label": "MOTHER IN LAW",
            "value": "MOTHER IN LAW"
        },
        {
            "label": "FATHER IN LAW",
            "value": "FATHER IN LAW"
        },
        {
            "label": "HUSBAND",
            "value": "HUSBAND"
        },
        {
            "label": "FIRST COUSIN",
            "value": "FIRST COUSIN"
        },
        {
            "label": "OTHERS",
            "value": "OTHERS"
        },
        {
            "label": "PROPERITORSHIP",
            "value": "PROPERITORSHIP"
        },
        {
            "label": "PARTNERSHIP",
            "value": "PARTNERSHIP"
        },
        {
            "label": "LIMITED LIABILITY PARTNERSHIP",
            "value": "LIMITED LIABILITY PARTNERSHIP"
        },
        {
            "label": "PRIVATE LIMITED COMPANY",
            "value": "PRIVATE LIMITED COMPANY"
        },
        {
            "label": "PUBLIC LIMITED COMPANY",
            "value": "PUBLIC LIMITED COMPANY"
        },
        {
            "label": "HUF",
            "value": "HUF"
        },
        {
            "label": "TRUST",
            "value": "TRUST"
        },
        {
            "label": "SOCIETY",
            "value": "SOCIETY"
        }
    ];

    get insMasterPolNoLife() {
        if (this.lifeInsRec.InsProvider__c && this.lifeInsRec.InsProvider__r.MPno__c) {
            return this.lifeInsRec.InsProvider__r.MPno__c;
        } else {
            return '';
        }
    }
    get insMasterPolNoGeneral() {

        if (this.generalInsRec.InsProvider__c && this.generalInsRec.InsProvider__r.MPno__c) {
            return this.generalInsRec.InsProvider__r.MPno__c;
        } else {
            return '';
        }
    }
    get majorAgeDate() {
        const today = new Date();
        const ageOf18 = new Date(today);
        ageOf18.setFullYear(today.getFullYear() - 18);
        return ageOf18.toISOString();
    }

    @track optonYN =
        [{ label: "Yes", value: "Yes" },
        { label: "No", value: "No" }];
    @track optSumInsuredTypeVal =
        [{ label: "Level", value: "Level" },
        { label: "Decreasing", value: "Decreasing" }];
    @track optonLifeInsurancePartner = [];
    @track optonLifeInsurancePartnerDisabled = [];
    @track optonGeneralInsurancePartnerDisabled = [];
    @track optonGeneralInsurancePartner = [];
    @track optonMasterPolicyHolderLife = [];
    @track optonMasterPolicyHolderGeneral = [];



    @track insuranceMsterData = [];
    @track borrowerListLife = [];
    @track borrowerListGeneral = [];
    @track lifeInsRec;
    @track generalInsRec;
    @track showAvailableIns = false;

    @track loanTenure = 0.00;
    @track loanTenureInMonths = 0.00;
    @track totalInsuranceAmount;

    @track disableMode = false;
    @track applicantInsDetail;

    @track breAmount = 0;
    @track breDeviationPresent = false;
    @track maxInsAmount = 0;
    @track totalPremiumSumOther;
    @track orgSanctionLoanAmount;
    @track orgInsLoanAmount;
    @track sanctionLoanAmount;

    connectedCallback() {
        if (!this.hasEditAccess) {
            this.disableMode = true;
            this.disablepFileUpload = true;
        }
        if (this.formFactor == "Large") {
            this.desktopBoolean = true;
            this.phoneBolean = false;
        } else if (this.formFactor == "Small") {
            this.desktopBoolean = false;
            this.phoneBolean = true;
        } else {
            this.desktopBoolean = false;
            this.phoneBolean = true;
        }
        this.sunscribeToMessageChannel();
        const today = new Date();
        console.log('from insurance', today.toISOString());
        this.getInsMsterData();
        console.log('from insurance');
        this.getdocDetail();


    }

    getInsurancePrmSumData() {
        let params = {
            ParentObjectName: 'Insurance__c',
            parentObjFields: ["Id", "LoanAppln__c", "Appl__c", "IsActive__c", "InsType__c", "SumAmount__c", "PremiumAmount__c", "LoanAppln__r.OrgSanctionLoanAmount__c", "LoanAppln__r.OrgInsAmountLoanAppl__c", "LoanAppln__r.SanLoanAmt__c"],
            // where LAN__c ='' AND Appl__c ='' AND DocCatgry__c = 'Insurance Document'
            queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND  Appl__r.Constitution__c = \'' + 'INDIVIDUAL' + '\''
        };
        console.log("params", JSON.stringify(params));
        getAssetPropType({ params: params })
            .then((res) => {
                console.log('getInsurancePrmSumData', res);
                if (res) {
                    this.totalPremiumSumOther = 0;
                    let currentInsPremiumOfCurrentUser = 0;
                    let result = JSON.parse(JSON.stringify(res));
                    console.log('getInsurancePrmSumData', result);
                    if (result.parentRecords && result.parentRecords.length > 0) {
                        console.log('getInsurancePrmSumData result count', result.parentRecords.length, result.parentRecords);
                        result.parentRecords.forEach(element => {
                            if (element.IsActive__c) {
                                this.orgSanctionLoanAmount = element.LoanAppln__r.OrgSanctionLoanAmount__c;
                                this.orgInsLoanAmount = element.LoanAppln__r.OrgInsAmountLoanAppl__c;
                                this.sanctionLoanAmount = element.LoanAppln__r.SanLoanAmt__c;
                                if (element.PremiumAmount__c) {
                                    this.totalPremiumSumOther = this.totalPremiumSumOther + element.PremiumAmount__c;
                                    if (element.Appl__c === this.applicantIdOnTabset) {
                                        currentInsPremiumOfCurrentUser = currentInsPremiumOfCurrentUser + element.PremiumAmount__c;

                                    }
                                }
                            }
                        });
                    }
                    this.totalPremiumSumOther = this.totalPremiumSumOther - currentInsPremiumOfCurrentUser;
                    console.log('getInsurancePrmSumData  this.totalPremiumSumOther ', this.totalPremiumSumOther);
                }
            })
    }
    getInsuranceDetails() {
        this.getRational();
        this.showAvailableIns = false;
        this.nomineeListLife = [];
        this.nomineeListGeneral = [];
        this.optonMasterPolicyHolderLife = [];
        this.optonMasterPolicyHolderGeneral = [];

        getInsuranceDet({ appicantId: this.applicantIdOnTabset, loanAppId: this.loanAppId })
            .then((result) => {
                console.log("result of getInsuranceDet ", result);
                if (result) {
                    let res = JSON.parse(JSON.stringify(result));
                    res.forEach(ele => {
                        console.log('insRec', ele.insurance.InsType__c);
                        if (ele.insurance.InsType__c == "Life Insurance") {

                            this.lifeInsRec = ele.insurance;
                            if (this.lifeInsRec.InsProvider__c && this.lifeInsRec.InsProvider__r.Id && this.insuranceMsterData) {
                                let opt = this.insuranceMsterData.filter(rec => rec.Id === this.lifeInsRec.InsProvider__r.Id);
                                let optList = [];
                                if (opt) {
                                    opt.forEach(element => {
                                        let optons = { label: element.MPHnm__c, value: element.MPHnm__c };
                                        console.log("optonMasterPolicyHolderLife", optons);
                                        optList.push(optons)
                                    });
                                }
                                this.optonMasterPolicyHolderLife = optList;
                            }
                            if (ele.nomineeList) {
                                let nomNew = [];
                                let nomOld = [];
                                ele.nomineeList.forEach(element => {
                                    if (element.fromOldList) {
                                        nomNew.push(element);
                                    } else {
                                        nomOld.push(element);
                                    }
                                });
                                if (nomOld) {
                                    this.nomineeListLife = ele.nomineeList;
                                }
                                this.nomineeListLife = ele.nomineeList;
                                console.log('this.nomineeListLife', this.nomineeListLife);
                            }
                            console.log("lifeInsRec", this.lifeInsRec);
                            if (ele.insurance.IsActive__c == true) {
                                this.isLifeInsurance = "Yes";
                                this.showLifeInsurance = true

                            }

                        }
                        else if (ele.insurance.InsType__c == "General Insurance") {
                            this.generalInsRec = ele.insurance;
                            if (this.generalInsRec.InsProvider__c && this.generalInsRec.InsProvider__r.Id && this.insuranceMsterData) {
                                let opt = this.insuranceMsterData.filter(rec => rec.Id === this.generalInsRec.InsProvider__r.Id);
                                let optList = [];
                                if (opt) {
                                    opt.forEach(element => {
                                        let optons = { label: element.MPHnm__c, value: element.MPHnm__c };
                                        console.log("optonMasterPolicyHolderGeneral", optons);
                                        optList.push(optons)
                                    });
                                }
                                this.optonMasterPolicyHolderGeneral = optList;
                            }
                            if (ele.nomineeList) {
                                let nomNew = [];
                                let nomOld = [];
                                ele.nomineeList.forEach(element => {
                                    if (element.fromOldList) {
                                        nomNew.push(element);
                                    } else {
                                        nomOld.push(element);
                                    }
                                });
                                if (nomOld) {
                                    this.nomineeListGeneral = ele.nomineeList;
                                }
                                this.nomineeListGeneral = ele.nomineeList;
                                console.log('this.nomineeListGeneral', this.nomineeListGeneral);
                            }
                            console.log("generalInsRec", this.generalInsRec);
                            if (ele.insurance.IsActive__c == true) {
                                this.isGeneralInsurance = "Yes";
                                this.showGeneralInsurance = true

                            }

                        } else {
                            this.isGeneralInsurance = "No";
                            this.isLifeInsurance = "No";
                            console.log('show ins desabling ');
                            this.showLifeInsurance = false;
                            this.showGeneralInsurance = false;
                        }
                    });
                    this.showAvailableIns = true;
                }
                this.getApplicants();
            })
            .catch((err) => {
                console.log(" Error occured in getInsuranceDet  Err=== ", err);
                return null;
            });
    }
    sunscribeToMessageChannel() {
        this.subscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveThroughLms(values)
        );
    }
    handleSaveThroughLms(values) {
        console.log('save called  in insurance Det', values);
        console.log('save called  in insurance Det this.lifeInsRec', this.lifeInsRec);

        if (values.validateBeforeSave) {
            let validationReport = true;
            this.template.querySelectorAll('lightning-input').forEach(element => {
                if (element.reportValidity()) {
                    console.log('element passed lightning input');
                } else {
                    validationReport = false;
                }
            });
            this.template.querySelectorAll('lightning-combobox').forEach(element => {
                if (element.reportValidity()) {
                    console.log('element passed lightning input');
                } else {
                    validationReport = false;
                }
            });
            if (this.lifeInsRec && this.isLifeInsurance === "Yes") {
                if (!this.lifeInsRec.SumAmount__c) {
                    this.showToastMessage("Error", 'Sum Assured Amount not Entered For Life Insurance', "error", "sticky");
                }
                if (!this.lifeInsRec.PolicyTenute__c) {
                    this.showToastMessage("Error", 'Policy Tenure in years not Entered For Life Insurance', "error", "sticky");
                }
                if (!this.lifeInsRec.PremiumAmount__c) {
                    this.showToastMessage("Error", 'Insurance Premium Amount not Entered For Life Insurance', "error", "sticky");
                }
                if (!this.hideUploadForLife) {
                    validationReport = false;
                    this.showToastMessage("Error", 'Please Upload Life Insurance Form', "error", "sticky");
                }
            }
            if (this.generalInsRec && this.isGeneralInsurance === "Yes") {
                if (!this.generalInsRec.SumAmount__c) {
                    this.showToastMessage("Error", 'Sum Assured Amount not Entered For General Insurance', "error", "sticky");
                }
                if (!this.generalInsRec.PolicyTenute__c) {
                    this.showToastMessage("Error", 'Policy Tenure in years not Entered For General Insurance', "error", "sticky");
                }
                if (!this.generalInsRec.PremiumAmount__c) {
                    this.showToastMessage("Error", 'Insurance Premium Amount not Entered For General Insurance', "error", "sticky");
                }
                if (!this.hideUploadForGeneral) {
                    validationReport = false;
                    this.showToastMessage("Error", 'Please Upload General Insurance Form', "error", "sticky");
                }
            }

            if (validationReport) {
                this.saveAction(values.validateBeforeSave);
            } else {
                this.showToastMessage("Error", this.customLabel.Insurance_ReqFields_ErrorMessage, "error", "sticky");
            }
        } else {
            this.saveAction(values.validateBeforeSave);
        }
    }
    saveAction(validateBeforeSave) {
        //debugger;
        console.log('saveAction 472 ', JSON.stringify(this.nomineeListLife), JSON.stringify(this.nomineeListGeneral));
        let saveNomData = [];
        let nomPercentGeneral = 0;
        let showNomPercentError = false;
        if (this.isGeneralInsurance === "Yes" && this.nomineeListGeneral && this.nomineeListGeneral.length > 0) {

            this.nomineeListGeneral.forEach(element => {
                if (element.percent && element.isDelete === false) {

                    nomPercentGeneral = nomPercentGeneral + parseFloat(element.percent);
                }
                if (element.id && element.id.toString().length != 18) {
                    element.id = null;
                    saveNomData.push(element);
                } else {
                    saveNomData.push(element);
                }
            });
            if (nomPercentGeneral < 100) {
                if (validateBeforeSave) {
                    showNomPercentError = true;
                }

            }
        } else if (this.isGeneralInsurance === "Yes") {
            if (validateBeforeSave) {
                console.log("Please add Nominee For General");
                this.showToastMessage("Error", Nominee_mandatory_General_Insurance_ErrorMessage, "error", "sticky");
                return;
            }

        }

        let nomPercentLife = 0;
        if (this.isLifeInsurance === "Yes" && this.nomineeListLife && this.nomineeListLife.length > 0) {
            this.nomineeListLife.forEach(element => {
                if (element.percent && element.isDelete === false) {
                    nomPercentLife = nomPercentLife + parseFloat(element.percent);
                }
                console.log("nomineeListLife element val", element, element.id, element.id.toString().length);
                if (element.id && element.id.toString().length != 18) {
                    element.id = null;

                    saveNomData.push(element);
                    console.log("nomineeListLife element val in condition", element.id);
                } else {
                    saveNomData.push(element);
                }

            });
            if (nomPercentLife < 100) {
                if (validateBeforeSave) {
                    showNomPercentError = true
                }

            }

        } else if (this.isLifeInsurance === "Yes") {
            if (validateBeforeSave) {
                console.log("Please add Nominee For Life");
                this.showToastMessage("Error", Nominee_mandatory_Life_Insurance_ErrorMessage, "error", "sticky");
                return;
            }
        }

        if (showNomPercentError && (this.isLifeInsurance === "Yes" || this.isGeneralInsurance === "Yes")) {
            console.log("nominee percent less than  100", nomPercentLife, nomPercentGeneral);
            this.showToastMessage("Error", Nominee_percentage_ErrorMessage, "error", "sticky");
            return;
        }

        if (this.isLifeInsurance === "Yes" || this.isGeneralInsurance === "Yes") {
            let finalSanctionLoanAmount;
            let finalInsAmount;
            let totalPremiumSum = 0;
            let lifeInsPremiunAmount = 0;
            let generalInsPremiunAmount = 0;
            if (this.lifeInsRec && this.lifeInsRec.PremiumAmount__c) {
                lifeInsPremiunAmount = parseInt(this.lifeInsRec.PremiumAmount__c);
            }
            if (this.generalInsRec && this.generalInsRec.PremiumAmount__c) {
                generalInsPremiunAmount = parseInt(this.generalInsRec.PremiumAmount__c);
            }
            totalPremiumSum = this.totalPremiumSumOther + lifeInsPremiunAmount + generalInsPremiunAmount;
            console.log('Final Value to save  breAmount :', this.breAmount, ' breDeviationPresent :', this.breDeviationPresent, ' maxInsAmount :', this.maxInsAmount, ' totalPremiumSumOther : ', this.totalPremiumSumOther, " totalPremiumSum :", totalPremiumSum, ' orgInsLoanAmount :', this.orgInsLoanAmount, ' orgSanctionLoanAmount: ', this.orgSanctionLoanAmount);

            if (totalPremiumSum > this.orgInsLoanAmount) {
                let diffAmount = totalPremiumSum - this.orgInsLoanAmount;
                finalSanctionLoanAmount = this.orgSanctionLoanAmount - diffAmount;
            } else {

                finalSanctionLoanAmount = this.orgSanctionLoanAmount;
            }
            finalInsAmount = totalPremiumSum;
            console.log('Final Value to save  finalInsAmount == ', finalInsAmount, 'finalSanctionLoanAmount', finalSanctionLoanAmount);
            console.log('Final Value to save  totalPremiumSum == ', totalPremiumSum, ' this.maxInsAmount', this.maxInsAmount, totalPremiumSum > this.maxInsAmount);
            // if (totalPremiumSum > this.maxInsAmount) {
            //     this.showToastMessage("Error", "Total insurance premium is more than the approved maximum insurance premium ( " + this.maxInsAmount + " ), differential amount would be reduced from net maximum loan amount without insurance.", "error", "sticky");
            //     return;
            // } 

            this.upsertRecord({ Id: this.loanAppId, sobjectType: "LoanAppln__c", SanLoanAmt__c: finalSanctionLoanAmount, InsAmt__c: finalInsAmount }, null, null);

        }
        else{
            this.upsertRecord({ Id: this.loanAppId, sobjectType: "LoanAppln__c", InsAmt__c: 0 }, null, null);
        }

        this.saveRational();
        this.upsertRecord(this.lifeInsRec, null, null);
        this.upsertRecord(this.generalInsRec, null, null);

        console.log("before save modifiedBorrorList ", JSON.stringify(this.modifiedBorrorList));
        console.log(" before save NomData is ", JSON.stringify(saveNomData), this.loanAppId);
        if (saveNomData.length > 0) {
            saveNomineeDet({ nomineeList: saveNomData, loanAppId: this.loanAppId })
                .then((res) => {
                    console.log("  saveNomData  result === ", res);
                    this.showAvailableIns = false;
                    this.getInsuranceDetails();
                    this.showToastMessage("Success", this.customLabel.Insurance_Save_SuccessMessage, "success", "sticky");
                })
                .catch((error) => {
                    this.showToastMessage("Error", "Error in Saving Nominee : " + error.body.message, "error", "sticky");
                    console.log(" Error occured in saveNomData  Err=== ", error);
                    return;
                })
        } else {
            this.showToastMessage("Success", this.customLabel.Insurance_Save_SuccessMessage, "success", "sticky");
        }
    }

    getRational() {
        let params = {
            ParentObjectName: 'Applicant__c',
            parentObjFields: ["Id", "InsRational__c", "InsPolicyNum__c", "InsCompanyName__c", "InsExpiryDate__c", "InsCoverageAmount__c", "InsAvailable__c", "LoanAppln__r.Loan_Tenure_Months__c", "LoanAppln__r.InsAmt__c", "LoanAppln__r.OrgInsAmountLoanAppl__c", "LoanAppln__r.Insurance_Amount__c", "LoanAppln__r.MaxBreLnEliWIns__c", "LoanAppln__r.MaxBreLnEliWoIns__c"],

            queryCriteria: ' where Id = \'' + this.applicantIdOnTabset + '\''
        };
        getAssetPropType({ params: params })
            .then((res) => {
                if (res && res.parentRecords) {
                    let responce = JSON.parse(JSON.stringify(res.parentRecords));
                    this.applicantInsDetail = responce[0];
                    console.log('rational val ', JSON.stringify(responce));


                    if (responce[0].LoanAppln__r.Loan_Tenure_Months__c) {
                        this.loanTenure = (responce[0].LoanAppln__r.Loan_Tenure_Months__c) / 12;
                        this.loanTenureInMonths = responce[0].LoanAppln__r.Loan_Tenure_Months__c;

                    }
                    if (responce[0].LoanAppln__r.OrgInsAmountLoanAppl__c) {//InsAmt__c prev updated to ->//OrgInsAmountLoanAppl__c
                        this.totalInsuranceAmount = responce[0].LoanAppln__r.OrgInsAmountLoanAppl__c;
                    }
                    if (this.applicantInsDetail && this.applicantInsDetail.InsRational__c) {
                        this.rational = this.applicantInsDetail.InsRational__c;
                    }
                    console.log('rational val ', JSON.stringify(responce), this.rational);
                    this.maxInsAmount = this.totalInsuranceAmount;
                    this.getInsurancePrmSumData();//added for updated requirement
                    //  this.getDeviation(); //commented for updated requirement
                }
            })
    }

    getDeviation() {
        console.log('Deviation_Code_For_Insurance == ', this.customLabel.Deviation_Code_For_Insurance);
        // let deviationCodeList = JSON.parse(this.customLabel.Deviation_Code_For_Insurance).deviationCode;
        let deviationCodeList = ["5669", "5698", "5577", "5440", "5463", "5600"];
        console.log('Deviation_Code_For_Insurance == ', deviationCodeList);

        let params = {
            ParentObjectName: 'Deviation__c',
            parentObjFields: ["Id", "Name", "LoanAppln__c", "DevCode__c"],
            //' where LoanAppln__c = \'' + this.loanAppId + '\' AND Deviation__c IN  (\''+deviationCodeList.join('\', \'') + '\'))'
            queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND Deviation__c IN  (\'' + deviationCodeList.join('\', \'') + '\')'
            //' where LoanAppln__c = \'' + this.loanAppId + '\''
        };
        console.log('getDeviation  qry: ', JSON.stringify(params));
        getAssetPropType({ params: params })
            .then((res) => {
                console.log('getDeviation  res: ', JSON.stringify(res));
                this.getInsurancePrmSumData();
                if (res && res.parentRecords) {
                    let responce = JSON.parse(JSON.stringify(res.parentRecords));
                    console.log('getDeviation : ', responce);
                    this.breDeviationPresent = true;
                }
                if (this.applicantInsDetail && this.applicantInsDetail.LoanAppln__r && this.applicantInsDetail.LoanAppln__r.MaxBreLnEliWIns__c && this.applicantInsDetail.LoanAppln__r.MaxBreLnEliWoIns__c) {
                    console.log('breAmount :: == ', this.applicantInsDetail.LoanAppln__r.MaxBreLnEliWIns__c - this.applicantInsDetail.LoanAppln__r.MaxBreLnEliWoIns__c);
                    this.breAmount = this.applicantInsDetail.LoanAppln__r.MaxBreLnEliWIns__c - this.applicantInsDetail.LoanAppln__r.MaxBreLnEliWoIns__c;
                } else {
                    console.log('breAmount else:: == ', 0);
                    this.breAmount = 0;
                }

                if (this.totalInsuranceAmount >= this.breAmount) {
                    this.maxInsAmount = this.totalInsuranceAmount

                } else {
                    if (this.breDeviationPresent) {
                        this.maxInsAmount = this.totalInsuranceAmount
                    } else {
                        this.maxInsAmount = this.breAmount
                    }
                }
                console.log('getDeviation :: deviation present  ==  ', this.breDeviationPresent, ', Uw recomended = : ', this.totalInsuranceAmount, ', BRE recomended = : ', this.breAmount, ', maxInsAmount = : ', this.maxInsAmount);
            })
            .catch((err) => {
                console.log(" Error occured in getDeviation   Err=== ", err);

            });
    }

    saveRational() {
        this.upsertRecord(this.applicantInsDetail, null, null);
    }

    getInsMsterData() {
        //select  Name,  MPHnm__c, MPno__c  from MasterData__c  
        // let params = {
        //     ParentObjectName: 'MasterData__c',
        //     parentObjFields: ["Id", "Name", "MPHnm__c", "MPno__c", "Type__c"],

        //     queryCriteria: ' where Type__c = \'' + 'Life Insurance' + '\' OR Type__c = \'' + 'General Insurance' + '\''
        // };
        // console.log("params", params);
        // getAssetPropType({ params: params })
        // .then((res) => {
        getMasterDataDet({ loanAppId: this.loanAppId })
            .then((res) => {
                if (res) {
                    this.insuranceMsterData = JSON.parse(JSON.stringify(res));
                    console.log('insuranceMsterData', JSON.stringify(this.insuranceMsterData));
                    res.forEach(ele => {
                        console.log('insuranceMsterData ele', ele);
                        if (ele.Type__c == "Life Insurance") {
                            this.optonLifeInsurancePartner.push({ label: ele.Name, value: ele.Id });

                        } else if (ele.Type__c == "General Insurance") {
                            this.optonGeneralInsurancePartner.push({ label: ele.Name, value: ele.Id });
                        }
                    });
                }
                this.getInsuranceDetails();
            })
            .catch((err) => {
                console.log(" Error occured in Updating Owner  Err=== ", err);
                this.showSpinner = false;
            });
    }
    handleInsInputChange(event) {
        let name = event.target.name;
        let value = event.target.value;
        console.log('handleInsInputChange ', name, value, this.lifeInsRec);
        if (name == "LifeInsurance") {
            this.isLifeInsurance = value;

            if (value === "Yes") {
                if (!this.lifeInsRec) {
                    this.upsertRecord({ Id: null, sobjectType: "Insurance__c", Appl__c: this.applicantIdOnTabset, LoanAppln__c: this.loanAppId, IsActive__c: true, InsType__c: "Life Insurance" }, null, null);
                    this.createDocDet("Life Insurance documents");
                } else {
                    this.upsertRecord({ Id: this.lifeInsRec.Id, sobjectType: "Insurance__c", IsActive__c: true }, null, null);
                    if (this.lifeInsDocDetId) {
                        this.upsertRecord({ Id: this.lifeInsDocDetId, sobjectType: "DocDtl__c", IsLatest__c: true }, null, null);
                    } else {
                        this.createDocDet("Life Insurance documents");
                    }
                }
            } else if (value === "No") {
                if (this.lifeInsRec) {
                    this.upsertRecord({ Id: this.lifeInsRec.Id, sobjectType: "Insurance__c", IsActive__c: false }, null, null);
                    this.showLifeInsurance = false;
                    if (this.lifeInsDocDetId) {
                        this.upsertRecord({ Id: this.lifeInsDocDetId, sobjectType: "DocDtl__c", IsLatest__c: false }, null, null);
                    }
                }
            }
        }
        else if (name == "GeneralInsurance") {
            this.isGeneralInsurance = value;
            if (value === "Yes") {
                if (!this.generalInsRec) {
                    this.upsertRecord({ Id: null, sobjectType: "Insurance__c", Appl__c: this.applicantIdOnTabset, LoanAppln__c: this.loanAppId, IsActive__c: true, InsType__c: "General Insurance" }, null, null);
                    this.createDocDet("General Insurance documents");
                } else {
                    this.upsertRecord({ Id: this.generalInsRec.Id, sobjectType: "Insurance__c", IsActive__c: true }, null, null);
                    if (this.generalInsDocDetId) {
                        this.upsertRecord({ Id: this.generalInsDocDetId, sobjectType: "DocDtl__c", IsLatest__c: true }, null, null);
                    } else {
                        this.createDocDet("General Insurance documents");
                    }
                }

            } else if (value === "No") {
                if (this.generalInsRec) {
                    this.upsertRecord({ Id: this.generalInsRec.Id, sobjectType: "Insurance__c", IsActive__c: false }, null, null);
                    this.showGeneralInsurance = false;
                    if (this.generalInsDocDetId) {
                        this.upsertRecord({ Id: this.generalInsDocDetId, sobjectType: "DocDtl__c", IsLatest__c: false }, null, null);
                    }
                }
            }

        }

    }
    handleRational(event) {
        this.rational = event.target.value;
        console.log("handleRational", this.rational);
    }
    get showExistingPolicy() {
        if (this.showRational && this.applicantInsDetail && this.applicantInsDetail.InsAvailable__c && this.applicantInsDetail.InsAvailable__c === 'Yes') {
            return true;
        } else {
            return false;
        }
    }

    get showLifeInsurancePartnerDisabled() {
        if (this.lifeInsurancePartnerVal && this.disableMode) {
            this.optonLifeInsurancePartnerDisabled.push({ label: this.lifeInsRec.InsProvider__r.Name, value: this.lifeInsurancePartnerVal });
            return true;
        } else {
            return false;
        }
    }

    get showGenInsurancePartnerDisabled() {
        if (this.generalInsurancePartnerVal && this.disableMode) {
            this.optonGeneralInsurancePartnerDisabled.push({ label: this.generalInsRec.InsProvider__r.Name, value: this.generalInsurancePartnerVal });
            return true;
        } else {
            return false;
        }
    }

    handleExistingPolicy(event) {
        let name = event.target.name;
        let value = event.target.value;
        let vartype = event.target.type;
        if (vartype === 'text') {
            this.applicantInsDetail[name] = value.toUpperCase();
        } else {
            this.applicantInsDetail[name] = value;
        }

        console.log("handleExistingPolicy", name, value, JSON.stringify(this.applicantInsDetail));
    }
    handleLifeInsMaster(event) {
        let name = event.target.name;
        let value = event.target.value;
        console.log('handleLifeInsMaster', name, value);
        if (name == "LifeInsurancePartner") {
            let InsProvider = { Id: value };
            this.lifeInsRec.InsProvider__c = value;
            this.lifeInsRec.InsProvider__r = InsProvider;
            let obj = this.insuranceMsterData.find(rec => rec.Id === value && rec.Type__c === "Life Insurance");
            this.lifeInsRec.InsProvider__r.MPHnm__c = obj.MPHnm__c;
            this.lifeInsRec.InsProvider__r.MPno__c = obj.MPno__c;
            let opt = this.insuranceMsterData.filter(rec => rec.Id === value && rec.Type__c === "Life Insurance");
            let optList = [];
            if (opt) {
                opt.forEach(element => {
                    let optons = { label: element.MPHnm__c, value: element.MPHnm__c };
                    console.log("optonMasterPolicyHolderLife", optons);
                    optList.push(optons)
                });
            }
            this.optonMasterPolicyHolderLife = optList;

        }
        if (name == "MasterPolicyHolder") {
            /// this.lifeInsRec.InsProvider__r = InsProvider;
            this.lifeInsRec.InsProvider__r.MPHnm__c = value;
            let opt = this.insuranceMsterData.find(rec => rec.MPHnm__c === value && rec.Type__c === "Life Insurance");
            if (opt) {
                this.lifeInsRec.InsProvider__c = opt.Id;
                this.lifeInsRec.InsProvider__r.Id = opt.Id;
                console.log('this.lifeInsRec', this.lifeInsRec);
                this.lifeInsRec.InsProvider__r.MPno__c = opt.MPno__c;
            }
            else {
                this.lifeInsRec.InsProvider__r.MPno__c = '';
            }

        }
    }
    handleGeneralInsMaster(event) {
        let name = event.target.name;
        let value = event.target.value;
        console.log('handleGeneralInsMaster', name, value);
        if (name == "GeneralInsurancePartner") {
            let InsProvider = { Id: value };
            this.generalInsRec.InsProvider__c = value;
            this.generalInsRec.InsProvider__r = InsProvider;
            let obj = this.insuranceMsterData.find(rec => rec.Id === value && rec.Type__c === "General Insurance");

            this.generalInsRec.InsProvider__r.MPHnm__c = obj.MPHnm__c;
            this.generalInsRec.InsProvider__r.MPno__c = obj.MPno__c;
            let opt = this.insuranceMsterData.filter(rec => rec.Id === value && rec.Type__c === "General Insurance");
            let optList = [];
            if (opt) {
                opt.forEach(element => {
                    let optons = { label: element.MPHnm__c, value: element.MPHnm__c };
                    console.log("optonMasterPolicyHolderGeneral", optons);
                    optList.push(optons)
                });
            }
            this.optonMasterPolicyHolderGeneral = optList;

        }
        if (name == "MasterPolicyHolder") {
            /// this.lifeInsRec.InsProvider__r = InsProvider;
            this.generalInsRec.InsProvider__r.MPHnm__c = value;
            let opt = this.insuranceMsterData.find(rec => rec.MPHnm__c === value && rec.Type__c === "General Insurance");
            if (opt) {
                this.generalInsRec.InsProvider__c = opt.Id;
                this.generalInsRec.InsProvider__r.Id = opt.Id;
                console.log('this.generalInsRec', this.generalInsRec);
                this.generalInsRec.InsProvider__r.MPno__c = opt.MPno__c;
            }
            else {
                this.generalInsRec.InsProvider__r.MPno__c = '';
            }
        }
    }

    @track sumInsuredTypeVal;
    @track PolicyTenureVal;
    handleInputChange(event) {
        let name = event.target.name;
        let value = event.target.value;
        if (name == "SumInsuredType") {
            this.sumInsuredTypeVal = value;
        }
        if (name == "PolicyTenure") {
            this.PolicyTenureVal = value;
        }
    }
    inputChangeHandlerLife(event) {
        let name = event.target.name;
        let value = event.target.value;

        console.log('inputChangeHandlerLife : ', name, value, 'PolicyTenute__c:', this.loanTenure, 'PremiumAmount__c : ', this.lifeInsRec.SumAmount__c);
        if (name === 'PolicyTenute__c') {
            this.lifeInsRec[name] = value;
            // let loanTenureInMonths = this.loanTenure *12; // changed under LAK-160 Split story
            if (value > this.loanTenureInMonths) {
                this.showToastMessage("Error", "Insurance Policy Tenure shall not exceed loan tenure.", "error", "sticky");
            }
        } else if (name === 'PremiumAmount__c') {
            this.lifeInsRec[name] = value;
            if (value && this.sanctionLoanAmount && this.sanctionLoanAmount != 0) {
                let penetration;
                penetration = (value / this.sanctionLoanAmount) * 100;
                this.lifeInsRec['Penettration__c'] = penetration;
            }
        }
        else {
            this.lifeInsRec[name] = value;
        }
        console.log('lifeInsRec : ', JSON.stringify(this.lifeInsRec));
    }
    inputChangeHandlerGeneral(event) {
        let name = event.target.name;
        let value = event.target.value;

        console.log('inputChangeHandlerLife : ', name, value, 'PolicyTenute__c:', this.loanTenure, 'PremiumAmount__c : ', this.generalInsRec.SumAmount__c);
        if (name === 'PolicyTenute__c') {
            this.generalInsRec[name] = value;
            if (value > this.loanTenure) {
                this.showToastMessage("Error", "Insurance Policy Tenure shall not exceed loan tenure.", "error", "sticky");
            }
        } else if (name === 'PremiumAmount__c') {
            this.generalInsRec[name] = value;
            if (value && this.sanctionLoanAmount && this.sanctionLoanAmount != 0) {
                let penetration;
                penetration = (value / this.sanctionLoanAmount) * 100;
                this.generalInsRec['Penettration__c'] = penetration;
            }

        } else {
            this.generalInsRec[name] = value;
        }
        console.log('generalInsRec : ', JSON.stringify(this.generalInsRec));

    }

    @track insuranceParticepents = [];
    getInsPati() {
        let params = {
            ParentObjectName: 'InsParti__c',
            parentObjFields: ["Id", "LoanAppln__c", "Appl__c", "Parti__c", "Insurance__c"],

            queryCriteria: ' where Appl__c = \'' + this.applicantIdOnTabset + '\''
        };
        console.log("params", params);
        getAssetPropType({ params: params })
            .then((res) => {
                if (res && res.parentRecords) {
                    console.log('getInsPati result', res.parentRecords);
                    this.insuranceParticepents = res.parentRecords;
                    this.nomineeList = this.insuranceParticepents.filter(rec => rec.Parti__c === "Nominee");

                }

            })
            .catch((err) => {
                //this.showToast("Error", "error", "Error occured in Updating Owner  " + err.message);
                console.log(" Error occured in Updating Owner  Err=== ", err);
                this.showSpinner = false;
            });
    }


    @track nomineeListLife = [];
    @track nomineeListGeneral = [];

    @track showNomineeListLife = true;
    @track showNomineeListGeneral = true;
    @track nIndex = 0;
    addNomineeClickLife(event) {
        let type = event.target.name;
        console.log('nomineeList 2', type, event.target.name);
        this.showNomineeListLife = false;

        let nml = {
            id: this.nIndex + 1,
            appId: null,
            addId: null,
            insId: this.lifeInsRec.Id,
            title: "", fName: "", lName: "", gender: "", dateOfBirth: null, relation: "", hNo: "",
            street: "", area: "", city: "", cityId: "", pincode: "", pincodeId: "", state: "", stateId: "", percent: '', insPartType: "Nominee", isDelete: false
        }
        if (type === "LIfeIns") {
            console.log('nomineeList 3')
            this.nomineeListLife.push(nml);
        }
        console.log('nomineeList 4', JSON.stringify(this.nomineeListLife));
        this.showNomineeListLife = true;
        this.nIndex = this.nIndex + 1;
    }
    removeNominee(event) {


        let selectedRecordId = event.currentTarget.dataset.recordid;
        let insType = event.currentTarget.dataset.instype;
        if (insType === 'Life') {
            let resp = this.nomineeListLife.find(rec => rec.id == selectedRecordId);
            console.log('removeNominee', insType, selectedRecordId, resp)
            if (resp && resp.id && resp.id.toString().length != 18) {
                console.log('inside filter', resp.id, resp.id.toString().length, this.nomineeListLife.length)
                this.nomineeListLife = this.nomineeListLife.filter(obj => obj.id !== resp.id);
                console.log('last inside filter', this.nomineeListLife.length)
            } else {
                let respBorr = this.borrowerListLife.find(rec => rec.id == selectedRecordId);
                if (respBorr) {
                    respBorr.selectCheckbox = false;
                }
                resp.isDelete = true;

            }
        } else if (insType === 'General') {
            let resp = this.nomineeListGeneral.find(rec => rec.id == selectedRecordId);
            console.log('removeNominee', insType, selectedRecordId, resp)
            if (resp && resp.id && resp.id.toString().length != 18) {
                console.log('inside filter', resp.id, resp.id.toString().length, this.nomineeListGeneral.length)
                this.nomineeListGeneral = this.nomineeListGeneral.filter(obj => obj.id !== resp.id);
                console.log('last inside filter', this.nomineeListGeneral.length)
            } else {
                resp.isDelete = true;
            }
        }



    }

    addNomineeClickGeeral(event) {
        let type = event.target.name;
        console.log('nomineeList 2', type, event.target.name);
        this.showNomineeListGeneral = false;


        let nml = {
            id: this.nIndex + 1,
            appId: null,
            addId: null,
            insId: this.generalInsRec.Id,
            title: "", fName: "", lName: "", gender: "", dateOfBirth: null, relation: "", hNo: "",
            street: "", area: "", city: "", cityId: "", pincode: "", pincodeId: "", state: "", stateId: "", percent: '', insPartType: "Nominee", isDelete: false
        }
        if (type === "LIfeIns") {

            console.log('nomineeList 3')

            this.nomineeListGeneral.push(nml);
        }
        console.log('nomineeList 4', JSON.stringify(this.nomineeListGeneral));
        this.showNomineeListGeneral = true;
        this.nIndex = this.nIndex + 1;
    }
    upsertRecord(parentRec, childRec, parentField) {
        let upsertData = {
            parentRecord: parentRec,
            ChildRecords: childRec,
            ParentFieldNameToUpdate: parentField
        };

        upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
            .then(result => {

                console.log('upsert success result 733', JSON.stringify(result))
                console.log('upsert success upsertData 734', JSON.stringify(upsertData));

                this.showAvailableIns = false;
                this.getInsuranceDetails();
            })
            .catch(error => {
                console.error(error)
                console.log('upsert error -', JSON.stringify(error))
            })
    }

    getApplicants() {
        getAvailabeApplicants({ loanAppId: this.loanAppId })
            .then((result) => {
                let res = JSON.parse(JSON.stringify(result));
                console.log('getAvailabeApplicants', res);
                let filteredRes = res.filter(record => record.appId !== this.applicantIdOnTabset);
                //  filteredRes = filteredRes.filter(record => record.appType !== 'P'); // https://fedfina.atlassian.net/browse/LAK-4896 commented bz of //https://fedfina.atlassian.net/browse/LAK-6023
                this.borrowerListLife = JSON.parse(JSON.stringify(filteredRes));
                this.borrowerListLife.forEach(borlife => {
                    let foundRecord = this.nomineeListLife.find(rec => rec.appId === borlife.appId);
                    if (foundRecord) {
                        borlife.selectCheckbox = true;
                    } else {
                        borlife.selectCheckbox = false;
                    }
                });
                this.borrowerListGeneral = JSON.parse(JSON.stringify(filteredRes));;
                this.borrowerListGeneral.forEach(borgen => {
                    let foundRecord = this.nomineeListGeneral.find(rec => rec.appId === borgen.appId);
                    if (foundRecord) {
                        borgen.selectCheckbox = true;
                    } else {
                        borgen.selectCheckbox = false;
                    }
                });
                console.log('getAvailabeApplicants borrowerListLife ', this.borrowerListLife, this.nomineeListLife);
                console.log('getAvailabeApplicants borrowerListGeneral ', this.borrowerListGeneral, this.nomineeListGeneral);


            })
            .catch(error => {

                console.log('error in getAvailabeApplicants ', JSON.stringify(error))
            })

    }
    @track modifiedBorrorList = [];


    handleAddBorrowerAsNom(event) {
        let name = event.target.name;
        console.log('record ', event.target.dataset.recordid);
        let selectedRecordId = event.target.dataset.recordid;
        console.log('value is', event.target.checked, name, selectedRecordId);
        let val = event.target.checked;

        if (name === 'LifeIns' && selectedRecordId) {
            let searchDoc = this.borrowerListLife.find((doc) => doc.appId == selectedRecordId && doc.isDelete == false);
            console.log('searchDoc', searchDoc);
            if (searchDoc) {
                searchDoc['selectCheckbox'] = val;
                let nomcount = 0;
                if (this.nomineeListLife && this.nomineeListLife.length > 0) {
                    nomcount = this.nomineeListLife.length + 1
                }
                searchDoc['id'] = nomcount;
                searchDoc['insId'] = this.lifeInsRec.Id;
                searchDoc['insPartType'] = 'Nominee';
                searchDoc['readOnly'] = true;

                let addedToNom = this.nomineeListLife.find((doc) => doc.appId == selectedRecordId);
                console.log('addedToNom', addedToNom);
                if (addedToNom) {
                    if (val == false) {
                        this.nomineeListLife = this.nomineeListLife.filter(obj => !(obj.appId == selectedRecordId));
                    }
                } else {

                    this.nomineeListLife.push(searchDoc);

                }
                console.log('handleAddBorrowerAsNom LifeIns', JSON.stringify(this.nomineeListLife));

            }
        }
        if (name === 'GeneralIns' && selectedRecordId) {
            let searchDoc = this.borrowerListGeneral.find((doc) => doc.appId == selectedRecordId && doc.isDelete == false);
            console.log('searchDoc', searchDoc);
            if (searchDoc) {
                searchDoc['selectCheckbox'] = val;
                let nomcount = 0;
                if (this.nomineeListGeneral && this.nomineeListGeneral.length > 0) {
                    nomcount = this.nomineeListGeneral.length + 1
                }
                searchDoc['id'] = nomcount;
                searchDoc['insId'] = this.generalInsRec.Id;
                searchDoc['insPartType'] = 'Nominee';
                searchDoc['readOnly'] = true;
                //searchDoc['isDelete'] = !val;


                let addedToNom = this.nomineeListGeneral.find((doc) => doc.appId == selectedRecordId);
                console.log('addedToNom', addedToNom);
                if (addedToNom) {
                    if (val == false) {
                        this.nomineeListGeneral = this.nomineeListGeneral.filter(obj => !(obj.appId == selectedRecordId));
                    }
                } else {

                    this.nomineeListGeneral.push(searchDoc);

                }
                console.log('handleAddBorrowerAsNom GeneralIns', JSON.stringify(this.nomineeListGeneral));

            }
        }

        console.log('borrowerList updated', JSON.stringify(this.modifiedBorrorList));
    }


    inputChangeNomineeLife(event) {
        this.showNomineeListLife = false;
        console.log('event ', event);//, JSON.stringify(error)
        let name = event.target.name;
        let value = event.target.value;
        let vartype = event.target.type;
        if (vartype === 'text') {
            value = event.target.value.toUpperCase();
        }
        let selectedRecordId = event.target.dataset.recordid;
        let resp = this.nomineeListLife.find(rec => rec.id == selectedRecordId && rec.isDelete == false);
        console.log('inputChangeNomineeLife ', this.nomineeListLife, resp);


        if (resp) {
            resp[name] = value;
            if (name == "dateOfBirth") {
                const userEnteredDate = new Date(value);
                let age = this.getAge(userEnteredDate);
                if (age < 18 && age >= 0) {
                    console.log('appointee Required 1 ', age, JSON.stringify(resp), " insId:", JSON.stringify(this.lifeInsRec), '  rec.Id', JSON.stringify(resp));
                    console.log('appointee Required', age, JSON.stringify(resp), " insId:", JSON.stringify(this.lifeInsRec), '  rec.Id', JSON.stringify(resp));
                    let appointee = {
                        id: null,
                        appId: null,
                        addId: null,
                        insId: this.lifeInsRec.Id,
                        title: "", fName: "", lName: "", gender: "", dateOfBirth: null, relation: "", hNo: "",
                        street: "", area: "", city: "", cityId: "", pincode: "", pincodeId: "", state: "", stateId: "", insPartType: "Appointee", appointeeFor: resp.Id
                    }
                    console.log('appointee to  add', appointee);
                    resp['appointee'] = appointee;
                    console.log('appointee after  add', JSON.stringify(resp));

                } else {
                    if (resp.appointee) {
                        delete resp['appointee'];
                    }


                    console.log("No appointee Required");
                }
            }
            else if (name == 'percent') {
                console.log("nominee percent exceed");
                let totalNomPercent = 0;
                this.nomineeListLife.forEach(element => {
                    if (element.isDelete === false) {
                        totalNomPercent = totalNomPercent + parseFloat(element.percent);
                    }

                    console.log("nominee percent exceed ", element, totalNomPercent);
                });
                if (totalNomPercent > 100) {
                    console.log("nominee percent exceed 100", totalNomPercent);
                    this.showToastMessage("Error", Nominee_percentage_ErrorMessage, "error", "sticky");
                    resp.percent = '';
                }
            }
        }
        console.log('inputChangeNomineeLife ', name, selectedRecordId, resp);
        this.showNomineeListLife = true;
    }
    inputChangeNomineeGeneral(event) {
        let name = event.target.name;
        let value = event.target.value;
        let vartype = event.target.type;
        if (vartype == 'text') {
            value = value.toUpperCase();
        }
        let selectedRecordId = event.target.dataset.recordid;
        let resp = this.nomineeListGeneral.find(rec => rec.id == selectedRecordId && rec.isDelete == false);
        if (resp) {
            resp[name] = value;
            if (name == "dateOfBirth") {

                const userEnteredDate = new Date(value);
                let age = this.getAge(userEnteredDate);
                if (age < 18 && age >= 0) {
                    console.log('appointee Required', this.getAge(userEnteredDate));
                    let appointee = {
                        id: null,
                        appId: null,
                        addId: null,
                        insId: this.generalInsRec.Id,
                        title: "", fName: "", lName: "", gender: "", dateOfBirth: null, relation: "", hNo: "",
                        street: "", area: "", city: "", cityId: "", pincode: "", pincodeId: "", state: "", stateId: "", insPartType: "Appointee", appointeeFor: resp.id
                    }
                    resp.appointee = appointee;

                } else {

                    console.log("No appointee Required");
                }
            }
            else if (name == 'percent') {
                //  resp[name] = value;
                console.log("nominee percent exceed");
                let totalNomPercent = 0;
                this.nomineeListGeneral.forEach(element => {
                    if (element.isDelete === false) {
                        totalNomPercent = totalNomPercent + parseFloat(element.percent);
                    }
                    console.log("nominee percent exceed ", element, totalNomPercent);
                    //totalNomPercent = totalNomPercent + parseFloat(element.percent);
                });
                if (totalNomPercent > 100) {
                    this.showToastMessage("Error", Nominee_percentage_ErrorMessage, "error", "sticky");
                    resp.percent = '';
                }
            }
        }
        console.log('inputChangeNomineeGeneral ', name, selectedRecordId, resp);
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
    getAge(dateString) {
        var today = new Date();
        var birthDate = new Date(dateString);
        var age = today.getFullYear() - birthDate.getFullYear();
        var m = today.getMonth() - birthDate.getMonth();
        if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
            age--;
        }
        console.log("AGE IS V:::", age);
        return age;
    }
    inputChangeAppointeeLife(event) {
        let name = event.target.name;
        let value = event.target.value;
        let vartype = event.target.type;
        if (vartype == 'text') {
            value = value.toUpperCase();
        }
        let selectedRecordId = event.target.dataset.recordid;
        let searchDoc = this.nomineeListLife.find((doc) => doc.id == selectedRecordId);
        console.log('inputChangeAppointeeLife ', name, selectedRecordId, searchDoc);
        if (searchDoc) {
            searchDoc.appointee[name] = value;
        }
        console.log('inputChangeAppointeeLife ', JSON.stringify(this.nomineeListLife));
    }
    inputChangeAppointeeGeneral(event) {
        let name = event.target.name;
        let value = event.target.value;
        let vartype = event.target.type;
        if (vartype == 'text') {
            value = value.toUpperCase();
        }
        let selectedRecordId = event.target.dataset.recordid;
        let searchDoc = this.nomineeListGeneral.find((doc) => doc.id == selectedRecordId);
        console.log('inputChangeAppointeeGeneral ', this.nomineeListGeneral, name, selectedRecordId, searchDoc);
        if (searchDoc) {
            searchDoc.appointee[name] = value;
        }
    }
    @track lifeInsDocDetId;
    @track generalInsDocDetId;

    @track acceptedFormats = [".jpg", ".jpeg", ".pdf"];
    @track fileUploadMsz = "Maximum File Size should be 5Mb. Allowed File Types are  .jpg, .jpeg, .pdf ";
    @track alowMultiple = true;
    @track disablepForFile = true;
    @track hideUpload = false;

    fileUploadFinish() {
        console.log('fileUploadFinish  ');
        this.showSpinner = false;
        this.getUploadedFileData(this.lifeInsDocDetId, 'life');
        this.getUploadedFileData(this.generalInsDocDetId, 'general');

    }
    spinnerStatus(event) {
        console.log('spinner value ', event.detail);
        this.showSpinner = event.detail;
    }
    createDocDet(insType) {
        createDocDetailForIns({ applicantId: this.applicantIdOnTabset, loanAppId: this.loanAppId, docCategory: "Insurance Documents", docType: insType, docSubType: insType, availableInFile: false, appKycId: null })
            .then(result => {
                console.log('createDocDetailForIns result ', result);
                if (insType == 'Life Insurance documents') {
                    this.lifeInsDocDetId = result;
                } else if (insType == 'General Insurance documents') {
                    this.generalInsDocDetId = result;
                }

            })
            .catch(error => {
                console.error(error)
                console.log('createDocDetailForIns error -', JSON.stringify(error))
            })
            .catch((err) => {
                //this.showToast("Error", "error", "Error occured in Updating Owner  " + err.message);
                console.log(" Error occured in createDocDetailForIns  Err=== ", err);
                //  this.showSpinner = false;

            });
    }
    getdocDetail() {
        let params = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ["Id", "LAN__c", "Appl__c", "DocMstr__c", "DocCatgry__c", "DocTyp__c", "Applicant_KYC__c", "DocSubTyp__c"],
            // where LAN__c ='' AND Appl__c ='' AND DocCatgry__c = 'Insurance Document'
            queryCriteria: ' where LAN__c = \'' + this.loanAppId + '\' AND Appl__c = \'' + this.applicantIdOnTabset + '\' AND DocCatgry__c = \'' + 'Insurance documents' + '\''
        };
        console.log("params", params);
        getAssetPropType({ params: params })
            .then((res) => {
                if (res && res.parentRecords) {
                    let responce = JSON.parse(JSON.stringify(res.parentRecords));
                    //console.log('rational val ' , JSON.stringify(responce));
                    responce.forEach(element => {
                        if (element.DocTyp__c == "Life Insurance documents") {
                            this.lifeInsDocDetId = element.Id;
                            this.getUploadedFileData(this.lifeInsDocDetId, 'life');
                        } else if (element.DocTyp__c == "General Insurance documents") {
                            this.generalInsDocDetId = element.Id;
                            this.getUploadedFileData(this.generalInsDocDetId, 'general');
                        }
                    });
                    console.log('getdocDetail val ', JSON.stringify(responce), ' : lifeInsDocDetId : ', this.lifeInsDocDetId, ' : generalInsDocDetId : ', this.generalInsDocDetId);
                }
            })
            .catch((err) => {
                //this.showToast("Error", "error", "Error occured in Updating Owner  " + err.message);
                console.log(" Error occured in getdocDetail  Err=== ", err);
                //  this.showSpinner = false;

            });
    }
    @track
    addressObj = {
        Id: '',
        recType: '',
        isAppointee: false,
        pincode: '',
        pincodeId: '',
        city: '',
        cityId: '',
        state: '',
        stateId: '',
        appointee: {
            pincode: '',
            pincodeId: '',
            city: '',
            cityId: '',
            state: '',
            stateId: '',
        }
    };
    @track addressSelected;

    @track
    pincodeParams = {
        ParentObjectName: 'PincodeMstr__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'City__r.City__c'],
        childObjFields: [],
        queryCriteria: ''//' where PIN__c = \'' + this.wrapAddressObj.Pincode__c + '\''
    }

    @track cityName

    searchPinCodeMasterRecord(add) {
        let pincode;
        if (add.isAppointee) {
            pincode = add.appointee.pincode;
        } else {
            pincode = add.pincode;
        }

        this.pincodeParams.queryCriteria = ' where PIN__c = \'' + pincode + '\''
        getSobjectData({ params: this.pincodeParams })
            .then((result) => {
                console.log('searchPinCodeMasterRecord O', add, result.parentRecords[0]);
                if (add.isAppointee) {
                    add.appointee.city = result.parentRecords[0].City__r.City__c;
                    add.appointee.cityId = result.parentRecords[0].City__r.Id;
                } else {
                    add.city = result.parentRecords[0].City__r.City__c;
                    add.cityId = result.parentRecords[0].City__r.Id;

                }

                console.log('searchPinCodeMasterRecord city', add, result.parentRecords[0]);
                // this.wrapAddressObj.City__c = this.cityName;
                // this.wrapAddressObj.CityId__c = result.parentRecords[0].City__r.Id;
                // this.wrapAddressObj.State__c = result.parentRecords[0].State__c;
                // this.wrapAddressObj.StateId__c = result.parentRecords[0].City__r.Id;

                this.searchCityNstate(add);
            })
            .catch((error) => {
                console.error('Error in line ##189', error)
            })
    }

    //parameter to find the City and State for pincode
    @track
    cityNstateParams = {
        ParentObjectName: 'LocMstr__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'City__c', 'State__c'],
        childObjFields: [],
        queryCriteria: ''// ' where City__c = \'' + this.cityName + '\''
    }


    searchCityNstate(add) {

        let city;
        if (add.isAppointee) {
            city = add.appointee.city;
        } else {
            city = add.city
        }
        this.cityNstateParams.queryCriteria = ' where City__c = \'' + city + '\''
        getSobjectData({ params: this.cityNstateParams })
            .then((result) => {
                console.log('Line ##207', result)

                if (add.isAppointee) {
                    add.appointee.state = result.parentRecords[0].State__c
                    add.appointee.stateId = result.parentRecords[0].Id;
                } else {
                    add.state = result.parentRecords[0].State__c
                    add.stateId = result.parentRecords[0].Id;
                }
                this.addressSelected = add;
                console.log('searchPinCodeMasterRecord state', result.parentRecords[0], this.addressSelected);
                if (add.recType === 'life') {
                    this.nomineeListLife.forEach(ele => {
                        if (ele.id == add.Id) {
                            console.log('searchPinCodeMasterRecord nomineeListLife', ele);
                            if (add.isAppointee) {
                                ele.appointee.city = add.appointee.city;
                                ele.appointee.state = add.appointee.state;

                                ele.appointee.pincode = add.appointee.pincode;
                                ele.appointee.pincodeId = add.appointee.pincodeId;
                                ele.appointee.stateId = add.appointee.stateId;
                                ele.appointee.cityId = add.appointee.cityId;
                            } else {
                                ele.city = add.city;
                                ele.state = add.state;
                                ele.pincode = add.pincode;
                                ele.pincodeId = add.pincodeId;
                                ele.stateId = add.stateId;
                                ele.cityId = add.cityId;

                            }

                        }

                    });
                }
                else if (add.recType === 'general') {
                    this.nomineeListGeneral.forEach(ele => {
                        if (ele.id == add.Id) {
                            console.log('searchPinCodeMasterRecord nomineeListLife', ele);
                            if (add.isAppointee) {
                                ele.appointee.city = add.appointee.city;
                                ele.appointee.state = add.appointee.state;

                                ele.appointee.pincode = add.appointee.pincode;
                                ele.appointee.pincodeId = add.appointee.pincodeId;
                                ele.appointee.stateId = add.appointee.stateId;
                                ele.appointee.cityId = add.appointee.cityId;
                            } else {
                                ele.city = add.city;
                                ele.state = add.state;

                                ele.pincode = add.pincode;
                                ele.pincodeId = add.pincodeId;
                                ele.stateId = add.stateId;
                                ele.cityId = add.cityId;
                            }
                        }

                    });

                }

                console.log('final Nominee list fter pin update ', JSON.stringify(this.nomineeListLife), JSON.stringify(this.nomineeListGeneral));


            })
            .catch((error) => {
                console.error('Error in line ##185', error)
            })
        //this.searchstate(add);
    }


    handleValueSelect(event) {
        let lookupRec = event.detail;
        let recId = event.target.dataset.recordid;
        let recType = event.target.dataset.recordtype;
        let isAppointee = false;
        let label = event.target.label;
        if (event.target.dataset.isappointee === 'Yes') {
            isAppointee = true;
        }

        console.log('lookupRec', recType, recId, lookupRec);
        if (label === 'City') {

        }
        if (label === 'State/UT') {

        }

        if (label === 'Pincode') {

            if (lookupRec.mainField) {
                let add = this.addressObj;
                add.Id = recId;
                add.recType = recType;
                add.isAppointee = isAppointee;
                if (isAppointee) {
                    add.appointee.pincode = lookupRec.mainField;
                    add.appointee.pincodeId = lookupRec.id;
                } else {
                    add.pincode = lookupRec.mainField;
                    add.pincodeId = lookupRec.id;
                }

                this.searchPinCodeMasterRecord(add);
            } else {
                let add = this.addressObj;
                add.Id = recId;
                add.recType = recType;
                add.isAppointee = isAppointee;
                if (add.recType === 'life') {
                    this.nomineeListLife.forEach(ele => {
                        if (ele.id == add.Id) {
                            console.log('searchPinCodeMasterRecord nomineeListLife', ele);
                            if (add.isAppointee) {
                                ele.appointee.city = '';
                                ele.appointee.state = '';
                            } else {
                                ele.city = '';
                                ele.state = '';
                            }

                        }

                    });
                }
                else if (add.recType === 'general') {
                    this.nomineeListGeneral.forEach(ele => {
                        if (ele.id == add.Id) {
                            console.log('searchPinCodeMasterRecord nomineeListLife', ele);
                            if (add.isAppointee) {
                                ele.appointee.city = '';
                                ele.appointee.state = '';
                            } else {
                                ele.city = '';
                                ele.state = '';
                            }
                        }
                    });
                }
            }
        }
    }
    @track uploadedDocDetailGeneralIns = [];
    @track uploadedDocDetailLifelIns = [];
    @track hideUploadForGeneral = false;
    @track hideUploadForLife = false;

    getUploadedFileData(docId, insType) {
        getFilePreviewDataList({ ddID: docId })
            .then((res) => {
                console.log('result from getFilePreviewData ', res, insType);

                if (insType === 'life') {

                    if (res && res.length > 0) {
                        this.uploadedDocDetailLifelIns = res;
                        this.hideUploadForLife = true;
                    } else {
                        this.hideUploadForLife = false;
                    }
                } else if (insType === 'general') {
                    this.uploadedDocDetailGeneralIns = res;
                    if (res && res.length > 0) {
                        this.uploadedDocDetailGeneralIns = res;
                        this.hideUploadForGeneral = true;
                    } else {
                        this.hideUploadForGeneral = false;
                    }
                }
                console.log(" uploaded Files ", this.uploadedDocDetailLifelIns, this.uploadedDocDetailGeneralIns);
                //this.disablepFileUpload = false;  this.stop
            })
            .catch((err) => {
                // this.showToast("Error", "error", "Error occured in dd " + err.message);
                console.log(" getFilePreviewData error===", err);


            });
    }
    deleteFile(event) {
        let name = event.target.name
        console.log('handle delete called', name);
        this.fileDelDet = name;
        this.isModalOpen = true;
    }
    @track filePrevDet;
    @track fileDelDet;
    @track showModalForFilePre = false;
    @track isModalOpen = false;
    filePreview(event) {
        let name = event.target.name
        console.log('clecked for preview ', name);

        this.filePrevDet = name;

        this.showModalForFilePre = true;
        this.url = '/sfc/servlet.shepherd/document/download/' + name.cdId;// this.uploadedDocDetail.cdId;//this.contDocId
        console.log('this.url' + this.url);

    }
    handleUploadFinished(event) {
        console.log('handleUploadFinished ', event);
        //const uploadedFiles = event.detail.files;
        this.showUploadModal = false;
        //this.disablepFileUpload = true;
        this.showToast("Success", "success", "Document Uploaded Successfully");
        this.getUploadedFileData(this.lifeInsDocDetId, 'life');
        this.getUploadedFileData(this.generalInsDocDetId, 'general');
    }
    showToast(title, variant, message) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message
        });
        this.dispatchEvent(evt);
    }
    handleCloseModalEvent(event) {
        this.showModalForFilePre = false;
    }
    closeModal() {
        console.log('isModalOpen ', this.isModalOpen);
        this.isModalOpen = false;
    }
    handleRemoveRecord() {
        console.log('delete started ', JSON.stringify(this.fileDelDet));
        this.showSpinner = true;
        if (this.fileDelDet.cdlId) {
            let recList = [];
            let cldRecord = {};
            cldRecord['Id'] = this.fileDelDet.cdlId;
            recList.push(cldRecord);
            console.log('delete started ', JSON.stringify(recList));
            deleteDocRecord({ rcrds: recList })
                // .then((result) => {
                .then((result) => {
                    this.getUploadedFileData(this.lifeInsDocDetId, 'life');
                    this.getUploadedFileData(this.generalInsDocDetId, 'general');
                    this.showSpinner = false;
                    this.isModalOpen = false;
                    console.log('delete result ', JSON.stringify(result));
                })
                .catch((error) => {
                    this.isModalOpen = false;
                    this.showSpinner = false;
                    this.showToast("Error", "error", "Unable To delete File" + err.message);
                });
        } else {
            this.showSpinner = false;
        }
    }

}