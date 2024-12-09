public class PropertyQuestionController {
    @AuraEnabled
    public static PropertyQuesResponse retrieveAllPropQues(Id assetId) {
        PropertyQuesResponse propQuesResp = new PropertyQuesResponse();
        Map<String, List<PropertyQuesWpr>> propQuesMap = new Map<String, List<PropertyQuesWpr>>();

        ApplAsset__c property = [
            SELECT
                Id,
                State__c,
                Prop_Sub_TyId__c,
                LoanAppln__c,
                LoanAppln__r.Product__c,
                LoanAppln__r.SchemeId__c,
                AllPropSbtypNrmsMet__c,
                AllPropGnrlNrmsMet__c
            FROM ApplAsset__c
            WHERE Id = :assetId
        ];

        List<PropQuesResp__c> paresntResp = [
            SELECT Id
            FROM PropQuesResp__c
            WHERE Property__c = :assetId
        ];
        PropQuesResp__c propQues;
        if (paresntResp != null && paresntResp.size() > 0) {
            propQues = paresntResp[0];
        }
        else {
            propQues = new PropQuesResp__c();
            propQues.Property__c = assetId;
            propQues.LoanApplc__c = property.LoanAppln__c;
            propQues.ProdTyp__c = property.LoanAppln__r.Product__c;
            insert propQues;
        }

        Map<Id, PropQuesRespJn__c> questionWithRespMap = new Map<Id, PropQuesRespJn__c>();
        for (PropQuesRespJn__c resp : [
            SELECT Id, Resp__c, PropQuest__c
            FROM PropQuesRespJn__c
            WHERE PropQuesResp__r.Property__c = :assetId
        ]) {
            questionWithRespMap.put(resp.PropQuest__c, resp);
        }
        List<PropQues__c> allQues = [
            SELECT Id, Question_Tiltle__c, RespTyp__c, PossResp__c, Category__c,VisibleMob__c,VisibleWeb__c
            FROM PropQues__c
            WHERE
                IsActive__c = TRUE
                AND ((RecordType.Name = 'Property Questions'
                AND (PropertySubType__c = NULL
                OR PropertySubType__c = :property.Prop_Sub_TyId__c)
                AND ProdTyp__c INCLUDES (:property.LoanAppln__r.Product__c)
                /* AND State__c INCLUDES (:property.State__c) */
                AND (Scheme__c = NULL
                OR Scheme__c = :property.LoanAppln__r.SchemeId__c))
                OR Category__c = 'General Norms')
        ];

        for (PropQues__c ques : allQues) {
            List<PropertyQuesWpr> quesList = propQuesMap.get(ques.Category__c);
            if (quesList == null) {
                quesList = new List<PropertyQuesWpr>();
            }
            PropQuesRespJn__c respRec = questionWithRespMap.get(ques.Id);
            PropertyQuesWpr proQues = new PropertyQuesWpr();
            proQues.quesId = ques.Id;
            proQues.quesTitle = ques.Question_Tiltle__c;
            if (respRec != null) {
                proQues.quesResp = respRec.Resp__c;
                proQues.respId = respRec.Id;
            }
            proQues.isReqPortal = true;
            if (ques.PossResp__c != null) {
                List<String> options = (List<String>) JSON.deserialize(
                    ques.PossResp__c,
                    List<String>.class
                );
                proQues.possibleOptions = options;
            }
            proQues.respType = ques.RespTyp__c;
            proQues.visibleOnMobile = true;
            proQues.visibleOnPortal = true;
            quesList.add(proQues);
            propQuesMap.put(ques.Category__c, quesList);
            System.debug('quesList==>:' + quesList);
        }
        propQuesResp.propCheckboxValue = property.AllPropSbtypNrmsMet__c;
        propQuesResp.gnrlCheckboxValue = property.AllPropGnrlNrmsMet__c;
        propQuesResp.propRespId= propQues.Id;
        propQuesResp.generalNormsQues = new List<PropertyQuesWpr>();
        propQuesResp.propSubtypeQues = new List<PropertyQuesWpr>();
        if(propQuesMap.get('General Norms') != null) {
            propQuesResp.generalNormsQues = propQuesMap.get('General Norms');
        }
        if(propQuesMap.get('Property Subtype') != null) {
            propQuesResp.propSubtypeQues = propQuesMap.get('Property Subtype');
        }
        System.debug('Data==>:' + propQuesResp);
        return propQuesResp;
    }

    public class PropertyQuesResponse {
        @AuraEnabled
        public Id propRespId { get; set; }
        @AuraEnabled
        public Boolean gnrlCheckboxValue { get; set; }
        @AuraEnabled
        public Boolean propCheckboxValue { get; set; }
        @AuraEnabled
        public List<PropertyQuesWpr> generalNormsQues { get; set; }
        @AuraEnabled
        public List<PropertyQuesWpr> propSubtypeQues { get; set; }
    }

    public class PropertyQuesWpr {
        @AuraEnabled
        public Id quesId { get; set; }
        @AuraEnabled
        public String quesTitle { get; set; }
        @AuraEnabled
        public String quesResp { get; set; }
        @AuraEnabled
        public String respType { get; set; }
        @AuraEnabled
        public String respId { get; set; }
        @AuraEnabled
        public Boolean isReqPortal { get; set; }
        @AuraEnabled
        public Boolean visibleOnMobile { get; set; }
        @AuraEnabled
        public Boolean visibleOnPortal { get; set; }
        @AuraEnabled
        public List<String> possibleOptions { get; set; }
    }
}