import { LightningElement, track, api, wire } from 'lwc';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, MessageContext, APPLICATION_SCOPE } from "lightning/messageService";
import { ShowToastEvent } from "lightning/platformShowToastEvent";


import getRoiPfData from '@salesforce/apex/RoiPfCorrectionController.getRoiPfData';
import saveRoiPfData from '@salesforce/apex/RoiPfCorrectionController.saveRoiPfData';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import getSobjectDataNonCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';

import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import CURRENTUSERID from '@salesforce/user/Id';

export default class RoiPfCorrection extends LightningElement {

    @api recordId;
    @api loanAppId;
    @api isReadOnly;
    @api hasEditAccess;
    @api layoutSize;
    @track showLoanTermModal = false;
    @track showRoiPfForm = false;
    filterConditionForLookup = 'EmpRole__c IN(\'' + this.emprole + '\',\'' + this.chrole + '\',\'' + this.acmrole + '\',\'' + this.rcmrole + '\',\'' + this.zcmrole + '\',\'' + this.ncmrole + '\') ' + 'AND Employee__c != \'' + this.userId + '\'';
    @track disableInitiateRoi = false;
    @track showSpinner = false;
    @track showApproverProp = false;

    @track approverId = '';
    @track recomenderId = '';
    @track recommenderName = '';
    @track approverName = '';
    @track decision = '';
    get isRmUser() {

        return this.salesRole;
        //(this.userRole == 'RM' || this.userRole == 'SM' || this.userRole == 'BBH') ? true : false;
    }
    @track salesRole = false;

    get isRecomendorOrApprover() {
        return CURRENTUSERID == this.approverId || CURRENTUSERID == this.approverId;
    }
    get isApprover() {
        return CURRENTUSERID == this.approverId;
    }
    saveSubscription = null;
    @wire(MessageContext)
    MessageContext;
    YesNoOpt = [{ label: "YES", value: "YES" },
    { label: "NO", value: "NO" }
    ];
    ynOpt = [{ label: "YES", value: "Y" },
    { label: "NO", value: "N" }
    ];

    decisionOption = [{ label: "Forward To Approver", value: "Forward To Approver" }
    ];
    isNotApprover = true;
    disableInput = false;
    get disableMode() {

        return this.isReadOnly || this.disableInput
    }

    //select  where BranchCode__c = 'MUM'  AND IsActive__c = true and EmpRole__c in ('BBH','CBH','ABH','RBH','DBH','CBO')
    //     @track thRecommender = {
    //         ParentObjectName: 'TeamHierarchy__c',
    //         ChildObjectRelName: '',
    //         parentObjFields: ['Id', 'Employee__c', 'Product_Type__c', 'EmpRole__c', 'FullName__c', 'BranchCode__c'],
    //         childObjFields: [],
    //         queryCriteria: "BranchCode__c = 'MUM' \n AND EmpRole__c IN ('BBH', 'CBH', 'ABH', 'RBH', 'DBH', 'CBO')",
    // queryCriteria: ' where BranchCode__c = \'' + 'MUM' + '\' AND EmpRole__c IN \'('BBH', 'CBH', 'ABH', 'RBH', 'DBH', 'CBO')'\' order by CreatedDate desc'
    //     }

    //     @wire(getSobjectData, { params: '$thRecommender' })
    //     getmasterDataRec({ data, error }) {
    //         if (data) {
    //             console.log('MasterData__c  thRecommender >>>>', data);
    //             if (data.parentRecords !== undefined) {
    //                 console.log('MasterData__c  thRecommender res >>>>', data.parentRecords);
    //             }

    //         }
    //         if (error) {
    //             console.error('ERROR APPL RELOOK::::thRecommender:::#133', error)
    //             console.log('masterRec thRecommender', this.masterRec);
    //         }
    //     }

