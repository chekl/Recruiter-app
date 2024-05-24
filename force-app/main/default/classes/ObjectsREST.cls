@RestResource(urlMapping='/objects')
global with sharing class ObjectsREST {
  @HttpGet
  global static void getObjects() {
    try {
      List<String> objectNames = new List<String>();
      for (Schema.SObjectType objType : Schema.getGlobalDescribe().Values()) {
        objectNames.add(objType.getDescribe().getName());
      }
      RestHelpers.setSuccessResponse(objectNames, 200);
    } catch (Exception e) {
      RestHelpers.setExceptionResponse(e);
    }
  }
}
