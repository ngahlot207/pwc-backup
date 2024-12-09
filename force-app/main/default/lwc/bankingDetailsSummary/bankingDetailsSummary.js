import { LightningElement, wire, api, track } from 'lwc';
import getData from '@salesforce/apex/SObjectDynamicRecordProvider.getAllSobjectDatawithRelatedRecords';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from '@salesforce/apex';
import getBankingDetailsSummaryCASA from '@salesforce/apex/ObligationDetailsSummaryController.getBankingDetailsSummaryForCASA';
import getBankingDetailsSummaryODCC from '@salesforce/apex/ObligationDetailsSummaryController.getBankingDetailsSummaryForODCC';
export default class BankingDetailsSummary extends LightningElement {

    borrowerName;
    allDataofApplicant;
    listofRecAfteArddingVals;
    @track showSpinner = false;

    @api recordId;
    @api isBlPl=false;
    listOfOverDraftCcAdd = [];
    listOfSvinJointCaAdd = [];
    listApplicantBanking = [];
    ListApplicantBankingDetails = [];

    @wire(getBankingDetailsSummaryCASA, { recordId: '$recordId' })
    wiredgetgetBankingDetailsSummaryCASA({ data, error }) {
        if (data) {
            //  console.log('data-->'+JSON.stringify(data));
            this.listOfSvinJointCaAdd = data;
            var tempApplicantBank = [];
            var tempApplicantBankDetails = [];
           

            for (var i = 0; i < data.length; i++) {
                tempApplicantBank.push(data[i].listApplicantBankingWrapper);

                //tempApplicantBankDetails.push( data[i].listApplicantBankingDetailWrapper );

            }

            // for (const childRec of data) {
            //     tempApplicantBankDetails.push(childRec.listApplicantBankingDetailWrapper);
            // }

            for (let j = 0; j < tempApplicantBank.length; j++) {
                // tempApplicantBank.push( data[ i ].listApplicantBankingWrapper );

                tempApplicantBankDetails.push(tempApplicantBank[j].Applicant_Banking_Detail__r);

            }

            this.listApplicantBanking = tempApplicantBank;
            this.ListApplicantBankingDetails = tempApplicantBankDetails;

            console.log('listApplicantBanking-->' + JSON.stringify(this.listApplicantBanking));
            console.log('ListApplicantBankingDetails-->' + JSON.stringify(this.ListApplicantBankingDetails));
            console.log('listOfSvinJointCaAdd-->' + JSON.stringify(this.listOfSvinJointCaAdd));
           

        } else if (error) {
            console.error('Error loading Banking Details Details: ', error);
        }
    }


    @wire(getBankingDetailsSummaryODCC, { recordId: '$recordId' })
    wiredgetBankingDetailsSummaryODCC({ data, error }) {
        if (data) {
            //  console.log('data-->'+JSON.stringify(data));
            this.listOfOverDraftCcAdd = data;
            var tempApplicantBank = [];
            var tempApplicantBankDetails = [];
           

            
            console.log('listOfOverDraftCcAdd-->' + JSON.stringify(this.listOfOverDraftCcAdd));
           

        } else if (error) {
            console.error('Error loading Banking Details Details: ', error);
        }
    }
    /*totalValueSummationDebit=0;
    totalValueSummationCredit=0;
    totalCountofDebit=0;
    totalCountofCredit=0;
    totalInwardReturnsCount=0;
    totalOutwardReturnsCount=0;
    totalStopPaymentCount=0;
    
    totalBalanceAt_1st=0;
    totalBalanceAt_5th__c=0;
    totalBalanceAt_10th=0;
    totalBalanceAt_15th=0;
    totalBalanceAt_20th=0;
    totalBalanceAt_25th=0;
    totalAverageBankBalance=0;
    averageValueSummationDebit=0;
    averageValueSummationCredit=0;
    averageCountofDebit=0;
    averageCountofCredit=0;
    averageInwardReturnsCount=0;
    averageOutwardReturnsCount=0;
    averageStopPaymentCount=0;
    
    averageBalanceAt_1st=0;
    averageBalanceAt_5th__c=0;
    averageBalanceAt_10th=0;
    averageBalanceAt_15th=0;
    averageBalanceAt_20th=0;
    averageBalanceAt_25th=0;
    averageAverageBankBalance=0;*/

