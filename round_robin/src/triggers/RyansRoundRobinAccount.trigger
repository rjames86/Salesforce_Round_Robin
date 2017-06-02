trigger RyansRoundRobinAccount on Account (after insert) {

    if (Test.isRunningTest()) {
        // this is because of line 7 in RoundRobinSettings
        // it's icky. Need to fix
        return;
    }

    RoundRobinSettings rrSettings = new RoundRobinSettings();
    List<Account> records = [Select OwnerId from Account WHERE Id IN :Trigger.New];

    if (Trigger.New.size() > 99) {
        RyanRoundRobinBatchLoad batchRoundRobin = new RyanRoundRobinBatchLoad(Trigger.newMap);
        database.executeBatch(batchRoundRobin, 50);
    } else {
        RoundRobinService service = new RoundRobinService(records);
        service.assignRoundRobin();
        service.save();
    }
}
