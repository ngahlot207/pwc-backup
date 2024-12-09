import { LightningElement, api, track, wire } from 'lwc';

//Apex Methods
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import deleteRecord from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';
import boSaveData from '@salesforce/apex/BoSaveHandlerController.boSaveData';

import Bo_Not_applicable_Label from '@salesforce/label/c.Bo_Not_applicable_Label';

import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, MessageContext } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import formFactorPropertyName from "@salesforce/client/formFactor";
export default class CaptureShareHolderDetails extends LightningElement {
    @api applicantIdOnTabset;
    @api primaryapplicantId;
    @api loanAppId;
    @api hasEditAccess;

    @track isReadOnly = false;
    @track label = {
        Bo_Not_applicable_Label
    }
    @track appId;
    @track showSpinner = false;
    @track notIndvi = false;
    @track loggedInuserConst;
    @track tableData = [];
    @track removeModalMessageDocDis = "Do you really want to delete";

    @track activeSections = ["A", "B"];

    @track addOptions = [
        { value: 'Add New', label: 'Add New' },
        { value: 'Existing BO', label: 'Existing BO' }
    ];
    @track formFactor = formFactorPropertyName;
    desktopBoolean = false;
    phoneBolean = false;
    @track loanProduct = [];
    @track loanProductNew;
    connectedCallback() {
        if (this.hasEditAccess === true || this.hasEditAccess === undefined) {
            this.isReadOnly = false;
        }
        else {
            this.isReadOnly = true;
        }
        if (this.formFactor === "Large") {
            this.desktopBoolean = true;
            this.phoneBolean = false;
        } else if (this.formFactor === "Small") {
            this.desktopBoolean = false;
            this.phoneBolean = true;
        } else {
            this.desktopBoolean = false;
            this.phoneBolean = true;
        }

        if (this.applicantIdOnTabset) {
            this.appId = this.applicantIdOnTabset;
        } else if (this.primaryapplicantId) {
            this.appId = this.primaryapplicantId;
        }
        console.log('loanAppId ', this.loanAppId);
        console.log('applicantIdOnTabset ', this.appId);
        console.log('hasEditAccess ', this.hasEditAccess);
        console.log('applicantId ', this.primaryapplicantId);
        this.getApplicantConst();
        this.scribeToMessageChannel();
    }

    @track coApplConstitutionType;

