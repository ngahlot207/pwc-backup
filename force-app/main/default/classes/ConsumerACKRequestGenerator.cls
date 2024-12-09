public class ConsumerACKRequestGenerator implements ICalloutRequestGenerator {
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
        List<String> addressTypes = new List<String>{'Residence Address','Residence Cum office'};
            try{
               
                List<IntgMsg__c> updateIntMsgRecords = new List<IntgMsg__c>();
                
                Set<Id> refIds = new Set<Id>();
                
                // Extract all RefIds
                for (IntgMsg__c intMsg : msgs) {
                    refIds.add(intMsg.RefId__c);
                }
                
                Map<Id, Applicant__c> applicantMap = new Map<Id, Applicant__c>();
                Set<Id> loanIds = new Set<Id>();
                
                for(Applicant__c applist:[select id,Name,Gender__c,DOB__c,FName__c,MName__c,LName__c,MobNumber__c,LoanAppln__c,FullName__c	 from Applicant__c where Id IN:refIds]){
                    applicantMap.put(applist.id,applist);
                    loanIds.add(applist.LoanAppln__c);
                }
                
                
                Map<Id, LoanAppl__c> loanMap = new Map<Id, LoanAppl__c>();
                for(LoanAppl__c loanlist:[Select id,Name,Product__c,ReqLoanAmt__c from LoanAppl__c WHERE id IN:loanIds]){
                    loanMap.put(loanlist.id,loanlist);
                }
                
                Map<Id, ApplAddr__c> addrMap = new Map<Id, ApplAddr__c>();
                
                
                for(ApplAddr__c addr:[select id,Applicant__c,AddrTyp__c,HouseNo__c,AddrLine1__c,AddrLine2__c,City__c,Pincode__c,State__c from ApplAddr__c where Applicant__c IN:refIds AND AddrTyp__c IN:addressTypes]){
                    if(!addrMap.containsKey(addr.Applicant__c)){
                        addrMap.put(addr.Applicant__c,addr);
                    }
                    else{
                        if(addr.AddrTyp__c == 'Residence Address' && addrMap.get(addr.Applicant__c).AddrTyp__c !='Residence Address'){
                            addrMap.put(addr.Applicant__c,addr);
                        }
                    }
                }
                
                
                Map<Id, ApplKyc__c> appKycMap = new Map<Id, ApplKyc__c>();
                
                Map<Id,Map<String,String>> applKycMap = new Map<Id,Map<String,String>>();
                for(ApplKyc__c applkyc:[select id,Applicant__c,kycDoc__c,Pan__c,Name__c,VotIdEpicNo__c,PassNo__c,DLNo__c,DtOfIssue__c,PassIssueDt__c,PassExpDt__c,DLIssueDt__c,DLExpDt__c from ApplKyc__c where Applicant__c IN:refIds AND kycDoc__c !=null]){
                    
                    
                    if(!applKycMap.containsKey(applkyc.Applicant__c)){
                        if (applkyc.kycDoc__c == 'Pan' && String.isNOTBlank(applkyc.Pan__c)) {
                            Map<String,String> dataMap = new Map<String,String>();
                            dataMap.put('01',applkyc.Pan__c);
                            if(applkyc.DtOfIssue__c!=null){
                                dataMap.put('02',String.valueOf(DateTime.newInstance(applkyc.DtOfIssue__c.year(), applkyc.DtOfIssue__c.month(), applkyc.DtOfIssue__c.day()).format('ddMMyyyy')));
                            }
                            applKycMap.put(applkyc.Applicant__c,dataMap);
                            
                        }
                        else if (applkyc.kycDoc__c == 'Passport' && String.isNOTBlank(applkyc.PassNo__c)) {
                            Map<String,String> dataMap = new Map<String,String>();
                            dataMap.put('04',applkyc.PassNo__c);
                            if(applkyc.PassIssueDt__c!=null){
                                dataMap.put('05',String.valueOf(DateTime.newInstance(applkyc.PassIssueDt__c.year(), applkyc.PassIssueDt__c.month(), applkyc.PassIssueDt__c.day()).format('ddMMyyyy')));
                            }
                            if(applkyc.PassExpDt__c!=null){
                                dataMap.put('06',String.valueOf(DateTime.newInstance(applkyc.PassExpDt__c.year(), applkyc.PassExpDt__c.month(), applkyc.PassExpDt__c.day()).format('ddMMyyyy')));
                            }
                            applKycMap.put(applkyc.Applicant__c,dataMap);
                        }
                        else if (applkyc.kycDoc__c == 'Voter Id' && String.isNOTBlank(applkyc.VotIdEpicNo__c)) {
                            applKycMap.put(applkyc.Applicant__c,new Map<String,String>{'07'=>applkyc.VotIdEpicNo__c});
                        }
                        else if (applkyc.kycDoc__c == 'Driving License' && String.isNOTBlank(applkyc.DLNo__c)) {
                            Map<String,String> dataMap = new Map<String,String>();
                            dataMap.put('10',applkyc.DLNo__c);
                            if(applkyc.DLIssueDt__c!=null){
                                dataMap.put('11',String.valueOf(DateTime.newInstance(applkyc.DLIssueDt__c.year(), applkyc.DLIssueDt__c.month(), applkyc.DLIssueDt__c.day()).format('ddMMyyyy')));
                            }
                            if(applkyc.DLExpDt__c!=null){
                                dataMap.put('12',String.valueOf(DateTime.newInstance(applkyc.DLExpDt__c.year(), applkyc.DLExpDt__c.month(), applkyc.DLExpDt__c.day()).format('ddMMyyyy')));
                            }
                            applKycMap.put(applkyc.Applicant__c,dataMap);
                            
                        }
                        
                    }
                    else{
                        if (applkyc.kycDoc__c == 'Pan' && String.isNOTBlank(applkyc.Pan__c)) {
                            if(!applKycMap.get(applkyc.Applicant__c).containsKey('01')){
                                
                                applKycMap.get(applkyc.Applicant__c).put('01',applkyc.Pan__c);
                                if(applkyc.DtOfIssue__c!=null){
                                    applKycMap.get(applkyc.Applicant__c).put('02',String.valueOf(DateTime.newInstance(applkyc.DtOfIssue__c.year(), applkyc.DtOfIssue__c.month(), applkyc.DtOfIssue__c.day()).format('ddMMyyyy')));
                                }
                            }
                        }
                        else if (applkyc.kycDoc__c == 'Passport' && String.isNOTBlank(applkyc.PassNo__c)) {
                            if(!applKycMap.get(applkyc.Applicant__c).containsKey('04')){
                                applKycMap.get(applkyc.Applicant__c).put('04',applkyc.PassNo__c);
                                if(applkyc.PassIssueDt__c!=null){
                                    applKycMap.get(applkyc.Applicant__c).put('05',String.valueOf(DateTime.newInstance(applkyc.PassIssueDt__c.year(), applkyc.PassIssueDt__c.month(), applkyc.PassIssueDt__c.day()).format('ddMMyyyy')));
                                }
                                if(applkyc.PassExpDt__c!=null){
                                    applKycMap.get(applkyc.Applicant__c).put('06',String.valueOf(DateTime.newInstance(applkyc.PassExpDt__c.year(), applkyc.PassExpDt__c.month(), applkyc.PassExpDt__c.day()).format('ddMMyyyy')));
                                }
                            }
                        }
                        else if (applkyc.kycDoc__c == 'Voter Id' && String.isNOTBlank(applkyc.VotIdEpicNo__c)) {
                            if(!applKycMap.get(applkyc.Applicant__c).containsKey('07')){
                                applKycMap.get(applkyc.Applicant__c).put('07',applkyc.VotIdEpicNo__c);
                            }
                        }
                        else if (applkyc.kycDoc__c == 'Driving License' && String.isNOTBlank(applkyc.DLNo__c)) {
                            if(!applKycMap.get(applkyc.Applicant__c).containsKey('10')){
                                applKycMap.get(applkyc.Applicant__c).put('10',applkyc.DLNo__c);
                                if(applkyc.DLIssueDt__c!=null){
                                    applKycMap.get(applkyc.Applicant__c).put('11',String.valueOf(DateTime.newInstance(applkyc.DLIssueDt__c.year(), applkyc.DLIssueDt__c.month(), applkyc.DLIssueDt__c.day()).format('ddMMyyyy')));
                                }
                                if(applkyc.DLExpDt__c!=null){
                                    applKycMap.get(applkyc.Applicant__c).put('12',String.valueOf(DateTime.newInstance(applkyc.DLExpDt__c.year(), applkyc.DLExpDt__c.month(), applkyc.DLExpDt__c.day()).format('ddMMyyyy')));
                                }
                            }
                        }
                        
                    }
                    
                }
                // Key Values from metaData
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Consumer_ACK_Request');
                
                for(IntgMsg__c intmsg:msgs){
                    Map<String, Object> rootMap = new Map<String, Object>();
                    
                    if(applicantMap.containskey(intmsg.RefId__c)){
                        
                        Applicant__c appl= applicantMap.get(intmsg.RefId__c);
                        LoanAppl__c  loanl= loanMap.get(appl.LoanAppln__c);
                        ApplAddr__c  appladdr=addrMap.get(intmsg.RefId__c);
                        ApplKyc__c   appkyc=appKycMap.get(intmsg.RefId__c);
                        Map<String,String> applkyc = applKycMap.containsKey(intmsg.RefId__c)?applKycMap.get(intmsg.RefId__c): new Map<String,String>();
                        
                        
                        // Used In HEADER section REQUEST-TIME
                        DateTime currentDateTime=DateTime.now();
                        String currentDateTimeString=currentDateTime.format('dd-MM-yyyy HH:mm:ss');
                        
                        // Used In REQUEST[29] 03
                        //string concatenateaddress=appladdr!=null ?appladdr.HouseNo__c+' '+appladdr.AddrLine1__c + ' ' + appladdr.AddrLine2__c: '';
                        String concatenateAddress = '';
                        if (appladdr != null) {
                            if (!String.isEmpty(appladdr.HouseNo__c)) {
                                concatenateAddress += appladdr.HouseNo__c + ' ';
                            }
                            if (!String.isEmpty(appladdr.AddrLine1__c)) {
                                concatenateAddress += appladdr.AddrLine1__c + ' ';
                            }
                            if (!String.isEmpty(appladdr.AddrLine2__c)) {
                                concatenateAddress += appladdr.AddrLine2__c;
                            }
                        }
                        
                        
                        //used in 04 to round of the loan value 
                        Decimal inputNumber = loanl.ReqLoanAmt__c;
                        Decimal outputNumber = inputNumber!=null ? inputNumber.setScale(0, System.RoundingMode.DOWN) : null;
                        
                        //maps used generate requestbody
                        Map<String, Object> headerMap = new Map<String, Object>();
                        Map<String, Object> requestMap = new Map<String, Object>();
                        Map<String, Object> inner21Map = new Map<String, Object>();
                        List<Map<String, Object>> inner29List = new List<Map<String, Object>>();
                        Map<String, Object> inner30Map = new Map<String, Object>();
                        List<Map<String, Object>> inner31List = new List<Map<String, Object>>();
                        
                        // HEADER section
                        headerMap.put('APPLICATION-ID',loanl.Name!=null?loanl.Name:'' );
                        headerMap.put('CUST-ID',appl.Name!=null?appl.Name:'');
                        headerMap.put('REQUEST-TYPE', String.isNotBlank(svc.InquiryCode__c)?svc.InquiryCode__c:'');//REQUEST
                        headerMap.put('REQUEST-TIME', currentDateTimeString);
                        
                        
                        // REQUEST section
                        requestMap.put('11', String.isNotBlank(svc.Organization__c)?svc.Organization__c:''); // UAT,Production
                        
                        requestMap.put('22',(appl.Gender__c!=null && GenderMap.containsKey(appl.Gender__c))?GenderMap.get(appl.Gender__c):'');
                        requestMap.put('27', (appl!=null &&appl.DOB__c!=null)?String.valueOf(DateTime.newInstance(appl.DOB__c.year(), appl.DOB__c.month(), appl.DOB__c.day()).format('ddMMyyyy')):'');
                        
                        requestMap.put('03',(loanl.Product__c!=null && ProductTypeMap.containsKey(loanl.Product__c))?ProductTypeMap.get(loanl.Product__c):'');
                        
                        requestMap.put('04', outputNumber);
                        requestMap.put('07', String.isNotBlank(svc.SourceSystem__c)?svc.SourceSystem__c:'');
                        requestMap.put('21', inner21Map);
                        requestMap.put('29', inner29List);
                        requestMap.put('30', applkyc);//inner30Map
                        requestMap.put('31', inner31List);
                        
                        
                        // REQUEST[21] section
                        inner21Map.put('01',appl!=null?appl.FullName__c:'' );
                        
                        // REQUEST[29] section (List of objects)
                        Map<String, Object> inner29Map = new Map<String, Object>();
                        inner29Map.put('01', System.label.ConsumerBureauAddrTyp);//Residence Address OFFICE
                        inner29Map.put('03', concatenateaddress);
                        inner29Map.put('04', (appladdr!=null && appladdr.City__c!=null)?appladdr.City__c:'');
                        inner29Map.put('05', (appladdr!=null && appladdr.Pincode__c!=null)?appladdr.Pincode__c:'');
                        inner29Map.put('06', (appladdr!=null && appladdr.State__c!=null)?appladdr.State__c:'');
                        inner29List.add(inner29Map);
                        
                        // REQUEST[30] section
                        inner30Map.put('01',(appkyc!=null && appkyc.Pan__c!=null)?appkyc.Pan__c:'');
                        
                        // REQUEST[31] section (List of objects)
                        Map<String, Object> inner31Map = new Map<String, Object>();
                        inner31Map.put('01', System.label.BureauPhoneType);
                        inner31Map.put('02',appl.MobNumber__c!=null?appl.MobNumber__c:'');
                        inner31List.add(inner31Map);
                        
                        
                        
                        // ROOT section
                        rootMap.put('HEADER', headerMap);
                        rootMap.put('REQUEST', requestMap);
                        
                        
                        IntgMsg__c integrationMessage =new IntgMsg__c();
                        integrationMessage.Id=intmsg.id;
                        integrationMessage.Req__c=JSON.serialize(rootMap);
                        integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntMsgRecords.add(integrationMessage);
                    }
                    
                }
                
                if(!updateIntMsgRecords.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntMsgRecords);
                }
                uow.commitWork();
                
            }catch(Exception ex){
                GlobalUtility.logMessage('Error', 'ConsumerACKRequestGenerator class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }	
    }
    //**************************************************************************************************************************************//
    Private Map<String,String> ProductTypeMap=new Map<String,String>{
            'Home Loan'=>System.label.BureauHousingLoanProduct,
            'Small Ticket LAP'=>System.label.BureauSTLProduct,
            'Loan Against Property' =>System.label.BureauLAPProduct,
             'Business Loan'=>System.label.BureauBusinessLoanProduct,
             'Personal Loan'=>System.label.BureauPersonalLoanProduct
            };
                
     //**************************************************************************************************************************************//
     Private Map<String,String> GenderMap=new Map<String,String>{
        'M'=>'male',
        'F'=>'female',
        'T'=>'transgender'
         };
                            
}