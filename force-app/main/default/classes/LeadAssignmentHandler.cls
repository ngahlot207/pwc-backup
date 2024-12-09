/** 
* ********************************************************
* Created By : Paresh Saindane
* Created Date: 15-May-2024
* ********************************************************
*/
public class LeadAssignmentHandler implements TriggerAction.AfterInsert{
    public static void afterInsert(list<Lead> newList){
        set<String> leadCity = new set<String>();
     //   map<string,Id> mapCityIds = new map<string,Id>();
        List<Lead> ldList = new List<Lead>();
        List<Lead> bulkldList = new List<Lead>();
        List<TeamHierarchy__c> tmRecList = new List<TeamHierarchy__c>();
     //   List<BankBrchMstr__c> bankBrList = new List<BankBrchMstr__c>();
        map<id,TeamHierarchy__c> updateTmRecMap = new map<id,TeamHierarchy__c>();
        map<string, list<TeamHierarchy__c>> mapCity = new map<string, list<TeamHierarchy__c>>();
        map<string, Integer> countMap = new map<string, Integer>();     
        Integer tmCount = 0;
        
        System.debug(' lead update called  ');
        for(Lead l : newList){
            if(l.LeadSource =='Digital'){
                if(string.isNotBlank(l.CurrentResidenceCity__City__s)){
                    leadCity.add(l.CurrentResidenceCity__City__s);
                }
                if(string.isNotBlank(l.OfficeAddressCity__City__s)){
                     leadCity.add(l.OfficeAddressCity__City__s);
                }
            }else if(l.LeadSource !='Digital' && l.Product__c != null && l.City != null && l.Bulk_Lead__c == true){
                bulkldList.add(l);
            }
            
        }
        
        List<LocBrchJn__c> branchLocationJnList = new  List<LocBrchJn__c>();
        set<Id> allBranchSet = new set<ID>();

        branchLocationJnList = [SELECT Id, Branch__c, Branch__r.BrchCode__c,  IsActive__c, Location__c,Location__r.City__c, ProductType__c  FROM LocBrchJn__c  WHERE IsActive__c = true AND Location__r.City__c In: leadCity ]  ;
        map<string,set<Id>> cityBrMap = new  map<string,set<Id>>();
        for (LocBrchJn__c brJn : branchLocationJnList) {
           // cityBrMap.put(brJn.Location__r.City__c,set<Id> br );
            if(cityBrMap.containsKey(brJn.Location__r.City__c)){
                cityBrMap.get(brJn.Location__r.City__c).add(brJn.Branch__c);
            }else{
                cityBrMap.put(brJn.Location__r.City__c,new set<Id>{brJn.Branch__c});
            }
            allBranchSet.add(brJn.Branch__c);	
        }
        // for LeadSource =='Digital' EmpRole__c ='BBH'
        if(!leadCity.isEmpty() && leadCity.size() >0){
             System.debug(' leadCity  #33'+leadCity+':::::leadCitySize' + leadCity.size());
            tmRecList = [SELECT id, EmpLoc__r.City__c, Employee__c, EmpBrch__r.City__c, EmpBrch__r.LocationMaster__r.City__c, EmpBrch__r.BrchCode__c,EmpRole__c, IsActive__c,
                         Employee__r.FirstName,Employee__r.LastName, LstAssDtTime__c  from TeamHierarchy__c
                         WHERE EmpBrch__c IN :allBranchSet AND employee__r.isActive=true AND IsActive__c = true AND EmpRole__c ='BBH'
                         ORDER BY LstAssDtTime__c ASC];
                   
            for(TeamHierarchy__c t : tmRecList){
                String city ='';
                for (String key : cityBrMap.keySet()) {
                    Set<Id> idSet = cityBrMap.get(key);
                    if (idSet.contains(t.EmpBrch__c)) {
                        city = key; 
                    }
                }

                if(mapCity.containsKey(city)){
                    mapCity.get(city).add(t);
                }else{
                    mapCity.put(city,new List<TeamHierarchy__c>{t});
                }	             
            }
            
          /*  bankBrList =[SELECT Id, Name,  City__c, BrchCode__c, LocationMaster__c,LocationMaster__r.City__c FROM BankBrchMstr__c WHERE LocationMaster__r.City__c IN : leadCity];
            if(!bankBrList.isEmpty()){
                for(BankBrchMstr__c bk : bankBrList){
                        mapCityIds.put(bk.LocationMaster__r.City__c,bk.LocationMaster__c); 
                    
                }
            }*/
        }
        if(!mapCity.isEmpty()){
           // system.debug('mapCityIds:::'+mapCityIds);
            for(Lead l : newList){                
                if(l.LeadSource =='Digital' && mapCity.containsKey(l.City)){
                    integer count = countMap.containskey(l.City) ? countMap.get(l.City) : 0; 
                    list<TeamHierarchy__c> lstTeam = mapCity.get(l.City);
                    if(!lstTeam.isEmpty()){
                        lead ld = new lead(); 
                        ld.Id = l.Id;
                        ld.OwnerId = lstTeam[math.mod(count, lstTeam.size())].Employee__c;
                        ld.BBHUser__c = lstTeam[math.mod(count, lstTeam.size())].Employee__r.FirstName + lstTeam[math.mod(tmCount, lstTeam.size())].Employee__r.LastName;
                        if(l.Constitution__c != 'INDIVIDUAL'){
                            ld.OfficeAddressCity__City__s = l.OfficeAddressCity__City__s;
                        }else{
                             ld.CurrentResidenceCity__City__s = l.CurrentResidenceCity__City__s;
                        }
                       
                        ldList.add(ld);
                        TeamHierarchy__c tm = new TeamHierarchy__c();
                        tm.Id = lstTeam[math.mod(count, lstTeam.size())].Id;
                        tm.LstAssDtTime__c = system.now(); 
                        updateTmRecMap.put(tm.id,tm);
                        count++;
                        countMap.put(l.City,count);
                    }
                    
                }
            }
        }
        if(!ldList.isEmpty()){
            update ldList;
        }
        if(!updateTmRecMap.values().isEmpty()){
            update updateTmRecMap.values();
        }
        //FOR BULK UPLOAD l.Bulk_Lead__c ==true && l.Product__c != null  && l.city != null
        if(!bulkldList.isEmpty()){
            LeadAssignmentHandler.updateBulkUpload(bulkldList);
        }
        
    }
    public static void updateBulkUpload(list<Lead> newList){
        set<String> leadCity = new set<String>();
        List<Lead> ldList = new List<Lead>();
        List<TeamHierarchy__c> tmRecList = new List<TeamHierarchy__c>();
        map<id,TeamHierarchy__c> updateTmRecMap = new map<id,TeamHierarchy__c>();
        map<string, list<TeamHierarchy__c>> mapCity = new map<string, list<TeamHierarchy__c>>();
        map<string, Integer> countMap = new map<string, Integer>();
        map<string, Integer> countMapBulk = new map<string, Integer>();
        Integer tmCount = 0;
        set<String> leadCityForBulkUpload = new set<String>();
        set<String> leadProductForBulkUpload = new set<String>();
        List<String> includesClauses = new List<String>();

     

       
        list<string> roleAssign_AllList = new  list<string> ();
       
        string  leadProdAssignRole = Label.Lead_Bulk_Upload_Assignment_Role;        
            Map<String, Object> strObj = (Map<String, Object>) JSON.deserializeUntyped(leadProdAssignRole);         
            Map<String, List<String>> leadProdAssignRoleMap = new Map<String, List<String>>();
            for (String key : strObj.keySet()) {
                List<Object> objectList = (List<Object>) strObj.get(key);
                List<String> stringList = new List<String>();
                for (Object obj : objectList) {
                    stringList.add((String) obj);
                    roleAssign_AllList.add((String) obj);
                }
                leadProdAssignRoleMap.put(key, stringList);
            }
            Set<String> roleAssign_AllSet = new Set<String>(roleAssign_AllList);
          //  s<string> roleAssign_AllSet = new list<string>(roleAssign_AllSet1);
            System.debug('leadProdAssignRoleMap : '  + leadProdAssignRoleMap + 'roleAssign_AllSet : '+ roleAssign_AllSet);
            string  role_AllStr = '';
            for (string role : roleAssign_AllSet) {
                if (role_AllStr != '') {
                    role_AllStr += ',' + '\'' + role + '\'';
                } else {
                    role_AllStr = '\'' + role + '\'';
                }        
            }




        
        System.debug(' lead update called  ');
        // getting lead city and product 
        for(Lead l : newList){           
            if(l.Bulk_Lead__c == true && l.City != '' && l.Product__c != '' ){
                System.debug(' lead update called for Bulk upload  '+ l.city+ l.Product__c);
                leadCityForBulkUpload.add(l.city);
                leadProductForBulkUpload.add(l.Product__c);               
            }
        }
        System.debug('leadCityForBulkUpload == '+ leadCityForBulkUpload);
        System.debug('leadProductForBulkUpload == '+ leadProductForBulkUpload);
        //    new added 21/08
        map<string,set<Id>> cityBrMap = new  map<string,set<Id>>();
        List<LocBrchJn__c> branchLocationJnList = new  List<LocBrchJn__c>();
        set<Id> allBranchSet = new set<ID>();

        branchLocationJnList= [SELECT Id, Branch__c, Branch__r.BrchCode__c,  IsActive__c, Location__c,Location__r.City__c, ProductType__c  FROM LocBrchJn__c  WHERE IsActive__c = true AND Location__r.City__c In: leadCityForBulkUpload AND  Branch__c != null ]  ;
        
        for (LocBrchJn__c brJn : branchLocationJnList) {
           // cityBrMap.put(brJn.Location__r.City__c,set<Id> br );
            if(cityBrMap.containsKey(brJn.Location__r.City__c)){
                cityBrMap.get(brJn.Location__r.City__c).add(brJn.Branch__c);
            }else{
                cityBrMap.put(brJn.Location__r.City__c,new set<Id>{brJn.Branch__c});
            }
           
                allBranchSet.add(brJn.Branch__c);	
           
            
        }
      
        
        list<string> allBranchList = new list<string>();
      string  allBranchStr = '';
        for (id brId : allBranchSet) {
            if (allBranchStr != '') {
                allBranchStr += ',' + '\'' + brId + '\'';
            } else {
                allBranchStr = '\'' + brId + '\'';
            }        
        }

        List<TeamHierarchy__c> tmRecListBulkUpld = new List<TeamHierarchy__c>();
        List<TeamHierarchy__c> tmRecListBulkUpld1 = new List<TeamHierarchy__c>();
        map<string, list<TeamHierarchy__c>> tmRecListBulkUpldMAP = new  map<string, list<TeamHierarchy__c>>();
        
        map<string, map<string, list<TeamHierarchy__c>>> thCityMap = new map<string,map<string, list<TeamHierarchy__c>>>();
        String productsCondition = '';
        // adding product Condition in query
        if(!leadProductForBulkUpload.isEmpty()){
            for (String product : leadProductForBulkUpload) {
                if (productsCondition != '') {
                    productsCondition += ' OR ';
                }
                productsCondition += 'Product_Type__c  INCLUDES(\'' + product + '\')';
            }
        }
       
        System.debug('productsCondition  ::  ' + productsCondition);
        String cityCondition = '';
        // adding City Condition in query
        for (String city : leadCityForBulkUpload) {
            if (cityCondition != '') {
                cityCondition += ',' + '\'' + city + '\'';
            } else {
                cityCondition = '\'' + city + '\'';
            }        
        }

        System.debug('cityCondition  ::  ' + cityCondition);


        // Construct the SOQL query string
        String soqlQuery = 'SELECT id, EmpBrch__r.City__c,EmpBrch__r.LocationMaster__r.City__c, Product_Type__c, Employee__c, EmpBrch__r.BrchCode__c, EmpRole__c, IsActive__c, ' +
            'Employee__r.FirstName, Employee__r.LastName, LstAssDtTime__c ' +
            'FROM TeamHierarchy__c ' +
            'WHERE IsActive__c = true ';// AND EmpBrch__c  IN (' + allBranchStr+ ')';
            if(allBranchStr !=''){
                soqlQuery +=   ' AND EmpBrch__c  IN (' + allBranchStr+ ')';
            }
            if(productsCondition !=''){
                soqlQuery +=  ' AND (' + productsCondition + ') '  ;
            }
       // soqlQuery += productsCondition;
        
        soqlQuery += 
            'AND Employee__r.IsActive = true ' ;
          if(role_AllStr != ''){
            soqlQuery +=  ' AND EmpRole__c  IN (' + role_AllStr + ')' ;
          }
           // 'AND EmpRole__c  IN (' + role_AllStr + ')' + //(EmpRole__c = \'SM\' OR EmpRole__c = \'RM\') ' +
           soqlQuery +=  'ORDER BY LstAssDtTime__c ASC';
        
        // Executing the dynamic SOQL query
        System.debug('SOQL QUERY == 1'+soqlQuery );
        tmRecListBulkUpld = Database.query(soqlQuery);
        System.debug('tmRecListBulkUpld size : ' + tmRecListBulkUpld.size());    
        // adding TeamHierarchy__c to map<city,map<product,list<TeamHierarchy__c>>>  ;         
        if(!tmRecListBulkUpld.isEmpty()){  
            for(TeamHierarchy__c th : tmRecListBulkUpld) {
                
                String city ='';
                for (String key : cityBrMap.keySet()) {
                    Set<Id> idSet = cityBrMap.get(key);
                    if (idSet.contains(th.EmpBrch__c)) {
                        city = key; 
                    }
                }
        
                list<string> productList = new  list<string> ();
                productList = th.Product_Type__c.split(';'); 
                system.debug('productList :: ' + productList+ '  city == '+ city);
                if(!productList.isEmpty() && city !='' ){
                    for(string Prod : productList){
                        String product =  prod;
                        system.debug('prod iteration :: ' + Prod); 
                        if(!thCityMap.containsKey(product)) {
                            thCityMap.put(product, new Map<String, List<TeamHierarchy__c>>());
                        }                        
                        if(!thCityMap.get(product).containsKey(city)) {
                            thCityMap.get(product).put(city, new List<TeamHierarchy__c>());
                        }        
                        if (leadProdAssignRoleMap.get(product).contains(th.EmpRole__c)) {
                            thCityMap.get(product).get(city).add(th);
                        }                
                        
                    }  
                }             
            }
            
            System.debug('TH City Size :: ' + thCityMap.keySet().size() + thCityMap.keySet());
            System.debug('TH JSON.serialize(thCityMap):: ' +JSON.serialize(thCityMap));  
            System.debug('TH  thCityMap.values().keyset():: ' + thCityMap.values());
            // for  Bulk Lead Upload   
            List<lead> leadBulkUpload = new List<lead>(); 
            if(!thCityMap.isEmpty()){
                
                for(Lead l : newList){
                    System.debug('LEAD DETAILS ' + l.Bulk_Lead__c +' :: '+ thCityMap.containsKey(l.Product__c) +' :: '+ l.Product__c  );
                    if(l.Bulk_Lead__c ==true && l.Product__c != null &&  thCityMap.containsKey(l.Product__c) && l.city != null ){
                        integer count = countMapBulk.containskey(l.City) ? countMapBulk.get(l.City) : 0;
                        System.debug(' th City MAp == '+ thCityMap.get(l.Product__c));
                        
                        list<TeamHierarchy__c> lstTeam = new  list<TeamHierarchy__c> ();
                        System.debug(' th City MAp == '+ l.Product__c +' : ' +l.City + ' ::  '+ !thCityMap.get(l.Product__c).isEmpty() + !thCityMap.get(l.Product__c).containsKey(l.City) + thCityMap.get(l.Product__c).get(l.City));
                        if(!thCityMap.get(l.Product__c).isEmpty() && !thCityMap.get(l.Product__c).get(l.City).isEmpty() ){
                            System.debug(' th City MAp  pro== '+ thCityMap.get(l.Product__c).get(l.City));
                            lstTeam = thCityMap.get(l.Product__c).get(l.City);   
                        }    
                        if(!lstTeam.isEmpty()){
                            lead ld = new lead(); 
                            ld.Id = l.Id;
                            ld.OwnerId = lstTeam[math.mod(count, lstTeam.size())].Employee__c;
                            ld.RM_SM_Name__c =  lstTeam[math.mod(count, lstTeam.size())].Employee__c;
                            leadBulkUpload.add(ld);
                            TeamHierarchy__c tm = new TeamHierarchy__c();
                            tm.Id = lstTeam[math.mod(count, lstTeam.size())].Id;
                            tm.LstAssDtTime__c = system.now(); 
                            updateTmRecMap.put(tm.id,tm);
                            count++;
                            countMapBulk.put(l.City,count);
                        }                       
                    }
                }
            }
            // update Lead
            if(!leadBulkUpload.isEmpty()){
                System.debug(' Lead list To Update size::'+ leadBulkUpload.size()+  leadBulkUpload );
                update leadBulkUpload;
            }
            // update TeamHierarchy__c
            if(!updateTmRecMap.values().isEmpty()){
                System.debug(' TH list To Update size::' + updateTmRecMap.size() + updateTmRecMap);
                update updateTmRecMap.values();
            }   
        }
    }
}