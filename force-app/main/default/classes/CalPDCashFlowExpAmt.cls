public without sharing class CalPDCashFlowExpAmt implements TriggerAction.AfterInsert, TriggerAction.AfterUpdate, TriggerAction.AfterDelete {
    public static void afterInsert(List<ApplExpense__c> newList) {
        updateCashFlowExpense(newList);
    }

    public static void afterUpdate(
        List<ApplExpense__c> newList,
        List<ApplExpense__c> oldList
    ) {
        updateCashFlowExpense(newList);
    }

    public static void afterDelete(List<ApplExpense__c> newList) {
        updateCashFlowExpense(newList);
    }

    public static void updateCashFlowExpense(List<ApplExpense__c> newList) {
        //Map<Id, ApplExpense__c> newMap = new Map<Id, ApplExpense__c>(newList);
        RecordType rt = [
            SELECT Id, Name
            FROM RecordType
            WHERE Name = 'Fedfina Officer Validation'
            LIMIT 1
        ];
        //List<ApplExpense__c> expenses = [SELECT Id, PrsnlDis__c, RecordType.name, ApplInc__c FROM ApplExpense__c WHERE Id IN :newMap.keySet()];
        Map<Id, Id> pdtoCashflowIds = new Map<Id, Id>();
        for (ApplExpense__c ae : newList) {
            if (ae.PrsnlDis__c != null && ae.RecordTypeId == rt.Id) {
                pdtoCashflowIds.put(ae.PrsnlDis__c, ae.ApplInc__c);
            }
        }

        if (pdtoCashflowIds.size() > 0) {
            Map<Id, Decimal> caseflowExpMap = new Map<Id, Decimal>();
            List<Applicant_Income__c> cfIncome = [
                SELECT Id, Total_Expense_of_operations_Or_Business__c
                FROM Applicant_Income__c
                WHERE Id = :pdtoCashflowIds.Values()
            ];
            List<ApplExpense__c> pdExpenses = [
                SELECT Id, ExpAmt__c, ApplInc__c
                FROM ApplExpense__c
                WHERE
                    PrsnlDis__c = :pdtoCashflowIds.Keyset()
                    AND RecordTypeId = :rt.Id
                    AND IsDeleted = FALSE
            ];
            for (ApplExpense__c exp : pdExpenses) {
                if (caseflowExpMap.containsKey(exp.ApplInc__c)) {
                    caseflowExpMap.put(
                        exp.ApplInc__c,
                        caseflowExpMap.get(exp.ApplInc__c) + exp.ExpAmt__c
                    );
                } else {
                    caseflowExpMap.put(exp.ApplInc__c, exp.ExpAmt__c);
                }
            }

            for (Applicant_Income__c applInc : cfIncome) {
                applInc.Total_Expense_of_operations_Or_Business__c = caseflowExpMap.get(
                    applInc.Id
                );
            }
            System.debug('cfIncome==' + cfIncome);
            update cfIncome;
        }
    }
}