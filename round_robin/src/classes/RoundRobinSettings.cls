public with sharing class RoundRobinSettings {
    Map<String, RyansRoundRobinSettings__c> settings;
    public RyansRoundRobinSettings__c setting;

    public RoundRobinSettings() {
        settings = RyansRoundRobinSettings__c.getAll();
        setting = settings.values().get(0); // this is dumb. need to make this better
    }

    public static void createRecord(String Name_i, SOBjectField fieldName, String fieldValue, SObjectField fieldType) {
        insert new RyansRoundRobinSettings__c(
            Name=Name_i,
            FieldName__c = fieldName.getDescribe().getName(),
            FieldValue__c=fieldValue
        );
    }

    public void incrementRRNumber(Integer i) {
        addRRNumberValue(i);
    }

    public void decrementRRNumber(Integer i) {
        addRRNumberValue(-i);
    }

    public List<User> usersForSetting {
        get {
            if (null == usersForSetting){
                String fieldValue = setting.FieldValue__c;
                String query = 'SELECT Id' +
                        ' FROM User ' +
                        ' WHERE ' + setting.FieldName__c +
                        ' = :fieldValue' +
                        ' ORDER BY CreatedDate';
                usersForSetting = Database.query(query);
            }
            return usersForSetting;
        }
        set;
    }

    public Integer userCountForRecord {
        get {
            if (null == userCountForRecord) {
                String fieldValue = setting.FieldValue__c;
                String query = 'SELECT COUNT()' +
                        ' FROM User ' +
                        ' WHERE ' + setting.FieldName__c +
                        ' = :fieldValue';
                userCountForRecord = Database.countQuery(query);
            }
            return userCountForRecord;
        }
        set;
    }

    private void addRRNumberValue(Integer numberToAdd){
        if (null == setting) {
            return;
        }
        Integer numberForUpdate = Math.mod((Integer)setting.RR_Number__c + numberToAdd, userCountForRecord);
        if (setting.RR_Number__c > userCountForRecord) {
            // Is this the right thing to do here? This might skip someone who should be next
            numberForUpdate = 0;
        }
        if (numberForUpdate < 0) {
            numberForUpdate = 0;
        }
        setting.RR_Number__c = numberForUpdate;
    }

    public void save() {
        update setting;
    }

}