    getApplicantConst() {
        this.showSpinner = true;
        let params = {
            ParentObjectName: 'Applicant__c',
            parentObjFields: ['Id', 'Constitution__c', 'LoanAppln__c', 'LoanAppln__r.Product__c', 'Listed_Unlisted__c'],
            queryCriteria: ' where Id = \'' + this.appId + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {
                // this.showSpinner = true;
                console.log('Applicant Data is ', JSON.stringify(result));
                if (result.parentRecords) {
                    if (result.parentRecords[0] && result.parentRecords[0].Constitution__c && result.parentRecords[0].Constitution__c !== 'INDIVIDUAL') {
                        this.coApplConstitutionType = 'NON INDIVIDUAL';
                    } else if (this.wrapObj && this.wrapObj.Constitution__c && this.wrapObj.Constitution__c === 'INDIVIDUAL') {
                        this.coApplConstitutionType = 'INDIVIDUAL';
                    }

                    if (result.parentRecords[0] && result.parentRecords[0].Constitution__c && (result.parentRecords[0].Constitution__c === 'INDIVIDUAL' || (result.parentRecords[0].Constitution__c === 'PUBLIC LIMITED COMPANY' && result.parentRecords[0].Listed_Unlisted__c && result.parentRecords[0].Listed_Unlisted__c === 'LISTED'))) {
                        this.notIndvi = true;
                        this.showSpinner = false;
                    } else {
                        this.notIndvi = false;
                        this.loggedInuserConst = result.parentRecords[0].Constitution__c;
                        this.loanProductNew = result.parentRecords[0].LoanAppln__c ? result.parentRecords[0].LoanAppln__r.Product__c : '';
                        if (result.parentRecords[0].LoanAppln__c && result.parentRecords[0].LoanAppln__r.Product__c) {
                            this.loanProduct.push(result.parentRecords[0].LoanAppln__r.Product__c);
                        }
                        // this.showSpinner = false;
                        this.getIndAppData();
                    }
                }
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Applicant Data is ', error);
            });
    }
    @track appData = [];
    @track nameOptions = [];
    @track applConstitutionType;
    getIndAppData() {
        let indv = 'INDIVIDUAL';
        let arra = ['P', 'C', 'G'];
        let params = {
            ParentObjectName: 'Applicant__c',
            parentObjFields: ['Id', 'Constitution__c', 'toLabel(ApplType__c)', 'FName__c', 'LName__c', 'FullName__c', 'Relationship__c'],
            queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND Constitution__c = \'' + indv + '\' AND ApplType__c  IN (\'' + arra.join('\', \'') + '\')'
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Individual Applicant Data is ', JSON.stringify(result));
                if (result && result.parentRecords && result.parentRecords.length > 0) {
                    this.appData = result.parentRecords;
                    // Assuming this.appData is your array and this.appId is the id you want to remove
                    this.appData = this.appData.filter(item => item.id !== this.appId);  
                } else {
                    this.showSpinner = false;
                }
                this.showSpinner = false;
                this.getAppRelDetails();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Individual Applicant Data is ', error);
            });
    }
    // @track relationShipOptions = [];
    // getRelationshipVal() {
    //     let params = {
    //         ParentObjectName: 'Relationship__c',
    //         parentObjFields: ['Id', 'Name'],
    //         queryCriteria: ' where ApplType__c = \'' + this.applConstitutionType + '\' AND CoApplType__c = \'' + this.coApplConstitutionType + '\''
    //     }
    //     getSobjectData({ params: params })
    //         .then((result) => {
    //             // this.showSpinner = true;
    //             console.log('Relationship Data is ', JSON.stringify(result));
    //             if (result.parentRecords) {
    //                 let arr = [];
    //                 result.parentRecords.forEach(item => {
    //                     let obj = {};
    //                     obj.label = item.Name;
    //                     obj.value = item.Name;
    //                     arr.push(obj);
    //                 })
    //                 if (arr && arr.length > 0) {
    //                     this.relationShipOptions = [...arr];
    //                 }
    //             }
    //         })
    //         .catch((error) => {
    //             this.showSpinner = false;
    //             console.log('Error In getting Applicant Data is ', error);
    //         });
    // }
    getAppRelDetails() {
        let arra = ['Beneficial Owner', 'ShareHolder'];
        // const relType = 'Beneficial Owner';
        // queryCriteria: ` WHERE Loan_Applicant__c = '${this.appId}' AND Relationship_Type__c = '${relType}'`
        const params = {
            ParentObjectName: 'LoanApplRelationship__c',
            parentObjFields: [
                'Id', 'Partofpraposalloan__c', 'Related_Person__r.Constitution__c',
                'Loan_Applicant__c', 'Related_Person__c', 'Related_Person__r.LoanAppln__c', 'Related_Person__r.FullName__c', 'Related_Person__r.FName__c', 'Related_Person__r.LName__c',
                'toLabel(Related_Person__r.ApplType__c)', 'Related_Person__r.Relationship__c',
                'Relationship_Type__c', 'BeneficialOwner__c', 'Shareholding__c'
            ],
            queryCriteria: ' where Loan_Applicant__c = \'' + this.appId + '\' AND Relationship_Type__c  IN (\'' + arra.join('\', \'') + '\')'

        };

        getSobjectData({ params: params })
            .then((result) => {
                console.log('Relation Data is ', JSON.stringify(result));
                this.tableData = []; // Clear the tableData before populating it
                if (result.parentRecords && result.parentRecords.length > 0) {
                    result.parentRecords.forEach(it => {
                        let applicant = this.appData.find(app => app.Id === it.Related_Person__c);
                        if (applicant) {
                            applicant.isBo = it.BeneficialOwner__c;
                            applicant.Shareholding = it.Shareholding__c;
                            applicant.isDelete = false;
                            applicant.PartofProposedLoan = 'Yes';
                            applicant.relationShipId = it.Id;
                            applicant.isExst = true;
                            applicant.relId = it.Id;
                        } else {
                            applicant = {
                                Id: it.Related_Person__c ? it.Related_Person__c : '',
                                relatedPerId: it.Related_Person__c ? it.Related_Person__c : '',
                                relationShipId: it.Id,
                                isExst: true,
                                FName__c: it.Related_Person__r.FName__c,
                                LName__c: it.Related_Person__r.LName__c,
                                FullName__c: it.Related_Person__r.FullName__c,
                                ApplType__c: it.Related_Person__r.ApplType__c,
                                Constitution__c: it.Related_Person__r.Constitution__c,
                                Relationship__c: it.Related_Person__r.Relationship__c,
                                isBo: it.BeneficialOwner__c,
                                Shareholding: it.Shareholding__c,
                                isDelete: true,
                                PartofProposedLoan: 'No',
                                relId: it.Id
                            };
                        }
                        this.tableData.push(applicant);
                    });
                } else {
                    this.appData.forEach(it => {
                        let applicant = {};
                        applicant.Id = it.Id;
                        applicant.relatedPerId = '';
                        applicant.FName__c = it.FName__c;
                        applicant.LName__c = it.LName__c;
                        applicant.ApplType__c = it.ApplType__c;
                        applicant.Constitution__c = it.Constitution__c;
                        applicant.Relationship__c = it.Relationship__c;
                        applicant.isBo = '';
                        applicant.Shareholding = '';
                        applicant.PartofProposedLoan = 'Yes';
                        applicant.isDelete = false;
                        applicant.required = true;
                        applicant.isExst = true;
                        this.tableData.push(applicant);
                    });
                }

                if (this.tableData && this.tableData.length > 0) {
                    this.appData.forEach(item => {
                        let obj = this.tableData.find(it => it.Id === item.Id);
                        if (!obj) {
                            let applicant = {};
                            applicant.Id = item.Id;
                            applicant.FName__c = item.FName__c;
                            applicant.LName__c = item.LName__c;
                            applicant.ApplType__c = item.ApplType__c;
                            applicant.Constitution__c = item.Constitution__c;
                            applicant.Relationship__c = item.Relationship__c;
                            applicant.isBo = '';
                            applicant.Shareholding = '';
                            applicant.PartofProposedLoan = 'Yes';
                            applicant.isDelete = false;
                            applicant.required = true;
                            applicant.isExst = true;
                            this.tableData.push(applicant);
                        }
                    })
                }

                this.showSpinner = false;
                console.log('NameOptions are ===>>>>>>>>.', this.nameOptions);
                console.log('tableData is ===>>>>>>>>.', this.tableData);

            })
            .catch((error) => {
                this.showSpinner = false;
                console.error('Error In getting Relation Data is ', error);
            });
    }

    handlValueChange(event) {
        let val = event.target.value;
        let nameVal = event.target.dataset.name;
        let index = event.target.dataset.index;
        let obj = { ...this.tableData[index] };
        obj[nameVal] = val.toUpperCase();
        obj.isDirty = true;
        this.tableData[index] = obj;
        this.tableData = [...this.tableData];
    }
    handlePicklistValuesNew(event) {
        let val = event.detail.val;
        let nameVal = event.detail.nameVal;
        let index = event.detail.index;
        let obj = { ...this.tableData[index] };
        obj[nameVal] = val;
        obj.isDirty = true;
        this.tableData[index] = obj;
        this.tableData = [...this.tableData];
    }
    handlePicklistValues(event) {
        this.showSpinner = true;
        let val = event.detail.val;
        let hunterRecordId = event.detail.recordid;
        let nameVal = event.detail.nameVal;
        console.log('val is in hunter ', val, 'hunter id is ', hunterRecordId, ' name is ', nameVal);
        let obj = this.tableData.find(item => item.Id === hunterRecordId);
        let appObj = this.appData.find(item => item.Id === hunterRecordId);
        if (obj) {
            console.log('obj is ', JSON.stringify(obj));
            obj[nameVal] = val;
            obj['LName__c'] = appObj.LName__c ? appObj.LName__c : '';
            obj['ApplType__c'] = appObj.ApplType__c ? appObj.ApplType__c : '';
            obj['Constitution__c'] = appObj.Constitution__c ? appObj.Constitution__c : '';
            obj['Relationship__c'] = appObj.Relationship__c ? appObj.Relationship__c : '';
            obj.isChanged = true;
            obj.isDirty = true;
        }
        console.log('this.hunterdata  ', this.hunterData);
        // this.makeFieldsRequired();
        this.showSpinner = false;
    }

    @track showPickList = false;
    handleAddNew() {
        this.showPickList = true;
        this.showExBo = false;
    }

    closeMPickListModal() {
        this.showPickList = false;
        this.showExBo = false;
    }
    closeModalYes() {

        // this.adNewPickListValue && this.adNewPickListValue === 'Existing BO'
        if (this.exstBo) {
            if (this.selectedBO && this.selectedBOVal) {
                this.showPickList = false;
                this.showSpinner = true;
                let applicant = {};
                applicant.Id = '';
                // this.selectedBO.Loan_Applicant__c ? this.selectedBO.Loan_Applicant__c :
                applicant.relatedPerId ='';
                // this.selectedBO.Related_Person__c ? this.selectedBO.Related_Person__c : 
                applicant.relId = '';
                // this.selectedBO.Id ? this.selectedBO.Id : 
                applicant.FName__c = this.selectedBO.Related_Person__c && this.selectedBO.Related_Person__r.FName__c ? this.selectedBO.Related_Person__r.FName__c : '';
                applicant.LName__c = this.selectedBO.Related_Person__c && this.selectedBO.Related_Person__r.LName__c ? this.selectedBO.Related_Person__r.LName__c : '';
                applicant.ApplType__c = this.selectedBO.Related_Person__c && this.selectedBO.Related_Person__r.ApplType__c ? this.selectedBO.Related_Person__r.ApplType__c : '';
                applicant.Constitution__c = this.selectedBO.Related_Person__c && this.selectedBO.Related_Person__r.Constitution__c ? this.selectedBO.Related_Person__r.Constitution__c : '';
                applicant.Relationship__c = this.selectedBO.Related_Person__c && this.selectedBO.Related_Person__r.Relationship__c ? this.selectedBO.Related_Person__r.Relationship__c : '';
                applicant.isBo = this.selectedBO.BeneficialOwner__c ? this.selectedBO.BeneficialOwner__c : '';
                applicant.Shareholding = '';
                // this.selectedBO.Shareholding__c ? this.selectedBO.Shareholding__c :
                applicant.PartofProposedLoan = this.selectedBO.Partofpraposalloan__c ? this.selectedBO.Partofpraposalloan__c : '';
                applicant.isDelete = true;
                applicant.required = true;
                applicant.isExst = true;
                console.log("applicant existing = ", applicant);
                let tableData = [...this.tableData, applicant];
                this.tableData = tableData;

                this.showExBo = false;

                this.showSpinner = false;
                this.selectedBO = {};
                this.selectedBOVal = '';
            } else {
                this.showToastMessage("Error", 'Select Existing Bo Value', "error", "sticky");
            }
            // this.adNewPickListValue && this.adNewPickListValue === 'Add New'
        } else if (!this.exstBo) {
            this.showPickList = false;
            this.showSpinner = true;
            let numberOfRec = this.tableData.length;
            console.log("numberOfRec", numberOfRec);
            let applicant = {};
            applicant.FName__c = '';
            applicant.LName__c = '';
            applicant.ApplType__c = 'ShareHolder';
            applicant.Constitution__c = 'INDIVIDUAL';
            applicant.Relationship__c = 'ShareHolder';
            applicant.isBo = '';
            applicant.Shareholding = '';
            applicant.PartofProposedLoan = 'No';
            applicant.isDelete = true;
            applicant.required = true;
            applicant.isExst = false;
            console.log("applicant++++++ = ", applicant);
            let tableData = [...this.tableData, applicant];
            this.tableData = tableData;

            this.showExBo = false;
            // this.showPickList = false;
            this.showSpinner = false;
        }
    }
    @track addNewValue;
    @track showExBo = false;
    @track adNewPickListValue;
    @track selectedBO = {};
    @track exstBo = false;
    handleInputChange(event) {
        let dataName = event.target.dataset.name;
        this.adNewPickListValue = event.target.value;
        if (dataName && dataName === 'Select Value') {
            if (this.adNewPickListValue && this.adNewPickListValue === 'Existing BO') {
                this.getExiStBoDetails();
            } else {
                this.hideYesButton = false
                this.exstBo = false;
                this.showExBo = false;
            }
        }
    }
    @track selectedBOVal;
    handleInputChangeBo(event) {
        // this.selectedBO = {};
        this.exstBo = true;
        this.selectedBOVal = event.target.value;
        let obj = this.tableData.find(item => item.relId === this.selectedBOVal);
        if (obj) {
            this.selectedBOVal = '';
            this.selectedBOVal = null;
            this.showToastMessage("Error", 'Already added', "error", "sticky");
        } else {
            // let verId = event.target.verId;
            this.selectedBO = this.extBoDetails.find(item => item.Id === this.selectedBOVal);
        }
    }
    @track existBoOptions = [];
    @track disableExBoPick = false;
    @track hideYesButton = false;
    @track extBoDetails = [];
    @track showSpinnerNew = false;
    getExiStBoDetails() {
        let arra = ['SH'];
        this.showSpinnerNew = true;
        let params = {
            ParentObjectName: 'LoanApplRelationship__c',
            parentObjFields: ['Id', 'Loan_Applicant__c','Related_Person__c','Partofpraposalloan__c', 'BeneficialOwner__c', 'Relationship_Type__c', 'Shareholding__c', 'Related_Person__r.Constitution__c', 'toLabel(Related_Person__r.ApplType__c)', 'Related_Person__r.FName__c', 'Related_Person__r.LName__c', 'Related_Person__r.FullName__c', 'Related_Person__r.Relationship__c'],
            queryCriteria: ' where Related_Person__r.LoanAppln__c = \'' + this.loanAppId + '\' AND Related_Person__r.ApplType__c  IN (\'' + arra.join('\', \'') + '\')'
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Existing BO Details are ', JSON.stringify(result));
                let arr = [];
                if (result.parentRecords) {
                    this.extBoDetails = result.parentRecords;
                    result.parentRecords.forEach(item => {
                        if (item.Loan_Applicant__c && item.Loan_Applicant__c !== this.appId) {
                            let obj = {};
                            obj.value = item.Id;
                            obj.label = item.Related_Person__r.FullName__c;
                            arr.push(obj);
                        }
                    });
                }
                this.showExBo = true;
                if (arr && arr.length > 0) {
                    this.existBoOptions = [...arr];
                    this.disableExBoPick = false;
                    this.exstBo = true;
                    this.hideYesButton = false;
                } else {
                    this.hideYesButton = true;
                    this.disableExBoPick = true;
                }
                arr = [];
                console.log('this.existBoOptions ', this.existBoOptions);

                this.showSpinnerNew = false;
            })
            .catch((error) => {
                this.showSpinnerNew = false;
                console.log('Error In getting Existing BO Details are ', error);
            });
    }

    handleKeyPress(event) {
        const charCode = event.which ? event.which : event.keyCode;

        // Allow: backspace (8), tab (9), delete (46), arrow keys, enter (13)
        if (charCode === 8 || charCode === 9 || charCode === 13 || charCode === 46 ||
            (charCode >= 37 && charCode <= 40)) { // Allow arrow keys
            return;
        }

        // Allow number keys (0-9)
        if (charCode >= 48 && charCode <= 57) {
            const inputValue = event.target.value + String.fromCharCode(charCode);
            // Prevent if input exceeds 100
            if (parseFloat(inputValue) > 100) {
                event.preventDefault();
            }
            return;
        }

        // Prevent any other key
        event.preventDefault();
    }


    // handleKeyPress(event) {
    //     const charCode = event.which ? event.which : event.keyCode;
    //     // Allow: backspace, tab, delete, arrow keys, enter, and . (dot for decimal)
    //     if (charCode === 46 || charCode >= 48 && charCode <= 57 || charCode === 8 || charCode === 9 || charCode === 13) {
    //         return;
    //     }
    //     event.preventDefault();
    // }

    handlChange(event) {
        this.showSpinner = true;
        let currentIndex = event.target.dataset.index;
        let obj = { ...this.tableData[currentIndex] };
        let name = event.target.name;
        let val = parseFloat(event.target.value); // Ensure the value is a number
        if (isNaN(val)) {
            // If the value is not a number, handle it accordingly
            this.showSpinner = false;
            obj.isBo = '';
            this.tableData[currentIndex] = obj;
            this.tableData = [...this.tableData];
            return;
        }
        console.log('this.loanProduct ', this.loanProduct);

        if (val) {
            let type = 'BO Criteria';
            let params = {
                ParentObjectName: 'MasterData__c',
                parentObjFields: ['Id', 'Constitution__c', 'Type__c', 'Ope__c', 'Min__c', 'Product__c'],
                queryCriteria: ` where Constitution__c = '${this.loggedInuserConst}' AND Type__c = '${type}' AND Product__c INCLUDES ('${this.loanProduct.join("', '")}')`
            };
            getSobjectData({ params: params })
                .then((result) => {
                    // this.showSpinner = true;
                    console.log('Master Data is ', JSON.stringify(result));
                    if (result.parentRecords && result.parentRecords.length > 0) {
                        let record = result.parentRecords[0];
                        let ope = record.Ope__c;
                        let min = parseFloat(record.Min__c);

                        // Determine if the value meets the criteria
                        let isBo = this.checkCriteria(val, ope, min);

                        obj.isBo = isBo ? 'Yes' : 'No';
                        obj[name] = val;
                        obj.isDirty = true;
                        this.tableData[currentIndex] = obj;
                        this.tableData = [...this.tableData];
                        console.log('this.tableData  ', this.tableData);
                    }

                    this.showSpinner = false;
                })
                .catch((error) => {
                    this.showSpinner = false;
                    console.log('Error In getting Master Data is ', error);
                });
        } else {
            this.showSpinner = false;
            obj[name] = val;
            obj.isBo = 'No';
            obj.isDirty = true;
            this.tableData[currentIndex] = obj;
            this.tableData = [...this.tableData];
            console.log('this.tableData  ', this.tableData);
        }
    }

    // Helper function to check criteria
    checkCriteria(value, operator, minValue) {
        switch (operator) {
            case 'Greater than':
                return value > minValue;
            case 'Less than':
                return value < minValue;
            case 'Greater than are equal to':
                return value >= minValue;
            case 'Less than are equal to':
                return value <= minValue;
            default:
                return false;
        }
    }



    @track deleteRecId;
    @track showDocumentDispatchDelete = false;
    @track indexToDelDocDis;
    @track deleteRelationShipId;
    @track deleteAppId;
    handleDeleteAction(event) {
        this.deleteRecId = this.tableData[event.target.dataset.index].Id;
        this.indexToDelDocDis = event.target.dataset.index;
        this.deleteRelationShipId = event.target.dataset.relid;
        this.deleteAppId = event.target.dataset.appid;
        this.showDocumentDispatchDelete = true;
    }
    closeModalDeleteDocDis() {
        this.showDocumentDispatchDelete = false;
    }
    handleDeleteDocDis() {
        this.showDocumentDispatchDelete = false;
        this.showSpinner = true;

        if (this.deleteRecId === undefined) {
            this.tableData.splice(this.indexToDelDocDis, 1);
            this.showSpinner = false;
        }
        else {
            console.log("delete initated");
            this.handleDeleteData(this.deleteAppId, this.deleteRelationShipId);
        }
    }
    handleDeleteData(appId, RelationShipId) {
        let dataToDelete = [];
        this.showBo = true;
        if (appId) {
            let obj = {};
            obj.Id = appId;
            dataToDelete.push(obj);
        }
        if (RelationShipId) {
            let objDe = {};
            objDe.Id = RelationShipId;
            dataToDelete.push(objDe);
        }
        if (dataToDelete && dataToDelete.length > 0) {
            deleteRecord({ rcrds: dataToDelete }).then(() => {
                this.tableData.splice(this.indexToDelDocDis, 1);
                this.showToastMessage("Success", 'Deleted Successfully!', "success", "sticky");
                this.showBo =false;
                this.showSpinner = false;
            }).catch(error => {
                this.showSpinner = false;
                console.log('error occured while deleting ', error);
            })
        }
        this.showSpinner = false;
    }

    showToastMessage(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
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
        console.log('values to save through Lms ', JSON.stringify(values));
        if(!this.notIndvi){
            let totalShareHolding = 0;
            if (values.validateBeforeSave) {
                let returnVal = this.checkReportValidity();
                console.log('return val from data iss ', returnVal);
                if (this.tableData && this.tableData.length > 0) {
                    this.tableData.forEach(item => {
                        totalShareHolding += item.Shareholding;
                    })
                }
                let shareHolderYes = false;
                if (totalShareHolding && (totalShareHolding === 100 || totalShareHolding === 100.00)) {
                    shareHolderYes = true;
                }
                if (returnVal === true && shareHolderYes === true) {
                    this.handlevSubmit(values.validateBeforeSave);
                } else {
                    if (!returnVal) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Error",
                                message: 'Required Fields Missing',
                                variant: "error",
                                mode: 'sticky'
                            }),
                        );
                    }
                    if (!shareHolderYes) {
                        this.showToastMessage("Error", 'Controlling ownership interest % is not equal to 100%', "error", "sticky");
                    }
                }
    
            } else {
                this.handlevSubmit(values.validateBeforeSave);
            }
        }  
    }
    @track showBo = false;
    handlevSubmit(validateBeforeSave) {
        this.showBo = true;
        let tempArr = [];
        let filterData = this.tableData.filter(item => item.isDirty === true);
        if (filterData && filterData.length > 0) {
            this.showSpinner = true;
            filterData.forEach(item => {
                let obj = {};
                obj.relatedPerId = item.Id ? item.Id : '';
                obj.Id = this.appId;
                obj.relId = item.relId ? item.relId : '';
                obj.FName = item.FName__c;
                obj.LName = item.LName__c;
                if (item.ApplType__c && item.ApplType__c === 'ShareHolder') {
                    obj.ApplType = 'SH';
                } else if (item.ApplType__c && item.ApplType__c === 'APPLICANT') {
                    obj.ApplType = 'P';
                } else if (item.ApplType__c && item.ApplType__c === 'CO-APPLICANT') {
                    obj.ApplType = 'C';
                } else if (item.ApplType__c && item.ApplType__c === 'GUARANTOR') {
                    obj.ApplType = 'G';
                }
                //obj.ApplType = item.ApplType__c && item.ApplType__c === 'ShareHolder' ? 'SH' : item.ApplType__c;
                obj.Constitution = item.Constitution__c;
                obj.Relationship = item.Relationship__c;
                obj.isBo = item.isBo;
                obj.Shareholding = item.Shareholding;
                obj.PartofProposedLoan = item.PartofProposedLoan;
                if (item.isBo && item.isBo === 'Yes') {
                    obj.relationshipType = 'Beneficial Owner';
                } else if (item.isBo && item.isBo === 'No') {
                    obj.relationshipType = 'ShareHolder';
                }
                obj.loanAppId = this.loanAppId;
                tempArr.push(obj);
            })
        } else {
            this.showBo = false;
            this.showToastMessage("Error", 'No Change in Data', "error", "sticky");
        }

        if (tempArr && tempArr.length > 0) {
            console.log('new array is ', JSON.stringify(tempArr));
            boSaveData({ inputDataAll: tempArr })
                .then((result) => {
                    this.tempArr = [];
                    console.log('Result after update is ', result);
                    this.showSpinner = false;
                    this.getApplicantConst();
                    this.showBo = false;
                    this.showToastMessage("Success", 'Details saved Successfully!', "success", "sticky");
                })
                .catch((error) => {
                    console.log('error ', JSON.stringify(error));
                    this.showSpinner = false;
                });
        }
    }

    checkReportValidity() {
        let isValid = true;
        this.template.querySelectorAll('c-hunter-displayvalue').forEach(element => {
            if (element.reportValidity()) {
                console.log('c-hunter-displayvalue');
                console.log('element if--' + element.value);
            } else {
                isValid = false;
                // element.setCustomValidity("Received Date can not be future date");
                console.log('element else--' + element.value);
            }
            // element.reportValidity("");
        });
        this.template.querySelectorAll('lightning-textarea').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed');
            } else {
                isValid = false;
            }
        });
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (element.reportValidity()) {
                console.log('element passed');
            } else {
                isValid = false;
            }
        });
        return isValid;
    }
}