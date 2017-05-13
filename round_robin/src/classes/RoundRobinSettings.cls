public with sharing class RoundRobinSettings {
    Map<String, RyansRoundRobinSettings__c> settings;

    public RoundRobinSettings() {
        settings = RyansRoundRobinSettings__c.getAll();
    }

    public static void createRecord(String Name_i, SOBjectField fieldName, String fieldValue, SObjectField fieldType) {
        insert new RyansRoundRobinSettings__c(
            Name=Name_i,
            FieldName__c = fieldName.getDescribe().getName(),
            FieldValue__c=fieldValue
        );
    }

    public void assignLeadtoUser(Lead l){
        // I assume we need some kind of criteria to know which group to route to. For now, we'll just route to the first one
        RyansRoundRobinSettings__c record = settings.values().get(0);
        List<User> possibleUsersToAssign = getUsersForSetting(record);
        Integer assigneeNumber = (Integer)record.RR_Number__c;

        if (possibleUsersToAssign.size() == 0){
            // no one to assign to. let's reset the RR_Number back to 0
            if (assigneeNumber != 0) {
                record.RR_Number__c = 0;
                update record;
            }
            return;
        } else if (record.RR_Number__c > possibleUsersToAssign.size()) {
            // a user has changed since we last incremented. Let's set it to the max it can be
            assigneeNumber = possibleUsersToAssign.size() - 1;
        }
        l.OwnerId = possibleUsersToAssign.get(assigneeNumber).Id;
        incrementRRNumber(record.Name);
    }

    public void incrementRRNumber(String Name_i) {
        addRRNumberValue(Name_i, 1);
    }

    public void decrementRRNumber(String Name_i) {
        addRRNumberValue(Name_i, -1);
    }

    public List<User> getUsersForSetting(RyansRoundRobinSettings__c record){
        String fieldValue = record.FieldValue__c;
        String query = 'SELECT Id' +
                ' FROM User ' +
                ' WHERE ' + record.FieldName__c +
                ' = :fieldValue' +
                ' ORDER BY CreatedDate';
        return Database.query(query);
    }

    private void addRRNumberValue(String Name_i, Integer numberToAdd){
        RyansRoundRobinSettings__c record = settings.get(Name_i);
        if (null == record) {
            return;
        }
        String fieldValue = record.FieldValue__c;
        String query = 'SELECT COUNT()' +
                ' FROM User ' +
                ' WHERE ' + record.FieldName__c +
                ' = :fieldValue';
        Integer userCountForRR = Database.countQuery(query);
        Integer numberForUpdate = Math.mod((Integer)record.RR_Number__c + numberToAdd, userCountForRR);
        if (numberForUpdate < 0) {
            numberForUpdate = 0;
        }
        record.RR_Number__c = numberForUpdate;
        update record;
    }

}
