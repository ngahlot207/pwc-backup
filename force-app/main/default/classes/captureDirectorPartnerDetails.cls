public class captureDirectorPartnerDetails {
    
    @AuraEnabled
    public static void insertLoanApplicantData(List<Sobject> jsonData) {
        System.debug('JSON Data:'+jsonData);
        // Deserialize JSON string into a list of maps
        List<LoanApplRelationship__c> loanApplicantsToUpsert = new List<LoanApplRelationship__c>();
        List<Applicant__c> relatedPersonsToUpsert = new List<Applicant__c>();
        
        // Extract and process the records
        for (SObject sObj : jsonData) {
            if (sObj instanceof LoanApplRelationship__c) {
                LoanApplRelationship__c loanApplicant = (LoanApplRelationship__c) sObj;
                loanApplicantsToUpsert.add(loanApplicant);
            } else if (sObj instanceof Applicant__c) {
                Applicant__c relatedPerson = (Applicant__c) sObj;
                relatedPersonsToUpsert.add(relatedPerson);
            }
        }
        
        // Upsert Related Person records
        if (!relatedPersonsToUpsert.isEmpty()) {
            upsert relatedPersonsToUpsert;
        }
        
        // Upsert Loan Applicant records
        if (!loanApplicantsToUpsert.isEmpty()) {
            upsert loanApplicantsToUpsert;
        }
    }
    
    @AuraEnabled
    public static void insertApplicantrelationData(String jsonData) {
        
        if(String.isNotblank(jsonData)){
            
            try{
                
                List<insertDirectorData> response =(List<insertDirectorData>) JSON.deserialize(jsonData,List<insertDirectorData>.class);
                List<insertDirectorData> dataInsert = new List<insertDirectorData>();
                if(response!=null){
                    
                    List<Applicant__c> applicantList =new List<Applicant__c>();
                    List<LoanApplRelationship__c>  updateList =new List<LoanApplRelationship__c>();
                    List<Applicant__c>  updateApplList =new List<Applicant__c>();
                    for(insertDirectorData dirData:response){
                        
                        //Insert Logic
                        if(String.isBlank(dirData.Related_PersonId)){
                            dataInsert.add(dirData);
                            //Applicant  record
                            if(dirData.Related_Person!=null){
                                
                                insertrelatedData realtedData =dirData.Related_Person;
                                
                                Applicant__c app =new Applicant__c();
                                
                                if(string.isNotBlank(realtedData.LoanAppln)){
                                    app.LoanAppln__c=realtedData.LoanAppln;
                                }
                                
                                if(string.isNotBlank(realtedData.Part_of_Loan_Propos)){
                                    app.Part_of_Loan_Propos__c=(realtedData.Part_of_Loan_Propos.toLowerCase()=='yes')?'YES':'NO';
                                }
                                if(string.isNotBlank(realtedData.FName)){
                                    app.FName__c=realtedData.FName;
                                }
                                if(string.isNotBlank(realtedData.PAN)){
                                    app.PAN__c=realtedData.PAN;
                                }
                                if(string.isNotBlank(realtedData.DOB)){
                                    app.DOB__c=IntegrationUtility.getConvertedDate2(realtedData.DOB);
                                }
                                
                                if(string.isNotBlank(realtedData.Gender)){
                                    app.Gender__c=realtedData.Gender;
                                }
                                
                                if(string.isNotBlank(realtedData.Father_Name)){
                                    app.Father_Name__c=realtedData.Father_Name;
                                }
                                
                                if(string.isNotBlank(realtedData.DataSource)){
                                    app.DataSource__c=realtedData.DataSource;
                                }
                                
                                if(string.isNotBlank(realtedData.ApplType)){
                                    app.ApplType__c=realtedData.ApplType;
                                }
                                
                                applicantList.add(app);
                            }
                        }
                        else if(String.isNotBlank(dirData.Related_PersonId)){
                            LoanApplRelationship__c loanApplData = new LoanApplRelationship__c();
                            loanApplData.Id = dirData.Id;
                            loanApplData.Designation__c = dirData.Designation;
                             if (dirData.Designation != Null) {
                                String designation = dirData.Designation.toLowerCase();
                                
                                if (designation.contains('partner')) {
                                    loanApplData.Relationship_Type__c = 'Partner';
                                } else if (designation.contains('director')) {
                                    loanApplData.Relationship_Type__c = 'Director';
                                } else {
                                    loanApplData.Relationship_Type__c = null;
                                }
                            } else {
                                loanApplData.Relationship_Type__c = null;
                            } 
                            //loanApplData.Relationship_Type__c = dirData.Designation != null ? dirData.Designation.substring(0, 1).toUpperCase() + dirData.Designation.substring(1).toLowerCase():null;
                            loanApplData.Din__c = dirData.Din;
                            loanApplData.DinStatus__c = dirData.DinStatus;
                            loanApplData.DateOfAppointment__c = String.isNotBlank(dirData.DateOfAppointment) ? IntegrationUtility.getConvertedDate2(dirData.DateOfAppointment) : NULL;
                            loanApplData.DateOfCessation__c = String.isNotBlank(dirData.DateOfCessation) ? IntegrationUtility.getConvertedDate2(dirData.DateOfAppointment) : NULL;
                            loanApplData.Dsc_Status__c = dirData.Dsc_Status;
                            loanApplData.Related_Person__c = dirData.Related_PersonId;
                            updateList.add(loanApplData);
                            if(dirData.Related_Person != NULL){
                            Applicant__c ApplData = new Applicant__c();
                                insertrelatedData relatData = dirData.Related_Person;
                                ApplData.Id = relatData.Id;
                                ApplData.LoanAppln__c = relatData.LoanAppln;
                                ApplData.Part_of_Loan_Propos__c = relatData.Part_of_Loan_Propos;
                                ApplData.FName__c = relatData.FName;
                                if(string.isNotBlank(relatData.ApplType)){
                                    ApplData.ApplType__c=relatData.ApplType;
                                }
                                ApplData.PAN__c = relatData.PAN;
                                ApplData.DOB__c = String.isNotBlank(relatData.DOB) ? IntegrationUtility.getConvertedDate2(relatData.DOB) : NULL;
                                ApplData.Gender__c = relatData.Gender;
                                ApplData.Father_Name__c = relatData.Father_Name;
                                ApplData.DataSource__c = relatData.DataSource;
                                updateApplList.add(ApplData);
                            }
                            
                        }
                    }
                    if(!updateList.isEmpty()){
                        update updateList;
                    }
                    if(!updateApplList.isEmpty()){
                        update updateApplList;
                    }
                    
                    
                    if(!applicantList.isEmpty()){
                        Insert applicantList;
                        
                        List<LoanApplRelationship__c>  relationShipList =new List<LoanApplRelationship__c>();
                        
                        for(Integer i=0;i<dataInsert.size();i++){
                            
                            insertDirectorData director =dataInsert[i];
                            Applicant__c app =applicantList[i];
                            
                            if(director!=null && app!=null){
                                LoanApplRelationship__c loanAppRel =new LoanApplRelationship__c();
                                
                                loanAppRel.Related_Person__c=app.Id;
                                
                                if(String.isNotblank(director.Loan_Applicant)){
                                    loanAppRel.Loan_Applicant__c=director.Loan_Applicant;
                                }
                                
                                if(String.isNotblank(director.Designation)){
                                    loanAppRel.Designation__c=director.Designation;
                                }

                                if(String.isNotblank(director.Designation)){
                                String designation = director.Designation.toLowerCase();
                                if (designation.contains('partner')) {
                                    loanAppRel.Relationship_Type__c = 'Partner';
                                } else if (designation.contains('director')) {
                                    loanAppRel.Relationship_Type__c = 'Director';
                                } else {
                                    loanAppRel.Relationship_Type__c = null;
                                }
                                }
                                    //loanAppRel.Relationship_Type__c=director.Designation.substring(0, 1).toUpperCase() + director.Designation.substring(1).toLowerCase();
                                
                                
                                if(String.isNotblank(director.Din)){
                                    loanAppRel.Din__c=director.Din;
                                }
                                if(String.isNotblank(director.DinStatus)){
                                    loanAppRel.DinStatus__c=director.DinStatus;
                                }
                                if(String.isNotblank(director.Dsc_Status)){
                                    loanAppRel.Dsc_Status__c=director.Dsc_Status;
                                }
                                if(String.isNotblank(director.DateOfAppointment)){
                                    loanAppRel.DateOfAppointment__c=IntegrationUtility.getConvertedDate2(director.DateOfAppointment);
                                }
                                if(String.isNotblank(director.DateOfCessation)){
                                    loanAppRel.DateOfCessation__c=IntegrationUtility.getConvertedDate2(director.DateOfCessation);
                                }
                                
                                relationShipList.add(loanAppRel);
                             }
                        }
                        
                        if(!relationShipList.isEmpty()){
                            
                            Insert relationShipList;
                        }
                    }
                }
                
            }
            
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'captureDirectorPartnerDetails', 'insertApplicantrelationData', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
            
        }
    }
    
    //public class jsonBody{
    public class insertDirectorData {
        public String Id;   //a2eC40000001mU1IAI
        public String Loan_Applicant;   //a0AC4000000JaqzMAC
        public String Designation;  //Director
        public String Din;  //01691518
        public String DinStatus;    //Approved
        public String Dsc_Status;   //ACTIVE
        public String DateOfAppointment;    //2012-10-31
        public String DateOfCessation;  //2012-10-31
        public String Related_PersonId; //a0AC4000000dfbBMAQ
        public insertrelatedData Related_Person;
        public boolean isAPI;
    }
    public class insertrelatedData {
        public String LoanAppln;    //a08C40000084NJBIA2
       // public String LoanApplicant;
        public String ApplType; 
        public String Part_of_Loan_Propos;  //YES
        public String FName;    //NAVEEN MATHEW PHILIP
        public String PAN;  //AFAPN5763Q
        public String DOB;  //1981-11-27
        public String Gender;   //M
        public String Father_Name;  //VENKAPPA NAIK
        public String DataSource;   //API
        public String Id;   //a0AC4000000dfbBMAQ
    }
    //}
    
}