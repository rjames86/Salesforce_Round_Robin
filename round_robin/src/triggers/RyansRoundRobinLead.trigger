trigger RyansRoundRobinLead on Lead (before insert) {
    RoundRobinSettings rrSettings = new RoundRobinSettings();

    for (Lead so : Trigger.new) {
        if(Trigger.isInsert) {
            // TODO custom to Heap's sfdc. Need to generalize
            Id salesforceDevId = Id.valueOf('0051a000000d1qrAAA');
            if (so.CreatedById == salesforceDevId){
                rrSettings.assignLeadtoUser(so);
            }
        }
    }
}
