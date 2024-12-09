import { LightningElement, api,track,wire } from 'lwc';
import getData from '@salesforce/apex/SObjectDynamicRecordProvider.getAllSobjectDatawithRelatedRecords';
import { refreshApex } from '@salesforce/apex';
import getDataForFilterChild from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithFilterRelatedRecords';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { createRecord,updateRecord } from "lightning/uiRecordApi";
import deleteRecord from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';
import APPLBANKING_OBJECT from '@salesforce/schema/ApplBanking__c';
import updateData from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import { getRecord, getObjectInfo , getPicklistValuesByRecordType} from 'lightning/uiObjectInfoApi';
export default class ShowAllBankingDetailConsolidateData extends LightningElement {
    allDataofApplicant;
    listofRecAfteArddingVals;
    _allApplicantData;
    listOfOverDraftCcAdd=[];
    listOfSvinJointCaAdd=[];
    params;
    CheckIdLength=true;
    showtableforSav=true;
    showTableForCC=true;
    ceckForOdCc=true;
    _idsForOverDraftCca=[]
    _idsForSvinJointCa=[]
    paramsforSav;
    @api
    get allApplicantData(){
        return this._allApplicantData;
    }

    set allApplicantData(value){
        this._allApplicantData = value;
    }
    
    @api
    get idsForOverDraftCca(){
        return this._idsForOverDraftCca;
    }
    set idsForOverDraftCca(value){
        this._idsForOverDraftCca = value;  
        console.log('this._idsForOverDraftCca'+this._idsForOverDraftCca); 
        if(this._idsForOverDraftCca !=null && this._idsForOverDraftCca !='' && typeof this._idsForOverDraftCca !== undefined){
            this.params ={
                ParentObjectName:'ApplBanking__c',
                ChildObjectRelName:'Applicant_Banking_Detail__r',
                parentObjFields:[  'Id', 'Limit__c','SumofMonthlyAverageBalance__c','LimitUtilisation__c','AverageBankBalance__c','Appl__r.TabName__c','SFDC_Bank_Master_Name__c','Appl__c', 'LoanAppl__c', 'Name_of_the_Primary_Account_Holder_s__c', 'OtherBankName__c', 'AccountType__c', 'FileType__c', 'SalaryAccount__c', 'DocumentDetail__c', 'BankName__c', 'BankId__c', 'JointAccountHoldersName__c', 'AC_No__c', 'IsThereChangeInLimitDuringThePeri__c', 'AverageLimitDuringThePeriod__c', 'LatestMonthForWhichBankStatementIs__c', 'PeriodOfBankingStart__c', 'PeriodOfBankingEnd__c', 'Repayment_bank_A_c__c', 'Bank_Branch__c', 'MICR_Code__c', 'eNACH_feasible__c'],
                childObjFields:['ApplBanking__c','Monthend__c','Average_Daily_Bank_Balance__c', 'DailyABBBalance__c','MonthlyLimit__c','Id', 'Name', 'Month__c', 'Year__c', 'ValueSummationCredit__c', 'ValueSummationDebit__c', 'CountofCredit__c', 'CountofDebit__c', 'InwardReturnsCount__c', 'OutwardReturnsCount__c', 'StopPaymentCount__c', 'MinBalanceCharges__c', 'BalanceAt_1st__c', 'BalanceAt_5th__c', 'BalanceAt_10th__c', 'BalanceAt_15th__c', 'BalanceAt_20th__c', 'BalanceAt_25th__c', 'AverageBankBalance__c'],        
                queryCriteria:' WHERE ID IN (\''+this._idsForOverDraftCca.join('\', \'') + '\') AND Type__c = \'\' AND IsDeleted__c != true'
                //queryCriteria: ' WHERE ID IN (\''+this._idsForOverDraftCca.join('\', \'') + '\')'
            }
        }else{
            this.showTableForCC=false;
            this.ceckForOdCc=false
        } 
            
    }
    
