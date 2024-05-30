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

      List<Schema.SObjectField> fields = objectType.getDescribe()
        .fields.getMap()
        .values();
      List<String> fieldNames = new List<String>();

      for (Schema.SObjectField field : fields) {
        fieldNames.add(String.valueOf(field));
      }

      String query =
        'SELECT ' +
        String.join(fieldNames, ',') +
        ' FROM ' +
        objectName;
      List<SObject> records = Database.query(query);

      Integer totalRecords = records.size();
      if (totalRecords == 0) {
        throw new CustomException('There are no records for this object');
      }

      Map<String, String> fieldUsage = new Map<String, String>();
      for (Schema.SObjectField field : fields) {
        Integer filledRecords = 0;
        for (SObject record : records) {
          Object recordField = record.get(field);
          if (recordField != null) {
            if (recordField instanceof Boolean && !((Boolean) recordField)) {
              continue;
            }
            filledRecords++;
          }
        }
        Decimal percentage = (Decimal) filledRecords / totalRecords * 100;
        fieldUsage.put(
          field.getDescribe().getName(),
          percentage.setscale(1).format() + '%'
        );
      }

      RestHelpers.setSuccessResponse(fieldUsage, 200);
    } catch (Exception e) {
      RestHelpers.setExceptionResponse(e);
    }
  }
}
