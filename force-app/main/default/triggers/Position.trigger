trigger Position on Position__c(before update, before insert) {
  if (Trigger.isBefore) {
    if (Trigger.isInsert || Trigger.isUpdate)
      PositionTriggerHandler.addClosedDateToPosition(Trigger.new);
  }
}
