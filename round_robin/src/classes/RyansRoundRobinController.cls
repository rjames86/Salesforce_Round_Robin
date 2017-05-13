public with sharing class RyansRoundRobinController {
    public integer rowNum;
    public RyansRoundRobinController() {
    }

    class SettingWrapper {
        public RyansRoundRobinSettings__c rrSetting { get; set; }
        public Integer rowNum { get; set; }

        public SettingWrapper(RyansRoundRobinSettings__c s, Integer num) {
            rrSetting = s;
            rowNum = num;
        }
    }

    public List<SelectOption> getUserFieldNames() {
        List<SelectOption> tempList = new List<SelectOption>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType userSchema = schemaMap.get('User');
        Map<String, Schema.SObjectField> fieldMap = userSchema.getDescribe().fields.getMap();
        for (String fieldName: fieldMap.keySet()) {
            String objectFieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
            Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
            if (fielddataType != Schema.DisplayType.Reference) {
                tempList.add(new SelectOption(objectFieldLabel, fieldName));
            }
        }
        return tempList;
    }

    public void addRow(){
        wrapperObject.add(new SettingWrapper(new RyansRoundRobinSettings__c(), wrapperObject.size()));
    }

    public void removeRow() {
        rowNum = Integer.valueOf(ApexPages.currentPage().getParameters().get('rowIndex'));
        RyansRoundRobinSettings__c toDelete = wrapperObject.get(rowNum).rrSetting;
        if (null != toDelete.Id) {
            delete toDelete;
        }
        wrapperObject.remove(rowNum);
        if (wrapperObject.size() == 0){
            addRow();
        }
    }

    public void save() {
        if (wrapperObject.size() == 0) {
            delete RyansRoundRobinSettings__c.getAll().values();
        } else {
            List<RyansRoundRobinSettings__c> recordsForUpsert = new List<RyansRoundRobinSettings__c>();
            for (SettingWrapper s : wrapperObject) {
                recordsForUpsert.add(s.rrSetting);
            }
            upsert recordsForUpsert;
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'Round Robin Updated!'));
    }

    public List<SettingWrapper> wrapperObject {
        get {
            if (wrapperObject == null) {
                Integer rowNum = 0;
                wrapperObject = new List<SettingWrapper>();
                for (RyansRoundRobinSettings__c setting : RyansRoundRobinSettings__c.getAll().values()){
                    wrapperObject.add(new SettingWrapper(setting, rowNum));
                    rowNum += 1;
                }
                if (wrapperObject.size() == 0){
                    addRow();
                }
            }
            return wrapperObject;
        }
        private set;
    }
}
