public class RiskRatingRequestGenerator implements ICalloutRequestGenerator{

    public void generate(List<IntgMsg__c> msgs, String service, String processType){  
        System.debug('*****************RiskRatingRequestGenerator Class Start******************');
        
        final Map<Integer, String> monthMap = new Map<Integer, String>{1=>'JAN', 2=>'FEB', 3=>'MAR', 4=>'APR', 5=>'MAY', 6=>'JUN', 7=>'JUL', 8=>'AUG', 9=>'SEP', 10=>'OCT', 11=>'NOV',12=>'DEC'};
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { IntgMsg__c.SObjectType });
        List<Id> appIds = new List<Id>();
        List<Id> loanApplnIds = new List<Id>();
        Map<Id,List<Applicant__c>> loanAppMap = new Map<Id,List<Applicant__c>>();
        //Map<Id,Map<String,ApplKyc__c>> applKycMap = new Map<Id,Map<String,ApplKyc__c>>();
        Map<Id,Map<String,ApplAddr__c>> applAddMap = new Map<Id,Map<String,ApplAddr__c>>();
        Map<String, CustomerType__mdt> customerTypeMap = CustomerType__mdt.getAll();
        Map<Id,List<ApplAddr__c>> appAddMap = new Map<Id,List<ApplAddr__c>>();
        Map<Id,List<ApplKyc__c>> appKycsMap = new Map<Id,List<ApplKyc__c>>();

        //Map for Applicant Constitution
        Map<String,String> mapForCustType= new Map<String,String>();

        mapForCustType.put('ASSOCIATION OF PERSONS','18');//6
        mapForCustType.put('HUF','2');
        mapForCustType.put('INDIVIDUAL','1');
        mapForCustType.put('LIMITED LIABILITY PARTNERSHIP','11');
        mapForCustType.put('PARTNERSHIP','17');//6
        mapForCustType.put('PRIVATE LIMITED COMPANY','30');//6
        mapForCustType.put('PROPERITORSHIP','C1');//6
        mapForCustType.put('PUBLIC LIMITED COMPANY','29');//6
        mapForCustType.put('SOCIETY','26');//6
        mapForCustType.put('TRUST','9');
        

        
         Map<String, String> numberByNameMap = new Map<String, String>();
         List<CustomerType__mdt> metadataList = [SELECT Code__c,Name__c FROM CustomerType__mdt];
                        
         for(CustomerType__mdt metadata : metadataList){
         numberByNameMap.put(metadata.Name__c.toLowerCase(),metadata.Code__c);
         }
		  
       	 for(IntgMsg__c intMsg : msgs){ 
            loanApplnIds.add(intMsg.ParentRefId__c);
            if(String.isNotBlank(intMsg.RefId__c)){
                List<Id> ids = intMsg.RefId__c.split(',');
                appIds.addAll(ids);
            }
            
        }
        
