public class UcidRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){  
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType });
        
        //Creating a Set of ids
        Set<Id> intMsgIds = new Set<Id>();
        Set<Id> ids = new Set<Id>();
        List<String> addressType=New List<String>{'Residence Address','Principal place for business','Residence Cum office'};
            
            //Iterating over new Intgeration Message record ids to add them into the above Set
            for(IntgMsg__c intMsg : msgs){ 
                ids.add(intMsg.RefId__c);
                intMsgIds.add(intMsg.ParentRefId__c);
                
            }
        
        //Fetching required fields to create Request Payload
        Map<Id,IntgMsg__c> intMsgMap = new Map<Id,IntgMsg__c>([Select Id,Resp__c FROM IntgMsg__c WHERE Id IN:intMsgIds]);
        Map<Id,Applicant__c> applMap = new Map<Id,Applicant__c>([select id,Name,Gender__c,DOB__c,EmailId__c,FName__c,MName__c,LName__c,
                                                                 MobNumber__c,Father_Name__c,LoanAppln__c,Constitution__c,CompanyName__c,MariStatus__c,
                                                                 CKYC_Number__c,MthrMdnName__c,UCID__c,SpName__c,LoanAppln__r.FinnoneAppid__c
                                                                 from Applicant__c where Id=:ids]);
        
        Map<Id,Map<String,ApplAddr__c>> ApplAddrMap=new Map<Id,Map<String,ApplAddr__c>>();
        for(ApplAddr__c addr:[Select Id,Applicant__c,AddrTyp__c,HouseNo__c,AddrLine1__c,AddrLine2__c,City__c,
                              State__c,Pincode__c from ApplAddr__c Where Applicant__c IN:ids AND AddrTyp__c IN:addressType]){
                                  
                                  if (!ApplAddrMap.containsKey(addr.Applicant__c)) {
                                      ApplAddrMap.put(addr.Applicant__c, new Map<String, ApplAddr__c>{addr.AddrTyp__c=>addr});
                                  }
                                  else
                                  {
                                      ApplAddrMap.get(addr.Applicant__c).put(addr.AddrTyp__c, addr);
                                  }
                                  
                                  
                              }
        
        
        try{
            //If the List of new Integration Message records is not empty, then iterating over and assigning data to variables from Wrapper Class
            List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>(); 
            
            if(!msgs.isEmpty()){
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('UCIC');
                for(IntgMsg__c intMsg : msgs){
                    System.debug('**intMsg.RefId__c=>'+intMsg.RefId__c+'**intMsg.ParentRefId__c**'+intMsg.ParentRefId__c+'************');
                    if(applMap.containsKey(intMsg.RefId__c) && intMsgMap.containskey(intMsg.ParentRefId__c)){
                        Applicant__c appl = applMap.get(intMsg.RefId__c);
                        Map<String,String> kycMap = getKYCDocIds(appl.Id);
                        
                        UcidRequestWrapper ucidRequestDetails = new UcidRequestWrapper();
                        ucidRequestDetails.aadharNumber = kycMap.containsKey('Aadhaar')? kycMap.get('Aadhaar'):'';
                        ucidRequestDetails.passportno = kycMap.containsKey('Passport')? kycMap.get('Passport'):'';
                        ucidRequestDetails.ckycid = String.isNotBlank(appl.CKYC_Number__c ) ? appl.CKYC_Number__c: '';
                        ucidRequestDetails.gender = String.isNotBlank(appl.Gender__c) ? appl.Gender__c:'';
                        ucidRequestDetails.panno = kycMap.containsKey('Pan')? kycMap.get('Pan'):'';
                        ucidRequestDetails.emailId = String.isNotBlank(appl.EmailId__c) ? appl.EmailId__c :'';
                        ucidRequestDetails.mothermiddlename = '';
                        ucidRequestDetails.motherlastname = '';
                        ucidRequestDetails.customerMiddleName = String.isNotBlank(appl.MName__c) ? appl.MName__c : '';
                        ucidRequestDetails.motherfirstname = String.isNotBlank(appl.MthrMdnName__c) ?appl.MthrMdnName__c:'';
                        ucidRequestDetails.customerLastName = String.isNotBlank(appl.LName__c) ? appl.LName__c : '';
                        
                        ucidRequestDetails.dateofbirth = appl.DOB__c!= null ? String.valueOf(DateTime.newInstance(appl.DOB__c.year(), appl.DOB__c.month(), appl.DOB__c.day()).format('dd-MM-yyyy')) : '';
                        
                        
                        if (ApplAddrMap.containsKey(appl.Id)) {
                            
                            if(appl.Constitution__c =='INDIVIDUAL' && ApplAddrMap.get(appl.Id).containsKey('Residence Address')){
                                ApplAddr__c Addr=ApplAddrMap.get(appl.Id).get('Residence Address');
                                
                                ucidRequestDetails.address1 =String.isNotBlank(getAddressAsString(Addr))?getAddressAsString(Addr):'';
                                ucidRequestDetails.city =String.isNotBlank(Addr.City__c)?Addr.City__c:'';
                                ucidRequestDetails.pincode = String.isNotBlank(Addr.Pincode__c)?Addr.Pincode__c:'';
                            }
                            else if(appl.Constitution__c =='INDIVIDUAL' && ApplAddrMap.get(appl.Id).containsKey('Residence Cum office')){
                                ApplAddr__c Addr=ApplAddrMap.get(appl.Id).get('Residence Cum office');
                                
                                ucidRequestDetails.address1 =String.isNotBlank(getAddressAsString(Addr))?getAddressAsString(Addr):'';
                                ucidRequestDetails.city =String.isNotBlank(Addr.City__c)?Addr.City__c:'';
                                ucidRequestDetails.pincode = String.isNotBlank(Addr.Pincode__c)?Addr.Pincode__c:'';
                            }
                            else if(appl.Constitution__c !='INDIVIDUAL' && ApplAddrMap.get(appl.Id).containsKey('Principal place for business')){
                                ApplAddr__c Addr=ApplAddrMap.get(appl.Id).get('Principal place for business');
                                
                                ucidRequestDetails.address1 =String.isNotBlank(getAddressAsString(Addr))?getAddressAsString(Addr):'';
                                ucidRequestDetails.city =String.isNotBlank(Addr.City__c)?Addr.City__c:'';
                                ucidRequestDetails.pincode = String.isNotBlank(Addr.Pincode__c)?Addr.Pincode__c:'';
                            }
                        }
                        
                        else{
                            ucidRequestDetails.address1 ='';
                            ucidRequestDetails.city ='';
                            ucidRequestDetails.pincode = '';
                        }
                        //ucidRequestDetails.address1 = '';
                        ucidRequestDetails.primarymobileno = String.isNotBlank(appl.MobNumber__c) ?appl.MobNumber__c :'';
                        ucidRequestDetails.drivinglicenseid = kycMap.containsKey('Driving License')? kycMap.get('Driving License'):'';
                        ucidRequestDetails.husbandorfathermiddlename = '';
                        ucidRequestDetails.husbandorfatherlastname = '';
                        ucidRequestDetails.voteridno = kycMap.containsKey('Voter Id')? kycMap.get('Voter Id'):'';
                        ucidRequestDetails.customerFirstName = appl.Constitution__c=='INDIVIDUAL' ? appl.FName__c: appl.CompanyName__c;
                        ucidRequestDetails.appid = String.isNotBlank(appl.LoanAppln__r.FinnoneAppid__c)?appl.LoanAppln__r.FinnoneAppid__c:'';
                        ucidRequestDetails.husbandorfatherfirstname = appl.MariStatus__c=='S'?String.isNotBlank(appl.Father_Name__c)?appl.Father_Name__c:'':String.isNotBlank(appl.SpName__c)?appl.SpName__c:'';
                        ucidRequestDetails.customerid = String.isNotBlank(appl.UCID__c)?appl.UCID__c:'';
                        ucidRequestDetails.secondarymobileno = '';
                        //ucidRequestDetails.city = '';
                        ucidRequestDetails.uniqueRefNumber = GlobalUtility.getUniqueNumber();
                        ucidRequestDetails.source = svc.SourceSystem__c;
                        // ucidRequestDetails.constitution = String.isNotBlank(appl.Constitution__c) ? appl.Constitution__c : '';
                        
                        IntgMsg__c intg=New IntgMsg__c();
                        intg.id=intMsg.id;
                        intg.Req__c = JSON.serialize(ucidRequestDetails); 
                        intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntRecords.add(intg);
                        
                    }
                    else {
                        throw new UcidRequestException('Invalid References Ids');
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
            GlobalUtility.logMessage('Error', 'UcidRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
        
    }
    
    public class UcidRequestException extends Exception {
        
    }
    
    public static Map<String,String> getKYCDocIds(String applicantId){
        
        Map<String,String> kycMap = new Map<String,String>();
        for(ApplKyc__c applkyc : [Select Id, Pan__c, AadharNo__c, VotIdEpicNo__c, DLNo__c, PassNo__c,Applicant__c, kycDoc__c, OCRStatus__c, ValidationStatus__c FROM ApplKyc__c Where Applicant__c =:applicantId]){
            if(applkyc.kycDoc__c=='Aadhaar' && String.isNOTBlank(applkyc.AadharNo__c)){
                kycMap.put('Aadhaar',applkyc.AadharNo__c);
            }
            if(applkyc.kycDoc__c=='Voter Id' && String.isNOTBlank(applkyc.VotIdEpicNo__c)){
                kycMap.put('Voter Id',applkyc.VotIdEpicNo__c);
            }
            if(applkyc.kycDoc__c=='Passport' && String.isNOTBlank(applkyc.PassNo__c)){
                kycMap.put('Passport',applkyc.PassNo__c);
            }
            if(applkyc.kycDoc__c=='Driving License' && String.isNOTBlank(applkyc.DLNo__c)){
                kycMap.put('Driving License',applkyc.DLNo__c);
            }
            if(applkyc.kycDoc__c=='Pan' && String.isNOTBlank(applkyc.Pan__c)){
                kycMap.put('Pan',applkyc.Pan__c);
            }
        }
        return kycMap;
    }
    
    
    public String getAddressAsString(ApplAddr__c Address) {
        String addressString = '';
        
        if (Address != null) {
            addressString = (String.isNotBlank(address.HouseNo__c) ? address.HouseNo__c + ' ' : '') +
                (String.isNotBlank(address.AddrLine1__c) ? address.AddrLine1__c + ' ' : '') +
                (String.isNotBlank(address.AddrLine2__c) ? address.AddrLine2__c + ' ' : '') +
                (String.isNotBlank(address.City__c) ? address.City__c + ' ' : '') +
                (String.isNotBlank(address.State__c) ? address.State__c + ' ' : '') +
                (String.isNotBlank(address.Pincode__c) ? address.Pincode__c : '');
        }
        
        return addressString;
    }    
    
}