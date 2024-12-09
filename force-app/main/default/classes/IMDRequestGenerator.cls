public class IMDRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){  
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( 
            new List<SObjectType> { IntgMsg__c.SObjectType,ApplIMD__c.SObjectType }
        );
        IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('IMD');
        //Creating a Set of ids
        Set<Id> ids = new Set<Id>();
        Set<Id> applIMDIds = new Set<Id>();
        Set<Id> paymentIds = new Set<Id>();
        Set<Id> loanAppIds = new Set<Id>();
        Set<Id> schemeIds = new Set<Id>();
        //Set<Id> cityIds = new Set<Id>();
        Set<String> micrCode = new Set<String>();
        Set<Id> appIds = new Set<Id>();
        Set<String>branchCode = new Set<String>();
        
        //Iterating over new Intgeration Message record ids to add them into the above Set
        for(IntgMsg__c intMsg : msgs){ 
            //ids.add(intMsg.RefId__c);
            if(intMsg.RefObj__c=='ApplIMD__c'){
                applIMDIds.add(intMsg.RefId__c);
            }
            else if(intMsg.RefObj__c=='Payment__c'){
                paymentIds.add(intMsg.RefId__c);
            }
            
            loanAppIds.add(intMsg.ParentRefId__c);
        }
        
        //Fetching required fields to create Request Payload
        Map<Id,ApplIMD__c> appIMDMap = new Map<Id,ApplIMD__c>();
        Map<Id,LoanAppl__c> loanAppMap = new Map<Id,LoanAppl__c>();
        Map<String,BankBrchMstr__c> bankBranchMap = new Map<String,BankBrchMstr__c>();
        for(ApplIMD__c applIMD : [Select Id,AppId__c,BankName__c,CityId__c,InstrumentAmt__c,InstrumentDt__c,InstrumentNo__c,PaymentMode__c,PaymentRefNo__c,MICRCode__c,DealingBank__c,DealingBank__r.FinnoneCode__c,TransDt__c FROM ApplIMD__c WHERE Id IN:applIMDIds]){
            appIMDMap.put(applIMD.Id,applIMD);
            //cityIds.add(applIMD.CityId__c);  
            micrCode.add(applIMD.MICRCode__c);          
        }
        for(LoanAppl__c loanAppl : [Select Id,ApplicantName__c,Applicant__c,Applicant__r.Constitution__c,Applicant__r.EmailId__c,Applicant__r.MobNumber__c,BrchCode__c,Name,Product__c,SchemeId__c,FinnoneAppid__c FROM LoanAppl__c WHERE Id IN:loanAppIds]){
            loanAppMap.put(loanAppl.Id,loanAppl);
            schemeIds.add(loanAppl.SchemeId__c);
            appIds.add(loanAppl.Applicant__c);
            branchCode.add(loanAppl.BrchCode__c);
        }
        
        Map<String,MICRCodeMstr__c> micrCodeMap = new Map<String,MICRCodeMstr__c>();
        for(MICRCodeMstr__c micr : [Select Id,MICRCode__c,BanckBrchId__c,City__c,City__r.CityId__c,Bank__c,Bank__r.BankId__c from MICRCodeMstr__c WHERE MICRCode__c IN:micrCode]){
            micrCodeMap.put(micr.MICRCode__c,micr);
        }
        //Map<Id,BankCityMapping__c> cityMap =new Map<Id,BankCityMapping__c>([Select Id,City__c,City__r.CityId__c,City__r.StateId__c FROM BankCityMapping__c WHERE City__r.CityId__c IN:cityIds]);
        
        Map<Id,SchMapping__c> schMap = new Map<Id,SchMapping__c>([Select Id,SchmId__c FROM SchMapping__c WHERE ID IN:schemeIds]);
        Map<Id,ApplKyc__c> applKycMap = new Map<Id,ApplKyc__c>([Select Id,Pan__c FROM ApplKyc__c WHERE kycDoc__c='Pan' AND Applicant__c IN:appIds]);
        
        for(BankBrchMstr__c brch : [Select Id, BrchCode__c,OffcCode__c,LocationMaster__c,LocationMaster__r.StateId__c from BankBrchMstr__c WHERE BrchCode__c IN:branchCode]){
            bankBranchMap.put(brch.BrchCode__c,brch);
        }
        
        Map<Id,Payment__c> paymentMap = new Map<Id,Payment__c>([Select Id,TransAmt__c,TransDt__c,PaymentRefNo__c FROM Payment__c WHERE Id IN:paymentIds]);
        
        Map<Id,ApplIMD__c> updateApplIMDMap = new Map<Id,ApplIMD__c>();
        Map<String,MasterData__c> masterDataMap = new Map<String,MasterData__c>();
        for(MasterData__c masterData : [SELECT Id,Name,FinnoneVal__c,FinnoneCode__c,SalesforceCode__c,Type__c  from MasterData__c where FinnoneCode__c =:system.label.IMDPaytmDealingBank]){
            if(masterData.FinnoneCode__c!=null && String.isNotBlank(masterData.FinnoneCode__c)){
                masterDataMap.put(masterData.FinnoneCode__c,masterData);
            }
        }
        try{
            //If the List of new Integration Message records is not empty, then iterating over and assigning data to variables from Wrapper Class
            List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>(); 
            
            if(!msgs.isEmpty()){
                
                for(IntgMsg__c intMsg : msgs){
                    if(intMsg.RefId__c!=null){
                        if(intMsg.RefObj__c=='ApplIMD__c'){
                            if(appIMDMap.containsKey(intMsg.RefId__c) && loanAppMap.containsKey(intMsg.ParentRefId__c)){
                                
                                ApplIMD__c appIMD = appIMDMap.get(intMsg.RefId__c);
                                LoanAppl__c loanApp = loanAppMap.get(intMsg.ParentRefId__c);
                                
                                IMDRequestWrapper imdRequestDetials = new IMDRequestWrapper();
                                imdRequestDetials.sourceId =svc.SourceSystem__c;
                                imdRequestDetials.ftMode = appIMD.PaymentMode__c=='Payment Gateway'?'OT':'CR';
                                imdRequestDetials.city = micrCodeMap.containsKey(appIMD.MICRCode__c) ?  micrCodeMap.get(appIMD.MICRCode__c).City__r.CityId__c: '';//.cityMap.containsKey(appIMD.CityId__c) ? cityMap.get(appIMD.CityId__c).City__r.CityId__c : '';
                                imdRequestDetials.modeOfPayment = appIMD.PaymentMode__c=='Payment Gateway' ? 'F' : appIMD.PaymentMode__c=='DD' ? 'D' : appIMD.PaymentMode__c=='Cheque' ? 'Q' : '';
                                imdRequestDetials.chequeStatus = GlobalConstants.chequeStatus;
                                imdRequestDetials.inFavourOf = GlobalConstants.InFavourOf;//appIMD.BankName__c;
                                imdRequestDetials.schemeId = schMap.containsKey(loanApp.SchemeId__c) ? schMap.get(loanApp.SchemeId__c).SchmId__c : '';
                                imdRequestDetials.chequeNumber = imdRequestDetials.ftMode !='OT' ? appIMD.InstrumentNo__c : '';
                                imdRequestDetials.branch = bankBranchMap.containsKey(loanApp.BrchCode__c) ? bankBranchMap.get(loanApp.BrchCode__c).OffcCode__c : '';//(micrCodeMap.containsKey(appIMD.MICRCode__c) && String.isNotBlank(micrCodeMap.get(appIMD.MICRCode__c).BanckBrchId__c)) ? String.valueOf(Integer.valueOf(micrCodeMap.get(appIMD.MICRCode__c).BanckBrchId__c)) : '';
                                imdRequestDetials.receiptAmount = appIMD.InstrumentAmt__c!=null ? String.valueOf(appIMD.InstrumentAmt__c) : '';
                                imdRequestDetials.password = svc.Password__c;
                                imdRequestDetials.requestId = GlobalUtility.getUniqueNumber();
                                imdRequestDetials.imdFlag = GlobalConstants.imdFlag;
                                imdRequestDetials.bpType = GlobalConstants.bpType;
                                imdRequestDetials.receiptDate = (appIMD.PaymentMode__c=='Payment Gateway' && appIMD.TransDt__c!=null) ? String.valueOf(DateTime.newInstance(appIMD.TransDt__c.year(), appIMD.TransDt__c.month(), appIMD.TransDt__c.day()).format('dd-MMM-yyyy')) : (appIMD.InstrumentDt__c !=null && appIMD.PaymentMode__c!='Payment Gateway') ? String.valueOf(DateTime.newInstance(appIMD.InstrumentDt__c.year(), appIMD.InstrumentDt__c.month(), appIMD.InstrumentDt__c.day()).format('dd-MMM-yyyy')) : '';
                                imdRequestDetials.imdCustom4 = applKycMap.containsKey(loanApp.Applicant__c) ? applKycMap.get(loanApp.Applicant__c).Pan__c : '';
                                imdRequestDetials.imdCustom3 = (loanApp.Applicant__c!=null && loanApp.Applicant__r.Constitution__c=='INDIVIDUAL') ? getCompleteAddress(loanApp.Applicant__c,'Residence Address'): (loanApp.Applicant__c!=null && loanApp.Applicant__r.Constitution__c!='INDIVIDUAL') ? getCompleteAddress(loanApp.Applicant__c,'Principal place for business'):'';
                                imdRequestDetials.productFlag = (loanApp.Product__c=='Small Ticket LAP' || loanApp.Product__c=='Loan Against Property') ? 'LAP' : 'HL';
                                imdRequestDetials.imdCustom2 = loanApp.ApplicantName__c;
                                imdRequestDetials.transactionCode = GlobalConstants.transactionCode;
                                imdRequestDetials.imdCustom1 = (bankBranchMap.containsKey(loanApp.BrchCode__c) && bankBranchMap.get(loanApp.BrchCode__c).LocationMaster__c!=null) ? bankBranchMap.get(loanApp.BrchCode__c).LocationMaster__r.StateId__c : '' ;//9'; //gst State Id
                                imdRequestDetials.imdCustom7 = loanApp.Name;
                                imdRequestDetials.chequeDate = appIMD.InstrumentDt__c !=null ? String.valueOf(DateTime.newInstance(appIMD.InstrumentDt__c.year(), appIMD.InstrumentDt__c.month(), appIMD.InstrumentDt__c.day()).format('dd-MMM-yyyy')) : '';
                                imdRequestDetials.imdCustom6 = loanApp.Applicant__r.EmailId__c;
                                imdRequestDetials.drawnOn = micrCodeMap.containsKey(appIMD.MICRCode__c) ?  micrCodeMap.get(appIMD.MICRCode__c).Bank__r.BankId__c : '';//GlobalConstants.drawnOn;//'229';
                                imdRequestDetials.imdCustom5 = loanApp.Applicant__r.MobNumber__c;
                                imdRequestDetials.utrNo = imdRequestDetials.ftMode=='OT'?appIMD.PaymentRefNo__c:'';
                                imdRequestDetials.chargeId = GlobalConstants.chargeId;//'56';
                                imdRequestDetials.receiptNo = appIMD.PaymentMode__c=='Payment Gateway' ? (appIMD.PaymentRefNo__c!=null && appIMD.PaymentRefNo__c.length()>12) ? appIMD.PaymentRefNo__c.left(12) : appIMD.PaymentRefNo__c : appIMD.InstrumentNo__c;
                                imdRequestDetials.dealingBank =  appIMD.PaymentMode__c=='Payment Gateway'? system.label.IMDPaytmDealingBank : (appIMD.DealingBank__c!=null && appIMD.DealingBank__r.FinnoneCode__c!=null) ? appIMD.DealingBank__r.FinnoneCode__c : ''; //GlobalConstants.dealingBank;
                                imdRequestDetials.applicationId = String.valueOf(loanApp.FinnoneAppid__c);
                                imdRequestDetials.user = svc.Username__c;
                                
                                IntgMsg__c intg=New IntgMsg__c();
                                intg.id=intMsg.id;
                                intg.Req__c = JSON.serialize(imdRequestDetials); 
                                intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                                updateIntRecords.add(intg);
                                
                                if(appIMD.PaymentMode__c=='Payment Gateway' && masterDataMap.containsKey(system.label.IMDPaytmDealingBank)){
                                    updateApplIMDMap.put(appIMD.Id,new ApplIMD__c(Id=appIMD.Id,DealingBank__c=masterDataMap.get(system.label.IMDPaytmDealingBank).Id));
                                }
                                
                            }
                            else {
                                throw new IMDRequestGeneratorException('Invalid Reference Ids');
                            }
                        }
                        else if(intMsg.RefObj__c=='Payment__c'){
                            if(paymentMap.containsKey(intMsg.RefId__c) && loanAppMap.containsKey(intMsg.ParentRefId__c)){
                                
                                Payment__c payment = paymentMap.get(intMsg.RefId__c);
                                LoanAppl__c loanApp = loanAppMap.get(intMsg.ParentRefId__c);
                                
                                IMDRequestWrapper imdRequestDetials = new IMDRequestWrapper();
                                imdRequestDetials.sourceId =svc.SourceSystem__c;
                                imdRequestDetials.ftMode = 'OT';
                                imdRequestDetials.city = '';
                                imdRequestDetials.modeOfPayment = 'F';
                                imdRequestDetials.chequeStatus = GlobalConstants.chequeStatus;
                                imdRequestDetials.inFavourOf = GlobalConstants.InFavourOf;
                                imdRequestDetials.schemeId = schMap.containsKey(loanApp.SchemeId__c) ? schMap.get(loanApp.SchemeId__c).SchmId__c : '';
                                imdRequestDetials.chequeNumber = '';
                                imdRequestDetials.branch = bankBranchMap.containsKey(loanApp.BrchCode__c) ? bankBranchMap.get(loanApp.BrchCode__c).OffcCode__c : '';
                                imdRequestDetials.receiptAmount = payment.TransAmt__c!=null ? String.valueOf(payment.TransAmt__c) : '';
                                imdRequestDetials.password = svc.Password__c;
                                imdRequestDetials.requestId = GlobalUtility.getUniqueNumber();
                                imdRequestDetials.imdFlag = GlobalConstants.imdFlag;
                                imdRequestDetials.bpType = GlobalConstants.bpType;
                                imdRequestDetials.receiptDate = payment.TransDt__c!=null ? String.valueOf(DateTime.newInstance(payment.TransDt__c.year(), payment.TransDt__c.month(), payment.TransDt__c.day()).format('dd-MMM-yyyy')) : '';
                                imdRequestDetials.imdCustom4 = applKycMap.containsKey(loanApp.Applicant__c) ? applKycMap.get(loanApp.Applicant__c).Pan__c : '';
                                imdRequestDetials.imdCustom3 = (loanApp.Applicant__c!=null && loanApp.Applicant__r.Constitution__c=='INDIVIDUAL') ? getCompleteAddress(loanApp.Applicant__c,'Residence Address'): (loanApp.Applicant__c!=null && loanApp.Applicant__r.Constitution__c!='INDIVIDUAL') ? getCompleteAddress(loanApp.Applicant__c,'Principal place for business'):'';
                                imdRequestDetials.productFlag = (loanApp.Product__c=='Small Ticket LAP' || loanApp.Product__c=='Loan Against Property') ? 'LAP' : 'HL';
                                imdRequestDetials.imdCustom2 = loanApp.ApplicantName__c;
                                imdRequestDetials.transactionCode = GlobalConstants.transactionCode;
                                imdRequestDetials.imdCustom1 = (bankBranchMap.containsKey(loanApp.BrchCode__c) && bankBranchMap.get(loanApp.BrchCode__c).LocationMaster__c!=null) ? bankBranchMap.get(loanApp.BrchCode__c).LocationMaster__r.StateId__c : '' ;//9'; //gst State Id
                                imdRequestDetials.imdCustom7 = loanApp.Name;
                                imdRequestDetials.chequeDate = '';
                                imdRequestDetials.imdCustom6 = loanApp.Applicant__r.EmailId__c;
                                imdRequestDetials.drawnOn = '';
                                imdRequestDetials.imdCustom5 = loanApp.Applicant__r.MobNumber__c;
                                imdRequestDetials.utrNo = payment.PaymentRefNo__c!=null ? payment.PaymentRefNo__c :'';
                                imdRequestDetials.chargeId = GlobalConstants.chargeId;//'56';
                                imdRequestDetials.receiptNo = payment.PaymentRefNo__c!=null ? (payment.PaymentRefNo__c!=null && payment.PaymentRefNo__c.length()>12) ? payment.PaymentRefNo__c.left(12) : payment.PaymentRefNo__c :'';
                                imdRequestDetials.dealingBank =  system.label.IMDPaytmDealingBank; 
                                imdRequestDetials.applicationId = String.valueOf(loanApp.FinnoneAppid__c);
                                imdRequestDetials.user = svc.Username__c;
                                
                                IntgMsg__c intg=New IntgMsg__c();
                                intg.id=intMsg.id;
                                intg.Req__c = JSON.serialize(imdRequestDetials); 
                                intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                                updateIntRecords.add(intg);
                                
                            }
                            else {
                                throw new IMDRequestGeneratorException('Invalid Reference Ids');
                            }
                        }
                    }    
                }
                
                if(!updateIntRecords.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntRecords);
                }
                
                if(!updateApplIMDMap.isEmpty()) {
                    String sObjectName = 'ApplIMD__c';
                    List<String> fieldNamesList = new List<String>{'DealingBank__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateApplIMDMap.values());
                }
            }
            
            uow.commitWork();
        }
        
        //Catch bloack to catch Exceptions occured during generation of payload and displaying the passing the same in GlobalUtility class
        catch(Exception ex){
            System.debug('error'+ex.getMessage());
            GlobalUtility.logMessage('Error', 'IMDRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
        
    }
    
    Public static String getCompleteAddress(Id ApplicantId,String AddressType){
        
        List<ApplAddr__c> adrList=[Select Id,Applicant__c,AddrLine1__c,AddrLine2__c,AddrTyp__c,Locality__c,City__c,Country__c,HouseNo__c,Landmark__c,Pincode__c,State__c FROM ApplAddr__c  WHERE Applicant__c =:ApplicantId AND AddrTyp__c =:AddressType];
        
        if (!adrList.isEmpty()) {
            ApplAddr__c adr = adrList[0]; 
            
            String concatenatedAddress = adr.HouseNo__c + ' ' + adr.AddrLine1__c + ' ' + adr.AddrLine2__c +' ' +adr.City__c +' ' +adr.Pincode__c +' ' +adr.State__c +' ' +adr.Country__c;
            
            system.debug('concatenatedAddress  '+concatenatedAddress);
            return concatenatedAddress;
        }
        
        return '';
    }
    
    public class IMDRequestGeneratorException extends Exception {
        
    }
    
}