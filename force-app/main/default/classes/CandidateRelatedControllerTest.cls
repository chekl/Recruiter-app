@isTest
public class CandidateRelatedControllerTest {
  @TestSetup
  static void makeData() {
    Test.startTest();
    Position__c position = TestDataFactory.createPosition('Test');
    Candidate__c candidate = TestDataFactory.createCandidate('Test');
    insert position;
    insert candidate;
    Job_Application__c jobApplication = TestDataFactory.createJobApplication(
      position.Id,
      candidate.Id
    );
    insert jobApplication;
    Test.stopTest();
  }

  @isTest
  static void testSelectCountOfRelatedCandidates() {
    Test.startTest();
    Id positionId = [
      SELECT Id
      FROM Position__c
      WHERE Title__c = 'Test'
      LIMIT 1
    ]
    .Id;
    List<AggregateResult> result = CandidateRelatedController.selectCountOfRelatedCandidates(
      positionId
    );
    Test.stopTest();
    Integer expectedResult = 1;
    Integer actualResult = result.isEmpty()
      ? 0
      : (Integer) result[0].get('expr0');

    Assert.areEqual(
      expectedResult,
      actualResult,
      'The expected count is ' +
        expectedResult +
        ', but instead get: ' +
        actualResult
    );
  }

  @isTest
  static void testSelectCandidatesRelatedToPosition() {
    Test.startTest();
    Id positionId = [
      SELECT Id
      FROM Position__c
      WHERE Title__c = 'Test'
      LIMIT 1
    ]
    .Id;
    List<Job_Application__c> jobApplications = CandidateRelatedController.selectCandidatesRelatedToPosition(
      positionId,
      1,
      0,
      'Related_Candidate_Tile'
    );
    Test.stopTest();
    Integer expectedResult = 1;
    Assert.areEqual(
      expectedResult,
      jobApplications.size(),
      'The expected result is ' +
        expectedResult +
        ', but instead get: ' +
        jobApplications.size()
    );
  }

  @isTest
  static void testSelectJobApplicationRelatedToCandidate() {
    Test.startTest();
    Id candidateId = [
      SELECT Id
      FROM Candidate__c
      WHERE Last_Name__c = 'Test'
      LIMIT 1
    ]
    .Id;
    Id positionId = [
      SELECT Id
      FROM Position__c
      WHERE Title__c = 'Test'
      LIMIT 1
    ]
    .Id;
    Job_Application__c jobApplication = CandidateRelatedController.selectJobApplicationRelatedToCandidate(
      candidateId,
      positionId,
      'Related_Candidate_Job_Application'
    );
    Test.stopTest();
    String expectedResult = 'Need review';
    Assert.areEqual(
      expectedResult,
      jobApplication.Status__c,
      'The expected status is ' +
        expectedResult +
        ', but instead get: ' +
        jobApplication.Status__c
    );
  }

  @isTest
  static void testSelectCandidateById() {
    Test.startTest();
    Id candidateId = [
      SELECT Id
      FROM Candidate__c
      WHERE Last_Name__c = 'Test'
      LIMIT 1
    ]
    .Id;
    Candidate__c candidate = CandidateRelatedController.selectCandidateByIdAndFieldSet(
      candidateId,
      'All_Fields'
    );
    Test.stopTest();

    Assert.areEqual(
      candidateId,
      candidate.Id,
      'The expected candidateId is ' +
        candidateId +
        ', but instead get: ' +
        candidate.Id
    );
  }

  @isTest
  static void testGetCustomMetadataDefaultForRelatedCandidate() {
    Test.startTest();
    Related_Candidate_Setting__mdt customMetadata = CandidateRelatedController.getCustomMetadataForRelatedCandidate();
    Test.stopTest();

    Assert.areNotEqual(null, customMetadata, 'Custom metadata is null');
  }
}
