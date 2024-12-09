public with sharing class DataCaptureSummaryController {
    
    @AuraEnabled // (cacheable=true) commented bz not  showing updated value on tab change  //string param
    public static CombinedObjectData getCombinedObjData( String params){
        system.debug('params>>>>'+params);
        
        CombinedObjectData combinedData = new CombinedObjectData();
        
        List<Applicant__c> applTypeList = [SELECT Id, FName__c,FullName__c, LName__c, ApplType__c, LoanAppln__c FROM Applicant__c where LoanAppln__c =:params];
        system.debug('applTypeList>>>'+applTypeList);
        if (applTypeList != null) {
            system.debug('data available>>>');
            combinedData.applTypeData =applTypeList;
        }
        List<Deviation__c> deviationList = [SELECT Id, Apprv_By__c, Devia_Desrp__c, Appr_Remarks__c, Mitigation__c, Dev_DescrId__c, Req_Apprv_Level__c, Dev_Type__c,BRE__c,BRE__r.IsLatest__c, LoanAppln__c FROM Deviation__c where LoanAppln__c=:params and ((BRE__r.IsLatest__c=true and Dev_Type__c='System') OR Dev_Type__c='Manual')];
        system.debug('deviationList>>>'+deviationList);
        if (deviationList != null) {
            system.debug('data available>>>');
            combinedData.deviationData =deviationList;
        }
        
        
        
        List<Sanction_Conditions__c> sancCondtnList =   [SELECT Id, Condition__c,Remarks__c, Loan_Application__c FROM Sanction_Conditions__c where Loan_Application__c =:params];
       

        system.debug('sancCondtnList>>>'+sancCondtnList);
        if (sancCondtnList != null) {
            system.debug('data available>>>');
            combinedData.sancCondtnData =sancCondtnList;
            
        }
        
        List<Repayment_Account__c> repaymentDataList = [SELECT Id, Is_Active__c, Repayment_Mode__c,Applicant_Banking__r.Name_of_the_Primary_Account_Holder_s__c,Applicant_Banking__r.BankName__c,Applicant_Banking__r.AC_No__c,Loan_Application__c,Applicant_Banking__r.eNACHFeasible__c,Applicant_Banking__r.NACHFeasible__c FROM Repayment_Account__c where Is_Active__c=true AND Loan_Application__c=:params];
        system.debug('data available>>>'+repaymentDataList);
        if (repaymentDataList != null) {
            
            combinedData.repaymentData =repaymentDataList;
        }
       
        List<Repayment_Account__c> repayAccList = [select id,Repayment_Mode__c,Loan_Application__c,(select id,Mandate_Type__c,IsActive__c from NACH__r where IsActive__c=true ) from Repayment_Account__c  where Is_Active__c=true AND Loan_Application__c=:params ];
         if (repayAccList != null) {
                
                combinedData.RepaymentModeData = repayAccList;
            }
            
            List<ApplAsset__c> applAssetDataList =   [SELECT Id, Name, Appl__c, LoanAppln__c, PropType__c, PropAddrs__c, Prop_Owners__c FROM ApplAsset__c where LoanAppln__c=:params];
            system.debug('data available>>>'+applAssetDataList);
            if (applAssetDataList != null) {
                
                combinedData.applAssetData = applAssetDataList;
            }
            
            List<LoanAppl__c> loanApplcantList = [SELECT Id,Actual_LTV__c,Actual_FOIR__c,Applicant__c,ReqInterestType__c,Total_PF_Amount__c,Product__c,EMI_Proposed_Loan__c, Stage__c, SubStage__c, Name, Insurance_Amount__c,InsAmt__c,SanLoanAmt__c,Loan_Tenure_Months__c,EffectiveROI__c,TotalLoanAmtInclInsurance__c,ApprovedValidTill__c,OrgInsAmountLoanAppl__c,OrgSanctionLoanAmount__c FROM LoanAppl__c where id=:params];
            system.debug('data available>>>'+loanApplcantList);
            if (loanApplcantList != null) {
                
                combinedData.loanApplData =loanApplcantList;
            }
            
            List<BRE__c> loanBREDataList =[SELECT Id, LoanAppl__c, Applicant__c,Actual_FOIR__c, Actual_LTV__c,EMI__c,Application_Level_Assessment_Program__c FROM BRE__c where IsLatest__c=true AND LoanAppl__c=:params ];
            if (loanBREDataList.size()>0) {
                
                combinedData.loanBREData =loanBREDataList;
            }
            List<UWDecision__c> uwDecisionDateList = [SELECT Id, LoanAppl__c, Decision__c, Decision_Type__c, LastModifiedDate,LastModifiedById FROM UWDecision__c where LoanAppl__c=:params AND (Decision__c='Approved' or Decision__c='Soft Approved') order by LastModifiedDate desc];
            system.debug('data available>>>'+uwDecisionDateList);
            string userRoleId;
            if (uwDecisionDateList != null) {
                
                if(uwDecisionDateList.size() > 0) {
                    if(uwDecisionDateList[0].LastModifiedById!=null){
                        userRoleId =uwDecisionDateList[0].LastModifiedById;   
                    }
                    
                    
                }
                
                combinedData.uwDecisionDate =uwDecisionDateList;
                
            }
            
            
            system.debug('data available userRoleId>>>'+userRoleId);
         
         if(userRoleId!=null){
                List<SPDD_Approval_Config__c> empRoleLevelList = [select id,Dev_Level__c, LastModifiedBy.name,Role__c,Emp__c from SPDD_Approval_Config__c WHERE Emp__c=:userRoleId];
                
                if(empRoleLevelList!=null){
                    combinedData.empRoleLevel =empRoleLevelList;
                }            
            }
            
            system.debug('All object data combination>>'+combinedData);
            return combinedData;
        }
        
        
        public class CombinedObjectData{
            @AuraEnabled public List<BRE__c> loanBREData { get; set; }
            @AuraEnabled public List<UWDecision__c> uwDecisionDate { get; set; }
            @AuraEnabled public List<SPDD_Approval_Config__c> empRoleLevel { get; set; }
            @AuraEnabled public List<LoanAppl__c> loanApplData { get; set; }
            @AuraEnabled public List<Applicant__c> applTypeData { get; set; }
            @AuraEnabled public List<Sanction_Conditions__c> sancCondtnData { get; set; }
            @AuraEnabled public List<Repayment_Account__c> repaymentData { get; set; }
            @AuraEnabled public List<Repayment_Account__c> RepaymentModeData { get; set; }
            @AuraEnabled public List<ApplAsset__c> applAssetData { get; set; }
            @AuraEnabled public List<Deviation__c> deviationData { get; set; }
        }
        
        public class SobjectQueryParams {
            @AuraEnabled
            public string loanApplID { get; set; }
            
        }
        
    }