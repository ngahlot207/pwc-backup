public class IndustrySubIndMapCreator {
  
    public static  map<string,set<string>>  getIndNsubInd(){
        try {

            list<SubIndustry__c>  subIndList = new list<SubIndustry__c>();
            subIndList= [select   Name,Industry__c, Industry__r.name  from SubIndustry__c ];
            map<string,set<string>> finalMap = new  map<string,set<string>>();
           
            for (SubIndustry__c sunInd : subIndList) {
                set<string> subIndVal= new set<string>();
                //system.debug(sunInd  +' :: '+ finalMap.keySet().size());
                if(finalMap.keySet().size() >0){
                    for (string  mapKey : finalMap.keySet()) {
                        if(mapKey == sunInd.Industry__r.Name){
                          set<string> ss =   finalMap.get(mapKey);
                            ss.add(sunInd.Name);
                            finalMap.put(sunInd.Industry__r.Name,ss);
                        }else{
                            subIndVal.add(sunInd.Name);
                            finalMap.put(sunInd.Industry__r.Name,subIndVal);
                        }
                    }
                }else{
                    subIndVal.add(sunInd.Name);
                    finalMap.put(sunInd.Industry__r.Name,subIndVal);
                }
               
                
            }
            system.debug(finalMap);
            //system.debug(JSON.serialize(finalMap));
           return finalMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}