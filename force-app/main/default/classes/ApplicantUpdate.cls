public class ApplicantUpdate implements TriggerAction.Afterinsert {  
    
    public set<id> applicantKYCset;  
    public Map<id, ApplKyc__c> ApplicantkycMap;
    public list<ApplKyc__c> ApplicantKyclist;
    public set<id> applKycSet;
    public set<Id> applDOBKycSet;
    public set<Id> docIds;
    
    // Processing the document details and getting the Applicantkycid 
    public void Afterinsert(List<DocDtl__c> newList) { 
        
        applicantKYCset=new set<id>();
        applKycSet= new set<Id>();
        applDOBKycSet = new set<Id>();
        docIds= new set<Id>();
        
        Map<DocDtl__c,ApplKyc__c> docKycMap =new Map<DocDtl__c,ApplKyc__c>();
        
        if(!newList.isEmpty())
        {
            for(DocDtl__c doc: newList)
            {	
                system.debug(':::'+doc.Applicant_KYC__c);
                if(doc.Applicant_KYC__c!=null && doc.DocTyp__c=='Residence Address proof - OVD')
                {
                    applicantKYCset.add(doc.Applicant_KYC__c);
                }
                if(doc.Applicant_KYC__c!=null && doc.DocTyp__c=='Identity Proof'){
                    applKycSet.add(doc.Applicant_KYC__c);
                }
                if(doc.Applicant_KYC__c!=null && doc.DocTyp__c=='DOB Proof'){
                    applDOBKycSet.add(doc.Applicant_KYC__c);
                }
                
                if( doc.Applicant_KYC__c!=null && ((doc.Applicant_KYC__r.ValidationStatus__c==GlobalConstants.MSG_SUCCESS  && ( String.isBlank(doc.Applicant_KYC__r.AdrsSplitStatus__c) || doc.Applicant_KYC__r.AdrsSplitStatus__c == GlobalConstants.MSG_SUCCESS )) || doc.Applicant_KYC__r.OCRStatus__c==GlobalConstants.MSG_SUCCESS) ){ 
                    if(doc.DocTyp__c=='Residence Address proof - Deemed OVD'||doc.DocTyp__c=='Registered office - Address Proof' || doc.DocTyp__c=='Principal Place of Business - Address Proof'){
                        docKycMap.put(doc,doc.Applicant_KYC__r);
                    }
                }
                
                if(doc.Id!=null && (doc.DocCatgry__c =='KYC Documents' || doc.DocCatgry__c =='PAN Documents')){
                    docIds.add(doc.Id);
                }
            }
            
            
        }
        if(applicantKYCset.size()>0)
        {
            getapplicantKYCwithApplicant(applicantKYCset);
        }
        if(applKycSet.size()>0)
        {
            updateApplicant(applKycSet);
        }
        if(applDOBKycSet.size()>0)
        {
            updateApplicantDOB(applDOBKycSet);
        }
        
        if(!docKycMap.isEmpty()){
            upsertApplicantAddress(docKycMap);
        }
        
        if(!docIds.isEmpty()){
            createIntgMsgForNameMatch(docIds); 
        }
        
    }
    
    // Checking the applicantkyc ocr and validation status and preparing the map.
    public void getapplicantKYCwithApplicant(set<id> Appkycid)
    {
        
        ApplicantkycMap=new Map<id,ApplKyc__c>();
        
        for(ApplKyc__c Appky:[select id,Applicant__c,AddrLine1__c,AddrLine2__c,State__c,Landmark__c,Locality__c,HouseNo__c,City__c,Pincode__c,Country__c,ValidationStatus__c from ApplKyc__c where Id IN:Appkycid AND (ValidationStatus__c=:GlobalConstants.MSG_SUCCESS OR OCRStatus__c=:GlobalConstants.MSG_SUCCESS)]){
            ApplicantkycMap.put(appky.Applicant__c, AppKy);          
        }
        if(ApplicantkycMap.keyset().size()>0){
            UpdateApplicantAddress(ApplicantkycMap);
        }
        
    }
    
    // Updating applicant residential address with validated applicant kyc address
    public void UpsertApplicantResiAddress(list<ApplKyc__c> Appkycmap,Map<String,PincodeMstr__c> pincodeMap)
    {
        list<ApplAddr__c> Addlist=new list<ApplAddr__c>();
        list<PincodeMstr__c> pincodemasterlist=[Select ZipId__c,PIN__c,City__c, City__r.City__c,City__r.CityId__c,City__r.StateId__c,City__r.State__c from PincodeMstr__c where PIN__c=:Appkycmap[0].Pincode__c];
        for(ApplKyc__c Appkyc: Appkycmap)
        {
            
            ApplAddr__c apAdd= new ApplAddr__c();
            apAdd.AddrTyp__c='Residence Address';
            apAdd.AddrLine1__c=Appkyc.AddrLine1__c;
            apAdd.AddrLine2__c=Appkyc.AddrLine2__c;
            apAdd.Landmark__c=Appkyc.Landmark__c;
            apAdd.Locality__c=Appkyc.Locality__c;
            apAdd.HouseNo__c=Appkyc.HouseNo__c;
            apAdd.Country__c=Appkyc.Country__c;
            apAdd.Applicant__c=AppKyc.Applicant__c;
            if(pincodeMap.containsKey(Appkyc.Pincode__c)){
                apAdd.CityId__c=pincodeMap.get(Appkyc.Pincode__c).City__r.CityId__c;
                apAdd.City__c=pincodeMap.get(Appkyc.Pincode__c).City__r.City__c;
                apAdd.Pincode__c=pincodeMap.get(Appkyc.Pincode__c).PIN__c;
                apAdd.State__c=pincodeMap.get(Appkyc.Pincode__c).City__r.State__c;
                apAdd.StateId__c=pincodeMap.get(Appkyc.Pincode__c).City__r.StateId__c;
            }
            else{
                apAdd.City__c=Appkyc.City__c;
                apAdd.State__c=Appkyc.State__c;
                apAdd.Pincode__c=Appkyc.Pincode__c;
            }
            Addlist.add(apAdd);
        }
        if(!Addlist.isEmpty())  
        {
            //Upsert Addlist;
            insert Addlist;
        }
        
    }
    
    
    public void updateApplicant(Set<Id> appKYCIDs){
        ApplicantkycMap=new Map<id,ApplKyc__c>();
        List<Applicant__c> updateApplicantList = new List<Applicant__c>();
        for(ApplKyc__c Appky:[select id,Applicant__c,Name__c,FatherName__c,HusbandName__c,DtOfBirth__c,Gender__c,kycDoc__c,DLExpDt__c,PassExpDt__c,ValidationStatus__c from ApplKyc__c where ID IN:appKYCIDs AND (ValidationStatus__c=:GlobalConstants.MSG_SUCCESS OR OCRStatus__c=:GlobalConstants.MSG_SUCCESS)]){
            ApplicantkycMap.put(appky.Applicant__c, AppKy);          
        }
        if(ApplicantkycMap.keySet().size()>=1){
            for(Id applId : ApplicantkycMap.keySet()){
                ApplKyc__c apky= ApplicantkycMap.get(applId);
                Applicant__c applicant = new Applicant__c();
                applicant.Id=applId;
                //if(apky.DtOfBirth__c!=null){
                //    applicant.DOB__c=apky.DtOfBirth__c;
                //}
                if(!String.isEmpty(apky.FatherName__c)){
                    applicant.Father_Name__c=apky.FatherName__c;
                }
                if(!String.isEmpty(apky.Gender__c)){
                    applicant.Gender__c=apky.Gender__c;
                }
                
                if(!String.isEmpty(apky.Name__c)){
                    String[] nameTokens = apky.Name__c.split(' ');
                    
                    if (nameTokens.size() >= 1) {
                        applicant.FName__c = nameTokens[0];
                    }
                    if (nameTokens.size() >= 3) {
                        applicant.MName__c = nameTokens[1];
                        for (Integer i = 2; i < nameTokens.size(); i++) {
                            if (i == 2) {
                                applicant.LName__c = nameTokens[i];
                            } else {
                                applicant.LName__c += ' ' + nameTokens[i];
                            }
                        }
                    } 
                    else if (nameTokens.size() == 2) {
                        applicant.LName__c = nameTokens[1];
                    }
                    
                    
                }
                if(!String.isEmpty(apky.HusbandName__c)){
                    applicant.SpName__c=apky.HusbandName__c;
                }
                
                if(apky.kycDoc__c =='Passport' && apky.PassExpDt__c !=null){
                    applicant.PassportExpDate__c = apky.PassExpDt__c;
                }
                if(apky.kycDoc__c =='Driving License' && apky.DLExpDt__c != null){
                    applicant.DrivingLicExpDate__c = apky.DLExpDt__c;
                }
                updateApplicantList.add(applicant);
            }
        }
        
        if(!updateApplicantList.isEmpty()){
            Update updateApplicantList;
        }
    }
    
    
    public void UpdateApplicantAddress(Map<id, ApplKyc__c> Appkycmap){
        list<ApplAddr__c> Addlist=new list<ApplAddr__c>();
        System.debug('===*741741*'+Appkycmap.keyset());
        
        Set<String> pincodeSet = new Set<String>();
        for(ApplKyc__c Appkyc: Appkycmap.values()){
            pincodeSet.add(Appkyc.Pincode__c);
        } 
        System.debug('===**********'+pincodeSet);
        list<PincodeMstr__c> pincodemasterlist=[Select ZipId__c,PIN__c,City__c, City__r.City__c,City__r.CityId__c,City__r.StateId__c,City__r.State__c from PincodeMstr__c where PIN__c IN:pincodeSet];
        System.debug(pincodemasterlist);
        Map<String,PincodeMstr__c> pincodeMap= new  Map<String,PincodeMstr__c>();
        
        if(!pincodemasterlist.isEmpty()){
            for(PincodeMstr__c pin : pincodemasterlist){
                pincodeMap.put(pin.PIN__c,pin);
            }
        }
        
        for(ApplAddr__c apAdd:[select id,AddrLine1__c,AddrLine2__c,AddrTyp__c,City__c,Country__c,Landmark__c,Locality__c,HouseNo__c,Applicant__c from ApplAddr__c where Applicant__c In :Appkycmap.keyset() and AddrTyp__c='Residence Address']){
            if(Appkycmap.containskey(apAdd.Applicant__c))
            {
                ApplKyc__c apky= Appkycmap.get(apAdd.Applicant__c);
                
                apAdd.AddrLine1__c=apky.AddrLine1__c;
                apAdd.AddrLine2__c=apky.AddrLine2__c;
                apAdd.Landmark__c=apky.Landmark__c;
                apAdd.Locality__c=apky.Locality__c;
                apAdd.HouseNo__c=apky.HouseNo__c;
                apAdd.Country__c=apky.Country__c;
                
                if(pincodeMap.containsKey(apky.Pincode__c)){
                    apAdd.CityId__c=pincodeMap.get(apky.Pincode__c).City__r.CityId__c;
                    apAdd.City__c=pincodeMap.get(apky.Pincode__c).City__r.City__c;
                    apAdd.Pincode__c=pincodeMap.get(apky.Pincode__c).PIN__c;
                    apAdd.State__c=pincodeMap.get(apky.Pincode__c).City__r.State__c;
                    apAdd.StateId__c=pincodeMap.get(apky.Pincode__c).City__r.StateId__c;
                }
                else{
                    apAdd.City__c=apky.City__c;
                    apAdd.State__c=apky.State__c;
                    apAdd.Pincode__c=apky.Pincode__c;
                }
                Addlist.add(apAdd);
                
            }
            
            
        }
        if(!Addlist.isEmpty())  
        {
            Update Addlist;
        }
        else
        {	
            System.debug('::::::::::::::::::::::::::::');
            UpsertApplicantResiAddress(Appkycmap.values(),pincodeMap);
            
        }
        
    }
    
    public void updateApplicantDOB(Set<Id> appKYCIDs){
        ApplicantkycMap=new Map<id,ApplKyc__c>();
        List<Applicant__c> updateApplicantList = new List<Applicant__c>();
        for(ApplKyc__c Appky:[select id,Applicant__c,Name__c,FatherName__c,HusbandName__c,DtOfBirth__c,Gender__c from ApplKyc__c where ID IN: appKYCIDs AND (ValidationStatus__c=:GlobalConstants.MSG_SUCCESS OR OCRStatus__c=:GlobalConstants.MSG_SUCCESS)]){
            ApplicantkycMap.put(appky.Applicant__c, AppKy);          
        }
        if(ApplicantkycMap.keySet().size()>=1){
            for(Id applId : ApplicantkycMap.keySet()){
                ApplKyc__c apky= ApplicantkycMap.get(applId);
                Applicant__c applicant = new Applicant__c();
                applicant.Id=applId;
                if(apky.DtOfBirth__c!=null){
                    applicant.DOB__c=apky.DtOfBirth__c;
                }
                updateApplicantList.add(applicant);
            }
        }
        
        if(!updateApplicantList.isEmpty()){
            Update updateApplicantList;
        }
    }
    
    //*******************************************************************
    public static void upsertApplicantAddress(Map<DocDtl__c,ApplKyc__c> docKycMap){
        
        try {
            
            Set<Id> applicantIds=new Set<Id>();
            Set<String> pincodeSet =new Set<String>();
            Map<String,PincodeMstr__c> pincodeMap= new  Map<String,PincodeMstr__c>();
            Map<Id,Map<String,ApplAddr__c>> addressMap=new Map<Id,Map<String,ApplAddr__c>>();
            
            List<ApplAddr__c> upsertApplAddrs =new List<ApplAddr__c>();
            
            //Querying ApplKyc__c 
            for(ApplKyc__c applkyc:docKycMap.values()){
                
                if(applkyc.Applicant__c!=null){
                    applicantIds.add(applkyc.Applicant__c);
                }
                
                if(String.isNotblank(applkyc.Pincode__c)){
                    pincodeSet.add(applkyc.Pincode__c);
                }
            }
            
            //Querying PincodeMstr__c 
            if(!pincodeSet.isEmpty()){
                
                for(PincodeMstr__c pinMstr:[Select ZipId__c,PIN__c,City__c, City__r.City__c,City__r.CityId__c,City__r.StateId__c,City__r.State__c from PincodeMstr__c where PIN__c IN:pincodeSet]){
                    pincodeMap.put(pinMstr.PIN__c,pinMstr); 
                }
            }
            
            //Querying ApplAddr__c
            if(!applicantIds.isEmpty()){
                
                for(ApplAddr__c addrs:[Select id,AddrTyp__c,Applicant__c from ApplAddr__c where Applicant__c IN:applicantIds]){
                    
                    if(addressMap.containsKey(addrs.Applicant__c) && addressMap.get(addrs.Applicant__c).containsKey(addrs.AddrTyp__c)){
                        
                        addressMap.get(addrs.Applicant__c).put(addrs.AddrTyp__c,addrs);
                    }else{
                        addressMap.put(addrs.Applicant__c,new Map<String,ApplAddr__c>{addrs.AddrTyp__c=>addrs});
                    }
                }
            }
            
            //Upsert address
            for(DocDtl__c docdt:docKycMap.keyset()){
                
                ApplKyc__c kyc=docKycMap.get(docdt);
                
                ApplAddr__c appladdrs =new ApplAddr__c();
                
                if(addressMap.containsKey(kyc.Applicant__c) && docTypetoAddressType.containsKey(docdt.DocTyp__c) &&
                  addressMap.get(kyc.Applicant__c).containsKey(docTypetoAddressType.get(docdt.DocTyp__c))){
                    //ApplAddr__c ads=addressMap.get(kyc.Applicant__c).get(docTypetoAddressType.get(docdt.DocTyp__c));
                    appladdrs.Id=addressMap.get(kyc.Applicant__c).get(docTypetoAddressType.get(docdt.DocTyp__c)).Id;
                }
                else{
                    appladdrs.Applicant__c=kyc.Applicant__c;
                    appladdrs.LoanAppl__c=kyc.Applicant__r.LoanAppln__c;
                    appladdrs.AddrTyp__c = docTypetoAddressType.get(docdt.DocTyp__c);
                    
                }
                appladdrs.AddrLine1__c=string.isNotblank(kyc.AddrLine1__c)?kyc.AddrLine1__c:'';
                appladdrs.AddrLine2__c=string.isNotblank(kyc.AddrLine2__c)?kyc.AddrLine2__c:'';
                appladdrs.Landmark__c=string.isNotblank(kyc.Landmark__c)?kyc.Landmark__c:'';
                appladdrs.Locality__c=string.isNotblank(kyc.Locality__c)?kyc.Locality__c:'';
                appladdrs.HouseNo__c=string.isNotblank(kyc.HouseNo__c)?kyc.HouseNo__c:'';
                appladdrs.Country__c=string.isNotblank(kyc.Country__c)?kyc.Country__c:'';
                
                if(pincodeMap.containsKey(kyc.Pincode__c)){
                    appladdrs.CityId__c=pincodeMap.get(kyc.Pincode__c).City__r.CityId__c;
                    appladdrs.City__c=pincodeMap.get(kyc.Pincode__c).City__r.City__c;
                    appladdrs.Pincode__c=pincodeMap.get(kyc.Pincode__c).PIN__c;
                    appladdrs.State__c=pincodeMap.get(kyc.Pincode__c).City__r.State__c;
                    appladdrs.StateId__c=pincodeMap.get(kyc.Pincode__c).City__r.StateId__c;
                }
                else{
                    appladdrs.City__c=kyc.City__c;
                    appladdrs.State__c=kyc.State__c;
                    appladdrs.Pincode__c=kyc.Pincode__c;
                }
                upsertApplAddrs.add(appladdrs);
            }
            
            
            if(!upsertApplAddrs.isEmpty()){
                upsert upsertApplAddrs;
            }
            
        } catch (Exception ex) {
            System.debug('Error Message' +ex.getMessage() + 'Line:::'+ex.getLineNumber());
            
        }
    }
    
    //********************************************************************************
    public static void createIntgMsgForNameMatch(Set<Id> docIds){
        
        List<DocDtl__c> docDtls=[SELECT Id,Applicant_KYC__c,Applicant_KYC__r.Name__c,Appl__c,Appl__r.Constitution__c,DocSubTyp__c,Name,DocTyp__c,DocCatgry__c,Applicant_KYC__r.kycDoc__c,Applicant_KYC__r.ValidationStatus__c FROM DocDtl__c Where Id IN:docIds];
        //SELECT Id,Applicant_KYC__c,Applicant_KYC__r.Name__c,Appl__c,Appl__r.Constitution__c,DocSubTyp__c,Name,DocTyp__c,DocCatgry__c,Applicant_KYC__r.kycDoc__c FROM DocDtl__c
        if(!docDtls.isEmpty()){
            
            Set<Id> applicantIds = new Set<Id>();
            Set<String> kycDocuments = new Set<String>{'Aadhaar','Voter Id','Passport','Driving License','Pan','Shop and Establishment','Electricity Bill','Udyam Registration Certificate'};
                Map<Id,Id>  applKycMap = new Map<Id,Id>(); 
            Map<Id,Boolean> applIDProofMap = new Map<Id,Boolean>();
            List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();
            
            for(DocDtl__c doc: docDtls){
                if(doc.Appl__c!=null){
                    applicantIds.add(doc.Appl__c);
                }
                
            }
            
            if(!applicantIds.isEmpty()){
                for(DocDtl__c docDtl : [SELECT Id,Applicant_KYC__r.Name__c,Applicant_KYC__r.ValidationStatus__c,Appl__c,Appl__r.Constitution__c,DocSubTyp__c,Name,DocTyp__c,DocCatgry__c FROM DocDtl__c WHERE 
                                        ((Appl__r.Constitution__c ='INDIVIDUAL' AND DocCatgry__c ='KYC Documents'  AND DocTyp__c ='Identity Proof')  OR
                                        (Appl__r.Constitution__c <> 'INDIVIDUAL' AND DocCatgry__c ='PAN Documents'  AND DocTyp__c ='PAN')) AND 
                                        Applicant_KYC__c != null  AND Applicant_KYC__r.Name__c !=null  AND  (Applicant_KYC__r.ValidationStatus__c = 'Success' OR Applicant_KYC__r.OCRStatus__c = 'Success') 
                                        AND Appl__c IN: applicantIds ORDER BY CreatedDate DESC]){
                                             if(!applIDProofMap.containsKey(docDtl.Appl__c)){
                                                 applIDProofMap.put(docDtl.Appl__c,TRUE);
                                             } 
                                         }
            }
            
            for(DocDtl__c doc: docDtls){
                
                if((doc.DocCatgry__c =='KYC Documents' || doc.DocCatgry__c =='PAN Documents') && doc.Applicant_KYC__c!=null && doc.Applicant_KYC__r.ValidationStatus__c==GlobalConstants.MSG_SUCCESS && doc.Appl__c!=null && kycDocuments.contains(doc.Applicant_KYC__r.kycDoc__c) ){
                    
                    if((doc.DocTyp__c=='Identity Proof' &&  doc.Appl__r.Constitution__c =='INDIVIDUAL') || ( doc.DocTyp__c =='PAN' && doc.Appl__r.Constitution__c <> 'INDIVIDUAL')){
                        
                        if(!applKycMap.containsKey(doc.Appl__c)){
                            applKycMap.put(doc.Appl__c,doc.Id);
                        }
                    }
                    else{
                        
                        if(applIDProofMap.containsKey(doc.Appl__c) && applIDProofMap.get(doc.Appl__c)){
                            
                            IntgMsg__c intMsgRec = new IntgMsg__c();
                            intMsgRec.Name = 'Name Similarity';
                            intMsgRec.BU__c = 'HL / STL';
                            intMsgRec.Status__c = GlobalConstants.INT_MSG_STATUS_NEW;
                            intMsgRec.MStatus__c = GlobalConstants.INT_MSG_MStatus_BLANK;
                            intMsgRec.Svc__c = 'Name Similarity';
                            intMsgRec.RefId__c = doc.Applicant_KYC__c;
                            intMsgRec.RefObj__c = 'ApplKyc__c';
                            intMsgRec.ParentRefId__c = doc.Appl__c;
                            intMsgRec.ParentRefObj__c = 'Applicant__c';
                            intMsgRec.IsActive__c = TRUE;
                            createRequestList.add(intMsgRec); 
                        }
                    }
                    
                }
                
            }
            
            if(!applKycMap.isEmpty()){
                
                for(DocDtl__c docDtl : [SELECT Id,Applicant_KYC__c,Applicant_KYC__r.Name__c,Appl__c,Appl__r.Constitution__c,DocSubTyp__c,Name,DocTyp__c,DocCatgry__c,Applicant_KYC__r.kycDoc__c FROM DocDtl__c WHERE  DocCatgry__c IN ('PAN Documents','KYC Documents')  AND Appl__c IN:applKycMap.keySet() AND ID NOT IN: applKycMap.values()]){
                    if(applIDProofMap.containsKey(docDtl.Appl__c) && applIDProofMap.get(docDtl.Appl__c) && kycDocuments.contains(docDtl.Applicant_KYC__r.kycDoc__c)){
                        IntgMsg__c intMsgRec = new IntgMsg__c();
                        intMsgRec.Name = 'Name Similarity';
                        intMsgRec.BU__c = 'HL / STL';
                        intMsgRec.Status__c = GlobalConstants.INT_MSG_STATUS_NEW;
                        intMsgRec.MStatus__c = GlobalConstants.INT_MSG_MStatus_BLANK;
                        intMsgRec.Svc__c = 'Name Similarity';
                        intMsgRec.RefId__c = docDtl.Applicant_KYC__c;
                        intMsgRec.RefObj__c = 'ApplKyc__c';
                        intMsgRec.ParentRefId__c = docDtl.Appl__c;
                        intMsgRec.ParentRefObj__c = 'Applicant__c';
                        intMsgRec.IsActive__c = TRUE;
                        createRequestList.add(intMsgRec); 
                    }
                }
                
                for(APIVer__c apiVer : [SELECT Id,Appl__c FROM APIVer__c  WHERE IsLatest__c=TRUE AND RecordType.DeveloperName IN ('GST','QualificationCheck') AND  IntegrationStatus__c =:GlobalConstants.MSG_SUCCESS ]){
                    
                    if(applIDProofMap.containsKey(apiVer.Appl__c) && applIDProofMap.get(apiVer.Appl__c)){
                        IntgMsg__c intMsgRec = new IntgMsg__c();
                        intMsgRec.Name = 'Name Similarity';
                        intMsgRec.BU__c = 'HL / STL';
                        intMsgRec.Status__c = GlobalConstants.INT_MSG_STATUS_NEW;
                        intMsgRec.MStatus__c = GlobalConstants.INT_MSG_MStatus_BLANK;
                        intMsgRec.Svc__c = 'Name Similarity';
                        intMsgRec.RefId__c = apiVer.Id;
                        intMsgRec.RefObj__c = 'APIVer__c';
                        intMsgRec.ParentRefId__c = apiVer.Appl__c;
                        intMsgRec.ParentRefObj__c = 'Applicant__c';
                        intMsgRec.IsActive__c = TRUE;
                        createRequestList.add(intMsgRec); 
                    }
                    
                }
                
            }
            
            if(!createRequestList.isEmpty()){
                insert createRequestList;
            }
        }
    }            
    
    
    //**************************************************
    private static final Map<String, String> docTypetoAddressType = new Map<String, String>{
        'Residence Address proof - OVD' => 'Residence Address',
        'Residence Address proof - Deemed OVD' => 'Residence Address',
        'Registered office - Address Proof' => 'Registered place for business',  //LAK-9302 - Office Address => Registered place for business 
        'Principal Place of Business - Address Proof' => 'Principal place for business'
            };
                
                
    
 }