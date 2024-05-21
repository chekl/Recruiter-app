@isTest
private class JobApplicationRESTTest {
  @TestSetup
  static void makeData() {
    Candidate__c candidate = TestDataFactory.createCandidate('Test');
    Position__c position = TestDataFactory.createPosition('Test');
    insert candidate;
    insert position;
    Job_Application__c jobApplication = TestDataFactory.createJobApplication(
      position.Id,
      candidate.Id
    );
    insert jobApplication;
  }

  @isTest
  static void testGetJobApplicationDetails() {
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
    Id jobApplicationId = [
      SELECT Id
      FROM Job_Application__c
      WHERE Position__c = :positionId AND Candidate__c = :candidateId
      LIMIT 1
    ]
    .Id;
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI =
      '/services/apexrest/JobApplication/?id=' + jobApplicationId;
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    JobApplicationREST.getJobApplicationDetails();
    Test.stopTest();

    Assert.areEqual(
      200,
      RestContext.response.statusCode,
      req.requestURI +
        'Error ' +
        JSON.deserializeUntyped(RestContext.response.responseBody.toString())
    );
  }
  @isTest
  static void testCreateJobApplication() {
    // TO DO: implement unit test
  }
  @isTest
  static void testUpdateJobApplication() {
    // TO DO: implement unit test
  }
  @isTest
  static void testDeleteJobApplication() {
    // TO DO: implement unit test
  }
}
