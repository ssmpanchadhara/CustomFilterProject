public with sharing class CustomObjectController {
    public CustomObjectController() {

    }

    @AuraEnabled(cacheable=true)
    public static List<String> getContactFields(){
        SObjectType contactType = Schema.getGlobalDescribe().get('Contact');
        Map<String,Schema.SObjectField> mfields = contactType.getDescribe().fields.getMap();

        List<String> sObjectDetailsList = new List<String>();
        for(String s : mfields.keySet()){
            sObjectDetailsList.add(String.valueOf(mfields.get(s)));
        }
        sObjectDetailsList.sort();
        return sObjectDetailsList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactList(String[] recordIds, String[] selectedFields){
        //List<String> fields = getContactFields();
        String fieldString = '';
        String recordIdString = '';
        
        for(String field:selectedFields){
            fieldString = fieldString+field+',';
        }
        
        for(String recordId:recordIds){
            recordIdString = recordIdString+''+recordId+',';
        }
        fieldString = fieldString.substring(0, fieldString.length()-1);
        
        
        if(recordIdString.length()>0){
        	recordIdString = recordIdString.substring(0, recordIdString.length()-1);
            String query = 'Select '+fieldString+' from Contact where Id IN :recordIds';
            List<Contact> contactList= Database.query(query);
            system.debug('myData::'+JSON.serialize(contactList));
        	return contactList;
        
        }
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Object> wireRecords(List<Object> records){
        return records;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Object> GetListView(String ObjName){
        Id userId = UserInfo.getUserId();
        System.debug(userId);
        List<ListView> listView = [SELECT Id, Name, DeveloperName, SobjectType 
                                   FROM ListView 
                                   WHERE SobjectType =: ObjName
                                  and CreatedById =: userId
                                  ORDER BY LastModifiedDate DESC];
        System.debug(ObjName);
        System.debug(listView);
        return listView;
    }
}