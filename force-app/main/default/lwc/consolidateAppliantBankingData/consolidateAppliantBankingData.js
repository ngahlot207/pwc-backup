import { LightningElement,wire,api,track } from 'lwc';
import getDatawithoucah from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataWithoutCacheable';
import getData from '@salesforce/apex/SObjectDynamicRecordProvider.getAllSobjectDatawithRelatedRecords';
import getDataForFilterChild from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithFilterRelatedRecords';
import getDataForFilterChildwithOutCah from '@salesforce/apex/SObjectDynamicRecordProvider.getFilterRelRecordsWithOutCache';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { createRecord,updateRecord } from "lightning/uiRecordApi";
import APPLBANKING_OBJECT from '@salesforce/schema/ApplBanking__c';
import deleteRecord from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';
import updateData from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import { getRecord, getObjectInfo , getPicklistValuesByRecordType} from 'lightning/uiObjectInfoApi';
import { refreshApex } from '@salesforce/apex';
export default class ConsolidateAppliantBankingData extends LightningElement {
    allDataofApplicant;
    listofRecAfteArddingVals;
    @track showSpinner = false;
    showtableforSav=true;
    showTableForCC=true;
    _allApplicantData;
    listOfOverDraftCcAdd=[];
    listOfSvinJointCaAdd=[];
    params;
    @track product;
    @api
    get allApplicantData(){
        return this._allApplicantData;
    }

    set allApplicantData(value){
        this._allApplicantData = value;
    }
    _applicantIdPare;
    @api
    get applicantIdPare(){
        return _applicantIdPare;
    }

    set applicantIdPare(value){
        console.log('valuevaluevaluevaluevalue'+value)
        this._applicantIdPare = value;
        this.setAttribute("applicantIdPare", value);            
        this.handleRecordIdChange(value);  
    }

    handleRecordIdChange(){        
        let tempParams = this.paramsforFinan;
        console.log('>>>>>'+this._applicantIdPare)
       tempParams.queryCriteria=  ' where Loan_Applicant__c= \''+this._applicantIdPare+ '\'  AND RecordType.name = \'Profit & Loss\''      
       console.log('>>>>>')
        this.paramsforFinan = {...tempParams};
        console.log('Applicantid-->', this.paramsforFinan );
    }

    @track paramsforFinan={
        ParentObjectName:'Applicant_Financial__c',
        ChildObjectRelName:'Applicant_Financial_Summary_s__r',
        parentObjFields:['Id'],
        childObjFields:['Id','Total_Sales__c','FinancialYearFor__c'],  
        queryCriteriaForChild: ' order by FinancialYearFor__c asc',   
        queryCriteria:  ' where Loan_Applicant__c= \''+this._applicantIdPare+ '\'  AND RecordType.name = \'Profit & Loss\''      
    }

    _wiredForFinancialData;
    totalSalesAmou;
    @wire(getDataForFilterChild,{params:'$paramsforFinan'})
    forFinancialData(wiredForFinancialData) {
        //console.log('hhhhhh')
        const { data, error } = wiredForFinancialData;
        this._wiredForFinancialData = wiredForFinancialData;
        let FinancialRecData=[];
        //console.log('this._wiredForFinancialData'+JSON.stringify(this._wiredForFinancialData))
        if (data) {
            var listOfFinSumaryRecs=[];
            if(data.ChildReords!=''&& data.ChildReords !=null && typeof data.ChildReords!== 'undefined'){
                listOfFinSumaryRecs=data.ChildReords;
                console.log('listOfFinSumaryRecs',JSON.stringify(listOfFinSumaryRecs));
                this.totalSalesAmou=listOfFinSumaryRecs[1].Total_Sales__c
                this.BusTransRowsCalforSav.TopLineAsPerFin=this.totalSalesAmou;
                this.BusTransRowsCal.TopLineAsPerFin=this.totalSalesAmou;
                console.log('this.totalSalesAmou',JSON.stringify(this.totalSalesAmou));
            }else{
                this.totalSalesAmou=0
            }
         
        } else if (error) {
            console.log(error);
        }
    }
    _idsForOverDraftCca
    @api
    get idsForOverDraftCca(){
        return this._idsForOverDraftCca;
    }
    set idsForOverDraftCca(value){
        this._idsForOverDraftCca = value;  
        //console.log('this._idsForOverDraftCca'+this._idsForOverDraftCca);     
        if(this._idsForOverDraftCca !=null && this._idsForOverDraftCca !='' && typeof this._idsForOverDraftCca !== undefined){
            this.params ={
                ParentObjectName:'ApplBanking__c',
                ChildObjectRelName:'Applicant_Banking_Detail__r',
                parentObjFields:[  'Id', 'Limit__c','Appl__c', 'LoanAppl__r.product__c','LoanAppl__c', 'Name_of_the_Primary_Account_Holder_s__c', 'OtherBankName__c', 'AccountType__c', 'FileType__c', 'SalaryAccount__c', 'DocumentDetail__c', 'BankName__c', 'BankId__c', 'JointAccountHoldersName__c', 'AC_No__c', 'IsThereChangeInLimitDuringThePeri__c', 'AverageLimitDuringThePeriod__c', 'LatestMonthForWhichBankStatementIs__c', 'PeriodOfBankingStart__c', 'PeriodOfBankingEnd__c', 'Repayment_bank_A_c__c', 'Bank_Branch__c', 'MICR_Code__c', 'eNACH_feasible__c'],
                childObjFields:['Party__c','Amount__c','Count__c','SubType__c','IsLatest__c','ApplBanking__c','Monthend__c','Average_Daily_Bank_Balance__c', 'DailyABBBalance__c','MonthlyLimit__c','Id', 'Name', 'Month__c', 'Year__c', 'ValueSummationCredit__c', 'ValueSummationDebit__c', 'CountofCredit__c', 'CountofDebit__c', 'InwardReturnsCount__c', 'OutwardReturnsCount__c', 'StopPaymentCount__c', 'MinBalanceCharges__c', 'BalanceAt_1st__c', 'BalanceAt_5th__c', 'BalanceAt_10th__c', 'BalanceAt_15th__c', 'BalanceAt_20th__c', 'BalanceAt_25th__c', 'AverageBankBalance__c'],        
                queryCriteria:' WHERE ID IN (\''+this._idsForOverDraftCca.join('\', \'') + '\') AND Type__c = \'\' AND IsDeleted__c != true'
                // queryCriteria: ' WHERE ID IN (\'' + this._idsForOverDraftCca.join('\', \'') + '\') AND Type__c != \'Banking Summary\' AND Type__c != \'Consolidated Banking Summary\''
                // queryCriteria: ' WHERE ID IN (\''+this._idsForOverDraftCca.join('\', \'') + '\')'
            }
        }else{
            this.showTableForCC=false;
            this.ceckForOdCc=false;

            let paramsSaveOD={
                ParentObjectName:'Applicant__c',
                ChildObjectRelName:'Applicant_Banking1__r',
                parentObjFields:['Id','CustProfile__c'],
                childObjFields:['Id','Summary_Type__c','Type__c','Repayment_bank_A_c__c','SFDC_Bank_Master_Name__c','SFDCBankMaster__r.BankName__c','BankName__c','AccountType__c','FileType__c','DocumentDetail__c','DocumentDetail__r.DocTyp__c','SalaryAccount__c','DocumentDetail__r.Content_Document_Id__c','DocumentDetail__r.DocSubTyp__c'],        
                queryCriteriaForChild: ' WHERE Type__c = \'Banking Summary\' AND Summary_Type__c = \'Combined Banking (OD/CC)\' AND IsDeleted__c != true',   
                queryCriteria: ' where Id= \'' + this._applicantIdPare + '\''
            }

            getDataForFilterChildwithOutCah({ params: paramsSaveOD })
            .then((data) => {
                console.log('>>>>>>>>>>>>'+JSON.stringify(data));
                let listfordelete=[];
                
                if(data.ChildReords!=''&& data.ChildReords !=null && typeof data.ChildReords!== 'undefined'){
                    for(const record of data.ChildReords){
                        listfordelete.push(record);
                        this.handleDeleteAppDetail(listfordelete);
                    }
                }
                   // console.log('childexists>>>>>>>>>>>>>>>>>>>>>>>>>>'+data.ChildReords[0].Id)}

             })
            .catch(error => {
                console.log('Errorured:-999 '+JSON.stringify(error));
            });
            //console.log('this.listOfOverDraftCcAdd>>>'+this.listOfOverDraftCcAdd.length);
        }   
    }
    
    ceckForOdCc=true
    _idsForSvinJointCa
    paramsforSav;
    @api
    get idsForSvinJointCa(){
        return this._idsForSvinJointCa;
    }
    set idsForSvinJointCa(value){
        this._idsForSvinJointCa = value;  
       // console.log('this.idsForSvinJointCa'+this._idsForSvinJointCa);     
        if(this._idsForSvinJointCa !=null && this._idsForSvinJointCa !='' && typeof this._idsForSvinJointCa !== undefined){

            this.paramsforSav ={
                ParentObjectName:'ApplBanking__c',
                ChildObjectRelName:'Applicant_Banking_Detail__r',
                parentObjFields:[  'Id', 'ConsideredForABBProgram__c','LoanAppl__r.product__c','Appl__c', 'LoanAppl__c', 'Name_of_the_Primary_Account_Holder_s__c', 'OtherBankName__c', 'AccountType__c', 'FileType__c', 'SalaryAccount__c', 'DocumentDetail__c', 'BankName__c', 'BankId__c', 'JointAccountHoldersName__c', 'AC_No__c', 'IsThereChangeInLimitDuringThePeri__c', 'AverageLimitDuringThePeriod__c', 'LatestMonthForWhichBankStatementIs__c', 'PeriodOfBankingStart__c', 'PeriodOfBankingEnd__c', 'Repayment_bank_A_c__c', 'Bank_Branch__c', 'MICR_Code__c', 'eNACH_feasible__c'],
                childObjFields:['Party__c','Amount__c','Count__c','SubType__c','IsLatest__c','ApplBanking__c','ApplBanking__r.ConsideredForABBProgram__c','Monthend__c','Average_Daily_Bank_Balance__c', 'DailyABBBalance__c','MonthlyLimit__c','Id', 'Name', 'Month__c', 'Year__c', 'ValueSummationCredit__c', 'ValueSummationDebit__c', 'CountofCredit__c', 'CountofDebit__c', 'InwardReturnsCount__c', 'OutwardReturnsCount__c', 'StopPaymentCount__c', 'MinBalanceCharges__c', 'BalanceAt_1st__c', 'BalanceAt_5th__c', 'BalanceAt_10th__c', 'BalanceAt_15th__c', 'BalanceAt_20th__c', 'BalanceAt_25th__c', 'AverageBankBalance__c'],        
                queryCriteria:' WHERE ID IN (\''+this._idsForSvinJointCa.join('\', \'') + '\') AND Type__c = \'\' AND IsDeleted__c != true'
            } 
        }else{
            this.CheckIdLength=false;
            this.showtableforSav=false
            console.log('>>>>>>>>>>>>'+this._applicantIdPare);
           let paramsSaveOD={
                ParentObjectName:'Applicant__c',
                ChildObjectRelName:'Applicant_Banking1__r',
                parentObjFields:['Id','CustProfile__c'],
                childObjFields:['Id','Summary_Type__c','Type__c','Repayment_bank_A_c__c','SFDC_Bank_Master_Name__c','SFDCBankMaster__r.BankName__c','BankName__c','AccountType__c','FileType__c','DocumentDetail__c','DocumentDetail__r.DocTyp__c','SalaryAccount__c','DocumentDetail__r.Content_Document_Id__c','DocumentDetail__r.DocSubTyp__c'],        
                queryCriteriaForChild: ' WHERE Type__c = \'Banking Summary\' AND Summary_Type__c = \'Combined Banking (CASA)\' AND IsDeleted__c != true',   
                queryCriteria: ' where Id= \'' + this._applicantIdPare + '\''
            }

            getDataForFilterChildwithOutCah({ params: paramsSaveOD })
            .then((data) => {
                let listfordelete=[];
                console.log('>>>>>>>>>>>>'+JSON.stringify(data));
                if(data.ChildReords!=''&& data.ChildReords !=null && typeof data.ChildReords!== 'undefined'){
                    for(const record of data.ChildReords){
                        listfordelete.push(record);
                        this.handleDeleteAppDetail(listfordelete);
                    }
                }
                   // console.log('childexists>>>>>>>>>>>>>>>>>>>>>>>>>>'+data.ChildReords[0].Id)}

             })
            .catch(error => {
                console.log('Errorured:-999 '+JSON.stringify(error));
            });
            //console.log('this.listOfSvinJointCaAdd>>>'+this.listOfSvinJointCaAdd.length);
        }     
    }

    
    