    @api
    get idsForSvinJointCa(){
        return this._idsForSvinJointCa;
    }
    set idsForSvinJointCa(value){
        console.log('this.idsForSvinJointCa'+value);   
        this._idsForSvinJointCa = value;  
        console.log('????????????????'+this._idsForSvinJointCa);
        if(this._idsForSvinJointCa !=null && this._idsForSvinJointCa !='' && typeof this._idsForSvinJointCa !== undefined){

            this.paramsforSav ={
                ParentObjectName:'ApplBanking__c',
                ChildObjectRelName:'Applicant_Banking_Detail__r',
                parentObjFields:[  'Id','Appl__r.TabName__c', 'ConsideredForABBProgram__c','LoanAppl__r.product__c','Appl__c', 'LoanAppl__c', 'Name_of_the_Primary_Account_Holder_s__c', 'OtherBankName__c', 'AccountType__c', 'FileType__c', 'SalaryAccount__c', 'DocumentDetail__c', 'BankName__c', 'BankId__c', 'JointAccountHoldersName__c', 'AC_No__c', 'IsThereChangeInLimitDuringThePeri__c', 'AverageLimitDuringThePeriod__c', 'LatestMonthForWhichBankStatementIs__c', 'PeriodOfBankingStart__c', 'PeriodOfBankingEnd__c', 'Repayment_bank_A_c__c', 'Bank_Branch__c', 'MICR_Code__c', 'eNACH_feasible__c'],
                childObjFields:['ApplBanking__c','ApplBanking__r.ConsideredForABBProgram__c','Monthend__c','Average_Daily_Bank_Balance__c', 'DailyABBBalance__c','MonthlyLimit__c','Id', 'Name', 'Month__c', 'Year__c', 'ValueSummationCredit__c', 'ValueSummationDebit__c', 'CountofCredit__c', 'CountofDebit__c', 'InwardReturnsCount__c', 'OutwardReturnsCount__c', 'StopPaymentCount__c', 'MinBalanceCharges__c', 'BalanceAt_1st__c', 'BalanceAt_5th__c', 'BalanceAt_10th__c', 'BalanceAt_15th__c', 'BalanceAt_20th__c', 'BalanceAt_25th__c', 'AverageBankBalance__c'],        
                queryCriteria:' WHERE ID IN (\''+this._idsForSvinJointCa.join('\', \'') + '\') AND Type__c = \'\' AND IsDeleted__c != true'
            
            } 
        }else{
            this.showtableforSav=false
            this.CheckIdLength=false
        }     
           
    }
    connectedCallback(){
        
    }
    _wiredForOverDraftCca
    totalLimitValue=0;
    loanAppId
    listOfAppBankForccOD;
    @wire(getData,{params:'$params'})
    ForOverDraftCca(wiredForOverDraftCca) {
        
        const { data, error } = wiredForOverDraftCca;
        this._wiredForOverDraftCca = wiredForOverDraftCca;
        console.log('ForOverDraftCca>>>>>>>',this._wiredForOverDraftCca);
        let listOfAllChildReco=[];
        let listOfParentForccODnew=[];
        let i=0
        let j=1
        if (data) {
            for(const record of data){
                //listOfParentForccOD.push(record);
                this.loanAppId=record.parentRecord.LoanAppl__c;
                console.log('record.parentRecord.Appl__r'+record.parentRecord.Id)
                if(typeof record.parentRecord.Appl__c!=='undefined'){
                   
                }else{
                    record[record.parentRecord.Appl__r.TabName__c]=''
                }
                //console.log('>>>>>>>>>>>>record2'+JSON.stringify(record))
                listOfParentForccODnew.push(record.parentRecord)
                listOfParentForccODnew[i] = { ...listOfParentForccODnew[i], Index1: j};
                i++
                j++
                //console.log('recordrecord'+record);
                if(record.parentRecord.Limit__c != null && record.parentRecord.Limit__c!='' && record.parentRecord.Limit__c!='undefined'){
                    this.totalLimitValue +=Number(record.parentRecord.Limit__c)
                }
                if(record.ChildReords && record.ChildReords != undefined){
                    for(const childRec of record.ChildReords){
                        if(childRec.Month__c && childRec.Year__c){
                            listOfAllChildReco.push(childRec);
                        }
                        
                    }
                }
             }
             if(listOfAllChildReco.length==0){
                this.showTableForCC=false;
             }
             
             //console.log('this.totalLimitValue'+this.totalLimitValue)
           var listODCcaArddingVals=[];
           listODCcaArddingVals = this.forCreateDataForConsolidateTable(listOfAllChildReco);
           this.listOfOverDraftCcAdd=listODCcaArddingVals;
           this.listOfAppBankForccOD=listOfParentForccODnew;
           console.log(' this.listOfAppBankForccOD'+JSON.stringify(this.listOfAppBankForccOD));
           this.sortRecordsDescending(this.listOfAppBankForccOD);
           //console.log('this.listOfOverDraftCcAdd>>>>>>'+JSON.stringify(this.listOfOverDraftCcAdd))
           this.listOfOverDraftCcAdd.sort(this.customSort);
           this.listOfOverDraftCcAdd =this.calculationforsum(this.listOfOverDraftCcAdd);
           this.listOfOverDraftCcAdd =this.calForUtilization(this.listOfOverDraftCcAdd);
           //this.listOfOverDraftCcAdd=this.calcuForMonLimit(this.listOfOverDraftCcAdd);
            let lengthOfList = this.listOfOverDraftCcAdd.length;
            if(lengthOfList>0){
                this.handleODndCCRecSave();
            }
            this.calForTotalAndAverageODC=this.calForTotalAndAverage(this.listOfOverDraftCcAdd,lengthOfList);
            //console.log('this.calForTotalAndAverage'+JSON.stringify(this.calForTotalAndAverageODC))
               
        } else if (error) {
            console.log('error>>>>>>>',error);
        }
    }

    sortRecordsDescending(ParentRec) {
        ParentRec.sort((a, b) => {
            const dateA = new Date(a.PeriodOfBankingStart__c);
            const dateB = new Date(b.PeriodOfBankingStart__c);
            return dateB - dateA; // Sort in descending order
        });
    }

