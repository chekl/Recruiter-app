@isTest
private class FieldsRESTTest {
  @TestSetup
  static void makeData() {
    List<Candidate__c> candidates = new List<Candidate__c>();

    for (Integer i = 0; i < 10000; i++) {
      candidates.add(TestDataFactory.createCandidate('Test'));
    }

    insert candidates;
  }

  @isTest
  static void testGetFieldUsage() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/fields/';
    req.httpMethod = 'GET';
    req.addParameter('objectName', 'Candidate__c');
    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    FieldsREST.getFieldsUsage();
    Test.stopTest();

    Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(
      RestContext.response.responseBody.toString()
    );

    Assert.areEqual(
      200,
      RestContext.response.statusCode,
      'Error: ' + responseBody.get('message')
    );

    Assert.areEqual(
      '100%',
      responseBody.get('Last_Name__c'),
      'Last_Name__c usage is 100%, but instead got: ' +
      responseBody.get('Last_Name__c')
    );
  }
}
