import { LightningElement, api, wire} from 'lwc';
import LEADDATAMC from '@salesforce/messageChannel/LeadDataMessageChannel__c';
import {subscribe, publish, MessageContext, APPLICATION_SCOPE} from 'lightning/messageService';

export default class LeadButtons extends LightningElement { 

    @api saveAndDraft
    @api closeLead = false
    @api enableEMIButton = false
    saveButton = false 
    closeButton = false
    disableEMIButton = true

    firstName 
    lastName


    @wire(MessageContext)
    context

    connectedCallback(){
        this.subscribeHandler(); 
    }
    
    subscribeHandler(){
        subscribe(this.context, LEADDATAMC, (message)=>{this.handleMessage(message)}, {scope:APPLICATION_SCOPE})
    }
    
    handleMessage(message){
        if(message.lmsData.value === 'Enable Close Lead Button' ){
            this.closeLead = true
        }
        ///LAK-46 Enable EMI Calculator
        if(message.lmsData.value === 'Enable EMI Calculator Button' ){
            this.enableEMIButton = true
            this.disableEMIButton = false
        }
        ///LAK-46 Disable EMI Calculator
        if(message.lmsData.value === 'Disable EMI Calculator Button' ){
            this.enableEMIButton = true
            this.disableEMIButton = true
        }
    }
    
    handleSaveAsDraft(){
        this.publishSaveMessage();
    } 

    handleCloseLead(){       
        this.publishCloseMessage()
    }
    handleEmiCalculator(){
        this.publishEMICalculatorMessage();
    }

    publishSaveMessage(){        
        const message = {
            lmsData : {
                value : 'Save as draft'
            }
        }
        publish(this.context, LEADDATAMC, message);
    }

    publishCloseMessage(){        
        const message = {
            lmsData : {
                value : 'Close Lead' 
            }
        }
        publish(this.context, LEADDATAMC, message);
    }
    ///LAK-46 Publish EMI Calculator
    publishEMICalculatorMessage(){        
        const message = {
            lmsData : {
                value : 'emi calculator'
            }
        }
        publish(this.context, LEADDATAMC, message);
    }
}