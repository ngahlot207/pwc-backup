import { LightningElement, track, wire, api } from 'lwc';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import formFactorPropertyName from "@salesforce/client/formFactor";
//import BT_FINAC_STATUS from '@salesforce/schema/BTLoan__c.BTFinancierStatus__c';

//Apex methods
import getSobjectDataWithoutCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataWithoutCacheable';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import deletebtLoanRecord from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';
import getSobjectData from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData";
//LMS details
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, MessageContext, APPLICATION_SCOPE } from "lightning/messageService";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

//Labels
import BTFinancierDeleteSuccess from '@salesforce/label/c.BTFinancierDeleteSuccess';
import BTFinancierRequired from '@salesforce/label/c.BTFinancierRequired';
import BTFinancierDuplicateRecordError from '@salesforce/label/c.BTFinancierDuplicateRecordError';
import BTFinancierAddedSuccess from '@salesforce/label/c.BTFinancierAddedSuccess';
import BTFinancierRequiredFields from '@salesforce/label/c.BTFinancierRequiredFields';

//refresh wire adapter
import { refreshApex } from '@salesforce/apex';

export default class BtLoanDetails extends LightningElement {

    label = {
        BTFinancierDeleteSuccess,
        BTFinancierRequired,
        BTFinancierDuplicateRecordError,
        BTFinancierAddedSuccess,
        BTFinancierRequiredFields
    };

    @track _loanAppId;

    @api existingFed;
    @api stage;
    @api schemeChanged;
    @api isInterTopUp;
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        console.log('Loan App Id !#14 ', value);
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);
        // this.handleLoanRecordIdChange();          

    }

    @track formFactor = formFactorPropertyName;
    desktopBoolean = false;
    phoneBolean = false;

    // get mandatoryUw(){
    //     return this.stage === "UnderWriting" || this.stage === "Post Sanction" || this.stage ==='Disbursed' || this.stage === 'Disbursement Initiation';
    // }

    get mandatoryUw() {
        return this.stage !== "QDE";
    }

    get addButtonLabel() {
        let label;
        if (!this.existingFed) {
            //label = 'Add BT Loan';
            label = 'Add TopUp Loan';
        } else {
            label = 'Add Internal Loan';
        }
        return label;
    }

    @track wrpBtLoan = {}
    @track btLoanRec = [];
    @track btLnFinstatusOptions = [];
    @track index
    @track wiredData = [];
    @track showOtherBT;
    @api disabled;
    @wire(MessageContext)
    MessageContext;


    @track
    btQueryParams = {
      ParentObjectName: "BalTranFinancier__c",
      ChildObjectRelName: "",
      parentObjFields: [
        "Id",
        "Name",
        "Balance_Transfer_Financier_Status__c"
      ],
      childObjFields: [],
      queryCriteria: " "
    };
  

    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveThroughLms(values)
        );
    }
   
