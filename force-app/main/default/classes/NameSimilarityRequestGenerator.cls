public class NameSimilarityRequestGenerator implements ICalloutRequestGenerator{

    public void generate(List<IntgMsg__c> msgs, String service, String processType){  
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { IntgMsg__c.SObjectType });
        List<Id> appIds = new List<Id>();
        List<Applicant__c> appliList = new List<Applicant__c>();
        Id idChildObj= null;
        List<DocDtl__c> listDocDtls; 
        Set<Id> applKycIds = new Set<Id>();
        Set<Id> applBankingIds = new Set<Id>();
        Set<Id> apiVerIds = new Set<Id>();
        Set<Id> applFinIds = new Set<Id>();
        Set<Id> applGstIds = new Set<Id>();

        for (IntgMsg__c intMsg : msgs) {

        appIds.add(intMsg.ParentRefId__c);
        idChildObj = intMsg.RefId__c;

        if (intMsg.RefObj__c == 'ApplKyc__c') {
            applKycIds.add(idChildObj);
        } else if (intMsg.RefObj__c == 'ApplBanking__c') {
            applBankingIds.add(idChildObj);
        } else if (intMsg.RefObj__c == 'APIVer__c') {
            apiVerIds.add(idChildObj);
        } else if (intMsg.RefObj__c == 'Applicant_Financial__c') {
            applFinIds.add(idChildObj);
        } else if (intMsg.RefObj__c == 'ApplGST__c') {
            applGstIds.add(idChildObj);
        }

        }

        System.debug('Id for idChildObj =>'+idChildObj);
        
        if(appIds!=null && !appIds.isEmpty()){
            appliList = [SELECT Id,Name,ApplType__c,Type_of_Borrower__c,Constitution__c,CompanyName__c FROM Applicant__c Where Id IN:appIds];
        }

        Map<Id, ApplKyc__c> kycsMap = (applKycIds != null && !applKycIds.isEmpty()) ? new Map<Id, ApplKyc__c>([
            SELECT Id, Name__c FROM ApplKyc__c WHERE Id IN :applKycIds
        ]) : new Map<Id, ApplKyc__c>();

        Map<Id, ApplBanking__c> bankMap = (applBankingIds != null && !applBankingIds.isEmpty()) ? new Map<Id, ApplBanking__c>([
            SELECT Id, Name_of_the_Primary_Account_Holder_s__c FROM ApplBanking__c WHERE Id IN :applBankingIds
        ]) : new Map<Id, ApplBanking__c>();

        Map<Id, APIVer__c> apiVerMap = (apiVerIds != null && !apiVerIds.isEmpty()) ? new Map<Id, APIVer__c>([
            SELECT Id, Name__c FROM APIVer__c WHERE Id IN :apiVerIds
        ]) : new Map<Id, APIVer__c>();

        Map<Id, Applicant_Financial__c> appFinMap = (applFinIds != null && !applFinIds.isEmpty()) ? new Map<Id, Applicant_Financial__c>([
            SELECT Id, Name FROM Applicant_Financial__c WHERE Id IN :applFinIds
        ]) : new Map<Id, Applicant_Financial__c>();

        Map<Id, ApplGST__c> gstMap = (applGstIds != null && !applGstIds.isEmpty()) ? new Map<Id, ApplGST__c>([
            SELECT Id, RegistName__c FROM ApplGST__c WHERE Id IN :applGstIds
        ]) : new Map<Id, ApplGST__c>();







        if(appIds!=null && !appIds.isEmpty())
        {
           listDocDtls=[Select id,Applicant_KYC__r.Name__c,Appl__c,Appl__r.Constitution__c,DocSubTyp__c,Name,DocTyp__c,DocCatgry__c from DocDtl__c where 
            ((Appl__r.Constitution__c ='INDIVIDUAL' AND DocCatgry__c ='KYC Documents'  AND DocTyp__c ='Identity Proof')  OR
             (Appl__r.Constitution__c <> 'INDIVIDUAL' AND DocCatgry__c ='PAN Documents'  AND DocTyp__c ='PAN')) AND Appl__c =: appIds[0] AND Applicant_KYC__c != null  AND Applicant_KYC__r.Name__c !=null  AND (Applicant_KYC__r.ValidationStatus__c = 'Success' OR Applicant_KYC__r.OCRStatus__c = 'Success') ORDER BY CreatedDate DESC] ; 
        }

        System.debug('listDocDtls :'+listDocDtls);


        try{
            List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>(); 
            if(!msgs.isEmpty()){
                 
                for(IntgMsg__c intMsg : msgs){
                   NameSimilarityRequestWrapper recordOfNmSmlty = new NameSimilarityRequestWrapper();

                    idChildObj = intMsg.RefId__c;

                    if (intMsg.RefObj__c == 'ApplKyc__c' && kycsMap.containsKey(idChildObj)) {
                        ApplKyc__c kyc = kycsMap.get(idChildObj);
                        recordOfNmSmlty.name2 = kyc.Name__c != null ? kyc.Name__c : '';
                    } else if (intMsg.RefObj__c == 'ApplBanking__c' && bankMap.containsKey(idChildObj)) {
                        ApplBanking__c bank = bankMap.get(idChildObj);
                        recordOfNmSmlty.name2 = bank.Name_of_the_Primary_Account_Holder_s__c != null ? bank.Name_of_the_Primary_Account_Holder_s__c : '';
                    } else if (intMsg.RefObj__c == 'APIVer__c' && apiVerMap.containsKey(idChildObj)) {
                        APIVer__c apiVer = apiVerMap.get(idChildObj);
                        recordOfNmSmlty.name2 = apiVer.Name__c != null ? apiVer.Name__c : '';
                    } else if (intMsg.RefObj__c == 'ApplGST__c' && gstMap.containsKey(idChildObj)) {
                        ApplGST__c gst = gstMap.get(idChildObj);
                        recordOfNmSmlty.name2 = gst.RegistName__c != null ? gst.RegistName__c : '';
                    } else if (intMsg.RefObj__c == 'Applicant_Financial__c' && appFinMap.containsKey(idChildObj)) {
                        Applicant_Financial__c appFin = appFinMap.get(idChildObj);
                        recordOfNmSmlty.name2 = appFin.Name != null ? appFin.Name : '';
                    } else {
                        recordOfNmSmlty.name2 = '';
                    }


                    if(listDocDtls !=null && !listDocDtls.isEmpty()){
                        recordOfNmSmlty.name1= listDocDtls[0].Applicant_KYC__r.Name__c  !=null ? listDocDtls[0].Applicant_KYC__r.Name__c :'';
                    }

                    if(appliList !=null && !appliList.isEmpty()){
                        if(appliList[0].Constitution__c !=null && appliList[0].Constitution__c == 'INDIVIDUAL'){
                            recordOfNmSmlty.type=  'individual'; 
                        }else{
                            recordOfNmSmlty.type=  'entity';  
                        }
                    }
                    recordOfNmSmlty.preset=''; //G(General), L(Lenient),S (Strict); Default value: G
                    recordOfNmSmlty.allowPartialMatch=false; //Allowed values: true,false
                    recordOfNmSmlty.suppressReorderPenalty=false; //Allowed values: true,false
                   
                    //Inner Class
                    NameSimilarityRequestWrapper.ClientData cltData = new NameSimilarityRequestWrapper.ClientData();
                    cltData.caseId = intMsg.Integration_Message_Number__c;  
                    recordOfNmSmlty.clientData = cltData;

                    IntgMsg__c intg=New IntgMsg__c();
                        intg.id=intMsg.id;
                        intg.Req__c = JSON.serialize(recordOfNmSmlty); 
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
            }
            
            uow.commitWork();
        }
        
        catch(Exception ex){
            System.debug('error'+ex.getMessage());
            GlobalUtility.logMessage('Error', 'NameSimilarityRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
}