    CheckIdLength=true
    _wiredForOverDraftCca
    totalLimitValue=0;
    applicantId;
    loanAppId;
    listOfTop10Supp=[];
    listOfTop10Customers=[];
    @wire(getData,{params:'$params'})
    ForOverDraftCca(wiredForOverDraftCca) {
         const { data, error } = wiredForOverDraftCca;
        this._wiredForOverDraftCca = wiredForOverDraftCca;
        let listOfAllChildReco=[];
        if (data) {
            for(const record of data){
                this.applicantId=record.parentRecord.Appl__c
                this.loanAppId=record.parentRecord.LoanAppl__c;
                console.log('this.applicantId>>>'+this.applicantId)
                if(record.parentRecord.Limit__c != null && record.parentRecord.Limit__c!='' && record.parentRecord.Limit__c!='undefined'){
                    this.totalLimitValue +=Number(record.parentRecord.Limit__c)
                }
                let j=1;
                let k=1;
                if(record.ChildReords && record.ChildReords != undefined){
                    for(const childRec of record.ChildReords){
                        if(childRec.Month__c && childRec.Year__c){
                            listOfAllChildReco.push(childRec);
                        }
                        if(childRec.IsLatest__c && childRec.SubType__c =='Top 10 Payments Made'){
                            this.listOfTop10Supp.push(childRec)
                            this.listOfTop10Supp[j-1] = { ...this.listOfTop10Supp[j-1], Index1: j};
                            j++
                        }
                        if(childRec.IsLatest__c && childRec.SubType__c =='Top 10 Payments Received'){
                            this.listOfTop10Customers.push(childRec)
                            this.listOfTop10Customers[k-1] = { ...this.listOfTop10Customers[k-1], Index1: k};
                            k++
                        }
                    }
                }
             }
             if(listOfAllChildReco.length==0){
                this.showTableForCC=false;
             }
            // console.log('this.totalLimitValue'+this.totalLimitValue)
           var listODCcaArddingVals=[];
           listODCcaArddingVals = this.forCreateDataForConsolidateTable(listOfAllChildReco);
           this.listOfOverDraftCcAdd=listODCcaArddingVals;
           //console.log('this.listOfOverDraftCcAdd>>>>>>'+JSON.stringify(this.listOfOverDraftCcAdd))
           this.listOfOverDraftCcAdd.sort(this.customSort);
           this.listOfOverDraftCcAdd =this.calculationforsum(this.listOfOverDraftCcAdd);
           this.listOfOverDraftCcAdd =this.calForUtilization(this.listOfOverDraftCcAdd);
           //this.listOfOverDraftCcAdd=this.calcuForMonLimit(this.listOfOverDraftCcAdd);
            let lengthOfList = this.listOfOverDraftCcAdd.length;
            this.calForTotalAndAverageODC=this.calForTotalAndAverage(this.listOfOverDraftCcAdd,lengthOfList);
            this.BusTransRowsCal=this.calForBusTransRowsCal(this.listOfOverDraftCcAdd)
            console.log('this.BusTransRowsCal'+JSON.stringify(this.BusTransRowsCal))
            if(lengthOfList>0){
                this.handleODndCCRecSave();
            }
            
         
        } else if (error) {
            console.log(error);
        }
    }
    
    calForTotalAndAverageODC ={"totalValueSummationDebit":0,"finalOfMinibalanceChar":'N',"totalValueSummationCredit":0,"totalCountofCredit":0,"totalCountofDebit":0,"totalInwardReturnsCount":0,"totalOutwardReturnsCount":0,"totalStopPaymentCount":0,"totalBalanceAt_1st":0,"totalBalanceAt_5th__c":0,"totalBalanceAt_10th":0,"totalBalanceAt_15th":0,"totalBalanceAt_20th":0,"totalBalanceAt_25th":0,"totalAverageBankBalance":0,"averageValueSummationCredit":0,"averageValueSummationDebit":0,"averageCountofCredit":0,"averageCountofDebit":0,"averageInwardReturnsCount":0,"averageOutwardReturnsCount":0,"averageStopPaymentCount":0,"averageBalanceAt_1st":0,"averageBalanceAt_5th__c":0,"averageBalanceAt_10th":0,"averageBalanceAt_15th":0,"averageBalanceAt_20th":0,"averageBalanceAt_25th":0,"averageAverageBankBalance":0,"totalForConAbbPro":0,"averForConAbbPro":0};  
    calForTotalAndAverageSav={"totalValueSummationDebit":0,"finalOfMinibalanceChar":'N',"totalValueSummationCredit":0,"totalCountofCredit":0,"totalCountofDebit":0,"totalInwardReturnsCount":0,"totalOutwardReturnsCount":0,"totalStopPaymentCount":0,"totalBalanceAt_1st":0,"totalBalanceAt_5th__c":0,"totalBalanceAt_10th":0,"totalBalanceAt_15th":0,"totalBalanceAt_20th":0,"totalBalanceAt_25th":0,"totalAverageBankBalance":0,"averageValueSummationCredit":0,"averageValueSummationDebit":0,"averageCountofCredit":0,"averageCountofDebit":0,"averageInwardReturnsCount":0,"averageOutwardReturnsCount":0,"averageStopPaymentCount":0,"averageBalanceAt_1st":0,"averageBalanceAt_5th__c":0,"averageBalanceAt_10th":0,"averageBalanceAt_15th":0,"averageBalanceAt_20th":0,"averageBalanceAt_25th":0,"averageAverageBankBalance":0,"totalForConAbbPro":0,"averForConAbbPro":0};  
    
    _wiredForSvinJointCa
    @wire(getData,{params:'$paramsforSav'})
    ForSvinJointCa(wiredForSvinJointCa) {
        const { data, error } = wiredForSvinJointCa;
        this._wiredForSvinJointCa = wiredForSvinJointCa;
        //console.log('this._wiredFForSvinJointCa',this._wiredForSvinJointCa);
        let listOfAllChildReco=[];
        if (data) {
            console.log('ForSvinJointCa>>>>>'+JSON.stringify(data))
            for(const record of data){
                
                this.applicantId=record.parentRecord.Appl__c
                this.loanAppId=record.parentRecord.LoanAppl__c;
                this.product=record.parentRecord.LoanAppl__r.Product__c;
                console.log('ForSvinJointCa'+JSON.stringify(record))
                let j=1
                let k=1
                if(record.ChildReords && record.ChildReords != undefined){
                    for(const childRec of record.ChildReords){
                        if(childRec.Month__c && childRec.Year__c){
                            listOfAllChildReco.push(childRec);
                        }
                        if(childRec.IsLatest__c && childRec.SubType__c =='Top 10 Payments Made'){
                            this.listOfTop10Supp.push(childRec)
                            this.listOfTop10Supp[j-1] = { ...this.listOfTop10Supp[j-1], Index1: j};
                            j++
                        }
                        if(childRec.IsLatest__c && childRec.SubType__c =='Top 10 Payments Received'){
                            this.listOfTop10Customers.push(childRec)
                            this.listOfTop10Customers[k-1] = { ...this.listOfTop10Customers[k-1], Index1: k};
                            k++
                        }
                        
                    }
                }
            }
            if(listOfAllChildReco.length==0){
                this.showtableforSav=false;
            }
           var listSvinJointCaArddingVals=[];
           listSvinJointCaArddingVals = this.forCreateDataForConsolidateTableSaving(listOfAllChildReco);
           this.listOfSvinJointCaAdd=listSvinJointCaArddingVals
           this.listOfSvinJointCaAdd.sort(this.customSort);
           this.listOfSvinJointCaAdd=this.calculationforsum(this.listOfSvinJointCaAdd);
            let lengthOfList = this.listOfSvinJointCaAdd.length;
            
            this.calForTotalAndAverageSav= this.calForTotalAndAverage(this.listOfSvinJointCaAdd,lengthOfList);
            this.BusTransRowsCalforSav=this.calForBusTransRowsCalforSav(this.listOfSvinJointCaAdd)
            if(lengthOfList>0){
                console.log('15666')
                this.handleSavJoinCurreRecSave();
            }
            
        } else if (error) {
            console.log(error);
        }
    }
    @wire(getObjectInfo, { objectApiName:  APPLBANKING_OBJECT})
    objectInfo