    @track approverOpt = [];
    @track recomenderOpt = [];
    @track approverRoleList;
    @track masterRec = {
        ParentObjectName: 'MasterData__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Type__c', 'Roles__c', 'Product__c', 'ROI_deviation_limit__c', 'RoiDeviLowerLimit__c'],
        childObjFields: [],
        queryCriteria: ' where Type__c = \'' + 'ROI Deviation Master' + '\''
    }
    @wire(getSobjectData, { params: '$masterRec' })
    getmasterData({ data, error }) {
        if (data) {
            console.log('MasterData__c  >>>>', data);
            if (data.parentRecords !== undefined) {
                console.log('MasterData__c  res >>>>', data.parentRecords);
                this.approverRoleList = data.parentRecords;
            }

        }
        if (error) {
            console.error('ERROR APPL RELOOK:::::::#133', error)
        }
    }
    //select   Product_Name__c, Maximum_ROI__c, Maximum_PF__c, Minimum_ROI_c__c, Minimum_PF__c  from pricingApprovalMaxROIndPF__mdt  
    get revRoiPlaceholder() {

        if (this.ROI_PF_Limit && this.roiPfData.RevRoiMaxVal) {
            return 'Enter a number between ' + this.ROI_PF_Limit.Minimum_ROI__c + ' and ' + this.roiPfData.RevRoiMaxVal;
        } else {
            return '';
        }
    }
    get revPfPlaceholder() {

        if (this.ROI_PF_Limit && this.roiPfData.RaacPF) {
            return 'Enter a number between ' + this.ROI_PF_Limit.Minimum_PF__c + ' and ' + this.roiPfData.RaacPF;
        } else {
            return '';
        }
    }
    @track ROI_PF_Limit;
    roiPfLImits(product) {
        let params = {
            ParentObjectName: 'pricingApprovalMaxROIndPF__mdt',
            ChildObjectRelName: '',
            parentObjFields: ['Product_Name__c', 'Maximum_ROI__c', 'Maximum_PF__c', 'Minimum_ROI__c', 'Minimum_PF__c'],
            childObjFields: [],
            queryCriteria: ' where Product_Name__c = \'' + product + '\''
        }
        getSobjectDataNonCacheable({ params: params })
            .then((result) => {
                console.log('pricingApprovalMaxROIndPF__mdt    ', JSON.stringify(result));
                if (result.parentRecords) {
                    this.ROI_PF_Limit = result.parentRecords[0];
                }

            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting pricingApprovalMaxROIndPF__mdt is ', error);

            });
        // getmasterData({ data, error }) {
        //     if (data) {
        //         console.log('pricingApprovalMaxROIndPF__mdt  >>>>', data);
        //         this.ROI_PF_Limit = data;

        //     }
        //     if (error) {
        //         console.error('Error in pricingApprovalMaxROIndPF__mdt:::::::#133', error)
        //     }
        // }
    }


    get ROI_PF_MaxMin() {
        if (this.ROI_PF_Limit && this.loanAppData.Product__c) {
            console.log('data in metadeta  : ', this.ROI_PF_Limit.find(item => item.Product_Name__c == this.loanAppData.Product__c));
            return this.ROI_PF_Limit.find(item => item.Product_Name__c == this.loanAppData.Product__c);
        } else {
            return null;
        }
    }


    @track teamHierParam = {
        ParentObjectName: 'TeamHierarchy__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'EmpRole__c', 'Employee__c'],
        childObjFields: [],
        queryCriteria: ' where Employee__c = \'' + CURRENTUSERID + '\' limit 1'
    }
    @wire(getSobjectData, { params: '$teamHierParam' })
    teamHierHandler({ data, error }) {
        if (data) {
            console.log('DATA IN APPL RELOOK :::: #125>>>>', data);
            if (data.parentRecords !== undefined) {
                this.userRole = data.parentRecords[0].EmpRole__c
                console.log('DATA IN APPL RELOOK :::: #128>>>>', this.userRole);
                if (this.userRole == 'RM' || this.userRole == 'SM' || this.userRole == 'BBH') {
                    this.salesRole = true;
                } else {
                    this.salesRole = false;
                }
            }

        }
        if (error) {
            console.error('ERROR APPL RELOOK:::::::#133', error)
        }
    }
    connectedCallback() {
        this.sunscribeToSaveMessageChannel();
        console.log('CURRENTUSERID ', CURRENTUSERID);
        this.getSharingHierarchyForSales();
        this.getCreatedRoidata();
        this.getLoanData();
    }
    handleInitiateRoi(event) {
        this.showLoanTermModal = true;
        //this.getRoiData();
    }
    closeModal() {
        this.showLoanTermModal = false;
    }

    handleSubmit() {
        this.getRoiData();

    }
    @track
    roiPfData = {};
    @track loanAppealData;
    @track formattedItems = []; // Array to hold formatted items

    // This getter will format the dates when the appealItemList is set or changed
    // get formattedAppealItems() {
    //     if (!this.appealItemList) return [];
    //     let revRoi
    //     let revPf
    //     this.appealItemList.forEach(i=>{
    //         if(i.RevRoi){
    //             revRoi=i.RevRoi;
    //         }
    //         if(i.RevPF){
    //             revPf=i.RevRoi;
    //         }
    //     })
    //     // Format each item in the list
    //     return this.appealItemList.map(item => {
    //         return {
    //             ...item, (item.RevRoi ? item.RevRoi : revRoi), item.RevPF ? item.RevPF : revPf
    //             formattedDate: this.formatDate(item.CreatedDate)
    //         };
    //     });
    // }

    get formattedAppealItems() {
        if (!this.appealItemList) return [];

        let revRoi;
        let revPf;

        // Identify the first available RevRoi and RevPF values in the list
        this.appealItemList.forEach(item => {
            if (!revRoi && item.RevRoi) {
                revRoi = item.RevRoi;
            }
            if (!revPf && item.RevPF) {
                revPf = item.RevPF;
            }
        });

        // Format each item in the list
        return this.appealItemList.map(item => {
            return {
                ...item, // Spread the original item properties
                RevRoi: item.RevRoi || revRoi, // Use the item's RevRoi if present, otherwise use the first found RevRoi
                RevPF: item.RevPF || revPf,    // Use the item's RevPF if present, otherwise use the first found RevPF
                formattedDate: this.formatDate(item.CreatedDate) // Add formatted date
            };
        });
    }
    get formattedloanAppealData() {
        if (!this.loanAppealData) return [];

        // Format each item in the list
        return this.loanAppealData.map(item => {
            return {
                ...item,
                formattedDate: this.formatDate(item.CreatedDate)
            };
        });
    }

    // Method to format the date
    // formatDate(dateString) {
    //     if (!dateString) return 'No date available';

    //     const date = new Date(dateString);
    //     if (isNaN(date.getTime())) return 'Invalid date';

    //     const day = String(date.getDate()).padStart(2, '0');
    //     const month = date.toLocaleString('default', { month: 'short' }); // 'short' for abbreviated month
    //     const year = date.getFullYear();

    //     // Extract hours and minutes
    //     const hours = String(date.getHours()).padStart(2, '0');
    //     const minutes = String(date.getMinutes()).padStart(2, '0');

    //     return `${day}-${month}-${year} ${hours}:${minutes}`;
    // }
    formatDate(dateString) {
        if (!dateString) return 'No date available';

        const date = new Date(dateString);
        if (isNaN(date.getTime())) return 'Invalid date';

        const day = String(date.getDate()).padStart(2, '0');
        const month = date.toLocaleString('default', { month: 'short' });
        const year = date.getFullYear();

        // Extract hours and minutes
        let hours = date.getHours();
        const minutes = String(date.getMinutes()).padStart(2, '0');

        // Determine AM or PM
        const amPm = hours >= 12 ? 'PM' : 'AM';

        // Convert to 12-hour format
        hours = hours % 12 || 12; // Converts 0 to 12 for 12 AM

        return `${day}-${month}-${year} ${String(hours).padStart(2, '0')}:${minutes} ${amPm}`;
    }


    get disablebtn() {
        if (this.roiPresent) { //&& this.hasEditAccess
            return true;

        } else if (this.isRmUser) { //&& this.hasEditAccess
            if (this.loanAppData && this.loanAppData.Stage__c == 'Post Sanction' && (this.loanAppData.SubStage__c == 'Ops Query Pool' || this.loanAppData.SubStage__c == 'UW Approval Pool')) {
                return true;
            } else if (this.loanAppData && this.loanAppData.Stage__c == 'Post Sanction' && (this.loanAppData.SubStage__c == 'Data Entry' || this.loanAppData.SubStage__c == 'Data Entry Pool')) {
                return false;
            } else {
                return true;
            }

        } else {
            return true;
        }

    }
    @track roiPresent = false;
    getCreatedRoidata() {
        //select Id,Name, Status__c, LoanAppl__c, Comments__c, DocDet__c,  OwnerName__c, LAN__c,  Recommender__c, Approver__c  from LoanAppeal__c  where LoanAppl__c ='a08C4000007WKIwIAO' AND RecordType.name = 'Roi Pf Correction'
        let params = {
            ParentObjectName: 'LoanAppeal__c',
            parentObjFields: ['Id', 'Name', 'CreatedDate', 'RecordType.name', 'Recommender__r.Name', 'Approver__r.Name', 'ApproverLevel__c', 'Status__c', 'LoanAppl__c', 'Comments__c', 'OwnerName__c', 'LAN__c', 'Recommender__c', 'Approver__c', 'Decision__c'],
            queryCriteria: ' where LoanAppl__c = \'' + this.loanAppId + '\' order by CreatedDate  ' //'\' AND RecordType.name = \'' + 'Roi Pf Correction' + 
            //' where ParentId = \'' + this._recordId + '\' AND Field=\''+field+'\' order by CreatedDate desc limit 1'
        }
        this.showSpinner = true;
        getSobjectDataNonCacheable({ params: params })
            .then((result) => {
                console.log('LoanAppeal__c    ', JSON.stringify(result));
                if (result.parentRecords) {
                    let loanAppealDataLocal = JSON.parse(JSON.stringify(result.parentRecords));
                    let loanAppealDataLocalNew = [];
                    loanAppealDataLocal.forEach(ele => {
                        if (ele.RecordType.Name == 'Roi Pf Correction') {


                            if (ele.Status__c == 'In Progress' && ele.Approver__c == CURRENTUSERID) {
                                ele['EnableAction'] = false;
                            } else {
                                ele['EnableAction'] = true;
                            }
                            loanAppealDataLocalNew.push(ele);
                        }
                        if (ele.RecordType.Name == 'Roi Pf Correction' || ele.RecordType.Name == 'Loan Term Negotiation') {
                            if (ele.Status__c === 'New' || ele.Status__c === 'In Progress') {// || ele.Status__c === 'Approve'
                                this.disableInitiateRoi = true;
                                this.roiPresent = true;
                            } else {
                                //  this.roiPresent = false;
                                if (this.isRmUser) {
                                    this.disableInitiateRoi = false;
                                } else {
                                    this.disableInitiateRoi = true;
                                }
                            }
                        }



                    });

                    this.loanAppealData = loanAppealDataLocalNew;

                    console.log(' this.loanAppealData   .... ', this.loanAppealData);
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting LoanAppeal__c is ', error);

            });
    }
    getRoiData() {
        this.roiPfData = {};
        this.appealItemList = [];
        this.showRoiPfForm = false;
        this.disableInput = false;

        this.lenghtAppItm = 0;
        this.appealItemList = [];
        this.latestroipfRevPf = 0;
        this.latestroipfRevROI = 0;


        getRoiPfData({ loanAppid: this.loanAppId, loanAppealId: '', actionType: 'Create' })
            .then((result) => {
                console.log('getRoiData data  ', result);

                this.roiPfData = result;
                let appLevel = 0;
                appLevel = this.roiPfData.RaacROI - (this.roiPfData.EffRoiUw >= this.roiPfData.RevRoi ? this.roiPfData.RevRoi : this.roiPfData.EffRoiUw);
                this.roiPfData.ApproverLevel = appLevel.toFixed(2);//number.toFixed(2);
                this.updateApproverList()
                this.closeModal();
                //this.disableInitiateRoi = true;
                this.showRoiPfForm = true;
                this.showApproverProp = true;
                this.latestroipfRevROI = result.RevRoi;//
                this.latestroipfRevPf = result.RevPf;//

            })
            .catch((error) => {
                console.log("error occured in creating  RoiData", error);
                this.showSpinner = false;
                this.showToast("Error", "error", ' Error in creating Data.. ');

            });
    }
    sunscribeToSaveMessageChannel() {
        this.saveSubscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveLms(values)
        );
    }
    handleSaveLms(values) {

        // console.log('values to save through Lms  ', JSON.stringify(values));
        console.log('this.draftvalues onclick of save ');
        //this.saveLoanTermItem();
        let valid = this.checkValidation();
        if (valid) {
            this.saveRoiData();
        } else {
            this.showToast("Error ", "error", 'Required field Missing');
            console.log('validation failed ');
        }


    }
    checkValidation() {
        let isValid = true
        this.template.querySelectorAll('lightning-textarea').forEach(element => {

            if (element.reportValidity()) {
                console.log('element passed textarea');

            } else {
                isValid = false;
                console.log('element else--', element);
            }
        });
        this.template.querySelectorAll('lightning-combobox').forEach(element => {

            if (element.reportValidity()) {
                console.log('element passed lightning-combobox');

            } else {
                isValid = false;
                console.log('element else--', element);
            }
        });
        this.template.querySelectorAll('lightning-input').forEach(element => {

            if (element.reportValidity()) {
                console.log('element passed lightning-input');

            } else {
                isValid = false;
                console.log('element else--', element);
            }
        });

        return isValid;
    }
    saveRoiData() {
        //  saveRoiPfData(RoiPfCorrWpr roiPfdata)
        this.showSpinner = true;

        console.log('before save', this.roiPfData);
        let decision = this.roiPfData.Decision;
        if (decision == 'Approve' || decision == 'Reject') {
            this.roiPfData.approverId = CURRENTUSERID;
        }
        saveRoiPfData({ roiPfdata: this.roiPfData })
            .then((result) => {
                console.log('saveRoiPfData data  ', result);
                this.getCreatedRoidata();
                this.showRoiPfForm = false;
                if (decision == 'Forward To Recommender') {
                    this.showToast("Success", "success", 'Case Forwarded To Recommender Successfully');
                } else if (decision == 'Forward To Approver') {
                    this.showToast("Success", "success", 'Case Forwarded To Approver Successfully');
                } else if (decision == 'Reject') {
                    this.showToast("Success", "success", 'Case is Rejected Successfully');
                } else if (decision == 'Approve') {
                    this.createIntegrationMessage();
                    this.showToast("Success", "success", 'Case is Approve Successfully');
                }


            })
            .catch((error) => {
                this.showSpinner = false;
                console.log("error occured in getting saveRoiPfData", error);

                this.showToast("Error", "error", ' Error in Saving ROI/PF');
            });

    }

    @track intRecords = [];
    createIntegrationMessage() {
        let fieldsWo = {};
        fieldsWo['sobjectType'] = 'IntgMsg__c';
        fieldsWo['Name'] = 'Crif Auth Login'; //serviceName;//'KYC OCR'
        fieldsWo['BU__c'] = 'HL / STL';
        fieldsWo['IsActive__c'] = true;
        fieldsWo['Svc__c'] = 'Crif Auth Login'; //serviceName;
        fieldsWo['Status__c'] = 'New';
        fieldsWo['Outbound__c'] = true;
        fieldsWo['RefObj__c'] = 'LoanAppl__c';
        fieldsWo['ApiVendor__c'] = 'Crif';
        fieldsWo['RefId__c'] = this.loanAppId;
        this.intRecords.push(fieldsWo);
        this.createRecords(this.intRecords);
    }

    createRecords(intRecords) {
        this.showSpinner = true;
        upsertMultipleRecord({ params: intRecords })
            .then((result) => {
                console.log('result In creating Record 353', result);
                //this.showToastMessage('Success',this.label.BRETriggerMessage,'Success','sticky')
                //this.dispatchEvent(new CloseActionScreenEvent());
                this.intRecords = [];
                //this.breIntMsgId = result[0].Id;
                //this.startPolling();
                //  this.startFirstIntPolling();
            })
            .catch((error) => {
                this.showToast('Error', error, 'Error', 'sticky');
                //this.dispatchEvent(new CloseActionScreenEvent());
                console.log('Error In creating Record', error);
                // this.fireCustomEvent("Error", "error", "Error occured in accepting File  " + error.message, false);
            });
    }
    showToast(title, variant, message) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
    }
    handleLookupFieldChange(event) {
        this.lookupId = event.detail;
        let lookupIds = this.lookupId.id;
        this.lookupId = lookupIds;
        let tempevent = JSON.parse(JSON.stringify(event.detail));
        this.ForwardToUserName = tempevent.mainField;


    }
    handleInputChangeRout(event) {
        let val = event.target.value;
        if (val === 'YES') {
            this.showRoutRec = true;
            this.decisionOption = [
                { label: "Forward To Recommender", value: "Forward To Recommender" }
            ];
        } else {
            this.showRoutRec = false;
            this.roiPfData.RecomenderId = '';
            this.decisionOption = [{ label: "Forward To Approver", value: "Forward To Approver" }
            ];
        }
    }
    get isPricingApplicable() {
        return this.isPricingApplicableVal == 'Y';
    }

    @track isPricingApplicableVal = 'Y';
    handleInputChangePricing(event) {
        let val = event.target.value;
        this.isPricingApplicableVal = val;
        this.roiPfData.IsPricingApplicable = val;
    }
    @track showRoutRec = false;
    handleInputChange(event) {
        let val = event.target.value;
        let name = event.target.name;
        console.log('handleInputChange  ', val, name);
        if (name != 'RoutRec') {
            this.roiPfData[name] = val;
        }
        let appLevel = 0
        // hideApprover if false
        // showRoutRec if true
        if (name == 'Decision') {
            // this.roiPfData.RecomenderId = '';
            // this.roiPfData.ApproverId = '';
            // this.approverId = '';
            // this.recomenderId = '';
            // this.lookupIdProp = '';
            // this.lookupIdAppr = '';
            if (val == 'Forward To Recommender') {
                if (this.roiPfData.Status == 'New') {
                    this.showRoutRec = true;
                    this.hideApprover = false;
                } else {
                    this.showRoutRec = true;
                    this.hideApprover = true;
                }
            } else if (val == 'Forward To Approver') {
                this.showRoutRec = false;
                this.hideApprover = false;
            } else if (val == 'Approve') {
                this.showRoutRec = false;
                this.hideApprover = true;
                this.isNotApprover = false;
            } else {
                this.showRoutRec = false;
                this.hideApprover = true;
            }
        }
        console.log('Racc roi ', this.roiPfData.RaacROI, '  Effective Roi ', this.roiPfData.EffRoiUw, '  Ui revised  Roi ', this.roiPfData.RevRoi);
        appLevel = this.roiPfData.RaacROI - (this.roiPfData.EffRoiUw >= this.roiPfData.RevRoi ? this.roiPfData.RevRoi : this.roiPfData.EffRoiUw);

        this.roiPfData.ApproverLevel = appLevel.toFixed(2);//number.toFixed(2);
        console.log('handleInputChange  ', appLevel, '   tyty ', JSON.stringify(this.roiPfData));
        if (appLevel > 0 && (name === 'RevRoi' || name === 'RevPf')) {
            this.updateApproverList();
            // this.roiPfData.RecomenderId = '';
            // this.roiPfData.ApproverId = '';
            if (this.recomenderId == CURRENTUSERID && this.decision == 'Forward To Recommender') {
                this.decisionOption = [{ label: 'Forward To Recommender', value: 'Forward To Recommender' }, { label: 'Forward To Approver', value: 'Forward To Approver' }, { label: 'Reject', value: 'Reject' }];
                if (this.approverRoleList) {
                    this.approverRoleList.forEach(ele => {
                        let devlevel = ele.ROI_deviation_limit__c / 100
                        if (ele.Roles__c === this.userRole && devlevel >= this.roiPfData.ApproverLevel) {
                            this.decisionOption = [{ label: 'Forward To Recommender', value: 'Forward To Recommender' }, { label: 'Forward To Approver', value: 'Forward To Approver' }, { label: 'Reject', value: 'Reject' }, { label: 'Approve', value: 'Approve' }];
                        }
                    });
                }

            } else if (this.approverId == CURRENTUSERID && this.decision == 'Forward To Approver') {
                this.decisionOption = [{ label: 'Reject', value: 'Reject' }];
                if (this.approverRoleList) {
                    this.approverRoleList.forEach(ele => {
                        let devlevel = ele.ROI_deviation_limit__c / 100
                        if (ele.Roles__c === this.userRole && devlevel >= this.roiPfData.ApproverLevel) {
                            this.decisionOption = [{ label: 'Reject', value: 'Reject' }, { label: 'Approve', value: 'Approve' }];
                        }
                    });
                }

            }

        }

    }

    @track salesRoleList = ['RBH', 'DBH'];
    getSharingHierarchyForSales() {

        let params = {
            ParentObjectName: 'SharingHierarchy__mdt',
            parentObjFields: ['DeveloperName', 'SupervisoreRoleSharing__c', 'BrchRoleSharing__c', 'SharingReason__c'],
            queryCriteria: ' where SharingReason__c = \'' + 'Sales__c' + '\''
        }
        getSobjectDataNonCacheable({ params: params })
            .then((result) => {
                console.log('SharingHierarchy__mdt    ', JSON.stringify(result));
                if (result.parentRecords) {
                    let salesData = result.parentRecords[0].BrchRoleSharing__c;
                    //this.salesRoleList = salesData.split(',');
                    console.log('SharingHierarchy__mdt    salesData ', salesData, this.salesRoleList);
                }
                this.getLoanData();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting SharingHierarchy__mdt is ', error);

            });

    }

    @track loanAppData;

    getLoanData() {
        //SELECT tolabel(Rate_Type_Floating_Flag__c),  EffectiveROI__c, RevisedROI__c,LeadROI__c ,PFInPercentage__c, BrchCode__c ,BranchTier__c, BrchName__c ,City__c,SanLoanAmt__c ,Product__c  FROM LoanAppl__c WHERE Id =:loanAppid  
        let params = {
            ParentObjectName: 'LoanAppl__c',
            parentObjFields: ['BrchCode__c', 'Product__c', 'PricingApprovalApplicable__c', "Stage__c", "SubStage__c"],
            queryCriteria: ' where Id = \'' + this.loanAppId + '\''
        }
        getSobjectDataNonCacheable({ params: params })
            .then((result) => {
                console.log('LoanAppl__c     ', JSON.stringify(result));
                if (result.parentRecords) {
                    this.loanAppData = result.parentRecords[0];
                    this.getTeamHyrData(result.parentRecords[0].BrchCode__c);
                    this.isPricingApplicableVal = 'Y';//result.parentRecords[0] && result.parentRecords[0].PricingApprovalApplicable__c != null ? result.parentRecords[0].PricingApprovalApplicable__c : 'N';
                    //console.log('isPricingApplicableVal ', this.isPricingApplicableVal);
                    this.roiPfLImits(result.parentRecords[0].Product__c);
                }

            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting LoanAppl__c is ', error);

            });

    }

    getTeamHyrData(branchCode) {
        //SELECT  TeamHierarchy__c  WHERE BranchCode__c =: laonApp.BrchCode__c  AND IsActive__c = true   AND EmpRole__c != null
        let params = {
            ParentObjectName: 'TeamHierarchy__c',
            parentObjFields: ['Id', 'Employee__c', 'Product_Type__c', 'EmpRole__c', 'FullName__c', 'BranchCode__c'],
            queryCriteria: ' where IsActive__c = true \ AND  BranchCode__c = \'' + branchCode + '\''
        }
        console.log('params   1212 ', params.queryCriteria);
        getSobjectDataNonCacheable({ params: params })
            .then((result) => {
                console.log('TeamHierarchy__c     ', JSON.stringify(result));
                if (result.parentRecords) {
                    result.parentRecords.forEach(ele => {
                        let pv = { label: ele.FullName__c, value: ele.Employee__c, role: ele.EmpRole__c };
                        this.approverOpt.push(pv);
                        if (this.salesRoleList.includes(ele.EmpRole__c)) {
                            this.recomenderOpt.push(pv);
                        }

                    });

                }
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting TeamHierarchy__c is ', error);

            });

    }
    @track approverOptUi = [];
    @track roleAccordingToLevel = ['CBO'];

    updateApproverList() {
        let level = this.roiPfData.ApproverLevel;
        let appRole = [];
        if (this.approverRoleList) {
            this.approverRoleList.forEach(ele => {
                let devlevel = ele.ROI_deviation_limit__c / 100

                if (devlevel >= level) {
                    appRole.push(ele.Roles__c);
                    console.log(ele.Roles__c);
                }
                else if (devlevel > 1) {
                    appRole.push(ele.Roles__c);
                }
            });
        }
        console.log('appRole ', appRole);
        this.roleAccordingToLevel = appRole;
        console.log('roleAccordingToLevel ', JSON.stringify(this.roleAccordingToLevel));
        // let approverOptLocal = [];
        // if (this.approverOpt) {
        //     this.approverOpt.forEach(element => {
        //         if (appRole.contains(element.role)) {
        //             approverOptLocal.push(element);
        //         }
        //     });
        //     this.approverOptUi = approverOptLocal;
        // }

        // this.approverOpt = this.approverOpt.filter(item => !appRole.contains(item.role));
        console.log('approver level  ', JSON.stringify(this.approverOptUi));

    }

    @track appealItemList = [];
    @track appealItemheading = '';
    @track hideRouteRec = false;
    @track hideApprover = false;
    @track hideRecommend = false;
    @track hideForsales = false;
    @track showComment = false;
    @track lenghtAppItm = 0;
    @track latestroipfRevPf = 0;
    @track latestroipfRevROI = 0;
    handleView(event) {
        let lonapplId = event.target.dataset.id;
        let appealItem = {};

        if (this.loanAppealData.filter(item => item.Id == lonapplId)) {

            appealItem = this.loanAppealData.filter(item => item.Id == lonapplId)[0];

            this.approverId = appealItem.Approver__c ? appealItem.Approver__c : '';
            this.recomenderId = appealItem.Recommender__c ? appealItem.Recommender__c : '';
            this.lookupIdProp = this.recomenderId;
            this.lookupIdAppr = this.approverId;
            this.recommenderName = appealItem.Recommender__c && appealItem.Recommender__r.Name ? appealItem.Recommender__r.Name : '';
            this.approverName = appealItem.Approver__c && appealItem.Approver__r.Name ? appealItem.Approver__r.Name : '';
            this.decision = appealItem.Decision__c;

        }
        this.appealItemheading = appealItem ? appealItem.Name : '';

        console.log('appealItem is in view ', appealItem);
        getRoiPfData({ loanAppid: this.loanAppId, loanAppealId: lonapplId, actionType: 'getOlder' })
            .then((result) => {
                if (result) {
                    console.log('getRoiData data  ', result);
                    console.log('idmatch current Id  ', CURRENTUSERID);
                    console.log('idmatch approverId Id  ', this.approverId);
                    console.log('idmatch recomenderId Id  ', this.recomenderId);
                    this.roiPfData = result;


                    if (this.approverId == CURRENTUSERID && this.decision == 'Forward To Approver') {
                        this.decisionOption = [{ label: 'Approve', value: 'Approve' }, { label: 'Reject', value: 'Reject' }];
                        this.showRoiPfForm = true
                        this.hideRouteRec = true;
                        this.hideApprover = true;
                        this.isNotApprover = false;
                        this.showApproverProp = true;
                    } else if (this.recomenderId == CURRENTUSERID && this.decision == 'Forward To Recommender') {
                        this.decisionOption = [{ label: 'Forward To Recommender', value: 'Forward To Recommender' }, { label: 'Forward To Approver', value: 'Forward To Approver' }, { label: 'Reject', value: 'Reject' }];
                        if (this.approverRoleList) {
                            this.approverRoleList.forEach(ele => {
                                let devlevel = ele.ROI_deviation_limit__c / 100
                                if (ele.Roles__c === this.userRole && devlevel >= this.roiPfData.ApproverLevel) {
                                    this.decisionOption = [{ label: 'Forward To Recommender', value: 'Forward To Recommender' }, { label: 'Forward To Approver', value: 'Forward To Approver' }, { label: 'Reject', value: 'Reject' }, { label: 'Approve', value: 'Approve' }];
                                }
                            });
                        }
                        this.showRoiPfForm = true
                        this.hideRecommend = true;
                        this.showComment = true;
                        this.hideRouteRec = true;
                        this.hideApprover = true;
                        this.showApproverProp = true;
                    } else if (appealItem.Status__c == 'New') {
                        this.showRoiPfForm = true;
                        this.hideForsales = true;
                        this.showApproverProp = true;
                    } else {
                        this.showRoiPfForm = true;
                        this.disableInput = true;
                        this.showApproverProp = false;
                    }


                    // if (this.roiPfData.ApproverList.length > 0) {
                    //     this.approverOpt = this.roiPfData.ApproverList;
                    // }
                    if (result.ApplItemList && result.ApplItemList.length > 0) {
                        this.lenghtAppItm = result.ApplItemList.length;
                        this.appealItemList = result.ApplItemList;
                        this.latestroipfRevPf = result.ApplItemList[this.lenghtAppItm - 1].RevPF;
                        this.roiPfData.RevPf = this.latestroipfRevPf;
                        this.latestroipfRevROI = result.ApplItemList[this.lenghtAppItm - 1].RevRoi;
                        this.roiPfData.RevRoi = this.latestroipfRevROI;
                    }

                    console.log(' this.appealItemList', JSON.stringify(this.appealItemList));
                }

            })
            .catch((error) => {
                console.log("error occured in getting getRoiData", error);
            });
    }

    get filterCondn() {
        let val;
        let apvrId = this.approverId;
        // = appealItem.Approver__c ? appealItem.Approver__c : '';
        // this.recomenderId = appealItem.Recommender__c ? appealItem.Recommender__c : '';
        // this.lookupIdProp = this.recomenderId;
        // this.lookupIdAppr = this.approverId;
        //  if (this.loanAppealStatus === 'New') { }
        val = 'EmpRole__c IN (\'' + this.salesRoleList.join('\', \'') + '\') AND Employee__c != \'' + CURRENTUSERID + '\'AND BranchCode__c = \'' + this.loanAppData.BrchCode__c + '\'';// BranchCode__c = \'' + branchCode + '\'

        if (this.lookupIdAppr) {
            val = 'EmpRole__c IN (\'' + this.salesRoleList.join('\', \'') + '\') AND (Employee__c != \'' + CURRENTUSERID + '\'AND Employee__c != \'' + this.lookupIdAppr + '\') AND BranchCode__c = \'' + this.loanAppData.BrchCode__c + '\'';// BranchCode__c = \'' + branchCode + '\'
        }
        console.log('filterCondn salesrole', val, this.lookupIdAppr);
        return val;
    }

    get filterCondnAppr() {
        let val;
        let recId = this.recomenderId;
        val = 'EmpRole__c IN (\'' + this.roleAccordingToLevel.join('\', \'') + '\') AND Employee__c != \'' + CURRENTUSERID + '\'AND BranchCode__c = \'' + this.loanAppData.BrchCode__c + '\'';// BranchCode__c = \'' + branchCode + '\'
        if (this.lookupIdProp) {
            val = 'EmpRole__c IN (\'' + this.roleAccordingToLevel.join('\', \'') + '\') AND (Employee__c != \'' + CURRENTUSERID + '\'AND Employee__c != \'' + this.lookupIdProp + '\') AND BranchCode__c = \'' + this.loanAppData.BrchCode__c + '\'';// BranchCode__c = \'' + branchCode + '\'
        }

        //  if (this.loanAppealStatus === 'New') { }

        console.log('filterCondn approver', val, this.lookupIdProp);

        return val;
    }




    @track lookupIdProp;
    @track lookupIdAppr;
    handleLookupFieldChange(event) {
        if (event.detail) {
            this.lookupIdProp = event.detail.id;
            this.roiPfData.RecomenderId = event.detail.id;
        }
        console.log('recomendor id ::::::', event.detail);
    }
    handleLookupFieldChangeAppr(event) {
        if (event.detail) {
            this.lookupIdAppr = event.detail.id
            this.roiPfData.ApproverId = event.detail.id;
        }
        console.log('Approver id::::::', event.detail);
    }

}