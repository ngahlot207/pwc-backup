import { LightningElement, api, wire, track } from "lwc";
import fetchRecords from "@salesforce/apex/ReusableLookupController.fetchRecords";
import { getRecord, deleteRecord } from 'lightning/uiRecordApi';

import deleteDocRecord from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';
/** The delay used when debouncing event handlers before invoking Apex. */
const DELAY = 500;
import { ShowToastEvent } from "lightning/platformShowToastEvent";
// Custom labels
import MultiSelLookup_Record_ErrorMessage from '@salesforce/label/c.MultiSelLookup_Record_ErrorMessage';
import MultiSelLookup_ErrorMessage from '@salesforce/label/c.MultiSelLookup_ErrorMessage';

export default class MultiSelectLookupComponent extends LightningElement {
    customLabel = {
        MultiSelLookup_Record_ErrorMessage,
        MultiSelLookup_ErrorMessage

    }

    @api label;
    @api required;
    @api selectedIconName;
    @api objectLabel;

    recordsList = [];
    @api selectedRecordName;
    @api objectApiName;
    @api fieldApiName;
    @api searchString = "";
    @api selectedRecordId;

    @api parentRecordId;
    @api parentFieldApiName;
    @api fieldName;
    @api disabledFlag;
    @api filterCondn
    @api selectedFields
    @track isLookup;
    @api keyId;
    @api selectedFieldName
    @api multiSelectOptions;

    @api hasEditAccess;
    get disabled() {
        if (this.hasEditAccess) {
            return false;
        } else {
            return true;
        }

    };
    preventClosingOfSerachPanel = false;
    @track optionData = [];
    //"[{\""[{\"userName\":\"Abhishek Chaukhe\",\"userId\":\"005C4000001qFSDIA2\",\"recordId\":\"a1cC4000000FY4bIAG\"}]"\":\"Abhishek Chaukhe\",\"userId\":\"005C4000001qFSDIA2\",\"recordId\":\"a1cC4000000FY4bIAG\"}]"
    //getting the default selected record
    connectedCallback() {
        console.log("this.selectedFieldName>>>>>>>>>", this.selectedFieldName, '::::', this.selectedRecordId, this.disabled, this.multiSelectOptions);

        let ret = [];
        if (this.selectedRecordId) {
            let data = JSON.parse(this.selectedRecordId);
            data.forEach(element => {
                if (this.multiSelectOptions) {
                    let pd = this.multiSelectOptions.find((doc) => doc.value == element);
                    if (pd) {
                        console.log('this.multiSelectOptions rec', pd);
                        ret.push(pd);
                        //let recc = { label: pd.userName, value: element.userId, recordId: element.recordId };
                    }
                }

                // let recc = { label: element.userName, value: element.userId, recordId: element.recordId };
                // ret.push(recc);
            });
        }
        this.optionData = ret;
        /// this.updateToParent(this.optionData);/// https://fedfina.atlassian.net/browse/LAK-5769
        // if (this.selectedRecordId) {
        //     this.fetchSobjectRecords(true);
        // }
    }
    get methodInput() {
        return {
            objectApiName: this.objectApiName,
            fieldApiName: this.fieldApiName,
            searchString: this.searchString,
            selectedRecordId: '',
            parentRecordId: this.parentRecordId,
            parentFieldApiName: this.parentFieldApiName,
            filterConditions: this.filterCondn,
            selectFields: this.selectedFields,
            keyId: this.keyId,
            selecetdFieldName: this.selectedFieldName
        };
    }

    get showRecentRecords() {
        if (!this.recordsList) {
            return false;
        }
        return this.recordsList.length > 0;
    }

    fetchSobjectRecords(loadEvent) {
        console.log("input >>>>>", JSON.stringify(this.methodInput));
        fetchRecords({
            inputWrapper: this.methodInput
        })
            .then((result) => {
                console.log("result>>>>>", result);
                if (loadEvent && result) {
                    this.selectedRecordName = result[0].mainField;
                    console.log(
                        "this.selectedRecordName>>>>>>",
                        this.selectedRecordName
                    );
                } else if (result) {
                    let res = JSON.parse(JSON.stringify(result));

                    this.recordsList = res;
                    console.log("this.recordsList>>>>>>>", res, this.recordsList);
                } else {
                    this.recordsList = [];
                }
            })
            .catch((error) => {
                console.log(error);
            });
    }

    get isValueSelected() {
        return this.selectedRecordId;
    }

    //handler for calling apex when user change the value in lookup
    handleChange(event) {
        this.searchString = '';
        this.searchString = event.target.value;
        if (this.searchString) {
            this.fetchSobjectRecords(false);
        }
    }

    //handler for clicking outside the selection panel
    handleBlur() {
        this.recordsList = [];
        this.preventClosingOfSerachPanel = false;
    }

    //handle the click inside the search panel to prevent it getting closed
    handleDivClick() {
        this.preventClosingOfSerachPanel = true;
    }

    //handler for deselection of the selected item
    handleCommit() {
        this.selectedRecordId = "";
        this.selectedRecordName = "";
        this.lookupFieldAPIName = "";
        let selectedRecord = {
            mainField: null,
            subField: null,
            id: null,
            lookupFieldAPIName: this.fieldName

        };
        const selectedEvent = new CustomEvent("select", {
            detail: selectedRecord
        });

        //dispatching the custom event
        this.dispatchEvent(selectedEvent);
        console.log('Value is removed from lookup');
    }

