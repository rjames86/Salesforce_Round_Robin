trigger RyansRoundRobinLead on Lead (before insert) {
    RoundRobinSettings rrSettings = new RoundRobinSettings();

    for (Lead so : Trigger.new) {
        if(Trigger.isInsert) {
            rrSettings.assignLeadtoUser(so);
        }
    }
}