    /* _allApplicantData;
     listOfOverDraftCcAdd=[];
     listOfSvinJointCaAdd=[];
     params;
     @api
     get allApplicantData(){
         return this._allApplicantData;
     }
 
     set allApplicantData(value){
         this._allApplicantData = value;
     }
     _idsForOverDraftCca
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
                 parentObjFields:[  'Id', 'Limit__c','Appl__c', 'LoanAppl__c', 'Name_of_the_Primary_Account_Holder_s__c', 'OtherBankName__c', 'AccountType__c', 'FileType__c', 'SalaryAccount__c', 'DocumentDetail__c', 'BankName__c', 'BankId__c', 'JointAccountHoldersName__c', 'AC_No__c', 'IsThereChangeInLimitDuringThePeri__c', 'AverageLimitDuringThePeriod__c', 'LatestMonthForWhichBankStatementIs__c', 'PeriodOfBankingStart__c', 'PeriodOfBankingEnd__c', 'Repayment_bank_A_c__c', 'Bank_Branch__c', 'MICR_Code__c', 'eNACH_feasible__c'],
                 childObjFields:['ApplBanking__c', 'Id', 'Name', 'Month__c', 'Year__c', 'ValueSummationCredit__c', 'ValueSummationDebit__c', 'CountofCredit__c', 'CountofDebit__c', 'InwardReturnsCount__c', 'OutwardReturnsCount__c', 'StopPaymentCount__c', 'MinBalanceCharges__c', 'BalanceAt_1st__c', 'BalanceAt_5th__c', 'BalanceAt_10th__c', 'BalanceAt_15th__c', 'BalanceAt_20th__c', 'BalanceAt_25th__c', 'AverageBankBalance__c'],        
                 queryCriteria: ' WHERE ID IN (\''+this._idsForOverDraftCca.join('\', \'') + '\')'
             }
         }else{
             this.ceckForOdCc=false;
             console.log('this.listOfOverDraftCcAdd>>>'+this.listOfOverDraftCcAdd.length);
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
         console.log('this.idsForSvinJointCa'+this._idsForSvinJointCa);     
         if(this._idsForSvinJointCa !=null && this._idsForSvinJointCa !='' && typeof this._idsForSvinJointCa !== undefined){
 
             this.paramsforSav ={
                 ParentObjectName:'ApplBanking__c',
                 ChildObjectRelName:'Applicant_Banking_Detail__r',
                 parentObjFields:[  'Id', 'Appl__c', 'LoanAppl__c', 'Name_of_the_Primary_Account_Holder_s__c', 'OtherBankName__c', 'AccountType__c', 'FileType__c', 'SalaryAccount__c', 'DocumentDetail__c', 'BankName__c', 'BankId__c', 'JointAccountHoldersName__c', 'AC_No__c', 'IsThereChangeInLimitDuringThePeri__c', 'AverageLimitDuringThePeriod__c', 'LatestMonthForWhichBankStatementIs__c', 'PeriodOfBankingStart__c', 'PeriodOfBankingEnd__c', 'Repayment_bank_A_c__c', 'Bank_Branch__c', 'MICR_Code__c', 'eNACH_feasible__c'],
                 childObjFields:['ApplBanking__c', 'Id', 'Name', 'Month__c', 'Year__c', 'ValueSummationCredit__c', 'ValueSummationDebit__c', 'CountofCredit__c', 'CountofDebit__c', 'InwardReturnsCount__c', 'OutwardReturnsCount__c', 'StopPaymentCount__c', 'MinBalanceCharges__c', 'BalanceAt_1st__c', 'BalanceAt_5th__c', 'BalanceAt_10th__c', 'BalanceAt_15th__c', 'BalanceAt_20th__c', 'BalanceAt_25th__c', 'AverageBankBalance__c'],        
                 queryCriteria: ' WHERE ID IN (\''+this._idsForSvinJointCa.join('\', \'') + '\')'
             } 
         }else{
             this.CheckIdLength=false;
             console.log('this.listOfSvinJointCaAdd>>>'+this.listOfSvinJointCaAdd.length);
         }     
     }*/
    /*  CheckIdLength=true
      _wiredForOverDraftCca
      totalLimitValue=0;
      @wire(getBankingDetailsSummaryODCC,{ recordId: '$recordId'})       //@wire(getData,{params:'$params'})
      ForOverDraftCca(wiredForOverDraftCca) {
          console.log('hhhhhh')
          const { data, error } = wiredForOverDraftCca;
          this._wiredForOverDraftCca = wiredForOverDraftCca;
          console.log('ForOverDraftCca>>>>>>>',this._wiredForOverDraftCca);
          let listOfAllChildReco=[];
          if (data) {
              console.log('data-->',data);
              for(const record of data){
                  if(record.ApplBanking__r.Limit__c != null && record.ApplBanking__r.Limit__c!='' && record.ApplBanking__r.Limit__c!='undefined'){
                      this.totalLimitValue +=Number(record.ApplBanking__r.Limit__c)
                  }
                  listOfAllChildReco.push(record);
             
               }
               console.log('this.totalLimitValue'+this.totalLimitValue)
             var listODCcaArddingVals=[];
             listODCcaArddingVals = this.forCreateDataForConsolidateTable(listOfAllChildReco);
             this.listOfOverDraftCcAdd=listODCcaArddingVals;
             console.log('this.listOfOverDraftCcAdd>>>>>>'+JSON.stringify(this.listOfOverDraftCcAdd))
             this.listOfOverDraftCcAdd.sort(this.customSort);
             this.listOfOverDraftCcAdd =this.calculationforsum(this.listOfOverDraftCcAdd);
             this.listOfOverDraftCcAdd =this.calForUtilization(this.listOfOverDraftCcAdd);
              let lengthOfList = this.listOfOverDraftCcAdd.length;
              this.calForTotalAndAverageODC=this.calForTotalAndAverage(this.listOfOverDraftCcAdd,lengthOfList);
              console.log('this.calForTotalAndAverage'+JSON.stringify(this.calForTotalAndAverageODC));
              console.log('lengthOfList>>>'+lengthOfList);
           
          } else if (error) {
              console.log(error);
          }
      }
      
      calForTotalAndAverageODC ={"totalValueSummationDebit":0,"finalOfMinibalanceChar":'N',"totalValueSummationCredit":0,"totalCountofCredit":0,"totalCountofDebit":0,"totalInwardReturnsCount":0,"totalOutwardReturnsCount":0,"totalStopPaymentCount":0,"totalBalanceAt_1st":0,"totalBalanceAt_5th__c":0,"totalBalanceAt_10th":0,"totalBalanceAt_15th":0,"totalBalanceAt_20th":0,"totalBalanceAt_25th":0,"totalAverageBankBalance":0,"averageValueSummationCredit":0,"averageValueSummationDebit":0,"averageCountofCredit":0,"averageCountofDebit":0,"averageInwardReturnsCount":0,"averageOutwardReturnsCount":0,"averageStopPaymentCount":0,"averageBalanceAt_1st":0,"averageBalanceAt_5th__c":0,"averageBalanceAt_10th":0,"averageBalanceAt_15th":0,"averageBalanceAt_20th":0,"averageBalanceAt_25th":0,"averageAverageBankBalance":0};  ;
      calForTotalAndAverageSav={"totalValueSummationDebit":0,"finalOfMinibalanceChar":'N',"totalValueSummationCredit":0,"totalCountofCredit":0,"totalCountofDebit":0,"totalInwardReturnsCount":0,"totalOutwardReturnsCount":0,"totalStopPaymentCount":0,"totalBalanceAt_1st":0,"totalBalanceAt_5th__c":0,"totalBalanceAt_10th":0,"totalBalanceAt_15th":0,"totalBalanceAt_20th":0,"totalBalanceAt_25th":0,"totalAverageBankBalance":0,"averageValueSummationCredit":0,"averageValueSummationDebit":0,"averageCountofCredit":0,"averageCountofDebit":0,"averageInwardReturnsCount":0,"averageOutwardReturnsCount":0,"averageStopPaymentCount":0,"averageBalanceAt_1st":0,"averageBalanceAt_5th__c":0,"averageBalanceAt_10th":0,"averageBalanceAt_15th":0,"averageBalanceAt_20th":0,"averageBalanceAt_25th":0,"averageAverageBankBalance":0};  ;
      _wiredForSvinJointCa
      @wire(getBankingDetailsSummaryCASA,{ recordId: '$recordId'})    // @wire(getData,{params:'$paramsforSav'})
      ForSvinJointCa(wiredForSvinJointCa) {
          const { data, error } = wiredForSvinJointCa;
          this._wiredForSvinJointCa = wiredForSvinJointCa;
          console.log('this._wiredFForSvinJointCa',this._wiredForSvinJointCa);
          let listOfAllChildReco=[];
          if (data) {
              console.log('CASA data-->',data);
              for(const record of data){
                  console.log('ForSvinJointCa'+JSON.stringify(record))
                  listOfAllChildReco.push(record);
              
              }
             var listSvinJointCaArddingVals=[];
             listSvinJointCaArddingVals = this.forCreateDataForConsolidateTable(listOfAllChildReco);
             this.listOfSvinJointCaAdd=listSvinJointCaArddingVals
             this.listOfSvinJointCaAdd.sort(this.customSort);
             this.listOfSvinJointCaAdd=this.calculationforsum(this.listOfSvinJointCaAdd);
              let lengthOfList = this.listOfSvinJointCaAdd.length;
              this.calForTotalAndAverageSav= this.calForTotalAndAverage(this.listOfSvinJointCaAdd,lengthOfList);
              console.log('this.calForTotalAndAverageSav'+JSON.stringify(this.calForTotalAndAverageSav));
              console.log('lengthOfList>>>'+lengthOfList);
          } else if (error) {
              console.log(error);
          }
      }
  
      showToast(title, variant, message) {
          const evt = new ShowToastEvent({
              title: title,
              variant: variant,
              message: message
          });
          this.dispatchEvent(evt);
          
      }
      
  
      forCreateDataForConsolidateTable(ListOfChildRec){
          console.log('listofchild@@@@@@@@@@'+JSON.stringify(ListOfChildRec));
          
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
          let listofRecAfteArddingVals=[];
  
          let sumcheckMiniChan='';
          let checkMiniChan=false;
          console.log('recordsByMonthYearMap'+JSON.stringify(recordsByMonthYearMap));
          for (const [monthYear, records] of recordsByMonthYearMap) {
              console.log('[monthYear, records]'+[monthYear, records]);
                  sumcheckMiniChan='';
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
  
              for (const record of records) {
                 
                  if(sumcheckMiniChan ==undefined || sumcheckMiniChan =='N' || sumcheckMiniChan ==''){
                      console.log('this.finalOfMiniAver'+sumcheckMiniChan)
                      sumcheckMiniChan =record.MinBalanceCharges__c == '' ||  record.MinBalanceCharges__c == null ||  record.MinBalanceCharges__c == undefined ? 'N' :  record.MinBalanceCharges__c;
                  }
                  console.log('recordrecordrecord'+record);
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
                  
  
              }
              listofRecAfteArddingVals.push({
                  monthYear: monthYear,
                  sumValueSummationCredit: sumValueSummationCredit,
                  sumValueSummationDebit: sumValueSummationDebit,
                  sumChangesCountofDebit :	sumChangesCountofDebit,
                  sumChangesCountofCredit :	sumChangesCountofCredit, 	 			
                  sumChangesAverageBankBalance :	sumChangesAverageBankBalance, 	
                  sumChangesBalanceAt_25th :	sumChangesBalanceAt_25th, 	
                  sumChangesBalanceAt_20th :	sumChangesBalanceAt_20th, 	
                  sumChangesBalanceAt_1st :	 sumChangesBalanceAt_1st, 	
                  sumChangesBalanceAt_5th__c :sumChangesBalanceAt_5th__c, 	
                  sumChangesBalanceAt_10th :	sumChangesBalanceAt_10th, 	
                  sumChangesBalanceAt_15th :sumChangesBalanceAt_15th, 	
                  sumInwardReturnsCount :	  sumInwardReturnsCount, 		
                  sumOutwardReturnsCount :sumOutwardReturnsCount, 	
                  sumChangesStopPaymentCount : sumChangesStopPaymentCount,
                  sumcheckMiniChan : sumcheckMiniChan  	
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
              const sumFields = ['sumChangesBalanceAt_15th','sumChangesBalanceAt_10th', 'sumChangesBalanceAt_5th__c', 'sumChangesBalanceAt_1st', 'sumChangesBalanceAt_20th', 'sumChangesBalanceAt_25th'];
              let sum = 0;
              sumFields.forEach(field => {
                  if (record[field] !== null && !isNaN(record[field])) {
                  var numberasvar=Number(record[field])
                  
                      sum += parseFloat(numberasvar);
              
                  }
                  
              });
                  
              var sumWithAver=(sum/ListOfRecords.length).toFixed(2)
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
     // forTotalAndAverage={"totalValueSummationDebit":0,"finalOfMinibalanceChar":'N',"totalValueSummationCredit":0,"totalCountofCredit":0,"totalCountofDebit":0,"totalInwardReturnsCount":0,"totalOutwardReturnsCount":0,"totalStopPaymentCount":0,"totalBalanceAt_1st":0,"totalBalanceAt_5th__c":0,"totalBalanceAt_10th":0,"totalBalanceAt_15th":0,"totalBalanceAt_20th":0,"totalBalanceAt_25th":0,"totalAverageBankBalance":0,"averageValueSummationCredit":0,"averageValueSummationDebit":0,"averageCountofCredit":0,"averageCountofDebit":0,"averageInwardReturnsCount":0,"averageOutwardReturnsCount":0,"averageStopPaymentCount":0,"averageBalanceAt_1st":0,"averageBalanceAt_5th__c":0,"averageBalanceAt_10th":0,"averageBalanceAt_15th":0,"averageBalanceAt_20th":0,"averageBalanceAt_25th":0,"averageAverageBankBalance":0};  
      calForTotalAndAverage(ListOfRecords,lengthOfData){
          var forTotalAndAverage={"totalValueSummationDebit":0,"finalOfMinibalanceChar":'N',"totalValueSummationCredit":0,"totalCountofCredit":0,"totalCountofDebit":0,"totalInwardReturnsCount":0,"totalOutwardReturnsCount":0,"totalStopPaymentCount":0,"totalBalanceAt_1st":0,"totalBalanceAt_5th__c":0,"totalBalanceAt_10th":0,"totalBalanceAt_15th":0,"totalBalanceAt_20th":0,"totalBalanceAt_25th":0,"totalAverageBankBalance":0,"averageValueSummationCredit":0,"averageValueSummationDebit":0,"averageCountofCredit":0,"averageCountofDebit":0,"averageInwardReturnsCount":0,"averageOutwardReturnsCount":0,"averageStopPaymentCount":0,"averageBalanceAt_1st":0,"averageBalanceAt_5th__c":0,"averageBalanceAt_10th":0,"averageBalanceAt_15th":0,"averageBalanceAt_20th":0,"averageBalanceAt_25th":0,"averageAverageBankBalance":0};  
          let i=0;
          console.log('ListOfRecordnewwws>>>>>>>'+JSON.stringify(ListOfRecords));
          let sumcheckMiniChan='';
          console.log('lengthOfData'+lengthOfData)
          let checkMiniChan=false;
          for (const record of ListOfRecords) {
              var fortoal={}
              if(sumcheckMiniChan ==undefined || sumcheckMiniChan =='N' || sumcheckMiniChan ==''){
                 sumcheckMiniChan =record.sumcheckMiniChan == '' ||  record.sumcheckMiniChan == null ||  record.sumcheckMiniChan == undefined ? 'N' :  record.sumcheckMiniChan;
              }
              forTotalAndAverage.finalOfMinibalanceChar=sumcheckMiniChan
              forTotalAndAverage.totalValueSummationCredit += record.sumValueSummationCredit;
              forTotalAndAverage.totalValueSummationDebit += record.sumValueSummationDebit;
              forTotalAndAverage.totalCountofCredit += record.sumChangesCountofCredit;
              forTotalAndAverage.totalCountofDebit += record.sumChangesCountofDebit;
              forTotalAndAverage.totalInwardReturnsCount += record.sumInwardReturnsCount
              forTotalAndAverage.totalOutwardReturnsCount += record.sumOutwardReturnsCount
              forTotalAndAverage.totalStopPaymentCount += record.sumChangesStopPaymentCount
              forTotalAndAverage.totalBalanceAt_1st += record.sumChangesBalanceAt_1st
              forTotalAndAverage.totalBalanceAt_5th__c += record.sumChangesBalanceAt_5th__c
              forTotalAndAverage.totalBalanceAt_10th += record.sumChangesBalanceAt_10th
              forTotalAndAverage.totalBalanceAt_15th += record.sumChangesBalanceAt_15th
              forTotalAndAverage.totalBalanceAt_20th += record.sumChangesBalanceAt_20th
              forTotalAndAverage.totalBalanceAt_25th += record.sumChangesBalanceAt_25th
              forTotalAndAverage.totalAverageBankBalance += Number(record.sumChangesAverageBankBalance)
  
              forTotalAndAverage.averageValueSummationCredit =(forTotalAndAverage.totalValueSummationCredit / lengthOfData).toFixed(2);
              forTotalAndAverage.averageValueSummationDebit = (forTotalAndAverage.totalValueSummationDebit / lengthOfData).toFixed(2);
              forTotalAndAverage.averageCountofCredit =  (forTotalAndAverage.totalCountofCredit / lengthOfData).toFixed(2);
              forTotalAndAverage.averageCountofDebit = (forTotalAndAverage.totalCountofDebit / lengthOfData).toFixed(2);
              forTotalAndAverage.averageInwardReturnsCount =(forTotalAndAverage.totalInwardReturnsCount / lengthOfData).toFixed(2);
              forTotalAndAverage.averageOutwardReturnsCount =  (forTotalAndAverage.totalOutwardReturnsCount / lengthOfData).toFixed(2);
              forTotalAndAverage.averageStopPaymentCount = (forTotalAndAverage.totalStopPaymentCount / lengthOfData).toFixed(2);
              forTotalAndAverage.averageBalanceAt_1st = (forTotalAndAverage.totalBalanceAt_1st / lengthOfData).toFixed(2);
              forTotalAndAverage.averageBalanceAt_5th__c = (forTotalAndAverage.totalBalanceAt_5th__c / lengthOfData).toFixed(2);
              forTotalAndAverage.averageBalanceAt_10th = (forTotalAndAverage.totalBalanceAt_10th / lengthOfData).toFixed(2);
              forTotalAndAverage.averageBalanceAt_15th = (forTotalAndAverage.totalBalanceAt_15th / lengthOfData).toFixed(2);
              forTotalAndAverage.averageBalanceAt_20th = (forTotalAndAverage.totalBalanceAt_20th / lengthOfData).toFixed(2);
              forTotalAndAverage.averageBalanceAt_25th = (forTotalAndAverage.totalBalanceAt_25th / lengthOfData).toFixed(2);
              forTotalAndAverage.averageAverageBankBalance = (forTotalAndAverage.totalAverageBankBalance / lengthOfData).toFixed(2);
              forTotalAndAverage.averageOfUtilization= forTotalAndAverage.averageAverageBankBalance !=''&& forTotalAndAverage.averageAverageBankBalance !=null && typeof forTotalAndAverage.averageAverageBankBalance !==undefined  ? ((forTotalAndAverage.averageAverageBankBalance * 100) /this.totalLimitValue ).toFixed(2) : 0
             
          }
          console.log('forTotalAndAverage'+JSON.stringify(forTotalAndAverage));
          return forTotalAndAverage;
      }
    
     showUi=false
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
      }*/
}