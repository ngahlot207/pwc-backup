import { LightningElement, wire, track } from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';

export default class TestTabSet extends LightningElement {

    @track relatedRecords;
    @track updatedColumns;
    @track DocDetailotc;

    handleRowAction(){}
    handleCellChange(){

    }
    connectedCallback(){
        this.DocDetailotc = [
            {"Id": "asdfsdfdsfds", "DocTyp__c": "teDsdafdsf", "DocSubTyp__c": "23425345345"},
            {"Id": "asdfsdfds1fds", "DocTyp__c": "teDsdafds1f", "DocSubTyp__c": "234253453415"},
            {"Id": "asdfsdfdsf11ds", "DocTyp__c": "teDsdafds11f", "DocSubTyp__c": "2342534531145"},
            {"Id": "asdfsdfdsfd111s", "DocTyp__c": "teDsdafds111f", "DocSubTyp__c": "23425345311145"}
        ]
        this.updatedColumns = [
            {
                label: 'Document Type /SC',
                fieldName: 'DocTyp__c',
                type: 'text',
                editable: true,
                hideDefaultActions: true
            },
            {
                label: 'Document Name/SC Details',
                fieldName: 'DocSubTyp__c',
                type: 'text',
            }
        ];
    }
}