global with sharing class RyanRoundRobinBatchLoad implements Database.Batchable<sObject>, Database.Stateful {
    String query;
    Set<Id> ids;

    public RyanRoundRobinBatchLoad(Map<Id, Account> triggerAccountMap) {
        ids = triggerAccountMap.keySet();
        query = 'Select OwnerId from Account WHERE Id IN :ids';
    }

    global Database.QueryLocator start(Database.BatchableContext ctx) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject>scope) {
        RoundRobinService service = new RoundRobinService(scope);
        service.assignRoundRobin();
        service.save();
    }

    global void finish(Database.BatchableContext ctx) {}
}
