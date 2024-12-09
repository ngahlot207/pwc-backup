public without sharing class ObligatoryDtls {
    
    @auraEnabled
	public static void insertMultipleRecord(List<Applicant_Obligation_detail__c> params){
        system.debug('params'+params);
        if(params != null && params.size() > 0 ){
            system.debug('params'+params);
            insert params;
        }  
    } 


    @AuraEnabled
    public static Map<String,String> getIdMapForSfdcMstrObjs(List<String> bankNames){
        try 
        { 
        Set<String> bankNamesSet = new Set<String>(bankNames);    
        System.debug('bankNamesSet =='+bankNamesSet);
        Map<String,String> masterDataMap= new Map<String,String> ();    
        List<SFDCBANKMaster__c> listSfdcMstr =[SELECT Id,Name, BankName__c, BankCode__c from SFDCBANKMaster__c where BankName__c IN : bankNamesSet];
        System.debug('found list is ::'+listSfdcMstr);
        if(!listSfdcMstr.isEmpty()){
            for(SFDCBANKMaster__c eachMstr : listSfdcMstr){
                masterDataMap.put(eachMstr.BankName__c,eachMstr.Id);
            }
        }
        System.debug('found return master ::'+masterDataMap);
        return masterDataMap;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String,String> getIdMapForBalTranFinancier(List<String> bankNames){
        try 
        { 
        Set<String> bankNamesSet = new Set<String>(bankNames);
        System.debug('bankNamesSet =='+bankNamesSet);
        Map<String,String> masterDataMap= new Map<String,String> ();    
        List<BalTranFinancier__c> listBankFinMstr =[SELECT Id,Name,CRIFCode__c from BalTranFinancier__c where Name IN : bankNamesSet];
        System.debug('found list Fin Bank is ::'+listBankFinMstr);
        if(!listBankFinMstr.isEmpty()){
            for(BalTranFinancier__c eachMstr : listBankFinMstr){
                masterDataMap.put(eachMstr.Name,eachMstr.Id);
            }
        }
        System.debug('found return master ::'+masterDataMap);
        return masterDataMap;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable=false)
    public static String upsertParentChildRec(List<BureauRespDtl__c> parentRecords, List<Applicant_Obligation_detail__c> childRecords, String loanAppId) {
    try {
        if (parentRecords == null || parentRecords.isEmpty()) {
            return 'No Obligation records to process.';
        }

        List<BureauRespDtl__c> existBureauRec = [
            SELECT Id, LoanAmount__c,Source__c 
            FROM BureauRespDtl__c 
            WHERE LoanApplication__c = :loanAppId 
           // AND Source__c != 'Manual' 
            ORDER BY LastModifiedDate DESC
        ];

        Map<Id, Decimal> existBureauRecMap = new Map<Id, Decimal>();
        Map<Id, Decimal> existBureauRecMapManual = new Map<Id, Decimal>();

        for (BureauRespDtl__c rec : existBureauRec) {
            if(rec.Source__c !=null && rec.Source__c.equalsIgnoreCase('Manual')){
                existBureauRecMapManual.put(rec.Id, rec.LoanAmount__c);
            }
            else{
                existBureauRecMap.put(rec.Id, rec.LoanAmount__c);               
            }            
        }
        List<String> setRepayBanks = new List<String>();
        List<String> setFinBanks = new List<String>();
        List<BureauRespDtl__c> parentRecordsToUpsert = new List<BureauRespDtl__c>();
        Map<String, Id> getIdMap = new Map<String, Id>();
        String lastParentRecName = parentRecords!=null ? parentRecords[parentRecords.size() - 1].IdParent__c :'';
        Map<Id, Integer> idIndexMap = new Map<Id, Integer>();
        for (Integer i = 0; i < parentRecords.size(); i++) {
            BureauRespDtl__c eachB = parentRecords[i];

            if(eachB.Repayment_Bank__c !=null && String.isNotBlank(eachB.Repayment_Bank__c)){
                setRepayBanks.add(eachB.Repayment_Bank__c);  
            }
            if(eachB.FinancierName__c !=null && String.isNotBlank(eachB.FinancierName__c)){
                setFinBanks.add(eachB.FinancierName__c);  
            }
            if (String.isBlank(eachB.Id)) {
                eachB.Source__c = 'Manual';
            }
            System.debug('eachB.Source__c ='+eachB.Source__c +' and id is :'+eachB.Id);
            if((String.isBlank(eachB.Source__c) || eachB.Source__c ==null) && String.isEmpty(eachB.Id)){
                throw new AuraHandledException('Source is mandatory as "Manual" while Inserting new Obligation Records');//on row number
            }

            // if(eachB.Source__c!=null && eachB.Source__c.equalsIgnoreCase('Manual') && String.isNotBlank(eachB.Id) && !existBureauRecMapManual.containsKey(eachB.Id)){
            //     throw new AuraHandledException('Manual Records cannot have new Id while Inserting Obligation Records');
            // }

            if (String.isNotBlank(eachB.Id)) {
                for (Id existingId : idIndexMap.keySet()) {
                    if (String.valueOf(existingId).equalsIgnoreCase(eachB.Id)) {
                        Integer duplicateIndex = idIndexMap.get(existingId) + 2;
                        throw new AuraHandledException('Duplicate Id found at row ' + (i+2) + ' (first found at row ' + duplicateIndex + ')');
                    }
                }
                idIndexMap.put(eachB.Id, i);
            }
           
            
            

            if (eachB.Id != null && eachB.Source__c != 'Manual' && existBureauRecMap.containsKey(eachB.Id)) {
                Decimal existingLoanAmount = existBureauRecMap.get(eachB.Id);
                if (eachB.LoanAmount__c != existingLoanAmount) {
                    throw new AuraHandledException('File Upload has been failed since Loan Amount did not match with the bureau records. Row no. : '+(i+2));//on row number bureau details
                }
            }

            parentRecordsToUpsert.add(eachB);
        }

        Map<String,String> mapRepayBank =getIdMapForSfdcMstrObjs(setRepayBanks);
        Map<String,String> mapFinBank =getIdMapForBalTranFinancier(setFinBanks);

        List<BureauRespDtl__c> parentRecordsToUpsert1 = new List<BureauRespDtl__c>();
        if (!parentRecordsToUpsert.isEmpty()) {

            for(BureauRespDtl__c eachBureau : parentRecordsToUpsert){
                if(mapRepayBank.containsKey(eachBureau.Repayment_Bank__c)){
                    eachBureau.RepaymentBankID__c = mapRepayBank.get(eachBureau.Repayment_Bank__c);
                }
                if(mapFinBank.containsKey(eachBureau.FinancierName__c)){
                    eachBureau.FinancierNameID__c =  mapFinBank.get(eachBureau.FinancierName__c);
                }
                parentRecordsToUpsert1.add(eachBureau);
            }

            upsert parentRecordsToUpsert1;
        }

        for (BureauRespDtl__c eachParent : parentRecordsToUpsert) {
            getIdMap.put(eachParent.IdParent__c, eachParent.Id);
        }
        
        List<Applicant_Obligation_detail__c> existingChildRecords = [
            SELECT Id FROM Applicant_Obligation_detail__c 
            WHERE BureauRespDtl__c IN :parentRecordsToUpsert
        ];
        if (!existingChildRecords.isEmpty()) {
            Database.delete(existingChildRecords, true);
        }

        List<Applicant_Obligation_detail__c> upsertChildRecords = new List<Applicant_Obligation_detail__c>();
        for (Applicant_Obligation_detail__c eachChild : childRecords) {
            if (String.isBlank(eachChild.BureauRespDtl__c) || eachChild.BureauRespDtl__c ==null) {
                eachChild.BureauRespDtl__c = getIdMap.get(eachChild.IdChildsParent__c);
                
            }

            // Only add records where the last parent record name doesn't match the child's parent
           // if (lastParentRecName != null && lastParentRecName != eachChild.IdChildsParent__c) {
                upsertChildRecords.add(eachChild);
          //  }
        }

        if (!upsertChildRecords.isEmpty()) {
            upsert upsertChildRecords;
        }

        return 'Successfully completed the Operation.';

    } 
    
    catch (AuraHandledException e) {
        throw e; 
    } catch (Exception e) {
        System.debug('Unexpected Exception: ' + e.getMessage());
        throw new AuraHandledException('An unexpected error occurred.'+e.getMessage());
    }

    }



}