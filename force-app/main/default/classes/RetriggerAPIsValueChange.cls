public class RetriggerAPIsValueChange implements TriggerAction.AfterInsert, TriggerAction.AfterUpdate, TriggerAction.AfterDelete {
  public static void afterInsert(List<Applicant__c> newList) {

    List<Applicant__c> appNewList = new List<Applicant__c> ();
    for(Applicant__c app : newList){
      if(app.ApplType__c == 'P' || app.ApplType__c == 'C' || app.ApplType__c == 'G'){
        appNewList.add(app);
      }
    }
    if(!appNewList.isEmpty()){
      RetriggerUpsertHandler.InputData inputData = new RetriggerUpsertHandler.InputData();
      inputData.newList = appNewList;
      inputData.oldList = null;
      inputData.modificationType = 'Insert';
      inputData.objectApiName = 'Applicant__c';
      inputData.applFieldAPIName = 'Id';
      inputData.loanFieldAPIName = 'LoanAppln__c';
      RetriggerUpsertHandler.createRetriggerRecords(inputData);
    }
  }

  public static void afterUpdate(
    List<Applicant__c> newList,
    List<Applicant__c> oldList
  ) {
    system.debug('afterUpdate>> ');
    List<Applicant__c> appNewList = new List<Applicant__c> ();
    for(Applicant__c app : newList){
      if(app.ApplType__c == 'P' || app.ApplType__c == 'C' || app.ApplType__c == 'G'){
        appNewList.add(app);
      }
    }
    if(!appNewList.isEmpty()){
      RetriggerUpsertHandler.InputData inputData = new RetriggerUpsertHandler.InputData();
      inputData.newList = appNewList;
      inputData.oldList = oldList;
      inputData.modificationType = 'Update';
      inputData.objectApiName = 'Applicant__c';
      inputData.applFieldAPIName = 'Id';
      inputData.loanFieldAPIName = 'LoanAppln__c';
  
      RetriggerUpsertHandler.createRetriggerRecords(inputData);
    }
   
    updateEmpDetails(newList, oldList);
  }

  public static void afterDelete(List<Applicant__c> newList) {
    List<Applicant__c> appNewList = new List<Applicant__c> ();
    for(Applicant__c app : newList){
      if(app.ApplType__c == 'P' || app.ApplType__c == 'C' || app.ApplType__c == 'G'){
        appNewList.add(app);
      }
    }
    if(!appNewList.isEmpty()){
      RetriggerUpsertHandler.InputData inputData = new RetriggerUpsertHandler.InputData();
      inputData.newList = appNewList;
      inputData.oldList = null;
      inputData.modificationType = 'Delete';
      inputData.objectApiName = 'Applicant__c';
      inputData.applFieldAPIName = 'Id';
      inputData.loanFieldAPIName = 'LoanAppln__c';
      RetriggerUpsertHandler.createRetriggerRecords(inputData);
    }
  }

  public static void updateEmpDetails(
    List<Applicant__c> newList,
    List<Applicant__c> oldList
  ) {
    Set<Id> appIds = new Set<Id>();
    List<ApplicantEmployment__c> updateAppEmp = new List<ApplicantEmployment__c>();
    Map<Id, Applicant__c> appMap = new Map<Id, Applicant__c>(oldList);
    if (!newList.isEmpty()) {
      for (Applicant__c app : newList) {
        if (
          (app.CustProfile__c != appMap.get(app.Id).CustProfile__c ||
          app.Type_of_Borrower__c != appMap.get(app.Id).Type_of_Borrower__c ||
          app.Constitution__c != appMap.get(app.Id).Constitution__c) &&
          ((String.isNotBlank(app.CustProfile__c) &&
          app.CustProfile__c == 'SALARIED' &&
          ((appMap != null &&
          app.CustProfile__c != appMap.get(app.Id).CustProfile__c) ||
          appMap == null)) ||
          (String.isNotBlank(app.CustProfile__c) &&
          (app.CustProfile__c == 'SELF EMPLOYED NON PROFESSIONAL' ||
          app.CustProfile__c == 'SELF EMPLOYED PROFESSIONAL') &&
          String.isNotBlank(app.Constitution__c) &&
          app.Constitution__c == 'INDIVIDUAL' &&
          ((appMap != null &&
          (app.CustProfile__c != appMap.get(app.Id).CustProfile__c ||
          app.Constitution__c != appMap.get(app.Id).Constitution__c) ||
          appMap == null))) ||
          (String.isNotBlank(app.Type_of_Borrower__c) &&
          app.Type_of_Borrower__c == 'Non Financial' &&
          ((appMap != null &&
          app.Type_of_Borrower__c != appMap.get(app.Id).Type_of_Borrower__c) ||
          appMap == null)))
        ) {
          appIds.add(app.Id);
        }
      }
      if (!appIds.isEmpty()) {
        List<ApplicantEmployment__c> empRecrds = [
          SELECT
            Id,
            UdyamAssistCertificate__c,
            LoanApplicant__c,
            LoanApplicant__r.Constitution__c,
            LoanApplicant__r.CustProfile__c,
            UdyamRegistrationNumber__c,
            LoanApplicant__r.Id,
            Proprietorship_firm_part_of_the_proposal__c,
            Is_URC_UAC_available__c,
            Select_applicability_for_URC_UAC__c,
            DesignationValues__c
          FROM ApplicantEmployment__c
          WHERE LoanApplicant__c IN :appIds
        ];
        if (!empRecrds.isEmpty()) {
          for (ApplicantEmployment__c appEm : empRecrds) {
            ApplicantEmployment__c appEmp = new ApplicantEmployment__c();
            if (
              (String.isNotBlank(appEm.LoanApplicant__r.CustProfile__c) &&
              (appEm.LoanApplicant__r.CustProfile__c ==
              'SELF EMPLOYED NON PROFESSIONAL' ||
              appEm.LoanApplicant__r.CustProfile__c ==
              'SELF EMPLOYED PROFESSIONAL') &&
              String.isNotBlank(appEm.LoanApplicant__r.Constitution__c) &&
              appEm.LoanApplicant__r.Constitution__c == 'INDIVIDUAL' &&
              ((appMap != null &&
              (appEm.LoanApplicant__r.CustProfile__c !=
              appMap.get(appEm.LoanApplicant__r.Id).CustProfile__c ||
              appEm.LoanApplicant__r.Constitution__c !=
              appMap.get(appEm.LoanApplicant__r.Id).Constitution__c) ||
              appMap == null))) &&
              appEm.Proprietorship_firm_part_of_the_proposal__c == 'YES' &&
              String.isNotBlank(
                appEm.Proprietorship_firm_part_of_the_proposal__c
              )
            ) {
              appEmp.Id = appEm.Id;
              appEmp.Is_URC_UAC_available__c = String.isNotBlank(
                  appEm.Is_URC_UAC_available__c
                )
                ? null
                : appEm.Is_URC_UAC_available__c;
              appEmp.Select_applicability_for_URC_UAC__c = String.isNotBlank(
                  appEm.Select_applicability_for_URC_UAC__c
                )
                ? null
                : appEm.Select_applicability_for_URC_UAC__c;
              appEmp.UdyamRegistrationNumber__c = String.isNotBlank(
                  appEm.UdyamRegistrationNumber__c
                ) &&
                String.isNotBlank(appEm.Select_applicability_for_URC_UAC__c) &&
                appEm.Select_applicability_for_URC_UAC__c ==
                'UDYAM REGISTRATION NUMBER (URC)'
                ? null
                : appEm.UdyamRegistrationNumber__c;
              appEmp.UdyamAssistCertificate__c = String.isNotBlank(
                  appEm.UdyamAssistCertificate__c
                ) &&
                String.isNotBlank(appEm.Select_applicability_for_URC_UAC__c) &&
                appEm.Select_applicability_for_URC_UAC__c ==
                'UDYAM ASSIST CERTIFICATE (UAC)'
                ? null
                : appEm.UdyamAssistCertificate__c;
            } else {
              appEmp.Id = appEm.Id;
              appEmp.Is_URC_UAC_available__c = String.isNotBlank(
                  appEm.Is_URC_UAC_available__c
                )
                ? null
                : appEm.Is_URC_UAC_available__c;
              appEmp.Select_applicability_for_URC_UAC__c = String.isNotBlank(
                  appEm.Select_applicability_for_URC_UAC__c
                )
                ? null
                : appEm.Select_applicability_for_URC_UAC__c;
              appEmp.UdyamRegistrationNumber__c = String.isNotBlank(
                  appEm.UdyamRegistrationNumber__c
                ) &&
                String.isNotBlank(appEm.Select_applicability_for_URC_UAC__c) &&
                appEm.Select_applicability_for_URC_UAC__c ==
                'UDYAM REGISTRATION NUMBER (URC)'
                ? null
                : appEm.UdyamRegistrationNumber__c;
              appEmp.UdyamAssistCertificate__c = String.isNotBlank(
                  appEm.UdyamAssistCertificate__c
                ) &&
                String.isNotBlank(appEm.Select_applicability_for_URC_UAC__c) &&
                appEm.Select_applicability_for_URC_UAC__c ==
                'UDYAM ASSIST CERTIFICATE (UAC)'
                ? null
                : appEm.UdyamAssistCertificate__c;
            }
            updateAppEmp.add(appEmp);
          }
        }
      }
      if (!updateAppEmp.isEmpty()) {
        update updateAppEmp;
      }
    }
  }
}