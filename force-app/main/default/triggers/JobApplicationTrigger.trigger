trigger JobApplicationTrigger on Job_Application__c(after update, after insert) {
    if (Trigger.isAfter) {
      if (Trigger.isInsert) {
        JobApplicationTriggerHandler.closeRelatedPosition(Trigger.new);
      }
      if(Trigger.isUpdate) {
        List<Job_Application__c> jobApplications = JobApplicationTriggerHandler.getJobApplicationsWithChangedStatusToAccepted(Trigger.newMap, Trigger.oldMap);
        if(!jobApplications.isEmpty()) {
          JobApplicationTriggerHandler.closeRelatedPosition(jobApplications);
        }
      }
    }
  }
  