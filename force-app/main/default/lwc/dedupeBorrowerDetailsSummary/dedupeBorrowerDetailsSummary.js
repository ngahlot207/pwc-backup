import { LightningElement, track, api,wire } from 'lwc';

import getBorrowerDetails from '@salesforce/apex/ObligationDetailsSummaryController.getBorrowerDetails';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';

export default class DedupeBorrowerDetailsSummary extends LightningElement {

    //modified 
    @track borowerTypeName;
    @track listBorrowerDetails =[];
    //@api recordId;
    @wire(getBorrowerDetails,{ recordId: '$recordId'})
    wiredgetBorrowerDetails({ data, error }) {
       // console.log('Yesssssss-->');
        if (data) {
          //  console.log('dataYsssssss-->'+JSON.stringify(data));
            this.listBorrowerDetails = data;
            console.log('listBorrowerDetails-->'+JSON.stringify(this.listBorrowerDetails));
           
            
        } else if (error) {
            console.error('Error loading Borrower Details: ', error);
        }
    }

    @track _recordId
    @api get recordId() {
        return this._recordId;
    }
            //@api loanAppId;
    set recordId(value) {
    this._recordId = value;
    this.setAttribute("recordId", value);
    console.log('RecordId ##1 ::::>>>>',value);
    this.handleRecordIdChange(value);
    }

    handleRecordIdChange(){
        
        let tempParams = this.Params;
        tempParams.queryCriteria = ' where Id= \''+this.recordId+'\'';
        this.Params = { ...tempParams };
        console.log('RecordId ::::>>>>',this._recordId);

        let tempParams1 = this.addParams;
        tempParams1.queryCriteria = ' where Applicant__c= \''+this.recordId+'\'';
        this.addParams = { ...tempParams1 };
        console.log('RecordId ::::>>>>',this._recordId);
    }

    @track Params = {
        ParentObjectName: 'Applicant__c',
        ChildObjectRelName: '',
        parentObjFields: ['id','FullName__c','CustProfile__c','DOB__c', 'Gender__c', 'PAN__c', 'ID_proof_type__c', 'ID_Number__c','Father_Name__c', 'Relationship__c'],
        childObjFields: [],
        queryCriteria: ' where Id= \''+this.recordId+'\''
    }


    borrwerName;
    customerSegment;
    gender;
    pan;
    idprof;
    idtype;
    fatherName;

    dob;
    relationwithAppl;
    decsionDate;

    wiredCDataResult;
    appData
    @wire(getSobjectData, { params: '$Params' })
    handleCaseData(wiredCaseData) {

        let { error, data } = wiredCaseData;
        this.wiredCDataResult = wiredCaseData;
        if(data){
            this.appData = data;
            console.log('Data FullName ',JSON.stringify(this.appData));


            console.log('Data Id Number ',data.parentRecords[0].FullName__c);
            this.borrwerName = data.parentRecords[0].FullName__c?data.parentRecords[0].FullName__c:'';
            this.customerSegment = data.parentRecords[0].CustProfile__c?data.parentRecords[0].CustProfile__c:'';
            this.dob = data.parentRecords[0].DOB__c?data.parentRecords[0].DOB__c:'';
            
            this.gender = data.parentRecords[0].Gender__c?data.parentRecords[0].Gender__c:'';
            this.pan = data.parentRecords[0].PAN__c?data.parentRecords[0].PAN__c:'';
            this.idtype = data.parentRecords[0].ID_Number__c?data.parentRecords[0].ID_Number__c:'';
            
            this.idprof= data.parentRecords[0].ID_proof_type__c?data.parentRecords[0].ID_proof_type__c:'';
            this.fatherName = data.parentRecords[0].Father_Name__c?data.parentRecords[0].Father_Name__c:'';
            this.relationwithAppl = data.parentRecords[0].Relationship__c?data.parentRecords[0].Relationship__c:'';
            //this.decsionDate = data.parentRecords[0].Decision_Date__c?data.parentRecords[0].Decision_Date__c:'';


        }
    }



    @track addParams = {
        ParentObjectName: 'ApplAddr__c',
        ChildObjectRelName: '',
        parentObjFields: ['id','AddrTyp__c','HouseNo__c', 'AddrLine1__c', 'AddrLine2__c', 'Landmark__c', 'Locality__c', 'Pincode__c', 'City__c', 'State__c'],
        childObjFields: [],
        queryCriteria: ' where Applicant__c= \''+this.recordId+'\''
    }


    house;
    addLine1;
    addLine2;
    Lndmark;
    locality;
    pincode;
    city;
    state;

    wiredaddData;
    appAddData;
    appAddparentRecordsData;
    conslodiateparentRecords;
    @wire(getSobjectData, { params: '$addParams' })
    handleappAddData(wiredappAddData) {

        let { error, data } = wiredappAddData;
        this.wiredaddData = wiredappAddData;
        if(data){
            this.appAddData = data;
            console.log('this.appAddData',JSON.stringify(this.appAddData))
            this.listBorrowerDetails = data;
            console.log('listBorrowerAddDetails-->'+JSON.stringify(this.listBorrowerDetails));

            if(data.parentRecords){
                this.appAddparentRecordsData = data.parentRecords;

                this.conslodiateparentRecords = this.appAddparentRecordsData.map(record => {
                    return {
                        ...record,
                        consolidatedAddress: `${record.HouseNo__c || ''} ${record.AddrLine1__c || ''} ${record.AddrLine2__c || ''}, ${record.Landmark__c?record.Landmark__c+', ':'' || ''} ${record.Locality__c?record.Locality__c+', ':'' || ''} ${record.City__c || ''} - ${record.Pincode__c || ''}, ${record.State__c || ''}`
                    };
                });
            }

        }
    }
}