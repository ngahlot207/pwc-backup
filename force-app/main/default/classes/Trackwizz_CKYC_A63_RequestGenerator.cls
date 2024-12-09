public class Trackwizz_CKYC_A63_RequestGenerator implements ICalloutRequestGenerator {
    public void generate(List<IntgMsg__c> msgs,String service,String processType) {
        try {
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType>{ IntgMsg__c.SObjectType } );
            if(!msgs.isEmpty()) {

                Set<String> applIds = new Set<String>();
                List<IntgMsg__c> updateIntrecods = new List<IntgMsg__c>();
                Map<Id, Applicant__c> applRecordsMap = new Map<Id, Applicant__c>();
                Map<Id, List<DocDtl__c>> applyDocDtMap = new Map<Id, List<DocDtl__c>>();
                Map<Id, List<ApplKyc__c>> applyKYCMap = new Map<Id, List<ApplKyc__c>>();
                Map<Id, List<ApplAddr__c>> applyAddrMap = new Map<Id, List<ApplAddr__c>>();
                Set<String> userIdSet = new Set<String>();
                Set<String> branchCdSet = new Set<String>();
                Map<Id, String> kycEmpDesgMap = new Map<Id, String>();
                Map<String, String> bbmMap = new Map<String, String>();
                Map<String, List<Map<String, String>>> masterDataMap = new Map<String, List<Map<String, String>>>();
                Map<String, Map<Id, List<sObject>>> applRelRecsMap = new Map<String, Map<Id, List<sObject>>>();
                Set<String> masterDataKey = new Set<String>();
                Set<String> finnVal = new Set<String>();
                //Utilities
                Map<String, String> kycDocMap = new Map<String, String>();//{'Aadhaar' => 'AadharCard', 'Voter ID' => 'VoterID','Voter Id' => 'VoterID', 'Passport' => 'Passport', 'Driving license' => 'DrivingLicense','Driving License' => 'DrivingLicense', 'PAN' => 'PanCard','Pan' => 'PanCard', 'Letter issued by the National Population Register' => 'NPRLetter', 'Certificate of incorporation' => 'CIN', 'Electricity Bill' => 'UtilityBill2m', 'Post-paid mobile phone bill' => 'UtilityBill2m', 'Telephone Bill' => 'UtilityBill2m'};
                Map<String, String> proofIdSubMap = new Map<String, String>();//{'Partnership deed' => 'PD', 'MOA' => 'MOA', 'Certificate of incorporation' => 'CIN', 'Trust / Society Deed' => 'TRUSTDEED'};
                
                for(MasterData__c masterdata : [Select Id,Type__c,SalesforceCode__c, Trackwizzcode__c, Trackwizzval__c from MasterData__c where Type__c IN ('Trackwizz Proof of ID Master','Trackwizz KYC Master')]){
                    if(masterdata.Type__c == 'Trackwizz KYC Master'){
                        kycDocMap.put(masterdata.SalesforceCode__c,masterdata.Trackwizzcode__c);
                    }
                    else if(masterdata.Type__c == 'Trackwizz Proof of ID Master'){
                        proofIdSubMap.put(masterdata.SalesforceCode__c,masterdata.Trackwizzcode__c);
                    }
                }
                
                
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('CKYC_API');

                for(IntgMsg__c intMsgRec : msgs) {
                    if(intMsgRec.RefObj__c != NULL && intMsgRec.RefObj__c == 'Applicant__c' && intMsgRec.RefId__c != NULL) {
                        applIds.add(intMsgRec.RefId__c);
                    }
                }

                if(!applIds.isEmpty()) {
                    applRecordsMap = getCKYCApplData(applIds, 'generateRequest');
                    applRelRecsMap = getCKYCApplRelData(applIds, 'generateRequest');
                    if(!applRelRecsMap.isEmpty()) {
                        if(applRelRecsMap.containsKey('DocDtl__c') && !applRelRecsMap.get('DocDtl__c').isEmpty()) {
                            applyDocDtMap = (Map<Id, List<DocDtl__c>>)applRelRecsMap.get('DocDtl__c');
                        }
                        if(applRelRecsMap.containsKey('ApplKyc__c') && !applRelRecsMap.get('ApplKyc__c').isEmpty()) {
                            applyKYCMap = (Map<Id, List<ApplKyc__c>>)applRelRecsMap.get('ApplKyc__c');
                        }
                        if(applRelRecsMap.containsKey('ApplAddr__c') && !applRelRecsMap.get('ApplAddr__c').isEmpty()) {
                            applyAddrMap = (Map<Id, List<ApplAddr__c>>)applRelRecsMap.get('ApplAddr__c');
                        }
                    }
                    masterDataKey = getApplAddrState(applIds, 'generateRequest');
                }

                if(!applRecordsMap.isEmpty()) {
                    Map<String, Set<String>> utilitySetMap = getUtilitySets(applRecordsMap);
                    if(!utilitySetMap.isEmpty()) {
                        if(utilitySetMap.containsKey('userIdSet') && !utilitySetMap.get('userIdSet').isEmpty()) {
                            userIdSet = utilitySetMap.get('userIdSet');
                        }
                        if(utilitySetMap.containsKey('branchCdSet') && !utilitySetMap.get('branchCdSet').isEmpty()) {
                            branchCdSet = utilitySetMap.get('branchCdSet');
                        }
                        if(utilitySetMap.containsKey('finnVal') && !utilitySetMap.get('finnVal').isEmpty()) {
                            finnVal = utilitySetMap.get('finnVal');
                        }
                    }
                }

                if(!userIdSet.isEmpty()) {
                    kycEmpDesgMap = getTeamHierData(userIdSet);
                }

                if(!branchCdSet.isEmpty()) {
                    bbmMap = getBankBrnMastData(branchCdSet);
                }
                
                masterDataMap = fetchMasterObjData(masterDataKey, finnVal);
                
                for (IntgMsg__c intMsgRec : msgs) {
                    if (applRecordsMap.containsKey(intMsgRec.RefId__c)) {

                        Applicant__c applyVar = applRecordsMap.get(intMsgRec.RefId__c);

                        Trackwizz_CKYC_A63_RequestWrapper.RecordRequestDetailClass recdReqDetVar = new Trackwizz_CKYC_A63_RequestWrapper.RecordRequestDetailClass();
                        recdReqDetVar.TransactionId = intMsgRec.Integration_Message_Number__c + applyVar.LoanAppln__r.Name; 
                        recdReqDetVar.SourceSystemName = svc.SourceSystem__c;
                        recdReqDetVar.SourceSystemCustomerCode = applyVar.UCID__c != NULL ? String.valueOf(applyVar.UCID__c) : '';
                        recdReqDetVar.IsSmallCustomer = GlobalConstants.IsSmallCustomer;
                        recdReqDetVar.EkycOTPBased = GlobalConstants.EkycOTPBased;  
                        Date disbDate = applyVar.LoanAppln__r.DisbursementDate__c;
                        recdReqDetVar.SourceSystemCustomerCreationDate = disbDate != NULL ? dateUtility(disbDate.day(), disbDate.month(), disbDate.year()) : '';
                        //recdReqDetVar.RecordIdentifier = applyVar.UCID__c != NULL ? applyVar.UCID__c : '';
                        recdReqDetVar.RecordIdentifier = '';

                        //Segments Tag
                        Trackwizz_CKYC_A63_RequestWrapper.SegmentsClass segmentsVar = new Trackwizz_CKYC_A63_RequestWrapper.SegmentsClass();
                        recdReqDetVar.Segments = segmentsVar;
                            
                        //ProductSegments Tag
                        Trackwizz_CKYC_A63_RequestWrapper.ProductSegmentsClass prodSegmentsVar = new Trackwizz_CKYC_A63_RequestWrapper.ProductSegmentsClass();
                        recdReqDetVar.ProductSegments = prodSegmentsVar;

                        //CustomerStatus Tag
                        Trackwizz_CKYC_A63_RequestWrapper.CustomerStatusClass custStatusVar = new Trackwizz_CKYC_A63_RequestWrapper.CustomerStatusClass();
                            
                        //StatusDetail Tag
                        Trackwizz_CKYC_A63_RequestWrapper.StatusDetailClass statusDetVar = new Trackwizz_CKYC_A63_RequestWrapper.StatusDetailClass();
                        //Date loginAccDate = applyVar.LoanAppln__r.LoginAcceptDate__c != NULL ? applyVar.LoanAppln__r.LoginAcceptDate__c : NULL;
                        statusDetVar.Status = GlobalConstants.Status;
                        //statusDetVar.EffectiveDate = loginAccDate != NULL ? dateUtility(loginAccDate.day(),loginAccDate.month(),loginAccDate.year()) : '';
                        statusDetVar.EffectiveDate = disbDate != NULL ? dateUtility(disbDate.day(),disbDate.month(),disbDate.year()) : '';
                            
                        custStatusVar.StatusDetail = statusDetVar;
                        recdReqDetVar.CustomerStatus = custStatusVar;
                        
                        recdReqDetVar.CustomerType = applyVar.Constitution__c != NULL ? masterDataMapUtility(masterDataMap, 'Constitution', applyVar.Constitution__c) : '';
                        recdReqDetVar.CustomerSubType = '';

                        recdReqDetVar.Prefix = applyVar.Constitution__c != NULL && applyVar.Constitution__c == 'INDIVIDUAL' && applyVar.Title__c != NULL && applyVar.FName__c != NULL ? applyVar.Title__c.removeEnd('.') : '';
                        recdReqDetVar.FirstName = (applyVar.Constitution__c != NULL && applyVar.Constitution__c == 'INDIVIDUAL' && applyVar.FName__c != NULL) ? applyVar.FName__c : (applyVar.Constitution__c != NULL && applyVar.Constitution__c != 'INDIVIDUAL' && applyVar.FullName__c != NULL) ? applyVar.FullName__c : '';
                        recdReqDetVar.MiddleName = applyVar.Constitution__c != NULL && applyVar.Constitution__c == 'INDIVIDUAL' && applyVar.MName__c != NULL ? applyVar.MName__c : '';
                        recdReqDetVar.LastName = applyVar.Constitution__c != NULL && applyVar.Constitution__c == 'INDIVIDUAL' && applyVar.LName__c != NULL ? applyVar.LName__c : '';
                        recdReqDetVar.FatherPrefix = applyVar.Constitution__c != NULL && applyVar.Constitution__c == 'INDIVIDUAL' && applyVar.Father_Name__c != NULL ? GlobalConstants.FatherPrefix : '';
                        recdReqDetVar.FatherFirstName = applyVar.Constitution__c != NULL && applyVar.Constitution__c == 'INDIVIDUAL' && applyVar.Father_Name__c != NULL? applyVar.Father_Name__c : '';
                        recdReqDetVar.FatherMiddleName = '';
                        recdReqDetVar.FatherLastName = '';
                        recdReqDetVar.MaidenPrefix = applyVar.Constitution__c != NULL && applyVar.Constitution__c == 'INDIVIDUAL' && applyVar.MthrMdnName__c != NULL ? GlobalConstants.MotherPrefix : '';
                        recdReqDetVar.MaidenFirstName = applyVar.Constitution__c != NULL && applyVar.Constitution__c == 'INDIVIDUAL' && applyVar.MthrMdnName__c != NULL ? applyVar.MthrMdnName__c : '';
                        recdReqDetVar.MaidenMiddleName = '';
                        recdReqDetVar.MaidenLastName = '';
                        recdReqDetVar.MotherPrefix = applyVar.Constitution__c != NULL && applyVar.Constitution__c == 'INDIVIDUAL' && applyVar.MthrMdnName__c != NULL ? GlobalConstants.MotherPrefix : '';
                        recdReqDetVar.MotherFirstName = applyVar.Constitution__c != NULL && applyVar.Constitution__c == 'INDIVIDUAL' && applyVar.MthrMdnName__c != NULL ? applyVar.MthrMdnName__c : '';
                        recdReqDetVar.MotherMiddleName = '';
                        recdReqDetVar.MotherLastName = '';

                        String spousePfx;
                        if(applyVar.MariStatus__c != NULL && (applyVar.MariStatus__c == 'M' || applyVar.MariStatus__c == 'W')) {
                            if(applyVar.Title__c != NULL) {
                                if(applyVar.Title__c == 'Mr.') {
                                    spousePfx = 'Mrs';
                                }
                                else if(applyVar.Title__c == 'Mrs.') {
                                    spousePfx = 'Mr';
                                }
                            }
                        }
                        recdReqDetVar.SpousePrefix = applyVar.Constitution__c != NULL && applyVar.Constitution__c == 'INDIVIDUAL' && spousePfx != NULL && applyVar.SpName__c != NULL ? spousePfx : '';
                        recdReqDetVar.SpouseFirstName = applyVar.Constitution__c != NULL && applyVar.Constitution__c == 'INDIVIDUAL' && spousePfx != NULL && applyVar.SpName__c != NULL ? applyVar.SpName__c  : '';
                        recdReqDetVar.SpouseMiddleName = '';
                        recdReqDetVar.SpouseLastName = '';
                        recdReqDetVar.Gender = applyVar.Constitution__c != NULL && applyVar.Constitution__c == 'INDIVIDUAL' && applyVar.Gender__c != NULL ? applyVar.Gender__c : '';
                        
                        Id permAddId, corresAddId;
                        if(!applyAddrMap.isEmpty() && applyAddrMap.containsKey(applyVar.Id) && !applyAddrMap.get(applyVar.Id).isEmpty()) {
                            
                            if(applyVar.Constitution__c != NULL) {
                                if(applyVar.Constitution__c.equalsIgnoreCase('INDIVIDUAL')) {
                                    for(ApplAddr__c add : applyAddrMap.get(applyVar.Id)) {
                                        if(add.AddrTyp__c != NULL) {
                                            if(add.AddrTyp__c.equalsIgnoreCase('Permanent Address')) {
                                                permAddId = add.Id;
                                                break;
                                            }
                                            else if(add.AddrTyp__c.equalsIgnoreCase('Residence Address')) {
                                                permAddId = add.Id;
                                                break;
                                            }
                                        }
                                    }
                                    if(permAddId != NULL) {
                                        for(ApplAddr__c add : applyAddrMap.get(applyVar.Id)) {
                                            if(add.AddrTyp__c != NULL && add.Id != permAddId && add.MailAddr__c == TRUE) {
                                                corresAddId = add.Id; 
                                            }
                                        }
                                    }
                                }
                                else if(!applyVar.Constitution__c.equalsIgnoreCase('INDIVIDUAL')) {
                                   for(ApplAddr__c add : applyAddrMap.get(applyVar.Id)) {
                                        if(add.AddrTyp__c != NULL) {
                                            if(add.AddrTyp__c.equalsIgnoreCase('Principal place for business')) {
                                                permAddId = add.Id;
                                                break;
                                            }
                                            else if(add.AddrTyp__c.equalsIgnoreCase('Registered place for business')) {
                                                permAddId = add.Id;
                                                break;
                                            }
                                        }
                                    } 
                                    if(permAddId != NULL) {
                                        for(ApplAddr__c add : applyAddrMap.get(applyVar.Id)) {
                                            if(add.AddrTyp__c != NULL && add.Id != permAddId && add.MailAddr__c == TRUE) {
                                                corresAddId = add.Id; 
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        if(permAddId != NULL && corresAddId == NULL) {
                            corresAddId = permAddId;
                        }
                        
                        Map<String, ApplAddr__c> addrMap = new Map<String, ApplAddr__c>();
                        
                        if(!applyAddrMap.isEmpty() && applyAddrMap.containsKey(applyVar.Id) && !applyAddrMap.get(applyVar.Id).isEmpty()) {
                            for(ApplAddr__c add : applyAddrMap.get(applyVar.Id)) {
                                if(permAddId != NULL && corresAddId != NULL) {
                                    if(corresAddId == permAddId && add.Id == permAddId) {
                                        addrMap.put('Permanent', add);
                                        addrMap.put('Correspondence', add);
                                        break; 
                                    }
                                    else if(corresAddId != permAddId) {
                                        if(add.Id == permAddId) {
                                            addrMap.put('Permanent', add);
                                        }
                                        else if(add.Id == corresAddId) {
                                            addrMap.put('Correspondence', add);
                                        }
                                    }
                                }
                            }
                        }
                        
                        //AddressDetails Tag
                        Trackwizz_CKYC_A63_RequestWrapper.AddressDetailsClass addrDet = new Trackwizz_CKYC_A63_RequestWrapper.AddressDetailsClass();
                        List<Trackwizz_CKYC_A63_RequestWrapper.AddressDetailClass> addrDetList = new List<Trackwizz_CKYC_A63_RequestWrapper.AddressDetailClass>();
                        if(!addrMap.isEmpty()) {
                            for(String tempKey : addrMap.keySet()) {
                                Trackwizz_CKYC_A63_RequestWrapper.AddressDetailClass addrDetVarPer = new Trackwizz_CKYC_A63_RequestWrapper.AddressDetailClass();
                                
                                ApplAddr__c add = addrMap.get(tempKey);
                                String addStr = '';
                                if(add.AddrLine1__c != NULL && add.AddrLine2__c != NULL) {
                                    if(add.AddrLine1__c.equalsIgnoreCase(add.AddrLine2__c)) {
                                        addStr += add.AddrLine1__c;
                                    }
                                    else {
                                        addStr += add.AddrLine1__c + ' ' + add.AddrLine2__c;
                                    }
                                }
                                else if(add.AddrLine1__c != NULL && add.AddrLine2__c == NULL) {
                                    addStr += add.AddrLine1__c;
                                }
                                else if(add.AddrLine1__c == NULL && add.AddrLine2__c != NULL) {
                                    addStr += add.AddrLine2__c;
                                }
                                
                                if(add.Landmark__c != NULL && String.isNotBlank(addStr)) {
                                    addStr = addStr + ' ' + add.Landmark__c;
                                }
                                // else {
                                //     addStr += add.Landmark__c;
                                // }
                                
                                if(tempKey == 'Permanent') {
                                    addrDetVarPer.AddressType = 'Permanent';
                                }
                                else {
                                    addrDetVarPer.AddressType = 'Correspondence';
                                }
                                
                                String addLine1 = '', addLine2 = '', addLine3 = '';
                                if(String.isNotBlank(addStr)) {
                                    if(addStr.length() > 100) {
                                        addLine1 = addStr.substring(0,50);
                                        addLine2 = addStr.substring(50,100);
                                        addLine3 = addStr.substring(100, addStr.length());
                                    }
                                    else if(addStr.length() > 50 && addStr.length() <= 100) {
                                        addLine1 = addStr.substring(0,50);
                                        addLine2 = addStr.substring(50,addStr.length());
                                    }
                                    else if(addStr.length() <= 50) {
                                        addLine1 = addStr.substring(0,addStr.length());
                                    }
                                }
                                addrDetVarPer.PlotnoSurveynoHouseFlatno = add.HouseNo__c != NULL ? add.HouseNo__c : '';
                                addrDetVarPer.AddressLine1 = addLine1;
                                addrDetVarPer.AddressLine2 = addLine2;
                                addrDetVarPer.AddressLine3 = addLine3;
                                addrDetVarPer.PinCode = add.Pincode__c != NULL ? add.Pincode__c : '';
                                addrDetVarPer.City = add.City__c != NULL ? add.City__c : '';
                                addrDetVarPer.Country = 'IN';
                                addrDetVarPer.District = add.City__c != NULL ? add.City__c : '';
                                addrDetVarPer.State = add.State__c != NULL ? (String.isNotBlank(masterDataMapUtility(masterDataMap, 'Trackwizz State Master', add.State__c)) ? masterDataMapUtility(masterDataMap, 'Trackwizz State Master', add.State__c) : 'XX') : '';
                                
                                addrDetList.add(addrDetVarPer);
                            }
                        }
                        
                        if(!addrDetList.isEmpty()) {
                            addrDet.AddressDetail = addrDetList;
                            recdReqDetVar.AddressDetails = addrDet;
                        }
                        else {
                            recdReqDetVar.AddressDetails = addrDet;
                        }

                        Integer formSixtyVar = 1;
                        String permDoc, corresAddDoc, proofIdSubmVar;
                        Date kycDt;
                        if(!applyDocDtMap.isEmpty() && applyDocDtMap.containsKey(applyVar.Id) && !applyDocDtMap.get(applyVar.Id).isEmpty()) {
                            for(DocDtl__c dd : applyDocDtMap.get(applyVar.Id)) {
                                if(dd.DocCatgry__c != NULL && dd.DocCatgry__c.equalsIgnoreCase('PAN Documents')) {
                                    if(dd.DocTyp__c != NULL && (dd.DocTyp__c.equalsIgnoreCase('PAN') )) {//|| dd.DocTyp__c.equalsIgnoreCase('Form 60')
                                        formSixtyVar = 0;
                                    }
                                }
                                else if(dd.DocCatgry__c != NULL && dd.DocCatgry__c.equalsIgnoreCase('KYC Documents') && applyVar.Constitution__c != NULL && applyVar.Constitution__c.equalsIgnoreCase('INDIVIDUAL')) {
                                    if(dd.DocTyp__c != NULL && dd.DocTyp__c.equalsIgnoreCase('Residence Address proof - OVD') && dd.DocSubTyp__c != NULL && kycDocMap.containsKey(dd.DocSubTyp__c) && permDoc == NULL && corresAddDoc == NULL) {
                                        permDoc = kycDocMap.get(dd.DocSubTyp__c);
                                        corresAddDoc = kycDocMap.get(dd.DocSubTyp__c);
                                        kycDt = dd.CreatedDate.date();
                                    }
                                }
                                else if(dd.DocCatgry__c != NULL && dd.DocCatgry__c.equalsIgnoreCase('KYC Documents') && applyVar.Constitution__c != NULL && !applyVar.Constitution__c.equalsIgnoreCase('INDIVIDUAL')) {
                                    if(dd.DocTyp__c != NULL && ((dd.DocTyp__c.equalsIgnoreCase('Constitution wise Mandatory KYC documents') && dd.DocSubTyp__c != NULL && kycDocMap.containsKey(dd.DocSubTyp__c)) || dd.DocTyp__c.equalsIgnoreCase('Principal Place of Business - Address Proof')) && permDoc == NULL) {
                                        if(dd.DocTyp__c.equalsIgnoreCase('Constitution wise Mandatory KYC documents')) {
                                            permDoc = kycDocMap.get(dd.DocSubTyp__c);
                                        }
                                        else {
                                            permDoc = 'Others';
                                        }
                                        kycDt = dd.CreatedDate.date();
                                    }
                                    else if(dd.DocTyp__c != NULL && dd.DocTyp__c.equalsIgnoreCase('Registered office - Address Proof') && dd.DocSubTyp__c != NULL && kycDocMap.containsKey(dd.DocSubTyp__c) && corresAddDoc == NULL) {
                                        corresAddDoc = kycDocMap.get(dd.DocSubTyp__c);
                                    }
                                }

                                if(dd.DocCatgry__c != NULL && dd.DocCatgry__c.equalsIgnoreCase('KYC Documents') && dd.DocTyp__c != NULL && dd.DocTyp__c.equalsIgnoreCase('Constitution wise Mandatory KYC documents') && dd.DocSubTyp__c != NULL && proofIdSubMap.containsKey(dd.DocSubTyp__c) && proofIdSubmVar == NULL) {
                                    proofIdSubmVar = proofIdSubMap.get(dd.DocSubTyp__c);
                                }
                            }
                        }
                        recdReqDetVar.FormSixty = formSixtyVar;
                        recdReqDetVar.PermanentAddressProof = permDoc != NULL ? permDoc : '';
                        recdReqDetVar.CorrespondenceAddressProof = corresAddDoc != NULL ? corresAddDoc : '';

                        //recdReqDetVar.KYCDateOfDeclaration = kycDt != NULL ? dateUtility(kycDt.day(), kycDt.month(), kycDt.year()) : '';
                        recdReqDetVar.KYCDateOfDeclaration = disbDate != NULL ? dateUtility(disbDate.day(), disbDate.month(), disbDate.year()) : '';
                        recdReqDetVar.KYCPlaceOfDeclaration = !bbmMap.isEmpty() && applyVar.LoanAppln__r.BrchCode__c != NULL && bbmMap.containsKey(applyVar.LoanAppln__r.BrchCode__c) ? bbmMap.get(applyVar.LoanAppln__r.BrchCode__c) : '';
                        recdReqDetVar.KYCVerificationDate = kycDt != NULL ? dateUtility(kycDt.day(), kycDt.month(), kycDt.year()) : '';
                        recdReqDetVar.KYCEmployeeName = applyVar.LoanAppln__r.RM__c != NULL ? applyVar.LoanAppln__r.RM__c : '';
                        //recdReqDetVar.KYCEmployeeDesignation = applyVar.LoanAppln__r.RMSMName__c != NULL && !kycEmpDesgMap.isEmpty() && kycEmpDesgMap.containsKey(applyVar.LoanAppln__r.RMSMName__c) && kycEmpDesgMap.get(applyVar.LoanAppln__r.RMSMName__c) != NULL ? kycEmpDesgMap.get(applyVar.LoanAppln__r.RMSMName__c) : '';
                        recdReqDetVar.KYCEmployeeDesignation = 'SALES MANAGER';
                        recdReqDetVar.KYCVerificationBranch = applyVar.LoanAppln__r.BrchName__c != NULL ? applyVar.LoanAppln__r.BrchName__c : '';
                        recdReqDetVar.KYCEmployeeCode = applyVar.LoanAppln__r.RMSMEmployeeID__c != NULL ? applyVar.LoanAppln__r.RMSMEmployeeID__c : '';

                        APIVer__c apiVer = !applyVar.API_Verifications__r.isEmpty() ? applyVar.API_Verifications__r[0] : NULL;
                        Date riskDt = apiVer != NULL ? apiVer.CreatedDate.date() : NULL;
                        
                        recdReqDetVar.RegulatoryAMLRisk = apiVer != NULL && apiVer.Risk_Rating_Final__c != NULL ? apiVer.Risk_Rating_Final__c : '';
                        Date lastReviewDate;
                        if(riskDt != NULL) {
                            lastReviewDate = riskDt;
                        }
                        else {
                            Date currentDate = Date.today();
                            Integer month = currentDate.month();
                            Integer year = currentDate.year();
                            Integer lastQuartMonth, lastQuartYear, lastQuartDay;
                            if(month >= 1 && month <= 3) {
                                lastQuartDay = 31;
                                lastQuartMonth = 12;
                                lastQuartYear = year - 1;
                            }
                            else if(month >= 4 && month <= 6) {
                                lastQuartDay = 31;
                                lastQuartMonth = 3;
                                lastQuartYear = year;
                            }
                            else if(month >= 7 && month <= 9) {
                                lastQuartDay = 30;
                                lastQuartMonth = 6;
                                lastQuartYear = year;
                            }
                            else if(month >= 10 && month <= 12) {
                                lastQuartDay = 30;
                                lastQuartMonth = 9;
                                lastQuartYear = year;
                            }
                            lastReviewDate = Date.newInstance(lastQuartYear, lastQuartMonth, lastQuartDay);
                        }
                        recdReqDetVar.LastRiskReviewDate = lastReviewDate != NULL ? dateUtility(lastReviewDate.day(), lastReviewDate.month(), lastReviewDate.year()) : '';
                        //recdReqDetVar.NextRiskReviewDate = riskDtNxtQrt != NULL ? dateUtility(riskDtNxtQrt.day(), riskDtNxtQrt.month(), riskDtNxtQrt.year()) : '';
                        recdReqDetVar.NextRiskReviewDate = '';

                        recdReqDetVar.KYCAttestationType = '01';

                        String maritStatus;
                        if(applyVar.MariStatus__c != NULL) {
                            if (applyVar.MariStatus__c == 'M') {
                                maritStatus = 'M';
                            } 
                            else if (applyVar.MariStatus__c == 'S') {
                                maritStatus = 'U';
                            } 
                            else if (applyVar.MariStatus__c == 'W') {
                                maritStatus = 'O';
                            }
                        }
                            
                        recdReqDetVar.MaritalStatus = applyVar.Constitution__c != NULL && applyVar.Constitution__c == 'INDIVIDUAL' && maritStatus != NULL ? maritStatus : '';

                        //EducationalQualificationDetails Tag
                        Trackwizz_CKYC_A63_RequestWrapper.EducationalQualificationDetailsClass eduQual = new Trackwizz_CKYC_A63_RequestWrapper.EducationalQualificationDetailsClass();
                            
                        //EducationalQualificationDetail Tag
                        List<Trackwizz_CKYC_A63_RequestWrapper.EducationalQualificationDetailClass> eduQualList = new List<Trackwizz_CKYC_A63_RequestWrapper.EducationalQualificationDetailClass>();
                        Trackwizz_CKYC_A63_RequestWrapper.EducationalQualificationDetailClass eduQualVar = new Trackwizz_CKYC_A63_RequestWrapper.EducationalQualificationDetailClass();
                        eduQualVar.EducationalQualification = applyVar.EduQual__c != NULL ? applyVar.EduQual__c : '';
                        eduQualList.add(eduQualVar);
                        eduQual.EducationalQualificationDetail = eduQualList;
                        recdReqDetVar.EducationalQualificationDetails = eduQual;

                        //Citizenship Tag
                        Trackwizz_CKYC_A63_RequestWrapper.CitizenshipClass citizen = new Trackwizz_CKYC_A63_RequestWrapper.CitizenshipClass();
                            
                        //CountryDetail Tag
                        Trackwizz_CKYC_A63_RequestWrapper.CountryDetailClass countryDet = new Trackwizz_CKYC_A63_RequestWrapper.CountryDetailClass();
                        countryDet.Country = GlobalConstants.Country;
                        citizen.CountryDetail = countryDet;
                        recdReqDetVar.Citizenship = citizen;
                            
                        recdReqDetVar.CountryOfResidence = GlobalConstants.Country;
                        recdReqDetVar.OccupationType = '';

                        //ActivitySectorDetails Tag
                        Trackwizz_CKYC_A63_RequestWrapper.ActivitySectorDetailsClass activDet = new Trackwizz_CKYC_A63_RequestWrapper.ActivitySectorDetailsClass();
                        recdReqDetVar.ActivitySectorDetails = activDet;

                        recdReqDetVar.NatureOfBusinessOther = '';

                        //NatureOfBusiness Tag
                        Trackwizz_CKYC_A63_RequestWrapper.NatureOfBusinessClass natOfBus = new Trackwizz_CKYC_A63_RequestWrapper.NatureOfBusinessClass();
                        recdReqDetVar.NatureOfBusiness = natOfBus;

                        Date dobVar = (applyVar.Constitution__c != NULL && applyVar.Constitution__c == 'INDIVIDUAL' && applyVar.DOB__c != NULL) ? applyVar.DOB__c : (applyVar.Constitution__c != NULL && applyVar.Constitution__c != 'INDIVIDUAL' && applyVar.DOI__c != NULL) ? applyVar.DOI__c : NULL;
                        recdReqDetVar.DateofBirth = dobVar != NULL ? dateUtility(dobVar.day(),dobVar.month(),dobVar.year()) : '';

                        //EmailDetails Tag
                        Trackwizz_CKYC_A63_RequestWrapper.EmailDetailsClass emlDet = new Trackwizz_CKYC_A63_RequestWrapper.EmailDetailsClass();
                        List<Trackwizz_CKYC_A63_RequestWrapper.EmailDetailClass> emlDetList = new List<Trackwizz_CKYC_A63_RequestWrapper.EmailDetailClass>();
                        if(applyVar.EmailId__c != NULL) {
                            
                            Trackwizz_CKYC_A63_RequestWrapper.EmailDetailClass emlDetVarPer = new Trackwizz_CKYC_A63_RequestWrapper.EmailDetailClass();
                            emlDetVarPer.EmailType = 'Personal';
                            emlDetVarPer.EmailId = applyVar.EmailId__c;
                            emlDetVarPer.Disabled = 0;
                            emlDetList.add(emlDetVarPer);
                        }
                        if(!applyVar.Applicant_Employments__r.isEmpty()) {
                            ApplicantEmployment__c temp = applyVar.Applicant_Employments__r[0];
                            if(temp.OfficialEmail__c != NULL) {
                                
                                Trackwizz_CKYC_A63_RequestWrapper.EmailDetailClass emlDetVarPer = new Trackwizz_CKYC_A63_RequestWrapper.EmailDetailClass();
                                emlDetVarPer.EmailType = 'Work';
                                emlDetVarPer.EmailId = temp.OfficialEmail__c;
                                emlDetVarPer.Disabled = 0;
                                emlDetList.add(emlDetVarPer);
                            }
                        }
                        
                        emlDet.EmailDetail = emlDetList;
                        recdReqDetVar.EmailDetails = emlDet;

                        //recdReqDetVar.CommencementDate = applyVar.DOI__c != NULL ? dateUtility(applyVar.DOI__c.day(),applyVar.DOI__c.month(), applyVar.DOI__c.year()) : '';
                        recdReqDetVar.CommencementDate = applyVar.Constitution__c != NULL && applyVar.Constitution__c != 'INDIVIDUAL' && applyVar.DOI__c != NULL ? dateUtility(applyVar.DOI__c.day(),applyVar.DOI__c.month(), applyVar.DOI__c.year()) : '';
                        recdReqDetVar.PermanentAddressProofOthersValue = '';
                        recdReqDetVar.RelatedPersonCountForCKYC = 0;
                        recdReqDetVar.CountryOfBirth = 'IN';
                        recdReqDetVar.BirthCity = applyVar.CurrentResidenceCity__City__s != NULL ? applyVar.CurrentResidenceCity__City__s : '';

                        //TaxIdentificationDetails Tag
                        Trackwizz_CKYC_A63_RequestWrapper.TaxIdentificationDetailsClass taxVar = new Trackwizz_CKYC_A63_RequestWrapper.TaxIdentificationDetailsClass();
                        recdReqDetVar.TaxIdentificationDetails = taxVar;

                        //ContactDetails Tag
                        Trackwizz_CKYC_A63_RequestWrapper.ContactDetailsClass conDetl = new Trackwizz_CKYC_A63_RequestWrapper.ContactDetailsClass();
                            
                        //ContactDetail Tag
                        Trackwizz_CKYC_A63_RequestWrapper.ContactDetailClass conDetlVar = new Trackwizz_CKYC_A63_RequestWrapper.ContactDetailClass();
                        if(applyVar.MobNumber__c != NULL) {
                            conDetlVar.ContactType = 'TW03';
                            conDetlVar.ISDCode = '91';
                            conDetlVar.ContactNumber = String.valueOf(applyVar.MobNumber__c);
                            conDetlVar.Disabled = 0;
                            conDetl.ContactDetail = conDetlVar;
                        }
                        recdReqDetVar.ContactDetails = conDetl;

                        //IdentificationDetails Tag
                        Trackwizz_CKYC_A63_RequestWrapper.IdentificationDetailsClass ident = new Trackwizz_CKYC_A63_RequestWrapper.IdentificationDetailsClass();
                            
                        //IdentificationDetail Tag
                        List<Trackwizz_CKYC_A63_RequestWrapper.IdentificationDetailClass> identList = new List<Trackwizz_CKYC_A63_RequestWrapper.IdentificationDetailClass>();

                        if(!applyKYCMap.isEmpty() && applyKYCMap.containsKey(applyVar.Id) && !applyKYCMap.get(applyVar.Id).isEmpty()) {
                            List<ApplKyc__c> applyKYCList = applyKYCMap.get(applyVar.Id);
                            
                            for(ApplKyc__c tempRec : applyKYCList) {
                                
                                if(tempRec.kycDoc__c != NULL && kycDocMap.containsKey(tempRec.kycDoc__c)) {
                                   
                                    if(tempRec.kycDoc__c.equalsIgnoreCase('Passport') && tempRec.PassNo__c != NULL && tempRec.PassExpDt__c != NULL) {
                                        Trackwizz_CKYC_A63_RequestWrapper.IdentificationDetailClass identVar = new Trackwizz_CKYC_A63_RequestWrapper.IdentificationDetailClass();
                                        identVar.IdType = kycDocMap.get(tempRec.kycDoc__c);
                                        identVar.IdNumber = tempRec.PassNo__c;
                                        identVar.ExpiryDate = dateUtility(tempRec.PassExpDt__c.day(),tempRec.PassExpDt__c.month(), tempRec.PassExpDt__c.year());
                                        identList.add(identVar);
                                    }
                                    else if(tempRec.kycDoc__c.equalsIgnoreCase('Driving License') && tempRec.DLNo__c != NULL && tempRec.DLExpDt__c != NULL) {
                                        Trackwizz_CKYC_A63_RequestWrapper.IdentificationDetailClass identVar = new Trackwizz_CKYC_A63_RequestWrapper.IdentificationDetailClass();
                                        identVar.IdType = kycDocMap.get(tempRec.kycDoc__c);
                                        identVar.IdNumber = tempRec.DLNo__c;
                                        identVar.ExpiryDate = dateUtility(tempRec.DLExpDt__c.day(), tempRec.DLExpDt__c.month(), tempRec.DLExpDt__c.year());
                                        identList.add(identVar);
                                    }
                                    else if(tempRec.kycDoc__c.equalsIgnoreCase('Aadhaar') && tempRec.AadharNo__c != NULL && tempRec.AadharNo__c.length() == 12) {
                                        Trackwizz_CKYC_A63_RequestWrapper.IdentificationDetailClass identVar = new Trackwizz_CKYC_A63_RequestWrapper.IdentificationDetailClass();
                                        identVar.IdType = kycDocMap.get(tempRec.kycDoc__c);
                                        String last4Digits = tempRec.AadharNo__c.substring(8);
                                        identVar.IdNumber = last4Digits;
                                        identList.add(identVar);
                                    }
                                    else if(tempRec.kycDoc__c.equalsIgnoreCase('Voter Id') && tempRec.VotIdEpicNo__c != NULL) {
                                        Trackwizz_CKYC_A63_RequestWrapper.IdentificationDetailClass identVar = new Trackwizz_CKYC_A63_RequestWrapper.IdentificationDetailClass();
                                        identVar.IdType = kycDocMap.get(tempRec.kycDoc__c);
                                        identVar.IdNumber = tempRec.VotIdEpicNo__c;
                                        identList.add(identVar);
                                    }
                                    else if(tempRec.kycDoc__c.equalsIgnoreCase('Pan') && tempRec.Pan__c != NULL) {
                                        Trackwizz_CKYC_A63_RequestWrapper.IdentificationDetailClass identVar = new Trackwizz_CKYC_A63_RequestWrapper.IdentificationDetailClass();
                                        identVar.IdType = kycDocMap.get(tempRec.kycDoc__c);
                                        identVar.IdNumber = tempRec.Pan__c;
                                        identList.add(identVar);
                                    }
                                    else if(tempRec.kycDoc__c.equalsIgnoreCase('Letter issued by the National Population Register') && tempRec.NPRNumber__c != NULL) {
                                        Trackwizz_CKYC_A63_RequestWrapper.IdentificationDetailClass identVar = new Trackwizz_CKYC_A63_RequestWrapper.IdentificationDetailClass();
                                        identVar.IdType = kycDocMap.get(tempRec.kycDoc__c);
                                        identVar.IdNumber = tempRec.NPRNumber__c;
                                        identList.add(identVar);
                                    }
                                }
                            }
                        }
						
                        if(!identList.isEmpty()) {
                            ident.IdentificationDetail = identList;
                            recdReqDetVar.IdentificationDetails = ident;
                        }
                        else {
                            recdReqDetVar.IdentificationDetails = ident;
                        }
                        
                        if(applyVar.Constitution__c != NULL && !applyVar.Constitution__c.equalsIgnoreCase('INDIVIDUAL')) {
                            recdReqDetVar.ProofOfIDSubmitted = proofIdSubmVar != NULL ? proofIdSubmVar : '';
                        }
                        else {
                            recdReqDetVar.ProofOfIDSubmitted = '';
                        }
                        recdReqDetVar.Minor = 0;
                        recdReqDetVar.ApplicationRefNumber = applyVar.LoanAppln__r.Finnone_Loan_Number__c != NULL ? applyVar.LoanAppln__r.Finnone_Loan_Number__c : ''; //Need to pass finnone LAN no
                        recdReqDetVar.HolderforImages = '';
                        recdReqDetVar.IntermediaryCode = '';
                        recdReqDetVar.Listed = 0;
                        recdReqDetVar.Industry = '';

                        //Nationality Tag
                        Trackwizz_CKYC_A63_RequestWrapper.NationalityClass nat = new Trackwizz_CKYC_A63_RequestWrapper.NationalityClass();
                        recdReqDetVar.Nationality = nat;
                            
                        //CountryofOperation Tag
                        Trackwizz_CKYC_A63_RequestWrapper.CountryofOperationClass countOp = new Trackwizz_CKYC_A63_RequestWrapper.CountryofOperationClass();
                        recdReqDetVar.CountryofOperation = countOp;

                        //IncomeDetails Tag
                        Trackwizz_CKYC_A63_RequestWrapper.IncomeDetailsClass incmDet = new Trackwizz_CKYC_A63_RequestWrapper.IncomeDetailsClass();
                        recdReqDetVar.IncomeDetails = incmDet;
                            
                        //NetWorthDetails Tag
                        Trackwizz_CKYC_A63_RequestWrapper.NetWorthDetailsClass netWorthDet = new Trackwizz_CKYC_A63_RequestWrapper.NetWorthDetailsClass();
                        recdReqDetVar.NetWorthDetails = netWorthDet;

                        recdReqDetVar.PEP = '';
                        //PEPClassification Tag
                        Trackwizz_CKYC_A63_RequestWrapper.PEPClassificationClass pepClas = new Trackwizz_CKYC_A63_RequestWrapper.PEPClassificationClass();
                        recdReqDetVar.PEPClassification = pepClas;

                        recdReqDetVar.AdverseMedia = 0;
                        //AdverseMediaClassification Tag
                        Trackwizz_CKYC_A63_RequestWrapper.AdverseMediaClassificationClass advClas = new Trackwizz_CKYC_A63_RequestWrapper.AdverseMediaClassificationClass();
                        recdReqDetVar.AdverseMediaClassification = advClas;

                        recdReqDetVar.AdverseMediaDetails = '';
                        recdReqDetVar.InsiderInformation = '';

                        //Tags
                        Trackwizz_CKYC_A63_RequestWrapper.TagsClass tagCls = new Trackwizz_CKYC_A63_RequestWrapper.TagsClass();
                            
                        //TagDetail
                        Trackwizz_CKYC_A63_RequestWrapper.TagDetailClass tagDetCls = new Trackwizz_CKYC_A63_RequestWrapper.TagDetailClass();
                        tagDetCls.Tag = apiVer != NULL && apiVer.Risk_Rating_Final__c != NULL ? apiVer.Risk_Rating_Final__c : '';
                        tagCls.TagDetail = tagDetCls;
                        recdReqDetVar.Tags = tagCls;

                        recdReqDetVar.FamilyCode = '';
                        recdReqDetVar.Channel = '';
                        recdReqDetVar.Links = '';

                        //ReputationClassification tag
                        Trackwizz_CKYC_A63_RequestWrapper.ReputationClassificationClass repCls = new Trackwizz_CKYC_A63_RequestWrapper.ReputationClassificationClass();
                        recdReqDetVar.ReputationClassification = repCls;

                        //RelationDetails tag
                        Trackwizz_CKYC_A63_RequestWrapper.RelationDetailsClass relDetCls = new Trackwizz_CKYC_A63_RequestWrapper.RelationDetailsClass();
                        recdReqDetVar.RelationDetails = relDetCls;

                        recdReqDetVar.IUPartyType = '';
                        recdReqDetVar.PropertyOwnerFlag = 0;

                        //ContactPersonDetails tag
                        Trackwizz_CKYC_A63_RequestWrapper.ContactPersonDetailsClass conPerDet = new Trackwizz_CKYC_A63_RequestWrapper.ContactPersonDetailsClass();
                        recdReqDetVar.ContactPersonDetails = conPerDet;
                            
                        //RMDetails tag
                        Trackwizz_CKYC_A63_RequestWrapper.RMDetailsClass rmDet = new Trackwizz_CKYC_A63_RequestWrapper.RMDetailsClass();
                        recdReqDetVar.RMDetails = rmDet;

                        //ModuleApplicable tag
                        Trackwizz_CKYC_A63_RequestWrapper.ModuleApplicableClass modApl = new Trackwizz_CKYC_A63_RequestWrapper.ModuleApplicableClass();
                            
                        //ModuleDetail tag
                        Trackwizz_CKYC_A63_RequestWrapper.ModuleDetailClass modDet = new Trackwizz_CKYC_A63_RequestWrapper.ModuleDetailClass();
                            
                        modDet.Module = GlobalConstants.Module;
                        modApl.ModuleDetail = modDet;
                        recdReqDetVar.ModuleApplicable = modApl;

                        //ActivityEmployerDetails tag
                        Trackwizz_CKYC_A63_RequestWrapper.ActivityEmployerDetailsClass actEmpDet = new Trackwizz_CKYC_A63_RequestWrapper.ActivityEmployerDetailsClass();
                        recdReqDetVar.ActivityEmployerDetails = actEmpDet;
                            
                        //RegAMLSpecialCategoryDetails tag
                        Trackwizz_CKYC_A63_RequestWrapper.RegAMLSpecialCategoryDetailsClass reg = new Trackwizz_CKYC_A63_RequestWrapper.RegAMLSpecialCategoryDetailsClass();
                        recdReqDetVar.RegAMLSpecialCategoryDetails = reg;
                            
                        //RecordRequestDetails tag
                        Trackwizz_CKYC_A63_RequestWrapper.RecordRequestDetailsClass recRq = new Trackwizz_CKYC_A63_RequestWrapper.RecordRequestDetailsClass();
                        recRq.RecordRequestDetail = recdReqDetVar;

                        //CustomerRelatedPartyCreateUpdateRequest tag
                        Trackwizz_CKYC_A63_RequestWrapper.CustomerRelatedPartyCreateUpdateRequestClass custRelVar = new Trackwizz_CKYC_A63_RequestWrapper.CustomerRelatedPartyCreateUpdateRequestClass();
                        custRelVar.ParentCompany = svc.ParentCompany__c;
                        custRelVar.ApiToken = svc.APIToken__c; //39475a23-6dd8-43db-8a31-e12dc969324c
                        custRelVar.RecordRequestDetails = recRq;

                        Trackwizz_CKYC_A63_RequestWrapper ckycWrap = new Trackwizz_CKYC_A63_RequestWrapper();
                        ckycWrap.CustomerRelatedPartyCreateUpdateRequest = custRelVar;

                        IntgMsg__c intg = new IntgMsg__c();
                        intg.Id = intMsgRec.Id;
                        intg.Req__c = JSON.serialize(ckycWrap,true);
                        intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntrecods.add(intg);
                    }
                }

                if (!updateIntrecods.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                    Schema.SObjectType objType = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntrecods);
                    uow.commitWork();
                }
            }
        }
        catch(Exception ex) {
            System.debug('error' + ex.getMessage());
            GlobalUtility.logMessage('Error', 'Trackwizz_CKYC_A63_RequestGenerator' + ex.getLineNumber(), 'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    }

    public static String dateUtility(Integer dayVar, Integer monthVar, Integer yearVar) {
        Map<Integer, String> dayMap = new Map<Integer, String>{1 => '01', 2 => '02', 3 => '03', 4 => '04', 5 => '05', 6 => '06', 7 => '07', 8 => '08', 9 => '09'};
        Map<Integer, String> monthMap = new Map<Integer, String>{1 => 'Jan', 2 => 'Feb', 3 => 'Mar', 4 => 'Apr', 5 => 'May', 6 => 'Jun', 7 => 'Jul', 8 => 'Aug', 9 => 'Sep', 10 => 'Oct', 11 => 'Nov', 12 => 'Dec'};
                                
        String dd; //day DD
        String mmm; //Month MMM
        String yyyy; //Year YYYY
        String dateVar;
        
        if(dayMap.containsKey(dayVar)) {
            dd = dayMap.get(dayVar);
        } 
        else {
            dd = String.valueOf(dayVar);
        }
        
        mmm = monthMap.get(monthVar);
        yyyy = String.valueOf(yearVar);
        
        dateVar = dd + '-' + mmm + '-' + yyyy;
        
        return dateVar;
    }
    
    //Master Data utility to fetch master values
    public static String masterDataMapUtility(Map<String, List<Map<String, String>>> masterDataMap, String outsideMapKey, String internalMapKey) {
        String emptyStr = '';
        String returnMapValue;
        try {
            if(!masterDataMap.isEmpty() && String.isNotBlank(outsideMapKey) && String.isNotBlank(internalMapKey)) {
                internalMapKey = internalMapKey.toUpperCase();
                if(masterDataMap.containsKey(outsideMapKey) && !masterDataMap.get(outsideMapKey).isEmpty()) {
                    for(Map<String, String> temp : masterDataMap.get(outsideMapKey)) {
                        if(temp.containsKey(internalMapKey) && temp.get(internalMapKey) != NULL) {
                            returnMapValue = temp.get(internalMapKey);
                        }
                    }
                }
            }
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'Trackwizz_CKYC_A63_RequestGenerator', 'masterDataMapUtility', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        return returnMapValue != NULL ? returnMapValue : emptyStr;
    }
    
    //Applicants Data
    public static Map<Id, Applicant__c> getCKYCApplData(Set<String> recIds, String methodName) {
        Map<Id, Applicant__c> applRecordsMap = new Map<Id, Applicant__c>();
        Set<String> applIds = new Set<String>();
        try {
            if(String.isNotBlank(methodName) && methodName == 'generateRequest') {
                applIds.addAll(recIds);
            }
            else if(String.isNotBlank(methodName) && methodName == 'generateCKYCReport') {
                for(Applicant__c appl : [SELECT Id FROM Applicant__c WHERE LoanAppln__c IN : recIds]) {
                    applIds.add(appl.Id);
                }
            }
            if(!applIds.isEmpty()) {
                applRecordsMap.putAll([SELECT Id, Name, Title__c, FName__c, MName__c, LName__c, Gender__c, DOB__c, Father_Name__c, MthrMdnName__c, SpName__c, UCID__c, toLabel(EduQual__c), MariStatus__c, Constitution__c, DOI__c, EmailId__c, MobNumber__c, LoanAppln__r.BrchName__c, LoanAppln__r.RM__c, LoanAppln__r.LoginAcceptDate__c, LoanAppln__r.Finnone_Loan_Number__c, LoanAppln__r.RMSMEmployeeID__c, LoanAppln__r.BrchCode__c, LoanAppln__r.RMSMName__c, LoanAppln__r.DisbursementDate__c, LoanAppln__r.Name, CurrentResidenceCity__City__s, FullName__c, (SELECT Id, CreatedDate, Risk_Rating_Final__c FROM API_Verifications__r WHERE RecordType.Name = 'Risk Rating' AND IsLatest__c = TRUE AND Risk_Rating_Final__c != NULL ORDER BY CreatedDate DESC), (SELECT Id, OfficialEmail__c FROM Applicant_Employments__r) FROM Applicant__c WHERE ApplType__c != NULL AND ApplType__c IN ('P', 'C', 'G') AND Id IN : applIds]);
            }
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'Trackwizz_CKYC_A63_RequestGenerator', 'getCKYCApplData', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        return applRecordsMap;
    }
    
    //Applicants Related Data
    public static Map<String, Map<Id, List<sObject>>> getCKYCApplRelData(Set<String> recIds, String methodName) {
        Map<String, Map<Id, List<sObject>>> applRelRecsMap = new Map<String, Map<Id, List<sObject>>>();
        Map<Id, List<ApplKyc__c>> applyKYCMap = new Map<Id, List<ApplKyc__c>>();
        Map<Id, List<DocDtl__c>> applyDocDtMap = new Map<Id, List<DocDtl__c>>();
        Map<Id, List<ApplAddr__c>> applyAddrMap = new Map<Id, List<ApplAddr__c>>();
        Set<String> applIds = new Set<String>();
        try {
            if(String.isNotBlank(methodName) && methodName == 'generateRequest') {
                applIds.addAll(recIds);
            }
            else if(String.isNotBlank(methodName) && methodName == 'generateCKYCReport') {
                for(Applicant__c appl : [SELECT Id FROM Applicant__c WHERE LoanAppln__c IN : recIds]) {
                    applIds.add(appl.Id);
                }
            }
            if(!applIds.isEmpty()) {
                for(DocDtl__c dd : [SELECT Id, DocCatgry__c, DocTyp__c, DocSubTyp__c, Appl__c, Appl__r.Constitution__c, CreatedDate, Applicant_KYC__r.City__c FROM DocDtl__c WHERE Appl__c != NULL AND Appl__r.ApplType__c != NULL AND Appl__r.ApplType__c IN ('P', 'C', 'G') AND Appl__c IN : applIds]) {
                    if(!applyDocDtMap.containsKey(dd.Appl__c)) {
                        List<DocDtl__c> tempList = new List<DocDtl__c>();
                        tempList.add(dd);
                        applyDocDtMap.put(dd.Appl__c, tempList);
                    }
                    else {
                        applyDocDtMap.get(dd.Appl__c).add(dd);
                    }
                }
                
                for(ApplKyc__c ak : [SELECT Id, kycDoc__c, AadharNo__c, DLNo__c, PassNo__c, VotIdEpicNo__c, Pan__c, NPRNumber__c, PassExpDt__c, DLExpDt__c, Applicant__c FROM ApplKyc__c WHERE Applicant__c != NULL AND Applicant__r.ApplType__c != NULL AND Applicant__r.ApplType__c IN ('P', 'C', 'G') AND Applicant__c IN : applIds]) {
                    if(!applyKYCMap.containsKey(ak.Applicant__c)) {
                        List<ApplKyc__c> tempList = new List<ApplKyc__c>();
                        tempList.add(ak);
                        applyKYCMap.put(ak.Applicant__c, tempList);
                    }
                    else {
                        applyKYCMap.get(ak.Applicant__c).add(ak);
                    }
                }
                
                for(ApplAddr__c addr : [SELECT Id, Applicant__c, AddrTyp__c, AddrLine1__c, AddrLine2__c, State__c, Pincode__c, Country__c, City__c, HouseNo__c, Landmark__c, MailAddr__c FROM ApplAddr__c WHERE Applicant__c != NULL AND Applicant__r.ApplType__c != NULL AND Applicant__r.ApplType__c IN ('P', 'C', 'G') AND Applicant__c IN : applIds]) {
                    if(!applyAddrMap.containsKey(addr.Applicant__c)) {
                        List<ApplAddr__c> tempList = new List<ApplAddr__c>();
                        tempList.add(addr);
                        applyAddrMap.put(addr.Applicant__c, tempList);
                    }
                    else {
                        applyAddrMap.get(addr.Applicant__c).add(addr);
                    }
                }
                applRelRecsMap.put('DocDtl__c', applyDocDtMap);
                applRelRecsMap.put('ApplKyc__c', applyKYCMap);
                applRelRecsMap.put('ApplAddr__c', applyAddrMap);
            }
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'Trackwizz_CKYC_A63_RequestGenerator', 'getCKYCApplRelData', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        return applRelRecsMap;
    }
    
    //Applicant Address State Value
    public static Set<String> getApplAddrState(Set<String> recIds, String methodName) {
        Set<String> masterDataKey = new Set<String>();
        Set<String> applIds = new Set<String>();
        if(String.isNotBlank(methodName) && methodName == 'generateRequest') {
            applIds.addAll(recIds);
        }
        else if(String.isNotBlank(methodName) && methodName == 'generateCKYCReport') {
            for(Applicant__c appl : [SELECT Id FROM Applicant__c WHERE LoanAppln__c IN : recIds]) {
                applIds.add(appl.Id);
            }
        }
        for(ApplAddr__c addr : [SELECT Id, State__c FROM ApplAddr__c WHERE Applicant__c IN : applIds]) {
            if(addr.State__c != NULL) {
                masterDataKey.add(addr.State__c);
            }
        }
        return masterDataKey;
    }
    
    //To get utility data sets
    public static Map<String, Set<String>> getUtilitySets(Map<Id, Applicant__c> applRecordsMap) {
        Map<String, Set<String>> utilitySetMap = new Map<String, Set<String>>();
        for(Applicant__c app : applRecordsMap.values()) {
            if(app.LoanAppln__r.RMSMName__c != NULL) {
                if(!utilitySetMap.containsKey('userIdSet')) {
                    utilitySetMap.put('userIdSet', new Set<String>{app.LoanAppln__r.RMSMName__c});
                }
                else {
                    utilitySetMap.get('userIdSet').add(app.LoanAppln__r.RMSMName__c);
                }
            }
            if(app.LoanAppln__r.BrchCode__c != NULL) {
                if(!utilitySetMap.containsKey('branchCdSet')) {
                    utilitySetMap.put('branchCdSet', new Set<String>{app.LoanAppln__r.BrchCode__c});
                }
                else {
                    utilitySetMap.get('branchCdSet').add(app.LoanAppln__r.BrchCode__c);
                }
            }
            if(app.Constitution__c != NULL) {
                if(!utilitySetMap.containsKey('finnVal')) {
                    utilitySetMap.put('finnVal', new Set<String>{app.Constitution__c});
                }
                else {
                    utilitySetMap.get('finnVal').add(app.Constitution__c);
                }
            }
        }
        return utilitySetMap;
    }
    
    //Get Team Hierarchy Data
    public static Map<Id, String> getTeamHierData(Set<String> userIdSet) {
        Map<Id, String> teamHierMap = new Map<Id, String>();
        for(TeamHierarchy__c th : [SELECT Id, Employee__c, EmpRole__c FROM TeamHierarchy__c WHERE Employee__c != NULL AND EmpRole__c != NULL AND Employee__c IN : userIdSet]) {
            teamHierMap.put(th.Employee__c, th.EmpRole__c);
        }
        return teamHierMap;
    }
    
    //Get Bank Branch Master Data
    public static Map<String, String> getBankBrnMastData(Set<String> branchCdSet) {
        Map<String, String> bbmMap = new Map<String, String>();
        for(BankBrchMstr__c bbm : [SELECT Id, Name, BrchCode__c, LocationMaster__r.City__c FROM BankBrchMstr__c WHERE BrchCode__c != NULL AND BrchCode__c IN : branchCdSet]) {
            if(bbm.LocationMaster__r != NULL && bbm.LocationMaster__r.City__c != NULL) {
                bbmMap.put(bbm.BrchCode__c, bbm.LocationMaster__r.City__c);
            }
        }
        return bbmMap;
    }
    
    //Fetch Master Data object records
    public static Map<String, List<Map<String, String>>> fetchMasterObjData(Set<String> masterDataKey, Set<String> finnVal) {
        Map<String, List<Map<String, String>>> masterDataMap = new Map<String, List<Map<String, String>>>();
        for(MasterData__c temp : [SELECT Id, Trackwizzcode__c, Trackwizzval__c, Type__c, FinnoneVal__c from MasterData__c WHERE Trackwizzval__c IN : masterDataKey OR FinnoneVal__c IN : finnVal]) {
            if(String.isNotBlank(temp.Type__c)) {
                if(!masterDataMap.containsKey(temp.Type__c)) {
                    List<Map<String, String>> mpVar = new List<Map<String, String>>();
                    Map<String, String> md = new Map<String, String>();
                    
                    if(temp.Type__c.equalsIgnoreCase('Trackwizz State Master') && temp.Trackwizzcode__c != NULL && temp.Trackwizzval__c != NULL) {
                        md.put(temp.Trackwizzval__c.toUpperCase(), temp.Trackwizzcode__c);
                    }
                    else if(temp.Type__c.equalsIgnoreCase('Constitution') && temp.Trackwizzcode__c != NULL && temp.FinnoneVal__c != NULL) {
                        md.put(temp.FinnoneVal__c.toUpperCase(), temp.Trackwizzcode__c);
                    }
                    
                    mpVar.add(md);
                    masterDataMap.put(temp.Type__c, mpVar);
                }
                else {
                    Map<String, String> md = new Map<String, String>();
                    if(temp.Type__c.equalsIgnoreCase('Trackwizz State Master') && temp.Trackwizzcode__c != NULL && temp.Trackwizzval__c != NULL) {
                        md.put(temp.Trackwizzval__c, temp.Trackwizzcode__c);
                    }
                    else if(temp.Type__c.equalsIgnoreCase('Constitution') && temp.Trackwizzcode__c != NULL && temp.FinnoneVal__c != NULL) {
                        md.put(temp.FinnoneVal__c.toUpperCase(), temp.Trackwizzcode__c);
                    }
                    masterDataMap.get(temp.Type__c).add(md);
                }
            }
        }
        return masterDataMap;
    }
    
    @AuraEnabled(cacheable=true)
    public static String fetchApplCKYCDataReport(List<String> lanIds) {
        Map<Id, Applicant__c> applRecordsMap = new Map<Id, Applicant__c>();
        Set<String> masterDataKey = new Set<String>();
        List<Map<String, String>> objList = new List<Map<String, String>>();
        Map<Id, String> kycEmpDesgMap = new Map<Id, String>();
        Map<String, String> bbmMap = new Map<String, String>();
        Map<Id, List<DocDtl__c>> applyDocDtMap = new Map<Id, List<DocDtl__c>>();
        Map<Id, List<ApplKyc__c>> applyKYCMap = new Map<Id, List<ApplKyc__c>>();
        Map<Id, List<ApplAddr__c>> applyAddrMap = new Map<Id, List<ApplAddr__c>>();
        Map<String, Map<Id, List<sObject>>> applRelRecsMap = new Map<String, Map<Id, List<sObject>>>();
        Map<String, List<Map<String, String>>> masterDataMap = new Map<String, List<Map<String, String>>>();
        Set<String> userIdSet = new Set<String>();
        Set<String> branchCdSet = new Set<String>();
        Set<String> finnVal = new Set<String>();
        IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('CKYC_API');
        Map<String, String> kycDocMap = new Map<String, String>();//{'Aadhaar' => 'AadharCard', 'Voter ID' => 'VoterID','Voter Id' => 'VoterID', 'Passport' => 'Passport', 'Driving license' => 'DrivingLicense','Driving License' => 'DrivingLicense', 'PAN' => 'PanCard','Pan' => 'PanCard', 'Letter issued by the National Population Register' => 'NPRLetter', 'Certificate of incorporation' => 'CIN', 'Electricity Bill' => 'UtilityBill2m', 'Post-paid mobile phone bill' => 'UtilityBill2m', 'Telephone Bill' => 'UtilityBill2m'};    
        Map<String, String> proofIdSubMap = new Map<String, String>();//{'Partnership deed' => 'PD', 'MOA' => 'MOA', 'Certificate of incorporation' => 'CIN', 'Trust / Society Deed' => 'TRUSTDEED'};       
        
        for(MasterData__c masterdata : [Select Id,Type__c,SalesforceCode__c, Trackwizzcode__c, Trackwizzval__c from MasterData__c where Type__c IN ('Trackwizz Proof of ID Master','Trackwizz KYC Master')]){
            if(masterdata.Type__c == 'Trackwizz KYC Master'){
                kycDocMap.put(masterdata.SalesforceCode__c,masterdata.Trackwizzcode__c);
            }
            else if(masterdata.Type__c == 'Trackwizz Proof of ID Master'){
                proofIdSubMap.put(masterdata.SalesforceCode__c,masterdata.Trackwizzcode__c);
            }
        }    
            
        try {
            if(!lanIds.isEmpty()) {
                Set<String> lanIdsSet = new Set<String>();
                lanIdsSet.addAll(lanIds);
                applRecordsMap = getCKYCApplData(lanIdsSet, 'generateCKYCReport');
                applRelRecsMap = getCKYCApplRelData(lanIdsSet, 'generateCKYCReport');
                if(!applRelRecsMap.isEmpty()) {
                    if(applRelRecsMap.containsKey('DocDtl__c') && !applRelRecsMap.get('DocDtl__c').isEmpty()) {
                        applyDocDtMap = (Map<Id, List<DocDtl__c>>)applRelRecsMap.get('DocDtl__c');
                    }
                    if(applRelRecsMap.containsKey('ApplKyc__c') && !applRelRecsMap.get('ApplKyc__c').isEmpty()) {
                        applyKYCMap = (Map<Id, List<ApplKyc__c>>)applRelRecsMap.get('ApplKyc__c');
                    }
                    if(applRelRecsMap.containsKey('ApplAddr__c') && !applRelRecsMap.get('ApplAddr__c').isEmpty()) {
                        applyAddrMap = (Map<Id, List<ApplAddr__c>>)applRelRecsMap.get('ApplAddr__c');
                    }
                }
                masterDataKey = getApplAddrState(lanIdsSet, 'generateCKYCReport');
                if(!applRecordsMap.isEmpty()) {
                    Map<String, Set<String>> utilitySetMap = getUtilitySets(applRecordsMap);
                    if(!utilitySetMap.isEmpty()) {
                        if(utilitySetMap.containsKey('userIdSet') && !utilitySetMap.get('userIdSet').isEmpty()) {
                            userIdSet = utilitySetMap.get('userIdSet');
                        }
                        if(utilitySetMap.containsKey('branchCdSet') && !utilitySetMap.get('branchCdSet').isEmpty()) {
                            branchCdSet = utilitySetMap.get('branchCdSet');
                        }
                        if(utilitySetMap.containsKey('finnVal') && !utilitySetMap.get('finnVal').isEmpty()) {
                            finnVal = utilitySetMap.get('finnVal');
                        }
                    }
                }
                if(!userIdSet.isEmpty()) {
                    kycEmpDesgMap = getTeamHierData(userIdSet);
                }

                if(!branchCdSet.isEmpty()) {
                    bbmMap = getBankBrnMastData(branchCdSet);
                }
                
                masterDataMap = fetchMasterObjData(masterDataKey, finnVal);
                if(!applRecordsMap.isEmpty()) {
                    for(Id applId : applRecordsMap.keySet()) {
                        Applicant__c applRec = applRecordsMap.get(applId);
                        Map<String, String> objVar = new Map<String, String>();
                        Date disbDate = applRec.LoanAppln__r.DisbursementDate__c;
                        Date dobVar = (applRec.Constitution__c != NULL && applRec.Constitution__c == 'INDIVIDUAL' && applRec.DOB__c != NULL) ? applRec.DOB__c : (applRec.Constitution__c != NULL && applRec.Constitution__c != 'INDIVIDUAL' && applRec.DOI__c != NULL) ? applRec.DOI__c : NULL;
                        String spousePfx, maritStatus, workEmail;
                        if(applRec.MariStatus__c != NULL && (applRec.MariStatus__c == 'M' || applRec.MariStatus__c == 'W')) {
                            if(applRec.Title__c != NULL) {
                                if(applRec.Title__c == 'Mr.') {
                                    spousePfx = 'Mrs';
                                }
                                else if(applRec.Title__c == 'Mrs.') {
                                    spousePfx = 'Mr';
                                }
                            }
                        }
                        if(applRec.MariStatus__c != NULL) {
                            if (applRec.MariStatus__c == 'M') {
                                maritStatus = 'M';
                            } 
                            else if (applRec.MariStatus__c == 'S') {
                                maritStatus = 'U';
                            } 
                            else if (applRec.MariStatus__c == 'W') {
                                maritStatus = 'O';
                            }
                        }
                        if(!applRec.Applicant_Employments__r.isEmpty()) {
                            ApplicantEmployment__c temp = applRec.Applicant_Employments__r[0];
                            if(temp.OfficialEmail__c != NULL) {
                                workEmail = temp.OfficialEmail__c;
                            }
                        }
                        Integer formSixtyVar = 1;
                        String permDoc, corresAddDoc, proofIdSubmVar;
                        Date kycDt;
                        if(!applyDocDtMap.isEmpty() && applyDocDtMap.containsKey(applRec.Id) && !applyDocDtMap.get(applRec.Id).isEmpty()) {
                            for(DocDtl__c dd : applyDocDtMap.get(applRec.Id)) {
                                if(dd.DocCatgry__c != NULL && dd.DocCatgry__c.equalsIgnoreCase('PAN Documents')) {
                                    if(dd.DocTyp__c != NULL && (dd.DocTyp__c.equalsIgnoreCase('PAN'))) { //|| dd.DocTyp__c.equalsIgnoreCase('Form 60')
                                        formSixtyVar = 0;
                                    }
                                }
                                else if(dd.DocCatgry__c != NULL && dd.DocCatgry__c.equalsIgnoreCase('KYC Documents') && applRec.Constitution__c != NULL && applRec.Constitution__c.equalsIgnoreCase('INDIVIDUAL')) {
                                    if(dd.DocTyp__c != NULL && dd.DocTyp__c.equalsIgnoreCase('Residence Address proof - OVD') && dd.DocSubTyp__c != NULL && kycDocMap.containsKey(dd.DocSubTyp__c) && permDoc == NULL && corresAddDoc == NULL) {
                                        permDoc = kycDocMap.get(dd.DocSubTyp__c);
                                        corresAddDoc = kycDocMap.get(dd.DocSubTyp__c);
                                        kycDt = dd.CreatedDate.date();
                                    }
                                }
                                else if(dd.DocCatgry__c != NULL && dd.DocCatgry__c.equalsIgnoreCase('KYC Documents') && applRec.Constitution__c != NULL && !applRec.Constitution__c.equalsIgnoreCase('INDIVIDUAL')) {
                                    if(dd.DocTyp__c != NULL && ((dd.DocTyp__c.equalsIgnoreCase('Constitution wise Mandatory KYC documents') && dd.DocSubTyp__c != NULL && kycDocMap.containsKey(dd.DocSubTyp__c)) || dd.DocTyp__c.equalsIgnoreCase('Principal Place of Business - Address Proof')) && permDoc == NULL) {
                                        if(dd.DocTyp__c.equalsIgnoreCase('Constitution wise Mandatory KYC documents')) {
                                            permDoc = kycDocMap.get(dd.DocSubTyp__c);
                                        }
                                        else {
                                            permDoc = 'Others';
                                        }
                                        kycDt = dd.CreatedDate.date();
                                    }
                                    else if(dd.DocTyp__c != NULL && dd.DocTyp__c.equalsIgnoreCase('Registered office - Address Proof') && dd.DocSubTyp__c != NULL && kycDocMap.containsKey(dd.DocSubTyp__c) && corresAddDoc == NULL) {
                                        corresAddDoc = kycDocMap.get(dd.DocSubTyp__c);
                                    }
                                }

                                if(dd.DocCatgry__c != NULL && dd.DocCatgry__c.equalsIgnoreCase('KYC Documents') && dd.DocTyp__c != NULL && dd.DocTyp__c.equalsIgnoreCase('Constitution wise Mandatory KYC documents') && dd.DocSubTyp__c != NULL && proofIdSubMap.containsKey(dd.DocSubTyp__c) && proofIdSubmVar == NULL) {
                                    proofIdSubmVar = proofIdSubMap.get(dd.DocSubTyp__c);
                                }
                            }
                        }
                        
                        Id permAddId, corresAddId;
                        if(!applyAddrMap.isEmpty() && applyAddrMap.containsKey(applRec.Id) && !applyAddrMap.get(applRec.Id).isEmpty()) {
                            
                            if(applRec.Constitution__c != NULL) {
                                if(applRec.Constitution__c.equalsIgnoreCase('INDIVIDUAL')) {
                                    for(ApplAddr__c add : applyAddrMap.get(applRec.Id)) {
                                        if(add.AddrTyp__c != NULL) {
                                            if(add.AddrTyp__c.equalsIgnoreCase('Permanent Address')) {
                                                permAddId = add.Id;
                                                break;
                                            }
                                            else if(add.AddrTyp__c.equalsIgnoreCase('Residence Address')) {
                                                permAddId = add.Id;
                                                break;
                                            }
                                        }
                                    }
                                    if(permAddId != NULL) {
                                        for(ApplAddr__c add : applyAddrMap.get(applRec.Id)) {
                                            if(add.AddrTyp__c != NULL && add.Id != permAddId && add.MailAddr__c == TRUE) {
                                                corresAddId = add.Id; 
                                            }
                                        }
                                    }
                                }
                                else if(!applRec.Constitution__c.equalsIgnoreCase('INDIVIDUAL')) {
                                   for(ApplAddr__c add : applyAddrMap.get(applRec.Id)) {
                                        if(add.AddrTyp__c != NULL) {
                                            if(add.AddrTyp__c.equalsIgnoreCase('Principal place for business')) {
                                                permAddId = add.Id;
                                                break;
                                            }
                                            else if(add.AddrTyp__c.equalsIgnoreCase('Registered place for business')) {
                                                permAddId = add.Id;
                                                break;
                                            }
                                        }
                                    } 
                                    if(permAddId != NULL) {
                                        for(ApplAddr__c add : applyAddrMap.get(applRec.Id)) {
                                            if(add.AddrTyp__c != NULL && add.Id != permAddId && add.MailAddr__c == TRUE) {
                                                corresAddId = add.Id; 
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        if(permAddId != NULL && corresAddId == NULL) {
                            corresAddId = permAddId;
                        }
                        
                        Map<String, ApplAddr__c> addrMap = new Map<String, ApplAddr__c>();
                        
                        if(!applyAddrMap.isEmpty() && applyAddrMap.containsKey(applRec.Id) && !applyAddrMap.get(applRec.Id).isEmpty()) {
                            for(ApplAddr__c add : applyAddrMap.get(applRec.Id)) {
                                if(permAddId != NULL && corresAddId != NULL) {
                                    if(corresAddId == permAddId && add.Id == permAddId) {
                                        addrMap.put('Permanent', add);
                                        addrMap.put('Correspondence', add);
                                        break; 
                                    }
                                    else if(corresAddId != permAddId) {
                                        if(add.Id == permAddId) {
                                            addrMap.put('Permanent', add);
                                        }
                                        else if(add.Id == corresAddId) {
                                            addrMap.put('Correspondence', add);
                                        }
                                    }
                                }
                            }
                        }
                        
                        Map<String, Map<String, String>> addMapData = new Map<String, Map<String, String>>();
                        if(!addrMap.isEmpty()) {
                            for(String tempKey : addrMap.keySet()) {
                                ApplAddr__c add = addrMap.get(tempKey);
                                Map<String, String> tempMap = new Map<String, String>();
                                String addStr = '';
                                if(add.AddrLine1__c != NULL && add.AddrLine2__c != NULL) {
                                    if(add.AddrLine1__c.equalsIgnoreCase(add.AddrLine2__c)) {
                                        addStr += add.AddrLine1__c;
                                    }
                                    else {
                                        addStr += add.AddrLine1__c + ' ' + add.AddrLine2__c;
                                    }
                                }
                                else if(add.AddrLine1__c != NULL && add.AddrLine2__c == NULL) {
                                    addStr += add.AddrLine1__c;
                                }
                                else if(add.AddrLine1__c == NULL && add.AddrLine2__c != NULL) {
                                    addStr += add.AddrLine2__c;
                                }
                                if(add.Landmark__c != NULL && String.isNotBlank(addStr)) {
                                    addStr = addStr + ' ' + add.Landmark__c;
                                }
                                // else {
                                //     addStr += add.Landmark__c;
                                // }
                                
                                String addLine1 = '', addLine2 = '', addLine3 = '';
                                if(String.isNotBlank(addStr)) {
                                    if(addStr.length() > 100) {
                                        addLine1 = addStr.substring(0,50);
                                        addLine2 = addStr.substring(50,100);
                                        addLine3 = addStr.substring(100, addStr.length());
                                    }
                                    else if(addStr.length() > 50 && addStr.length() <= 100) {
                                        addLine1 = addStr.substring(0,50);
                                        addLine2 = addStr.substring(50, addStr.length());
                                    }
                                    else if(addStr.length() <= 50) {
                                        addLine1 = addStr.substring(0,addStr.length());
                                    }
                                }
                                
                                tempMap.put('AddrLine1', addLine1); 
                                tempMap.put('AddrLine2', addLine2);
                                tempMap.put('AddrLine3', addLine3);
                                tempMap.put('HouseNo', add.HouseNo__c != NULL ? add.HouseNo__c : '');
                                tempMap.put('Country', 'IN');
                                tempMap.put('State', add.State__c != NULL ? (String.isNotBlank(masterDataMapUtility(masterDataMap, 'Trackwizz State Master', add.State__c)) ? masterDataMapUtility(masterDataMap, 'Trackwizz State Master', add.State__c) : 'XX') : '');
                                tempMap.put('Pincode', add.Pincode__c != NULL ? add.Pincode__c : '');
                                tempMap.put('District', add.City__c != NULL ? add.City__c : '');
                                tempMap.put('City', add.City__c != NULL ? add.City__c : '');
                                addMapData.put(tempKey, tempMap);
                            }
                        }
                        
                        Map<String, Map<String, String>> kycDocMapVar = new Map<String, Map<String, String>>();
                        if(!applyKYCMap.isEmpty() && applyKYCMap.containsKey(applRec.Id) && !applyKYCMap.get(applRec.Id).isEmpty()) {
                            List<ApplKyc__c> applyKYCList = applyKYCMap.get(applRec.Id);
                            for(ApplKyc__c tempRec : applyKYCList) {
                                if(tempRec.kycDoc__c != NULL && kycDocMap.containsKey(tempRec.kycDoc__c)) {
                                    Map<String, String> tempMap = new Map<String, String>();
                                    
                                    if(tempRec.kycDoc__c.equalsIgnoreCase('Passport') && tempRec.PassNo__c != NULL && tempRec.PassExpDt__c != NULL) {
                                        tempMap.put('DocNo', tempRec.PassNo__c);
                                        tempMap.put('ExpiryDate', dateUtility(tempRec.PassExpDt__c.day(),tempRec.PassExpDt__c.month(), tempRec.PassExpDt__c.year()));
                                        tempMap.put('DocType', kycDocMap.get(tempRec.kycDoc__c));
                                        kycDocMapVar.put('Passport', tempMap);
                                    }
                                    else if(tempRec.kycDoc__c.equalsIgnoreCase('Driving License') && tempRec.DLNo__c != NULL && tempRec.DLExpDt__c != NULL) {
                                        tempMap.put('DocNo', tempRec.DLNo__c);
                                        tempMap.put('ExpiryDate', dateUtility(tempRec.DLExpDt__c.day(),tempRec.DLExpDt__c.month(), tempRec.DLExpDt__c.year()));
                                        tempMap.put('DocType', kycDocMap.get(tempRec.kycDoc__c));
                                        kycDocMapVar.put('DrivingLicense', tempMap);
                                    }
                                    else if(tempRec.kycDoc__c.equalsIgnoreCase('Aadhaar') && tempRec.AadharNo__c != NULL && tempRec.AadharNo__c.length() == 12) {
                                        String last4Digits = tempRec.AadharNo__c.substring(8);
                                        tempMap.put('DocNo', last4Digits);
                                        tempMap.put('DocType', kycDocMap.get(tempRec.kycDoc__c));
                                        kycDocMapVar.put('Aadhaar', tempMap);
                                    }
                                    else if(tempRec.kycDoc__c.equalsIgnoreCase('Voter Id') && tempRec.VotIdEpicNo__c != NULL) {
                                        tempMap.put('DocNo', tempRec.VotIdEpicNo__c);
                                        tempMap.put('DocType', kycDocMap.get(tempRec.kycDoc__c));
                                        kycDocMapVar.put('VoterId', tempMap);
                                    }
                                    else if(tempRec.kycDoc__c.equalsIgnoreCase('Pan') && tempRec.Pan__c != NULL) {
                                        tempMap.put('DocNo', tempRec.Pan__c);
                                        tempMap.put('DocType', kycDocMap.get(tempRec.kycDoc__c));
                                        kycDocMapVar.put('Pan', tempMap);
                                    }
                                    else if(tempRec.kycDoc__c.equalsIgnoreCase('Letter issued by the National Population Register') && tempRec.NPRNumber__c != NULL) {
                                        tempMap.put('DocNo', tempRec.NPRNumber__c);
                                        tempMap.put('DocType', kycDocMap.get(tempRec.kycDoc__c));
                                        kycDocMapVar.put('NPRLetter', tempMap);
                                    }
                                }
                            }
                        }
                        
                        objVar.put('PARENTCOMPANY', svc.ParentCompany__c);
                        objVar.put('TRANSACTIONID', applRec.Name);
                        objVar.put('SOURCESYSTEMNAME', svc.SourceSystem__c);
                        objVar.put('SOURCESYSTEMCUSTOMERCODE', applRec.UCID__c != NULL ? applRec.UCID__c : '');
                        objVar.put('SOURCESYSTEMCUSTOMERCREATIONDATE', disbDate != NULL ? dateUtility(disbDate.day(), disbDate.month(), disbDate.year()) : '');
                        objVar.put('ISSMALLCUSTOMER', GlobalConstants.IsSmallCustomer);
                        objVar.put('EKYCOTPBASED', GlobalConstants.EkycOTPBased);
                        objVar.put('RECORDIDENTIFIER', '');
                        objVar.put('SEGMENTS', '');
                        objVar.put('SEGMENTSTARTDATE', '');
                        objVar.put('PRODUCTSEGMENTS', '');
                        objVar.put('CUSTOMERSTATUS', GlobalConstants.Status);
                        objVar.put('CUSTOMERSTATUSEFFECTIVEDATE', disbDate != NULL ? dateUtility(disbDate.day(), disbDate.month(), disbDate.year()) : '');
                        objVar.put('RELATEDPARTYSTATUS', '');
                        objVar.put('RELATEDPARTYSTATUSEFFECTIVEDATE', '');
                        objVar.put('CUSTOMERTYPE', applRec.Constitution__c != NULL ? masterDataMapUtility(masterDataMap, 'Constitution', applRec.Constitution__c) : '');
                        objVar.put('CUSTOMERSUBTYPE', '');
                        objVar.put('Prefix', applRec.Constitution__c != NULL && applRec.Constitution__c == 'INDIVIDUAL' && applRec.Title__c != NULL && applRec.FName__c != NULL ? applRec.Title__c.removeEnd('.') : '');
                        objVar.put('FirstName', (applRec.Constitution__c != NULL && applRec.Constitution__c == 'INDIVIDUAL' && applRec.FName__c != NULL) ? applRec.FName__c : (applRec.Constitution__c != NULL && applRec.Constitution__c != 'INDIVIDUAL' && applRec.FullName__c != NULL) ? applRec.FullName__c : '');
                        objVar.put('MiddleName', applRec.Constitution__c != NULL && applRec.Constitution__c == 'INDIVIDUAL' && applRec.MName__c != NULL ? applRec.MName__c : '');
                        objVar.put('LastName', applRec.Constitution__c != NULL && applRec.Constitution__c == 'INDIVIDUAL' && applRec.LName__c != NULL ? applRec.LName__c: '');
                        objVar.put('MAIDENPREFIX', applRec.Constitution__c != NULL && applRec.Constitution__c == 'INDIVIDUAL' && applRec.MthrMdnName__c != NULL ? GlobalConstants.MotherPrefix : '');
                        objVar.put('MAIDENFIRSTNAME', applRec.Constitution__c != NULL && applRec.Constitution__c == 'INDIVIDUAL' && applRec.MthrMdnName__c != NULL ? applRec.MthrMdnName__c : '');
                        objVar.put('MAIDENMIDDLENAME', '');
                        objVar.put('MAIDENLASTNAME', '');
                        objVar.put('FatherPrefix', applRec.Constitution__c != NULL && applRec.Constitution__c == 'INDIVIDUAL' && applRec.Father_Name__c != NULL ? GlobalConstants.FatherPrefix : '');
                        objVar.put('FatherFirstName', applRec.Constitution__c != NULL && applRec.Constitution__c == 'INDIVIDUAL' && applRec.Father_Name__c != NULL? applRec.Father_Name__c : '');
                        objVar.put('FatherMiddleName', '');
                        objVar.put('FatherLastName', '');
                        objVar.put('SPOUSEPREFIX', applRec.Constitution__c != NULL && applRec.Constitution__c == 'INDIVIDUAL' && spousePfx != NULL && applRec.SpName__c != NULL ? spousePfx : '');
                        objVar.put('SPOUSEFIRSTNAME', applRec.Constitution__c != NULL && applRec.Constitution__c == 'INDIVIDUAL' && spousePfx != NULL && applRec.SpName__c != NULL ? applRec.SpName__c  : '');
                        objVar.put('SPOUSEMIDDLENAME', '');
                        objVar.put('SPOUSELASTNAME', '');
                        objVar.put('MOTHERPREFIX', applRec.Constitution__c != NULL && applRec.Constitution__c == 'INDIVIDUAL' && applRec.MthrMdnName__c != NULL ? GlobalConstants.MotherPrefix : '');
                        objVar.put('MOTHERFIRSTNAME', applRec.Constitution__c != NULL && applRec.Constitution__c == 'INDIVIDUAL' && applRec.MthrMdnName__c != NULL ? applRec.MthrMdnName__c : '');
                        objVar.put('MotherMiddleName', '');
                        objVar.put('MotherLastName', '');
                        objVar.put('GENDER', applRec.Constitution__c != NULL && applRec.Constitution__c == 'INDIVIDUAL' && applRec.Gender__c != NULL ? applRec.Gender__c : '');
                        objVar.put('MARITALSTATUS', applRec.Constitution__c != NULL && applRec.Constitution__c == 'INDIVIDUAL' && maritStatus != NULL ? maritStatus : '');
                        objVar.put('Citizenship', GlobalConstants.Country);
                        objVar.put('COUNTRYOFRESIDENCE', GlobalConstants.Country);
                        objVar.put('OCCUPATIONTYPE', '');
                        objVar.put('ACTIVITYSECTOR', '');
                        objVar.put('NATUREOFBUSINESS', '');
                        objVar.put('NATUREOFBUSINESSOTHER', '');
                        objVar.put('DATEOFBIRTH', dobVar != NULL ? dateUtility(dobVar.day(),dobVar.month(),dobVar.year()): '');
                        objVar.put('WORKEMAIL', workEmail != NULL ? workEmail : '');
                        objVar.put('PERSONALEMAIL', applRec.EmailId__c != NULL ? applRec.EmailId__c : '');
                        objVar.put('KYCDateOfDeclaration', disbDate != NULL ? dateUtility(disbDate.day(), disbDate.month(), disbDate.year()) : '');
                        objVar.put('KYCPLACEOFDECLARATION', !bbmMap.isEmpty() && applRec.LoanAppln__r.BrchCode__c != NULL && bbmMap.containsKey(applRec.LoanAppln__r.BrchCode__c) ? bbmMap.get(applRec.LoanAppln__r.BrchCode__c) : '');
                        objVar.put('KYCVERIFICATIONDATE', kycDt != NULL ? dateUtility(kycDt.day(), kycDt.month(), kycDt.year()) : '');
                        objVar.put('KYCEMPLOYEENAME', applRec.LoanAppln__r.RM__c != NULL ? applRec.LoanAppln__r.RM__c : '');
                        objVar.put('KYCEMPLOYEEDESIGNATION', 'SALES MANAGER');
                        objVar.put('KYCVERIFICATIONBRANCH', applRec.LoanAppln__r.BrchName__c != NULL ? applRec.LoanAppln__r.BrchName__c : '');
                        objVar.put('KYCEMPLOYEECODE', applRec.LoanAppln__r.RMSMEmployeeID__c != NULL ? applRec.LoanAppln__r.RMSMEmployeeID__c : '');
                        
                        Map<String, String> tempAddMapPer = !addMapData.isEmpty() && addMapData.containsKey('Permanent') ? addMapData.get('Permanent') : new Map<String, String>();
                        Map<String, String> tempAddMapCorr = !addMapData.isEmpty() && addMapData.containsKey('Correspondence') ? addMapData.get('Correspondence') : new Map<String, String>();
                        objVar.put('PERMANENTCKYCADDRESSTYPE', !tempAddMapPer.isEmpty() ? '1' : '');
                        objVar.put('PLOTNOSURVEYNOHOUSEFLATNO', !tempAddMapPer.isEmpty() ? tempAddMapPer.get('HouseNo') : '');
                        objVar.put('PERMANENTADDRESSCOUNTRY', !tempAddMapPer.isEmpty() ? tempAddMapPer.get('Country') : '');
                        objVar.put('PERMANENTADDRESSPINCODE', !tempAddMapPer.isEmpty() ? tempAddMapPer.get('Pincode') : '');
                        objVar.put('PERMANENTADDRESSLINE1', !tempAddMapPer.isEmpty() ? tempAddMapPer.get('AddrLine1') : '');
                        objVar.put('PERMANENTADDRESSLINE2', !tempAddMapPer.isEmpty() ? tempAddMapPer.get('AddrLine2') : '');
                        objVar.put('PERMANENTADDRESSLINE3', !tempAddMapPer.isEmpty() ? tempAddMapPer.get('AddrLine3') : '');
                        objVar.put('PERMANENTADDRESSDISTRICT', !tempAddMapPer.isEmpty() ? tempAddMapPer.get('District') : '');
                        objVar.put('PERMANENTADDRESSCITY', !tempAddMapPer.isEmpty() ? tempAddMapPer.get('City') : '');
                        objVar.put('PERMANENTADDRESSSTATE', !tempAddMapPer.isEmpty() ? tempAddMapPer.get('State') : '');
                        objVar.put('PERMANENTADDRESSPROOF', permDoc != NULL ? permDoc : '');
                        objVar.put('CORRESPONDENCEADDRESSCOUNTRY', !tempAddMapCorr.isEmpty() ? tempAddMapCorr.get('Country') : '');
                        objVar.put('CORRESPONDENCEADDRESSPINCODE', !tempAddMapCorr.isEmpty() ? tempAddMapCorr.get('Pincode') : '');
                        objVar.put('CORRESPONDENCEADDRESSLINE1', !tempAddMapCorr.isEmpty() ? tempAddMapCorr.get('AddrLine1') : '');
                        objVar.put('CORRESPONDENCEADDRESSLINE2', !tempAddMapCorr.isEmpty() ? tempAddMapCorr.get('AddrLine2') : '');
                        objVar.put('CORRESPONDENCEADDRESSLINE3', !tempAddMapCorr.isEmpty() ? tempAddMapCorr.get('AddrLine3') : '');
                        objVar.put('CORRESPONDENCEADDRESSDISTRICT', !tempAddMapCorr.isEmpty() ? tempAddMapCorr.get('District') : '');
                        objVar.put('CORRESPONDENCEADDRESSCITY', !tempAddMapCorr.isEmpty() ? tempAddMapCorr.get('City') : '');
                        objVar.put('CORRESPONDENCEADDRESSSTATE', !tempAddMapCorr.isEmpty() ? tempAddMapCorr.get('State') : '');
                        objVar.put('CORRESPONDENCEADDRESSPROOF', corresAddDoc != NULL ? corresAddDoc : '');
                        objVar.put('WORKADDRESSCOUNTRY', '');
                        objVar.put('WORKADDRESSPINCODE', '');
                        objVar.put('WORKADDRESSLINE1', '');
                        objVar.put('WORKADDRESSLINE2', '');
                        objVar.put('WORKADDRESSLINE3', '');
                        objVar.put('WORKADDRESSDISTRICT', '');
                        objVar.put('WORKADDRESSCITY', '');
                        objVar.put('WORKADDRESSSTATE', '');
                        objVar.put('COUNTRYOFBIRTH', 'IN');
                        objVar.put('BIRTHCITY', applRec.CurrentResidenceCity__City__s != NULL ? applRec.CurrentResidenceCity__City__s : '');
                        objVar.put('TAXRESIDENCYCOUNTRY', '');
                        objVar.put('TAXIDENTIFICATIONNUMBER', '');
                        objVar.put('TAXRESIDENCYADDRESSCOUNTRY', '');
                        objVar.put('TAXRESIDENCYADDRESSLINE1', '');
                        objVar.put('TAXRESIDENCYADDRESSLINE2', '');
                        objVar.put('TAXRESIDENCYADDRESSLINE3', '');
                        objVar.put('TAXRESIDENCYADDRESSPINCODE', '');
                        objVar.put('TAXRESIDENCYADDRESSDISTRICT', '');
                        objVar.put('TAXRESIDENCYADDRESSCITY', '');
                        objVar.put('TAXRESIDENCYADDRESSSTATE', '');
                        objVar.put('DESKPERSONALISDCODE', '');
                        objVar.put('DESKPERSONALSTDCODE', '');
                        objVar.put('DESKPERSONALTELEPHONENUMBER', '');
                        objVar.put('DESKWORKISDCODE', '');
                        objVar.put('DESKWORKSTDCODE', '');
                        objVar.put('DESKWORKTELEPHONENUMBER', '');
                        objVar.put('WORKMOBILEISD', '');
                        objVar.put('WORKMOBILENUMBER', '');
                        objVar.put('PERSONALMOBILEISD', '91');
                        objVar.put('PERSONALMOBILENUMBER', applRec.MobNumber__c != NULL ? applRec.MobNumber__c : '');
                        objVar.put('CKYCID', '');
                        Map<String, String> kycPassp = !kycDocMapVar.isEmpty() && kycDocMapVar.containsKey('Passport') ? kycDocMapVar.get('Passport') : new Map<String, String>();
                        Map<String, String> kycDL = !kycDocMapVar.isEmpty() && kycDocMapVar.containsKey('DrivingLicense') ? kycDocMapVar.get('DrivingLicense') : new Map<String, String>();
                        Map<String, String> kycAadh = !kycDocMapVar.isEmpty() && kycDocMapVar.containsKey('Aadhaar') ? kycDocMapVar.get('Aadhaar') : new Map<String, String>();
                        Map<String, String> kycVot = !kycDocMapVar.isEmpty() && kycDocMapVar.containsKey('VoterId') ? kycDocMapVar.get('VoterId') : new Map<String, String>();
                        Map<String, String> kycPan = !kycDocMapVar.isEmpty() && kycDocMapVar.containsKey('Pan') ? kycDocMapVar.get('Pan') : new Map<String, String>();
                    	objVar.put('PASSPORTISSUECOUNTRY', '');
                        objVar.put('PASSPORTNUMBER', !kycPassp.isEmpty() ? kycPassp.get('DocNo') : '');
                        objVar.put('PASSPORTEXPIRYDATE', !kycPassp.isEmpty() ? kycPassp.get('ExpiryDate') : '');
                        objVar.put('VOTERIDCARD', !kycVot.isEmpty() ? kycVot.get('DocNo') : '');
                        objVar.put('PAN', !kycPan.isEmpty() ? kycPan.get('DocNo') : '');
                        objVar.put('DRIVINGLICENSENUMBER', !kycDL.isEmpty() ? kycDL.get('DocNo') : '');
                        objVar.put('DRIVINGLICENSEEXPIRYDATE', !kycDL.isEmpty() ? kycDL.get('ExpiryDate') : '');
                        objVar.put('AADHAAR', !kycAadh.isEmpty() ? kycAadh.get('DocNo') : '');
                        objVar.put('AADHAARVAULTREFERENCENUMBER', '');
                        objVar.put('AADHAARTOKEN', '');
                        objVar.put('AADHAARVIRTUALID', '');
                        objVar.put('NREGA', '');
                        objVar.put('CKYCPOIOTHERCENTRALGOVTID', '');
                        objVar.put('CKYCPOIS01IDNUMBER', '');
                        objVar.put('CKYCPOIS02IDNUMBER', '');
                        objVar.put('NATIONALID', '');
                        objVar.put('TAXIDLOCAL', '');
                        objVar.put('COMPANYREGISTRATIONNUMBER', '');
                        objVar.put('COMPANYREGISTRATIONCOUNTRY', '');
                        objVar.put('GIIN', '');
                        objVar.put('OTHERSIND', '');
                        objVar.put('OTHERSNONIND', '');
                        if(applRec.Constitution__c != NULL && !applRec.Constitution__c.equalsIgnoreCase('INDIVIDUAL')) {
                            objVar.put('PROOFOFIDSUBMITTED', proofIdSubmVar != NULL ? proofIdSubmVar : '');
                        }
                        else {
                            objVar.put('PROOFOFIDSUBMITTED', '');
                        }
                        objVar.put('MINOR', '0');
                        objVar.put('ApplicationRefNumber', applRec.LoanAppln__r.Finnone_Loan_Number__c != NULL ? applRec.LoanAppln__r.Finnone_Loan_Number__c : '');
                        objVar.put('HOLDERFORIMAGES', '');
                        objVar.put('INTERMEDIARYCODE', '');
                        objVar.put('LISTED', '');
                        objVar.put('INDUSTRY', '');
                        objVar.put('NATIONALITY', '');
                        objVar.put('COUNTRYOFOPERATION', '');
                        
                        APIVer__c apiVer = !applRec.API_Verifications__r.isEmpty() ? applRec.API_Verifications__r[0] : NULL;
                        Date riskDt = apiVer != NULL ? apiVer.CreatedDate.date() : NULL;
                        objVar.put('REGULATORYAMLRISK', apiVer != NULL && apiVer.Risk_Rating_Final__c != NULL ? apiVer.Risk_Rating_Final__c : '');
                        objVar.put('REGAMLSPECIALCATEGORY', '');
                        objVar.put('REGAMLSPECIALCATEGORYSTARTDATE', '');
                        objVar.put('REGAMLSPECIALCATEGORYENDDATE', '');
                        
                        Date lastReviewDate;
                        if(riskDt != NULL) {
                            lastReviewDate = riskDt;
                        }
                        else {
                            Date currentDate = Date.today();
                            Integer month = currentDate.month();
                            Integer year = currentDate.year();
                            Integer lastQuartMonth, lastQuartYear, lastQuartDay;
                            if(month >= 1 && month <= 3) {
								lastQuartDay = 31;
                                lastQuartMonth = 12;
                                lastQuartYear = year - 1;
                            }
                            else if(month >= 4 && month <= 6) {
								lastQuartDay = 31;
                                lastQuartMonth = 3;
                                lastQuartYear = year;
                            }
							else if(month >= 7 && month <= 9) {
								lastQuartDay = 30;
                                lastQuartMonth = 6;
                                lastQuartYear = year;
                            }
							else if(month >= 10 && month <= 12) {
								lastQuartDay = 30;
                                lastQuartMonth = 9;
                                lastQuartYear = year;
                            }
                            lastReviewDate = Date.newInstance(lastQuartYear, lastQuartMonth, lastQuartDay);
                        }
                        objVar.put('LASTRISKREVIEWDATE', lastReviewDate != NULL ? dateUtility(lastReviewDate.day(), lastReviewDate.month(), lastReviewDate.year()) : '');
                        objVar.put('NEXTRISKREVIEWDATE', '');
                        objVar.put('INCOMERANGE', '');
                        objVar.put('EXACTINCOME', '');
                        objVar.put('INCOMECURRENCY', '');
                        objVar.put('INCOMEEFFECTIVEDATE', '');
                        objVar.put('INCOMEDESCRIPTION', '');
                        objVar.put('INCOMEPROOF', '');
                        objVar.put('EXACTNETWORTH', '');
                        objVar.put('NETWORTHCURRENCY', '');
                        objVar.put('NETWORTHEFFECTIVEDATE', '');
                        objVar.put('NETWORTHDESCRIPTION', '');
                        objVar.put('NETWORTHPROOF', '');
                        objVar.put('PEP', '');
                        objVar.put('PEPCLASSIFICATION', '');
                        objVar.put('ADVERSEMEDIA', '');
                        objVar.put('ADVERSEMEDIACLASSIFICATION', '');
                        objVar.put('ADVERSEMEDIADETAILS', '');
                        objVar.put('INSIDERINFORMATION', '');
                        objVar.put('TAGS', '');
                        objVar.put('FAMILYCODE', '');
                        objVar.put('CHANNEL', '');
                        objVar.put('LINKS', '');
                        objVar.put('REPUTATIONCLASSIFICATION', '');
                        objVar.put('IUPARTYTYPE', '');
                        objVar.put('PROPERTYOWNERFLAG', '');
                        objVar.put('CONTACTPERSONFIRSTNAME', '');
                        objVar.put('CONTACTPERSONMIDDLENAME', '');
                        objVar.put('CONTACTPERSONLASTNAME', '');
                        objVar.put('CONTACTPERSONDESIGNATION', '');
                        objVar.put('CONTACTPERSONMOBILEISD', '');
                        objVar.put('CONTACTPERSONMOBILENO', '');
                        objVar.put('CONTACTPERSONMOBILEISD2', '');
                        objVar.put('CONTACTPERSONMOBILENO2', '');
                        objVar.put('CONTACTPERSONEMAILID1', '');
                        objVar.put('CONTACTPERSONEMAILID2', '');
                        objVar.put('RMUSERCODE', '');
                        objVar.put('RMTYPE', '');
                        objVar.put('RMFROMDATE', '');
                        objVar.put('EDUCATIONALQUALIFICATION', '');
                        objVar.put('DESIGNATIONOTHERS', '');
                        objVar.put('EMPLOYERNAME', '');
                        objVar.put('EMPLOYERADDRESS', '');
                        objVar.put('EMPLOYERLISTED', '');
                        objVar.put('EMPLOYERORGANISATIONTYPE', '');
                        objVar.put('CURRENTEMPLOYMENTINYEARS', '');
                        objVar.put('MODULEAPPLICABLE', 'CKYC');
                        Map<String, String> kycNPRLetter = !kycDocMapVar.isEmpty() && kycDocMapVar.containsKey('NPRLetter') ? kycDocMapVar.get('NPRLetter') : new Map<String, String>();
                        objVar.put('NPRLETTER', !kycNPRLetter.isEmpty() ? kycNPRLetter.get('DocNo') : '');
                        objVar.put('KYCATTESTATIONTYPE', '01');
                        objVar.put('FORMSIXTY', String.valueOf(formSixtyVar));
                        objVar.put('COMMENCEMENTDATE', applRec.Constitution__c != NULL && applRec.Constitution__c != 'INDIVIDUAL' && applRec.DOI__c != NULL ? dateUtility(applRec.DOI__c.day(),applRec.DOI__c.month(), applRec.DOI__c.year()) : '');
                        objVar.put('PERMANENTADDRESSPROOFOTHERSVALUE', '');
                        objVar.put('DIN', '');
                        objVar.put('CIN', '');
                        objVar.put('RELATEDPERSONCOUNTFORCKYC', '');
                        objVar.put('LAN', applRec.LoanAppln__r.Name);
                        objList.add(objVar);
                    }
                }
            }
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'Trackwizz_CKYC_A63_RequestGenerator', 'fetchApplCKYCDataReport', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        return JSON.serialize(objList);
    }
}