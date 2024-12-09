/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-20-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class EnachCreateMandateRequestGenerator implements ICalloutRequestGenerator {
    public void generate(List<IntgMsg__c> msgs, String service, String processType) {
        try {
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { IntgMsg__c.SObjectType, NACH__c.SObjectType });
            if(!msgs.isEmpty()) {
                Set<Id> nachIds = new Set<Id>();
                List<IntgMsg__c> updateIntrecods = new List<IntgMsg__c>();
                Map<Id, NACH__c> nachRecordsMap = new Map<Id, NACH__c>();
                Map<Id, NACH__c> nachRecordsUpdateMap = new Map<Id, NACH__c>();
                for(IntgMsg__c intMsgRec : msgs) {
                    nachIds.add(intMsgRec.RefId__c);
                }
				nachRecordsMap.putAll([SELECT Id, Mobile_Number__c, Email_Id__c, Name_Acc_Holder__c, IFSC_Code__c, MICR_Code__c, Bank_Account_Number__c, Bank_Name__c, Account_Type__c, amount_numbers__c, Date__c, LoanAppl__r.ReqLoanAmt__c FROM NACH__c WHERE Id IN :nachIds]);
                if(!nachRecordsMap.isEmpty()) {
                    IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Enach');
                    
                    for(IntgMsg__c intMsgRec : msgs) {
                        if(nachRecordsMap.containsKey(intMsgRec.RefId__c)) {
                            
                            EnachCreateMandateRequestWrapper enachWrap= new EnachCreateMandateRequestWrapper();
                            EnachCreateMandateRequestWrapper.Mandate_Data manData= new EnachCreateMandateRequestWrapper.Mandate_Data();
                            String custIdentifier;
                            if(String.isNotBlank(nachRecordsMap.get(intMsgRec.RefId__c).Mobile_Number__c)) {
                                custIdentifier = nachRecordsMap.get(intMsgRec.RefId__c).Mobile_Number__c;
                            }
                            else if(String.isNotBlank(nachRecordsMap.get(intMsgRec.RefId__c).Email_Id__c)) {
                                custIdentifier = nachRecordsMap.get(intMsgRec.RefId__c).Email_Id__c;
                            }
                            enachWrap.customer_identifier = custIdentifier != NULL ? custIdentifier : '';
                            enachWrap.auth_mode = GlobalConstants.ENACH_AUTH_MODE;
                            enachWrap.mandate_type = GlobalConstants.ENACH_MANDATE_TYPE;
                            enachWrap.corporate_config_id =String.isnotblank(svc.CorporateId__c)?svc.CorporateId__c:'';//GlobalConstants.ENACH_CORPORATE_CONFIG_ID;
                            enachWrap.notify_customer = GlobalConstants.ENACH_NOTIFY_CUSTOMER;
                            enachWrap.expire_in_days = GlobalConstants.ENACH_EXPIRE_IN_DAYS;
                            
                            manData.maximum_amount = nachRecordsMap.get(intMsgRec.RefId__c).amount_numbers__c != NULL ? String.valueOf(nachRecordsMap.get(intMsgRec.RefId__c).amount_numbers__c) : '';
                            manData.instrument_type = GlobalConstants.ENACH_INSTRUMENT_TYPE;
                            manData.first_collection_date = nachRecordsMap.get(intMsgRec.RefId__c).Date__c != NULL ? String.valueOf(nachRecordsMap.get(intMsgRec.RefId__c).Date__c) : '';
                            manData.is_recurring = GlobalConstants.ENACH_IS_RECOCURRING;
                            manData.frequency = GlobalConstants.ENACH_FREQUENCY;
                            manData.management_category = GlobalConstants.ENACH_MANAGEMENT_CATEGORY;
                            manData.customer_name = nachRecordsMap.get(intMsgRec.RefId__c).Name_Acc_Holder__c != NULL ? nachRecordsMap.get(intMsgRec.RefId__c).Name_Acc_Holder__c : '';
                            manData.customer_account_number = nachRecordsMap.get(intMsgRec.RefId__c).Bank_Account_Number__c != NULL ? nachRecordsMap.get(intMsgRec.RefId__c).Bank_Account_Number__c : '';
                            manData.destination_bank_id = nachRecordsMap.get(intMsgRec.RefId__c).IFSC_Code__c != NULL ? nachRecordsMap.get(intMsgRec.RefId__c).IFSC_Code__c : '';
                            manData.destination_bank_name = nachRecordsMap.get(intMsgRec.RefId__c).Bank_Name__c != NULL ? nachRecordsMap.get(intMsgRec.RefId__c).Bank_Name__c : '';
                            
                            String custAccType;
                            if(nachRecordsMap.get(intMsgRec.RefId__c).Account_Type__c == 'SAVINGS') {
                                custAccType = GlobalConstants.ENACH_ACCOUNT_TYPE_SAVINGS;
                            }
                            else if(nachRecordsMap.get(intMsgRec.RefId__c).Account_Type__c == 'CURRENT') {
                                custAccType = GlobalConstants.ENACH_ACCOUNT_TYPE_CURRENT;
                            }
                            else if(nachRecordsMap.get(intMsgRec.RefId__c).Account_Type__c == 'CC') {
                                custAccType = GlobalConstants.ENACH_ACCOUNT_TYPE_CC;
                            }
                            else {
                                custAccType = GlobalConstants.ENACH_ACCOUNT_TYPE_OTHER;
                            }
                            manData.customer_account_type = custAccType != NULL ? custAccType : '';
                            enachWrap.mandate_data = manData;
                            
                            IntgMsg__c intg = New IntgMsg__c();
                            intg.id = intMsgRec.Id;
                            intg.Req__c = JSON.serialize(enachWrap); 
                            intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                            updateIntrecods.add(intg);
                            
                            NACH__c nach = new NACH__c();
                            nach.Id = intMsgRec.RefId__c;
                            nach.EnachInitiationDateTime__c = System.now();
                            nach.eNACH_Registration_Status__c='';
                            nach.eNACH_Rejection_Reasons__c='';
                            nach.EnachResponseDateTime__c=null;
                            nachRecordsUpdateMap.put(nach.Id,nach);
                            
                        }
                    }
                }
                if(!updateIntrecods.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{ 'Req__c','Status__c' };
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntrecods);
                    uow.commitWork();
                }
                if(!nachRecordsUpdateMap.isEmpty()){
                    String sObjectName = 'NACH__c';
                    List<String> fieldNamesList = new List<String>{ 'EnachInitiationDateTime__c','eNACH_Registration_Status__c','eNACH_Rejection_Reasons__c','EnachResponseDateTime__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(nachRecordsUpdateMap.values());
                    uow.commitWork();
                }
            }
        }
        catch(Exception ex) {
            System.debug('error'+ex.getMessage());
            GlobalUtility.logMessage('Error', 'EnachCreateMandateRequestGenerator' + ex.getLineNumber(), 'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    }
}