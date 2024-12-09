@isTest
public class insuranceControllerTest {
    @isTest
     static void insuranceHandler(){
         
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        
        Applicant__c Applicant=TestDataFactory.createSingleApplicant(true,loan.id);
         Applicant.ApplType__c = 'P';
        ApplAddr__c AppAddress =TestDataFactory.applAddPermanent(true,loan.id,Applicant.id);
		Insurance__c Insurance = TestDataFactory.InsuranceData(true,loan.id,Applicant.id);
         
         
         List<Applicant__c> AppList = new List<Applicant__c>();
         AppList.add(Applicant);
         
         ApplAddr__c appAddList = new ApplAddr__c();
         	 appAddList.Applicant__c = Applicant.id; 
             appAddList.AddrLine1__c = 'DNO 34/A'; 
             appAddList.AddrLine2__c = 'WARD NO 34#'; 
             appAddList.City__c = 'BANG'; 
             appAddList.Pincode__c = '454656'; 
             appAddList.State__c = 'KAR';  
             appAddList.LoanAppl__c = loan.id; 
             appAddList.HouseNo__c = 'NO 45';
             
             insert appAddList;
         
         InsParti__c inspar = new InsParti__c();
         inspar.Insurance__c = Insurance.id;
             inspar.Parti__c = 'Appointee';
             inspar.appointeeFor__c = inspar.id;
             inspar.NomPercent__c = 70;
             inspar.LoanAppln__c = loan.id;
         	
             insert inspar;
         
         insuranceController.Appointee appoin = new insuranceController.Appointee();
         						appoin.id = inspar.id;
         						appoin.addId = Applicant.id;
         						appoin.tempId = 'nomTemp'+ 1;
                                appoin.appId = Applicant.id;
                                appoin.insId = Insurance.id;
                                appoin.insPartType = inspar.Parti__c;
         
         insuranceController.Nominee nominee = new insuranceController.Nominee();
                                nominee.Id = inspar.Id;
                                nominee.isDelete = true;
                                nominee.percent = String.valueOf(inspar.NomPercent__c);
                                nominee.insId = Insurance.Id;
         						nominee.fromOldList = false;
         						nominee.percent = '';
         						nominee.appointee = appoin;
         						nominee.appId = Applicant.id;
         
         insuranceController.ModefyNomineeList mdfNomWrp = new insuranceController.ModefyNomineeList();
         mdfNomWrp.addStatus=true;
             mdfNomWrp.forInsType='';
             mdfNomWrp.id=Applicant.id;
             mdfNomWrp.insId=inspar.id;
         
         insuranceController.NomineeFromAppList NomiFromAppList = new insuranceController.NomineeFromAppList();
         						NomiFromAppList.id = inspar.id;
                                NomiFromAppList.insParticep = inspar;
                                NomiFromAppList.title = 'Test';
          list<insuranceController.ModefyNomineeList> mdfNomList = new list<insuranceController.ModefyNomineeList>();
         list<insuranceController.Nominee> NomList = new list<insuranceController.Nominee>();
         NomList.add(nominee);
         mdfNomList.add(mdfNomWrp);
         
        insuranceController.getInsuranceDet(Applicant.id,loan.Id);      
         insuranceController.addNomineeList(mdfNomList,Applicant.id,loan.Id);
        insuranceController.getAvailabeApplicants(loan.Id);
         insuranceController.saveNomineeDet(NomList,loan.Id);
         try{insuranceController.createDocDetail(Applicant.id,loan.Id,'PAN Documents','PAN','PAN',true,null);}catch(Exception e){}
        
         
    }
     @isTest
     static void insuranceHandler1(){
         
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        
        Applicant__c Applicant=TestDataFactory.createSingleApplicant(true,loan.id);
         Applicant.ApplType__c = 'N';
        ApplAddr__c AppAddress =TestDataFactory.applAddPermanent(true,loan.id,Applicant.id);
         AppAddress.AddrTyp__c = 'Residence Cum office';
         update AppAddress;
		Insurance__c Insurance = TestDataFactory.InsuranceData(true,loan.id,Applicant.id);
         
         
         List<Applicant__c> AppList = new List<Applicant__c>();
         AppList.add(Applicant);
         
         InsParti__c inspar = new InsParti__c();
         inspar.Insurance__c = Insurance.id;
             inspar.Parti__c = 'Nominee';
             inspar.appointeeFor__c = inspar.id;
             inspar.NomPercent__c = 70;
             inspar.LoanAppln__c = loan.id;
         inspar.Appl__c = Applicant.id;
         	
             insert inspar;
         
         insuranceController.Appointee appoin = new insuranceController.Appointee();
         						appoin.id = inspar.id;
         						appoin.percent = '0';
         
         insuranceController.Nominee nominee = new insuranceController.Nominee();
                                nominee.Id = inspar.Id;
                                nominee.isDelete = false;
                                nominee.percent = String.valueOf(inspar.NomPercent__c);
                                nominee.insId = Insurance.Id;
         						nominee.fromOldList = true;
         						nominee.isDelete = false;
         						nominee.percent = '';
         						nominee.appointee = appoin;
         						nominee.appType = Applicant.ApplType__c;
         						nominee.percent = '0';
         
         insuranceController.ModefyNomineeList mdfNomWrp = new insuranceController.ModefyNomineeList();
         mdfNomWrp.addStatus=true;
             mdfNomWrp.forInsType='';
             mdfNomWrp.id=Applicant.id;
             mdfNomWrp.insId=inspar.id;
         
         insuranceController.NomineeFromAppList NomiFromAppList = new insuranceController.NomineeFromAppList();
         						NomiFromAppList.id = inspar.id;
                                NomiFromAppList.insParticep = inspar;
                                NomiFromAppList.title = 'Test';
          list<insuranceController.ModefyNomineeList> mdfNomList = new list<insuranceController.ModefyNomineeList>();
         list<insuranceController.Nominee> NomList = new list<insuranceController.Nominee>();
         NomList.add(nominee);
         mdfNomList.add(mdfNomWrp);
         
        insuranceController.getInsuranceDet(Applicant.id,loan.Id);      
         insuranceController.addNomineeList(mdfNomList,Applicant.id,loan.Id);
        insuranceController.getAvailabeApplicants(loan.Id);
         insuranceController.saveNomineeDet(NomList,loan.Id);
         insuranceController.createDocDetail(Applicant.id,loan.Id,'PAN Documents','PAN','PAN',true,null);
        
    }
    
