import { LightningElement,wire,track } from 'lwc';
import {subscribe, publish, MessageContext, APPLICATION_SCOPE} from 'lightning/messageService';
import INTEGRATIONMC from '@salesforce/messageChannel/IntegrationMessageChannel__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DummyParentLWC extends LightningElement {

    @wire(MessageContext)
    messageContext;

    @track subscription;

    connectedCallback(){
        this.subscription = this.subscribeHandler();
    }

    subscribeHandler(){
        subscribe(this.messageContext, INTEGRATIONMC, (message)=>{this.handleMessage(message)}, {scope:APPLICATION_SCOPE})
    }
    
    handleMessage(message){
        if(message.response != ''){
            console.log('###### IF #########'+message.response); 
            var response = message.response;
            console.log('response value---'+response); 
            if(response!=undefined){
                let toastMessage = '';
            let variant = 'error';
            if (response.includes('Dedupe') && response.includes('Customer ACK Request') && response.includes('Customer Issue Request')) {
                variant = 'success';
                toastMessage = 'Integration Messages Created Successfully.';
            }else{
                if(response.includes('error') ){
                    toastMessage = JSON.parse(response).error;
                }else if(response.includes('dedupe failed')){
                    toastMessage = 'Dedupe Integration failed'
                }else{
                    toastMessage ='Bureau Integration Failed';
                }
            }
    
            const toastEvent = new ShowToastEvent({
                title: variant === 'error' ? 'Error' : 'Success',
                message: toastMessage,
                variant: variant
            });
            this.dispatchEvent(toastEvent);  
            }           
        }  
    }

    createIntegrationMessage() {
        const message = {
            applicantId : {
                value : 'a0AC4000000DwqzMAC'
            }
        }
        publish(this.messageContext, INTEGRATIONMC, message);
    }
}