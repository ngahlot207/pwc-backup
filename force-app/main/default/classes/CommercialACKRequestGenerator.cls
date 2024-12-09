public class CommercialACKRequestGenerator implements ICalloutRequestGenerator {
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
        List<String> addressTypes = new List<String>{'Principal place for business','Residence Cum office'};
            try{
                
                Set<Id> refids=new Set<Id>();
                for(IntgMsg__c intmsg:msgs){
                    refids.add(intmsg.RefId__c);
                }
                
                //Getting details from Loan and Applicant
                Map<Id,Applicant__c> applicantmap=new Map<Id,Applicant__c>();
                for(Applicant__c applist:[select id,Name,MobNumber__c,LoanAppln__c,LoanAppln__r.Name,LoanAppln__r.Product__c,FullName__c,
                                          LoanAppln__r.ReqLoanAmt__c,LoanAppln__r.LoanPurpose__c,Constitution__c from Applicant__c where Id IN:refids]){
                                              
                                              applicantmap.put(applist.Id,applist);                         
                                          }
                
                //  Getting details from  Applicant address
                Map<Id,ApplAddr__c> addressmap=new Map<Id,ApplAddr__c>();
                
                
                for(ApplAddr__c addr:[select id,Applicant__c,AddrTyp__c,HouseNo__c,AddrLine1__c,AddrLine2__c,City__c,Pincode__c,State__c from ApplAddr__c where Applicant__c IN:refIds AND AddrTyp__c IN:addressTypes]){
                    if(!addressmap.containsKey(addr.Applicant__c)){
                        addressmap.put(addr.Applicant__c,addr);
                    }
                    else{
                        if(addr.AddrTyp__c == 'Principal place for business' && addressmap.get(addr.Applicant__c).AddrTyp__c !='Principal place for business'){
                            addressmap.put(addr.Applicant__c,addr);
                        }
                    }
                }
                
                
                //  Getting details from  Applicant KYC
                Map<Id,ApplKyc__c> applkycmap=new Map<Id,ApplKyc__c>();
                for(ApplKyc__c appkyclist:[select id,Applicant__c,kycDoc__c,Pan__c,Name__c from ApplKyc__c where Applicant__c IN:refids AND kycDoc__c ='Pan']){
                    
                    applkycmap.put(appkyclist.Applicant__c,appkyclist);
                }
                
                
                
                List<IntgMsg__c> updateIntMsgRecords = new List<IntgMsg__c>();
                
                // Key Values from metaData
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Commercial_ACK_Request');
                
                for(IntgMsg__c intmsg:msgs){
                    
                    
                    Map<String,Object> rootmap=new Map<String,Object>();
                    Map<String,Object> headermap=new Map<String,Object>();
                    Map<String,Object> requestmap=new Map<String,Object>();
                    List<Map<String,Object>> inner24list=new List<Map<String,Object>>();
                    Map<String,Object> inner25map=new Map<String,Object>();
                    Map<String,Object> inner26map=new Map<String,Object>();
                    
                    
                    // Used In HEADER section REQUEST-TIME
                    DateTime currentDateTime = DateTime.now();
                    String currentDateTimeString = currentDateTime.format('E MMM dd HH:mm:ss z yyyy', 'IST');
                    
                    //HEADER
                    headermap.put('REQUEST-RECEIVED-TIME','');
                    headermap.put('REQUEST-TIME',currentDateTimeString);
                    headermap.put('REQUEST-TYPE',String.isNotBlank(svc.InquiryCode__c)?svc.InquiryCode__c:'');
                    
                    
                    requestmap.put('11',String.isNotBlank(svc.Organization__c)?svc.Organization__c:'');//changes QA/UAT Production
                    requestmap.put('07',String.isNotBlank(svc.SourceSystem__c)?svc.SourceSystem__c:'');//changes COMM
                    
                    
                    //innermap24
                    Map<String,Object> inner24map=new Map<String,Object>();
                    inner24map.put('01',System.label.CommercialBureauAddrTyp);//OFFICE
                    
                    if(applicantmap.containskey(intmsg.RefId__c)){
                        
                        Applicant__c appl=applicantmap.get(intmsg.RefId__c);
                        
                        
                        //used in 04 to round of the loan value 
                        Decimal inputNumber = appl.LoanAppln__r.ReqLoanAmt__c;
                        Decimal outputNumber = inputNumber!=null?inputNumber.setScale(0, System.RoundingMode.DOWN):0;
                        
                        
                        // HEADER section
                        headermap.put('APPLICATION-ID',appl.LoanAppln__r.Name!=null?appl.LoanAppln__r.Name:'');
                        headermap.put('CUST-ID',appl.Name!=null?appl.Name:'');
                        
                        // REQUEST section
                        requestmap.put('12',appl.LoanAppln__r.LoanPurpose__c!=null?appl.LoanAppln__r.LoanPurpose__c.toUpperCase():'');
                        requestmap.put('34',(appl.Constitution__c!=null && constitutionMap.containskey(appl.Constitution__c))?constitutionMap.get(appl.Constitution__c):'');
                        
                        
                        requestmap.put('35','CASTING OF IRON AND STEEL');// 
                        
                        requestmap.put('48',System.label.CommercialBureauProductType1);//P4
                        requestmap.put('02',System.label.CommercialBureauProductType2);//CCIR
                        requestMap.put('03',System.label.CommercialBureauLoanType);//NEW LOAN
                        
                        
                        requestmap.put('04',outputNumber);
                        
                        
                        requestmap.put('21',appl.FullName__c!=null?appl.FullName__c:'');
                        //Inner26 Section
                        inner26map.put('01',System.label.BureauPhoneType);//Mobile Phone
                        inner26map.put('02',appl.MobNumber__c!=null?appl.MobNumber__c:'');
                    }
                    
                    
                    if(applkycmap.containskey(intmsg.RefId__c)){
                        ApplKyc__c  applkyc=applkycmap.get(intmsg.RefId__c);
                        
                        // REQUEST section
                        //inner25
                        inner25map.put('01',applkyc.Pan__c!=null?applkyc.Pan__c:'');
                    }
                    
                    if(addressmap.containskey(intmsg.RefId__c)){
                        ApplAddr__c  appladdr=addressmap.get(intmsg.RefId__c);
                        
                        //Inner24 Section
                        
                        //string concatenateaddress=appladdr.HouseNo__c+' '+appladdr.AddrLine1__c + ' ' + appladdr.AddrLine2__c;
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
                        inner24map.put('03',concatenateaddress);
                        
                        inner24map.put('04',appladdr.City__c!=null?appladdr.City__c:'');
                        inner24map.put('05',appladdr.Pincode__c!=null?appladdr.Pincode__c:'');
                        inner24map.put('06',appladdr.State__c!=null?appladdr.State__c:'');
                        inner24list.add(inner24map);
                    }
                    
                    //REQUEST Section
                    requestmap.put('24',inner24list);
                    requestmap.put('25',inner25map);
                    requestmap.put('26',inner26map);
                    
                    
                    // ROOT section
                    rootmap.put('HEADER',headermap);
                    rootmap.put('REQUEST',requestmap);
                    
                    if(rootMap!=null){
                        IntgMsg__c integrationMessage =new IntgMsg__c();
                        integrationMessage.Id=intmsg.Id;
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
                
            }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CommercialACKRequestGenerator class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }	
    }
    //**************************************************************************************************************************************// 
    Private Map<String,String> constitutionMap=new Map<String,String>{
        'ASSOCIATION OF PERSONS'=>'ASSOCIATION OF PERSONS',
            'HUF'=>'HINDU UNDIVIDED FAMILY',
            'SOCIETY'=>'CO-OPERATIVE SOCIETY',
            'PARTNERSHIP'=>'PARTNERSHIP',
            'LIMITED LIABILITY PARTNERSHIP'=>'PARTNERSHIP',
            'PRIVATE LIMITED COMPANY'=>'PRIVATE LIMITED',
            'PROPERITORSHIP'=>'PROPRIETORSHIP',
            'PUBLIC LIMITED COMPANY'=>'PUBLIC LIMITED',
            'TRUST'=>'TRUST'
            };
                }