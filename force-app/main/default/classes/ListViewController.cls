public class ListViewController {
    public class MetadataServiceExamplesException extends Exception { }
    
	public static MetadataService.MetadataPort createService()
    {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        System.debug(service.endpoint_x);
        service.SessionHeader = new MetadataService.SessionHeader_element();
        //service.SessionHeader.sessionId = UserInfo.getSessionId();//'{!$Credential.OAuthToken}'
        //service.SessionHeader.sessionId = '{!$Credential.OAuthToken}';
        service.SessionHeader.sessionId = createSessionId();
        return service;
    }
    
    public static void createListView()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.ListView listView = new MetadataService.ListView();
        listView.fullName = 'Contact.Test004';
        listView.label = 'Test004';
        listView.filterScope = 'Everything';
        listView.columns = new List<String> { 'CONTACT.FIRST_NAME','CONTACT.LAST_NAME','CONTACT.BIRTHDATE' };
        System.debug(listView.columns);
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { listView });
        handleSaveResults(results[0]);
    }
    
    @AuraEnabled(cacheable=true)
    public static void upsertListView(String ObjName, String listName, String label,List<String> columns)
    {
        MetadataService.MetadataPort service = createService();
        System.debug(listName);
        MetadataService.ListView listView = (MetadataService.ListView) service.readMetadata('ListView',
		new String[] { ObjName + '.' + listName }).getRecords()[0];
        listView.filterScope = 'Everything';
        System.debug(listView.columns);
        
        List<String> updateColumns = stringConvertHelper(columns,ObjName);
        listView.columns = updateColumns;
        System.debug(updateColumns);
        MetadataService.UpsertResult[] results =
            service.upsertMetadata(
                new MetadataService.ListView[] { listView });
        handleUpsertResults(results[0]);
    }

    public static List<String> stringConvertHelper(List<String> columns, String ObjName){
        List<String> updateColumns = new List<String>();
        for(String column:columns){
            List<String> lstx = column.replaceAll('([A-Z])','\n$1' ).split('\n');
            lstx.remove(0);
            String col = '';
            for(String lst:lstx){
                col = col+lst+'_';
            }
            col = col.substring(0, col.length()-1);
            column = ObjName.toUppercase() + '.' + col.toUppercase();
            updateColumns.add(column);
        }
        return updateColumns;
    }    
    public static void handleSaveResults(MetadataService.SaveResult saveResult)
    {
        // Nothing to see?
        if(saveResult==null || saveResult.success)
            return;
        // Construct error message and throw an exception
        if(saveResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + saveResult.fullName + '.');
            for(MetadataService.Error error : saveResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new MetadataServiceExamplesException(String.join(messages, ' '));
        }
        if(!saveResult.success)
            throw new MetadataServiceExamplesException('Request failed with no specified error.');
    }
    
    public static void handleUpsertResults(MetadataService.UpsertResult upsertResult)
    {
        // Nothing to see?
        if(upsertResult==null || upsertResult.success)
            return;
        // Construct error message and throw an exception
        if(upsertResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (upsertResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + upsertResult.fullName + '.');
            for(MetadataService.Error error : upsertResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new MetadataServiceExamplesException(String.join(messages, ' '));
        }
        if(!upsertResult.success)
            throw new MetadataServiceExamplesException('Request failed with no specified error.');
    }
    
    public static String createSessionId(){
        PageReference sessionPage = Page.UserSessionPage;
        String vfContent = sessionPage.getContent().toString();
        Integer startIndex = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length();
        Integer endIndex = vfContent.indexOf('End_Of_Session_Id');

        return vfContent.substring(startIndex, endIndex);
    }
}