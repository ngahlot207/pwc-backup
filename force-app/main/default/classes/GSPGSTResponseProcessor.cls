public class GSPGSTResponseProcessor implements IintMsgCalloutResponseProcessor {
    
    public static void process(List<IntgMsg__c> responses){ 
        try {
            Map<IntgMsg__c,GSPGSTResponseWrapper> successResponseMap = new Map<IntgMsg__c,GSPGSTResponseWrapper>();
            Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
            Set<String> pincodes = new Set<String>();
            
            Set<Id> applGSTIds = new Set<Id>();
        	Set<Id> applKycIds = new Set<Id>();
            Map<Id,SObject> refMap = new Map<Id,SObject>();
            Set<Id> applIds = new Set<Id>();
            Map<Id,Map<String,ApplGST__c>> applGSTMap = new Map<Id,Map<String,ApplGST__c>>();
            for(IntgMsg__c integrationMessage : responses){
                
                try{
                    
                    GSPGSTResponseWrapper response = (GSPGSTResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, GSPGSTResponseWrapper.class);
                                        
                    if(String.isNotBlank(integrationMessage.RefId__c) && String.isNotBlank(integrationMessage.RefObj__c) && integrationMessage.RefObj__c == 'ApplGST__c') {
                        applGSTIds.add(integrationMessage.RefId__c);
                        if(integrationMessage.ParentRefId__c!=null){
                            applIds.add(integrationMessage.ParentRefId__c);
                        }
						
                    }
                    if(String.isNotBlank(integrationMessage.ParentRefId__c) && String.isNotBlank(integrationMessage.ParentRefObj__c) && integrationMessage.ParentRefObj__c == 'ApplKyc__c'){
                        applKycIds.add(integrationMessage.ParentRefId__c);
                    }
                    
                    if(response!=null){
                        
                        if(response.result!=null && response.result.pradr!=null && response.result.pradr.addr != null){
                            if(response.result.pradr.addr.pncd != null && String.isNotBlank(response.result.pradr.addr.pncd)){
                                pincodes.add(response.result.pradr.addr.pncd);
                            }
                        }
                        
                        if(response.statusCode!=null){
                            if(Integer.valueOf(response.statusCode) == GlobalConstants.karza_Status_101){
                                successResponseMap.put(integrationMessage,response);
                            }
                            else{
                                failureResponseMap.put(integrationMessage,GlobalConstants.karza_Status_Code_Authn_Description.containsKey(Integer.valueOf(response.statusCode))?GlobalConstants.karza_Status_Code_Authn_Description.get(Integer.valueOf(response.statusCode)):'');
                            }
                        }
                        else if(response.status!=null){
                            failureResponseMap.put(integrationMessage,(response.error!=null && String.isNotBlank(response.error) ? response.error : ''));
                        }
                    }
                }
                catch(Exception ex){
                    
                    failureResponseMap.put(integrationMessage,IntegrationUtility.getCustomErrorMessage(ex.getMessage().substringBefore(':')));
                    GlobalUtility.logMessage('Error', 'GSTPANResponseProcessor class', 
                                             'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                    
                }
            }
            
            for(ApplKyc__c applKyc : [SELECT Id,Applicant__c,GSTIN__c FROM ApplKyc__c WHERE Id IN: applKycIds]){
                applIds.add(applKyc.Applicant__c);
                refMap.put(applKyc.Id,applKyc);
            }
            
            for(ApplGST__c applGST : [Select Id,Applicant__c,GSTIN__c,Email__c,ApplStatus__c,MobNo__c,Pan__c,GSTIN_RefId__c,Reg_Type__c,GSTIN_Status__c,RegistName__c,TinNo__c FROM ApplGST__c where Applicant__c IN:applIds]){
                
                if(applGST.GSTIN__c!=null){
                    if(applGSTMap.containsKey(applGST.Applicant__c)){
                        applGSTMap.get(applGST.Applicant__c).put(applGST.GSTIN__c,applGST);
                    }
                    else{
                        applGSTMap.put(applGST.Applicant__c,new Map<String,ApplGST__c>{applGST.GSTIN__c=>applGST});
                    }
                }
                refMap.put(applGST.Id,applGST);
            }
            
            
            
            
            Map<Id,Applicant__c> applicantMap = new Map<Id,Applicant__c> ([SELECT id,Name,Gender__c,LoanAppln__c,ApplType__c,FullName__c,Constitution__c,CompanyName__c FROM Applicant__c WHERE ID IN:applIds]);
            Map<Id,Map<String,APIVer__c>> existingAPIVerMap = new Map<Id,Map<String,APIVer__c>>();
            for(APIVer__c apiVer : [Select Id,IsLatest__c,Appl__c,GSTIN__c FROM APIVer__c WHERE IsLatest__c=True AND Appl__c IN : applIds AND RecordTypeId =:Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('GST').getRecordTypeId()]){
                
                if(existingAPIVerMap.containsKey(apiVer.Appl__c)){
                    existingAPIVerMap.get(apiVer.Appl__c).put(apiVer.GSTIN__c,apiVer);
                }
                else{
                    existingAPIVerMap.put(apiVer.Appl__c, new Map<String,APIVer__c>{apiVer.GSTIN__c=>apiVer});
                }
            }
            
            system.debug('94>>>>>>>>>>>'+existingAPIVerMap);
            if(!successResponseMap.isEmpty()){
                processSuccess(applicantMap,applGSTMap,refMap,successResponseMap,existingAPIVerMap,pincodes);
            }
            if(!failureResponseMap.isEmpty()){
                processFailure(applicantMap,applGSTMap,refMap,failureResponseMap,existingAPIVerMap);
            }
        }
        catch(Exception ex) {
            System.debug('error' + ex.getMessage());
            GlobalUtility.logMessage('Error', 'GSPGSTResponseProcessor', 
                                     'Process', NULL, NULL, ex.getMessage() + ' line ' + ex.getLineNumber(), NULL, ex, NULL);
        }
    }
    
    public static void processSuccess(Map<Id,Applicant__c> applicantMap,Map<Id,Map<String,ApplGST__c>> applGSTMap,Map<Id,SObject> refMap,Map<IntgMsg__c,GSPGSTResponseWrapper> successResponses,Map<Id,Map<String,APIVer__c>> existingAPIVerMap, set<String> pincodes){
        try{
            
            List<ApplGST__c> applGSTList = new List<ApplGST__c>();
            List<APIVer__c> apiVerList = new List<APIVer__c>();
            Id recordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('GST').getRecordTypeId();
			List<APIVer__c> existingAPIVerList = new List<APIVer__c>();    
            Map<String,List<APIVerDtl__c>> apiVerDtlMap = new Map<String,List<APIVerDtl__c>>();
            Set<Id> docDtlIds = new Set<Id>();
            List<ApplKyc__c> applKycList = new List<ApplKyc__c>();
            if(!successResponses.isEmpty()){
                Map<String,PincodeMstr__c> pincodeMap = new Map<String,PincodeMstr__c>();
                if(pincodes!=null && !pincodes.isEmpty()){
                    for(PincodeMstr__c pin : [Select ZipId__c,PIN__c,City__c, City__r.City__c,City__r.CityId__c,City__r.StateId__c,City__r.State__c from PincodeMstr__c where PIN__c IN:pincodes]){
                        pincodeMap.put(pin.PIN__c,pin);
                    }
                }
                
                
                for(IntgMsg__c integrationMessage : successResponses.keySet()){
                    if((String.isNotBlank(integrationMessage.RefId__c) && String.isNotBlank(integrationMessage.RefObj__c) && integrationMessage.RefObj__c == 'ApplGST__c') ||
                      (String.isNotBlank(integrationMessage.ParentRefId__c) && String.isNotBlank(integrationMessage.ParentRefObj__c) && integrationMessage.ParentRefObj__c == 'ApplKyc__c')
                      ){
                        GSPGSTResponseWrapper response = successResponses.get(integrationMessage);
                        if(response!=null && response.result!=null){
                            
                            ApplGST__c gstRec = new ApplGST__c();
                            gstRec.GSTAuthenticationStatus__c = GlobalConstants.MSG_SUCCESS;
                            gstRec.GSTAuthenticationErrorMessage__c = '';
                            if(integrationMessage.RefObj__c == 'ApplGST__c'){
                                gstRec.Id=integrationMessage.RefId__c;
                                gstRec.Invalid__c = false;
                            }
                            else if(integrationMessage.ParentRefObj__c == 'ApplKyc__c') {
                                //gstRec.Applicant__c
                                if(refMap.containsKey(integrationMessage.ParentRefId__c)){
                                    ApplKyc__c applKyc = (ApplKyc__c) refMap.get(integrationMessage.ParentRefId__c);
                                    if(applGSTMap.containskey(applKyc.Applicant__c) && applGSTMap.get(applKyc.Applicant__c).containsKey(applKyc.GSTIN__c)){
                                        gstRec.Id=applGSTMap.get(applKyc.Applicant__c).get(applKyc.GSTIN__c).Id;
                                        gstRec.Invalid__c = false;
                                    }
                                    else{
                                        gstRec.Applicant__c = applKyc.Applicant__c;
                                    }
                                    
                                }
                            }
                            
                            if(response.result.pradr!=null && response.result.pradr.addr != null){
                                gstRec.LastSelectedAddrType__c = 'GST Address';
                                gstRec.Pincode__c = response.result.pradr.addr.pncd != null && String.isNotBlank(response.result.pradr.addr.pncd) ? response.result.pradr.addr.pncd : '';
                                
                                if(String.isNotBlank(gstRec.Pincode__c)  && pincodeMap.containsKey(gstRec.Pincode__c)){
                                    gstRec.CityId__c=pincodeMap.get(gstRec.Pincode__c).City__r.CityId__c;
                                    gstRec.City__c=pincodeMap.get(gstRec.Pincode__c).City__r.City__c;
                                    gstRec.Pincode__c=pincodeMap.get(gstRec.Pincode__c).PIN__c;
                                    gstRec.PinId__c = pincodeMap.get(gstRec.Pincode__c).Id;
                                    gstRec.State__c=pincodeMap.get(gstRec.Pincode__c).City__r.State__c;
                                    gstRec.StateId__c=pincodeMap.get(gstRec.Pincode__c).City__r.StateId__c;
                                }
                                else{
                                    gstRec.State__c = response.result.pradr.addr.stcd != null && String.isNotBlank(response.result.pradr.addr.stcd) ? response.result.pradr.addr.stcd : '';
                                }
                                
                                gstRec.Landmark__c = response.result.pradr.addr.landMark != null  && String.isNotBlank(response.result.pradr.addr.landMark) ? response.result.pradr.addr.landMark : '';
                                gstRec.Locality__c =  response.result.pradr.addr.locality != null && String.isNotBlank(response.result.pradr.addr.locality) ? response.result.pradr.addr.locality : '';
                                gstRec.AddrLine1__c = response.result.pradr.addr.st != null && String.isNotBlank(response.result.pradr.addr.st) ? response.result.pradr.addr.st : '';
                                gstRec.AddrLine2__c = response.result.pradr.addr.loc != null && String.isNotBlank(response.result.pradr.addr.loc) ? response.result.pradr.addr.loc : '';
                                
                                List<String> addrList = new List<String>();
                                if(response.result.pradr.addr.bnm != null  && String.isNotBlank(response.result.pradr.addr.bnm)){
                                    addrList.add(response.result.pradr.addr.bnm);
                                }
                                if(response.result.pradr.addr.bno != null  && String.isNotBlank(response.result.pradr.addr.bno)){
                                    addrList.add(response.result.pradr.addr.bno);
                                }
                                if(response.result.pradr.addr.flno != null  && String.isNotBlank(response.result.pradr.addr.flno)){
                                    addrList.add(response.result.pradr.addr.flno);
                                }
                                
                                gstRec.HouseNo__c = !addrList.isEmpty() ? String.join(addrList,',') : '';
                                
                            }
                            
                            gstRec.LegalNameOfBusiness_GST_Certificate__c = response.result.lgnm!=null && String.isNotBlank(response.result.lgnm) ? response.result.lgnm : '';
                            gstRec.TradeName_GST_Certificate__c = response.result.tradeNam!=null && String.isNotBlank(response.result.tradeNam) ? response.result.tradeNam : '';
                            gstRec.ConstBuisnessGST__c = response.result.ctb!=null && String.isNotBlank(response.result.ctb) ? response.result.ctb : '';
                            
                            if(response.result.rgdt!=null && String.isNotBlank(response.result.rgdt)){
                                List<String> rgDtList = response.result.rgdt.split('/');
                                if(rgDtList!=null && !rgDtList.isEmpty() && rgDtList.size()>=3){
                                    gstRec.RegDate__c= Date.newInstance(Integer.valueof(rgDtList[2]),Integer.valueof(rgDtList[1]),Integer.valueof(rgDtList[0]));
                                }
                            }
                            gstRec.NaturBuisnessReg__c = response.result.nba!=null && !response.result.nba.isEmpty() ?  String.join(response.result.nba,','): '';
                            
                            applGSTList.add(gstRec);
                            
                            if(integrationMessage.ParentRefObj__c == 'ApplKyc__c'){
                                ApplKyc__c applKyc = new ApplKyc__c();
                                applKyc.Id = integrationMessage.ParentRefId__c;
                                applKyc.ValidationStatus__c= GlobalConstants.MSG_SUCCESS;
                                applKyc.Validation_Error_Message__c='';
                                
                                
                                applKyc.Name__c = gstRec.LegalNameOfBusiness_GST_Certificate__c;
                                applKyc.AddrLine1__c = gstRec.AddrLine1__c;
                                applKyc.AddrLine2__c = gstRec.AddrLine2__c;
                                applKyc.Landmark__c = gstRec.Landmark__c;
                                applKyc.Locality__c = gstRec.Locality__c;
                                applKyc.HouseNo__c = gstRec.HouseNo__c;
                                applKyc.Pincode__c = gstRec.Pincode__c;
                                applKyc.City__c = gstRec.City__c;
                                applKyc.State__c = gstRec.State__c;   
                                
                                applKycList.add(applKyc);
                                
                                docDtlIds.add(integrationMessage.RefId__c);
                            }
                            
                            String key = integrationMessage.RefObj__c == 'ApplGST__c'? integrationMessage.RefId__c : integrationMessage.ParentRefObj__c == 'ApplKyc__c'? integrationMessage.ParentRefId__c : '';
                            if(refMap.containsKey(key)){
                                
                                Id applicantId;
                                
                                APIVer__c apiVer = new APIVer__c();
                                apiVer.IntegrationStatus__c = GlobalConstants.MSG_SUCCESS;
                                apiVer.IntegrationErrorMessage__c = '';
                                apiVer.IsLatest__c = True;
                                apiVer.RecordTypeId = recordTypeId;
                                
                                if(integrationMessage.RefObj__c == 'ApplGST__c'){
                                    ApplGST__c applGST = (ApplGST__C) refMap.get(key);
                                    applicantId = applGST.Applicant__c;
                                    if(existingAPIVerMap.containsKey(applGST.Applicant__c)  &&   existingAPIVerMap.get(applGST.Applicant__c).containsKey(applGST.GSTIN__c)){
                                        existingAPIVerList.add(existingAPIVerMap.get(applGST.Applicant__c).get(applGST.GSTIN__c));
                                    }
                                    
                                    apiVer.Email__c = applGST.Email__c;
                                    apiVer.ApplStatus__c = applGST.ApplStatus__c;
                                    apiVer.MobNo__c = applGST.MobNo__c;
                                    apiVer.Pan__c = applGST.Pan__c;
                                    apiVer.GSTIN_RefId__c = applGST.GSTIN_RefId__c;
                                    apiVer.Reg_Type__c = applGST.Reg_Type__c;
                                    apiVer.GSTIN_Status__c = applGST.GSTIN_Status__c;
                                    apiVer.RegistName__c = applGST.RegistName__c;
                                    apiVer.TinNo__c = applGST.TinNo__c;
                                    
                                    apiVer.Appl__c = applicantMap.get(applGST.Applicant__c).Id ;
                                    apiVer.LoanAplcn__c = applicantMap.get(applGST.Applicant__c).LoanAppln__c ;  
                                    apiVer.ApplNme__c = applicantMap.get(applGST.Applicant__c).FullName__c ;  
                                    apiVer.ApplTyp__c = applicantMap.get(applGST.Applicant__c).ApplType__c ;
                                }
                                else if(integrationMessage.ParentRefObj__c == 'ApplKyc__c'){
                                    ApplKyc__c applKyc = (ApplKyc__c) refMap.get(Key);
                                    applicantId = applKyc.Applicant__c;
                                    if(existingAPIVerMap.containsKey(applKyc.Applicant__c)  &&   existingAPIVerMap.get(applKyc.Applicant__c).containsKey(applKyc.GSTIN__c)){
                                        existingAPIVerList.add(existingAPIVerMap.get(applKyc.Applicant__c).get(applKyc.GSTIN__c));
                                    }
                                    apiVer.Appl__c = applicantMap.get(applKyc.Applicant__c).Id ;
                                    apiVer.LoanAplcn__c = applicantMap.get(applKyc.Applicant__c).LoanAppln__c ;  
                                    apiVer.ApplNme__c = applicantMap.get(applKyc.Applicant__c).FullName__c ;  
                                    apiVer.ApplTyp__c = applicantMap.get(applKyc.Applicant__c).ApplType__c ;
                                }                                
                                
                                apiVer.StateJurisdictionCode__c = response.result.stjCd!=null && String.isNotBlank(response.result.stjCd) ? response.result.stjCd : '';
                                apiVer.Name__c = response.result.lgnm!=null && String.isNotBlank(response.result.lgnm) ? response.result.lgnm : '';
                                apiVer.LegalNameOfBusiness_GST_Certificate__c = response.result.lgnm!=null && String.isNotBlank(response.result.lgnm) ? response.result.lgnm : '';
                                apiVer.StateJurisdiction__c = response.result.stj!=null && String.isNotBlank(response.result.stj) ? response.result.stj : '';
                                apiVer.TaxpayerType__c = response.result.dty!=null && String.isNotBlank(response.result.dty) ? response.result.dty : '';
                                
                                if(response.result.adadr!=null && !response.result.adadr.isEmpty()){
                                    for(GSPGSTResponseWrapper.ADADRClass addr : response.result.adadr){
                                        APIVerDtl__c apiVerDtl = new APIVerDtl__c();
                                        apiVerDtl.Type__c = 'Additional Address';
                                        
                                        apiVerDtl.Landmark__c = addr.addr.landMark != null  && String.isNotBlank(addr.addr.landMark) ? addr.addr.landMark : '';
                                        apiVerDtl.Locality__c =  addr.addr.locality != null && String.isNotBlank(addr.addr.locality) ? addr.addr.locality : '';
                                        apiVerDtl.AddrLine1__c = addr.addr.st != null && String.isNotBlank(addr.addr.st) ? addr.addr.st : '';
                                        apiVerDtl.AddrLine2__c = addr.addr.loc != null && String.isNotBlank(addr.addr.loc) ? addr.addr.loc : '';
                                        apiVerDtl.District__c = addr.addr.dst != null && String.isNotBlank(addr.addr.dst) ? addr.addr.dst : '';
                                        apiVerDtl.State__c = addr.addr.stcd != null && String.isNotBlank(addr.addr.stcd) ? addr.addr.stcd : '';
                                        apiVerDtl.Pincode__c = addr.addr.pncd != null && String.isNotBlank(addr.addr.pncd) ? addr.addr.pncd : '';
                                        List<String> addrList = new List<String>();
                                        if(addr.addr.bnm != null  && String.isNotBlank(addr.addr.bnm)){
                                            addrList.add(addr.addr.bnm);
                                        }
                                        if(addr.addr.bno != null  && String.isNotBlank(addr.addr.bno)){
                                            addrList.add(addr.addr.bno);
                                        }
                                        if(addr.addr.flno != null  && String.isNotBlank(addr.addr.flno)){
                                            addrList.add(addr.addr.flno);
                                        }
                                
                                		apiVerDtl.HouseNo__c = !addrList.isEmpty() ? String.join(addrList,',') : '';
                                        
                                        
                                        apiVerDtl.NatureofBuisness__c = addr.ntr != null && String.isNotBlank(addr.ntr) ? addr.ntr : '';
                                        
                                        if(applicantId!=null){
                                            if(apiVerDtlMap.containsKey(applicantId)){
                                                apiVerDtlMap.get(applicantId).add(apiVerDtl);
                                            }
                                            else{
                                                apiVerDtlMap.put(applicantId,new List<APIVerDtl__c>{apiVerDtl});
                                            }
                                        }
                                    }
                                }
                                
                                if(response.result.cxdt!=null && String.isNotBlank(response.result.cxdt)){
                                    List<String> dtList = response.result.cxdt.split('/');
                                    if(dtList!=null && !dtList.isEmpty() && dtList.size()>=3){
                                        apiVer.CancellationDt__c = Date.newInstance(Integer.valueof(dtList[2]),Integer.valueof(dtList[1]),Integer.valueof(dtList[0]));
                                    }
                                }
                                
                                apiVer.GSTIN__c =  response.result.gstin!=null && String.isNotBlank(response.result.gstin) ? response.result.gstin : '';
                                
                                if(response.result.lstupdt!=null && String.isNotBlank(response.result.lstupdt)){
                                    List<String> dtList = response.result.lstupdt.split('/');
                                    if(dtList!=null && !dtList.isEmpty() && dtList.size()>=3){
                                        apiVer.Lstupdt__c = Date.newInstance(Integer.valueof(dtList[2]),Integer.valueof(dtList[1]),Integer.valueof(dtList[0]));
                                    }
                                }
                                if(response.result.rgdt!=null && String.isNotBlank(response.result.rgdt)){
                                    List<String> dtList = response.result.rgdt.split('/');
                                    if(dtList!=null && !dtList.isEmpty() && dtList.size()>=3){
                                        apiVer.DateOfRegistration__c = Date.newInstance(Integer.valueof(dtList[2]),Integer.valueof(dtList[1]),Integer.valueof(dtList[0]));
                                    }
                                }
                                
                                apiVer.ConstBuisnessGST__c = gstRec.ConstBuisnessGST__c;
                                
                                apiVer.Pincode__c = gstRec.Pincode__c;
                                apiVer.State__c  = gstRec.State__c;
                                
                                apiVer.Landmark__c = gstRec.Landmark__c;
                                apiVer.Locality__c = gstRec.Locality__c;
                                apiVer.AddrLine1__c = gstRec.AddrLine1__c;
                                apiVer.AddrLine2__c = gstRec.AddrLine2__c;
                                apiVer.HouseNo__c = gstRec.HouseNo__c;
                                apiVer.NatureofBuisness__c  = gstRec.NaturBuisnessReg__c;
                                apiVer.TradeName_GST_Certificate__c = gstRec.TradeName_GST_Certificate__c;
                                apiVer.GSTIN_Status__c = response.result.sts!=null && String.isNotBlank(response.result.sts) ? response.result.sts : '';
                                apiVer.CentralJurisdictionCode__c = response.result.ctjCd!=null && String.isNotBlank(response.result.ctjCd) ? response.result.ctjCd : '';
                                apiVer.CentralJurisdiction__c = response.result.ctj!=null && String.isNotBlank(response.result.ctj) ? response.result.ctj : '';
                                apiVer.InvoiceStatus__c = response.result.einvoiceStatus!=null && String.isNotBlank(response.result.einvoiceStatus) ? response.result.einvoiceStatus : '';
                                apiVer.MemberNames__c = response.result.mbr!=null && !response.result.mbr.isEmpty() ?  String.join(response.result.mbr,','): '';
                                apiVer.CancellationFlag__c = response.result.canFlag!=null && String.isNotBlank(response.result.canFlag) ? response.result.einvoiceStatus : '';
                                apiVer.ComplianceRating__c = response.result.cmpRt!=null && String.isNotBlank(response.result.cmpRt) ? response.result.cmpRt : '';
                                apiVer.District__c = response.result.pradr.addr.dst != null && String.isNotBlank(response.result.pradr.addr.dst) ? response.result.pradr.addr.dst : '';
                                if(response.result.contacted!=null){
                                    apiVer.ContactEmail__c = response.result.contacted.email!=null && String.isNotBlank(response.result.contacted.email) ? response.result.contacted.email : '';
                                    apiVer.ContactMobNum__c = response.result.contacted.mobNum!=null && String.isNotBlank(response.result.contacted.mobNum) ? response.result.contacted.mobNum : '';
                                    apiVer.ContactName__c = response.result.contacted.name!=null && String.isNotBlank(response.result.contacted.name) ? response.result.contacted.name : '';
                                }
                                
                                List<String> addressList = new List<String>();
                                if(apiVer.HouseNo__c!=null && String.isNotBlank(apiVer.HouseNo__c)){
                                    addressList.add(apiVer.HouseNo__c);
                                }
                                if(apiVer.AddrLine1__c!=null && String.isNotBlank(apiVer.AddrLine1__c)){
                                    addressList.add(apiVer.AddrLine1__c);
                                }
                                if(apiVer.AddrLine2__c!=null && String.isNotBlank(apiVer.AddrLine2__c)){
                                    addressList.add(apiVer.AddrLine2__c);
                                }
                                if(apiVer.Landmark__c!=null && String.isNotBlank(apiVer.Landmark__c)){
                                    addressList.add(apiVer.Landmark__c);
                                }
                                if(apiVer.Locality__c!=null && String.isNotBlank(apiVer.Locality__c)){
                                    addressList.add(apiVer.Locality__c);
                                }
                                if(apiVer.State__c!=null && String.isNotBlank(apiVer.State__c)){
                                    addressList.add(apiVer.State__c);
                                }
                                if(apiVer.Pincode__c!=null && String.isNotBlank(apiVer.Pincode__c)){
                                    addressList.add(apiVer.Pincode__c);
                                }
                                apiVer.Address__c = !addressList.isEmpty() ? String.join(addressList,',') : '';
                                //LAK-9430 Changes Start
                                if(applicantId!=null && apiVerDtlMap.containsKey(applicantId) && !apiVerDtlMap.get(applicantId).isEmpty()){
                                    List<String> additionalAddressList = new List<String>();
                                    if(apiVerDtlMap.get(applicantId)[0].HouseNo__c!=null && String.isNotBlank(apiVerDtlMap.get(applicantId)[0].HouseNo__c)){
                                        additionalAddressList.add(apiVerDtlMap.get(applicantId)[0].HouseNo__c);
                                    }
                                    if(apiVerDtlMap.get(applicantId)[0].AddrLine1__c!=null && String.isNotBlank(apiVerDtlMap.get(applicantId)[0].AddrLine1__c)){
                                        additionalAddressList.add(apiVerDtlMap.get(applicantId)[0].AddrLine1__c);
                                    }
                                    if(apiVerDtlMap.get(applicantId)[0].AddrLine2__c!=null && String.isNotBlank(apiVerDtlMap.get(applicantId)[0].AddrLine2__c)){
                                        additionalAddressList.add(apiVerDtlMap.get(applicantId)[0].AddrLine2__c);
                                    }
                                    if(apiVerDtlMap.get(applicantId)[0].Landmark__c!=null && String.isNotBlank(apiVerDtlMap.get(applicantId)[0].Landmark__c)){
                                        additionalAddressList.add(apiVerDtlMap.get(applicantId)[0].Landmark__c);
                                    }
                                    if(apiVerDtlMap.get(applicantId)[0].Locality__c!=null && String.isNotBlank(apiVerDtlMap.get(applicantId)[0].Locality__c)){
                                        additionalAddressList.add(apiVerDtlMap.get(applicantId)[0].Locality__c);
                                    }
                                    if(apiVerDtlMap.get(applicantId)[0].State__c!=null && String.isNotBlank(apiVerDtlMap.get(applicantId)[0].State__c)){
                                        additionalAddressList.add(apiVerDtlMap.get(applicantId)[0].State__c);
                                    }
                                    if(apiVerDtlMap.get(applicantId)[0].Pincode__c!=null && String.isNotBlank(apiVerDtlMap.get(applicantId)[0].Pincode__c)){
                                        additionalAddressList.add(apiVerDtlMap.get(applicantId)[0].Pincode__c);
                                    }
                                    
                                    apiVer.AdditionalAddr__c = !additionalAddressList.isEmpty() ? String.join(additionalAddressList,',') : '';
                                    
                                }
                                //LAK-9430 Changes End
                                apiVerList.add(apiVer);
                                
                            }
                        }
                        
                        if(integrationMessage.Trigger_Platform_Event__c){
                            publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                            platformWra.intId = integrationMessage.Id; 
                            platformWra.recId = integrationMessage.RefObj__c == 'ApplGST__c'? integrationMessage.RefId__c : integrationMessage.ParentRefObj__c == 'ApplKyc__c'? integrationMessage.ParentRefId__c : '';
                            platformWra.ServiceName = integrationMessage.Svc__c ;
                            platformWra.Status = integrationMessage.Status__c ;
                            platformWra.success=true;
                            publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                        }
                        APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
                    }    
                }
                if(!existingAPIVerList.isEmpty()){
                    IntegrationUtility.updateBooleanFlag(existingAPIVerList, 'IsLatest__c', false);
                }
                if(!apiVerList.isEmpty()){
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { APIVer__c.SObjectType });
                    uow.registerNew(apiVerList);
                    uow.commitWork();
                }
                
                if(!applGSTList.isEmpty()){
                    upsert applGSTList;
                    
                }
                if(!applKycList.isEmpty()){
                    update applKycList;
                }
                if(!apiVerDtlMap.isEmpty()){
                    createAPIVerificationDetail(apiVerDtlMap);
                }
                
                if(!docDtlIds.isEmpty()){
                    List<DocDtl__c> docDtlList =[Select Id, CreatedBY.Name,Applicant_KYC__c,DocCatgry__c,DocTyp__c,DocSubTyp__c,Applicant_KYC__r.Applicant__r.LoanAppln__c,
                                     Applicant_KYC__r.Applicant__c,Applicant_KYC__r.ValidationStatus__c,Applicant_KYC__r.OCRStatus__c,
                                     Applicant_KYC__r.AdrsSplitStatus__c,Applicant_KYC__r.AddrLine1__c,Applicant_KYC__r.AddrLine2__c,
                                     Applicant_KYC__r.Landmark__c,Applicant_KYC__r.Locality__c,Applicant_KYC__r.HouseNo__c,
                                     Applicant_KYC__r.Country__c,Applicant_KYC__r.Pincode__c,Applicant_KYC__r.City__c,
                                     Applicant_KYC__r.State__c FROM DocDtl__c WHERE Id IN:docDtlIds];
                    if(docDtlList!=null && !docDtlList.isEmpty()){
                        ApplicantUpdate au = new ApplicantUpdate();
                        au.Afterinsert(docDtlList);
                    }
                }
            }
        }
        catch(exception ex){
            system.debug('Error message: '+ ex.getMessage() + ' and Line number: ' + ex.getLineNumber());
        }
    }
    
    public static void processFailure(Map<Id,Applicant__c> applicantMap,Map<Id,Map<String,ApplGST__c>> applGSTMap,Map<Id,SObject> refMap,Map<IntgMsg__c,String> failureResponses,Map<Id,Map<String,APIVer__c>> existingAPIVerMap){
        
        try{
            
            List<ApplGST__c> applGSTList=new List<ApplGST__c>();
            List<ApplKyc__c> updateApplKycList = new List<ApplKyc__c>();
            Id recordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('GST').getRecordTypeId();
            set<Id> existingApplicantIds = new set<Id>();
            List<APIVer__c> apiVerList = new List<APIVer__c>();
            
            List<APIVer__c> existingAPIVerList = new List<APIVer__c>();
            
           	for(IntgMsg__c integrationMessage : failureResponses.keySet()){
                
                
                if(integrationMessage.RefObj__c == 'ApplGST__c' && integrationMessage.RefId__c!=null){
                    ApplGST__c applGST = new ApplGST__c();
                    applGST.Id = integrationMessage.RefId__c;
                    applGST.GSTAuthenticationStatus__c = GlobalConstants.MSG_FAILURE;
                    applGST.GSTAuthenticationErrorMessage__c = failureResponses.containsKey(integrationMessage)? failureResponses.get(integrationMessage) : '';
                    applGSTList.add(applGST);
                }
                else if(integrationMessage.ParentRefObj__c == 'ApplKyc__c' && integrationMessage.ParentRefId__c!=null){
                    ApplKyc__c applKyc = new ApplKyc__c();
                    applKyc.Id = integrationMessage.ParentRefId__c;
                    applKyc.ValidationStatus__c= GlobalConstants.MSG_FAILURE;
                    applKyc.Validation_Error_Message__c = failureResponses.containsKey(integrationMessage)? failureResponses.get(integrationMessage) : '';
                    updateApplKycList.add(applKyc);
                    
                    if(refMap.containsKey(integrationMessage.ParentRefId__c)){
                        ApplKyc__c refapplKyc = (ApplKyc__c) refMap.get(integrationMessage.ParentRefId__c);
                        ApplGST__c applGST = new ApplGST__c();
                        if(applGSTMap.containskey(applKyc.Applicant__c) && applGSTMap.get(refapplKyc.Applicant__c).containsKey(refapplKyc.GSTIN__c)){
                            applGST.Id = applGSTMap.get(applKyc.Applicant__c).get(applKyc.GSTIN__c).Id;
                        }
                        applGST.GSTAuthenticationStatus__c = GlobalConstants.MSG_FAILURE;
                        applGST.GSTAuthenticationErrorMessage__c = failureResponses.containsKey(integrationMessage)? failureResponses.get(integrationMessage) : '';
                        applGSTList.add(applGST);
                        
                    }
                }
                
                String key = integrationMessage.RefObj__c == 'ApplGST__c'? integrationMessage.RefId__c : integrationMessage.ParentRefObj__c == 'ApplKyc__c'? integrationMessage.ParentRefId__c : '';
                if(refMap.containsKey(key)){
                    APIVer__c apiVer = new APIVer__c();
                    apiVer.IntegrationStatus__c = GlobalConstants.MSG_FAILURE;
                    apiVer.IntegrationErrorMessage__c = failureResponses.containsKey(integrationMessage)? failureResponses.get(integrationMessage) : '';
                    apiVer.IsLatest__c = True;
                    apiVer.RecordTypeId = recordTypeId;
                    
                    if(integrationMessage.RefObj__c == 'ApplGST__c'){
                        ApplGST__c applGST = (ApplGST__C) refMap.get(key);
                        if(existingAPIVerMap.containsKey(applGST.Applicant__c)  &&   existingAPIVerMap.get(applGST.Applicant__c).containsKey(applGST.GSTIN__c)){
                            existingAPIVerList.add(existingAPIVerMap.get(applGST.Applicant__c).get(applGST.GSTIN__c));
                        }
                        apiVer.Appl__c = applicantMap.get(applGST.Applicant__c).Id ;
                        apiVer.LoanAplcn__c = applicantMap.get(applGST.Applicant__c).LoanAppln__c ;  
                        apiVer.ApplNme__c = applicantMap.get(applGST.Applicant__c).FullName__c ;  
                        apiVer.ApplTyp__c = applicantMap.get(applGST.Applicant__c).ApplType__c ;
                        apiVer.GSTIN__c = applGST.GSTIN__c;
                        
                        apiVer.Email__c = applGST.Email__c;
                        apiVer.ApplStatus__c = applGST.ApplStatus__c;
                        apiVer.MobNo__c = applGST.MobNo__c;
                        apiVer.Pan__c = applGST.Pan__c;
                        apiVer.GSTIN_RefId__c = applGST.GSTIN_RefId__c;
                        apiVer.Reg_Type__c = applGST.Reg_Type__c;
                        apiVer.GSTIN_Status__c = applGST.GSTIN_Status__c;
                        apiVer.RegistName__c = applGST.RegistName__c;
                        apiVer.TinNo__c = applGST.TinNo__c;
                        
                    }
                    else if(integrationMessage.ParentRefObj__c == 'ApplKyc__c'){
                        ApplKyc__c applKyc = (ApplKyc__c) refMap.get(Key);
                        if(existingAPIVerMap.containsKey(applKyc.Applicant__c)  &&   existingAPIVerMap.get(applKyc.Applicant__c).containsKey(applKyc.GSTIN__c)){
                            existingAPIVerList.add(existingAPIVerMap.get(applKyc.Applicant__c).get(applKyc.GSTIN__c));
                        }
                        apiVer.Appl__c = applicantMap.get(applKyc.Applicant__c).Id ;
                        apiVer.LoanAplcn__c = applicantMap.get(applKyc.Applicant__c).LoanAppln__c ;  
                        apiVer.ApplNme__c = applicantMap.get(applKyc.Applicant__c).FullName__c ;  
                        apiVer.ApplTyp__c = applicantMap.get(applKyc.Applicant__c).ApplType__c ;
                        apiVer.GSTIN__c = applKyc.GSTIN__c;
                    }
                    apiVerList.add(apiVer);
                }
                
                if(integrationMessage.Trigger_Platform_Event__c){
                    publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                    platformWra.intId = integrationMessage.Id; 
                    platformWra.recId = integrationMessage.RefObj__c == 'ApplGST__c'? integrationMessage.RefId__c : integrationMessage.ParentRefObj__c == 'ApplKyc__c'? integrationMessage.ParentRefId__c : '';
                    platformWra.ServiceName = integrationMessage.Svc__c ;
                    platformWra.Status = integrationMessage.Status__c ;
                    platformWra.errorMessage = failureResponses.containsKey(integrationMessage)? failureResponses.get(integrationMessage) : '';
                    publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                }
                APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
            }
            
            if(!applGSTList.isEmpty()) {
                upsert applGSTList;
            }
            if(!updateApplKycList.isEmpty()){
                update updateApplKycList;
            }
            
            if(!existingAPIVerList.isEmpty()){
                IntegrationUtility.updateBooleanFlag(existingAPIVerList, 'IsLatest__c', false);
            }
            if(!apiVerList.isEmpty()){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { APIVer__c.SObjectType });
                List<string> fieldNamesList = New List<string>{'Appl__c','RecordTypeId','LoanAplcn__c','ApplNme__c','ApplTyp__c','GSTIN__c','IsLatest__c','IntegrationStatus__c','IntegrationErrorMessage__c'};
                    String sObjectName = 'APIVer__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkInsert(objType,fieldNamesList);
                uow.registerNew(apiVerList);
                uow.commitWork();
            }
            
        }
        catch(exception ex){
            system.debug('Error message: '+ ex.getMessage() + ' and Line number: ' + ex.getLineNumber());
        }
        
    }
    
    public static void createAPIVerificationDetail(Map<String,List<APIVerDtl__c>> apiVerDtlMap){
        
        if(apiVerDtlMap!=null && !apiVerDtlMap.isEmpty()){
            Id recordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('GST').getRecordTypeId();
            Map<String,APIVer__c> apiVerMap = new Map<String,APIVer__c>();
            List<APIVerDtl__c> insertAPIVerDtlList = new List<APIVerDtl__c>();
            
            for(APIVer__c apiVer : [Select Id,IsLatest__c,Appl__c FROM APIVer__c WHERE IsLatest__c=True AND Appl__c IN :apiVerDtlMap.keySet() AND RecordTypeId =:recordTypeId]){
                apiVerMap.put(apiVer.Appl__c,apiVer);
            }
            
            for(String key : apiVerDtlMap.keySet()){
                if(apiVerDtlMap.containsKey(key) && apiVerDtlMap.get(key)!=null && !apiVerDtlMap.get(key).isEmpty()){
                    if(apiVerMap.containsKey(key)){
                        for(APIVerDtl__c apiVerDtl : apiVerDtlMap.get(key)){
                            apiVerDtl.APIVerification__c = apiVerMap.get(key).Id;
                            insertAPIVerDtlList.add(apiVerDtl);
                        }
                    }
                }
            }
            
            if(!insertAPIVerDtlList.isEmpty()){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { APIVerDtl__c.SObjectType });
                uow.registerNew(insertAPIVerDtlList);
                uow.commitWork();
            }
        }
    }
    
    @AuraEnabled
    public static void updateApplicantAddress(Id docDtlId){
        List<DocDtl__c> docDtlList =[Select Id, CreatedBY.Name,Applicant_KYC__c,DocCatgry__c,DocTyp__c,DocSubTyp__c,Applicant_KYC__r.Applicant__r.LoanAppln__c,
                                     Applicant_KYC__r.Applicant__c,Applicant_KYC__r.ValidationStatus__c,Applicant_KYC__r.OCRStatus__c,
                                     Applicant_KYC__r.AdrsSplitStatus__c,Applicant_KYC__r.AddrLine1__c,Applicant_KYC__r.AddrLine2__c,
                                     Applicant_KYC__r.Landmark__c,Applicant_KYC__r.Locality__c,Applicant_KYC__r.HouseNo__c,
                                     Applicant_KYC__r.Country__c,Applicant_KYC__r.Pincode__c,Applicant_KYC__r.City__c,
                                     Applicant_KYC__r.State__c FROM DocDtl__c WHERE Id =:docDtlId];
        if(docDtlList!=null && !docDtlList.isEmpty()){
            ApplicantUpdate au = new ApplicantUpdate();
            au.Afterinsert(docDtlList);
        }
    }
}