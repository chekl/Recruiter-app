public class FieldsUsageBatchable implements Database.Batchable<SObject>, Database.Stateful {
  private String objectName;
  private Map<String, Integer> filledRecordsMap = new Map<String, Integer>();
  private List<String> fieldNames;

  public FieldsUsageBatchable(String objectName) {
    this.objectName = objectName;
    this.fieldNames = getFieldNames(objectName);
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    Integer batchSize = 500;
    List<String> currentFields = new List<String>();
    Integer index = 0;

    while (index < this.fieldNames.size()) {
      currentFields.clear();

      for (
        Integer i = index;
        i < Math.min(index + batchSize, this.fieldNames.size());
        i++
      ) {
        currentFields.add(this.fieldNames[i]);
      }

      String query =
        'SELECT ' +
        String.join(currentFields, ',') +
        ' FROM ' +
        this.objectName;
      Database.QueryLocator batchQueryLocator = Database.getQueryLocator(query);
      index += batchSize;
      return batchQueryLocator;
    }

    return null;
  }

  public void execute(Database.BatchableContext bc, List<SObject> scope) {
    for (SObject record : scope) {
      for (String fieldName : this.fieldNames) {
        Integer filledCount = this.filledRecordsMap.get(fieldName) ?? 0;
        if (record.get(fieldName) != null) {
          filledCount += 1;
        }
        this.filledRecordsMap.put(fieldName, filledCount);
      }
    }
  }

  public void finish(Database.BatchableContext bc) {
    Map<String, String> fieldUsage = getFieldUsage(
      this.fieldNames,
      this.filledRecordsMap,
      this.objectName
    );
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

    mail.setToAddresses(new List<String>{ UserInfo.getUserEmail() });
    mail.setSubject('Field Usage');
    mail.setHtmlBody(JSON.serialize(fieldUsage));
    Messaging.SendEmail(new List<Messaging.SingleEmailMessage>{ mail });
  }

  private Map<String, String> getFieldUsage(
    List<String> fieldNames,
    Map<String, Integer> filledRecordsMap,
    String objectName
  ) {
    Map<String, String> fieldUsage = new Map<String, String>();

    Integer totalRecords = Database.countQuery(
      'SELECT COUNT() FROM ' + objectName
    );

    for (String fieldName : fieldNames) {
      Decimal filledRecords = filledRecordsMap.get(fieldName) ?? 0;
      Decimal percentage = (Decimal) filledRecords / totalRecords * 100;
      fieldUsage.put(fieldName, percentage.setScale(1).format() + '%');
    }

    return fieldUsage;
  }

  private List<String> getFieldNames(String objectName) {
    Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);

    List<Schema.SObjectField> fields = objectType.getDescribe()
      .fields.getMap()
      .values();
    List<String> fieldNames = new List<String>();

    for (Schema.SObjectField field : fields) {
      fieldNames.add(String.valueOf(field));
    }
    return fieldNames;
  }
}
