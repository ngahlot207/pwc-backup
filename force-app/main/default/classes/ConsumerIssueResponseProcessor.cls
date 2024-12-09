public class ConsumerIssueResponseProcessor implements IintMsgCalloutResponseProcessor {
    
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
                
                 BureauPdfQueueable queueableInstance = new BureauPdfQueueable(jsonContent,responses[0],'Consumer API');
                System.enqueueJob(queueableInstance);
                
                
            }
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'ConsumerIssueResponseProcessor class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }	
        
        
    }
    
    //********************************************************************************************************************************************
    public static void BureauSuccess(id refIdset,ConsumerIssueResponseWrapper res){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Bureau__c.SObjectType,BureauRespDtl__c.SObjectType,BureauScore__c.SObjectType,
            BureauEmployment__c.SObjectType,BureauDemography__c.SObjectType,
            BureauHeader__c.SObjectType,BureauEnquiry__c.SObjectType,IntgMsg__c.SObjectType});
        
        List<Bureau__c> Bureau = [SELECT Id, Applicant__c,AckId__c,LoanApp__c, IsLatest__c,BureauAPI__c,LoanApp__r.Product__c FROM Bureau__c WHERE Applicant__c =:refIdSet AND IsLatest__c = true AND BureauAPI__c='Consumer'];
        
        try{
            
            //custom metadata to get the loan type using response accountType number
            Map<String, MultiBureau_Response_Master__mdt> numberToNameMap = new Map<String, MultiBureau_Response_Master__mdt>();
            
            List<MultiBureau_Response_Master__mdt> metadataList = [SELECT Label, Loan_Type__c,ROI__c,Typeofloan__c FROM MultiBureau_Response_Master__mdt];
            
            for(MultiBureau_Response_Master__mdt metadata : metadataList){
                numberToNameMap.put(metadata.Label,metadata);
            }
            
            //updating the parent Bureau if merged response is there
            if(res!=null){
                List<Bureau__c> brulist=New List<Bureau__c>();
                
                if(Bureau!=null){
                    
                    Bureau__c br =new Bureau__c();
                    
                    if(Bureau[0].id!=null){
                        br.id=Bureau[0].id;
                    }
                    
                    br.Source__c=sourceMap.containsKey(res.FINISHED[0].BUREAU)?sourceMap.get(res.FINISHED[0].BUREAU):'';
                    br.Product__c=(res.FINISHED[0]!=null && String.isNotblank(res.FINISHED[0].PRODUCT))?res.FINISHED[0].PRODUCT:'';
                        
                    if(res.FINISHED[0].JSONResponseObject!=null){
                        
                        //Score
                        if(res.FINISHED[0].JSONResponseObject.scoreList[0]!=null && String.isNotblank(res.FINISHED[0].JSONResponseObject.scoreList[0].score)){
                            br.Score__c=res.FINISHED[0].JSONResponseObject.scoreList[0].score;
                        }
                        
                        //Total Enquiries
                        if(res.FINISHED[0].JSONResponseObject.enquiryList!=null){
                            br.TotalEnquiries__c=res.FINISHED[0].JSONResponseObject.enquiryList.size();
                        }
                        
                        //Report date
                        if(res.FINISHED[0].JSONResponseObject.header!=null 
                           && String.isNotblank(res.FINISHED[0].JSONResponseObject.header.dateProceed)){
                            br.Report_date__c=IntegrationUtility.getDate(res.FINISHED[0].JSONResponseObject.header.dateProceed);
                        }
                        
                        //Awadhesh Jaiswal Input
                        if(res.FINISHED[0].JSONResponseObject.accountList!=null){
                            
                            Integer totalNoLiveLoan = 0;
                            Decimal Totalloanexposure=0;
                            Integer securedloanexposure = 0;
                            Integer Unsecuredloanexposure = 0;
                            Integer mortgageloanexposure = 0;
                            Integer creditCardOutstanding = 0;
                            Integer liveLoanOverdue = 0;
                            Integer creditCardOverdue=0;
                            
                            Map<String,BureauConsumerDPD__c> consumerBureauDPDMap = BureauConsumerDPD__c.getAll();
                            List<Integer> allDPDValues = new List<Integer>(); 
                            List<Integer> last12MonthsDPDValues = new List<Integer>();
                            
                            for(ConsumerIssueResponseWrapper.AccountList accList:res.FINISHED[0].JSONResponseObject.accountList){
                                
                                 //Total No of Live loans
                                if(String.isBlank(accList.dateClosed)){
                                    
                                  if(string.isNotblank(accList.accountType)){
                                        
                                        if(numberToNameMap.containsKey(accList.accountType) &&
                                           numberToNameMap.get(accList.accountType).Loan_Type__c.tolowerCase()!='secured credit card' &&
                                           numberToNameMap.get(accList.accountType).Loan_Type__c.tolowerCase()!='credit card'){
                                            
                                               totalNoLiveLoan++;
                                        }
                                    }
                                    else{
                                        totalNoLiveLoan++;
                                    }
                                    
                                 }
                                
                                //Total Live loan exposure
                                if(String.isBlank(accList.dateClosed) && String.isNotblank(accList.currentBalance)){
                                    
                                    if(string.isNotblank(accList.accountType)){
                                        
                                        if(numberToNameMap.containsKey(accList.accountType) &&
                                           numberToNameMap.get(accList.accountType).Loan_Type__c.tolowerCase()!='secured credit card' &&
                                           numberToNameMap.get(accList.accountType).Loan_Type__c.tolowerCase()!='credit card'){
                                              
                                               Totalloanexposure+=Decimal.valueOf(accList.currentBalance);
                                          }
                                        
                                    }else{
                                        Totalloanexposure+=Decimal.valueOf(accList.currentBalance);
                                    }
                                }
                                
                                
                                // Total Live Secured loan exposure && Total Live Unsecured loan exposure && Total Live Mortgage loan exposure
                                
                                if(String.isBlank(accList.dateClosed) && string.isNotblank(accList.accountType) 
                                   && String.isNotblank(accList.currentBalance) && numberToNameMap.containsKey(accList.accountType)){
                                    
                                       //Total Live Secured loan exposure
                                    if(numberToNameMap.get(accList.accountType).Loan_Type__c.tolowerCase()!='secured credit card' &&
                                       numberToNameMap.get(accList.accountType).Loan_Type__c.tolowerCase()!='credit card' &&
                                       numberToNameMap.get(accList.accountType).Typeofloan__c=='Secured'){
                                        
                                           securedloanexposure+=Integer.valueof(accList.currentBalance);
                                    }
                                       
                                        //Total Live Unsecured loan exposure
                                   else if(numberToNameMap.get(accList.accountType).Loan_Type__c.tolowerCase()!='secured credit card' &&
                                       numberToNameMap.get(accList.accountType).Loan_Type__c.tolowerCase()!='credit card' &&
                                       numberToNameMap.get(accList.accountType).Typeofloan__c=='Unsecured'){
                                        
                                           Unsecuredloanexposure+=Integer.valueof(accList.currentBalance);
                                    }
                                       
                                       //Total Live Mortgage loan exposure
                                   else if(numberToNameMap.get(accList.accountType).Typeofloan__c=='Mortgage'){
                                        
                                           mortgageloanexposure+=Integer.valueof(accList.currentBalance);
                                    }
                                    
                                }
                                
                                //Total Credit card outstanding
                                if(String.isBlank(accList.dateClosed) && string.isNotblank(accList.accountType)
                                  && String.isNotblank(accList.currentBalance) && numberToNameMap.containsKey(accList.accountType)){
                                    
                                      
                                      if(numberToNameMap.get(accList.accountType).Loan_Type__c.tolowerCase()=='secured credit card' ||
                                       numberToNameMap.get(accList.accountType).Loan_Type__c.tolowerCase()=='credit card'){
                                        
                                           creditCardOutstanding+=Integer.valueof(accList.currentBalance);
                                    }
                                }
                                
                                //Total Live Loan Overdue
                                if(String.isBlank(accList.dateClosed) && string.isNotblank(accList.overdueAmount)){
                                    
                                    if(string.isNotblank(accList.accountType)){
                                        
                                        if(numberToNameMap.containsKey(accList.accountType) &&
                                           numberToNameMap.get(accList.accountType).Loan_Type__c.tolowerCase()!='secured credit card' &&
                                           numberToNameMap.get(accList.accountType).Loan_Type__c.tolowerCase()!='credit card'){
                                            
                                               liveLoanOverdue+=Integer.valueOf(accList.overdueAmount);
                                        }
                                    }else{
                                        liveLoanOverdue+=Integer.valueOf(accList.overdueAmount);
                                    }
                                    
                                }
                                
                                //Total Live Credit Card Overdue
                                if(String.isBlank(accList.dateClosed) && string.isNotblank(accList.overdueAmount) &&
                                   string.isNotblank(accList.accountType) && numberToNameMap.containsKey(accList.accountType)){
                                       
                                       if(numberToNameMap.get(accList.accountType).Loan_Type__c.tolowerCase()=='secured credit card' ||
                                          numberToNameMap.get(accList.accountType).Loan_Type__c.tolowerCase()=='credit card'){
                                           creditCardOverdue=Integer.valueOf(accList.overdueAmount);
                                       }
                                    
                                    
                                }
                                
                                //Max current DPD of all Live Facilities
                                if(String.isBlank(accList.dateClosed) && 
                                   (string.isNotblank(accList.paymentHistory1) || string.isNotblank(accList.paymentHistory2))){
                                    
                                       String payHistory;
                                       
                                       if(string.isNotblank(accList.paymentHistory1)){
                                          payHistory+= accList.paymentHistory1;
                                       }
                                       
                                       if(string.isNotblank(accList.paymentHistory2)){
                                           payHistory+= accList.paymentHistory2;
                                       }
                                       
                                       if(string.isNotblank(payHistory)){
                                           List<String> dpdValues = splitStringByFixedLength(payHistory, 3);
                                           
                                           for (String dpd : dpdValues) {
                                               allDPDValues.add(getDPDValue(dpd, consumerBureauDPDMap));
                                           }
                                       }
                                }
                                
                                //Max DPD in last 12 months of all Live Facilities
                                if(String.isBlank(accList.dateClosed) && string.isNotblank(accList.paymentHistory1)){
                                    
                                    Integer count=0;
                                    List<String> dpdValues = splitStringByFixedLength(accList.paymentHistory1, 3);
                                    
                                    for(String dpd : dpdValues){
                                        
                                        if(count<=12){
                                            last12MonthsDPDValues.add(getDPDValue(dpd, consumerBureauDPDMap));
                                        }
                                    }
                                }
                            }
                            
                            br.Totalliveloan__c=totalNoLiveLoan;
                            br.Totalloanexposure__c=Totalloanexposure;
                            br.Totalsecuredloan__c=securedloanexposure;
                            br.Totalunsecuredloan__c=Unsecuredloanexposure;
                            br.TotalMortgageloan__c=mortgageloanexposure;
                            br.Totalcreditcardoutstanding__c=creditCardOutstanding;
                            br.Totaloanoverdue__c=liveLoanOverdue;
                            br.Totalcreditcardoverdue__c=creditCardOverdue;
                            br.MaxcurrentDPDLiveFacilities__c=getHighestValue(allDPDValues);
                            br.MaxDPDlast12months__c=getHighestValue(last12MonthsDPDValues);
                        }
                        
                        //Awadhesh Jaiswal Input
                        if(res.FINISHED[0].JSONResponseObject.enquiryList!=null){
                            
                            // Calculate the current date and the date 30 days ago
                            Date currentDate = Date.today();
                            Date thirtyDaysAgo = currentDate.addDays(-30);
                            
                            
                            Integer enquiriesWithinLast30Days = 0;
                            Integer mortgageenquiriesWithinLast30Days = 0;
                            Integer UnsecuredenquiriesWithinLast30Days = 0;
                            
                            for(ConsumerIssueResponseWrapper.EnquiryList enquiry :res.FINISHED[0].JSONResponseObject.enquiryList){
                                
                                if(String.isNotblank(enquiry.dateReported)){
                                    
                                    Date enquiryDate =IntegrationUtility.getDate(enquiry.dateReported);
                                    
                                    //Total Enquiries in last 30 days
                                    if (enquiryDate >= thirtyDaysAgo && enquiryDate <= currentDate) {
                                        enquiriesWithinLast30Days++;
                                    }
                                    
                                    //Total Mortgage Enquiries in last 30 days
                                    if(String.isNotblank(enquiry.enquiryPurpose) && numberToNameMap.containsKey(enquiry.enquiryPurpose)
                                      && numberToNameMap.get(enquiry.enquiryPurpose).Typeofloan__c=='Mortgage' &&
                                      enquiryDate >= thirtyDaysAgo && enquiryDate <= currentDate){
                                        
                                          mortgageenquiriesWithinLast30Days++;
                                    }
                                    
                                    //Total Unsecured Enquiries in last 30 days
                                    if(String.isNotblank(enquiry.enquiryPurpose) && numberToNameMap.containsKey(enquiry.enquiryPurpose)
                                      && numberToNameMap.get(enquiry.enquiryPurpose).Typeofloan__c=='Unsecured' &&
                                      enquiryDate >= thirtyDaysAgo && enquiryDate <= currentDate){
                                        
                                          UnsecuredenquiriesWithinLast30Days++;
                                    }
                                }
                            }
                            
                            br.TotalEnquirieslast30day__c=enquiriesWithinLast30Days;
                            br.TotalMortgageEnqlst30days__c=mortgageenquiriesWithinLast30Days;
                            br.TotalUnsecuredEnqlast30day__c=UnsecuredenquiriesWithinLast30Days;
                        }
                        
                    }
                   
                    
                   
                     brulist.add(br);
                    
                    if(brulist!=null){
                        List<string> fieldNamesList = New List<string>{'Source__c','Product__c','TotalEnquiries__c','Score__c','Report_date__c','Totalliveloan__c','Totalloanexposure__c',
                            'Totalsecuredloan__c','Totalunsecuredloan__c','TotalMortgageloan__c',
                            'Totalcreditcardoutstanding__c','Totaloanoverdue__c',
                            'Totalcreditcardoverdue__c','TotalEnquirieslast30day__c',
                            'TotalMortgageEnqlst30days__c','TotalUnsecuredEnqlast30day__c','MaxcurrentDPDLiveFacilities__c','MaxDPDlast12months__c'};
                                String sObjectName = 'Bureau__c';
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                        fflib_SecurityUtils.checkUpdate(objType,fieldNamesList); 
                        uow.registerDirty(brulist);
                    }
                    uow.commitWork();
                }
                
            }
            
            
            //Creating BureauScore__c record based on response scoreList
            if(res.FINISHED[0].JSONResponseObject.scoreList!=null){
                List<BureauScore__c> oldBureauScore=[Select id,Applicant__c,LoanApp__c,IsLatest__c from BureauScore__c Where IsLatest__c=true AND Applicant__c=:Bureau[0].Applicant__c AND LoanApp__c=:Bureau[0].LoanApp__c];
                
                if(!oldBureauScore.isempty()){
                    IsLatestFalse(oldBureauScore,'IsLatest__c');
                }
                List<BureauScore__c> BureauScoreList =new List<BureauScore__c>();
                
                for(ConsumerIssueResponseWrapper.ScoreList scorelist:res.FINISHED[0].JSONResponseObject.scoreList){
                    BureauScore__c bs=new BureauScore__c();
                    
                    bs.Bureau__c=Bureau[0].Id!=null?Bureau[0].Id:'';
                    bs.Applicant__c=Bureau[0].Applicant__c!=null?Bureau[0].Applicant__c:'';
                    bs.LoanApp__c=Bureau[0].LoanApp__c;    
                    bs.IsLatest__c=true;
                    
                    if(!string.isBlank(scorelist.score)){
                        bs.Score__c=scorelist.score;
                    }
                    
                    if(!string.isBlank(scorelist.reasonCode1)){
                        bs.ResCode1__c=Decimal.ValueOf(scorelist.reasonCode1);
                    }
                    
                    if(!string.isBlank(scorelist.reasonCode2)){
                        bs.ResCode2__c=Decimal.ValueOf(scorelist.reasonCode2);
                    }
                    
                    if(!string.isBlank(scorelist.scoreCardVersion)){
                        bs.ScoreCardVer__c=Decimal.ValueOf(scorelist.scoreCardVersion);
                    }
                    
                    if(!string.isBlank(scorelist.scoreCardName)){
                        bs.ScoreCardName__c=scorelist.scoreCardName;
                    }
                    
                    if(!string.isBlank(scorelist.scoreDate)){
                        bs.ScoreDate__c=IntegrationUtility.getDate(scorelist.scoreDate);
                    }
                    
                    if(!string.isBlank(scorelist.scoreName)){
                        bs.ScoreName__c=scorelist.scoreName;
                    }
                    BureauScoreList.add(bs);
                }
                
                if(BureauScoreList!=null){
                    List<string> fieldNamesList = New List<string>{'Bureau__c','Applicant__c','LoanApp__c','IsLatest__c','Score__c','ResCode1__c',
                        'ResCode2__c','ScoreCardVer__c','ScoreCardName__c','ScoreDate__c',
                        'ScoreName__c'};
                            String sObjectName = 'BureauScore__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(BureauScoreList);
                }
                
            } 
            
            //Creating BureauEmployment__c record based on response employmentList
            if(res.FINISHED[0].JSONResponseObject.employmentList!=null){
                
                List<BureauEmployment__c> oldBureauEmployment=[Select id,Applicant__c,LoanApp__c,IsLatest__c from BureauEmployment__c Where IsLatest__c=true AND Applicant__c=:Bureau[0].Applicant__c AND LoanApp__c=:Bureau[0].LoanApp__c];
                
                if(!oldBureauEmployment.isempty()){
                    IsLatestFalse(oldBureauEmployment,'IsLatest__c');
                }
                List<BureauEmployment__c> BureauEmploymentList =new List<BureauEmployment__c>();
                
                for(ConsumerIssueResponseWrapper.EmploymentList employmentList:res.FINISHED[0].JSONResponseObject.employmentList){
                    BureauEmployment__c be=new BureauEmployment__c();
                    
                    be.Bureau__c=Bureau[0].Id!=null?Bureau[0].Id:'';
                    be.Applicant__c=Bureau[0].Applicant__c!=null?Bureau[0].Applicant__c:'';
                    be.LoanApp__c=Bureau[0].LoanApp__c;    
                    be.IsLatest__c=true;
                    
                    if(!string.isblank(employmentList.occupationCode)){
                        be.OccupationCode__c=employmentList.occupationCode;
                    }
                    
                    if(!string.isblank(employmentList.accountType)){
                        be.AccCode__c=employmentList.accountType;
                        be.AccountType__c=numberToNameMap.ContainsKey(be.AccCode__c)?numberToNameMap.get(be.AccCode__c).Loan_Type__c:'';
                    }
                    if(!string.isblank(employmentList.dateReported)){
                        be.DateReported__c=IntegrationUtility.getDate(employmentList.dateReported);
                    }
                    BureauEmploymentList.add(be);
                    
                }
                
                if(BureauEmploymentList!=null){
                    List<string> fieldNamesList = New List<string>{'Bureau__c','AccCode__c','Applicant__c','LoanApp__c','IsLatest__c','OccupationCode__c','AccountType__c','DateReported__c'};
                        String sObjectName = 'BureauEmployment__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(BureauEmploymentList);
                }
                
            }
            
            //Creating BureauDemography__c record with Consumer Bureau Address recordtype based on response addressList
            
            if(res.FINISHED[0].JSONResponseObject.addressList!=null){
                List<BureauDemography__c> oldBureauDemographyAddress=[Select id,Applicant__c,LoanApp__c,IsLatest__c,recordtype.name from BureauDemography__c 
                                                                      Where IsLatest__c=true AND Applicant__c=:Bureau[0].Applicant__c AND 
                                                                      LoanApp__c=:Bureau[0].LoanApp__c AND recordtype.name='Consumer Bureau Address'];
                
                if(!oldBureauDemographyAddress.isempty()){
                    IsLatestFalse(oldBureauDemographyAddress,'IsLatest__c');
                }
                
                Id recordTypeId =Schema.SObjectType.BureauDemography__c.getRecordTypeInfosByDeveloperName().get('BureauAddress').getRecordTypeId(); 
                List<BureauDemography__c> BureauDemographyaddressList =new List<BureauDemography__c>();
                
                for(ConsumerIssueResponseWrapper.AddressList addressList:res.FINISHED[0].JSONResponseObject.addressList){
                    BureauDemography__c bd=new BureauDemography__c();
                    
                    bd.Bureau__c=Bureau[0].Id!=null?Bureau[0].Id:'';
                    bd.Applicant__c=Bureau[0].Applicant__c!=null?Bureau[0].Applicant__c:'';
                    bd.LoanApp__c=Bureau[0].LoanApp__c;    
                    bd.IsLatest__c=true;
                    bd.RecordTypeId=recordTypeId;
                    
                    if(!String.isblank(addressList.addressCategory)){
                        bd.AddressCategory__c=addressList.addressCategory;
                    }
                    
                    if(!String.isblank(addressList.addressLine1)){
                        bd.Address1__c=addressList.addressLine1;
                    }
                    if(!String.isblank(addressList.addressLine2)){
                        bd.Address2__c=addressList.addressLine2;
                    }
                    if(!String.isblank(addressList.addressLine3)){
                        bd.Address3__c=addressList.addressLine3;
                    }
                    if(!String.isblank(addressList.addressLine4)){
                        bd.Address4__c=addressList.addressLine4;
                    }
                    if(!String.isblank(addressList.addressLine5)){
                        bd.Address5__c=addressList.addressLine5;
                    }
                    if(!String.isblank(addressList.dateReported)){
                        bd.DateRpt__c=IntegrationUtility.getDate(addressList.dateReported);
                    }
                    if(!String.isblank(addressList.pinCode)){
                        bd.Pincode__c=Decimal.valueOf(addressList.pinCode);
                    }
                    if(!String.isblank(addressList.stateCode)){
                        bd.StateCode__c=addressList.stateCode;
                    }
                    if(!String.isblank(addressList.enrichedThroughtEnquiry)){
                        bd.EnrichedEnquiry__c=addressList.enrichedThroughtEnquiry;
                    }
                    if(!String.isblank(addressList.residenceCode)){
                           bd.ResiCode__c=addressList.residenceCode;
                       }
                    
                    BureauDemographyaddressList.add(bd);
                    
                }
                
                if(BureauDemographyaddressList!=null){
                    List<string> fieldNamesList = New List<string>{'Bureau__c','Applicant__c','LoanApp__c','IsLatest__c','RecordTypeId','AddressCategory__c','Address1__c',
                        'Address2__c','Address3__c','Address4__c','Address5__c','DateRpt__c','Pincode__c','StateCode__c','EnrichedEnquiry__c','ResiCode__c'};
                            String sObjectName = 'BureauDemography__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(BureauDemographyaddressList);
                }
                
            }
            
            
            //Creating BureauDemography__c record with Consumer Bureau Name recordtype based on response name
            if(res.FINISHED[0].JSONResponseObject.name!=null){
                
                List<BureauDemography__c> oldBureauDemographyname=[Select id,Applicant__c,LoanApp__c,IsLatest__c,recordtype.name from BureauDemography__c 
                                                                   Where IsLatest__c=true AND Applicant__c=:Bureau[0].Applicant__c AND 
                                                                   LoanApp__c=:Bureau[0].LoanApp__c AND recordtype.name='Consumer Bureau Name'];
                
                if(!oldBureauDemographyname.isempty()){
                    IsLatestFalse(oldBureauDemographyname,'IsLatest__c');
                }
                Id recordTypeId =Schema.SObjectType.BureauDemography__c.getRecordTypeInfosByDeveloperName().get('BureauName').getRecordTypeId();
                List<BureauDemography__c> BureauDemographynameList =new List<BureauDemography__c>();
                
                ConsumerIssueResponseWrapper.name nameList=res.FINISHED[0].JSONResponseObject.name;
                BureauDemography__c bd=new BureauDemography__c();
                
                bd.Bureau__c=Bureau[0].Id!=null?Bureau[0].Id:'';
                bd.Applicant__c=Bureau[0].Applicant__c!=null?Bureau[0].Applicant__c:'';
                bd.LoanApp__c=Bureau[0].LoanApp__c;    
                bd.IsLatest__c=true;
                bd.RecordTypeId=recordTypeId!=null?recordTypeId:'';
                
                if(!string.isblank(nameList.name1)){
                    bd.FirstName__c=nameList.name1;
                }
                if(!string.isblank(nameList.name2)){
                    bd.MiddleName__c=namelist.name2;
                }
                if(!string.isblank(nameList.name3)){
                    bd.LastName__c=nameList.name3;
                }
                if(!string.isblank(nameList.dob)){
                    bd.Dob__c=IntegrationUtility.getDate(nameList.dob);
                }
                if(!string.isblank(nameList.gender)){
                       bd.Gender__c=nameList.gender;
                   }
                
                BureauDemographynameList.add(bd);
                if(BureauDemographynameList!=null){
                    List<string> fieldNamesList = New List<string>{'Bureau__c','Applicant__c','LoanApp__c','IsLatest__c','RecordTypeId','FirstName__c',
                        'MiddleName__c','LastName__c','Dob__c','Gender__c'};
                            String sObjectName = 'BureauDemography__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(BureauDemographynameList);
                }
            }
            
            //Creating BureauHeader__c record  based on response header
            if(res.FINISHED[0].JSONResponseObject.header!=null){
                List<BureauHeader__c> oldBureauHeader=[Select id,Applicant__c,LoanApp__c,IsLatest__c from BureauHeader__c Where IsLatest__c=true AND Applicant__c=:Bureau[0].Applicant__c AND LoanApp__c=:Bureau[0].LoanApp__c];
                
                if(!oldBureauHeader.isempty()){
                    IsLatestFalse(oldBureauHeader,'IsLatest__c');
                }
                List<BureauHeader__c> BureauHeaderList =new List<BureauHeader__c>();
                
                ConsumerIssueResponseWrapper.innerheader headertList = res.FINISHED[0].JSONResponseObject.header;
                BureauHeader__c bh=new BureauHeader__c();
                
                bh.Bureau__c=Bureau[0].Id!=null?Bureau[0].Id:'';
                bh.Applicant__c=Bureau[0].Applicant__c!=null?Bureau[0].Applicant__c:'';
                bh.LoanApp__c=Bureau[0].LoanApp__c;    
                bh.IsLatest__c=true;
                
                if(!string.isblank(headertList.dateProceed)){
                     bh.DateProceed__c=IntegrationUtility.getDate(headertList.dateProceed);
                }
                if(!string.isblank(headertList.enquiryControlNumber)){
                    bh.EnqContNum__c=Decimal.valueof(headertList.enquiryControlNumber);
                }
                if(!string.isblank(headertList.enquiryMemberUserID)){
                    bh.EnqMemberUserID__c=headertList.enquiryMemberUserID;
                }
                if(!string.isblank(headertList.memberReferenceNumber)){
                    bh.MemberRefNum__c=Decimal.valueof(headertList.memberReferenceNumber);
                }
                if(!string.isblank(headertList.subjectReturnCode)){
                    bh.SubRtnCode__c=Decimal.valueof(headertList.subjectReturnCode);
                }
                if(!string.isblank(headertList.timeProceed)){
                    bh.TimeProceed__c=IntegrationUtility.timeProcess(headertList.timeProceed);
                }
                if(!string.isblank(headertList.version)){
                       bh.Version__c=headertList.version;
                   }
                BureauHeaderList.add(bh);
                
                if(BureauHeaderList!=null){
                    List<string> fieldNamesList = New List<string>{'Bureau__c','Applicant__c','LoanApp__c','IsLatest__c','DateProceed__c','EnqContNum__c',
                        'EnqMemberUserID__c','MemberRefNum__c','SubRtnCode__c','TimeProceed__c','Version__c'};
                            String sObjectName = 'BureauHeader__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(BureauHeaderList);
                }
                
            }
            
            //Creating BureauDemography__c record with Consumer Bureau Phone recordtype based on response phoneList
            if(res.FINISHED[0].JSONResponseObject.phoneList!=null){
                
                List<BureauDemography__c> oldBureauDemographyphone=[Select id,Applicant__c,LoanApp__c,IsLatest__c,recordtype.name from BureauDemography__c 
                                                                    Where IsLatest__c=true AND Applicant__c=:Bureau[0].Applicant__c AND 
                                                                    LoanApp__c=:Bureau[0].LoanApp__c AND recordtype.name='Consumer Bureau Phone'];
                
                if(!oldBureauDemographyphone.isempty()){
                    IsLatestFalse(oldBureauDemographyphone,'IsLatest__c');
                }
                
                Id recordTypeId =Schema.SObjectType.BureauDemography__c.getRecordTypeInfosByDeveloperName().get('BureauPhone').getRecordTypeId(); 
                List<BureauDemography__c> BureauDemographyphoneList =new List<BureauDemography__c>();
                
                for(ConsumerIssueResponseWrapper.PhoneList phoneList:res.FINISHED[0].JSONResponseObject.phoneList){
                    BureauDemography__c bd=new BureauDemography__c();
                    
                    bd.Bureau__c=Bureau[0].Id!=null?Bureau[0].Id:'';
                    bd.Applicant__c=Bureau[0].Applicant__c!=null?Bureau[0].Applicant__c:'';
                    bd.LoanApp__c=Bureau[0].LoanApp__c;    
                    bd.IsLatest__c=true;
                    bd.RecordTypeId=recordTypeId;
                    
                    if(!string.isblank(phoneList.telephoneNumber)){
                        bd.TeleNumber__c=phoneList.telephoneNumber;
                    }
                    if(!string.isblank(phoneList.telephoneType)){
                        bd.TeleType__c=Decimal.Valueof(phoneList.telephoneType);
                    }
                    if(!string.isblank(phoneList.enrichEnquiryForPhone)){
                           bd.EnrichEnquiryForPhone__c=phoneList.enrichEnquiryForPhone;
                       }
                    BureauDemographyphoneList.add(bd);
                }
                if(BureauDemographyphoneList!=null){
                    List<string> fieldNamesList = New List<string>{'Bureau__c','Applicant__c','LoanApp__c','IsLatest__c','RecordTypeId','TeleNumber__c',
                        'TeleType__c','EnrichEnquiryForPhone__c'};
                            String sObjectName = 'BureauDemography__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(BureauDemographyphoneList);
                }
            }
            
            //Creating BureauDemography__c record with Consumer Bureau ID recordtype based on response idList
            if(res.FINISHED[0].JSONResponseObject.idList!=null){
                
                List<BureauDemography__c> oldBureauDemographyid=[Select id,Applicant__c,LoanApp__c,IsLatest__c,recordtype.name from BureauDemography__c 
                                                                 Where IsLatest__c=true AND Applicant__c=:Bureau[0].Applicant__c AND 
                                                                 LoanApp__c=:Bureau[0].LoanApp__c AND recordtype.name='Consumer Bureau ID'];
                
                if(!oldBureauDemographyid.isempty()){
                    IsLatestFalse(oldBureauDemographyid,'IsLatest__c');
                }
                
                Id recordTypeId =Schema.SObjectType.BureauDemography__c.getRecordTypeInfosByDeveloperName().get('BureauID').getRecordTypeId(); 
                List<BureauDemography__c> BureauDemographyidList =new List<BureauDemography__c>();
                
                for(ConsumerIssueResponseWrapper.IdList idList:res.FINISHED[0].JSONResponseObject.idList){
                    BureauDemography__c bd=new BureauDemography__c();
                    
                    bd.Bureau__c=Bureau[0].Id!=null?Bureau[0].Id:'';
                    bd.Applicant__c=Bureau[0].Applicant__c!=null?Bureau[0].Applicant__c:'';
                    bd.LoanApp__c=Bureau[0].LoanApp__c;    
                    bd.IsLatest__c=true;
                    bd.RecordTypeId=recordTypeId;
                    
                    if(!string.isblank(idList.expiryDate)){
                        bd.ExpiryDate__c=IntegrationUtility.getDate(idList.expiryDate);
                    }
                    if(!string.isblank(idList.idType)){
                        bd.IdType__c=idList.idType;
                    }
                    if(!string.isblank(idList.idValue)){
                        bd.IdValue__c=idList.idValue;
                    }
                    BureauDemographyidList.add(bd);
                }
                if(BureauDemographyidList!=null){
                    List<string> fieldNamesList = New List<string>{'Bureau__c','Applicant__c','LoanApp__c','IsLatest__c','RecordTypeId','ExpiryDate__c',
                        'IdType__c','IdValue__c'};
                            String sObjectName = 'BureauDemography__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(BureauDemographyidList);
                }
            }
            
            
            //Creating BureauEnquiry__c record  based on response enquiryList
            
            if(res.FINISHED[0].JSONResponseObject.enquiryList!=null){
                List<BureauEnquiry__c> oldBureauEnquiry=[Select id,Applicant__c,LoanApp__c,IsLatest__c from BureauEnquiry__c Where IsLatest__c=true AND Applicant__c=:Bureau[0].Applicant__c AND LoanApp__c=:Bureau[0].LoanApp__c];
                
                if(!oldBureauEnquiry.isempty()){
                    IsLatestFalse(oldBureauEnquiry,'IsLatest__c');
                }
                List<BureauEnquiry__c> BureauEnquiryList =new List<BureauEnquiry__c>();
                
                for(ConsumerIssueResponseWrapper.EnquiryList enquiryList:res.FINISHED[0].JSONResponseObject.enquiryList){
                    BureauEnquiry__c benq=new BureauEnquiry__c();
                    
                    benq.Bureau__c=Bureau[0].Id!=null?Bureau[0].Id:'';
                    benq.Applicant__c=Bureau[0].Applicant__c!=null?Bureau[0].Applicant__c:'';
                    benq.LoanApp__c=Bureau[0].LoanApp__c;    
                    benq.IsLatest__c=true;
                    
                    if(!string.isblank(enquiryList.dateReported)){
                        benq.DateReported__c=IntegrationUtility.getDate(enquiryList.dateReported);
                    }
                    if(!string.isblank(enquiryList.enquiryAmount)){
                        benq.EnqAmount__c=Decimal.valueof(enquiryList.enquiryAmount);
                    }
                    if(!string.isblank(enquiryList.enquiryPurpose)){
                        benq.EnqPurposeCode__c=enquiryList.enquiryPurpose;
                        benq.EnquiryPurpose__c=numberToNameMap.ContainsKey(enquiryList.enquiryPurpose)?numberToNameMap.get(enquiryList.enquiryPurpose).Loan_Type__c:'';
                    }
                    if(!string.isblank(enquiryList.reportingMemberShortName)){
                        benq.ReportingName__c=enquiryList.reportingMemberShortName;
                    }
                    BureauEnquiryList.add(benq);
                }
                if(BureauEnquiryList!=null){
                    List<string> fieldNamesList = New List<string>{'Bureau__c','Applicant__c','LoanApp__c','IsLatest__c','DateReported__c','EnqAmount__c',
                        'EnquiryPurpose__c','ReportingName__c','EnqPurposeCode__c'};
                            String sObjectName = 'BureauEnquiry__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(BureauEnquiryList);
                }
            }
            
            
            //Creating BureauRespDtl__c record based on response account list 
            
            if(res.FINISHED[0].JSONResponseObject.accountList!=null){
                
                List<BureauRespDtl__c> oldBureauResp=[Select id,Applicant__c,LoanApplication__c,IsLatest__c from BureauRespDtl__c Where IsLatest__c=true AND Applicant__c=:Bureau[0].Applicant__c AND LoanApplication__c=:Bureau[0].LoanApp__c ];
                
                if(!oldBureauResp.isEmpty()){
                    IsLatestFalse(oldBureauResp,'IsLatest__c');
                }
                Id recordTypeId =Schema.SObjectType.BureauRespDtl__c.getRecordTypeInfosByDeveloperName().get('Consumer_Obligation').getRecordTypeId(); 
                
                List<BureauRespDtl__c> BureauRespDtl =new List<BureauRespDtl__c>();
                
                for(ConsumerIssueResponseWrapper.AccountList AccListData:res.FINISHED[0].JSONResponseObject.accountList){
                    
                    BureauRespDtl__c ao=new BureauRespDtl__c();
                    
                    ao.Bureau__c=Bureau[0].Id!=null?Bureau[0].Id:'';
                    ao.Applicant__c=Bureau[0].Applicant__c!=null?Bureau[0].Applicant__c:'';
                    ao.LoanApplication__c=Bureau[0].LoanApp__c;    
                    ao.IsLatest__c=true;
                    ao.RecordTypeId=recordTypeId!=null?recordTypeId:'';
                    
                    ao.Source__c=sourceMap.containsKey(res.FINISHED[0].BUREAU)?sourceMap.get(res.FINISHED[0].BUREAU):'';
                    
                    
                    
                    if(!string.isBlank(AccListData.accountType)){
                        ao.AccCode__c=AccListData.accountType;
                        ao.NatureOfLoan__c=numberToNameMap.containsKey(AccListData.accountType)?numberToNameMap.get(AccListData.accountType).Loan_Type__c:'';
                    }
                    
                    if(!string.isBlank(AccListData.ownershipIndicator)){
                        ao.OwnershipIndicator__c=AccListData.ownershipIndicator;
                        ao.LoanCapacity__c=ownershipIndicatorMap.containsKey(AccListData.ownershipIndicator)?ownershipIndicatorMap.get(AccListData.ownershipIndicator):'';
                    }
                    
                    if(!string.isBlank(AccListData.reportingMemberShortName)){
                        ao.FinancierName__c=AccListData.reportingMemberShortName;
                    }
                    
                    if(!string.isBlank(AccListData.dateOpenedOrDisbursed)){ 
                        ao.DisbursalDate__c =IntegrationUtility.getDate(AccListData.dateOpenedOrDisbursed);
                        
                        
                    }
                    if(!string.isBlank(AccListData.dateClosed)){
                        ao.CloseDate__c = IntegrationUtility.getDate(AccListData.dateClosed);
                        
                    }
                    
                    
                    if(!string.isBlank(AccListData.highCreditOrSanctionedAmount)){
                        ao.LoanAmount__c=Decimal.ValueOf(AccListData.highCreditOrSanctionedAmount);
                    } 
                    if(!string.isBlank(AccListData.currentBalance)){
                        ao.CurrentOs__c=Decimal.ValueOf(AccListData.currentBalance);
                    }
                    if(!string.isBlank(AccListData.emiAmount)){
                        ao.EMISource__c='Bureau';
                        ao.EMI__c=Decimal.ValueOf(AccListData.emiAmount);
                    }
                    else{
                        if(AccListData.repaymentTenure!=null && AccListData.highCreditOrSanctionedAmount!=null && AccListData.accountType!=null){
                            string natureOfLoanNumber=AccListData.accountType;
                            system.debug(natureOfLoanNumber);
                            MultiBureau_Response_Master__mdt natureOfLoanName = numberToNameMap.get(natureOfLoanNumber);
                            Double interest = natureOfLoanName.ROI__c!=null?Double.valueOf(natureOfLoanName.ROI__c) / Double.valueOf(100):null;
                            String tenureStr = AccListData.repaymentTenure;
                            Integer tenure = Integer.valueOf(tenureStr);
                            
                            String loanAmountStr = AccListData.highCreditOrSanctionedAmount;
                            Decimal loanAmount = Decimal.valueOf(loanAmountStr);
                            
                            if(interest!=null && tenure !=null && loanAmount !=null){
                                Decimal emi = loanAmount * (interest / 12) * Math.pow((1 + interest / 12), tenure) / (Math.pow((1 + interest / 12), tenure) - 1);
                                System.debug(emi.setScale(0, RoundingMode.HALF_UP));
                                ao.EMISource__c='Estimated';
                                ao.EMI__c=emi.setScale(0, RoundingMode.HALF_UP);
                            }
                        }
                    }
                    
                    
                    
                    if(!string.isBlank(AccListData.repaymentTenure)){
                        ao.Tenure__c=Decimal.ValueOf(AccListData.repaymentTenure);
                    }
                    if(!string.isBlank(AccListData.paymentHistory1)){
                        ao.PayHis1__c = AccListData.paymentHistory1;
                    }
                    if(!string.isBlank(AccListData.paymentHistory2)){
                        ao.PayHis2__c = AccListData.paymentHistory2;
                    }
                    if(!string.isBlank(AccListData.creditLimit)){
                        ao.CreditLmt__c = Decimal.valueOf(AccListData.creditLimit);
                    }
                    if(!string.isBlank(AccListData.cashLimit)){
                        ao.Cashlmt__c = Decimal.valueOf(AccListData.cashLimit);
                    }
                    if(!string.isBlank(AccListData.rateOfInterest)){
                        ao.ROI__c = Decimal.valueOf(AccListData.rateOfInterest);
                    }
                    if(!string.isBlank(AccListData.valueOfCollateral)){
                        ao.Value_of_col__c = AccListData.valueOfCollateral;
                    }
                    
                    if(!string.isBlank(AccListData.paymentHistory1)){
                        
                        string paymentHistory= AccListData.paymentHistory1;
                        integer noemipaid=paymentHistory.length()/3;
                        ao.NoEMIPaid__c=noemipaid;
                        
                        //TenureLeft__c
                        if(!string.isBlank(AccListData.repaymentTenure) && noemipaid!=null){
                            //if(ao.DisbursalDate__c!=null && noemipaid!=null){
                            //integer tenureleft=ao.DisbursalDate__c.monthsBetween(system.today());
                            //ao.TenureLeft__c=tenureleft-noemipaid;
                            ao.TenureLeft__c=Decimal.valueof(AccListData.repaymentTenure)-noemipaid;
                        }
                        if(!string.isBlank(AccListData.overdueAmount)){
                            ao.Overdues__c= Decimal.valueof(AccListData.overdueAmount); 
                        }
                        List<String> result = splitStringByFixedLength(AccListData.paymentHistory1, 3);
                        Map<String,BureauConsumerDPD__c> consumerBureauDPDMap = BureauConsumerDPD__c.getAll();    
                        
                        if(result.size()>1){
                            
                            if(result.size()>1  || result.size()>3)
                            {   
                                List<Integer> dpdValues = new List<Integer>();
                                Integer indexLimit =result.size()>3 ? 3 : result.size(); 
                                for(integer i=0;i<indexLimit;i++)
                                {
                                    /*if(result[i]=='SMA' || result[i]=='SUB' || result[i]=='LSS' ||  result[i]=='DBT')
{
ao.MaxDPDLst3month__c=90;
}else{
ao.MaxDPDLst3month__c=0;
}*/
                                    
                                    if(result[i].isNumeric()){
                                        dpdValues.add(Integer.valueOf(result[i]));
                                    }
                                    else{
                                        if(consumerBureauDPDMap.containsKey(result[i])){
                                            dpdValues.add(Integer.valueOf(consumerBureauDPDMap.get(result[i]).DPDValue__c));
                                        }
                                    }
                                }
                                ao.MaxDPDLst3month__c=getHighestValue(dpdValues);
                                ao.Ever90__c = ao.MaxDPDLst3month__c>90? 'Yes' : 'No';
                                
                            }
                            else
                            {
                                ao.MaxDPDLst3month__c=0;
                            }
                            if(result.size()>1 || result.size()>6)
                            {
                                List<Integer> dpdValues = new List<Integer>();
                                Integer indexLimit =result.size()>6 ? 6 : result.size(); 
                                for(integer i=0;i<indexLimit;i++)
                                {
                                    /*if(result[i]=='SMA' || result[i]=='SUB' || result[i]=='LSS' ||  result[i]=='DBT')
{
ao.MaxDPDLst6month__c=90;
}else{
ao.MaxDPDLst6month__c=0;
}*/
                                    if(result[i].isNumeric()){
                                        dpdValues.add(Integer.valueOf(result[i]));
                                    }
                                    else{
                                        if(consumerBureauDPDMap.containsKey(result[i])){
                                            dpdValues.add(Integer.valueOf(consumerBureauDPDMap.get(result[i]).DPDValue__c));
                                        }
                                    }
                                    
                                }
                                ao.MaxDPDLst6month__c=getHighestValue(dpdValues);
                                ao.Ever90__c = ao.MaxDPDLst6month__c>90? 'Yes' : 'No';
                            }
                            else{
                                ao.MaxDPDLst6month__c=0;
                            }
                            
                            if(result.size()>1 || result.size()>12)
                            {
                                Integer indexLimit =result.size()>12 ? 12 : result.size(); 
                                List<Integer> dpdValues = new List<Integer>();
                                for(integer i=0;i<indexLimit;i++)
                                {
                                    /*if(result[i]=='SMA' || result[i]=='SUB' || result[i]=='LSS' ||  result[i]=='DBT')
{
ao.MaxDPDLst12month__c=90;
}else{
ao.MaxDPDLst12month__c=0;
}*/
                                    if(result[i].isNumeric()){
                                        dpdValues.add(Integer.valueOf(result[i]));
                                    }
                                    else{
                                        if(consumerBureauDPDMap.containsKey(result[i])){
                                            dpdValues.add(Integer.valueOf(consumerBureauDPDMap.get(result[i]).DPDValue__c));
                                        }
                                    }
                                    
                                }
                                ao.MaxDPDLst12month__c=getHighestValue(dpdValues);
                                ao.Ever90__c = ao.MaxDPDLst12month__c>90? 'Yes' : 'No';
                            }
                            else{
                                ao.MaxDPDLst12month__c=0;
                            }
                            
                        }
                        else
                        {
                            ao.MaxDPDLst3month__c=0;
                            ao.MaxDPDLst6month__c=0;
                            ao.MaxDPDLst12month__c=0;
                            ao.Ever90__c='No'; 
                            
                        }
                    }
                    
                    
                    
                    
                    if(!string.isBlank(AccListData.dateReportedAndCertified)){ 
                        ao.DateReportedCert__c = IntegrationUtility.getDate(AccListData.dateReportedAndCertified);
                        
                        
                    }
                    
                    if(!string.isBlank(AccListData.paymentHistoryEndDate)){ 
                        ao.PaymentEndDate__c = IntegrationUtility.getDate(AccListData.paymentHistoryEndDate);
                        
                        
                    }
                    
                    if(!string.isBlank(AccListData.paymentHistoryStartDate)){ 
                        ao.PaymentStartDate__c = IntegrationUtility.getDate(AccListData.paymentHistoryStartDate);
                        
                        
                    }
                    
                    if(!string.isBlank(AccListData.dateOfLastPayment)){ 
                        ao.LastPayment__c =IntegrationUtility.getDate(AccListData.dateOfLastPayment);
                        
                        
                    }
                    
                    if(!string.isBlank(AccListData.actualPaymentAmount)){
                        ao.ActPayAmt__c=Decimal.ValueOf(AccListData.actualPaymentAmount);
                    }
                    
                    //Changes Realted BRE New Request
                    if(string.isNotBlank(AccListData.writtenOffAmountPrincipal)){
                        ao.WrittenOffAmtPrincipal__c=Decimal.ValueOf(AccListData.writtenOffAmountPrincipal);
                    }
                    
                    if(string.isNotBlank(AccListData.settlementAmount)){
                        ao.SettlementAmt__c=Decimal.ValueOf(AccListData.settlementAmount);
                    }
                    
                     if(string.isNotBlank(AccListData.suitFiledOrWilfulDefault)){
                        ao.SuitFiledWillfulDft__c=AccListData.suitFiledOrWilfulDefault;
                    }
                    
                    if(string.isNotBlank(AccListData.writtenOffAmountTotal)){
                        ao.WrittenOffAmtTotal__c=Decimal.ValueOf(AccListData.writtenOffAmountTotal);
                    }
                    
                    if(string.isNotBlank(AccListData.writtenOffAndSettledStatus)){
                        ao.WrittenOffSettledStatus__c=AccListData.writtenOffAndSettledStatus;
                    }
                    
                    
                    BureauRespDtl.add(ao);
                }
                
                if(BureauRespDtl!=null){
                    
                    List<string> fieldNamesList = New List<string>{'Bureau__c','Source__c','NatureOfLoan__c','LoanCapacity__c','LastPayment__c','ActPayAmt__c',
                        'FinancierName__c','DisbursalDate__c','CloseDate__c','LoanAmount__c','CurrentOs__c','EMISource__c',
                        'EMI__c','Tenure__c','NoEMIPaid__c','TenureLeft__c','Applicant__c','LoanApplication__c',
                        'DateReportedCert__c','PaymentEndDate__c','PaymentStartDate__c', 'PayHis2__c', 'PayHis1__c',
                        'Cashlmt__c', 'CreditLmt__c', 'ROI__c', 'Value_of_col__c','Overdues__c','Ever90__c','AccCode__c','OwnershipIndicator__c',
                        'WrittenOffAmtPrincipal__c','SettlementAmt__c','SuitFiledWillfulDft__c','WrittenOffAmtTotal__c','WrittenOffSettledStatus__c'};
                            String sObjectName = 'BureauRespDtl__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(BureauRespDtl);
                }
                
            }
            
            uow.commitWork();
            
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'ConsumerIssueResponseProcessor Class', 
                                     'BureauSuccess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    } 
    
    //************************************************************************************************************************************
    Public static void BureauError(string jsonString,Id refIdSet){
        
        try {
            if (jsonString != null) {
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Bureau__c.SObjectType });
                
                List<Bureau__c> Bureau = [SELECT Id, Applicant__c,IsLatest__c,BureauAPI__c FROM Bureau__c WHERE Applicant__c =:refIdSet AND IsLatest__c = true AND BureauAPI__c='Consumer'];
                List<Bureau__c> BureauList =new List<Bureau__c>();
                
                List<String> errorDescriptions = new List<String>();
                List<String> errorCategory = new List<String>();
                List<String> errorCode = new List<String>();
                
                
                ConsumerIssueResponseWrapper res  = (ConsumerIssueResponseWrapper) JSON.deserialize(jsonString.replace('JSON-RESPONSE-OBJECT','JSONResponseObject'), ConsumerIssueResponseWrapper.class);
                
                if(res!=null && res.FINISHED!=null && res.FINISHED[0].JSONResponseObject!=null &&
                   res.FINISHED[0].JSONResponseObject.errorDomainList!=null){
                       
                       for(ConsumerIssueResponseWrapper.errorDomainList err:res.FINISHED[0].JSONResponseObject.errorDomainList){
                           
                           if(string.isNotblank(err.errorDescription)){
                               errorDescriptions.add(err.errorDescription);
                           }
                           
                           if(string.isNotblank(err.errorCategory)){
                               errorCategory.add(err.errorCategory);
                           }
                           
                           if(string.isNotblank(err.errorCode)){
                               errorCode.add(err.errorCode);
                           }
                       }
                       
                   }
                
                
                if(!errorDescriptions.isEmpty() || !errorCategory.isEmpty() || !errorCode.isEmpty()){
                    
                    Bureau__c bur=new Bureau__c();
                    bur.Id=Bureau[0].Id;
                    bur.ErrorMess__c=errorDescriptions!=null?String.join(errorDescriptions, ', '):'';
                    bur.ErrorCode__c=errorCode!=null?String.join(errorCode, ', '):'';
                    bur.ErrorCategory__c=errorCategory!=null?String.join(errorCategory, ', '):'';
                    BureauList.add(bur);
                }
                
                if(BureauList!=null){
                    List<string> fieldNamesList = New List<string>{'Id','ErrorMess__c','ErrorCode__c','ErrorCategory__c'};
                        String sObjectName = 'Bureau__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList); 
                    uow.registerDirty(BureauList);
                }
                
                uow.commitWork();
                
            }
        } catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'ConsumerIssueResponseProcessor Class', 
                                     'BureauError', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    //**************************************************************************************************************************
    Public static Void BureauReject(ConsumerIssueResponseWrapper responseWrapper,Id refIdSet){
        
        try {
            if (responseWrapper != null) {
                
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Bureau__c.SObjectType });
                
                List<Bureau__c> Bureau = [SELECT Id, Applicant__c,IsLatest__c,BureauAPI__c FROM Bureau__c WHERE Applicant__c =:refIdSet AND IsLatest__c = true AND BureauAPI__c='Consumer'];
                
                List<Bureau__c> BureauList =new List<Bureau__c>();
                List<String> errorDescriptions = new List<String>();
                List<String> errorCode = new List<String>();
                
                if (responseWrapper.REJECT != null) {
                    for (ConsumerIssueResponseWrapper.Reject reject : responseWrapper.REJECT) {
                        if (reject.ERRORS != null) {
                            for (ConsumerIssueResponseWrapper.error errorDetail : reject.ERRORS) {
                                
                                if(String.isNotblank(errorDetail.DESCRIPTION)){
                                    errorDescriptions.add(errorDetail.DESCRIPTION);
                                }
                                
                                if(String.isNotblank(errorDetail.CODE)){
                                    errorCode.add(errorDetail.CODE);
                                }   
                                
                            }
                        }
                    }
                }
                
                
                if(!errorDescriptions.isEmpty() || !errorCode.isEmpty()){
                    Bureau__c bur=new Bureau__c();
                    bur.Id=Bureau[0].Id;
                    bur.ErrorMess__c=errorDescriptions!=null?String.join(errorDescriptions, ', '):'';
                    bur.ErrorCode__c=errorCode!=null?String.join(errorCode, ', '):'';
                    BureauList.add(bur);
                }
                if(BureauList!=null){
                    List<string> fieldNamesList = New List<string>{'Id','ErrorMess__c','ErrorCode__c'};
                        String sObjectName = 'Bureau__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList); 
                    uow.registerDirty(BureauList);
                }
                uow.commitWork();
                
            }
        } catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'ConsumerIssueResponseProcessor Class', 
                                     'BureauReject', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
    }
    //*****************************************************************************************************************************
    Public static Void BureauDLQUEUE(ConsumerIssueResponseWrapper responseWrapper,Id refIdSet){
        
        try {
            if (responseWrapper != null) {
                
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Bureau__c.SObjectType });
                
                List<Bureau__c> Bureau = [SELECT Id, Applicant__c,IsLatest__c,BureauAPI__c FROM Bureau__c WHERE Applicant__c =:refIdSet AND IsLatest__c = true AND BureauAPI__c='Consumer'];
                
                List<Bureau__c> BureauList =new List<Bureau__c>();
                
                List<String> status = new List<String>();
                
                if (responseWrapper.REJECT != null) {
                    
                    for(ConsumerIssueResponseWrapper.REJECT rej:responseWrapper.REJECT){
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
    //*******************************************************************************************************
    public static Void BureauInProgress(Id refIdSet,IntgMsg__c response){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Bureau__c.SObjectType });
        
        if(refIdSet!=null){
            
            try {
                
                List<Bureau__c> BureauInsert =new List<Bureau__c>();
                
                List<Bureau__c> Bureau = [SELECT Id, Applicant__c,TriggerCount__c,IsLatest__c,BureauAPI__c FROM Bureau__c WHERE Applicant__c =:refIdSet AND IsLatest__c = true AND BureauAPI__c='Consumer'];
                
                
                //Create Cusomer Issue Request Integration Message with 1 min Delay
                if(Bureau[0].TriggerCount__c>=0 && Bureau[0].TriggerCount__c<2){
                    
                    Bureau__c bur =new Bureau__c();
                    bur.id=Bureau[0].Id;
                    bur.TriggerCount__c=Bureau[0].TriggerCount__c+1;
                    BureauInsert.add(bur);
                    
                    Map<String,Object> jsonDataMap = new Map<String, Object>();
                    
                    jsonDataMap.put('Name','Cusomer Issue Request');
                    jsonDataMap.put('Status','New');
                    jsonDataMap.put('MStatus','Blank');
                    jsonDataMap.put('BU',response.BU__c);
                    jsonDataMap.put('RefId',response.RefId__c);
                    jsonDataMap.put('RefObj',response.RefObj__c);
                    jsonDataMap.put('Svc','Cusomer Issue Request');
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
    //*******************************************************************************************************
    public Static void IsLatestFalse(List<SObject> recordList, String fieldName){
        
        if(!recordList.isempty()){
            SObjectType sObjectType = recordList.getSObjectType();
            
            List<SObject> recordsToUpdate = new List<SObject>();
            
            for (SObject record : recordList) {
                if (record.get(fieldName) != null) {
                    record.put(fieldName, false);
                    recordsToUpdate.add(record);
                }
            }
            
            if (!recordsToUpdate.isEmpty()) {
                update recordsToUpdate;
            }
        }
        
        
        
        
        
    }
    //*********************************************************************************************************************************** 
    public static List<String>  splitStringByFixedLength(String inputString, Integer substringLength) {
        List<String> substrings = new List<String>();
        
        // Check if the input string is not null and has a length greater than 0
        if (inputString != null && inputString.length() > 0) {
            for (Integer i = 0; i < inputString.length(); i += substringLength) {
                Integer endIndex = i + substringLength;
                
                // Ensure endIndex does not exceed the length of the input string
                if (endIndex > inputString.length()) {
                    endIndex = inputString.length();
                }
                
                // Extract a substring of the specified length and add it to the list
                substrings.add(inputString.substring(i, endIndex));
            }
        }
        
        return substrings;
    }
     //*********************************************************************************************************************************** 
    public static Integer getHighestValue(List<Integer> inputList){
        if(!inputList.isEmpty()){
            inputList.sort();
            return inputList.get(inputList.size()-1);
        }
        return 0;
    } 
   
 //*********************************************************************************************************************************** 
    public static Integer getDPDValue(String dpdString, Map<String, BureauConsumerDPD__c> consumerBureauDPDMap) {
        if (dpdString.isNumeric()) {
            return Integer.valueOf(dpdString);
        } else if (consumerBureauDPDMap.containsKey(dpdString)) {
            return Integer.valueOf(consumerBureauDPDMap.get(dpdString).DPDValue__c);
        }
        
        return 0;
    }
    
    //***********************************************************************************************************************************
    public static Map<String,String> sourceMap =new Map<String,String>{
        
        'CIBIL'=>'Consumer CIBIL',
            'CRIF'=>'Consumer CRIF',
            'Equifax'=>'Consumer Equifax',
            'Experian'=>'Consumer Experian'
            };
                
                //***********************************************************************************************************************************
                public static Map<String,String> ownershipIndicatorMap =new Map<String,String>{
                    
                    '1'=>'Individual',
                        '3'=>'Guarantor',
                        '4'=>'Joint'
                        };
}