      @isTest
     static void insuranceHandler2(){
         
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        
         Applicant__c Applicant = new Applicant__c();
         Applicant.ApplType__c = 'A';
         Applicant.LoanAppln__c = loan.id;
         insert Applicant;
         
        ApplAddr__c AppAddress =TestDataFactory.applAddPermanent(true,loan.id,Applicant.id);
         AppAddress.AddrTyp__c = 'Principal place for business';
         update AppAddress;
		Insurance__c Insurance = TestDataFactory.InsuranceData(true,loan.id,Applicant.id);
         InsParti__c inspar = new InsParti__c();
         inspar.Insurance__c = Insurance.id;
             inspar.Parti__c = 'Appointee';
             inspar.appointeeFor__c = inspar.id;
             inspar.NomPercent__c = 70;
             inspar.LoanAppln__c = loan.id;
         inspar.Appl__c = Applicant.id;
         	
             insert inspar;
         
         insuranceController.Appointee appoin = new insuranceController.Appointee();
         	 appoin.id = inspar.id;
             appoin.tempId = 'nomTemp0';
             //appoin.addId = appAddList.id;
             appoin.appId = inspar.Appl__c;
             appoin.insId = Insurance.id;
             appoin.insPartType = inspar.Parti__c;
             appoin.appointeeFor = inspar.appointeeFor__c;
             appoin.title = Applicant.Title__c;
             appoin.fName = Applicant.FName__c;
             appoin.lName = Applicant.LName__c;
             appoin.gender = Applicant.Gender__c;
             appoin.dateOfBirth = Applicant.DOB__c;
             appoin.relation = Applicant.Relationship__c;
         
         insuranceController.Nominee nominee = new insuranceController.Nominee();
                                nominee.Id = inspar.id;
                                nominee.isDelete = false;
         						nominee.fromOldList = false;
                                nominee.percent = String.valueOf(inspar.NomPercent__c);
                                nominee.insId = Insurance.Id;
         						nominee.percent = '';
         						nominee.appointee = appoin;
         						nominee.appType = Applicant.ApplType__c;
         						nominee.readOnly = true;
         						nominee.tabName = 'TestTab';
                                nominee.selectCheckbox = 'Yes';
         
         
         List<Applicant__c> AppList = new List<Applicant__c>();
         AppList.add(Applicant);
         
         insuranceController.ModefyNomineeList mdfNomWrp = new insuranceController.ModefyNomineeList();
         mdfNomWrp.addStatus=true;
             mdfNomWrp.forInsType='';
             mdfNomWrp.id=Applicant.id;
             mdfNomWrp.insId=inspar.id;
         
         insuranceController.NomineeFromAppList NomiFromAppList = new insuranceController.NomineeFromAppList();
         						NomiFromAppList.id = inspar.id;
                                NomiFromAppList.insParticep = inspar;
                                NomiFromAppList.title = 'Test';
          list<insuranceController.ModefyNomineeList> mdfNomList = new list<insuranceController.ModefyNomineeList>();
         list<insuranceController.Nominee> NomList = new list<insuranceController.Nominee>();
         NomList.add(nominee);
         mdfNomList.add(mdfNomWrp);
         
        insuranceController.getInsuranceDet(Applicant.id,loan.Id);      
         insuranceController.addNomineeList(mdfNomList,Applicant.id,loan.Id);
        insuranceController.getAvailabeApplicants(loan.Id);
         try{insuranceController.saveNomineeDet(NomList,loan.Id);}catch(exception e){}
         insuranceController.createDocDetail(Applicant.id,loan.Id,'PAN Documents','PAN','PAN',true,null);
        
    }   
}