    appliBnkReIdForConCCndOD;
    ListofCCDetailRecToUpsert;

    
    handleODndCCRecSave(){
        //var listToDeleteRec=[];
        var ListForUpsertRec=[];
        var appliBnkReForConNew={"Appl__c":this.applicantId,"LoanAppl__c":this.loanAppId,"Summary_Type__c":"Combined Banking (OD/CC)","Type__c":"Banking Summary"}
        let paramsODCC={
            ParentObjectName:'Applicant__c',
            ChildObjectRelName:'Applicant_Banking1__r',
            parentObjFields:['Id','CustProfile__c'],
            childObjFields:['Id','Summary_Type__c','Type__c','Repayment_bank_A_c__c','SFDC_Bank_Master_Name__c','SFDCBankMaster__r.BankName__c','BankName__c','AccountType__c','FileType__c','DocumentDetail__c','DocumentDetail__r.DocTyp__c','SalaryAccount__c','DocumentDetail__r.Content_Document_Id__c','DocumentDetail__r.DocSubTyp__c'],        
            queryCriteriaForChild: ' WHERE Type__c = \'Banking Summary\' AND Summary_Type__c = \'Combined Banking (OD/CC)\'',   
            queryCriteria: ' where Id= \'' + this.applicantId + '\''
        }
        getDataForFilterChildwithOutCah({ params: paramsODCC })
            .then((data) => {
                //console.log('>>>>>>>>>>>>'+JSON.stringify(data));
                if(data.ChildReords!=''&& data.ChildReords !=null && typeof data.ChildReords!== 'undefined'){
                    //console.log('childexists>>>>>>>>>>>>>>>>>>>>>>>>>>'+data.ChildReords[0].Id)
                    this.appliBnkReIdForConCCndOD=data.ChildReords[0].Id;

                    this.UpdateAppBnkWithDetail();
                  }else{
                    //console.log('childnotexists>>>>>>>>>>>>>>>>>>>>>>>>>>')
                    const recordInput = {
                        apiName: APPLBANKING_OBJECT.objectApiName,
                        fields: appliBnkReForConNew
                    };
                    createRecord(recordInput)
                    .then((record) => {
                        //console.log(record.id)
                        this.appliBnkReIdForConCCndOD=record.id;
                        this.UpdateAppBnkWithDetail();
                    })
                    .catch((err) => {
                        console.log(" createRecord error===", err);
                    });
                }
             })
            .catch(error => {
                console.log('Errorured:-6666 '+JSON.stringify(error));
            });
        
    }
    parentRecord;
    ChildRecordsToUpsert;
    UpdateAppBnkWithDetail(){
        //console.log('211111');
        const mapOfExistingRecWithMon = new Map(); 
        var listOfMonYeNewRec=[];
        var listtodeleteRec=[]
        var ListOfMonYearOfRec=[];
        let paramForAppDetail={
            ParentObjectName:'ApplBanking__c',
            ChildObjectRelName:'Applicant_Banking_Detail__r',
            parentObjFields:[  'Id', 'Appl__c', 'eNACHFeasible__c','SFDC_Bank_Master_Name__c','NACHFeasible__c','SFDCBankMaster__r.BankName__c','LoanAppl__c','IFSC_Code__c','Limit__c', 'Name_of_the_Primary_Account_Holder_s__c', 'OtherBankName__c', 'AccountType__c', 'FileType__c', 'SalaryAccount__c', 'DocumentDetail__c', 'BankName__c', 'BankId__c', 'JointAccountHoldersName__c', 'AC_No__c', 'IsThereChangeInLimitDuringThePeri__c', 'AverageLimitDuringThePeriod__c', 'LatestMonthForWhichBankStatementIs__c', 'PeriodOfBankingStart__c', 'PeriodOfBankingEnd__c','Bank_City__c', 'Repayment_bank_A_c__c', 'Bank_Branch__c', 'MICR_Code__c','Appl__r.CustProfile__c', 'eNACH_feasible__c'],
            childObjFields:['ApplBanking__c','Monthend__c','Average_Daily_Bank_Balance__c', 'DailyABBBalance__c','MonthlyLimit__c','Utilization__c','Id', 'Name', 'Month__c', 'Year__c', 'ValueSummationCredit__c', 'ValueSummationDebit__c', 'CountofCredit__c', 'CountofDebit__c', 'InwardReturnsCount__c', 'OutwardReturnsCount__c', 'StopPaymentCount__c', 'MinBalanceCharges__c', 'BalanceAt_1st__c', 'BalanceAt_5th__c', 'BalanceAt_10th__c', 'BalanceAt_15th__c', 'BalanceAt_20th__c', 'BalanceAt_25th__c', 'AverageBankBalance__c'],        
            queryCriteria: ' where Id= \'' + this.appliBnkReIdForConCCndOD + '\' AND IsDeleted__c != true'
        }
        getDatawithoucah({ params: paramForAppDetail })
            .then((data) => {
                
                this.parentRecord=JSON.parse(JSON.stringify(data[0].parentRecord));
                this.parentRecord["BusinessTransactionsSummationCredit__c"]=this.calForTotalAndAverageODC.totalValueSummationCredit
                this.parentRecord["BusinessTransactionsSummationDebit__c"]=this.calForTotalAndAverageODC.totalValueSummationDebit
                this.parentRecord["BTOof12monthsForBusinessTransaction__c"]=this.BusTransRowsCal.BTOfor12Month
                this.parentRecord["AnnualisedBTO6MonthsBusinessTransaction__c"]=this.BusTransRowsCal.BTOfor6Month

                this.parentRecord["I_W_Return_Ratio__c"]=this.BusTransRowsCal.IandWReturnRatio
                this.parentRecord["O_W_Return_Ratio__c"]=this.BusTransRowsCal.OandWReturnRatio
                this.parentRecord["X6MAverageBalance__c"]=this.sixMonthTotalCCndOd.SixMonTotalForbal
                this.parentRecord["X12M_Average_Balance__c"]=this.sixMonthTotalCCndOd.allTotalForbal
                console.log('231111'+JSON.stringify(this.parentRecord))
                if(data[0].ChildReords !=null && data[0].ChildReords !=''  && typeof data[0].ChildReords !== 'undefined'){
                    //console.log('childexistsin'+JSON.stringify(data[0].ChildReords))
                    
                    data[0].ChildReords.forEach(record => {
                    const month = record.Month__c; 
                    const year = record.Year__c;
                    const monthYear1 = `${month}-${year}`; 
                    if (!mapOfExistingRecWithMon.has(monthYear1)) { 
                        //console.log('monthYear1'+monthYear1)
                        mapOfExistingRecWithMon.set(monthYear1, []); 
                    } 
                   // console.log('recordrecordrecord'+JSON.stringify(record))
                    mapOfExistingRecWithMon.get(monthYear1).push(record); 
                    }); 
                   // console.log('mapOfExisting24555'+mapOfExistingRecWithMon.get('MAR-2023'));
                    for(const rec of this.listOfOverDraftCcAdd){
                        listOfMonYeNewRec.push(rec.monthYear);
                       //console.log('recrec'+JSON.stringify(rec))
                        if(mapOfExistingRecWithMon.get(rec.monthYear) !='' && mapOfExistingRecWithMon.get(rec.monthYear) !=null &&typeof mapOfExistingRecWithMon.get(rec.monthYear) !=='undefined' ){
                            var existRecord=mapOfExistingRecWithMon.get(rec.monthYear)
                            //console.log('357@@@@@'+JSON.stringify(existRecord));
                            let blankListForNewDetailRec = {"Id":existRecord[0].Id,"ApplBanking__c":this.appliBnkReIdForConJointSav,"Month__c":existRecord[0].Month__c,"Year__c":existRecord[0].Year__c,"ValueSummationCredit__c":rec.sumValueSummationCredit,"ValueSummationDebit__c":rec.sumValueSummationDebit,"CountofCredit__c":rec.sumChangesCountofCredit,"CountofDebit__c":rec.sumChangesCountofDebit,"InwardReturnsCount__c":rec.sumInwardReturnsCount,"OutwardReturnsCount__c":rec.sumOutwardReturnsCount,"StopPaymentCount__c":rec.sumChangesStopPaymentCount,"MinBalanceCharges__c":rec.sumcheckMiniChan,"BalanceAt_1st__c":rec.sumChangesBalanceAt_1st,"BalanceAt_5th__c":rec.sumChangesBalanceAt_5th__c,"BalanceAt_10th__c":rec.sumChangesBalanceAt_10th,"BalanceAt_15th__c":rec.sumChangesBalanceAt_15th,"BalanceAt_20th__c":rec.sumChangesBalanceAt_20th,"BalanceAt_25th__c":rec.sumChangesBalanceAt_25th,"AverageBankBalance__c":rec.sumChangesAverageBankBalance,"Utilization__c":rec.Utilization,"MonthlyLimit__c":rec.sumMonthlyLimit,"DailyABBBalance__c":rec.sumValueAbbPro};
                            ListOfMonYearOfRec.push(blankListForNewDetailRec)
                        }else{
                            const monyearToSplit=rec.monthYear.split('-')
                            let blankListForNewDetailRec = {"ApplBanking__c":this.appliBnkReIdForConJointSav,"Month__c":monyearToSplit[0],"Year__c":monyearToSplit[1],"ValueSummationCredit__c":rec.sumValueSummationCredit,"ValueSummationDebit__c":rec.sumValueSummationDebit,"CountofCredit__c":rec.sumChangesCountofCredit,"CountofDebit__c":rec.sumChangesCountofDebit,"InwardReturnsCount__c":rec.sumInwardReturnsCount,"OutwardReturnsCount__c":rec.sumOutwardReturnsCount,"StopPaymentCount__c":rec.sumChangesStopPaymentCount,"MinBalanceCharges__c":rec.sumcheckMiniChan,"BalanceAt_1st__c":rec.sumChangesBalanceAt_1st,"BalanceAt_5th__c":rec.sumChangesBalanceAt_5th__c,"BalanceAt_10th__c":rec.sumChangesBalanceAt_10th,"BalanceAt_15th__c":rec.sumChangesBalanceAt_15th,"BalanceAt_20th__c":rec.sumChangesBalanceAt_20th,"BalanceAt_25th__c":rec.sumChangesBalanceAt_25th,"AverageBankBalance__c":rec.sumChangesAverageBankBalance,"Utilization__c":rec.Utilization,"MonthlyLimit__c":rec.sumMonthlyLimit,"DailyABBBalance__c":rec.sumValueAbbPro};
                            ListOfMonYearOfRec.push(blankListForNewDetailRec)
                        }
                        
                    }
                    for(const key of mapOfExistingRecWithMon.keys()){
                       // console.log('385'+key)
                        //console.log('testtesttest'+listOfMonYeNewRec)
                        if(!listOfMonYeNewRec.includes(key)){
                            var listforDelete=mapOfExistingRecWithMon.get(key)[0]
                            listtodeleteRec.push(listforDelete)
                            //console.log('indeleteeee'+JSON.stringify(listtodeleteRec))
                        }else{
                            console.log('innotttttdeleteeee')
                        }
                    }
                    if(listtodeleteRec.length>0){
                        this.handleDeleteAppDetail(listtodeleteRec)
                    }
                }
                else{
                    for(const rec of this.listOfOverDraftCcAdd){
                        const monyearToSplit=rec.monthYear.split('-')
                        let blankListForNewDetailRec = {"ApplBanking__c":this.appliBnkReIdForConCCndOD,"Month__c":monyearToSplit[0],"Year__c":monyearToSplit[1],"ValueSummationCredit__c":rec.sumValueSummationCredit,"ValueSummationDebit__c":rec.sumValueSummationDebit,"CountofCredit__c":rec.sumChangesCountofCredit,"CountofDebit__c":rec.sumChangesCountofDebit,"InwardReturnsCount__c":rec.sumInwardReturnsCount,"OutwardReturnsCount__c":rec.sumOutwardReturnsCount,"StopPaymentCount__c":rec.sumChangesStopPaymentCount,"MinBalanceCharges__c":rec.sumcheckMiniChan,"BalanceAt_1st__c":rec.sumChangesBalanceAt_1st,"BalanceAt_5th__c":rec.sumChangesBalanceAt_5th__c,"BalanceAt_10th__c":rec.sumChangesBalanceAt_10th,"BalanceAt_15th__c":rec.sumChangesBalanceAt_15th,"BalanceAt_20th__c":rec.sumChangesBalanceAt_20th,"BalanceAt_25th__c":rec.sumChangesBalanceAt_25th,"AverageBankBalance__c":rec.sumChangesAverageBankBalance,"DailyABBBalance__c":rec.sumValueAbbPro, "Utilization__c":rec.Utilization,"MonthlyLimit__c":rec.sumMonthlyLimit};
                        ListOfMonYearOfRec.push(blankListForNewDetailRec)
                    }
                   
                }
                //console.log('26333'+JSON.stringify(ListOfMonYearOfRec));
                this.ChildRecordsToUpsert=ListOfMonYearOfRec
                /*console.log('26333'+JSON.stringify(this.parentRecord));
                console.log('26333'+JSON.stringify(this.ChildRecordsToUpsert));*/
                this.handleSave(this.parentRecord,this.ChildRecordsToUpsert);

             })
            .catch(error => {
                console.log('Errorured:-7777 '+JSON.stringify(error));
            });

    }
    appliBnkReIdForConJointSav;

