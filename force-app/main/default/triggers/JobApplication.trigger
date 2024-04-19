trigger JobApplication on Job_Application__c (after update) {
    if(Trigger.isAfter || Trigger.isUpdate) {       
        JobApplicationTriggerHandler.closeRelatedPosition(Trigger.new);
    }
}