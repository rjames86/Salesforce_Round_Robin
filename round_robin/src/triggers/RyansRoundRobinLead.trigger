trigger RyansRoundRobinLead on Lead (after insert) {
    RoundRobinSettings rrSettings = new RoundRobinSettings();

    for (Lead so : Trigger.new) {
        if(Trigger.isInsert) {
            // TODO custom to Heap's sfdc. Need to generalize
            Id salesforceDevId = Id.valueOf('0051a000001JeGWAA0');
            if (so.CreatedById == salesforceDevId){
                System.debug('assigning lead to someone ' + so);
                rrSettings.assignLeadtoUser(so);
            }
        }
    }
}
