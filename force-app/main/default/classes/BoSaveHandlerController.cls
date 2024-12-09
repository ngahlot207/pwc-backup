public class BoSaveHandlerController {
    
    @AuraEnabled
    public static void boSaveData(List<BoSaveDataWrapper> inputDataAll){
        if(inputDataAll != null && inputDataAll.size() > 0){
            system.debug('inputDataAll ' + inputDataAll);
            system.debug('inputDataAll size ' + inputDataAll.size());
            try {
                fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(new List<SObjectType> {Applicant__c.SObjectType,LoanApplRelationship__c.SObjectType });
                String loanAppId = inputDataAll[0].loanAppId;
                
                for(BoSaveDataWrapper inputData : inputDataAll){
                    if(inputData.relatedPerId != null && inputData.relatedPerId != '')
                    {
                        //update operation
                        Applicant__c applObjNew = new Applicant__c();
                        applObjNew.Id =  inputData.relatedPerId;
                        //applObj.Related_Person__c =  inputData.relatedPerId;
                        applObjNew.FName__c = inputData.FName;
                        applObjNew.LName__c = inputData.LName;
                        applObjNew.ApplType__c = inputData.ApplType;
                        applObjNew.Constitution__c = inputData.Constitution;
                        applObjNew.Relationship__c = inputData.Relationship;         
                        uow1.registerDirty(applObjNew);
                        
                        if(inputData.relId != null && inputData.relId != '')
                        {
                            //Update relationship
                            LoanApplRelationship__c appRelObj = new LoanApplRelationship__c();
                            
                            appRelObj.Id=inputData.relId;
                            appRelObj.BeneficialOwner__c = inputData.isBo;
                            appRelObj.Loan_Applicant__c = inputData.Id;
                            appRelObj.Shareholding__c = inputData.Shareholding;
                            appRelObj.Partofpraposalloan__c = inputData.PartofProposedLoan;
                            appRelObj.Relationship_Type__c = inputData.relationshipType;
                            
                            uow1.registerRelationship(appRelObj, LoanApplRelationship__c.Related_Person__c, applObjNew);   
                            uow1.registerDirty(appRelObj);
                        }else{
                            //create relationship
                            LoanApplRelationship__c appRelObj = new LoanApplRelationship__c();
                            appRelObj.BeneficialOwner__c = inputData.isBo;
                            appRelObj.Loan_Applicant__c = inputData.Id;
                            appRelObj.Shareholding__c = inputData.Shareholding;
                            appRelObj.Partofpraposalloan__c = inputData.PartofProposedLoan;
                            appRelObj.Relationship_Type__c = inputData.relationshipType;
                            
                            uow1.registerRelationship(appRelObj, LoanApplRelationship__c.Related_Person__c, applObjNew);   
                            uow1.registerNew(appRelObj);
                            
                        }
                    }
                    else{
                        //insert operation
                        Applicant__c applObj = new Applicant__c();
                        
                        applObj.LoanAppln__c  = inputData.loanAppId;
                        applObj.FName__c = inputData.FName;
                        applObj.LName__c= inputData.LName;
                        applObj.ApplType__c = inputData.ApplType;
                        applObj.Constitution__c = inputData.Constitution;
                        applobj.Relationship__c = inputData.Relationship;        
                        uow1.registerNew(applObj);
                        
                        LoanApplRelationship__c appRelObj = new LoanApplRelationship__c();
                        appRelObj.BeneficialOwner__c = inputData.isBo;
                        appRelObj.Shareholding__c = inputData.Shareholding;
                        appRelObj.Loan_Applicant__c = inputData.Id;
                        appRelObj.Relationship_Type__c = inputData.relationshipType;
                        appRelObj.Partofpraposalloan__c = inputData.PartofProposedLoan;
                        
                        uow1.registerRelationship(appRelObj, LoanApplRelationship__c.Related_Person__c, applObj);   
                        uow1.registerNew(appRelObj);   
                    }
                }
                system.debug('uow1 ' + uow1);
                uow1.commitWork();
                
                Set<String> appIds = new Set<String> ();
                
                List<LoanApplRelationship__c> appRelationships = [SELECT Id,Related_Person__c FROM LoanApplRelationship__c WHERE Related_Person__r.LoanAppln__c =: loanAppId AND Related_Person__r.ApplType__c IN ('P','C','G','SH') AND BeneficialOwner__c = 'Yes' AND Relationship_Type__c = 'Beneficial Owner'];
                
                if(!appRelationships.isEmpty()){
                    for(LoanApplRelationship__c loanAppRel : appRelationships){
                        if(loanAppRel.Related_Person__c != null){
                            appIds.add(loanAppRel.Related_Person__c);
                        }
                    }
                }
                
                List<Applicant__c> applicants = [SELECT Id,IsBo__c FROM Applicant__c WHERE LoanAppln__c =:loanAppId AND ApplType__c IN ('P','C','G','SH')];
                List<Applicant__c> appToUpdate = new List<Applicant__c> ();
                
                if(!applicants.isEmpty()){
                    for(Applicant__c app : applicants){
                        if(appIds.contains(app.Id)){
                            Applicant__c appNew = new Applicant__c();
                            appNew.Id = app.Id;
                            appNew.IsBo__c = 'Yes';
                            appToUpdate.add(appNew);
                        }
                    }
                }
                if(!appToUpdate.isEmpty()){
                    update appToUpdate;
                }
            } catch (Exception e) {
                throw new AuraHandledException(
                    'Error during boSaveData: ' +  e.getMessage() + ' line ' + e.getLineNumber()
                );
            }
        }
    }
    public class BoSaveDataWrapper {
        @AuraEnabled
        public String Id { get; set; }
        @AuraEnabled
        public String loanAppId { get; set; }
        @AuraEnabled
        public String relatedPerId { get; set; }
        @AuraEnabled
        public String relId { get; set; }
        @AuraEnabled
        public String FName { get; set; }
        @AuraEnabled
        public String LName { get; set; }
        @AuraEnabled
        public String ApplType { get; set; }
        @AuraEnabled
        public String Constitution { get; set; }
        @AuraEnabled
        public String Relationship { get; set; }
        @AuraEnabled
        public String  isBo{ get; set; }
        @AuraEnabled
        public Decimal  Shareholding{ get; set; }
        @AuraEnabled
        public String  PartofProposedLoan{ get; set; }
        @AuraEnabled
        public String  relationshipType{ get; set; }
    }
}