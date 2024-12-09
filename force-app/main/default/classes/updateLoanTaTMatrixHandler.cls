public class updateLoanTaTMatrixHandler implements TriggerAction.AfterUpdate{
    
    public static void afterUpdate(List<DocDtl__c> newList, List<DocDtl__c> oldList) {
        
        Map<Id, DocDtl__c> oldRecordsMap = new Map<Id, DocDtl__c>(oldList);   
        
        Map<Id,Map<String,List<DocDtl__c>>> loanAppWithDocStaMap = new Map<Id,Map<String,List<DocDtl__c>>>();
        Map<String,LoanTATMatrix__c> uniqIdWithLoanTATMatMap = new Map<String,LoanTATMatrix__c>();
        List<LoanTATMatrix__c> loanTATMatrxRecds = new List<LoanTATMatrix__c>();
        List<LoanTATMatrix__c> loanTATMatrxRecdsToUpdate = new List<LoanTATMatrix__c>();
        
        for(DocDtl__c docDtl : newList){
            
            if((docDtl.DocStatus__c == 'OTC' || docDtl.DocStatus__c == 'PDD') && docDtl.ReceivedDt__c != null  && docDtl.ReceivedDt__c != oldRecordsMap.get(docDtl.Id).ReceivedDt__c){
                
                Map<String,List<DocDtl__c>> existringRecord = loanAppWithDocStaMap.get(docDtl.LAN__c);
                
                if(existringRecord == null) {        
                    existringRecord = new Map<String,List<DocDtl__c>>();      
                    List<DocDtl__c> docRecords =new List<DocDtl__c> ();           
                    docRecords.add(docDtl);            
                    existringRecord.put(docDtl.DocStatus__c,docRecords);           
                }else{                  
                    List<DocDtl__c> docRecords = existringRecord.get(docDtl.DocStatus__c);  
                    if(docRecords == null){
                        docRecords = new List<DocDtl__c> ();
                    }
                    docRecords.add(docDtl);           
                    existringRecord.put(docDtl.DocStatus__c,docRecords);                      
                }
                loanAppWithDocStaMap.put(docDtl.LAN__c,existringRecord);
            }
        }
        
        Map<Id, LoanAppl__c> loanDetWithMap = new Map<Id, LoanAppl__c>([SELECT Id,FinnSubDtTime__c FROM LoanAppl__c WHERE Id IN :loanAppWithDocStaMap.keySet()]);
        
        if(loanAppWithDocStaMap != null && loanAppWithDocStaMap.size() > 0){
            loanTATMatrxRecds = [SELECT Id,UniqueId__c FROM LoanTATMatrix__c WHERE LoanApp__c IN : loanAppWithDocStaMap.keySet() AND (TATName__c = 'OTC TAT' OR TATName__c = 'PDD TAT')];
        }
        
        if(loanTATMatrxRecds != null && loanTATMatrxRecds.size() > 0){
            for(LoanTATMatrix__c loanTatMat : loanTATMatrxRecds){
                uniqIdWithLoanTATMatMap.put(loanTatMat.UniqueId__c,loanTatMat);
            }
        }
        
        if(loanAppWithDocStaMap != null && loanAppWithDocStaMap.size() > 0){
            for(Id loanId : loanAppWithDocStaMap.keyset()){ 
                
                Map<String,List<DocDtl__c>> docStsWithDocDtls = loanAppWithDocStaMap.get(loanId);
                
                for(String str : docStsWithDocDtls.keyset()){ 
                    String strr;
                    String tatName;
                    if(str == 'OTC'){
                        strr = loanId + '-OTC TAT';
                        tatName = 'OTC TAT';
                    }else if(str == 'PDD'){
                        tatName = 'PDD TAT';
                        strr = loanId + '-PDD TAT';
                    }
                    LoanTATMatrix__c loanTatMatrx = uniqIdWithLoanTATMatMap.get(strr);
                    
                    List<DocDtl__c> docList = docStsWithDocDtls.get(str);
                    Date receivedDate = Date.newInstance(1900, 1, 1); // Initialize with a default value
                    DocDtl__c docDtRec = new DocDtl__c();
                    for (DocDtl__c docDt : docList) {
                        if (docDt.ReceivedDt__c != null ) {
                            if(docDt.ReceivedDt__c > receivedDate){
                                receivedDate = docDt.ReceivedDt__c;
                                docDtRec = docDt;
                            }   
                        }else{
                            docDtRec = docDt;
                            receivedDate = docDt.ReceivedDt__c;
                        }
                    }
                    system.debug('receivedDate '+ receivedDate);
                    Datetime todayDateTime = receivedDate;
                    system.debug('todayDateTime '+ todayDateTime);  
                    LoanAppl__c loanAppRec = loanDetWithMap.get(loanId);
                    
                    Datetime finnOneSubmtTime = loanAppRec.FinnSubDtTime__c;
                    
                    system.debug('finnOneSubmtTime  '+ finnOneSubmtTime);
                    
                    Decimal differenceInMilliseconds = Decimal.valueOf(todayDateTime.getTime() - finnOneSubmtTime.getTime());
                    Decimal hoursDifference = differenceInMilliseconds/1000/60/60; 
                    //Long differenceInMilliseconds = todayDateTime.getTime() - finnOneSubmtTime.getTime();    
                    system.debug('differenceInMilliseconds  is  ' +  differenceInMilliseconds); 
                    // Decimal hoursDifference = differenceInMilliseconds / (1000.0 * 60.0 * 60.0); 
                    //hoursDifference = hoursDifference.setScale(2);
                    system.debug('hoursDifference  is  ' +  hoursDifference);
                    
                    LoanTATMatrix__c loanTatMtrxRec = new LoanTATMatrix__c();
                    
                    if(loanTatMatrx == null){
                        loanTatMtrxRec.LoanApp__c = loanId;
                        loanTatMtrxRec.UniqueId__c = strr;
                        loanTatMtrxRec.TATName__c = tatName;
                        loanTatMtrxRec.TimeSpentInhrs__c = hoursDifference;
                    }else{
                        loanTatMtrxRec.Id = loanTatMatrx.Id;
                        loanTatMtrxRec.TimeSpentInhrs__c = hoursDifference;
                    } 
                    loanTATMatrxRecdsToUpdate.add(loanTatMtrxRec);
                }
            }
        }
        if(loanTATMatrxRecdsToUpdate != null && loanTATMatrxRecdsToUpdate.size() > 0){
            system.debug('loanTATMatrxRecdsToUpdate ' + loanTATMatrxRecdsToUpdate);
            upsert loanTATMatrxRecdsToUpdate;
        }  
        
    }    
}