import { LightningElement, api, wire, track } from 'lwc';

//ui methods to get record detials
import { getRecord, deleteRecord, getRecords } from 'lightning/uiRecordApi';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';

//Apex Methods
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import deleteIncomeRecord from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';

//To Get Current user
import { CurrentPageReference } from 'lightning/navigation';


import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const fields = ['User.Name'];
export default class CaptureApplicantComments extends LightningElement {

    //public property
    @api layoutSize;
    @api hasEditAccess;
    @api applicantId;
    @api loanAppId = 'a08C40000084NJBIA2';
    //@api applicantIdOnTabset;
    @api isCpa;

    @track _applicantIdOnTabset = 'a0AC4000000JaqzMAC';
    @api get applicantIdOnTabset() {
        return this._applicantIdOnTabset;
    }
    set applicantIdOnTabset(value) {
        // this._applicantIdOnTabset = value;
        // this.setAttribute("applicantId", value);

        // this.handleRecordIdChange(value);
    }


    @track applCommentsArrVarible = false;
    @track applCommentsArr=[];

    // applicantCommentRecords;
    // @wire(getRelatedListRecords, {
    //     parentRecordId: '$applicantIdOnTabset',
    //     relatedListId: 'Application_Comments__r',
    //     fields: ['ApplicationComments__c.Id', 'ApplicationComments__c.Name', 'ApplicationComments__c.CreatedById','ApplicationComments__c.Comments__c' ],
    // }) applicantComments(value){
    //     this.applicantCommentRecords = value;
    //     console.log(this.applicantIdOnTabset);
    //     let {error, data} = value;

    //     if(data){
    //         console.log('data--------->' + JSON.stringify(data));
    //     }
    //     else if(error){
    //         console.log('Error occured while fetching applicant Commnets ' + JSON.stringify(error));
    //     }

    // }

     
    @track
    Incomeparams = {
        ParentObjectName: 'ApplicationComments__c ',
        ChildObjectRelName: '',
        parentObjFields: ['Id', 'Name', 'Comments__c','CreatedById','Underwriter_Name__c'],
        childObjFields: [],
        queryCriteria: ' where Applicant__c = \'' + this._applicantIdOnTabset + '\'' + ' AND Applicant__c!=null'
    }

    handleRecordIdChange(event) {
        let tempParams = this.Incomeparams;
        tempParams.queryCriteria = ' where Applicant__c = \'' + this._applicantIdOnTabset + '\'' + ' AND Applicant__c!=null';
        this.Incomeparams = { ...tempParams };
    }

    @wire(getSobjectData, { params: '$Incomeparams' })
    commoentResponse(wiredResult) {

        let { error, data } = wiredResult;
        console.log('wiredResult---------->',JSON.stringify(wiredResult));
         this.wiredData = wiredResult;
        if (data) {
            this.commentsRecord = data.parentRecords;
            this.handleCommentsRecords();
            console.log('in wire Comments available----->' + JSON.stringify(this.commentsRecord ));

        } else if (error) {
            console.error('Error Team ------------->', error);
        }
        console.log('applCommentsArr length ----->', this.applCommentsArr.length);
    

    }

    handleCommentsRecords() {
        if (this.commentsRecord && this.commentsRecord.length > 0) {
            this.applCommentsArr = [];
            this.commentsRecord.forEach(newItem => {
                let tempObj = {
                    Name : newItem.Name ? newItem.Name : '',
                    Comments__c: newItem.Comments__c ? newItem.Comments__c : '',
                    CreatedById: newItem.CreatedById ? newItem.CreatedById : '',
                    Underwriter_Name__c : newItem.Underwriter_Name__c ? newItem.Underwriter_Name__c : ''
                };
              
                this.applCommentsArr.push(tempObj);
               
            });
            console.log(' this.applCommentsArr =====>',JSON.stringify( this.applCommentsArr));

        }
        else {
            console.log('commentsRecord Not Available');

        }
    }

    @wire(CurrentPageReference) pageRef;

    @wire(getRecord, { recordId: '$pageRef.attributes.userId', fields })
    user;

    get userName() {
        return this.user.data ? this.user.data.fields.Name.value : 'N/A';
    }

    showToastMessage(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant,
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
    }

    @track userComment;
    
    handleInputChange(event){
    if (event.target.dataset.fieldname === "Comments__c") {
      let  tempUserComment = event.target.value;
      this.userComment = tempUserComment.toUpperCase();

        }
    }

    addApplicantComments(){
        console.log('appl Comments Arr For User Name -------->');
        console.log('appl Comments Arr For User Name -------->',this.userComment);
        console.log('User Name -------->',userName);
        if(this.userComment ){
            console.log('appl Comments Arr For User Name Inside if-------->');
            this.applCommentsArr.push({
                Comments__c: this.userComment,
                sobjectType: 'ApplicationComments__c',
               // Underwriter_Name__c: userName
            });
            console.log('appl Comments Arr For User Name -------->',JSON.stringify(this.applCommentsArr));
        }
    }

    @api handleUpsert(event){
        this.showSpinner = true;
        if(this.applCommentsArr && this.applCommentsArr.length > 0 ){
           this.applicantDetails = {
                    LoanAppl__c: this.loanAppId,
                    Id: this._applicantIdOnTabset,
                    sobjectType: 'Applicant__c'
                };
    
                console.log('this applicantDetails -------->' + JSON.stringify(this.applicantDetails));
    
                let upsertData = {
                    parentRecord: this.applicantDetails,
                    ChildRecords: this.applCommentsArr,
                    ParentFieldNameToUpdate: 'Applicant__c'
                }
                console.log('comments data 135 --------->', JSON.stringify(upsertData));
                upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
                    .then(result => {
                        this.showToastMessage("Success", 'Comment Save Successfully', "success", "sticky");
                        this.showSpinner = false;
                    })
                    .catch(error => {
                        console.error(error)
                        console.log('upsert error -', JSON.stringify(error));
                        this.showToastMessage("Error In Upsert Record ", error.body.message, "error", "sticky");
                        this.showSpinner = false;
                    })
            }else{
                this.showSpinner = false;
            }
        }
    
        }