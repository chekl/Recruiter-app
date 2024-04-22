trigger JobApplication on Job_Application__c(after update, after insert) {
  if (Trigger.isAfter) {
    if (Trigger.isInsert || Trigger.isUpdate)
      JobApplicationTriggerHandler.closeRelatedPosition(Trigger.new);
  }
}
