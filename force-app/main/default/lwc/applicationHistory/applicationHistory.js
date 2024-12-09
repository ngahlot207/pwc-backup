import { LightningElement,track,api, wire  } from 'lwc';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import { formattedDateTime } from 'c/dateUtility';
import { formattedDateTimeWithSeconds } from 'c/dateUtility';
export default class ApplicationHistory extends LightningElement {

//@api recordId = 'a08C4000007VLU0IAO';
@track activeSections = [];
 updatedColumns = [
{
    label: 'Status',
    fieldName: 'Status__c',
    type: 'text',
      
},   
{
    label: 'Stage',
    fieldName: 'Stage__c',
    type: 'text',
    
},
{
    label: 'Sub Stage',
    fieldName: 'Sub_Stage__c',
    type: 'text',
   
},
{
    label: 'User Role',
    fieldName: 'UserRole__c',
    type: 'text',
   
},
{
    label: 'User',
    fieldName: 'OwnerName__c',
    type: 'text',
  
},
{
    label: 'In Date & Time',
    fieldName: 'EntryTime__c',
    type: 'datetime'
    
},
{
    label: 'Out Date & Time',
    fieldName: 'ExitTime__c',
    type: 'datetime'
    // typeAttributes: {
    //   day: 'numeric',
    //   month: 'short',
    //   year: 'numeric',
    //   hour: '2-digit',
    //   minute: '2-digit',
    //   second: '2-digit',
    //   hour12: true
    // },
    
},
{
    label: 'Time Difference',
    fieldName: 'TotalTimeDiff__c',
    type: 'text',
    
}
];
@track _recordId
    @api get recordId() {
        return this._recordId;
    }
    @api loanAppId;
    set recordId(value) {
        this._recordId = value;
        this.setAttribute("recordId", value);
       this.handleRecordIdChange(value);
    }

    @track error;
    @track accList ;
    @track loanTatParams = {
        ParentObjectName: 'LoanTAT__c',
        ChildObjectRelName: '',
        parentObjFields: ['Id','Stage__c','LoanApplication__c','Sub_Stage__c', 'UserRole__c', 'OwnerName__c', 'EntryTime__c','ExitTime__c','TotalTimeDiff__c','Status__c'],
        childObjFields: [],
        queryCriteria: ''
        }   
       handleRecordIdChange() {
            let tempParams = this.loanTatParams;
            tempParams.queryCriteria = ' where LoanApplication__c = \'' + this._recordId + '\' order by EntryTime__c desc' ;
            this.loanTatParams = { ...tempParams };
    
        }

    @wire(getSobjectData,{params : '$loanTatParams'})
    floatingRateHandler({data,error}){
        if(data){

            console.log('DATA IN APPLICATION HISTORY ::::>>>>',data);
            //this.accList = data.parentRecords;

            // if(data && data.parentRecords && data.parentRecords.length){
            //     this.accList = data.parentRecords.map(record => {
            //         let modifiedRecord = { ...record };       
            //         if (modifiedRecord && modifiedRecord.EntryTime__c) {
            //             const rawDateTime = new Date(modifiedRecord.EntryTime__c);
            //             if (!isNaN(rawDateTime.getTime())) { // Check if the date is valid
            //                 const day = rawDateTime.getDate().toString().padStart(2, '0');
            //                 const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            //                 const month = monthNames[rawDateTime.getMonth()];
            //                 const year = rawDateTime.getFullYear();
            //                 const hours = rawDateTime.getHours().toString().padStart(2, '0');
            //                 const minutes = rawDateTime.getMinutes().toString().padStart(2, '0');
            //                 const seconds = rawDateTime.getSeconds().toString().padStart(2, '0');
            //                 const formattedDate = `${day}-${month}-${year} ${hours}:${minutes}:${seconds}`;
            //                 modifiedRecord.EntryTime__c = formattedDate;
            //             }
            //         }
            //         if (modifiedRecord && modifiedRecord.ExitTime__c) {
            //             const rawDateTime = new Date(modifiedRecord.ExitTime__c);
            //             if (!isNaN(rawDateTime.getTime())) { // Check if the date is valid
            //                 const day = rawDateTime.getDate().toString().padStart(2, '0');
            //                 const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            //                 const month = monthNames[rawDateTime.getMonth()];
            //                 const year = rawDateTime.getFullYear();
            //                 const hours = rawDateTime.getHours().toString().padStart(2, '0');
            //                 const minutes = rawDateTime.getMinutes().toString().padStart(2, '0');
            //                 const seconds = rawDateTime.getSeconds().toString().padStart(2, '0');
            //                 const formattedDate = `${day}-${month}-${year} ${hours}:${minutes}:${seconds}`;
            //                 modifiedRecord.ExitTime__c = formattedDate;
            //             }
            //         }
            //         return modifiedRecord; // Return the modified record
            //     });
            // }


            if(data && data.parentRecords && data.parentRecords.length){
                this.accList = data.parentRecords.map(record => {
                    let modifiedRecord = { ...record };       
                    if (modifiedRecord && modifiedRecord.EntryTime__c) {
                        const rawDateTime = new Date(modifiedRecord.EntryTime__c);
                        if (!isNaN(rawDateTime.getTime())) { // Check if the date is valid
                            
                            const formattedDate1 = formattedDateTimeWithSeconds(rawDateTime); 
                            const dateOfIntiation1 = `${formattedDate1}`;
                            modifiedRecord.EntryTime__c = dateOfIntiation1;
                        }
                    }
                    if (modifiedRecord && modifiedRecord.ExitTime__c) {
                        const rawDateTime = new Date(modifiedRecord.ExitTime__c);
                        if (!isNaN(rawDateTime.getTime())) { // Check if the date is valid
                            const formattedDate1 = formattedDateTimeWithSeconds(rawDateTime); 
                            const dateOfIntiation1 = `${formattedDate1}`;
                            modifiedRecord.ExitTime__c = dateOfIntiation1;
                        }
                    }
                    return modifiedRecord; // Return the modified record
                });
            }
           
           
        }
        if(error){
            console.error(error);
            this.error = error;
        }
    }
  }