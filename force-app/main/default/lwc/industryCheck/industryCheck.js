import { LightningElement,wire , api,track } from 'lwc';
import { updateRecord } from "lightning/uiRecordApi";
import getDataAll from '@salesforce/apex/SObjectDynamicRecordProvider.getAllSobjectDatawithRelatedRecords';
import getData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import FinalIndustryForRBI from '@salesforce/schema/LoanAppl__c.Final_Industry_for_RBI__c';
import FinalMSMECategorization from '@salesforce/schema/LoanAppl__c.Final_MSME__c';
import loanID from '@salesforce/schema/LoanAppl__c.Id';
import Loan_OBJECT from "@salesforce/schema/LoanAppl__c";
import { refreshApex } from '@salesforce/apex';

export default class MsmeCheck extends LightningElement {
   
    @api isReadOnly;
    @track disableMode;
    @api hasEditAccess;
    @api layoutSize;   
    AppParentRecord=[]
    LoanChildRecord=[]
    EmpParentRecord=[]
    EmpChildRecord=[]
    @track MSMERecords = []
    @track RBIRecords = []
    idRBI =[]
    @track RBIrecordsIDS
    @track MSMErecordsIDS
    @track RBIresult
    @track finalRBIResult
    @track finalMSMEResult
    @track _wiredLoanApplData
    @track _wiredLoanEmpData
    @track _wiredData
    @track _loanAppId;
    //loanAppId='a08C4000006afh7IAA';
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        console.log('Loan App Id ! '+value);
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);            
        this.handleRecordIdChange(value);        
    }

    handleRecordIdChange(){      
    
        let tempParamsLoan = this.loanAppParam;
        tempParamsLoan.queryCriteria = ' where id = \'' + this.loanAppId + '\'';
        this.loanAppParam = {...tempParamsLoan};
        
    }


//  fetching Loan and applicant details
    @track loanAppParam={
        ParentObjectName:'LoanAppl__c',
        ChildObjectRelName:'Applicants__r',
        parentObjFields:['Id','Stage__c'],
        childObjFields:['Type_of_Borrower__c ','Constitution__c','Id','ApplType__c','CustProfile__c','CompanyName__c','FullName__c'],        
        queryCriteria: ' where id= \'' + this.loanAppId + '\''

    }

    @wire(getDataAll,{params:'$loanAppParam'})
    loanData(wiredLoanApplData) {
        console.log(' Loan id in child comp' ,this.loanAppId);
        const { data, error } = wiredLoanApplData;
        this._wiredLoanApplData = wiredLoanApplData;
        if (data) {
            if(data[0].parentRecord!=undefined){
             this.LoanParentRecord=JSON.parse(JSON.stringify(data[0].parentRecord));    
            }
             if(data[0].ChildReords!=undefined ){        
            this.LoanChildRecord=JSON.parse(JSON.stringify(data[0].ChildReords));

            for(var i=0;i< this.LoanChildRecord.length;i++){
                
                this.idRBI.push(this.LoanChildRecord[i].Id);               
                
            }
            let stringRBI =JSON.stringify(this.idRBI);
               this.RBIrecordsIDS = stringRBI.replaceAll('[', '(')
                                             .replaceAll(']', ')')
                                             .replaceAll('"', '\'');

                this.MSMErecordsIDS=this.RBIrecordsIDS;

            let tempParams = this.loanEmpParam;
            tempParams.queryCriteria = ' where id IN ' +this.RBIrecordsIDS;
            this.loanEmpParam = {...tempParams};
          console.log('ids RBIrecordsIDS',this.RBIrecordsIDS);

            // let tempAppParams = this.loanAppEmpParam;
            // tempAppParams.queryCriteria = ' where id IN ' +this.MSMErecordsIDS;
            // this.loanAppEmpParam = {...tempAppParams};
            // console.log('ids msmerecordIds2',this.MSMErecordsIDS);

            
         } 
        } else if (error) {
            console.log(error);
        }
    }
//MSME data

//     @track loanAppEmpParam={
//         ParentObjectName:'Applicant__c',
//         ChildObjectRelName:'Applicant_Employments__r',
//         parentObjFields:['MSME_Type__c','MSME__c','Annual_Turnover__c','Investment_in_Plant_and_Machinery__c','Type_of_Borrower__c ','Constitution__c','Id','ApplType__c','CustProfile__c','CompanyName__c','FullName__c','TotalIncome__c','LoanAppln__r.Final_MSME__c'],
//         childObjFields:['Proprietorship_firm_part_of_the_proposal__c','UdyamRegistrationNumber__c','DesignationValues__c','DesignationText__c','Id','MSME_Industry_selection__c'],        
//         queryCriteria:  ' where id IN ' +this.MSMErecordsIDS 
//     }

