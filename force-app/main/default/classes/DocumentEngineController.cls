public class DocumentEngineController {
    
    public static List<String> evalAllRequiredDocs(DocumentEngine docEng, String applicantId,String loanAppId,String productType,String stage,String subStage,List<String> categoriesList){
        List<String> errors = new List<String>();
        DocumentEngine.MissingDocRetunWrpr returnDocs = docEng.evalAllRequiredDocsAddNew(applicantId,loanAppId,productType,stage,subStage,categoriesList);
        system.debug('returnDocs ' + returnDocs);
        if(returnDocs != null){
            Map<String,List<String>> missingAndDocs = returnDocs.andList;
            if(missingAndDocs != null && missingAndDocs.keySet().size() > 0){
                for(String str : missingAndDocs.keySet()){
                    List<String> docSubTypes = missingAndDocs.get(str);
                    if(docSubTypes != null && docSubTypes.size() > 0){
                        String docSubTpes = String.join(docSubTypes, ',');
                        docSubTpes = docSubTpes.removeEnd(','); 
                        errors.add('Required Documents are missing for ' + str + ' :(' + docSubTpes + ')');
                    }
                   
                }
            }
            Map<String,List<String>> missingOrDocs = returnDocs.orList;
            if(missingOrDocs != null && missingOrDocs.keySet().size() > 0){
                for(String str : missingOrDocs.keySet()){
                    List<String> docSubTypes = missingOrDocs.get(str);
                    if(docSubTypes != null && docSubTypes.size() > 0){
                        String docSubTpes = String.join(docSubTypes, ',');
                        docSubTpes = docSubTpes.removeEnd(','); 
                        errors.add('Atleast One Document is required for ' + str + ' :(' + docSubTpes + ')');
                    } 
                }
            }
        }
        if(errors != null && errors.size() > 0){
            return errors;
        }
        return null;
    }
}