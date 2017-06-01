trigger RyansRoundRobinLead on Lead (after insert) {
    RoundRobinSettings rrSettings = new RoundRobinSettings();

    List<Lead> records = [Select OwnerId from Lead WHERE Id IN :Trigger.New];

    for (Lead so : Trigger.new) {
        if(Trigger.isInsert) {
            rrSettings.assignLeadtoUser(so);
        }
    }
}
