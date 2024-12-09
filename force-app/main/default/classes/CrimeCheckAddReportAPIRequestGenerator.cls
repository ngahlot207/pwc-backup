public class CrimeCheckAddReportAPIRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){
        
        if(!msgs.isempty()){
            
            try{
                
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
                
                List<IntgMsg__c> updateIntMsgRecords = new List<IntgMsg__c>();
                Set<Id> applicantIds =new Set<Id>();
                List<String> addresstype =new List<String>{'Principal place for business','Residence Address','Residence Cum office'};
                Map<String,APIConfiguration__c> APICrdMap = APIConfiguration__c.getAll();
                
                    for(IntgMsg__c intmsg:msgs){
                        
                        if(String.isNotblank(intmsg.RefId__c)){
                            applicantIds.add(intmsg.RefId__c);
                        }
                    }
                
                if(!applicantIds.isEmpty()){
                    
                    Map<Id,Applicant__c> applicantMap=new Map<Id,Applicant__c>([Select Id,LoanAppln__c,LoanAppln__r.Name,CompanyName__c,Constitution__c,CIN__c,
                                                                                LoanAppln__r.Product__c,FullName__c,Father_Name__c,DOB__c,
                                                                                (Select id,kycDoc__c,Pan__c from Applicant_KYC__r Where kycDoc__c='Pan'),
                                                                                (Select id,GSTIN__c from Applicant_Employments__r) from Applicant__c Where Id IN:applicantIds]);
                    
                    Map<Id,Map<String,ApplAddr__c>> addressMap=new Map<Id,Map<String,ApplAddr__c>>();
                    
                    for(ApplAddr__c adrs:[Select id,Applicant__c,AddrTyp__c,FullAdrs__c from ApplAddr__c Where Applicant__c IN:applicantIds AND AddrTyp__c IN:addresstype]){
                        
                        if(addressMap.containsKey(adrs.Applicant__c)){
                            
                            addressMap.get(adrs.Applicant__c).put(adrs.AddrTyp__c,adrs);
                        }else{
                            addressMap.put(adrs.Applicant__c,new Map<String,ApplAddr__c>{adrs.AddrTyp__c=>adrs});
                        }
                    }
                    
                    for(IntgMsg__c msg:msgs){
                        
                        List<String> requestString =new List<String>();
                        String joinString;
                        
                        boolean isException=!Test.isRunningTest() ? true : false;
                        
                        if(applicantMap.containsKey(msg.RefId__c) && APICrdMap!=null){
                            
                            Applicant__c app =applicantMap.get(msg.RefId__c);
                            
                            //Mapping from ApplKyc__c
                            if(!app.Applicant_KYC__r.isEmpty()){
                                
                                ApplKyc__c kyc =app.Applicant_KYC__r[0];
                                
                                requestString.add('panNumber='+EncodingUtil.urlEncode((string.isnotBlank(kyc.Pan__c)?kyc.Pan__c:''),'UTF-8'));
                            }
                            requestString.add('apiKey='+EncodingUtil.urlEncode(APICrdMap.get('Crime Check').APIKey__c,'UTF-8'));//FedFinaDev-sandbox-T9HBC
                            
                            
                            if(isException){
                                
                                requestString.add('clientRefNo='+EncodingUtil.urlEncode(app.LoanAppln__r.Name +'_' + app.FullName__c ,'UTF-8'));
                            }
                            
                            
                            requestString.add('reportMode='+EncodingUtil.urlEncode(((string.isnotBlank(msg.TriggerType__c) && msg.TriggerType__c=='System')?APICrdMap.get('Crime Check').Mode__c:''),'UTF-8'));//realTimeHighAccuracy
                            
                            requestString.add('priority='+EncodingUtil.urlEncode(APICrdMap.get('Crime Check').Priority__c,'UTF-8'));//normal    
                            
                            requestString.add('callbackUrl='+EncodingUtil.urlEncode(APICrdMap.get('Crime Check').URL__c,'UTF-8')); //https://uat-api.fedfina.com/sandbox/dev/crimecheckCallback    
                            
                            requestString.add('reqTag='+EncodingUtil.urlEncode((String.isNotblank(app.LoanAppln__r.Product__c)?app.LoanAppln__r.Product__c:''),'UTF-8'));
                            
                            requestString.add('crimewatch='+EncodingUtil.urlEncode(String.valueof(APICrdMap.get('Crime Check').Consent__c),'UTF-8'));//false
                            
                            if(app.Constitution__c=='INDIVIDUAL' || app.Constitution__c=='PROPERITORSHIP'){
                                
                                requestString.add('name='+EncodingUtil.urlEncode((string.isnotBlank(app.FullName__c)?app.FullName__c:''),'UTF-8'));
                                requestString.add('fatherName='+EncodingUtil.urlEncode((string.isnotBlank(app.Father_Name__c)?app.Father_Name__c:''),'UTF-8'));
                                requestString.add('dob=' + EncodingUtil.urlEncode(((app.DOB__c != null) ? String.valueOf(app.DOB__c) : ''),'UTF-8'));
                                
                                //Mapping From Applicant Address
                                if(app.Constitution__c=='INDIVIDUAL' && addressMap.containsKey(app.Id) && addressMap.get(app.Id).containsKey('Residence Address')){
                                    
                                    ApplAddr__c addrss = addressMap.get(app.Id).get('Residence Address');
                                    
                                    requestString.add('address='+EncodingUtil.urlEncode((String.isNotblank(addrss.FullAdrs__c)?addrss.FullAdrs__c:''),'UTF-8'));
                                }
                                else if(app.Constitution__c=='PROPERITORSHIP' && addressMap.containsKey(app.Id)){
                                    
                                    if(addressMap.get(app.Id).containsKey('Residence Cum office')){
                                        
                                        ApplAddr__c addrss = addressMap.get(app.Id).get('Residence Cum office');
                                        requestString.add('address='+EncodingUtil.urlEncode((String.isNotblank(addrss.FullAdrs__c)?addrss.FullAdrs__c:''),'UTF-8'));
                                        
                                    }else if(addressMap.get(app.Id).containsKey('Residence Address') || addressMap.get(app.Id).containsKey('Principal place for business')){
                                        
                                        if(addressMap.get(app.Id).containsKey('Residence Address')){
                                            
                                            ApplAddr__c addrss = addressMap.get(app.Id).get('Residence Address');
                                            requestString.add('address='+EncodingUtil.urlEncode((String.isNotblank(addrss.FullAdrs__c)?addrss.FullAdrs__c:''),'UTF-8'));
                                            
                                            if(addressMap.get(app.Id).containsKey('Principal place for business')){
                                                ApplAddr__c adrs = addressMap.get(app.Id).get('Principal place for business');
                                                requestString.add('address2='+EncodingUtil.urlEncode((String.isNotblank(adrs.FullAdrs__c)?adrs.FullAdrs__c:''),'UTF-8'));
                                            }
                                        }
                                        
                                        else if(addressMap.get(app.Id).containsKey('Principal place for business')){
                                            
                                            ApplAddr__c addrss = addressMap.get(app.Id).get('Principal place for business');
                                            requestString.add('address='+EncodingUtil.urlEncode((String.isNotblank(addrss.FullAdrs__c)?addrss.FullAdrs__c:''),'UTF-8'));
                                            
                                            if(addressMap.get(app.Id).containsKey('Residence Address')){
                                                ApplAddr__c adrs = addressMap.get(app.Id).get('Residence Address');
                                                requestString.add('address2='+EncodingUtil.urlEncode((String.isNotblank(adrs.FullAdrs__c)?adrs.FullAdrs__c:''),'UTF-8'));
                                            }
                                        }
                                    }
                                }
                                
                                joinString=string.join(requestString,'&'); 
                                
                            }else{
                                requestString.add('companyName='+EncodingUtil.urlEncode((string.isnotBlank(app.CompanyName__c)?app.CompanyName__c:''),'UTF-8'));
                                requestString.add('companyType='+EncodingUtil.urlEncode(((string.isnotBlank(app.Constitution__c) && companyType.containsKey(app.Constitution__c))?companyType.get(app.Constitution__c):''),'UTF-8'));
                                requestString.add('cinNumber='+EncodingUtil.urlEncode((string.isnotBlank(app.CIN__c)?app.CIN__c:''),'UTF-8'));
                                
                                //Mapping From Applicant Address
                                if(addressMap.containsKey(app.Id) && addressMap.get(app.Id).containsKey('Principal place for business')){
                                    ApplAddr__c addrss = addressMap.get(app.Id).get('Principal place for business');
                                    
                                    requestString.add('companyAddress='+EncodingUtil.urlEncode((String.isNotblank(addrss.FullAdrs__c)?addrss.FullAdrs__c:''),'UTF-8'));
                                }else{
                                    requestString.add('companyAddress='+EncodingUtil.urlEncode('','UTF-8'));
                                }
                                
                                //Mapping from ApplicantEmployment__c
                                if(!app.Applicant_Employments__r.isEmpty()){
                                    
                                    ApplicantEmployment__c emp =app.Applicant_Employments__r[0];
                                    
                                    requestString.add('gstNumber='+EncodingUtil.urlEncode((string.isnotBlank(emp.GSTIN__c)?emp.GSTIN__c:''),'UTF-8'));
                                }
                                
                                joinString=string.join(requestString,'&');
                            }
                            
                            IntgMsg__c integrationMessage =new IntgMsg__c();
                            integrationMessage.Id=msg.Id;
                            integrationMessage.Req__c=joinString;
                            integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                            updateIntMsgRecords.add(integrationMessage);
                        }
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
                }
                
            }catch(Exception ex){
                GlobalUtility.logMessage('Error', 'CrimeCheckAddReportAPIRequestGenerator class', 
                                         'generate', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
    }
    
    //******************************************************************************************************************************
    Public static Map<String,String> companyType =new Map<String,String>{
        
        'ASSOCIATION OF PERSONS'=>'dontknow',
            'HUF'=>'dontknow',
            'INDIVIDUAL'=>'dontknow',
            'LIMITED LIABILITY PARTNERSHIP'=>'LLP',
            'PARTNERSHIP'=>'dontknow',  
            'PRIVATE LIMITED COMPANY'=>'PvtLtd',
            'PROPERITORSHIP'=>'Proprietary',   
            'PUBLIC LIMITED COMPANY'=>'Limited',
            'SOCIETY'=>'dontknow',
            'TRUST'=>'dontknow'
            };     
                }