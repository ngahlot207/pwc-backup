import { LightningElement, track, api, wire } from 'lwc';
import { publish, MessageContext } from "lightning/messageService";
import SaveBtnChannel from "@salesforce/messageChannel/SaveBtnChannel__c";

export default class SaveBthGeneric extends LightningElement {
    @api buttonConfiguration = [
        {
            btnLabel: "Save",
            variant: "brand",
            title: "Looks like a link",
            class: "slds-m-left_x-small",
            positionClass: "slds-p-left_medium"
        },
        {
            btnLabel: "Save As Draft",
            variant: "brand",
            title: "Looks like a link",
            class: "slds-m-left_x-small",
            positionClass: "slds-p-left_medium"
        },
        {
            btnLabel: "Validate",
            variant: "brand",
            title: "Looks like a link",
            class: "slds-m-left_x-small",
            positionClass: "slds-p-left_medium"
        }
    ];

    @api hasEditAccess;

    @api currentTabId;

    @track disableMode;

    subscription = null;
    @wire(MessageContext)
    MessageContext;
    // {
    //     "buttonConfiguration": [
    //       {"btnLabel":"Save" ,
    //         "variant":"brand" ,
    //         "title":"Looks like a link" ,
    //         "class":"slds-m-left_x-small"
    //       },
    //       {"btnLabel":"Save As Draft" ,
    //         "variant":"brand" ,
    //         "title":"Looks like a link" ,
    //         "class":"slds-m-left_x-small"
    //       },
    //         {"btnLabel":"Validate" ,
    //         "variant":"brand" ,
    //         "title":"Looks like a link" ,
    //         "class":"slds-m-left_x-small"
    //       }
    //     ]
    //   }

    connectedCallback() {
        if (this.hasEditAccess === false) {
            this.disableMode = true;
        }
        else {
            this.disableMode = false;
        }
       
    }
    handleSave(event) {
        let label = event.target.label;
        const payload = {
            buttonClicked: label,
            Id: this.currentTabId
        };
        publish(this.MessageContext, SaveBtnChannel, payload);
        console.log('save lms called From  SaveBthGeneric ', JSON.stringify(payload));

    }

  
}