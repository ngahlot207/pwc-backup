public class HunterRequestGenerator implements ICalloutRequestGenerator {
    public void generate(List<IntgMsg__c> msgs, String service, String processType) { 
        try {
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType });
            if(!msgs.isEmpty()) {
                List<Id> loanApplIds = new List<Id>();
                List<Id> loanAppIdsTemp = new List<Id>();
                List<Id> applIds = new List<Id>();
				List<IntgMsg__c> updateIntrecods = new List<IntgMsg__c>(); 
                Map<Id, Id> intMsgIdLoanAppIdMap = new Map<Id, Id>();
                Map<Id, Applicant__c> mapAppIdRecs = new Map<Id, Applicant__c>();
                //Map of Loan Application Ids as key and Applicant__c records as values
                Map<Id, List<Applicant__c>> applLAMap = new Map<Id, List<Applicant__c>>();


                //Collecting Loan Application record Ids
                for(IntgMsg__c intMsgRec : msgs) {
                    if(intMsgRec.RefObj__c == 'LoanAppl__c') {
						loanApplIds.add(intMsgRec.RefId__c);
                        loanAppIdsTemp.add(intMsgRec.RefId__c);
					}
                    else if(intMsgRec.RefObj__c == 'Applicant__c') {
						applIds.addAll(intMsgRec.RefId__c.split(','));
					}
                }

                for(LoanAppl__c tempRec : [SELECT Id FROM LoanAppl__c WHERE Id IN (SELECT LoanAppln__c FROM Applicant__c WHERE Id IN : applIds)]) {
                    loanApplIds.add(tempRec.Id);
                }

                for(Applicant__c applyRec : [SELECT Id, Name, Constitution__c, LoanAppln__c, LoanAppln__r.Name, DOB__c, MthrMdnName__c, Father_Name__c, FName__c, MName__c, LName__c, CompanyName__c, MobNumber__c, CurrentResidenceCity__CountryCode__s, toLabel(ApplType__c), (SELECT id, Name, kycDoc__c, PassNo__c, AadharEncripted__c, Pan__c, DLNo__c, VotIdEpicNo__c, NPRNumber__c, AadharNo__c FROM Applicant_KYC__r), (Select Id,HouseNo__c,AddrLine1__c, AddrLine2__c, AddrTyp__c, Locality__c, City__c,Pincode__c,  State__c, Country__c FROM Applicant_Addresses__r WHERE AddrTyp__c IN ('Residence Address','Principal place for business','Residence Cum office','Office Address')) FROM Applicant__c WHERE LoanAppln__c IN :loanApplIds]) {
                    
                    if(!applIds.isEmpty() && applIds.contains(applyRec.Id)) {
                        if(applLAMap.containsKey(applyRec.LoanAppln__c)) {
                            applLAMap.get(applyRec.LoanAppln__c).add(applyRec);
                        }
                        else {
                            List<Applicant__c> tempList = new List<Applicant__c>();
                            tempList.add(applyRec);
                            applLAMap.put(applyRec.LoanAppln__c, tempList);
                        } 
                    }
                    else if(!applIds.isEmpty() && !applIds.contains(applyRec.Id) && applyRec.ApplType__c == 'APPLICANT') {
                        if(applLAMap.containsKey(applyRec.LoanAppln__c)) {
                            applLAMap.get(applyRec.LoanAppln__c).add(applyRec);
                        }
                        else {
                            List<Applicant__c> tempList = new List<Applicant__c>();
                            tempList.add(applyRec);
                            applLAMap.put(applyRec.LoanAppln__c, tempList);
                        } 
                        /*
                        List<Applicant__c> tempList = new List<Applicant__c>();
                        tempList.add(applyRec);
                        applLAMap.put(applyRec.LoanAppln__c, tempList);
						*/
                    }

                    if(!loanAppIdsTemp.isEmpty() && loanAppIdsTemp.contains(applyRec.LoanAppln__c)) {
                        if(applLAMap.containsKey(applyRec.LoanAppln__c)) {
                            applLAMap.get(applyRec.LoanAppln__c).add(applyRec);
                        }
                        else {
                            List<Applicant__c> tempList = new List<Applicant__c>();
                            tempList.add(applyRec);
                            applLAMap.put(applyRec.LoanAppln__c, tempList);
                        }
                    }
                    
                    mapAppIdRecs.put(applyRec.Id, applyRec);
                }

                for(IntgMsg__c intMsgRec : msgs) {
					if(intMsgRec.RefObj__c == 'LoanAppl__c') {
						intMsgIdLoanAppIdMap.put(intMsgRec.RefId__c, intMsgRec.Id);
					}
					else if(intMsgRec.RefObj__c == 'Applicant__c') {
						intMsgIdLoanAppIdMap.put(mapAppIdRecs.get(intMsgRec.RefId__c.split(',')[0]).LoanAppln__c, intMsgRec.Id);
					}
				}

                if(!applLAMap.isEmpty()) {
                    for(Id LAId : applLAMap.keySet()) {
                        if(applLAMap.containsKey(LAId)) {
                            Id loanAppId = LAId;
                            List<Applicant__c> applys = applLAMap.get(LAId);
                            String loanAppName = (!applys.isEmpty()) ? applys[0].LoanAppln__r.Name : '';
                            //List<String> strList = loanAppName.split('-');

                            HunterRequestWrapper.Header headerVal = new HunterRequestWrapper.Header();
                            headerVal.tenantId = GlobalConstants.tenantId;
                            headerVal.requestType = GlobalConstants.requestType;
                            headerVal.clientReferenceId = GlobalConstants.clientReferenceId + loanAppName;// strList[0] + '_' + strList[1];
                            headerVal.expRequestId = '';
                            headerVal.messageTime = String.valueOf(System.Now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
                            headerVal.options = new HunterRequestWrapper.Options();

                            HunterRequestWrapper.Payload paylVar = new HunterRequestWrapper.Payload();
                            List<HunterRequestWrapper.Contacts> conList = new List<HunterRequestWrapper.Contacts>();
                            List<HunterRequestWrapper.Applicants> applList = new List<HunterRequestWrapper.Applicants>();
                            if(!applys.isEmpty()) {
                                for(Applicant__c app : applys) {
                                    HunterRequestWrapper.Contacts con = new HunterRequestWrapper.Contacts();
                                    HunterRequestWrapper.Person personVar = new HunterRequestWrapper.Person();
                                    List<HunterRequestWrapper.IdentityDocuments> identityDocsList = new List<HunterRequestWrapper.IdentityDocuments>();
                                    List<HunterRequestWrapper.Names> namesList = new List<HunterRequestWrapper.Names>();
                                    List<HunterRequestWrapper.Telephones> teleList = new List<HunterRequestWrapper.Telephones>();
                                    List<HunterRequestWrapper.Addresses> addr = new List<HunterRequestWrapper.Addresses>();
                                    List<HunterRequestWrapper.EmploymentHistory> empHistory = new List<HunterRequestWrapper.EmploymentHistory>();
                                    List<HunterRequestWrapper.Incomes> inc = new List<HunterRequestWrapper.Incomes>();
                                    con.id = String.valueOf(app.Name);

                                    String typeOfApplicant, typeOfApplVar;
                                    if(String.isNotBlank(app.ApplType__c)) {
                                        if(app.ApplType__c == 'APPLICANT') {
                                            typeOfApplicant = 'APPLICANT';
                                            typeOfApplVar = 'MAIN_APPLICANT';
                                        } 
                                        else if(app.ApplType__c == 'CO-APPLICANT') {
                                            typeOfApplicant = 'CO_APPLICANT'; //CO_APPLICANT
                                            typeOfApplVar = 'JOINT_APPLICANT';
                                        }
                                        else if(app.ApplType__c == 'GUARANTOR') {
                                            typeOfApplicant = 'GUARANTOR';
                                            typeOfApplVar = 'JOINT_APPLICANT';
                                        }
                                    }
                                    personVar.typeOfPerson = typeOfApplicant != NULL ? typeOfApplicant : '';

                                    HunterRequestWrapper.PersonDetails perDetails = new HunterRequestWrapper.PersonDetails();
                                    perDetails.dateOfBirth = app.DOB__c != NULL ? String.valueOf(app.DOB__c) : '';
                                    perDetails.mothersFullName = app.MthrMdnName__c != NULL ? String.valueOf(app.MthrMdnName__c) : '';
							        perDetails.fathersFullName = app.Father_Name__c != NULL ? String.valueOf(app.Father_Name__c) : '';

							        HunterRequestWrapper.Names namesVar = new HunterRequestWrapper.Names();
                                    namesVar.id = GlobalUtility.getUniqueNumber();
                                    namesVar.type = GlobalConstants.types;
                                    namesVar.firstName = (app.Constitution__c != NULL && app.Constitution__c == 'INDIVIDUAL') ? String.valueOf(app.FName__c) : String.valueOf(app.Constitution__c);
							        namesVar.middleNames = (app.Constitution__c != NULL && app.Constitution__c == 'INDIVIDUAL') ? String.valueOf(app.MName__c) : '';
							        namesVar.surName = (app.Constitution__c != NULL && app.Constitution__c == 'INDIVIDUAL') ? String.valueOf(app.LName__c) : String.valueOf(app.CompanyName__c);
                                    namesList.add(namesVar);

                                    personVar.names = namesList;
							        personVar.personDetails = perDetails;

							        HunterRequestWrapper.Telephones teleph = new HunterRequestWrapper.Telephones();
                                    teleph.id = GlobalUtility.getUniqueNumber();
                                    teleph.type = GlobalConstants.Mobtype;
                                    teleph.areaCode = app.CurrentResidenceCity__CountryCode__s != NULL ? app.CurrentResidenceCity__CountryCode__s : '';
                                    teleph.numberVar = app.MobNumber__c != NULL ? app.MobNumber__c : '';
                                    if(app.ApplType__c == 'APPLICANT') {
                                        teleList.add(teleph);
                                    }
                                    

                                    if(!app.Applicant_KYC__r.isEmpty()) {
                                        for(ApplKyc__c applKycRec : app.Applicant_KYC__r) {
                                            
                                            if(applKycRec.kycDoc__c != NULL) {
                                                
                                                if(applKycRec.kycDoc__c == 'Pan' && applKycRec.Pan__c != NULL) {
                                                    HunterRequestWrapper.IdentityDocuments identityDocs = new HunterRequestWrapper.IdentityDocuments();
                                                    identityDocs.id = GlobalUtility.getUniqueNumber();
                                                    identityDocs.documentType = 'PAN CARD'; //PAN
                                                    identityDocs.documentNumber = applKycRec.Pan__c;
                                                    identityDocsList.add(identityDocs);
                                                }
                                                else if(applKycRec.kycDoc__c == 'Aadhaar' && applKycRec.AadharNo__c != NULL) {
                                                    HunterRequestWrapper.IdentityDocuments identityDocs = new HunterRequestWrapper.IdentityDocuments();
                                                    identityDocs.id = GlobalUtility.getUniqueNumber();
                                                    identityDocs.documentType = 'AADHAR ID'; //AADHAAR
                                                    identityDocs.documentNumber = applKycRec.AadharNo__c;
                                                    identityDocsList.add(identityDocs);
                                                }
                                                else if(applKycRec.kycDoc__c == 'Driving License' && applKycRec.DLNo__c != NULL) { 
                                                    HunterRequestWrapper.IdentityDocuments identityDocs = new HunterRequestWrapper.IdentityDocuments();
                                                    identityDocs.id = GlobalUtility.getUniqueNumber();
                                                    identityDocs.documentType = 'DRIVING LISENCE'; // DRIVER_LICENSE
                                                    identityDocs.documentNumber = applKycRec.DLNo__c;
                                                    identityDocsList.add(identityDocs);                                            
                                                }
                                                else if(applKycRec.kycDoc__c == 'Voter Id' && applKycRec.VotIdEpicNo__c != NULL) { 
                                                    HunterRequestWrapper.IdentityDocuments identityDocs = new HunterRequestWrapper.IdentityDocuments();
                                                    identityDocs.id = GlobalUtility.getUniqueNumber();
                                                    identityDocs.documentType = 'VOTERS CARD'; //VOTER_ID
                                                    identityDocs.documentNumber = applKycRec.VotIdEpicNo__c;
                                                    identityDocsList.add(identityDocs);
                                                }
                                                else if(applKycRec.kycDoc__c == 'Passport' && applKycRec.PassNo__c != NULL) {
                                                    HunterRequestWrapper.IdentityDocuments identityDocs = new HunterRequestWrapper.IdentityDocuments();
                                                    identityDocs.id = GlobalUtility.getUniqueNumber();
                                                    identityDocs.documentType = 'PASSPORT';
                                                    identityDocs.documentNumber = applKycRec.PassNo__c;
                                                    identityDocsList.add(identityDocs);
                                                }
                                                else if(applKycRec.kycDoc__c == 'Letter issued by the National Population Register' && applKycRec.NPRNumber__c != NULL) {
                                                    HunterRequestWrapper.IdentityDocuments identityDocs = new HunterRequestWrapper.IdentityDocuments();
                                                    identityDocs.id = GlobalUtility.getUniqueNumber();
                                                    identityDocs.documentType = 'OTHER';
                                                    identityDocs.documentNumber = applKycRec.NPRNumber__c;
                                                    identityDocsList.add(identityDocs);
                                                }
                                            }
                                        }
                                    }
                                    
                                    Map<String, ApplAddr__c> addrMap = new Map<String, ApplAddr__c>();
                                    
                                    if((!app.Applicant_Addresses__r.isEmpty()) && String.isNotBlank(app.ApplType__c)) {
                                        ApplAddr__c currentAddId1, currentAddId2, currentAddId3;
                                        for(ApplAddr__c applAddr : app.Applicant_Addresses__r) {
                                            if(String.isNotBlank(applAddr.AddrTyp__c) && applAddr.AddrTyp__c == 'Principal place for business') {
                                            	addrMap.put('PRIMARY', applAddr);
                                            } 
                                            if(String.isNotBlank(applAddr.AddrTyp__c)) {
                                                if(applAddr.AddrTyp__c == 'Residence Address') { 
                                                    currentAddId1 = applAddr;
                                                }
                                                else if(applAddr.AddrTyp__c == 'Residence Cum office') {
                                                    currentAddId2 = applAddr;
                                                }
                                                else if(applAddr.AddrTyp__c == 'Office Address') {
                                                    currentAddId3 = applAddr;
                                                }
                                            }
                                        }
                                        if(currentAddId1 != NULL) {
                                            addrMap.put('CURRENT', currentAddId1);
                                        }
                                        else if(currentAddId2 != NULL) {
                                            addrMap.put('CURRENT', currentAddId2);
                                        }
                                        else if(currentAddId3 != NULL) {
                                            addrMap.put('CURRENT', currentAddId3);
                                        }
                                    }
                                    
                                    if(!addrMap.isEmpty()) {
                                        for(String addTyp : addrMap.keySet()) {
                                            ApplAddr__c applAddr = addrMap.get(addTyp);
                                            HunterRequestWrapper.Addresses address = new HunterRequestWrapper.Addresses();
                                            address.id = GlobalUtility.getUniqueNumber();
                                            if(addTyp == 'PRIMARY') {
                                                address.addressType = 'PRIMARY';
                                            }
                                            else if(addTyp == 'CURRENT') {
                                                address.addressType = 'CURRENT';
                                            }
                                            address.buildingName = applAddr.HouseNo__c != NULL ? applAddr.HouseNo__c : '' ;
                                            address.street = applAddr.AddrLine1__c != NULL ? applAddr.AddrLine1__c : '';
                                            address.street2 = applAddr.AddrLine2__c != NULL ? applAddr.AddrLine2__c : '';
                                            address.locality = applAddr.Locality__c != NULL ? applAddr.Locality__c : '';
                                            address.country = applAddr.Country__c != NULL ? applAddr.Country__c : '';
                                            address.postal = applAddr.Pincode__c != NULL ? applAddr.Pincode__c : '';
                                            address.stateProvinceCode = applAddr.State__c != NULL ? applAddr.State__c : '';
                                            address.postTown = applAddr.City__c != NULL ? applAddr.City__c : '';
                                            address.countryCode = GlobalConstants.CountryName;
                                            addr.add(address);
                                        }
                                    }
									
                                    HunterRequestWrapper.Organization org = new HunterRequestWrapper.Organization();
                                    con.person = personVar;
                                    con.Organization = org;
                                    con.addresses = addr;
                                    con.telephones = teleList;
                                    con.identityDocuments = identityDocsList;
                                    con.employmentHistory = empHistory;
                                    con.incomes = inc;

                                    HunterRequestWrapper.Applicants appl = new HunterRequestWrapper.Applicants();
                                    appl.id = GlobalUtility.getUniqueNumber(); 
                                    appl.contactId = String.valueOf(app.Name);
                                    appl.applicantType = typeOfApplVar != NULL ? typeOfApplVar : '';

                                    conList.add(con);
							        applList.add(appl);
                                }
                                HunterRequestWrapper.Application applicRec = new HunterRequestWrapper.Application();
						        applicRec.originalRequestTime = String.valueOf(System.Now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));

                                HunterRequestWrapper.ProductDetails prodDetails = new HunterRequestWrapper.ProductDetails();
                                prodDetails.productCode = GlobalConstants.productCode;
                                prodDetails.productType = GlobalConstants.productType;
                                applicRec.productDetails = prodDetails;
                                applicRec.applicants = applList;

                                paylVar.source = GlobalConstants.source;
                                paylVar.contacts = conList;
                                paylVar.application = applicRec;

                                HunterRequestWrapper hunterReqWrapp = new HunterRequestWrapper();
                                hunterReqWrapp.header = headerVal;
                                hunterReqWrapp.payload = paylVar;

                                IntgMsg__c intg = New IntgMsg__c();
                                intg.id = intMsgIdLoanAppIdMap.get(loanAppId);  //intMsgRec.Id;
                                intg.Req__c = JSON.serialize(hunterReqWrapp).replace('numberVar', 'number');
                                intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                                updateIntrecods.add(intg);
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
                }
            }
        }
        catch(Exception ex) {
            System.debug('error'+ex.getMessage());
            GlobalUtility.logMessage('Error', 'HunterRequestGenerator' + ex.getLineNumber(), 'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    }
}