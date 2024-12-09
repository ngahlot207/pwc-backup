@RestResource(urlMapping='/reterieveQuestions/*')
global class QuestionConfigMobileAPI {
    @HttpGet
    global static MobileResponseData getQuestionConfig() {
        String recordId = '';
        String category = '';
        RestRequest restReq = RestContext.request;
        String restRes;
        MobileResponseData response = new MobileResponseData();

        recordId = restReq.params.get('recordId');
        category = restReq.params.get('category');
        System.debug('recordId==' + recordId);
        System.debug('category==' + category);
        try {
            if (!String.isBlank(recordId) && !String.isBlank(category)) {
                if (category == 'PersonalDiscussion') {
                    restRes = JSON.serialize(PDController.retrievePD(recordId));
                } else if (category == 'CollateralVisit') {
                    restRes = JSON.serialize(
                        CollateralVisitController.retrieveCV(recordId)
                    );
                }
                response.isSuccess = true;
                response.responseData = restRes;
            }
        } catch (Exception ex) {
            response.isSuccess = false;
            response.errorMessage = ex.getMessage();
        }
        return response;
    }

    @HttpPost
    global static MobileResponseData saveQuestionData(String questionData) {
        String recordId = '';
        String category = '';
        //String questionData = '';
        RestRequest restReq = RestContext.request;
        String restRes;
        MobileResponseData response = new MobileResponseData();

        recordId = restReq.params.get('recordId');
        category = restReq.params.get('category');
        //questionData = restReq.params.get('questionData');
        System.debug('recordId=='+recordId);
        System.debug('category=='+category);
        System.debug('questionData=='+questionData);
        try {
            if (
                !String.isBlank(recordId) &&
                !String.isBlank(category) &&
                !String.isBlank(questionData)
            ) {
                if (category == 'PersonalDiscussion') {
                    List<QuestionsSaveWrapper> respData = (List<QuestionsSaveWrapper>) JSON.deserialize(
                        questionData,
                        List<QuestionsSaveWrapper>.class
                    );
                    System.debug('questionData == before PDController'+respData);
                    restRes = PDController.savePdData(recordId, respData);
                    System.debug('questionData == after PDController'+respData);
                    response.isSuccess = true;
                    response.responseData = restRes;
                }
                else if (category == 'CollateralVisit') {
                    List<QuestionsSaveWrapper> respData = (List<QuestionsSaveWrapper>) JSON.deserialize(
                        questionData,
                        List<QuestionsSaveWrapper>.class
                    );
                    System.debug('questionData == before PDController'+respData);
                    restRes = CollateralVisitController.saveCV(recordId, respData);
                    System.debug('questionData == after PDController'+respData);
                    response.isSuccess = true;
                    response.responseData = restRes;
                }
            }
        } catch (Exception ex) {
            response.isSuccess = false;
            response.errorMessage = ex.getMessage();
        }
        return response;
    }
}