    calForTotalAndAverageODC ={"totalValueSummationDebit":0,"finalOfMinibalanceChar":'N',"totalValueSummationCredit":0,"totalCountofCredit":0,"totalCountofDebit":0,"totalInwardReturnsCount":0,"totalOutwardReturnsCount":0,"totalStopPaymentCount":0,"totalBalanceAt_1st":0,"totalBalanceAt_5th__c":0,"totalBalanceAt_10th":0,"totalBalanceAt_15th":0,"totalBalanceAt_20th":0,"totalBalanceAt_25th":0,"totalAverageBankBalance":0,"averageValueSummationCredit":0,"averageValueSummationDebit":0,"averageCountofCredit":0,"averageCountofDebit":0,"averageInwardReturnsCount":0,"averageOutwardReturnsCount":0,"averageStopPaymentCount":0,"averageBalanceAt_1st":0,"averageBalanceAt_5th__c":0,"averageBalanceAt_10th":0,"averageBalanceAt_15th":0,"averageBalanceAt_20th":0,"averageBalanceAt_25th":0,"averageAverageBankBalance":0,"totalForConAbbPro":0,"averForConAbbPro":0};  ;
    calForTotalAndAverageSav={"totalValueSummationDebit":0,"finalOfMinibalanceChar":'N',"totalValueSummationCredit":0,"totalCountofCredit":0,"totalCountofDebit":0,"totalInwardReturnsCount":0,"totalOutwardReturnsCount":0,"totalStopPaymentCount":0,"totalBalanceAt_1st":0,"totalBalanceAt_5th__c":0,"totalBalanceAt_10th":0,"totalBalanceAt_15th":0,"totalBalanceAt_20th":0,"totalBalanceAt_25th":0,"totalAverageBankBalance":0,"averageValueSummationCredit":0,"averageValueSummationDebit":0,"averageCountofCredit":0,"averageCountofDebit":0,"averageInwardReturnsCount":0,"averageOutwardReturnsCount":0,"averageStopPaymentCount":0,"averageBalanceAt_1st":0,"averageBalanceAt_5th__c":0,"averageBalanceAt_10th":0,"averageBalanceAt_15th":0,"averageBalanceAt_20th":0,"averageBalanceAt_25th":0,"averageAverageBankBalance":0,"totalForConAbbPro":0,"averForConAbbPro":0};  ;
    _wiredForSvinJointCa
    listOfParentForSav;
    product;
    @wire(getData,{params:'$paramsforSav'})
    ForSvinJointCa(wiredForSvinJointCa) {
        const { data, error } = wiredForSvinJointCa;
        this._wiredForSvinJointCa = wiredForSvinJointCa;
        //console.log('this._wiredFForSvinJointCa',this._wiredForSvinJointCa);
        let listOfAllChildReco=[];
        let listOfParentForSavnew=[];
        let i=0
        let j=1
        
        if (data) {
            
            for(const record of data){
                this.loanAppId=record.parentRecord.LoanAppl__c;
                this.product=record.parentRecord.LoanAppl__r.Product__c
                if(typeof record.parentRecord.Appl__c!=='undefined'){
                   
                }else{
                    record[record.parentRecord.Appl__r.TabName__c]=''
                }
                console.log('>>>>>>>>>>>>record1'+JSON.stringify(record))
                listOfParentForSavnew.push(record.parentRecord)
                listOfParentForSavnew[i] = { ...listOfParentForSavnew[i], Index1: j};
                i++
                j++
                //console.log('ForSvinJointCa'+JSON.stringify(record))
                if(record.ChildReords && record.ChildReords != undefined){
                    for(const childRec of record.ChildReords){
                        if(childRec.Month__c && childRec.Year__c){
                            listOfAllChildReco.push(childRec);
                        }
                       
                    }
                }
            }
           var listSvinJointCaArddingVals=[];
           if(listOfAllChildReco.length==0){
            this.showtableforSav=false;
        }
           listSvinJointCaArddingVals = this.forCreateDataForConsolidateTableSaving(listOfAllChildReco);
           this.listOfSvinJointCaAdd=listSvinJointCaArddingVals
           this.listOfParentForSav=listOfParentForSavnew
           console.log('this.listOfParentForSav'+JSON.stringify(this.listOfParentForSav))
           this.sortRecordsDescending(this.listOfParentForSav)
           this.listOfSvinJointCaAdd.sort(this.customSort);
           this.listOfSvinJointCaAdd=this.calculationforsum(this.listOfSvinJointCaAdd);
            let lengthOfList = this.listOfSvinJointCaAdd.length;
            if(lengthOfList>0){
                console.log('15666')
                this.handleSavJoinCurreRecSave();
            }

           this.calForTotalAndAverageSav= this.calForTotalAndAverage(this.listOfSvinJointCaAdd,lengthOfList);
            //console.log('this.calForTotalAndAverageSav'+JSON.stringify(this.calForTotalAndAverageSav))
               
        } else if (error) {
            console.log('error******0', error);
        }
    }

