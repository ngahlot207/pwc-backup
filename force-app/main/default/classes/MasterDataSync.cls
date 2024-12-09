public class MasterDataSync {
    
    /*public static void processDSAMaster(String masterDataType,String externalKey, List<MasterDataSync__c> records){
        Map<String, String> externalToSalesforceFields = new Map<String, String>();
        List<MasterDataConfig__mdt> customMappings = [SELECT MasterDataType__c,SFObjectAPIName__c,FinnOneField__c,SFFieldAPIName__c FROM MasterDataConfig__mdt WHERE MasterDataType__c=:masterDataType];
        for (MasterDataConfig__mdt mapping : customMappings) {
            externalToSalesforceFields.put(mapping.FinnOneField__c, mapping.SFFieldAPIName__c);
        }
        
        if(!externalToSalesforceFields.isEmpty()){
            Map<Integer,Map<String, Object>> DSAMasterMap = new Map<Integer,Map<String, Object>>();
            Map<Integer,MasterDataSync__c> masterDataSyncUpdateMap = new Map<Integer,MasterDataSync__c>();
            Map<Integer,Account> accountUpsertMap = new Map<Integer,Account>();
            if(!records.isEmpty()){
                for(Integer i=0; i<records.size();i++){
                    System.debug(i);
                    MasterDataSync__c record = records[i];
                    if(String.isNotBlank(record.Record__c)){
                        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(record.Record__c);
                        if(!masterDataSyncUpdateMap.containsKey(i)){
                            masterDataSyncUpdateMap.put(i, new MasterDataSync__c(Id=record.Id,UID__c=jsonMap.containsKey(externalKey)?String.valueOf(jsonMap.get(externalKey)):''));
                        }
                        else{
                            masterDataSyncUpdateMap.get(i).UID__c=jsonMap.containsKey(externalKey)?String.valueOf(jsonMap.get(externalKey)):'';
                        }
                        
                        if(!DSAMasterMap.containsKey(i)){
                            DSAMasterMap.put(i,jsonMap);
                        }
                    }
                    
                }
            }
            System.debug('::::'+masterDataSyncUpdateMap); 
            System.debug('::::'+DSAMasterMap);
            if(!DSAMasterMap.isEmpty()){
                for (MasterDataConfig__mdt mapping : customMappings) {
                    String externalFieldApiName = mapping.FinnOneField__c;
                    String salesforceFieldApiName = mapping.SFFieldAPIName__c;
                    
                    for (Integer key : DSAMasterMap.keySet()) {
                        
                        Map<String, Object> jsonMap = DSAMasterMap.get(key);
                        
                        if(jsonMap.containsKey(externalFieldApiName)){
                            String externalFieldValue = (String) jsonMap.get(externalFieldApiName); 
                            if(externalFieldValue!=null){
                                if(!accountUpsertMap.containsKey(key)){
                                    Account record = new Account();
                                    Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('DSA').getRecordTypeId();
                                    record.put('RecordTypeId',recordTypeId);
                                    record.put(salesforceFieldApiName,externalFieldValue);
                                    accountUpsertMap.put(key,record);                           
                                }
                                else{
                                    accountUpsertMap.get(key).put(salesforceFieldApiName,externalFieldValue);
                                }
                            }
                        }
                        
                    }
                }
            }
            
            if(!accountUpsertMap.isEmpty()){
                System.debug('::::'+accountUpsertMap);
                Schema.SObjectField externalID = Account.Fields.DSAConnId__c;
                Database.UpsertResult[] results = Database.upsert(accountUpsertMap.values(),externalID, false);
                for(Integer i=0; i<results.size(); i++){
                    if(results[i].isSuccess()){
                        if(results[i].isCreated()){
                            System.debug('::::Created'+ results[i]);
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                masterDataSyncUpdateMap.get(i).SyncStatus__c='Success';
                                masterDataSyncUpdateMap.get(i).ErrorCode__c='';
                                masterDataSyncUpdateMap.get(i).ErrorMessage__c='';
                            }
                            
                        } else{
                            System.debug('::::Updated'+ results[i]); 
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                masterDataSyncUpdateMap.get(i).SyncStatus__c='Success';
                            }
                        }  
                    }
                    else {
                        for(Database.Error err : results[i].getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                masterDataSyncUpdateMap.get(i).SyncStatus__c='Failed';
                            }
                        }
                    }
                    
                }
            }
            if(!masterDataSyncUpdateMap.isEmpty()){
                update masterDataSyncUpdateMap.values();
            }
        }
        
    }*/
    //---------------------------------------------------------------------------------------//
    public static void processDSAMaster(List<MasterDataSync__c> records){
        try{ 
            Map<Integer,DSAMasterWrapper> DSAMasterMap = new Map<Integer,DSAMasterWrapper>();
            Map<Integer,MasterDataSync__c> masterDataSyncUpdateMap = new Map<Integer,MasterDataSync__c>();
            Map<Integer,Account> accountUpsertMap = new Map<Integer,Account>();
            Set<String> externalIds = new Set<String>();
            
            List<MasterDataSync__c> masterDataSyncErrorList = new List<MasterDataSync__c>();
			List<MasterDataSync__c> masterDataSyncUpdateList = new List<MasterDataSync__c>();
            
            
            if(!records.isEmpty()){
                
                Integer counter=0;
                for(MasterDataSync__c record : records){
                    if(String.isNotBlank(record.Record__c)){
                        DSAMasterWrapper responseWrapper = (DSAMasterWrapper) JSON.deserialize(record.Record__c, DSAMasterWrapper.class);
                        if(responseWrapper!=null){
                            try{
                                if(responseWrapper.BROKERID!=null && String.isNotBlank(responseWrapper.BROKERID) && responseWrapper.DSA_NAME!=null && String.isNotBlank(responseWrapper.DSA_NAME)){ 
                                	externalIds.add(responseWrapper.BROKERID);
                                    masterDataSyncUpdateMap.put(counter, new MasterDataSync__c(Id=record.Id,UID__c= (responseWrapper!=null && String.isNotBlank(responseWrapper.BROKERID))?responseWrapper.BROKERID:''));
                                    DSAMasterMap.put(counter,responseWrapper);
                                    counter++;
                                }
                                else{
                                    List<String> requiredList = new List<String>();
                                    if(responseWrapper.BROKERID==null || String.isBlank(responseWrapper.BROKERID)){
                                        requiredList.add('BROKERID');
                                    }
                                    if(responseWrapper.DSA_NAME==null || String.isBlank(responseWrapper.DSA_NAME)){
                                        requiredList.add('DSA_NAME');
                                    }
                                    throw new MasterDataSyncException(record.Id,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: Required attributes are missing: [' + String.Join(requiredList,',') + ']' );
                                }
                            }
                            catch(MasterDataSyncException ex){
                                if(ex.recordId!=null){
                                    MasterDataSync__c errorRecord = new MasterDataSync__c();
                                    errorRecord.Id = ex.recordId;
                                    errorRecord.IsProcessed__c=true;
                                    errorRecord.SyncStatus__c='Failed';
                                    errorRecord.ErrorCode__c= String.isNotBlank(ex.errorCode)? ex.errorCode:customErrorCode.get('SYNC_ERROR');
                                    errorRecord.ErrorMessage__c= String.isNotBlank(ex.errorMessage)? ex.errorMessage:'Error Occurred while Data Sync';
                                    masterDataSyncErrorList.add(errorRecord);
                                }
                                
                            }
                        }
                    }
                }
                
                /*for(Integer i=0; i<records.size();i++){
                    MasterDataSync__c record = records[i];
                    if(String.isNotBlank(record.Record__c)){
                        DSAMasterWrapper responseWrapper = (DSAMasterWrapper) JSON.deserialize(record.Record__c, DSAMasterWrapper.class); 
                        if(responseWrapper!=null){
                            if(String.isNotBlank(responseWrapper.BROKERID)){
                                externalIds.add(responseWrapper.BROKERID);
                            }
                        }
                        if(!masterDataSyncUpdateMap.containsKey(i)){
                            masterDataSyncUpdateMap.put(i, new MasterDataSync__c(Id=record.Id,UID__c= (responseWrapper!=null && String.isNotBlank(responseWrapper.BROKERID))?responseWrapper.BROKERID:''));
                        }
                        else{
                            masterDataSyncUpdateMap.get(i).UID__c=(responseWrapper!=null && String.isNotBlank(responseWrapper.BROKERID))?responseWrapper.BROKERID:'';
                        }
                        if(!DSAMasterMap.containsKey(i)){
                            DSAMasterMap.put(i,responseWrapper);
                        }
                    }
                }*/
                
                if(!DSAMasterMap.isEmpty()){
                    Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('DSA').getRecordTypeId();
                    //Map<String,Account> accountMap = new Map<String,Account>();
                    //for(Account acc: [Select Id,DSAConnId__c FROM Account WHERE DSAConnId__c IN :externalIds AND RecordTypeID=:recordTypeId]){
                    //    accountMap.put(acc.DSAConnId__c,acc);
                    //}
                    
                    for (Integer key : DSAMasterMap.keySet()) {
                        DSAMasterWrapper dsaMaster = DSAMasterMap.get(key);
                        if(!accountUpsertMap.containsKey(key)){
                            if(dsaMaster!=null){
                                Account acc = new Account();
                                acc.RecordTypeId = recordTypeId;
                                if(dsaMaster.BROKERID!=null && String.isNotBlank(dsaMaster.BROKERID)){
                                    //if(accountMap.containsKey(dsaMaster.BROKERID)){
                                        //acc.Id = accountMap.get(dsaMaster.BROKERID).Id;
                                    //}
                                    //else{
                                        
                                    //}
                                    acc.DSAConnId__c =dsaMaster.BROKERID;
                                }
                                if(dsaMaster.DSA_NAME!=null && String.isNotBlank(dsaMaster.DSA_NAME)){
                                    acc.Name = dsaMaster.DSA_NAME;
                                }
                                /*if(dsaMaster.PRODUCT_CODE!=null && String.isNotBlank(dsaMaster.PRODUCT_CODE)){
                                    acc.Product__c = dsaMaster.PRODUCT_CODE=='LAP'? 'Small Ticket LAP':'Home Loan';
                                }*/
                                if(dsaMaster.ACTIVE_STATUS!=null && String.isNotBlank(dsaMaster.ACTIVE_STATUS)){
                                    acc.Status__c = dsaMaster.ACTIVE_STATUS;
                                }
                                accountUpsertMap.put(key,acc);
                            }
                        }
                    }
                }
                if(!accountUpsertMap.isEmpty()){
                    System.debug('::::'+accountUpsertMap);
                    Schema.SObjectField externalID = Account.Fields.DSAConnId__c;
                    Database.UpsertResult[] results = Database.upsert(accountUpsertMap.values(),externalID,false);
                    for(Integer i=0; i<results.size(); i++){
                        if(results[i].isSuccess()){
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                masterDataSyncUpdateMap.get(i).SyncStatus__c='Success';
                                masterDataSyncUpdateMap.get(i).ErrorCode__c=customErrorCode.get('SUCCESS');
                                masterDataSyncUpdateMap.get(i).ErrorMessage__c='SUCCESS: Data Sync Successful';
                            }		
                        }
                        else {
                            List<Database.Error> err = results[i].getErrors();
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                masterDataSyncUpdateMap.get(i).SyncStatus__c='Failed';
                                masterDataSyncUpdateMap.get(i).ErrorCode__c= !err.isEmpty() && customErrorCode.containsKey(String.valueOf(err[0].getStatusCode())) ? customErrorCode.get(String.ValueOf(err[0].getStatusCode())) : customErrorCode.get('SYNC_ERROR');
                                masterDataSyncUpdateMap.get(i).ErrorMessage__c= !err.isEmpty() ? err[0].getStatusCode() + ': ' + err[0].getMessage() : 'Error Occurred while Data Sync';
                            }
                        }
                    }
                }
                if(!masterDataSyncUpdateMap.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncUpdateMap.values());
                }
				if(!masterDataSyncErrorList.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncErrorList);
				}	
				if(!masterDataSyncUpdateList.isEmpty()){
					update masterDataSyncUpdateList;
				}
            }
        }
        catch(Exception ex){
            System.debug('processDSAMaster ' + ex.getMessage() + ' line ' + ex.getLineNumber());
        }
    }
    
    public static void processConnectorMaster(List<MasterDataSync__c> records){
        try{
            Map<Integer,ConnectorMasterWrapper> connectorMasterMap = new Map<Integer,ConnectorMasterWrapper>();
            Map<Integer,MasterDataSync__c> masterDataSyncUpdateMap = new Map<Integer,MasterDataSync__c>();
            Map<Integer,Account> accountUpsertMap = new Map<Integer,Account>();
            Set<String> externalIds = new Set<String>();
            
			List<MasterDataSync__c> masterDataSyncErrorList = new List<MasterDataSync__c>();
			List<MasterDataSync__c> masterDataSyncUpdateList = new List<MasterDataSync__c>();			
	            
            if(!records.isEmpty()){
                
                Integer counter=0;
                for(MasterDataSync__c record : records){
                    if(String.isNotBlank(record.Record__c)){
                        ConnectorMasterWrapper responseWrapper = (ConnectorMasterWrapper) JSON.deserialize(record.Record__c, ConnectorMasterWrapper.class); 
                        if(responseWrapper!=null){
                            try{
                                if(responseWrapper.VC_REFERRAL_ID!=null && String.isNotBlank(responseWrapper.VC_REFERRAL_ID) && responseWrapper.VC_REFERRAL_CD!=null && String.isNotBlank(responseWrapper.VC_REFERRAL_CD)){
                                    externalIds.add(responseWrapper.VC_REFERRAL_ID);
                                    masterDataSyncUpdateMap.put(counter, new MasterDataSync__c(Id=record.Id,UID__c= (responseWrapper!=null && String.isNotBlank(responseWrapper.VC_REFERRAL_ID))?responseWrapper.VC_REFERRAL_ID:''));
                                    connectorMasterMap.put(counter,responseWrapper);
                                    counter++;
                                    
                                }
                                else{
                                    List<String> requiredList = new List<String>();
                                    if(responseWrapper.VC_REFERRAL_ID==null || String.isBlank(responseWrapper.VC_REFERRAL_ID)){
                                        requiredList.add('VC_REFERRAL_ID');
                                    }
                                    if(responseWrapper.VC_REFERRAL_CD==null || String.isBlank(responseWrapper.VC_REFERRAL_CD)){
                                        requiredList.add('VC_REFERRAL_CD');
                                    }
                                    throw new MasterDataSyncException(record.Id,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: Required attributes are missing: [' + String.Join(requiredList,',') + ']' );
                                }
                            }
                            catch(MasterDataSyncException ex){
                                if(ex.recordId!=null){
                                    MasterDataSync__c errorRecord = new MasterDataSync__c();
                                    errorRecord.Id = ex.recordId;
                                    errorRecord.IsProcessed__c=true;
                                    errorRecord.SyncStatus__c='Failed';
                                    errorRecord.ErrorCode__c= String.isNotBlank(ex.errorCode)? ex.errorCode:customErrorCode.get('SYNC_ERROR');
                                    errorRecord.ErrorMessage__c= String.isNotBlank(ex.errorMessage)? ex.errorMessage:'Error Occurred while Data Sync';
                                    masterDataSyncErrorList.add(errorRecord);
                                }
                            }
                        }
                    }
                }
                
                /*for(Integer i=0; i<records.size();i++){
                    MasterDataSync__c record = records[i];
                    if(String.isNotBlank(record.Record__c)){
                        ConnectorMasterWrapper responseWrapper = (ConnectorMasterWrapper) JSON.deserialize(record.Record__c, ConnectorMasterWrapper.class); 
                        if(responseWrapper!=null){
                            if(String.isNotBlank(responseWrapper.VC_REFERRAL_ID)){
                                externalIds.add(responseWrapper.VC_REFERRAL_ID);
                            }
                        }
                        if(!masterDataSyncUpdateMap.containsKey(i)){
                            masterDataSyncUpdateMap.put(i, new MasterDataSync__c(Id=record.Id,UID__c= (responseWrapper!=null && String.isNotBlank(responseWrapper.VC_REFERRAL_ID))?responseWrapper.VC_REFERRAL_ID:''));
                        }
                        else{
                            masterDataSyncUpdateMap.get(i).UID__c=(responseWrapper!=null && String.isNotBlank(responseWrapper.VC_REFERRAL_ID))?responseWrapper.VC_REFERRAL_ID:'';
                        }
                        if(!connectorMasterMap.containsKey(i)){
                            connectorMasterMap.put(i,responseWrapper);
                        }
                    }
                }*/
                
                if(!connectorMasterMap.isEmpty()){
                    Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Connector').getRecordTypeId();
                    //Map<String,Account> accountMap = new Map<String,Account>();
                    
                    //for(Account acc: [Select Id,Name,VCReferralId__c, VCReferralCode__c FROM Account WHERE VCReferralId__c IN :externalIds AND RecordTypeID=:recordTypeId]){
                    //    accountMap.put(acc.VCReferralId__c,acc);
                    //}
                    
                    for (Integer key : connectorMasterMap.keySet()) {
                        ConnectorMasterWrapper connectorMaster = connectorMasterMap.get(key);
                        if(!accountUpsertMap.containsKey(key)){
                            if(connectorMaster!=null){
                                Account acc = new Account();
                                acc.RecordTypeId = recordTypeId;
                                if(connectorMaster.VC_REFERRAL_ID!=null && String.isNotBlank(connectorMaster.VC_REFERRAL_ID)){
                                    //if(accountMap.containsKey(connectorMaster.VC_REFERRAL_ID)){
                                        //acc.Id = accountMap.get(connectorMaster.VC_REFERRAL_ID).Id;
                                    //}
                                    //else{
                                        
                                    //}
                                    acc.VCReferralId__c = connectorMaster.VC_REFERRAL_ID;
                                }
                                if(connectorMaster.VC_REFERRAL_CD!=null && String.isNotBlank(connectorMaster.VC_REFERRAL_CD)){
                                    acc.VCReferralCode__c = connectorMaster.VC_REFERRAL_CD;
                                }
                                if(connectorMaster.VC_REFERRAL_NAME!=null && String.isNotBlank(connectorMaster.VC_REFERRAL_NAME)){
                                    acc.Name = connectorMaster.VC_REFERRAL_NAME;
                                }
                                if(connectorMaster.LPP_PRODCAT_C!=null && String.isNotBlank(connectorMaster.LPP_PRODCAT_C)){
                                    acc.LPPProdCat__c = connectorMaster.LPP_PRODCAT_C;
                                }   
                                if(connectorMaster.STATUS!=null && String.isNotBlank(connectorMaster.STATUS)){
                                    acc.Status__c = connectorMaster.STATUS;
                                }
                                accountUpsertMap.put(key,acc);
                            }
                        }
                    }
                }
                if(!accountUpsertMap.isEmpty()){
                    System.debug('::::'+accountUpsertMap);
                    Schema.SObjectField externalID = Account.Fields.VCReferralId__c;
                    Database.UpsertResult[] results = Database.upsert(accountUpsertMap.values(),externalID,false);
                    for(Integer i=0; i<results.size(); i++){
                        if(results[i].isSuccess()){
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                masterDataSyncUpdateMap.get(i).SyncStatus__c='Success';
                                masterDataSyncUpdateMap.get(i).ErrorCode__c=customErrorCode.get('SUCCESS');
                                masterDataSyncUpdateMap.get(i).ErrorMessage__c='SUCCESS: Data Sync Successful';
                            }		
                        }
                        else {
                            List<Database.Error> err = results[i].getErrors();
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                masterDataSyncUpdateMap.get(i).SyncStatus__c='Failed';
                                masterDataSyncUpdateMap.get(i).ErrorCode__c= !err.isEmpty() && customErrorCode.containsKey(String.valueOf(err[0].getStatusCode())) ? customErrorCode.get(String.ValueOf(err[0].getStatusCode())) : customErrorCode.get('SYNC_ERROR');
                                masterDataSyncUpdateMap.get(i).ErrorMessage__c= !err.isEmpty() ? err[0].getStatusCode() + ': ' + err[0].getMessage() : 'Error Occurred while Data Sync';
                            }
                        }
                    }
                }
                if(!masterDataSyncUpdateMap.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncUpdateMap.values());
                }
				if(!masterDataSyncErrorList.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncErrorList);
				}	
				if(!masterDataSyncUpdateList.isEmpty()){
					update masterDataSyncUpdateList;
				}
            }
        }
        catch(Exception ex){
            System.debug('processConnectorMaster ' + ex.getMessage() + ' line ' + ex.getLineNumber());
        }
    }
    
    public static void processPropertySubTypeMaster(List<MasterDataSync__c> records){
        try{
            Map<Integer,PropertySubTypeMasterWrapper> propertySubTypeMap = new Map<Integer,PropertySubTypeMasterWrapper>();
            Map<Integer,MasterDataSync__c> masterDataSyncUpdateMap = new Map<Integer,MasterDataSync__c>();
            Map<Integer,PropSubTypeMstr__c> propSubTypeMstrUpsertMap = new Map<Integer,PropSubTypeMstr__c>();
			List<MasterDataSync__c> masterDataSyncErrorList = new List<MasterDataSync__c>();
			List<MasterDataSync__c> masterDataSyncUpdateList = new List<MasterDataSync__c>();
            Set<String> externalIds = new Set<String>();
            if(!records.isEmpty()){
				Integer counter=0;
				for(MasterDataSync__c record : records){
					if(String.isNotBlank(record.Record__c)){
						
						PropertySubTypeMasterWrapper responseWrapper = (PropertySubTypeMasterWrapper) JSON.deserialize(record.Record__c, PropertySubTypeMasterWrapper.class);
						if(responseWrapper!=null){
						try{
							if(responseWrapper.DESCRIPTION!=null && String.isNotBlank(responseWrapper.DESCRIPTION) && responseWrapper.VALUE!=null && String.isNotBlank(responseWrapper.VALUE)){
								
								externalIds.add(responseWrapper.DESCRIPTION);
								if(!masterDataSyncUpdateMap.containsKey(counter)){
									masterDataSyncUpdateMap.put(counter, new MasterDataSync__c(Id=record.Id,UID__c= (responseWrapper!=null && String.isNotBlank(responseWrapper.DESCRIPTION))?responseWrapper.DESCRIPTION:''));
									propertySubTypeMap.put(counter,responseWrapper);
									counter++;
								}
								
							}
							else{
								List<String> requiredList = new List<String>();
								if(responseWrapper.DESCRIPTION==null || String.isBlank(responseWrapper.DESCRIPTION)){
									requiredList.add('DESCRIPTION');
								}
								if(responseWrapper.VALUE==null || String.isBlank(responseWrapper.VALUE)){
									requiredList.add('VALUE');
								}
								throw new MasterDataSyncException(record.Id,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: Required attributes are missing: [' + String.Join(requiredList,',') + ']' );
							}
						}
						catch(MasterDataSyncException ex){
							if(ex.recordId!=null){
								MasterDataSync__c errorRecord = new MasterDataSync__c();
								errorRecord.Id = ex.recordId;
								errorRecord.IsProcessed__c=true;
								errorRecord.SyncStatus__c='Failed';
                                errorRecord.ErrorCode__c= String.isNotBlank(ex.errorCode)? ex.errorCode:customErrorCode.get('SYNC_ERROR');
                                errorRecord.ErrorMessage__c= String.isNotBlank(ex.errorMessage)? ex.errorMessage:'Error Occurred while Data Sync';
								masterDataSyncErrorList.add(errorRecord);
							}
						
						}	
						}
						
					}
				}
				
				if(!propertySubTypeMap.isEmpty()){
                    
                    for (Integer key : propertySubTypeMap.keySet()) {
                        PropertySubTypeMasterWrapper propertySubTypeMaster = propertySubTypeMap.get(key);
                        if(!propSubTypeMstrUpsertMap.containsKey(key)){
                            if(propertySubTypeMaster!=null){
                                PropSubTypeMstr__c propSubTypeMstr = new PropSubTypeMstr__c();
                                if(propertySubTypeMaster!=null && String.isNotBlank(propertySubTypeMaster.VALUE)){
                                    propSubTypeMstr.Value__c = propertySubTypeMaster.VALUE;
                                }
                                if(propertySubTypeMaster!=null && String.isNotBlank(propertySubTypeMaster.DESCRIPTION)){
                                    propSubTypeMstr.Desc__c = propertySubTypeMaster.DESCRIPTION;
                                }
                                propSubTypeMstrUpsertMap.put(key,propSubTypeMstr);
                            }
                        }
                    }
                }
                if(!propSubTypeMstrUpsertMap.isEmpty()){
                    System.debug('::::'+propSubTypeMstrUpsertMap);
                    Schema.SObjectField externalID = PropSubTypeMstr__c.Fields.Desc__c;
                    Database.UpsertResult[] results = Database.upsert(propSubTypeMstrUpsertMap.values(),externalID,false);
                    for(Integer i=0; i<results.size(); i++){
                        if(results[i].isSuccess()){
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                    masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                    masterDataSyncUpdateMap.get(i).SyncStatus__c='Success';
                                    masterDataSyncUpdateMap.get(i).ErrorCode__c=customErrorCode.get('SUCCESS');
                                    masterDataSyncUpdateMap.get(i).ErrorMessage__c='SUCCESS: Data Sync Successful';
                            }		
                        }
                        else {
                            List<Database.Error> err = results[i].getErrors();
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                masterDataSyncUpdateMap.get(i).SyncStatus__c='Failed';
                                masterDataSyncUpdateMap.get(i).ErrorCode__c= !err.isEmpty() && customErrorCode.containsKey(String.valueOf(err[0].getStatusCode())) ? customErrorCode.get(String.ValueOf(err[0].getStatusCode())) : customErrorCode.get('SYNC_ERROR');
                                masterDataSyncUpdateMap.get(i).ErrorMessage__c= !err.isEmpty() ? err[0].getStatusCode() + ': ' + err[0].getMessage() : 'Error Occurred while Data Sync';
                            }
                        }
                        
                    }
                }
                if(!masterDataSyncUpdateMap.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncUpdateMap.values());
                    
                }
				if(!masterDataSyncErrorList.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncErrorList);
				}	
				if(!masterDataSyncUpdateList.isEmpty()){
					update masterDataSyncUpdateList;
				}
                
            }
            
        }
        catch(Exception ex){
            System.debug('processPropertySubTypeMaster ' + ex.getMessage() + ' line ' + ex.getLineNumber());
        }
    }
    
    public static void processPropertyMaster(String type, List<MasterDataSync__c> records){
        try{
            
            Map<Integer,PropertyTypeMasterWrapper> propertyTypeMasterMap = new Map<Integer,PropertyTypeMasterWrapper>();
            Map<Integer,MasterDataSync__c> masterDataSyncUpdateMap = new Map<Integer,MasterDataSync__c>();
            Map<Integer,MasterData__c> masterDataUpsertMap = new Map<Integer,MasterData__c>();
            List<MasterDataSync__c> masterDataSyncErrorList = new List<MasterDataSync__c>();
			List<MasterDataSync__c> masterDataSyncUpdateList = new List<MasterDataSync__c>();
            Set<String> externalIds = new Set<String>();
            
            Map<String,MasterDataSync__c> uniqueRecordsMap = new Map<String,MasterDataSync__c>();
            Map<String,Boolean> duplicateRecordMap = new Map<String,Boolean>();
            Map<String,PropertyTypeMasterWrapper> uniquePropertyTypeMasterMap = new Map<String,PropertyTypeMasterWrapper>();
            
            if(!records.isEmpty()){
                Integer counter=0;
                Integer count=0;
				for(MasterDataSync__c record : records){
                    if(String.isNotBlank(record.Record__c)){
                        PropertyTypeMasterWrapper responseWrapper = (PropertyTypeMasterWrapper) JSON.deserialize(record.Record__c, PropertyTypeMasterWrapper.class); 
                        if(responseWrapper!=null){
                            try{
                                if(responseWrapper.DESCRIPTION!=null && String.isNotBlank(responseWrapper.DESCRIPTION) && responseWrapper.VALUE!=null && String.isNotBlank(responseWrapper.VALUE)){
                                    externalIds.add(responseWrapper.VALUE);
                                    if(!uniqueRecordsMap.containsKey(responseWrapper.VALUE) && !duplicateRecordMap.containsKey(responseWrapper.VALUE)){
                                        uniqueRecordsMap.put(responseWrapper.VALUE,record);
                                        duplicateRecordMap.put(responseWrapper.VALUE,true);
                                        uniquePropertyTypeMasterMap.put(responseWrapper.VALUE,responseWrapper);
                                    }
                                    else{
                                        if(uniqueRecordsMap.containsKey(responseWrapper.VALUE)){
                                            MasterDataSync__c errorRecord = new MasterDataSync__c();
                                    		errorRecord.Id = uniqueRecordsMap.get(responseWrapper.VALUE).Id;
                                    		errorRecord.IsProcessed__c=true;
                                    		errorRecord.SyncStatus__c='Failed';
                                            errorRecord.ErrorCode__c= customErrorCode.get('DUPLICATE_VALUE');
                                    		errorRecord.ErrorMessage__c=  'DUPLICATE_VALUE: Duplicate external id specified: '+responseWrapper.VALUE;
                                    		masterDataSyncErrorList.add(errorRecord);
                                            uniqueRecordsMap.remove(responseWrapper.VALUE);
                                            uniquePropertyTypeMasterMap.remove(responseWrapper.VALUE);
                                        }
                                        
                                        MasterDataSync__c errorRecord = new MasterDataSync__c();
                                        errorRecord.Id = record.Id;
                                        errorRecord.IsProcessed__c=true;
                                        errorRecord.SyncStatus__c='Failed';
                                        errorRecord.ErrorCode__c= customErrorCode.get('DUPLICATE_VALUE');
                                        errorRecord.ErrorMessage__c=  'DUPLICATE_VALUE: Duplicate external id specified: '+responseWrapper.VALUE;
                                        masterDataSyncErrorList.add(errorRecord);
                                        
                                    }
                                }
                                else{
                                    List<String> requiredList = new List<String>();
                                    if(responseWrapper.DESCRIPTION==null || String.isBlank(responseWrapper.DESCRIPTION)){
                                        requiredList.add('DESCRIPTION');
                                    }
                                    if(responseWrapper.VALUE==null || String.isBlank(responseWrapper.VALUE)){
                                        requiredList.add('VALUE');
                                    }
                                    throw new MasterDataSyncException(record.Id,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: Required attributes are missing: [' + String.Join(requiredList,',') + ']' );
                                }
                            }
                            catch(MasterDataSyncException ex){
                                if(ex.recordId!=null){
                                    MasterDataSync__c errorRecord = new MasterDataSync__c();
                                    errorRecord.Id = ex.recordId;
                                    errorRecord.IsProcessed__c=true;
                                    errorRecord.SyncStatus__c='Failed';
                                    errorRecord.ErrorCode__c= String.isNotBlank(ex.errorCode)? ex.errorCode:customErrorCode.get('SYNC_ERROR');
                                    errorRecord.ErrorMessage__c= String.isNotBlank(ex.errorMessage)? ex.errorMessage:'Error Occurred while Data Sync';
                                    masterDataSyncErrorList.add(errorRecord);
                                }
                            }
						
                        }
                    }
                }
                
                for(String key: uniqueRecordsMap.keySet()){
                    masterDataSyncUpdateMap.put(count, new MasterDataSync__c(Id=uniqueRecordsMap.get(key).Id,UID__c= key));
                    propertyTypeMasterMap.put(count,uniquePropertyTypeMasterMap.get(key));
                    count++;
                }
                
                system.debug(':::'+propertyTypeMasterMap);
                
                
                if(!propertyTypeMasterMap.isEmpty()){
                    
                    Map<String,MasterData__c> masterDataMap = new Map<String,MasterData__c>();
                    for(MasterData__c data: [Select Id,FinnoneCode__c,Type__c FROM MasterData__c WHERE FinnoneCode__c IN :externalIds AND Type__c =:type]){
                        masterDataMap.put(data.FinnoneCode__c,data);
                    }
                    
                    for (Integer key : propertyTypeMasterMap.keySet()) {
                        PropertyTypeMasterWrapper propertyTypeMaster = propertyTypeMasterMap.get(key);
                        if(!masterDataUpsertMap.containsKey(key)){
                            if(propertyTypeMaster!=null){
                                MasterData__c masterData = new MasterData__c();
                                if(propertyTypeMaster.VALUE!=null && String.isNotBlank(propertyTypeMaster.VALUE)){
                                    if(masterDataMap.containsKey(propertyTypeMaster.VALUE)){
                                        masterData.Id = masterDataMap.get(propertyTypeMaster.VALUE).Id;
                                    }
                                    else{
                                        masterData.Type__c =type;
                                    }
                                    masterData.FinnoneCode__c =propertyTypeMaster.VALUE;
                                }
                                if(propertyTypeMaster.DESCRIPTION!=null && String.isNotBlank(propertyTypeMaster.DESCRIPTION)){
                                    masterData.Name = propertyTypeMaster.DESCRIPTION;
                                    masterData.FinnoneVal__c = propertyTypeMaster.DESCRIPTION;
                                    masterData.SalesforceCode__c = propertyTypeMaster.DESCRIPTION;
                                }
                                masterDataUpsertMap.put(key,masterData);
                            }
                        }
                    }
                }
                if(!masterDataUpsertMap.isEmpty()){
                    System.debug('::::'+masterDataUpsertMap);
                    Schema.SObjectField externalID = MasterData__c.Fields.Id;
                    Database.UpsertResult[] results = Database.upsert(masterDataUpsertMap.values(),externalID,false);
                    for(Integer i=0; i<results.size(); i++){
                        if(results[i].isSuccess()){
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                    masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                    masterDataSyncUpdateMap.get(i).SyncStatus__c='Success';
                                    masterDataSyncUpdateMap.get(i).ErrorCode__c=customErrorCode.get('SUCCESS');
                                    masterDataSyncUpdateMap.get(i).ErrorMessage__c='SUCCESS: Data Sync Successful';
                            }		
                        }
                        else {
                            List<Database.Error> err = results[i].getErrors();
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                masterDataSyncUpdateMap.get(i).SyncStatus__c='Failed';
                                masterDataSyncUpdateMap.get(i).ErrorCode__c= !err.isEmpty() && customErrorCode.containsKey(String.valueOf(err[0].getStatusCode())) ? customErrorCode.get(String.ValueOf(err[0].getStatusCode())) : customErrorCode.get('SYNC_ERROR');
                                masterDataSyncUpdateMap.get(i).ErrorMessage__c= !err.isEmpty() ? err[0].getStatusCode() + ': ' + err[0].getMessage() : 'Error Occurred while Data Sync';
                            }
                        }
                        
                    }
                }
                if(!masterDataSyncUpdateMap.isEmpty()){
                    masterDataSyncUpdateList.addAll(masterDataSyncUpdateMap.values());
                }
                if(!masterDataSyncErrorList.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncErrorList);
				}	
				if(!masterDataSyncUpdateList.isEmpty()){
					update masterDataSyncUpdateList;
				}
                
                if(type=='Property Usage'){
                    updatePropertyUsagePicklistField();
                }
                if(type=='Property Type'){
                    updateGlobalPicklistField('Property Type');
                }
            }
        }
        catch(Exception ex){
            System.debug('processPropertyMaster ' + ex.getMessage() + ' line ' + ex.getLineNumber());
        }
    }
    
    public static void processBranchMaster(List<MasterDataSync__c> records){
        try{
            Map<Integer,BranchMasterWrapper> branchMasterMap = new Map<Integer,BranchMasterWrapper>();
            Map<Integer,MasterDataSync__c> masterDataSyncUpdateMap = new Map<Integer,MasterDataSync__c>();
            Map<Integer,BankBrchMstr__c> bankBrchMstrUpsertMap = new Map<Integer,BankBrchMstr__c>();
            Set<String> externalIds = new Set<String>();
            List<MasterDataSync__c> masterDataSyncErrorList = new List<MasterDataSync__c>();
			List<MasterDataSync__c> masterDataSyncUpdateList = new List<MasterDataSync__c>();
            
            if(!records.isEmpty()){
                
                Integer counter=0;
                for(MasterDataSync__c record : records){
                    if(String.isNotBlank(record.Record__c)){
                        BranchMasterWrapper responseWrapper = (BranchMasterWrapper) JSON.deserialize(record.Record__c, BranchMasterWrapper.class); 
                        if(responseWrapper!=null){
                            try{
                                if(responseWrapper.BRANCHID!=null && String.isNotBlank(responseWrapper.BRANCHID) && responseWrapper.BRANCHDESC!=null && String.isNotBlank(responseWrapper.BRANCHDESC) && 
                                   responseWrapper.BRANCHCODE!=null && String.isNotBlank(responseWrapper.BRANCHCODE) && responseWrapper.SUNINFO_BRANCH_CODE!=null && String.isNotBlank(responseWrapper.SUNINFO_BRANCH_CODE)
                                  ){
                                      if(!masterDataSyncUpdateMap.containsKey(counter)){
                                          masterDataSyncUpdateMap.put(counter, new MasterDataSync__c(Id=record.Id,UID__c= (responseWrapper!=null && String.isNotBlank(responseWrapper.BRANCHID))?responseWrapper.BRANCHID:''));
                                          branchMasterMap.put(counter,responseWrapper);
                                          counter++;
                                      }
                                }
                                else{
                                    List<String> requiredList = new List<String>();
                                    if(responseWrapper.BRANCHID==null || String.isBlank(responseWrapper.BRANCHID)){
                                        requiredList.add('BRANCHID');
                                    }
                                    if(responseWrapper.BRANCHDESC==null || String.isBlank(responseWrapper.BRANCHDESC)){
                                        requiredList.add('BRANCHDESC');
                                    }
                                    if(responseWrapper.BRANCHCODE==null || String.isBlank(responseWrapper.BRANCHCODE)){
                                        requiredList.add('BRANCHCODE');
                                    }
                                    if(responseWrapper.SUNINFO_BRANCH_CODE==null || String.isBlank(responseWrapper.SUNINFO_BRANCH_CODE)){
                                        requiredList.add('SUNINFO_BRANCH_CODE');
                                    }
                                    throw new MasterDataSyncException(record.Id,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: Required attributes are missing: [' + String.Join(requiredList,',') + ']' );
                                }
                            }
                            catch(MasterDataSyncException ex){
                                if(ex.recordId!=null){
                                    MasterDataSync__c errorRecord = new MasterDataSync__c();
                                    errorRecord.Id = ex.recordId;
                                    errorRecord.IsProcessed__c=true;
                                    errorRecord.SyncStatus__c='Failed';
                                    errorRecord.ErrorCode__c= String.isNotBlank(ex.errorCode)? ex.errorCode:customErrorCode.get('SYNC_ERROR');
                                    errorRecord.ErrorMessage__c= String.isNotBlank(ex.errorMessage)? ex.errorMessage:'Error Occurred while Data Sync';
                                    masterDataSyncErrorList.add(errorRecord);
                                }
                            }
                        }
                    }                    
                }
                
                if(!branchMasterMap.isEmpty()){
                    
                    for (Integer key : branchMasterMap.keySet()) {
                        BranchMasterWrapper branchMaster = branchMasterMap.get(key);
                        if(!bankBrchMstrUpsertMap.containsKey(key)){
                            if(branchMaster!=null){
                                BankBrchMstr__c bankBrchMstr = new BankBrchMstr__c();
                                if(branchMaster!=null && String.isNotBlank(branchMaster.BRANCHID)){
                                    bankBrchMstr.OffcCode__c = branchMaster.BRANCHID;
                                }
                                if(branchMaster!=null && String.isNotBlank(branchMaster.BRANCHDESC)){
                                    bankBrchMstr.Name = branchMaster.BRANCHDESC;
                                }
                                if(branchMaster!=null && String.isNotBlank(branchMaster.PHONE1)){
                                    bankBrchMstr.Phone__c = branchMaster.PHONE1;
                                }
                                if(branchMaster!=null && String.isNotBlank(branchMaster.BRANCHCODE)){
                                    bankBrchMstr.BrchCode__c = branchMaster.BRANCHCODE;
                                }
                                if(branchMaster!=null && String.isNotBlank(branchMaster.SUNINFO_BRANCH_CODE)){
                                    bankBrchMstr.SunInforBrchCode__c = branchMaster.SUNINFO_BRANCH_CODE;
                                }
                                bankBrchMstrUpsertMap.put(key,bankBrchMstr);
                            }
                        }
                    }
                }
                if(!bankBrchMstrUpsertMap.isEmpty()){
                    System.debug('::::'+bankBrchMstrUpsertMap);
                    Schema.SObjectField externalID = BankBrchMstr__c.Fields.OffcCode__c;
                    Database.UpsertResult[] results = Database.upsert(bankBrchMstrUpsertMap.values(),externalID,false);
                    for(Integer i=0; i<results.size(); i++){
                        if(results[i].isSuccess()){
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                    masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                    masterDataSyncUpdateMap.get(i).SyncStatus__c='Success';
                                    masterDataSyncUpdateMap.get(i).ErrorCode__c=customErrorCode.get('SUCCESS');
                                    masterDataSyncUpdateMap.get(i).ErrorMessage__c='SUCCESS: Data Sync Successful';
                            }		
                        }
                        else {
                            List<Database.Error> err = results[i].getErrors();
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                masterDataSyncUpdateMap.get(i).SyncStatus__c='Failed';
                                masterDataSyncUpdateMap.get(i).ErrorCode__c= !err.isEmpty() && customErrorCode.containsKey(String.valueOf(err[0].getStatusCode())) ? customErrorCode.get(String.ValueOf(err[0].getStatusCode())) : customErrorCode.get('SYNC_ERROR');
                                masterDataSyncUpdateMap.get(i).ErrorMessage__c= !err.isEmpty() ? err[0].getStatusCode() + ': ' + err[0].getMessage() : 'Error Occurred while Data Sync';
                            }
                        }
                        
                    }
                }
                if(!masterDataSyncUpdateMap.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncUpdateMap.values());
                    
                }
				if(!masterDataSyncErrorList.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncErrorList);
				}	
				if(!masterDataSyncUpdateList.isEmpty()){
					update masterDataSyncUpdateList;
				}
            }
        }
        catch(Exception ex){
            System.debug('processBranchMaster ' + ex.getMessage() + ' line ' + ex.getLineNumber());
        }
    }
    
    public static void processSchemeMaster(List<MasterDataSync__c> records){
        try{
            //Map<Integer,SchemeMasterWrapper> schemeMasterMap = new Map<Integer,SchemeMasterWrapper>();
            Map<Integer,MasterDataSync__c> masterDataSyncUpdateMap = new Map<Integer,MasterDataSync__c>();
            Map<Integer,SchMapping__c> schMappingUpsertMap = new Map<Integer,SchMapping__c>();
            Set<String> externalIds = new Set<String>();
            Set<String> parentRefIds = new Set<String>();
            Map<String,SchmGrp__c> schmGrpMap = new Map<String,SchmGrp__c>();
            
            List<MasterDataSync__c> masterDataSyncErrorList = new List<MasterDataSync__c>();
			List<MasterDataSync__c> masterDataSyncUpdateList = new List<MasterDataSync__c>();
            Map<String,MasterDataSync__c> masterDataSyncMap = new Map<String,MasterDataSync__c>();
            Map<String,SchemeMasterWrapper> schemeMap = new Map<String,SchemeMasterWrapper>();
            
            if(!records.isEmpty()){
                
                for(MasterDataSync__c record : records){
					if(String.isNotBlank(record.Record__c)){
						
						SchemeMasterWrapper responseWrapper = (SchemeMasterWrapper) JSON.deserialize(record.Record__c, SchemeMasterWrapper.class); 
                        if(responseWrapper!=null){
                            try{
                                if(responseWrapper.SCHEMEID!=null && String.isNotBlank(responseWrapper.SCHEMEID) && responseWrapper.SCHEMEDESC!=null && String.isNotBlank(responseWrapper.SCHEMEDESC) &&
                                  responseWrapper.MAXAMTFIN!=null && String.isNotBlank(responseWrapper.MAXAMTFIN) && responseWrapper.MAXTENURE!=null && String.isNotBlank(responseWrapper.MAXTENURE) &&
                                  responseWrapper.MINAMTFIN!=null && String.isNotBlank(responseWrapper.MINAMTFIN) && responseWrapper.MINTENURE!=null && String.isNotBlank(responseWrapper.MINTENURE) &&
                                  responseWrapper.SCHID!=null && String.isNotBlank(responseWrapper.SCHID) && responseWrapper.TENURE!=null && String.isNotBlank(responseWrapper.TENURE)
                                  ){
                                    externalIds.add(responseWrapper.SCHEMEID);
									parentRefIds.add(responseWrapper.SCHID);
									masterDataSyncMap.put(record.Id,record);
									schemeMap.put(record.Id,responseWrapper);                                      
                                }
                                else{
                                    List<String> requiredList = new List<String>();
                                    if(responseWrapper.SCHEMEID==null || String.isBlank(responseWrapper.SCHEMEID)){
                                        requiredList.add('SCHEMEID');
                                    }
                                    if(responseWrapper.SCHEMEDESC==null || String.isBlank(responseWrapper.SCHEMEDESC)){
                                        requiredList.add('SCHEMEDESC');
                                    }
                                    if(responseWrapper.MAXAMTFIN==null || String.isBlank(responseWrapper.MAXAMTFIN)){
                                        requiredList.add('MAXAMTFIN');
                                    }
                                    if(responseWrapper.MAXTENURE==null || String.isBlank(responseWrapper.MAXTENURE)){
                                        requiredList.add('MAXTENURE');
                                    }
                                    if(responseWrapper.MINAMTFIN==null || String.isBlank(responseWrapper.MINAMTFIN)){
                                        requiredList.add('MINAMTFIN');
                                    }
                                    if(responseWrapper.MINTENURE==null || String.isBlank(responseWrapper.MINTENURE)){
                                        requiredList.add('MINTENURE');
                                    }
                                    if(responseWrapper.SCHID==null || String.isBlank(responseWrapper.SCHID)){
                                        requiredList.add('SCHID');
                                    }
                                    if(responseWrapper.TENURE==null || String.isBlank(responseWrapper.TENURE)){
                                        requiredList.add('TENURE');
                                    }    
                                    throw new MasterDataSyncException(record.Id,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: Required attributes are missing: [' + String.Join(requiredList,',') + ']' );
                                }
                            }
                            catch(MasterDataSyncException ex){
                                if(ex.recordId!=null){
                                    MasterDataSync__c errorRecord = new MasterDataSync__c();
                                    errorRecord.Id = ex.recordId;
                                    errorRecord.IsProcessed__c=true;
                                    errorRecord.SyncStatus__c='Failed';
                                    errorRecord.ErrorCode__c= String.isNotBlank(ex.errorCode)? ex.errorCode:customErrorCode.get('SYNC_ERROR');
                                    errorRecord.ErrorMessage__c= String.isNotBlank(ex.errorMessage)? ex.errorMessage:'Error Occurred while Data Sync';
                                    masterDataSyncErrorList.add(errorRecord);
                                }
                                
                            }
                        }
                    }
                }
                
                for(SchmGrp__c grp : [Select Id,SCHID__c FROM SchmGrp__c WHERE SCHID__c IN:parentRefIds]){
                    schmGrpMap.put(grp.SCHID__c,grp);
                }
                
                Integer counter=0;
                for(String key : masterDataSyncMap.keySet()){
                    try{
                        SchemeMasterWrapper schemeMaster = schemeMap.get(key);
                        if(schmGrpMap.containsKey(schemeMaster.SCHID)){
                            masterDataSyncUpdateMap.put(counter, new MasterDataSync__c(Id=key,UID__c= schemeMaster.SCHID));
                            //schemeMasterMap.put(counter,schemeMaster);
                            if(!schMappingUpsertMap.containsKey(counter)){
                                if(schemeMaster!=null){
                                    SchMapping__c schMapping = new SchMapping__c();
                                    if(schemeMaster!=null && String.isNotBlank(schemeMaster.PRODUCTFLAG)){
                                        //STL,LAP,HL,BL
                                        schMapping.ProductType__c = schemeMaster.PRODUCTFLAG=='LAP'? 'Loan Against Property': schemeMaster.PRODUCTFLAG=='STL'? 'Small Ticket LAP': schemeMaster.PRODUCTFLAG=='BL'? 'Business Loan': schemeMaster.PRODUCTFLAG=='HL'? 'Home Loan' : '';
                                    }
                                    if(schemeMaster!=null && String.isNotBlank(schemeMaster.SCHEME_END_DATE)){
                                        List<String> dateList = schemeMaster.SCHEME_END_DATE.split('/');
                                        if(dateList.size()>=3){
                                            schMapping.EndDate__c = Date.newInstance(Integer.valueof(dateList[2]),Integer.valueof(dateList[1]),Integer.valueof(dateList[0]));
                                        }
                                        
                                    }
                                    if(schemeMaster!=null && String.isNotBlank(schemeMaster.SCHEMEID)){
                                        schMapping.SchmId__c = schemeMaster.SCHEMEID;
                                    }
                                    if(schemeMaster!=null && String.isNotBlank(schemeMaster.SCHEMEDESC)){
                                        schMapping.SchemeDesc__c = schemeMaster.SCHEMEDESC;
                                    }
                                    if(schemeMaster!=null && String.isNotBlank(schemeMaster.FREQUENCY)){
                                        schMapping.Frequency__c = schemeMaster.FREQUENCY;
                                    }
                                    if(schemeMaster!=null && String.isNotBlank(schemeMaster.INSTLMODE)){
                                        schMapping.InstlMode__c = schemeMaster.INSTLMODE;
                                    }
                                    if(schemeMaster!=null && String.isNotBlank(schemeMaster.INSTLTYPE)){
                                        schMapping.InstlType__c = schemeMaster.INSTLTYPE;
                                    }
                                    if(schemeMaster!=null && String.isNotBlank(schemeMaster.INTRATE)){
                                        schMapping.IntRate__c = Decimal.valueOf(schemeMaster.INTRATE);
                                    }
                                    if(schemeMaster!=null && String.isNotBlank(schemeMaster.MAXAMTFIN)){
                                        schMapping.MaxAmtFin__c = Decimal.valueOf(schemeMaster.MAXAMTFIN);
                                    }
                                    if(schemeMaster!=null && String.isNotBlank(schemeMaster.MAXINTRATE)){
                                        schMapping.MaxIntRate__c = Decimal.valueOf(schemeMaster.MAXINTRATE);
                                    }
                                    if(schemeMaster!=null && String.isNotBlank(schemeMaster.MAXTENURE)){
                                        schMapping.MaxTenure__c = Integer.ValueOf(schemeMaster.MAXTENURE);
                                    }
                                    if(schemeMaster!=null && String.isNotBlank(schemeMaster.MINAMTFIN)){
                                        schMapping.MinAmtFin__c = Decimal.valueOf(schemeMaster.MINAMTFIN);
                                    }
                                    if(schemeMaster!=null && String.isNotBlank(schemeMaster.MININTRATE)){
                                        schMapping.MinIntRate__c = Decimal.ValueOf(schemeMaster.MININTRATE);
                                    }
                                    if(schemeMaster!=null && String.isNotBlank(schemeMaster.MINTENURE)){
                                        schMapping.MinTenure__c = Integer.ValueOf(schemeMaster.MINTENURE);
                                    }
                                    if(schemeMaster!=null && String.isNotBlank(schemeMaster.SCHID)){
                                        if(schmGrpMap.containsKey(schemeMaster.SCHID)){
                                            schMapping.SchGroup__c = schmGrpMap.get(schemeMaster.SCHID).Id;
                                        }
                                        
                                    }
                                    if(schemeMaster!=null && String.isNotBlank(schemeMaster.SCHEME_START_DATE)){
                                        List<String> dateList = schemeMaster.SCHEME_START_DATE.split('[- T :]');
                                        if(dateList.size()>=3){
                                            schMapping.StartDate__c = Date.newInstance(Integer.valueof(dateList[0]),Integer.valueof(dateList[1]),Integer.valueof(dateList[2]));
                                        }
                                    }
                                    if(schemeMaster!=null && String.isNotBlank(schemeMaster.STATUS)){
                                        schMapping.Status__c = schemeMaster.STATUS;
                                    }
                                    if(schemeMaster!=null && String.isNotBlank(schemeMaster.TENURE)){
                                        schMapping.Tenure__c = Integer.ValueOf(schemeMaster.TENURE);
                                    }
                                    schMappingUpsertMap.put(counter,schMapping);
                                }
                            }
                            counter++;
							                            
                        }
                        else{
                            throw new MasterDataSyncException(key,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: SCHID: ' + schemeMaster.SCHID + ' not found in SFDC Master');
                        }
                    }
                    catch(MasterDataSyncException ex){
                        if(ex.recordId!=null){
                            MasterDataSync__c errorRecord = new MasterDataSync__c();
                            errorRecord.Id = ex.recordId;
                            errorRecord.IsProcessed__c=true;
                            errorRecord.SyncStatus__c='Failed';
                            errorRecord.ErrorCode__c= String.isNotBlank(ex.errorCode)? ex.errorCode:customErrorCode.get('SYNC_ERROR');
                            errorRecord.ErrorMessage__c= String.isNotBlank(ex.errorMessage)? ex.errorMessage:'Error Occurred while Data Sync';
                            masterDataSyncErrorList.add(errorRecord);
                        }
                    }
                }
                
                if(!schMappingUpsertMap.isEmpty()){
                    System.debug('::::'+schMappingUpsertMap);
                    Schema.SObjectField externalID = SchMapping__c.Fields.SchmId__c;
                    Database.UpsertResult[] results = Database.upsert(schMappingUpsertMap.values(),externalID,false);
                    for(Integer i=0; i<results.size(); i++){
                        if(results[i].isSuccess()){
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                    masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                    masterDataSyncUpdateMap.get(i).SyncStatus__c='Success';
                                    masterDataSyncUpdateMap.get(i).ErrorCode__c=customErrorCode.get('SUCCESS');
                                    masterDataSyncUpdateMap.get(i).ErrorMessage__c='SUCCESS: Data Sync Successful';
                            }		
                        }
                        else {
                            List<Database.Error> err = results[i].getErrors();
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                masterDataSyncUpdateMap.get(i).SyncStatus__c='Failed';
                                masterDataSyncUpdateMap.get(i).ErrorCode__c= !err.isEmpty() && customErrorCode.containsKey(String.valueOf(err[0].getStatusCode())) ? customErrorCode.get(String.ValueOf(err[0].getStatusCode())) : customErrorCode.get('SYNC_ERROR');
                                masterDataSyncUpdateMap.get(i).ErrorMessage__c= !err.isEmpty() ? err[0].getStatusCode() + ': ' + err[0].getMessage() : 'Error Occurred while Data Sync';
                            }
                        }
                        
                    }
                }
                
                if(!masterDataSyncUpdateMap.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncUpdateMap.values());
                }
				if(!masterDataSyncErrorList.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncErrorList);
				}	
				if(!masterDataSyncUpdateList.isEmpty()){
					update masterDataSyncUpdateList;
				}
            }
        }
		catch(Exception ex){
            System.debug('processSchemeMaster ' + ex.getMessage() + ' line ' + ex.getLineNumber());
        }
    }
    
    public static void processTechnicalAgencyMaster(List<MasterDataSync__c> records){
        try{
            Map<Integer,TechnicalAgencyMasterWrapper> masterMap = new Map<Integer,TechnicalAgencyMasterWrapper>();
            Map<Integer,MasterDataSync__c> masterDataSyncUpdateMap = new Map<Integer,MasterDataSync__c>();
            Map<Integer,Account> accountUpsertMap = new Map<Integer,Account>();
            Set<String> externalIds = new Set<String>();
            Set<String> refIds = new Set<String>();
            
            List<MasterDataSync__c> masterDataSyncErrorList = new List<MasterDataSync__c>();
			List<MasterDataSync__c> masterDataSyncUpdateList = new List<MasterDataSync__c>();
            
            
            if(!records.isEmpty()){
                
                Integer counter=0;
				for(MasterDataSync__c record : records){
                    if(String.isNotBlank(record.Record__c)){
                        TechnicalAgencyMasterWrapper responseWrapper = (TechnicalAgencyMasterWrapper) JSON.deserialize(record.Record__c, TechnicalAgencyMasterWrapper.class); 
                        if(responseWrapper!=null){
                            try{
                                if(responseWrapper.LAWYERNAME!=null && String.isNotBlank(responseWrapper.LAWYERNAME)){
                                    externalIds.add(responseWrapper.LAWYERNAME);
                                    if(String.isNotBlank(responseWrapper.BRANCHID)){
                                        refIds.add(responseWrapper.BRANCHID);
                                    }
                                    if(!masterDataSyncUpdateMap.containsKey(counter)){
                                        masterDataSyncUpdateMap.put(counter, new MasterDataSync__c(Id=record.Id,UID__c= (responseWrapper!=null && String.isNotBlank(responseWrapper.LAWYERNAME))?responseWrapper.LAWYERNAME:''));
                                        masterMap.put(counter,responseWrapper);
                                        counter++;
                                    }
                                    
                                }
                                else{
                                    List<String> requiredList = new List<String>();
                                    if(responseWrapper.LAWYERNAME==null || String.isBlank(responseWrapper.LAWYERNAME)){
                                        requiredList.add('LAWYERNAME');
                                    }
                                    throw new MasterDataSyncException(record.Id,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: Required attributes are missing: [' + String.Join(requiredList,',') + ']' );
                                }
                            }
                            catch(MasterDataSyncException ex){
                                if(ex.recordId!=null){
                                    MasterDataSync__c errorRecord = new MasterDataSync__c();
                                    errorRecord.Id = ex.recordId;
                                    errorRecord.IsProcessed__c=true;
                                    errorRecord.SyncStatus__c='Failed';
                                    errorRecord.ErrorCode__c= String.isNotBlank(ex.errorCode)? ex.errorCode:customErrorCode.get('SYNC_ERROR');
                                    errorRecord.ErrorMessage__c= String.isNotBlank(ex.errorMessage)? ex.errorMessage:'Error Occurred while Data Sync';
                                    masterDataSyncErrorList.add(errorRecord);
                                }
                                
                            }
                        }
                    }
                }
                
                if(!masterMap.isEmpty()){
                    Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency').getRecordTypeId();
                    //Map<String,Account> accountMap = new Map<String,Account>();
                    Map<String,BankBrchMstr__c> bankBrchMstrMap = new Map<String,BankBrchMstr__c>();
                    //for(Account acc: [Select Id,AgencyCode__c FROM Account WHERE AgencyCode__c IN :externalIds AND RecordTypeID=:recordTypeId]){
                    //    accountMap.put(acc.AgencyCode__c,acc);
                    //}
                    for(BankBrchMstr__c bankBrch : [Select Id,OffcCode__c from BankBrchMstr__c WHERE OffcCode__c IN: refIds]){
                        bankBrchMstrMap.put(bankBrch.OffcCode__c,bankBrch);
                    }
                    
                    for (Integer key : masterMap.keySet()) {
                        TechnicalAgencyMasterWrapper master = masterMap.get(key);
                        if(!accountUpsertMap.containsKey(key)){
                            if(master!=null){
                                if(master.LAWYERNAME!=null && String.isNotBlank(master.LAWYERNAME)){
                                    //if(accountMap.containsKey(master.LAWYERNAME)){
                                        //acc.Id = accountMap.get(master.LAWYERNAME).Id;
                                    //}
                                    //else{
                                    //    acc.RecordTypeId = recordTypeId;
                                        
                                    //}
                                    Account acc = new Account();
                                    acc.Name = master.LAWYERNAME;
                                    acc.AgencyCode__c = master.LAWYERNAME;
                                    acc.RecordTypeId = recordTypeId;
                                    if(master.BRANCHID!=null && String.isNotBlank(master.BRANCHID)){
                                        if(bankBrchMstrMap.containsKey(master.BRANCHID)){
                                            acc.Branch__c = bankBrchMstrMap.get(master.BRANCHID).Id;
                                        }
                                    }
                                    accountUpsertMap.put(key,acc);
                                }
                                
                            }
                        }
                    }
                }
                if(!accountUpsertMap.isEmpty()){
                    System.debug('::::'+accountUpsertMap);
                    Schema.SObjectField externalID = Account.Fields.AgencyCode__c;
                    Database.UpsertResult[] results = Database.upsert(accountUpsertMap.values(),externalID,false);
                    for(Integer i=0; i<results.size(); i++){
                        if(results[i].isSuccess()){
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                    masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                    masterDataSyncUpdateMap.get(i).SyncStatus__c='Success';
                                    masterDataSyncUpdateMap.get(i).ErrorCode__c=customErrorCode.get('SUCCESS');
                                    masterDataSyncUpdateMap.get(i).ErrorMessage__c='SUCCESS: Data Sync Successful';
                            }		
                        }
                        else {
                            List<Database.Error> err = results[i].getErrors();
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                masterDataSyncUpdateMap.get(i).SyncStatus__c='Failed';
                                masterDataSyncUpdateMap.get(i).ErrorCode__c= !err.isEmpty() && customErrorCode.containsKey(String.valueOf(err[0].getStatusCode())) ? customErrorCode.get(String.ValueOf(err[0].getStatusCode())) : customErrorCode.get('SYNC_ERROR');
                                masterDataSyncUpdateMap.get(i).ErrorMessage__c= !err.isEmpty() ? err[0].getStatusCode() + ': ' + err[0].getMessage() : 'Error Occurred while Data Sync';
                            }
                        }
                        
                    }
                }
                if(!masterDataSyncUpdateMap.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncUpdateMap.values());
                    
                }
				if(!masterDataSyncErrorList.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncErrorList);
				}	
				if(!masterDataSyncUpdateList.isEmpty()){
					update masterDataSyncUpdateList;
				}
            }
        }   
        catch(Exception ex){
            System.debug('processTechnicalAgencyMaster ' + ex.getMessage() + ' line ' + ex.getLineNumber());
        }
    }
    
    public static void processLegalAgencyMaster(List<MasterDataSync__c> records){
        try{
            Map<Integer,LegalAgencyMasterWrapper> masterMap = new Map<Integer,LegalAgencyMasterWrapper>();
            Map<Integer,MasterDataSync__c> masterDataSyncUpdateMap = new Map<Integer,MasterDataSync__c>();
            Map<Integer,Account> accountUpsertMap = new Map<Integer,Account>();
            Set<String> externalIds = new Set<String>();
            Set<String> refIds = new Set<String>();
            
            List<MasterDataSync__c> masterDataSyncErrorList = new List<MasterDataSync__c>();
			List<MasterDataSync__c> masterDataSyncUpdateList = new List<MasterDataSync__c>();
            
            if(!records.isEmpty()){
                
                Integer counter=0;
				for(MasterDataSync__c record : records){
                    if(String.isNotBlank(record.Record__c)){
                        LegalAgencyMasterWrapper responseWrapper = (LegalAgencyMasterWrapper) JSON.deserialize(record.Record__c, LegalAgencyMasterWrapper.class); 
                        if(responseWrapper!=null){
                            try{
                                if(responseWrapper.LFAM_AGENCYCODE_C!=null && String.isNotBlank(responseWrapper.LFAM_AGENCYCODE_C) && responseWrapper.LFAM_AGENCYNAME_C!=null && String.isNotBlank(responseWrapper.LFAM_AGENCYNAME_C)){
                                    externalIds.add(responseWrapper.LFAM_AGENCYCODE_C);
                                    if(String.isNotBlank(responseWrapper.BRANCHID)){
                                        refIds.add(responseWrapper.BRANCHID);
                                    }
                                    if(!masterDataSyncUpdateMap.containsKey(counter)){
                                        masterDataSyncUpdateMap.put(counter, new MasterDataSync__c(Id=record.Id,UID__c= (responseWrapper!=null && String.isNotBlank(responseWrapper.LFAM_AGENCYCODE_C))?responseWrapper.LFAM_AGENCYCODE_C:''));
                                        masterMap.put(counter,responseWrapper);
                                        counter++;
                                    }
                                }
                                else{
                                    List<String> requiredList = new List<String>();
								if(responseWrapper.LFAM_AGENCYCODE_C==null || String.isBlank(responseWrapper.LFAM_AGENCYCODE_C)){
									requiredList.add('LFAM_AGENCYCODE_C');
								}
								if(responseWrapper.LFAM_AGENCYNAME_C==null || String.isBlank(responseWrapper.LFAM_AGENCYNAME_C)){
									requiredList.add('LFAM_AGENCYNAME_C');
								}
								throw new MasterDataSyncException(record.Id,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: Required attributes are missing: [' + String.Join(requiredList,',') + ']' );
                                }
                            }
                            catch(MasterDataSyncException ex){
                                if(ex.recordId!=null){
                                    MasterDataSync__c errorRecord = new MasterDataSync__c();
                                    errorRecord.Id = ex.recordId;
                                    errorRecord.IsProcessed__c=true;
                                    errorRecord.SyncStatus__c='Failed';
                                    errorRecord.ErrorCode__c= String.isNotBlank(ex.errorCode)? ex.errorCode:customErrorCode.get('SYNC_ERROR');
                                    errorRecord.ErrorMessage__c= String.isNotBlank(ex.errorMessage)? ex.errorMessage:'Error Occurred while Data Sync';
                                    masterDataSyncErrorList.add(errorRecord);
                                }
                                
                            }
                        }
                    }
                }
                
                if(!masterMap.isEmpty()){
                    Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency').getRecordTypeId();
                    //Map<String,Account> accountMap = new Map<String,Account>();
                    Map<String,BankBrchMstr__c> bankBrchMstrMap = new Map<String,BankBrchMstr__c>();
                    //for(Account acc: [Select Id,AgencyCode__c FROM Account WHERE AgencyCode__c IN :externalIds AND RecordTypeID=:recordTypeId]){
                    //    accountMap.put(acc.AgencyCode__c,acc);
                    //}
                    for(BankBrchMstr__c bankBrch : [Select Id,OffcCode__c from BankBrchMstr__c WHERE OffcCode__c IN: refIds]){
                        bankBrchMstrMap.put(bankBrch.OffcCode__c,bankBrch);
                    }
                    
                    for (Integer key : masterMap.keySet()) {
                        LegalAgencyMasterWrapper master = masterMap.get(key);
                        if(!accountUpsertMap.containsKey(key)){
                            if(master!=null){
                                Account acc = new Account();
                                if(master.LFAM_AGENCYCODE_C!=null && String.isNotBlank(master.LFAM_AGENCYCODE_C)){
                                    //if(accountMap.containsKey(master.LFAM_AGENCYCODE_C)){
                                        //acc.Id = accountMap.get(master.LFAM_AGENCYCODE_C).Id;
                                    //}
                                    //else{
                                        
                                    //}
                                    acc.RecordTypeId = recordTypeId;
                                    acc.AgencyCode__c = master.LFAM_AGENCYCODE_C;
                                    
                                    if(master.LFAM_AGENCYNAME_C!=null && String.isNotBlank(master.LFAM_AGENCYNAME_C)){
                                        acc.Name = master.LFAM_AGENCYNAME_C;
                                    }
                                    if(master.LFABPMM_PRODCODE_C!=null && String.isNotBlank(master.LFABPMM_PRODCODE_C)){
                                        acc.Product__c = master.LFABPMM_PRODCODE_C=='LAP'? 'Small Ticket LAP': 'Home Loan';
                                    }
                                    if(master.BRANCHID!=null && String.isNotBlank(master.BRANCHID)){
                                        if(bankBrchMstrMap.containsKey(master.BRANCHID)){
                                            acc.Branch__c = bankBrchMstrMap.get(master.BRANCHID).Id;
                                        }
                                    }
                                }
                                accountUpsertMap.put(key,acc);
                            }
                        }
                    }
                }
                if(!accountUpsertMap.isEmpty()){
                    System.debug('::::'+accountUpsertMap);
                    Schema.SObjectField externalID = Account.Fields.AgencyCode__c;
                    Database.UpsertResult[] results = Database.upsert(accountUpsertMap.values(),externalID,false);
                    for(Integer i=0; i<results.size(); i++){
                        if(results[i].isSuccess()){
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                    masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                    masterDataSyncUpdateMap.get(i).SyncStatus__c='Success';
                                    masterDataSyncUpdateMap.get(i).ErrorCode__c=customErrorCode.get('SUCCESS');
                                    masterDataSyncUpdateMap.get(i).ErrorMessage__c='SUCCESS: Data Sync Successful';
                            }		
                        }
                        else {
                            List<Database.Error> err = results[i].getErrors();
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                masterDataSyncUpdateMap.get(i).SyncStatus__c='Failed';
                                masterDataSyncUpdateMap.get(i).ErrorCode__c= !err.isEmpty() && customErrorCode.containsKey(String.valueOf(err[0].getStatusCode())) ? customErrorCode.get(String.ValueOf(err[0].getStatusCode())) : customErrorCode.get('SYNC_ERROR');
                                masterDataSyncUpdateMap.get(i).ErrorMessage__c= !err.isEmpty() ? err[0].getStatusCode() + ': ' + err[0].getMessage() : 'Error Occurred while Data Sync';
                            }
                        }
                    }
                }
                if(!masterDataSyncUpdateMap.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncUpdateMap.values());
                    
                }
				if(!masterDataSyncErrorList.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncErrorList);
				}	
				if(!masterDataSyncUpdateList.isEmpty()){
					update masterDataSyncUpdateList;
				}
            }
        } 
        catch(Exception ex){
            System.debug('processLegalAgencyMaster ' + ex.getMessage() + ' line ' + ex.getLineNumber());
        }  
    }
    
    public static void processBankNameMaster(List<MasterDataSync__c> records){
        try{
            Map<Integer,BankNameMasterWrapper> masterMap = new Map<Integer,BankNameMasterWrapper>();
            Map<Integer,MasterDataSync__c> masterDataSyncUpdateMap = new Map<Integer,MasterDataSync__c>();
            Map<Integer,MasterData__c> masterDataUpsertMap = new Map<Integer,MasterData__c>();
            Set<String> externalIds = new Set<String>();
            
            List<MasterDataSync__c> masterDataSyncErrorList = new List<MasterDataSync__c>();
			List<MasterDataSync__c> masterDataSyncUpdateList = new List<MasterDataSync__c>();
            Map<String,MasterDataSync__c> uniqueRecordsMap = new Map<String,MasterDataSync__c>();
            Map<String,Boolean> duplicateRecordMap = new Map<String,Boolean>();
            Map<String,BankNameMasterWrapper> uniquemasterMap = new Map<String,BankNameMasterWrapper>();
            
            if(!records.isEmpty()){
                
                Integer counter=0;
                Integer count=0;
				for(MasterDataSync__c record : records){
                    if(String.isNotBlank(record.Record__c)){
                        BankNameMasterWrapper responseWrapper = (BankNameMasterWrapper) JSON.deserialize(record.Record__c, BankNameMasterWrapper.class); 
                        if(responseWrapper!=null){
                            try{
                                
                                if(responseWrapper.BANKID!=null && String.isNotBlank(responseWrapper.BANKID) && responseWrapper.BANKDESC!=null && String.isNotBlank(responseWrapper.BANKDESC)){
                                    externalIds.add(responseWrapper.BANKID);
                                    if(!uniqueRecordsMap.containsKey(responseWrapper.BANKID) && !duplicateRecordMap.containsKey(responseWrapper.BANKID)){
                                        uniqueRecordsMap.put(responseWrapper.BANKID,record);
                                        duplicateRecordMap.put(responseWrapper.BANKID,true);
                                        uniquemasterMap.put(responseWrapper.BANKID,responseWrapper);
                                    }
                                    else{
                                        if(uniqueRecordsMap.containsKey(responseWrapper.BANKID)){
                                            MasterDataSync__c errorRecord = new MasterDataSync__c();
                                    		errorRecord.Id = uniqueRecordsMap.get(responseWrapper.BANKID).Id;
                                    		errorRecord.IsProcessed__c=true;
                                    		errorRecord.SyncStatus__c='Failed';
                                            errorRecord.ErrorCode__c= customErrorCode.get('DUPLICATE_VALUE');
                                    		errorRecord.ErrorMessage__c=  'DUPLICATE_VALUE: Duplicate external id specified: '+responseWrapper.BANKID;
                                    		masterDataSyncErrorList.add(errorRecord);
                                            uniqueRecordsMap.remove(responseWrapper.BANKID);
                                            uniquemasterMap.remove(responseWrapper.BANKID);
                                        }
                                        
                                        MasterDataSync__c errorRecord = new MasterDataSync__c();
                                        errorRecord.Id = record.Id;
                                        errorRecord.IsProcessed__c=true;
                                        errorRecord.SyncStatus__c='Failed';
                                        errorRecord.ErrorCode__c= customErrorCode.get('DUPLICATE_VALUE');
                                        errorRecord.ErrorMessage__c=  'DUPLICATE_VALUE: Duplicate external id specified: '+responseWrapper.BANKID;
                                        masterDataSyncErrorList.add(errorRecord);
                                        
                                    }
                                }
                                else{
                                    List<String> requiredList = new List<String>();
                                    if(responseWrapper.BANKID==null || String.isBlank(responseWrapper.BANKID)){
                                        requiredList.add('BANKID');
                                    }
                                    if(responseWrapper.BANKDESC==null || String.isBlank(responseWrapper.BANKDESC)){
                                        requiredList.add('BANKDESC');
                                    }
                                    throw new MasterDataSyncException(record.Id,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: Required attributes are missing: [' + String.Join(requiredList,',') + ']' );
                                }
                            }
                            catch(MasterDataSyncException ex){
                                if(ex.recordId!=null){
                                    MasterDataSync__c errorRecord = new MasterDataSync__c();
                                    errorRecord.Id = ex.recordId;
                                    errorRecord.IsProcessed__c=true;
                                    errorRecord.SyncStatus__c='Failed';
                                    errorRecord.ErrorCode__c= String.isNotBlank(ex.errorCode)? ex.errorCode:customErrorCode.get('SYNC_ERROR');
                                    errorRecord.ErrorMessage__c= String.isNotBlank(ex.errorMessage)? ex.errorMessage:'Error Occurred while Data Sync';
                                    masterDataSyncErrorList.add(errorRecord);
                                }
                                
                            }
                        }
                    }
                }
                
                for(String key: uniqueRecordsMap.keySet()){
                    masterDataSyncUpdateMap.put(count, new MasterDataSync__c(Id=uniqueRecordsMap.get(key).Id,UID__c= key));
                    masterMap.put(count,uniquemasterMap.get(key));
                    count++;
                }
                
                system.debug(':::'+masterMap);
                if(!masterMap.isEmpty()){
                    
                    Map<String,MasterData__c> masterDataMap = new Map<String,MasterData__c>();
                    for(MasterData__c data: [Select Id,FinnoneCode__c,Type__c FROM MasterData__c WHERE FinnoneCode__c IN :externalIds AND Type__c ='CashBank Account']){
                        masterDataMap.put(data.FinnoneCode__c,data);
                    }
                    
                    for (Integer key : masterMap.keySet()) {
                        BankNameMasterWrapper master = masterMap.get(key);
                        if(!masterDataUpsertMap.containsKey(key)){
                            if(master!=null){
                                MasterData__c masterData = new MasterData__c();
                                if(master.BANKID!=null && String.isNotBlank(master.BANKID)){
                                    if(masterDataMap.containsKey(master.BANKID)){
                                        masterData.Id = masterDataMap.get(master.BANKID).Id;
                                    }
                                    else{
                                        masterData.Type__c ='CashBank Account';
                                        
                                    }
                                    masterData.FinnoneCode__c =	master.BANKID;
                                    masterData.SalesforceCode__c = master.BANKID;
                                }
                                if(master.BANKDESC!=null && String.isNotBlank(master.BANKDESC)){
                                    masterData.Name = master.BANKDESC;
                                    masterData.FinnoneVal__c = master.BANKDESC;
                                }
                                if(master.FABANKGLID!=null && String.isNotBlank(master.FABANKGLID)){
                                    masterData.FABankgId__c = master.FABANKGLID;
                                }
                                if(master.BANKACNUM!=null && String.isNotBlank(master.BANKACNUM)){
                                    masterData.BankAcNum__c = master.BANKACNUM;
                                }
                                if(master.BANKACNUM!=null && String.isNotBlank(master.BANKACNUM)){
                                    masterData.BankAcNum__c = master.BANKACNUM;
                                }
                                if(master.BANK_IFS_C!=null && String.isNotBlank(master.BANK_IFS_C)){
                                    masterData.BankIFS__c = master.BANK_IFS_C;
                                }
                                if(master.BANK_RTGS_C!=null && String.isNotBlank(master.BANK_RTGS_C)){
                                    masterData.BankRTGS__c = master.BANK_RTGS_C;
                                }
                                if(master.BANK_NEFT_C!=null && String.isNotBlank(master.BANK_NEFT_C)){
                                    masterData.BankNEFT__c = master.BANK_NEFT_C;
                                }
                                if(master.BANK_IMPS_C!=null && String.isNotBlank(master.BANK_IMPS_C)){
                                    masterData.BankIMPS__c = master.BANK_IMPS_C;
                                }
                                
                                masterDataUpsertMap.put(key,masterData);
                            }
                        }
                    }
                }
                if(!masterDataUpsertMap.isEmpty()){
                    System.debug('::::'+masterDataUpsertMap);
                    Schema.SObjectField externalID = MasterData__c.Fields.Id;
                    Database.UpsertResult[] results = Database.upsert(masterDataUpsertMap.values(),externalID,false);
                    for(Integer i=0; i<results.size(); i++){
                        if(results[i].isSuccess()){
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                masterDataSyncUpdateMap.get(i).SyncStatus__c='Success';
                                masterDataSyncUpdateMap.get(i).ErrorCode__c=customErrorCode.get('SUCCESS');
                                masterDataSyncUpdateMap.get(i).ErrorMessage__c='SUCCESS: Data Sync Successful';
                            }		
                        }
                        else {
                            List<Database.Error> err = results[i].getErrors();
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                masterDataSyncUpdateMap.get(i).SyncStatus__c='Failed';
                                masterDataSyncUpdateMap.get(i).ErrorCode__c= !err.isEmpty() && customErrorCode.containsKey(String.valueOf(err[0].getStatusCode())) ? customErrorCode.get(String.ValueOf(err[0].getStatusCode())) : customErrorCode.get('SYNC_ERROR');
                                masterDataSyncUpdateMap.get(i).ErrorMessage__c= !err.isEmpty() ? err[0].getStatusCode() + ': ' + err[0].getMessage() : 'Error Occurred while Data Sync';
                            }
                        }
                        
                    }
                }
                if(!masterDataSyncUpdateMap.isEmpty()){
                    masterDataSyncUpdateList.addAll(masterDataSyncUpdateMap.values());
                }
                if(!masterDataSyncErrorList.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncErrorList);
				}	
				if(!masterDataSyncUpdateList.isEmpty()){
					update masterDataSyncUpdateList;
				}
            }
        }
        catch(Exception ex){
            System.debug('processBankNameMaster ' + ex.getMessage() + ' line ' + ex.getLineNumber());
        }
    }
    
    public static void processMICRBankNameMaster(List<MasterDataSync__c> records){
        try{
            Map<Integer,MICRBankNameMasterWrapper> masterMap = new Map<Integer,MICRBankNameMasterWrapper>();
            Map<Integer,MasterDataSync__c> masterDataSyncUpdateMap = new Map<Integer,MasterDataSync__c>();
            Map<Integer,BankMstr__c> masterDataUpsertMap = new Map<Integer,BankMstr__c>();
            Set<String> bankIds = new Set<String>();
            Set<String> cityIds = new Set<String>();
            Set<String> externalIds = new Set<String>();
            Map<String,BankMstr__c> bankMstrMap = new Map<String,BankMstr__c>();
            Map<String,CityInstrument__c> cityMap = new Map<String,CityInstrument__c>();
                
            
            List<MasterDataSync__c> masterDataSyncErrorList = new List<MasterDataSync__c>();
			List<MasterDataSync__c> masterDataSyncUpdateList = new List<MasterDataSync__c>();
            //Map<String,MasterDataSync__c> masterDataSyncMap = new Map<String,MasterDataSync__c>();
            //Map<String,MICRBankNameMasterWrapper> MICRBankNameMap = new Map<String,MICRBankNameMasterWrapper>();
            
            Map<String,MasterDataSync__c> uniqueRecordsMap = new Map<String,MasterDataSync__c>();
            Map<String,Boolean> duplicateRecordMap = new Map<String,Boolean>();
            Map<String,MICRBankNameMasterWrapper> uniqueMICRBankNameMap = new Map<String,MICRBankNameMasterWrapper>();
            
            if(!records.isEmpty()){
                
                for(MasterDataSync__c record : records){
                    if(String.isNotBlank(record.Record__c)){
                        MICRBankNameMasterWrapper responseWrapper = (MICRBankNameMasterWrapper) JSON.deserialize(record.Record__c, MICRBankNameMasterWrapper.class); 
                        if(responseWrapper!=null){
                            try{
                                if(responseWrapper.BANKID!=null && String.isNotBlank(responseWrapper.BANKID) && responseWrapper.NAME!=null && String.isNotBlank(responseWrapper.NAME) && responseWrapper.CITYID!=null && String.isNotBlank(responseWrapper.CITYID)){
                                    externalIds.add(responseWrapper.BANKID +'-'+ responseWrapper.CITYID);
                                    
                                    if(!uniqueRecordsMap.containsKey(responseWrapper.BANKID +'-'+ responseWrapper.CITYID) && !duplicateRecordMap.containsKey(responseWrapper.BANKID +'-'+ responseWrapper.CITYID)){
                                        uniqueRecordsMap.put(responseWrapper.BANKID +'-'+ responseWrapper.CITYID,record);
                                        duplicateRecordMap.put(responseWrapper.BANKID +'-'+ responseWrapper.CITYID,true);
                                        uniqueMICRBankNameMap.put(responseWrapper.BANKID +'-'+ responseWrapper.CITYID,responseWrapper);
                                        
                                        bankIds.add(responseWrapper.BANKID);
                                        cityIds.add(responseWrapper.CITYID);
                                        //masterDataSyncMap.put(record.Id,record);
                                        //MICRBankNameMap.put(record.Id,responseWrapper);                                      
                                    }
                                    else{
                                        if(uniqueRecordsMap.containsKey(responseWrapper.BANKID +'-'+ responseWrapper.CITYID)){
                                            MasterDataSync__c errorRecord = new MasterDataSync__c();
                                            errorRecord.Id = uniqueRecordsMap.get(responseWrapper.BANKID +'-'+ responseWrapper.CITYID).Id;
                                            errorRecord.IsProcessed__c=true;
                                            errorRecord.SyncStatus__c='Failed';
                                            errorRecord.ErrorCode__c= customErrorCode.get('DUPLICATE_VALUE');
                                            errorRecord.ErrorMessage__c=  'DUPLICATE_VALUE: Duplicate external id specified: '+responseWrapper.BANKID;
                                            masterDataSyncErrorList.add(errorRecord);
                                            uniqueRecordsMap.remove(responseWrapper.BANKID +'-'+ responseWrapper.CITYID);
                                            uniqueMICRBankNameMap.remove(responseWrapper.BANKID +'-'+ responseWrapper.CITYID);
                                        }
                                        
                                        MasterDataSync__c errorRecord = new MasterDataSync__c();
                                        errorRecord.Id = record.Id;
                                        errorRecord.IsProcessed__c=true;
                                        errorRecord.SyncStatus__c='Failed';
                                        errorRecord.ErrorCode__c= customErrorCode.get('DUPLICATE_VALUE');
                                        errorRecord.ErrorMessage__c=  'DUPLICATE_VALUE: Duplicate external id specified: '+responseWrapper.BANKID;
                                        masterDataSyncErrorList.add(errorRecord);
                                    }
                                    
                                    
                                    
                                }
                                else{
                                    List<String> requiredList = new List<String>();
                                    if(responseWrapper.BANKID==null || String.isBlank(responseWrapper.BANKID)){
                                        requiredList.add('BANKID');
                                    }
                                    if(responseWrapper.NAME==null || String.isBlank(responseWrapper.NAME)){
                                        requiredList.add('NAME');
                                    }
                                    if(responseWrapper.CITYID==null || String.isBlank(responseWrapper.CITYID)){
                                        requiredList.add('CITYID');
                                    }
                                    throw new MasterDataSyncException(record.Id,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: Required attributes are missing: [' + String.Join(requiredList,',') + ']' );
                                }
                            }
                            catch(MasterDataSyncException ex){
                                if(ex.recordId!=null){
                                    MasterDataSync__c errorRecord = new MasterDataSync__c();
                                    errorRecord.Id = ex.recordId;
                                    errorRecord.IsProcessed__c=true;
                                    errorRecord.SyncStatus__c='Failed';
                                    errorRecord.ErrorCode__c= String.isNotBlank(ex.errorCode)? ex.errorCode:customErrorCode.get('SYNC_ERROR');
                                    errorRecord.ErrorMessage__c= String.isNotBlank(ex.errorMessage)? ex.errorMessage:'Error Occurred while Data Sync';
                                    masterDataSyncErrorList.add(errorRecord);
                                }
                                
                            }
                        }
                    }
                }
                
                for(BankMstr__c data: [Select Id,BankId__c,City__c,City__r.CityId__c from BankMstr__c WHERE BankId__c IN:bankIds AND City__r.CityId__c IN:cityIds]){
                    bankMstrMap.put(data.BankId__c+'-'+data.City__r.CityId__c,data);
                }
                for(CityInstrument__c ci : [Select Id,CityId__c, Name,CityMICRCode__c, FORMAT(CreatedDate),FORMAT(LastModifiedDate) from CityInstrument__c ]  ){
                    cityMap.put(ci.CityId__c,ci);
                }
                
                Integer counter=0;
                for(String key: uniqueRecordsMap.keySet()){
                    try{
                        MICRBankNameMasterWrapper master = uniqueMICRBankNameMap.get(key);
                        if(cityMap.containsKey(master.CITYID)){
                            if(!masterDataUpsertMap.containsKey(counter)){
                                if(master!=null){
                                    masterDataSyncUpdateMap.put(counter, new MasterDataSync__c(Id=uniqueRecordsMap.get(key).Id,UID__c= master.BANKID+'-'+master.CITYID));
                                    BankMstr__c bankMstr = new BankMstr__c();
                                    if(master.BANKID!=null && String.isNotBlank(master.BANKID) && master.CITYID!=null && String.isNotBlank(master.CITYID)){
                                        if(bankMstrMap.containsKey(master.BANKID+'-'+master.CITYID)){
                                            bankMstr.Id = bankMstrMap.get(master.BANKID+'-'+master.CITYID).Id;
                                        }
                                        bankMstr.BankId__c = master.BANKID;
                                        if(cityMap.containsKey(master.CITYID)){
                                            bankMstr.City__c = cityMap.get(master.CITYID).Id;
                                        }
                                    }
                                    if(master.NAME!=null && String.isNotBlank(master.NAME)){
                                        bankMstr.Name = master.NAME;
                                        
                                    }
                                    masterDataUpsertMap.put(counter,bankMstr);
                                    counter++;
                                }
                            }
                        }
                        else{
                            throw new MasterDataSyncException(uniqueRecordsMap.get(key).Id,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: CITYID: ' + master.CITYID + ' not found in SFDC Master');
                        }
                    }
                    catch(MasterDataSyncException ex){
                        if(ex.recordId!=null){
                            MasterDataSync__c errorRecord = new MasterDataSync__c();
                            errorRecord.Id = ex.recordId;
                            errorRecord.IsProcessed__c=true;
                            errorRecord.SyncStatus__c='Failed';
                            errorRecord.ErrorCode__c= String.isNotBlank(ex.errorCode)? ex.errorCode:customErrorCode.get('SYNC_ERROR');
                            errorRecord.ErrorMessage__c= String.isNotBlank(ex.errorMessage)? ex.errorMessage:'Error Occurred while Data Sync';
                            masterDataSyncErrorList.add(errorRecord);
                        }
                    }
                }
                
                /*for(Integer i=0; i<records.size();i++){
                    MasterDataSync__c record = records[i];
                    if(String.isNotBlank(record.Record__c)){
                        MICRBankNameMasterWrapper responseWrapper = (MICRBankNameMasterWrapper) JSON.deserialize(record.Record__c, MICRBankNameMasterWrapper.class); 
                        if(responseWrapper!=null){
                            if(String.isNotBlank(responseWrapper.BANKID) && String.isNotBlank(responseWrapper.CITYID)){
                                externalIds.add(responseWrapper.BANKID +'-'+ responseWrapper.CITYID);
                                bankIds.add(responseWrapper.BANKID);
                                cityIds.add(responseWrapper.CITYID);
                            }
                            
                        }
                        if(!masterDataSyncUpdateMap.containsKey(i)){
                            masterDataSyncUpdateMap.put(i, new MasterDataSync__c(Id=record.Id,UID__c= (responseWrapper!=null && String.isNotBlank(responseWrapper.BANKID) && String.isNotBlank(responseWrapper.CITYID))?responseWrapper.BANKID +'-'+ responseWrapper.CITYID:''));
                        }
                        else{
                            masterDataSyncUpdateMap.get(i).UID__c=(responseWrapper!=null && String.isNotBlank(responseWrapper.BANKID) && String.isNotBlank(responseWrapper.CITYID))?responseWrapper.BANKID +'-'+ responseWrapper.CITYID:'';
                        }
                        if(!masterMap.containsKey(i)){
                            masterMap.put(i,responseWrapper);
                        }
                    }
                }*/
                system.debug(':::'+masterMap);
                /*if(!masterMap.isEmpty()){
                	for (Integer key : masterMap.keySet()) {
                        MICRBankNameMasterWrapper master = masterMap.get(key);
                        if(!masterDataUpsertMap.containsKey(key)){
                            if(master!=null){
                                BankMstr__c bankMstr = new BankMstr__c();
                                if(master.BANKID!=null && String.isNotBlank(master.BANKID) && master.CITYID!=null && String.isNotBlank(master.CITYID)){
                                    if(bankMstrMap.containsKey(master.BANKID+'-'+master.CITYID)){
                                        bankMstr.Id = bankMstrMap.get(master.BANKID).Id;
                                    }
                                    bankMstr.BankId__c = master.BANKID;
                                    if(cityMap.containsKey(master.CITYID)){
                                        bankMstr.City__c = cityMap.get(master.CITYID).Id;
                                    }
                                }
                                if(master.NAME!=null && String.isNotBlank(master.NAME)){
                                    bankMstr.Name = master.NAME;
                                    
                                }
                                masterDataUpsertMap.put(key,bankMstr);
                            }
                        }
                    }
                }*/
                if(!masterDataUpsertMap.isEmpty()){
                    System.debug('::::'+masterDataUpsertMap);
                    Schema.SObjectField externalID = BankMstr__c.Fields.Id;
                    Database.UpsertResult[] results = Database.upsert(masterDataUpsertMap.values(),externalID,false);
                    for(Integer i=0; i<results.size(); i++){
                        if(results[i].isSuccess()){
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                masterDataSyncUpdateMap.get(i).SyncStatus__c='Success';
                                masterDataSyncUpdateMap.get(i).ErrorCode__c=customErrorCode.get('SUCCESS');
                                masterDataSyncUpdateMap.get(i).ErrorMessage__c='SUCCESS: Data Sync Successful';
                            }		
                        }
                        else {
                            List<Database.Error> err = results[i].getErrors();
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                masterDataSyncUpdateMap.get(i).SyncStatus__c='Failed';
                                masterDataSyncUpdateMap.get(i).ErrorCode__c= !err.isEmpty() && customErrorCode.containsKey(String.valueOf(err[0].getStatusCode())) ? customErrorCode.get(String.ValueOf(err[0].getStatusCode())) : customErrorCode.get('SYNC_ERROR');
                                masterDataSyncUpdateMap.get(i).ErrorMessage__c= !err.isEmpty() ? err[0].getStatusCode() + ': ' + err[0].getMessage() : 'Error Occurred while Data Sync';
                            }
                        }
                    }
                }
                if(!masterDataSyncUpdateMap.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncUpdateMap.values());
                }
				if(!masterDataSyncErrorList.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncErrorList);
				}	
				if(!masterDataSyncUpdateList.isEmpty()){
					update masterDataSyncUpdateList;
				}
            }
        }
        catch(Exception ex){
            System.debug('processMICRBankNameMaster ' + ex.getMessage() + ' line ' + ex.getLineNumber());
        }
    }
    
    public static void processChargesMaster(List<MasterDataSync__c> records){
        try{
            Map<Integer,ChargeMasterWrapper> masterMap = new Map<Integer,ChargeMasterWrapper>();
            Map<Integer,MasterDataSync__c> masterDataSyncUpdateMap = new Map<Integer,MasterDataSync__c>();
            Map<Integer,MasterData__c> masterDataUpsertMap = new Map<Integer,MasterData__c>();
            Set<String> externalIds = new Set<String>();
            
            List<MasterDataSync__c> masterDataSyncErrorList = new List<MasterDataSync__c>();
			List<MasterDataSync__c> masterDataSyncUpdateList = new List<MasterDataSync__c>();
            Map<String,MasterDataSync__c> uniqueRecordsMap = new Map<String,MasterDataSync__c>();
            Map<String,Boolean> duplicateRecordMap = new Map<String,Boolean>();
            Map<String,ChargeMasterWrapper> uniqueChargeMasterMap = new Map<String,ChargeMasterWrapper>();
            
            if(!records.isEmpty()){
                for(MasterDataSync__c record : records){
                    if(String.isNotBlank(record.Record__c)){
                        ChargeMasterWrapper responseWrapper = (ChargeMasterWrapper) JSON.deserialize(record.Record__c, ChargeMasterWrapper.class);
                        if(responseWrapper!=null){
                            try{
                                if(responseWrapper.CHARGEID!=null && String.isNotBlank(responseWrapper.CHARGEID) && responseWrapper.CHARGECODEID!=null && String.isNotBlank(responseWrapper.CHARGECODEID) &&
                                  responseWrapper.CHARGEDESC!=null && String.isNotBlank(responseWrapper.CHARGEDESC)
                                  ){
                                    externalIds.add(responseWrapper.CHARGEID);
                                    if(!uniqueRecordsMap.containsKey(responseWrapper.CHARGEID) && !duplicateRecordMap.containsKey(responseWrapper.CHARGEID)){
                                        uniqueRecordsMap.put(responseWrapper.CHARGEID,record);
                                        duplicateRecordMap.put(responseWrapper.CHARGEID,true);
                                        uniqueChargeMasterMap.put(responseWrapper.CHARGEID,responseWrapper);
                                    }
                                    else{
                                        if(uniqueRecordsMap.containsKey(responseWrapper.CHARGEID)){
                                            MasterDataSync__c errorRecord = new MasterDataSync__c();
                                    		errorRecord.Id = uniqueRecordsMap.get(responseWrapper.CHARGEID).Id;
                                    		errorRecord.IsProcessed__c=true;
                                    		errorRecord.SyncStatus__c='Failed';
                                            errorRecord.ErrorCode__c= customErrorCode.get('DUPLICATE_VALUE');
                                    		errorRecord.ErrorMessage__c=  'DUPLICATE_VALUE: Duplicate external id specified: '+responseWrapper.CHARGEID;
                                    		masterDataSyncErrorList.add(errorRecord);
                                            uniqueRecordsMap.remove(responseWrapper.CHARGEID);
                                            uniqueChargeMasterMap.remove(responseWrapper.CHARGEID);
                                        }
                                        
                                        MasterDataSync__c errorRecord = new MasterDataSync__c();
                                        errorRecord.Id = record.Id;
                                        errorRecord.IsProcessed__c=true;
                                        errorRecord.SyncStatus__c='Failed';
                                        errorRecord.ErrorCode__c= customErrorCode.get('DUPLICATE_VALUE');
                                        errorRecord.ErrorMessage__c=  'DUPLICATE_VALUE: Duplicate external id specified: '+responseWrapper.CHARGEID;
                                        masterDataSyncErrorList.add(errorRecord);
                                        
                                    }  
                                      
                                }else{
                                    List<String> requiredList = new List<String>();
                                    if(responseWrapper.CHARGEID==null || String.isBlank(responseWrapper.CHARGEID)){
                                        requiredList.add('CHARGEID');
                                    }
                                    if(responseWrapper.CHARGECODEID==null || String.isBlank(responseWrapper.CHARGECODEID)){
                                        requiredList.add('CHARGECODEID');
                                    }
                                    if(responseWrapper.CHARGEDESC==null || String.isBlank(responseWrapper.CHARGEDESC)){
                                        requiredList.add('CHARGEDESC');
                                    }
                                    throw new MasterDataSyncException(record.Id,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: Required attributes are missing: [' + String.Join(requiredList,',') + ']' );
                                }
                            }
                            catch(MasterDataSyncException ex){
                                if(ex.recordId!=null){
                                    MasterDataSync__c errorRecord = new MasterDataSync__c();
                                    errorRecord.Id = ex.recordId;
                                    errorRecord.IsProcessed__c=true;
                                    errorRecord.SyncStatus__c='Failed';
                                    errorRecord.ErrorCode__c= String.isNotBlank(ex.errorCode)? ex.errorCode:customErrorCode.get('SYNC_ERROR');
                                    errorRecord.ErrorMessage__c= String.isNotBlank(ex.errorMessage)? ex.errorMessage:'Error Occurred while Data Sync';
                                    masterDataSyncErrorList.add(errorRecord);
                                }
                            }
                        }
                    }
                }
                
                Integer count=0;
                for(String key: uniqueRecordsMap.keySet()){
                    masterDataSyncUpdateMap.put(count, new MasterDataSync__c(Id=uniqueRecordsMap.get(key).Id,UID__c= key));
                    masterMap.put(count,uniqueChargeMasterMap.get(key));
                    count++;
                }
                system.debug(':::'+masterMap);
                if(!masterMap.isEmpty()){
                    Map<String,MasterData__c> masterDataMap = new Map<String,MasterData__c>();
                    for(MasterData__c data: [Select Id,FinnoneCode__c,Type__c FROM MasterData__c WHERE FinnoneCode__c IN :externalIds AND Type__c ='CashBank Account']){
                        masterDataMap.put(data.FinnoneCode__c,data);
                    }
                    for (Integer key : masterMap.keySet()) {
                        ChargeMasterWrapper master = masterMap.get(key);
                        if(!masterDataUpsertMap.containsKey(key)){
                            if(master!=null){
                                MasterData__c masterData = new MasterData__c();
                                if(master.CHARGEID!=null && String.isNotBlank(master.CHARGEID)){
                                    if(masterDataMap.containsKey(master.CHARGEID)){
                                        masterData.Id = masterDataMap.get(master.CHARGEID).Id;
                                    }
                                    else{
                                        masterData.Type__c ='Charge Master';
                                    }
                                    masterData.FinnoneCode__c =	master.CHARGEID;
                                    masterData.SalesforceCode__c = master.CHARGEID;
                                }
                                if(master.CHARGECODEID!=null && String.isNotBlank(master.CHARGECODEID)){
                                    masterData.ChargeID__c = master.CHARGECODEID;
                                }
                                if(master.CHARGEDESC!=null && String.isNotBlank(master.CHARGEDESC)){
                                    masterData.FinnoneVal__c = master.CHARGEDESC;
                                    masterData.Name = master.CHARGEDESC;
                                }
                                
                                masterDataUpsertMap.put(key,masterData);
                            }
                        }
                    }
                }
                if(!masterDataUpsertMap.isEmpty()){
                    System.debug('::::'+masterDataUpsertMap);
                    Schema.SObjectField externalID = MasterData__c.Fields.Id;
                    Database.UpsertResult[] results = Database.upsert(masterDataUpsertMap.values(),externalID,false);
                    for(Integer i=0; i<results.size(); i++){
                        if(results[i].isSuccess()){
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                    masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                    masterDataSyncUpdateMap.get(i).SyncStatus__c='Success';
                                    masterDataSyncUpdateMap.get(i).ErrorCode__c=customErrorCode.get('SUCCESS');
                                    masterDataSyncUpdateMap.get(i).ErrorMessage__c='SUCCESS: Data Sync Successful';
                            }		
                        }
                        else {
                            List<Database.Error> err = results[i].getErrors();
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                masterDataSyncUpdateMap.get(i).SyncStatus__c='Failed';
                                masterDataSyncUpdateMap.get(i).ErrorCode__c= !err.isEmpty() && customErrorCode.containsKey(String.valueOf(err[0].getStatusCode())) ? customErrorCode.get(String.ValueOf(err[0].getStatusCode())) : customErrorCode.get('SYNC_ERROR');
                                masterDataSyncUpdateMap.get(i).ErrorMessage__c= !err.isEmpty() ? err[0].getStatusCode() + ': ' + err[0].getMessage() : 'Error Occurred while Data Sync';
                            }
                        }
                        
                    }
                }
                if(!masterDataSyncUpdateMap.isEmpty()){
                    masterDataSyncUpdateList.addAll(masterDataSyncUpdateMap.values());
                }
                if(!masterDataSyncErrorList.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncErrorList);
				}	
				if(!masterDataSyncUpdateList.isEmpty()){
					update masterDataSyncUpdateList;
				}
            }
        }
        catch(Exception ex){
            System.debug('processChargesMaster ' + ex.getMessage() + ' line ' + ex.getLineNumber());
        }
    }
    
    /*public static void processInspectorMaster(List<MasterDataSync__c> records){
        try{
            Map<Integer,InspectorMasterWrapper> masterMap = new Map<Integer,InspectorMasterWrapper>();
            Map<Integer,MasterDataSync__c> masterDataSyncUpdateMap = new Map<Integer,MasterDataSync__c>();
            Map<Integer,DSABrchJn__c> masterDataUpsertMap = new Map<Integer,DSABrchJn__c>();
            Set<String> externalIds = new Set<String>();
            Set<String> refIds = new Set<String>();
            
            List<MasterDataSync__c> masterDataSyncErrorList = new List<MasterDataSync__c>();
			List<MasterDataSync__c> masterDataSyncUpdateList = new List<MasterDataSync__c>();
            Map<String,MasterDataSync__c> masterDataSyncMap = new Map<String,MasterDataSync__c>();
            Map<String,InspectorMasterWrapper> inspectorMap = new Map<String,InspectorMasterWrapper>();
            
            if(!records.isEmpty()){
                
                for(MasterDataSync__c record : records){
                    if(String.isNotBlank(record.Record__c)){
                        InspectorMasterWrapper responseWrapper = (InspectorMasterWrapper) JSON.deserialize(record.Record__c, InspectorMasterWrapper.class);
                        if(responseWrapper!=null){
                            try{
                                if(responseWrapper.INSPECTORID!=null && String.isNotBlank(responseWrapper.INSPECTORID) && responseWrapper.BROKERID!=null && String.isNotBlank(responseWrapper.BROKERID)){
                                    externalIds.add(responseWrapper.INSPECTORID);
                                    refIds.add(responseWrapper.BROKERID);
                                    masterDataSyncMap.put(record.Id,record);
									inspectorMap.put(record.Id,responseWrapper);                                      
                                    
                                }
                                else{
                                    List<String> requiredList = new List<String>();
                                    if(responseWrapper.INSPECTORID==null || String.isBlank(responseWrapper.INSPECTORID)){
                                        requiredList.add('INSPECTORID');
                                    }
                                    if(responseWrapper.BROKERID==null || String.isBlank(responseWrapper.BROKERID)){
                                        requiredList.add('BROKERID');
                                    }
                                    throw new MasterDataSyncException(record.Id,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: Required attributes are missing: [' + String.Join(requiredList,',') + ']' );
                                }
                            }
                            catch(MasterDataSyncException ex){
                                if(ex.recordId!=null){
                                    MasterDataSync__c errorRecord = new MasterDataSync__c();
                                    errorRecord.Id = ex.recordId;
                                    errorRecord.IsProcessed__c=true;
                                    errorRecord.SyncStatus__c='Failed';
                                    errorRecord.ErrorCode__c= String.isNotBlank(ex.errorCode)? ex.errorCode:customErrorCode.get('SYNC_ERROR');
                                    errorRecord.ErrorMessage__c= String.isNotBlank(ex.errorMessage)? ex.errorMessage:'Error Occurred while Data Sync';
                                    masterDataSyncErrorList.add(errorRecord);
                                }
                                
                            }
                        }
                    }
                }
                
                Map<String,Account> masterDataMap = new Map<String,Account>();
                for(Account data: [Select Id,DSAConnId__c,VCReferralId__c FROM Account WHERE  DSAConnId__c IN:refIds OR VCReferralId__c IN :refIds] ){
                    if(data.DSAConnId__c!=null){
                        masterDataMap.put(data.DSAConnId__c,data);
                    }
                    else{
                        masterDataMap.put(data.VCReferralId__c,data);
                    }
                }
                
                Integer counter=0;
                for(String key : masterDataSyncMap.keySet()){
                    try{
                        InspectorMasterWrapper master = inspectorMap.get(key);
                        if(masterDataMap.containsKey(master.BROKERID)){
                            masterDataSyncUpdateMap.put(counter, new MasterDataSync__c(Id=key,UID__c= master.BROKERID));
                            if(!masterDataUpsertMap.containsKey(counter)){
                                if(master!=null){
                                    DSABrchJn__c dsaBrchJn = new DSABrchJn__c();
                                    
                                    if(master.INSPECTORID!=null && String.isNotBlank(master.INSPECTORID)){
                                        dsaBrchJn.InspectorId__c = master.INSPECTORID;
                                    }
                                    //if(master.INSPECTORNAME!=null && String.isNotBlank(master.INSPECTORNAME)){
                                    //}
                                    if(master.BROKERID!=null && String.isNotBlank(master.BROKERID)){
                                        if(masterDataMap.containsKey(master.BROKERID)){
                                            dsaBrchJn.Account__c = masterDataMap.get(master.BROKERID).Id;
                                        }	
                                    }
                                    masterDataUpsertMap.put(counter,dsaBrchJn);
                                }
                            }
                            counter++;
                        }
                        else{
                            throw new MasterDataSyncException(key,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: SCHID: ' + master.BROKERID + 'not found in SFDC Master');
                        }
                    }
                    catch(MasterDataSyncException ex){
                        if(ex.recordId!=null){
                            MasterDataSync__c errorRecord = new MasterDataSync__c();
                            errorRecord.Id = ex.recordId;
                            errorRecord.IsProcessed__c=true;
                            errorRecord.SyncStatus__c='Failed';
                            errorRecord.ErrorCode__c= String.isNotBlank(ex.errorCode)? ex.errorCode:customErrorCode.get('SYNC_ERROR');
                            errorRecord.ErrorMessage__c= String.isNotBlank(ex.errorMessage)? ex.errorMessage:'Error Occurred while Data Sync';
                            masterDataSyncErrorList.add(errorRecord);
                        }
                    }
                    
                }
                
                system.debug(':::'+masterMap);
                
                if(!masterDataUpsertMap.isEmpty()){
                    System.debug('::::'+masterDataUpsertMap);
                    Schema.SObjectField externalID = DSABrchJn__c.Fields.InspectorId__c;
                    Database.UpsertResult[] results = Database.upsert(masterDataUpsertMap.values(),externalID,false);
                    for(Integer i=0; i<results.size(); i++){
                        if(results[i].isSuccess()){
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                    masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                    masterDataSyncUpdateMap.get(i).SyncStatus__c='Success';
                                    masterDataSyncUpdateMap.get(i).ErrorCode__c=customErrorCode.get('SUCCESS');
                                    masterDataSyncUpdateMap.get(i).ErrorMessage__c='SUCCESS: Data Sync Successful';
                            }		
                        }
                        else {
                            List<Database.Error> err = results[i].getErrors();
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                masterDataSyncUpdateMap.get(i).SyncStatus__c='Failed';
                                masterDataSyncUpdateMap.get(i).ErrorCode__c= !err.isEmpty() && customErrorCode.containsKey(String.valueOf(err[0].getStatusCode())) ? customErrorCode.get(String.ValueOf(err[0].getStatusCode())) : customErrorCode.get('SYNC_ERROR');
                                masterDataSyncUpdateMap.get(i).ErrorMessage__c= !err.isEmpty() ? err[0].getStatusCode() + ': ' + err[0].getMessage() : 'Error Occurred while Data Sync';
                            }
                        }
                        
                    }
                }
                if(!masterDataSyncUpdateMap.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncUpdateMap.values());
                }
				if(!masterDataSyncErrorList.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncErrorList);
				}	
				if(!masterDataSyncUpdateList.isEmpty()){
					update masterDataSyncUpdateList;
				}
            }
        }
        catch(Exception ex){
            System.debug(ex.getMessage() + ' line ' + ex.getLineNumber());
        }
    }*/
    public static void processInspectorMaster(List<MasterDataSync__c> records){
        try{
            Map<Integer,InspectorMasterWrapper> masterMap = new Map<Integer,InspectorMasterWrapper>();
            Map<Integer,MasterDataSync__c> masterDataSyncUpdateMap = new Map<Integer,MasterDataSync__c>();
            Map<Integer,DSABrchJn__c> masterDataUpsertMap = new Map<Integer,DSABrchJn__c>();
            Set<String> externalIds = new Set<String>();
            Set<String> refIds = new Set<String>();
            
            List<MasterDataSync__c> masterDataSyncErrorList = new List<MasterDataSync__c>();
			List<MasterDataSync__c> masterDataSyncUpdateList = new List<MasterDataSync__c>();
            Map<String,MasterDataSync__c> masterDataSyncMap = new Map<String,MasterDataSync__c>();
            Map<String,InspectorMasterWrapper> inspectorMap = new Map<String,InspectorMasterWrapper>();
            
			Map<String,String> inspectorEmployeeIDMap = new Map<String,String>();
			Map<String,String> inspectorNameMap = new Map<String,String>();
            
			if(!records.isEmpty()){
                
                for(MasterDataSync__c record : records){
                    if(String.isNotBlank(record.Record__c)){
                        InspectorMasterWrapper responseWrapper = (InspectorMasterWrapper) JSON.deserialize(record.Record__c, InspectorMasterWrapper.class);
                        if(responseWrapper!=null){
                            try{
                                if(responseWrapper.INSPECTORID!=null && String.isNotBlank(responseWrapper.INSPECTORID) && responseWrapper.BROKERID!=null && String.isNotBlank(responseWrapper.BROKERID) && responseWrapper.INSPECTORNAME!=null && String.isNotBlank(responseWrapper.INSPECTORNAME)){
                                    externalIds.add(responseWrapper.INSPECTORID);
                                    refIds.add(responseWrapper.BROKERID);
                                    masterDataSyncMap.put(record.Id,record);
									inspectorMap.put(record.Id,responseWrapper); 
									
									List<String>data =responseWrapper.INSPECTORNAME.split('-');
									if(data!=null && !data.isEmpty() && data.size()>=2){
										inspectorEmployeeIDMap.put(responseWrapper.INSPECTORID,data[0].trim());
										inspectorNameMap.put(responseWrapper.INSPECTORID,data[1].trim());
									}
                                    
                                }
                                else{
                                    List<String> requiredList = new List<String>();
                                    if(responseWrapper.INSPECTORID==null || String.isBlank(responseWrapper.INSPECTORID)){
                                        requiredList.add('INSPECTORID');
                                    }
                                    if(responseWrapper.BROKERID==null || String.isBlank(responseWrapper.BROKERID)){
                                        requiredList.add('BROKERID');
                                    }
									if(responseWrapper.INSPECTORNAME==null || String.isBlank(responseWrapper.INSPECTORNAME)){
                                        requiredList.add('INSPECTORNAME');
                                    }
                                    throw new MasterDataSyncException(record.Id,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: Required attributes are missing: [' + String.Join(requiredList,',') + ']' );
                                }
                            }
                            catch(MasterDataSyncException ex){
                                if(ex.recordId!=null){
                                    MasterDataSync__c errorRecord = new MasterDataSync__c();
                                    errorRecord.Id = ex.recordId;
                                    errorRecord.IsProcessed__c=true;
                                    errorRecord.SyncStatus__c='Failed';
                                    errorRecord.ErrorCode__c= String.isNotBlank(ex.errorCode)? ex.errorCode:customErrorCode.get('SYNC_ERROR');
                                    errorRecord.ErrorMessage__c= String.isNotBlank(ex.errorMessage)? ex.errorMessage:'Error Occurred while Data Sync';
                                    masterDataSyncErrorList.add(errorRecord);
                                }
                                
                            }
                        }
                    }
                }
                
                Map<String,Account> masterDataMap = new Map<String,Account>();
                for(Account data: [Select Id,DSAConnId__c FROM Account WHERE  DSAConnId__c IN:refIds] ){
                    if(data.DSAConnId__c!=null){
                        masterDataMap.put(data.DSAConnId__c,data);
                    }
                }
				
				Map<String,User> userMap = new Map<String,User>();
				for(User u: [Select Id,EmployeeNumber FROM User WHERE EmployeeNumber IN:inspectorEmployeeIDMap.values()]){
					userMap.put(u.EmployeeNumber,u);
				}
                
                Integer counter=0;
                for(String key : masterDataSyncMap.keySet()){
                    try{
                        InspectorMasterWrapper master = inspectorMap.get(key);
                        if(masterDataMap.containsKey(master.BROKERID)){
							if(inspectorEmployeeIDMap.containsKey(master.INSPECTORID)  && userMap.containsKey(inspectorEmployeeIDMap.get(master.INSPECTORID))){
								masterDataSyncUpdateMap.put(counter, new MasterDataSync__c(Id=key,UID__c= master.BROKERID));
								if(!masterDataUpsertMap.containsKey(counter)){
									if(master!=null){
										DSABrchJn__c dsaBrchJn = new DSABrchJn__c();
										
										if(master.INSPECTORID!=null && String.isNotBlank(master.INSPECTORID)){
											dsaBrchJn.InspectorId__c = master.INSPECTORID;
										}
										//if(master.INSPECTORNAME!=null && String.isNotBlank(master.INSPECTORNAME)){
										//}
										if(master.BROKERID!=null && String.isNotBlank(master.BROKERID)){
											if(masterDataMap.containsKey(master.BROKERID)){
												dsaBrchJn.Account__c = masterDataMap.get(master.BROKERID).Id;
											}	
										}
										dsaBrchJn.RMUsr__c = userMap.get(inspectorEmployeeIDMap.get(master.INSPECTORID)).Id;
										dsaBrchJn.IsActive__c = true;
										masterDataUpsertMap.put(counter,dsaBrchJn);
									}
								}
								counter++;
							}
							else{
								throw new MasterDataSyncException(key,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: Employee Code: ' + inspectorEmployeeIDMap.get(master.INSPECTORID) + ' not found in SFDC');
							}
                        }
                        else{
                            throw new MasterDataSyncException(key,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: BROKERID: ' + master.BROKERID + ' not found in SFDC Master');
                        }
                    }
                    catch(MasterDataSyncException ex){
                        if(ex.recordId!=null){
                            MasterDataSync__c errorRecord = new MasterDataSync__c();
                            errorRecord.Id = ex.recordId;
                            errorRecord.IsProcessed__c=true;
                            errorRecord.SyncStatus__c='Failed';
                            errorRecord.ErrorCode__c= String.isNotBlank(ex.errorCode)? ex.errorCode:customErrorCode.get('SYNC_ERROR');
                            errorRecord.ErrorMessage__c= String.isNotBlank(ex.errorMessage)? ex.errorMessage:'Error Occurred while Data Sync';
                            masterDataSyncErrorList.add(errorRecord);
                        }
                    }
                    
                }
                
                system.debug(':::'+masterMap);
                
                if(!masterDataUpsertMap.isEmpty()){
                    System.debug('::::'+masterDataUpsertMap);
                    Schema.SObjectField externalID = DSABrchJn__c.Fields.InspectorId__c;
                    Database.UpsertResult[] results = Database.upsert(masterDataUpsertMap.values(),externalID,false);
                    for(Integer i=0; i<results.size(); i++){
                        if(results[i].isSuccess()){
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                    masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                    masterDataSyncUpdateMap.get(i).SyncStatus__c='Success';
                                    masterDataSyncUpdateMap.get(i).ErrorCode__c=customErrorCode.get('SUCCESS');
                                    masterDataSyncUpdateMap.get(i).ErrorMessage__c='SUCCESS: Data Sync Successful';
                            }		
                        }
                        else {
                            List<Database.Error> err = results[i].getErrors();
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                masterDataSyncUpdateMap.get(i).SyncStatus__c='Failed';
                                masterDataSyncUpdateMap.get(i).ErrorCode__c= !err.isEmpty() && customErrorCode.containsKey(String.valueOf(err[0].getStatusCode())) ? customErrorCode.get(String.ValueOf(err[0].getStatusCode())) : customErrorCode.get('SYNC_ERROR');
                                masterDataSyncUpdateMap.get(i).ErrorMessage__c= !err.isEmpty() ? err[0].getStatusCode() + ': ' + err[0].getMessage() : 'Error Occurred while Data Sync';
                            }
                        }
                        
                    }
                }
                if(!masterDataSyncUpdateMap.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncUpdateMap.values());
                }
				if(!masterDataSyncErrorList.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncErrorList);
				}	
				if(!masterDataSyncUpdateList.isEmpty()){
					update masterDataSyncUpdateList;
				}
            }
        }
        catch(Exception ex){
            System.debug('processInspectorMaster ' + ex.getMessage() + ' line ' + ex.getLineNumber());
        }
    }
    
    public static void processConstitutionMaster(List<MasterDataSync__c> records){
        try{
            Map<Integer,ConstitutionMasterWrapper> masterMap = new Map<Integer,ConstitutionMasterWrapper>();
            Map<Integer,MasterDataSync__c> masterDataSyncUpdateMap = new Map<Integer,MasterDataSync__c>();
            Map<Integer,MasterData__c> masterDataUpsertMap = new Map<Integer,MasterData__c>();
            Set<String> externalIds = new Set<String>();
            
            List<MasterDataSync__c> masterDataSyncErrorList = new List<MasterDataSync__c>();
            List<MasterDataSync__c> masterDataSyncUpdateList = new List<MasterDataSync__c>();
            
            Map<String,MasterDataSync__c> uniqueRecordsMap = new Map<String,MasterDataSync__c>();
            Map<String,Boolean> duplicateRecordMap = new Map<String,Boolean>();
            Map<String,ConstitutionMasterWrapper> uniqueConstitutionMap = new Map<String,ConstitutionMasterWrapper>();
            
            
            if(!records.isEmpty()){
                
                for(MasterDataSync__c record : records){
                    if(String.isNotBlank(record.Record__c)){
                        ConstitutionMasterWrapper responseWrapper = (ConstitutionMasterWrapper) JSON.deserialize(record.Record__c, ConstitutionMasterWrapper.class); 
                        if(responseWrapper!=null){
                            try{
                                
                                if(responseWrapper.CONSTID!=null && String.isNotBlank(responseWrapper.CONSTID) && responseWrapper.CONSTDESC!=null && String.isNotBlank(responseWrapper.CONSTDESC)){
                                    externalIds.add(responseWrapper.CONSTID);
                                    if(!uniqueRecordsMap.containsKey(responseWrapper.CONSTID) && !duplicateRecordMap.containsKey(responseWrapper.CONSTID)){
                                        uniqueRecordsMap.put(responseWrapper.CONSTID,record);
                                        duplicateRecordMap.put(responseWrapper.CONSTID,true);
                                        uniqueConstitutionMap.put(responseWrapper.CONSTID,responseWrapper);
                                    }
                                    else{
                                        if(uniqueRecordsMap.containsKey(responseWrapper.CONSTID)){
                                            MasterDataSync__c errorRecord = new MasterDataSync__c();
                                    		errorRecord.Id = uniqueRecordsMap.get(responseWrapper.CONSTID).Id;
                                    		errorRecord.IsProcessed__c=true;
                                    		errorRecord.SyncStatus__c='Failed';
                                            errorRecord.ErrorCode__c= customErrorCode.get('DUPLICATE_VALUE');
                                    		errorRecord.ErrorMessage__c=  'DUPLICATE_VALUE: Duplicate external id specified: '+responseWrapper.CONSTID;
                                    		masterDataSyncErrorList.add(errorRecord);
                                            uniqueRecordsMap.remove(responseWrapper.CONSTID);
                                            uniqueConstitutionMap.remove(responseWrapper.CONSTID);
                                        }
                                        
                                        MasterDataSync__c errorRecord = new MasterDataSync__c();
                                        errorRecord.Id = record.Id;
                                        errorRecord.IsProcessed__c=true;
                                        errorRecord.SyncStatus__c='Failed';
                                        errorRecord.ErrorCode__c= customErrorCode.get('DUPLICATE_VALUE');
                                        errorRecord.ErrorMessage__c=  'DUPLICATE_VALUE: Duplicate external id specified: '+responseWrapper.CONSTID;
                                        masterDataSyncErrorList.add(errorRecord);
                                        
                                    }
                                }
                                else{
                                    List<String> requiredList = new List<String>();
                                    if(responseWrapper.CONSTID==null || String.isBlank(responseWrapper.CONSTID)){
                                        requiredList.add('CONSTID');
                                    }
                                    if(responseWrapper.CONSTDESC==null || String.isBlank(responseWrapper.CONSTDESC)){
                                        requiredList.add('CONSTDESC');
                                    }
                                    throw new MasterDataSyncException(record.Id,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: Required attributes are missing: [' + String.Join(requiredList,',') + ']' );
                                }
                            }
                            catch(MasterDataSyncException ex){
                                if(ex.recordId!=null){
                                    MasterDataSync__c errorRecord = new MasterDataSync__c();
                                    errorRecord.Id = ex.recordId;
                                    errorRecord.IsProcessed__c=true;
                                    errorRecord.SyncStatus__c='Failed';
                                    errorRecord.ErrorCode__c= String.isNotBlank(ex.errorCode)? ex.errorCode:customErrorCode.get('SYNC_ERROR');
                                    errorRecord.ErrorMessage__c= String.isNotBlank(ex.errorMessage)? ex.errorMessage:'Error Occurred while Data Sync';
                                    masterDataSyncErrorList.add(errorRecord);
                                }
                                
                            }
                        }
                    }
                }
                Integer count=0;
                for(String key: uniqueRecordsMap.keySet()){
                    masterDataSyncUpdateMap.put(count, new MasterDataSync__c(Id=uniqueRecordsMap.get(key).Id,UID__c= key));
                    masterMap.put(count,uniqueConstitutionMap.get(key));
                    count++;
                }
                system.debug(':::'+masterMap);
                if(!masterMap.isEmpty()){
                    
                    Map<String,MasterData__c> masterDataMap = new Map<String,MasterData__c>();
                    for(MasterData__c data: [Select Id,FinnoneCode__c,Type__c FROM MasterData__c WHERE FinnoneCode__c IN :externalIds AND Type__c ='Constitution']){
                        masterDataMap.put(data.FinnoneCode__c,data);
                    }
                    
                    for (Integer key : masterMap.keySet()) {
                        ConstitutionMasterWrapper master = masterMap.get(key);
                        if(!masterDataUpsertMap.containsKey(key)){
                            if(master!=null){
                                MasterData__c masterData = new MasterData__c();
                                if(master.CONSTID!=null && String.isNotBlank(master.CONSTID)){
                                    if(masterDataMap.containsKey(master.CONSTID)){
                                        masterData.Id = masterDataMap.get(master.CONSTID).Id;
                                    }
                                    else{
                                        masterData.Type__c ='Constitution';
                                    }
                                }
                                if(master.CONSTDESC!=null && String.isNotBlank(master.CONSTDESC)){
                                    masterData.Name = master.CONSTDESC;
                                    masterData.FinnoneVal__c = master.CONSTDESC;
                                }
                                if(master.STATUS!=null && String.isNotBlank(master.Status)){
                                    masterData.Status__c = master.STATUS;
                                }
                                masterDataUpsertMap.put(key,masterData);
                            }
                        }
                    }
                }
                if(!masterDataUpsertMap.isEmpty()){
                    System.debug('::::'+masterDataUpsertMap);
                    Schema.SObjectField externalID = MasterData__c.Fields.Id;
                    Database.UpsertResult[] results = Database.upsert(masterDataUpsertMap.values(),externalID,false);
                    for(Integer i=0; i<results.size(); i++){
                        if(results[i].isSuccess()){
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                    masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                    masterDataSyncUpdateMap.get(i).SyncStatus__c='Success';
                                    masterDataSyncUpdateMap.get(i).ErrorCode__c=customErrorCode.get('SUCCESS');
                                    masterDataSyncUpdateMap.get(i).ErrorMessage__c='SUCCESS: Data Sync Successful';
                            }		
                        }
                        else {
                            List<Database.Error> err = results[i].getErrors();
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                masterDataSyncUpdateMap.get(i).SyncStatus__c='Failed';
                                masterDataSyncUpdateMap.get(i).ErrorCode__c= !err.isEmpty() && customErrorCode.containsKey(String.valueOf(err[0].getStatusCode())) ? customErrorCode.get(String.ValueOf(err[0].getStatusCode())) : customErrorCode.get('SYNC_ERROR');
                                masterDataSyncUpdateMap.get(i).ErrorMessage__c= !err.isEmpty() ? err[0].getStatusCode() + ': ' + err[0].getMessage() : 'Error Occurred while Data Sync';
                            }
                        }
                        
                    }
                }
                if(!masterDataSyncUpdateMap.isEmpty()){
                    masterDataSyncUpdateList.addAll(masterDataSyncUpdateMap.values());
                }
                if(!masterDataSyncErrorList.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncErrorList);
				}	
				if(!masterDataSyncUpdateList.isEmpty()){
					update masterDataSyncUpdateList;
				}
                
                updateGlobalPicklistField('Constitution');
            }
        }
        catch(Exception ex){
            System.debug('processConstitutionMaster ' + ex.getMessage() + ' line ' + ex.getLineNumber());
        }
    }
    
    public static void processFIAgencyMaster(List<MasterDataSync__c> records){
        try{
            Map<Integer,FIAgencyMasterWrapper> masterMap = new Map<Integer,FIAgencyMasterWrapper>();
            Map<Integer,MasterDataSync__c> masterDataSyncUpdateMap = new Map<Integer,MasterDataSync__c>();
            Map<Integer,Account> accountUpsertMap = new Map<Integer,Account>();
            Set<String> externalIds = new Set<String>();
            Set<String> refIds = new Set<String>();
            
            List<MasterDataSync__c> masterDataSyncErrorList = new List<MasterDataSync__c>();
			List<MasterDataSync__c> masterDataSyncUpdateList = new List<MasterDataSync__c>();
            
            if(!records.isEmpty()){
                
                Integer counter=0;
				for(MasterDataSync__c record : records){
                    if(String.isNotBlank(record.Record__c)){
                        FIAgencyMasterWrapper responseWrapper = (FIAgencyMasterWrapper) JSON.deserialize(record.Record__c, FIAgencyMasterWrapper.class); 
                        if(responseWrapper!=null){
                            try{
                                if(responseWrapper.LFAM_AGENCYCODE_C!=null && String.isNotBlank(responseWrapper.LFAM_AGENCYCODE_C) && responseWrapper.LFAM_AGENCYNAME_C!=null && String.isNotBlank(responseWrapper.LFAM_AGENCYNAME_C)){
                                    externalIds.add(responseWrapper.LFAM_AGENCYCODE_C);
                                    if(String.isNotBlank(responseWrapper.BRANCHID)){
                                        refIds.add(responseWrapper.BRANCHID);
                                    }
                                    if(!masterDataSyncUpdateMap.containsKey(counter)){
                                        masterDataSyncUpdateMap.put(counter, new MasterDataSync__c(Id=record.Id,UID__c= (responseWrapper!=null && String.isNotBlank(responseWrapper.LFAM_AGENCYCODE_C))?responseWrapper.LFAM_AGENCYCODE_C:''));
                                        masterMap.put(counter,responseWrapper);
                                        counter++;
                                    }
                                    
                                }
                                else{
                                    List<String> requiredList = new List<String>();
                                    if(responseWrapper.LFAM_AGENCYCODE_C==null || String.isBlank(responseWrapper.LFAM_AGENCYCODE_C)){
                                        requiredList.add('LFAM_AGENCYCODE_C');
                                    }
                                    if(responseWrapper.LFAM_AGENCYNAME_C==null || String.isBlank(responseWrapper.LFAM_AGENCYNAME_C)){
                                        requiredList.add('LFAM_AGENCYNAME_C');
                                    }
                                    throw new MasterDataSyncException(record.Id,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: Required attributes are missing: [' + String.Join(requiredList,',') + ']' );
                                }
                            }
                            catch(MasterDataSyncException ex){
                                if(ex.recordId!=null){
                                    MasterDataSync__c errorRecord = new MasterDataSync__c();
                                    errorRecord.Id = ex.recordId;
                                    errorRecord.IsProcessed__c=true;
                                    errorRecord.SyncStatus__c='Failed';
                                    errorRecord.ErrorCode__c= String.isNotBlank(ex.errorCode)? ex.errorCode:customErrorCode.get('SYNC_ERROR');
                                    errorRecord.ErrorMessage__c= String.isNotBlank(ex.errorMessage)? ex.errorMessage:'Error Occurred while Data Sync';
                                    masterDataSyncErrorList.add(errorRecord);
                                }
                                
                            }
                        }
                    }
                }
                
                if(!masterMap.isEmpty()){
                    Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency').getRecordTypeId();
                    //Map<String,Account> accountMap = new Map<String,Account>();
                    Map<String,BankBrchMstr__c> bankBrchMstrMap = new Map<String,BankBrchMstr__c>();
                    //for(Account acc: [Select Id,AgencyCode__c FROM Account WHERE AgencyCode__c IN :externalIds AND RecordTypeID=:recordTypeId]){
                    //    accountMap.put(acc.AgencyCode__c,acc);
                    //}
                    for(BankBrchMstr__c bankBrch : [Select Id,OffcCode__c from BankBrchMstr__c WHERE OffcCode__c IN: refIds]){
                        bankBrchMstrMap.put(bankBrch.OffcCode__c,bankBrch);
                    }
                    
                    for (Integer key : masterMap.keySet()) {
                        FIAgencyMasterWrapper master = masterMap.get(key);
                        if(!accountUpsertMap.containsKey(key)){
                            if(master!=null){
                                Account acc = new Account();
                                if(master.LFAM_AGENCYCODE_C!=null && String.isNotBlank(master.LFAM_AGENCYCODE_C)){
                                    //if(accountMap.containsKey(master.LFAM_AGENCYCODE_C)){
                                        //acc.Id = accountMap.get(master.LFAM_AGENCYCODE_C).Id;
                                    //}
                                    //else{
                                        
                                    //}
                                    acc.RecordTypeId = recordTypeId;
                                    acc.AgencyCode__c = master.LFAM_AGENCYCODE_C;
                                    if(master.LFAM_AGENCYNAME_C!=null && String.isNotBlank(master.LFAM_AGENCYNAME_C)){
                                        acc.Name = master.LFAM_AGENCYNAME_C;
                                    }
                                    if(master.LFABPMM_PRODCODE_C!=null && String.isNotBlank(master.LFABPMM_PRODCODE_C)){
                                        acc.Product__c = master.LFABPMM_PRODCODE_C=='LAP'? 'Small Ticket LAP': 'Home Loan';
                                    }
                                    if(master.BRANCHID!=null && String.isNotBlank(master.BRANCHID)){
                                        if(bankBrchMstrMap.containsKey(master.BRANCHID)){
                                            acc.Branch__c = bankBrchMstrMap.get(master.BRANCHID).Id;
                                        }
                                    }
                                }
                                accountUpsertMap.put(key,acc);
                            }
                        }
                    }
                }
                if(!accountUpsertMap.isEmpty()){
                    System.debug('::::'+accountUpsertMap);
                    Schema.SObjectField externalID = Account.Fields.AgencyCode__c;
                    Database.UpsertResult[] results = Database.upsert(accountUpsertMap.values(),externalID,false);
                    for(Integer i=0; i<results.size(); i++){
                        if(results[i].isSuccess()){
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                    masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                    masterDataSyncUpdateMap.get(i).SyncStatus__c='Success';
                                    masterDataSyncUpdateMap.get(i).ErrorCode__c=customErrorCode.get('SUCCESS');
                                    masterDataSyncUpdateMap.get(i).ErrorMessage__c='SUCCESS: Data Sync Successful';
                            }		
                        }
                        else {
                            List<Database.Error> err = results[i].getErrors();
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                masterDataSyncUpdateMap.get(i).SyncStatus__c='Failed';
                                masterDataSyncUpdateMap.get(i).ErrorCode__c= !err.isEmpty() && customErrorCode.containsKey(String.valueOf(err[0].getStatusCode())) ? customErrorCode.get(String.ValueOf(err[0].getStatusCode())) : customErrorCode.get('SYNC_ERROR');
                                masterDataSyncUpdateMap.get(i).ErrorMessage__c= !err.isEmpty() ? err[0].getStatusCode() + ': ' + err[0].getMessage() : 'Error Occurred while Data Sync';
                            }
                        }
                        
                    }
                }
                if(!masterDataSyncUpdateMap.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncUpdateMap.values());
                    
                }
				if(!masterDataSyncErrorList.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncErrorList);
				}	
				if(!masterDataSyncUpdateList.isEmpty()){
					update masterDataSyncUpdateList;
				}
            }
        }
        catch(Exception ex){
            System.debug('processFIAgencyMaster ' + ex.getMessage() + ' line ' + ex.getLineNumber());
        }
    }
    
    public static void processRCUAgencyMaster(List<MasterDataSync__c> records){
        try{
            Map<Integer,RCUAgencyMasterWrapper> masterMap = new Map<Integer,RCUAgencyMasterWrapper>();
            Map<Integer,MasterDataSync__c> masterDataSyncUpdateMap = new Map<Integer,MasterDataSync__c>();
            Map<Integer,Account> accountUpsertMap = new Map<Integer,Account>();
            Set<String> externalIds = new Set<String>();
            Set<String> refIds = new Set<String>();
            
            List<MasterDataSync__c> masterDataSyncErrorList = new List<MasterDataSync__c>();
			List<MasterDataSync__c> masterDataSyncUpdateList = new List<MasterDataSync__c>();
            
            if(!records.isEmpty()){
                
                Integer counter=0;
				for(MasterDataSync__c record : records){
                    if(String.isNotBlank(record.Record__c)){
                        RCUAgencyMasterWrapper responseWrapper = (RCUAgencyMasterWrapper) JSON.deserialize(record.Record__c, RCUAgencyMasterWrapper.class); 
                        if(responseWrapper!=null){
                            try{
                                if(responseWrapper.LFAM_AGENCYCODE_C!=null && String.isNotBlank(responseWrapper.LFAM_AGENCYCODE_C) && responseWrapper.LFAM_AGENCYNAME_C!=null && String.isNotBlank(responseWrapper.LFAM_AGENCYNAME_C)){
                                    externalIds.add(responseWrapper.LFAM_AGENCYCODE_C);
                                    if(String.isNotBlank(responseWrapper.BRANCHID)){
                                        refIds.add(responseWrapper.BRANCHID);
                                    }
                                    if(!masterDataSyncUpdateMap.containsKey(counter)){
                                        masterDataSyncUpdateMap.put(counter, new MasterDataSync__c(Id=record.Id,UID__c= (responseWrapper!=null && String.isNotBlank(responseWrapper.LFAM_AGENCYCODE_C))?responseWrapper.LFAM_AGENCYCODE_C:''));
                                        masterMap.put(counter,responseWrapper);
                                        counter++;
                                    }
                                    
                                }
                                else{
                                    List<String> requiredList = new List<String>();
                                    if(responseWrapper.LFAM_AGENCYCODE_C==null || String.isBlank(responseWrapper.LFAM_AGENCYCODE_C)){
                                        requiredList.add('LFAM_AGENCYCODE_C');
                                    }
                                    if(responseWrapper.LFAM_AGENCYNAME_C==null || String.isBlank(responseWrapper.LFAM_AGENCYNAME_C)){
                                        requiredList.add('LFAM_AGENCYNAME_C');
                                    }
                                    throw new MasterDataSyncException(record.Id,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: Required attributes are missing: [' + String.Join(requiredList,',') + ']' );
                                }
                            }
                            catch(MasterDataSyncException ex){
                                if(ex.recordId!=null){
                                    MasterDataSync__c errorRecord = new MasterDataSync__c();
                                    errorRecord.Id = ex.recordId;
                                    errorRecord.IsProcessed__c=true;
                                    errorRecord.SyncStatus__c='Failed';
                                    errorRecord.ErrorCode__c= String.isNotBlank(ex.errorCode)? ex.errorCode:customErrorCode.get('SYNC_ERROR');
                                    errorRecord.ErrorMessage__c= String.isNotBlank(ex.errorMessage)? ex.errorMessage:'Error Occurred while Data Sync';
                                    masterDataSyncErrorList.add(errorRecord);
                                }
                                
                            }
                        }
                    }
                }
                
                if(!masterMap.isEmpty()){
                    Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency').getRecordTypeId();
                    //Map<String,Account> accountMap = new Map<String,Account>();
                    Map<String,BankBrchMstr__c> bankBrchMstrMap = new Map<String,BankBrchMstr__c>();
                    //for(Account acc: [Select Id,AgencyCode__c FROM Account WHERE AgencyCode__c IN :externalIds AND RecordTypeID=:recordTypeId]){
                    //    accountMap.put(acc.AgencyCode__c,acc);
                    //}
                    for(BankBrchMstr__c bankBrch : [Select Id,OffcCode__c from BankBrchMstr__c WHERE OffcCode__c IN: refIds]){
                        bankBrchMstrMap.put(bankBrch.OffcCode__c,bankBrch);
                    }
                    
                    for (Integer key : masterMap.keySet()) {
                        RCUAgencyMasterWrapper master = masterMap.get(key);
                        if(!accountUpsertMap.containsKey(key)){
                            if(master!=null){
                                Account acc = new Account();
                                if(master.LFAM_AGENCYCODE_C!=null && String.isNotBlank(master.LFAM_AGENCYCODE_C)){
                                    //if(accountMap.containsKey(master.LFAM_AGENCYCODE_C)){
                                        //acc.Id = accountMap.get(master.LFAM_AGENCYCODE_C).Id;
                                    //}
                                    //else{
                                        
                                    //}
                                    acc.RecordTypeId = recordTypeId;
                                    acc.AgencyCode__c = master.LFAM_AGENCYCODE_C;
                                    if(master.LFAM_AGENCYNAME_C!=null && String.isNotBlank(master.LFAM_AGENCYNAME_C)){
                                        acc.Name = master.LFAM_AGENCYNAME_C;
                                    }
                                    if(master.LFABPMM_PRODCODE_C!=null && String.isNotBlank(master.LFABPMM_PRODCODE_C)){
                                        acc.Product__c = master.LFABPMM_PRODCODE_C=='LAP'? 'Small Ticket LAP': 'Home Loan';
                                    }
                                    if(master.BRANCHID!=null && String.isNotBlank(master.BRANCHID)){
                                        if(bankBrchMstrMap.containsKey(master.BRANCHID)){
                                            acc.Branch__c = bankBrchMstrMap.get(master.BRANCHID).Id;
                                        }
                                    }
                                }
                                accountUpsertMap.put(key,acc);
                            }
                        }
                    }
                }
                if(!accountUpsertMap.isEmpty()){
                    System.debug('::::'+accountUpsertMap);
                    Schema.SObjectField externalID = Account.Fields.AgencyCode__c;
                    Database.UpsertResult[] results = Database.upsert(accountUpsertMap.values(),externalID,false);
                    for(Integer i=0; i<results.size(); i++){
                        if(results[i].isSuccess()){
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                    masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                    masterDataSyncUpdateMap.get(i).SyncStatus__c='Success';
                                    masterDataSyncUpdateMap.get(i).ErrorCode__c=customErrorCode.get('SUCCESS');
                                    masterDataSyncUpdateMap.get(i).ErrorMessage__c='SUCCESS: Data Sync Successful';
                            }		
                        }
                        else {
                            List<Database.Error> err = results[i].getErrors();
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                masterDataSyncUpdateMap.get(i).SyncStatus__c='Failed';
                                masterDataSyncUpdateMap.get(i).ErrorCode__c= !err.isEmpty() && customErrorCode.containsKey(String.valueOf(err[0].getStatusCode())) ? customErrorCode.get(String.ValueOf(err[0].getStatusCode())) : customErrorCode.get('SYNC_ERROR');
                                masterDataSyncUpdateMap.get(i).ErrorMessage__c= !err.isEmpty() ? err[0].getStatusCode() + ': ' + err[0].getMessage() : 'Error Occurred while Data Sync';
                            }
                        }
                        
                    }
                }
                if(!masterDataSyncUpdateMap.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncUpdateMap.values());
                }
				if(!masterDataSyncErrorList.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncErrorList);
				}	
				if(!masterDataSyncUpdateList.isEmpty()){
					update masterDataSyncUpdateList;
				}
            }
        }
        catch(Exception ex){
            System.debug('processRCUAgencyMaster ' + ex.getMessage() + ' line ' + ex.getLineNumber());
        }
    }
    
    public static void processMICRMaster(List<MasterDataSync__c> records){
        try{
            Map<Integer,MICRMasterWrapper> masterMap = new Map<Integer,MICRMasterWrapper>();
            Map<Integer,MasterDataSync__c> masterDataSyncUpdateMap = new Map<Integer,MasterDataSync__c>();
            Map<Integer,MICRCodeMstr__c> masterDataUpsertMap = new Map<Integer,MICRCodeMstr__c>();
            Set<String> externalIds = new Set<String>();
            Set<String> bankIds = new Set<String>();
            Set<String> cityIds = new Set<String>();
            Map<String,CityInstrument__c> cityMap = new Map<String,CityInstrument__c>();
            Map<String,BankMstr__c> bankMap = new Map<String,BankMstr__c>();
                
            List<MasterDataSync__c> masterDataSyncErrorList = new List<MasterDataSync__c>();
            List<MasterDataSync__c> masterDataSyncUpdateList = new List<MasterDataSync__c>();
            Map<String,MasterDataSync__c> masterDataSyncMap = new Map<String,MasterDataSync__c>();
            Map<String,MICRMasterWrapper> MICRMap = new Map<String,MICRMasterWrapper>();    
            
            if(!records.isEmpty()){
                
                for(MasterDataSync__c record : records){
                    MICRMasterWrapper responseWrapper = (MICRMasterWrapper) JSON.deserialize(record.Record__c, MICRMasterWrapper.class);
                    if(responseWrapper!=null){
                        try{
                         
                            if(responseWrapper.MICRCODE!=null && String.isNotBlank(responseWrapper.MICRCODE) && responseWrapper.BANKID!=null && String.isNotBlank(responseWrapper.BANKID) && responseWrapper.CITYID!=null && String.isNotBlank(responseWrapper.CITYID)){
                                externalIds.add(responseWrapper.MICRCODE);
                                bankIds.add(responseWrapper.BANKID);
                                cityIds.add(responseWrapper.CITYID);
                                masterDataSyncMap.put(record.Id,record);
								MICRMap.put(record.Id,responseWrapper);                                      
                            }
                            else{
                                List<String> requiredList = new List<String>();
                                if(responseWrapper.MICRCODE==null || String.isBlank(responseWrapper.MICRCODE)){
                                    requiredList.add('MICRCODE');
                                }
                                if(responseWrapper.BANKID==null || String.isBlank(responseWrapper.BANKID)){
                                    requiredList.add('BANKID');
                                }
                                if(responseWrapper.CITYID==null || String.isBlank(responseWrapper.CITYID)){
                                    requiredList.add('CITYID');
                                }
                                throw new MasterDataSyncException(record.Id,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: Required attributes are missing: [' + String.Join(requiredList,',') + ']' );
                            }
                        }
                        catch(MasterDataSyncException ex){
                            if(ex.recordId!=null){
                                MasterDataSync__c errorRecord = new MasterDataSync__c();
                                errorRecord.Id = ex.recordId;
                                errorRecord.IsProcessed__c=true;
                                errorRecord.SyncStatus__c='Failed';
                                errorRecord.ErrorCode__c= String.isNotBlank(ex.errorCode)? ex.errorCode:customErrorCode.get('SYNC_ERROR');
                                errorRecord.ErrorMessage__c= String.isNotBlank(ex.errorMessage)? ex.errorMessage:'Error Occurred while Data Sync';
                                masterDataSyncErrorList.add(errorRecord);
                            }
                            
                        }
                    }
                }
                
                
                for(CityInstrument__c data: [Select Id,CityId__c FROM CityInstrument__c WHERE  CityId__c IN:cityIds] ){
                    cityMap.put(data.CityId__c,data);
                }
                for(BankMstr__c data: [Select Id,BankId__c FROM BankMstr__c WHERE  BankId__c IN:bankIds] ){
                    bankMap.put(data.BankId__c,data);
                }
                
                Integer counter=0;
                for(String key : masterDataSyncMap.keySet()){
                    try{
                        MICRMasterWrapper master = MICRMap.get(key);
                        if(bankMap.containsKey(master.BANKID) && cityMap.containsKey(master.CITYID)){
                            masterDataSyncUpdateMap.put(counter, new MasterDataSync__c(Id=key,UID__c= master.MICRCODE));
                            if(master!=null){
                                MICRCodeMstr__c micrMstr = new MICRCodeMstr__c();
                                if(master.CITYID!=null && String.isNotBlank(master.CITYID)){
                                    if(cityMap.containsKey(master.CITYID)){
                                        micrMstr.City__c = cityMap.get(master.CITYID).Id;
                                    }
                                }
                                if(master.BANKID!=null && String.isNotBlank(master.BANKID)){
                                    if(bankMap.containsKey(master.BANKID)){
                                        micrMstr.Bank__c = bankMap.get(master.BANKID).Id;
                                    }
                                }
                                if(master.BANKBRANCHID!=null && String.isNotBlank(master.BANKBRANCHID)){
                                    micrMstr.BanckBrchId__c = master.BANKBRANCHID;
                                }
                                if(master.NAME!=null && String.isNotBlank(master.NAME)){
                                    micrMstr.BrchName__c = master.NAME;
                                }
                                if(master.MICRCODE!=null && String.isNotBlank(master.MICRCODE)){
                                    micrMstr.MICRCode__c = master.MICRCODE;
                                }
                                if(master.LSO_OFFICE_IFS_C!=null && String.isNotBlank(master.LSO_OFFICE_IFS_C)){
                                    micrMstr.IFSCCode__c = master.LSO_OFFICE_IFS_C;
                                }
                                masterDataUpsertMap.put(counter,micrMstr);
                            }
                            counter++;
                        }
                        else{
                            if(!cityMap.containsKey(master.CITYID) && !bankMap.containsKey(master.BANKID)){
                                throw new MasterDataSyncException(key,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: CITYID: ' + master.CITYID + ' and BANKID: '+ master.BANKID + ' not found in SFDC Master');
                            }else if(!cityMap.containsKey(master.CITYID)){
                                throw new MasterDataSyncException(key,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: CITYID: ' + master.CITYID + ' not found in SFDC Master');
                            }
                            else if(!bankMap.containsKey(master.BANKID)){
                                throw new MasterDataSyncException(key,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: BANKID: ' + master.BANKID + ' not found in SFDC Master');
                            }
                        }
                        
                    }
                    catch(MasterDataSyncException ex){
                        if(ex.recordId!=null){
                            MasterDataSync__c errorRecord = new MasterDataSync__c();
                            errorRecord.Id = ex.recordId;
                            errorRecord.IsProcessed__c=true;
                            errorRecord.SyncStatus__c='Failed';
                            errorRecord.ErrorCode__c= String.isNotBlank(ex.errorCode)? ex.errorCode:customErrorCode.get('SYNC_ERROR');
                            errorRecord.ErrorMessage__c= String.isNotBlank(ex.errorMessage)? ex.errorMessage:'Error Occurred while Data Sync';
                            masterDataSyncErrorList.add(errorRecord);
                        }
                    }
                }
                system.debug(':::'+masterMap);
                
                if(!masterDataUpsertMap.isEmpty()){
                    System.debug('::::'+masterDataUpsertMap);
                    Schema.SObjectField externalID = MICRCodeMstr__c.Fields.MICRCode__c;
                    Database.UpsertResult[] results = Database.upsert(masterDataUpsertMap.values(),externalID,false);
                    for(Integer i=0; i<results.size(); i++){
                        if(results[i].isSuccess()){
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                    masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                    masterDataSyncUpdateMap.get(i).SyncStatus__c='Success';
                                    masterDataSyncUpdateMap.get(i).ErrorCode__c=customErrorCode.get('SUCCESS');
                                    masterDataSyncUpdateMap.get(i).ErrorMessage__c='SUCCESS: Data Sync Successful';
                            }		
                        }
                        else {
                            List<Database.Error> err = results[i].getErrors();
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                masterDataSyncUpdateMap.get(i).SyncStatus__c='Failed';
                                masterDataSyncUpdateMap.get(i).ErrorCode__c= !err.isEmpty() && customErrorCode.containsKey(String.valueOf(err[0].getStatusCode())) ? customErrorCode.get(String.ValueOf(err[0].getStatusCode())) : customErrorCode.get('SYNC_ERROR');
                                masterDataSyncUpdateMap.get(i).ErrorMessage__c= !err.isEmpty() ? err[0].getStatusCode() + ': ' + err[0].getMessage() : 'Error Occurred while Data Sync';
                            }
                        }
                        
                    }
                }
                if(!masterDataSyncUpdateMap.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncUpdateMap.values());
                }
				if(!masterDataSyncErrorList.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncErrorList);
				}	
				if(!masterDataSyncUpdateList.isEmpty()){
					update masterDataSyncUpdateList;
				}
            }
        }
        catch(Exception ex){
            System.debug('processMICRMaster ' + ex.getMessage() + ' line ' + ex.getLineNumber());
        }
    }
    
    public static void processCityMaster(List<MasterDataSync__c> records){
        try{
            Map<Integer,CityMasterWrapper> masterMap = new Map<Integer,CityMasterWrapper>();
            Map<Integer,MasterDataSync__c> masterDataSyncUpdateMap = new Map<Integer,MasterDataSync__c>();
            Map<Integer,LocMstr__c> locMstrUpsertMap = new Map<Integer,LocMstr__c>();
            Set<String> externalIds = new Set<String>();
            
            List<MasterDataSync__c> masterDataSyncErrorList = new List<MasterDataSync__c>();
			List<MasterDataSync__c> masterDataSyncUpdateList = new List<MasterDataSync__c>();
            
            
            if(!records.isEmpty()){
                
                Integer counter=0;
				for(MasterDataSync__c record : records){
                    if(String.isNotBlank(record.Record__c)){
                        CityMasterWrapper responseWrapper = (CityMasterWrapper) JSON.deserialize(record.Record__c, CityMasterWrapper.class); 
                        if(responseWrapper!=null){
                            try{
                                if(responseWrapper.LMC_CITYID_C!=null && String.isNotBlank(responseWrapper.LMC_CITYID_C) && responseWrapper.LMC_CITYNAME_C!=null && String.isNotBlank(responseWrapper.LMC_CITYNAME_C) && 
								   responseWrapper.STATEID!=null && String.isNotBlank(responseWrapper.STATEID) && responseWrapper.STATEDESC!=null && String.isNotBlank(responseWrapper.STATEDESC)){
                                    externalIds.add(responseWrapper.LMC_CITYID_C);
                                    if(!masterDataSyncUpdateMap.containsKey(counter)){
                                        masterDataSyncUpdateMap.put(counter, new MasterDataSync__c(Id=record.Id,UID__c= (responseWrapper!=null && String.isNotBlank(responseWrapper.LMC_CITYID_C))?responseWrapper.LMC_CITYID_C:''));
                                        masterMap.put(counter,responseWrapper);
                                        counter++;
                                    }
                                    
                                }
                                else{
                                    List<String> requiredList = new List<String>();
                                    if(responseWrapper.LMC_CITYID_C==null || String.isBlank(responseWrapper.LMC_CITYID_C)){
                                        requiredList.add('LMC_CITYID_C');
                                    }
									if(responseWrapper.LMC_CITYNAME_C==null || String.isBlank(responseWrapper.LMC_CITYNAME_C)){
                                        requiredList.add('LMC_CITYNAME_C');
                                    }
									if(responseWrapper.STATEID==null || String.isBlank(responseWrapper.STATEID)){
                                        requiredList.add('STATEID');
                                    }
									if(responseWrapper.STATEDESC==null || String.isBlank(responseWrapper.STATEDESC)){
                                        requiredList.add('STATEDESC');
                                    }
                                    throw new MasterDataSyncException(record.Id,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: Required attributes are missing: [' + String.Join(requiredList,',') + ']' );
                                }
                            }
                            catch(MasterDataSyncException ex){
                                if(ex.recordId!=null){
                                    MasterDataSync__c errorRecord = new MasterDataSync__c();
                                    errorRecord.Id = ex.recordId;
                                    errorRecord.IsProcessed__c=true;
                                    errorRecord.SyncStatus__c='Failed';
                                    errorRecord.ErrorCode__c= String.isNotBlank(ex.errorCode)? ex.errorCode:customErrorCode.get('SYNC_ERROR');
                                    errorRecord.ErrorMessage__c= String.isNotBlank(ex.errorMessage)? ex.errorMessage:'Error Occurred while Data Sync';
                                    masterDataSyncErrorList.add(errorRecord);
                                }
                                
                            }
                        }
                    }
                }
                
                if(!masterMap.isEmpty()){
                    
                    for (Integer key : masterMap.keySet()) {
                        CityMasterWrapper master = masterMap.get(key);
                        if(!locMstrUpsertMap.containsKey(key)){
                            if(master!=null){
                                if(master.LMC_CITYID_C!=null && String.isNotBlank(master.LMC_CITYID_C)){
                                    LocMstr__c loc = new LocMstr__c();
                                    if(master.LMC_CITYID_C!=null && String.isNotBlank(master.LMC_CITYID_C)){
                                        loc.CityId__c = master.LMC_CITYID_C;
                                    }
                                    if(master.LMC_CITYNAME_C!=null && String.isNotBlank(master.LMC_CITYNAME_C)){
                                        loc.City__c = master.LMC_CITYNAME_C;
                                    }
                                    if(master.STATEID!=null && String.isNotBlank(master.STATEID)){
                                        loc.StateId__c = master.STATEID;
                                    }
                                    if(master.GSTSTATECODE!=null && String.isNotBlank(master.GSTSTATECODE)){
                                        loc.StateGSTId__c = master.GSTSTATECODE;
                                    }
                                    if(master.STATEDESC!=null && String.isNotBlank(master.STATEDESC)){
                                        loc.State__c = master.STATEDESC;
                                    }
                                    locMstrUpsertMap.put(key,loc);
                                }
                                
                            }
                        }
                    }
                }
                if(!locMstrUpsertMap.isEmpty()){
                    Schema.SObjectField externalID = LocMstr__c.Fields.CityId__c;
                    Database.UpsertResult[] results = Database.upsert(locMstrUpsertMap.values(),externalID,false);
                    for(Integer i=0; i<results.size(); i++){
                        if(results[i].isSuccess()){
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                    masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                    masterDataSyncUpdateMap.get(i).SyncStatus__c='Success';
                                    masterDataSyncUpdateMap.get(i).ErrorCode__c=customErrorCode.get('SUCCESS');
                                    masterDataSyncUpdateMap.get(i).ErrorMessage__c='SUCCESS: Data Sync Successful';
                            }		
                        }
                        else {
                            List<Database.Error> err = results[i].getErrors();
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                masterDataSyncUpdateMap.get(i).SyncStatus__c='Failed';
                                masterDataSyncUpdateMap.get(i).ErrorCode__c= !err.isEmpty() && customErrorCode.containsKey(String.valueOf(err[0].getStatusCode())) ? customErrorCode.get(String.ValueOf(err[0].getStatusCode())) : customErrorCode.get('SYNC_ERROR');
                                masterDataSyncUpdateMap.get(i).ErrorMessage__c= !err.isEmpty() ? err[0].getStatusCode() + ': ' + err[0].getMessage() : 'Error Occurred while Data Sync';
                            }
                        }
                        
                    }
                }
                if(!masterDataSyncUpdateMap.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncUpdateMap.values());
                    
                }
				if(!masterDataSyncErrorList.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncErrorList);
				}	
				if(!masterDataSyncUpdateList.isEmpty()){
					update masterDataSyncUpdateList;
				}
            }
        }   
        catch(Exception ex){
            System.debug('processCityMaster' + ex.getMessage() + ' line ' + ex.getLineNumber());
        }
    }
    
    public static void processCityPincodeMapping(List<MasterDataSync__c> records){
        try{
            
            Map<Integer,MasterDataSync__c> masterDataSyncUpdateMap = new Map<Integer,MasterDataSync__c>();
            Map<Integer,PincodeMstr__c> pincodeUpsertMap = new Map<Integer,PincodeMstr__c>();
            Set<String> externalIds = new Set<String>();
            Set<String> refIds = new Set<String>();
            Map<String,LocMstr__c> locMstrMap = new Map<String,LocMstr__c>();
            
            List<MasterDataSync__c> masterDataSyncErrorList = new List<MasterDataSync__c>();
			List<MasterDataSync__c> masterDataSyncUpdateList = new List<MasterDataSync__c>();
            Map<String,MasterDataSync__c> masterDataSyncMap = new Map<String,MasterDataSync__c>();
            Map<String,CityPincodeMappingWrapper> cityPincodeMap = new Map<String,CityPincodeMappingWrapper>();
            
            if(!records.isEmpty()){
                
                for(MasterDataSync__c record : records){
					if(String.isNotBlank(record.Record__c)){
						
						CityPincodeMappingWrapper responseWrapper = (CityPincodeMappingWrapper) JSON.deserialize(record.Record__c, CityPincodeMappingWrapper.class); 
                        if(responseWrapper!=null){
                            try{
                                if(responseWrapper.ZIPID!=null && String.isNotBlank(responseWrapper.ZIPID) && responseWrapper.PINCODE!=null && String.isNotBlank(responseWrapper.PINCODE) &&
                                  responseWrapper.CITYID!=null && String.isNotBlank(responseWrapper.CITYID) 
                                  ){
                                    externalIds.add(responseWrapper.ZIPID);
									refIds.add(responseWrapper.CITYID);
									masterDataSyncMap.put(record.Id,record);
									cityPincodeMap.put(record.Id,responseWrapper);                                      
                                }
                                else{
                                    List<String> requiredList = new List<String>();
                                    if(responseWrapper.ZIPID==null || String.isBlank(responseWrapper.ZIPID)){
                                        requiredList.add('ZIPID');
                                    }
									if(responseWrapper.PINCODE==null || String.isBlank(responseWrapper.PINCODE)){
                                        requiredList.add('PINCODE');
                                    }
                                    if(responseWrapper.CITYID==null || String.isBlank(responseWrapper.CITYID)){
                                        requiredList.add('CITYID');
                                    }
                                    throw new MasterDataSyncException(record.Id,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: Required attributes are missing: [' + String.Join(requiredList,',') + ']' );
                                }
                            }
                            catch(MasterDataSyncException ex){
                                if(ex.recordId!=null){
                                    MasterDataSync__c errorRecord = new MasterDataSync__c();
                                    errorRecord.Id = ex.recordId;
                                    errorRecord.IsProcessed__c=true;
                                    errorRecord.SyncStatus__c='Failed';
                                    errorRecord.ErrorCode__c= String.isNotBlank(ex.errorCode)? ex.errorCode:customErrorCode.get('SYNC_ERROR');
                                    errorRecord.ErrorMessage__c= String.isNotBlank(ex.errorMessage)? ex.errorMessage:'Error Occurred while Data Sync';
                                    masterDataSyncErrorList.add(errorRecord);
                                }
                                
                            }
                        }
                    }
                }
                
                for(LocMstr__c loc : [SELECT Id, CityId__c, City__c, StateGSTId__c, StateId__c, State__c FROM LocMstr__c WHERE CityId__c IN:refIds] ){
                    locMstrMap.put(loc.CityId__c,loc);
                }
                
                Integer counter=0;
                for(String key : masterDataSyncMap.keySet()){
                    try{
                        CityPincodeMappingWrapper pincodeMaster = cityPincodeMap.get(key);
                        if(locMstrMap.containsKey(pincodeMaster.CITYID)){
                            masterDataSyncUpdateMap.put(counter, new MasterDataSync__c(Id=key,UID__c= pincodeMaster.ZIPID));
                            
							if(!pincodeUpsertMap.containsKey(counter)){
                                if(pincodeMaster!=null){
                                    PincodeMstr__c pincode = new PincodeMstr__c();
                                    
                                    if(pincodeMaster.ZIPID!=null && String.isNotBlank(pincodeMaster.ZIPID)){
                                        pincode.ZipId__c = pincodeMaster.ZIPID;
                                    }
                                    if(pincodeMaster.PINCODE!=null && String.isNotBlank(pincodeMaster.PINCODE)){
                                        pincode.PIN__c = pincodeMaster.PINCODE;
                                        pincode.Name = pincodeMaster.PINCODE;
                                    }
                                    if(pincodeMaster.CITYID!=null && String.isNotBlank(pincodeMaster.CITYID)){
                                        if(locMstrMap.containsKey(pincodeMaster.CITYID)){
                                            pincode.City__c = locMstrMap.get(pincodeMaster.CITYID).Id;
                                        }
                                        
                                    }
                                    pincodeUpsertMap.put(counter,pincode);
                                }
                            }
                            counter++;
							                            
                        }
                        else{
                            throw new MasterDataSyncException(key,customErrorCode.get('SYNC_ERROR'),'SYNC_ERROR: CITYID: ' + pincodeMaster.CITYID + ' not found in SFDC Master');
                        }
                    }
                    catch(MasterDataSyncException ex){
                        if(ex.recordId!=null){
                            MasterDataSync__c errorRecord = new MasterDataSync__c();
                            errorRecord.Id = ex.recordId;
                            errorRecord.IsProcessed__c=true;
                            errorRecord.SyncStatus__c='Failed';
                            errorRecord.ErrorCode__c= String.isNotBlank(ex.errorCode)? ex.errorCode:customErrorCode.get('SYNC_ERROR');
                            errorRecord.ErrorMessage__c= String.isNotBlank(ex.errorMessage)? ex.errorMessage:'Error Occurred while Data Sync';
                            masterDataSyncErrorList.add(errorRecord);
                        }
                    }
                }
                
                if(!pincodeUpsertMap.isEmpty()){
                    Schema.SObjectField externalID = PincodeMstr__c.Fields.ZipId__c;
                    Database.UpsertResult[] results = Database.upsert(pincodeUpsertMap.values(),externalID,false);
                    for(Integer i=0; i<results.size(); i++){
                        if(results[i].isSuccess()){
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                    masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                    masterDataSyncUpdateMap.get(i).SyncStatus__c='Success';
                                    masterDataSyncUpdateMap.get(i).ErrorCode__c=customErrorCode.get('SUCCESS');
                                    masterDataSyncUpdateMap.get(i).ErrorMessage__c='SUCCESS: Data Sync Successful';
                            }		
                        }
                        else {
                            List<Database.Error> err = results[i].getErrors();
                            if(masterDataSyncUpdateMap.containsKey(i)){
                                masterDataSyncUpdateMap.get(i).IsProcessed__c=true;
                                masterDataSyncUpdateMap.get(i).SyncStatus__c='Failed';
                                masterDataSyncUpdateMap.get(i).ErrorCode__c= !err.isEmpty() && customErrorCode.containsKey(String.valueOf(err[0].getStatusCode())) ? customErrorCode.get(String.ValueOf(err[0].getStatusCode())) : customErrorCode.get('SYNC_ERROR');
                                masterDataSyncUpdateMap.get(i).ErrorMessage__c= !err.isEmpty() ? err[0].getStatusCode() + ': ' + err[0].getMessage() : 'Error Occurred while Data Sync';
                            }
                        }
                        
                    }
                }
                
                if(!masterDataSyncUpdateMap.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncUpdateMap.values());
                }
				if(!masterDataSyncErrorList.isEmpty()){
					masterDataSyncUpdateList.addAll(masterDataSyncErrorList);
				}	
				if(!masterDataSyncUpdateList.isEmpty()){
					update masterDataSyncUpdateList;
				}
				
            }
        }
		catch(Exception ex){
            System.debug('processCityPincodeMapping ' + ex.getMessage() + ' line ' + ex.getLineNumber());
        }
    }
    
    //---------------------------------------------------------------------------------------//
    
    public static void processMasterData(List<MasterDataSync__c> records){
        try{
            if(!records.isEmpty()){
                List<MasterDataSync__c> dsaMasterList = new List<MasterDataSync__c>();
                List<MasterDataSync__c> connectorMasterList = new List<MasterDataSync__c>();
                List<MasterDataSync__c> propertySubTypeMasterList = new List<MasterDataSync__c>();
                List<MasterDataSync__c> propertyTypeMasterList = new List<MasterDataSync__c>();
                List<MasterDataSync__c> propertyUsageMasterList = new List<MasterDataSync__c>();
                List<MasterDataSync__c> branchMasterList = new List<MasterDataSync__c>();
                List<MasterDataSync__c> schemeMasterList = new List<MasterDataSync__c>();
                List<MasterDataSync__c> technicalAgencyMasterList = new List<MasterDataSync__c>();
                List<MasterDataSync__c> legalAgencyMasterList = new List<MasterDataSync__c>();
                List<MasterDataSync__c> bankNameList = new List<MasterDataSync__c>();
                List<MasterDataSync__c> chargesMasterList = new List<MasterDataSync__c>();
                List<MasterDataSync__c> inspectorMasterList = new List<MasterDataSync__c>();
                List<MasterDataSync__c> constitutionMasterList = new List<MasterDataSync__c>();
                List<MasterDataSync__c> MICRMasterList = new List<MasterDataSync__c>();
                List<MasterDataSync__c> MICRBankNameList = new List<MasterDataSync__c>();
                List<MasterDataSync__c> FIAgencyMasterList = new List<MasterDataSync__c>();
                List<MasterDataSync__c> RCUAgencyMasterList = new List<MasterDataSync__c>();
                List<MasterDataSync__c> CityMasterList = new List<MasterDataSync__c>();
                List<MasterDataSync__c> CityPincodeMappingList = new List<MasterDataSync__c>();
                
                Set<String> identifierSet = new Set<String>();             
                Set<Id> recordIds = new Set<Id>();             
                for(MasterDataSync__c mstrData : records){
                    identifierSet.add(mstrData.Identifier__c);
                    recordIds.add(mstrData.Id);
                    if(mstrData.MasterDataType__c=='DSAMASTER'){
                        dsaMasterList.add(mstrData);
                    }
                    if(mstrData.MasterDataType__c=='CONNECTORMASTER'){
                        connectorMasterList.add(mstrData);
                    }
                    if(mstrData.MasterDataType__c=='PROPERTYSUBTYPEMASTER'){
                        propertySubTypeMasterList.add(mstrData);
                    }
                    if(mstrData.MasterDataType__c=='PROPERTTYPEMASTER'){
                        propertyTypeMasterList.add(mstrData);
                    }
                    if(mstrData.MasterDataType__c=='PROPERTPROPUSAGEMASTER'){
                        propertyUsageMasterList.add(mstrData);
                    }
                    if(mstrData.MasterDataType__c=='BRANCHMASTER'){
                        branchMasterList.add(mstrData);
                    }
                    if(mstrData.MasterDataType__c=='SCHEMEMASTER'){
                        schemeMasterList.add(mstrData);
                    }
                    if(mstrData.MasterDataType__c=='TECHNICALAGENCYEMASTER'){
                        technicalAgencyMasterList.add(mstrData);
                    }
                    if(mstrData.MasterDataType__c=='LEGALAGENCYEMASTER'){
                        legalAgencyMasterList.add(mstrData);
                    }
                    if(mstrData.MasterDataType__c=='BANKNAMEMASTER'){
                        bankNameList.add(mstrData);
                    }
                    if(mstrData.MasterDataType__c=='CHARGESMASTER'){
                        chargesMasterList.add(mstrData);
                    }
                    if(mstrData.MasterDataType__c=='INSPECTORMASTER'){
                        inspectorMasterList.add(mstrData);
                    }
                    if(mstrData.MasterDataType__c=='CONSTITUTIONMASTER'){
                        constitutionMasterList.add(mstrData);
                    }
                    if(mstrData.MasterDataType__c=='MICRMASTER'){
                        MICRMasterList.add(mstrData);
                    }
                    if(mstrData.MasterDataType__c=='MICRBANKNAME'){
                        MICRBankNameList.add(mstrData);
                    }
                    if(mstrData.MasterDataType__c=='FIAGENCYEMASTER'){
                        FIAgencyMasterList.add(mstrData);
                    }
                    if(mstrData.MasterDataType__c=='RCUAGENCYEMASTER'){
                        RCUAgencyMasterList.add(mstrData);
                    }
                    if(mstrData.MasterDataType__c=='CITYMASTER'){
                        CityMasterList.add(mstrData);
                    }
                    if(mstrData.MasterDataType__c=='CITYPINCODEMAPPING'){
                        CityPincodeMappingList.add(mstrData);
                    }
                }
                
                if(!dsaMasterList.isEmpty()){
                    processDSAMaster(dsaMasterList);
                }
                if(!connectorMasterList.isEmpty()){
                    processConnectorMaster(connectorMasterList);
                }
                if(!propertySubTypeMasterList.isEmpty()){
                    processPropertySubTypeMaster(propertySubTypeMasterList);
                }
                if(!propertyTypeMasterList.isEmpty()){
                    processPropertyMaster('Property Type',propertyTypeMasterList);
                }
                if(!propertyUsageMasterList.isEmpty()){
                    processPropertyMaster('Property Usage',propertyUsageMasterList);
                }
                if(!branchMasterList.isEmpty()){
                    processBranchMaster(branchMasterList);
                }
                if(!schemeMasterList.isEmpty()){
                    processSchemeMaster(schemeMasterList);
                }
                if(!technicalAgencyMasterList.isEmpty()){
                    processTechnicalAgencyMaster(technicalAgencyMasterList);
                }
                if(!legalAgencyMasterList.isEmpty()){
                    processLegalAgencyMaster(legalAgencyMasterList);
                }
                if(!bankNameList.isEmpty()){
                    processBankNameMaster(bankNameList);
                }
                if(!chargesMasterList.isEmpty()){
                    processChargesMaster(chargesMasterList);
                }
                if(!inspectorMasterList.isEmpty()){
                    processInspectorMaster(inspectorMasterList);
                }
                if(!constitutionMasterList.isEmpty()){
                    processConstitutionMaster(constitutionMasterList);
                }
                if(!MICRMasterList.isEmpty()){
                    processMICRMaster(MICRMasterList);
                }
                if(!MICRBankNameList.isEmpty()){
                    processMICRBankNameMaster(MICRBankNameList);
                }
                if(!FIAgencyMasterList.isEmpty()){
                    processFIAgencyMaster(FIAgencyMasterList);
                }
                if(!RCUAgencyMasterList.isEmpty()){
                    processRCUAgencyMaster(RCUAgencyMasterList);
                }
                if(!CityMasterList.isEmpty()){
                    processCityMaster(CityMasterList);
                }
                if(!CityPincodeMappingList.isEmpty()){
                    processCityPincodeMapping(CityPincodeMappingList);
                }
                
                if(!identifierSet.isEmpty()){
                    List<MasterDataSync__c> recordsList = new List<MasterDataSync__c>([Select Id,Identifier__c, SequenceNumber__c, SyncStatus__c, MasterDataType__c, Record__c,Async__c, ProcessImmediately__c, IsProcessed__c,ErrorCode__c,ErrorMessage__c FROM MasterDataSync__c WHERE IsProcessed__c =true AND Identifier__c IN:identifierSet AND ID IN:recordIds]);
                    if(!recordsList.isEmpty()){
                        masterSyncResult(recordsList);
                    }
                }
            }
        } 
        catch(Exception ex){
            System.debug('processMasterData ' + ex.getMessage() + ' line ' + ex.getLineNumber());
        }
    }
    
    /*************/
	@future(callout=true)
    public static void updatePropertyUsagePicklistField(){
        try{
            MetadataService.MetadataPort service = createService();
            List<MetadataService.PicklistValue> filteredDependentValues = new List<MetadataService.PicklistValue>();
            
            MetadataService.CustomField customField = new MetadataService.CustomField();
            customField.fullName = 'ApplAsset__c.Property_Usage__c';
            customField.label = 'Property Usage';
            customField.type_x = 'Picklist';
            
            // Define the Value Set and Value Set Definitions
            MetadataService.ValueSet vs = new MetadataService.ValueSet();
            MetadataService.ValueSetValuesDefinition vd = new MetadataService.ValueSetValuesDefinition();
            
            // Define the picklist values
            List<MetadataService.CustomValue> customValues = new List<MetadataService.CustomValue>();
            
            for(MasterData__c md : [Select Id,Name,FinnoneVal__c, FinnoneCode__c,SalesforceCode__c,Status__c,Type__c  from MasterData__c WHERE Type__c ='Property Usage' AND FinnoneCode__c<>null]){
                MetadataService.CustomValue cv = new MetadataService.CustomValue();
                cv.label = md.Name;
                cv.fullName = md.SalesforceCode__c;
                cv.isActive = true;
                cv.default_x = false;
                customValues.add(cv);
            }
            
            vd.value = customValues;
            vd.sorted = true;
            
            vs.valueSetDefinition = vd;
            
            customField.valueSet  = vs;
            
            List<MetadataService.UpsertResult> results =
                service.upsertMetadata(
                    new MetadataService.Metadata[] { customField });
        }
        catch(Exception ex){
            System.debug('updatePropertyUsagePicklistField ' + ex.getMessage() + ' line ' + ex.getLineNumber());
        }
        
    }
    
    @future(callout=true)
    public static void updateGlobalPicklistField(String type){
        try{
            MetadataService.MetadataPort service = createService();
            MetadataService.GlobalValueSet gvs = new MetadataService.GlobalValueSet();
            
            if(type!=null){
                if(type=='Property Type'){
                    gvs.fullName ='Property_Type';
                    gvs.masterLabel ='Property Type';
                    
                }
                else if(type=='Constitution'){
                    gvs.fullName ='Constitution';
                    gvs.masterLabel ='Constitution';
                }
                gvs.sorted=true;
                
                List<MetadataService.CustomValue> customValues = new List<MetadataService.CustomValue>();
                for(MasterData__c md : [Select Id,Name,FinnoneVal__c, FinnoneCode__c,SalesforceCode__c,Status__c,Type__c  from MasterData__c WHERE Type__c =:type AND SalesforceCode__c<>null]){
                    MetadataService.CustomValue cv = new MetadataService.CustomValue();
                    cv.label = md.Name;
                    cv.fullName = md.SalesforceCode__c;
                    cv.isActive = true;
                    cv.default_x = false;
                    customValues.add(cv);
                }
                
                gvs.customValue=customValues;
                
                List<MetadataService.SaveResult> results =
                    service.updateMetadata(
                        new MetadataService.Metadata[] { gvs });
                
                system.debug('Result'+results);
            }
            
        }
        catch(Exception ex){
            System.debug('updateGlobalPicklistField ' + ex.getMessage() + ' line ' + ex.getLineNumber());
        }
        
    }
    
    public static MetadataService.MetadataPort createService()
    {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }
	/*************/    
    public static void masterSyncResult(List<MasterDataSync__c> records){
        try{
            if(!records.isEmpty()){
                Map<String,Map<String,List<MasterDataSync__c>>> resultRecordsMap = new Map<String,Map<String,List<MasterDataSync__c>>>();
                for(MasterDataSync__c record:records){
                    if(record.Identifier__c !=null && record.MasterDataType__c!=null){
                        system.debug(':::::'+record.Identifier__c + '::'+record.MasterDataType__c+':'+record.Id);
                        if(!resultRecordsMap.containsKey(record.Identifier__c)){
                            
                            resultRecordsMap.put(record.Identifier__c, new Map<String,List<MasterDataSync__c>>{record.MasterDataType__c => new List<MasterDataSync__c>{record}});
                        }
                        else{
                            if(!resultRecordsMap.get(record.Identifier__c).containsKey(record.MasterDataType__c)){
                                resultRecordsMap.get(record.Identifier__c).put(record.MasterDataType__c, new List<MasterDataSync__c>{record});
                            }
                            else{
                                resultRecordsMap.get(record.Identifier__c).get(record.MasterDataType__c).add(record);
                            }
                        }
                    }
                }
                System.debug(resultRecordsMap);
                if(!resultRecordsMap.isEmpty()){
                    List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();
                    for(String key : resultRecordsMap.keyset()){
                        System.debug('Key::::'+key);
                        MasterDataSyncWrapper result = new MasterDataSyncWrapper();
                        result.identifier = key;
                        
                        
                        Map<String,List<MasterDataSync__c>> masterRecordMap = resultRecordsMap.get(key);
                        List<Masterbody> masterbodyList = new List<Masterbody>();
                        if(!masterRecordMap.isEmpty()){
                            for(String key1 : masterRecordMap.keyset()){
                                List<MasterData> masterDataList = new List<MasterData>();
                                System.debug(':::::Key1'+key1);
                                Masterbody masterbody = new Masterbody();
                                masterbody.masterDataType = key1;
                                MasterData masterData = new MasterData();
                                List<MasterDataSync__c> recordsList = masterRecordMap.get(key1);
                                List<Map<String,Object>>recordList = new List<Map<String,Object>>();
                                System.debug('Records::::::'+recordsList);
                                if(!recordsList.isEmpty()){
                                    for(MasterDataSync__c record : recordsList){
                                        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(record.Record__c);
                                        jsonMap.put('ERROR_CODE',record.ErrorCode__c);
                                        jsonMap.put('ERROR_DEC',record.ErrorMessage__c);
                                        recordList.add(jsonMap);
                                    }
                                }
                                masterData.record = recordList;
                                masterDataList.add(masterData);
                                masterbody.masterData =masterDataList;
                                masterbodyList.add(masterbody);
                                
                            }
                            result.masterbody = masterbodyList;
                        }
                        system.debug(JSON.serialize(result));
                        IntgMsg__c intMsg = new IntgMsg__c();
                        intmsg.Name ='Master Data Sync';
                        intmsg.BU__c='HL / STL';
                        intmsg.Status__c='New';
                        intmsg.MStatus__c='Blank';
                        intmsg.Svc__c='Master Data Sync';
                        intmsg.Req__c = JSON.serialize(result);
                        intmsg.IsActive__c=true;
                        createRequestList.add(intmsg);
                    }
                    
                    if(!createRequestList.isEmpty()){
                        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
                        List<string> fieldNamesList = New List<string>{'Name','BU__c','Status__c','MStatus__c','Req__c','Svc__c','IsActive__c'};
                            String sObjectName = 'IntgMsg__c';
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                        fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                        uow.registerNew(createRequestList);
                        uow.commitWork();
                    }
                }
            }
        }
        catch(Exception ex){
            System.debug('masterSyncResult ' + ex.getMessage() + ' line ' + ex.getLineNumber());
        }
    }
    
    public class MasterDataSyncWrapper{
        
        public String identifier;	//47012275
        public List<Masterbody> masterbody;
        
    }
    public class Masterbody {
        public String masterDataType;	//DSAMASTER
        //public String asyncProcessing;	//true
        public List<MasterData> masterData;
    }
    public class MasterData {
        public List<Map<String,Object>> record;
    }
    
    //DSAMASTER
    public class DSAMasterWrapper{
        public String BROKERID;	//4
        public String DSA_NAME;	//VALUE LINE FINANCIAL SERVICES
        public String BRANCH;	//DELHI
        public String PRODUCT_CODE;	//LAP
        public String ACTIVE_STATUS;	//I
        public String AUTHID;	//FEDM
        public String AUTHDATE;	//2012-07-23T15:30:52
    }
    
    //CONNECTORMASTER
    public class ConnectorMasterWrapper{
        public String VC_REFERRAL_ID;	//13
        public String VC_REFERRAL_CD;	//CPSS1001
        public String VC_REFERRAL_NAME;	//ANAND THANGAMALIGAI
        public String LPP_PRODCAT_C;	//PERSONAL
        public String STATUS;	//A
        public String AUTHID;	//IT011579
        public String AUTHDATE;	//2015-03-25T15:46:38
    }
    
    //PROPERTYSUBTYPEMASTER
    public class PropertySubTypeMasterWrapper{
        public String KEY1;	//PROPDESC
        public String VALUE;	//HRH
        public String DESCRIPTION;	//HR - HSIIDC
        public String AUTHID;	//APIUSER
        public String AUTHDATE;	//2021-05-26T00:00:00
        
    }
    
    //PROPERTTYPEMASTER
    public class PropertyTypeMasterWrapper{
        public String KEY1;	//PURCHASETYPE
        public String VALUE;	//NEW
        public String DESCRIPTION;	//NEW
        public String AUTHID;	//SYSTEM
        public String AUTHDATE;	//2011-12-29T04:08:01
    }
    
    //PROPERTPROPUSAGEMASTER
    public class ProperPropUsageMasterWrappper{
        public String KEY1;	//PROPUSAGE
        public String VALUE;	//LOC
        public String DESCRIPTION;	//LET OUT COMMERCIAL
        public String AUTHID;	//SYSTEM
        public String AUTHDATE;	//2012-06-06T00:00:00
    }
    
    //BRANCHMASTER
    public class BranchMasterWrapper{
        public String BRANCHID;	//88
        public String BRANCHDESC;	//REPALLE
        public String PHONE1;	//08648320022
        public String BRANCHCODE;	//REP
        public String SUNINFO_BRANCH_CODE;	//Closed
        public String AUTHID;	//FEDA
        public String AUTHDATE;	//2013-05-13T17:44:04
    }
    
    //SCHEMEMASTER
    public class SchemeMasterWrapper{
        public String PRODUCTFLAG;	//LAP
        public String SCHEME_END_DATE;	//16/07/2018
        public String SCHEMEID;	//325
        public String SCHEMEDESC;	//TOP-UP - OTHERS
        public String FREQUENCY;	//M
        public String INSTLMODE;	//R
        public String INSTLTYPE;	//E
        public String INTRATE;	//13.0
        public String MAXAMTFIN;	//50000000.0
        public String MAXINTRATE;	//24.0
        public String MAXTENURE;	//180
        public String MINAMTFIN;	//100000.0
        public String MININTRATE;	//10.0
        public String MINTENURE;
        public String SCHID;	//239
        public String SCHEME_START_DATE;	//2012-06-25T00:00:00
        public String STATUS;	//A
        public String TENURE;	//180
        public String AUTHID;	//CRE11341
        public String AUTHDATE;	//2012-07-21T20:02:12
    }
    
    //TECHNICALAGENCYEMASTER
    public class TechnicalAgencyMasterWrapper{
        public String LAWYERNAME;	//K P SATISH BABU
        public String BRANCH;	//K R PURAM
        public String BRANCHID; 
        public String AUTHID;	//IT012709
        public String AUTHDATE;	//2021-04-13T11:45:06
    }
    
    //LEGALAGENCYEMASTER
    public class LegalAgencyMasterWrapper{
        public String LFAM_AGENCYCODE_C;	//G A MEMON
        public String LFAM_AGENCYNAME_C;	//G A MEMON
        public String LFABPMM_PRODCODE_C;	//LAP
        public String BRANCH;	//AHMEDABAD
        public String BRANCHID;
        public String AUTHORID;	//IT011579
        public String AUTHORDATE;	//2019-08-28T16:19:03
    }
    
    //BANKNAMEMASTER
    public class BankNameMasterWrapper{
        public String BANKID;	//11
        public String BANKDESC;	//FEDERAL BANK - PF A/C
        public String FABANKGLID;	//FBPF
        public String BANKACNUM;	//13850200015678
        public String BANK_IFS_C;	//FDRL0001385
        public String BANK_RTGS_C;	//
        public String BANK_NEFT_C;	//
        public String BANK_IMPS_C;	//
        public String AUTHID;	//SMM1
        public String AUTHDATE;	//2011-06-02T00:00:00
    }
    
    //CHARGESMASTER
    public class ChargeMasterWrapper{
        public String CHARGEID;	//230
        public String MODULEID;	//LEA
        public String CHARGECODEID;	//230
        public String CHARGEDESC;	//UNUTILIZED DMA SUBVENTION
        public Decimal CHARGEAMT;	//1
        public String TAX_APPL_FLG;	//
        public String GST_FLAG;	//
        public String AUTHID;	//ADMIN
        public String AUTHDATE;	//2011-07-29T00:00:00
    }
    
    //INSPECTORMASTER
    public class InspectorMasterWrapper{
        public String INSPECTORID;	//5080
        public String INSPECTORNAME;	//18712 - RAMESH R
        public String BROKERID;	//1546
        public String BROKERNAME;	//1054482 FINN GURU SOLUTIONS
        public String AUTHID;	//IT017531
        public String AUTHDATE;	//2022-08-19T12:14:09
        
    }
    
    //CONSTITUTIONMASTER
    public class ConstitutionMasterWrapper{
        public String CONSTID;	//7
        public String CONSTDESC;	//HUF
        public String STATUS;	//A
        public String AUTHID;	//RITIKA
        public String AUTHDATE;	//2011-05-26T00:00:00
    }
    
    //MICRMASTER
    public class MICRMasterWrapper{
        public String BBRANCHID;	//7220
        public String CITYID;	//160
        public String BANKID;	//024
        public String BANKBRANCHID;	//010
        public String NAME;	//SECTOR 12, PANCHKULA
        public String CLEARINGHOUSEID;	//641
        public String MICRCODE;	//160024010
        public String LSO_OFFICE_IFS_C;	//PUNB0395600
        public String APPROVEDBY;	//70019384
        public String APPROVALDATE;	//2011-07-18T00:00:00
    }
    
    //MICRBANKNAME
    public class MICRBankNameMasterWrapper{
        public String BANKID;	//192
        public String NAME;	//URBAN CO-OP BANK LTD,JAIPUR
        public String CITYID;
        public String APPROVEDBY;	//MIGR
        public String APPROVALDATE;	//2007-04-01T00:00:00
        
    }
    
    //FIAGENCYEMASTER
    public class FIAgencyMasterWrapper{
        public String LFAM_AGENCYCODE_C;	//OM
        public String LFAM_AGENCYNAME_C;	//OM SHREE SAI ASSOCIATES
        public String LFABPMM_PRODCODE_C;	//BL
        public String BRANCH;	//KAMMANAHALLI
        public String BRANCHID;
        public String AUTHORID;	//IT011579
        public String AUTHORDATE;	//2019-05-06T12:38:24
    }
    
    //RCUAGENCYEMASTER
    public class RCUAgencyMasterWrapper{
        public String LFAM_AGENCYCODE_C;	//URMS
        public String LFAM_AGENCYNAME_C;	//URMS
        public String LFABPMM_PRODCODE_C;	//BL
        public String BRANCH;	//DELHI
        public String BRANCHID;
        public String AUTHORID;	//IT011579
        public String AUTHORDATE;	//2019-11-05T16:19:04
        
    }
    
    //CITYMASTER
    public class CityMasterWrapper{
        public String LMC_CITYID_C;	//1735
        public String LMC_CITYNAME_C;	//GUNA
        public String STATEID;	//29
        public String GSTSTATECODE;	//24
        public String STATEDESC;	//GUJARAT
        public String AUTHID;	//IT011579
        public String AUTHDATE;	//2024-08-18T06:41:10
    }
    
    //CITYPINCODEMAPPING
    public class CityPincodeMappingWrapper{
        public String ZIPID;	//14584
        public String PINCODE;	//605118
        public String CITYID;	//1308
        public String AUTHID;	//IT011579
        public String AUTHDATE;	//2024-08-18T06:41:10
    }
    
    
    public static final Map<String, String> customErrorCode = new Map<String, String>{
        'SUCCESS' => '000',
        'DUPLICATE_VALUE' => '111',
        'MISSING_ARGUMENT' => '112',
        'REQUIRED_FIELD_MISSING' => '113',
        'STRING_TOO_LONG' => '114',
        'SYNC_ERROR' => '115'   
    };
        
    // Exception class
    public class MasterDataSyncException extends Exception {
        
        public String recordId;
        public String errorCode;
        public String errorMessage;
        
        public MasterDataSyncException(String recordId, String errorCode,String errorMessage){
            this.recordId = recordId;
            this.errorCode = errorCode;
            this.errorMessage = errorMessage;
        }
    }    
}