        if(!appIds.isEmpty()){
            for(Applicant__c app : [SELECT Id,Name,LoanAppln__c,CompanyName__c,MobNumber__c,EmailId__c,MariStatus__c,Title__c,LoanAppln__r.Name, LoanAppln__r.BrchName__c,FName__c,MName__c,LName__c,Constitution__c,Gender__c,DOB__c,(Select Id,Applicant__c,MailAddr__c,Country__c,OwnType__c,AddrStability__c,AddrTyp__c,City__c,State__c,AddrLine1__c,AddrLine2__c,Landmark__c,Pincode__c,Locality__c FROM Applicant_Addresses__r),(Select Id,Name, Applicant__c, AadharEncripted__c,DLNo__c,Pan__c,PassNo__c,kycDoc__c,VotIdEpicNo__c,DLExpDt__c,PassExpDt__c from Applicant_KYC__r)  FROM Applicant__c Where Id IN:appIds AND ApplType__c IN ('P','C','G')]){
                if(loanAppMap.containsKey(app.LoanAppln__c))
                {
                    loanAppMap.get(app.LoanAppln__c).add(app);
                    
                }
                else{
                    loanAppMap.put(app.LoanAppln__c,new List<Applicant__c>{app});
                }

                appAddMap.put(app.Id,app.Applicant_Addresses__r);
                appKycsMap.put(app.Id,app.Applicant_KYC__r);
                 
            }
        }
        
        
        if(appIds.isEmpty() && !loanApplnIds.isEmpty()){
            /*
			for(LoanAppl__c app : [SELECT ID, (SELECT Id,Name,CompanyName__c,LoanAppln__r.Name, LoanAppln__r.BrchName__c,FName__c,MName__c,LName__c,Constitution__c,Gender__c,DOB__c,MobNumber__c  FROM Applicants__r) FROM LoanAppl__c WHERE Id IN:loanApplnIds]){
                loanAppMap.put(app.Id,app.Applicants__r);
            }			
			*/
            for(Applicant__c app : [SELECT Id,Name,LoanAppln__c,CompanyName__c,MobNumber__c,EmailId__c,MariStatus__c,Title__c,LoanAppln__r.Name, LoanAppln__r.BrchName__c,FName__c,MName__c,LName__c,Constitution__c,Gender__c,DOB__c,(Select Id,Applicant__c,MailAddr__c,Country__c,OwnType__c,AddrStability__c,AddrTyp__c,City__c,State__c,AddrLine1__c,AddrLine2__c,Landmark__c,Pincode__c,Locality__c FROM Applicant_Addresses__r),(Select Id,Name, Applicant__c, AadharEncripted__c,DLNo__c,Pan__c,PassNo__c,kycDoc__c,VotIdEpicNo__c,PassExpDt__c,DLExpDt__c from Applicant_KYC__r)  FROM Applicant__c Where LoanAppln__c IN:loanApplnIds AND ApplType__c IN ('P','C','G')]){
                if(loanAppMap.containsKey(app.LoanAppln__c))
                {
                    loanAppMap.get(app.LoanAppln__c).add(app);
                    
                }
                else{
                    loanAppMap.put(app.LoanAppln__c,new List<Applicant__c>{app});
                }

                appAddMap.put(app.Id,app.Applicant_Addresses__r);
                appKycsMap.put(app.Id,app.Applicant_KYC__r);
                 
            }
        }
      
       
        