    handleODndCCRecSave(){
        var listToDeleteRec=[];
        var ListForUpsertRec=[];
        var appliBnkReForConNew={"LoanAppl__c":this.loanAppId,"Summary_Type__c":"Combined Banking (OD/CC)","Type__c":"Consolidated Banking Summary"}
        let paramsODCC={
            ParentObjectName:'LoanAppl__c',
            ChildObjectRelName:'Applicant_Banking1__r',
            parentObjFields:['Id'],
            childObjFields:['Id','Summary_Type__c','Type__c','Repayment_bank_A_c__c','SumofMonthlyAverageBalance__c','SFDC_Bank_Master_Name__c','SFDCBankMaster__r.BankName__c','BankName__c','AccountType__c','FileType__c','DocumentDetail__c','DocumentDetail__r.DocTyp__c','SalaryAccount__c','DocumentDetail__r.Content_Document_Id__c','DocumentDetail__r.DocSubTyp__c'],        
            queryCriteriaForChild: ' WHERE Type__c = \'Consolidated Banking Summary\' AND Summary_Type__c = \'Combined Banking (OD/CC)\'',   
            queryCriteria: ' where Id= \'' + this.loanAppId + '\''
        }
        getDataForFilterChild({ params: paramsODCC })
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
                console.log('Errorured:- '+JSON.stringify(error));
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
            parentObjFields:[  'Id', 'Appl__c', 'SumofMonthlyAverageBalance__c','eNACHFeasible__c','SFDC_Bank_Master_Name__c','NACHFeasible__c','SFDCBankMaster__r.BankName__c','LoanAppl__c','IFSC_Code__c','Limit__c', 'Name_of_the_Primary_Account_Holder_s__c', 'OtherBankName__c', 'AccountType__c', 'FileType__c', 'SalaryAccount__c', 'DocumentDetail__c', 'BankName__c', 'BankId__c', 'JointAccountHoldersName__c', 'AC_No__c', 'IsThereChangeInLimitDuringThePeri__c', 'AverageLimitDuringThePeriod__c', 'LatestMonthForWhichBankStatementIs__c', 'PeriodOfBankingStart__c', 'PeriodOfBankingEnd__c','Bank_City__c', 'Repayment_bank_A_c__c', 'Bank_Branch__c', 'MICR_Code__c','Appl__r.CustProfile__c', 'eNACH_feasible__c'],
            childObjFields:['ApplBanking__c','Monthend__c','Average_Daily_Bank_Balance__c', 'DailyABBBalance__c','MonthlyLimit__c','Utilization__c','Id', 'Name', 'Month__c', 'Year__c', 'ValueSummationCredit__c', 'ValueSummationDebit__c', 'CountofCredit__c', 'CountofDebit__c', 'InwardReturnsCount__c', 'OutwardReturnsCount__c', 'StopPaymentCount__c', 'MinBalanceCharges__c', 'BalanceAt_1st__c', 'BalanceAt_5th__c', 'BalanceAt_10th__c', 'BalanceAt_15th__c', 'BalanceAt_20th__c', 'BalanceAt_25th__c', 'AverageBankBalance__c'],        
            queryCriteria: ' where Id= \'' + this.appliBnkReIdForConCCndOD + '\' AND IsDeleted__c != true'
        }
        getData({ params: paramForAppDetail })
            .then((data) => {
                //console.log('22444444');
                //console.log('fullllldataaaa>>>>>>'+JSON.stringify(data));
                this.parentRecord=JSON.parse(JSON.stringify(data[0].parentRecord));
                //this.parentRecord=data[0].parentRecord
                //console.log('datadatadatadatadata'+JSON.stringify(this.parentRecord));
               // console.log('datadatadatadatadata'+JSON.stringify(data[0].ChildReords));
                if(data[0].ChildReords !=null && data[0].ChildReords !=''  && typeof data[0].ChildReords !== 'undefined'){
                    //console.log('childexistsin 2 method>>>>>>>>>>>>>>>>>>>>>>>>>>')
                    
                    data[0].ChildReords.forEach(record => {
                    const month = record.Month__c; 
                    const year = record.Year__c;
                    const monthYear1 = `${month}-${year}`; 
                    if (!mapOfExistingRecWithMon.has(monthYear1)) { 
                        mapOfExistingRecWithMon.set(monthYear1, []); 
                    } 
                    mapOfExistingRecWithMon.get(monthYear1).push(record); 
                    }); 
                   // console.log('mapOfExistingRecWithMon'+mapOfExistingRecWithMon);
                    for(const rec of this.listOfOverDraftCcAdd){
                        listOfMonYeNewRec.push(rec.monthYear);
                       // if(mapOfExistingRecWithMon.get(rec.monthYear) !=''){
                        if(mapOfExistingRecWithMon.get(rec.monthYear) !='' && mapOfExistingRecWithMon.get(rec.monthYear) !=null &&typeof mapOfExistingRecWithMon.get(rec.monthYear) !=='undefined' ){
                            //console.log('246666'+mapOfExistingRecWithMon.get(rec.monthYear));
                            var existRecord=mapOfExistingRecWithMon.get(rec.monthYear)
                            //console.log('2488888'+JSON.stringify(existRecord));
                            let blankListForNewDetailRec = {"Id":existRecord[0].Id,"ApplBanking__c":this.appliBnkReIdForConCCndOD,"Month__c":existRecord[0].Month__c,"Year__c":existRecord[0].Year__c,"ValueSummationCredit__c":rec.sumValueSummationCredit,"ValueSummationDebit__c":rec.sumValueSummationDebit,"CountofCredit__c":rec.sumChangesCountofCredit,"CountofDebit__c":rec.sumChangesCountofDebit,"InwardReturnsCount__c":rec.sumInwardReturnsCount,"OutwardReturnsCount__c":rec.sumOutwardReturnsCount,"StopPaymentCount__c":rec.sumChangesStopPaymentCount,"MinBalanceCharges__c":rec.sumcheckMiniChan,"BalanceAt_1st__c":rec.sumChangesBalanceAt_1st,"BalanceAt_5th__c":rec.sumChangesBalanceAt_5th__c,"BalanceAt_10th__c":rec.sumChangesBalanceAt_10th,"BalanceAt_15th__c":rec.sumChangesBalanceAt_15th,"BalanceAt_20th__c":rec.sumChangesBalanceAt_20th,"BalanceAt_25th__c":rec.sumChangesBalanceAt_25th,"AverageBankBalance__c":rec.sumChangesAverageBankBalance,"Utilization__c":rec.Utilization,"MonthlyLimit__c":rec.sumMonthlyLimit,"DailyABBBalance__c":rec.sumValueAbbPro};
                            //console.log('246666'+JSON.stringify(blankListForNewDetailRec));
                            ListOfMonYearOfRec.push(blankListForNewDetailRec)
                        }else{
                            // console.log('2511111');
                            listtodeleteRec.push(mapOfExistingRecWithMon.get(rec.monthYear));
                            const monyearToSplit=rec.monthYear.split('-')
                            let blankListForNewDetailRec = {"ApplBanking__c":this.appliBnkReIdForConCCndOD,"Month__c":monyearToSplit[0],"Year__c":monyearToSplit[1],"ValueSummationCredit__c":rec.sumValueSummationCredit,"ValueSummationDebit__c":rec.sumValueSummationDebit,"CountofCredit__c":rec.sumChangesCountofCredit,"CountofDebit__c":rec.sumChangesCountofDebit,"InwardReturnsCount__c":rec.sumInwardReturnsCount,"OutwardReturnsCount__c":rec.sumOutwardReturnsCount,"StopPaymentCount__c":rec.sumChangesStopPaymentCount,"MinBalanceCharges__c":rec.sumcheckMiniChan,"BalanceAt_1st__c":rec.sumChangesBalanceAt_1st,"BalanceAt_5th__c":rec.sumChangesBalanceAt_5th__c,"BalanceAt_10th__c":rec.sumChangesBalanceAt_10th,"BalanceAt_15th__c":rec.sumChangesBalanceAt_15th,"BalanceAt_20th__c":rec.sumChangesBalanceAt_20th,"BalanceAt_25th__c":rec.sumChangesBalanceAt_25th,"AverageBankBalance__c":rec.sumChangesAverageBankBalance,"Utilization__c":rec.Utilization,"MonthlyLimit__c":rec.sumMonthlyLimit, "DailyABBBalance__c":rec.sumValueAbbPro};
                            ListOfMonYearOfRec.push(blankListForNewDetailRec)
                        }
                        
                    }
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
                    //console.log('childnotexistsin 2 method>>>>>>>>>>>>>>>>>>>>>>>>>>')
                    for(const rec of this.listOfOverDraftCcAdd){
                        const monyearToSplit=rec.monthYear.split('-')
                        let blankListForNewDetailRec = {"ApplBanking__c":this.appliBnkReIdForConCCndOD,"Month__c":monyearToSplit[0],"Year__c":monyearToSplit[1],"ValueSummationCredit__c":rec.sumValueSummationCredit,"ValueSummationDebit__c":rec.sumValueSummationDebit,"CountofCredit__c":rec.sumChangesCountofCredit,"CountofDebit__c":rec.sumChangesCountofDebit,"InwardReturnsCount__c":rec.sumInwardReturnsCount,"OutwardReturnsCount__c":rec.sumOutwardReturnsCount,"StopPaymentCount__c":rec.sumChangesStopPaymentCount,"MinBalanceCharges__c":rec.sumcheckMiniChan,"BalanceAt_1st__c":rec.sumChangesBalanceAt_1st,"BalanceAt_5th__c":rec.sumChangesBalanceAt_5th__c,"BalanceAt_10th__c":rec.sumChangesBalanceAt_10th,"BalanceAt_15th__c":rec.sumChangesBalanceAt_15th,"BalanceAt_20th__c":rec.sumChangesBalanceAt_20th,"BalanceAt_25th__c":rec.sumChangesBalanceAt_25th,"AverageBankBalance__c":rec.sumChangesAverageBankBalance,"DailyABBBalance__c":rec.sumValueAbbPro};
                        ListOfMonYearOfRec.push(blankListForNewDetailRec)
                    }
                   
                }
               // console.log('ListOfMonYearOfRec'+JSON.stringify(ListOfMonYearOfRec));
                this.ChildRecordsToUpsert=ListOfMonYearOfRec
                this.handleSave(this.parentRecord,this.ChildRecordsToUpsert);

             })
            .catch(error => {
                console.log('Errorured:- '+JSON.stringify(error));
            });

    }
    appliBnkReIdForConJointSav;

    handleSavJoinCurreRecSave(){
        var listToDeleteRec=[];
        var ListForUpsertRec=[];
        var appliBnkReForConNew={"LoanAppl__c":this.loanAppId,"Summary_Type__c":"Combined Banking (CASA)","Type__c":"Consolidated Banking Summary"}
        let paramsSaveOD={
            ParentObjectName:'LoanAppl__c',
            ChildObjectRelName:'Applicant_Banking1__r',
            parentObjFields:['Id'],
            childObjFields:['Id','Summary_Type__c','SumofMonthlyAverageBalance__c','Type__c','Repayment_bank_A_c__c','SFDC_Bank_Master_Name__c','SFDCBankMaster__r.BankName__c','BankName__c','AccountType__c','FileType__c','DocumentDetail__c','DocumentDetail__r.DocTyp__c','SalaryAccount__c','DocumentDetail__r.Content_Document_Id__c','DocumentDetail__r.DocSubTyp__c'],        
            queryCriteriaForChild: ' WHERE Type__c = \'Consolidated Banking Summary\' AND Summary_Type__c = \'Combined Banking (CASA)\'',   
            queryCriteria: ' where Id= \'' + this.loanAppId + '\''
        }
        getDataForFilterChild({ params: paramsSaveOD })
            .then((data) => {
                //console.log('>>>>>>>>>>>>'+JSON.stringify(data));
                if(data.ChildReords!=''&& data.ChildReords !=null && typeof data.ChildReords!== 'undefined'){
                    //console.log('childexists>>>>>>>>>>>>>>>>>>>>>>>>>>'+data.ChildReords[0].Id)
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
                console.log('Errorured:- '+JSON.stringify(error));
            });
        
    }
    parentRecordForSav;
    ChildRecordsSavToUpsert;
    UpdateAppBnkWithDetailforSav(){
        console.log('211111');
        const mapOfExistingRecWithMon = new Map(); 
        const mapOfnewRecWithMon = new Map(); 
        const listOfMonYeNewRec=[]
        var ListOfMonYearOfRec=[];
        var listtodeleteRec=[];
        let paramForAppDetail={
            ParentObjectName:'ApplBanking__c',
            ChildObjectRelName:'Applicant_Banking_Detail__r',
            parentObjFields:[  'Id', 'Appl__c', 'SumofMonthlyAverageBalance__c','eNACHFeasible__c','SFDC_Bank_Master_Name__c','NACHFeasible__c','SFDCBankMaster__r.BankName__c','LoanAppl__c','IFSC_Code__c','Limit__c', 'Name_of_the_Primary_Account_Holder_s__c', 'OtherBankName__c', 'AccountType__c', 'FileType__c', 'SalaryAccount__c', 'DocumentDetail__c', 'BankName__c', 'BankId__c', 'JointAccountHoldersName__c', 'AC_No__c', 'IsThereChangeInLimitDuringThePeri__c', 'AverageLimitDuringThePeriod__c', 'LatestMonthForWhichBankStatementIs__c', 'PeriodOfBankingStart__c', 'PeriodOfBankingEnd__c','Bank_City__c', 'Repayment_bank_A_c__c', 'Bank_Branch__c', 'MICR_Code__c','Appl__r.CustProfile__c', 'eNACH_feasible__c'],
            childObjFields:['ApplBanking__c','Monthend__c','Average_Daily_Bank_Balance__c', 'DailyABBBalance__c','Utilization__c','Id', 'Name', 'Month__c', 'Year__c', 'ValueSummationCredit__c', 'ValueSummationDebit__c', 'CountofCredit__c', 'CountofDebit__c', 'InwardReturnsCount__c', 'OutwardReturnsCount__c', 'StopPaymentCount__c', 'MinBalanceCharges__c', 'BalanceAt_1st__c', 'BalanceAt_5th__c', 'BalanceAt_10th__c', 'BalanceAt_15th__c', 'BalanceAt_20th__c', 'BalanceAt_25th__c', 'AverageBankBalance__c'],        
            queryCriteria: ' where Id= \'' + this.appliBnkReIdForConJointSav + '\' AND IsDeleted__c != true'
        }
        getData({ params: paramForAppDetail })
            .then((data) => {
               // console.log('22444444');
                console.log('fullllldataaaa>>>>>>'+JSON.stringify(data));
                this.parentRecordForSav=JSON.parse(JSON.stringify(data[0].parentRecord));
                //this.parentRecord=data[0].parentRecord
                //console.log('datadatadatadatadata'+JSON.stringify(this.parentRecord));
                //console.log('datadatadatadatadata'+JSON.stringify(data[0].ChildReords));
                if(data[0].ChildReords !=null && data[0].ChildReords !=''  && typeof data[0].ChildReords !== 'undefined'){
                    //console.log('childexistsin 2 method>>>>>>>>>>>>>>>>>>>>>>>>>>')
                    
                    data[0].ChildReords.forEach(record => {
                    const month = record.Month__c; 
                    const year = record.Year__c;
                    const monthYear1 = `${month}-${year}`; 
                    if (!mapOfExistingRecWithMon.has(monthYear1)) { 
                        mapOfExistingRecWithMon.set(monthYear1, []); 
                    } 
                    mapOfExistingRecWithMon.get(monthYear1).push(record); 
                    }); 
                   /* console.log('mapOfExistingRecWithMon'+mapOfExistingRecWithMon);
                    console.log('mapOfExistingRecWithMon'+mapOfExistingRecWithMon.keys());*/
                    for(const rec of this.listOfSvinJointCaAdd){
                        listOfMonYeNewRec.push(rec.monthYear);
                        mapOfnewRecWithMon.set(rec.monthYear,rec)
                       // if(mapOfExistingRecWithMon.get(rec.monthYear) !=''){
                        if(mapOfExistingRecWithMon.get(rec.monthYear) !='' && mapOfExistingRecWithMon.get(rec.monthYear) !=null &&typeof mapOfExistingRecWithMon.get(rec.monthYear) !=='undefined' ){
                            //console.log('246666'+mapOfExistingRecWithMon.get(rec.monthYear));
                            var existRecord=mapOfExistingRecWithMon.get(rec.monthYear)
                           // console.log('2488888'+JSON.stringify(existRecord));
                            let blankListForNewDetailRec = {"Id":existRecord[0].Id,"ApplBanking__c":this.appliBnkReIdForConJointSav,"Month__c":existRecord[0].Month__c,"Year__c":existRecord[0].Year__c,"ValueSummationCredit__c":rec.sumValueSummationCredit,"ValueSummationDebit__c":rec.sumValueSummationDebit,"CountofCredit__c":rec.sumChangesCountofCredit,"CountofDebit__c":rec.sumChangesCountofDebit,"InwardReturnsCount__c":rec.sumInwardReturnsCount,"OutwardReturnsCount__c":rec.sumOutwardReturnsCount,"StopPaymentCount__c":rec.sumChangesStopPaymentCount,"MinBalanceCharges__c":rec.sumcheckMiniChan,"BalanceAt_1st__c":rec.sumChangesBalanceAt_1st,"BalanceAt_5th__c":rec.sumChangesBalanceAt_5th__c,"BalanceAt_10th__c":rec.sumChangesBalanceAt_10th,"BalanceAt_15th__c":rec.sumChangesBalanceAt_15th,"BalanceAt_20th__c":rec.sumChangesBalanceAt_20th,"BalanceAt_25th__c":rec.sumChangesBalanceAt_25th,"AverageBankBalance__c":rec.sumChangesAverageBankBalance,"DailyABBBalance__c":rec.sumValueAbbPro};
                            //console.log('246666'+JSON.stringify(blankListForNewDetailRec));
                            ListOfMonYearOfRec.push(blankListForNewDetailRec)
                        }else{
                            // console.log('2511111');
                           // listtodeleteRec.push(mapOfExistingRecWithMon.get(rec.monthYear));
                            const monyearToSplit=rec.monthYear.split('-')
                            let blankListForNewDetailRec = {"ApplBanking__c":this.appliBnkReIdForConJointSav,"Month__c":monyearToSplit[0],"Year__c":monyearToSplit[1],"ValueSummationCredit__c":rec.sumValueSummationCredit,"ValueSummationDebit__c":rec.sumValueSummationDebit,"CountofCredit__c":rec.sumChangesCountofCredit,"CountofDebit__c":rec.sumChangesCountofDebit,"InwardReturnsCount__c":rec.sumInwardReturnsCount,"OutwardReturnsCount__c":rec.sumOutwardReturnsCount,"StopPaymentCount__c":rec.sumChangesStopPaymentCount,"MinBalanceCharges__c":rec.sumcheckMiniChan,"BalanceAt_1st__c":rec.sumChangesBalanceAt_1st,"BalanceAt_5th__c":rec.sumChangesBalanceAt_5th__c,"BalanceAt_10th__c":rec.sumChangesBalanceAt_10th,"BalanceAt_15th__c":rec.sumChangesBalanceAt_15th,"BalanceAt_20th__c":rec.sumChangesBalanceAt_20th,"BalanceAt_25th__c":rec.sumChangesBalanceAt_25th,"AverageBankBalance__c":rec.sumChangesAverageBankBalance,"DailyABBBalance__c":rec.sumValueAbbPro};
                            ListOfMonYearOfRec.push(blankListForNewDetailRec)
                        }
                        
                    }
                    for(const key of mapOfExistingRecWithMon.keys()){
                        //console.log('385'+key)
                        //console.log('testtesttest'+listOfMonYeNewRec)
                        if(!listOfMonYeNewRec.includes(key)){
                            var listforDelete=mapOfExistingRecWithMon.get(key)[0]
                            listtodeleteRec.push(listforDelete)
                            //console.log('indeleteeee'+JSON.stringify(listtodeleteRec))
                        }else{
                           // console.log('innotttttdeleteeee')
                        }
                    }
                    if(listtodeleteRec.length>0){
                        this.handleDeleteAppDetail(listtodeleteRec)
                    }
                  /* for(const key of mapOfExistingRecWithMon.keys()){
                    console.log('385')
                        if(!mapOfnewRecWithMon.keys().includes(key)){
                            console.log('need to delete rec');
                            listtodeleteRec.push(mapOfExistingRecWithMon.get(key))
                        }else{
                            console.log('need to not delete rec');
                        }
                    }*/
                   // console.log('248888888'+ListOfMonYearOfRec);
                }else{
                    console.log('childnotexistsin 2 method>>>>>>>>>>>>>>>>>>>>>>>>>>')
                    for(const rec of this.listOfSvinJointCaAdd){
                        const monyearToSplit=rec.monthYear.split('-')
                        let blankListForNewDetailRec = {"ApplBanking__c":this.appliBnkReIdForConJointSav,"Month__c":monyearToSplit[0],"Year__c":monyearToSplit[1],"ValueSummationCredit__c":rec.sumValueSummationCredit,"ValueSummationDebit__c":rec.sumValueSummationDebit,"CountofCredit__c":rec.sumChangesCountofCredit,"CountofDebit__c":rec.sumChangesCountofDebit,"InwardReturnsCount__c":rec.sumInwardReturnsCount,"OutwardReturnsCount__c":rec.sumOutwardReturnsCount,"StopPaymentCount__c":rec.sumChangesStopPaymentCount,"MinBalanceCharges__c":rec.sumcheckMiniChan,"BalanceAt_1st__c":rec.sumChangesBalanceAt_1st,"BalanceAt_5th__c":rec.sumChangesBalanceAt_5th__c,"BalanceAt_10th__c":rec.sumChangesBalanceAt_10th,"BalanceAt_15th__c":rec.sumChangesBalanceAt_15th,"BalanceAt_20th__c":rec.sumChangesBalanceAt_20th,"BalanceAt_25th__c":rec.sumChangesBalanceAt_25th,"AverageBankBalance__c":rec.sumChangesAverageBankBalance,"DailyABBBalance__c":rec.sumValueAbbPro};
                        ListOfMonYearOfRec.push(blankListForNewDetailRec)
                    }
                   
                }
               // console.log('ListOfMonYearOfRec'+JSON.stringify(ListOfMonYearOfRec));
                this.ChildRecordsSavToUpsert=ListOfMonYearOfRec
                this.handleSave(this.parentRecordForSav, this.ChildRecordsSavToUpsert);

             })
            .catch(error => {
                console.log('Errorured:- '+JSON.stringify(error));
            });

    }
    
    handleSave(parentRec, ChildRecList){
        //console.log('inhandle'+JSON.stringify(this.parentRecord));
        delete parentRec.Appl__r
        parentRec.sobjectType='ApplBanking__c'
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
       // console.log('@@@@@@@@@@@@@@@@@@@@'+JSON.stringify(upsertData));                 
        updateData ({upsertData:upsertData})
        .then(result => {  
           console.log('resultresultresultresultresult'+JSON.stringify(result))                    
               
        }).catch(error => {
            
            console.log('erorrrrrrr'+JSON.stringify(error));
        })
    }

    forCreateDataForConsolidateTable(ListOfChildRec){
        //console.log('listofchild@@@@@@@@@@'+JSON.stringify(ListOfChildRec));
        
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
        //console.log('recordsByMonthYearMap'+JSON.stringify(recordsByMonthYearMap));
        for (const [monthYear, records] of recordsByMonthYearMap) {
            //console.log('[monthYear, records]'+[monthYear, records]);
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
                    //console.log('this.finalOfMiniAver'+sumcheckMiniChan)
                    sumcheckMiniChan =record.MinBalanceCharges__c == '' ||  record.MinBalanceCharges__c == null ||  record.MinBalanceCharges__c == undefined ? 'N' :  record.MinBalanceCharges__c;
                }
                //console.log('recordrecordrecord'+record);
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
                sumMonthlyLimit:Math.floor(sumMonthlyLimit),
                sumValueAbbPro:Math.floor(sumValueAbbPro),
                sumDailyBalan:Math.floor(sumDailyBalan),
                sumMonthEnd:Math.floor(sumMonthEnd)			
            });
            
            }
            return listofRecAfteArddingVals;
            
    }
    forCreateDataForConsolidateTableSaving(ListOfChildRec){
        //console.log('listofchild@@@@@@@@@@'+JSON.stringify(ListOfChildRec));
        
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
        //console.log('recordsByMonthYearMap'+JSON.stringify(recordsByMonthYearMap));
        for (const [monthYear, records] of recordsByMonthYearMap) {
            //console.log('[monthYear, records]'+[monthYear, records]);
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
                    //console.log('this.finalOfMiniAver'+sumcheckMiniChan)
                    sumcheckMiniChan =record.MinBalanceCharges__c == '' ||  record.MinBalanceCharges__c == null ||  record.MinBalanceCharges__c == undefined ? 'N' :  record.MinBalanceCharges__c;
                }
                //console.log('recordrecordrecord'+record);
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
                // sumDailyBalan+= record.Average_Daily_Bank_Balance__c == '' ||  record.Average_Daily_Bank_Balance__c == null ||  record.Average_Daily_Bank_Balance__c == undefined ? 0 :  record.Average_Daily_Bank_Balance__c;

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
                sumDailyBalan:Math.floor(sumDailyBalan),
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

    calcuForMonLimit(ListOfRecords){
        //console.log('calcuForMonLimit'+this.totalLimitValue);
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

    calForUtilization(ListOfRecords){
        //console.log('calForUtilization');
        ListOfRecords = ListOfRecords.map((record) => {
            if (record.sumChangesAverageBankBalance !=0.00) {
                record["Utilization"] = ((record.sumChangesAverageBankBalance * 100) / (this.totalLimitValue)).toFixed(2);
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
            //console.log('sumWithAver>>'+sumWithAver)
            var sumWithAver=Math.floor((sum/6).toFixed(2))
            if(!isNaN(sumWithAver)){
                console.log('iniffffff')
                record.sumChangesAverageBankBalance = sumWithAver;
            }else{
                //console.log('elseeeee')
                record.sumChangesAverageBankBalance=0.00;
            }
            
            });
            return ListOfRecords;
           // this.listofRecAfteArddingVals=ListOfRecords
            }
   // forTotalAndAverage={"totalValueSummationDebit":0,"finalOfMinibalanceChar":'N',"totalValueSummationCredit":0,"totalCountofCredit":0,"totalCountofDebit":0,"totalInwardReturnsCount":0,"totalOutwardReturnsCount":0,"totalStopPaymentCount":0,"totalBalanceAt_1st":0,"totalBalanceAt_5th__c":0,"totalBalanceAt_10th":0,"totalBalanceAt_15th":0,"totalBalanceAt_20th":0,"totalBalanceAt_25th":0,"totalAverageBankBalance":0,"averageValueSummationCredit":0,"averageValueSummationDebit":0,"averageCountofCredit":0,"averageCountofDebit":0,"averageInwardReturnsCount":0,"averageOutwardReturnsCount":0,"averageStopPaymentCount":0,"averageBalanceAt_1st":0,"averageBalanceAt_5th__c":0,"averageBalanceAt_10th":0,"averageBalanceAt_15th":0,"averageBalanceAt_20th":0,"averageBalanceAt_25th":0,"averageAverageBankBalance":0};  
    calForTotalAndAverage(ListOfRecords,lengthOfData){
        var forTotalAndAverage={"totalValueMonLimit":0,"averageMonLimit":0,"totalValueSummationDebit":0,"finalOfMinibalanceChar":'N',"totalValueSummationCredit":0,"totalCountofCredit":0,"totalCountofDebit":0,"totalInwardReturnsCount":0,"totalOutwardReturnsCount":0,"totalStopPaymentCount":0,"totalBalanceAt_1st":0,"totalBalanceAt_5th__c":0,"totalBalanceAt_10th":0,"totalBalanceAt_15th":0,"totalBalanceAt_20th":0,"totalBalanceAt_25th":0,"totalAverageBankBalance":0,"averageValueSummationCredit":0,"averageValueSummationDebit":0,"averageCountofCredit":0,"averageCountofDebit":0,"averageInwardReturnsCount":0,"averageOutwardReturnsCount":0,"averageStopPaymentCount":0,"averageBalanceAt_1st":0,"averageBalanceAt_5th__c":0,"averageBalanceAt_10th":0,"averageBalanceAt_15th":0,"averageBalanceAt_20th":0,"averageBalanceAt_25th":0,"averageAverageBankBalance":0,"totalForConAbbPro":0,"averForConAbbPro":0, "AvermonthEnd":0, "AverDailyBala":0, "totalMonthEnd":0, "TotalDailyBala":0};  
        let i=0;
       // console.log('ListOfRecordnewwws>>>>>>>'+JSON.stringify(ListOfRecords));
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
            //forTotalAndAverage.totalValueMonLimit += Number(record.MonthlyLimit)
            forTotalAndAverage.totalValueMonLimit += Math.floor(Number(record.sumMonthlyLimit))
            forTotalAndAverage.totalMonthEnd += Math.floor(record.sumMonthEnd)
            forTotalAndAverage.TotalDailyBala += Math.floor(record.sumDailyBalan)
            

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
    @track showUi=false
    @api
    checkShowtable(){
        refreshApex(this._wiredForOverDraftCca);
        refreshApex(this._wiredForSvinJointCa);
        console.log('this.listOfOverDraftCcAdd.length'+this.listOfOverDraftCcAdd.length)
        console.log('this.listOfSvinJointCaAdd.length'+this.listOfSvinJointCaAdd.length)
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
        console.log('inrefresewireMethods');
        refreshApex(this._wiredForOverDraftCca);
        refreshApex(this._wiredForSvinJointCa);
        this.showUi=false
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