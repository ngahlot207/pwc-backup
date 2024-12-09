public without sharing class RackRateController {
  @AuraEnabled
  public static Decimal retrieveLeadROI(RackRateInputWrpr inputData) {
    Decimal leadROI = 0.00;
    if (inputData != null) {
      String query = 'SELECT Id, RackRate__c FROM MasterData__c WHERE Product__c INCLUDES (\'' + inputData.product + '\') AND Type__c = \'Rack Rate ROI\' AND (';
      TeamHierarchy__c teamHier;
      Lead leadRec;
      String branchTier;
      String customerProf;
      if (
        inputData.customerProfile == 'SALARIED' &&
        inputData.isAssessedIncomePrgrm != null &&
        inputData.isAssessedIncomePrgrm == true
      ) {
        customerProf = 'Salaried Assessed Income';
      } else if (
        inputData.customerProfile == 'SALARIED' &&
        inputData.isAssessedIncomePrgrm != null &&
        inputData.isAssessedIncomePrgrm == false
      ) {
        customerProf = 'Salaried Regular Income';
      } else if (
        (inputData.customerProfile == 'SELF EMPLOYED NON PROFESSIONAL' ||
        inputData.customerProfile == 'SELF EMPLOYED PROFESSIONAL') &&
        inputData.isAssessedIncomePrgrm != null &&
        inputData.isAssessedIncomePrgrm == true
      ) {
        customerProf = 'Self Employed Assessed Income';
      } else if (
        (inputData.customerProfile == 'SELF EMPLOYED NON PROFESSIONAL' ||
        inputData.customerProfile == 'SELF EMPLOYED PROFESSIONAL') &&
        inputData.isAssessedIncomePrgrm != null &&
        inputData.isAssessedIncomePrgrm == false
      ) {
        customerProf = 'Self Employed Regular Income';
      }

      String product;
      if (
        inputData.product != null &&
        (inputData.product == 'Small Ticket LAP' || inputData.product == 'Loan Against Property') &&
        inputData.productSubType != null
      ) {
        if (inputData.productSubType == 'LAP Residential') {
          product = 'LAP Residential';
        } else if (inputData.productSubType == 'LAP Commercial') {
          product = 'LAP Commercial';
        } else if (inputData.productSubType == 'Commercial Property Purchase') {
          product = 'Commercial Property Purchase';
        }
      } else if (
        inputData.product != null &&
        inputData.product == 'Home Loan'
      ) {
        product = 'Home Loan';
      }
        
      if (customerProf != null && inputData.product != null && (inputData.product == 'Home Loan' || inputData.product == 'Small Ticket LAP')) {
        query += '(RackRateCusProfile__c = \'' + customerProf + '\' AND ';
      }
      if (product != null && inputData.product != null && (inputData.product == 'Home Loan' || inputData.product == 'Small Ticket LAP')) {
        query +=
          'RackRateProd__c = \'' +
          product +
          '\' AND RackRateType__c = \'Customer Profile\') OR ';
      }
      if (
        inputData.propertyCat != null &&
        ((inputData.propertyIdentified != 'No' &&
        inputData.product == 'Home Loan') ||
        (inputData.propertyIdentified != 'No' &&
        (inputData.product == 'Small Ticket LAP'|| inputData.product == 'Loan Against Property') &&
        inputData.productSubType == 'Commercial Property Purchase') ||
        ((inputData.product == 'Small Ticket LAP' || inputData.product == 'Loan Against Property') &&
        inputData.productSubType != 'Commercial Property Purchase'))
      ) {
        query +=
          '(Prop__c = \'' +
          inputData.propertyCat +
          '\' AND RackRateType__c = \'Property Category\') OR ';
      }

      if (inputData.leadId != null) {
        leadRec = [
          SELECT Id, Branch_Code__c
          FROM Lead
          WHERE Id = :inputData.leadId
          LIMIT 1
        ];
        BankBrchMstr__c bankBraMstr;
        if (leadRec != null) {
          bankBraMstr = [
            SELECT Id, BranchTier__c
            FROM BankBrchMstr__c
            WHERE BrchCode__c = :leadRec.Branch_Code__c
            LIMIT 1
          ];
        }
        if (bankBraMstr != null && bankBraMstr.BranchTier__c != null) {
          branchTier = bankBraMstr.BranchTier__c;
        }
      } else if (inputData.rmSmId != null && inputData.rmSmId != '') {
        teamHier = [
          SELECT Id, EmpBrch__c, EmpBrch__r.BranchTier__c
          FROM TeamHierarchy__c
          WHERE Employee__c = :inputData.rmSmId
          LIMIT 1
        ];
        branchTier = teamHier.EmpBrch__r.BranchTier__c;
      }

      if (branchTier != null) {
        query +=
          '(Loc__c = \'' +
          branchTier +
          '\' AND RackRateType__c = \'Location\') OR ';
      }

      if (inputData.loanAmount != null) {
        query +=
          '((Min__c <= ' +
          inputData.loanAmount +
          ' OR Min__c = null) AND (Max__c >= ' +
          inputData.loanAmount +
          ' OR Max__c = null) AND RackRateType__c = \'Ticket\'))';
      }

      system.debug('Final Query is ' + query);
      // Execute the query
      List<MasterData__c> rackRateList = Database.query(query);
      if (rackRateList != null && !rackRateList.isEmpty()) {
        system.debug('size of rackRateList ' + rackRateList.size());
        for (MasterData__c rackRatMstr : rackRateList) {
          if (rackRatMstr.RackRate__c != null) {
            leadROI += rackRatMstr.RackRate__c;
          }
        }
      }
      System.debug('leadROI: ' + leadROI);
    }
    return leadROI;
  }

  public class RackRateInputWrpr {
    @AuraEnabled
    public String leadId { get; set; }
    @AuraEnabled
    public String rmSmId { get; set; }
    @AuraEnabled
    public String product { get; set; }
    @AuraEnabled
    public String productSubType { get; set; }
    @AuraEnabled
    public String customerProfile { get; set; }
    @AuraEnabled
    public Decimal loanAmount { get; set; }
    @AuraEnabled
    public Boolean isAssessedIncomePrgrm { get; set; }
    @AuraEnabled
    public String propertyIdentified { get; set; }
    @AuraEnabled
    public String propertyCat { get; set; }
  }
}