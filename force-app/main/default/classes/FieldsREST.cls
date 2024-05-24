@RestResource(urlMapping='/fields/*')
global with sharing class FieldsREST {
  @HttpGet
  global static void getFieldsUsage() {
    try {
      String objectName = RestContext.request.params.get('objectName');
      if (objectName == null) {
        throw new CustomException('Object Name is not provided');
      }

      Map<String, String> fieldUsage = new Map<String, String>();
      Schema.SObjectType objectType = Schema.getGlobalDescribe()
        .get(objectName);

      if (objectType == null) {
        throw new CustomException('Object Name is not exist');
      }

      List<Schema.SObjectField> fields = objectType.getDescribe()
        .fields.getMap()
        .values();

      String query = 'SELECT ';
      for (Schema.SObjectField field : fields) {
        query += field + ', ';
      }
      query = query.removeEnd(', ') + ' FROM ' + objectName;

      List<SObject> records = Database.query(query);

      Integer totalRecords = records.size();
      for (Schema.SObjectField field : fields) {
        Integer filledRecords = 0;
        for (SObject record : records) {
          if (record.get(field) != null) {
            filledRecords++;
          }
        }
        Decimal percentage = (Decimal) filledRecords / totalRecords * 100;
        fieldUsage.put(
          field.getDescribe().getName(),
          percentage.format() + '%'
        );
      }

      RestHelpers.setSuccessResponse(fieldUsage, 200);
    } catch (Exception e) {
      RestHelpers.setExceptionResponse(e);
    }
  }
}
