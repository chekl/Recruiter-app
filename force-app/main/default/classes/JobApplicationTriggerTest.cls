@isTest
public with sharing class JobApplicationTriggerTest {
  @isTest
  static void testCloseRelatedPosition() {
    List<Position__c> positions = new List<Position__c>();
    for (Integer i = 0; i < 1000; i++) {
      positions.add(TestDataFactory.createPosition('Test'));
    }
    Candidate__c candidate = TestDataFactory.createCandidate('Test');
    Test.startTest();
    insert positions;
    insert candidate;
    Id candidateId = [
      SELECT Id
      FROM Candidate__c
      WHERE Last_Name__c = 'Test'
      LIMIT 1
    ]
    .Id;
    positions = [
      SELECT Id
      FROM Position__c
      WHERE Title__c = 'Test'
    ];
    List<Job_Application__c> jobApplications = new List<Job_Application__c>();
    for (Integer i = 0; i < 1000; i++) {
      Job_Application__c jobApplication = TestDataFactory.createJobApplication(
        positions.get(i).Id,
        candidateId
      );
      jobApplication.Status__c = 'Need Review';
      jobApplications.add(jobApplication);
    }
    insert jobApplications;

    List<Job_Application__c> jobApplicationsToUpdate = [SELECT Id, Status__c, Cover_Letter__c FROM Job_Application__c WHERE Status__c = 'Need Review'];
    Integer halfSize = jobApplicationsToUpdate.size() / 2;
    
    for(Integer i = 0; i < halfSize; i++) {
      jobApplicationsToUpdate.get(i).Status__c = 'Accepted';
    }
    
    for(Integer i = halfSize; i < jobApplicationsToUpdate.size(); i++) {
      jobApplicationsToUpdate.get(i).Cover_Letter__c = 'New';
    }
    
    update jobApplicationsToUpdate;
    Test.stopTest();
    List<Job_Application__c> insertedJobApplications = [
      SELECT Id, Position__r.Status__c
      FROM Job_Application__c
      WHERE Position__c = :positions AND Position__r.Status__c = 'Closed'
    ];

    Assert.areEqual(
      halfSize,
      insertedJobApplications.size(),
      'The expected result is '+ halfSize + ', but instead get: ' +
      insertedJobApplications.size()
    );
  }
}