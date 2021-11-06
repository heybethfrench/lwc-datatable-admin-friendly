public with sharing class datatableHelper {
    @AuraEnabled(cacheable=true)
    public static tableOutput getTableOutput(String fieldSetName, String theObject) {
        
        tableOutput output = new tableOutput();
        output.fields = getFieldSetMembers(fieldSetName, theObject, True);

        String fieldString = '';
        Integer index = 0;
        Integer length = output.fields.size() - 1;
        String queryString;

        for (fieldSetOutput field : output.fields) {
            if (index == length) {
                fieldString = fieldString + field.fieldName;
                break;
            } else {
                fieldString = fieldString + field.fieldName + ', ';
                index = index + 1;
            }
        }

        queryString = 'SELECT ' + fieldString + ' FROM ' + theObject;

        List<sObject> records = Database.query(queryString);

        output.recordList = records;
        return output;
    }
    @AuraEnabled(cacheable=true)
    public static List<fieldSetOutput> getFieldSetMembers(String fieldSetName, String theObject, Boolean isSortable){
        List<fieldSetOutput> fieldSetReturn = new List<fieldSetOutput>();
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(theObject);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);

        List<Schema.FieldSetMember> fields = new List<Schema.FieldSetMember>();
        
        fields.addAll(fieldSetObj.getFields());
      
        for(Schema.FieldSetMember x: fields){
            fieldSetOutput output = new fieldSetOutput();
            output.label = x.label;
            output.fieldName = x.getFieldPath();
            output.type = String.valueOf(x.getType());
            output.sortable = isSortable;
            fieldSetReturn.add(output);
        }

        return fieldSetReturn;
    }

    public class fieldSetOutput {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String fieldName;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public Boolean sortable;

    }

    public class tableOutput {
        @AuraEnabled
        public List<fieldSetOutput> fields;
        @AuraEnabled
        public List<sObject> recordList;
        
    }
}
