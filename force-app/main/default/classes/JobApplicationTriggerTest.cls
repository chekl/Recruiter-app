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
    List<Position__c> positionsId = [
      SELECT Id
      FROM Position__c
      WHERE Title__c = 'Test'
    ];
    List<Job_Application__c> jobApplications = new List<Job_Application__c>();
    for (Integer i = 0; i < 1000; i++) {
      Job_Application__c jobApplication = TestDataFactory.createJobApplication(
        positionsId[i].Id,
        candidateId
      );
      jobApplication.Status__c = 'Accepted';
      jobApplications.add(jobApplication);
    }
    insert jobApplications;
    Test.stopTest();
    List<Job_Application__c> insertedJobApplications = [
      SELECT Id, Position__r.Status__c
      FROM Job_Application__c
      WHERE Position__c = :positionsId
    ];
    Integer closedPositions = [
      SELECT COUNT()
      FROM Position__c
      WHERE Status__c = 'Closed'
    ];

    Assert.areEqual(
      1000,
      closedPositions,
      'The expected closed positions count is 1000, but insted get: ' +
      closedPositions
    );
    Assert.areEqual(
      'Closed',
      insertedJobApplications[0].Position__r.Status__c,
      'The expected result is Closed, but instead get: ' +
      insertedJobApplications[0].Position__r.Status__c
    );
  }
}
