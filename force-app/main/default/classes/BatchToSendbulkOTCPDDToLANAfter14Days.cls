global class BatchToSendbulkOTCPDDToLANAfter14Days implements Database.Batchable<sobject>, schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        return Database.getQueryLocator([select id,FinnSubDtTime__c,BrchCode__c,BrchName__c,UWUser__c,
                                         Product__c,RMSMName__r.Email,Applicant__r.TabName__c,name,CPA_User__c,CPA_User__r.Email,UWUser__r.Email,
                                         RM__c,RMSMName__c from LoanAppl__c  where Loan_Boarding_API_Status__c ='Success' 
                                         and Stage__c ='Disbursed'
                                         and  FinnSubDtTime__c =N_DAYS_AGO:14 order by BrchCode__c]);
    }
    
    global void execute(Database.BatchableContext BC, list<LoanAppl__c> loanList) {
        try{
        system.debug('2');
        
        Map<String,List<loanAppl__c>> mapOfBranchToLoan = new Map<String,List<loanAppl__c>>();
        set<Id> setLoanIds = new set<Id>();
        set<string> brchCode = new set<string>();
        set<string> productType = new set<string>();
        String productTypeString;
        List<loanAppl__c> lstLoanApp = new List<loanAppl__c>();
        Map<String,String> mapOfBranchName = new Map<String,String>();
        List<LocBrchJn__c> BranchStateData = new List<LocBrchJn__c>();
        List<DocDtl__c> lstDocDetails = new List<DocDtl__c>();
        Map<String,String> mapOfBranchState = new Map<String,String>();
        Map<Id, List<DocDtl__c>> mapOfLoanDocument = new Map<Id, List<DocDtl__c>>();
        Map<Id,Integer> mapOfCountOTC = new Map<Id,Integer>();
        Map<Id,Integer> mapOfCountPDD = new Map<Id,Integer>();
        List<DocDtl__c> lstDocumentDetails = new List<DocDtl__c>();
        Map<string, string> BranchToBBhMap = new Map<string, string>();
        //LAK-8625 - Jayesh
        Map<string, Id> BranchToBBhMapId = new Map<string, Id>();
        Map<string, string> BranchToBBhNameMap = new Map<string, string>();
        Map<string, String> branchtoCPAUWMap = new Map<string, String>();
        List<String> sendToAddressesList = new List<String>();
        List<String> sendCCAddressesList = new List<String>();
        Map<String,String> BranchToNOM = new Map<String,String>();
       	set<string> rmUser = new set<string>();
        set<string> cpaUser = new set<string>();
        set<string> uwUser = new set<string>();
        Set<Id> loanIdsWithOTCOrPDD = new Set<Id>();
        Integer countOTC = 0;
        Integer countPDD = 0;
          Boolean emailSent;
        
        
        for(LoanAppl__c loan : loanList ){
            setLoanIds.add(loan.id);
            brchCode.add(loan.BrchCode__c);
            productType.add(loan.Product__c);
            rmUser.add(loan.RMSMName__c);
            cpaUser.add(loan.CPA_User__c);
            uwUser.add(loan.UWUser__c);
            mapOfBranchName.put(loan.BrchCode__c,loan.BrchName__c);
            if(mapOfBranchToLoan.containsKey(loan.BrchCode__c)){
                mapOfBranchToLoan.get(loan.BrchCode__c).add(loan);
            }else{
                mapOfBranchToLoan.put(loan.BrchCode__c,new List<LoanAppl__c> {loan});
            } 
        }
        
        
        productTypeString = String.join(productType,';');
        
        system.debug('productTypeString-->'+productTypeString);
        system.debug('mapOfBranchToLoan-->'+mapOfBranchToLoan);
        
        for(LocBrchJn__c loc :[Select id, Location__r.State__c,Branch__r.BrchCode__c from LocBrchJn__c where Branch__r.BrchCode__c In:brchCode]){
            if(String.isNotBlank(loc.Branch__r.BrchCode__c) && String.isNotBlank(loc.Location__r.State__c))
                mapOfBranchState.put(loc.Branch__r.BrchCode__c,loc.Location__r.State__c);
        }
        system.debug('mapOfBranchState:'+mapOfBranchState);
        
        for (DocDtl__c doc: [select LAN__r.Id,id,DocCatgry__c, DocStatus__c, DocSubTyp__c from DocDtl__c where LAN__c in:setLoanIds and DocStatus__c IN ('OTC','PDD')]){
            if(mapOfCountOTC.containsKey(doc.LAN__r.id) && doc.DocStatus__c =='OTC'){
                countOTC = countOTC + 1;
                mapOfCountOTC.put(doc.LAN__r.id, countOTC);
            }
            
            else if(mapOfCountOTC.containsKey(doc.LAN__r.id) && doc.DocStatus__c =='PDD'){
                countPDD = countPDD + 1;
                mapOfCountPDD.put(doc.LAN__r.id, countPDD);
            }
            else{    
                countOTC = 0;
                countPDD = 0;
                
                if(doc.DocStatus__c =='OTC'){
                    countOTC = countOTC + 1;
                    mapOfCountOTC.put(doc.LAN__r.id, countOTC);
                }
                else if(doc.DocStatus__c =='PDD'){
                    countPDD = countPDD + 1;
                    mapOfCountPDD.put(doc.LAN__r.id, countPDD);
                }
            }
            loanIdsWithOTCOrPDD.add(doc.LAN__r.Id);
            
        }
        
        // LAK-8366 Remove loans with no OTC or PDD documents from mapOfBranchToLoan
        for (String branchCode : new List<String>(mapOfBranchToLoan.keySet())) {
            List<loanAppl__c> loans = mapOfBranchToLoan.get(branchCode);
            List<loanAppl__c> loansToKeep = new List<loanAppl__c>();
            
            for (loanAppl__c loan : loans) {
                if (loanIdsWithOTCOrPDD.contains(loan.Id)) {
                    loansToKeep.add(loan);
                }
            }
            
            if (loansToKeep.isEmpty()) {
                mapOfBranchToLoan.remove(branchCode);
            } else {
                mapOfBranchToLoan.put(branchCode, loansToKeep);
            }
        }
        /*for (TeamHierarchy__c teamHir: [select id,Employee__r.Email,Employee__r.Name,BranchCode__c,emprole__c from TeamHierarchy__c where BranchCode__c in:brchCode and Product_Type__c INCLUDES(:productTypeString)]) {
            if(teamHir.emprole__c == 'BBH'){
                BranchToBBhMap.put(teamHir.BranchCode__c, teamHir.Employee__r.Email);
                BranchToBBhNameMap.put(teamHir.BranchCode__c,teamHir.Employee__r.Name);
            }
            if(teamHir.emprole__c == 'CPA' || teamHir.emprole__c == 'UW' || teamHir.emprole__c ==  'ACM' || teamHir.emprole__c ==  'RCM' || teamHir.emprole__c == 'NCM' || teamHir.emprole__c == 'ZCM' || teamHir.emprole__c == 'CH'){
                branchtoCPAUWMap.put(teamHir.branchcode__c,teamHir.Employee__r.Email);
            }
        }*/
        
        ///
                list<TeamHierarchy__c> bbhlist = [select id,Employee__c,Employee__r.Email,Employee__r.Name,BranchCode__c,emprole__c,L2_Email__c,L1Email__c,L3Email__c,L4Email__c from TeamHierarchy__c where emprole__c = 'BBH' and BranchCode__c in:brchCode and Product_Type__c INCLUDES(:productTypeString) order by LastModifiedDate];
        Map<string, string> BranchToRBHMap = new Map<string, string>();
        Map<string, string> BranchToABHMap = new Map<string, string>();
        Map<string, string> BranchToZBHMap = new Map<string, string>();
        Map<string, string> BranchToBHMap = new Map<string, string>();
        for (TeamHierarchy__c bbhEmail: bbhlist) {
            BranchToBBhMap.put(bbhEmail.BranchCode__c, bbhEmail.Employee__r.Email);
            BranchToBBhNameMap.put(bbhEmail.BranchCode__c,bbhEmail.Employee__r.Name);
            //LAK-8625 - Jayesh
            BranchToBBhMapId.put(bbhEmail.BranchCode__c, bbhEmail.Employee__c);
            BranchToABHMap.put(bbhEmail.BranchCode__c, bbhEmail.L1Email__c);
            BranchToRBHMap.put(bbhEmail.BranchCode__c, bbhEmail.L2_Email__c);
            BranchToZBHMap.put(bbhEmail.BranchCode__c, bbhEmail.L3Email__c);
            BranchToBHMap.put(bbhEmail.BranchCode__c, bbhEmail.L4Email__c);
        }
        system.debug('BranchToBBhMap-->'+BranchToBBhMap);
        
        Map<string, String> branchsmMap = new Map<string, String>();
        
        list<TeamHierarchy__c> smList = [Select id, employee__r.email, branchcode__c,L1Email__c,Employee__c  from TeamHierarchy__c where Employee__c =: rmUser and BranchCode__c in:brchCode and Product_Type__c INCLUDES(:productTypeString)];
        
        for(TeamHierarchy__c teamHList : smList){
            
            branchsmMap.put(teamHList.branchcode__c,teamHList.L1Email__c);
            // cpaUWEmailList
        }
        system.debug('branchsmMap-->'+branchsmMap);
        
        
        Map<string, String> branchuwMap = new Map<string, String>();
        Map<string, String> branchuw2Map = new Map<string, String>();
        Map<string, String> branchuw3Map = new Map<string, String>();
        Map<string, String> branchuw4Map = new Map<string, String>();
       list<TeamHierarchy__c> uwHirachyList = [Select id, employee__r.email, branchcode__c,L1Email__c,L2_Email__c,L3Email__c,L4Email__c  from TeamHierarchy__c where Employee__c =: uwUser and BranchCode__c in:brchCode and Product_Type__c INCLUDES(:productTypeString)];
        
        for(TeamHierarchy__c teamHList : uwHirachyList){
            
            branchuwMap.put(teamHList.branchcode__c,teamHList.L1Email__c);
            branchuw2Map.put(teamHList.branchcode__c,teamHList.L2_Email__c);
            branchuw3Map.put(teamHList.branchcode__c,teamHList.L3Email__c);
            branchuw4Map.put(teamHList.branchcode__c,teamHList.L4Email__c);
            // cpaUWEmailList
        }
        system.debug('branchuwMap-->'+branchuwMap);
        
        ///
        
        //NOM User removed branch code condition
     /*   for (TeamHierarchy__c teamHir1: [select id,Employee__r.Email,Employee__r.Name,BranchCode__c,emprole__c from TeamHierarchy__c where  Product_Type__c INCLUDES(:productTypeString) AND emprole__c = 'NOM']) {
            BranchToNOM.put(teamHir1.branchcode__c, teamHir1.Employee__r.Email);
        }*/
        
        
        system.debug('BranchToBBhMap-->'+BranchToBBhMap);
        system.debug('branchtoCPAUWMap-->'+branchtoCPAUWMap);
        
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:system.label.orgWideEmail];
        
        Set<Id> setIds = new set<Id>();
        List<String> listBranchName = new List<String>();
        System.debug('BranchToBBhMap-->'+BranchToBBhMap);
        System.debug('branchtoCPAUWMap-->'+branchtoCPAUWMap);
        
        if(mapOfBranchToLoan.size()>0){
            for (String branchCode: mapOfBranchToLoan.keySet()){
               
                if (BranchToBBhMap.containsKey(branchCode)) {
                    sendToAddressesList.add(BranchToBBhMap.get(branchCode));
                }
                if (BranchToABHMap.containsKey(branchCode)) {
                    sendToAddressesList.add(BranchToABHMap.get(branchCode));
                }
                if (BranchToRBHMap.containsKey(branchCode)) {
                    sendToAddressesList.add(BranchToRBHMap.get(branchCode));
                }
                
                if (BranchToZBHMap.containsKey(branchCode)) {
                    sendToAddressesList.add(BranchToZBHMap.get(branchCode));
                }
                
                if (BranchToBHMap.containsKey(branchCode)) {
                    sendToAddressesList.add(BranchToBHMap.get(branchCode));
                }
                if (branchsmMap.containsKey(branchCode)) {
                    sendToAddressesList.add(branchsmMap.get(branchCode));
                }
                if (branchuwMap.containsKey(branchCode)) {
                    sendCCAddressesList.add(branchuwMap.get(branchCode));
                }
                if (branchuw2Map.containsKey(branchCode)) {
                    sendCCAddressesList.add(branchuw2Map.get(branchCode));
                }
                
                if (branchuw3Map.containsKey(branchCode)) {
                    sendCCAddressesList.add(branchuw3Map.get(branchCode));
                }
                
                if (branchuw4Map.containsKey(branchCode)) {
                    sendCCAddressesList.add(branchuw4Map.get(branchCode));
                }
                
                List<String> cleanedSendToAddressesList = new List<String>();
                for (String email : sendToAddressesList) {
                    if (email != null) {
                    cleanedSendToAddressesList.add(email);
                    }
	            }

	            sendToAddressesList = cleanedSendToAddressesList;
        
                List<String> cleanedsendCCAddressesList = new List<String>();
                for (String email : sendCCAddressesList) {
                    if (email != null) {
                    cleanedsendCCAddressesList.add(email);
                    }
	            }

	            sendCCAddressesList = cleanedsendCCAddressesList;
                
                List<Messaging.SingleEmailMessage> mailList =  new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage newMail = new Messaging.SingleEmailMessage();
                
                if ( owea.size() > 0 ) {
                    newMail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                //LAK-8625 - Jayesh
                if(BranchToBBhMapId.containsKey(branchCode)){
                    newMail.setTargetObjectId(BranchToBBhMapId.get(branchCode));
                    newMail.setSaveAsActivity(false);
                }
                newMail.setSubject('Reminder: Pending OTC/PDD Documents of '+ mapOfBranchState.get(branchCode) +' Region of MSE LAP/ AFHL ');
                String body = 'Hi,<br/><br/> Please find the list of MSE LAP/ AFHL Loan application where OTC/PDD Documents are pending for over 14 days for '+ mapOfBranchState.get(branchCode) +' Region.  Kindly resolve the same at earliest for timely closure.';   
                // body+='<h3> OTC Documents</h3>';
                body+='<br/><br/> <table border="1" style="border-collapse: collapse">';
                body+='<tr>';
                body+='<th>Application No.</th>';
                body+='<th>Disbursment Date</th>';
                body+='<th>Days since Disbursment</th>';
                body+='<th>Branch Name</th>';
                body+='<th>RM Name</th>';
                body+='<th>BBH Name</th>';
                body+='<th>No of Pending OTC</th>';
                body+='<th>No of Pending PDD</th>';
                body+='</tr>';
                for (LoanAppl__c loan: mapOfBranchToLoan.get(branchCode) ){
                    if(mapOfCountOTC.get(loan.id) != null || mapOfCountPDD.get(loan.id) != null){
                        emailSent = true;
                    }
                    
                   Integer otcCount;
                   integer pddCount;
                    if(mapOfCountOTC.get(loan.id) != null){
                       otcCount =  mapOfCountOTC.get(loan.id);
                    }else{
                        otcCount = 0;
                    }
                    
                    if(mapOfCountPDD.get(loan.id) != null){
                      pddCount =  mapOfCountPDD.get(loan.id); 
                    }else{
                        pddCount =  0;
                    }
                    
                    integer DisbursmentDays = date.valueof(loan.FinnSubDtTime__c).daysBetween(Date.today());
                    
                    if(loan.RMSMName__r.Email != null){
                       sendToAddressesList.add(loan.RMSMName__r.Email); 
                    }
                    if(loan.UWUser__r.Email != null){
                        sendCCAddressesList.add(loan.UWUser__r.Email);
                    }
                     if(loan.CPA_User__r.Email != null){
            		   sendCCAddressesList.add(loan.CPA_User__r.Email);
                    }
                system.debug('sendToAddressesList:'+sendToAddressesList);
                    
                system.debug('sendCCAddressesList:'+sendCCAddressesList);
                  
                    body+='<tr>';
                    body+='<td style="text-align: center; vertical-align: middle;">'+loan.name+'</td>';
                    body+='<td style="text-align: center; vertical-align: middle;">'+loan.FinnSubDtTime__c+'</td>';
                    body+='<td style="text-align: center; vertical-align: middle;">'+ DisbursmentDays +'</td>';
                    body+='<td style="text-align: center; vertical-align: middle;">'+loan.BrchName__c +'</td>';
                    body+='<td style="text-align: center; vertical-align: middle;">'+loan.RM__c+'</td>';
                    body+='<td style="text-align: center; vertical-align: middle;">'+BranchToBBhNameMap.get(branchCode)+'</td>';
                    body+='<td style="text-align: center; vertical-align: middle;">'+ otcCount +'</td>';
                    body+='<td style="text-align: center; vertical-align: middle;">'+pddCount +'</td>';
                    body+='</tr>';
                    
                }
                body+='</table>';
                body+='<br/>';
                body+='Thanks & Rgds.,';
               
                  if(!sendToAddressesList.IsEmpty()){
                  newMail.setToAddresses(sendToAddressesList);
                  newMail.setCcAddresses(sendCCAddressesList);
                  newMail.setHtmlBody(body);
                  }
                system.debug('After Html body '+body);
                
                mailList.add(newMail);
                
                //sendToAddressesList.clear();
               // sendCCAddressesList.clear();
                system.debug('new mail-->'+newMail);
                
                if(!mailList.isEmpty() && emailSent == True &&  !sendToAddressesList.isEmpty()){
                   if(!Test.IsRunningTest()){
                    List<EmailMessage> EmailMessList = new List<EmailMessage>();
                    for(Messaging.SingleEmailMessage mess : mailList){
                        EmailMessage emailMess = new EmailMessage();
                        emailMess.ToAddress = String.join(mess.getToAddresses(), ', '); 
                        if(mess.getCcAddresses() != null){
                            emailMess.CcAddress = String.join(mess.getCcAddresses(), ', ');  
                        }           
                        emailMess.HtmlBody = mess.getHtmlBody();
                        emailMess.Subject = mess.getSubject();
                        emailMess.Status = '3';
                        if(mess.getWhatId() != null){
                            emailMess.RelatedToId = mess.getWhatId(); 
                        }
                        emailMess.BulkEmail__c=true;
                        EmailMessList.add(emailMess);
                    }
                
                    if(!EmailMessList.isEmpty() && EmailMessList != null) {
                        Insert EmailMessList;
                    }
                    EmailMessageBatchHandler.handleEmailMessage(EmailMessList);
                   }
                }
            }
        }
    }catch(Exception e){
        System.debug('Problem sending notification: ' + e.getMessage());
    }
    } 
    
    
    
    
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    global void execute(SchedulableContext sc) {
        try{
        BatchToSendbulkOTCPDDToLANAfter14Days BatchToSendBulkODCPDD = new BatchToSendbulkOTCPDDToLANAfter14Days();
        Database.executeBatch(BatchToSendBulkODCPDD);
        }catch(Exception e){
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
}