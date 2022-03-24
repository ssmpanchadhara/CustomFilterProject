public class TestMetadataApi {
    public class MetadataServiceExamplesException extends Exception { }
    
	public static MetadataService.MetadataPort createService()
    {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }
    
    public static void createListView()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.ListView listView = new MetadataService.ListView();
        listView.fullName = 'Contact.Test001';
        listView.label = 'Test001';
        listView.filterScope = 'Everything';
        listView.columns = new List<String> { 'ACCOUNT.NAME' };
            System.debug(listView);
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { listView });
        handleSaveResults(results[0]);
    }
    
    public static void upsertListView(String ObjName, String listName, String label,List<String> columns)
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.ListView listView = new MetadataService.ListView();
        listView.fullName = ObjName+'.'+listName;
        listView.label = label;
        //listView.filterScope = 'Everything';
        //listView.columns = new List<String> { 'CONTACT.FIRST_NAME' };
       	listView.columns = columns;
        MetadataService.SaveResult[] results =
            service.updateMetadata(
                new MetadataService.ListView[] { listView });
        handleSaveResults(results[0]);
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
}