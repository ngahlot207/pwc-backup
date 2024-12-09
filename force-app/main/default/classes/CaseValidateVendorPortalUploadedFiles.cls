public class CaseValidateVendorPortalUploadedFiles implements TriggerAction.BeforeUpdate{
    
    public static void beforeUpdate(List<Case> newList, List<Case> oldList){
        system.debug('validation new List List :'+newList);
        Map<Id,Case> mapOfOldCaseRecord = new Map<Id,Case>(oldList);
        Profile pfile = [Select Name from Profile where Id =: userinfo.getProfileid()];
        system.debug('Profile name:'+pfile.Name);
        Map<Id,RecordType> mapOfRecordTypeId = new Map<Id,RecordType>();
        List<RecordType> recordTypeId = [SELECT Name, DeveloperName, Id FROM RecordType];
        for(RecordType objrecordType : [SELECT Name, DeveloperName, Id FROM RecordType]){
            mapOfRecordTypeId.put(objrecordType.Id,objrecordType);    
        }
        
        system.debug('mapOfRecordTypeId:'+mapOfRecordTypeId);
        
        for(Case objCase : newList){
            If(objCase.ReportResult__c != null &&  pfile.Name == 'Agency Profile' && mapOfOldCaseRecord.get(objCase.Id).Status != objCase.Status){
                if(mapOfRecordTypeId.get(objCase.RecordTypeId).DeveloperName == 'CPVFI' || mapOfRecordTypeId.get(objCase.RecordTypeId).DeveloperName == 'Technical' || mapOfRecordTypeId.get(objCase.RecordTypeId).DeveloperName == 'LIP_Vendor_case'){
                    if(mapOfRecordTypeId.get(objCase.RecordTypeId).DeveloperName == 'Technical' || mapOfRecordTypeId.get(objCase.RecordTypeId).DeveloperName == 'LIP_Vendor_case'){
                        if((objCase.ReportCount__c == null || objCase.ReportCount__c < 1  )  && (objCase.PhotoCount__c == null || objCase.PhotoCount__c < 1  )  ){
                            objCase.addError('Please Upload the Report and Photos'); 
                        }else if(objCase.ReportCount__c == null || objCase.ReportCount__c < 1){
                            objCase.addError('Please Upload the Report'); 
                        }else if(objCase.PhotoCount__c == null || objCase.PhotoCount__c < 1){
                            objCase.addError('Please Upload the Photo'); 
                        }else if(mapOfRecordTypeId.get(objCase.RecordTypeId).DeveloperName == 'Technical' && objCase.PhotoCount__c <= 5){
                            system.debug('CPV Error');
                            objCase.addError('Please Upload minimum 6 photos');
                        }else if(mapOfRecordTypeId.get(objCase.RecordTypeId).DeveloperName == 'LIP_Vendor_case' && objCase.PhotoCount__c <= 3){
                            system.debug('Technical Error');
                            objCase.addError('Please Upload minimum 4 photos');             
                        }
                    }
                    else if(mapOfRecordTypeId.get(objCase.RecordTypeId).DeveloperName == 'CPVFI'){
                        if(!(objCase.ReportResult__c == 'Negative' && objCase.Negative_Report_reason__c == 'Difficult to trace the address')){
                            if((objCase.ReportCount__c == null || objCase.ReportCount__c < 1  )  && (objCase.PhotoCount__c == null || objCase.PhotoCount__c < 1  )){
                                system.debug('CPVFI #27 Error');
                                objCase.addError('Please Upload the Report and Photos');
                            }else if(objCase.ReportCount__c == null || objCase.ReportCount__c < 1){
                                objCase.addError('Please Upload the Report'); 
                            }else if(objCase.PhotoCount__c == null || objCase.PhotoCount__c < 1){
                                objCase.addError('Please Upload the Photo'); 
                            }else if(objCase.ReportCount__c == null || objCase.ReportCount__c < 1){
                                objCase.addError('Please Upload the Report'); 
                            }else if(objCase.PhotoCount__c == null || objCase.PhotoCount__c < 1){
                                objCase.addError('Please Upload the Photo'); 
                            }else if((objCase.Product_Type__c == 'Home Loan' || objCase.Product_Type__c =='Small Ticket LAP') && objCase.PhotoCount__c <= 3){
                                system.debug('Technical Error');
                                objCase.addError('Please Upload minimum 4 photos');   
                                
                            }else if((objCase.Product_Type__c == 'Business Loan' || objCase.Product_Type__c =='Personal Loan') && objCase.PhotoCount__c <= 1){
                                system.debug('Technical Error');
                                objCase.addError('Please Upload minimum 2 photos');
                            }
                            
                            
                        }else{
                            if((objCase.ReportCount__c == null || objCase.ReportCount__c < 1  )){
                                system.debug('CPVFI #33 Error');
                                objCase.addError('Please Upload the Report');
                            }
                        }
                    }
                    /*    else if(mapOfRecordTypeId.get(objCase.RecordTypeId).DeveloperName == 'CPVFI'){
if((objCase.Product_Type__c == 'Home Loan' || objCase.Product_Type__c =='Small Ticket LAP') && objCase.PhotoCount__c <= 3){
system.debug('Technical Error');
objCase.addError('Please Upload minimum 4 photos');   

}else if((objCase.Product_Type__c == 'Business Loan' || objCase.Product_Type__c =='Personal Loan') && objCase.PhotoCount__c <= 1){
if(!(objCase.ReportResult__c == 'Negative' && objCase.Negative_Report_reason__c == 'Difficult to trace the address')){
system.debug('Technical Error');
objCase.addError('Please Upload minimum 2 photos');
}

}
}*/
                    
                    
                }
                if(mapOfRecordTypeId.get(objCase.RecordTypeId).DeveloperName == 'TSR' || mapOfRecordTypeId.get(objCase.RecordTypeId).DeveloperName == 'Vetting'|| mapOfRecordTypeId.get(objCase.RecordTypeId).DeveloperName == 'Legal'){
                    if(objCase.ReportCount__c == null || objCase.ReportCount__c < 1 ){
                        objCase.addError('Please Upload the Report'); 
                    }
                }
                
            }
            If(pfile.Name == 'Agency Profile' && mapOfOldCaseRecord.get(objCase.Id).Status != objCase.Status){
                if(mapOfRecordTypeId.get(objCase.RecordTypeId).DeveloperName == 'RCU' && objCase.AccountId != null && objCase.ContactId != null){
                    if(objCase.ReportCount__c == null || objCase.ReportCount__c < 1 ){
                        objCase.addError('Please Upload the Report'); 
                    }
                    if(objCase.AgcRCUReportStatus__c == null ){
                        objCase.addError('Please Update the Document Status'); 
                    }
                }
            }
        }
    }
}