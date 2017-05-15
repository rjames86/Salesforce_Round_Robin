trigger RyansRoundRobinLead on Lead (before insert) {
    RoundRobinSettings rrSettings = new RoundRobinSettings();

    for (Lead so : Trigger.new) {
        if(Trigger.isInsert) {
            // TODO custom to Heap's sfdc. Need to generalize
            if (so.CreatedById == (Id)'0051a000001JeGWAA0'){
                rrSettings.assignLeadtoUser(so);
            }
        }
    }
}
