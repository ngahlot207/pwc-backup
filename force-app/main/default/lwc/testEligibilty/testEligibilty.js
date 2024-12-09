import { LightningElement, wire } from 'lwc';
import { getRecord, deleteRecord } from 'lightning/uiRecordApi';
import { getPicklistValues, getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import { subscribe, publish, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';

export default class TestEligibilty extends LightningElement {


    @wire(MessageContext)
    MessageContext;


    connectedCallback(){
        this.scribeToMessageChannel();
    }

    scribeToMessageChannel() {
        this.subscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveThroughLms(values)
        );
    
    }

    handleSaveThroughLms(values) {
        //console.log('values to save through Lms ', JSON.stringify(values));
        this.handleSave(values.validateBeforeSave);
    }

    handleSave(validate){
        if(validate){
            // check with queryselector if your resective is on the scren or not
            // First fore the validate method of the respective child component
            // if(validation is successful){
            //     then call the upsertmethod to save the data
            // }


        }
        // check with queryselector if your resective is on the scren or not
        //then call the upsertmethod to save the data
    }

}