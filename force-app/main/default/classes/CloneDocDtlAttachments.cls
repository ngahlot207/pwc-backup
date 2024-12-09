public class CloneDocDtlAttachments implements Database.Batchable<SObject>, Database.Stateful {
  private CloneLoanAppController.CloneLoanAppwrpr inputData;
  private Id originalLoanAppId;
  private Id clonedLoanAppId;
  private Map<Id, Id> appWithOldIdMap;

  public CloneDocDtlAttachments(
    CloneLoanAppController.CloneLoanAppwrpr inputData,
    Id originalLoanAppId,
    Id clonedLoanAppId,
    Map<Id, Id> appWithOldIdMap
  ) {
    this.inputData = inputData;
    this.originalLoanAppId = originalLoanAppId;
    this.clonedLoanAppId = clonedLoanAppId;
    this.appWithOldIdMap = appWithOldIdMap;
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    // Query the DocDtl__c records to be cloned
    return Database.getQueryLocator(
      [
        SELECT Id, ClonedSource__c
        FROM DocDtl__c
        WHERE Appl__c IN :appWithOldIdMap.keySet()
      ]
    );
  }

  public void execute(
    Database.BatchableContext bc,
    List<DocDtl__c> docDtlRecords
  ) {
    try {
      if (!docDtlRecords.isEmpty()) {
        system.debug('docDtlRecords ' + docDtlRecords);
        Map<Id, Id> docDtlOldIdMap = new Map<Id, Id>();
        List<ContentDocumentLink> newContentDocLinks = new List<ContentDocumentLink>();

        for (DocDtl__c docDtl : docDtlRecords) {
          docDtlOldIdMap.put(docDtl.ClonedSource__c, docDtl.Id);
        }
          system.debug('docDtlOldIdMap '+ docDtlOldIdMap);
        if (!docDtlOldIdMap.keyset().isEmpty()) {
          List<ContentDocumentLink> contentDocLinks = [
            SELECT Id, ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :docDtlOldIdMap.keySet()
          ];
          for (ContentDocumentLink cdl : contentDocLinks) {
            ContentDocumentLink newCdl = new ContentDocumentLink(
              ContentDocumentId = cdl.ContentDocumentId,
              LinkedEntityId = docDtlOldIdMap.get(cdl.LinkedEntityId)
            );
            newContentDocLinks.add(newCdl);
          }

          if (!newContentDocLinks.isEmpty()) {
            system.debug('newContentDocLinks ' + newContentDocLinks);
            insert newContentDocLinks;
          }
        }
      }
    } catch (Exception e) {
      if (clonedLoanAppId != null) {
        CloneRollbackHanlder.rollbackClonedloanApp(clonedLoanAppId);
      }
      GlobalUtility.logMessage(
        'Error',
        'CloneDocDtlAttachments',
        'Process',
        null,
        null,
        e.getMessage() + ' line ' + e.getLineNumber(),
        null,
        e,
        null
      );
    }
  }

  public void finish(Database.BatchableContext bc) {
    LoanAppl__c updateLoanRecord = new LoanAppl__c();
    updateLoanRecord.Id = clonedLoanAppId;
    updateLoanRecord.CloneStatus__c = 'Success';
    update updateLoanRecord;
    System.debug('Cloning process completed successfully.');
  }
}