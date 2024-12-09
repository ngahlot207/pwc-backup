import { LightningElement, api, track, wire } from 'lwc';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, MessageContext, APPLICATION_SCOPE } from "lightning/messageService";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { RefreshEvent } from 'lightning/refresh';
import InitiateLoanTerm from "@salesforce/apex/LoanTermNegController.initiateLoanTerm";
import CreateLoanTerm from "@salesforce/apex/LoanTermNegController.createLoanTerm";
import getLoanTerm from "@salesforce/apex/LoanTermNegController.getLoanTerm";
import getSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords'
import getSobjectDataNonCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import CURRENTUSERID from '@salesforce/user/Id';
export default class LoanTermNegotiation extends LightningElement {

    @api recordId;
    @api loanAppId;
    @api isReadOnly;
    @api hasEditAccess;
    @api layoutSize;

    @track ShowReject = false;
    @track ShowApprove = false;
    @track ShowSubmit = false;
    @track applicantId;
    @track loanAppeal;
    get negotiationInitiated() {
        if (this.loanAppeal && this.loanAppeal.Id !== 'nullId') {
            this.applicantId = this.loanAppeal.Id;
            return true;
        } else {
            this.applicantId = this.applicantRecs.Id;
            return false;
        }

    }

    productlistHL = ['Home Loan', 'Small Ticket LAP'];
    productlistBL = ['Business Loan', 'Personal Loan'];

    get isRmUser() {
        const rmRolesHL = ['RM', 'SM', 'BBH'];
        const rmRolesBL = ['RM', 'SM', 'ABH'];

        if (this.productlistHL.includes(this.productType)) {
            return rmRolesHL.includes(this.userRole);
        } else if (this.productlistBL.includes(this.productType)) {
            return rmRolesBL.includes(this.userRole);
        } else {
            return false;
            // // return (this.userRole == 'RM' || this.userRole == 'SM' || this.userRole == 'BBH')
        }
    }


    get isUwUser() {
        return this.userRole == 'UW';
    }
    @track disableClaim = true;
    @track claimAppealFor = null;
    @track userRole;
    @track showLoanTermModal = false;
    @track loanTermData = [];
    @track loanTermDataDisplay = [];
    @track showSpinner = false;
    @track showUploadsection = false;
    YNoption = [{ label: 'YES', value: 'YES' },
    { label: 'NO', value: 'NO' }
    ];

    UwYNoption = [{ label: 'OK TO RELOOK', value: 'YES' },
    { label: 'REVIEW REJECTED', value: 'NO' }
    ];


