public with sharing class JobApplicationTriggerHandler {
  public static void onlyUniqueCandidatesPerPosition(
    List<Job_Application__c> jobApplications
  ) {
    Set<Id> positionIds = new Set<Id>();
    for (Job_Application__c jobApplication : jobApplications) {
      positionIds.add(jobApplication.Position__c);
    }

    Map<Id, List<Id>> positionsWithCandidates = new Map<Id, List<Id>>();
    for (Job_Application__c jobApplication : [
      SELECT Position__c, Candidate__c
      FROM Job_Application__c
      WHERE Position__c IN :positionIds
    ]) {
      if (!positionsWithCandidates.containsKey(jobApplication.Position__c)) {
        positionsWithCandidates.put(jobApplication.Position__c, new List<Id>());
      }
      positionsWithCandidates.get(jobApplication.Position__c)
        .add(jobApplication.Candidate__c);
    }

    for (Job_Application__c jobApplication : jobApplications) {
      List<Id> candidates = positionsWithCandidates.get(
        jobApplication.Position__c
      );
      if (
        candidates != null && candidates.contains(jobApplication.Candidate__c)
      ) {
        jobApplication.addError(System.Label.Only_Unique_Candidates_Error);
      }
    }
  }

  public static List<Job_Application__c> getJobApplicationsWithChangedStatusToAccepted(
    Map<Id, Job_Application__c> jobApplicationNewMap,
    Map<Id, Job_Application__c> jobApplicationOldMap
  ) {
    List<Job_Application__c> changedJobApplications = new List<Job_Application__c>();
    for (Id jobApplicationId : jobApplicationNewMap.keySet()) {
      Job_Application__c newJobApplication = jobApplicationNewMap.get(
        jobApplicationId
      );
      if (
        newJobApplication.Status__c !=
        jobApplicationOldMap.get(jobApplicationId).Status__c &&
        newJobApplication.Status__c == 'Accepted'
      ) {
        changedJobApplications.add(newJobApplication);
      }
    }
    return changedJobApplications;
  }

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

    Map<Id, Position__c> positionsToUpdateMap = new Map<Id, Position__c>();
    for (Job_Application__c jobApplication : jobApplications) {
      if (jobApplication.Status__c == 'Accepted') {
        Position__c position = positions.get(jobApplication.Position__c);
        if (!positionsToUpdateMap.containsKey(position.Id)) {
          position.Status__c = 'Closed';
          positionsToUpdateMap.put(position.Id, position);
        }
      }
    }

    if (!positionsToUpdateMap.isEmpty()) {
      update positionsToUpdateMap.values();
    }
  }
}
