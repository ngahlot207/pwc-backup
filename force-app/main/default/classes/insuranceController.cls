public with sharing class insuranceController {
    @AuraEnabled
    public static  list<Insurance> getInsuranceDet(string appicantId , string loanAppId){
        try {
            list<Insurance__c> insList = new list<Insurance__c>();
            insList = [SELECT Id, LoanAppln__c, Appl__c, IsActive__c,InsProvider__c,
                       InsProvider__r.Name, InsProvider__r.MPHnm__c, InsProvider__r.MPno__c, 
                       InsType__c, SumAmount__c, SumInsuredType__c,Plan_Name__c,
                       PolicyTenute__c, PremiumAmount__c, Penettration__c, isCoBorrNominee__c 
                       FROM Insurance__c WHERE LoanAppln__c =: loanAppId AND  Appl__c =:appicantId ]; 
            
            System.debug('insList :  ' + insList);
           
            
            list<InsParti__c> insParticipantList = new list<InsParti__c>();
            insParticipantList =  [SELECT  Id,  LoanAppln__c,Appl__r.Id, Appl__r.fName__c, Appl__r.LName__c, Appl__r.Title__c, Appl__r.Gender__c,
                                   Appl__r.DOB__c, Appl__r.Relationship__c,Appl__r.ApplType__c, Insurance__c, Parti__c ,appointeeFor__c ,NomPercent__c
                                   FROM InsParti__c  WHERE  LoanAppln__c =: loanAppId ];
            //AND  Appl__c =:appicantId
            
            
            
            System.debug('insParticipantList :  ' + insParticipantList);
            
            //   list<Applicant__c> appList = new list<Applicant__c>();
            //   appList = [SELECT  Id,  Name, LoanAppln__c, CompanyName__c, fName__c, LName__c, DOB__c, DOI__c, KeyManName__c, MobNumber__c,
            //    EmailId__c, CustProfile__c, Constitution__c,  MName__c, ApplType__c, FullName__c FROM Applicant__c WHERE LoanAppln__c =:loanAppId   ];
            
            
            Map<ID, Applicant__c> appMap = new Map<ID, Applicant__c>([SELECT  Id,  Name, LoanAppln__c, CompanyName__c, fName__c, LName__c, DOB__c, DOI__c, KeyManName__c, MobNumber__c,
                                                                      EmailId__c, CustProfile__c, Constitution__c,  MName__c, ApplType__c, FullName__c FROM Applicant__c WHERE LoanAppln__c =:loanAppId   ]);
            
            list<Insurance> insRespList = new  list<Insurance>();
            
            List<ApplAddr__c> appAddList = new List<ApplAddr__c>();
            appAddList = [SELECT Id,  Applicant__c , Applicant__r.ApplType__c	, AddrLine1__c, AddrLine2__c, City__c, 
                          Pincode__c, State__c,  LoanAppl__c, HouseNo__c,  AddrTyp__c, MailAddr__c, Locality__c,StateId__c,PinId__c,CityId__c
                          FROM ApplAddr__c
                          WHERE Applicant__c IN: appMap.keySet() AND (AddrTyp__c ='Residence Address' OR  AddrTyp__c ='Principal place for business' OR  AddrTyp__c ='Residence Cum office' ) AND (Applicant__r.ApplType__c	!= null )
                         ];
            Map<ID, ApplAddr__c> appAddMap = new Map<ID, ApplAddr__c>();
            Map<ID, List<ApplAddr__c>> listAppAddMap = new Map<ID, List<ApplAddr__c>>();
            if(!appAddList.isEmpty()){
                for (ApplAddr__c appAdd : appAddList) {
                    if(listAppAddMap.isEmpty()){
                        List<ApplAddr__c> addList1 = new List<ApplAddr__c>();
                        addList1.add(appAdd);
                        listAppAddMap.put(appAdd.Applicant__c,addList1);
                    }
                    else{
                        List<ApplAddr__c> addList2 =new List<ApplAddr__c>();
                        system.debug(listAppAddMap);
                        system.debug(listAppAddMap.get(appAdd.Applicant__c));
                        addList2 = listAppAddMap.get(appAdd.Applicant__c);
                        if(addList2 != null){
                            addList2.add(appAdd);
                            listAppAddMap.put(appAdd.Applicant__c,addList2);
                        }else{
                            List<ApplAddr__c> addList3 = new List<ApplAddr__c>();
                            addList3.add(appAdd);
                            listAppAddMap.put(appAdd.Applicant__c,addList3);
                        }               
                    }                         
                }
            }       
            for (Id key : listAppAddMap.keySet()) {
                List<ApplAddr__c> applicantAddList = listAppAddMap.get(key);     
                map<string, ApplAddr__c> appAddTypeMap = new   map<string, ApplAddr__c>();
                for (ApplAddr__c appAdd : applicantAddList) {   
                    appAddTypeMap.put(appAdd.AddrTyp__c,appAdd);
                } 
                if(appAddTypeMap.keySet().contains('Residence Address') ){
                    appAddMap.put(appAddTypeMap.get('Residence Address').Applicant__c,appAddTypeMap.get('Residence Address') );
                }else if(appAddTypeMap.keySet().contains('Principal place for business') ){
                    appAddMap.put(appAddTypeMap.get('Principal place for business').Applicant__c,appAddTypeMap.get('Principal place for business') );
                }else if(appAddTypeMap.keySet().contains('Residence Cum office') ){
                    appAddMap.put(appAddTypeMap.get('Residence Cum office').Applicant__c,appAddTypeMap.get('Residence Cum office') );
                }                                    
            }
            
            
            if(insList.size()>0){
                for (Insurance__c ins : insList) {
                    Insurance insResp = new Insurance(); 
                    insResp.insurance =  ins; 
                    
                    //rest to  be added here
                    System.debug('insParticipantList '+ insParticipantList.size() + insParticipantList );
                    if(insParticipantList.size()>0){
                        list<Nominee> nomineeList = new list<Nominee>();
                        list<Appointee> appointeeList = new list<Appointee>();
                        List<InsParti__c> nomInsPart = new List<InsParti__c>();
                        List<InsParti__c> appoInsPart = new List<InsParti__c>();
                        for (InsParti__c insParti : insParticipantList) { 
                            System.debug('insParti ' + insParti + insParti.Insurance__c + ins.Id + insParti.Parti__c  );
                            if(insParti.Insurance__c == ins.Id && insParti.Parti__c =='Nominee' ){
                                nomInsPart.add(insParti);
                            }
                            if(insParti.Insurance__c == ins.Id && insParti.Parti__c =='Appointee' ){
                                
                                appoInsPart.add(insParti);
                            }
                        }
                        System.debug('nomInsPart ' + nomInsPart);
                        System.debug('appoInsPart ' + appoInsPart);
                        if(nomInsPart.size()>0){
                            for (InsParti__c nomParti : nomInsPart) { 
                                Nominee nominee = new Nominee();
                                nominee.Id = nomParti.Id;
                                nominee.isDelete = false;
                                nominee.percent = String.valueOf(nomParti.NomPercent__c);
                                nominee.insId = ins.Id;
                                //Appl__r., Appl__r., Appl__r.Title__c, Appl__r.Gender__c,
                                //   Appl__r.DOB__c, Appl__r.Relationship__c,
                                
                                nominee.fromOldList= false;
                                if(appMap.get(nomParti.Appl__r.Id) != null && (appMap.get(nomParti.Appl__r.Id).ApplType__c == 'N' || appMap.get(nomParti.Appl__r.Id).ApplType__c == 'A')){
                                    nominee.fromOldList= false;
                                    nominee.readOnly= false;
                                }else{
                                    nominee.fromOldList= true;
                                    nominee.readOnly= true;
                                }
                                nominee.title = nomParti.Appl__r.Title__c;
                                nominee.appId = nomParti.Appl__r.Id;
                                nominee.fName = nomParti.Appl__r.fName__c;
                                nominee.lName = nomParti.Appl__r.LName__c;
                                nominee.gender = nomParti.Appl__r.Gender__c;
                                nominee.appType = nomParti.Appl__r.ApplType__c;
                                nominee.dateOfBirth = nomParti.Appl__r.DOB__c;
                                nominee.relation = nomParti.Appl__r.Relationship__c;
                                nominee.insPartType =  nomParti.Parti__c;
                                ApplAddr__c nomAppAdd = new ApplAddr__c();
                                nomAppAdd = appAddMap.get(nomParti.Appl__r.Id);
                                if(nomAppAdd != null){
                                    nominee.hNo = nomAppAdd.HouseNo__c ;
                                    nominee.street = nomAppAdd.AddrLine1__c ;
                                    nominee.area = nomAppAdd.AddrLine2__c ;
                                    nominee.city = nomAppAdd.City__c ;
                                    nominee.nomAddType = nomAppAdd.AddrTyp__c; 
                                    nominee.pincode = nomAppAdd.Pincode__c ;
                                    nominee.addId = nomAppAdd.Id ;
                                    nominee.stateId = nomAppAdd.StateId__c ;
                                    nominee.pincodeId = nomAppAdd.PinId__c ;
                                    nominee.cityId = nomAppAdd.CityId__c ;
                                    nominee.state = nomAppAdd.State__c ;
                                    
                                    
                                }else{
                                    nominee.hNo = '' ;
                                    nominee.street ='';
                                    nominee.area ='' ;
                                    nominee.city = '' ;
                                    nominee.pincode = '' ; 
                                    nominee.stateId = '';
                                    nominee.pincodeId ='' ;
                                    nominee.cityId = '';
                                    nominee.state = '';
                                    nominee.addId = null;
                                }
                                
                                // nominee.hNo = appAddMap.get(nomParti.Appl__r.Id).HouseNo__c ;
                                // nominee.street = appAddMap.get(nomParti.Appl__r.Id).AddrLine1__c ;
                                // nominee.area = appAddMap.get(nomParti.Appl__r.Id).AddrLine2__c ;
                                // nominee.city = appAddMap.get(nomParti.Appl__r.Id).City__c ;
                                // nominee.pincode = appAddMap.get(nomParti.Appl__r.Id).Pincode__c ;
                                // nominee.insParticep = insParti;
                                //restto  be added here
                                nomineeList.add(nominee);
                            }
                            
                            // for (InsParti__c insParti : insParticipantList) { 
                            //     Nominee nominee = new Nominee();
                            //     Appointee appointee = new Appointee();
                            
                            //     System.debug('insParti' + ins.Id+' :: '+insParti.Insurance__c +insParti.Parti__c);
                            //     //'Appointee' 'Assured' 'Nominee' 'Policy Holder' null
                            //     if(insParti.Insurance__c == ins.Id && insParti.Parti__c =='Nominee' ){
                            //         nominee.Id = insParti.Id;
                            //         //Appl__r., Appl__r., Appl__r.Title__c, Appl__r.Gender__c,
                            //         //   Appl__r.DOB__c, Appl__r.Relationship__c,
                            //         nominee.title = insParti.Appl__r.Title__c;
                            //         nominee.fromOldList= false;
                            
                            //         nominee.fName = insParti.Appl__r.fName__c;
                            //         nominee.lName = insParti.Appl__r.LName__c;
                            //         nominee.gender = insParti.Appl__r.Gender__c;
                            //         nominee.dateOfBirth = insParti.Appl__r.DOB__c;
                            //         nominee.relation = insParti.Appl__r.Relationship__c;
                            
                            //        // nominee.insParticep = insParti;
                            //           //restto  be added here
                            //           nomineeList.add(nominee);
                            //     }
                            //     if(insParti.Insurance__c == ins.Id &&  insParti.Parti__c =='Appointee'){
                            //         appointee.Id = insParti.Appl__c;
                            //         appointee.appointeeFor = insParti.appointeeFor__c;
                            //           //restto  be added here
                            
                            //           appointeeList.add(appointee);
                            //     }
                            //  }
                            if(appointeeList.size()>0){
                                for (Appointee app : appointeeList) {
                                    for (Nominee nom : nomineeList) {
                                        System.debug(' Nominee det  '+ app.appointeeFor + ' :: '+nom.Id);  
                                        if(app.appointeeFor == nom.id){
                                            nom.appointee = app;
                                            System.debug('updated Nominee '+ nomineeList);
                                        }   
                                    }                           
                                }
                            }
                            System.debug('appointee list '+ appointeeList);
                            System.debug('nomineeList list '+ nomineeList);
                            insResp.nomineeList = nomineeList;
                        }
                        if(appoInsPart.size()>0){
                            for (InsParti__c appoParti : appoInsPart) { 
                                Appointee appointee = new Appointee();
                                
                                
                                appointee.Id = appoParti.Id;
                                
                                appointee.insId = ins.Id;
                                appointee.appointeeFor = appoParti.appointeeFor__c ;
                                
                                appointee.title = appoParti.Appl__r.Title__c;
                                appointee.appId = appoParti.Appl__r.Id;
                                appointee.fName = appoParti.Appl__r.fName__c;
                                appointee.lName = appoParti.Appl__r.LName__c;
                                appointee.gender = appoParti.Appl__r.Gender__c;
                                appointee.dateOfBirth = appoParti.Appl__r.DOB__c;
                                appointee.relation = appoParti.Appl__r.Relationship__c;
                                appointee.insPartType =  appoParti.Parti__c;
                                ApplAddr__c appoAppAdd = new ApplAddr__c();
                                appoAppAdd = appAddMap.get(appoParti.Appl__r.Id);
                                if(appoAppAdd != null){
                                    appointee.hNo = appoAppAdd.HouseNo__c ;
                                    appointee.street = appoAppAdd.AddrLine1__c ;
                                    appointee.area = appoAppAdd.AddrLine2__c ;
                                    appointee.city = appoAppAdd.City__c ;
                                    appointee.state = appoAppAdd.State__c ;
                                    appointee.pincode = appoAppAdd.Pincode__c ;
                                    appointee.addId = appoAppAdd.Id ;
                                    
                                }else{
                                    appointee.hNo = '' ;
                                    appointee.street ='';
                                    appointee.area ='' ;
                                    appointee.city = '' ;
                                    appointee.pincode = '' ; 
                                    appointee.addId = null;
                                }
                                
                                // nominee.hNo = appAddMap.get(nomParti.Appl__r.Id).HouseNo__c ;
                                // nominee.street = appAddMap.get(nomParti.Appl__r.Id).AddrLine1__c ;
                                // nominee.area = appAddMap.get(nomParti.Appl__r.Id).AddrLine2__c ;
                                // nominee.city = appAddMap.get(nomParti.Appl__r.Id).City__c ;
                                // nominee.pincode = appAddMap.get(nomParti.Appl__r.Id).Pincode__c ;
                                // nominee.insParticep = insParti;
                                //restto  be added here
                                System.debug( appoParti.Id +':::'  +'appoParti.appointeeFor__c ' +  appoParti.appointeeFor__c  );
                                if(appoParti.appointeeFor__c != null){
                                    System.debug( 'appoParti.appointeeFor__c ' + appoParti.appointeeFor__c );
                                    for (Nominee nom : nomineeList) {
                                        System.debug( 'appintee match ' +nom.Id + '  :: '+ appoParti.appointeeFor__c );  
                                        if(nom.Id == appoParti.appointeeFor__c){
                                            System.debug( 'appintee match success');    
                                            nom.appointee = appointee;
                                            
                                        }
                                        
                                    }
                                }
                            }
                            
                        }
                        
                    }
                    insRespList.add(insResp);
                    System.debug('insRespList  '+ insRespList);
                }
                
                
            }   
            // throw new AuraHandledException('mmm'); 
            return insRespList;
            
        } catch (Exception e) {
            System.debug('error message' + e.getMessage() + '  line no ::'+ e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
            
        }
    }

    //LAK-10096
    @AuraEnabled
    public static List<MasterData__c> getMasterDataDet(string loanAppId){
        try {
            //LAK-10096
            list<LoanAppl__c> loanApplicationRec = [SELECT Id, BrchCode__c, Product__c FROM LoanAppl__c WHERE id =: loanAppId];

            List<LocBrchJn__c> locBrchList = [
            SELECT Id, Location__r.State__c
            FROM LocBrchJn__c
            WHERE Branch__r.BrchCode__c = :loanApplicationRec[0].BrchCode__c
            ];

            String product_name = loanApplicationRec[0].Product__c;

            String state = '';

            if (locBrchList.size() > 0) {
                state = locBrchList[0].Location__r.State__c;
            }

            List<MasterData__c> listMaster = new List<MasterData__c>();
            listMaster = [SELECT Id, Name, MPHnm__c, MPno__c, Type__c, State__c, Product__c FROM MasterData__c WHERE (Type__c = 'Life Insurance' OR Type__c = 'General Insurance') AND State__c INCLUDES (:state) AND Product__c INCLUDES (:product_name)];
       
        
            return listMaster;
            
        } 
        
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string addNomineeList(list<ModefyNomineeList> nomineeList ,string applicantId,string loanAppId){
        try {
            List<InsParti__c> insPartiList = new List<InsParti__c>(); 
            insPartiList = [SELECT Id,  LoanAppln__c, Appl__c, Insurance__c,
                            Insurance__r.InsType__c,  Parti__c, appointeeFor__c ,isActive__c  
                            FROM InsParti__c  where Appl__c =:  applicantId ];
            Map<string, InsParti__c> inaPartMap = new Map<string, InsParti__c>();
            for (InsParti__c ver : insPartiList) {
                inaPartMap.put(ver.Appl__c,ver);
            }
            List<InsParti__c> insPartiUpsertList = new List<InsParti__c>();
            if(nomineeList.size()>0){
                for (ModefyNomineeList nom : nomineeList) {
                    InsParti__c insPart = new InsParti__c();
                    if(nom.forInsType == 'Life Insurance'){
                        if(nom.addStatus == true){
                            insPart.LoanAppln__c = loanAppId;
                            insPart.Appl__c = nom.id;
                            insPart.Insurance__c = nom.insId;
                            insPart.Parti__c = 'Nominee';
                            insPart.isActive__c = true;
                        }else{
                            insPart =  inaPartMap.get(nom.id);
                            insPart.isActive__c =  false;
                        }
                    }  
                    if(nom.forInsType == 'General Insurance'){
                        if(nom.addStatus == true){
                            insPart.LoanAppln__c = loanAppId;
                            insPart.Appl__c = nom.id;
                            insPart.Insurance__c = nom.insId;
                            insPart.Parti__c = 'Nominee';
                            insPart.isActive__c = true;
                        }else{
                            insPart =  inaPartMap.get(nom.id);
                            insPart.isActive__c =  false;
                        }
                    } 
                    insPartiUpsertList.add(insPart);                                   
                }  
            }
            if(insPartiUpsertList.size()>0){
                upsert  insPartiUpsertList;
                
            }
            return 'insPartiUpsertList';
            
        } catch (Exception e) {
            System.debug('error message' + e.getMessage()+'  line no ::'+ e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
            
        }
    }
    @AuraEnabled
    public static list<Nominee> getAvailabeApplicants(string loanAppId){
        try {
            list<Nominee> nomList =new list<Nominee>();
            Map<string, string> appTpMap = new Map<string, string>();
            appTpMap = PDController.getPickListValuesIntoMap(
                'Applicant__c',
                'ApplType__c'
            );
            system.debug(appTpMap);
            Map<string, string> appTypeMap = new Map<string, string>();
            for(string key : appTpMap.keySet()){
                appTypeMap.put(appTpMap.get(key),key);
            } 
            system.debug(appTypeMap);
            Map<ID, Applicant__c> appMap = new Map<ID, Applicant__c>([SELECT  Id, FName__c, LName__c, DOB__c, Title__c, Gender__c, LoanAppln__c,Relationship__c, TabName__c ,ApplType__c,Constitution__c
                                                                      FROM Applicant__c 
                                                                      WHERE LoanAppln__c  =:loanAppId
                                                                      AND   ApplType__c     !='N' AND ApplType__c    !='A' AND ApplType__c    !=null AND Constitution__c != null AND Constitution__c ='INDIVIDUAL' ]);
            
            List<ApplAddr__c> appAddList = new List<ApplAddr__c>();
            appAddList = [SELECT Id,  Applicant__c, AddrLine1__c, AddrLine2__c, City__c, 
                          Pincode__c, State__c,  LoanAppl__c, HouseNo__c,  AddrTyp__c, MailAddr__c, Locality__c,StateId__c,PinId__c,CityId__c
                          FROM ApplAddr__c
                          WHERE (AddrTyp__c ='Residence Address' OR  AddrTyp__c ='Principal place for business' OR  AddrTyp__c ='Residence Cum office' ) AND Applicant__c IN: appMap.keySet() ];
            Map<ID, ApplAddr__c> appAddMap = new Map<ID, ApplAddr__c>();
            Map<ID, List<ApplAddr__c>> listAppAddMap = new Map<ID, List<ApplAddr__c>>();
            // for (ApplAddr__c appAdd : appAddList) {
            //     appAddMap.put(appAdd.Applicant__c,appAdd);         
            // }
            //
            
            if(!appAddList.isEmpty()){
                for (ApplAddr__c appAdd : appAddList) {
                    if(listAppAddMap.isEmpty()){
                        List<ApplAddr__c> addList1 = new List<ApplAddr__c>();
                        addList1.add(appAdd);
                        listAppAddMap.put(appAdd.Applicant__c,addList1);
                    }
                    else{
                        List<ApplAddr__c> addList2 =new List<ApplAddr__c>();
                        system.debug(listAppAddMap);
                        system.debug(listAppAddMap.get(appAdd.Applicant__c));
                        addList2 = listAppAddMap.get(appAdd.Applicant__c);
                        if(addList2 != null){
                            addList2.add(appAdd);
                            listAppAddMap.put(appAdd.Applicant__c,addList2);
                        }else{
                            List<ApplAddr__c> addList3 = new List<ApplAddr__c>();
                            addList3.add(appAdd);
                            listAppAddMap.put(appAdd.Applicant__c,addList3);
                        }               
                    }                         
                }
            }       
            for (Id key : listAppAddMap.keySet()) {
                List<ApplAddr__c> applicantAddList = listAppAddMap.get(key);     
                map<string, ApplAddr__c> appAddTypeMap = new   map<string, ApplAddr__c>();
                for (ApplAddr__c appAdd : applicantAddList) {   
                    appAddTypeMap.put(appAdd.AddrTyp__c,appAdd);
                } 
                if(appAddTypeMap.keySet().contains('Residence Address') ){
                    appAddMap.put(appAddTypeMap.get('Residence Address').Applicant__c,appAddTypeMap.get('Residence Address') );
                }else if(appAddTypeMap.keySet().contains('Principal place for business') ){
                    appAddMap.put(appAddTypeMap.get('Principal place for business').Applicant__c,appAddTypeMap.get('Principal place for business') );
                }else if(appAddTypeMap.keySet().contains('Residence Cum office') ){
                    appAddMap.put(appAddTypeMap.get('Residence Cum office').Applicant__c,appAddTypeMap.get('Residence Cum office') );
                }                                    
            }
            
            
            
            
            
            //
            System.debug('appAddList :  ' + appAddList);
            
            System.debug('appAddMap :  ' + appAddMap);
            for (Id app :  appMap.keySet()) {
                Applicant__c applicant =new   Applicant__c ();
                applicant =  appMap.get(app);
                Nominee nom = new Nominee();
                nom.fromOldList = true;
                nom.appId = app;
                nom.appType = applicant.ApplType__c;
                nom.appTypeLabel = appTypeMap.get(applicant.ApplType__c);
                nom.title = applicant.Title__c;
                nom.fName = applicant.FName__c;
                nom.lName = applicant.LName__c;
                nom.gender = applicant.Gender__c;
                nom.dateOfBirth = applicant.DOB__c;
                nom.relation = applicant.Relationship__c;
                nom.tabName = applicant.TabName__c;
                nom.percent = '';
                
                nom.isDelete = false;
                nom.readOnly = true;
                
                if(appAddMap.get(app) != null){
                    System.debug('appAddList :  ' + app+' ::: '+ appAddMap.get(app));
                    nom.hNo = appAddMap.get(app).HouseNo__c;             
                    nom.street = appAddMap.get(app).AddrLine1__c ;
                    nom.area = appAddMap.get(app).AddrLine2__c ;
                    nom.city = appAddMap.get(app).City__c ;
                    nom.nomAddType = appAddMap.get(app).AddrTyp__c; 
                    nom.pincode = appAddMap.get(app).Pincode__c ;
                    nom.state = appAddMap.get(app).State__c ;
                    nom.stateId = appAddMap.get(app).StateId__c ;
                    nom.pincodeId = appAddMap.get(app).PinId__c ;
                    nom.cityId = appAddMap.get(app).CityId__c ;
                    nom.addId = appAddMap.get(app).Id ;
                }
                
                //  nom.street = appAddMap.get(app).str;
                //   nom.area = applicant.Title__c;
                //    nom.city = applicant.Title__c;
                //     nom.pincode = applicant.Title__c;
                //      nom.percent = applicant.Title__c;
                //       nom.appointee = applicant.Title__c;
                // nom.percent = applicant.Title__c;
                nomList.add(nom);
                
            }            
            return nomList;
            
        } catch (Exception e) {
            System.debug('error message' + e.getMessage()+'  line no ::'+ e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
            
        }
    }
    @AuraEnabled
    public static list<Nominee>  saveNomineeDet(list<Nominee> nomineeList ,string loanAppId){
        System.debug('nomineeList is' );
        System.debug('nomineeList'+':: '+nomineeList.size()+':: '+ nomineeList);
        
        try {
            List<Nominee> nomListNew = new List<Nominee>();
            List<Nominee> nomListOld = new List<Nominee>();
            for (Nominee nom : nomineeList) {
                if(nom.fromOldList == true){
                    nomListOld.add(nom);
                }else{
                    nomListNew.add(nom);
                }
            }
            if(nomListNew.size()>0){
                
                List<InsParti__c> insPartList = new List<InsParti__c>();
                List<Applicant__c> applicantList = new List<Applicant__c>();
                List<ApplAddr__c> appAddList = new List<ApplAddr__c>();
                
                Map<id, ApplAddr__c> appAddListMap = new Map<id, ApplAddr__c>();
                Map<id, Applicant__c> applicantListMap = new Map<id, Applicant__c>();
                
                Map<id, InsParti__c> insPartDeleteMap = new Map<id, InsParti__c>();
                Map<id, Applicant__c> applicantDeleteMap = new Map<id, Applicant__c>();
                
                
                Integer tempNo = 0;
                for (Nominee nom : nomListNew) {
                    if(nom.id != null && nom.id.length() != 18){
                        nom.id = null;
                    } 
                    Applicant__c applicant = new Applicant__c();
                    InsParti__c insPartDelete = new InsParti__c();
                    Applicant__c applicantDelete = new Applicant__c();
                    ApplAddr__c appAddDelete = new ApplAddr__c();
                    if(nom.isDelete == true && nom.fromOldList == false && nom.Id != null){
                        if(nom.id != null){
                            insPartDelete.Id = nom.id;                     
                            insPartDeleteMap.put(nom.id,insPartDelete);
                        }
                        
                        if(nom.appId != null){
                            applicantDelete.Id = nom.appId;
                            applicantDeleteMap.put(nom.appId,applicantDelete);
                            
                        }
                        
                        
                    }else{
                        
                        
                        nom.tempId = 'nomTemp'+  String.valueOf(tempNo);
                        tempNo = tempNo +1;
                        applicant.TempId__c = nom.tempId  ;
                        applicant.Id = nom.appId;
                        applicant.LoanAppln__c = loanAppId;
                        if(nom.appType !=null){
                            applicant.ApplType__c = nom.appType;
                        }else{
                            applicant.ApplType__c = 'N';
                        }
                        
                        applicant.fName__c = nom.fName;
                        applicant.LName__c = nom.lName;
                        applicant.Title__c = nom.title;
                        applicant.Gender__c = nom.gender;
                        applicant.Relationship__c = nom.relation;
                        applicant.DOB__c = nom.dateOfBirth;
                        
                        // applicantListMap.put(applicant.Id,applicant);
                        applicantList.add(applicant);
                        if(nom.appointee != null){
                            Applicant__c appApplicant = new Applicant__c();
                            
                            System.debug('appointeee present ' + nom.appointee);
                            
                            nom.appointee.tempId = 'nomTemp'+  String.valueOf(tempNo);
                            tempNo = tempNo +1;
                            appApplicant.TempId__c = nom.appointee.tempId ;
                            appApplicant.Id = nom.appointee.appId;
                            appApplicant.LoanAppln__c = loanAppId;
                            appApplicant.ApplType__c = 'A';
                            appApplicant.fName__c = nom.appointee.fName;
                            appApplicant.LName__c = nom.appointee.lName;
                            appApplicant.Title__c = nom.appointee.title;
                            appApplicant.Gender__c = nom.appointee.gender;
                            appApplicant.Relationship__c = nom.appointee.relation;
                            appApplicant.DOB__c = nom.appointee.dateOfBirth;
                            //applicantListMap.put(applicant.Id,applicant);
                            applicantList.add(appApplicant);
                        }    
                    }
                    
                }
                upsert applicantList;
                // for (Applicant__c appl : applicantList) {
                //     applicantListMap.put(appl.Id,appl);
                // }
                // if(!applicantListMap.isEmpty()){
                //     System.debug('appAddListMap before'+ applicantListMap);
                //     upsert  applicantListMap.values();                    
                //     System.debug('appAddListMap after'+ applicantListMap);
                // }
                System.debug('applicantList'+ applicantList);
                Map<string, string> appIdMap = new Map<string, string>();
                for (Integer i = 0; i < applicantList.size() ; i++) {
                    appIdMap.put(applicantList[i].TempId__c,applicantList[i].Id); 
                }
                System.debug('appIdMap '+ appIdMap);
                for (Nominee nom : nomListNew) {
                    InsParti__c insPart = new InsParti__c();
                    
                    ApplAddr__c appAdd = new ApplAddr__c();
                    if(nom.isDelete == true && nom.fromOldList == false && nom.Id != null){
                        System.debug('no operation ');              
                    }else{
                        appAdd.Applicant__c = appIdMap.get(nom.tempId);
                        appAdd.LoanAppl__c = loanAppId;
                        appAdd.HouseNo__c = nom.hNo;
                        appAdd.Pincode__c = nom.pincode;
                        appAdd.AddrLine1__c = nom.street;
                        appAdd.AddrLine2__c = nom.area;
                        
                        appAdd.City__c = nom.city;
                        appAdd.CityId__c = nom.cityId;
                        appAdd.State__c = nom.state;
                        appAdd.StateId__c = nom.stateId;
                        appAdd.Pincode__c = nom.pincode;
                        appAdd.PinId__c = nom.pincodeId;
                        
                        appAdd.Id = nom.addId;
                        appAdd.AddrTyp__c = 'Residence Address';
                        if(nom.nomAddType !=null){
                            appAdd.AddrTyp__c = nom.nomAddType;
                        }
                        
                        
                        appAddList.add(appAdd);
                        //appAddListMap.put(appAdd.Id,appAdd);
                        
                        insPart.LoanAppln__c = loanAppId;
                        insPart.Appl__c =appIdMap.get(nom.tempId);
                        insPart.Insurance__c = nom.insId;
                        insPart.Parti__c = nom.insPartType; // 'Nominee';
                        insPart.isActive__c = true;
                        if(nom.percent ==''){
                            insPart.NomPercent__c = 0;
                        }else{
                            insPart.NomPercent__c =Integer.valueOf( nom.percent);
                        }
                        
                        insPart.Id = nom.id;
                       
                        if(nom.appointee != null && nom.id == null ){
                            upsert insPart;
                        }
                        insPartList.add(insPart);
                        if(nom.appointee != null){

                           
                            InsParti__c appInsPart = new InsParti__c();
                            
                            ApplAddr__c appAppAdd = new ApplAddr__c();
                            
                            appAppAdd.Applicant__c = appIdMap.get(nom.appointee.tempId);
                            appAppAdd.LoanAppl__c = loanAppId;
                            appAppAdd.HouseNo__c = nom.appointee.hNo;
                            appAppAdd.Pincode__c = nom.appointee.pincode;
                            appAppAdd.AddrLine1__c = nom.appointee.street;
                            appAppAdd.AddrLine2__c = nom.appointee.area;
                            
                            appAppAdd.City__c =  nom.appointee.city;
                            appAppAdd.CityId__c =  nom.appointee.cityId;
                            appAppAdd.State__c =  nom.appointee.state;
                            appAppAdd.StateId__c =  nom.appointee.stateId;
                            appAppAdd.Pincode__c =  nom.appointee.pincode;
                            appAppAdd.PinId__c =  nom.appointee.pincodeId;
                            
                            appAppAdd.Id = nom.appointee.addId;
                            appAppAdd.AddrTyp__c = 'Residence Address';
                            appAddList.add(appAppAdd);
                            // appAddListMap.put(appAppAdd.Id,appAppAdd);
                            
                            appInsPart.LoanAppln__c = loanAppId;
                            appInsPart.Appl__c =appIdMap.get(nom.appointee.tempId);
                            appInsPart.Insurance__c = nom.appointee.insId;
                            appInsPart.Parti__c = nom.appointee.insPartType; // 'Nominee';
                            appInsPart.isActive__c = true;
                            // if(nom.appointee.percent ==''){
                            //     insPart.NomPercent__c = 0;
                            // }else{
                            //     insPart.NomPercent__c =Integer.valueOf(nom.appointee.percent);
                            // }
                            
                            appInsPart.Id = nom.appointee.id;

                            System.debug('nominee id  in appointee' + nom.id);
                            if(insPart.Id != null ){
                                appInsPart.appointeeFor__c = insPart.Id;
                            }
                           
                           // appInsPart.appointeeFor__c = nom.appointee.appointeeFor;
                            insPartList.add(appInsPart);
                            
                        }  
                    }
                    
                }
                
                if(insPartList.size()>0){    
                    System.debug('insPartList before'+ insPartList);              
                    upsert insPartList;
                    System.debug('insPartList after'+ insPartList);
                }
                if(appAddList.size()>0){ 
                    System.debug('appAddList before'+ appAddList);                     
                    upsert appAddList;
                    System.debug('appAddList after'+ appAddList);
                }
                // if(!appAddListMap.isEmpty()){
                //     System.debug('appAddListMap before'+ appAddListMap);
                //     upsert  appAddListMap.values();                   
                //     System.debug('appAddListMap after'+ appAddListMap);
                // }
                
                if(!applicantDeleteMap.isEmpty()){
                    System.debug('applicantDeleteMap before'+ applicantDeleteMap);
                    delete  applicantDeleteMap.values();                   
                    System.debug('applicantDeleteMap after'+ applicantDeleteMap);
                }
                
                if(!insPartDeleteMap.isEmpty()){
                    System.debug('insPartDeleteMap before'+ insPartDeleteMap);
                    delete  insPartDeleteMap.values();                    
                    System.debug('insPartDeleteMap after'+ insPartDeleteMap);
                }
                
                //    for (Applicant__c app : applicantList) {
                
                //     for (ApplAddr__c appAdd : appAddList) {
                
                //     }
                //     for (Nominee nom : nomineeList) {
                //          //Id, LoanAppln__c, Appl__c, Insurance__c, Parti__c, appointeeFor__c, isActive__c    // for insPart  
                //          InsParti__c insPart = new InsParti__c();
                //          insPart.LoanAppln__c = loanAppId;
                //         insPart.Appl__c = app.Id;
                //         insPart.Insurance__c = nom.insId;
                //         insPart.Parti__c = 'Nominee';
                //         insPart.isActive__c = true;
                
                //          if(nom.appId == app.Id){
                //         insPart.Id = nom.Id;
                
                //        }else{
                //         insPart.Id = null;
                
                //        }
                //        insPartList.add(insPart);
                
                //    }
                // }
                
                
            }
            if(nomListOld.size()>0){
                
                List<InsParti__c> insPartListOld = new List<InsParti__c>();
                Map<id, InsParti__c> insPartDeleteMapOld = new Map<id, InsParti__c>();
                for (Nominee nomOld : nomListOld) {
                    if(nomOld.isDelete == true && nomOld.fromOldList == true && nomOld.Id != null){
                        InsParti__c insPartOld = new InsParti__c();
                        if(nomOld.id != null){
                            insPartOld.Id = nomOld.id;                     
                            insPartDeleteMapOld.put(nomOld.id,insPartOld);
                        }
                        
                    }else{
                        InsParti__c insPartOld = new InsParti__c();
                        insPartOld.LoanAppln__c = loanAppId;
                        insPartOld.Appl__c = nomOld.appId;
                        insPartOld.Insurance__c = nomOld.insId;
                        insPartOld.Parti__c =  'Nominee';
                        insPartOld.isActive__c = true;
                        insPartOld.Id = nomOld.Id;
                        // if(nomOld.Id != null @ nomOld.Id.length()<18){
                        
                        // }
                        
                        if(nomOld.percent ==''){
                            insPartOld.NomPercent__c = 0;
                        }else{
                            insPartOld.NomPercent__c =Integer.valueOf( nomOld.percent);
                        }
                        
                        // insPartOld.Id = nomOld.id;
                        insPartListOld.add(insPartOld);
                    }
                    
                }
                if(!insPartDeleteMapOld.isEmpty()){
                    System.debug('insPartDeleteMapOld before'+ insPartDeleteMapOld);
                    delete  insPartDeleteMapOld.values();                    
                    System.debug('insPartDeleteMapOld after'+ insPartDeleteMapOld);
                }
                upsert insPartListOld;
            }
            return nomListNew;
        }
        
        catch (Exception e) {
            System.debug('error message' + e.getMessage()+'  line no ::'+ e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
            
        }
    }
    @AuraEnabled
    public static string createDocDetail(String applicantId, String loanAppId, string docCategory, string docType,string docSubType,Boolean availableInFile,String appKycId){
        
        try {
            return    DocumentDetailController.createDocDetail( applicantId,  loanAppId,  docCategory,  docType, docSubType, availableInFile, appKycId);
        } catch (Exception e) {
            System.debug('error message' + e.getMessage()+'  line no ::'+ e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
            
        }
    }
    public class Insurance {
        // @AuraEnabled
        // public string insId { get; set; }
        // @AuraEnabled
        // public string type { get; set; }
        // @AuraEnabled
        // public boolean isActive { get; set; }
        
        // @AuraEnabled
        // public string policyHolderNm { get; set; }
        // @AuraEnabled
        // public string partner { get; set; }
        // @AuraEnabled
        // public string masPolicyNo { get; set; }
        
        // @AuraEnabled
        // public decimal amount { get; set; }
        // @AuraEnabled
        // public string sunInsType { get; set; }
        // @AuraEnabled
        // public decimal tenure { get; set; }
        // @AuraEnabled
        // public string premAmount { get; set; }
        // @AuraEnabled
        // public string insType { get; set; }
        @AuraEnabled
        public Insurance__c  insurance { get; set; }
        @AuraEnabled
        public list<Nominee> nomineeList { get; set; }
    }
    public class NomineeFromAppList {
        @AuraEnabled
        public string id { get; set; }
        @AuraEnabled
        public InsParti__c insParticep { get; set; }
        
        @AuraEnabled
        public string title { get; set; }
    }
    
    public class Nominee {
        @AuraEnabled
        public string id { get; set; }
        @AuraEnabled
        public string appId { get; set; }
        @AuraEnabled
        public string addId { get; set; } 
        @AuraEnabled
        public string appType { get; set; }  
        @AuraEnabled
        public string appTypeLabel { get; set; }    
        @AuraEnabled
        public string insId { get; set; }
        @AuraEnabled
        public string tabName { get; set; }
        @AuraEnabled
        public boolean fromOldList { get; set; }
        @AuraEnabled
        public string title { get; set; }
        @AuraEnabled
        public string fName { get; set; }
        @AuraEnabled
        public string lName { get; set; }
        @AuraEnabled
        public string gender { get; set; }
        @AuraEnabled
        public date dateOfBirth { get; set; }
        @AuraEnabled
        public string relation { get; set; } 
        @AuraEnabled
        public string hNo { get; set; }
        @AuraEnabled
        public string street { get; set; }
        @AuraEnabled
        public string area { get; set; }
        @AuraEnabled
        public string city { get; set; }
        @AuraEnabled
        public string nomAddType { get; set; }
        @AuraEnabled
        public string pincode { get; set; }
        @AuraEnabled
        public string pincodeId { get; set; }
        @AuraEnabled
        public string cityId { get; set; }
        @AuraEnabled
        public string stateId { get; set; }
        @AuraEnabled
        public string state { get; set; }
        @AuraEnabled
        public string percent { get; set; }
        @AuraEnabled
        public Appointee appointee { get; set; }
        @AuraEnabled
        public string tempId { get; set; }
        @AuraEnabled
        public string insPartType { get; set; }
        @AuraEnabled
        public string selectCheckbox { get; set; }
        @AuraEnabled
        public boolean isDelete { get; set; }
        @AuraEnabled
        public boolean readOnly { get; set; }
        
        
    }
    public class Appointee {
        @AuraEnabled
        public string id { get; set; }
        @AuraEnabled
        public string tempId { get; set; }
        @AuraEnabled
        public string addId { get; set; }
        @AuraEnabled
        public string appId { get; set; }
        @AuraEnabled
        public string insId { get; set; }
        @AuraEnabled
        public string insPartType { get; set; }
        
        @AuraEnabled
        public string appointeeFor { get; set; }
        @AuraEnabled
        public string title { get; set; }
        @AuraEnabled
        public string fName { get; set; }
        @AuraEnabled
        public string lName { get; set; }
        @AuraEnabled
        public string gender { get; set; }
        @AuraEnabled
        public date dateOfBirth { get; set; }
        @AuraEnabled
        public string relation { get; set; } 
        @AuraEnabled
        public string hNo { get; set; }
        @AuraEnabled
        public string street { get; set; }
        @AuraEnabled
        public string area { get; set; }
        @AuraEnabled
        public string city { get; set; }
        @AuraEnabled
        public string appoAddType { get; set; }
        
        @AuraEnabled
        public string pincode { get; set; }
        
        @AuraEnabled
        public string state { get; set; }
        @AuraEnabled
        public string pincodeId { get; set; }
        @AuraEnabled
        public string cityId { get; set; }
        @AuraEnabled
        public string stateId { get; set; }
        @AuraEnabled
        public string percent { get; set; }
        
    }
    public class ModefyNomineeList {
        @AuraEnabled
        public string forInsType { get; set; }
        @AuraEnabled
        public string insId { get; set; }
        @AuraEnabled
        public string id { get; set; }
        @AuraEnabled
        public boolean addStatus { get; set; }
    }
    
    
    
    
}