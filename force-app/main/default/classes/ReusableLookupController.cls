public without sharing class ReusableLookupController {
    @AuraEnabled(cacheable=true)
    public static List<ResultWrapper> fetchRecords(SearchWrapper inputWrapper) {
        Map<String, ResultWrapper> resultMap = new Map<String, ResultWrapper>();
        try {
            if (inputWrapper != null) {
                String fieldsToQuery = 'SELECT Id, ';
                if (string.isNotBlank(inputWrapper.fieldApiName)) {
                    fieldsToQuery = fieldsToQuery + inputWrapper.fieldApiName;
                }


                if (string.isNotBlank(inputWrapper.selectFields)) {
                    fieldsToQuery =
                        fieldsToQuery +
                        ',' +
                        inputWrapper.selectFields;
                }
                String query =
                    fieldsToQuery +
                    ' FROM ' +
                    inputWrapper.objectApiName;

                String filterCriteria =
                    inputWrapper.fieldApiName +
                    ' LIKE ' +
                    '\'%' +
                    String.escapeSingleQuotes(
                        inputWrapper.searchString.trim()
                    ) +
                    '%\'';

                system.debug('input wrapper ' + inputWrapper);
                if (string.isNotBlank(inputWrapper.filterConditions)) {
                    filterCriteria += ' AND ' + inputWrapper.filterConditions;
                }
                if (String.isNotBlank(inputWrapper.selectedRecordId)) {
                    if (String.isNotBlank(inputWrapper.selecetdFieldName)) {
                        query +=
                            ' WHERE ' +
                            inputWrapper.selecetdFieldName +
                            ' = \'' +
                            inputWrapper.selectedRecordId +
                            '\'';
                    } else {
                        query +=
                            ' WHERE Id = \'' +
                            inputWrapper.selectedRecordId +
                            '\'';
                    }
                } else if (
                    String.isNotBlank(inputWrapper.parentFieldApiName) &&
                    String.isNotBlank(inputWrapper.parentRecordId)
                ) {
                    query +=
                        ' WHERE ' +
                        inputWrapper.parentFieldApiName +
                        ' = \'' +
                        inputWrapper.parentRecordId +
                        '\'';
                    query += ' AND ' + filterCriteria;
                } else {
                    query += ' WHERE ' + filterCriteria;
                }
                List<ResultWrapper> returnWrapperList = new List<ResultWrapper>();
                //Adding limit Manish P
                query =
                    query +
                    ' Order BY ' +
                    inputWrapper.fieldApiName +
                    ' LIMIT 5000';

                system.debug('query:::::::>' + query);
                for (SObject s : Database.query(query)) {
                    ResultWrapper wrap = new ResultWrapper();
                    wrap.record = s;
                    
                    if (inputWrapper.fieldApiName.contains('__r')) {
                        //string filedApiName = inputWrapper.fieldApiName.replace('__r','');
                        list<string> fieldNames = inputWrapper.fieldApiName.split(
                            '\\.'
                        );
                        system.debug(s.getSobject(fieldNames[0]));
                        wrap.mainField = (String) s.getSobject(fieldNames[0])
                            .get(fieldNames[1]);
                        
                    } else {
                        wrap.mainField = (String) s.get(
                            inputWrapper.fieldApiName
                        );
                    }
                    // if(inputWrapper.objectApiName.contains('TeamHierarchy__c')){
                    //     wrap.role = (String) s.get('EmpRole__c');
                    // }
                    //wrap.subField = (String)s.get(inputWrapper.otherFieldApiName
                    if (string.isNotBlank(inputWrapper.keyId)) {
                        if (inputWrapper.keyId.contains('__r')) {
                            list<string> keyIdList = inputWrapper.keyId.split(
                                '\\.'
                            );

                            wrap.id = (String) s.getSobject(keyIdList[0])
                                .get(keyIdList[1]);
                        } else {
                            wrap.id = (String) s.get(inputWrapper.keyId);
                        }
                    } else {
                        wrap.id = (String) s.get('id');
                    }
                    if (
                        inputWrapper.fieldApiName == 'DocTyp__c' &&
                        inputWrapper.objectApiName == 'DocMstr__c'
                    ) {
                        resultMap.put(wrap.mainField, wrap);
                    } else {
                        resultMap.put(wrap.id, wrap);
                        //resultMap.put(wrap.role,wrap);
                    }

                    if(resultMap.size() == 200) {
                        break;
                    }
                }
                return resultMap.values();
            }
            return null;
        } catch (Exception err) {
            system.debug(
                'Error Msg' +
                (err.getMessage() +
                'Line Number::::>' +
                err.getLineNumber())
            );
            throw new AuraHandledException(err.getMessage());
        }
    }

    public class ResultWrapper {
        @AuraEnabled
        public String mainField { get; set; }
        // @AuraEnabled public String subField{get;set;}
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public SObject record { get; set; }
    }

    public class SearchWrapper {
        @AuraEnabled
        public String objectApiName { get; set; }
        @AuraEnabled
        public String fieldApiName { get; set; }
        //  @AuraEnabled public String otherFieldApiName{get;set;}
        @AuraEnabled
        public String searchString { get; set; }
        @AuraEnabled
        public String selectedRecordId { get; set; }
        @AuraEnabled
        public String parentRecordId { get; set; }
        @AuraEnabled
        public String parentFieldApiName { get; set; }
        @AuraEnabled
        public String filterConditions { get; set; }
        @AuraEnabled
        public String selectFields { get; set; }
        @AuraEnabled
        public String keyId { get; set; }
        @AuraEnabled
        public String selecetdFieldName { get; set; }
    }
}