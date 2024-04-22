@isTest
public with sharing class JobApplicationTriggerTest {
  @isTest
  static void testCloseRelatedPosition() {
    Position__c position = TestDataFactory.createPosition('Test');
    Candidate__c candidate = TestDataFactory.createCandidate('Test');
    Test.startTest();
    insert position;
    insert candidate;
    Id candidateId = [
      SELECT Id
      FROM Candidate__c
      WHERE Last_Name__c = 'Test'
      LIMIT 1
    ]
    .Id;
    Id positionId = [SELECT Id FROM Position__c WHERE Title__c = 'Test' LIMIT 1]
    .Id;
    Job_Application__c jobApplication = TestDataFactory.createJobApplication(
      positionId,
      candidateId
    );
    jobApplication.Status__c = 'Accepted';
    insert jobApplication;
    Test.stopTest();
    Job_Application__c insertedJobApplication = [
      SELECT Id, Position__r.Status__c
      FROM Job_Application__c
      WHERE Position__c = :positionId
      LIMIT 1
    ];

    Assert.areEqual(
      'Closed',
      insertedJobApplication.Position__r.Status__c,
      'The expected result is Closed, but instead get: ' +
      insertedJobApplication.Position__r.Status__c
    );
  }
}
