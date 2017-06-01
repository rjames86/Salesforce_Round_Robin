public with sharing class RoundRobinSettings {
    Map<String, RyansRoundRobinSettings__c> settings;
    RyansRoundRobinSettings__c record;

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

    public void assignAccountToUser(Account a){
        // I assume we need some kind of criteria to know which group to route to. For now, we'll just route to the first one
        record = settings.values().get(0);
        System.debug('settings ' + record);
        Integer assigneeNumber = (Integer)record.RR_Number__c;

        if (usersForRecord.size() == 0){
            // no one to assign to. let's reset the RR_Number back to 0
            if (assigneeNumber != 0) {
                record.RR_Number__c = 0;
                update record;
            }
            return;
        } else if (record.RR_Number__c > usersForRecord.size()) {
            System.debug('RR Nubmer is larger than usersForRecord');
            // a user has changed since we last incremented. Let's set it to the max it can be
            assigneeNumber = usersForRecord.size() - 1;
            record.RR_Number__c = assigneeNumber;
        }
        a.OwnerId = usersForRecord.get(assigneeNumber).Id;
        update a;
        incrementRRNumber(record.Name);
    }

    public void assignLeadtoUser(Lead l){
        // I assume we need some kind of criteria to know which group to route to. For now, we'll just route to the first one
        record = settings.values().get(0);

        Integer assigneeNumber = (Integer)record.RR_Number__c;

        if (usersForRecord.size() == 0){
            // no one to assign to. let's reset the RR_Number back to 0
            if (assigneeNumber != 0) {
                record.RR_Number__c = 0;
                update record;
            }
            return;
        } else if (record.RR_Number__c > usersForRecord.size()) {
            // a user has changed since we last incremented. Let's set it to the max it can be
            assigneeNumber = usersForRecord.size() - 1;
            record.RR_Number__c = assigneeNumber;
        }
        l.OwnerId = usersForRecord.get(assigneeNumber).Id;
        update l;
        incrementRRNumber(record.Name);
    }

    public void incrementRRNumber(String Name_i) {
        addRRNumberValue(Name_i, 1);
    }

    public void decrementRRNumber(String Name_i) {
        addRRNumberValue(Name_i, -1);
    }

    public List<User> usersForRecord {
        get {
            if (null == usersForRecord){
                String fieldValue = record.FieldValue__c;
                String query = 'SELECT Id' +
                        ' FROM User ' +
                        ' WHERE ' + record.FieldName__c +
                        ' = :fieldValue' +
                        ' ORDER BY CreatedDate';
                usersForRecord = Database.query(query);
            }
            return usersForRecord;
        }
        set;
    }

    public Integer userCountForRecord {
        get {
            if (null == userCountForRecord) {
                String fieldValue = record.FieldValue__c;
                String query = 'SELECT COUNT()' +
                        ' FROM User ' +
                        ' WHERE ' + record.FieldName__c +
                        ' = :fieldValue';
                userCountForRecord = Database.countQuery(query);
            }
            return userCountForRecord;
        }
        set;
    }

    private void addRRNumberValue(String Name_i, Integer numberToAdd){
        if (null == record) {
            return;
        }
        System.debug('record ' + record);

        System.debug('userCountForRecord ' + userCountForRecord);
        Integer numberForUpdate = Math.mod((Integer)record.RR_Number__c + numberToAdd, userCountForRecord);
        if (record.RR_Number__c > userCountForRecord) {
            numberForUpdate = 0;
        }
        if (numberForUpdate < 0) {
            numberForUpdate = 0;
        }
        record.RR_Number__c = numberForUpdate;
        update record;
    }

}