    handleSavJoinCurreRecSave(){
        //var listToDeleteRec=[];
        var ListForUpsertRec=[];
        var appliBnkReForConNew={"Appl__c":this.applicantId,"LoanAppl__c":this.loanAppId,"Summary_Type__c":"Combined Banking (CASA)","Type__c":"Banking Summary"}
        let paramsSaveOD={
            ParentObjectName:'Applicant__c',
            ChildObjectRelName:'Applicant_Banking1__r',
            parentObjFields:['Id','CustProfile__c'],
            childObjFields:['Id','Summary_Type__c','Type__c','Repayment_bank_A_c__c','SFDC_Bank_Master_Name__c','SFDCBankMaster__r.BankName__c','BankName__c','AccountType__c','FileType__c','DocumentDetail__c','DocumentDetail__r.DocTyp__c','SalaryAccount__c','DocumentDetail__r.Content_Document_Id__c','DocumentDetail__r.DocSubTyp__c'],        
            queryCriteriaForChild: ' WHERE Type__c = \'Banking Summary\' AND Summary_Type__c = \'Combined Banking (CASA)\' AND IsDeleted__c != true',   
            queryCriteria: ' where Id= \'' + this.applicantId + '\''
        }
        getDataForFilterChildwithOutCah({ params: paramsSaveOD })
            .then((data) => {
                //console.log('>>>>>>>>>>>>'+JSON.stringify(data));
                if(data.ChildReords!=''&& data.ChildReords !=null && typeof data.ChildReords!== 'undefined'){
                   // console.log('childexists>>>>>>>>>>>>>>>>>>>>>>>>>>'+data.ChildReords[0].Id)
                    this.appliBnkReIdForConJointSav=data.ChildReords[0].Id;

                    this.UpdateAppBnkWithDetailforSav();
                  }else{
                    //console.log('childnotexists>>>>>>>>>>>>>>>>>>>>>>>>>>')
                    const recordInput = {
                        apiName: APPLBANKING_OBJECT.objectApiName,
                        fields: appliBnkReForConNew
                    };
                    createRecord(recordInput)
                    .then((record) => {
                        console.log(record.id)
                        this.appliBnkReIdForConJointSav=record.id;
                        this.UpdateAppBnkWithDetailforSav();
                    })
                    .catch((err) => {
                        console.log(" createRecord error===", err);
                    });
                }
             })
            .catch(error => {
                console.log('Errorured:-999 '+JSON.stringify(error));
            });
        
    }
    parentRecordForSav;
    ChildRecordsSavToUpsert;
    UpdateAppBnkWithDetailforSav(){
        console.log('211111');
        const mapOfExistingRecWithMon = new Map(); 
        //const mapOfnewRecWithMon = new Map(); 
        const listOfMonYeNewRec=[]
        var ListOfMonYearOfRec=[];
        var listtodeleteRec=[];
        let paramForAppDetail={
            ParentObjectName:'ApplBanking__c',
            ChildObjectRelName:'Applicant_Banking_Detail__r',
            parentObjFields:[  'Id', 'Appl__c', 'eNACHFeasible__c','SFDC_Bank_Master_Name__c','NACHFeasible__c','SFDCBankMaster__r.BankName__c','LoanAppl__c','IFSC_Code__c','Limit__c', 'Name_of_the_Primary_Account_Holder_s__c', 'OtherBankName__c', 'AccountType__c', 'FileType__c', 'SalaryAccount__c', 'DocumentDetail__c', 'BankName__c', 'BankId__c', 'JointAccountHoldersName__c', 'AC_No__c', 'IsThereChangeInLimitDuringThePeri__c', 'AverageLimitDuringThePeriod__c', 'LatestMonthForWhichBankStatementIs__c', 'PeriodOfBankingStart__c', 'PeriodOfBankingEnd__c','Bank_City__c', 'Repayment_bank_A_c__c', 'Bank_Branch__c', 'MICR_Code__c','Appl__r.CustProfile__c', 'eNACH_feasible__c'],
            childObjFields:['ApplBanking__c','Monthend__c','Average_Daily_Bank_Balance__c', 'DailyABBBalance__c','Utilization__c','Id', 'Name', 'Month__c', 'Year__c', 'ValueSummationCredit__c', 'ValueSummationDebit__c', 'CountofCredit__c', 'CountofDebit__c', 'InwardReturnsCount__c', 'OutwardReturnsCount__c', 'StopPaymentCount__c', 'MinBalanceCharges__c', 'BalanceAt_1st__c', 'BalanceAt_5th__c', 'BalanceAt_10th__c', 'BalanceAt_15th__c', 'BalanceAt_20th__c', 'BalanceAt_25th__c', 'AverageBankBalance__c'],        
            queryCriteria: ' where Id= \'' + this.appliBnkReIdForConJointSav + '\' AND IsDeleted__c != true'
        }
        getDatawithoucah({ params: paramForAppDetail })
            .then((data) => {
                this.parentRecordForSav=JSON.parse(JSON.stringify(data[0].parentRecord));
                this.parentRecordForSav["BusinessTransactionsSummationCredit__c"]=this.calForTotalAndAverageSav.totalValueSummationCredit
                this.parentRecordForSav["BusinessTransactionsSummationDebit__c"]=this.calForTotalAndAverageSav.totalValueSummationDebit
                this.parentRecordForSav["BTOof12monthsForBusinessTransaction__c"]=this.BusTransRowsCalforSav.BTOfor12Month
                this.parentRecordForSav["AnnualisedBTO6MonthsBusinessTransaction__c"]=this.BusTransRowsCalforSav.BTOfor6Month

                this.parentRecordForSav["I_W_Return_Ratio__c"]=this.BusTransRowsCalforSav.IandWReturnRatio
                this.parentRecordForSav["O_W_Return_Ratio__c"]=this.BusTransRowsCalforSav.OandWReturnRatio
                this.parentRecordForSav["X6MAverageBalance__c"]=this.sixMonthTotalSavNDjoint.SixMonTotalForbal
                this.parentRecordForSav["X12M_Average_Balance__c"]=this.sixMonthTotalSavNDjoint.allTotalForbal
                if(data[0].ChildReords !=null && data[0].ChildReords !=''  && typeof data[0].ChildReords !== 'undefined'){
                    //console.log('childexistsin')
                    
                    data[0].ChildReords.forEach(record => {
                    const month = record.Month__c; 
                    const year = record.Year__c;
                    const monthYear1 = `${month}-${year}`; 
                    if (!mapOfExistingRecWithMon.has(monthYear1)) { 
                        mapOfExistingRecWithMon.set(monthYear1, []); 
                    } 
                    mapOfExistingRecWithMon.get(monthYear1).push(record); 
                    }); 
                    //console.log('mapOfExisting'+mapOfExistingRecWithMon.keys());
                    for(const rec of this.listOfSvinJointCaAdd){
                       // mapOfnewRecWithMon.set(rec.monthYear,rec)
                        listOfMonYeNewRec.push(rec.monthYear);
                        if(mapOfExistingRecWithMon.get(rec.monthYear) !='' && mapOfExistingRecWithMon.get(rec.monthYear) !=null &&typeof mapOfExistingRecWithMon.get(rec.monthYear) !=='undefined' ){
                        //if(mapOfExistingRecWithMon.get(rec.monthYear) !=''){
                            var existRecord=mapOfExistingRecWithMon.get(rec.monthYear)
                           // console.log('357@@@@@'+JSON.stringify(existRecord));
                            let blankListForNewDetailRec = {"Id":existRecord[0].Id,"ApplBanking__c":this.appliBnkReIdForConJointSav,"Month__c":existRecord[0].Month__c,"Year__c":existRecord[0].Year__c,"ValueSummationCredit__c":rec.sumValueSummationCredit,"ValueSummationDebit__c":rec.sumValueSummationDebit,"CountofCredit__c":rec.sumChangesCountofCredit,"CountofDebit__c":rec.sumChangesCountofDebit,"InwardReturnsCount__c":rec.sumInwardReturnsCount,"OutwardReturnsCount__c":rec.sumOutwardReturnsCount,"StopPaymentCount__c":rec.sumChangesStopPaymentCount,"MinBalanceCharges__c":rec.sumcheckMiniChan,"BalanceAt_1st__c":rec.sumChangesBalanceAt_1st,"BalanceAt_5th__c":rec.sumChangesBalanceAt_5th__c,"BalanceAt_10th__c":rec.sumChangesBalanceAt_10th,"BalanceAt_15th__c":rec.sumChangesBalanceAt_15th,"BalanceAt_20th__c":rec.sumChangesBalanceAt_20th,"BalanceAt_25th__c":rec.sumChangesBalanceAt_25th,"AverageBankBalance__c":rec.sumChangesAverageBankBalance,"DailyABBBalance__c":rec.sumValueAbbPro};
                            ListOfMonYearOfRec.push(blankListForNewDetailRec)
                        }else{
                            const monyearToSplit=rec.monthYear.split('-')
                            let blankListForNewDetailRec = {"ApplBanking__c":this.appliBnkReIdForConJointSav,"Month__c":monyearToSplit[0],"Year__c":monyearToSplit[1],"ValueSummationCredit__c":rec.sumValueSummationCredit,"ValueSummationDebit__c":rec.sumValueSummationDebit,"CountofCredit__c":rec.sumChangesCountofCredit,"CountofDebit__c":rec.sumChangesCountofDebit,"InwardReturnsCount__c":rec.sumInwardReturnsCount,"OutwardReturnsCount__c":rec.sumOutwardReturnsCount,"StopPaymentCount__c":rec.sumChangesStopPaymentCount,"MinBalanceCharges__c":rec.sumcheckMiniChan,"BalanceAt_1st__c":rec.sumChangesBalanceAt_1st,"BalanceAt_5th__c":rec.sumChangesBalanceAt_5th__c,"BalanceAt_10th__c":rec.sumChangesBalanceAt_10th,"BalanceAt_15th__c":rec.sumChangesBalanceAt_15th,"BalanceAt_20th__c":rec.sumChangesBalanceAt_20th,"BalanceAt_25th__c":rec.sumChangesBalanceAt_25th,"AverageBankBalance__c":rec.sumChangesAverageBankBalance,"DailyABBBalance__c":rec.sumValueAbbPro};
                            ListOfMonYearOfRec.push(blankListForNewDetailRec)
                        }
                        
                    }
                    //console.log('testtesttest'+test)
                   for(const key of mapOfExistingRecWithMon.keys()){
                        console.log('385'+key)
                        //console.log('testtesttest'+listOfMonYeNewRec)
                        if(!listOfMonYeNewRec.includes(key)){
                            var listforDelete=mapOfExistingRecWithMon.get(key)[0]
                            listtodeleteRec.push(listforDelete)
                            console.log('indeleteeee'+JSON.stringify(listtodeleteRec))
                        }else{
                            console.log('innotttttdeleteeee')
                        }
                    }
                    if(listtodeleteRec.length>0){
                        this.handleDeleteAppDetail(listtodeleteRec)
                    }
                   // console.log('248888888'+ListOfMonYearOfRec);
                }else{
                    console.log('childnotexistsin 2 method>>>>>>>>>>>>>>>>>>>>>>>>>>')
                    for(const rec of this.listOfSvinJointCaAdd){
                        const monyearToSplit=rec.monthYear.split('-')
                        let blankListForNewDetailRec = {"ApplBanking__c":this.appliBnkReIdForConJointSav,"Month__c":monyearToSplit[0],"Year__c":monyearToSplit[1],"ValueSummationCredit__c":rec.sumValueSummationCredit,"ValueSummationDebit__c":rec.sumValueSummationDebit,"CountofCredit__c":rec.sumChangesCountofCredit,"CountofDebit__c":rec.sumChangesCountofDebit,"InwardReturnsCount__c":rec.sumInwardReturnsCount,"OutwardReturnsCount__c":rec.sumOutwardReturnsCount,"StopPaymentCount__c":rec.sumChangesStopPaymentCount,"MinBalanceCharges__c":rec.sumcheckMiniChan,"BalanceAt_1st__c":rec.sumChangesBalanceAt_1st,"BalanceAt_5th__c":rec.sumChangesBalanceAt_5th__c,"BalanceAt_10th__c":rec.sumChangesBalanceAt_10th,"BalanceAt_15th__c":rec.sumChangesBalanceAt_15th,"BalanceAt_20th__c":rec.sumChangesBalanceAt_20th,"BalanceAt_25th__c":rec.sumChangesBalanceAt_25th,"AverageBankBalance__c":rec.sumChangesAverageBankBalance,"DailyABBBalance__c":rec.sumValueAbbPro};
                        ListOfMonYearOfRec.push(blankListForNewDetailRec)
                    }
                   
                }
                //console.log('ListOfMonYearOfRec'+JSON.stringify(ListOfMonYearOfRec));
                this.ChildRecordsSavToUpsert=ListOfMonYearOfRec
                this.handleSave(this.parentRecordForSav, this.ChildRecordsSavToUpsert);

             })
            .catch(error => {
                console.log('Errorured:-123 '+JSON.stringify(error));
            });

    }
    
