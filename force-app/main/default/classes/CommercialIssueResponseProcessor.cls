public class CommercialIssueResponseProcessor implements IintMsgCalloutResponseProcessor {
    
    public static void process(List<IntgMsg__c> responses) {
        
        
        List<Id> ids = new List<Id>();
        
        for (IntgMsg__c integrationMessage : responses) {
            ids.add(integrationMessage.Id);
        }
        
        ContentDocumentLink cdlList = [SELECT ContentDocumentId FROM ContentDocumentLink
                                       WHERE LinkedEntityId = :ids
                                       AND ContentDocument.Title = 'response.json' LIMIT 1];//response.json
        
        
        ContentVersion contentVersion = [SELECT Id, VersionData,FileType FROM ContentVersion
                                         WHERE ContentDocumentId = :cdlList.ContentDocumentId LIMIT 1];
        
        
        try{
            if (contentVersion != null) {
                String jsonContent = contentVersion.VersionData.toString();
                
                BureauPdfQueueable queueableInstance = new BureauPdfQueueable(jsonContent,responses[0],'Commercial API');
                System.enqueueJob(queueableInstance);
                
                /*CommercialIssueResponseWrapper res = (CommercialIssueResponseWrapper) JSON.deserialize(jsonContent, CommercialIssueResponseWrapper.class);


if (res.STATUS == 'COMPLETED') { 

if (res.FINISHED != null && !res.FINISHED.isEmpty()) {

if (res.FINISHED[0].STATUS == 'SUCCESS') {
BureauSuccess(jsonContent, responses[0].RefId__c);

} else if (res.FINISHED[0].STATUS == 'BUREAU-ERROR') {
BureauError(jsonContent,responses[0].RefId__c);
}
}

if (res.REJECT != null && !res.REJECT.isEmpty() && res.REJECT[0].STATUS == 'ERROR') {
BureauReject(res,responses[0].RefId__c);

}
}
// if(res.STATUS == 'IN-PROCESS'){
// BureauInProgress(responses[0].RefId__c,responses);
// }*/
                
            }
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CommercialIssueResponseProcessor class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }	
        
    }
    //**************************************************************************************************************************
    public static Void BureauInProgress(Id refIdSet,IntgMsg__c response){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Bureau__c.SObjectType });
        
        if(refIdSet!=null){
            
            try {
                
                List<Bureau__c> BureauInsert =new List<Bureau__c>();
                
                List<Bureau__c> Bureau = [SELECT Id, Applicant__c,TriggerCount__c,IsLatest__c,BureauAPI__c FROM Bureau__c WHERE Applicant__c =:refIdSet AND IsLatest__c = true AND BureauAPI__c='Commercial'];
                
                //Create Commercial Issue Request Integration Message with 1 min Delay
                if(Bureau[0].TriggerCount__c>=0 && Bureau[0].TriggerCount__c<2){
                    
                    Bureau__c bur =new Bureau__c();
                    bur.id=Bureau[0].Id;
                    bur.TriggerCount__c=Bureau[0].TriggerCount__c+1;
                    BureauInsert.add(bur);
                    
                    Map<String,Object> jsonDataMap = new Map<String, Object>();
                    
                    jsonDataMap.put('Name','Commercial Issue Request');
                    jsonDataMap.put('Status','New');
                    jsonDataMap.put('MStatus','Blank');
                    jsonDataMap.put('BU',response.BU__c);
                    jsonDataMap.put('RefId',response.RefId__c);
                    jsonDataMap.put('RefObj',response.RefObj__c);
                    jsonDataMap.put('Svc','Commercial Issue Request');
                    jsonDataMap.put('ApiVendor',response.ApiVendor__c);
                    jsonDataMap.put('IsActive',true);
                    
                    String jsonSer = JSON.serialize(jsonDataMap);
                    
                    System.enqueueJob(new BureauQueueable(jsonSer), Integer.valueof(system.label.Bureau_Timer));
                }
                
                if(BureauInsert!=null){
                    List<string> fieldNamesList = New List<string>{'TriggerCount__c'};
                        String sObjectName = 'Bureau__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList); 
                    uow.registerDirty(BureauInsert);
                }
                uow.commitWork();
                
                
                
            } catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'BureauInProgress', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
            
        }
        
    } 
    
    //**************************************************************************************************************************
    public static Void   BureauSuccess(id refIdset,CommercialIssueResponseWrapper res){//string jsonString,
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Bureau__c.SObjectType});
        try {
            
            
            // CommercialIssueResponseWrapper res=(CommercialIssueResponseWrapper) JSON.deserialize(jsonString.replace('JSON-RESPONSE-OBJECT','JSONRESPONSEOBJECT'), CommercialIssueResponseWrapper.class);
            
            
            //Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            
            // string ackid;
            //if (responseMap.containsKey('ACKNOWLEDGEMENT-ID')) {
            //   ackid=String.valueOf(responseMap.get('ACKNOWLEDGEMENT-ID'));
            //}
            
           
            
            if(res!=null){
                List<Bureau__c> Bureau = [SELECT Id, Applicant__c,LoanApp__c,IsLatest__c,BureauAPI__c,LoanApp__r.Product__c FROM Bureau__c WHERE Applicant__c =:refIdSet AND IsLatest__c = true AND BureauAPI__c='Commercial']; 
                
                
                List<Bureau__c> updateBureau = new List<Bureau__c>();
                
                Map<String,BureauCrdType__mdt> bureaucrdtype=new Map<String,BureauCrdType__mdt>();
                for(BureauCrdType__mdt bct:[Select id,Description__c,Typeofloan__c,ROI__c from BureauCrdType__mdt]){
                    bureaucrdtype.put(bct.Description__c,bct);
                }
                
                Bureau__c bur=new Bureau__c();
                
                bur.id=Bureau[0].id;
                if(res.FINISHED[0].BUREAU=='CIBIL'){
                    bur.Source__c='Commercial CIBIL';
                }
                else if(res.FINISHED[0].BUREAU=='CRIF'){
                    bur.Source__c='Commercial CRIF';
                }
                else if(res.FINISHED[0].BUREAU=='Equifax'){
                    bur.Source__c='Commercial Equifax';
                }
                else if(res.FINISHED[0].BUREAU=='Experian'){
                    bur.Source__c='Commercial Experian';
                }
                
                //Rank Value For Score
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.rankSec!=null){
                    
                    if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.rankSec.rankVec!=null){
                        
                        CommercialIssueResponseWrapper.RankVec RankVec=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.rankSec.rankVec[0];
                        
                        if(!String.isBlank(RankVec.rankValue)){
                            bur.Score__c =RankVec.rankValue;
                        }
                        
                    }
                    
                }
                
                //Credit profile summary Total CF(Total No of live loans,Total Live Loan Exposure)
                
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditProfileSummarySec!=null && 
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditProfileSummarySec.total!=null){
                       
                       if(!String.isBlank(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditProfileSummarySec.total.openCF)){
                           bur.Totalliveloan__c=Integer.valueOf(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditProfileSummarySec.total.openCF);
                       }
                       
                       if(!String.isBlank(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditProfileSummarySec.total.totalOutstanding)){
                           bur.Totalloanexposure__c=Decimal.valueOf(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditProfileSummarySec.total.totalOutstanding);
                       }
                       
                       
                       
                   }
                
                //Credit facility Current details Overdues(Over dues)
                
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditFacilityDetailsasBorrowerSecVec!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditFacilityDetailsasBorrowerSecVec.creditFacilityDetailsasBorrowerSec!=null){
                       Integer overdue=0;
                       for(CommercialIssueResponseWrapper.creditFacilityDetailsasBorrowerSec creditFacility:res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditFacilityDetailsasBorrowerSecVec.creditFacilityDetailsasBorrowerSec){
                           
                           if(creditFacility.creditFacilityCurrentDetailsVec!=null &&
                              creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails!=null &&
                              creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.amount!=null){
                                  
                                  if(!String.isBlank(creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.amount.overdue)){
                                      overdue+=Integer.valueOf(creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.amount.overdue);
                                  }
                                  
                              }
                       }
                       bur.Totaloanoverdue__c=overdue;
                       
                       
                   }
                
                
                //enquirySummarySec enquiry total(total enquirey last 30 days)
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquirySummarySec!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquirySummarySec.enquiryTotal!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquirySummarySec.enquiryTotal.noOfEnquiries!=null){
                       
                       if(!String.isBlank(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquirySummarySec.enquiryTotal.noOfEnquiries.month1)){
                           
                           bur.TotalEnquirieslast30day__c=integer.valueOf(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquirySummarySec.enquiryTotal.noOfEnquiries.month1);
                       }
                       
                   }
                
                //Total Live Secured loan exposure,Total Live Unsecured loan exposure,Total Live Mortgage loan exposure 
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditFacilityDetailsasBorrowerSecVec!=null && 
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditFacilityDetailsasBorrowerSecVec.creditFacilityDetailsasBorrowerSec!=null){
                       
                       integer securecount=0;
                       integer unsecurecount=0;
                       integer mortgagecount=0;
                       for(CommercialIssueResponseWrapper.creditFacilityDetailsasBorrowerSec creditFacility:res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditFacilityDetailsasBorrowerSecVec.creditFacilityDetailsasBorrowerSec){
                           
                           if(creditFacility.creditFacilityCurrentDetailsVec!=null && 
                              creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails!=null){
                                  
                                  if(!String.isBlank(creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.cfType) &&
                                     bureaucrdtype.containsKey(creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.cfType)){
                                         
                                         if(bureaucrdtype.get(creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.cfType).Typeofloan__c=='Secured'){
                                            if(creditFacility.creditFacilityCurrentDetailsVec!=null && 
                                               creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails!=null &&
                                               creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.dates!=null&&
                                               creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.dates.loanExpiryDt!=null){

                                                if(convertToDate(creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.dates.loanExpiryDt) > Date.today() ){
                                                    securecount++;
                                                }
                                               }
                                             
                                         }
                                         else if(bureaucrdtype.get(creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.cfType).Typeofloan__c=='Unsecured'){

                                            if(creditFacility.creditFacilityCurrentDetailsVec!=null && 
                                               creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails!=null &&
                                               creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.dates!=null&&
                                               creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.dates.loanExpiryDt!=null){

                                                if(convertToDate(creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.dates.loanExpiryDt) > Date.today() ){
                                                    unsecurecount++;
                                                }
                                               }
                                             
                                         }
                                         else if(bureaucrdtype.get(creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.cfType).Typeofloan__c=='Mortgage'){
                                            if(creditFacility.creditFacilityCurrentDetailsVec!=null && 
                                            creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails!=null &&
                                            creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.dates!=null&&
                                            creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.dates.loanExpiryDt!=null){

                                             if(convertToDate(creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.dates.loanExpiryDt) > Date.today() ){
                                                mortgagecount++;
                                             }
                                            }

                                             
                                         }
                                     }
                                  
                              }
                       }
                       
                       bur.Totalsecuredloan__c=securecount;
                       bur.Totalunsecuredloan__c=unsecurecount;
                       bur.TotalMortgageloan__c=mortgagecount;
                       
                   }
                
                //enquiryDetailsInLast24MonthVec(Total Mortgage Enquiries in last 30 days,Total Unsecured Enquiries in last 30 day)
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquiryDetailsInLast24MonthVec!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquiryDetailsInLast24MonthVec.enquiryDetailsInLast24Month!=null){
                       
                       // Calculate the current date and the date 30 days ago
                       Date currentDate = Date.today();
                       Date thirtyDaysAgo = currentDate.addDays(-30);
                       
                       // Process past enquiries within the last 30 days
                       Integer mortageLast30Days = 0;
                       Integer unsecuredLast30Days = 0;
                       
                       
                       for(CommercialIssueResponseWrapper.EnquiryDetailsInLast24Month enq24:res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquiryDetailsInLast24MonthVec.enquiryDetailsInLast24Month){
                           
                           if(!string.isBlank(enq24.enquiryPurpose) && !string.isBlank(enq24.enquiryDt) && bureaucrdtype.containsKey(enq24.enquiryPurpose)){
                               
                               Date enquiryDate = convertToDate(enq24.enquiryDt);
                               
                               if (enquiryDate >= thirtyDaysAgo && enquiryDate <= currentDate) {
                                   if(bureaucrdtype.get(enq24.enquiryPurpose).Typeofloan__c=='Mortgage'){
                                       mortageLast30Days++;
                                   }
                                   if(bureaucrdtype.get(enq24.enquiryPurpose).Typeofloan__c=='Unsecured'){
                                       unsecuredLast30Days++;
                                   }     
                               }
                               
                           }
                           
                           
                       }
                       bur.TotalMortgageEnqlst30days__c=mortageLast30Days;
                       bur.TotalUnsecuredEnqlast30day__c=unsecuredLast30Days;
                       
                   }
                
                
                
                //reportHeaderRec response
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.reportHeaderRec!=null){
                    
                    CommercialIssueResponseWrapper.ReportHeaderRec ReportHeaderRec=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.reportHeaderRec;
                    
                    if(!String.isBlank(ReportHeaderRec.reportOrderedBy)){
                        bur.ReportOrderedBy__c=ReportHeaderRec.reportOrderedBy;
                    }
                    
                    if(!String.isBlank(ReportHeaderRec.memberReferenceNumber)){
                        bur.MemberRefNum__c=ReportHeaderRec.memberReferenceNumber;
                        
                    }
                    
                    if(!String.isBlank(ReportHeaderRec.inquiryPurpose)){
                        bur.InquiryPurpose__c=ReportHeaderRec.inquiryPurpose;
                        
                    }
                    
                    if(!String.isBlank(ReportHeaderRec.reportOrderDate)){
                        bur.Report_date__c=convertToDate(ReportHeaderRec.reportOrderDate);
                        
                    }
                    
                    if(!String.isBlank(ReportHeaderRec.daysPasswordToExpire)){
                        bur.DaysPsdToExp__c=ReportHeaderRec.daysPasswordToExpire;
                        
                    }
                    
                    if(!String.isBlank(ReportHeaderRec.reportOrderNumber)){
                        bur.RptOrdNum__c=ReportHeaderRec.reportOrderNumber;
                        
                    }
                    
                    if(!String.isBlank(ReportHeaderRec.memberDetails)){
                        bur.MbrDtls__c=ReportHeaderRec.memberDetails;
                        
                    }
                    
                    if(!String.isBlank(ReportHeaderRec.applicationReferenceNumber)){
                        bur.AppRefNum__c=ReportHeaderRec.applicationReferenceNumber;
                        
                    }
                    
                    
                }
                
                //enquiryInformationRec response
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.enquiryInformationRec!=null){
                    
                    CommercialIssueResponseWrapper.EnquiryInformationRec EnquiryInformationRec=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.enquiryInformationRec;
                    
                    if(!String.isBlank(EnquiryInformationRec.borrowerName)){
                        bur.BorrowerName__c=EnquiryInformationRec.borrowerName;
                        
                    }
                    
                    if(!String.isBlank(EnquiryInformationRec.dateOfRegistration)){
                        bur.DteOfReg__c=convertToDate(EnquiryInformationRec.dateOfRegistration);
                        
                    }
                    
                    if(!String.isBlank(EnquiryInformationRec.cin)){
                        bur.CIN__c=EnquiryInformationRec.cin;
                        
                    }
                    
                    if(!String.isBlank(EnquiryInformationRec.pan)){
                        bur.Pan__c=EnquiryInformationRec.pan;
                        
                    }
                    
                    if(!String.isBlank(EnquiryInformationRec.crn)){
                        bur.CRN__c=EnquiryInformationRec.crn;
                        
                    }
                    
                    //address
                    if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.enquiryInformationRec.addressVec!=null &&
                       res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.enquiryInformationRec.addressVec.address!=null ){
                           
                           for(CommercialIssueResponseWrapper.address  address:res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.enquiryInformationRec.addressVec.address){
                               
                               
                               if(!String.isBlank(address.city)){
                                   bur.City__c=address.city;
                                   
                               }
                               
                               if(!String.isBlank(address.pinCode)){
                                   bur.Pincode__c=address.pinCode;
                                   
                               }
                               
                               if(!String.isBlank(address.state)){
                                   bur.State__c=address.state;
                                   
                               }
                               
                               if(!String.isBlank(address.addressLine)){
                                   bur.Address__c=address.addressLine;
                                   
                               }
                           }
                       }
                    
                }
                //relationshipDetailsVec
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.relationshipDetailsVec.message!=null){
                    
                    if(!String.isBlank(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.relationshipDetailsVec.message)){
                        bur.MsgRelDtils__c=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.relationshipDetailsVec.message;
                    }
                }
                
                //derogatoryInformationSec   response
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec!=null){
                    
                    CommercialIssueResponseWrapper.DerogatoryInformationSec DerogatoryInfo =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec;
                    
                    if(!string.isBlank(DerogatoryInfo.messageOfRelatedParties)){
                        bur.MsgRltPrts__c=DerogatoryInfo.messageOfRelatedParties;
                    }
                    
                    if(!string.isBlank(DerogatoryInfo.messageOfRelatedPartiesOutsideInstitution)){
                        bur.MsgRltdParties__c=DerogatoryInfo.messageOfRelatedPartiesOutsideInstitution;
                    }
                    
                    if(!string.isBlank(DerogatoryInfo.messageOfGuarantedParties)){
                        bur.MsgGrtPrts__c=DerogatoryInfo.messageOfGuarantedParties;
                    }
                    
                    if(!string.isBlank(DerogatoryInfo.messageOfRelatedPartiesYourInstitution)){
                        bur.MsgRltdPrtsInst__c=DerogatoryInfo.messageOfRelatedPartiesYourInstitution;
                    }
                    
                    if(!string.isBlank(DerogatoryInfo.messageOfBorrowerYourInstitution)){
                        bur.MsgBrwInst__c=DerogatoryInfo.messageOfBorrowerYourInstitution;
                    }
                    
                    if(!string.isBlank(DerogatoryInfo.messageOfBorrowerOutsideInstitution)){
                        bur.MsgBrwOutsideInst__c=DerogatoryInfo.messageOfBorrowerOutsideInstitution;
                    }
                    
                    if(!string.isBlank(DerogatoryInfo.messageOfBorrower)){
                        bur.MsgBorrower__c=DerogatoryInfo.messageOfBorrower;
                    }
                    
                    if(!string.isBlank(DerogatoryInfo.message)){
                        bur.message__c=DerogatoryInfo.message;
                    }
                    
                }
                
                //suitFiledVec
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.suitFiledVec.message!=null){
                    bur.SuitMessage__c=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.suitFiledVec.message;
                }
                
                //rankSec
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.rankSec!=null && 
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.rankSec.message!=null){
                    bur.RankMess__c=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.rankSec.message;
                }
                
                //creditFacilityDetailsasBorrowerSec Message
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditFacilityDetailsasBorrowerSecVec!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditFacilityDetailsasBorrowerSecVec.message!=null){
                       bur.CreditBorrowerMess__c=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditFacilityDetailsasBorrowerSecVec.message;
                   }
                //countOfCreditFacilities with noOfCreditFacilities
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditFacilitiesSummary!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditFacilitiesSummary.countOfCreditFacilities!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditFacilitiesSummary.countOfCreditFacilities.noOfCreditFacilities!=null){
                       
                       CommercialIssueResponseWrapper.NoOfCreditGrantors NoOfCredit= res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditFacilitiesSummary.countOfCreditFacilities.noOfCreditFacilities;
                       
                       if(!String.isBlank(NoOfCredit.others)){
                           bur.CreditFacilitiesOther__c=NoOfCredit.others;
                       }
                       if(!String.isBlank(NoOfCredit.total)){
                           bur.CreditFacilitiesTotal__c=NoOfCredit.total;
                       }
                       if(!String.isBlank(NoOfCredit.yourBank)){
                           bur.CreditFacilitiesBank__c=NoOfCredit.yourBank;
                       }
                       
                   }
                
                //countOfCreditFacilities with noOfCreditGrantors
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditFacilitiesSummary!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditFacilitiesSummary.countOfCreditFacilities!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditFacilitiesSummary.countOfCreditFacilities.noOfCreditGrantors!=null){
                       
                       CommercialIssueResponseWrapper.NoOfCreditGrantors NoOfCredit=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditFacilitiesSummary.countOfCreditFacilities.noOfCreditGrantors;
                       
                       
                       if(!String.isBlank(NoOfCredit.others)){
                           bur.CreditGrantorsOthers__c=NoOfCredit.others;
                       }
                       if(!String.isBlank(NoOfCredit.total)){
                           bur.CreditGrantorsTotal__c=NoOfCredit.total;
                       }
                       if(!String.isBlank(NoOfCredit.yourBank)){
                           bur.CreditGrantorsBank__c=NoOfCredit.yourBank;
                       }
                   }
                
                //enquirySummarySec message
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquirySummarySec!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquirySummarySec.message!=null){
                       bur.EnquiryMess__c=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquirySummarySec.message;
                       
                   }
                
                updateBureau.add(bur);
                
                if(updateBureau!=null){
                    List<string> fieldNamesList = New List<string>{'id','ReportOrderedBy__c','MemberRefNum__c','InquiryPurpose__c','Report_date__c',
                        'DaysPsdToExp__c','RptOrdNum__c','MbrDtls__c','AppRefNum__c','BorrowerName__c',
                        'DteOfReg__c','CIN__c','Pan__c','CRN__c','City__c','Pincode__c','State__c',
                        'Address__c','MsgRltPrts__c','MsgRltdParties__c',
                        'MsgGrtPrts__c','MsgRltdPrtsInst__c','MsgBrwInst__c','MsgBrwOutsideInst__c','TotalEnquirieslast30day__c',
                        'MsgBorrower__c','message__c','SuitMessage__c','Totalliveloan__c','Totaloanoverdue__c',
                        'CreditFacilitiesBank__c','Source__c','Score__c','Totalloanexposure__c',
                        'CreditFacilitiesOther__c','CreditFacilitiesTotal__c','CreditGrantorsBank__c',
                        'CreditGrantorsOthers__c','CreditGrantorsTotal__c','RankMess__c','CreditBorrowerMess__c',
                        'EnquiryMess__c','Totalsecuredloan__c','Totalunsecuredloan__c','TotalMortgageloan__c'};
                            String sObjectName = 'Bureau__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList); 
                    uow.registerDirty(updateBureau);
                    
                }
                uow.commitWork();
                
                //relationshipDispute
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.relationshipDetailsVec!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.relationshipDetailsVec.relationshipDispute!=null){
                    relationshipDispute(res,Bureau[0].id);
                } 
                
                //relationshipDetails
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.relationshipDetailsVec!=null &&
                   	res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.relationshipDetailsVec.relationshipDetails!=null){
                    relationshipDetails(res,Bureau[0].id);
                } 
                //enquiryDetailsInLast24Month
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquiryDetailsInLast24MonthVec!=null){
                    enquiryDetailsInLast24Month(res,Bureau[0].id);
                } 
                
                //enquiriesDispute
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquiryDetailsInLast24MonthVec!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquiryDetailsInLast24MonthVec.enquiriesDispute!=null){
                    enquiriesDispute(res,Bureau[0].id);
                } 
                
                //derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec!=null){
                       derogatoryInformationOnRelatedParties(res, Bureau[0].id);
                   }
                
                //derogatoryInformationBorrower
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower!=null){
                       DerogatoryInformationBorrower(res, Bureau[0].id);
                   }
                
                //locationDetailsSec
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.locationDetailsSec!=null){
                    locationDetailsSec(res, Bureau[0].id);
                }
                
                //locationInformation
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.locationDetailsSec!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.locationDetailsSec.locationInformationVec!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.locationDetailsSec.locationInformationVec.locationInformation!=null){
                    locationInformation(res, Bureau[0].id);
                }
                //locationDispute
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.locationDetailsSec!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.locationDetailsSec.locationDispute!=null){
                    locationDispute(res, Bureau[0].id);
                }
                //borrwerAddressContactDetails and borrwerIDDetailsVec and borrwerDetails
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec!=null && 
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec.borrwerIDDetailsVec!=null){
                       borrwerAddressContactDetails(res, Bureau[0].id);
                   }
                
                //borrwerIDDetails
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec.borrwerIDDetailsVec!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec.borrwerIDDetailsVec.borrwerIDDetails!=null){
                       borrwerIDDetails(res, Bureau[0].id);
                   }
                
                //borrowerDispute
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec.borrowerDispute!=null){
                       borrowerDispute(res, Bureau[0].id);
                   }
                //classOfActivity
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec!=null  &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec.borrwerDetails!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec.borrwerDetails.classOfActivityVec!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec.borrwerDetails.classOfActivityVec.classOfActivity!=null){
                       classOfActivity(res,Bureau[0].id);
                       
                   }
                
                //borrowerDelinquencyReportedOnBorrower
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec!=null  &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec.borrowerDelinquencyReportedOnBorrower!=null){
                       borrowerDelinquencyReportedOnBorrower(res, Bureau[0].id);
                   }
                
                //borrowerDelinquencyReportedOnRSOrGSOftheBorrowerIn24Months
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec!=null  &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec.borrowerDelinquencyReportedOnRSOrGSOftheBorrowerIn24MonthsVec!=null){
                       borrowerDelinquencyReportedOnRSOrGSOftheBorrowerIn24Months(res, Bureau[0].id);
                   }
                //rankVec
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.rankSec.rankVec!=null ){
                    rankVec(res,Bureau[0].id);
                }
                
                //creditFacilityDetailsasBorrowerSec
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditFacilityDetailsasBorrowerSecVec!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditFacilityDetailsasBorrowerSecVec.creditFacilityDetailsasBorrowerSec!=null ){
                       creditFacilityDetailsasBorrowerSec(res,Bureau[0].id,Bureau[0].LoanApp__c,Bureau[0].Applicant__c,bureaucrdtype);
                   }
                
                //guarantorIDDetails
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditFacilityDetailsasBorrowerSecVec!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditFacilityDetailsasBorrowerSecVec.creditFacilityDetailsasBorrowerSec!=null ){
                       guarantorIDDetails(res,Bureau[0].id);
                   }
                
                //enquirySummarySec
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquirySummarySec!=null){
                    enquirySummarySec(res,Bureau[0].id);
                }
                
                //creditVisionSec
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditVisionSec!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditVisionSec.creditVision!=null){
                       creditVision(res,Bureau[0].id);
                   }
                
                //creditProfileSummarySec
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditProfileSummarySec!=null){
                    creditProfileSummary(res,Bureau[0].id);
                }
                
                //creditRatingSummaryVec
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditRatingSummaryVec!=null){
                    creditRatingSummary(res,Bureau[0].id);
                }
                
                //oustandingBalanceByCFAndAssetClasificationSec
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec!=null){
                    oustandingBalanceByCFAndAssetClasificationSec(res,Bureau[0].id);
                }
                
                //pdf file
                if(res.FINISHED[0].PDF_REPORT!=null){
                    BureauCommercialPdfQueueable queueableInstance = new BureauCommercialPdfQueueable(res.FINISHED[0].PDF_REPORT,refIdset);
                   System.enqueueJob(queueableInstance);
                }
                
            }
        } catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'BureauSuccess', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
    }
    //************************************************************************************************************************** 
    public static Void relationshipDispute(CommercialIssueResponseWrapper res,Id refIdset){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {CM_BureauDispute__c.SObjectType});
        if(res!=null && refIdset!=null){
            
            try {
                List<CM_BureauDispute__c> insertBureauDispute = new List<CM_BureauDispute__c>();
                
                CommercialIssueResponseWrapper.RelationshipDispute  dispute=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.relationshipDetailsVec.relationshipDispute;
                
                CM_BureauDispute__c bd =new CM_BureauDispute__c();
                
                bd.BureauResponse__c=refIdset!=null?refIdset:'';
                bd.Type__c='Relationship';
                
                if(!String.isBlank(dispute.disputeRemarks)){
                    bd.DispRem__c=dispute.disputeRemarks;
                }
                if(!String.isBlank(dispute.disputeRemarksDate)){
                    bd.DispRemDte__c=convertToDate(dispute.disputeRemarksDate);
                }
                insertBureauDispute.add(bd);
                
                if(insertBureauDispute!=null){
                    List<string> fieldNamesList = New List<string>{'BureauResponse__c','DispRem__c','DispRemDte__c','Type__c'};
                        String sObjectName = 'CM_BureauDispute__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(insertBureauDispute);
                }
                uow.commitWork();
            } catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'relationshipDispute', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
        
    }
    //************************************************************************************************************************** 
    public static Void relationshipDetails(CommercialIssueResponseWrapper res,Id refIdset){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {CM_BureauRelationShipDetail__c.SObjectType,
            CM_Bureau_Child_Relation_Ship__c.SObjectType});
        
        if(res!=null && refIdset!=null){
            try {
                string ackid=res.ACKNOWLEDGEMENT_ID;
                List<CM_BureauRelationShipDetail__c> insertCBureauRelationShipDetail = new List<CM_BureauRelationShipDetail__c>();
                
                Map<String,List<CommercialIssueResponseWrapper.BorrwerIDDetails>> idmaps =New Map<String,List<CommercialIssueResponseWrapper.BorrwerIDDetails>>();
                
                for(CommercialIssueResponseWrapper.relationshipDetails rsd:res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.relationshipDetailsVec.relationshipDetails){
                    
                    CM_BureauRelationShipDetail__c brds =new CM_BureauRelationShipDetail__c();
                    
                    brds.BureauResponse__c=refIdset!=null?refIdset:'';
                    
                    if (!string.isBlank(res.ACKNOWLEDGEMENT_ID)) {
                        brds.AckId__c=Integer.valueOf(res.ACKNOWLEDGEMENT_ID);
                    }
                    
                    //relationshipInformation
                    if(rsd.relationshipInformation!=null){
                        
                        CommercialIssueResponseWrapper.relationshipInformation relinfo=rsd.relationshipInformation;
                        
                        if(!String.isBlank(relinfo.businessCategory)){
                            brds.BusCat__c=relinfo.businessCategory;
                        }
                        if(!String.isBlank(relinfo.businessIndustryType)){
                            brds.BusIndType__c=relinfo.businessIndustryType;
                        }
                        if(!String.isBlank(relinfo.classOfActivity1)){
                            brds.ClsAct__c=relinfo.classOfActivity1;
                        }
                        if(!String.isBlank(relinfo.dateOfIncorporation)){
                            brds.Dtencorp__c=convertToDate(relinfo.dateOfIncorporation);
                        }
                        if(!String.isBlank(relinfo.name)){
                            brds.Name__c=relinfo.name;
                        }
                        if(!String.isBlank(relinfo.percentageOfControl)){
                            brds.PerCon__c=Decimal.valueOf(relinfo.percentageOfControl.replace('%',''));
                        }
                        if(!String.isBlank(relinfo.relatedType)){
                            brds.RelatedType__c=relinfo.relatedType;
                        }
                        if(!String.isBlank(relinfo.relationship)){
                            brds.Relationship__c=relinfo.relationship;
                        }
                        
                    }
                    
                    //borrwerAddressContactDetails
                    if(rsd.borrwerAddressContactDetails!=null){
                        CommercialIssueResponseWrapper.BorrwerAddressContactDetails addressdet=rsd.borrwerAddressContactDetails;
                        
                        if(!String.isBlank(addressdet.address)){
                            brds.Address__c=addressdet.address;
                        }
                        if(!String.isBlank(addressdet.telephoneNumber)){
                            brds.TeleNum__c=addressdet.telephoneNumber;
                        }
                        if(!String.isBlank(addressdet.mobileNumber)){
                            brds.MobNum__c=addressdet.mobileNumber;
                        }
                        
                    }
                    
                    //relationshipHeader
                    if(rsd.relationshipHeader!=null){
                        
                        if(!String.isBlank(rsd.relationshipHeader)){
                            brds.RelHeader__c=rsd.relationshipHeader;
                        }
                        
                    }
                    
                    //borrwerIDDetailsVec borrwerIDDetails
                    if(rsd.borrwerIDDetailsVec!=null){
                        
                        if(!string.isBlank(rsd.borrwerIDDetailsVec.lastReportedDate)){
                            brds.LstRprtDte__c=convertToDate(rsd.borrwerIDDetailsVec.lastReportedDate);
                        }
                        
                        //borrwerIDDetails
                        if(rsd.borrwerIDDetailsVec.borrwerIDDetails!=null){
                            
                            for(CommercialIssueResponseWrapper.BorrwerIDDetails iddetails:rsd.borrwerIDDetailsVec.borrwerIDDetails){
                                
                                
                                if (!idmaps.containsKey(rsd.relationshipHeader)) {
                                    idmaps.put(rsd.relationshipHeader, new List<CommercialIssueResponseWrapper.BorrwerIDDetails>{iddetails});
                                } else {
                                    idmaps.get(rsd.relationshipHeader).add(iddetails);
                                }
                                
                                /* if(!idmaps.containsKey(rsd.relationshipHeader)){

List<CommercialIssueResponseWrapper.BorrwerIDDetails> newList = new List<CommercialIssueResponseWrapper.BorrwerIDDetails>();
newList.add(iddetails);
idmaps.put(rsd.relationshipHeader, newList);
}
else{
//List<CommercialIssueResponseWrapper.BorrwerIDDetails> existingList = idmaps.get(rsd.relationshipHeader);
//existingList.add(iddetails);
//idmaps.put(rsd.relationshipHeader, existingList);
idmaps.get(rsd.relationshipHeader).add(iddetails);
}*/
                                
                            }
                            
                        }
                        
                    }
                    
                    insertCBureauRelationShipDetail.add(brds);
                    
                    
                    
                }
                
                if(insertCBureauRelationShipDetail!=null){
                    List<string> fieldNamesList = New List<string>{'BureauResponse__c','BusCat__c','BusIndType__c','ClsAct__c','AckId__c',
                        'Dtencorp__c','Name__c','PerCon__c','RelatedType__c','Relationship__c',
                        'Address__c','TeleNum__c','MobNum__c','RelHeader__c','LstRprtDte__c'};
                            String sObjectName = 'CM_BureauRelationShipDetail__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(insertCBureauRelationShipDetail);
                    
                }
                uow.commitWork();
                
                //calling child method
                if(!idmaps.isempty()){
                    relationshipborrwerIDDetails(idmaps,ackid);
                }
            } catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'relationshipDetails', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
        
    }
    //************************************************************************************************************************
    public static void relationshipborrwerIDDetails(Map<String,List<CommercialIssueResponseWrapper.BorrwerIDDetails>> idmaps,String ackid){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {CM_Bureau_Child_Relation_Ship__c.SObjectType});
        
        List<CM_BureauRelationShipDetail__c> BurRelShip=[Select id,AckId__c,RelHeader__c from CM_BureauRelationShipDetail__c 
                                                         Where AckId__c=:Integer.valueOf(ackid) AND RelHeader__c=:idmaps.keySet()];
        
        try{
            if(!BurRelShip.isempty()){
                
                List<CM_Bureau_Child_Relation_Ship__c> insertBureauChildShip =new List<CM_Bureau_Child_Relation_Ship__c>();
                
                for(CM_BureauRelationShipDetail__c brs:BurRelShip){
                    
                    List<CommercialIssueResponseWrapper.BorrwerIDDetails> detailsList = idmaps.get(brs.RelHeader__c);
                    
                    
                    for (CommercialIssueResponseWrapper.BorrwerIDDetails detail : detailsList) {
                        
                        CM_Bureau_Child_Relation_Ship__c bcr =new CM_Bureau_Child_Relation_Ship__c();
                        
                        bcr.BureauRelationShip_Detail__c=brs.id;
                        bcr.Pan__c=detail.pan;
                        insertBureauChildShip.add(bcr);
                        
                    }
                    
                }
                
                if(insertBureauChildShip!=null){
                    List<string> fieldNamesList = New List<string>{'BureauRelationShip_Detail__c','Pan__c'};
                        String sObjectName = 'CM_Bureau_Child_Relation_Ship__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(insertBureauChildShip);
                }
                uow.commitWork();
                
            } 
        }catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'relationshipborrwerIDDetails', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        
        
    }
    //************************************************************************************************************************** 
    public static Void enquiryDetailsInLast24Month(CommercialIssueResponseWrapper res,Id refIdset){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { CM_EnquiryDetail__c.SObjectType});
        
        if(res!=null && refIdset!=null){
            
            try {
                List<CM_EnquiryDetail__c> InsertEnquiryDetail =new List<CM_EnquiryDetail__c>();
                
                //enquiryDetailsInLast24MonthVec message
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquiryDetailsInLast24MonthVec.message!=null){
                    
                    CM_EnquiryDetail__c ed =new CM_EnquiryDetail__c();
                    
                    ed.BureauResponse__c= refIdset!=null?refIdset:'';
                    ed.Message__c=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquiryDetailsInLast24MonthVec.message;
                    
                    InsertEnquiryDetail.add(ed);
                    
                }
                //enquiryDetailsInLast24MonthVec enquiryDetailsInLast24Month
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquiryDetailsInLast24MonthVec.enquiryDetailsInLast24Month!=null){
                    
                    
                    for(CommercialIssueResponseWrapper.EnquiryDetailsInLast24Month DetailsInLast24:res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquiryDetailsInLast24MonthVec.enquiryDetailsInLast24Month){
                        CM_EnquiryDetail__c ed =new CM_EnquiryDetail__c();
                        
                        ed.BureauResponse__c= refIdset!=null?refIdset:'';
                        
                        if(!String.isBlank(DetailsInLast24.creditLender)){
                            ed.CrdLender__c=DetailsInLast24.creditLender;
                        }
                        if(!String.isBlank(DetailsInLast24.enquiryAmt)){
                            ed.EnqAmt__c=Decimal.valueOf(DetailsInLast24.enquiryAmt);
                        }
                        if(!String.isBlank(DetailsInLast24.enquiryDt)){
                            ed.EnqDte__c=convertToDate(DetailsInLast24.enquiryDt);
                        }
                        if(!String.isBlank(DetailsInLast24.enquiryPurpose)){
                            ed.EnqPurpose__c=DetailsInLast24.enquiryPurpose;
                        }
                        InsertEnquiryDetail.add(ed);
                    }
                }
                
                
                if(InsertEnquiryDetail!=null){
                    List<string> fieldNamesList = New List<string>{'BureauResponse__c','CrdLender__c','EnqAmt__c','EnqDte__c','EnqPurpose__c','Message__c'};
                        String sObjectName = 'CM_EnquiryDetail__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(InsertEnquiryDetail);
                }
                uow.commitWork();
                
            } catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'enquiryDetailsInLast24Month', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
        
        
    }
    //************************************************************************************************************************** 
    public static Void enquiriesDispute(CommercialIssueResponseWrapper res,Id refIdset){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { CM_BureauDispute__c.SObjectType});
        
        if(res!=null && refIdset!=null){
            
            try {
                
                CommercialIssueResponseWrapper.RelationshipDispute enquiriesDispute=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquiryDetailsInLast24MonthVec.enquiriesDispute;
                
                List<CM_BureauDispute__c> insertBureauDispute =new List<CM_BureauDispute__c>();
                
                CM_BureauDispute__c bd=new CM_BureauDispute__c();
                
                bd.BureauResponse__c=refIdset!=null?refIdset:'';
                bd.Type__c='Enquiry';
                
                if(!String.isBlank(enquiriesDispute.disputeRemarks)){
                    bd.DispRem__c=enquiriesDispute.disputeRemarks;
                }
                
                if(!String.isBlank(enquiriesDispute.disputeRemarksDate)){
                    bd.DispRemDte__c=convertToDate(enquiriesDispute.disputeRemarksDate);
                }
                
                insertBureauDispute.add(bd);
                
                if(insertBureauDispute!=null){
                    List<string> fieldNamesList = New List<string>{'BureauResponse__c','Type__c','DispRem__c','DispRemDte__c'};
                        String sObjectName = 'CM_BureauDispute__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(insertBureauDispute);
                }
                uow.commitWork();
                
            } catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'enquiriesDispute', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
            
        }
        
    }
    
    //**************************************************************************************************************************
    public static void derogatoryInformationOnRelatedParties(CommercialIssueResponseWrapper res,Id refIdset){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { CM_DerogatoryInfo__c.SObjectType});
        
        if(res!=null && refIdset!=null){
            
            try{
                List<CM_DerogatoryInfo__c> insertDerogatoryInfo =new list<CM_DerogatoryInfo__c>();
                //total
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.total!=null){
                    
                    
                    CommercialIssueResponseWrapper.Total tot=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.total;
                    
                    
                    
                    CM_DerogatoryInfo__c di =new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Related Parties or Guarantor';
                    di.Institution__c='Total';
                    
                    if(!string.isBlank(tot.dishonoredCheque)){
                        di.DishonoredChq__c=tot.dishonoredCheque;
                    }
                    
                    if(!string.isBlank(tot.wilfulDefault)){
                        di.WilfulDft__c=tot.wilfulDefault;
                    }
                    insertDerogatoryInfo.add(di);
                    
                }
                
                //total inside Settled
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.total.settled!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.total.settled;
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Related Parties or Guarantor';
                    di.Institution__c='Total';
                    di.Type__c='Settled';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                }
                //total inside 	Written Off
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.total.writtenOff!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.total.writtenOff;
                    
                    
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Related Parties or Guarantor';
                    di.Institution__c='Total';
                    di.Type__c='Written Off';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                    
                }
                //total inside Invoked
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.total.invoked!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.total.invoked;
                    
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Related Parties or Guarantor';
                    di.Institution__c='Total';
                    di.Type__c='Invoked';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                    
                }
                //total inside Suit Filled
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.total.suitFilled!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.total.suitFilled;
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Related Parties or Guarantor';
                    di.Institution__c='Total';
                    di.Type__c='Suit Filled';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                    
                }
                //total inside overdue CF
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.total.overdueCF!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.total.overdueCF;
                    
                    
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Related Parties or Guarantor';
                    di.Institution__c='Total';
                    di.Type__c='overdue CF';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                    
                }
                
                
                //Your Institution
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.yourInstitution!=null){
                    
                    
                    CommercialIssueResponseWrapper.Total tot=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.yourInstitution;
                    
                    
                    CM_DerogatoryInfo__c di =new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Related Parties or Guarantor';
                    di.Institution__c='Your Institution';
                    
                    if(!string.isBlank(tot.dishonoredCheque)){
                        di.DishonoredChq__c=tot.dishonoredCheque;
                    }
                    
                    if(!string.isBlank(tot.wilfulDefault)){
                        di.WilfulDft__c=tot.wilfulDefault;
                    }
                    insertDerogatoryInfo.add(di);
                    
                    
                }
                
                //Your Institution inside Settled
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.yourInstitution.settled!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.yourInstitution.settled;
                    
                    
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Related Parties or Guarantor';
                    di.Institution__c='Your Institution';
                    di.Type__c='Settled';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                    
                }
                //yourInstitution inside 	Written Off
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.yourInstitution.writtenOff!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.yourInstitution.writtenOff;
                    
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Related Parties or Guarantor';
                    di.Institution__c='Your Institution';
                    di.Type__c='Written Off';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                    
                }
                //yourInstitution inside Invoked
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.yourInstitution.invoked!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.yourInstitution.invoked;
                    
                    
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Related Parties or Guarantor';
                    di.Institution__c='Your Institution';
                    di.Type__c='Invoked';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                    
                }
                //yourInstitution inside Suit Filled
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.yourInstitution.suitFilled!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.yourInstitution.suitFilled;
                    
                    
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Related Parties or Guarantor';
                    di.Institution__c='Your Institution';
                    di.Type__c='Suit Filled';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                    
                }
                //yourInstitution inside overdue CF
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.yourInstitution.overdueCF!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.yourInstitution.overdueCF;
                    
                    
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Related Parties or Guarantor';
                    di.Institution__c='Your Institution';
                    di.Type__c='overdue CF';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                    
                }
                
                
                //Outside Institution
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.outsideInstitution!=null){
                    
                    
                    CommercialIssueResponseWrapper.Total tot=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.outsideInstitution;
                    
                    
                    CM_DerogatoryInfo__c di =new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Related Parties or Guarantor';
                    di.Institution__c='Outside Institution';
                    
                    if(!string.isBlank(tot.dishonoredCheque)){
                        di.DishonoredChq__c=tot.dishonoredCheque;
                    }
                    
                    if(!string.isBlank(tot.wilfulDefault)){
                        di.WilfulDft__c=tot.wilfulDefault;
                    }
                    insertDerogatoryInfo.add(di);
                    
                    
                }
                
                //Outside Institution inside Settled
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.outsideInstitution.settled!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.outsideInstitution.settled;
                    
                    
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Related Parties or Guarantor';
                    di.Institution__c='Outside Institution';
                    di.Type__c='Settled';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                    
                }
                //Outside Institution inside 	Written Off
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.outsideInstitution.writtenOff!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.outsideInstitution.writtenOff;
                    
                    
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Related Parties or Guarantor';
                    di.Institution__c='Outside Institution';
                    di.Type__c='Written Off';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                    
                }
                //Outside Institution inside Invoked
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.outsideInstitution.invoked!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.outsideInstitution.invoked;
                    
                    
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Related Parties or Guarantor';
                    di.Institution__c='Outside Institution';
                    di.Type__c='Invoked';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                    
                }
                //Outside Institution inside Suit Filled
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.outsideInstitution.suitFilled!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.outsideInstitution.suitFilled;
                    
                    
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Related Parties or Guarantor';
                    di.Institution__c='Outside Institution';
                    di.Type__c='Suit Filled';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                    
                }
                //Outside Institution inside overdue CF
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.outsideInstitution.overdueCF!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationOnRelatedPartiesOrGuarantorsOfBorrowerSec.outsideInstitution.overdueCF;
                    
                    
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Related Parties or Guarantor';
                    di.Institution__c='Outside Institution';
                    di.Type__c='overdue CF';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                    
                }
                
                if(insertDerogatoryInfo!=null){
                    List<string> fieldNamesList = New List<string>{'BureauRes__c','DerogatoryInfoParty__c','Institution__c','DishonoredChq__c','Type__c','Amt__c','NbrSuitFiled__c',
                        'WilfulDft__c'};
                            String sObjectName = 'CM_DerogatoryInfo__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(insertDerogatoryInfo);
                }
                uow.commitWork();
                
            }
            catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'derogatoryInformationOnRelatedParties', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
            
            
            
        }
        
        
        
    } 
    //**************************************************************************************************************************
    public static void DerogatoryInformationBorrower(CommercialIssueResponseWrapper res,Id refIdset){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { CM_DerogatoryInfo__c.SObjectType});
        
        if(res!=null && refIdset!=null){
            try{
                
                List<CM_DerogatoryInfo__c> insertDerogatoryInfo =new List<CM_DerogatoryInfo__c>();
                //total
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.total!=null){
                    
                    
                    CommercialIssueResponseWrapper.Total tot=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.total;
                    
                    CM_DerogatoryInfo__c di =new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Borrower';
                    di.Institution__c='Total';
                    
                    if(!string.isBlank(tot.dishonoredCheque)){
                        di.DishonoredChq__c=tot.dishonoredCheque;
                    }
                    
                    if(!string.isBlank(tot.wilfulDefault)){
                        di.WilfulDft__c=tot.wilfulDefault;
                    }
                    insertDerogatoryInfo.add(di);
                    
                    
                }
                
                //total inside Settled
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.total.settled!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.total.settled;
                    
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Borrower';
                    di.Institution__c='Total';
                    di.Type__c='Settled';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                }
                //total inside 	Written Off
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.total.writtenOff!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.total.writtenOff;
                    
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Borrower';
                    di.Institution__c='Total';
                    di.Type__c='Written Off';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                }
                //total inside Invoked
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.total.invoked!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.total.invoked;
                    
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Borrower';
                    di.Institution__c='Total';
                    di.Type__c='Invoked';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                }
                //total inside Suit Filled
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.total.suitFilled!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.total.suitFilled;
                    
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Borrower';
                    di.Institution__c='Total';
                    di.Type__c='Suit Filled';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                }
                //total inside overdue CF
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.total.overdueCF!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.total.overdueCF;
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Borrower';
                    di.Institution__c='Total';
                    di.Type__c='overdue CF';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                    
                }
                
                
                //Your Institution
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.yourInstitution!=null){
                    
                    
                    CommercialIssueResponseWrapper.Total tot=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.yourInstitution;
                    
                    CM_DerogatoryInfo__c di =new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Borrower';
                    di.Institution__c='Your Institution';
                    
                    if(!string.isBlank(tot.dishonoredCheque)){
                        di.DishonoredChq__c=tot.dishonoredCheque;
                    }
                    
                    if(!string.isBlank(tot.wilfulDefault)){
                        di.WilfulDft__c=tot.wilfulDefault;
                    }
                    insertDerogatoryInfo.add(di);
                    
                    
                }
                
                //Your Institution inside Settled
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.yourInstitution.settled!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.yourInstitution.settled;
                    
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Borrower';
                    di.Institution__c='Your Institution';
                    di.Type__c='Settled';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                    
                }
                //yourInstitution inside 	Written Off
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.yourInstitution.writtenOff!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.yourInstitution.writtenOff;
                    
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Borrower';
                    di.Institution__c='Your Institution';
                    di.Type__c='Written Off';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                    
                }
                //yourInstitution inside Invoked
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.yourInstitution.invoked!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.yourInstitution.invoked;
                    
                    
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Borrower';
                    di.Institution__c='Your Institution';
                    di.Type__c='Invoked';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                    
                }
                //yourInstitution inside Suit Filled
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.yourInstitution.suitFilled!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.yourInstitution.suitFilled;
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Borrower';
                    di.Institution__c='Your Institution';
                    di.Type__c='Suit Filled';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                }
                //yourInstitution inside overdue CF
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.yourInstitution.overdueCF!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.yourInstitution.overdueCF;
                    
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Borrower';
                    di.Institution__c='Your Institution';
                    di.Type__c='overdue CF';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                }
                
                //Outside Institution
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.outsideInstitution!=null){
                    
                    
                    CommercialIssueResponseWrapper.Total tot=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.outsideInstitution;
                    
                    CM_DerogatoryInfo__c di =new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Borrower';
                    di.Institution__c='Outside Institution';
                    
                    if(!string.isBlank(tot.dishonoredCheque)){
                        di.DishonoredChq__c=tot.dishonoredCheque;
                    }
                    
                    if(!string.isBlank(tot.wilfulDefault)){
                        di.WilfulDft__c=tot.wilfulDefault;
                    }
                    insertDerogatoryInfo.add(di);
                }
                
                //Outside Institution inside Settled
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.outsideInstitution.settled!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.outsideInstitution.settled;
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Borrower';
                    di.Institution__c='Outside Institution';
                    di.Type__c='Settled';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                    
                }
                //Outside Institution inside 	Written Off
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.outsideInstitution.writtenOff!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.outsideInstitution.writtenOff;
                    
                    
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Borrower';
                    di.Institution__c='Outside Institution';
                    di.Type__c='Written Off';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                }
                //Outside Institution inside Invoked
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.outsideInstitution.invoked!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.outsideInstitution.invoked;
                    
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Borrower';
                    di.Institution__c='Outside Institution';
                    di.Type__c='Invoked';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                    
                }
                //Outside Institution inside Suit Filled
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.outsideInstitution.suitFilled!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.outsideInstitution.suitFilled;
                    
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Borrower';
                    di.Institution__c='Outside Institution';
                    di.Type__c='Suit Filled';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                    
                }
                //Outside Institution inside overdue CF
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.outsideInstitution.overdueCF!=null){
                    
                    CommercialIssueResponseWrapper.Settled settled =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.derogatoryInformationSec.derogatoryInformationBorrower.outsideInstitution.overdueCF;
                    
                    
                    
                    
                    CM_DerogatoryInfo__c di=new CM_DerogatoryInfo__c();
                    
                    di.BureauRes__c=refIdset!=null?refIdset:'';
                    di.DerogatoryInfoParty__c='Borrower';
                    di.Institution__c='Outside Institution';
                    di.Type__c='overdue CF';
                    
                    if(!string.isBlank(settled.amt)){
                        di.Amt__c=Decimal.valueOf(settled.amt);
                    }
                    if(!string.isBlank(settled.numberOfSuitFiled)){
                        di.NbrSuitFiled__c=settled.numberOfSuitFiled;
                    }
                    
                    insertDerogatoryInfo.add(di);
                    
                    
                }
                if(insertDerogatoryInfo!=null){
                    List<string> fieldNamesList = New List<string>{'BureauRes__c','DerogatoryInfoParty__c','Institution__c','DishonoredChq__c','Type__c','Amt__c','NbrSuitFiled__c',
                        'WilfulDft__c'};
                            String sObjectName = 'CM_DerogatoryInfo__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(insertDerogatoryInfo);
                }
                uow.commitWork();   
                
            }
            catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'DerogatoryInformationBorrower', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
        
        
        
    }  
    
    //**************************************************************************************************************************
    public static void locationDetailsSec(CommercialIssueResponseWrapper res,Id refIdset){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { CM_LocationDetail__c.SObjectType});
        system.debug('locationDetailsSec start::'+limits.getcputime());
        if(res!=null && refIdset!=null){
            try {
                
                CommercialIssueResponseWrapper.LocationDetailsSec locations=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.locationDetailsSec;
                
                list<CM_LocationDetail__c> insertLocationDetail =new List<CM_LocationDetail__c>();
                
                CM_LocationDetail__c Ld =new CM_LocationDetail__c();
                
                Ld.BureauResponse__c=refIdset!=null?refIdset:'';
                
                if(!String.isBlank(locations.contactNumber)){
                    Ld.ConNum__c=locations.contactNumber;
                }
                if(!String.isBlank(locations.faxNumber)){
                    Ld.FaxNum__c=locations.faxNumber;
                }
                if(!String.isBlank(locations.message)){
                    Ld.Message__c=locations.message;
                }
                insertLocationDetail.add(Ld);
                
                if(insertLocationDetail!=null){
                    List<string> fieldNamesList = New List<string>{'BureauResponse__c','ConNum__c','FaxNum__c','Message__c'};
                        String sObjectName = 'CM_LocationDetail__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(insertLocationDetail);
                }
                uow.commitWork();
            } catch (Exception ex) {
                system.debug('Error message and line number: ' + ex.getMessage() + ' Line: ' + ex.getLineNumber());
            }
            
            
        }
        
    }
    //**************************************************************************************************************************
    
    public static void locationInformation(CommercialIssueResponseWrapper res,Id refIdset){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { CM_LocationInfo__c.SObjectType});
        
        if(res!=null && refIdset!=null){
            
            try {
                
                List<CM_LocationDetail__c> detail =[Select id,BureauResponse__c from CM_LocationDetail__c Where BureauResponse__c =: refIdset];
                
                list<CM_LocationInfo__c> insertLocationInfo =new List<CM_LocationInfo__c>();
                
                for(CommercialIssueResponseWrapper.locationInformation locinfo:res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.locationDetailsSec.locationInformationVec.locationInformation){
                    
                    CM_LocationInfo__c li=new CM_LocationInfo__c();
                    
                    li.LocationDetail__c=detail[0].id;
                    
                    if(!string.isBlank(locinfo.address)){
                        li.Address__c=locinfo.address;
                    }
                    if(!string.isBlank(locinfo.borrowerOfficeLocationType)){
                        li.BorrowerOficLocType__c=locinfo.borrowerOfficeLocationType;
                    }
                    if(!string.isBlank(locinfo.firstReportedDate)){
                        li.FstRptDte__c=convertToDate(locinfo.firstReportedDate);
                    }
                    if(!string.isBlank(locinfo.lastReportedDate)){
                        li.LstReptdDte__c=convertToDate(locinfo.lastReportedDate);
                    }
                    if(!string.isBlank(locinfo.numberOfInstitutions)){
                        li.NumOfInst__c=locinfo.numberOfInstitutions;
                    }
                    
                    insertLocationInfo.add(li);
                }
                
                if(insertLocationInfo!=null){
                    List<string> fieldNamesList = New List<string>{'LocationDetail__c','Address__c','BorrowerOficLocType__c',
                        'FstRptDte__c','LstReptdDte__c','NumOfInst__c'};
                            String sObjectName = 'CM_LocationInfo__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(insertLocationInfo);
                }
                uow.commitWork();
            } catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'locationInformation', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
        
    }
    
    //****************************************************************************************************************************
    public static void locationDispute(CommercialIssueResponseWrapper res,Id refIdset){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { CM_BureauDispute__c.SObjectType});
        
        if (res!=null && refIdset!=null) {
            
            CommercialIssueResponseWrapper.RelationshipDispute locdispute =res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.locationDetailsSec.locationDispute;
            
            List<CM_BureauDispute__c> insertBureauDispute =new List<CM_BureauDispute__c>();
            
            CM_BureauDispute__c bd=new CM_BureauDispute__c();
            
            bd.BureauResponse__c=refIdset!=null?refIdset:'';
            bd.Type__c='Location';
            
            if(!String.isBlank(locdispute.disputeRemarks)){
                bd.DispRem__c=locdispute.disputeRemarks;
                
            }
            if(!String.isBlank(locdispute.disputeRemarksDate)){
                bd.DispRemDte__c=convertToDate(locdispute.disputeRemarksDate);
            }
            insertBureauDispute.add(bd);
            
            if(insertBureauDispute!=null){
                List<string> fieldNamesList = New List<string>{'BureauResponse__c','Type__c','DispRem__c',
                    'DispRemDte__c'};
                        String sObjectName = 'CM_BureauDispute__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                uow.registerNew(insertBureauDispute);
            }
            uow.commitWork();
            
        }
    }
    
    //******************************************************************************************************************************
    public static void borrwerAddressContactDetails(CommercialIssueResponseWrapper res,Id refIdset){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { CM_Person_Entity_Detail__c.SObjectType});
        
        if (res!=null && refIdset!=null) {
            
            try {
                
                List<CM_Person_Entity_Detail__c> InsertPersonEntity=new List<CM_Person_Entity_Detail__c>();
                
                CM_Person_Entity_Detail__c ped =new CM_Person_Entity_Detail__c();
                
                ped.BureauResponse__c=refIdset!=null?refIdset:'';
                ped.Type__c='Borrower';
                
                //borrwerIDDetailsVec lastReportedDate
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec.borrwerIDDetailsVec.lastReportedDate!=null){
                    ped.LstRepDte__c=convertToDate(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec.borrwerIDDetailsVec.lastReportedDate);
                }
                //borrwerAddressContactDetails
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec.borrwerAddressContactDetails!=null){
                    CommercialIssueResponseWrapper.BorrwerAddressContactDetails AddressDetails=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec.borrwerAddressContactDetails;
                    
                    if(!String.isBlank(AddressDetails.address)){
                        ped.Address__c=AddressDetails.address;
                    }
                    if(!String.isBlank(AddressDetails.faxNumber)){
                        ped.FaxNum__c=AddressDetails.faxNumber;
                    }
                    if(!String.isBlank(AddressDetails.mobileNumber)){
                        ped.MobNum__c=AddressDetails.mobileNumber;
                    }
                    if(!String.isBlank(AddressDetails.telephoneNumber)){
                        ped.TeleNum__c=AddressDetails.telephoneNumber;
                    }
                }
                
                //borrwerDetails
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec.borrwerDetails!=null){
                    
                    CommercialIssueResponseWrapper.BorrwerDetails BorrwerDetails=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec.borrwerDetails;
                    
                    if(!String.isBlank(BorrwerDetails.borrowersLegalConstitution)){
                        ped.BorrLegalCons__c=BorrwerDetails.borrowersLegalConstitution;
                    }
                    if(!String.isBlank(BorrwerDetails.businessCategory)){
                        ped.BusinessCtgy__c=BorrwerDetails.businessCategory;
                    }
                    if(!String.isBlank(BorrwerDetails.businessIndustryType)){
                        ped.BusIndType__c=BorrwerDetails.businessIndustryType;
                    }
                    if(!String.isBlank(BorrwerDetails.dateOfIncorporation)){
                        ped.DteIncorp__c=convertToDate(BorrwerDetails.dateOfIncorporation);
                    }
                    if(!String.isBlank(BorrwerDetails.name)){
                        ped.Name__c=BorrwerDetails.name;
                    }
                    if(!String.isBlank(BorrwerDetails.numberOfEmployees)){
                        ped.NumEmp__c=Decimal.valueOf(BorrwerDetails.numberOfEmployees);
                    }
                    if(!String.isBlank(BorrwerDetails.salesFigure)){
                        ped.SalesFig__c=BorrwerDetails.salesFigure;
                    }
                    
                }
                
                InsertPersonEntity.add(ped);
                
                if(InsertPersonEntity!=null){
                    List<string> fieldNamesList = New List<string>{'BureauResponse__c','LstRepDte__c','Address__c','BorrLegalCons__c',
                        'FaxNum__c','MobNum__c','TeleNum__c','BusinessCtgy__c','BusIndType__c',
                        'DteIncorp__c','Name__c','SalesFig__c','Type__c'};
                            String sObjectName = 'CM_Person_Entity_Detail__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(InsertPersonEntity);
                }
                uow.commitWork();
                
            } catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'borrwerAddressContactDetails', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
            
            
        }
        
    }
    //*****************************************************************************************************************************
    public static void borrwerIDDetails(CommercialIssueResponseWrapper res,Id refIdset){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { CM_Person_Entity_ID_Detail__c.SObjectType});
        
        if(res!=null && refIdset!=null){
            
            try {
                List<CM_Person_Entity_Detail__c> EntityDetail =[Select id,BureauResponse__c,Type__c from CM_Person_Entity_Detail__c Where BureauResponse__c =:refIdset AND Type__c='Borrower'];
                
                List<CM_Person_Entity_ID_Detail__c> insertEntityIDDetail =new List<CM_Person_Entity_ID_Detail__c>();
                
                for(CommercialIssueResponseWrapper.BorrwerIDDetails BorrwerIDDetails:res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec.borrwerIDDetailsVec.borrwerIDDetails){
                    
                    CM_Person_Entity_ID_Detail__c peid =new CM_Person_Entity_ID_Detail__c();
                    
                    peid.PersonEntity_Detail__c=EntityDetail[0].id;
                    peid.Type__c='Borrower';
                    
                    If(!string.isBlank(BorrwerIDDetails.cin)){
                        peid.CIN__c=BorrwerIDDetails.cin;
                    }
                    If(!string.isBlank(BorrwerIDDetails.pan)){
                        peid.PAN__c=BorrwerIDDetails.pan;
                    }
                    insertEntityIDDetail.add(peid);
                }
                
                if(insertEntityIDDetail!=null){
                    List<string> fieldNamesList = New List<string>{'PersonEntity_Detail__c','CIN__c','PAN__c','Type__c'};
                        String sObjectName = 'CM_Person_Entity_ID_Detail__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(insertEntityIDDetail);
                }
                uow.commitWork();
                
            } catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'borrwerIDDetails', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
        
    }
    //******************************************************************************************************************************
    public static void borrowerDispute(CommercialIssueResponseWrapper res,Id refIdset){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { CM_BureauDispute__c.SObjectType});
        
        if(res!=null && refIdset!=null){
            
            try {
                
                List<CM_BureauDispute__c> insertBureauDispute =new List<CM_BureauDispute__c>();
                
                CommercialIssueResponseWrapper.RelationshipDispute  Dispute=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec.borrowerDispute;
                
                CM_BureauDispute__c bd=new CM_BureauDispute__c();
                
                bd.BureauResponse__c=refIdset!=null?refIdset:'';
                bd.Type__c='Borrower';
                
                if(!String.isBlank(Dispute.disputeRemarks)){
                    bd.DispRem__c=Dispute.disputeRemarks;
                }
                if(!String.isBlank(Dispute.disputeRemarksDate)){
                    bd.DispRemDte__c=convertToDate(Dispute.disputeRemarksDate);
                }
                insertBureauDispute.add(bd);
                
                if(insertBureauDispute!=null){
                    List<string> fieldNamesList = New List<string>{'BureauResponse__c','Type__c','DispRem__c','DispRemDte__c'};
                        String sObjectName = 'CM_BureauDispute__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(insertBureauDispute);
                }
                uow.commitWork();
            } catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'borrowerDispute', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
        
    }
    //******************************************************************************************************************************
    public static void classOfActivity(CommercialIssueResponseWrapper res,Id refIdset){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { CM_Person_Entity_Class_Activity__c.SObjectType});
        
        if(res!=null && refIdset!=null){
            
            try {
                
                List<CM_Person_Entity_Detail__c> EntityDetail =[Select id,BureauResponse__c,Type__c from CM_Person_Entity_Detail__c Where BureauResponse__c =:refIdset AND Type__c='Borrower'];
                
                List<CM_Person_Entity_Class_Activity__c> insertEntityClassActivity =new List<CM_Person_Entity_Class_Activity__c>();
                
                CM_Person_Entity_Class_Activity__c peca =new CM_Person_Entity_Class_Activity__c();
                
                peca.PersonEntity_Detail__c=EntityDetail[0].id;
                
                String joinedValues = String.join(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec.borrwerDetails.classOfActivityVec.classOfActivity, ', ');
                
                if(!string.isBlank(joinedValues)){
                    peca.ClsActivityResponse__c=joinedValues;
                }
                insertEntityClassActivity.add(peca);
                
                if(insertEntityClassActivity!=null){
                    List<string> fieldNamesList = New List<string>{'PersonEntity_Detail__c','ClsActivityResponse__c'};
                        String sObjectName = 'CM_Person_Entity_Class_Activity__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(insertEntityClassActivity);
                }
                uow.commitWork();
            } catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'classOfActivity', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
        
    }
    //*******************************************************************************************************************************
    public static void borrowerDelinquencyReportedOnBorrower(CommercialIssueResponseWrapper res,Id refIdset){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { CM_Borrower_Delinquency__c.SObjectType});
        
        if(res!=null && refIdset!=null){
            try {
                List<CM_Person_Entity_Detail__c> EntityDetail =[Select id,BureauResponse__c,Type__c from CM_Person_Entity_Detail__c Where BureauResponse__c =:refIdset AND Type__c='Borrower'];
                
                List<CM_Borrower_Delinquency__c> insertBorrowerDelinquency =new List<CM_Borrower_Delinquency__c>();
                
                //your Institution
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec.borrowerDelinquencyReportedOnBorrower.yourInstitution!=null){
                    
                    
                    CM_Borrower_Delinquency__c bd =new CM_Borrower_Delinquency__c();
                    
                    bd.PersonEntityDetail__c=EntityDetail[0].id;
                    bd.Type__c='On Borrower';
                    bd.DeliType__c='Your Institution';
                    
                    CommercialIssueResponseWrapper.YourInstitution YourInstitution=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec.borrowerDelinquencyReportedOnBorrower.yourInstitution;
                    
                    if(!String.isBlank(YourInstitution.current)){
                        bd.Current__c=YourInstitution.current;
                    }
                    if(!String.isBlank(YourInstitution.last24Months)){
                        bd.Lst24mon__c=YourInstitution.last24Months;
                    }
                    
                    insertBorrowerDelinquency.add(bd);
                    
                }
                
                //outside Institution
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec.borrowerDelinquencyReportedOnBorrower.outsideInstitution!=null){
                    
                    
                    
                    CM_Borrower_Delinquency__c bd =new CM_Borrower_Delinquency__c();
                    
                    bd.PersonEntityDetail__c=EntityDetail[0].id;
                    bd.DeliType__c='Outside Institution';
                    bd.Type__c='On Borrower';
                    
                    CommercialIssueResponseWrapper.YourInstitution YourInstitution=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec.borrowerDelinquencyReportedOnBorrower.outsideInstitution;
                    
                    if(!String.isBlank(YourInstitution.current)){
                        bd.Current__c=YourInstitution.current;
                    }
                    if(!String.isBlank(YourInstitution.last24Months)){
                        bd.Lst24mon__c=YourInstitution.last24Months;
                    }
                    
                    insertBorrowerDelinquency.add(bd);
                    
                    
                }
                
                if(insertBorrowerDelinquency!=null){
                    List<string> fieldNamesList = New List<string>{'PersonEntityDetail__c','Type__c','DeliType__c','Current__c','Lst24mon__c'};
                        String sObjectName = 'CM_Borrower_Delinquency__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(insertBorrowerDelinquency);
                }
                uow.commitWork();
            } catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'borrowerDelinquencyReportedOnBorrower', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
        
    }
    //*******************************************************************************************************************************
    public static void borrowerDelinquencyReportedOnRSOrGSOftheBorrowerIn24Months(CommercialIssueResponseWrapper res,Id refIdset){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { CM_Borrower_Delinquency__c.SObjectType});
        
        if(res!=null && refIdset!=null){
            
            try {
                List<CM_Person_Entity_Detail__c> EntityDetail =[Select id,BureauResponse__c,Type__c from CM_Person_Entity_Detail__c Where BureauResponse__c =:refIdset AND Type__c='Borrower'];
                
                List<CM_Borrower_Delinquency__c> insertBorrowerDelinquency =new List<CM_Borrower_Delinquency__c>();
                
                
                //message
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec.borrowerDelinquencyReportedOnRSOrGSOftheBorrowerIn24MonthsVec.message!=null){
                    CM_Borrower_Delinquency__c bd =new CM_Borrower_Delinquency__c();
                    
                    bd.PersonEntityDetail__c=EntityDetail[0].id;
                    bd.Type__c='On Related Parties & Guarantor';
                    bd.Message__c=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec.borrowerDelinquencyReportedOnRSOrGSOftheBorrowerIn24MonthsVec.message;
                    insertBorrowerDelinquency.add(bd);
                }
                
                //borrowerDelinquencyReportedOnRSOrGSOftheBorrowerIn24Months
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec.borrowerDelinquencyReportedOnRSOrGSOftheBorrowerIn24MonthsVec.borrowerDelinquencyReportedOnRSOrGSOftheBorrowerIn24Months!=null){
                    for(CommercialIssueResponseWrapper.borrowerDelinquencyReportedOnRSOrGSOftheBorrowerIn24Months months24:res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.borrowerProfileSec.borrowerDelinquencyReportedOnRSOrGSOftheBorrowerIn24MonthsVec.borrowerDelinquencyReportedOnRSOrGSOftheBorrowerIn24Months){
                        
                        CM_Borrower_Delinquency__c bd =new CM_Borrower_Delinquency__c();
                        
                        bd.PersonEntityDetail__c=EntityDetail[0].id;
                        bd.Type__c='On Related Parties & Guarantor';
                        
                        if(!String.isBlank(months24.detail)){
                            bd.Details__c=months24.detail;
                            
                        }
                        
                        if(!String.isBlank(months24.fxCount)){
                            bd.FXCount__c=Decimal.valueOf(months24.fxCount);
                        }
                        
                        if(!String.isBlank(months24.fxOutstanding)){
                            bd.FXOutstanding__c=Decimal.valueOf(months24.fxOutstanding);
                        }
                        
                        if(!String.isBlank(months24.nfCount)){
                            bd.NFCount__c=Decimal.valueOf(months24.nfCount);
                        }
                        
                        if(!String.isBlank(months24.nfOutstanding)){
                            bd.NFOutstanding__c=Decimal.valueOf(months24.nfOutstanding);
                        }
                        
                        if(!String.isBlank(months24.relationship)){
                            bd.Relationship__c=months24.relationship;
                        }
                        
                        if(!String.isBlank(months24.tlCount)){
                            bd.TlCount__c=Decimal.valueOf(months24.tlCount);
                        }
                        
                        if(!String.isBlank(months24.tlOutstanding)){
                            bd.TLOutstanding__c=Decimal.valueOf(months24.tlOutstanding);
                        }
                        
                        if(!String.isBlank(months24.wcCount)){
                            bd.WCCount__c=Decimal.valueOf(months24.wcCount);
                        }
                        
                        if(!String.isBlank(months24.wcOutstanding)){
                            bd.wcOutstanding__c=Decimal.valueOf(months24.wcOutstanding);
                        }
                        
                        
                        insertBorrowerDelinquency.add(bd);
                    }
                    
                }
                
                if(insertBorrowerDelinquency!=null){
                    List<string> fieldNamesList = New List<string>{'PersonEntityDetail__c','Type__c','Message__c','Details__c','FXCount__c',
                        'FXOutstanding__c','NFCount__c','NFOutstanding__c','Relationship__c','TlCount__c',
                        'TLOutstanding__c','WCCount__c','wcOutstanding__c'};
                            String sObjectName = 'CM_Borrower_Delinquency__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(insertBorrowerDelinquency);
                }
                uow.commitWork();
            } catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'borrowerDelinquencyReportedOnRSOrGSOftheBorrowerIn24Months', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
        
    }
    //*****************************************************************************************************************************
    public static void rankVec(CommercialIssueResponseWrapper res,Id refIdset){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {Rank__c.SObjectType});
        
        if(res!=null && refIdset!=null){
            
            try {
                List<Rank__c> insertRank =new List<Rank__c>();
                
                for(CommercialIssueResponseWrapper.RankVec RankVec:res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.rankSec.rankVec){
                    
                    Rank__c rk =new Rank__c();
                    
                    rk.BureauResponse__c=refIdset!=null?refIdset:'';
                    
                    
                    if(!String.isBlank(RankVec.exclusionReason)){
                        rk.ExclusionRes__c=RankVec.exclusionReason;
                    }
                    if(!String.isBlank(RankVec.rankName)){
                        rk.RankName__c=RankVec.rankName;
                    }
                    if(!String.isBlank(RankVec.rankValue)){
                        rk.RankVal__c=RankVec.rankValue;
                    }
                    insertRank.add(rk);
                }
                
                if(insertRank!=null){
                    List<string> fieldNamesList = New List<string>{'BureauResponse__c','Message__c','RankName__c','ExclusionRes__c','RankVal__c'};
                        String sObjectName = 'Rank__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(insertRank);
                }
                uow.commitWork();
            } catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'rankVec', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
            
        }
    }
    //********************************************************************************************************************************
    public static void creditFacilityDetailsasBorrowerSec(CommercialIssueResponseWrapper res,Id refIdset,Id loanId,Id ApplicantID,Map<String,BureauCrdType__mdt> bureaucrdtype){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {BureauRespDtl__c.SObjectType,
            CM_BureauDispute__c.SObjectType,
            CM_CreditHistoryForACorDPD__c.SObjectType,
            CM_Person_Entity_Detail__c.SObjectType});
        
        if(res!=null && refIdset!=null){
            
            try {
                
                List<BureauRespDtl__c> insertBureauRespDtl =new List<BureauRespDtl__c>();
                List<CM_BureauDispute__c> insertBureauDispute =new List<CM_BureauDispute__c>();
                List<CM_CreditHistoryForACorDPD__c> insertCreditHistoryForACorDPD =new List<CM_CreditHistoryForACorDPD__c>();
                List<CM_Person_Entity_Detail__c> insertPersonEntityDetail =new List<CM_Person_Entity_Detail__c>();
                
                Id RecordType = Schema.SObjectType.BureauRespDtl__c.getRecordTypeInfosByDeveloperName().get('Commercial_Obligation').getRecordTypeId();
                
                
                

                

                for(CommercialIssueResponseWrapper.creditFacilityDetailsasBorrowerSec creditFacility:res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditFacilityDetailsasBorrowerSecVec.creditFacilityDetailsasBorrowerSec){
                    string bureausource='';
                	string loantype;
                	integer tenure;
                	Decimal loanamount;
                    //creditFacilityCurrentDetails
                    if(creditFacility.creditFacilityCurrentDetailsVec!=null && creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails!=null){
                        
                        CommercialIssueResponseWrapper.creditFacilityCurrentDetails CurrentDetails=creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails;
                        
                        BureauRespDtl__c brd=new BureauRespDtl__c();
                        
                        brd.Bureau__c=refIdset!=null?refIdset:'';
                        brd.LoanApplication__c=loanId!=null?loanId:'';
                        brd.Applicant__c=ApplicantID!=null?ApplicantID:'';
                        brd.RecordTypeId=RecordType!=null?RecordType:'';
                        brd.LoanCapacity__c='Individual';
                        brd.CrdFacType__c='Current';
                        brd.CrdFaciAgainst__c='Borrower';
                        brd.LoanName__c=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.enquiryInformationRec.borrowerName!=null?res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.enquiryInformationRec.borrowerName:'';
                        
                        if(res.FINISHED[0].BUREAU=='CIBIL'){
                            brd.Source__c='Commercial CIBIL';
                        }
                        else if(res.FINISHED[0].BUREAU=='CRIF'){
                            brd.Source__c='Commercial CRIF';
                        }
                        else if(res.FINISHED[0].BUREAU=='Equifax'){
                            brd.Source__c='Commercial Equifax';
                        }
                        else if(res.FINISHED[0].BUREAU=='Experian'){
                            brd.Source__c='Commercial Experian';
                        }
                        if(!string.isBlank(CurrentDetails.statusDate)){
                            brd.StatusDate__c=convertToDate(CurrentDetails.statusDate);
                        }
                        if(!string.isBlank(CurrentDetails.cfSerialNumber)){
                            brd.CFSeriNum__c=CurrentDetails.cfSerialNumber;
                        }
                        if(!string.isBlank(CurrentDetails.lastReportedDate)){
                            brd.LstRepDte__c=convertToDate(CurrentDetails.lastReportedDate);
                            brd.CloseDate__c=convertToDate(CurrentDetails.lastReportedDate);
                        }
                        if(!string.isBlank(CurrentDetails.cfType)){
                            brd.CFType__c=CurrentDetails.cfType;
                            brd.NatureOfLoan__c=CurrentDetails.cfType;
                            loantype=CurrentDetails.cfType;
                        }
                        if(!string.isBlank(CurrentDetails.derivative)){
                            brd.Derivative__c=CurrentDetails.derivative;
                        }
                        if(!string.isBlank(CurrentDetails.cfMember)){
                            brd.CFMember__c=CurrentDetails.cfMember;
                        }
                        if(!string.isBlank(CurrentDetails.accountNumber)){
                            brd.AccNum__c=CurrentDetails.accountNumber;
                        }
                        if(!string.isBlank(CurrentDetails.assetClassificationDaysPastDueDpd)){
                            brd.AstClassDysPstDueDpd__c=CurrentDetails.assetClassificationDaysPastDueDpd;
                        }
                        if(!string.isBlank(CurrentDetails.status)){
                            brd.Status__c=CurrentDetails.status;
                        }
                        
                        //amount
                        if(creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.amount!=null){
                            
                            CommercialIssueResponseWrapper.amount amount=creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.amount;
                            
                            if(!String.isBlank(amount.drawingPower)){
                                brd.DrawingPow__c=amount.drawingPower;
                            }
                            if(!String.isBlank(amount.highCredit)){
                                brd.HighCredit__c=Decimal.valueof(amount.highCredit);
                            }
                            if(!String.isBlank(amount.installmentAmt)){
                                brd.EMISource__c='Bureau';
                                brd.InstalAmt__c=Decimal.valueOf(amount.installmentAmt);
                                brd.EMI__c=Decimal.valueOf(amount.installmentAmt);
                            }else{
                                bureausource='Estimated';
                            }
                            if(!String.isBlank(amount.lastRepaid)){
                                brd.LastRepaid__c=Decimal.valueOf(amount.lastRepaid);
                            }
                            if(!String.isBlank(amount.outstandingBalance)){
                                brd.OutstandingBal__c=Decimal.valueOf(amount.outstandingBalance);
                                brd.CurrentOs__c=Decimal.valueOf(amount.outstandingBalance);
                            }
                            if(!String.isBlank(amount.overdue)){
                                brd.Overdues__c=Decimal.valueOf(amount.overdue);
                            }
                            if(!String.isBlank(amount.sanctionedAmt)){
                                brd.SanctionedAmt__c=Decimal.valueOf(amount.sanctionedAmt);
                                brd.LoanAmount__c=Decimal.valueOf(amount.sanctionedAmt);
                                loanamount=Decimal.valueOf(amount.sanctionedAmt);
                            }
                            if(!String.isBlank(amount.settled)){
                                brd.Settled__c=Decimal.valueOf(amount.settled);
                            }
                            if(!String.isBlank(amount.writtenOFF)){
                                brd.WrittenOFF__c=Decimal.valueOf(amount.writtenOFF);
                            }
                        }
                        
                        //otherDetails
                        if(creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.otherDetails!=null){
                            
                            CommercialIssueResponseWrapper.otherDetails otherDetails=creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.otherDetails;
                            
                            if(!String.isBlank(otherDetails.assetBasedSecurityCoverage)){
                                brd.AstBasedSecCov__c=otherDetails.assetBasedSecurityCoverage;
                            }
                            if(!String.isBlank(otherDetails.guaranteeCoverage)){
                                brd.GuaranteeCov__c=otherDetails.guaranteeCoverage;
                            }
                            if(!String.isBlank(otherDetails.repaymentFrequency)){
                                brd.RepayFreq__c=otherDetails.repaymentFrequency;
                            }
                            if(!String.isBlank(otherDetails.restructingReason)){
                                brd.RestructingRes__c=otherDetails.restructingReason;
                            }
                            if(!String.isBlank(otherDetails.tenure)){
                                brd.Tenure__c=Decimal.valueOf(otherDetails.tenure);
                                tenure=Integer.valueOf(otherDetails.tenure);
                            }
                            else{//calucation tenure manually
                                if(creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.dates!=null){

                                    date sancation;
                                    date loanexpiry;
                                     //sancation date 
                                    if(!String.isBlank(creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.dates.sanctionedDt)){
                                        sancation=convertToDate(creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.dates.sanctionedDt);
                                    }
                                    //loan expiry date 
                                    if(!String.isBlank(creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.dates.loanExpiryDt)){
                                        loanexpiry=convertToDate(creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.dates.loanExpiryDt);
                                    }

                                    if(sancation!=null && loanexpiry!=null){
                                        tenure = sancation.monthsBetween(loanexpiry);
                                    }

                                }
                            }
                        }
                        
                        //dates
                        if(creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.dates!=null){
                            
                            CommercialIssueResponseWrapper.dates dates=creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.dates;
                            
                            if(!String.isBlank(dates.loanExpiryDt)){
                                brd.loanExpiryDt__c=convertToDate(dates.loanExpiryDt);
                            }
                            if(!String.isBlank(dates.loanRenewalDt)){
                                brd.loanRenewalDt__c=convertToDate(dates.loanRenewalDt);
                            }
                            if(!String.isBlank(dates.sanctionedDt)){
                                brd.SanctionedDt__c=convertToDate(dates.sanctionedDt);
                                brd.DisbursalDate__c=convertToDate(dates.sanctionedDt);
                            }
                            
                            //calcuating the EMI manually
                           if(loantype!=null && tenure!=null && tenure!=0 && loanamount!=null  && 
                             loanamount!=0 && bureausource=='Estimated'){

                                 system.debug('loantype::::'+loantype);
                                 system.debug('tenure::::'+tenure);
                                 system.debug('loanamount:::'+loanamount);
                                 system.debug('bureausource:::'+bureausource);
                            
                           BureauCrdType__mdt loan =bureaucrdtype.get(loantype);
 
                            if(loan != null && loan.ROI__c != null && loan.ROI__c != 0){

                               Double interest = Double.valueOf(loan.ROI__c) / Double.valueOf(100);

                                system.debug('interest'+interest);

                                 Decimal emi = loanAmount * (interest / 12) * Math.pow((1 + interest / 12), tenure) / (Math.pow((1 + interest / 12), tenure) - 1);
                                 system.debug(emi.setScale(0, RoundingMode.HALF_UP));
                                 
                                 brd.EMISource__c='Estimated';
                                 brd.Tenure__c=tenure;
                                 brd.EMI__c=emi.setScale(0, RoundingMode.HALF_UP);
                              
                            }
 
 
 
                     }
                        }
                        
                        insertBureauRespDtl.add(brd);
                        
                    }
                    
                    //creditFacilityOverdueDetailsVec
                    if(creditFacility.creditFacilityOverdueDetailsVec!=null){
                        
                        BureauRespDtl__c brd=new BureauRespDtl__c();
                        
                        brd.RecordTypeId=RecordType!=null?RecordType:'';
                        brd.Bureau__c=refIdset!=null?refIdset:'';
                        brd.LoanApplication__c=loanId!=null?loanId:'';
                        brd.Applicant__c=ApplicantID!=null?ApplicantID:'';
                        brd.LoanCapacity__c='Individual';
                        brd.CrdFacType__c='OverDue';
                        brd.CrdFaciAgainst__c='Borrower';
                        
                        if(!string.isblank(creditFacility.creditFacilityOverdueDetailsVec.message)){
                            brd.Message__c=creditFacility.creditFacilityOverdueDetailsVec.message;
                        }
                        
                        //creditFacilityOverdueDetails
                        
                        if(creditFacility.creditFacilityOverdueDetailsVec!=null && creditFacility.creditFacilityOverdueDetailsVec.creditFacilityOverdueDetails!=null){
                            
                            CommercialIssueResponseWrapper.creditFacilityOverdueDetails OverdueDetails=creditFacility.creditFacilityOverdueDetailsVec.creditFacilityOverdueDetails;
                            
                            if(!string.isBlank(OverdueDetails.DPD1To30Amt)){
                                brd.DPD1To30Amt__c=Integer.valueOf(OverdueDetails.DPD1To30Amt);
                            }
                            if(!string.isBlank(OverdueDetails.DPD31To60Amt)){
                                brd.DPD31To60Amt__c=Integer.valueOf(OverdueDetails.DPD31To60Amt);
                            }
                            if(!string.isBlank(OverdueDetails.DPD61T090Amt)){
                                brd.DPD61T090Amt__c=Integer.valueOf(OverdueDetails.DPD61T090Amt);
                            }
                            if(!string.isBlank(OverdueDetails.DPD91To180Amt)){
                                brd.DPD91To180Amt__c=Integer.valueOf(OverdueDetails.DPD91To180Amt);
                            }
                            if(!string.isBlank(OverdueDetails.DPDabove180Amt)){
                                brd.DPDabove180Amt__c=Integer.valueOf(OverdueDetails.DPDabove180Amt);
                            }
                            
                        }
                        insertBureauRespDtl.add(brd);
                        
                    }
                    
                    //CFHistoryforACOrDPDupto24Months
                    if(creditFacility.CFHistoryforACOrDPDupto24MonthsVec!=null && creditFacility.CFHistoryforACOrDPDupto24MonthsVec.CFHistoryforACOrDPDupto24Months!=null){
                        
                        for(CommercialIssueResponseWrapper.CFHistoryforACOrDPDupto24Months History:creditFacility.CFHistoryforACOrDPDupto24MonthsVec.CFHistoryforACOrDPDupto24Months){
                            
                            CM_CreditHistoryForACorDPD__c cfdHistory =new CM_CreditHistoryForACorDPD__c();
                            
                            cfdHistory.BureauResponse__c=refIdset!=null?refIdset:'';
                            
                            if(!String.isBlank(History.month)){
                                cfdHistory.Month__c=History.month;
                            }
                            if(!String.isBlank(History.ACorDPD)){
                                cfdHistory.ACorDPD__c=History.ACorDPD;
                            }
                            if(!String.isBlank(History.OSAmount)){
                                cfdHistory.OSAmount__c=Decimal.valueOf(History.OSAmount);
                            }
                            insertCreditHistoryForACorDPD.add(cfdHistory);
                        }
                        
                        
                    }
                    
                    //creditFacilitySecurityDetailsVec
                    if(creditFacility.creditFacilitySecurityDetailsVec!=null){
                        
                        BureauRespDtl__c brd=new BureauRespDtl__c();
                        
                        brd.RecordTypeId=RecordType!=null?RecordType:'';
                        brd.Bureau__c=refIdset!=null?refIdset:'';
                        brd.LoanApplication__c=loanId!=null?loanId:'';
                        brd.Applicant__c=ApplicantID!=null?ApplicantID:'';
                        brd.LoanCapacity__c='Individual';
                        brd.CrdFacType__c='Security';
                        brd.CrdFaciAgainst__c='Borrower';
                        
                        
                        if(!String.isBlank(creditFacility.creditFacilitySecurityDetailsVec.message)){
                            brd.Message__c=creditFacility.creditFacilitySecurityDetailsVec.message;
                        }
                        //creditFacilitySecurityDetails
                        if(creditFacility.creditFacilitySecurityDetailsVec!=null && creditFacility.creditFacilitySecurityDetailsVec.creditFacilitySecurityDetails!=null){
                            
                            for(CommercialIssueResponseWrapper.creditFacilitySecurityDetails sequirty:creditFacility.creditFacilitySecurityDetailsVec.creditFacilitySecurityDetails){
                                if(!String.isBlank(sequirty.classification)){
                                    brd.Classification__c=sequirty.classification;
                                }
                                if(!String.isBlank(sequirty.lastReportedDt)){
                                    brd.LstRepDte__c=convertToDate(sequirty.lastReportedDt);
                                }
                                if(!String.isBlank(sequirty.relatedType)){
                                    brd.RelatedType__c=sequirty.relatedType;
                                }
                                if(!String.isBlank(sequirty.validationDt)){
                                    brd.ValidationDate__c=convertToDate(sequirty.validationDt);
                                }
                                if(!String.isBlank(sequirty.value)){
                                    brd.value__c=sequirty.value;
                                }
                            }
                        }
                        
                        insertBureauRespDtl.add(brd);
                        
                    }
                    
                    //creditFacilityGuarantorDetailsVec
                    if(creditFacility.creditFacilityGuarantorDetailsVec!=null){
                        
                        
                        if(!String.isBlank(creditFacility.creditFacilityGuarantorDetailsVec.message)){
                            CM_Person_Entity_Detail__c ped =new CM_Person_Entity_Detail__c();
                            ped.BureauResponse__c=refIdset!=null?refIdset:'';
                            ped.Type__c='Credit Facility';
                            
                            ped.Message__c=creditFacility.creditFacilityGuarantorDetailsVec.message;
                            
                            insertPersonEntityDetail.add(ped);
                        }
                        
                        //creditFacilityGuarantorDetails
                        if(creditFacility.creditFacilityGuarantorDetailsVec.creditFacilityGuarantorDetails!=null){
                            
                            for(CommercialIssueResponseWrapper.creditFacilityGuarantorDetails GuarDet:creditFacility.creditFacilityGuarantorDetailsVec.creditFacilityGuarantorDetails){
                                
                                CM_Person_Entity_Detail__c ped =new CM_Person_Entity_Detail__c();
                                
                                ped.BureauResponse__c=refIdset!=null?refIdset:'';
                                ped.Type__c='Credit Facility';
                                
                                
                                //guarantorAddressContactDetails
                                if(GuarDet.guarantorAddressContactDetails!=null){
                                    CommercialIssueResponseWrapper.guarantorAddressContactDetails guarantorAddress=GuarDet.guarantorAddressContactDetails;
                                    
                                    ped.Address__c=guarantorAddress.address;
                                }
                                
                                //guarantorDetails
                                if(GuarDet.guarantorDetails!=null){
                                    CommercialIssueResponseWrapper.guarantorDetails guarantorDetails=GuarDet.guarantorDetails;
                                    
                                    ped.RelatedType__c=guarantorDetails.relatedType;
                                    ped.Name__c=guarantorDetails.name;
                                    
                                }
                                
                                //guarantorDetailsBorrwerIDDetailsVec
                                if(GuarDet.guarantorDetailsBorrwerIDDetailsVec!=null){
                                    
                                    CommercialIssueResponseWrapper.guarantorDetailsBorrwerIDDetailsVec Iddetails=GuarDet.guarantorDetailsBorrwerIDDetailsVec;
                                    
                                    ped.LstRepDte__c=convertToDate(Iddetails.lastReportedDate);
                                }
                                insertPersonEntityDetail.add(ped);
                                
                            }
                        }
                        
                    }
                    
                    //chequeDishounouredDuetoInsufficientFunds
                    if (creditFacility.chequeDishounouredDuetoInsufficientFunds!=null) {
                        
                        if (creditFacility.chequeDishounouredDuetoInsufficientFunds.message!=null) {
                            
                            BureauRespDtl__c brd=new BureauRespDtl__c();
                            
                            brd.Bureau__c=refIdset!=null?refIdset:'';
                            brd.LoanApplication__c=loanId!=null?loanId:'';
                            brd.Applicant__c=ApplicantID!=null?ApplicantID:'';
                            brd.RecordTypeId=RecordType;
                            brd.LoanCapacity__c='Individual';
                            brd.CrdFacType__c='Cheque DisHonored';
                            brd.CrdFaciAgainst__c='Borrower';
                            brd.Message__c=creditFacility.chequeDishounouredDuetoInsufficientFunds.message;
                            
                            insertBureauRespDtl.add(brd);
                            
                            
                        }
                        
                    }
                    
                    //Dispute
                    if(creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.creditFacilityDispute!=null){
                        
                        CommercialIssueResponseWrapper.RelationshipDispute RelationshipDispute=creditFacility.creditFacilityCurrentDetailsVec.creditFacilityCurrentDetails.creditFacilityDispute;
                        
                        CM_BureauDispute__c bd=new CM_BureauDispute__c();
                        
                        bd.BureauResponse__c=refIdset!=null?refIdset:'';
                        bd.Type__c='Credit Facility';
                        
                        if(!String.isBlank(RelationshipDispute.disputeRemarks)){
                            bd.DispRem__c=RelationshipDispute.disputeRemarks;
                        }
                        if(!String.isBlank(RelationshipDispute.disputeRemarksDate)){
                            bd.DispRemDte__c=convertToDate(RelationshipDispute.disputeRemarksDate);
                        }
                        
                        insertBureauDispute.add(bd);
                        
                    }

                    
                }
                
                if(insertBureauRespDtl!=null){
                    List<string> fieldNamesList = New List<string>{'Bureau__c','RecordTypeId','StatusDate__c','CFSeriNum__c',
                        'LstRepDte__c','CFType__c','Derivative__c','CFMember__c','AccNum__c','NatureOfLoan__c','Applicant__c',
                        'AstClassDysPstDueDpd__c','Status__c','DrawingPow__c','HighCredit__c','LoanName__c','LoanApplication__c',
                        'InstalAmt__c','LastRepaid__c','OutstandingBal__c','Overdues__c','SanctionedAmt__c','LoanCapacity__c',
                        'Settled__c','WrittenOFF__c','loanExpiryDt__c','Message__c','DisbursalDate__c','CurrentOs__c',
                        'loanRenewalDt__c','SanctionedDt__c','DPD1To30Amt__c','DPD31To60Amt__c','CloseDate__c','EMI__c','EMISource__c',
                        'DPD61T090Amt__c','DPD91To180Amt__c','DPDabove180Amt__c','Classification__c','LoanAmount__c',
                        'RelatedType__c','ValidationDate__c','value__c','CrdFacType__c','CrdFaciAgainst__c','Source__c'};
                            String sObjectName = 'BureauRespDtl__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(insertBureauRespDtl);
                }
                
                
                if(insertBureauDispute!=null){
                    List<string> fieldNamesList = New List<string>{'BureauResponse__c','Type__c','DispRem__c',
                        'DispRemDte__c'};
                            String sObjectName = 'CM_BureauDispute__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(insertBureauDispute);
                }
                
                if(insertCreditHistoryForACorDPD!=null){
                    List<string> fieldNamesList = New List<string>{'BureauResponse__c','Month__c','ACorDPD__c','OSAmount__c'};
                        String sObjectName = 'CM_CreditHistoryForACorDPD__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(insertCreditHistoryForACorDPD);
                }
                if(insertPersonEntityDetail!=null){
                    List<string> fieldNamesList = New List<string>{'BureauResponse__c','Type__c','Message__c',
                        'Address__c','RelatedType__c','Name__c','LstRepDte__c'};
                            String sObjectName = 'CM_Person_Entity_Detail__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(insertPersonEntityDetail);
                    
                }
                
                uow.commitWork();
                
            } catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'creditFacilityDetailsasBorrowerSec', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        } 
        
    }
    
    //*********************************************************************************************************************
    public static void guarantorIDDetails(CommercialIssueResponseWrapper res,Id refIdset){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {CM_Person_Entity_ID_Detail__c.SObjectType});
        
        if(res!=null && refIdset!=null){
            try {
                List<CM_Person_Entity_ID_Detail__c> insertEntityIDDetail =new List<CM_Person_Entity_ID_Detail__c>();
                
                List<CM_Person_Entity_Detail__c> entrylist=[Select id,BureauResponse__c,Type__c from CM_Person_Entity_Detail__c where BureauResponse__c=:refIdset AND Type__c='Credit Facility'];
                
                
                for(CommercialIssueResponseWrapper.creditFacilityDetailsasBorrowerSec creditFacility:res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditFacilityDetailsasBorrowerSecVec.creditFacilityDetailsasBorrowerSec){
                    
                    ////guarantorIDDetails 
                    if(creditFacility.creditFacilityGuarantorDetailsVec!=null){
                        
                        if (creditFacility.creditFacilityGuarantorDetailsVec.creditFacilityGuarantorDetails!=null) {
                            
                            //creditFacilityGuarantorDetails
                            for(CommercialIssueResponseWrapper.creditFacilityGuarantorDetails GuarDet:creditFacility.creditFacilityGuarantorDetailsVec.creditFacilityGuarantorDetails){
                                
                                if(GuarDet.guarantorDetailsBorrwerIDDetailsVec!=null){
                                    
                                    if(GuarDet.guarantorDetailsBorrwerIDDetailsVec.guarantorIDDetails!=null){
                                        
                                        //guarantorIDDetails
                                        for(CommercialIssueResponseWrapper.guarantorIDDetails iddetails:GuarDet.guarantorDetailsBorrwerIDDetailsVec.guarantorIDDetails){
                                            
                                            CM_Person_Entity_ID_Detail__c details =new CM_Person_Entity_ID_Detail__c();
                                            details.PersonEntity_Detail__c=entrylist[0].id;
                                            details.Type__c='Credit Facility';
                                            
                                            if(!String.isBlank(iddetails.pan)){
                                                details.PAN__c=iddetails.pan;
                                            }
                                            insertEntityIDDetail.add(details);
                                        }
                                    }
                                    
                                    
                                }
                            }
                        }
                    }
                    
                }
                
                if(insertEntityIDDetail!=null){
                    List<string> fieldNamesList = New List<string>{'PersonEntity_Detail__c','Type__c','PAN__c'};
                        String sObjectName = 'CM_Person_Entity_ID_Detail__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(insertEntityIDDetail);
                }
                uow.commitWork();
                
            } catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'guarantorIDDetails', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
        
        
        
    }
    //*********************************************************************************************************************************
    public static void enquirySummarySec(CommercialIssueResponseWrapper res,Id refIdset){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {CM_EnquirySummary__c.SObjectType});
        
        if(res!=null && refIdset!=null){
            
            try {
                List<CM_EnquirySummary__c> insertEnquirySummary =new List<CM_EnquirySummary__c>();
                
                //Message
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquirySummarySec.message!=null){
                    
                    if(!string.isblank(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquirySummarySec.message)){
                        
                        CM_EnquirySummary__c es =new CM_EnquirySummary__c();
                        
                        es.BureauResponse__c=refIdset!=null?refIdset:'';
                        
                        es.Message__c=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquirySummarySec.message;
                        
                        insertEnquirySummary.add(es);
                        
                    }
                    
                    
                }
                //enquiryOutsideInstitution
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquirySummarySec.enquiryOutsideInstitution!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquirySummarySec.enquiryOutsideInstitution.noOfEnquiries!=null){
                       
                       CommercialIssueResponseWrapper.NoOfEnquiries NoOfEnquiries=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquirySummarySec.enquiryOutsideInstitution.noOfEnquiries;
                       
                       CM_EnquirySummary__c es =new CM_EnquirySummary__c();
                       
                       es.BureauResponse__c=refIdset!=null?refIdset:'';
                       es.EnquiryType__c='Outside Institution';
                       
                       if(!string.isBlank(NoOfEnquiries.greaterthan24Month)){
                           es.Greater24Month__c=Decimal.valueOf(NoOfEnquiries.greaterthan24Month);
                       }
                       if(!string.isBlank(NoOfEnquiries.month1)){
                           es.month1__c=Decimal.valueOf(NoOfEnquiries.month1);
                       }
                       if(!string.isBlank(NoOfEnquiries.month12To24)){
                           es.Month12To24__c=Decimal.valueOf(NoOfEnquiries.month1);
                       }
                       if(!string.isBlank(NoOfEnquiries.month2To3)){
                           es.Month2To3__c=Decimal.valueOf(NoOfEnquiries.month1);
                       }
                       if(!string.isBlank(NoOfEnquiries.month4To6)){
                           es.Month4To6__c=Decimal.valueOf(NoOfEnquiries.month1);
                       }
                       if(!string.isBlank(NoOfEnquiries.month7To12)){
                           es.Month7To12__c=Decimal.valueOf(NoOfEnquiries.month1);
                       }
                       if(!string.isBlank(NoOfEnquiries.mostRecentDate)){
                           es.MostRctDte__c=convertToDate(NoOfEnquiries.mostRecentDate);
                       }
                       if(!string.isBlank(NoOfEnquiries.total)){
                           es.Total__c=Decimal.valueOf(NoOfEnquiries.month1);
                       }
                       
                       insertEnquirySummary.add(es);
                       
                       
                   }
                //enquiryYourInstitution
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquirySummarySec.enquiryYourInstitution!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquirySummarySec.enquiryYourInstitution.noOfEnquiries!=null){
                       
                       CommercialIssueResponseWrapper.NoOfEnquiries NoOfEnquiries=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquirySummarySec.enquiryYourInstitution.noOfEnquiries;
                       
                       CM_EnquirySummary__c es =new CM_EnquirySummary__c();
                       
                       es.BureauResponse__c=refIdset!=null?refIdset:'';
                       es.EnquiryType__c='Your Institution';
                       
                       if(!string.isBlank(NoOfEnquiries.greaterthan24Month)){
                           es.Greater24Month__c=Decimal.valueOf(NoOfEnquiries.greaterthan24Month);
                       }
                       if(!string.isBlank(NoOfEnquiries.month1)){
                           es.month1__c=Decimal.valueOf(NoOfEnquiries.month1);
                       }
                       if(!string.isBlank(NoOfEnquiries.month12To24)){
                           es.Month12To24__c=Decimal.valueOf(NoOfEnquiries.month1);
                       }
                       if(!string.isBlank(NoOfEnquiries.month2To3)){
                           es.Month2To3__c=Decimal.valueOf(NoOfEnquiries.month1);
                       }
                       if(!string.isBlank(NoOfEnquiries.month4To6)){
                           es.Month4To6__c=Decimal.valueOf(NoOfEnquiries.month1);
                       }
                       if(!string.isBlank(NoOfEnquiries.month7To12)){
                           es.Month7To12__c=Decimal.valueOf(NoOfEnquiries.month1);
                       }
                       if(!string.isBlank(NoOfEnquiries.mostRecentDate)){
                           es.MostRctDte__c=convertToDate(NoOfEnquiries.mostRecentDate);
                       }
                       if(!string.isBlank(NoOfEnquiries.total)){
                           es.Total__c=Decimal.valueOf(NoOfEnquiries.month1);
                       }
                       
                       insertEnquirySummary.add(es);
                       
                       
                   }
                //enquiryTotal
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquirySummarySec.enquiryTotal!=null &&
                   res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquirySummarySec.enquiryTotal.noOfEnquiries!=null){
                       
                       CommercialIssueResponseWrapper.NoOfEnquiries NoOfEnquiries=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.enquirySummarySec.enquiryTotal.noOfEnquiries;
                       
                       CM_EnquirySummary__c es =new CM_EnquirySummary__c();
                       
                       es.BureauResponse__c=refIdset!=null?refIdset:'';
                       es.EnquiryType__c='Total';
                       
                       if(!string.isBlank(NoOfEnquiries.greaterthan24Month)){
                           es.Greater24Month__c=Decimal.valueOf(NoOfEnquiries.greaterthan24Month);
                       }
                       if(!string.isBlank(NoOfEnquiries.month1)){
                           es.month1__c=Decimal.valueOf(NoOfEnquiries.month1);
                       }
                       if(!string.isBlank(NoOfEnquiries.month12To24)){
                           es.Month12To24__c=Decimal.valueOf(NoOfEnquiries.month1);
                       }
                       if(!string.isBlank(NoOfEnquiries.month2To3)){
                           es.Month2To3__c=Decimal.valueOf(NoOfEnquiries.month1);
                       }
                       if(!string.isBlank(NoOfEnquiries.month4To6)){
                           es.Month4To6__c=Decimal.valueOf(NoOfEnquiries.month1);
                       }
                       if(!string.isBlank(NoOfEnquiries.month7To12)){
                           es.Month7To12__c=Decimal.valueOf(NoOfEnquiries.month1);
                       }
                       if(!string.isBlank(NoOfEnquiries.mostRecentDate)){
                           es.MostRctDte__c=convertToDate(NoOfEnquiries.mostRecentDate);
                       }
                       if(!string.isBlank(NoOfEnquiries.total)){
                           es.Total__c=Decimal.valueOf(NoOfEnquiries.month1);
                       }
                       
                       insertEnquirySummary.add(es);
                       
                       
                   }
                
                if(insertEnquirySummary!=null){
                    List<string> fieldNamesList = New List<string>{'BureauResponse__c','EnquiryType__c','Greater24Month__c','MostRctDte__c',
                        'month1__c','Month12To24__c','Month2To3__c','Month4To6__c','Month7To12__c','Total__c'};
                            String sObjectName = 'CM_EnquirySummary__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(insertEnquirySummary);
                }
                uow.commitWork(); 
                
            } catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'enquirySummarySec', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
        
    }
    //*******************************************************************************************************************************
    public static Void creditVision(CommercialIssueResponseWrapper res,Id refIdset){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {CM_CreditVision__c.SObjectType});
        
        if(res!=null && refIdset!=null){
            
            try {
                List<CM_CreditVision__c> insertCreditVision =new List<CM_CreditVision__c>();
                
                for(CommercialIssueResponseWrapper.creditVision creditVision:res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditVisionSec.creditVision){
                    
                    CM_CreditVision__c cv =new CM_CreditVision__c();
                    
                    cv.BureauResponse__c=refIdset!=null?refIdset:'';
                    
                    if(!String.isBlank(creditVision.creditVisionDesc)){
                        cv.Description__c=creditVision.creditVisionDesc;
                    }
                    if(!String.isBlank(creditVision.creditVisionName)){
                        cv.Name__c=creditVision.creditVisionName;
                    }
                    if(creditVision.creditVisionValue!=null){
                        cv.Value__c=String.valueOf(creditVision.creditVisionValue);
                    }
                    insertCreditVision.add(cv);
                }
                if(insertCreditVision!=null){
                    List<string> fieldNamesList = New List<string>{'BureauResponse__c','Description__c','Name__c','Value__c'};
                        String sObjectName = 'CM_CreditVision__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(insertCreditVision);
                }
                uow.commitWork();
            } catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'creditVision', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
        
        
        
    }
    //*********************************************************************************************************************************
    public static void creditProfileSummary(CommercialIssueResponseWrapper res,Id refIdset){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { CM_CreditProfileSummary__c.SObjectType});
        
        if(res!=null && refIdset !=null){
            try {
                
                List<CM_CreditProfileSummary__c> insertCreditProfileSummary =new List<CM_CreditProfileSummary__c>();
                //total
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditProfileSummarySec.total!=null){
                    
                    
                    CommercialIssueResponseWrapper.Total_Z Total_Z=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditProfileSummarySec.total;
                    
                    
                    
                    CM_CreditProfileSummary__c cps = new CM_CreditProfileSummary__c();
                    
                    cps.BureauResponse__c=refIdset!=null?refIdset:'';
                    cps.EtyType__c='Total';
                    
                    if(!String.isBlank(Total_Z.delinquentCF)){
                        cps.Delinquent_CF__c=Integer.valueOf(Total_Z.delinquentCF);
                    }
                    if(!String.isBlank(Total_Z.delinquentOutstanding)){
                        cps.DelinquentOutstanding__c=Integer.valueOf(Total_Z.delinquentOutstanding);
                    }
                    if(!String.isBlank(Total_Z.latestCFOpenedDate) && Total_Z.latestCFOpenedDate!='-' ){
                        cps.LstCFOpenedDte__c=convertToDate(Total_Z.latestCFOpenedDate);
                    }
                    if(!String.isBlank(Total_Z.openCF)){
                        cps.Open_CF__c=Integer.valueOf(Total_Z.openCF);
                    }
                    if(!String.isBlank(Total_Z.totalCF)){
                        cps.TotalCF__c=Integer.valueOf(Total_Z.totalCF);
                    }
                    if(!String.isBlank(Total_Z.totalLenders)){
                        cps.TotalLenders__c=Integer.valueOf(Total_Z.totalLenders);
                    }
                    if(!String.isBlank(Total_Z.totalOutstanding)){
                        cps.TotalOutstanding__c=Total_Z.totalOutstanding;
                    }
                    insertCreditProfileSummary.add(cps);
                    
                    
                    
                }
                
                
                //yourInstitution
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditProfileSummarySec.yourInstitution!=null){
                    
                    CommercialIssueResponseWrapper.YourInstitution_Z YourInstitution_Z=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditProfileSummarySec.yourInstitution;
                    
                    
                    
                    CM_CreditProfileSummary__c cps = new CM_CreditProfileSummary__c();
                    
                    cps.BureauResponse__c=refIdset!=null?refIdset:'';
                    cps.EtyType__c='Your Institution';
                    
                    if(!String.isBlank(YourInstitution_Z.latestCFOpenedDate) && YourInstitution_Z.latestCFOpenedDate!='-'){
                        cps.LstCFOpenedDte__c=convertToDate(YourInstitution_Z.latestCFOpenedDate);
                    }
                    
                    if(!String.isBlank(YourInstitution_Z.message)){
                        cps.Message__c=YourInstitution_Z.message; 
                    }
                    if(!String.isBlank(YourInstitution_Z.openCF)){
                        cps.Open_CF__c=Integer.valueOf(YourInstitution_Z.openCF);
                    }
                    if(!String.isBlank(YourInstitution_Z.totalLenders)){
                        cps.TotalLenders__c=Integer.valueOf(YourInstitution_Z.totalLenders);
                    }
                    //totalOutstanding
                    if(YourInstitution_Z.totalOutstanding!=null){
                        
                        CommercialIssueResponseWrapper.TotalOutstanding TotalOutstanding=YourInstitution_Z.totalOutstanding;
                        
                        if(!string.isBlank(TotalOutstanding.borrower)){
                            cps.TotalBorrower__c=TotalOutstanding.borrower;
                        }
                        if(!string.isBlank(TotalOutstanding.borrowerPercentage)){
                            cps.TotalBorrowerPer__c=TotalOutstanding.borrowerPercentage;
                            
                        }
                        if(!string.isBlank(TotalOutstanding.guarantor)){
                            cps.TotalGuarantor__c=TotalOutstanding.guarantor;
                        }
                        if(!string.isBlank(TotalOutstanding.guarantorPercentage)){
                            cps.TotalGuarantorPer__c=TotalOutstanding.guarantorPercentage;
                        }
                        
                    }
                    
                    //totalCF
                    if(YourInstitution_Z.totalCF!=null){
                        
                        CommercialIssueResponseWrapper.TotalOutstanding totalCF=YourInstitution_Z.totalCF;
                        
                        if(!string.isBlank(totalCF.borrower)){
                            cps.TotalCFBorrower__c=totalCF.borrower;
                            
                        }
                        if(!string.isBlank(totalCF.borrowerPercentage)){
                            cps.TotalCFborper__c=totalCF.borrowerPercentage;
                        }
                        if(!string.isBlank(totalCF.guarantor)){
                            cps.TotalCFGuarantor__c=totalCF.guarantor;
                        }
                        if(!string.isBlank(totalCF.guarantorPercentage)){
                            cps.TotalCFGuarPer__c=totalCF.guarantorPercentage;
                        }
                        
                    }
                    //delinquentOutstanding
                    if(YourInstitution_Z.delinquentOutstanding!=null){
                        
                        CommercialIssueResponseWrapper.TotalOutstanding delinquentOutstanding=YourInstitution_Z.delinquentOutstanding;
                        
                        if(!string.isBlank(delinquentOutstanding.borrower)){
                            cps.DelinquentBorr__c=delinquentOutstanding.borrower;
                        }
                        if(!string.isBlank(delinquentOutstanding.borrowerPercentage)){
                            cps.DelinquentBorrPer__c=delinquentOutstanding.borrowerPercentage;
                        }
                        if(!string.isBlank(delinquentOutstanding.guarantor)){
                            cps.DelinquentGuarantor__c=delinquentOutstanding.guarantor;
                        }
                        if(!string.isBlank(delinquentOutstanding.guarantorPercentage)){
                            cps.DelinquentGuarantorPerc__c=delinquentOutstanding.guarantorPercentage;
                        }
                        
                    }
                    //delinquentCF
                    if(YourInstitution_Z.delinquentCF!=null){
                        
                        CommercialIssueResponseWrapper.TotalOutstanding delinquentCF=YourInstitution_Z.delinquentCF;
                        
                        if(!string.isBlank(delinquentCF.borrower)){
                            cps.DelinquentCFBorr__c=delinquentCF.borrower;
                        }
                        if(!string.isBlank(delinquentCF.borrowerPercentage)){
                            cps.DelinquentCFBorrPer__c=delinquentCF.borrowerPercentage;
                        }
                        if(!string.isBlank(delinquentCF.guarantor)){
                            cps.DelinquentCFGuarantor__c=delinquentCF.guarantor;
                        }
                        if(!string.isBlank(delinquentCF.guarantorPercentage)){
                            cps.DelinquentCFGuarantorPer__c=delinquentCF.guarantorPercentage;
                        }
                        
                    }
                    
                    insertCreditProfileSummary.add(cps);
                    
                    
                    
                }
                
                
                //outsideInstitution
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditProfileSummarySec.outsideInstitution!=null){
                    
                    CommercialIssueResponseWrapper.OutsideInstitution OutsideInstitution=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditProfileSummarySec.outsideInstitution;
                    
                    
                    CM_CreditProfileSummary__c cps = new CM_CreditProfileSummary__c();
                    
                    cps.BureauResponse__c=refIdset!=null?refIdset:'';
                    cps.EtyType__c='Outside Institution';
                    
                    if(!String.isBlank(OutsideInstitution.message)){
                        cps.Message__c=OutsideInstitution.message;
                    }
                    insertCreditProfileSummary.add(cps);
                    
                    
                    //outsideTotal
                    if(OutsideInstitution.outsideTotal!=null){
                        
                        
                        
                        CommercialIssueResponseWrapper.YourInstitution_Z outside=OutsideInstitution.outsideTotal;
                        
                        CM_CreditProfileSummary__c cp = new CM_CreditProfileSummary__c();
                        
                        cp.BureauResponse__c=refIdset!=null?refIdset:'';
                        cp.Outside_Institution__c='Outside Total';
                        cps.EtyType__c='Outside Institution';
                        
                        if(!String.isBlank(outside.latestCFOpenedDate) && outside.latestCFOpenedDate!='-'){
                            cp.LstCFOpenedDte__c=convertToDate(outside.latestCFOpenedDate);
                        }
                        if(!String.isBlank(outside.totalOutstanding.borrower)){
                            cp.TotalBorrower__c=outside.totalOutstanding.borrower;
                        }
                        if(!String.isBlank(outside.totalOutstanding.borrowerPercentage)){
                            cp.TotalBorrowerPer__c=outside.totalOutstanding.borrowerPercentage;
                        }
                        if(!String.isBlank(outside.totalOutstanding.guarantor)){
                            cp.TotalGuarantor__c=outside.totalOutstanding.guarantor;
                        }
                        if(!String.isBlank(outside.totalOutstanding.guarantorPercentage)){
                            cp.TotalGuarantorPer__c=outside.totalOutstanding.guarantorPercentage;
                        }
                        if(!String.isBlank(outside.totalCF.borrower)){
                            cp.TotalCFBorrower__c=outside.totalCF.borrower;
                        }
                        if(!String.isBlank(outside.totalCF.borrowerPercentage)){
                            cp.TotalCFborper__c=outside.totalCF.borrowerPercentage;
                        }
                        if(!String.isBlank(outside.totalCF.guarantor)){
                            cp.TotalCFGuarantor__c=outside.totalCF.guarantor;
                        }
                        if(!String.isBlank(outside.totalCF.guarantorPercentage)){
                            cp.TotalCFGuarPer__c=outside.totalCF.guarantorPercentage;
                        }
                        if(!String.isBlank(outside.delinquentOutstanding.borrower)){
                            cp.DelinquentBorr__c=outside.delinquentOutstanding.borrower;
                        }
                        if(!String.isBlank(outside.delinquentOutstanding.borrowerPercentage)){
                            cp.DelinquentBorrPer__c=outside.delinquentOutstanding.borrowerPercentage;
                        }
                        if(!String.isBlank(outside.delinquentOutstanding.guarantor)){
                            cp.DelinquentGuarantor__c=outside.delinquentOutstanding.guarantor;
                        }
                        if(!String.isBlank(outside.delinquentOutstanding.guarantorPercentage)){
                            cp.DelinquentGuarantorPerc__c=outside.delinquentOutstanding.guarantorPercentage;
                        }
                        
                        if(!String.isBlank(outside.delinquentCF.borrower)){
                            cp.DelinquentCFBorr__c=outside.delinquentCF.borrower;
                        }
                        if(!String.isBlank(outside.delinquentCF.borrowerPercentage)){
                            cp.DelinquentCFBorrPer__c=outside.delinquentCF.borrowerPercentage;
                        }
                        if(!String.isBlank(outside.delinquentCF.guarantor)){
                            cp.DelinquentCFGuarantor__c=outside.delinquentCF.guarantor;
                        }
                        if(!String.isBlank(outside.delinquentCF.guarantorPercentage)){
                            cp.DelinquentCFGuarantorPer__c=outside.delinquentCF.guarantorPercentage;
                        }
                        
                        if(!String.isBlank(outside.message)){
                            cp.Message__c=outside.message;
                        }
                        
                        insertCreditProfileSummary.add(cp);
                        
                        
                    }
                    
                    //otherPublicSectorBanks
                    if(OutsideInstitution.otherPublicSectorBanks!=null){
                        
                        
                        
                        CommercialIssueResponseWrapper.YourInstitution_Z outside=OutsideInstitution.otherPublicSectorBanks;
                        
                        CM_CreditProfileSummary__c cp = new CM_CreditProfileSummary__c();
                        
                        cp.BureauResponse__c=refIdset!=null?refIdset:'';
                        cps.EtyType__c='Outside Institution';
                        cp.Outside_Institution__c='Other Public Sector Banks';
                        
                        if(!String.isBlank(outside.latestCFOpenedDate) && outside.latestCFOpenedDate!='-'){
                            cp.LstCFOpenedDte__c=convertToDate(outside.latestCFOpenedDate);
                        }
                        if(!String.isBlank(outside.totalOutstanding.borrower)){
                            cp.TotalBorrower__c=outside.totalOutstanding.borrower;
                        }
                        if(!String.isBlank(outside.totalOutstanding.borrowerPercentage)){
                            cp.TotalBorrowerPer__c=outside.totalOutstanding.borrowerPercentage;
                        }
                        if(!String.isBlank(outside.totalOutstanding.guarantor)){
                            cp.TotalGuarantor__c=outside.totalOutstanding.guarantor;
                        }
                        if(!String.isBlank(outside.totalOutstanding.guarantorPercentage)){
                            cp.TotalGuarantorPer__c=outside.totalOutstanding.guarantorPercentage;
                        }
                        if(!String.isBlank(outside.totalCF.borrower)){
                            cp.TotalCFBorrower__c=outside.totalCF.borrower;
                        }
                        if(!String.isBlank(outside.totalCF.borrowerPercentage)){
                            cp.TotalCFborper__c=outside.totalCF.borrowerPercentage;
                        }
                        if(!String.isBlank(outside.totalCF.guarantor)){
                            cp.TotalCFGuarantor__c=outside.totalCF.guarantor;
                        }
                        if(!String.isBlank(outside.totalCF.guarantorPercentage)){
                            cp.TotalCFGuarPer__c=outside.totalCF.guarantorPercentage;
                        }
                        if(!String.isBlank(outside.delinquentOutstanding.borrower)){
                            cp.DelinquentBorr__c=outside.delinquentOutstanding.borrower;
                        }
                        if(!String.isBlank(outside.delinquentOutstanding.borrowerPercentage)){
                            cp.DelinquentBorrPer__c=outside.delinquentOutstanding.borrowerPercentage;
                        }
                        if(!String.isBlank(outside.delinquentOutstanding.guarantor)){
                            cp.DelinquentGuarantor__c=outside.delinquentOutstanding.guarantor;
                        }
                        if(!String.isBlank(outside.delinquentOutstanding.guarantorPercentage)){
                            cp.DelinquentGuarantorPerc__c=outside.delinquentOutstanding.guarantorPercentage;
                        }
                        
                        if(!String.isBlank(outside.delinquentCF.borrower)){
                            cp.DelinquentCFBorr__c=outside.delinquentCF.borrower;
                        }
                        if(!String.isBlank(outside.delinquentCF.borrowerPercentage)){
                            cp.DelinquentCFBorrPer__c=outside.delinquentCF.borrowerPercentage;
                        }
                        if(!String.isBlank(outside.delinquentCF.guarantor)){
                            cp.DelinquentCFGuarantor__c=outside.delinquentCF.guarantor;
                        }
                        if(!String.isBlank(outside.delinquentCF.guarantorPercentage)){
                            cp.DelinquentCFGuarantorPer__c=outside.delinquentCF.guarantorPercentage;
                        }
                        
                        if(!String.isBlank(outside.message)){
                            cp.Message__c=outside.message;
                        }
                        
                        insertCreditProfileSummary.add(cp);
                        
                        
                        
                    }
                    
                    //otherPrivateForeignBanks
                    if(OutsideInstitution.otherPrivateForeignBanks!=null){
                        
                        
                        
                        CommercialIssueResponseWrapper.YourInstitution_Z outside=OutsideInstitution.otherPrivateForeignBanks;
                        
                        CM_CreditProfileSummary__c cp = new CM_CreditProfileSummary__c();
                        
                        cp.BureauResponse__c=refIdset!=null?refIdset:'';
                        cps.EtyType__c='Outside Institution';
                        cp.Outside_Institution__c='Other Private Foreign Banks';
                        
                        if(!String.isBlank(outside.latestCFOpenedDate) && outside.latestCFOpenedDate!='-'){
                            cp.LstCFOpenedDte__c=convertToDate(outside.latestCFOpenedDate);
                        }
                        if(!String.isBlank(outside.totalOutstanding.borrower)){
                            cp.TotalBorrower__c=outside.totalOutstanding.borrower;
                        }
                        if(!String.isBlank(outside.totalOutstanding.borrowerPercentage)){
                            cp.TotalBorrowerPer__c=outside.totalOutstanding.borrowerPercentage;
                        }
                        if(!String.isBlank(outside.totalOutstanding.guarantor)){
                            cp.TotalGuarantor__c=outside.totalOutstanding.guarantor;
                        }
                        if(!String.isBlank(outside.totalOutstanding.guarantorPercentage)){
                            cp.TotalGuarantorPer__c=outside.totalOutstanding.guarantorPercentage;
                        }
                        if(!String.isBlank(outside.totalCF.borrower)){
                            cp.TotalCFBorrower__c=outside.totalCF.borrower;
                        }
                        if(!String.isBlank(outside.totalCF.borrowerPercentage)){
                            cp.TotalCFborper__c=outside.totalCF.borrowerPercentage;
                        }
                        if(!String.isBlank(outside.totalCF.guarantor)){
                            cp.TotalCFGuarantor__c=outside.totalCF.guarantor;
                        }
                        if(!String.isBlank(outside.totalCF.guarantorPercentage)){
                            cp.TotalCFGuarPer__c=outside.totalCF.guarantorPercentage;
                        }
                        if(!String.isBlank(outside.delinquentOutstanding.borrower)){
                            cp.DelinquentBorr__c=outside.delinquentOutstanding.borrower;
                        }
                        if(!String.isBlank(outside.delinquentOutstanding.borrowerPercentage)){
                            cp.DelinquentBorrPer__c=outside.delinquentOutstanding.borrowerPercentage;
                        }
                        if(!String.isBlank(outside.delinquentOutstanding.guarantor)){
                            cp.DelinquentGuarantor__c=outside.delinquentOutstanding.guarantor;
                        }
                        if(!String.isBlank(outside.delinquentOutstanding.guarantorPercentage)){
                            cp.DelinquentGuarantorPerc__c=outside.delinquentOutstanding.guarantorPercentage;
                        }
                        
                        if(!String.isBlank(outside.delinquentCF.borrower)){
                            cp.DelinquentCFBorr__c=outside.delinquentCF.borrower;
                        }
                        if(!String.isBlank(outside.delinquentCF.borrowerPercentage)){
                            cp.DelinquentCFBorrPer__c=outside.delinquentCF.borrowerPercentage;
                        }
                        if(!String.isBlank(outside.delinquentCF.guarantor)){
                            cp.DelinquentCFGuarantor__c=outside.delinquentCF.guarantor;
                        }
                        if(!String.isBlank(outside.delinquentCF.guarantorPercentage)){
                            cp.DelinquentCFGuarantorPer__c=outside.delinquentCF.guarantorPercentage;
                        }
                        
                        if(!String.isBlank(outside.message)){
                            cp.Message__c=outside.message;
                        }
                        
                        insertCreditProfileSummary.add(cp);
                        
                        
                        
                    }
                    
                    //NBFCOthers
                    if(OutsideInstitution.NBFCOthers!=null){
                        
                        
                        
                        CommercialIssueResponseWrapper.YourInstitution_Z outside=OutsideInstitution.NBFCOthers;
                        
                        CM_CreditProfileSummary__c cp = new CM_CreditProfileSummary__c();
                        
                        cp.BureauResponse__c=refIdset!=null?refIdset:'';
                        cps.EtyType__c='Outside Institution';
                        cp.Outside_Institution__c='NBFC Others';
                        
                        if(!String.isBlank(outside.latestCFOpenedDate) && outside.latestCFOpenedDate!='-'){
                            cp.LstCFOpenedDte__c=convertToDate(outside.latestCFOpenedDate);
                        }
                        if(!String.isBlank(outside.totalOutstanding.borrower)){
                            cp.TotalBorrower__c=outside.totalOutstanding.borrower;
                        }
                        if(!String.isBlank(outside.totalOutstanding.borrowerPercentage)){
                            cp.TotalBorrowerPer__c=outside.totalOutstanding.borrowerPercentage;
                        }
                        if(!String.isBlank(outside.totalOutstanding.guarantor)){
                            cp.TotalGuarantor__c=outside.totalOutstanding.guarantor;
                        }
                        if(!String.isBlank(outside.totalOutstanding.guarantorPercentage)){
                            cp.TotalGuarantorPer__c=outside.totalOutstanding.guarantorPercentage;
                        }
                        if(!String.isBlank(outside.totalCF.borrower)){
                            cp.TotalCFBorrower__c=outside.totalCF.borrower;
                        }
                        if(!String.isBlank(outside.totalCF.borrowerPercentage)){
                            cp.TotalCFborper__c=outside.totalCF.borrowerPercentage;
                        }
                        if(!String.isBlank(outside.totalCF.guarantor)){
                            cp.TotalCFGuarantor__c=outside.totalCF.guarantor;
                        }
                        if(!String.isBlank(outside.totalCF.guarantorPercentage)){
                            cp.TotalCFGuarPer__c=outside.totalCF.guarantorPercentage;
                        }
                        if(!String.isBlank(outside.delinquentOutstanding.borrower)){
                            cp.DelinquentBorr__c=outside.delinquentOutstanding.borrower;
                        }
                        if(!String.isBlank(outside.delinquentOutstanding.borrowerPercentage)){
                            cp.DelinquentBorrPer__c=outside.delinquentOutstanding.borrowerPercentage;
                        }
                        if(!String.isBlank(outside.delinquentOutstanding.guarantor)){
                            cp.DelinquentGuarantor__c=outside.delinquentOutstanding.guarantor;
                        }
                        if(!String.isBlank(outside.delinquentOutstanding.guarantorPercentage)){
                            cp.DelinquentGuarantorPerc__c=outside.delinquentOutstanding.guarantorPercentage;
                        }
                        
                        if(!String.isBlank(outside.delinquentCF.borrower)){
                            cp.DelinquentCFBorr__c=outside.delinquentCF.borrower;
                        }
                        if(!String.isBlank(outside.delinquentCF.borrowerPercentage)){
                            cp.DelinquentCFBorrPer__c=outside.delinquentCF.borrowerPercentage;
                        }
                        if(!String.isBlank(outside.delinquentCF.guarantor)){
                            cp.DelinquentCFGuarantor__c=outside.delinquentCF.guarantor;
                        }
                        if(!String.isBlank(outside.delinquentCF.guarantorPercentage)){
                            cp.DelinquentCFGuarantorPer__c=outside.delinquentCF.guarantorPercentage;
                        }
                        
                        if(!String.isBlank(outside.message)){
                            cp.Message__c=outside.message;
                        }
                        
                        insertCreditProfileSummary.add(cp);
                        
                        
                        
                    }
                    
                }
                if(insertCreditProfileSummary!=null){
                    List<string> fieldNamesList = New List<string>{'BureauResponse__c','LstCFOpenedDte__c',
                        'Message__c','Open_CF__c','TotalLenders__c','TotalBorrower__c','EtyType__c',
                        'TotalBorrowerPer__c','TotalGuarantor__c','TotalGuarantorPer__c',
                        'TotalCFBorrower__c','TotalCFborper__c','TotalCFGuarantor__c',
                        'TotalCFGuarPer__c','DelinquentBorr__c','DelinquentBorrPer__c',
                        'DelinquentGuarantor__c','DelinquentGuarantorPerc__c','DelinquentCFBorr__c',
                        'DelinquentCFBorrPer__c','DelinquentCFGuarantor__c','DelinquentCFGuarantorPer__c'};
                            String sObjectName = 'CM_CreditProfileSummary__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(insertCreditProfileSummary);
                }
                uow.commitWork();
            } catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'creditProfileSummary', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
        
    }
    
    //*********************************************************************************************************************************
    public static void creditRatingSummary(CommercialIssueResponseWrapper res,Id refIdset){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { CM_CreditRating__c.SObjectType});
        
        if(res!=null && refIdset !=null){
            
            try {
                
                List<CM_CreditRating__c> insertCreditRating =new List<CM_CreditRating__c>();
                
                if(!String.isBlank(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditRatingSummaryVec.message)){
                    CM_CreditRating__c cr=new CM_CreditRating__c();
                    cr.BureauResponse__c=refIdset!=null?refIdset:'';
                    cr.Message__c=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.creditRatingSummaryVec.message;
                    insertCreditRating.add(cr);
                }
                if(insertCreditRating!=null){
                    List<string> fieldNamesList = New List<string>{'BureauResponse__c','Message__c'};
                        String sObjectName = 'CM_CreditRating__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(insertCreditRating);
                }
                uow.commitWork();
            } catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'creditRatingSummary', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
            
        }
        
        
    }
    //*********************************************************************************************************************************
    public static void oustandingBalanceByCFAndAssetClasificationSec(CommercialIssueResponseWrapper res,Id refIdset){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { CM_OutstandingBalanceByCFAsset__c.SObjectType});
        
        if(res!=null && refIdset!=null){
            
            try {
                
                List<CM_OutstandingBalanceByCFAsset__c> insertOutstandingBalance =new List<CM_OutstandingBalanceByCFAsset__c>();
                
                //yourInstitution
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution!=null){
                    //total 
                    if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.total!=null ){
                        //NONSTDVec with sub
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.total.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.total.NONSTDVec.sub!=null){
                               
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.total.NONSTDVec.sub;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Total';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='sub';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                               
                           }
                        
                        //NONSTDVec with loss
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.total.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.total.NONSTDVec.loss!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.total.NONSTDVec.loss;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Total';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='loss';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with DPD91To180
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.total.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.total.NONSTDVec.DPD91To180!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.total.NONSTDVec.DPD91To180;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Total';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='DPD91To180';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with dbt
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.total.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.total.NONSTDVec.dbt!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.total.NONSTDVec.dbt;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Total';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='dbt';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD0
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.total.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.total.STDVec.DPD0!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.total.STDVec.DPD0;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Total';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD0';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD1To30
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.total.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.total.STDVec.DPD1To30!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.total.STDVec.DPD1To30;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Total';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD1To30';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD31To60
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.total.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.total.STDVec.DPD31To60!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.total.STDVec.DPD31To60;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Total';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD31To60';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD61To90
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.total.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.total.STDVec.DPD61To90!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.total.STDVec.DPD61To90;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Total';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD61To90';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        
                    }
                    
                    //termLoan
                    if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.termLoan!=null){
                        
                        //NONSTDVec with sub
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.termLoan.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.termLoan.NONSTDVec.sub!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.termLoan.NONSTDVec.sub;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Term Loan';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='sub';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with loss
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.termLoan.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.termLoan.NONSTDVec.loss!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.termLoan.NONSTDVec.loss;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Term Loan';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='loss';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with DPD91To180
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.termLoan.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.termLoan.NONSTDVec.DPD91To180!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.termLoan.NONSTDVec.DPD91To180;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Term Loan';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='DPD91To180';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with dbt
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.termLoan.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.termLoan.NONSTDVec.dbt!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.termLoan.NONSTDVec.dbt;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Term Loan';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='dbt';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD0
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.termLoan.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.termLoan.STDVec.DPD0!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.termLoan.STDVec.DPD0;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Total';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD0';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD1To30
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.termLoan.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.termLoan.STDVec.DPD1To30!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.termLoan.STDVec.DPD1To30;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Term Loan';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD1To30';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD31To60
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.termLoan.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.termLoan.STDVec.DPD31To60!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.termLoan.STDVec.DPD31To60;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Term Loan';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD31To60';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD61To90
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.termLoan.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.termLoan.STDVec.DPD61To90!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.termLoan.STDVec.DPD61To90;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Term Loan';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD61To90';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        //termLoan with total
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.termLoan.total!=null){
                            CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                            
                            CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.termLoan.total;
                            
                            osb.BureauResponse__c=refIdset!=null?refIdset:'';
                            osb.Outstanding_Balance_Entity__c='Your Institution';
                            osb.OutstandBalCat__c='Term Loan';
                            osb.OutstandiBalVecType__c='Total';
                            osb.BalanceType__c='';
                            
                            if(!String.isBlank(val.count)){
                                osb.OutstandingCount__c=val.count;
                            }
                            if(!String.isBlank(val.value)){
                                osb.OutstandingValue__c=val.value;
                            }
                            insertOutstandingBalance.add(osb);
                        }
                    }
                    
                    //workingCapital
                    if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.workingCapital!=null){
                        
                        //NONSTDVec with sub
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.workingCapital.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.workingCapital.NONSTDVec.sub!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.workingCapital.NONSTDVec.sub;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Working Capital';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='sub';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with loss
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.workingCapital.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.workingCapital.NONSTDVec.loss!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.workingCapital.NONSTDVec.loss;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Working Capital';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='loss';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with DPD91To180
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.workingCapital.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.workingCapital.NONSTDVec.DPD91To180!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.workingCapital.NONSTDVec.DPD91To180;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Working Capital';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='DPD91To180';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with dbt
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.workingCapital.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.workingCapital.NONSTDVec.dbt!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.workingCapital.NONSTDVec.dbt;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Working Capital';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='dbt';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD0
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.workingCapital.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.workingCapital.STDVec.DPD0!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.workingCapital.STDVec.DPD0;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Total';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD0';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD1To30
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.workingCapital.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.workingCapital.STDVec.DPD1To30!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.workingCapital.STDVec.DPD1To30;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Working Capital';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='DPD1To30';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD31To60
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.workingCapital.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.workingCapital.STDVec.DPD31To60!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.workingCapital.STDVec.DPD31To60;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Working Capital';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD31To60';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD61To90
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.workingCapital.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.workingCapital.STDVec.DPD61To90!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.workingCapital.STDVec.DPD61To90;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Working Capital';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD61To90';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        //workingCapital with total
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.workingCapital.total!=null){
                            CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                            
                            CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.workingCapital.total;
                            
                            osb.BureauResponse__c=refIdset!=null?refIdset:'';
                            osb.Outstanding_Balance_Entity__c='Your Institution';
                            osb.OutstandBalCat__c='Term Loan';
                            osb.OutstandiBalVecType__c='Total';
                            osb.BalanceType__c='';
                            
                            if(!String.isBlank(val.count)){
                                osb.OutstandingCount__c=val.count;
                            }
                            if(!String.isBlank(val.value)){
                                osb.OutstandingValue__c=val.value;
                            }
                            insertOutstandingBalance.add(osb);
                        }
                    }
                    
                    //forex
                    if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.forex!=null){
                        
                        //NONSTDVec with sub
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.forex.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.forex.NONSTDVec.sub!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.forex.NONSTDVec.sub;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Forex';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='sub';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with loss
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.forex.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.forex.NONSTDVec.loss!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.forex.NONSTDVec.loss;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Forex';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='loss';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with DPD91To180
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.forex.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.forex.NONSTDVec.DPD91To180!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.forex.NONSTDVec.DPD91To180;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Forex';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='DPD91To180';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with dbt
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.forex.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.forex.NONSTDVec.dbt!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.forex.NONSTDVec.dbt;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Forex';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='dbt';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD0
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.forex.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.forex.STDVec.DPD0!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.forex.STDVec.DPD0;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Forex';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD0';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD1To30
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.forex.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.forex.STDVec.DPD1To30!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.forex.STDVec.DPD1To30;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Forex';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD1To30';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD31To60
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.forex.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.forex.STDVec.DPD31To60!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.forex.STDVec.DPD31To60;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Forex';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD31To60';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD61To90
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.forex.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.forex.STDVec.DPD61To90!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.forex.STDVec.DPD61To90;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Forex';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD61To90';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        //workingCapital with total
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.forex.total!=null){
                            CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                            
                            CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.forex.total;
                            
                            osb.BureauResponse__c=refIdset!=null?refIdset:'';
                            osb.Outstanding_Balance_Entity__c='Your Institution';
                            osb.OutstandBalCat__c='Working Capital';
                            osb.OutstandiBalVecType__c='Total';
                            osb.BalanceType__c='';
                            
                            if(!String.isBlank(val.count)){
                                osb.OutstandingCount__c=val.count;
                            }
                            if(!String.isBlank(val.value)){
                                osb.OutstandingValue__c=val.value;
                            }
                            insertOutstandingBalance.add(osb);
                        }
                    }
                    
                    //nonFunded
                    if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.nonFunded!=null){
                        
                        //NONSTDVec with sub
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.nonFunded.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.nonFunded.NONSTDVec.sub!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.nonFunded.NONSTDVec.sub;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Non Funded';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='sub';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with loss
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.nonFunded.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.nonFunded.NONSTDVec.loss!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.nonFunded.NONSTDVec.loss;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Non Funded';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='loss';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with DPD91To180
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.nonFunded.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.nonFunded.NONSTDVec.DPD91To180!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.nonFunded.NONSTDVec.DPD91To180;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Non Funded';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='DPD91To180';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with dbt
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.nonFunded.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.nonFunded.NONSTDVec.dbt!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.nonFunded.NONSTDVec.dbt;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Non Funded';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='dbt';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD0
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.nonFunded.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.nonFunded.STDVec.DPD0!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.nonFunded.STDVec.DPD0;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Non Funded';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD0';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD1To30
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.nonFunded.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.nonFunded.STDVec.DPD1To30!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.nonFunded.STDVec.DPD1To30;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Non Funded';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD1To30';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD31To60
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.nonFunded.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.nonFunded.STDVec.DPD31To60!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.nonFunded.STDVec.DPD31To60;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Non Funded';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD31To60';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD61To90
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.nonFunded.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.nonFunded.STDVec.DPD61To90!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.nonFunded.STDVec.DPD61To90;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Your Institution';
                               osb.OutstandBalCat__c='Non Funded';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD61To90';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        //nonFunded with total
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.nonFunded.total!=null){
                            CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                            
                            CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.yourInstitution.nonFunded.total;
                            
                            osb.BureauResponse__c=refIdset!=null?refIdset:'';
                            osb.Outstanding_Balance_Entity__c='Your Institution';
                            osb.OutstandBalCat__c='Non Funded';
                            osb.OutstandiBalVecType__c='STD Vec';
                            osb.BalanceType__c='DPD0';
                            
                            if(!String.isBlank(val.count)){
                                osb.OutstandingCount__c=val.count;
                            }
                            if(!String.isBlank(val.value)){
                                osb.OutstandingValue__c=val.value;
                            }
                            insertOutstandingBalance.add(osb);
                        }
                    }
                }
                
                //outsideInstitution
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution!=null){
                    //total 
                    if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.total!=null ){
                        //NONSTDVec with sub
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.total.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.total.NONSTDVec.sub!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.total.NONSTDVec.sub;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Total';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='sub';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with loss
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.total.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.total.NONSTDVec.loss!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.total.NONSTDVec.loss;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Total';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='loss';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with DPD91To180
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.total.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.total.NONSTDVec.DPD91To180!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.total.NONSTDVec.DPD91To180;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Total';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='DPD91To180';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with dbt
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.total.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.total.NONSTDVec.dbt!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.total.NONSTDVec.dbt;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Total';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='dbt';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD0
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.total.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.total.STDVec.DPD0!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.total.STDVec.DPD0;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Total';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD0';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD1To30
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.total.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.total.STDVec.DPD1To30!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.total.STDVec.DPD1To30;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Total';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD1To30';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD31To60
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.total.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.total.STDVec.DPD31To60!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.total.STDVec.DPD31To60;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Total';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD31To60';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD61To90
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.total.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.total.STDVec.DPD61To90!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.total.STDVec.DPD61To90;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Total';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD61To90';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        
                    }
                    
                    //termLoan
                    if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.termLoan!=null){
                        
                        //NONSTDVec with sub
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.termLoan.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.termLoan.NONSTDVec.sub!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.termLoan.NONSTDVec.sub;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Term Loan';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='sub';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with loss
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.termLoan.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.termLoan.NONSTDVec.loss!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.termLoan.NONSTDVec.loss;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Term Loan';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='loss';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with DPD91To180
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.termLoan.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.termLoan.NONSTDVec.DPD91To180!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.termLoan.NONSTDVec.DPD91To180;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Term Loan';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='DPD91To180';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with dbt
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.termLoan.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.termLoan.NONSTDVec.dbt!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.termLoan.NONSTDVec.dbt;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Term Loan';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='dbt';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD0
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.termLoan.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.termLoan.STDVec.DPD0!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.termLoan.STDVec.DPD0;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Term Loan';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD0';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD1To30
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.termLoan.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.termLoan.STDVec.DPD1To30!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.termLoan.STDVec.DPD1To30;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Term Loan';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD1To30';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD31To60
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.termLoan.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.termLoan.STDVec.DPD31To60!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.termLoan.STDVec.DPD31To60;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Term Loan';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD31To60';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD61To90
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.termLoan.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.termLoan.STDVec.DPD61To90!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.termLoan.STDVec.DPD61To90;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Term Loan';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD61To90';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        //termLoan with total
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.termLoan.total!=null){
                            CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                            
                            CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.termLoan.total;
                            
                            osb.BureauResponse__c=refIdset!=null?refIdset:'';
                            osb.Outstanding_Balance_Entity__c='Outside Institution';
                            osb.OutstandBalCat__c='Term Loan';
                            osb.OutstandiBalVecType__c='Total';
                            osb.BalanceType__c='';
                            
                            if(!String.isBlank(val.count)){
                                osb.OutstandingCount__c=val.count;
                            }
                            if(!String.isBlank(val.value)){
                                osb.OutstandingValue__c=val.value;
                            }
                            insertOutstandingBalance.add(osb);
                        }
                    }
                    
                    //workingCapital
                    if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.workingCapital!=null){
                        
                        //NONSTDVec with sub
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.workingCapital.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.workingCapital.NONSTDVec.sub!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.workingCapital.NONSTDVec.sub;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Working Capital';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='sub';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with loss
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.workingCapital.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.workingCapital.NONSTDVec.loss!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.workingCapital.NONSTDVec.loss;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Working Capital';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='loss';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with DPD91To180
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.workingCapital.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.workingCapital.NONSTDVec.DPD91To180!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.workingCapital.NONSTDVec.DPD91To180;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Working Capital';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='DPD91To180';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with dbt
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.workingCapital.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.workingCapital.NONSTDVec.dbt!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.workingCapital.NONSTDVec.dbt;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Working Capital';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='dbt';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD0
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.workingCapital.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.workingCapital.STDVec.DPD0!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.workingCapital.STDVec.DPD0;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Working Capital';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD0';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD1To30
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.workingCapital.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.workingCapital.STDVec.DPD1To30!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.workingCapital.STDVec.DPD1To30;
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Working Capital';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD1To30';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD31To60
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.workingCapital.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.workingCapital.STDVec.DPD31To60!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.workingCapital.STDVec.DPD31To60;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Working Capital';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD31To60';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD61To90
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.workingCapital.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.workingCapital.STDVec.DPD61To90!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.workingCapital.STDVec.DPD61To90;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Working Capital';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD61To90';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        //workingCapital with total
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.workingCapital.total!=null){
                            CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                            
                            CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.workingCapital.total;
                            
                            osb.BureauResponse__c=refIdset!=null?refIdset:'';
                            osb.Outstanding_Balance_Entity__c='Outside Institution';
                            osb.OutstandBalCat__c='Working Capital';
                            osb.OutstandiBalVecType__c='Total';
                            osb.BalanceType__c='';
                            
                            if(!String.isBlank(val.count)){
                                osb.OutstandingCount__c=val.count;
                            }
                            if(!String.isBlank(val.value)){
                                osb.OutstandingValue__c=val.value;
                            }
                            insertOutstandingBalance.add(osb);
                        }
                    }
                    
                    //forex
                    if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.forex!=null){
                        
                        //NONSTDVec with sub
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.forex.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.forex.NONSTDVec.sub!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.forex.NONSTDVec.sub;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Forex';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='sub';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with loss
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.forex.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.forex.NONSTDVec.loss!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.forex.NONSTDVec.loss;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Forex';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='loss';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with DPD91To180
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.forex.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.forex.NONSTDVec.DPD91To180!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.forex.NONSTDVec.DPD91To180;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Forex';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='DPD91To180';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with dbt
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.forex.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.forex.NONSTDVec.dbt!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.forex.NONSTDVec.dbt;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Forex';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='dbt';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD0
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.forex.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.forex.STDVec.DPD0!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.forex.STDVec.DPD0;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Forex';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD0';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD1To30
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.forex.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.forex.STDVec.DPD1To30!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.forex.STDVec.DPD1To30;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Forex';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD1To30';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD31To60
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.forex.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.forex.STDVec.DPD31To60!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.forex.STDVec.DPD31To60;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Forex';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD31To60';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD61To90
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.forex.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.forex.STDVec.DPD61To90!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.forex.STDVec.DPD61To90;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Forex';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD61To90';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        //workingCapital with total
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.forex.total!=null){
                            CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                            
                            CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.forex.total;
                            
                            osb.BureauResponse__c=refIdset!=null?refIdset:'';
                            osb.Outstanding_Balance_Entity__c='Outside Institution';
                            osb.OutstandBalCat__c='Forex';
                            osb.OutstandiBalVecType__c='Total';
                            osb.BalanceType__c='';
                            
                            if(!String.isBlank(val.count)){
                                osb.OutstandingCount__c=val.count;
                            }
                            if(!String.isBlank(val.value)){
                                osb.OutstandingValue__c=val.value;
                            }
                            insertOutstandingBalance.add(osb);
                        }
                    }
                    
                    //nonFunded
                    if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.nonFunded!=null){
                        
                        //NONSTDVec with sub
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.nonFunded.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.nonFunded.NONSTDVec.sub!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.nonFunded.NONSTDVec.sub;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Non Funded';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='sub';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with loss
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.nonFunded.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.nonFunded.NONSTDVec.loss!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.nonFunded.NONSTDVec.loss;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Non Funded';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='loss';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with DPD91To180
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.nonFunded.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.nonFunded.NONSTDVec.DPD91To180!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.nonFunded.NONSTDVec.DPD91To180;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Non Funded';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='DPD91To180';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //NONSTDVec with dbt
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.nonFunded.NONSTDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.nonFunded.NONSTDVec.dbt!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.nonFunded.NONSTDVec.dbt;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Non Funded';
                               osb.OutstandiBalVecType__c='NON STD Vec';
                               osb.BalanceType__c='dbt';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD0
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.nonFunded.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.nonFunded.STDVec.DPD0!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.nonFunded.STDVec.DPD0;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Non Funded';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD0';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD1To30
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.nonFunded.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.nonFunded.STDVec.DPD1To30!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.nonFunded.STDVec.DPD1To30;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Non Funded';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD1To30';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD31To60
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.nonFunded.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.nonFunded.STDVec.DPD31To60!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.nonFunded.STDVec.DPD31To60;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Non Funded';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD31To60';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        
                        //STDVec with DPD61To90
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.nonFunded.STDVec!=null &&
                           res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.nonFunded.STDVec.DPD61To90!=null){
                               CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                               
                               CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.nonFunded.STDVec.DPD61To90;
                               
                               osb.BureauResponse__c=refIdset!=null?refIdset:'';
                               osb.Outstanding_Balance_Entity__c='Outside Institution';
                               osb.OutstandBalCat__c='Non Funded';
                               osb.OutstandiBalVecType__c='STD Vec';
                               osb.BalanceType__c='DPD61To90';
                               
                               if(!String.isBlank(val.count)){
                                   osb.OutstandingCount__c=val.count;
                               }
                               if(!String.isBlank(val.value)){
                                   osb.OutstandingValue__c=val.value;
                               }
                               insertOutstandingBalance.add(osb);
                           }
                        //nonFunded with total
                        if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.nonFunded.total!=null){
                            CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                            
                            CommercialIssueResponseWrapper.Sub val=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.outsideInstitution.nonFunded.total;
                            
                            osb.BureauResponse__c=refIdset!=null?refIdset:'';
                            osb.Outstanding_Balance_Entity__c='Outside Institution';
                            osb.OutstandBalCat__c='Non Funded';
                            osb.OutstandiBalVecType__c='Total';
                            osb.BalanceType__c='';
                            
                            if(!String.isBlank(val.count)){
                                osb.OutstandingCount__c=val.count;
                            }
                            if(!String.isBlank(val.value)){
                                osb.OutstandingValue__c=val.value;
                            }
                            insertOutstandingBalance.add(osb);
                        }
                    }
                }
                //message
                if(res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.message!=null){
                    
                    CM_OutstandingBalanceByCFAsset__c osb =new CM_OutstandingBalanceByCFAsset__c();
                    
                    osb.BureauResponse__c=refIdset!=null?refIdset:'';
                    
                    osb.Message__c=res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.productSec.oustandingBalanceByCFAndAssetClasificationSec.message;
                    insertOutstandingBalance.add(osb);
                }
                
                if(insertOutstandingBalance!=null){
                    List<string> fieldNamesList = New List<string>{'BureauResponse__c','BalanceType__c','Message__c','OutstandBalCat__c',
                        'Outstanding_Balance_Entity__c','OutstandiBalVecType__c','OutstandingCount__c',
                        'OutstandingValue__c'};
                            String sObjectName = 'CM_OutstandingBalanceByCFAsset__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(insertOutstandingBalance);
                }
                uow.commitWork();
                 
            } catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'oustandingBalanceByCFAndAssetClasificationSec', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
            
        }
        
    }
    
    
    //**************************************************************************************************************************    
    public static Void BureauError(string jsonString,Id refId){
        
        try{
            if(jsonString!=null){
                
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Bureau__c.SObjectType });
                
                CommercialIssueResponseWrapper res = (CommercialIssueResponseWrapper) JSON.deserialize(jsonString.replace('JSON-RESPONSE-OBJECT','JSONRESPONSEOBJECT').replace('PDF REPORT','PDF_REPORT'), CommercialIssueResponseWrapper.class);
                
                
                List<Bureau__c> Bureau = [SELECT Id, Applicant__c,IsLatest__c,BureauAPI__c FROM Bureau__c WHERE Applicant__c =:refId AND IsLatest__c = true AND BureauAPI__c='Commercial'];
                
                List<Bureau__c> BureauList =new List<Bureau__c>();
                List<String> descriptions = new List<String>();
                
                for(CommercialIssueResponseWrapper.reportIssuesVec errormess:res.FINISHED[0].JSONRESPONSEOBJECT.responseReport.reportIssuesVec){
                    
                    String description = errormess.message;
                    descriptions.add(description);
                    
                }
                
                string errorDescriptions='';
                errorDescriptions = descriptions!=null?String.join(descriptions, ', '):'';
                
                if(errorDescriptions!=''){
                    
                    Bureau__c bur=new Bureau__c();
                    bur.Id=Bureau[0].Id;
                    bur.ErrorMess__c=errorDescriptions;
                    BureauList.add(bur);
                }
               
                if(BureauList!=null){
                    List<string> fieldNamesList = New List<string>{'Id','ErrorMess__c'};
                        String sObjectName = 'Bureau__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList); 
                    uow.registerDirty(BureauList);
                }
                uow.commitWork();
                
            }
        }
        catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'BureauError', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
    //**************************************************************************************************************************
    public static Void BureauReject(CommercialIssueResponseWrapper responseWrapper,Id refIdSet){
        
        try {
            if (responseWrapper != null) {
                
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Bureau__c.SObjectType });
                
                List<Bureau__c> Bureau = [SELECT Id, Applicant__c,IsLatest__c,BureauAPI__c FROM Bureau__c WHERE Applicant__c =:refIdSet AND IsLatest__c = true AND BureauAPI__c='Commercial'];
                
                List<Bureau__c> BureauList =new List<Bureau__c>();
                List<String> descriptions = new List<String>();
                
                if (responseWrapper.REJECT != null) {
                    for (CommercialIssueResponseWrapper.Reject reject : responseWrapper.REJECT) {
                        if (reject.ERRORS != null) {
                            for (CommercialIssueResponseWrapper.error errorDetail : reject.ERRORS) {
                                String description = errorDetail.DESCRIPTION;
                                descriptions.add(description);
                            }
                        }
                    }
                }
                String errorDescriptions = '';
                
                errorDescriptions = descriptions!=null?String.join(descriptions, ', '):'';
                if(errorDescriptions!=''){
                    Bureau__c bur=new Bureau__c();
                    bur.Id=Bureau[0].Id;
                    bur.ErrorMess__c=errorDescriptions;
                    BureauList.add(bur);
                }
                if(BureauList!=null){
                    List<string> fieldNamesList = New List<string>{'Id','ErrorMess__c'};
                        String sObjectName = 'Bureau__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList); 
                    uow.registerDirty(BureauList);
                }
                uow.commitWork();
                
            }
        } catch (Exception ex) {
           GlobalUtility.logMessage('Error', 'BureauReject', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
    }
    
    //**************************************************************************************************************************
    Public static Void BureauDLQUEUE(CommercialIssueResponseWrapper responseWrapper,Id refIdSet){
        
        try {
            if (responseWrapper != null) {
                
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Bureau__c.SObjectType });
                
                 List<Bureau__c> Bureau = [SELECT Id, Applicant__c,IsLatest__c,BureauAPI__c FROM Bureau__c WHERE Applicant__c =:refIdSet AND IsLatest__c = true AND BureauAPI__c='Commercial'];
                
                List<Bureau__c> BureauList =new List<Bureau__c>();
                
                List<String> status = new List<String>();
                
                if (responseWrapper.REJECT != null) {
                    
                    for(CommercialIssueResponseWrapper.REJECT rej:responseWrapper.REJECT){
                        String statusdescription = rej.STATUS;
                        status.add(statusdescription);
                        
                    }
                    
                }
                
                String DLstatus=status!=null?String.join(status,','):'';
                
                if(String.isNotBlank(DLstatus)){
                    Bureau__c bur=new Bureau__c();
                    bur.Id=Bureau[0].Id;
                    bur.ErrorMess__c=DLstatus;
                    BureauList.add(bur);
                }
                
                
                if(BureauList!=null){
                    List<string> fieldNamesList = New List<string>{'Id','ErrorMess__c'};
                        String sObjectName = 'Bureau__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList); 
                    uow.registerDirty(BureauList);
                }
                uow.commitWork();
                
            }
        } catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'BureauDLQUEUE', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
    }
    //********************************************************************************************************************************* 
    public static Date convertToDate(String dateString) {
        Map<String, String> monthMap = new Map<String, String>{
            'JAN' => '01', 'FEB' => '02', 'MAR' => '03',
                'APR' => '04', 'MAY' => '05', 'JUN' => '06',
                'JUL' => '07', 'AUG' => '08', 'SEP' => '09',
                'OCT' => '10', 'NOV' => '11', 'DEC' => '12'
                };
                    
                    List<String> dateParts = dateString.split('-');
        
        if (dateParts.size() == 3) {
            String year = dateParts[2];
            String month = monthMap.get(dateParts[1].toUpperCase());
            String day = dateParts[0];
            
            String salesforceDateFormat = year + '-' + month + '-' + day;
            
            return Date.valueOf(salesforceDateFormat);
        }
        
        return null; 
    }
}