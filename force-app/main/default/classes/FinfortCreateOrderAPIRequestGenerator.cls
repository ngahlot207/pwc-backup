public class FinfortCreateOrderAPIRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
        
        
        if(!msgs.isEmpty()){
            
            try{
                
                List<String> addressType=new List<String>{'Office Address','Residence Cum office','Principal place for business'};
                List<IntgMsg__c> updateIntMsgRecords = new List<IntgMsg__c>();
                Set<Id> applicantIds =new Set<Id>();
                Set<Id> authIntmsgIds =new Set<Id>();
                Set<Id> userIds =new Set<Id>();
                Map<Id,String> intmsgMap =new Map<Id,String>();
                Map<Id,Applicant__c> applicantMap;
                Map<Id,User> userMap;
                Map<Id,List<ApplGST__c>> applGstMap=new Map<Id,List<ApplGST__c>>();
                Map<Id,Map<String,ApplAddr__c>> addressTypeMap=new Map<Id,Map<String,ApplAddr__c>>();
                Map<Id,Map<String,Id>> userIdMap =new Map<Id,Map<String,Id>>();
                Map<String,APIConfiguration__c> APICrdMap = APIConfiguration__c.getAll();
                
                //Getting Key Ids
                for(IntgMsg__c msg :msgs){
                    
                    if(String.isNotblank(msg.RefId__c)){
                        applicantIds.add(msg.RefId__c);
                    }
                    
                    /* if(String.isNotblank(msg.ParentRefId__c)){
                        authIntmsgIds.add(msg.ParentRefId__c);
                    }*/
                    
                    if(String.isNotblank(msg.RefId__c) && String.isNotblank(msg.Svc__c)){
                        
                        if(msg.Svc__c=='Create Order - GST'){
                           intmsgMap.put(msg.RefId__c,'FinFort Auth Token - GST'); 
                        }
                        else if(msg.Svc__c=='Create Order - ITR'){
                            intmsgMap.put(msg.RefId__c,'FinFort Auth Token - ITR');
                        }
                       
                    }
                }
                
                if(!applicantIds.isEmpty()){
                    
                    //Applicant Details
                    applicantMap =new Map<Id,Applicant__c>([Select Id,Constitution__c,CustProfile__c,DOB__c,FullName__c,CompanyName__c,PAN__c,
                                                            EmailId__c,PhoneNumber__c,MobNumber__c,LoanAppln__r.Product__c,LoanAppln__r.BrchName__c,
                                                            LoanAppln__r.Name,BorrowerPreferredLanguage__c,LLPIN__c,
                                                            (Select Id,Pan__c from Applicant_KYC__r where kycDoc__c='Pan') from Applicant__c Where Id IN:applicantIds]);
                    
                    //GST details
                    for(ApplGST__c gst:[Select Id,Applicant__c,GSTIN__c from ApplGST__c Where Applicant__c IN:applicantIds 
                                        AND (GSTIN__c!=null OR GSTIN__c!='')]){
                                            
                                            if(applGstMap.containskey(gst.Applicant__c)){
                                                
                                                applGstMap.get(gst.Applicant__c).add(gst);
                                                
                                            }else{
                                                
                                                applGstMap.put(gst.Applicant__c,new list<ApplGST__c>{gst});
                                                
                                            }
                                        }
                    
                    //Address
                    for(ApplAddr__c adrs:[Select id,Applicant__c,AddrTyp__c,FullAdrs__c,State__c,Country__c,
                                          City__c,Pincode__c from ApplAddr__c Where Applicant__c IN:applicantIds AND AddrTyp__c IN:addressType]){
                        
                        if(addressTypeMap.containsKey(adrs.Applicant__c)){
                            
                            addressTypeMap.get(adrs.Applicant__c).put(adrs.AddrTyp__c,adrs);
                        }else{
                            addressTypeMap.put(adrs.Applicant__c,new Map<String,ApplAddr__c>{adrs.AddrTyp__c=>adrs});
                        }
                    }
                }
                
                //IntMsg Details
                if(!intmsgMap.isEmpty()){
                    
                    for(IntgMsg__c msg:[Select id,RefId__c,Svc__c,CreatedBy.Name,APIStatus__c from IntgMsg__c 
                                        Where RefId__c IN :intmsgMap.keyset() AND Svc__c IN:intmsgMap.values() 
                                        AND  CreatedBy.Name!='Integration User'
                                        ORDER BY CreatedDate DESC]){
                        
                                            if(!userIdMap.containsKey(msg.RefId__c)){
                                                 userIdMap.put(msg.RefId__c,new Map<String,Id>{msg.Svc__c=>msg.CreatedById});
                                                userIds.add(msg.CreatedById);
                                            }
                                           
                    }
                }
                
                //User Details
                if(!userIds.isEmpty()){
                    userMap =new Map<Id,User>([Select Id,Name,Email,MobilePhone,Phone from User Where Id IN:userIds]);
                }
                
                
                //Looping IntgMsg__c
                for(IntgMsg__c intmsg :msgs){
                    
                   /* List<FinfortCreateOrderAPIRequestWrapper.WebhookUrls> WebhookList =new List<FinfortCreateOrderAPIRequestWrapper.WebhookUrls>();
                    
                    //WebhookUrls  Request Tag
                    FinfortCreateOrderAPIRequestWrapper.WebhookUrls Webhook =new FinfortCreateOrderAPIRequestWrapper.WebhookUrls();
                    Webhook.webhook_url='';
                    Webhook.key_name='';
                    Webhook.key_value='';
                    WebhookList.add(Webhook);*/
                    
                    //OtherInfo Request Tag
                    FinfortCreateOrderAPIRequestWrapper.OtherInfo otrInfo =new FinfortCreateOrderAPIRequestWrapper.OtherInfo();
                    otrInfo.send_consent_borrower=APICrdMap!=null?APICrdMap.get('Finfort Create Order').Consent__c:false;
                    
                    
                    //OrderInfo Request Tag
                    FinfortCreateOrderAPIRequestWrapper.OrderInfo odrInfo =new FinfortCreateOrderAPIRequestWrapper.OrderInfo();
                    odrInfo.assistanceBy=APICrdMap!=null?APICrdMap.get('Finfort Create Order').AssistanceBy__c:'';
                    
                    if(!applicantMap.isEmpty() && applicantMap.containsKey(intmsg.RefId__c)){
                        
                        Applicant__c applicant =applicantMap.get(intmsg.RefId__c);
                        
                        //For ITR
                        if(intmsg.Svc__c=='Create Order - ITR'){
                            
                            if(applicant.Constitution__c=='INDIVIDUAL' && (applicant.CustProfile__c=='SELF EMPLOYED PROFESSIONAL' || applicant.CustProfile__c=='SELF EMPLOYED NON PROFESSIONAL')){
                                
                                odrInfo.product_name='E-Financials(Self Employed Individuals)';
                            }
                            else if(applicant.Constitution__c!='INDIVIDUAL'){
                                odrInfo.product_name='E-Financials(Corporate)';
                            }
                        }
                        
                        //For GST
                        if(intmsg.Svc__c=='Create Order - GST'){
                            odrInfo.product_name='GST';
                        }
                        
                        //For Both
                       /* if(intmsg.Svc__c=='Create Order - ITR + GST'){
                            
                            if(applicant.Constitution__c=='INDIVIDUAL' && (applicant.CustProfile__c=='SELF EMPLOYED PROFESSIONAL' || applicant.CustProfile__c=='SELF EMPLOYED NON PROFESSIONAL')){
                                
                                odrInfo.product_name='GST + E-Financials(Self Employed Individuals)';
                            }
                            else if(applicant.Constitution__c!='INDIVIDUAL'){
                                odrInfo.product_name='GST + E-Financials(Corporate)';
                            }
                        }*/
                        
                    }
                    
                    
                    
                    
                    List<String> gstNumber =new List<String>();
                    List<String> itrNumber =new List<String>();
                    
                    //gstInfo
                    if(!applGstMap.isEmpty() && applGstMap.containsKey(intmsg.RefId__c) && 
                       (intmsg.Svc__c=='Create Order - GST'||intmsg.Svc__c=='Create Order - ITR + GST')){
                        
                        for(ApplGST__c gst:applGstMap.get(intmsg.RefId__c)){
                            
                            if(string.isNotblank(gst.GSTIN__c)){
                                gstNumber.add(gst.GSTIN__c);
                            }
                        }
                    }
                    
                    //itrinfo
                    if(!applicantMap.isEmpty() && applicantMap.containsKey(intmsg.RefId__c) && 
                       (intmsg.Svc__c=='Create Order - ITR'||intmsg.Svc__c=='Create Order - ITR + GST')){
                        
                        Applicant__c app =applicantMap.get(intmsg.RefId__c);
                        
                        
                        itrNumber.add(String.isNotBlank(app.PAN__c) ? app.PAN__c :
                                      (app.Applicant_KYC__r != null && !app.Applicant_KYC__r.isEmpty() && String.isNotBlank(app.Applicant_KYC__r[0].Pan__c)) 
                                      ? app.Applicant_KYC__r[0].Pan__c : '');
                     }
                    
                    
                    
                    //DataRelatedInfo Request Tag
                    FinfortCreateOrderAPIRequestWrapper.DataRelatedInfo dataInfo =new FinfortCreateOrderAPIRequestWrapper.DataRelatedInfo();
                    dataInfo.gstInfo=gstNumber;
                    dataInfo.itrInfo=itrNumber;
                    
                    //BorrowerInfo Request Tag
                    FinfortCreateOrderAPIRequestWrapper.BorrowerInfo brwInfo =new FinfortCreateOrderAPIRequestWrapper.BorrowerInfo();
                    
                    if(!applicantMap.isEmpty() && applicantMap.containsKey(intmsg.RefId__c)){
                        
                        Applicant__c app =applicantMap.get(intmsg.RefId__c);
                        ApplKyc__c kyc =app.Applicant_KYC__r[0]; 
                        
                        brwInfo.borrower_name=(string.isNotblank(app.Constitution__c) && app.Constitution__c=='INDIVIDUAL')?app.FullName__c:app.CompanyName__c;
                        brwInfo.borrower_DOIB=app.DOB__c!=null?DateTime.newInstance(app.DOB__c.year(),app.DOB__c.month(),app.DOB__c.day()).format('dd/MM/yyyy'):''; 
                        brwInfo.borrower_pan=string.isnotblank(app.PAN__c)?app.PAN__c:kyc.Pan__c;
                        brwInfo.borrower_email=String.isNotblank(app.EmailId__c)?app.EmailId__c:'';
                        brwInfo.borrower_phone=String.isNotblank(app.MobNumber__c)?app.MobNumber__c:'';//
                        brwInfo.borrower_language=String.isNotblank(app.BorrowerPreferredLanguage__c)?app.BorrowerPreferredLanguage__c:'';//
                        
                        if(!addressTypeMap.isEmpty() && applicantMap.containsKey(intmsg.RefId__c)){
                            
                            ApplAddr__c ads =getAddress(addressTypeMap,applicantMap.get(intmsg.RefId__c).Id,applicantMap.get(intmsg.RefId__c).CustProfile__c);
                        
                            brwInfo.borrower_state=(ads!=null && String.isNotblank(ads.State__c))?ads.State__c:'';
                            brwInfo.borrower_country=(ads!=null && String.isNotblank(ads.Country__c))?ads.Country__c:'';
                            brwInfo.borrower_street=(ads!=null && String.isNotblank(ads.FullAdrs__c))?ads.FullAdrs__c:'';
                            brwInfo.borrower_city=(ads!=null && String.isNotblank(ads.City__c))?ads.City__c:'';
                            brwInfo.borrower_pincode=(ads!=null && String.isNotblank(ads.Pincode__c))?ads.Pincode__c:'';
                        
                        }
                       
                       
                        brwInfo.borrower_cinLlpin=(string.isNotblank(app.Constitution__c) && app.Constitution__c=='LIMITED LIABILITY PARTNERSHIP')?app.CIN__c:app.LLPIN__c;
                        
                    }
                    
                    //RequestorInfo Request Tag
                    FinfortCreateOrderAPIRequestWrapper.RequestorInfo reqInfo =new FinfortCreateOrderAPIRequestWrapper.RequestorInfo();
                    
                    if(!userMap.isEmpty() && intmsgMap.containsKey(intmsg.RefId__c) && svcMap.containsKey(intmsg.Svc__c) && 
                       userIdMap.get(intmsg.RefId__c).containsKey(svcMap.get(intmsg.Svc__c))){
                        
                        
                        
                        User usr = userMap.get(userIdMap.get(intmsg.RefId__c).get(svcMap.get(intmsg.Svc__c))) ;
                        
                        if(applicantMap.containsKey(intmsg.RefId__c)){
                            
                            //reqInfo.requestor_division=string.isNotblank(applicantMap.get(intmsg.RefId__c).LoanAppln__r.Product__c)?applicantMap.get(intmsg.RefId__c).LoanAppln__r.Product__c:'';
                            reqInfo.requestor_branch=string.isNotblank(applicantMap.get(intmsg.RefId__c).LoanAppln__r.BrchName__c)?applicantMap.get(intmsg.RefId__c).LoanAppln__r.BrchName__c:'';
                        }
                        reqInfo.requestor_division='BL_PA1';
                        
                        reqInfo.requestor_name=String.isnotBlank(usr.Name)?usr.Name:'';
                        reqInfo.requestor_email=String.isnotBlank(usr.Email)?usr.Email:'';
                        reqInfo.requestor_phone=String.isnotBlank(usr.MobilePhone)?usr.MobilePhone:usr.Phone;
                        
                    }
                     
                    //LenderInfo Request Tag
                    FinfortCreateOrderAPIRequestWrapper.LenderInfo lenInfo =new FinfortCreateOrderAPIRequestWrapper.LenderInfo();
                    
                    if(applicantMap.containsKey(intmsg.RefId__c)){
                         lenInfo.lender_referenceNumber=applicantMap.get(intmsg.RefId__c).LoanAppln__r.Name+''+intmsg.Integration_Message_Number__c;
                    }
                   
                    lenInfo.lender_source=APICrdMap!=null?APICrdMap.get('Finfort Create Order').Source__c:'';
                    lenInfo.lender_name=APICrdMap!=null?APICrdMap.get('Finfort Create Order').SourceName__c:'';
                    
                    //params Request Tag
                    FinfortCreateOrderAPIRequestWrapper.Param params =new FinfortCreateOrderAPIRequestWrapper.Param();
                    params.lenderInfo=lenInfo;
                    params.requestorInfo=reqInfo;
                    params.borrowerInfo=brwInfo;
                    params.dataRelatedInfo=dataInfo;
                    params.orderInfo=odrInfo;
                    params.otherInfo=otrInfo;
                    //params.webhook_urls=WebhookList;
                    
                    //Full Request Tag
                    FinfortCreateOrderAPIRequestWrapper request =new FinfortCreateOrderAPIRequestWrapper();
                    request.request=APICrdMap!=null?APICrdMap.get('Finfort Create Order').RequestType__c:'';
                    request.param=params;
                    
                    
                    IntgMsg__c integrationMessage =new IntgMsg__c();
                    integrationMessage.Id=intmsg.Id;
                    integrationMessage.Req__c=JSON.serialize(request);
                    integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                    updateIntMsgRecords.add(integrationMessage);
                }
                
                //Updating the IntgMsg
                if(!updateIntMsgRecords.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntMsgRecords);
                }
                uow.commitWork();
                
            }catch(Exception ex){
                GlobalUtility.logMessage('Error', 'FinfortCreateOrderAPIRequestGenerator class', 
                                         'generate', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
            
        }
        
    }
    
    //************************************************************************************************************************
    public static ApplAddr__c getAddress(Map<Id,Map<String,ApplAddr__c>> addressTypeMap,Id applicantId,String customerProfile){
        
        
        
        ApplAddr__c adrs;
        
        if(customerProfile=='SELF EMPLOYED NON PROFESSIONAL' || customerProfile=='SALARIED'){
            
            if(addressTypeMap.containsKey(applicantId) && addressTypeMap.get(applicantId).containsKey('Principal place for business')){
                
                adrs=addressTypeMap.get(applicantId).get('Principal place for business');
            }
        }
        else{
            if(addressTypeMap.containsKey(applicantId) && addressTypeMap.get(applicantId).containsKey('Residence Cum office')){
                
                adrs=addressTypeMap.get(applicantId).get('Residence Cum office');
            }
            else if(addressTypeMap.containsKey(applicantId) && addressTypeMap.get(applicantId).containsKey('Office Address')){
                
                adrs=addressTypeMap.get(applicantId).get('Office Address');
            }
        }
        system.debug(adrs);
        return adrs;
    }
    //************************************************************************************************************************
    public static Map<String,String> svcMap =new Map<String,String>{
        'Create Order - GST'=>'FinFort Auth Token - GST',
            'Create Order - ITR'=>'FinFort Auth Token - ITR'
    };
    
    
}