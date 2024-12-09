public class ScreeningRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){  
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { IntgMsg__c.SObjectType });
        Set<Id> appIds = new Set<Id>();
        Set<Id> loanApplnIds = new Set<Id>();
        Map<Id,List<Applicant__c>> loanAppMap = new Map<Id,List<Applicant__c>>();
        
        IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Screening_API');
        //Iterating over new Intgeration Message record ids to add them into the above Set
        for(IntgMsg__c intMsg : msgs){ 
            loanApplnIds.add(intMsg.ParentRefId__c);
            if(String.isNotBlank(intMsg.RefId__c)){
                List<Id> ids = intMsg.RefId__c.split(',');
                appIds.addAll(ids);
            }
            
        }
        //Fetching required fields to create Request Payload
        if(!appIds.isEmpty()){
            for(Applicant__c app : [SELECT Id,Name,LoanAppln__c,LoanAppln__r.Name, LoanAppln__r.BrchName__c,FName__c,MName__c,LName__c,CompanyName__c,Constitution__c,Gender__c,DOB__c  FROM Applicant__c Where Id IN:appIds AND ApplType__c IN ('P','C','G')]){
                if(loanAppMap.containsKey(app.LoanAppln__c)){
                    loanAppMap.get(app.LoanAppln__c).add(app);
                }
                else{
                    loanAppMap.put(app.LoanAppln__c,new List<Applicant__c>{app});
                }
            }
        }
        
        if(appIds.isEmpty() && !loanApplnIds.isEmpty()){
            for(LoanAppl__c app : [SELECT ID, (SELECT Id,Name,LoanAppln__r.Name, LoanAppln__r.BrchName__c,FName__c,MName__c,LName__c,CompanyName__c,Constitution__c,Gender__c,DOB__c  FROM Applicants__r WHERE ApplType__c IN ('P','C','G')) FROM LoanAppl__c WHERE Id IN:loanApplnIds]){
                loanAppMap.put(app.Id,app.Applicants__r);
            }
        }
        
        try{
            //If the List of new Integration Message records is not empty, then iterating over and assigning data to variables from Wrapper Class
            
            List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>(); 
            
            if(!msgs.isEmpty()){
                 
                for(IntgMsg__c intMsg : msgs){
                    if(loanAppMap.containsKey(intMsg.ParentRefId__c)){
                        
                        List<Applicant__c> applicantList =loanAppMap.get(intMsg.ParentRefId__c);
                        List<ScreeningRequestWrapper.Record> recordList = new List<ScreeningRequestWrapper.Record>();
                        
                        if(!applicantList.isEmpty()){
                            
                            for(Applicant__c app : applicantList){
                                ScreeningRequestWrapper.Record record = new ScreeningRequestWrapper.Record();
                                record.RequestId=Integer.ValueOf(GlobalUtility.getUniqueNumber());
                                record.RecordIdentifier = app.Name;
                                record.ApplicationFormNumber = app.LoanAppln__r.Name;
                                record.BranchName = app.LoanAppln__r.BrchName__c;
                                record.RegionId = '';
                                record.SystemName = 'Finnone';
                                record.ParentCompany = 'Fedbank';//'Fedfina';
                                record.FirstName = app.Constitution__c=='INDIVIDUAL' ? app.FName__c : app.CompanyName__c;
                                record.MiddleName = app.Constitution__c=='INDIVIDUAL' ? app.MName__c : '';
                                record.LastName = app.Constitution__c=='INDIVIDUAL' ? app.LName__c : '';
                                record.CustomerCategory = app.Constitution__c=='INDIVIDUAL' ? 'IND' : 'NON IND';
                                record.Gender = app.Gender__c;
                                record.Pan = '';
                                record.Din = '';
                                record.Cin = '';
                                record.DateOfBirth = app.DOB__c != null ? String.valueOf(DateTime.newInstance(app.DOB__c.year(), app.DOB__c.month(), app.DOB__c.day()).format('dd-MMM-yyyy')) : '';       
                                record.PlaceOfBirth = '';
                                record.CountryOfBirth = '';
                                record.Nationality = GlobalConstants.Nationality;
                                //Citizenships.Citizenship;
                                record.Passport = '';
                                record.DrivingLicenceNumber = '';
                                record.CorrespondenceAddress1 = '';
                                record.CorrespondenceAddress2 = '';
                                record.CorrespondenceAddress3 = '';
                                record.CorrespondenceAddressCity = '';
                                record.CorrespondenceAddressState = '';
                                record.CorrespondenceAddressCountry = '';
                                record.CorrespondenceAddressPin = null;
                                record.PermanentAddress1 = '';
                                record.PermanentAddress2 = '';
                                record.PermanentAddress3 = '';
                                record.PermanentAddressCity = '';
                                record.PermanentAddressState = '';
                                record.PermanentAddressCountry = '';
                                //record.PermanentAddressPin = null;
                                record.PEP = '';
                                record.Occupation = '';
                                //RMDetails.RMDetail.UserCode
                                //RMDetails.RMDetail.Type
                                //RMDetails.RMDetail.FromDate
                                record.CreateAlert = 'Yes'; 
                                record.ScreeningCategory = GlobalConstants.ScreeningCategory;
                                recordList.add(record);
                                system.debug('recordList'+recordList);
                            }
                            
                            
                        }
                        
                        
                        ScreeningRequestWrapper requestDetails = new ScreeningRequestWrapper();
                        ScreeningRequestWrapper.ScreeningRequestData requestData = new ScreeningRequestWrapper.ScreeningRequestData();
                        requestData.ApiToken=svc.APIToken__c;
                        
                        ScreeningRequestWrapper.Records records = new ScreeningRequestWrapper.Records();
                        records.Record =recordList;
                        requestData.Records = records;
                       
                        requestDetails.ScreeningRequestData =  requestData;                       
                        
                        
                        IntgMsg__c intg=New IntgMsg__c();
                        intg.id=intMsg.id;
                        intg.Req__c = JSON.serialize(requestDetails); 
                        intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntRecords.add(intg);
                    }
                }
                if(!updateIntRecords.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntRecords);
                }
            }
            
            uow.commitWork();
        }
        
        //Catch bloack to catch Exceptions occured during generation of payload and displaying the passing the same in GlobalUtility class
        catch(Exception ex){
            System.debug('error'+ex.getMessage());
            GlobalUtility.logMessage('Error', 'ScreeningRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    }    
    
}