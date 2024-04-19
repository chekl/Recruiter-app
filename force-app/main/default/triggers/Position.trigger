trigger Position on Position__c (before update) {
    if(Trigger.isBefore && Trigger.isUpdate) {       
        PositionTriggerHandler.addClosedDateToPosition(Trigger.new);
    }
}