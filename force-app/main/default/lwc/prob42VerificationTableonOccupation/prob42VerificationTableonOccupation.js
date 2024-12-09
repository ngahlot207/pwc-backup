import { LightningElement, api, track, wire } from 'lwc';
//Apex Methods
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataWithoutCacheable';
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import { formattedDate } from 'c/dateUtility';
const verificationTypes = [
    { label: 'Successful', value: 'Successful' },
    { label: 'Failed', value: 'Failed' }
];
export default class ShowPanToGstDetails extends LightningElement {
    //@api loanAppId = 'a08C4000007x0uSIAQ';
    @api hasEditAccess;
    @track userId = Id;
    @track disableReintiate = false;
    @track isReadOnly;
    @track panToGstData = [];
    @track appData = [];
    @track showModal = false;
    @track apVerAppIds = [];
    @track panToGstFailedData = [];
    @track intRecords = [];
    @track loanApplStage;
    enableInfiniteScrolling = true;
    enableBatchLoading = true;
    @track showSpinner = false;
    @track isUWStage = false;
    @track employeeRole;
    @track employeeName;
    @track options = verificationTypes;
    @track appDataDisplay = [];


    @track currentDate ='';
    get currentdateSf(){
       return this.currentDate;
    }

    get disbaleMode() {
        return !this.hasEditAccess;
    }
    connectedCallback() {

        if (this.hasEditAccess === true || this.hasEditAccess === undefined) {
            this.isReadOnly = false;
        }
        else {
            this.isReadOnly = true;
        }
        //this.isReadOnly = false;
        this.disableReintiate = this.isReadOnly;
        this.getUserRole();
        //this.getApplicantsData();
        this.fetchDocuments();
        this.fetchReports();
        
        setTimeout(() => {
           
              this.getApplicantsData();
        }, 5000);

    }
    @track _loanAppId;
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);
        //this.handleRecordIdChange(value);
    }

    getUserRole() {
        let paramsLoanApp = {
            ParentObjectName: 'TeamHierarchy__c',
            parentObjFields: ['Id', 'EmpRole__c', 'Employee__c','Employee__r.name'],
            queryCriteria: ' where Employee__c = \'' + this.userId + '\' LIMIT 1'
        }
        getSobjectData({ params: paramsLoanApp })
            .then((result) => {
                console.log('result is get Role ==', JSON.stringify(result));
                if (result) {


                    result.forEach(item=> {
                    this.employeeRole = item.parentRecord.EmpRole__c;
                    console.log('item.parentRecord.Employee__r ==',item.parentRecord.Employee__r.Name)
                    if(item.parentRecord.Employee__r.Name){
                        this.employeeName = item.parentRecord.Employee__r.Name;
                        console.log('this.employeeName == ',this.employeeName)
                    }
                    
                    console.log('result employeeRole ', JSON.stringify(this.employeeRole));
                    if (this.employeeRole === 'UW') {
                        this.isUWStage = true;
                    }
                    })


                    
                }
            })
            .catch((error) => {

                this.showSpinner = false;
                console.log("error occured in employeeRole", error);

            });
    }

    triggerProbDetail(event) {
        this.showSpinner = true;
        let params = {
            ParentObjectName: 'Applicant__c',
            parentObjFields: ['Id', 'FullName__c', 'Constitution__c','RationalRemarks__c'],
            queryCriteria: ' where Id = \'' + event.target.dataset.id + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Applicants Data is ', JSON.stringify(result));
                if (result && result[0].parentRecord) {
                    let filteredData = [];
                    filteredData.push(result[0].parentRecord);
                    this.createIntMsgProbDetail(filteredData);
                }
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getApplicantsData Data is ', error);
            });
    }

    handleFetch(event) {
        this.fetchDocuments();
        this.fetchReports();
    }

    @track showModalForFilePre = false;
    @track docData = new Map();
    @track docDataReport = new Map();
    @track documentDetailId;
    @track documentDetailIdReport;
    @track hasDocumentId;
    
    
    fetchDocuments() {
        let category = 'Probe42 Documents';
        let docSubType = ['Articles of Association/Memorandum of Association Probe','Certificate of Incorporation Probe']
        let docType = ['LLP Document', 'Company Document'];

        let docDetParams = {
            ParentObjectName: "DocDtl__c",
            ChildObjectRelName: "",
            parentObjFields: [
                "Id", "Name", "LAN__c", "DocTyp__c", "DocCatgry__c", "Appl__c", "DocSubTyp__c", "IsLatest__c"
            ],
            childObjFields: [],
            queryCriteria: ' where LAN__c =\'' + this._loanAppId + '\' AND IsLatest__c= true \ AND DocCatgry__c=\'' + category + '\' AND DocTyp__c  IN  (\'' + docType.join('\', \'') + '\') ' + '\ AND DocSubTyp__c  IN  (\'' + docSubType.join('\', \'') + '\')  ' + '\ Order by  CreatedDate  '
        }
        console.log('docDetParams Documents : ', docDetParams);
        getSobjectDataNonCacheable({ params: docDetParams }).then((result) => {
            this.showSpinner = false;
            console.log("Probe 42 DOCUMENT DETAILS #168", JSON.stringify(result));
            if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
                let docData = JSON.parse(JSON.stringify(result.parentRecords));
                // let docMap = new Map();
                docData.forEach(element => {
                    this.docData.set(element.Appl__c, element.Id);
                });
                // this.docData = docMap;
                console.log("Probe 42 DOCUMENT DETAILS #106 fetchDocuments  : ", this.docData);
                // this.documentDetailId = docDetId;
                // this.hasDocumentId = true;
            }


        })
            .catch((error) => {
                this.showSpinner = false;
                console.log("RCU Details DOCUMENT DETAILS #594", error);
            });
    }

    fetchReports() {
        let category = 'Probe42 Documents';
        let docSubType = ['LLP Comprehensive Report Probe', 'Company Comprehensive Report Probe'];
        let docType = ['LLP Report', 'Company Report'];

        let docDetParams = {
            ParentObjectName: "DocDtl__c",
            ChildObjectRelName: "",
            parentObjFields: [
                "Id", "Name", "LAN__c", "DocTyp__c", "DocCatgry__c", "Appl__c", "DocSubTyp__c", "IsLatest__c"
            ],
            childObjFields: [],
            queryCriteria: ' where LAN__c =\'' + this._loanAppId + '\' AND IsLatest__c= true \ AND DocCatgry__c=\'' + category + '\' AND DocTyp__c  IN  (\'' + docType.join('\', \'') + '\') ' + '\ AND DocSubTyp__c  IN  (\'' + docSubType.join('\', \'') + '\')  ' + '\ Order by  CreatedDate  '
        }
        console.log('docDetParams  Report : ', docDetParams);
        getSobjectDataNonCacheable({ params: docDetParams }).then((result) => {
            this.showSpinner = false;
            console.log("Probe 42 DOCUMENT DETAILS #206", JSON.stringify(result));
            if (result.parentRecords !== undefined && result.parentRecords.length > 0) {
                let docData = JSON.parse(JSON.stringify(result.parentRecords));
                // let docMap = new Map();
                docData.forEach(element => {
                    this.docDataReport.set(element.Appl__c, element.Id);
                });
                console.log("Probe 42 DOCUMENT DETAILS #106 fetchReports : ", this.docDataReport);
            }
            
            this.showSpinner = false;

        })
            .catch((error) => {
                this.showSpinner = false;
                console.log("RCU Details DOCUMENT DETAILS #594", error);
            });
    }

    handleCloseModalEvent(event) {
        this.showModalForReportPre = false;
        this.showModalForFilePre = false;
    }
    @track recForPrev = '';
    @track recForPrevReport = '';
    @track handlePriveClick = false;
    @track handlePriveClickReport  = false;
    handlePreview(event) {
        console.log('record handle preview is ::', event.target.dataset.id);
        console.log('dataset name :',event.target.dataset.label)
        let selectedRecordId = event.target.dataset.id;
        let selectedRecordLabel = event.target.dataset.label;

        if(selectedRecordLabel === 'Detailed Probe 42 Report'){
            this.recForPrevReport = selectedRecordId;
            this.handlePriveClickReport = true;   
        }
        else if(selectedRecordLabel === 'Detailed Probe 42 Document'){
            this.recForPrev = selectedRecordId;
            this.handlePriveClick = true;   
        }
        
        
        
        this.handleRefreshClick();
    }
    @track showModalForReportPre = false;
    @track hasDocumentIdReport = false;


    showPreview(event) {
        let selectedRecordId = event;
        if (selectedRecordId) {
            this.documentDetailId = this.docData.get(selectedRecordId);
            this.showModalForFilePre = true;
            this.showModalForReportPre = false; // Ensure only one modal is shown
            this.hasDocumentId = true;
        }
        this.handlePriveClick = false;  // Reset after use
    }
    
    showPreviewReport(event) {
        let selectedRecordId = event;
        if (selectedRecordId) {
            this.documentDetailIdReport = this.docDataReport.get(selectedRecordId);
            this.showModalForReportPre = true;
            this.showModalForFilePre = false;  // Ensure only one modal is shown
            this.hasDocumentIdReport = true;
        }
        this.handlePriveClickReport = false;  // Reset after use
    }
    

    showSaveButton = false;
    getApplicantsData() {
        this.appData=[];
        let appTypes = ['P', 'C', 'G'];
        let constitutionType =['PROPERITORSHIP','LIMITED LIABILITY PARTNERSHIP','PRIVATE LIMITED COMPANY','PUBLIC LIMITED COMPANY','PARTNERSHIP'];

        this.showSpinner = true;
        let params = {
            ParentObjectName: 'Applicant__c',
            parentObjFields: ['Id', 'FullName__c', 'Constitution__c','RationalRemarks__c'],
            queryCriteria: ' where LoanAppln__c = \'' + this.loanAppId + '\' AND ApplType__c  IN (\'' + appTypes.join('\', \'') + '\')  AND Constitution__c IN (\'' + constitutionType.join('\', \'') + '\')'
        } 
        let existingIds = new Set();
        getSobjectData({ params: params })
            .then((result) => {
                console.log('Applicants Data is this===', JSON.stringify(result));
                console.log('result.parentRecords ===',result)
                if (result) {
                    result.forEach(item => {
                        // Check if the Id is already in the Set
                        if (!existingIds.has(item.parentRecord.Id)) {
                            // Add the Id to the Set and push the applicant data
                            existingIds.add(item.parentRecord.Id);
                            this.appData.push(item.parentRecord);
                        } else {
                            console.log(`Duplicate Applicant Id found: ${item.parentRecord.Id}`);
                        }
                    });

                }
                this.getProbeDetails();
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getApplicantsData Data is ', error);
            });
    }
    parentRecords = [];
    childRecords = [];
    get appliDisplayFlag(){
        console.log('get this.disFlagProbe ==',this.disFlagProbe)
        return (this.disFlagProbe) ;
     
    }

    get disableFlagFinal(){
        console.log('get final appliDisplayFlag ==',this.appliDisplayFlag)
        console.log('get final this.isReadOnly  ==',this.isReadOnly )
        return  (this.appliDisplayFlag && !this.isReadOnly)
    }


    @track disFlagProbe = true;



    getProbeDetails() {
        this.parentRecords = [];
        this.childRecords = [];
        let isprob42 = 'Probe42';
        let params = {
            ParentObjectName: 'APIVer__c',
            ChildObjectRelName: 'API_Verification_Details__r',
            parentObjFields: ['Id','Type__c', 'Invalid__c', 'Appl__c', 'Appl__r.CompanyName__c', 'Appl__r.FullName__c', 'toLabel(Appl__r.ApplType__c)', 'Appl__r.Constitution__c', 'Appl__r.PAN__c', 'Name_Match_Score__c', 'Classification__c', 'DataStatus__c', 'EfilingStatus__c', 'DteOfIncorp__c', 'AuthorizedCapital__c', 'PaidupCapital__c', 'Verification_Status__c', 'IntegrationErrorMessage__c','RetriggerRationale__c', 'Address__c', 'PanCinDin__c', 'Llpin__c', 'IntegrationStatus__c', 'UW_Manual_Verification__c','ActionedDate__c','UserName__c','UserNameRole__c' ],
            childObjFields: ['Id', 'APIVerification__r.Appl__r.CompanyName__c', 'Pan__c', 'Type__c', 'Designation__c', 'DateOfAppointment__c', 'AuthSignName__c', 'DirectNwName__c'],
            queryCriteria: ' where LoanAplcn__c = \'' + this.loanAppId + '\' AND RecordType.Name = \'' + isprob42 + '\' AND IsLatest__c = true AND Type__c IN (\'Probe Basic Company\',\'Probe Basic LLP\',\'Probe Comprehensive Company\',\'Probe Comprehensive LLP\')'
        }
        getSobjectData({ params: params })
            .then((result) => {
                 this.parentRecords = [];
                this.childRecords = [];
                this.apVerAppIds =[];
                console.log('Api Verification Data is data is ::: ', JSON.stringify(result));
                if (result) {
                    this.panToGstData = result;
                    this.panToGstData.forEach(record => {
                        // Store parent record
                        this.parentRecords.push(JSON.parse(JSON.stringify(record.parentRecord)));

                        // Store child records
                        if (record.ChildReords && record.ChildReords.length > 0) {
                            record.ChildReords.forEach(rec => {
                                if (rec.Type__c === 'Directors' || rec.Type__c === 'Authorized Signatories') {
                                    this.childRecords.push(rec);
                                }
                            });
                            //this.childRecords = this.childRecords.concat(record.ChildReords);
                        }

                    });
                   /// console.log('parentRecords', JSON.stringify(this.parentRecords));
                    //console.log('childRecords', JSON.stringify(this.childRecords));
                    this.parentRecords.forEach(item => {
                        if (item.Appl__c) {
                            this.apVerAppIds.push(item);
                        }
                        if (item.IntegrationStatus__c == 'Success') {
                            item.disableManualVer = true;
                        } else {
                            item.disableManualVer = false;
                        }

                        if(item.Type__c === 'Probe Comprehensive Company' || item.Type__c === 'Probe Comprehensive LLP'){
                            item.showPreviewLogic = true;
                        }else{
                            item.showPreviewLogic = false;
                        }
                        // if(item.PanCinDin__c){
                        //     item.panLlpin = item.PanCinDin__c;
                        // }
                        // if(item.Llpin__c){
                        //     item.panLlpin = item.Llpin__c;
                        // }
                        if(item.IntegrationStatus__c === 'Failure'){
                            console.log('making false for : ',item)
                            this.disFlagProbe =false;
                        }
                    })
                    console.log(' this.parentRecords.  ::254 ', this.parentRecords);
                    if (this.parentRecords.length > 0) {
                        this.showSaveButton = true;
                    }
                    this.apVerAppIds = [...new Set(this.apVerAppIds)];
                this.checkReIntiateLogic();
                //this.fetchDocuments();
                //this.fetchReports();
                }
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Api Verification Data is ', error);
            });
    }
    checkReIntiateLogic() {
        this.appDataDisplay=[];
        console.log('this.appData ===',this.appData)
        let existingIds = new Set();
        // if (this.appData && this.appData.length > 0) {
        //     console.log('inside this.appData ', JSON.stringify(this.appData));
        //     this.appData.forEach(app => {
        //         if (this.apVerAppIds && this.apVerAppIds.length > 0 && this.apVerAppIds.includes(app.Id)) {
        //             console.log('inside this.apVerAppIds ', JSON.stringify(this.apVerAppIds));
        //             let tempArr = this.parentRecords.filter(item => item.Appl__c === app.Id);
        //             if (tempArr && tempArr.length > 0) {
        //                 console.log('tempArr ', JSON.stringify(tempArr));
        //                 tempArr.forEach(ite => {
        //                     if (ite.IntegrationStatus__c && ite.IntegrationStatus__c === 'Failure') {
        //                         this.appDataDisplay.push(app);
        //                     }
        //                 })
        //             }
        //         } else {
        //             this.appDataDisplay.push(app);
        //         }
        //     })
        // }

        if (this.appData && this.appData.length > 0) {
            console.log('inside this.appData ', JSON.stringify(this.appData));
            console.log('inside this.apVerAppIds ', JSON.stringify(this.apVerAppIds));
            this.appData.forEach(app => {
                // Check if the Id is already processed to avoid duplicates
                if (!existingIds.has(app.Id)) {
                    // Add the Id to the Set
                    existingIds.add(app.Id);
    
                    if (this.apVerAppIds && this.apVerAppIds.length > 0) {
                        console.log('inside Appl__c:: ', JSON.stringify(this.apVerAppIds));
                        
                        let tempArr = this.apVerAppIds.filter(item => item.Appl__c === app.Id);
                        console.log('tempArr:: ',JSON.stringify(tempArr))
                        if (tempArr && tempArr.length > 0) {
                            console.log('tempArr ', JSON.stringify(tempArr));
                            tempArr.forEach(ite => {
                                if (ite.IntegrationStatus__c && ite.IntegrationStatus__c === 'Failure') {
                                    this.appDataDisplay.push(app);
                                }
                            });
                        }
                    } else {
                        this.appDataDisplay.push(app);
                    }
                } else {
                    console.log(`Duplicate Applicant Id found: ${app.Id}`);
                }
            });
            console.log('this.appDataDisplay is===> 121: ', JSON.stringify(this.appDataDisplay));
            if(this.appDataDisplay && this.appDataDisplay.length > 0){
                this.disableReintiate = false;
                this.disFlagProbe =false;
            }
            else{
                this.disableReintiate = true;
                this.disFlagProbe =true;
            }
        }

        //console.log('this.appDataDisplay is===>', JSON.stringify(this.appDataDisplay));
        if (this.appDataDisplay && this.appDataDisplay.length > 0) {
            //this.disableReintiate = false;
        } else {
            //this.disableReintiate = true;
        }
        this.showSpinner = false;
    if(this.handlePriveClick === true){
        
        if (this.recForPrev) {
            console.log('this.recForPrev) ==',this.recForPrev)
            this.showPreview(this.recForPrev);
            this.recForPrev ='';
        }
    }
    if(this.handlePriveClickReport === true){

        if(this.recForPrevReport){
           // console.log('this.recForPrevReport ==',this.recForPrevReport)
            this.showPreviewReport(this.recForPrevReport);
            this.recForPrevReport='';
        }

        }
    }
    handleIntialization() {
        this.showModal = true;
    }
    // handleRefreshClick() {
    //     this.showSpinner = true;
    //     setTimeout(() => {
    //         this.fetchReports();
    //         this.fetchDocuments();
    //     this.getApplicantsData();
    //     }, 6000);
    //     console.log('after');
    // }

    handleRefreshClick() {
        this.showSpinner = true;
        Promise.all([this.fetchReports(), this.fetchDocuments(), this.getApplicantsData()])
           .then(() => {
               // Only after all data has been fetched should we handle modal display
               console.log('Data fetched successfully');
               this.showSpinner = false;
               // Handle modal logic here, if needed
           })
           .catch((error) => {
               console.error('Error fetching data', error);
               this.showSpinner = false;
           })
        //    .finally(() => {
        //        this.showSpinner = false;
        //    });
    }
    

    handlevSubmit() {
        this.showSpinner = true;
        let filterdData = this.parentRecords;
        console.log('filterdData is =========>', JSON.stringify(filterdData));
        upsertMultipleRecord({ params: filterdData })
            .then((result) => {
                console.log('Result after creating Int Msgs is ', JSON.stringify(result));
                this.showSpinner = false;
                this.showToastMessage('Success', 'Verification Data Saved Successful!', 'success', 'sticky');

            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In creating Record', error);
            });
    }

    handleClick(event) {
        console.log('record ', event.target.dataset.recordid);
        let selectedRecordId = event.target.dataset.recordid;
        console.log('value is', event.target.checked);
        console.log('All selected Records before ', this.appDataDisplay);
        let val = event.target.checked;
        let recordData = {};
        let searchDoc = this.appDataDisplay.find((doc) => doc.Id === selectedRecordId);
        if (searchDoc) {
            console.log('searchDoc', searchDoc);
            //searchDoc = { ...searchDoc, selectCheckbox: val }
            searchDoc['selectCheckbox'] = val;
        }
        else {
            recordData['Id'] = selectedRecordId;
            recordData['selectCheckbox'] = val;
            this.appDataDisplay.push(recordData);
        }
        console.log('All selected Records', this.appDataDisplay);
    }
    closeModal() {
        this.showModal = false;
        this.recForPrev = '';
        this.recForPrevReport ='';
    }

    handleChange(event) {
        let val = event.detail.val;
        let appRecordId = event.detail.recordid;
        let nameVal = event.detail.nameVal;
        // let appRecordId = event.target.dataset.recordid;
        // let nameVal = event.target.name;
        console.log('val is ', val, 'watchOutRecordId is ', appRecordId, ' name is ', nameVal);
        let obj = this.parentRecords.find(item => item.Id === appRecordId);
        if (obj) {
            console.log('obj is ', JSON.stringify(obj));
            obj[nameVal] = val;
            obj['isChanged'] = true;
            //this.callEnpaMethod();
        }
    }

    handleReIntialization() {
        this.currentDate= formattedDate(new Date());
        this.showModal = false;
        this.showSpinner = true;
        let filteredData = this.appDataDisplay.filter(item => item.selectCheckbox === true);
        console.log('All filteredData Records', JSON.stringify(filteredData));
        if (filteredData.length > 0) {
            this.createIntMsg(filteredData);
        } else {
            this.showToastMessage('Error', 'Please Select Applicant to Re-Initiate', 'Error', 'sticky');
            this.showSpinner = false;
        }
    }
    @track serviceName;
    createIntMsg(appIds) {
        appIds.forEach(item => {
            if (item.Constitution__c === 'PROPERITORSHIP' || item.Constitution__c === 'LIMITED LIABILITY PARTNERSHIP') {
                this.serviceName = 'LLP Base Details';
            }
            else {
                this.serviceName = 'Company Base Details';
            }
            let fields = {};
            fields['sobjectType'] = 'IntgMsg__c';
            fields['Name'] = this.serviceName;
            fields['BU__c'] = 'HL / STL';
            fields['IsActive__c'] = true;
            fields['Svc__c'] = this.serviceName;
            fields['Status__c'] = 'New';
            fields['Mresp__c'] = 'Blank';
            fields['Trigger_Platform_Event__c'] = false;
            fields['RefObj__c'] = 'Applicant__c';
            fields['RefId__c'] = item.Id;
            fields['ParentRefObj__c'] = "LoanAppl__c";
            fields['ParentRefId__c'] = this.loanAppId;

            fields['RetriRatinal__c'] = this.rationalValue;
           // fields['ActionedDate__c'] = System.now();
            fields['UserName__c'] = this.employeeName;
            fields['UserNameRole__c'] = this.employeeRole;

            this.intRecords.push(fields);
        })
        console.log('intRecords are', this.intRecords);
        this.upsertIntRecord(this.intRecords);
    }

    createIntMsgProbDetail(appIds) {
        appIds.forEach(item => {
            if (item.Constitution__c === 'PROPERITORSHIP' || item.Constitution__c === 'LIMITED LIABILITY PARTNERSHIP') {
                this.serviceName = 'LLP Comprehensive Details';
            }
            else {
                this.serviceName = 'Company Comprehensive Details';
            }
            let fields = {};
            fields['sobjectType'] = 'IntgMsg__c';
            fields['Name'] = this.serviceName;
            fields['BU__c'] = 'HL / STL';
            fields['IsActive__c'] = true;
            fields['Svc__c'] = this.serviceName;
            fields['Status__c'] = 'New';
            fields['Mresp__c'] = 'Blank';
            fields['Trigger_Platform_Event__c'] = false;
            fields['RefObj__c'] = 'Applicant__c';
            fields['RefId__c'] = item.Id;
            fields['ParentRefObj__c'] = "LoanAppl__c";
            fields['ParentRefId__c'] = this.loanAppId;
            fields['RetriRatinal__c'] = this.rationalValue;
            
          //  fields['ActionedDate__c'] = System.now();
            fields['UserName__c'] = this.employeeName;
            fields['UserNameRole__c'] = this.employeeRole;
            this.intRecords.push(fields);
        })
        console.log('intRecords are', this.intRecords);
        this.upsertIntRecord(this.intRecords);
    }
    @track intMsgIds = [];
    upsertIntRecord(intRecords) {
        console.log('int msgs records ', JSON.stringify(intRecords));
        upsertMultipleRecord({ params: intRecords })
            .then((result) => {
                console.log('Result after creating Int Msgs is ', JSON.stringify(result));
                result.forEach(item => {
                    this.intMsgIds.push(item.Id);
                })
                this.showToastMessage('Success', 'Initiated Successfully, Please Click on Refresh Button to See Details on Table', 'Success', 'sticky')
                console.log('intMsgIds after creating Int Msgs is ', JSON.stringify(this.intMsgIds));
                this.intRecords = [];
                this.rationalValue= '';
                this.showSpinner = false;
            })
            .catch((error) => {
                console.log('Error In creating Record', error);
                this.showSpinner = false;
            });
    }
    showToastMessage(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant,
            mode
        });
        this.dispatchEvent(evt);
    }

    @track rationalValue= '';
    handleRationalChange(event){
        this.rationalValue=event.target.value;


    }
    //******************FOR HANDLING THE HORIZONTAL SCROLL OF TABLE MANUALLY******************//
    tableOuterDivScrolled(event) {
        this._tableViewInnerDiv = this.template.querySelector(".tableViewInnerDiv");
        if (this._tableViewInnerDiv) {
            if (!this._tableViewInnerDivOffsetWidth || this._tableViewInnerDivOffsetWidth === 0) {
                this._tableViewInnerDivOffsetWidth = this._tableViewInnerDiv.offsetWidth;
            }
            this._tableViewInnerDiv.style = 'width:' + (event.currentTarget.scrollLeft + this._tableViewInnerDivOffsetWidth) + "px;" + this.tableBodyStyle;
        }
        this.tableScrolled(event);
    }

    tableScrolled(event) {
        if (this.enableInfiniteScrolling) {
            if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
                this.dispatchEvent(new CustomEvent('showmorerecords', {
                    bubbles: true
                }));
            }
        }
        if (this.enableBatchLoading) {
            if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
                this.dispatchEvent(new CustomEvent('shownextbatch', {
                    bubbles: true
                }));
            }
        }
    }

    //******************************* RESIZABLE COLUMNS *************************************//
    handlemouseup(e) {
        this._tableThColumn = undefined;
        this._tableThInnerDiv = undefined;
        this._pageX = undefined;
        this._tableThWidth = undefined;
    }

    handlemousedown(e) {
        if (!this._initWidths) {
            this._initWidths = [];
            let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
            tableThs.forEach(th => {
                this._initWidths.push(th.style.width);
            });
        }

        this._tableThColumn = e.target.parentElement;
        this._tableThInnerDiv = e.target.parentElement;
        while (this._tableThColumn.tagName !== "TH") {
            this._tableThColumn = this._tableThColumn.parentNode;
        }
        while (!this._tableThInnerDiv.className.includes("slds-cell-fixed")) {
            this._tableThInnerDiv = this._tableThInnerDiv.parentNode;
        }
        console.log("handlemousedown._tableThColumn.tagName => ", this._tableThColumn.tagName);
        this._pageX = e.pageX;

        this._padding = this.paddingDiff(this._tableThColumn);

        this._tableThWidth = this._tableThColumn.offsetWidth - this._padding;
        console.log("handlemousedown._tableThColumn.tagName => ", this._tableThColumn.tagName);
    }

    handlemousemove(e) {
        console.log("mousemove._tableThColumn => ", this._tableThColumn);
        if (this._tableThColumn && this._tableThColumn.tagName === "TH") {
            this._diffX = e.pageX - this._pageX;

            this.template.querySelector("table").style.width = (this.template.querySelector("table") - (this._diffX)) + 'px';

            this._tableThColumn.style.width = (this._tableThWidth + this._diffX) + 'px';
            this._tableThInnerDiv.style.width = this._tableThColumn.style.width;

            let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
            let tableBodyRows = this.template.querySelectorAll("table tbody tr");
            let tableBodyTds = this.template.querySelectorAll("table tbody .dv-dynamic-width");
            tableBodyRows.forEach(row => {
                let rowTds = row.querySelectorAll(".dv-dynamic-width");
                rowTds.forEach((td, ind) => {
                    rowTds[ind].style.width = tableThs[ind].style.width;
                });
            });
        }
    }

    handledblclickresizable() {
        let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
        let tableBodyRows = this.template.querySelectorAll("table tbody tr");
        tableThs.forEach((th, ind) => {
            th.style.width = this._initWidths[ind];
            th.querySelector(".slds-cell-fixed").style.width = this._initWidths[ind];
        });
        tableBodyRows.forEach(row => {
            let rowTds = row.querySelectorAll(".dv-dynamic-width");
            rowTds.forEach((td, ind) => {
                rowTds[ind].style.width = this._initWidths[ind];
            });
        });
    }

    paddingDiff(col) {

        if (this.getStyleVal(col, 'box-sizing') === 'border-box') {
            return 0;
        }

        this._padLeft = this.getStyleVal(col, 'padding-left');
        this._padRight = this.getStyleVal(col, 'padding-right');
        return (parseInt(this._padLeft, 10) + parseInt(this._padRight, 10));

    }

    getStyleVal(elm, css) {
        return (window.getComputedStyle(elm, null).getPropertyValue(css))
    }
}