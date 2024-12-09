import { LightningElement,wire } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import YOUR_OBJECT from '@salesforce/schema/POCObject__c';

export default class csvLwCUploadPOC extends LightningElement {
    fileName;
    fileData;
    ObjFields1;
    fieldData;
    fieldList = [];
    handleFileChange(event) {
        this.fileData = event.target.files[0];
        this.fileName = this.fileData.name;
    }
    @wire(getObjectInfo, { objectApiName: YOUR_OBJECT })
    objectInfo;

    get fields() {
        
        let ObjFields;
        ObjFields = JSON.stringify(Object.values(this.objectInfo.data.fields));
        console.log('this.ObjFields',JSON.stringify(ObjFields));
        
    }

    async parseCSV(file) {
        const reader = new FileReader();
        
        reader.onload = async () => {
            const csv = reader.result;
            const rows = csv.split('\n');
            
            // Assuming CSV structure: header row followed by data rows
            const headers1 = rows[0].split(',');
            const headers = headers1.map(element => {return element.replace('\r', '')});
            console.log('headers',JSON.stringify(headers));
            // Parse data rows
            //console.log('this.fields',this.fields());
            for (let i = 1; i < rows.length-1; i++) {
                const data = rows[i].split(',');
                const recordInput = {};
                
                // Assuming headers.length === data.length
                for (let j = 0; j < headers.length; j++) {
                    recordInput[headers[j]] = data[j];
                }
                
                // Create record using Lightning Data Service
                await this.createRecord(recordInput);
                console.log('recordInput',JSON.stringify(recordInput));
            }
        };
        
        reader.readAsText(file);
    }
    async handleSave(){
        let ObjFields;
        
        ObjFields = Object.values(this.objectInfo.data.fields);
        this.ObjFields1 = JSON.stringify(ObjFields);
        console.log('this.ObjFields',this.ObjFields1);
        
        try{
            
             this.fieldData = this.ObjFields1;
            this.fieldList = this.fieldData.map(field => (
                field.apiName
                // Add more fields as needed
            ));
        console.log('this.fieldList',JSON.stringify(this.fieldList));
    }catch(error){
        console.error('this.apiName',error);
    }
        // if (this.fileData) {
        //     this.parseCSV(this.fileData);
        // }
    }

    async createRecord(recordData) {
        // Create a record using Lightning Data Service
        try {
            const record = await createRecord({ apiName: 'POCObject__c', fields: recordData });
            console.log('Record created:', record.id);
        } catch (error) {
            console.error('Error creating record:', error);
        }
    }
}