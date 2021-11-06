public with sharing class getRecordsByIds {
    @InvocableMethod(
        label='getAccounts'
        description='Retrieves Account records when provided with sObject API name and a List of Ids or a List of Codes'
    )
    public static List<accountsOutput> getAccountRecordsByCodeOrId(List<getRecordsByCodeOrIdInput> inputList) {
        List<accountsOutput> outputList = new List<accountsOutput>();

        accountsOutput outputObject = new accountsOutput();

        List<Account> accounts = getRecordsByCodeOrId(inputList);

        outputObject.accounts = accounts;

        outputList.add(outputObject);

        return outputList;
    }

    public class getRecordsByCodeOrIdInput {
        @InvocableVariable
        public String sObjectApiName;

        @InvocableVariable
        public String fieldSetApiName;

        @InvocableVariable
        public List<String> salesforceIds;

        @InvocableVariable
        public List<String> codes;
    }

    public class accountsOutput {
        @InvocableVariable
        public List<Account> accounts;
    }

    public static List<sObject> getRecordsByCodeOrId(List<getRecordsByCodeorIdInput> inputList) {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();

        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(inputList[0].sObjectApiName);

        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

        List<Schema.FieldSetMember> fields = new List<Schema.FieldSetMember>();

        List<Id> allIds = new List<Id>();

        List<String> allCodes = new List<String>();

        List<String> allFieldSets = new List<String>();

        for (getRecordsByCodeOrIdInput input : inputList) {
            if (String.valueOf(SObjectTypeObj) == input.sObjectApiName) {
                if (input.codes != null) {
                    allCodes.addall(input.codes);
                }

                if (input.salesforceIds != null) {
                    allIds.addall(input.salesforceIds);
                }

                if (input.fieldSetApiName != null) {
                    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap()
                        .get(input.fieldSetApiName);
                    fields.addAll(fieldSetObj.getFields());
                }
            }
        }

        String fieldString = '';
        Integer index = 0;
        Integer length = fields.size() - 1;
        for (Schema.FieldSetMember field : fields) {
            if (index == length) {
                fieldString = fieldString + field.getFieldPath();
                break;
            } else {
                fieldString = fieldString + field.getFieldPath() + ', ';
                index = index + 1;
            }
        }

        String queryString;

        if (allCodes.isEmpty() && !allIds.isEmpty()) {
            queryString = 'SELECT ' + fieldString + ' FROM ' + SObjectTypeObj + ' WHERE Id IN :allIds';
        } else {
            queryString = 'SELECT ' + fieldString + ' FROM ' + SObjectTypeObj + ' WHERE Code__c IN :allCodes';
        }

        List<sObject> result = new List<sObject>();
        result = (List<SObject>) Type.forName('List<' + SObjectTypeObj + '>').newInstance();

        if (fieldString != '' && fieldString != null && queryString != null && queryString != '') {
            result = Database.query(queryString);
        }

        return result;
    }
}