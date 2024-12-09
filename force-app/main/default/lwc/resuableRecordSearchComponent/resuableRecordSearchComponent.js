import { LightningElement, track, wire, api} from 'lwc';
import LEADDATAMC from '@salesforce/messageChannel/LeadDataMessageChannel__c';
import {subscribe, publish, MessageContext, APPLICATION_SCOPE} from 'lightning/messageService';

export default class ResuableRecordSearchComponent extends LightningElement {
    @api label
    @api resultData = []
    @api recId
    @api searchInput 
    @api messageResult = false  
    @api searchResult = false 
    @api reqFlag = false  
    @api disabled = false

    @wire(MessageContext)
    context   

    handleKeyChange(event){
            this.searchResult = true
            this.dispatchEvent(new CustomEvent('inputchange', 
            {
                detail:{
                    searchkey : event.target.value
                }
            }
            ))       
    }

    handleParentSelection(event){
        this.recId = event.currentTarget.dataset.value
        this.searchInput = event.currentTarget.dataset.label
        const selectedEvent = new CustomEvent('selected',
        {
            detail:{
                id : this.recId,
                value : this.searchInput
            }
        }) 
        this.dispatchEvent(selectedEvent) 
        this.searchResult = false  
    }

    connectedCallback(){
        this.subscribeHandler();         
    }
    
    subscribeHandler(){
        subscribe(this.context, LEADDATAMC, (message)=>{this.handleMessage(message)}, {scope:APPLICATION_SCOPE})
    }

    handleMessage(message){
        this.searchInput = message.lmsData.value ? message.lmsData.value : ''
        console.log('serach input -'+this.searchInput)
    }
    
}