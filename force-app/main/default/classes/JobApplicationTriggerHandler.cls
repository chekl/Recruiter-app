public with sharing class JobApplicationTriggerHandler {
  public static void closeRelatedPosition(
    List<Job_Application__c> jobApplications
  ) {
    Set<String> positionIds = new Set<String>();
    for (Job_Application__c jobApplication : jobApplications) {
      positionIds.add(jobApplication.Position__c);
    }

    Map<Id, Position__c> positions = new Map<Id, Position__c>(
      [SELECT Id, Status__c FROM Position__c WHERE Id IN :positionIds]
    );

    List<Position__c> positionsToUpdate = new List<Position__c>();
    for (Job_Application__c jobApplication : jobApplications) {
      if (jobApplication.Status__c == 'Accepted') {
        Position__c position = positions.get(jobApplication.Position__c);
        if (position != null) {
          position.Status__c = 'Closed';
          positionsToUpdate.add(position);
        }
      }
    }

    if (!positionsToUpdate.isEmpty()) {
      update positionsToUpdate;
    }
  }
}
