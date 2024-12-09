public class ApplKyc_AfterUpdate implements TriggerAction.Afterupdate {
    
    Private Static Map<String, String> kycFieldMap = new Map<String, String>{'Aadhaar' => 'AadharNo__c','Driving License' => 'DLNo__c','Pan' => 'Pan__c','Passport' => 'PassNo__c','Voter Id' => 'VotIdEpicNo__c'};
    Private Static Map<String, String> applicantFieldMap = new Map<String, String>{'Aadhaar' => 'AadhaarNo__c','Driving License' => 'DLNo__c','Pan' => 'PAN__c','Passport' => 'PassNo__c','Voter Id' => 'VotIdEpicNo__c'};
    Private Static Map<Id,Applicant__c> UpdateApplicantMap =new Map<Id,Applicant__c>();  
    
    public void Afterupdate(List<ApplKyc__c> newList,List<ApplKyc__c> oldList) {
        try{ 
            Map<Id,ApplKyc__c> OldRecordsMap= new Map<Id,ApplKyc__c>(oldList);
            Map<Id,DocDtl__c> applKycDocDtlMap = new Map<Id,DocDtl__c>();
            
            Map<Id,ApplKyc__c> applicantkycUpdateMap = new Map<Id,ApplKyc__c>();
            Map<Id,ApplKyc__c> applicantAddressUpdateMap = new Map<Id,ApplKyc__c>();
            Map<Id,ApplKyc__c> applicantDOBUpdateMap = new Map<Id,ApplKyc__c>();
            Set<id> applKYCset = new Set<Id>();
            
            List<ApplKyc__c> kycRecords = new List<ApplKyc__c>();
            
            for(ApplKyc__c applkyc : newList){
                
                if((applkyc.OCRStatus__c==GlobalConstants.MSG_SUCCESS && applkyc.OCRStatus__c!=OldRecordsMap.get(applkyc.id).OCRStatus__c)){// || (applkyc.ValidationStatus__c==GlobalConstants.MSG_SUCCESS && applkyc.ValidationStatus__c!=OldRecordsMap.get(applkyc.id).ValidationStatus__c)){
                    applKYCset.add(applkyc.Id);
                }
                //LAK-10502 Changes Start
                if((applkyc.ValidationStatus__c=='Success' || applkyc.ValidationStatus__c=='Failure') && 
                   applkyc.ValidationStatus__c!=OldRecordsMap.get(applkyc.id).ValidationStatus__c){
                       
                       kycRecords.add(applkyc);
                   }
                
                if(applkyc.OCRStatus__c=='Success' && applkyc.OCRStatus__c!=OldRecordsMap.get(applkyc.id).OCRStatus__c){
                    
                    kycRecords.add(applkyc);
                }
                
                if(string.isNotblank(applkyc.kycDoc__c) && kycFieldMap.containsKey(applkyc.kycDoc__c)){
                    
                    string fieldname =kycFieldMap.get(applkyc.kycDoc__c);
                    String oldMapValue = (String)OldRecordsMap.get(applKyc.id).get(fieldName);
                    
                    if(string.isNotblank(string.valueOf(applkyc.get(fieldname))) && 
                       (String)applKyc.get(fieldName) != oldMapValue){
                           
                           kycRecords.add(applkyc);
                       }
                    
                }                
                //LAK-10502 Changes End
                
            }
            
            if(!applKYCset.isEmpty()){
                for(DocDtl__c docDtl: [Select Id,DocTyp__c,DocCatgry__c,Applicant_KYC__c from DocDtl__c where Applicant_KYC__c IN:applKYCset AND DocCatgry__c='KYC Documents']){
                    applKycDocDtlMap.put(docDtl.Applicant_KYC__c,docDtl);
                }
                //}
                for(ApplKyc__c applkyc : newList){
                    if(applKycDocDtlMap.containsKey(applkyc.Id) && applKycDocDtlMap.get(applkyc.Id).DocTyp__c=='Residence Address proof - OVD'){
                        applicantAddressUpdateMap.put(applkyc.Applicant__c, applkyc);
                    }
                    if(applKycDocDtlMap.containsKey(applkyc.Id) && applKycDocDtlMap.get(applkyc.Id).DocTyp__c=='Identity Proof'){
                        applicantkycUpdateMap.put(applkyc.Applicant__c, applkyc);
                    }
                    if(applKycDocDtlMap.containsKey(applkyc.Id) && applKycDocDtlMap.get(applkyc.Id).DocTyp__c=='DOB Proof'){
                        applicantDOBUpdateMap.put(applkyc.Applicant__c, applkyc);
                    }
                }
                
                if(!applicantkycUpdateMap.isEmpty()){
                    updateApplicant(applicantkycUpdateMap);
                }
                if(!applicantDOBUpdateMap.isEmpty()){
                    updateApplicantDOB(applicantDOBUpdateMap);
                }
                if(!applicantAddressUpdateMap.isEmpty()){
                    UpdateApplicantAddress(applicantAddressUpdateMap);
                }
                
                
            } 
            //LAK-10502 Changes Start
            if(!kycRecords.isEmpty()){
                updateKycValuesOnApplicant(kycRecords,OldRecordsMap);
            }
            //update Applicant
            if(!UpdateApplicantMap.isEmpty()){
                update UpdateApplicantMap.values();
            }
            //LAK-10502 Changes End
            
        }
        catch(Exception ex){
            System.debug('error'+ex.getMessage() +':::' + ex.getLineNumber());
        }
    }
    
    public void updateApplicant(Map<Id,ApplKyc__c>ApplicantkycMap){
        
        if(ApplicantkycMap.keySet().size()>=1){
            for(Id applId : ApplicantkycMap.keySet()){
                ApplKyc__c apky= ApplicantkycMap.get(applId);
                Applicant__c applicant;// = new Applicant__c();
                
                if(UpdateApplicantMap.containsKey(apky.Applicant__c)){
                    applicant=UpdateApplicantMap.get(apky.Applicant__c);
                }else{
                    applicant =new Applicant__c();
                    applicant.Id=applId;
                }
                
                // if(apky.DtOfBirth__c!=null){
                //     applicant.DOB__c=apky.DtOfBirth__c;
                // } LAK-4978
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
                UpdateApplicantMap.put(applicant.id,applicant);
            }
        }
        
        
    }
    
    public void updateApplicantDOB(Map<Id,ApplKyc__c>ApplicantkycMap){
        
        if(ApplicantkycMap.keySet().size()>=1){
            for(Id applId : ApplicantkycMap.keySet()){
                ApplKyc__c apky= ApplicantkycMap.get(applId);
                Applicant__c applicant;// = new Applicant__c();
                
                if(UpdateApplicantMap.containsKey(apky.Applicant__c)){
                    applicant=UpdateApplicantMap.get(apky.Applicant__c);
                }else{
                    applicant =new Applicant__c();
                    applicant.Id=applId;
                }
                
                if(apky.DtOfBirth__c!=null){
                    applicant.DOB__c=apky.DtOfBirth__c;
                }
                UpdateApplicantMap.put(applicant.id,applicant);
            }
        }
        
        
    }
    
    public void UpdateApplicantAddress(Map<id, ApplKyc__c> Appkycmap){
        list<ApplAddr__c> Addlist=new list<ApplAddr__c>();
        
        
        Set<String> pincodeSet = new Set<String>();
        for(ApplKyc__c Appkyc: Appkycmap.values()){
            pincodeSet.add(Appkyc.Pincode__c);
        } 
        
        list<PincodeMstr__c> pincodemasterlist=[Select ZipId__c,PIN__c,City__c, City__r.City__c,City__r.CityId__c,City__r.StateId__c,City__r.State__c from PincodeMstr__c where PIN__c IN:pincodeSet];
        
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
            
            UpsertApplicantResiAddress(Appkycmap.values(),pincodeMap);
            
        }
        
    }
    
    public void UpsertApplicantResiAddress(list<ApplKyc__c> Appkycmap,Map<String,PincodeMstr__c> pincodeMap){
        
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
    
    Public static void updateKycValuesOnApplicant(List<ApplKyc__c> KycRec,Map<Id,ApplKyc__c> OldRecordsMap){
        
        try{
            List<IntgMsg__c> insertIntgMsg =new List<IntgMsg__c>();
            Map<Id,ApplKyc__c> kycMap =new Map<Id,ApplKyc__c>();
            
            for(ApplKyc__c kyc:[Select Id,Applicant__r.Constitution__c,Applicant__r.Type_of_Borrower__c,Applicant__r.CustProfile__c
                                from ApplKyc__c Where Id IN:KycRec]){
                                    
                                    kycMap.put(kyc.Id,kyc);
                                }
            
            for(ApplKyc__c applkyc:KycRec){
                
                //Validation Success
                if(applkyc.ValidationStatus__c=='Success' && applkyc.ValidationStatus__c!=OldRecordsMap.get(applkyc.id).ValidationStatus__c &&
                   applicantFieldMap.containsKey(applkyc.kycDoc__c)){
                       
                       //applkyc.Applicant__r.Constitution__c!='INDIVIDUAL' && applkyc.Applicant__r.Constitution__c != 'PROPERITORSHIP'
                       Applicant__c app = UpdateApplicantMap.containsKey(applkyc.Applicant__c)? UpdateApplicantMap.get(applkyc.Applicant__c) : new Applicant__c(Id=applkyc.Applicant__c);
                       app.put(applicantFieldMap.get(applkyc.kycDoc__c),applkyc.get(kycFieldMap.get(applkyc.kycDoc__c)));
                       if(applkyc.kycDoc__c== 'Pan' && kycMap.containsKey(applkyc.Id) && 
                          kycMap.get(applkyc.Id).Applicant__r.Constitution__c!='INDIVIDUAL' && kycMap.get(applkyc.Id).Applicant__r.Constitution__c!='PROPERITORSHIP'){
                              
                              app.CompanyName__c = applkyc.Name__c;
                              if(applkyc.DtOfBirth__c!=null){
                                  app.DOI__c = applkyc.DtOfBirth__c;
                              }
                          }
                       UpdateApplicantMap.put(app.Id,app);
                       
                       
                       //Create integration message
                       if(applkyc.kycDoc__c=='Aadhaar' || 
                          (applkyc.kycDoc__c=='Pan' && kycMap.containsKey(applkyc.Id) && kycMap.get(applkyc.Id).Applicant__r.Type_of_Borrower__c=='Financial' && 
                           (kycMap.get(applkyc.Id).Applicant__r.CustProfile__c!='SALARIED' || kycMap.get(applkyc.Id).Applicant__r.Constitution__c!='INDIVIDUAL'))){
                               insertIntgMsg.add(createIntgMsg(applkyc));
                           }
                       
                   }
                
                //Validation Failure or OCR Success
                if((applkyc.ValidationStatus__c=='Failure' && applkyc.ValidationStatus__c!=OldRecordsMap.get(applkyc.id).ValidationStatus__c &&
                    applicantFieldMap.containsKey(applkyc.kycDoc__c)) ||
                   (applkyc.OCRStatus__c=='Success' && applkyc.OCRStatus__c!=OldRecordsMap.get(applkyc.id).OCRStatus__c && applicantFieldMap.containsKey(applkyc.kycDoc__c))){
                       
                       Applicant__c app;
                       
                       if(UpdateApplicantMap.containsKey(applkyc.Applicant__c)){
                           app=UpdateApplicantMap.get(applkyc.Applicant__c);
                       }
                       else{
                           app =new Applicant__c();
                           app.put('Id',applkyc.Applicant__c);
                           
                       }
                       
                       app=KycFeildMapping(app,applkyc,kycMap);
                       UpdateApplicantMap.put(app.Id,app);
                   }
                
                
                //Change in KYC ID
                if(applicantFieldMap.containsKey(applkyc.kycDoc__c) && (applkyc.ValidationStatus__c=='Success' || applkyc.OCRStatus__c=='Success')){
                    
                    //Used to get Filed API Name
                    string fieldname =kycFieldMap.get(applkyc.kycDoc__c);
                    //to get Old Map value
                    String oldMapValue = (String)OldRecordsMap.get(applKyc.id).get(fieldName);
                    
                    if(string.isNotblank(string.valueOf(applkyc.get(fieldname))) && 
                       (String)applKyc.get(fieldName) != oldMapValue && applkyc.ValidationStatus__c=='Success'){
                           
                           Applicant__c app = UpdateApplicantMap.containsKey(applkyc.Applicant__c)? UpdateApplicantMap.get(applkyc.Applicant__c) : new Applicant__c(Id=applkyc.Applicant__c);
                           app.put(applicantFieldMap.get(applkyc.kycDoc__c),applkyc.get(kycFieldMap.get(applkyc.kycDoc__c)));
                           if(applkyc.kycDoc__c== 'Pan' && kycMap.containsKey(applkyc.Id) && 
                              kycMap.get(applkyc.Id).Applicant__r.Constitution__c!='INDIVIDUAL' && kycMap.get(applkyc.Id).Applicant__r.Constitution__c != 'PROPERITORSHIP'){
                                  
                                  app.CompanyName__c = applkyc.Name__c;
                                  if(applkyc.DtOfBirth__c!=null){
                                      app.DOI__c = applkyc.DtOfBirth__c;
                                  }
                              }
                           UpdateApplicantMap.put(app.Id,app);
                           
                           
                           //Create integration message
                           if(applkyc.kycDoc__c=='Aadhaar' || 
                              (applkyc.kycDoc__c=='Pan' && kycMap.containsKey(applkyc.Id) && kycMap.get(applkyc.Id).Applicant__r.Type_of_Borrower__c=='Financial' && 
                               (kycMap.get(applkyc.Id).Applicant__r.CustProfile__c!='SALARIED' || kycMap.get(applkyc.Id).Applicant__r.Constitution__c!='INDIVIDUAL'))){
                                   insertIntgMsg.add(createIntgMsg(applkyc));
                               }
                       }
                    
                    if(string.isNotblank(string.valueOf(applkyc.get(fieldname))) && 
                       (String)applKyc.get(fieldName) != oldMapValue && applkyc.OCRStatus__c=='Success'){
                           
                           Applicant__c app;
                           
                           if(UpdateApplicantMap.containsKey(applkyc.Applicant__c)){
                               app=UpdateApplicantMap.get(applkyc.Applicant__c);
                               
                           }else{
                               app =new Applicant__c();
                               app.put('Id',applkyc.Applicant__c);
                           }
                           app=KycFeildMapping(app,applkyc,kycMap);
                           UpdateApplicantMap.put(app.Id,app);  
                       }
                    
                }
            }
            
            if(!insertIntgMsg.isEmpty()){
                Insert insertIntgMsg;
            }
        }catch(Exception ex){
            System.debug('error'+ex.getMessage() +':::' + ex.getLineNumber());
            GlobalUtility.logMessage('Error', 'ApplKyc_AfterUpdate class', 
                                     'updateKycValuesOnApplicant', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    public static Applicant__c KycFeildMapping(Applicant__c applicant,ApplKyc__c applkyc,Map<Id,ApplKyc__c> kycMap){
        
        
        try{
            
            if(applkyc.kycDoc__c=='Driving License' && applkyc.DLExpDt__c!=null){
                applicant.DrivingLicExpDate__c=applkyc.DLExpDt__c;
            }
            else if(applkyc.kycDoc__c=='Passport' && applkyc.PassExpDt__c!=null){
                applicant.PassportExpDate__c=applkyc.PassExpDt__c;
            }
            else if(applkyc.kycDoc__c== 'Pan' && kycMap.containsKey(applkyc.Id) && 
                    kycMap.get(applkyc.Id).Applicant__r.Constitution__c!='INDIVIDUAL' && kycMap.get(applkyc.Id).Applicant__r.Constitution__c != 'PROPERITORSHIP'){
                        applicant.CompanyName__c = applkyc.Name__c;
                        if(applkyc.DtOfBirth__c!=null){
                            applicant.DOI__c = applkyc.DtOfBirth__c;
                        }
                        
                    }
            applicant.put(applicantFieldMap.get(applkyc.kycDoc__c),applkyc.get(kycFieldMap.get(applkyc.kycDoc__c)));
            
        }catch(Exception ex){
            System.debug('error'+ex.getMessage() +':::' + ex.getLineNumber());
        }
        return applicant;
        
    }
    public static IntgMsg__c createIntgMsg(ApplKyc__c applkyc){
        IntgMsg__c msg =new IntgMsg__c();
        
        try{
            
            msg.BU__c='HL / STL';
            msg.IsActive__c=TRUE;
            msg.Status__c='New';
            msg.RefId__c=applkyc.Id;
            msg.RefObj__c='ApplKyc__c';
            msg.Name=applkyc.kycDoc__c=='Aadhaar'?'Aadhar Vault':'GST Search Basis PAN';
            msg.Svc__c=applkyc.kycDoc__c=='Aadhaar'?'SFDC Aadhar Vault':'GST Search Basis PAN';
            msg.ParentRefId__c=applkyc.kycDoc__c=='Aadhaar'?'':applkyc.Applicant__c;
            msg.ParentRefObj__c=applkyc.kycDoc__c=='Aadhaar'?'':'Applicant__c';
            
        }catch(Exception ex){
            System.debug('error'+ex.getMessage() +':::' + ex.getLineNumber());
        }
        return msg;
    }
}