    handleSave(parentRec, ChildRecList){
        console.log('inhandlesaveeee')
        delete parentRec.Appl__r
        parentRec.sobjectType='ApplBanking__c'
        //console.log('this.parentRecord'+JSON.stringify(parentRec))
        //console.log('this.ChildRecordsToUpsert'+JSON.stringify(ChildRecList))
        let ChildRecords = [];
        let childRecordObj = {};
        for(var i=0;i<ChildRecList.length;i++){
            childRecordObj = {...ChildRecList[i]};
            childRecordObj.sobjectType='ApplBankDetail__c',
            ChildRecords.push(childRecordObj);
         } 
        let upsertData={                       
            parentRecord:parentRec,                       
            ChildRecords:ChildRecords,
            ParentFieldNameToUpdate:'ApplBanking__c'
        }  
        //console.log('@@@@@@@@@@@@@@@@@@@@'+JSON.stringify(upsertData));                 
        updateData ({upsertData:upsertData})
        .then(result => {  
            this.showSpinner = false;
            console.log('resultresultresultresultresult'+JSON.stringify(result))                    
               
        }).catch(error => {
            
            console.log('erorrrrrrr'+JSON.stringify(error));
        })
    }

    /*handleSave(){
        console.log('inhandle'+JSON.stringify(this.parentRecord));
        delete this.parentRecord.Appl__r
        console.log('inhandle'+JSON.stringify(this.parentRecord));
        this.parentRecord.sobjectType='ApplBanking__c'
        console.log('this.parentRecord'+JSON.stringify(this.parentRecord))
        console.log('this.ChildRecordsToUpsert'+JSON.stringify(this.ChildRecordsToUpsert))
        let ChildRecords = [];
        let childRecordObj = {};
        for(var i=0;i<this.ChildRecordsToUpsert.length;i++){
            childRecordObj = {...this.ChildRecordsToUpsert[i]};
            childRecordObj.sobjectType='ApplBankDetail__c',
            ChildRecords.push(childRecordObj);
         } 
        let upsertData={                       
            parentRecord:this.parentRecord,                       
            ChildRecords:ChildRecords,
            ParentFieldNameToUpdate:'ApplBanking__c'
        }  
        console.log('@@@@@@@@@@@@@@@@@@@@'+JSON.stringify(upsertData));                 
        updateData ({upsertData:upsertData})
        .then(result => {  
            console.log('resultresultresultresultresult'+JSON.stringify(result))                    
               
        }).catch(error => {
            
            console.log('erorrrrrrr'+JSON.stringify(error));
        })
    }*/

