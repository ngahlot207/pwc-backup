public class EligibilityScreenDataController {
    
    @AuraEnabled
    public static ResponseWrapper fetchRecords(String params) {
        String incomeProgramAppl ='Cash Flow - Assessed income,Business income - Regular Income Program (P&L),Gross Eligible Salary with Bank Credit,Net Eligible Salary with Bank Credit,Cash Salary,Net Salary,Rental bank credit,Rental without bank credit,Pension Income,Other Income,Agriculture Income,Gross Salary';
        
        //BRE  Eligibility And Applicant Obj data
        List<BRE_Eligibility__c> breList = new List<BRE_Eligibility__c>();
        breList = [SELECT Id, Name, BREResponse__c, Type__c, IncomeProgram__c,Consideration__c,BREResponse__r.Applicant__r.FullName__c,BREResponse__r.Applicant__c,BREResponse__r.Applicant__r.CreatedDate,BREResponse__r.Applicant__r.AssessmentProgram__c, BREResponse__r.LoanAppl__c, BREValue__c, BREValueType__c, IsLatest__c,BREResponse__r.Applicant__r.Type_of_Borrower__c FROM BRE_Eligibility__c WHERE IsLatest__c=true AND BREResponse__r.LoanAppl__c=:params
                  AND BREResponse__r.Applicant__r.Type_of_Borrower__c !='Non Financial'];
        Map<Id,ApplicantEligibility> applicantEliMap = new Map<Id,ApplicantEligibility>();
        ApplicantEligibility wrapObj = new ApplicantEligibility();
        
        ResponseWrapper resp = new ResponseWrapper();
        resp.application = new ApplicantEligibility();
       
        for (BRE_Eligibility__c record : breList) {
          //  wrapObj.applicantRecord = record.BREResponse__r.Applicant__r.FullName__c;
         //  wrapObj.ApplicantId = record.BREResponse__r.Applicant__c;
            
            if(record.Type__c =='Applicant' && record.BREResponse__r.Applicant__c != null){
                
                wrapObj = (applicantEliMap.containsKey(record.BREResponse__r.Applicant__c)) ? applicantEliMap.get(record.BREResponse__r.Applicant__c): new ApplicantEligibility();
                wrapObj.applicantCreatedDate = (record.BREResponse__r.Applicant__r.CreatedDate != null)? record.BREResponse__r.Applicant__r.CreatedDate: NULL;
                wrapObj.assesmentProgram =(record.BREResponse__r.Applicant__r.AssessmentProgram__c != null)? record.BREResponse__r.Applicant__r.AssessmentProgram__c: 'Not Available';
                resp.showAssesmentProgram =(record.BREResponse__r.Applicant__r.AssessmentProgram__c != null);
                
                
                /*if(record.IncomeProgram__c == 'Cash Flow - Assessed income'){
                    resp.showcashFlowAssessedIncome = true;
                    wrapObj.cashFlowAssedIncome = record.BREValue__c;
                }*/
                if(record.IncomeProgram__c == 'Business income - Regular Income Program (P&L)'){
                    resp.showBusinessIncome = true;
                    wrapObj.businessIncome = record.BREValue__c;
                }if(record.IncomeProgram__c == 'Gross Eligible Salary with Bank Credit'){
                    resp.showGrossWithBankCredit = true;
                    wrapObj.grossSalaryBankCredit = record.BREValue__c;
                }if(record.IncomeProgram__c == 'Net Eligible Salary with Bank Credit'){
                    resp.showNetWithBankCredit = true;
                    wrapObj.netSalaryBankCredit = record.BREValue__c;
                    
                }
                applicantEliMap.put(record.BREResponse__r.Applicant__c,wrapObj);
                system.debug('bre applicant list>>>>'+applicantEliMap);
            }
            
           if(record.Type__c =='Application' && record.BREResponse__r.LoanAppl__c != null ){
                
                
                if(record.IncomeProgram__c == 'Cash Flow - Assessed income'){
                  //  resp.showcashFlowAssessedIncome = true;
                    resp.application.cashFlowAssedIncome =record.Consideration__c;
                }
                else if(record.IncomeProgram__c == 'Business income - Regular Income Program (P&L)'){
                  //  resp.showBusinessIncome = true;
                    resp.application.businessIncome = record.Consideration__c;
                }else if(record.IncomeProgram__c == 'Gross Eligible Salary with Bank Credit'){
                   // resp.showGrossWithBankCredit = true;
                    resp.application.grossSalaryBankCredit = record.Consideration__c;
                }else if(record.IncomeProgram__c == 'Net Eligible Salary with Bank Credit'){
                   // resp.showNetWithBankCredit = true;
                    resp.application.netSalaryBankCredit = record.Consideration__c;
                }
                else if(record.IncomeProgram__c == 'Cash Salary'){
                  //  resp.showCashSalary = true;
                    resp.application.cashSalary = record.Consideration__c;
                }else if(record.IncomeProgram__c == 'Rental bank credit'){
                   // resp.showRentalWBankCredit = true;
                    resp.application.rentalBankCredit = record.Consideration__c;
                }else if(record.IncomeProgram__c == 'Rental without bank credit'){
                   // resp.showRentalWNoBankCredit = true;
                    resp.application.rentalWithoutBankCredit = record.Consideration__c;
                }
                else if(record.IncomeProgram__c == 'Pension Income'){
                   // resp.showPensionIncome = true;
                    resp.application.PensionIncome = record.Consideration__c;
                }
                else if(record.IncomeProgram__c == 'Agriculture Income'){
                  //  resp.showAgricultureIncome = true;
                    resp.application.AgricultureIncome = record.Consideration__c;
                }
                else if(record.IncomeProgram__c == 'Other Income'){
                 //   resp.showOtherIncome = true;
                    resp.application.OtherIncome = record.Consideration__c;
                }
               // applicantEliMap.put(record.BREResponse__r.Applicant__c,wrapObj);
               system.debug('bre eligibility >>>'+applicantEliMap);
            }
        }
      //  system.debug('debug at line 87>>>>'+applicantEliMap.values().size());
        for(Applicant__c appli : [select id,CreatedDate,LoanAppln__c, ApplType__c, FullName__c,Type_of_Borrower__c,Average_Monthly_Rental_No_Bank_Credit__c,
                                  Average_Monthly_Rental_With_Bank_Credit__c,Average_Other_Income__c,AssessmentProgram__c,
                                  AverageMonthlyAgricultureIncome__c,Average_Monthly_Cash_Salary__c,Average_Monthly_Pension__c,
                                  Average_Monthly_Gross_Salary__c, Average_Net_Salary__c, (select NET_CASH_PROFIT_LOSS__c from Applicant_Income__r where RecordType.DeveloperName = 'cashflow_map')
                                  FROM Applicant__c where  ApplType__c IN('P','G','C') AND LoanAppln__c=:params
                                  AND Type_of_Borrower__c !='Non Financial']){ 
                                      
                                      wrapObj =(applicantEliMap.containsKey(appli.Id))?applicantEliMap.get(appli.Id):new ApplicantEligibility();
                                      
                                      
                                      
                                      wrapObj.ApplicantId = appli.Id;          
                                      wrapObj.applicantRecord = appli.FullName__c;
                                      wrapObj.applicantCreatedDate = (appli.CreatedDate != null)? appli.CreatedDate: NULL;
                                      wrapObj.assesmentProgram =(appli.AssessmentProgram__c != null)?appli.AssessmentProgram__c:'';
                                      if(appli.AssessmentProgram__c != null && appli.AssessmentProgram__c != ''){
                                      resp.showAssesmentProgram=(appli.AssessmentProgram__c != null);
                                      }
                                     if(appli.Applicant_Income__r.size() > 0){
                                        wrapObj.cashFlowAssedIncome =(appli.Applicant_Income__r[0].NET_CASH_PROFIT_LOSS__c != null && appli.AssessmentProgram__c=='Assessed Income Program')?appli.Applicant_Income__r[0].NET_CASH_PROFIT_LOSS__c:0;
                                          if (appli.Applicant_Income__r[0].NET_CASH_PROFIT_LOSS__c != null && appli.Applicant_Income__r[0].NET_CASH_PROFIT_LOSS__c != 0) {
                                            resp.showcashFlowAssessedIncome = (appli.Applicant_Income__r[0].NET_CASH_PROFIT_LOSS__c != null && appli.AssessmentProgram__c=='Assessed Income Program');
                                          }
                                      }
                                      wrapObj.cashSalary =(appli.Average_Monthly_Cash_Salary__c != null && appli.AssessmentProgram__c=='Assessed Income Program')?appli.Average_Monthly_Cash_Salary__c:0;
                                      if (appli.Average_Monthly_Cash_Salary__c != null && appli.Average_Monthly_Cash_Salary__c != 0) {
                                      resp.showCashSalary=(appli.Average_Monthly_Cash_Salary__c != null && appli.AssessmentProgram__c=='Assessed Income Program');
                                      }
                                      
                                      wrapObj.rentalBankCredit =(appli.Average_Monthly_Rental_With_Bank_Credit__c != null)?appli.Average_Monthly_Rental_With_Bank_Credit__c:0;
                                      if(appli.Average_Monthly_Rental_With_Bank_Credit__c != null && appli.Average_Monthly_Rental_With_Bank_Credit__c !=0){
                                      resp.showRentalWBankCredit =(appli.Average_Monthly_Rental_With_Bank_Credit__c != null);
                                  }
                                  
                                      wrapObj.rentalWithoutBankCredit =(appli.Average_Monthly_Rental_No_Bank_Credit__c != null)?appli.Average_Monthly_Rental_No_Bank_Credit__c:0;
                                      if(appli.Average_Monthly_Rental_No_Bank_Credit__c != null && appli.Average_Monthly_Rental_No_Bank_Credit__c !=0){
                                        resp.showRentalWNoBankCredit =(appli.Average_Monthly_Rental_No_Bank_Credit__c != null);
                                      }
                                
                                      
                                      
                                      wrapObj.PensionIncome = (appli.Average_Monthly_Pension__c != null) ? appli.Average_Monthly_Pension__c : 0;
                                      if(appli.Average_Monthly_Pension__c != null && appli.Average_Monthly_Pension__c != 0){
                                          resp.showPensionIncome = (appli.Average_Monthly_Pension__c != null);
                                      }
                         
                                      
                                      wrapObj.AgricultureIncome =(appli.AverageMonthlyAgricultureIncome__c != null)? appli.AverageMonthlyAgricultureIncome__c:0;
                                      if(appli.AverageMonthlyAgricultureIncome__c != null &&appli.AverageMonthlyAgricultureIncome__c !=0){
                                      resp.showAgricultureIncome = (appli.AverageMonthlyAgricultureIncome__c != null);
                                      }
                                      wrapObj.OtherIncome =(appli.Average_Other_Income__c != null)?appli.Average_Other_Income__c:0;
                                      if(appli.Average_Other_Income__c != null && appli.Average_Other_Income__c != 0){
                                      resp.showOtherIncome =(appli.Average_Other_Income__c != null);
                                      }
                                      applicantEliMap.put(appli.Id,wrapObj);  
                                      system.debug('applicant query size'+applicantEliMap);
                                  }
        
        //BRE Response Data
      //  system.debug('debug at line 146>>>>'+applicantEliMap.values().size());
        List<BRE__c> breRespList = new List<BRE__c>();
        
        
        breRespList=[SELECT Id,Applicant__r.Type_of_Borrower__c, LoanAppl__c, Applicant__c,AppFOIR__c,AppEMI_NetSal__c,Mnthlyapprincome__c,Max_EMI_Other_than_Cash_Salary__c, EligibilityType__c, AppraisedMonIncome__c, RAACROI__c, Applicable_FOIR__c, Appl_EMI_Net_Salary__c, Applicable_FOIR_Cash_Salary__c, Max_EMI_Cash_Salary__c, Eligible_tenure_in_Months__c, Financial_Loan_Eligibility_other_cash__c, FinLoanEligibCashSalary__c,FinancialLoanEligibilityTotal__c , Application_level_Assessment_program__c,MaxBreLnEliWoIns__c,MaxBreLnEliWIns__c,MaxBreLnEliWDeviation__c,MaxFinLnEligblwithDevi__c,EMI__c,Actual_FOIR__c, Actual_LTV__c, Combined_LTV__c,Combined_LTV_And_FOIR_without_Insurance__c,MaxcoltrlLnEliWDeviation__c,LTVApplWDeviation__c,TotlLTVBsdLnEliWIns__c,AddLTVBsdEliIns__c,LTVBsdEliWOIns__c,LTVApplLnWtInsurance__c,LTVApplLnWOInsurance__c FROM BRE__c where LoanAppl__c=:params AND IsLatest__c=true 
               AND Applicant__r.Type_of_Borrower__c !='Non Financial'];
        system.debug('breRespList>>>>'+breRespList);
        
        for (BRE__c recordBREResp : breRespList) {
            
            if(recordBREResp.EligibilityType__c =='Applicant' && recordBREResp.Applicant__c != null){
                
                wrapObj =(applicantEliMap.containsKey(recordBREResp.Applicant__c))? applicantEliMap.get(recordBREResp.Applicant__c):new ApplicantEligibility();
                
                wrapObj.ApprMonthIncOtherthanCashSalary =(recordBREResp.Mnthlyapprincome__c != null)?recordBREResp.Mnthlyapprincome__c:0;
                system.debug('wrapObj.ApprMonthIncOtherthanCashSalary-->'+wrapObj.ApprMonthIncOtherthanCashSalary);
                
                wrapObj.ApplFOIR =(recordBREResp.AppFOIR__c != null)?recordBREResp.AppFOIR__c:0;
                
                wrapObj.ApplEMINetSalary =  (recordBREResp.AppEMI_NetSal__c != null)?recordBREResp.AppEMI_NetSal__c: 0;              
                
                wrapObj.MaxEMIOtherCashSalary =(recordBREResp.Max_EMI_Other_than_Cash_Salary__c != null)?recordBREResp.Max_EMI_Other_than_Cash_Salary__c:0;
                
                wrapObj.ApplFOIRCashSalary=(recordBREResp.Applicable_FOIR_Cash_Salary__c != null)?recordBREResp.Applicable_FOIR_Cash_Salary__c:0;
                wrapObj.MaxEMICashSalary =(recordBREResp.Max_EMI_Cash_Salary__c != null)?recordBREResp.Max_EMI_Cash_Salary__c:0;
                applicantEliMap.put(recordBREResp.Applicant__c,wrapObj);
                
            }
            if(recordBREResp.EligibilityType__c =='Application' && recordBREResp.LoanAppl__c != null){
                
                //These are some modification for Fields mappings
                 resp.application.MaxEMIOtherCashSalaryAppltn =(recordBREResp.Max_EMI_Other_than_Cash_Salary__c != null)?recordBREResp.Max_EMI_Other_than_Cash_Salary__c:0;
                 resp.application.MaxEMICashSalaryAppltn =(recordBREResp.Max_EMI_Cash_Salary__c != null)?recordBREResp.Max_EMI_Cash_Salary__c:0;
                 resp.application.ApprMonthIncOtherthanCashSalaryAppltn =(recordBREResp.Mnthlyapprincome__c != null)?recordBREResp.Mnthlyapprincome__c:0;
                //
                resp.application.EliTenureMonths =(recordBREResp.Eligible_tenure_in_Months__c != null)? recordBREResp.Eligible_tenure_in_Months__c:0;
                
                resp.application.RAACROI = (recordBREResp.RAACROI__c != null) ? recordBREResp.RAACROI__c:0;
                
                resp.application.LoanEliOtherCashSalary =(recordBREResp.Financial_Loan_Eligibility_other_cash__c != null) ? recordBREResp.Financial_Loan_Eligibility_other_cash__c:0;
                
                resp.application.FinLoanEliCashSalary = (recordBREResp.FinLoanEligibCashSalary__c != null)? recordBREResp.FinLoanEligibCashSalary__c:0;
                
                resp.application.FinLoanEliTotal = (recordBREResp.FinancialLoanEligibilityTotal__c != null)? recordBREResp.FinancialLoanEligibilityTotal__c:0;
                
                resp.application.MaxFinLoanElideviation =(recordBREResp.MaxFinLnEligblwithDevi__c != null)?  recordBREResp.MaxFinLnEligblwithDevi__c:0;
                
                resp.application.ApplLevelAssprogram = (recordBREResp.Application_level_Assessment_program__c != null)? recordBREResp.Application_level_Assessment_program__c:'';
                system.debug('recordBREResp123'+recordBREResp.MaxBreLnEliWoIns__c);
                resp.application.MaxBreLnEliWoIns =(recordBREResp.MaxBreLnEliWoIns__c != null) ?  recordBREResp.MaxBreLnEliWoIns__c:0;
                
                resp.application.MaxBreLnEliWIns =(recordBREResp.MaxBreLnEliWIns__c != null)?  recordBREResp.MaxBreLnEliWIns__c:0;
                resp.application.MaxBreLnEliWDeviation =(recordBREResp.MaxBreLnEliWDeviation__c != null)?  recordBREResp.MaxBreLnEliWDeviation__c:0;
                
                resp.application.EMI =(recordBREResp.EMI__c != null)?  recordBREResp.EMI__c:0;
                resp.application.ActuaFOIR =(recordBREResp.Actual_FOIR__c != null)?  recordBREResp.Actual_FOIR__c:0;
                resp.application.ActualLTV =(recordBREResp.Actual_LTV__c != null)?  recordBREResp.Actual_LTV__c:0;
                resp.application.CombLTVFOIR =(recordBREResp.Combined_LTV_And_FOIR_without_Insurance__c != null)?  recordBREResp.Combined_LTV_And_FOIR_without_Insurance__c:0;
                
                
                //applicantEliMap.put(recordBREResp.Applicant__c,wrapObj);
                
            }
       
        }
        
        system.debug('debug at line 215>>>'+applicantEliMap.values().size());
        
        
        //This is for obligation table
        //Applicant__r.Type_of_Borrower__c!='Non Financial' beacuse of LAK-7554
        list<BureauRespDtl__c> appId=new list<BureauRespDtl__c>();
        set<id> idsofAppln=new set<id> ();
       appId= [SELECT Id,Applicant__c, EMI__c,CloseDate__c FROM BureauRespDtl__c WHERE Treatment__c = 'To continue - Obligate' AND LoanApplication__c=:params AND Applicant__r.Type_of_Borrower__c!='Non Financial' and Applicant__c != null and (CloseDate__c >= LAST_N_DAYS:365 or CloseDate__c=null) ];
        for(BureauRespDtl__c aId :appId){
            idsofAppln.add(aId.id);
        }
        for(AggregateResult aggr : [SELECT Applicant__c, SUM(EMI__c)amt FROM BureauRespDtl__c WHERE Id IN :idsofAppln and  Treatment__c = 'To continue - Obligate' AND LoanApplication__c=:params AND Applicant__r.Type_of_Borrower__c!='Non Financial' and Applicant__c != null GROUP BY Applicant__c ]){
            wrapObj =(applicantEliMap.containsKey((id)aggr.get('Applicant__c')))? applicantEliMap.get((id)aggr.get('Applicant__c')):new ApplicantEligibility();
          // wrapObj = applicantEliMap.get((id)aggr.get('Applicant__c'));
            wrapObj.obligationAMount = (decimal)aggr.get('amt');
            applicantEliMap.put((id)aggr.get('Applicant__c'),wrapObj);
        }
        
        system.debug('debug at line 224>>>>'+applicantEliMap.values().size());
        
        List<ApplicantEligibility> templist  = applicantEliMap.values();
        templist.sort();
        //resp.eligibilityList = applicantEliMap.values();
        resp.eligibilityList = templist;
        system.debug('all data of EligibilityScreenDataController>>>>>'+JSON.serialize(resp));
        return resp;
    }
    
    /*public class ApplicantEligibility{
        
        //These are BRE Eligibility data
        @auraEnabled public String ApplicantId{get;set;}
        @auraEnabled public string applicantRecord{get;set;}
        
        @auraEnabled public decimal obligationAMount{get;set;}
        
        //  @auraEnabled public string breApplicantRecord{get;set;}
        // @auraEnabled public Applicant__c applicantRecord{get;set;}
        @auraEnabled public decimal cashFlowAssedIncome{get;set;}
        @auraEnabled public decimal businessIncome{get;set;}
        @auraEnabled public decimal grossSalaryBankCredit{get;set;}
        @auraEnabled public decimal netSalaryBankCredit{get;set;}
        
        //These are Applicant data
        @auraEnabled public string assesmentProgram{get;set;}
        @auraEnabled public decimal cashSalary{get;set;}
        @auraEnabled public decimal rentalBankCredit{get;set;}
        @auraEnabled public  boolean showRentalWBankCredit{get;set;}
        @auraEnabled public decimal rentalWithoutBankCredit{get;set;}
        @auraEnabled public decimal PensionIncome{get;set;}
        @auraEnabled public decimal AgricultureIncome{get;set;}
        @auraEnabled public decimal OtherIncome{get;set;}
        @auraEnabled Public DateTime applicantCreatedDate{get;set;}
        
        //These Are BRE Respnse data
        
          @auraEnabled public decimal MaxEMIOtherCashSalaryAppltn{get;set;}
         @auraEnabled public decimal MaxEMICashSalaryAppltn{get;set;}
        @auraEnabled public decimal ApprMonthIncOtherthanCashSalaryAppltn{get;set;}
        
        @auraEnabled public decimal RAACROI{get;set;}
        @auraEnabled public decimal ApprMonthIncOtherthanCashSalary{get;set;}
        @auraEnabled public decimal ApplFOIR{get;set;}
        @auraEnabled public decimal ApplEMINetSalary {get;set;}
        @auraEnabled public decimal MaxEMIOtherCashSalary{get;set;}
        @auraEnabled public decimal ApplFOIRCashSalary{get;set;}
        @auraEnabled public decimal MaxEMICashSalary{get;set;}
        @auraEnabled public decimal EliTenureMonths{get;set;}
        @auraEnabled public decimal LoanEliOtherCashSalary{get;set;}
        @auraEnabled public decimal FinLoanEliCashSalary{get;set;}
        @auraEnabled public decimal FinLoanEliTotal{get;set;}
        @auraEnabled public decimal MaxFinLoanElideviation{get;set;}
        @auraEnabled public string ApplLevelAssprogram{get;set;}
        
        @auraEnabled public decimal MaxBreLnEliWoIns{get;set;}
        @auraEnabled public decimal MaxBreLnEliWIns{get;set;}
        @auraEnabled public decimal MaxBreLnEliWDeviation{get;set;}
        
        //Recommandation Table Fields data 
        @auraEnabled public decimal EMI{get;set;}
        @auraEnabled public decimal ActuaFOIR{get;set;}
        @auraEnabled public decimal ActualLTV{get;set;}
        @auraEnabled public decimal CombLTVFOIR{get;set;}
        
        //These Are BRE data for Type Property
        @auraEnabled public decimal LTVApplLnWOInsurance{get;set;}
        @auraEnabled public decimal LTVApplLnWtInsurance{get;set;}
        @auraEnabled public decimal LTVBsdEliWOIns{get;set;}
        @auraEnabled public decimal AddLTVBsdEliIns{get;set;}      
        @auraEnabled public decimal TotlLTVBsdLnEliWIns{get;set;}
        @auraEnabled public decimal LTVApplWDeviation{get;set;}
        @auraEnabled public decimal MaxcoltrlLnEliWDeviation{get;set;}
        //These Are SFDC data for Type Property
        @auraEnabled public string PropAddrs{get;set;} 
        @auraEnabled public string PropType{get;set;}
        @auraEnabled public string PropSubType{get;set;}
        @auraEnabled public string PropertyUsage{get;set;}
        @auraEnabled public decimal ApproxValue{get;set;}
        
        
    }*/
    
    Public class ResponseWrapper{
        @auraEnabled public List<ApplicantEligibility> eligibilityList{get;set;}
        //  @auraEnabled public List<ApplicantBREREsponse> BREResponse {get;set;}
        @auraEnabled public  boolean showAssesmentProgram{get;set;}
        @auraEnabled public  boolean showcashFlowAssessedIncome{get;set;}
        @auraEnabled public  boolean showBusinessIncome{get;set;}
        @auraEnabled public  boolean showGrossWithBankCredit{get;set;}
        @auraEnabled public  boolean showNetWithBankCredit{get;set;}
        
        @auraEnabled public  boolean showCashSalary{get;set;}
        @auraEnabled public  boolean showRentalWBankCredit{get;set;}
        @auraEnabled public  boolean showRentalWNoBankCredit{get;set;}
        @auraEnabled public  boolean showPensionIncome{get;set;}
        @auraEnabled public  boolean showAgricultureIncome{get;set;}
        @auraEnabled public  boolean showOtherIncome{get;set;}
        @auraEnabled public ApplicantEligibility application {get;set;}
        
        @auraEnabled public ApplicantEligibility property {get;set;}
        //@auraEnabled public BRE__c application {get;set;}
        //@auraEnabled public  boolean showRentalIncome{get;set;}
        
    }
    
}