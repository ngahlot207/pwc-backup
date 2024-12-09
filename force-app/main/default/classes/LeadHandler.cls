public without sharing class LeadHandler {
   
    @AuraEnabled()
    public static String createLeadRecord(LeadCreateWrapper wrapObj
    ){ 
        String status; 
        try{
        system.debug(wrapObj);
        Lead newLead = new Lead();
        newLead.MobilePhone = wrapObj.mobile;   
        newLead.Status =  wrapObj.leadStatus;
        newLead.RM_SM_Name__c = wrapObj.rmNameId;       
        newLead.CurrentResidenceCity__City__s  = wrapObj.currentCitySearch;       
        newLead.OfficeAddressCity__City__s  = wrapObj.officeCitySearch;        
        newLead.Requested_loan_amount__c = wrapObj.loanAmount;  
        newLead.Requested_tenure_in_Months__c = wrapObj.tenure;
        newLead.Property_Identified__c = wrapObj.propertyIdentifiedValue;
        newLead.Additional_Comments__c = wrapObj.otherReason;
        newLead.UnservicableCityCheck__c = wrapObj.cityService;
        newLead.PromCodId__c = wrapObj.promCodeId;
        
        if(String.isnotBlank(wrapObj.lastName)){
            newLead.LastName = wrapObj.lastName; 
        }else{
            newLead.LastName = wrapObj.companyChange; 
        }
        system.debug('LeadRecordId 27' + wrapObj.leadRecordId);
         

        if(String.isnotBlank(wrapObj.leadRecordId)){
            newLead.Id = wrapObj.leadRecordId;
           system.debug('LeadRecordId 29' + wrapObj.leadRecordId);
        }
            if (String.isNotBlank(wrapObj.leadRecordId) && (wrapObj.leadRecordId.length() == 15 || wrapObj.leadRecordId.length() == 18)) {
    // Only set the Lead.Id if it's a valid Salesforce ID
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
        //Start of Changes for LAK-321
        if(wrapObj.leadROI != null){
            newLead.Lead_ROI__c = wrapObj.leadROI;
        }
        //End of changes for LAK-321
        
        //START LAK-61  
        if(wrapObj.leadFOIR != null){
            newLead.Lead_FOIR__c = wrapObj.leadFOIR.setScale(2);
        }
        if(wrapObj.emi != null){
            newLead.EMI__c = wrapObj.emi.setScale(2);
        }  
        if(wrapObj.EMIperLac != null){
            newLead.EMI_per_Lac__c = wrapObj.EMIperLac.setScale(2);
        }
            if(wrapObj.declredMontlyIncVal != null){
            newLead.DeclaredMonthlyIncome__c = wrapObj.declredMontlyIncVal.setScale(2);
        }
            if(wrapObj.declredMontlyOblVal != null){
            newLead.DeclaredMonthlyObligation__c = wrapObj.declredMontlyOblVal.setScale(2);
        }
            if(wrapObj.eligibilityinlacs != null){
            newLead.Eligibility_in_lacs__c = wrapObj.eligibilityinlacs.setScale(2);
        }
        if(wrapObj.selectDSABranchId != null){
            newLead.Branch__c = wrapObj.selectDSABranchId;
        }
        if(!String.isBlank(wrapObj.selectDSACityId)){
            newLead.LocMstr__c = wrapObj.selectDSACityId;
        }
        //END LAK-61  
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
        newLead.Referral_Employee_Code__c = wrapObj.referralCode;
        newLead.EMI__c = wrapObj.emi;
        newLead.EMI_per_Lac__c = wrapObj.EMIperLac;
        newLead.DeclaredMonthlyIncome__c = wrapObj.declredMontlyIncVal;
        newLead.DeclaredMonthlyObligation__c= wrapObj.declredMontlyOblVal;
        newLead.Eligibility_in_lacs__c= wrapObj.eligibilityinlacs;  
        upsert newLead; 

        system.debug('New Lead -'+ newLead.id);
        status = newLead.Id ;        
        }catch(Exception e){
            system.debug(wrapObj);
            status =''+e.getCause()+' '+ e.getLineNumber()+' '+ e.getStackTraceString() + '' + e.getMessage();  
        }
        system.debug('lead id msg+'+status);
        return status; 
    } 
    ///LAK-91
    @AuraEnabled()
    public static string checkDuplicateLead(String leadRecordID, String mobile) {
         String empRole;
        if (String.isNotBlank(leadRecordID) && String.isNotBlank(mobile)) {
            
            Case newCase = new Case();
            // Query the lead and owner information
            list<Lead> lead = [SELECT Id, OwnerId, Approved_Rejected__c,Product__c,Disposition_Status__c,LeadSource FROM Lead WHERE Id = :leadRecordID];
            system.debug('lead'+lead);
            if(lead.size()>0){
            if(!String.isNotBlank(lead[0].Approved_Rejected__c)){
            // Query the team hierarchy for the lead owner
            list<TeamHierarchy__c> ownerTeam = [
                SELECT Id, Employee__c, EmpBrch__c, EmpRole__c
                FROM TeamHierarchy__c 
                WHERE Employee__c = :lead[0].OwnerId
            ];
            if (ownerTeam.size() > 0) {
     empRole = ownerTeam[0].EmpRole__c;
    System.debug('EmpRole__c' + empRole);
 
    // Query the team hierarchy for BBH and RBH roles
    List<TeamHierarchy__c> branchTeam = [
                SELECT Id, Employee__c, EmpBrch__c, EmpRole__c 
                FROM TeamHierarchy__c 
        WHERE EmpBrch__c = :ownerTeam[0].EmpBrch__c
        AND EmpRole__c IN ('BBH', 'RBH')
        AND IsActive__c = true
                ORDER BY LastModifiedDate DESC
            ];
 
    if (branchTeam.size() > 0) {
        if (lead[0] != null && lead[0].LeadSource != null && lead[0].LeadSource == 'DSA') {
            for (TeamHierarchy__c member : branchTeam) {
                if (member.EmpRole__c == 'RBH') {
                    newCase.OwnerId = member.Employee__c;
                    break;
                }
            }
        } else {
            for (TeamHierarchy__c member : branchTeam) {
                if (member.EmpRole__c == 'BBH') {
                    newCase.OwnerId = member.Employee__c;
                    break;
                }
            }
            	}
            }
}
            // Query applicants by mobile number
            List<Applicant__c> appListRecords = [
                SELECT Id, MobNumber__c, LoanAppln__r.CreatedDate, LoanAppln__r.Status__c, LoanAppln__r.Product__c,
                       LoanAppln__r.FirstApprovalDate__c, LoanAppln__r.Stage__c, LoanAppln__r.SubStage__c,LoanAppln__r.RejectReason__c
                FROM Applicant__c 
                WHERE MobNumber__c = :mobile 
                ORDER BY CreatedDate DESC
            ];
            System.debug('Applications: ' + appListRecords);

            // Filter applicant records based on criteria
            List<Applicant__c> appRecordsFound = new List<Applicant__c>();
            Date sixMonthsAgo = Date.today().addMonths(-6);
            Date threeMonthsAgo = Date.today().addMonths(-3);
			
            if(appListRecords.size()>0){
            for (Applicant__c record : appListRecords) {
                if(record.LoanAppln__r.Status__c == 'Rejected' && record.LoanAppln__r.RejectReason__c !=null && record.LoanAppln__r.RejectReason__c.toLowerCase().contains('fraud')){
                    
                	lead[0].Status = 'Rejected';
                	lead[0].Match_Found__c = true;
                    lead[0].Disposition_Status__c = 'Lead closed';
                	update lead;
                    
                    return 'Rejected';
                }
                else if (record.LoanAppln__r.Status__c == 'Rejected' && record.LoanAppln__r.CreatedDate >= sixMonthsAgo) {
                    appRecordsFound.add(record);
                    System.debug('Loan Application inside Rejected and sixMonthsAgo');
                } else if (record.LoanAppln__r.Status__c == 'Approved' && record.LoanAppln__r.Stage__c == 'Disbursement Initiation' 
                           && record.LoanAppln__r.FirstApprovalDate__c >= threeMonthsAgo && record.LoanAppln__r.Product__c == lead[0].Product__c
                           && (record.LoanAppln__r.SubStage__c == 'DI Check' || record.LoanAppln__r.SubStage__c == 'DI Pool')) {
                    appRecordsFound.add(record);
                    System.debug('Loan Application inside Disbursement Initiation and threeMonthsAgo and DI Check and DI Pool');
                } else if ((record.LoanAppln__r.Status__c == 'In Progress' || record.LoanAppln__r.Status__c == 'Approved') 
                           && record.LoanAppln__r.CreatedDate >= sixMonthsAgo && record.LoanAppln__r.Product__c == lead[0].Product__c) {
                    if (record.LoanAppln__r.Stage__c != 'Post Sanction' && record.LoanAppln__r.Stage__c != 'Disbursement Initiation' 
                        && record.LoanAppln__r.Stage__c != 'Disbursed') {
                        appRecordsFound.add(record);
                        System.debug('Loan Application inside Disbursement Initiation and threeMonthsAgo and DI Check and DI Pool');
                    }
                }
            }
            }

            // If matching records are found, update lead status and create case
            if (!appRecordsFound.isEmpty() && empRole != null && empRole == 'DSA' ) {
                lead[0].Status = 'Referred to RSM';
                lead[0].Match_Found__c = true;
                update lead;
                //Get RecordTypeId of Lead ounery
                Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Lead Journey' LIMIT 1].Id;
                
                newCase.RecordTypeId = recordTypeId;
                newCase.Lead__c = lead[0].Id;
                newCase.Loan_Application__c = appRecordsFound[0].LoanAppln__c;
                newCase.Applicant__c = appRecordsFound[0].Id;
                insert newCase;

                Case cas = [select id,ownerid,CaseNumber from case where id=: newCase.id];
                lead[0].Case_No__c = cas.CaseNumber;
                lead[0].Case_Owner__c = cas.OwnerId;
                update lead;
                
                
                    return 'Referred to RSM';
 
                }
                else if(!appRecordsFound.isEmpty() && empRole != 'DSA'){
                lead[0].Status = 'Referred to BBH';
                lead[0].Match_Found__c = true;
                //update lead;
 
                 // Get RecordTypeId of Lead Journey
                Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Lead Journey' LIMIT 1].Id;
 
   
   
                newCase.RecordTypeId = recordTypeId;
                newCase.Lead__c = lead[0].Id;
                newCase.Loan_Application__c = appRecordsFound[0].LoanAppln__c;
                newCase.Applicant__c = appRecordsFound[0].Id;
                insert newCase;

                Case cas = [select id,ownerid,CaseNumber from case where id=: newCase.id];
                lead[0].Case_No__c = cas.CaseNumber;
                lead[0].Case_Owner__c = cas.OwnerId;
                update lead;
 
                    return 'Referred to BBH';
            }
            }
        }
        }
        			
                    return 'No Match Found';
    }
}