    //handler for selection of records from lookup result list
    handleSelect(event) {
        if (this.hasEditAccess) {
            let selectedRecord = {
                mainField: event.currentTarget.dataset.mainfield,
                subField: event.currentTarget.dataset.subfield,
                id: event.currentTarget.dataset.id,
                lookupFieldAPIName: this.fieldName

            };
            console.log('selectedRecord', selectedRecord);
            // this.selectedRecordId = selectedRecord.id;
            // this.selectedRecordName = selectedRecord.mainField;
            // this.lookupFieldAPIName = selectedRecord.parentName;
            let recc = { label: selectedRecord.mainField, value: selectedRecord.id };
            let addVal = true;
            if (this.optionData.length > 0) {
                this.optionData.forEach(element => {
                    if (element.value === selectedRecord.id) {
                        addVal = false;
                    }
                });
                if (addVal) {
                    this.optionData.push(recc);
                } else {
                    this.showToast('Error', 'error', this.customLabel.MultiSelLookup_Record_ErrorMessage);
                }

            } else {
                this.optionData.push(recc);
            }


            //this.optionData = [{ label: selectedRecord.mainField, value: selectedRecord.id, selected: true }];

            console.log("this.optionData>>>>>>>", this.optionData.length, this.optionData);
            this.recordsList = [];
            this.updateToParent(this.optionData);
            // Creates the event
            // const selectedEvent = new CustomEvent("select", {
            //     detail: selectedRecord
            // });

            // //dispatching the custom event
            // this.dispatchEvent(selectedEvent);
        }
        this.reportValidity();
    }
    updateToParent(value) {
        let param = value;
        const selectEvent = new CustomEvent('select', {
            detail: param
        });
        this.dispatchEvent(selectEvent);
    }

    showToast(title, varient, msz) {

        const toastEvent = new ShowToastEvent({
            title: title,
            message: msz,
            variant: varient,
            mode: "dismissable"
        });
        this.dispatchEvent(toastEvent);
    }

    //to close the search panel when clicked outside of search input
    handleInputBlur(event) {
        // Debouncing this method: Do not actually invoke the Apex call as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        window.clearTimeout(this.delayTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            if (!this.preventClosingOfSerachPanel) {
                this.recordsList = [];
            }
            this.preventClosingOfSerachPanel = false;
        }, DELAY);
        this.reportValidity();
    }
    @track errorMsg;
    @api checkValidityLookup() {
        // let recordValue = this.template.querySelector(".lookupCls");

        // if (!recordValue.value) {
        //     recordValue.setCustomValidity("Please Enter Valid Input");
        //     console.log(" recordValue.setCustomValidity>>>",  recordValue.setCustomValidity);
        //     this.errorMsg =  recordValue.setCustomValidity();
        // } else {
        //     recordValue.setCustomValidity(""); // clear previous value
        // }

        const isInputCorrect = [
            ...this.template.querySelectorAll("lightning-input")
        ].reduce((validSoFar, inputField) => {
            if (!this.selectedRecordName && this.required) {
                inputField.setCustomValidity("Please Enter Valid Input");
            } else {
                inputField.setCustomValidity("");
            }
            inputField.reportValidity();

            return validSoFar && inputField.checkValidity();
        }, true);
        console.log("return in custom lookup>>>", isInputCorrect);

        return isInputCorrect;

    }


    closePill(event) {
        if (this.hasEditAccess) {
            var value = event.currentTarget.name;

            var options = JSON.parse(JSON.stringify(this.optionData));
            let optnew;
            for (var i = 0; i < options.length; i++) {
                if (options[i].value === value) {
                    if (options[i].recordId) {
                        let delList = [];
                        let delRecord = {};
                        delRecord['Id'] = options[i].recordId;
                        delList.push(delRecord);
                        console.log('delete started ', JSON.stringify(delList));
                        deleteDocRecord({ rcrds: delList })
                            // .then((result) => {
                            .then((result) => {
                                console.log('record removed', JSON.stringify(result));
                            })
                            .catch((error) => {
                                this.showToast("Error", "error", error.body.message);
                            });

                        deleteRecord(options[i].recordId)
                            .then(() => {
                                console.log('record removed');
                            });
                    }


                    optnew = options.filter(e => e !== options[i]);
                }
            }
            this.optionData = [...optnew];
            this.updateToParent(this.optionData);
        }
        this.reportValidity();
    }
    @api reportValidity() {
        let isValid = true;

        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (this.optionData.length == 0 && this.required) {
                element.setCustomValidity('Complete this field.');
                isValid = false;
            } else {
                element.setCustomValidity('');
                isValid = true;
            }
            element.reportValidity();
        });

        // if (this.optionData.length == 0 && this.required) {
        //     isValid = false;
        // } else {
        //     isValid = true;
        // }

        // this.template.querySelectorAll('lightning-textarea').forEach(element => {
        //     if (element.reportValidity()) {
        //         console.log('element passed lightning-textarea');
        //         console.log('element if--' + element.value);
        //     } else {
        //         isValid = false;
        //     }
        // });
        return isValid;
    }
}