    showToast(title, variant, message) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message
        });
        this.dispatchEvent(evt);
        
    }
    
    forCreateDataForConsolidateTable(ListOfChildRec){
        const recordsByMonthYearMap = new Map(); 
        ListOfChildRec.forEach(record => {
        const month = record.Month__c; 
        const year = record.Year__c;
         const monthYear = `${month}-${year}`; 
         if (!recordsByMonthYearMap.has(monthYear)) { 
            recordsByMonthYearMap.set(monthYear, []); 
        } 
        recordsByMonthYearMap.get(monthYear).push(record); 
        }); 
        let sumMonthEnd=0
        let sumDailyBalan=0  
        let sumValueAbbPro=0;
        let sumValueSummationCredit = 0;
        let sumValueSummationDebit = 0;
        let sumChangesCountofDebit=0
        let sumChangesCountofCredit=0
        let sumChangesAverageBankBalance=0
        let sumChangesBalanceAt_25th=0
        let sumChangesBalanceAt_20th=0
        let sumChangesBalanceAt_1st=0
        let sumChangesBalanceAt_5th__c=0
        let sumChangesBalanceAt_10th=0
        let sumChangesBalanceAt_15th=0
        let sumInwardReturnsCount=0
        let sumOutwardReturnsCount=0
        let sumChangesStopPaymentCount=0
        let sumMonthlyLimit=0;
        let listofRecAfteArddingVals=[];

        let sumcheckMiniChan='';
        let checkMiniChan=false;
        console.log('recordsByMonthYearMap'+JSON.stringify(recordsByMonthYearMap));
        for (const [monthYear, records] of recordsByMonthYearMap) {
            console.log('[monthYear, records]'+[monthYear, records]);
             sumMonthEnd=0
             sumDailyBalan=0  
            sumcheckMiniChan='';
            sumValueAbbPro=0;
            sumValueSummationCredit = 0;
            sumValueSummationDebit = 0;
            sumChangesCountofDebit=0
            sumChangesCountofCredit=0
            sumChangesAverageBankBalance=0
            sumChangesBalanceAt_25th=0
            sumChangesBalanceAt_20th=0
            sumChangesBalanceAt_1st=0
            sumChangesBalanceAt_5th__c=0
            sumChangesBalanceAt_10th=0
            sumChangesBalanceAt_15th=0
            sumInwardReturnsCount=0
            sumOutwardReturnsCount=0
            sumChangesStopPaymentCount=0
            sumMonthlyLimit=0
            for (const record of records) {
                
                if(sumcheckMiniChan ==undefined || sumcheckMiniChan =='N' || sumcheckMiniChan ==''){
                    console.log('this.finalOfMiniAver'+sumcheckMiniChan)
                    sumcheckMiniChan =record.MinBalanceCharges__c == '' ||  record.MinBalanceCharges__c == null ||  record.MinBalanceCharges__c == undefined ? 'N' :  record.MinBalanceCharges__c;
                }
                console.log('recordrecordrecord'+record);
                sumValueAbbPro += record.DailyABBBalance__c == '' ||  record.DailyABBBalance__c == null ||  record.DailyABBBalance__c == undefined ? 0 :  record.DailyABBBalance__c;
                sumValueSummationCredit += record.ValueSummationCredit__c == '' ||  record.ValueSummationCredit__c == null ||  record.ValueSummationCredit__c == undefined ? 0 :  record.ValueSummationCredit__c;
                sumValueSummationDebit += record.ValueSummationDebit__c == '' ||  record.ValueSummationDebit__c == null ||  record.ValueSummationDebit__c == undefined ? 0 :  record.ValueSummationDebit__c;
                sumChangesCountofCredit += record.CountofCredit__c == '' ||  record.CountofCredit__c == null ||  record.CountofCredit__c == undefined ? 0 :  record.CountofCredit__c;
    		    sumChangesCountofDebit += record.CountofDebit__c == '' ||  record.CountofDebit__c == null ||  record.CountofDebit__c == undefined ? 0 :  record.CountofDebit__c;
                // sumChangesAverageBankBalance+= record.AverageBankBalance__c == '' ||  record.AverageBankBalance__c == null ||  record.AverageBankBalance__c == undefined ? 0 :  record.AverageBankBalance__c;
                 sumChangesBalanceAt_25th+= record.BalanceAt_25th__c == '' ||  record.BalanceAt_25th__c == null ||  record.BalanceAt_25th__c == undefined ? 0 :  record.BalanceAt_25th__c;
                 sumChangesBalanceAt_20th+= record.BalanceAt_20th__c == '' ||  record.BalanceAt_20th__c == null ||  record.BalanceAt_20th__c == undefined ? 0 :  record.BalanceAt_20th__c;
                 sumChangesBalanceAt_1st+=   record.BalanceAt_1st__c == '' ||  record.BalanceAt_1st__c == null ||  record.BalanceAt_1st__c == undefined ? 0 :  record.BalanceAt_1st__c;
                 sumChangesBalanceAt_5th__c+=   record.BalanceAt_5th__c == '' ||  record.BalanceAt_5th__c == null ||  record.BalanceAt_5th__c == undefined ? 0 :  record.BalanceAt_5th__c;
                 sumChangesBalanceAt_10th+=record.BalanceAt_10th__c == '' ||  record.BalanceAt_10th__c == null ||  record.BalanceAt_10th__c == undefined ? 0 :  record.BalanceAt_10th__c;
                 sumChangesBalanceAt_15th+= record.BalanceAt_15th__c == '' ||  record.BalanceAt_15th__c == null ||  record.BalanceAt_15th__c == undefined ? 0 :  record.BalanceAt_15th__c;
                 sumInwardReturnsCount+= record.InwardReturnsCount__c == '' ||  record.InwardReturnsCount__c == null ||  record.InwardReturnsCount__c == undefined ? 0 :  record.InwardReturnsCount__c;
                 sumOutwardReturnsCount+= record.OutwardReturnsCount__c == '' ||  record.OutwardReturnsCount__c == null ||  record.OutwardReturnsCount__c == undefined ? 0 :  record.OutwardReturnsCount__c;
                 sumChangesStopPaymentCount+= record.StopPaymentCount__c == '' ||  record.StopPaymentCount__c == null ||  record.StopPaymentCount__c == undefined ? 0 :  record.StopPaymentCount__c;
                 sumMonthlyLimit+= record.MonthlyLimit__c == '' ||  record.MonthlyLimit__c == null ||  record.MonthlyLimit__c == undefined ? 0 :  record.MonthlyLimit__c;
                 sumMonthEnd+= record.Monthend__c == '' ||  record.Monthend__c == null ||  record.Monthend__c == undefined ? 0 :  Math.floor(Number(record.Monthend__c));
                 sumDailyBalan+= record.Average_Daily_Bank_Balance__c == '' ||  record.Average_Daily_Bank_Balance__c == null ||  record.Average_Daily_Bank_Balance__c == undefined ? 0 :  Math.floor(Number(record.Average_Daily_Bank_Balance__c));

            }
            listofRecAfteArddingVals.push({
                monthYear: monthYear,
                sumValueSummationCredit: sumValueSummationCredit,
                sumValueSummationDebit: sumValueSummationDebit,
                sumChangesCountofDebit :	sumChangesCountofDebit,
                sumChangesCountofCredit :	sumChangesCountofCredit, 	 			
                sumChangesAverageBankBalance :	sumChangesAverageBankBalance, 	
                sumChangesBalanceAt_25th :	Math.floor(sumChangesBalanceAt_25th), 	
                sumChangesBalanceAt_20th :	Math.floor(sumChangesBalanceAt_20th), 	
                sumChangesBalanceAt_1st :	 Math.floor(sumChangesBalanceAt_1st), 	
                sumChangesBalanceAt_5th__c :Math.floor(sumChangesBalanceAt_5th__c), 	
                sumChangesBalanceAt_10th :	Math.floor(sumChangesBalanceAt_10th), 	
                sumChangesBalanceAt_15th :Math.floor(sumChangesBalanceAt_15th), 	
                sumInwardReturnsCount :	  sumInwardReturnsCount, 		
                sumOutwardReturnsCount :sumOutwardReturnsCount, 	
                sumChangesStopPaymentCount : sumChangesStopPaymentCount,
                sumcheckMiniChan : sumcheckMiniChan,
                sumMonthlyLimit:sumMonthlyLimit,
                sumValueAbbPro:Math.floor(sumValueAbbPro),
                sumDailyBalan:Math.floor(sumDailyBalan),
                sumMonthEnd:Math.floor(sumMonthEnd)		
            });
            
            }
            return listofRecAfteArddingVals;
    }


    forCreateDataForConsolidateTableSaving(ListOfChildRec){
        const recordsByMonthYearMap = new Map(); 
        ListOfChildRec.forEach(record => {
        const month = record.Month__c; 
        const year = record.Year__c;
         const monthYear = `${month}-${year}`; 
         if (!recordsByMonthYearMap.has(monthYear)) { 
            recordsByMonthYearMap.set(monthYear, []); 
        } 
        recordsByMonthYearMap.get(monthYear).push(record); 
        }); 
        let sumMonthEnd=0
        let sumDailyBalan=0  
        let sumValueAbbPro=0;
        let sumValueSummationCredit = 0;
        let sumValueSummationDebit = 0;
        let sumChangesCountofDebit=0
        let sumChangesCountofCredit=0
        let sumChangesAverageBankBalance=0
        let sumChangesBalanceAt_25th=0
        let sumChangesBalanceAt_20th=0
        let sumChangesBalanceAt_1st=0
        let sumChangesBalanceAt_5th__c=0
        let sumChangesBalanceAt_10th=0
        let sumChangesBalanceAt_15th=0
        let sumInwardReturnsCount=0
        let sumOutwardReturnsCount=0
        let sumChangesStopPaymentCount=0
        let sumMonthlyLimit=0;
        let listofRecAfteArddingVals=[];

        let sumcheckMiniChan='';
        let checkMiniChan=false;
        console.log('recordsByMonthYearMap'+JSON.stringify(recordsByMonthYearMap));
        for (const [monthYear, records] of recordsByMonthYearMap) {
            console.log('[monthYear, records]'+[monthYear, records]);
             sumMonthEnd=0
             sumDailyBalan=0  
            sumcheckMiniChan='';
            sumValueAbbPro=0;
            sumValueSummationCredit = 0;
            sumValueSummationDebit = 0;
            sumChangesCountofDebit=0
            sumChangesCountofCredit=0
            sumChangesAverageBankBalance=0
            sumChangesBalanceAt_25th=0
            sumChangesBalanceAt_20th=0
            sumChangesBalanceAt_1st=0
            sumChangesBalanceAt_5th__c=0
            sumChangesBalanceAt_10th=0
            sumChangesBalanceAt_15th=0
            sumInwardReturnsCount=0
            sumOutwardReturnsCount=0
            sumChangesStopPaymentCount=0
            sumMonthlyLimit=0
            for (const record of records) {
                
                if(sumcheckMiniChan ==undefined || sumcheckMiniChan =='N' || sumcheckMiniChan ==''){
                    console.log('this.finalOfMiniAver'+sumcheckMiniChan)
                    sumcheckMiniChan =record.MinBalanceCharges__c == '' ||  record.MinBalanceCharges__c == null ||  record.MinBalanceCharges__c == undefined ? 'N' :  record.MinBalanceCharges__c;
                }
                console.log('recordrecordrecord'+record);
                sumValueAbbPro += record.DailyABBBalance__c == '' ||  record.DailyABBBalance__c == null ||  record.DailyABBBalance__c == undefined ? 0 :  record.DailyABBBalance__c;
                sumValueSummationCredit += record.ValueSummationCredit__c == '' ||  record.ValueSummationCredit__c == null ||  record.ValueSummationCredit__c == undefined ? 0 :  record.ValueSummationCredit__c;
                sumValueSummationDebit += record.ValueSummationDebit__c == '' ||  record.ValueSummationDebit__c == null ||  record.ValueSummationDebit__c == undefined ? 0 :  record.ValueSummationDebit__c;
                sumChangesCountofCredit += record.CountofCredit__c == '' ||  record.CountofCredit__c == null ||  record.CountofCredit__c == undefined ? 0 :  record.CountofCredit__c;
    		    sumChangesCountofDebit += record.CountofDebit__c == '' ||  record.CountofDebit__c == null ||  record.CountofDebit__c == undefined ? 0 :  record.CountofDebit__c;
                // sumChangesAverageBankBalance+= record.AverageBankBalance__c == '' ||  record.AverageBankBalance__c == null ||  record.AverageBankBalance__c == undefined ? 0 :  record.AverageBankBalance__c;
                
                if(this.product=='Business Loan' ||this.product=='Personal Loan'){
                    if(record.ApplBanking__r.ConsideredForABBProgram__c=='Yes'){
                        sumChangesBalanceAt_25th+= record.BalanceAt_25th__c == '' ||  record.BalanceAt_25th__c == null ||  record.BalanceAt_25th__c == undefined ? 0 :  record.BalanceAt_25th__c;
                        sumChangesBalanceAt_20th+= record.BalanceAt_20th__c == '' ||  record.BalanceAt_20th__c == null ||  record.BalanceAt_20th__c == undefined ? 0 :  record.BalanceAt_20th__c;
                        sumChangesBalanceAt_1st+=   record.BalanceAt_1st__c == '' ||  record.BalanceAt_1st__c == null ||  record.BalanceAt_1st__c == undefined ? 0 :  record.BalanceAt_1st__c;
                        sumChangesBalanceAt_5th__c+=   record.BalanceAt_5th__c == '' ||  record.BalanceAt_5th__c == null ||  record.BalanceAt_5th__c == undefined ? 0 :  record.BalanceAt_5th__c;
                        sumChangesBalanceAt_10th+=record.BalanceAt_10th__c == '' ||  record.BalanceAt_10th__c == null ||  record.BalanceAt_10th__c == undefined ? 0 :  record.BalanceAt_10th__c;
                        sumChangesBalanceAt_15th+= record.BalanceAt_15th__c == '' ||  record.BalanceAt_15th__c == null ||  record.BalanceAt_15th__c == undefined ? 0 :  record.BalanceAt_15th__c;
                        sumDailyBalan+= record.Average_Daily_Bank_Balance__c == '' ||  record.Average_Daily_Bank_Balance__c == null ||  record.Average_Daily_Bank_Balance__c == undefined ? 0 :  Math.floor(Number(record.Average_Daily_Bank_Balance__c));
                    }
                }else{
                    sumChangesBalanceAt_25th+= record.BalanceAt_25th__c == '' ||  record.BalanceAt_25th__c == null ||  record.BalanceAt_25th__c == undefined ? 0 :  record.BalanceAt_25th__c;
                    sumChangesBalanceAt_20th+= record.BalanceAt_20th__c == '' ||  record.BalanceAt_20th__c == null ||  record.BalanceAt_20th__c == undefined ? 0 :  record.BalanceAt_20th__c;
                    sumChangesBalanceAt_1st+=   record.BalanceAt_1st__c == '' ||  record.BalanceAt_1st__c == null ||  record.BalanceAt_1st__c == undefined ? 0 :  record.BalanceAt_1st__c;
                    sumChangesBalanceAt_5th__c+=   record.BalanceAt_5th__c == '' ||  record.BalanceAt_5th__c == null ||  record.BalanceAt_5th__c == undefined ? 0 :  record.BalanceAt_5th__c;
                    sumChangesBalanceAt_10th+=record.BalanceAt_10th__c == '' ||  record.BalanceAt_10th__c == null ||  record.BalanceAt_10th__c == undefined ? 0 :  record.BalanceAt_10th__c;
                    sumChangesBalanceAt_15th+= record.BalanceAt_15th__c == '' ||  record.BalanceAt_15th__c == null ||  record.BalanceAt_15th__c == undefined ? 0 :  record.BalanceAt_15th__c;
                    sumDailyBalan+= record.Average_Daily_Bank_Balance__c == '' ||  record.Average_Daily_Bank_Balance__c == null ||  record.Average_Daily_Bank_Balance__c == undefined ? 0 :  Math.floor(Number(record.Average_Daily_Bank_Balance__c));
                    
                }
                
                sumInwardReturnsCount+= record.InwardReturnsCount__c == '' ||  record.InwardReturnsCount__c == null ||  record.InwardReturnsCount__c == undefined ? 0 :  record.InwardReturnsCount__c;
                 sumOutwardReturnsCount+= record.OutwardReturnsCount__c == '' ||  record.OutwardReturnsCount__c == null ||  record.OutwardReturnsCount__c == undefined ? 0 :  record.OutwardReturnsCount__c;
                 sumChangesStopPaymentCount+= record.StopPaymentCount__c == '' ||  record.StopPaymentCount__c == null ||  record.StopPaymentCount__c == undefined ? 0 :  record.StopPaymentCount__c;
                 sumMonthlyLimit+= record.MonthlyLimit__c == '' ||  record.MonthlyLimit__c == null ||  record.MonthlyLimit__c == undefined ? 0 :  record.MonthlyLimit__c;
                 sumMonthEnd+= record.Monthend__c == '' ||  record.Monthend__c == null ||  record.Monthend__c == undefined ? 0 :  Math.floor(Number(record.Monthend__c));
              //   sumDailyBalan+= record.Average_Daily_Bank_Balance__c == '' ||  record.Average_Daily_Bank_Balance__c == null ||  record.Average_Daily_Bank_Balance__c == undefined ? 0 :  record.Average_Daily_Bank_Balance__c;

            }
            listofRecAfteArddingVals.push({
                monthYear: monthYear,
                sumValueSummationCredit: sumValueSummationCredit,
                sumValueSummationDebit: sumValueSummationDebit,
                sumChangesCountofDebit :	sumChangesCountofDebit,
                sumChangesCountofCredit :	sumChangesCountofCredit, 	 			
                sumChangesAverageBankBalance :	sumChangesAverageBankBalance, 	
                sumChangesBalanceAt_25th :	Math.floor(sumChangesBalanceAt_25th), 	
                sumChangesBalanceAt_20th :	Math.floor(sumChangesBalanceAt_20th), 	
                sumChangesBalanceAt_1st :	 Math.floor(sumChangesBalanceAt_1st), 	
                sumChangesBalanceAt_5th__c :Math.floor(sumChangesBalanceAt_5th__c), 	
                sumChangesBalanceAt_10th :	Math.floor(sumChangesBalanceAt_10th), 	
                sumChangesBalanceAt_15th :Math.floor(sumChangesBalanceAt_15th), 	
                sumInwardReturnsCount :	  sumInwardReturnsCount, 		
                sumOutwardReturnsCount :sumOutwardReturnsCount, 	
                sumChangesStopPaymentCount : sumChangesStopPaymentCount,
                sumcheckMiniChan : sumcheckMiniChan,
                sumMonthlyLimit:Math.floor(sumMonthlyLimit),
                sumValueAbbPro:Math.floor(sumValueAbbPro),
                sumDailyBalan:sumDailyBalan,
                sumMonthEnd:Math.floor(sumMonthEnd)		
            });
            
            }
            return listofRecAfteArddingVals;
    }

    customSort(a, b) {
        const monthYearA = new Date(`${a.monthYear}-01`);
        const monthYearB = new Date(`${b.monthYear}-01`);
        return monthYearB - monthYearA;
    
      }

    calForUtilization(ListOfRecords){
        console.log('calForUtilization');
        ListOfRecords = ListOfRecords.map((record) => {
            if (record.sumChangesAverageBankBalance !=0.00) {
                record["Utilization"] =((record.sumChangesAverageBankBalance * 100) / (this.totalLimitValue)).toFixed(2);
                console.log('record.Utilization'+record.Utilization)
                if(record.Utilization=='Infinity' || typeof this.totalLimitValue ==='undefined' || this.totalLimitValue ==0 || this.totalLimitValue==null ||this.totalLimitValue==''){
                    console.log('insoideeeeeee')
                    record.Utilization=0
                }
            } else {
                record["Utilization"] = 0; // Handle cases where AverageBankBalance__c is 0 or null
            }
            return record;
            
        });
        return ListOfRecords

    }
    calcuForMonLimit(ListOfRecords){
        console.log('calcuForMonLimit'+this.totalLimitValue);
        ListOfRecords = ListOfRecords.map((record) => {
            if (this.totalLimitValue!='' && this.totalLimitValue!=null && typeof this.totalLimitValue!='undefined') {
               record["MonthlyLimit"] =Number(this.totalLimitValue);
            } else {
                record["MonthlyLimit"] = 0; // Handle cases where AverageBankBalance__c is 0 or null
            }
            return record;
            
        });
        return ListOfRecords
    }

    finalOfMinibalanceChar;
    calculationforsum(ListOfRecords){
        ListOfRecords.forEach(record => {
            const sumFields = ['sumChangesBalanceAt_15th','sumChangesBalanceAt_10th', 'sumChangesBalanceAt_5th__c', 'sumChangesBalanceAt_1st', 'sumChangesBalanceAt_20th', 'sumChangesBalanceAt_25th','sumMonthEnd'];
            let sum = 0;
            sumFields.forEach(field => {
                if (record[field] !== null && !isNaN(record[field])) {
                var numberasvar=Number(record[field])
                
                    sum += parseFloat(numberasvar);
            
                }
                
            });
                
            //var sumWithAver=(sum/ListOfRecords.length).toFixed(2)
            var sumWithAver=Math.floor((sum/6).toFixed(2))
            console.log('sumWithAver>>'+sumWithAver)
            if(!isNaN(sumWithAver)){
                console.log('iniffffff')
                record.sumChangesAverageBankBalance = sumWithAver;
            }else{
                console.log('elseeeee')
                record.sumChangesAverageBankBalance=0.00;
            }
            
        });
            return ListOfRecords;
           // this.listofRecAfteArddingVals=ListOfRecords
    }
    BusTransRowsCal={"IandWReturnRatio":0,"12MAverageBalance":0,"OandWReturnRatio":0,"6MAverageBalance":0,"BTOfor12Month":0,"BTOfor6Month":0,"TopLineAsPerFin":0}; 
    calForBusTransRowsCal(ListOfRecords){
        var BusTransRowsCalNew={"IandWReturnRatio":0,"12MAverageBalance":0,"OandWReturnRatio":0,"6MAverageBalance":0,"BTOfor12Month":0,"BTOfor6Month":0,"TopLineAsPerFin":0}; 
        BusTransRowsCalNew.IandWReturnRatio=this.calForTotalAndAverageODC.totalCountofDebit !=0 && this.calForTotalAndAverageODC.totalCountofDebit !='' && this.calForTotalAndAverageODC.totalCountofDebit !=null && this.calForTotalAndAverageODC.totalCountofDebit !=='undefined' ? Math.floor(((this.calForTotalAndAverageODC.totalInwardReturnsCount * 100)/this.calForTotalAndAverageODC.totalCountofDebit).toFixed(2)) :0
        BusTransRowsCalNew.OandWReturnRatio=this.calForTotalAndAverageODC.totalCountofCredit !=0 && this.calForTotalAndAverageODC.totalCountofCredit !='' && this.calForTotalAndAverageODC.totalCountofCredit !=null && this.calForTotalAndAverageODC.totalCountofCredit !=='undefined' ? Math.floor(((this.calForTotalAndAverageODC.totalOutwardReturnsCount * 100 )/this.calForTotalAndAverageODC.totalCountofCredit).toFixed(2)) :0
        console.log('this.totalSalesAmou????'+this.totalSalesAmou)
        BusTransRowsCalNew.TopLineAsPerFin=this.totalSalesAmou;
        BusTransRowsCalNew.BTOfor12Month=this.totalSalesAmou !=0 && this.totalSalesAmou !='' && this.totalSalesAmou !=null && this.totalSalesAmou !=='undefined' ?  Math.floor(((this.calForTotalAndAverageODC.totalValueSummationCredit )*100/this.totalSalesAmou).toFixed(2)) :0
        this.sixMonthTotalCCndOd=this.SixMonthTotalCalforODCC(ListOfRecords);
        BusTransRowsCalNew.BTOfor6Month=this.totalSalesAmou !=0 && this.totalSalesAmou !='' && this.totalSalesAmou !=null && this.totalSalesAmou !=='undefined' ?  Math.floor(((this.sixMonthTotalCCndOd.sixMonthTotalCredit )*100/this.totalSalesAmou).toFixed(2)) :0
        return BusTransRowsCalNew;
    }
    sixMonthTotalCCndOd;
    @track hide12MonthCoDD=false
    @track colHeadForDD='12M Average Balance'
    SixMonthTotalCalforODCC(ListOfRecords){
        var lengthofList=ListOfRecords.length;
        var totalVal=lengthofList*6
        var totalOfAllVal=Number(this.calForTotalAndAverageODC.totalBalanceAt_1st)+Number(this.calForTotalAndAverageODC.totalBalanceAt_5th__c)+Number(this.calForTotalAndAverageODC.totalBalanceAt_10th)+Number(this.calForTotalAndAverageODC.totalBalanceAt_15th)+Number(this.calForTotalAndAverageODC.totalBalanceAt_20th)+Number(this.calForTotalAndAverageODC.totalBalanceAt_25th)
        console.log('totalOfAllVal'+totalOfAllVal);
        console.log('totalVal'+totalVal)
        var sixMonthTotal ={"sixMonthTotalCredit":0,"allTotalForbal":0,"SixMonTotalForbal":0}; 
        //sixMonthTotal.allTotalForbal=Number(this.calForTotalAndAverageODC.averageBalanceAt_1st) + Number(this.calForTotalAndAverageODC.averageBalanceAt_5th__c) + Number(this.calForTotalAndAverageODC.averageBalanceAt_10th) +Number(this.calForTotalAndAverageODC.averageBalanceAt_15th) +Number(this.calForTotalAndAverageODC.averageBalanceAt_20th) +Number(this.calForTotalAndAverageODC.averageBalanceAt_25th)
        if(lengthofList<12){
            sixMonthTotal.allTotalForbal=''
            this.hide12MonthCoDD=true;
            this.colHeadForDD=''
        }else{
            sixMonthTotal.allTotalForbal=Math.floor((totalOfAllVal/totalVal).toFixed(2))
        }
        //sixMonthTotal.allTotalForbal=(totalOfAllVal/totalVal).toFixed(2)
        var i=0
        var j=0
        var sumOfSixMonth={"sumOfSixMonthFor1":0,"sumOfSixMonthFor5":0,"sumOfSixMonthFor10":0,"sumOfSixMonthFor15":0,"sumOfSixMonthFor20":0,"sumOfSixMonthFor25":0}; 
        for(const record of ListOfRecords){
            if(i<6){
                console.log('>>>>>>'+record.sumChangesAverageBankBalance)
                sixMonthTotal.sixMonthTotalCredit+=record.sumValueSummationCredit;
                sumOfSixMonth.sumOfSixMonthFor1 += Number(record.sumChangesAverageBankBalance)
                /*sumOfSixMonth.sumOfSixMonthFor1 += record.sumChangesBalanceAt_1st
                sumOfSixMonth.sumOfSixMonthFor5 += record.sumChangesBalanceAt_5th__c
                sumOfSixMonth.sumOfSixMonthFor10 += record.sumChangesBalanceAt_10th
                sumOfSixMonth.sumOfSixMonthFor15 += record.sumChangesBalanceAt_15th
                sumOfSixMonth.sumOfSixMonthFor20 += record.sumChangesBalanceAt_20th
                sumOfSixMonth.sumOfSixMonthFor25 += record.sumChangesBalanceAt_25th*/
                j++
            }
            i++
        }
        console.log('////////////////'+sumOfSixMonth.sumOfSixMonthFor1)
        sixMonthTotal.SixMonTotalForbal =Math.floor((sumOfSixMonth.sumOfSixMonthFor1/j).toFixed(2))
        //sixMonthTotal.SixMonTotalForbal=sumOfSixMonth.sumOfSixMonthFor1 +sumOfSixMonth.sumOfSixMonthFor5 + sumOfSixMonth.sumOfSixMonthFor10 +sumOfSixMonth.sumOfSixMonthFor15+sumOfSixMonth.sumOfSixMonthFor20 + sumOfSixMonth.sumOfSixMonthFor25;
        //sixMonthTotal.SixMonTotalForbal =(sixMonthTotal.SixMonTotalForbal/6).toFixed(2)
        return sixMonthTotal;
    }
    
    BusTransRowsCalforSav={"IandWReturnRatio":0,"12MAverageBalance":0,"OandWReturnRatio":0,"6MAverageBalance":0,"BTOfor12Month":0,"BTOfor6Month":0,"TopLineAsPerFin":0}; 
    calForBusTransRowsCalforSav(ListOfRecords){
        var BusTransRowsCalNew={"IandWReturnRatio":0,"12MAverageBalance":0,"OandWReturnRatio":0,"6MAverageBalance":0,"BTOfor12Month":0,"BTOfor6Month":0,"TopLineAsPerFin":0}; 
        BusTransRowsCalNew.IandWReturnRatio=this.calForTotalAndAverageSav.totalCountofDebit !=0 && this.calForTotalAndAverageSav.totalCountofDebit !='' && this.calForTotalAndAverageSav.totalCountofDebit !=null && this.calForTotalAndAverageSav.totalCountofDebit !=='undefined' ?  Math.floor(((this.calForTotalAndAverageSav.totalInwardReturnsCount * 100)/this.calForTotalAndAverageSav.totalCountofDebit).toFixed(2)) :0
        BusTransRowsCalNew.OandWReturnRatio=this.calForTotalAndAverageSav.totalCountofCredit !=0 && this.calForTotalAndAverageSav.totalCountofCredit !='' && this.calForTotalAndAverageSav.totalCountofCredit !=null && this.calForTotalAndAverageSav.totalCountofCredit !=='undefined' ? Math.floor(((this.calForTotalAndAverageSav.totalOutwardReturnsCount * 100 )/this.calForTotalAndAverageSav.totalCountofCredit).toFixed(2)) :0
        console.log('this.totalSalesAmou>>>>>'+this.totalSalesAmou)
        BusTransRowsCalNew.TopLineAsPerFin=this.totalSalesAmou;
        BusTransRowsCalNew.BTOfor12Month=this.totalSalesAmou !=0 && this.totalSalesAmou !='' && this.totalSalesAmou !=null && this.totalSalesAmou !=='undefined' ?  Math.floor(((this.calForTotalAndAverageSav.totalValueSummationCredit )*100/this.totalSalesAmou).toFixed(2)) :0
        this.sixMonthTotalSavNDjoint=this.SixMonthTotalCalforSavJoint(ListOfRecords);
        BusTransRowsCalNew.BTOfor6Month=this.totalSalesAmou !=0 && this.totalSalesAmou !='' && this.totalSalesAmou !=null && this.totalSalesAmou !=='undefined' ?  Math.floor(((this.sixMonthTotalSavNDjoint.sixMonthTotalCredit )*100/this.totalSalesAmou).toFixed(2)) :0
        return BusTransRowsCalNew;
    }
    sixMonthTotalSavNDjoint;
    @track hide12MonthColSav=false
    @track colHeadForSav='12M Average Balance'
    SixMonthTotalCalforSavJoint(ListOfRecords){
        var lengthofList=ListOfRecords.length;
        var totalVal=lengthofList*6
        var totalOfAllVal=Number(this.calForTotalAndAverageSav.totalBalanceAt_1st)+Number(this.calForTotalAndAverageSav.totalBalanceAt_5th__c)+Number(this.calForTotalAndAverageSav.totalBalanceAt_10th)+Number(this.calForTotalAndAverageSav.totalBalanceAt_15th)+Number(this.calForTotalAndAverageSav.totalBalanceAt_20th)+Number(this.calForTotalAndAverageSav.totalBalanceAt_25th)
        var sixMonthTotal ={"sixMonthTotalCredit":0,"allTotalForbal":0,"SixMonTotalForbal":0}; 
       
        //sixMonthTotal.allTotalForbal=(totalOfAllVal/totalVal).toFixed(2)
        if(lengthofList<12){
            sixMonthTotal.allTotalForbal=''
            this.hide12MonthColSav=true;
            this.colHeadForSav=''
        }else{
            sixMonthTotal.allTotalForbal=Math.floor((totalOfAllVal/totalVal).toFixed(2))
        }

       // var sixMonthTotal ={"sixMonthTotalCredit":0,"allTotalForbal":0,"SixMonTotalForbal":0}; 
       // sixMonthTotal.allTotalForbal=Number(this.calForTotalAndAverageSav.averageBalanceAt_1st)+ Number(this.calForTotalAndAverageSav.averageBalanceAt_5th__c) + Number(this.calForTotalAndAverageSav.averageBalanceAt_10th) +Number(this.calForTotalAndAverageSav.averageBalanceAt_15th) +Number(this.calForTotalAndAverageSav.averageBalanceAt_20th) +Number(this.calForTotalAndAverageSav.averageBalanceAt_25th)
        var i=0
        var j=0
        var sumOfSixMonth={"sumOfSixMonthFor1":0,"sumOfSixMonthFor5":0,"sumOfSixMonthFor10":0,"sumOfSixMonthFor15":0,"sumOfSixMonthFor20":0,"sumOfSixMonthFor25":0}; 
        for(const record of ListOfRecords){
            if(i<6){
                sixMonthTotal.sixMonthTotalCredit+=record.sumValueSummationCredit;
                sumOfSixMonth.sumOfSixMonthFor1 += Number(record.sumChangesAverageBankBalance)
                /*sumOfSixMonth.sumOfSixMonthFor1 += record.sumChangesBalanceAt_1st
                sumOfSixMonth.sumOfSixMonthFor5 += record.sumChangesBalanceAt_5th__c
                sumOfSixMonth.sumOfSixMonthFor10 += record.sumChangesBalanceAt_10th
                sumOfSixMonth.sumOfSixMonthFor15 += record.sumChangesBalanceAt_15th
                sumOfSixMonth.sumOfSixMonthFor20 += record.sumChangesBalanceAt_20th
                sumOfSixMonth.sumOfSixMonthFor25 += record.sumChangesBalanceAt_25th*/
                j++
            }
            i++
        }
        //console.log('totlValFor6'+sumOfSixMonth.sumOfSixMonthFor1)
        //sixMonthTotal.SixMonTotalForbal=sumOfSixMonth.sumOfSixMonthFor1 +sumOfSixMonth.sumOfSixMonthFor5 + sumOfSixMonth.sumOfSixMonthFor10 +sumOfSixMonth.sumOfSixMonthFor15+sumOfSixMonth.sumOfSixMonthFor20 + sumOfSixMonth.sumOfSixMonthFor25;
        //sixMonthTotal.SixMonTotalForbal =(sixMonthTotal.SixMonTotalForbal/6).toFixed(2)
        sixMonthTotal.SixMonTotalForbal =Math.floor((sumOfSixMonth.sumOfSixMonthFor1/j).toFixed(2))
        return sixMonthTotal;
    }



   // forTotalAndAverage={"totalValueSummationDebit":0,"finalOfMinibalanceChar":'N',"totalValueSummationCredit":0,"totalCountofCredit":0,"totalCountofDebit":0,"totalInwardReturnsCount":0,"totalOutwardReturnsCount":0,"totalStopPaymentCount":0,"totalBalanceAt_1st":0,"totalBalanceAt_5th__c":0,"totalBalanceAt_10th":0,"totalBalanceAt_15th":0,"totalBalanceAt_20th":0,"totalBalanceAt_25th":0,"totalAverageBankBalance":0,"averageValueSummationCredit":0,"averageValueSummationDebit":0,"averageCountofCredit":0,"averageCountofDebit":0,"averageInwardReturnsCount":0,"averageOutwardReturnsCount":0,"averageStopPaymentCount":0,"averageBalanceAt_1st":0,"averageBalanceAt_5th__c":0,"averageBalanceAt_10th":0,"averageBalanceAt_15th":0,"averageBalanceAt_20th":0,"averageBalanceAt_25th":0,"averageAverageBankBalance":0};  
    calForTotalAndAverage(ListOfRecords,lengthOfData){
        var forTotalAndAverage={"totalValueMonLimit":0,"averageMonLimit":0,"totalValueSummationDebit":0,"finalOfMinibalanceChar":'N',"totalValueSummationCredit":0,"totalCountofCredit":0,"totalCountofDebit":0,"totalInwardReturnsCount":0,"totalOutwardReturnsCount":0,"totalStopPaymentCount":0,"totalBalanceAt_1st":0,"totalBalanceAt_5th__c":0,"totalBalanceAt_10th":0,"totalBalanceAt_15th":0,"totalBalanceAt_20th":0,"totalBalanceAt_25th":0,"totalAverageBankBalance":0,"averageValueSummationCredit":0,"averageValueSummationDebit":0,"averageCountofCredit":0,"averageCountofDebit":0,"averageInwardReturnsCount":0,"averageOutwardReturnsCount":0,"averageStopPaymentCount":0,"averageBalanceAt_1st":0,"averageBalanceAt_5th__c":0,"averageBalanceAt_10th":0,"averageBalanceAt_15th":0,"averageBalanceAt_20th":0,"averageBalanceAt_25th":0,"averageAverageBankBalance":0,"totalForConAbbPro":0,"averForConAbbPro":0, "AvermonthEnd":0, "AverDailyBala":0, "totalMonthEnd":0, "TotalDailyBala":0};  
        let i=0;
        //console.log('ListOfRecordnewwws>>>>>>>'+JSON.stringify(ListOfRecords));
        let sumcheckMiniChan='';
        console.log('lengthOfData'+lengthOfData)
        let checkMiniChan=false;
        for (const record of ListOfRecords) {
            var fortoal={}
            if(sumcheckMiniChan ==undefined || sumcheckMiniChan =='N' || sumcheckMiniChan ==''){
               sumcheckMiniChan =record.sumcheckMiniChan == '' ||  record.sumcheckMiniChan == null ||  record.sumcheckMiniChan == undefined ? 'N' :  record.sumcheckMiniChan;
            }
            forTotalAndAverage.finalOfMinibalanceChar=sumcheckMiniChan
            forTotalAndAverage.totalValueSummationCredit += Math.floor(record.sumValueSummationCredit);
            forTotalAndAverage.totalValueSummationDebit += Math.floor(record.sumValueSummationDebit);
            forTotalAndAverage.totalCountofCredit += Math.floor(record.sumChangesCountofCredit);
            forTotalAndAverage.totalCountofDebit += Math.floor(record.sumChangesCountofDebit);
            forTotalAndAverage.totalInwardReturnsCount += Math.floor(record.sumInwardReturnsCount)
            forTotalAndAverage.totalOutwardReturnsCount += Math.floor(record.sumOutwardReturnsCount)
            forTotalAndAverage.totalStopPaymentCount += Math.floor(record.sumChangesStopPaymentCount)
            forTotalAndAverage.totalBalanceAt_1st += Math.floor(record.sumChangesBalanceAt_1st)
            forTotalAndAverage.totalBalanceAt_5th__c += Math.floor(record.sumChangesBalanceAt_5th__c)
            forTotalAndAverage.totalBalanceAt_10th += Math.floor(record.sumChangesBalanceAt_10th)
            forTotalAndAverage.totalBalanceAt_15th += Math.floor(record.sumChangesBalanceAt_15th)
            forTotalAndAverage.totalBalanceAt_20th += Math.floor(record.sumChangesBalanceAt_20th)
            forTotalAndAverage.totalBalanceAt_25th += Math.floor(record.sumChangesBalanceAt_25th)
            forTotalAndAverage.totalAverageBankBalance += Math.floor(Number(record.sumChangesAverageBankBalance))
            forTotalAndAverage.totalForConAbbPro += Math.floor(Number(record.sumValueAbbPro))
            forTotalAndAverage.totalMonthEnd += Math.floor(record.sumMonthEnd)
            forTotalAndAverage.TotalDailyBala += Math.floor(record.sumDailyBalan)
            
            console.log('forTotalAndAverage.totalAverageBankBalance'+forTotalAndAverage.totalAverageBankBalance.toFixed(2))
            forTotalAndAverage.totalValueMonLimit += Number(record.sumMonthlyLimit)

            forTotalAndAverage.averageValueSummationCredit =Math.floor((forTotalAndAverage.totalValueSummationCredit / lengthOfData).toFixed(2));
            forTotalAndAverage.averageValueSummationDebit = Math.floor((forTotalAndAverage.totalValueSummationDebit / lengthOfData).toFixed(2));
            forTotalAndAverage.averageCountofCredit =  Math.floor((forTotalAndAverage.totalCountofCredit / lengthOfData).toFixed(2));
            forTotalAndAverage.averageCountofDebit = Math.floor((forTotalAndAverage.totalCountofDebit / lengthOfData).toFixed(2));
            forTotalAndAverage.averageInwardReturnsCount =Math.floor((forTotalAndAverage.totalInwardReturnsCount / lengthOfData).toFixed(2));
            forTotalAndAverage.averageOutwardReturnsCount =  Math.floor((forTotalAndAverage.totalOutwardReturnsCount / lengthOfData).toFixed(2));
            forTotalAndAverage.averageStopPaymentCount = Math.floor((forTotalAndAverage.totalStopPaymentCount / lengthOfData).toFixed(2));
            forTotalAndAverage.averageBalanceAt_1st = Math.floor((forTotalAndAverage.totalBalanceAt_1st / lengthOfData).toFixed(2));
            forTotalAndAverage.averageBalanceAt_5th__c = Math.floor((forTotalAndAverage.totalBalanceAt_5th__c / lengthOfData).toFixed(2));
            forTotalAndAverage.averageBalanceAt_10th = Math.floor((forTotalAndAverage.totalBalanceAt_10th / lengthOfData).toFixed(2));
            forTotalAndAverage.averageBalanceAt_15th = Math.floor((forTotalAndAverage.totalBalanceAt_15th / lengthOfData).toFixed(2));
            forTotalAndAverage.averageBalanceAt_20th = Math.floor((forTotalAndAverage.totalBalanceAt_20th / lengthOfData).toFixed(2));
            forTotalAndAverage.averageBalanceAt_25th = Math.floor((forTotalAndAverage.totalBalanceAt_25th / lengthOfData).toFixed(2));
            forTotalAndAverage.averageAverageBankBalance = Math.floor((forTotalAndAverage.totalAverageBankBalance / lengthOfData).toFixed(2));
            forTotalAndAverage.averForConAbbPro = Math.floor((forTotalAndAverage.totalForConAbbPro / lengthOfData).toFixed(2));
            forTotalAndAverage.averageOfUtilization= forTotalAndAverage.averageAverageBankBalance !=''&& forTotalAndAverage.averageAverageBankBalance !=null && typeof forTotalAndAverage.averageAverageBankBalance !==undefined  ? Math.floor(((forTotalAndAverage.averageAverageBankBalance * 100) /this.totalLimitValue ).toFixed(2)) : 0
            forTotalAndAverage.averageMonLimit = Math.floor((forTotalAndAverage.totalValueMonLimit / lengthOfData).toFixed(2));
            forTotalAndAverage.AvermonthEnd = Math.floor((forTotalAndAverage.totalMonthEnd / lengthOfData).toFixed(2));
            forTotalAndAverage.AverDailyBala = Math.floor((forTotalAndAverage.TotalDailyBala / lengthOfData).toFixed(2));
        }
        
        forTotalAndAverage.totalAverageBankBalance=Math.floor(forTotalAndAverage.totalAverageBankBalance.toFixed(2))
        console.log('forTotalAndAverage'+JSON.stringify(forTotalAndAverage));
        return forTotalAndAverage;
    }

   @api showUi=false
    @api
    checkShowtable(){
        refreshApex(this._wiredForOverDraftCca);
        refreshApex(this._wiredForSvinJointCa);
        console.log('this.listOfOverDraftCcAdd.length>>>1>1'+this.listOfOverDraftCcAdd.length);
        console.log('this.listOfSvinJointCaAdd.length>>>1>1'+this.listOfSvinJointCaAdd.length);
        if(this.listOfOverDraftCcAdd.length>0 || this.listOfSvinJointCaAdd.length >0){
            this.showUi=true
            return true;
            
        }else{
            this.showUi=false
            return false;
           
        }
    }

    @api
    refresewireMethods(){
        refreshApex(this._wiredForOverDraftCca);
        refreshApex(this._wiredForSvinJointCa);
    }
    handleDeleteAppDetail(listtodeleteRec){
        console.log('indelete');
        deleteRecord({ rcrds: listtodeleteRec })
            .then(result => {
               console.log('resultresultresultresult'+result)
            })
            .catch(error => {
                console.error(error);
            });
    }
}