// @wire(getDataAll,{params:'$loanAppEmpParam'})
//     loanApplicationData(wiredData) {
//         const { data, error } = wiredData;
//         this._wiredData = wiredData;
//         if (data) {
//             this.AppParentRecord=JSON.parse(JSON.stringify(data)); 
//             for(var i=0;i< this.AppParentRecord.length;i++){
//                 let MSMERecordObj={}
//                     if(this.AppParentRecord[i].parentRecord.ApplType__c=='P' || 
//                     this.AppParentRecord[i].parentRecord.ApplType__c=='C'){   
                        
//                         if(this.AppParentRecord[i].parentRecord.Constitution__c!='INDIVIDUAL' || 
//                         this.AppParentRecord[i].parentRecord.CustProfile__c=='SELF EMPLOYED NON PROFESSIONAL' ||
//                         this.AppParentRecord[i].parentRecord.CustProfile__c=='SELF EMPLOYED PROFESSIONAL' ||
//                         ( this.AppParentRecord[i].parentRecord.Constitution__c=='PROPRIETORSHIP' && 
//                         this.AppParentRecord[i].parentRecord.Applicant_Employments__r[0].Proprietorship_firm_part_of_the_proposal__c=='No'))
//                                 {
//                                     MSMERecordObj.ApplType__c=this.AppParentRecord[i].parentRecord.ApplType__c;
//                                     MSMERecordObj.CustProfile__c=this.AppParentRecord[i].parentRecord.CustProfile__c;
//                                     MSMERecordObj.Constitution__c=this.AppParentRecord[i].parentRecord.Constitution__c;
//                                     MSMERecordObj.FullName__c=this.AppParentRecord[i].parentRecord.FullName__c;
//                                     MSMERecordObj.CompanyName__c=this.AppParentRecord[i].parentRecord.CompanyName__c;
                                   
//                                     if(this.AppParentRecord[i].parentRecord.CustProfile__c=='SALARIED')
//                                     {
//                                         MSMERecordObj.Des__c=this.AppParentRecord[i].parentRecord.Applicant_Employments__r[0].DesignationText__c;
                                      
//                                     }
//                                     if(this.AppParentRecord[i].parentRecord.CustProfile__c=!'SALARIED')
//                                     {
//                                         MSMERecordObj.Des__c=this.AppParentRecord[i].parentRecord.Applicant_Employments__r[0].DesignationValues__c;
                                      
//                                     }
                                    
//                                     MSMERecordObj.MSME_Industry_selection__c=this.AppParentRecord[i].parentRecord.Applicant_Employments__r[0].MSME_Industry_selection__c;
//                                     MSMERecordObj.UdyamRegistrationNumber__c=this.AppParentRecord[i].parentRecord.Applicant_Employments__r[0].UdyamRegistrationNumber__c;
                        
                                   
//                                     MSMERecordObj.Investment_in_Plant_and_Machinery__c=this.AppParentRecord[i].parentRecord.Investment_in_Plant_and_Machinery__c;
//                                     MSMERecordObj.Annual_Turnover__c=this.AppParentRecord[i].parentRecord.Annual_Turnover__c;
//                                     MSMERecordObj.MSME__c=this.AppParentRecord[i].parentRecord.MSME__c;
//                                     MSMERecordObj.MSME_Type__c=this.AppParentRecord[i].parentRecord.MSME_Type__c;
                                   
//                                     MSMERecordObj.Final_MSME__c=this.AppParentRecord[i].parentRecord.LoanAppln__r.Final_MSME__c;
//                                     this.finalMSMEResult=MSMERecordObj.Final_MSME__c;

//                                     this.MSMERecords.push(MSMERecordObj);  
//                                 }

//                     }
//             }
       


//         }
//         else if (error) {
//             console.log(error);
//         }
//     }




