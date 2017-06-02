public with sharing class RoundRobinService {
    List<SObject> records;
    RoundRobinSettings settings;

    public RoundRobinService(List<SObject> sObjects) {
        records = sObjects;
        settings = new RoundRobinSettings();
    }

    public RoundRobinService(List<Account> accounts) {
        this((List<SObject>)accounts);
    }

    public void assignRoundRobin(){
        for (SObject record : records) {
            Integer assigneeNumber = (Integer)settings.setting.RR_Number__c;

            if (settings.usersForSetting.size() == 0){
                // no one to assign to. let's reset the RR_Number back to 0
                if (assigneeNumber != 0) {
                    settings.setting.RR_Number__c = 0;
                }
                return;
            } else if (settings.setting.RR_Number__c > settings.usersForSetting.size()) {
                // a user has changed since we last incremented. Let's set it to the max it can be
                assigneeNumber = settings.usersForSetting.size() - 1;
                settings.setting.RR_Number__c = assigneeNumber;
            }
            record.put('OwnerId', settings.usersForSetting.get(assigneeNumber).Id);
            settings.incrementRRNumber(1);
        }
    }

    public void save(){
        settings.save();
        update records;
    }
}
