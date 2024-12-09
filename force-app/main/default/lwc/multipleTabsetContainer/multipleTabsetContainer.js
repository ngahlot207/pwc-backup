import { LightningElement, api, track, wire } from 'lwc';
import fetchQryRecordMethod from "@salesforce/apex/FetchApplicantDetails.fetchQryRecordMethod";
import { deleteRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import formFactorPropertyName from "@salesforce/client/formFactor";

//LMS details
import UpdateTable from "@salesforce/messageChannel/RecordCreate__c";
import { subscribe, publish, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
// Custom labels
import MultiTabset_Del_SuccessMessage from '@salesforce/label/c.MultiTabset_Del_SuccessMessage';

export default class MultipleTabsetContainer extends LightningElement {
    customLabel = {
        MultiTabset_Del_SuccessMessage
    }
    @api loanAppId;
    @api qry;
    @api fieldsOnTabset;
    @api componentsToRender;
    @api addButtonLabel;
    @api removeButtonLabel = 'Remove';
    @api addSuccessMessage;
    @api removeSuccessMessage;
    @api removeModalMessage = 'Do you want to delete?';
    @api noRecordsMessage = 'No records are present currently.';
    @api newTabLabel;
    @api useAddRowBy = false;
    @api showAddRecord;
    @api objectApiName;
    @api applicantId;
    @api isReadOnly;
    @api hasEditAccess;
    @api newlyAddedTabLabel;

    @track formFactor = formFactorPropertyName;
    desktopBoolean = false;
    phoneBolean = false;

    @track metadataList = [];
    @track showScreenConfig = false;
    @track hideDeleteBth = true;
    @track tabset = [];
    @track tabDefaultValue;
    // @track applicantId;
    @track refreshTabset = false;
    @track isModalOpen = false;
    @track disableMode;
    // @track disableMode;
    @track renderTabSet = false;
    get neMeta() {
        return JSON.stringify(this.metadataList);
    }


    @wire(MessageContext)
    MessageContext;

    connectedCallback() {

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

        console.log('hasEditAccess in multitab set::::::', this.hasEditAccess);
        if (this.hasEditAccess === false) {
            this.disableMode = true;
            this.hideDeleteBth = this.disableMode;
        }
        this.scribeToMessageChannel();
        this.getTabsetData();


    }
    renderedCallback() {

        if (this.renderTabSet) {
            this.template.querySelector('lightning-tabset').activeTabValue = this.tabDefaultValue;
            this.renderTabSet = false;
        }
    }

    scribeToMessageChannel() {
        this.subscription = subscribe(
            this.MessageContext,
            UpdateTable,
            (values) => this.reloadTabset(values)
        );

    }
    reloadTabset(value) {
        console.log('value to update tabset ', value);
        this.getTabsetData(value.recordId);
    }

    @track newRecordId;

    getTabsetData(val) {
        this.newRecordId = val;
        console.log("multipletabsetComponent ", " qry: ", this.qry, " loanAppId: ", this.loanAppId, " tabsetFields: ", this.fieldsOnTabset);
        fetchQryRecordMethod({ qry: this.qry, loanAppId: this.loanAppId, tabsetFields: this.fieldsOnTabset, newTabLabel: this.newTabLabel }).then((result) => {
            console.log(
                "fetchQryRecordMethod result of qry == ",
                result
            );
            if (result != null) {
                //this.refreshTabset = false;
                this.hideDeleteBth = false;
                let res = JSON.parse(result);
                console.log('Result Receieved!! ' + JSON.stringify(res) + val + ' ' + res.length);
                if (val) {
                    var i = res.length;
                    var tabId;
                    while (i--) {
                        if (val == res[i].value) {
                            tabId = res[i].value;
                            break;
                        }
                    }

                    //this.tabDefaultValue = res[res.length - 1].value;
                    if (tabId) {
                        this.tabDefaultValue = tabId;
                        this.renderTabSet = true;
                    } else {
                        this.tabDefaultValue = res[0].value;
                        this.renderTabSet = true;
                    }

                    //this.template.querySelector('lightning-tabset').activeTabValue = value;
                    // this.showToast("Success", "success", "Tab updated");

                } else {
                    this.tabDefaultValue = res[0].value;
                    this.renderTabSet = true;
                }

                this.tabset = res;
                this.tabset.forEach(element => {
                    if (element.value == this.tabDefaultValue) {
                        element.showTab = true;
                    } else {
                        element.showTab = false;
                    }

                });
                this.refreshTabset = true;

                this.updateMetadetaVal();
                console.log('metadataList :: ', JSON.stringify(this.metadataList));
                this.showScreenConfig = true;

            }
            else {
                console.log('SuccesMessage is not  there 000');
                this.hideDeleteBth = true;

                if (!this.disableMode) {
                    console.log('SuccesMessage is not  there');
                    this.showToast("", "info", this.noRecordsMessage);
                }
            }
            if (this.disableMode === true) {
                this.hideDeleteBth = true;
            }
        });

    }
    updateMetadetaVal() {
        this.metadataList = [];
        for (let i = 0; i < this.componentsToRender.length; i++) {

            this.metadataList.push(Object.assign({}, this.componentsToRender[i]));
        }
        console.log(' getTabsetData metadetaList   ', JSON.stringify(this.metadataList));

        for (let i = 0; i < this.componentsToRender.length; i++) {
            if (this.componentsToRender[i].key) {
                let idFor = this.componentsToRender[i].key;
                console.log('idFor i:: ', idFor);
                //ASF

                if (this.metadataList[i].applicantId === null) {
                    console.log(' For applicantId ');
                    this.metadataList[i]['applicantId'] = this.applicantId;
                }
                if (this.metadataList[i].loanAppId === null) {
                    console.log("For loanAppId ");
                    this.metadataList[i]['loanAppId'] = this.loanAppId;
                }
                if (this.metadataList[i].recordId === null) {
                    console.log("For recordId ");
                    this.metadataList[i]['recordId'] = this.loanAppId;
                }

                this.metadataList[i]['hasEditAccess'] = this.hasEditAccess;

                // this.metadataList[i]['loanAppId'] = this.loanAppId;
                // this.metadataList[i]['recordId'] = this.loanAppId;

                // if (idFor === 'applicantId') {
                //     this.metadataList[i][idFor] = this.applicantId;
                // }
                // else if (idFor === 'loanAppId' || idFor === 'recordId') {
                //     this.metadataList[i][idFor] = this.loanAppId;
                // }
            }
        }
    }

    handleActive(event) {

        //this.tabDefaultValue = event.target.value;
        if (this.newRecordId && this.tabDefaultValue && this.newRecordId == this.tabDefaultValue) {
            this.tabDefaultValue = this.newRecordId;
            let tabsetelement = this.template.querySelector('[data-id="multipleTabSet"]');

            tabsetelement.activeTabValue = this.tabDefaultValue;
            this.renderTabSet = true;
        } else {
            this.tabDefaultValue = event.target.value;

            this.template.querySelector('lightning-tabset').activeTabValue = this.tabDefaultValue;
            this.renderTabSet = true;
            //let tabsetelement = this.template.querySelector('[data-id="multipleTabSet"]');

            //tabsetelement.activeTabValue = this.tabDefaultValue;
        }
        console.log('this.tabDefaultValue>>>>', this.tabDefaultValue);
        if (this.newRecordId) {
            this.newRecordId = undefined;
        }
        console.log('handleActive  clicked  for ', event.target.label, '  and id is ', event.target.value);
        let value = event.target.value;
        //ASF
        // if (value === 'new') {
        //     value = '';
        // }
        console.log("handleActive ", JSON.stringify(this.componentsToRender));
        this.showScreenConfig = false;
        // for (let i = 0; i < this.componentsToRender.length; i++) {
        //     if (this.componentsToRender[i].key) {
        //         let idFor = this.componentsToRender[i].key;
        //         console.log('handleActive idFor i:: ', idFor);
        //         if (idFor === 'applicantId') {
        //             this.metadataList.push(Object.assign({}, this.componentsToRender[i]));
        //             this.metadataList[i][idFor] = value;
        //             // this.metadataList[i]['loanAppId'] = this.loanAppId;
        //         }
        //         if (idFor === 'loanAppId' || idFor === 'recordId') {

        //             //   console.log('handleActive  metadataList recordId :: ', JSON.stringify(this.metadataList));
        //             this.metadataList[i][idFor] = this.loanAppId;
        //             console.log('handleActive  metadataList recordId :: ', JSON.stringify(this.metadataList));

        //         } else {

        //         }
        //     } this.metadataList.push(Object.assign({}, this.componentsToRender[i]));
        // }

        console.log('handleActive  metadataList :: ', JSON.stringify(this.metadataList));
        // this.showScreenConfig = true;
        this.tabset.forEach(element => {
            if (element.value == this.tabDefaultValue) {
                element.showTab = true;
            } else {
                element.showTab = false;
            }

        });
        setTimeout(() => {
            this.showScreenConfig = true;
            console.log('this.showScreenConfig = true;', this.showScreenConfig);
        }, 100);

    }
    handleAddRecord(event) {
        this.showScreenConfig = false;
        console.log('new added val  first ', this.tabset, this.metadataList);
        this.refreshTabset = false;
        let saveFirst = false;
        for (let i = 0; i < this.tabset.length; i++) {
            if (this.tabset[i].value == "new") {
                this.showToast("Error", "error", "Please Save " + this.newTabLabel + " First ");

                saveFirst = true;
            } else {
            }
        }
        let tabLabel = '';
        if (this.newlyAddedTabLabel) {
            tabLabel = this.newlyAddedTabLabel;
        } else {
            tabLabel = this.newTabLabel;
        }

        let newRecordTab =
        {
            label: tabLabel,
            value: "new"
        }
        if (saveFirst == false || this.tabset.length === 0) {
            if (this.addSuccessMessage) {
                this.showToast("Success", "success", this.addSuccessMessage);
            } else {
                this.showToast("Success", "success", this.newTabLabel + " Added");
            }



            // let newTabList = [];
            // newTabList.push(newRecordTab);

            // this.tabset.push(Object.assign({}, newRecordTab));
            // this.tabset = { ...newRecordTab };
            this.tabset = [...this.tabset, newRecordTab];
            if (this.tabset.length > 0) {
                this.hideDeleteBth = false;
            } else {
                this.hideDeleteBth = true;
            }
            // this.tabset = newTabList;
            this.tabDefaultValue = "new";
            this.renderTabSet = true;
        }
        console.log('new added val  end ', this.tabset);
        this.refreshTabset = true;
        // this.showScreenConfig = true;
        let stageis = { target: newRecordTab };
        console.log(' stageis', stageis);
        this.updateMetadetaVal();
        this.handleActive(stageis);
    }

    handleRemoveClick() {
        this.isModalOpen = true;
    }


    handleRemoveRecord(event) {
        this.refreshTabset = false;
        // let deleteNew = false;
        // let deleteDefault = false;
        // let localTabset = [];
        let toDelete = this.tabset.find((doc) => doc.value == this.tabDefaultValue);
        let removedList = this.tabset.filter((doc) => doc.value !== this.tabDefaultValue);
        this.tabset = removedList;
        if (this.tabset.length > 0) {
            this.hideDeleteBth = false;
        } else {
            this.hideDeleteBth = true;
        }
        if (this.tabDefaultValue !== "new") {
            //  let removedList = this.tabset.filter((doc) => doc.value == this.tabDefaultValue);
            this.delete(toDelete.value);
        } else if (this.tabDefaultValue === "new") {
            this.isModalOpen = false;
            if (this.removeSuccessMessage) {
                this.showToast("Success", "success", this.removeSuccessMessage);
            } else {
                this.showToast("Success", "success", this.customLabel.MultiTabset_Del_SuccessMessage);
            }
        } else {
            this.isModalOpen = false;
        }
        this.tabDefaultValue = this.tabset[0].value;
        this.renderTabSet = true;
        console.log('new added val  ', this.tabset);
        this.refreshTabset = true;
        if (this.disableMode === true) {
            this.hideDeleteBth = true;
        }
    }


    delete(idToDelete) {

        deleteRecord(idToDelete)
            .then(() => {
                if (this.removeSuccessMessage) {
                    this.showToast("Success", "success", this.removeSuccessMessage);
                } else {
                    this.showToast("Success", "success", this.customLabel.MultiTabset_Del_SuccessMessage);
                }
                this.isModalOpen = false;

                // Navigate to a record home page after
                // the record is deleted, such as to the
                // contact home page


            })
            .catch((error) => {
                this.isModalOpen = false;
                console.log('Errror !! ' + JSON.stringify(error));
                this.showToast("Error deleting record", "error", error.body.message);

            });
    }
    showToast(title, variant, message) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message
        });
        this.dispatchEvent(evt);
    }

    closeModal() {
        this.isModalOpen = false;
    }

}