    saveSubscription = null;
    @wire(MessageContext)
    MessageContext;

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
            }

        }
        if (error) {
            console.error('ERROR APPL RELOOK:::::::#133', error)
        }
    }
    connectedCallback() {
        console.log('APi Data ', this.recordId, this.loanAppId,);
        this.getApplicantRecs();
        this.sunscribeToSaveMessageChannel();
        this.getLoanTermRecord();

    }
    handleButtonClickLoanTerm() {
        this.showLoanTermModal = true;
    }
    closeModal() {

        this.showLoanTermModal = false;
    }

    @track allowCreatingNewAppeal = true;
    @track loanTermRecInd = [];
    @track showAvailabeAppl = false;
    getLoanTermRecord() {
        getLoanTerm({ loanAplId: this.loanAppId })
            .then((result) => {
                if (result) {
                    this.disableClaim = true;
                    this.claimAppealFor = null;
                    console.log(' getLoanTerm res', result);
                    let res = JSON.parse(JSON.stringify(result))
                    this.getAvailableLoanTermRecord();
                    if (res.length > 0) {
                        res.forEach(element => {

                            console.log('checking Owner ', CURRENTUSERID, element.OwnerId, CURRENTUSERID === element.OwnerId);
                            if (element.Status == 'Approve' || element.Status == 'Reject') {
                                element['DisableAppRej'] = true;
                                element['DisableComm'] = true;
                            } else {


                                if (CURRENTUSERID === element.OwnerId) {
                                    element['DisableAppRej'] = false;
                                    element['DisableComm'] = this.isRmUser;
                                } else {
                                    element['DisableAppRej'] = true;
                                    element['DisableComm'] = this.isRmUser;
                                }

                            }
                            if (element.Status == 'New' || element.OwnerName == "UW Pool") {
                                this.disableClaim = false;
                                this.claimAppealFor = element.Id
                            }

                        });
                        this.loanTermData = res;


                        this.showAvailabeAppl = true;
                        console.log('this.loanTermDa', this.loanTermData);
                    }



                } else {

                }
            })
            .catch(error => {
                console.log("get applicantKyc error ", error);
            })
    }
    getAvailableLoanTermRecord() {
        //select Id, OwnerId,   RecordTypeId, Status__c, LoanAppl__c, Comments__c   from LoanAppeal__c 
        let params = {
            ParentObjectName: 'LoanAppeal__c',

            parentObjFields: ["Id", "Name", "CreatedDate", "RecordType.Name", "Owner.Name", "Status__c", "ownerId", "LoanAppl__c", "Comments__c"],
            queryCriteria: ' where LoanAppl__c = \'' + this.loanAppId + '\' order by CreatedDate  '// '\' AND RecordType.name = \'Loan Term Negotiation\'' //+ '\ AND ownerId  = \'' + CURRENTUSERID + '\''

        };
        console.log('loan term rec called ', params);
        getSobjectDataNonCacheable({ params: params })
            .then((result) => {
                console.log('loan term rec called ', result);
                if (result.parentRecords && result.parentRecords.length > 0) {
                    let loanAppealDataLocal = JSON.parse(JSON.stringify(result.parentRecords));

                    loanAppealDataLocal.forEach(ele => {

                        if (ele.RecordType.Name == 'Roi Pf Correction' || ele.RecordType.Name == 'Loan Term Negotiation') {
                            if (ele.Status__c === 'New' || ele.Status__c === 'In Progress') {// || ele.Status__c === 'Approve'
                                this.disableInitiation = true;
                                this.allowCreatingNewAppeal = false;
                            }
                        }



                    });

                } else {
                    //  this.initateLoanTerm();
                    // this.showAvailabeAppl = false;
                }
            })
            .catch(error => {
                console.log("get applicantKyc error ", error);
            })
    }
    handleSubmit() {
        if (this.allowCreatingNewAppeal == true) {
            this.initateLoanTerm();//
        } else {
            this.showToast("Error ", "error", "Please close In progress Loan Term Negotiation before raising new one");
        }

    }
    @track newInitauatedTerm = true;
    initateLoanTerm() {
        console.log('114');
        InitiateLoanTerm({
            loanAppId: this.loanAppId
        })
            .then((result) => {
                console.log(' Initate Loan Term rec', result);
                if (result) {
                    let res = JSON.parse(JSON.stringify(result));
                    res.LoanAplItem.forEach(ele => {
                        if (ele.SalesDecision === 'YES') {
                            ele.SalesCommReq = true;
                            if (ele.Field == 'Attached documents') {
                                this.showUploadsection = true;
                            }
                        } else {
                            ele.SalesCommReq = false;
                            if (ele.Field == 'Attached documents') {
                                this.showUploadsection = false;
                            }
                        }
                        if (ele.UwDecision === 'YES') {
                            ele.UwCommReq = true;
                        } else {
                            ele.UwCommReq = false;
                        }

                        ele['ViewOnlyRm'] = this.isUwUser;
                        ele['ViewOnlyUw'] = this.isRmUser;


                    });
                    this.disableSubmit = false;
                    this.loanTermData.push(res);
                    this.loanAppealItems = res.LoanAplItem;
                    this.newInitauatedTerm = true;
                }



                console.log(' Initate Loan Term rec', this.loanTermData);
                this.closeModal()
                //  this.showLoanTermModal = true;
            })
            .catch((error) => {
                console.log('error in initaiation loan term ', error);
            }).finally(() => {
                //   this.showSpinner = false;
            })
    }
    handleChange(event) {
        let id = event.target.dataset.id;
        let name = event.target.name;
        let value = event.target.value;

        let loanAppealItem;
        if (id.length != 18) {
            loanAppealItem = this.loanAppealItems.find(item => item.tempId == id);
        } else {
            loanAppealItem = this.loanAppealItems.find(item => item.Id == id);
        }
        if (loanAppealItem) {
            loanAppealItem[name] = value;

            if (name == 'SalesDecision') {
                if (value == 'YES') {
                    loanAppealItem.SalesCommReq = true;
                    if (loanAppealItem.Field == 'Attached documents') {
                        this.showUploadsection = true;
                    }

                } else {
                    loanAppealItem.SalesCommReq = false;
                    if (loanAppealItem.Field == 'Attached documents') {
                        this.showUploadsection = false;
                    }
                }

            }

            if (name == 'UwDecision') {
                if (value == 'YES') {
                    loanAppealItem.UwCommReq = true;
                } else {
                    loanAppealItem.UwCommReq = false;
                }


            }

            // console.log(' handleChange dataId ', id, name, value);
            // let docRec = this.loanTermData.LoanAplItem.find(item => item.tempId == id);
            // if (docRec) {
            //     docRec[name] = value;
            //     if (name == 'SalesDecision') {
            //         if (value == 'YES') {
            //             docRec.SalesCommReq = true;
            //         } else {
            //             docRec.SalesCommReq = false;
            //         }

            //     }
            //     if (name == 'UwDecision') {
            //         if (value == 'YES') {
            //             docRec.UwCommReq = true;
            //         } else {
            //             docRec.UwCommReq = false;
            //         }

            //     }

            // }
            console.log(' loanTermData', JSON.stringify(loanAppealItem));
        }
    }
    handleCommentChange(event) {
        let id = event.target.dataset.id;
        let name = event.target.name;
        let value = event.target.value;
        console.log(' handleCommentChange   ....', id, name, value, this.loanAppealItems);
        let loanAppealItem;
        if (id.length != 18) {
            loanAppealItem = this.loanAppealItems.find(item => item.tempId == id);

        } else {
            loanAppealItem = this.loanAppealItems.find(item => item.Id == id);

        }
        if (loanAppealItem) {
            loanAppealItem[name] = value;

        }

        console.log(' loanTermData', JSON.stringify(loanAppealItem));
        // console.log(' handleCommentChange sdataId ', id, name, value);
        // console.log(' handleChange dataId ', id, name, value);
        // let docRec = this.loanTermData.LoanAplItem.find(item => item.tempId == id);
        // if (docRec) {
        //     docRec[name] = value;
        // }
        // console.log(' loanTermData', JSON.stringify(docRec));
    }
    sunscribeToSaveMessageChannel() {
        this.saveSubscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveLms(values)
        );
    }
    handleSaveLms() {
        // console.log('values to save through Lms  ', JSON.stringify());
        console.log('this.draftvalues onclick of save ');
        //this.saveLoanTermItem();
        let valid = this.checkValidation();
        if (valid) {
            if (this.showUploadsection && this.isRmUser) {
                this.checkDocumentUploded();
            } else {
                this.saveLoanTermItem();
            }

        } else {
            this.showToast("Error ", "error", 'Required field Missing');
            console.log('validation failed ');
        }


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
    saveLoanTermItem() {
        console.log('save term ', this.loanTermData, this.loanAppealItems);

        let loanTermDataLocal = JSON.parse(JSON.stringify(this.loanTermData));
        let loantermItemLocal = [];

        this.loanAppealItems.forEach(ele => {// this.loanAppealItems.LoanAplItem.forEach(ele => {
            console.log('value To save in Loop', ele);

            if (ele.SalesDecision === 'YES' && this.isRmUser) {
                loantermItemLocal.push(ele);
            }
            if (ele.UwDecision === 'YES' && this.isUwUser) {
                loantermItemLocal.push(ele);
                // loanTermDataLocal[loanTermDataLocal.length - 1].Status__c = 'Approve'
            }
            if (ele.UwDecision === 'NO' && ele.UwComments !== '' && this.isUwUser) {
                loantermItemLocal.push(ele);


            }


        });
        loanTermDataLocal.LoanAplItem = loantermItemLocal;
        this.showSpinner = true;
        console.log('final value to  save  ', JSON.stringify(loanTermDataLocal));

        let toSave = loanTermDataLocal[loanTermDataLocal.length - 1];
        toSave.LoanAplItem = loantermItemLocal;
        console.log('final value to  save  1111111.......  ', JSON.stringify(toSave));

        if (loantermItemLocal) {

            if (this.isUwUser) {
                let forApprove = false;
                loantermItemLocal.forEach(element => {
                    if (element.UwDecision == 'YES') {
                        forApprove = true;
                    }


                });
                if (forApprove) {
                    toSave.Status = 'Approve';
                    this.submitStatus = 'Approve';

                } else {
                    toSave.Status = 'Reject';
                    this.submitStatus = 'Reject';


                }

            }
            if (this.isRmUser) {

                this.submitStatus = '';
            }

        }
        if (loantermItemLocal.length > 0) {

            CreateLoanTerm({
                loanTermRec: toSave, loanAppId: this.loanAppId
            })
                .then((result) => {
                    console.log(' Create Loan Term rec', result);
                    if (this.submitStatus == 'Reject') {
                        this.showToast("Success ", "success", 'Loan Appeal Rejected ');
                        this.updateLoanAppealStatus(false, this.submitStatus);
                    } else if (this.submitStatus == 'Approve') {
                        this.showToast("Success ", "success", 'Loan Appeal Approved ');
                        this.updateLoanAppealStatus(false, this.submitStatus);
                        // this.updateLoanAppl(this.loanAppId);
                    } else {
                        this.showToast("Success ", "success", 'Loan Appeal Created ');
                        this.updateLoanAppealStatus(true, this.submitStatus);
                        if (this.showUploadsection) {
                            this.updateDocDetail(result);
                        }

                    }

                    this.showSpinner = false;
                    this.loanTermData = [];
                    //loanTermData.LoanAplItem
                    this.getLoanTermRecord();
                    this.loanAppealItems = [];
                    this.showUploadsection = false;
                })
                .catch((error) => {
                    console.log('error in CreateLoanTerm ', error);
                }).finally(() => {
                    this.showSpinner = false;
                })
        } else {
            this.showSpinner = false;
            if (this.isUwUser) {
                this.showToast("Error ", "error", 'Please select at least One UW Response');
            }
            if (this.isRmUser) {
                this.showToast("Error ", "error", 'Please select at least One Sales Response');
            }


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
                console.log('element passed combobox');

            } else {
                isValid = false;
                console.log('element else--', element);
            }
        });
        return isValid;

    }
    @track disableRmInput = false;
    @track loanAppealItems;
    @track disableSubmit = false;
    handleView(event) {
        this.showUploadsection = false;
        let lonapplId = event.target.dataset.id;

        let lonapplData = this.loanTermData.find(item => item.Id == lonapplId);
        console.log('handleView  data', lonapplData, lonapplId);
        if (lonapplData) {
            this.applicantId = lonapplData.Id;
            if (lonapplData.Status == 'Approve' || lonapplData.Status == 'Reject') {

                this.disableRmInput = true;
                if (lonapplData.LoanAplItem) {
                    lonapplData.LoanAplItem.forEach(element => {
                        element['ViewOnlyRm'] = true;
                        element['ViewOnlyUw'] = true;
                        if (element.Field == 'Attached documents') {
                            this.showUploadsection = true;
                        }
                    });
                    this.loanAppealItems = lonapplData.LoanAplItem;
                    this.loanAppeal = lonapplData;
                    this.disableSubmit = true;
                }


            } else {
                if (lonapplData.Status == 'New' || lonapplData.Status == 'In Progress') {

                    this.disableRmInput = true;
                    if (lonapplData.LoanAplItem) {
                        lonapplData.LoanAplItem.forEach(element => {
                            //    let ownerComp = false;
                            // if (lonapplData.OwnerId) {
                            //     ownerComp = this.isRmUser && (lonapplData.OwnerId && lonapplData.OwnerId  == CURRENTUSERID ? false : true);
                            // }
                            if (element.Field == 'Attached documents') {
                                this.showUploadsection = true;
                            }

                            let viewRm = this.isRmUser && (lonapplData.OwnerId ? lonapplData.OwnerId == CURRENTUSERID ? true : false : true);
                            element['ViewOnlyRm'] = !viewRm;
                            let viewUw = this.isUwUser && lonapplData.OwnerId == CURRENTUSERID;
                            element['ViewOnlyUw'] = !viewUw;
                        });
                        this.loanAppealItems = lonapplData.LoanAplItem;
                        this.loanAppeal = lonapplData;
                        this.disableSubmit = false;
                    }

                }
            }
            console.log('this.loanAppealItems ', this.loanAppealItems);
        }
        // console.log('lonapplId  ', lonapplId, 'lonapplData ', lonapplData);
        // getLoanTerm({ loanAppilId: lonapplId })
        //     .then((result) => {
        //         if (result) {
        //             console.log(' getLoanTerm res', result);

        //             this.loanTermData = { Id: lonapplId, LoanAplItem: result };

        //             console.log('this.loanTermDa', this.loanTermData);

        //         } else {

        //         }
        //     })
        //     .catch(error => {
        //         console.log("get applicantKyc error ", error);
        //     })

    }
    handleCommentChangeUw(event) {
        let id = event.target.dataset.id;
        let value = event.target.value;
        let lonapplData = this.loanTermData.find(item => item.Id == id);
        if (lonapplData) {
            lonapplData.Comments = value;

        }
        console.log('handleCommentChangeUw', JSON.stringify(this.loanTermData));
    }
    @track disableAppRej = false;
    @track submitStatus = '';
    handleSumitUw(event) {
        let id = event.target.dataset.id;
        let label = event.target.label;
        console.log(' handleSumitUw  id ', id, '    name ', label);

        console.log('loanAppl Val  this.loanTermData ', this.loanTermData);
        let lonapplData = this.loanTermData.find(item => item.Id == id);
        if (label == 'Approve') {
            console.log(' handleSumitUw  Approve ');
            let allowForSubmit = false;
            if (lonapplData) {
                lonapplData.Status = 'Approve';
                this.submitStatus = 'Approve';
                lonapplData.LoanAplItem.forEach(ele => {
                    if (ele.UwDecision == 'YES' && ele.UwComment != null) {
                        allowForSubmit = true;
                    }

                });

            }
            if (allowForSubmit) {
                this.saveLoanTermItem();
                this.disableAppRej = true;
            } else {
                this.showToast("Error ", "error", 'Please Add Commnet ');

            }
        } else if (label == 'Reject') {
            console.log(' handleSumitUw  Reject ');
            let allowForSubmit = false;
            if (lonapplData) {
                lonapplData.Status = 'Reject';
                this.submitStatus = 'Reject';
                lonapplData.LoanAplItem.forEach(ele => {
                    if (ele.UwComment != null) {
                        allowForSubmit = true;
                    }

                });

            }
            if (allowForSubmit) {
                this.saveLoanTermItem();
                this.disableAppRej = true;
            } else {
                this.showToast("Error ", "error", 'Please Add Commnet ');

            }
        }

    }

    updateLoanAppealStatus(status, statusText) {// LAK-9134
        let obje = {
            sobjectType: "LoanAppl__c",
            Id: this.loanAppId,
            LoanNegotiationActive__c: status,
        }
        let newArray = [];
        if (obje) {
            newArray.push(obje);
        }

        if (newArray) {
            console.log('new array is ', JSON.stringify(newArray));
            upsertMultipleRecord({ params: newArray })
                .then((result) => {
                    console.log('Result after update loan application is ', result);
                    // if (!status) { }
                    this.updateStepNev(statusText);


                    this.showSpinner = false;
                    // this.dispatchEvent(
                    //     new ShowToastEvent({
                    //         title: "Success",
                    //         message: 'Loan Application Updated Successfully!',
                    //         variant: "success",
                    //         mode: 'sticky'
                    //     }),
                    // );
                })
                .catch((error) => {
                    console.log('error in updating loan application', JSON.stringify(error));

                    this.showSpinner = false;
                });
        }

    }
    updateLoanAppl(loanAppId) {

        var loanAppl = {};
        loanAppl.sobjectType = 'LoanAppl__c';
        loanAppl.Id = loanAppId;
        loanAppl.Stage__c = 'UnderWriting';
        loanAppl.SubStage__c = 'Credit Appraisal';
        // loanAppl.Status__c = 'In Progress';// for LAK-9941
        loanAppl.OwnerId = CURRENTUSERID;
        // 

        let tempRecs = [];
        tempRecs.push(loanAppl);

        upsertMultipleRecord({ params: tempRecs })
            .then(result => {
                this.dispatchEvent(new RefreshEvent());
                console.log('result ==>>>', JSON.stringify(result));


            }).catch(error => {
                console.log('error ==>>>', error);
                this.dispatchEvent(new RefreshEvent());
            })



    }
    //select id, ApplType__c,LoanAppln__r.Product__c, LoanAppln__c from Applicant__c  where LoanAppln__c = '' AND ApplType__c ='P' 
    @track productType = '';
    @track disableInitiation = true;
    @track docTypeOptions = [{ label: "Other", value: "Other" }];
    @track applicantRec;
    @track docCatagory = "Loan Term Negotiation Documents";
    @track layoutSize = { "small": "12", "medium": "6", "large": "4" };
    getApplicantRecs() {
        let applicantRec = {
            ParentObjectName: 'Applicant__c',
            ChildObjectRelName: '',
            parentObjFields: ["Id", "ApplType__c", "LoanAppln__r.Product__c", "LoanAppln__c", 'LoanAppln__r.Stage__c', 'LoanAppln__r.SubStage__c'],
            childObjFields: [],
            queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND ApplType__c = \'P\'' //+ '\ AND ownerId  = \'' + CURRENTUSERID + '\''
            //this.recordId, this.loanAppId
            //  queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\ AND ' limit 1'
        };
        console.log('applicantRec ', applicantRec);
        getSobjectDataNonCacheable({ params: applicantRec })
            .then((result) => {
                console.log('applicantRecs >>>', result);
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.applicantRecs = result.parentRecords[0];
                    this.productType = this.applicantRecs.LoanAppln__r.Product__c;
                    console.log('applicantRecs >>>', JSON.stringify(this.applicantRecs));
                    if (this.applicantRecs.LoanAppln__r.Stage__c === 'Post Sanction' && (this.applicantRecs.LoanAppln__r.SubStage__c === 'Data Entry' || this.applicantRecs.LoanAppln__r.SubStage__c === 'Data Entry Pool')) {
                        this.disableInitiation = false;
                    } else {
                        this.disableInitiation = true;
                    }


                }
            })
            .catch(error => {
                console.log("get applicantKyc error ", error);
            })
    }
    fileAdded(event) {
        console.log('fileAdded log', event);

    }
    updateDocDetail(loanAppealId) {
        //select Id , ReferenceId__c from DocDtl__c where LAN__c ='a08C4000007WVb2IAG' AND DocCatgry__c ='Loan Term Negotiation Documents'  AND ReferenceId__c =null
        let params = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ["Id", "ReferenceId__c"],
            queryCriteria: ' where LAN__c = \'' + this.loanAppId + '\' AND DocCatgry__c =\'' + this.docCatagory + '\' AND ReferenceId__c = null'
        }
        console.log('updateDocDetail query result ==>', params);


        getSobjectDataNonCacheable({ params: params })
            .then((result) => {
                console.log(' DocDtl__c result ==>', result);
                if (result.parentRecords && result.parentRecords.length > 0) {
                    this.docDtlRec = result.parentRecords;
                    if (loanAppealId) {
                        let newArray = [];
                        this.docDtlRec.forEach(ele => {
                            let obje = {
                                sobjectType: "DocDtl__c",
                                Id: ele.Id,
                                ReferenceId__c: loanAppealId,
                            }
                            if (obje) {
                                newArray.push(obje);
                            }
                        });
                        if (newArray) {
                            this.updateRecord(newArray);
                        }

                    }


                } else {
                    console.log('No file uploded');
                    //this.showToast("Error", "Please upload at least one document", "error");
                }
            })
            .catch(error => {
                console.log('error ==>', error);
            })
    }
    checkDocumentUploded() {
        let params = {
            ParentObjectName: 'DocDtl__c',
            parentObjFields: ["Id", "ReferenceId__c"],
            queryCriteria: ' where LAN__c = \'' + this.loanAppId + '\' AND DocCatgry__c =\'' + this.docCatagory + '\' AND ReferenceId__c = null'
        }
        console.log('updateDocDetail query result ==>', params);


        getSobjectDataNonCacheable({ params: params })
            .then((result) => {
                console.log(' DocDtl__c result ==>', result);
                if (result && result.parentRecords) {
                    this.saveLoanTermItem();
                    console.log('DocDtl__c recPresent  ==>');
                } else {
                    console.log('DocDtl__c rec NOT Present ==>');
                    this.showToast("Error ", "error", 'Please upload at least one document');
                }
            })
            .catch(error => {
                console.log('error ==>', error);
            })
    }
    updateRecord(record) {

        if (record) {
            console.log('updateRecord array is ', JSON.stringify(record));
            upsertMultipleRecord({ params: record })
                .then((result) => {
                    console.log('updateRecord result ==>', result);
                    this.dispatchEvent(new RefreshEvent());
                })
                .catch(error => {
                    console.log('updateRecord error ==>', error);
                })


        }


    }
    handleClaimButtonClickLoanTerm() {
        console.log('handleClaimButtonClickLoanTerm ==  ', this.claimAppealFor);

        if (this.claimAppealFor != null) {
            this.initialize();

        }
    }
    initialize() {
        let parameter = {
            ParentObjectName: 'LoanAppeal__c',
            ChildObjectRelName: null,
            parentObjFields: ['Id', 'Name', 'OwnerId', 'Owner.Name', 'RecordType.Name', 'Status__c', 'LoanAppl__c'],
            childObjFields: [],
            queryCriteria: ' where id = \'' + this.claimAppealFor + '\''
        }
        console.log('parameter ==>', JSON.stringify(parameter));


        getSobjDataWIthRelatedChilds({ params: parameter })
            .then(result => {
                console.log('Result:' + JSON.stringify(result));
                if (result.parentRecord.Id !== undefined) {

                    let rec = result.parentRecord;
                    console.log('rec ==>', rec);

                    if (rec.Owner.Name == "UW Pool" && rec.Status__c == "New") {
                        this.updateAppeal(result.parentRecord);
                    } else {
                        this.showToast("Error ", "error", 'The loan application is already claimed by another' + ' ' + rec.Owner.Name + ' ' + 'User');
                        this.getLoanTermRecord();

                    }


                }
            })

            .catch(error => {
                console.log(error);
            });
    }
    updateAppeal(event) {
        var loanAppeal = {};

        loanAppeal.sobjectType = 'LoanAppeal__c';
        loanAppeal.Id = this.claimAppealFor;
        loanAppeal.OwnerId = CURRENTUSERID;
        loanAppeal.Status__c = "In Progress";

        let tempRecs = [];
        tempRecs.push(loanAppeal);
        console.log('apppealto update == ', tempRecs);

        upsertMultipleRecord({ params: tempRecs })
            .then(result => {
                this.dispatchEvent(new RefreshEvent());
                console.log('result ==>>>', JSON.stringify(result));

                this.getLoanTermRecord();

            }).catch(error => {
                console.log('error ==>>>', error);
                this.dispatchEvent(new RefreshEvent());
            })

    }
    updateStepNev(statusText) {

        let params = {
            ParentObjectName: 'StepperNav__c',
            parentObjFields: ["Id", 'CurStep__c', 'LoanAppln__c'],
            queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\''
        };
        console.log('StepperNav__c rec called ', params);
        getSobjDataWIthRelatedChilds({ params: params })
            .then(result => {
                console.log('result  of StepperNav__c==>', result);
                if (result.parentRecord) {

                    let rec = result.parentRecord;
                    console.log('rec  StepperNav__c==>', rec);
                    var loanNavRec = {};

                    loanNavRec.sobjectType = 'StepperNav__c';
                    loanNavRec.Id = rec.Id;
                    loanNavRec.CurStep__c = 'Post Sanction';

                    let tempRecs = [];
                    tempRecs.push(loanNavRec);
                    console.log('loanNavRec update == ', loanNavRec);

                    upsertMultipleRecord({ params: tempRecs })
                        .then(result => {

                            console.log('result  stepNav Updated==>>>', JSON.stringify(result));
                            if (statusText == 'Approve') {
                                this.updateLoanAppl(this.loanAppId);
                            } else {
                                this.dispatchEvent(new RefreshEvent());
                            }



                        }).catch(error => {
                            console.log('error in updating StepNav ==>>>', error);

                        })


                }
            }).catch(error => {
                console.log('error in Getting StepNev ==>>>', error);

            })

    }
}