@track labelVal ='Balance Transfer Loans';
    connectedCallback() {
        if(this.isInterTopUp){
this.labelVal = 'Top Up Loans';
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

        this.subscribeToMessageChannel();
        this.getBtLoanRecords();
         refreshApex(this.wiredData)
    }

    // handleLoanRecordIdChange() {
    //     let tempParams = this.params_btLoan;
    //     tempParams.queryCriteria = ' where Id = \'' + this._loanAppId + '\' limit 1' ;
    //     this.params_btLoan = { ...tempParams };

    // }

    //parameter to find the BT Loans records
    // @track
    // params_btLoan = {
    //     ParentObjectName: 'LoanAppl__c',
    //     ChildObjectRelName: 'BT_Loans__r',
    //     parentObjFields: ['Id'],
    //     childObjFields: ['Id','BTFinancier__c','BTOriginalLoanAmt__c','BTLoanOutstandingValue__c','SpecifyOtherBTFinancier__c','BTFinancierStatus__c'],
    //     queryCriteria: ' '
    // }


    // @wire(getSobjectDatawithRelatedRecords, { params: '$params_btLoan' })
    // handleLoanAppChargeResponse(result) {   
    //     this.wiredData=[] 
    //     this.btLoanRec=[];
    //     this.wiredData = result;
    //     if (result.data) {          
    //         console.log('Data ##70', JSON.stringify(result.data))

    //         if (result.data.ChildReords !== undefined && result.data.ChildReords.length > 0) {
    //             let arr = []
    //             arr = result.data.ChildReords;
    //             arr.forEach((item) => {
    //                     if(item.BTFinancier__c){
    //                         let otherFinValu = item.BTFinancier__c.toLocaleLowerCase();
    //                         let otherFinValue = otherFinValu.search(/other/);
    //                         console.log("otherFinValue:::::", otherFinValue);
    //                         if (otherFinValue === 0) {
    //                             item= {...item,enableOtherScheme: false};
    //                          // item.enableOtherScheme= false;
    //                           console.log('item in bt loans if bloack',item);
    //                         }
    //                         else {
    //                             item= {...item,enableOtherScheme: true};
    //                             //item={enableOtherScheme: true};
    //                             console.log('item in bt loans else',item);
    //                           }
    //                           this.btLoanRec.push(item)
    //                          // this.btLoanRec=[item]
    //                     }

    //             })
    //         }          
    //     }
    //     if (result.error) { 
    //         console.error('ERROR IN BT LOANS ##48',result.error);
    //     }  
    // }


    // @api deletBtLoan() {
    //     if (this.btLoanRec) {
    //         deletebtLoanRecord({ rcrds: this.btLoanRec }).then((result) => {
    //             this.showToastMessage('Success', this.label.BTFinancierDeleteSuccess, 'success', 'sticky');
    //         });
    //     }

    // }

    @track loanToClosedIntOptions = [];

   @api  getBtLoanRecords() {
        let params_btLoan = {
            ParentObjectName: 'LoanAppl__c',
            ChildObjectRelName: 'BT_Loans__r',
            parentObjFields: ['Id'],
            childObjFields: ['Id', 'BTFinancier__c', 'BTOriginalLoanAmt__c', 'BTLoanOutstandingValue__c', 'SpecifyOtherBTFinancier__c', 'BTFinancierStatus__c', 'ExistFedfinaAccNo__c','EMI__c','Loantobeclosedinternally__c'],
            queryCriteria: ' where Id = \'' + this._loanAppId + '\' limit 1'

        }
        getSobjectDataWithoutCacheable({ params: params_btLoan })
            .then((result) => {
                
                console.log('Data #161 in bt loan', JSON.stringify(result), result)
                this.wiredData = result;
                let newArray = []
                newArray = result;
                this.btLoanRec = [];
                if (newArray[0].ChildReords && newArray[0].ChildReords.length > 0) {
                    let arr = []
                    arr = newArray[0].ChildReords;
                    console.log('ARRAY IN BT LOANS::::165', JSON.stringify(newArray[0].ChildReords));
                    console.log('ARRAY IN BT LOANS::::166', arr);

                    arr.forEach((item) => {
                        if (item.BTFinancier__c) {
                            let otherFinValu = item.BTFinancier__c.toLocaleLowerCase();
                            let otherFinValue = otherFinValu.search(/other/);
                            console.log("otherFinValue:::::", otherFinValue);
                            if (otherFinValue === 0) {
                                item = { ...item, enableOtherScheme: false };
                                // item.enableOtherScheme= false;
                                console.log('item in bt loans if bloack', item);
                            }
                            else {
                                item = { ...item, enableOtherScheme: true };
                                //item={enableOtherScheme: true};
                                console.log('item in bt loans else', item);
                            }

                            // this.btLoanRec=[item]
                        }
                        this.btLoanRec.push(item);
                    })

                }

                const selectedEvent = new CustomEvent("select", {
                    detail: this.btLoanRec
                  });
              
                  this.dispatchEvent(selectedEvent);
                  if(this.btLoanRec && this.btLoanRec.length > 0){
                    this.handleTotalMethod(this.btLoanRec);
                  }else{
                    this.addRow();
                  }
                  
                if (result.error) {
                    console.error('appl result getting error=', result.error);
                }
            })
    }

    @track saveData = [];
    handlePicklistValuesNew(event) {
        let val = event.detail.val;
        let hunterRecordId = event.detail.recordid;
        let nameVal = event.detail.nameVal;
        console.log('val is in hunter ', val, 'hunter id is ', hunterRecordId, ' name is ', nameVal);
        let obj = this.btLoanRec.find(item => item.Id === hunterRecordId);
        if (obj) {
            console.log('obj is ', JSON.stringify(obj));
            obj[nameVal] = val;
        } 
    }

    handleInputChange(event) {
        let currentIndex = event.target.dataset.index;
        let obj = { ...this.btLoanRec[event.target.dataset.index] };

        obj[event.target.dataset.name] = event.target.value;
        obj.isDirty = true

        this.btLoanRec = [...this.btLoanRec];
        this.btLoanRec[currentIndex] = obj;

        const selectedEvent = new CustomEvent("select", {
            detail: this.btLoanRec
          });
      
          //dispatching the custom event
          this.dispatchEvent(selectedEvent);

        console.log("btLoanRec ///89", JSON.stringify(this.btLoanRec));

        //  this.wrpBtLoan[event.target.dataset.name] = event.target.value;
        this.handleTotalMethod(this.btLoanRec);

    }

    @track lookupRec;
    handleValueSelect(event) {

        this.lookupRec = event.detail;
        console.log("this.lookupRec>>>>>", this.lookupRec);

        let lookupId = this.lookupRec.id;
        console.log("lookupId>>>", lookupId);
        let lookupAPIName = this.lookupRec.lookupFieldAPIName;

        const outputObj = { [lookupAPIName]: lookupId };
        console.log("outputObj>>>", outputObj);
        Object.assign(this.wrpBtLoan, outputObj);

       
        let currentIndex = event.target.index;
        this.fetchBtStatus(currentIndex, lookupId );


        let fieldName = event.detail.lookupFieldAPIName;
        let obj = { ...this.btLoanRec[currentIndex] };
        obj.isDirty = true;
        obj[fieldName] = this.lookupRec.mainField;
        this.btLoanRec = [...this.btLoanRec];
        this.btLoanRec[currentIndex] = obj;

        // if (this.wrpBtLoan.BTFinancierId__c) {


        if (this.lookupRec.mainField) {
            let otherFinValu = this.lookupRec.mainField.toLocaleLowerCase();
            let otherFinValue = otherFinValu.search(/other/);
            console.log("otherFinValue:::::", otherFinValue);
            if (otherFinValue === 0) {
                obj.enableOtherScheme = false;
            }
            else {
                obj.enableOtherScheme = true;
            }

            this.btLoanRec = [...this.btLoanRec];
            this.btLoanRec[currentIndex] = obj;
        }

        const selectedEvent = new CustomEvent("select", {
            detail: this.btLoanRec
          });
      
          //dispatching the custom event
          this.dispatchEvent(selectedEvent);
    }

    fetchBtStatus(index,id){
        this.btQueryParams.queryCriteria=' Where Id = \'' + id + '\' limit 1';
        getSobjectData({
            params: this.btQueryParams
        })
        .then((result) => {
                  console.log("result bt ststus #321>>>>>", result);
                  let obj = { ...this.btLoanRec[index] };
                  

               let btStatus = result.parentRecords[0].Balance_Transfer_Financier_Status__c;
               obj.BTFinancierStatus__c = btStatus;
               this.btLoanRec = [...this.btLoanRec];
               this.btLoanRec[index] = obj;
               const selectedEvent = new CustomEvent("select", {
                detail: this.btLoanRec
              });
          
              //dispatching the custom event
              this.dispatchEvent(selectedEvent);
               
                })
                .catch((error) => {
                  console.log("BT STATUS ERRROR #325", error);
                });
            }
          

        

    

    generatePicklist(data) {
        return data.values.map(item => ({ label: item.label, value: item.value }))
    }

    @wire(getObjectInfo, { objectApiName: 'BTLoan__c' })
    objInfo1;
    @wire(getPicklistValuesByRecordType, {
        objectApiName: 'BTLoan__c',
        recordTypeId: '$objInfo1.data.defaultRecordTypeId',
    })
    dedupePicklistHandler({ data, error }) {
        if (data) {
            this.btLnFinstatusOptions = [...this.generatePicklist(data.picklistFieldValues.BTFinancierStatus__c)]
            this.loanToClosedIntOptions = [...this.generatePicklist(data.picklistFieldValues.Loantobeclosedinternally__c)]
        }
        if (error) {
            console.error('ERROR CASE DETAILS:::::::#163', error)
        }
    }


    handlePicklistValues(event) {
        let currentIndex = event.detail.index;
        let fieldName = event.detail.fieldName;
        // console.log("currentIndex is #780 ", currentIndex, event.detail);
        let obj = { ...this.btLoanRec[currentIndex] };
        obj.isDirty = true;
        obj[fieldName] = event.detail.val;
        this.btLoanRec = [...this.btLoanRec];
        this.btLoanRec[currentIndex] = obj;

        const selectedEvent = new CustomEvent("select", {
            detail: this.btLoanRec
          });
      
          //dispatching the custom event
          this.dispatchEvent(selectedEvent);
    }


    @track finalArr = []
    addRow() {
        let numberOfRec = this.btLoanRec.length;
        console.log("numberOfRec", numberOfRec);
        let myNewElement = {
            BTFinancier__c: "",
            BTOriginalLoanAmt__c: "",
            BTLoanOutstandingValue__c: "",
            SpecifyOtherBTFinancier__c: "",
            BTFinancierStatus__c: "",
            ExistFedfinaAccNo__c: "",
            EMI__c : "",
            Loantobeclosedinternally__c : "",
            isDirty: false
        };
        console.log("myNewElement++++++ = ", myNewElement);

        let btLoanData = [...this.btLoanRec, myNewElement];
        this.btLoanRec = btLoanData;
    }
    @track totalLoanAmt = 0;
@track totalOutstanding = 0;
@track totalEMI = 0;

handleTotalMethod(btLoanRecNew) {
    // Reset the totals to zero before calculating
    this.totalLoanAmt = 0;
    this.totalOutstanding = 0;
    this.totalEMI = 0;

    // Check if btLoanRecNew is not null or undefined and has length
    if (Array.isArray(btLoanRecNew) && btLoanRecNew.length > 0) {
        btLoanRecNew.forEach(item => {
            // Convert to number to ensure proper addition
            this.totalLoanAmt += Number(item.BTOriginalLoanAmt__c) || 0;
            this.totalOutstanding += Number(item.BTLoanOutstandingValue__c) || 0;
            this.totalEMI += Number(item.EMI__c) || 0;
        });
    }
}

    handleDeleteAction(event) {
        console.log('btLoanRec in handle delete', JSON.stringify(this.btLoanRec), this.btLoanRec);
        //     let deleteRecId = event.target.dataset.id;
        //   //  this.btLoanRec.splice(event.currentTarget.dataset.index, 0);
        //     this.btLoanRec = this.btLoanRec.filter(e => e.Id !== deleteRecId);

        let deleteRecId = this.btLoanRec[event.target.dataset.index].Id;
        if (deleteRecId === undefined) {
            this.btLoanRec.splice(event.target.dataset.index, 1);
        }
        //  console.log("deleteRecId", deleteRecId);
        // if (deleteRecId.length === 18) 
        else {
            console.log("delete initated");
            this.handleDeleteRecId(deleteRecId);
        }
this.handleTotalMethod(this.btLoanRec);
    }

    @track del_recIds = []
    handleDeleteRecId(delRecId) {
        let fields = {};
        fields.Id = delRecId
        this.del_recIds = []
        this.del_recIds.push(fields)
        console.log("deleteRec_Array ", this.del_recIds);
        deletebtLoanRecord({ rcrds: this.del_recIds }).then((result) => {
            this.showToastMessage('Success', this.label.BTFinancierDeleteSuccess, 'success', 'sticky');
            this.btLoanRec = [];
            this.getBtLoanRecords();
            this.handleTotalMethod(this.btLoanRec);
        });
    }

    // handleSaveThroughLms(values) {
    //     console.log("values to save through Lms ", JSON.stringify(values));
    //     // if (values.recordId === this.recordId) {
    //     this.handleSave(values.validateBeforeSave);

    //     //   }
    // }

    handleSave(validate) {
        if (validate) {
            if (this.btLoanRec.length >= 1) {
                let isInputCorrect = this.validateForm();

                console.log("custom lookup validity if false>>>", isInputCorrect);

                if (isInputCorrect === true) {

                  //  this.createBTLoanRec();
                }
                else {
                    this.showToastMessage('Error', this.label.BTFinancierRequiredFields, 'error', 'sticky')
                }

            } else {
                if (this.stage !== 'QDE') {
                    this.showToastMessage('Error', this.label.BTFinancierRequired, 'error', 'sticky')
                }

            }


        } else {
           // this.createBTLoanRec();
        }
    }



    createBTLoanRec() {
        //  if(this.handleChargeAmt_validity()){
        try {
            //this.finalArr = [...this.btLoanRec]
            this.finalArr = this.btLoanRec.filter(item => item.isDirty === true)
            console.log('Filtered Final Array//1556', JSON.stringify(this.finalArr))

            let tempArray = [];
            let btLoanObj = {};

            for (let i = 0; i < this.finalArr.length; i++) {
                btLoanObj = {};
                btLoanObj.sobjectType = 'BTLoan__c'
                btLoanObj.BTFinancier__c = this.finalArr[i].BTFinancier__c
                btLoanObj.BTOriginalLoanAmt__c = this.finalArr[i].BTOriginalLoanAmt__c
                btLoanObj.BTLoanOutstandingValue__c = this.finalArr[i].BTLoanOutstandingValue__c
                btLoanObj.SpecifyOtherBTFinancier__c = this.finalArr[i].SpecifyOtherBTFinancier__c
                btLoanObj.BTFinancierStatus__c = this.finalArr[i].BTFinancierStatus__c
                btLoanObj.ExistFedfinaAccNo__c = this.finalArr[i].ExistFedfinaAccNo__c
                btLoanObj.LoanAppl__c = this._loanAppId
                btLoanObj.Id = this.finalArr[i].Id;
                tempArray.push(btLoanObj);
            }

            console.log('Filtered Assigned Final Array//1630', JSON.stringify(this.tempArray))

            // let valueArr = tempArray.map(function (item) { return item.ExistFedfinaAccNo__c });
            // let isDuplicate = valueArr.some(function (item, idx) {
            //     return valueArr.indexOf(item) !== idx
            // });
            // if (isDuplicate === true) {
            //     this.showToastMessage('Error', this.label.BTFinancierDuplicateRecordError, 'error', 'sticky');

            // } else {
                let upsertData = {
                    parentRecord: { "Id": this._loanAppId },
                    ChildRecords: tempArray,
                    ParentFieldNameToUpdate: 'LoanAppl__c'
                }

                console.log('upsert data //1535 -', JSON.stringify(upsertData))

                upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
                    .then(result => {

                        console.log('Loan Application Charge Record Created ##1538', result);

                        this.showToastMessage('Success', this.label.BTFinancierAddedSuccess, 'success', 'sticky')
                        // this.btLoanRec=[];
                        // refreshApex(this.wiredData);
                    })
                    .catch(error => {
                        console.error('Line no ##276', error)
                    })

          //  }

        } catch (e) {
            console.error('Final Error', e)
        }
        //  }
    }

    checkValidityLookup() {
        let isInputCorrect = true;
        let allChilds = this.template.querySelectorAll("c-custom-lookup");
        console.log("custom lookup allChilds>>>", allChilds);
        allChilds.forEach((child) => {
            console.log("custom lookup child>>>", child);
            console.log("custom lookup validity custom lookup >>>", isInputCorrect);
            if (!child.checkValidityLookup()) {
                child.checkValidityLookup();
                isInputCorrect = false;
                console.log("custom lookup validity if false>>>", isInputCorrect);
            }
        });
        return isInputCorrect;
    }

    // checkValidityDeupeDisplay() {
    //     let isInputCorrect = true;
    //     let allChilds = this.template.querySelectorAll("c-dedupe-display-value");
    //     console.log("custom picklist>>>", allChilds);
    //     allChilds.forEach((child) => {
    //         console.log("custom picklist child>>>", child);
    //         console.log("custom picklist validity custom lookup >>>", isInputCorrect);
    //         if (!child.checkValidityDeupeDisplay()) {
    //             child.checkValidityDeupeDisplay();
    //             isInputCorrect = false;
    //             console.log("custom picklist validity if false>>>", isInputCorrect);
    //         }
    //     });
    //     return isInputCorrect;
    // }

    checkValidityDeupeDisplay() {
        let isValid = true
        this.template.querySelectorAll('c-dedupe-display-value').forEach(element => {
            if (element.reportValidity()) {
                console.log('c-dedupe-display-value');
                console.log('element if--' + element.value);
            } else {
                isValid = false;
                console.log('element else--' + element.value);
            }
        });
        return isValid;
    }

 @api validateForm() {
        let isValid = true;
        if (!this.checkValidityLookup()) {
            console.log("IN IF lookup #519 bt loan>>>");
            isValid = false;
        }

        //console.log("this.checkValidityDeupeDisplay()492 bt loan>>>", this.checkValidityLookup());
        if (!this.checkValidityDeupeDisplay()) {
            isValid = false;
          }
       // console.log("this.checkValidityDeupeDisplay()496 bt loan>>>", this.checkValidityDeupeDisplay());
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (element.reportValidity()) {
                console.log("()529 bt loan>>>");
                //console.log('element passed');
            } else {
                console.log("(IN ELSE )532 bt loan>>>");
                isValid = false;
                element.setCustomValidity('')
            }


        });
        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            if (element.reportValidity()) {
                //console.log('element passed');
            } else {
                isValid = false;
                element.setCustomValidity('')
            }

        });

        // let customValidate=this.checkValidityLookup();
        // console.log('customValidate',customValidate);


        return isValid;
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
}