public with sharing class DummyClassHL {
    /* @AuraEnabled(cacheable=true)
    public static List<HLRelatedDetailsWrapper> getHLRelatedDetailsData(String recordId){
        
        List<HLRelatedDetailsWrapper> listRecordWrapperHL = new List<HLRelatedDetailsWrapper>();
        
        List<ApplAsset__c>  applicantAssetsList = new List<ApplAsset__c>();
        List<LoanAppl__c>  loanApplicationList = new List<LoanAppl__c>();
        
       applicantAssetsList = [Select id,Agrem_Value__c, Regi_Cost__c, Stamp_Duty__c, Amenities__c, Total_Prop_Cost__c,
                              Down_payment_PartORegisteredAgreement__c, Balance_OCR_to_be_arranged_by_customer__c,
                              Total_estimate_as_per_architect_agreemen__c,Stage_of_Construction__c, 
                              StageOfConstrAsPerValuatioReport__c,Land_Valu__c,ValuationToBeTakenAheadForCalculation__c,
                              Built_up_area_Valu__c from ApplAsset__c where LoanAppln__c =:recordId]; //a08C4000007x0uSIAQ
        
        loanApplicationList = [Select id,Final_Loan_Disbursal_Amount__c,Product__c,SchemeId__c from LoanAppl__c where id=:recordId];
        
        
      //   List<SchMapping__c> schObjectList = new List<SchMapping__c>();
        
     //   if(loanApplicationList.size()>0){
            
     //       schObjectList=[select id,SchemeDesc__c,IsConstruction__c from SchMapping__c where id=:loanApplicationList[0].SchemeId__c];
     //      }
            
        
        
        decimal registeredAggrementValueSum =0;
        decimal downPaymentSum =0;
        decimal balanceAmountSum =0;
        decimal fedfinaLoanFundingSum =0;
        decimal balanceOCRSum =0;
        decimal mktValueOfPropertySum =0;
        
     if(applicantAssetsList.size()>0){
            
        for(ApplAsset__c appAsset: applicantAssetsList){
            
            
            
            registeredAggrementValueSum += appAsset.Agrem_Value__c == null ? 0 : appAsset.Agrem_Value__c;
            downPaymentSum += appAsset.Down_payment_PartORegisteredAgreement__c == null ? 0 : appAsset.Down_payment_PartORegisteredAgreement__c;
            balanceOCRSum  += appAsset.Balance_OCR_to_be_arranged_by_customer__c == null ? 0 : appAsset.Balance_OCR_to_be_arranged_by_customer__c;
            mktValueOfPropertySum += appAsset.ValuationToBeTakenAheadForCalculation__c == null ? 0 : appAsset.ValuationToBeTakenAheadForCalculation__c;
            
            
            
        }
            
        
        
            
            HLRelatedDetailsWrapper RecordWrapperHLData = new HLRelatedDetailsWrapper();
           // RecordWrapperHLData.isConstruction = false;
            RecordWrapperHLData.isHomeLoan = false;
            RecordWrapperHLData.registeredAggrementValue = registeredAggrementValueSum;
            RecordWrapperHLData.downPayment = downPaymentSum;
            RecordWrapperHLData.balanceAmount = registeredAggrementValueSum - downPaymentSum;
            RecordWrapperHLData.balanceOCR  = balanceOCRSum;
            RecordWrapperHLData.mktValueOfProperty = mktValueOfPropertySum;
            if(loanApplicationList.size()>0){
                 RecordWrapperHLData.fedfinaLoanFunding = loanApplicationList[0].Final_Loan_Disbursal_Amount__c == null ? 0 : loanApplicationList[0].Final_Loan_Disbursal_Amount__c;
            }
         
       //     if(schObjectList.size()>0)
       //     {
       //         if(schObjectList[0].IsConstruction__c=='Yes')
       //         {
        //           RecordWrapperHLData.isConstruction=true; 
        //        }
                
        //    }
         if(loanApplicationList.size()>0)
            {
                if(loanApplicationList[0].Product__c== 'Home Loan')
                {
                   RecordWrapperHLData.isHomeLoan=true; 
                }
                
            }
            
            listRecordWrapperHL.add(RecordWrapperHLData);
            
            system.debug('listRecordWrapperHL-->'+listRecordWrapperHL);
       
        }
         return listRecordWrapperHL;
           
        
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<ConstructionRelatedDetailsWrapper> getConstructionRelatedDetailData(String recordId){
        
        List<ConstructionRelatedDetailsWrapper> listRecordWrapperConstruction = new List<ConstructionRelatedDetailsWrapper>();
        
        List<ApplAsset__c>  applicantAssetsList = new List<ApplAsset__c>();
        List<LoanAppl__c>  loanApplicationList = new List<LoanAppl__c>();
        List<CollateralVisitJn__c>  collateralVisitList = new List<CollateralVisitJn__c>();
        
       applicantAssetsList = [Select id,Agrem_Value__c, Regi_Cost__c, Stamp_Duty__c, Amenities__c, Total_Prop_Cost__c,
                              Down_payment_PartORegisteredAgreement__c, Balance_OCR_to_be_arranged_by_customer__c,
                              Total_estimate_as_per_architect_agreemen__c,Stage_of_Construction__c, 
                              StageOfConstrAsPerValuatioReport__c,Land_Valu__c,ValuationToBeTakenAheadForCalculation__c,
                              Built_up_area_Valu__c,PropAddrs__c from ApplAsset__c where LoanAppln__c =:recordId];
        
        loanApplicationList = [Select id,Final_Loan_Disbursal_Amount__c,Product__c,SchemeId__c from LoanAppl__c where id=:recordId];
        
        
         List<SchMapping__c> schObjectList = new List<SchMapping__c>();
        
        if(loanApplicationList.size()>0){
            
            schObjectList=[select id,SchemeDesc__c,IsConstruction__c from SchMapping__c where id=:loanApplicationList[0].SchemeId__c];
           }
        
        Map<Id,String>MapOfLatestDateofConstruction = new Map<Id,String>();
        
         collateralVisitList = [select id, Resp__c,case__r.ApplAssetId__c from CollateralVisitJn__c 
                where Case__r.RecordType.Name = 'Collateral Visit' 
		        AND PropQues__r.Question_Tiltle__c  ='Tentative Date of Completion' 
                and case__r.isCompleted__C = true and case__r.Loan_Application__c =:recordId 
                order by Case__r.CreatedDate Desc];
        
      if(collateralVisitList.size()>0){
            
       for(CollateralVisitJn__c cvjn: collateralVisitList){
           
	      if(!MapOfLatestDateofConstruction.containsKey(cvjn.case__r.ApplAssetId__c)){
		    MapOfLatestDateofConstruction.put(cvjn.case__r.ApplAssetId__c,cvjn.Resp__c);
	      }
           
         }
            }
        
        
     if(applicantAssetsList.size()>0){
            
        for(ApplAsset__c appAsset: applicantAssetsList){
            
            system.debug('count');
            
             ConstructionRelatedDetailsWrapper RecordWrapperConstructionData = new ConstructionRelatedDetailsWrapper();
            RecordWrapperConstructionData.isConstruction = false;
            //RecordWrapperConstructionData.isHomeLoan = false; 
            RecordWrapperConstructionData.totalEstimateAsPerArtitech = appAsset.Total_estimate_as_per_architect_agreemen__c == null? 0:appAsset.Total_estimate_as_per_architect_agreemen__c;
            RecordWrapperConstructionData.stageOfConstruction = appAsset.Stage_of_Construction__c == null? 0:appAsset.Stage_of_Construction__c;
            RecordWrapperConstructionData.landValue = appAsset.Land_Valu__c == null? 0:appAsset.Land_Valu__c;
            RecordWrapperConstructionData.constructionValue = appAsset.Built_up_area_Valu__c == null? 0:appAsset.Built_up_area_Valu__c;
            RecordWrapperConstructionData.totalValuation = appAsset.ValuationToBeTakenAheadForCalculation__c == null? 0:appAsset.ValuationToBeTakenAheadForCalculation__c;
            RecordWrapperConstructionData.EstimateDate   = MapOfLatestDateofConstruction.get(appAsset.Id);
            RecordWrapperConstructionData.propertyAddress = appAsset.PropAddrs__c;
            
             if(schObjectList.size()>0)
            {
                if(schObjectList[0].IsConstruction__c=='Yes')
                {
                   RecordWrapperConstructionData.isConstruction=true; 
                }
                
            }
       //  if(loanApplicationList.size()>0)
      //      {
       //         if(loanApplicationList[0].Product__c== 'Home Loan')
        //        {
         //          RecordWrapperConstructionData.isHomeLoan=true; 
           //     }
                
          //  }
            
            
            listRecordWrapperConstruction.add(RecordWrapperConstructionData);
           
            
            
            
        }
            
         system.debug('listRecordWrapperConstruction-->'+listRecordWrapperConstruction);
            system.debug('listRecordWrapperConstruction size()-->'+listRecordWrapperConstruction.size());
        
        }
         return listRecordWrapperConstruction;
           
        
    }
    
    public class HLRelatedDetailsWrapper{
        // For HL
        @AuraEnabled
        public decimal registeredAggrementValue{get;set;}
        @AuraEnabled
        public decimal downPayment{get;set;}
        @AuraEnabled
        public decimal balanceAmount{get;set;}
        @AuraEnabled
        public decimal fedfinaLoanFunding{get;set;}
        @AuraEnabled
        public decimal balanceOCR{get;set;}
        @AuraEnabled
        public decimal mktValueOfProperty{get;set;}
        @AuraEnabled
        public boolean isConstruction{get;set;}
        @AuraEnabled
        public boolean isHomeLoan{get;set;}
        
        
    }
    
    public class ConstructionRelatedDetailsWrapper{
        // For Construction
        
         @AuraEnabled
        public decimal totalEstimateAsPerArtitech{get;set;}
         @AuraEnabled
        public String EstimateDate{get;set;}
         @AuraEnabled
        public decimal stageOfConstruction{get;set;}
        @AuraEnabled
        public decimal landValue{get;set;}
        @AuraEnabled
        public decimal constructionValue{get;set;}
        @AuraEnabled
        public decimal totalValuation{get;set;}
        @AuraEnabled
        public String propertyAddress{get;set;}
         @AuraEnabled
        public boolean isConstruction{get;set;}
        @AuraEnabled
        public boolean isHomeLoan{get;set;}
    }*/

}