// RBI Data
   
    @track loanEmpParam={
        ParentObjectName:'Applicant__c',
        ChildObjectRelName:'Applicant_Employments__r',
        parentObjFields:['MSME_Type__c','MSME__c','Annual_Turnover__c','Investment_in_Plant_and_Machinery__c','Type_of_Borrower__c ','Constitution__c','Id','toLabel(ApplType__c)','CustProfile__c','CompanyName__c','FullName__c','TotalIncome__c','LoanAppln__r.Final_Industry_for_RBI__c','LoanAppln__r.Final_MSME__c'],
        childObjFields:['Proprietorship_firm_part_of_the_proposal__c','MSME_Industry_selection__c','UdyamRegistrationNumber__c','DesignationValues__c','DesignationText__c','Id','IndustryType__r.Name','SubIndustry__r.Name','MainRBIIndustry__c','IndustryForRBIReporting__r.Name'],        
        queryCriteria:  ' where id IN ' +this.RBIrecordsIDS 
    }

    @wire(getDataAll,{params:'$loanEmpParam'})
    loanEmpData(result) {
        //const { data, error } = wiredLoanEmpData;
        this._wiredLoanEmpData = result;
        if (result.data) {
           this.RBIRecords = []
           this.EmpParentRecord=[]
           // console.log("result of loan in emp data"+JSON.stringify(data))
            this.EmpParentRecord=result.data;            
            

           for(var i=0;i< this.EmpParentRecord.length;i++){
            let RBIRecordObj={}
            let MSMERecordObj={}
               

                    // if(this.EmpParentRecord[i].parentRecord.Constitution__c!='INDIVIDUAL' || 
                    //     this.EmpParentRecord[i].parentRecord.CustProfile__c=='SELF EMPLOYED NON PROFESSIONAL' ||
                    //     this.EmpParentRecord[i].parentRecord.CustProfile__c=='SELF EMPLOYED PROFESSIONAL' ||
                    //     ( this.EmpParentRecord[i].parentRecord.Constitution__c=='PROPRIETORSHIP' && 
                    //     this.EmpParentRecord[i].parentRecord.Applicant_Employments__r[0].Proprietorship_firm_part_of_the_proposal__c=='No'))
                    //             {
                    //                 MSMERecordObj.ApplType__c=this.EmpParentRecord[i].parentRecord.ApplType__c;
                    //                 MSMERecordObj.CustProfile__c=this.EmpParentRecord[i].parentRecord.CustProfile__c;
                    //                 MSMERecordObj.Constitution__c=this.EmpParentRecord[i].parentRecord.Constitution__c;
                    //                 MSMERecordObj.FullName__c=this.EmpParentRecord[i].parentRecord.FullName__c;
                    //                 MSMERecordObj.CompanyName__c=this.EmpParentRecord[i].parentRecord.CompanyName__c;

                    //                if(this.EmpParentRecord[i].parentRecord.Applicant_Employments__r){
                    //                 if(this.EmpParentRecord[i].parentRecord.CustProfile__c=='SALARIED')
                    //                 {
                    //                     MSMERecordObj.Des__c=this.EmpParentRecord[i].parentRecord.Applicant_Employments__r[0].DesignationText__c;
                                      
                    //                 }
                    //                 if(this.EmpParentRecord[i].parentRecord.CustProfile__c!='SALARIED')
                    //                 {
                    //                     MSMERecordObj.Des__c=this.EmpParentRecord[i].parentRecord.Applicant_Employments__r[0].DesignationValues__c;
                                      
                    //                 }
                    //                 if(this.EmpParentRecord[i].parentRecord.Applicant_Employments__r[0].MSME_Industry_selection__c){
                    //                     MSMERecordObj.MSME_Industry_selection__c=this.EmpParentRecord[i].parentRecord.Applicant_Employments__r[0].MSME_Industry_selection__c;
                                    
                    //                 }
                    //                 if(this.EmpParentRecord[i].parentRecord.Applicant_Employments__r[0].UdyamRegistrationNumber__c){
                    //                     MSMERecordObj.UdyamRegistrationNumber__c=this.EmpParentRecord[i].parentRecord.Applicant_Employments__r[0].UdyamRegistrationNumber__c;
                        
                    //                 }    
                    //             }                                
                                   
                    //                 MSMERecordObj.Investment_in_Plant_and_Machinery__c=this.EmpParentRecord[i].parentRecord.Investment_in_Plant_and_Machinery__c;
                    //                 MSMERecordObj.Annual_Turnover__c=this.EmpParentRecord[i].parentRecord.Annual_Turnover__c;
                    //                 MSMERecordObj.MSME__c=this.EmpParentRecord[i].parentRecord.MSME__c;
                    //                 MSMERecordObj.MSME_Type__c=this.EmpParentRecord[i].parentRecord.MSME_Type__c;
                                   
                    //                 MSMERecordObj.Final_MSME__c=this.EmpParentRecord[i].parentRecord.LoanAppln__r.Final_MSME__c;
                    //                 this.finalMSMEResult=MSMERecordObj.Final_MSME__c;

                    //                 this.MSMERecords.push(MSMERecordObj);  
                    //             }


                    if(this.EmpParentRecord[i].parentRecord.Type_of_Borrower__c=='Financial'){
                        //parent
                       // console.log('appl type value' ,this.EmpParentRecord[i].parentRecord.ApplType__c)
                        RBIRecordObj.ApplType__c=this.EmpParentRecord[i].parentRecord.ApplType__c;
                        RBIRecordObj.CustProfile__c=this.EmpParentRecord[i].parentRecord.CustProfile__c;
                        RBIRecordObj.Constitution__c=this.EmpParentRecord[i].parentRecord.Constitution__c;
                        RBIRecordObj.FullName__c=this.EmpParentRecord[i].parentRecord.FullName__c;
                        RBIRecordObj.CompanyName__c=this.EmpParentRecord[i].parentRecord.CompanyName__c;
                       // RBIRecordObj.TotalIncome__c=this.EmpParentRecord[i].parentRecord.TotalIncome__c;

                        //child
                        if(this.EmpParentRecord[i].parentRecord.Applicant_Employments__r){
                        if(this.EmpParentRecord[i].parentRecord.CustProfile__c=='SALARIED')
                        {
                            RBIRecordObj.Des__c=this.EmpParentRecord[i].parentRecord.Applicant_Employments__r[0].DesignationText__c;
                          
                        }
                        if(this.EmpParentRecord[i].parentRecord.CustProfile__c!='SALARIED')
                        {
                            RBIRecordObj.Des__c=this.EmpParentRecord[i].parentRecord.Applicant_Employments__r[0].DesignationValues__c;
                          
                        }
                        //RBIRecordObj.DesignationValues__c=this.EmpParentRecord[i].parentRecord.Applicant_Employments__r[i].DesignationValues__c;
                        if(this.EmpParentRecord[i].parentRecord.Applicant_Employments__r[0].IndustryType__c){
                            RBIRecordObj.IndustryType__c=this.EmpParentRecord[i].parentRecord.Applicant_Employments__r[0].IndustryType__r.Name;
                        
                        }
                        if(this.EmpParentRecord[i].parentRecord.Applicant_Employments__r[0].SubIndustry__c){
                            RBIRecordObj.SubIndustry__c=this.EmpParentRecord[i].parentRecord.Applicant_Employments__r[0].SubIndustry__r.Name;
                        
                        }
                        RBIRecordObj.MainRBIIndustry__c=this.EmpParentRecord[i].parentRecord.Applicant_Employments__r[0].MainRBIIndustry__c;
                        //console.log('industry', this.EmpParentRecord[i].parentRecord.Applicant_Employments__r[0].IndustryForRBIReporting__r)
                        if(this.EmpParentRecord[i].parentRecord.Applicant_Employments__r[0].IndustryForRBIReporting__c ){
                            RBIRecordObj.IndustryForRBIReporting__c=this.EmpParentRecord[i].parentRecord.Applicant_Employments__r[0].IndustryForRBIReporting__r.Name;
                        }
                    }
                        RBIRecordObj.Id=this.EmpParentRecord[i].parentRecord.Id;  
                        RBIRecordObj.Final_Industry_for_RBI__c=this.EmpParentRecord[i].parentRecord.LoanAppln__r.Final_Industry_for_RBI__c;
                        this.finalRBIResult=RBIRecordObj.Final_Industry_for_RBI__c;

                        this.RBIRecords.push(RBIRecordObj);  


                    }
                
                console.log(' final RBI records methods' +JSON.stringify(this.RBIRecords));  
                
           }
 
        } if (result.error) {
            console.log("error print", result.error);
          }
        console.log(' final EmpParentRecord records' +JSON.stringify(this.EmpParentRecord));  
        console.log(' final EmpChildRecord records' +JSON.stringify(this.EmpChildRecord));  
        // this.handleSave();
    }
    renderedCallback(){
       // refreshApex(this._wiredLoanApplData);
        refreshApex(this._wiredLoanEmpData)
     }

// Saving Final MSME/RBI Value in Loan Appln
    
    // handleSave()
    // {
    //     const fields = {};
    // fields[loanID.fieldApiName] = this.loanAppId;
    // fields[FinalIndustryForRBI.fieldApiName] = this.finalRBIResult;
    // fields[FinalMSMECategorization.fieldApiName] = this.finalMSMEResult;
    
        
    // const recordInput = {
    //   fields: fields
    // };

    // updateRecord(recordInput).then((record) => {
    //     console.log(record);
    //   });
        
    // }
    



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

    /* handleSelectAll(event){
        this.selectedRows
        const isChecked = event.target.checked;
        const checkboxes = this.template.querySelectorAll('input[type="checkbox"][data-row-checkbox]');
        checkboxes.forEach(checkbox =>{
            checkbox.checked = isChecked;
        })
    } */
}