@RestResource(urlMapping='/fields/*')
global with sharing class FieldsREST {
  @HttpGet
  global static void getFieldsUsage() {
    try {
      String objectName = RestContext.request.params.get('objectName');
      if (objectName == null) {
        throw new CustomException('Object Name is not provided');
      }

      Schema.SObjectType objectType = Schema.getGlobalDescribe()
        .get(objectName);
      if (objectType == null) {
        throw new CustomException('Object Name is not exist');
      }

      FieldsUsageBatchable batchable = new FieldsUsageBatchable(objectName);
      Database.executeBatch(batchable);

      RestHelpers.setSuccessResponse('Check email', 200);
    } catch (Exception e) {
      RestHelpers.setExceptionResponse(e);
    }
  }
}
