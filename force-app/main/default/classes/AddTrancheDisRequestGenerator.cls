public class AddTrancheDisRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){  
        
        Map<Id,List<Applicant__c>> loanAppMap = new Map<Id,List<Applicant__c>>();
        Map<Id, LoanAppl__c> loanAppRecordsMap = new Map<Id, LoanAppl__c>();
        final Map<Integer, String> monthMap = new Map<Integer, String>{1=>'JAN', 2=>'FEB', 3=>'MAR', 4=>'APR', 5=>'MAY', 6=>'JUN', 7=>'JUL', 8=>'AUG', 9=>'SEP', 10=>'OCT', 11=>'NOV',12=>'DEC'};
        //Ucid Of Primary Applicant
        String ucidPriApp ='';
        Map<String,LocMstr__c> mapLocMas =new Map<String,LocMstr__c>();
        Set<String> citySet =new Set<String>();
        Id loanAppId ;
        Id disbursalId ;
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { IntgMsg__c.SObjectType });
        final Set<String> typeFilters=new Set<String>{'CashBank Account','Payment Mode','Fund Transfer Mode'};
        List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>();
        try{
        List<IntgSvcMgmt__mdt> liMdtReqd = [select id, DeveloperName,Username__c,Password__c,SourceSystem__c  from IntgSvcMgmt__mdt where DeveloperName ='Additional_Tranche_Disbursal'];
        if(msgs !=null && !msgs.isEmpty()){
                
        for(IntgMsg__c intMsg : msgs){

                loanAppId = intMsg.ParentRefId__c !=null ? intMsg.ParentRefId__c :'';
                disbursalId=intMsg.RefId__c !=null ? intMsg.RefId__c :'';//principal start date =>repayment date 
                System.debug('loanAppId::'+loanAppId);
                System.debug('disbursalId::'+disbursalId);
                System.debug('loanAppId::'+loanAppId);
        
        for(LoanAppl__c loanApp : [SELECT ID,FinnoneAppid__c,FirstEMIDate__c,(SELECT Id,UCID__c,ApplType__c FROM Applicants__r) FROM LoanAppl__c WHERE Id =:loanAppId]){
            loanAppMap.put(loanApp.Id,loanApp.Applicants__r);
            loanAppRecordsMap.put(loanApp.Id,loanApp);  
        }
        
        List<Applicant__c> listAppli= loanAppMap.get(loanAppId);
        List<Disbursement__c> listDisbNSplitDis =[select id,DisbrDiscription__c,Disbur_Desrp__c,Date_of_Disbur__c,Total_Disb_Amt__c,No_of_Disbur__c,Princ_Start_Date__c,Princ_Rec_on__c,(select Id,Effec_Date__c,IFSC_Detail__c,Split_Cheque_Amt__c,Fedbank_Acc_No__c,Custo_Name__c,Cheq_Favor_Acc_No__c,Remarks__c,Cheq_DD_Date__c,Disbur_To__c,Cheq_Favor_Dets__c,Payable_At__c,Fund_Transf_Mode__c,Pay_Mode__c,Date_of_Disbur__c,Cheq_DD_No__c,Fedbank_Acc_Nm__c from Split_Disbursements__r) from Disbursement__c where ID =: disbursalId ];
        
        if(listAppli != null && !listAppli.isEmpty())
        {       for(Applicant__c eachApp: listAppli)
            {     
                if(eachApp.ApplType__c =='P')
                {
                    ucidPriApp=eachApp.UCID__c != null ? eachApp.UCID__c :'';
                }
            }
        }
        
        System.debug('ucidPriApp::'+ucidPriApp);
        
        Map<String,Map<String,String>> masterDataMap= new Map<String,Map<String,String>> ();
        
        for(MasterData__c masterObj : [Select id,name,Type__c,FinnoneVal__c,SalesforceCode__c,FinnoneCode__c from MasterData__c Where Type__c IN:typeFilters])
        {
            Map<String,String> tempMap = new Map<String,String>();
            if(masterDataMap.containsKey(masterObj.Type__c))
            {
                tempMap = masterDataMap.get(masterObj.Type__c);
                tempMap.put(masterObj.Name,masterObj.FinnoneCode__c);
                masterDataMap.put(masterObj.Type__C, tempMap);
            }else
            {
                tempMap.put(masterObj.Name,masterObj.FinnoneCode__c);
                masterDataMap.put(masterObj.Type__C, tempMap);
            }
        }
        
        
        if(listDisbNSplitDis !=null && !listDisbNSplitDis.isEmpty()){
            for(Disbursement__c disB : listDisbNSplitDis ){
                for(Split_Disbur__c spDisb :disB.Split_Disbursements__r){
                    //listOfSplitDisb.add(spDisb);
                    if(spDisb.Payable_At__c !=null){
                        citySet.add(String.valueOf(spDisb.Payable_At__c).toUpperCase()); 
                    }
                }
            }
            
        }

        List<LocMstr__c> liLocMaster =[select ID,State__c,StateId__c ,City__c, CityId__c from LocMstr__c where City__c IN : citySet]; 
        
        for(LocMstr__c eachLocMas :liLocMaster){
            mapLocMas.put( String.valueOf(eachLocMas.City__c).toUppercase() ,eachLocMas);
        }
        
        LoanAppl__c dataLoanApp= loanAppRecordsMap.get(loanAppId);
        
        AddTrancheDisRequestWrapper.DisbursalDetail  disbDetails= new AddTrancheDisRequestWrapper.DisbursalDetail();
        String disbIdWithDesc='';
            
        if(listDisbNSplitDis !=null && !listDisbNSplitDis.isEmpty()){    
        for(Disbursement__c eachDisb : listDisbNSplitDis)
        {
            
            List<AddTrancheDisRequestWrapper.PaymentDetails> listPayDetails =new List<AddTrancheDisRequestWrapper.PaymentDetails>();
            for(Split_Disbur__c eachSplitDisObj:eachDisb.Split_Disbursements__r)
            {
                
                if(eachDisb.Princ_Rec_on__c !=null)
                {            
                    if(String.valueOf(eachDisb.Princ_Rec_on__c).equalsIgnoreCase('Amount Disbursed till Date')){
                        disbDetails.principalRecoveryFlag='D';
                    }
                    else if(String.valueOf(eachDisb.Princ_Rec_on__c).equalsIgnoreCase('AMOUNT FINANCED')){
                        disbDetails.principalRecoveryFlag='S';
                    }else{
                        disbDetails.principalRecoveryFlag='';
                    }
                }
                else{
                    disbDetails.principalRecoveryFlag='';
                }
                disbDetails.agreementNo='';//Blank
                disbDetails.applicationID=String.valueOf(dataLoanApp.FinnoneAppid__c)!=null ?String.valueOf(dataLoanApp.FinnoneAppid__c):''; 
                disbDetails.disbursalAmount = eachDisb.Total_Disb_Amt__c != null ? String.valueOf(eachDisb.Total_Disb_Amt__c):'';
                disbDetails.disbursalDate=String.valueOf(System.today().day()) + '-' +  monthMap.get(System.today().month()) + '-' +  String.valueOf(System.today().year());
                //eachDisb.Date_of_Disbur__c!=null ? String.valueOf(eachDisb.Date_of_Disbur__c.day()) + '-' + monthMap.get(eachDisb.Date_of_Disbur__c.month()) + '-' + String.valueOf(eachDisb.Date_of_Disbur__c.year()):'';
                disbDetails.disbusalDesc=eachDisb.DisbrDiscription__c !=null ? eachDisb.DisbrDiscription__c +'_'+eachDisb.Id  : '' ;
                System.debug('disbId with desc (disbDetails.disbusalDesc): '+disbDetails.disbusalDesc);
                if(disbDetails.disbusalDesc !=null){
                    disbIdWithDesc=disbDetails.disbusalDesc;
                }
                disbDetails.paymentDetails=listPayDetails;
                //LAK-8529
                disbDetails.repaymentDate= eachDisb.Princ_Start_Date__c!=null ? String.valueOf(eachDisb.Princ_Start_Date__c.day()) + '-' + monthMap.get(eachDisb.Princ_Start_Date__c.month()) + '-' + String.valueOf(eachDisb.Princ_Start_Date__c.year()):'';
                //Princ_Start_Date__c
                
                
                AddTrancheDisRequestWrapper.PaymentDetails payDetail=new AddTrancheDisRequestWrapper.PaymentDetails();
                payDetail.disbursalTo=System.Label.disbursalToAddtranche;
                payDetail.amount=String.valueOf(eachSplitDisObj.Split_Cheque_Amt__c)!=null ? String.valueOf(eachSplitDisObj.Split_Cheque_Amt__c):'';
                payDetail.creditPeriod=System.Label.creditPeriodAddTranche;
                payDetail.paymentMode = masterDataMap.get('Payment Mode') !=null && eachSplitDisObj.Pay_Mode__c !=null ? (masterDataMap.get('Payment Mode').get(eachSplitDisObj.Pay_Mode__c.toupperCase()) !=null ? masterDataMap.get('Payment Mode').get(eachSplitDisObj.Pay_Mode__c.toupperCase()) : '') :'' ;
                
                System.debug('masterDataMap.get(Fund Transfer Mode)::'+masterDataMap.get('Fund Transfer Mode'));
                payDetail.ftMode = masterDataMap.get('Fund Transfer Mode') !=null && eachSplitDisObj.Fund_Transf_Mode__c !=null ? (masterDataMap.get('Fund Transfer Mode').get(eachSplitDisObj.Fund_Transf_Mode__c.toupperCase()) !=null ? masterDataMap.get('Fund Transfer Mode').get(eachSplitDisObj.Fund_Transf_Mode__c.toupperCase()) : '') :'' ;
                payDetail.ifscCode= eachSplitDisObj.IFSC_Detail__c !=null?eachSplitDisObj.IFSC_Detail__c:''; 
                payDetail.chequeDate=eachSplitDisObj.Cheq_DD_Date__c !=null ?String.valueOf(eachSplitDisObj.Cheq_DD_Date__c.day()) + '-' + monthMap.get(eachSplitDisObj.Cheq_DD_Date__c.month()) + '-' + String.valueOf(eachSplitDisObj.Cheq_DD_Date__c.year()):'';
                payDetail.chequeNo=eachSplitDisObj.Cheq_DD_No__c !=null ? eachSplitDisObj.Cheq_DD_No__c:  '0';
                payDetail.effectiveDate=String.valueOf(System.today().day()) + '-' +  monthMap.get(System.today().month()) + '-' +  String.valueOf(System.today().year());
                payDetail.accountNo=eachSplitDisObj.Cheq_Favor_Acc_No__c!=null?eachSplitDisObj.Cheq_Favor_Acc_No__c:'';
                payDetail.disbrsmntBank=masterDataMap.get('CashBank Account')!=null ? masterDataMap.get('CashBank Account').get(eachSplitDisObj.Fedbank_Acc_Nm__c)   != null ?  String.valueOf(masterDataMap.get('CashBank Account').get(eachSplitDisObj.Fedbank_Acc_Nm__c))  : '' :'';
                payDetail.createdBy= System.Label.createdByAddTranche;
                payDetail.inFavourOf=eachSplitDisObj.Cheq_Favor_Dets__c!=null ?eachSplitDisObj.Cheq_Favor_Dets__c:'';
                payDetail.remarks= disbIdWithDesc!=null ? disbIdWithDesc :'';//  eachSplitDisObj.Remarks__c!=null ?eachSplitDisObj.Remarks__c:'NA';
                
                if(eachSplitDisObj.Payable_At__c !=null){
                    payDetail.city= mapLocMas.get(String.valueOf(eachSplitDisObj.Payable_At__c).toUppercase()) != null ? mapLocMas.get(String.valueOf(eachSplitDisObj.Payable_At__c).toUppercase()).CityId__c !=null ?mapLocMas.get(String.valueOf(eachSplitDisObj.Payable_At__c).toUppercase()).CityId__c:'':'';
                }
                else{
                    payDetail.city='';
                }
                payDetail.bpID= ucidPriApp !=null ? ucidPriApp :'';
                listPayDetails.add(payDetail);
             }
        }       
        }
        AddTrancheDisRequestWrapper addTrMainObj = new AddTrancheDisRequestWrapper();
        addTrMainObj.unqRequestId= GlobalUtility.getUniqueNumber();
        addTrMainObj.sourceSystem= liMdtReqd !=null ? liMdtReqd[0].SourceSystem__c :'';
        addTrMainObj.userId= liMdtReqd!=null ? liMdtReqd[0].Username__c :''; 	
        addTrMainObj.password=liMdtReqd!=null ? liMdtReqd[0].Password__c : '';
        addTrMainObj.disbursalDetail=disbDetails;
            
        
        IntgMsg__c intg=New IntgMsg__c();
        intg.id=intMsg.id;
        intg.Req__c = JSON.serialize(addTrMainObj,true); 
        intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
        updateIntRecords.add(intg);
            
            
        } 
            
          if(!updateIntRecords.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntRecords);
                }    
 uow.commitWork();
    } 
}   
    catch(Exception ex){
        System.debug('error'+ex.getMessage());
        GlobalUtility.logMessage('Error', 'AddTrancheDisRequestGenerator' + ex.getLineNumber(), 
                                 'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
    }
}     

}