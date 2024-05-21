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

    req.requestURI = '/services/apexrest/JobApplication/';
    req.httpMethod = 'GET';
    req.addParameter('id', jobApplicationId);
    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    JobApplicationREST.getJobApplicationDetails();
    Test.stopTest();

    Assert.areEqual(
      200,
      RestContext.response.statusCode,
      'Error: ' +
      JSON.deserializeUntyped(RestContext.response.responseBody.toString())
    );
  }
  @isTest
  static void testCreateJobApplication() {
    Candidate__c candidate = TestDataFactory.createCandidate('Test New');
    Position__c position = TestDataFactory.createPosition('Test New');
    insert candidate;
    insert position;
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/JobApplication/';
    req.httpMethod = 'POST';
    Map<String, Object> requestBodyMap = new Map<String, Object>{
      'Candidate__c' => candidate.Id,
      'Position__c' => position.Id,
      'Status__c' => 'Need review'
    };
    req.requestBody = Blob.valueOf(JSON.serialize(requestBodyMap));
    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    JobApplicationREST.createJobApplication();
    Test.stopTest();

    Id jobApplicationId = [
      SELECT Id
      FROM Job_Application__c
      WHERE Position__c = :position.Id AND Candidate__c = :candidate.Id
      LIMIT 1
    ]
    .Id;

    Assert.isNotNull(jobApplicationId, 'Job Application was not created');

    Assert.areEqual(
      200,
      RestContext.response.statusCode,
      'Error: ' +
      JSON.deserializeUntyped(RestContext.response.responseBody.toString())
    );
  }
  @isTest
  static void testUpdateJobApplication() {
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

    req.requestURI = '/services/apexrest/JobApplication/';
    req.httpMethod = 'PATCH';
    Map<String, Object> requestBodyMap = new Map<String, Object>{
      'Status__c' => 'Accepted',
      'id' => jobApplicationId
    };
    req.requestBody = Blob.valueOf(JSON.serialize(requestBodyMap));
    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    JobApplicationREST.updateJobApplication();
    Test.stopTest();

    Job_Application__c jobApplication = [
      SELECT Id, Status__c
      FROM Job_Application__c
      WHERE Position__c = :positionId AND Candidate__c = :candidateId
      LIMIT 1
    ];

    String expectedStatus = 'Accepted';
    Assert.areEqual(
      expectedStatus,
      jobApplication.Status__c,
      'Expected Status is ' +
        expectedStatus +
        'but got ' +
        jobApplication.Status__c
    );

    Assert.areEqual(
      200,
      RestContext.response.statusCode,
      'Error: ' +
      JSON.deserializeUntyped(RestContext.response.responseBody.toString())
    );
  }
  @isTest
  static void testDeleteJobApplication() {
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

    req.requestURI = '/services/apexrest/JobApplication/';
    req.httpMethod = 'DELETE';
    req.addParameter('id', jobApplicationId);
    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    JobApplicationREST.deleteJobApplication();
    Test.stopTest();

    List<Job_Application__c> jobApplication = [
      SELECT Id
      FROM Job_Application__c
      WHERE Position__c = :positionId AND Candidate__c = :candidateId
      LIMIT 1
    ];

    Assert.isTrue(jobApplication.isEmpty(), 'Job Application was not deleted');

    Assert.areEqual(
      200,
      RestContext.response.statusCode,
      'Error: ' +
      JSON.deserializeUntyped(RestContext.response.responseBody.toString())
    );
  }
}
