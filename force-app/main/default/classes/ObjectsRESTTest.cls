@isTest
private class ObjectsRESTTest {
  @isTest
  static void testGetObjects() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/objects';
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    ObjectsREST.getObjects();
    Test.stopTest();

    List<Object> responseBody = (List<Object>) JSON.deserializeUntyped(
      RestContext.response.responseBody.toString()
    );

    Assert.areEqual(
      200,
      RestContext.response.statusCode,
      'Error: ' + responseBody
    );

    Assert.isFalse(responseBody.isEmpty(), 'Responce body must have values');
  }
}
