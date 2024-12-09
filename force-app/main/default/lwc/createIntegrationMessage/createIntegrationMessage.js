import { LightningElement,wire,api, track } from 'lwc';
import {subscribe, publish, MessageContext, APPLICATION_SCOPE} from 'lightning/messageService';
import INTEGRATIONMC from '@salesforce/messageChannel/IntegrationMessageChannel__c';
import createIntMessage from '@salesforce/apex/GlobalServiceClass.CreateIntegrationRequest';

export default class CreateIntegrationMessage extends LightningElement {

    @api applicantid = '';
    @track responseWrapper;
    @wire(MessageContext)
    context;

    subscription;
    isPublishing = false;

    connectedCallback(){
        console.log('######CCB called#########');
        if(this.subscription == undefined || this.subscription ==''){
            this.subscription = subscribe(
                this.context,
                INTEGRATIONMC,
                (message) => {
                    if (!this.isPublishing) {
                        this.handleMessage(message);
                    }
                    this.isPublishing = false;
                }  
            );
        }
    }

    handleMessage(message){        
        if(message.applicantId.value != ''){
            console.log('###### IF Cretae Int Msg#########'+message.applicantId.value);                   
            this.applicantid = message.applicantId.value?message.applicantId.value:'No Value';
            createIntMessage({applicantId:this.applicantid})
            .then(data =>{
                if (data) {
                    this.responseWrapper = data;
                    console.log('responseWrapper fetching data: ' + JSON.stringify(this.responseWrapper));
                    const message = {
                        response: JSON.stringify(this.responseWrapper)
                    };
                    this.isPublishing = true;
                    publish(this.context, INTEGRATIONMC, message);

                } else if (error) {
                    console.error('Error fetching data: ' + error);
                }
        });
        }  
    }
}