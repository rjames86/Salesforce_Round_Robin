trigger RyansRoundRobinAccount on Account (after insert) {
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
