public with sharing class RegulatoryHandler {
    
    @AuraEnabled()
    public static String createRegulatoryRecord(RegulatoryCreateWrapper wrapObj
                                               ){ 
                                                   
                                                   String status; 
                                                   try{
                                                       system.debug(wrapObj);
                                                       ApplRegltry__c newReg = new ApplRegltry__c();
                                                       /* newLead.MobilePhone = wrapObj.mobile;  
newLead.Status =  wrapObj.leadStatus;
newLead.RM_SM_Name__c = wrapObj.rmNameId;       
newLead.CurrentResidenceCity__City__s  = wrapObj.currentCitySearch;       
newLead.OfficeAddressCity__City__s  = wrapObj.officeCitySearch;        
newLead.Requested_loan_amount__c = wrapObj.loanAmount;  
newLead.Property_Identified__c = wrapObj.propertyIdentifiedValue;
newLead.Additional_Comments__c = wrapObj.otherReason;
newLead.UnservicableCityCheck__c = wrapObj.cityService;*/
                                                       newReg.IsBorowrOrRelFFDir__c=wrapObj.IsBorowrOrRelFFDir;
                                                       newReg.CharDiscrmtn__c=wrapObj.CharDiscrmtn;
                                                       newReg.DealngIndstry__c=wrapObj.DealngIndstry;
                                                       newReg.Desgntn__c=wrapObj.Desgntn;
                                                       newReg.FundInESGPol__c=wrapObj.FundInESGPol;
                                                       newReg.FFDirRelIntrstAsPart__c=wrapObj.FFDirRelIntrstAsPart;
                                                       newReg.FFDirRelIntrstAsSH__c	=wrapObj.FFDirRelIntrstAsSH;
                                                       newReg.DirName__c=wrapObj.DirName;
                                                       newReg.Reltnshp__c=wrapObj.Reltnshp;
                                                       
                                                       /*  if(String.isnotBlank(wrapObj.lastName)){
newLead.LastName = wrapObj.lastName; 
}else{
newLead.LastName = wrapObj.companyChange; 
}
if(String.isnotBlank(wrapObj.leadRecordId)){
newLead.Id = wrapObj.leadRecordId;
}

//newLead.Id = wrapObj.leadRecordId;
if(wrapObj.assessedIncomeProgramValue){
newLead.IsthisAssessedIncomePrg__c = wrapObj.assessedIncomeProgramValue;
}else{
newLead.IsthisAssessedIncomePrg__c = false;
}             
if(wrapObj.tenure != null){
newLead.Requested_tenure_in_Months__c = wrapObj.tenure;
}
if(wrapObj.doiValue != null){
newLead.DOI__c = wrapObj.doiValue;
}
if(wrapObj.dob != null){
newLead.DOB__c = wrapObj.dob;
}       
// if(String.isnotBlank(wrapObj.accountId)){
//     newLead.Channel_Name__c = wrapObj.accountId;       
// }  
newLead.Channel_Name__c = wrapObj.accountId;    

newLead.Property_Category__c = wrapObj.propertyCategoryValue;        
newLead.Disposition_Remarks__c = wrapObj.depositionRemark;        
newLead.Company = wrapObj.companyChange;        
newLead.KeymanName__c = wrapObj.keyManName;       
newLead.FirstName = wrapObj.firstName;       
newLead.Email = wrapObj.emailId;       
newLead.Constitution__c = wrapObj.constitutionValue;       
newLead.Customer_Profile__c = wrapObj.customerProfileValue;            
newLead.LeadSource = wrapObj.leadValue; 
newLead.Disposition_Status__c =wrapObj.DispositionStatus;       
newLead.Product__c = wrapObj.productValue;       
newLead.Product_Sub_Type__c	 = wrapObj.productSubTypeValue;     
newLead.Promotion_Code__c = wrapObj.promotionCode;
newLead.Lead_Closure_Reason__c = wrapObj.leadClosureValue;
newLead.LMS_lead_ID__c = wrapObj.lmsLeadId;
newLead.Referral_Employee_Code__c = wrapObj.referralCode;*/
                                                       
                                                       upsert newReg; 
                                                       
                                                       system.debug('New Lead -'+ newReg.id);
                                                       status = newReg.Id ;        
                                                   }catch(Exception e){
                                                       system.debug(wrapObj);
                                                       status =''+e.getCause()+' '+ e.getLineNumber()+' '+ e.getStackTraceString() + '' + e.getMessage();  
                                                   }
                                                   system.debug('lead id msg+'+status);
                                                   return status; 
                                               }   
    
   
}