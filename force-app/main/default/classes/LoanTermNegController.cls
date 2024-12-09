public without sharing class LoanTermNegController {
    @AuraEnabled
    public static loanAppealWrapper initiateLoanTerm( string loanAppId ){
        try {
            List<loanAppealItem> loanAplItemList = new List<loanAppealItem>();
            string product ='';
            List<string> fieldSet =  new  List<string>();
            List<string> fieldSetHL = new List<string>{'Applicant Name', 'Co-applicants Name','Eligibility Method','Total Loan amount including insurance (₹)','Loan Amount (₹) - Without Insurance','Insurance Amount(₹)','Loan Tenure (Months)','EMI (₹) - (Loan amount including insurance)','Repayment a/c Bank name + Repayment a/c no','Property Address','Sanction condition','Other change requests' ,'Attached documents'};
            List<string> fieldSetBL = new List<string>{ 'Co-applicants Name','Eligibility Method','Total Loan amount including insurance (₹)','Loan Amount (₹) - Without Insurance','Insurance Amount(₹)','Loan Tenure (Months)','EMI (₹) - (Loan amount including insurance)','Repayment a/c Bank name + Repayment a/c no','Sanction condition','Other change requests' ,'Attached documents'};    
                List<Applicant__c> appList = new List<Applicant__c>();
            appList = [SELECT id,FullName__c,ApplType__c  FROM Applicant__c  WHERE LoanAppln__c  =:loanAppId AND ( ApplType__c ='P' OR ApplType__c ='C' )];
            
            
            string applicantName = '';
            List<string> coAppList = new List<string>();
            if(!appList.isEmpty()){
                for (Applicant__c app : appList) {
                    if(app.ApplType__c == 'P'){
                        applicantName = app.FullName__c;
                    }else{
                        coAppList.add(app.FullName__c);
                    }
                }
            }
            System.debug('appList :'+appList);
            list<BRE__c> breList = new List<BRE__c>([select id, LoanAppl__c, Application_level_Assessment_program__c   from BRE__c   where  IsLatest__c = true  AND  LoanAppl__c = : loanAppId]);
            LoanAppl__c loapp =[SELECT TotalLoanAmtInclInsurance__c,InsAmt__c,Loan_Tenure_Months__c,EMIIcludingInsurance__c,Product__c FROM LoanAppl__c  WHERE id =:loanAppId limit 1 ];
            list<Repayment_Account__c> repAccList =  new list<Repayment_Account__c>();
            decimal lawI ;
            if(loapp != null){
                product = loapp.Product__c;
              }
           
            if(loapp != null && loapp.TotalLoanAmtInclInsurance__c != null && loapp.InsAmt__c != null ){
                lawI = loapp.TotalLoanAmtInclInsurance__c - loapp.InsAmt__c;
               
            }
           
            repAccList =  [SELECT Id,Account_Number__c,Bank_Name__c, Loan_Application__c   FROM  Repayment_Account__c WHERE  Is_Active__c = true AND Loan_Application__c =: loanAppId ];
            Repayment_Account__c repAcc =  new Repayment_Account__c();
            if(repAccList.size()>0 ){
                repAcc = repAccList[0];
            }
           // LoanAppl__c loanApplication = [SELECT Insurance_Amount__c  FROM LoanAppl__c  WHERE Id =: loanAppId];
            Decimal insAmount  = loapp != null && loapp.InsAmt__c != null ? loapp.InsAmt__c : 0;
            List<ApplAsset__c>  appAssetList  = new List<ApplAsset__c>();
            system.debug( 'appAssetList query '+ 'SELECT Id,PropAddrs__c  FROM ApplAsset__c WHERE LoanAppln__c =:'+loanAppId);
            appAssetList = [SELECT Id,PropAddrs__c  FROM ApplAsset__c WHERE LoanAppln__c =:loanAppId ];
            system.debug( 'appAssetList'+ appAssetList);
            
            List<Sanction_Conditions__c> sanCntnList = new List<Sanction_Conditions__c>();
            Sanction_Conditions__c sanCntn = new Sanction_Conditions__c();
            sanCntnList = [SELECT Id, Condition__c, Loan_Application__c  FROM Sanction_Conditions__c  WHERE Loan_Application__c =:loanAppId ];
            
            if(sanCntnList.size() >0){
                sanCntn = sanCntnList[0];
            }
           
            integer recTempId = 1;
            List<String> productListHL = new List<String>{'Home Loan', 'Small Ticket LAP'};
            List<String> productListBL = new List<String>{'Business Loan', 'Personal Loan'};
            
            if (productListHL.contains(product)) {
                fieldSet = fieldSetHL;
            } else if (productListBL.contains(product)) {
                fieldSet = fieldSetBL;
            }
            for (string fs : fieldSet) {
                system.debug( 'fs'+ fs);
                
                
                if (fs =='Applicant Name' ) {
                    loanAppealItem loanAplItem = new loanAppealItem();
                    loanAplItem.tempId = string.valueOf(recTempId);
                    loanAplItem.Id ='nullId' ;
                    loanAplItem.Field = fs;
                    loanAplItem.DataEntry = applicantName ;
                    loanAplItem.SalesDecision = '';
                    loanAplItem.SalesComment = '';
                    loanAplItem.UwDecision = '';
                    loanAplItem.UwComment ='';
                    
                    loanAplItemList.add(loanAplItem);
                    recTempId = recTempId+1;
                }else if(fs =='Co-applicants Name' && coAppList.size() >0 ){
                    integer coappCount = 1;
                    for (string coapp : coAppList) {
                        loanAppealItem loanAplItem = new loanAppealItem();
                        loanAplItem.tempId = string.valueOf(recTempId);
                        loanAplItem.Id ='nullId'  ;
                        loanAplItem.Field = fs + ' - ' +coappCount ;
                        loanAplItem.DataEntry = coapp ;
                        loanAplItem.SalesDecision = '';
                        loanAplItem.SalesComment = '';
                        loanAplItem.UwDecision = '';
                        loanAplItem.UwComment ='';
                        
                        loanAplItemList.add(loanAplItem);
                        coappCount = coappCount +1;
                        recTempId = recTempId+1; 
                    }
                    
                }else if( fs == 'Eligibility Method'){
                    loanAppealItem loanAplItem = new loanAppealItem();
                    loanAplItem.tempId = string.valueOf(recTempId);
                    loanAplItem.Id ='nullId'  ;
                    loanAplItem.Field = fs;
                    loanAplItem.DataEntry = breList.size()>0 ?breList[0].Application_level_Assessment_program__c :'';
                    loanAplItem.SalesDecision = '';
                    loanAplItem.SalesComment = '';
                    loanAplItem.UwDecision = '';
                    loanAplItem.UwComment ='';
                    
                    loanAplItemList.add(loanAplItem);
                    recTempId = recTempId+1;  
                }
                else if( fs == 'Total Loan amount including insurance (₹)'){
                    loanAppealItem loanAplItem = new loanAppealItem();  
                    loanAplItem.tempId = string.valueOf(recTempId);
                    loanAplItem.Id ='nullId'  ;
                    loanAplItem.Field = fs;
                    loanAplItem.DataEntry = string.valueOf(loapp.TotalLoanAmtInclInsurance__c !=null ? loapp.TotalLoanAmtInclInsurance__c: 0);
                    loanAplItem.SalesDecision = '';
                    loanAplItem.SalesComment = '';
                    loanAplItem.UwDecision = '';
                    loanAplItem.UwComment ='';
                    
                    loanAplItemList.add(loanAplItem);
                    recTempId = recTempId+1;  
                }
                else if( fs == 'Loan Amount (₹) - Without Insurance'){
                    loanAppealItem loanAplItem = new loanAppealItem();  
                    loanAplItem.tempId = string.valueOf(recTempId);
                    loanAplItem.Id ='nullId'  ;
                    loanAplItem.Field = fs;
                    loanAplItem.DataEntry = string.valueOf(lawI);
                    loanAplItem.SalesDecision = '';
                    loanAplItem.SalesComment = '';
                    
                    loanAplItem.UwDecision = '';
                    loanAplItem.UwComment ='';
                    
                    loanAplItemList.add(loanAplItem);
                    recTempId = recTempId+1;  
                }
                else if( fs == 'Loan Tenure (Months)'){
                    loanAppealItem loanAplItem = new loanAppealItem();  
                    loanAplItem.tempId = string.valueOf(recTempId);
                    loanAplItem.Id ='nullId'  ;
                    loanAplItem.Field = fs;
                    loanAplItem.DataEntry = string.valueOf(loapp.Loan_Tenure_Months__c);
                    loanAplItem.SalesDecision = '';
                    loanAplItem.SalesComment = '';
                    loanAplItem.UwDecision = '';
                    loanAplItem.UwComment ='';
                    
                    loanAplItemList.add(loanAplItem);
                    recTempId = recTempId+1;  
                }
                else if( fs == 'EMI (₹) - (Loan amount including insurance)'){
                    loanAppealItem loanAplItem = new loanAppealItem();  
                    loanAplItem.tempId = string.valueOf(recTempId);
                    loanAplItem.Id ='nullId'  ;
                    loanAplItem.Field = fs;
                    loanAplItem.DataEntry = string.valueOf(loapp.EMIIcludingInsurance__c);
                    loanAplItem.SalesDecision = '';
                    loanAplItem.SalesComment = '';
                    loanAplItem.UwDecision = '';
                    loanAplItem.UwComment ='';
                    
                    loanAplItemList.add(loanAplItem);
                    recTempId = recTempId+1;  
                }
                else if( fs == 'Repayment a/c Bank name + Repayment a/c no'){
                    loanAppealItem loanAplItem = new loanAppealItem();  
                    loanAplItem.tempId = string.valueOf(recTempId);
                    loanAplItem.Id ='nullId'  ;
                    loanAplItem.Field = fs;
                    loanAplItem.DataEntry =repAcc !=null?  repAcc.Bank_Name__c + ' - ' + repAcc.Account_Number__c: '';
                    loanAplItem.SalesDecision = '';
                    loanAplItem.SalesComment = '';
                    loanAplItem.UwDecision = '';
                    loanAplItem.UwComment ='';
                    
                    loanAplItemList.add(loanAplItem);
                    recTempId = recTempId+1;  
                }
                else if(fs =='Property Address' && appAssetList.size() >0 ){
                    integer coappCount = 1;
                    for (ApplAsset__c asset : appAssetList) {
                        loanAppealItem loanAplItem = new loanAppealItem();
                        loanAplItem.tempId = string.valueOf(recTempId);
                        loanAplItem.Id ='nullId'  ;
                        loanAplItem.Field = fs + ' - ' +coappCount ;
                        loanAplItem.DataEntry = asset.PropAddrs__c ;
                        loanAplItem.SalesDecision = '';
                        loanAplItem.SalesComment = '';
                        loanAplItem.UwDecision = '';
                        loanAplItem.UwComment ='';
                        
                        loanAplItemList.add(loanAplItem);
                        coappCount = coappCount +1;
                        recTempId = recTempId+1; 
                    }
                    
                }
                else if( fs == 'Sanction condition'){
                   
                    
                    if (productListHL.contains(product)) {
                        // loanAppealItem loanAplItem = new loanAppealItem();
                        // loanAplItem.tempId = string.valueOf(recTempId);
                        // loanAplItem.Id ='nullId'  ;
                        // loanAplItem.Field = fs;
                        // loanAplItem.DataEntry = sanCntn != null ? sanCntn.Condition__c :'';
                        // loanAplItem.SalesDecision = '';
                        // loanAplItem.SalesComment = '';
                        // loanAplItem.UwDecision = '';
                        // loanAplItem.UwComment ='';
                        
                        // loanAplItemList.add(loanAplItem);
                        // recTempId = recTempId+1; 
                        if(sanCntnList.size()>0){
                            integer sncount = 1;
                            for (Sanction_Conditions__c san : sanCntnList) {
                                loanAppealItem loanAplItem = new loanAppealItem();
                                loanAplItem.tempId = string.valueOf(recTempId);
                                loanAplItem.Id ='nullId'  ;
                                loanAplItem.Field = fs + ' - ' +sncount ;
                                loanAplItem.DataEntry = san.Condition__c != null ? san.Condition__c :'';
                                loanAplItem.SalesDecision = '';
                                loanAplItem.SalesComment = '';
                                loanAplItem.UwDecision = '';
                                loanAplItem.UwComment ='';
                                
                                loanAplItemList.add(loanAplItem);
                                recTempId = recTempId+1; 
                                sncount = sncount+1;
                            }
                        }else{
                            loanAppealItem loanAplItem = new loanAppealItem();
                            loanAplItem.tempId = string.valueOf(recTempId);
                            loanAplItem.Id ='nullId'  ;
                            loanAplItem.Field = fs;
                            loanAplItem.DataEntry = sanCntn != null ? sanCntn.Condition__c :'';
                            loanAplItem.SalesDecision = '';
                            loanAplItem.SalesComment = '';
                            loanAplItem.UwDecision = '';
                            loanAplItem.UwComment ='';
                            
                            loanAplItemList.add(loanAplItem);
                            recTempId = recTempId+1; 
                        }
                    } else if (productListBL.contains(product)) {
                        if(sanCntnList.size()>0){
                            integer sncount = 1;
                            for (Sanction_Conditions__c san : sanCntnList) {
                                loanAppealItem loanAplItem = new loanAppealItem();
                                loanAplItem.tempId = string.valueOf(recTempId);
                                loanAplItem.Id ='nullId'  ;
                                loanAplItem.Field = fs + ' - ' +sncount ;
                                loanAplItem.DataEntry = san.Condition__c != null ? san.Condition__c :'';
                                loanAplItem.SalesDecision = '';
                                loanAplItem.SalesComment = '';
                                loanAplItem.UwDecision = '';
                                loanAplItem.UwComment ='';
                                
                                loanAplItemList.add(loanAplItem);
                                recTempId = recTempId+1; 
                                sncount = sncount+1;
                            }
                        }else{
                            loanAppealItem loanAplItem = new loanAppealItem();
                            loanAplItem.tempId = string.valueOf(recTempId);
                            loanAplItem.Id ='nullId'  ;
                            loanAplItem.Field = fs;
                            loanAplItem.DataEntry = sanCntn != null ? sanCntn.Condition__c :'';
                            loanAplItem.SalesDecision = '';
                            loanAplItem.SalesComment = '';
                            loanAplItem.UwDecision = '';
                            loanAplItem.UwComment ='';
                            
                            loanAplItemList.add(loanAplItem);
                            recTempId = recTempId+1; 
                        }
                        
                    } 
                }
                else if( fs == 'Insurance Amount(₹)'){
                    loanAppealItem loanAplItem = new loanAppealItem();
                    loanAplItem.tempId = string.valueOf(recTempId);
                    loanAplItem.Id ='nullId'  ;
                    loanAplItem.Field = fs;
                    loanAplItem.DataEntry =  string.valueOf(insAmount);// add ins amount 
                    loanAplItem.SalesDecision = '';
                    loanAplItem.SalesComment = '';
                    loanAplItem.UwDecision = '';
                    loanAplItem.UwComment ='';
                    
                    loanAplItemList.add(loanAplItem);
                    recTempId = recTempId+1;  
                }
                else{
                    loanAppealItem loanAplItem = new loanAppealItem();
                    loanAplItem.tempId = string.valueOf(recTempId);
                    loanAplItem.Id ='nullId'  ;
                    loanAplItem.Field = fs;
                    loanAplItem.DataEntry = '' ;
                    loanAplItem.SalesDecision = '';
                    loanAplItem.SalesComment = '';
                    loanAplItem.UwDecision = '';
                    loanAplItem.UwComment ='';
                    
                    loanAplItemList.add(loanAplItem);
                    recTempId = recTempId+1;  
                }
                
                
            }
            
            loanAppealWrapper laplWrapper = new loanAppealWrapper();
            laplWrapper.Id = 'null';
            laplWrapper.Status = 'New';
            laplWrapper.RecType = '';
            laplWrapper.LoanAplItem = loanAplItemList;
            return laplWrapper;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()+ e.getLineNumber());
        }
    }
    
    @AuraEnabled
    public static string  createLoanTerm( loanAppealWrapper loanTermRec, string loanAppId ){
        try {
            System.debug(' loanTermRec is   '+loanAppId+ ' ...............  '+ loanTermRec);
            
            
            Id UwPoolId = [select  id  from group where name = 'UW Pool' limit 1].Id;
            
            system.debug( ' loanTermRec   : '+ loanTermRec.Id);
            
            LoanAppeal__c lappl = new LoanAppeal__c ();
            
            // lappl.Id =  loanTermRec.Id != 'null' ?  loanTermRec.Id :'';
            
            if(  loanTermRec.Id =='null'){
                system.debug( ' loanTermRec   1  : '+ loanTermRec.Id);
                lappl.Status__c ='New'; 
                lappl.OwnerId = UwPoolId;
            }else{
                lappl.Id = loanTermRec.Id;
                lappl.Status__c =loanTermRec.Status;
                lappl.Comments__c = loanTermRec.Comments;
               
                // if(loanTermRec.Status == 'Approve'){
                //     updateLoanApplication(loanTermRec.OwnerId,loanAppId);
                // }
                // if(loanTermRec.Status == 'Reject'){
                //   updateLoanApplication(loanTermRec.OwnerId,loanAppId);
                // }
            }
            lappl.RecordTypeId = Schema.SObjectType.LoanAppeal__c.getRecordTypeInfosByName().get('Loan Term Negotiation').getRecordTypeId(); 
            lappl.LoanAppl__c = loanAppId;
            
            
            upsert lappl;
            system.debug('lappl with Id '+ lappl.Id);
            List<LoanAppealItem__c> laitmList = new List<LoanAppealItem__c>();
            if(!loanTermRec.LoanAplItem.isEmpty()){
                for (loanAppealItem lta : loanTermRec.LoanAplItem) {
                    LoanAppealItem__c  laitm = new LoanAppealItem__c ();
                    system.debug('lta   ........ '+ lta.Id +'   .......   '+lta);
                    if( lta.Id == 'nullId'){
                        system.debug('lta   .Null Id ....... ');
                        //  laitm.Id =  !String.isBlank(lta.Id) ?  lta.Id : '';
                    }else{
                        system.debug('lta  Not .Null Id ....... ');
                        laitm.Id =  lta.Id ;
                    }        
                    laitm.Field__c =lta.Field;        
                    laitm.Sales_Des__c =lta.SalesDecision; 
                    laitm.SalesComments__c =lta.SalesComment; 
                    laitm.UWDecision__c =lta.UwDecision; 
                    laitm.UWComments__c =lta.UwComment; 
                    laitm.LoanAppeal__c =lappl.Id; 
                    laitm.Data_Entry__c =lta.DataEntry; 
                    laitmList.add(laitm);        
                }
            }
            if(!laitmList.isEmpty()){
                upsert laitmList;
                
                
            }
            
            return lappl.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()+ '  error line no '+  e.getLineNumber());
        }
        
    }
    public static void updateLoanApplication (string OwnerId,string loanAppId){
        LoanAppl__c  ln = new LoanAppl__c();
        ln.Id = loanAppId ;
        ln.OwnerId = OwnerId;
        update ln;
    }
    // @AuraEnabled
    // public static string  updateLoanTerm( loanAppealWrapper loanTermRec, string loanAppId ){
    //     try {
    
    //        system.debug( ' loanTermRec   : '+ loanTermRec.Id);
    
    //         LoanAppeal__c lappl = new LoanAppeal__c ();
    
    //         lappl.Id =  loanTermRec.Id ;
    
    //         lappl.OwnerId = UwPoolId;
    //         lappl.Status__c = lappl.Status
    //         system.debug('lappl '+ lappl);
    //         upsert lappl;
    //         system.debug('lappl with Id '+ lappl.Id);
    //         List<LoanAppealItem__c> laitmList = new List<LoanAppealItem__c>();
    //         if(!loanTermRec.LoanAplItem.isEmpty()){
    //             for (loanAppealItem lta : loanTermRec.LoanAplItem) {
    //                 LoanAppealItem__c  laitm = new LoanAppealItem__c ();
    //                 system.debug('lta   ........ '+ lta.Id +'   .......   '+lta);
    //         if( lta.Id == 'nullId'){
    //             system.debug('lta   .Null Id ....... ');
    //           //  laitm.Id =  !String.isBlank(lta.Id) ?  lta.Id : '';
    //         }else{
    //             system.debug('lta  Not .Null Id ....... ');
    //             laitm.Id =  lta.Id ;
    //         }        
    //                 laitm.Field__c =lta.Field;        
    //                 laitm.Sales_Des__c =lta.SalesDecision; 
    //                 laitm.SalesComments__c =lta.SalesComment; 
    //                 laitm.UWDecision__c =lta.UwDecision; 
    //                 laitm.UWComments__c =lta.UwComment; 
    //                 laitm.LoanAppeal__c =lappl.Id; 
    //                 laitm.Data_Entry__c =lta.DataEntry; 
    //                 laitmList.add(laitm);        
    //               }
    //         }
    //      if(!laitmList.isEmpty()){
    //         upsert laitmList;
    
    
    //      }
    
    //         return 'Success';
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage()+ '  error line no '+  e.getLineNumber());
    //     }
    
    // }
    @AuraEnabled
    public static  List<loanAppealWrapper>  getLoanTerm( string loanAplId){
        try {
            List<LoanAppeal__c> lapplList  = new List<LoanAppeal__c>();
            list<LoanAppealItem__c> lappplItmList = new list<LoanAppealItem__c>();
            List<loanAppealWrapper> lappWrapperList= new List<loanAppealWrapper>();
            
            lapplList = [SELECT Id, OwnerId,Name, Owner.Name,CreatedDate, Status__c, LoanAppl__c, Comments__c, DocDet__c,  OwnerName__c, LAN__c, (SELECT Id, Field__c, Data_Entry__c, Sales_Des__c, SalesComments__c, UWDecision__c, UWComments__c, LoanAppeal__c FROM Loan_Appeal_Items__r ) FROM LoanAppeal__c  where LoanAppl__c =: loanAplId AND RecordType.DeveloperName ='LoanTermNegotiation' order by CreatedDate];
            
            if(!lapplList.isEmpty()){
                for (LoanAppeal__c lapp : lapplList) {
                    loanAppealWrapper lappWrapper= new loanAppealWrapper();
                    lappWrapper.Id = lapp.Id;
                    lappWrapper.Status =lapp.Status__c;
                    lappWrapper.Comments = lapp.Comments__c;
                    lappWrapper.OwnerId = lapp.OwnerId;
                    lappWrapper.Name = lapp.Name;
                    lappWrapper.OwnerName = lapp.Owner.Name;
                    lappWrapper.CreatedDate = lapp.CreatedDate;
                    list<loanAppealItem> lappItemListWpr = new list<loanAppealItem> ();
                    if(!lapp.Loan_Appeal_Items__r.isEmpty()){
                        for (LoanAppealItem__c lappitem :  lapp.Loan_Appeal_Items__r) {
                            loanAppealItem lappItemWpr = new loanAppealItem ();
                            lappItemWpr.Id = lappitem.Id;
                            lappItemWpr.tempId =lappitem.Id; 
                            lappItemWpr.Field = lappitem.Field__c;
                            lappItemWpr.DataEntry = lappitem.Data_Entry__c;
                            lappItemWpr.SalesDecision = lappitem.Sales_Des__c;
                            lappItemWpr.UwDecision = lappitem.UWDecision__c;
                            lappItemWpr.SalesComment = lappitem.SalesComments__c;
                            lappItemWpr.UwComment = lappitem.UWComments__c;
                            lappItemListWpr.add(lappItemWpr);
                        }
                        lappWrapper.LoanAplItem = lappItemListWpr;
                    }
                    lappWrapperList.add(lappWrapper);
                    
                }
                
            }
            
            
            
            //  lappplItmList = new List<LoanAppealItem__c>([SELECT  Id, Field__c, Data_Entry__c, Sales_Des__c, SalesComments__c, UWDecision__c, UWComments__c, LoanAppeal__c  FROM LoanAppealItem__c  WHERE LoanAppeal__c =: loanAppilId]);
            
            
            return lappWrapperList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class loanAppealItem{
        @AuraEnabled
        public String tempId  {get;set;}
        @AuraEnabled
        public String Id  {get;set;}
        @AuraEnabled
        public String Field {get;set;}
        @AuraEnabled
        public String DataEntry {get;set;}
        @AuraEnabled
        public String SalesDecision  {get;set;}
        @AuraEnabled
        public Boolean SalesCommReq  {get;set;}
        @AuraEnabled
        public String SalesComment  {get;set;}
        @AuraEnabled
        public String UwDecision  {get;set;}
        @AuraEnabled
        public Boolean UwCommReq  {get;set;}
        @AuraEnabled
        public String UwComment  {get;set;}
        
    }
    public class loanAppealWrapper {
        @AuraEnabled
        public String Id  {get;set;}
        @AuraEnabled
        public List<loanAppealItem> LoanAplItem  {get;set;}
        @AuraEnabled
        public String Status  {get;set;}
        @AuraEnabled
        public String RecType  {get;set;}
        @AuraEnabled
        public String OwnerId  {get;set;}
        @AuraEnabled
        public String Comments  {get;set;}
        @AuraEnabled
        public String Name  {get;set;}
        @AuraEnabled
        public String OwnerName  {get;set;}
        @AuraEnabled
        public DateTime CreatedDate  {get;set;}
    }
 
    
    
}