        try{
            
            List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>(); 
            
            if(!msgs.isEmpty()){
                 
                
                for(IntgMsg__c intMsg : msgs){
				
                    if(loanAppMap.containsKey(intMsg.ParentRefId__c)){
					
					
                        RiskRatingRequestWrapper.RecordRequestDetails reqRecObj=new RiskRatingRequestWrapper.RecordRequestDetails();
                    	List<Applicant__c> applicantList =loanAppMap.get(intMsg.ParentRefId__c);
                        List<RiskRatingRequestWrapper.RecordRequestDetail> reqDetailList=new List<RiskRatingRequestWrapper.RecordRequestDetail>();
                       
                        if(!applicantList.isEmpty()){
                            
                            for(Applicant__c app : applicantList){
                            RiskRatingRequestWrapper.RecordRequestDetail reqObj=new RiskRatingRequestWrapper.RecordRequestDetail();
                            reqObj.Minor=0;
                            
                            //reqObj.DateofBirth = app.DOB__c!=null ?String.valueOf(app.DOB__c.day()) + '-' + monthMap.get(app.DOB__c.month()) + '-' + String.valueOf(app.DOB__c.year()) :'';
							//reqObj.DateofBirth =String.valueOf(DateTime.newInstance(app.DOB__c.year(), app.DOB__c.month(), app.DOB__c.day()).format('dd-MMM-yyyy')); 
                            
                            reqObj.DateofBirth = app.DOB__c!=null ? String.valueOf(DateTime.newInstance(app.DOB__c.year(), app.DOB__c.month(), app.DOB__c.day()).format('dd-MMM-yyyy')) :'';     
                                
                            reqObj.LastName = app.LName__c!=null ?app.LName__c:'';

                            reqObj.TransactionId=GlobalUtility.getUniqueNumber();
                            reqObj.RecordIdentifier=app.Name;
                            reqObj.ProposedAs=System.Label.ProposedAs;
                            reqObj.SourceSystemName=System.Label.SourceSystemName;

                            reqObj.Gender=app.Gender__c!=null ? app.Gender__c:'';
                            reqObj.MiddleName=app.MName__c!=null?app.MName__c:''; 


                            reqObj.Prefix= app.Title__c !=null ?  String.valueOf(app.Title__c).toUpperCase() :''; 
                            
                            
                            //Segment Data Start
                            RiskRatingRequestWrapper.SegmentDetail segDetail=new RiskRatingRequestWrapper.SegmentDetail();
                            segDetail.Segment=System.Label.Segment;
                            RiskRatingRequestWrapper.Segments seg =new RiskRatingRequestWrapper.Segments();
                            seg.SegmentDetail=segDetail;
                            reqObj.Segments=seg;
                            //Segment Data End
                            
                            System.debug('app.Constitution__c::'+app.Constitution__c);

                            if(!String.isBlank(app.Constitution__c))
                            {
                            reqObj.CustomerType= mapForCustType.get(app.Constitution__c) !=null ? mapForCustType.get(app.Constitution__c) :'' ;
                           
                            }else
                            {
                             reqObj.CustomerType='';
                            }

                           
                            System.debug('reqObj.CustomerType::'+reqObj.CustomerType);

                            if(reqObj.CustomerType == '1'){
                                reqObj.FirstName= (app.FName__c)!=null ? app.FName__c : '';
                            }else{
                                reqObj.FirstName= (app.CompanyName__c)!=null ? app.CompanyName__c : '';
                            }
                            
                            System.debug('reqObj.FirstName::'+reqObj.FirstName);
                            reqObj.MaritalStatus=(maritalMap.containskey(app.MariStatus__c) && app.MariStatus__c!=null) ?maritalMap.get(app.MariStatus__c):''; 
                            

                            //Identification Details Start
                            RiskRatingRequestWrapper.IdentificationDetails identDetailsObj=new RiskRatingRequestWrapper.IdentificationDetails();
                            
                            List<RiskRatingRequestWrapper.IdentificationDetail> listIdentDetail=new List<RiskRatingRequestWrapper.IdentificationDetail>();
                            if(appKycsMap.containsKey(app.Id)){    
							
                            for(ApplKyc__c appKyc : appKycsMap.get(app.Id)){
                            

                                    if(String.isNotBlank(appKyc.kycDoc__c)){
                                    if(appKyc.kycDoc__c.equalsIgnoreCase('Aadhaar')){ 
                                     RiskRatingRequestWrapper.IdentificationDetail identDetailObjAadhaar=new RiskRatingRequestWrapper.IdentificationDetail();       
                                     identDetailObjAadhaar.IdType='AadhaarCard';
                                     identDetailObjAadhaar.IdNumber=(appKyc.AadharEncripted__c)!=null ? appKyc.AadharEncripted__c:'' ; 
                                     listIdentDetail.add(identDetailObjAadhaar);    
                                     //reqObj.PermanentAddressProof='AadharCard';
                                    }
                                    if(appKyc.kycDoc__c.equalsIgnoreCase('Passport') && appKyc.PassExpDt__c!=null){
                                     RiskRatingRequestWrapper.IdentificationDetail identDetailObjPass=new RiskRatingRequestWrapper.IdentificationDetail();       
                                     identDetailObjPass.IdType='Passport'; 
                                     identDetailObjPass.IdNumber=(appKyc.PassNo__c)!=null ?appKyc.PassNo__c:'' ;   
                                     identDetailObjPass.ExpiryDate =String.valueOf(DateTime.newInstance(appKyc.PassExpDt__c.year(), appKyc.PassExpDt__c.month(), appKyc.PassExpDt__c.day()).format('dd-MMM-yyyy')); 
                                     
                                     System.debug('passSfDate::::'+identDetailObjPass.ExpiryDate);
                                     identDetailObjPass.Country ='IN'; 
                                     listIdentDetail.add(identDetailObjPass);    
                                     
                                    }if(appKyc.kycDoc__c.equalsIgnoreCase('Voter Id')){
                                     RiskRatingRequestWrapper.IdentificationDetail identDetailObjVId=new RiskRatingRequestWrapper.IdentificationDetail();       
                                     identDetailObjVId.IdType='VoterId';
                                     identDetailObjVId.IdNumber=(appKyc.VotIdEpicNo__c)!=null ? appKyc.VotIdEpicNo__c:'' ;   
                                     listIdentDetail.add(identDetailObjVId); 
                                        
                                    }if(appKyc.kycDoc__c.equalsIgnoreCase('Driving License')  && appKyc.DLExpDt__c !=null){
                                     RiskRatingRequestWrapper.IdentificationDetail identDetailObjDrL=new RiskRatingRequestWrapper.IdentificationDetail();       
                                     identDetailObjDrL.IdType='DrivingLicense';
                                     identDetailObjDrL.IdNumber=(appKyc.DLNo__c)!=null ?appKyc.DLNo__c:'' ;   
                                     identDetailObjDrL.ExpiryDate =String.valueOf(DateTime.newInstance(appKyc.DLExpDt__c.year(), appKyc.DLExpDt__c.month(), appKyc.DLExpDt__c.day()).format('dd-MMM-yyyy')); 
                                     
                                     System.debug('formattedDateLicence:::::::::' + identDetailObjDrL.ExpiryDate); 
                                     identDetailObjDrL.Country ='IN';    
                                     listIdentDetail.add(identDetailObjDrL);   
                                     
                                     }if(appKyc.kycDoc__c.equalsIgnoreCase('Pan')){
                                     RiskRatingRequestWrapper.IdentificationDetail identDetailObjPan=new RiskRatingRequestWrapper.IdentificationDetail();        
                                     identDetailObjPan.IdType='PanCard';
                                     identDetailObjPan.IdNumber=(appKyc.Pan__c)!=null ? appKyc.Pan__c:'' ;   
                                     listIdentDetail.add(identDetailObjPan);    
                                         
                                    }
                                      
    
                                }else{
                                
                                }  
                                
                                
                            }    
                                                                                   
                               
                            
                            }else
                            {
                                    //do nothing
                            }
                              
                            identDetailsObj.IdentificationDetail=listIdentDetail;
                            //Identification Details End
                            
                            RiskRatingRequestWrapper.CountryDetail cd = new RiskRatingRequestWrapper.CountryDetail();
                            cd.Country=GlobalConstants.Country;    
                            RiskRatingRequestWrapper.Nationality na=new RiskRatingRequestWrapper.Nationality();
                            na.CountryDetail=cd;
                            reqObj.Nationality=na;    
                         	
                            
                            reqObj.IdentificationDetails=identDetailsObj;

                           

                            RiskRatingRequestWrapper.ProductSegmentDetail prodSeg= new RiskRatingRequestWrapper.ProductSegmentDetail();
                            prodSeg.ProductSegment= System.Label.Segment;//'TW19';

                            RiskRatingRequestWrapper.ProductSegments prodSegs =new RiskRatingRequestWrapper.ProductSegments();
                            prodSegs.ProductSegmentDetail=prodSeg;


                            reqObj.ProductSegments=prodSegs;

                             
                             
                                
                            List<RiskRatingRequestWrapper.AddressDetail> listAddDetls= new  List<RiskRatingRequestWrapper.AddressDetail>();
                             for(Applicant__c eachAppObj :applicantList){

                                List<ApplAddr__c> listOfAddsAppl =appAddMap.get(eachAppObj.Id);
								if(listOfAddsAppl !=null && !listOfAddsAppl.isEmpty())
                                {
                                  for(ApplAddr__c eachAppAddr: listOfAddsAppl)
                                    {
                                        

                                        if(eachAppObj.Constitution__c == 'INDIVIDUAL' && eachAppAddr.AddrTyp__c =='Residence Address')
                                        {
                                            RiskRatingRequestWrapper.AddressDetail addressDetail=new RiskRatingRequestWrapper.AddressDetail();
                                            addressDetail.AddressLine2=  eachAppAddr.AddrLine2__c!=null?eachAppAddr.AddrLine2__c:'';  
                                            addressDetail.AddressLine1=eachAppAddr.AddrLine1__c!=null?eachAppAddr.AddrLine1__c:'';
                                            addressDetail.State =  eachAppAddr.State__c !=null ? eachAppAddr.State__c: '';
                                            addressDetail.Country='IN';
                                            addressDetail.City= eachAppAddr.City__c !=null ?eachAppAddr.City__c:  '';
                                            
                                            if(eachAppAddr.AddrTyp__c =='Residence Address'){

                                                addressDetail.AddressType= 'Residential';
                                            }
                                            else{
                                                addressDetail.AddressType= '';
                                            }

                                            addressDetail.PinCode=eachAppAddr.Pincode__c !=null ? eachAppAddr.Pincode__c: '';
                                            listAddDetls.add(addressDetail);
                                        }

                                        
                                     }   
                                 }   

                             }

                             
                             RiskRatingRequestWrapper.AddressDetails addDetails=new RiskRatingRequestWrapper.AddressDetails();
                             addDetails.AddressDetail=listAddDetls;
                            
                                reqObj.AddressDetails=addDetails;
                            
                            //Writing Contact Details Start
                            RiskRatingRequestWrapper.ContactDetails conDetailsObj=new  RiskRatingRequestWrapper.ContactDetails();
                                    
                            List<RiskRatingRequestWrapper.ContactDetail> listConDetail=new List<RiskRatingRequestWrapper.ContactDetail>();
                            
                            RiskRatingRequestWrapper.ContactDetail conObj=new RiskRatingRequestWrapper.ContactDetail();
                            conObj.ContactNumber= (app.MobNumber__c!=null)?app.MobNumber__c:'' ;  
                            conObj.ContactType=GlobalConstants.Contact_Type;
                            

                            listConDetail.add(conObj);    
                            
                            RiskRatingRequestWrapper.EmailDetails listEmailsObj=new RiskRatingRequestWrapper.EmailDetails();


                            List<RiskRatingRequestWrapper.EmailDetail> lisEmail=new List<RiskRatingRequestWrapper.EmailDetail>();


                            if(app.EmailId__c !=null){
                                RiskRatingRequestWrapper.EmailDetail emailDe=new RiskRatingRequestWrapper.EmailDetail();
                                emailDe.EmailType=GlobalConstants.EmailType;
                                emailDe.EmailId=String.valueOf(app.EmailId__c)!=null?String.valueOf(app.EmailId__c):'';  
                                lisEmail.add(emailDe);
                            }
                            

                            listEmailsObj.EmailDetail=lisEmail;

                            reqObj.EmailDetails=listEmailsObj;
 
                                   
                            conDetailsObj.ContactDetail =listConDetail;
                            //Writing Contact Details End
                            
                            reqObj.ContactDetails=conDetailsObj;
                            
                            RiskRatingrequestWrapper.Citizenship citi=new  RiskRatingrequestWrapper.Citizenship();    
                            citi.CountryDetail=cd;    
                            reqObj.Citizenship=citi;
                            

                            
                            
                        RiskRatingRequestWrapper.NatureOfBusiness natureOfBus = new RiskRatingRequestWrapper.NatureOfBusiness();
                       

                        List<RiskRatingRequestWrapper.NatureOfBusinessDetail> listNtbs=new List<RiskRatingRequestWrapper.NatureOfBusinessDetail>();
                        RiskRatingRequestWrapper.NatureOfBusinessDetail nobs=new RiskRatingRequestWrapper.NatureOfBusinessDetail();
                        nobs.Business='';   
                        listNtbs.add(nobs);
                        natureOfBus.NatureOfBusinessDetail=listNtbs;
                        reqObj.NatureOfBusiness =natureOfBus;    
                                
                            
                            reqDetailList.add(reqObj);
                            System.debug('reqDetailList:'+reqDetailList.size());
                        
                            }
                            
                            
                        }
                        
                        reqRecObj.RecordRequestDetail=reqDetailList;

						RiskRatingRequestWrapper riskRatingReqWrapper = new RiskRatingRequestWrapper();
						RiskRatingRequestWrapper.RiskProfilingRequest riskProfilereqObj= new RiskRatingRequestWrapper.RiskProfilingRequest();
                    
                        riskProfilereqObj.ApiToken=System.Label.ApiToken;//custom label
                        riskProfilereqObj.RequestId=GlobalUtility.getUniqueNumber(); //globalcons
                        riskProfilereqObj.RiskCalculationFor=System.Label.RiskCalculationFor;//custom label
                        riskProfilereqObj.ParentCompany=System.Label.ParentCompany;
                        
                        
                        reqRecObj.RecordRequestDetail= reqDetailList;
                            
                        riskProfilereqObj.RecordRequestDetails=reqRecObj;
                        riskRatingReqWrapper.RiskProfilingRequest=riskProfilereqObj;
                        
                   
						
                       
                        IntgMsg__c intg=New IntgMsg__c();
                        intg.id=intMsg.id;
                        intg.Req__c = JSON.serialize(riskRatingReqWrapper,true); 
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
            GlobalUtility.logMessage('Error', 'RiskRatingRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    }    
  //***********************************************************************************************************
    public Static Map<String,String> maritalMap =new Map<String,String>{
        'M'=>'M',
            'S'=>'O',
            'W'=>'W'
    };  
}