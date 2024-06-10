public class FieldsUsageBatchable implements Database.Batchable<SObject>, Database.Stateful {
  private String objectName;
  private Map<String, Integer> filledRecordsMap = new Map<String, Integer>();
  private List<String> countingFields = new List<String>();
  private List<String> alwaysFilledFields = new List<String>();
  private List<String> nonCountingFields = new List<String>();

  public FieldsUsageBatchable(String objectName) {
    this.objectName = objectName;
    this.nonCountingFields = getFieldNames(objectName);
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    String fields = !this.nonCountingFields.isEmpty()
      ? String.join(this.nonCountingFields, ',')
      : 'Id';
    return Database.getQueryLocator(
      'SELECT ' + fields + ' FROM ' + this.objectName
    );
  }

  public void execute(Database.BatchableContext bc, List<SObject> scope) {
    if (!this.nonCountingFields.isEmpty()) {
      for (String fieldName : this.nonCountingFields) {
        Integer totalCount = 0;
        for (SObject record : scope) {
          Integer count = 0;
          Object recordField = record.get(fieldName);
          if (recordField != null) {
            count = 1;
            if (recordField instanceof Boolean && !((Boolean) recordField)) {
              count = 0;
            }
          }
          totalCount += count;
        }
        Integer filledCount = this.filledRecordsMap.get(fieldName) ?? 0;
        this.filledRecordsMap.put(fieldName, filledCount + totalCount);
      }
    }
  }

  public void finish(Database.BatchableContext bc) {
    Map<String, String> fieldUsage = getFieldUsage();

    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

    mail.setToAddresses(new List<String>{ UserInfo.getUserEmail() });
    mail.setSubject('Field Usage');
    mail.setHtmlBody(JSON.serialize(fieldUsage));
    Messaging.SendEmail(new List<Messaging.SingleEmailMessage>{ mail });
  }

  private String getContingString(List<String> fieldNames) {
    String countingString = '';
    for (String fieldName : fieldNames) {
      countingString += 'COUNT_DISTINCT(' + fieldName + '), ';
    }
    return countingString.removeEnd(', ');
  }

  private Map<String, String> getFieldUsage() {
    Map<String, String> fieldUsage = new Map<String, String>();

    for (String fieldName : this.alwaysFilledFields) {
      fieldUsage.put(fieldName, '100%');
    }

    if (!this.countingFields.isEmpty()) {
      for (Integer i = 0; i < this.countingFields.size(); i += 100) {
        List<String> subFields = new List<String>();
        for (
          Integer j = i; j < Math.min(i + 100, this.countingFields.size()); j++
        ) {
          subFields.add(this.countingFields[j]);
        }
        String query =
          'SELECT ' +
          getContingString(subFields) +
          ' FROM ' +
          this.objectName;
        List<AggregateResult> countResults = Database.query(query);

        if (countResults.isEmpty()) {
          continue;
        }

        for (Integer j = 0; j < countResults.size(); j++) {
          String fieldName = 'expr' + j;
          Integer fieldValue = (Integer) countResults[j].get(fieldName);
          fieldUsage.put(this.countingFields[j], fieldValue + '%');
        }
      }
    }

    if (!this.nonCountingFields.isEmpty()) {
      Integer totalRecords = Database.countQuery(
        'SELECT COUNT() FROM ' + this.objectName
      );

      for (String fieldName : this.nonCountingFields) {
        Decimal filledRecords = this.filledRecordsMap.get(fieldName) ?? 0;
        Decimal percentage = 0;
        if (totalRecords > 0) {
          percentage = (Decimal) filledRecords / totalRecords * 100;
        }
        fieldUsage.put(fieldName, percentage.setScale(1).format() + '%');
      }
    }

    return fieldUsage;
  }

  private List<String> getFieldNames(String objectName) {
    Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);

    List<Schema.SObjectField> fields = objectType.getDescribe()
      .fields.getMap()
      .values();
    List<String> nonFieldNames = new List<String>();

    for (Schema.SObjectField field : fields) {
      Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
      if (isRequiredField(fieldDescribe) || isSystemField(fieldDescribe)) {
        this.alwaysFilledFields.add(String.valueOf(field));
        continue;
      }
      if (isNonCountedField(fieldDescribe)) {
        nonFieldNames.add(String.valueOf(field));
        continue;
      }
      this.countingFields.add(String.valueOf(field));
    }
    return nonFieldNames;
  }

  private Boolean isRequiredField(Schema.DescribeFieldResult fieldDescribe) {
    return fieldDescribe.isCreateable() &&
      !fieldDescribe.isNillable() &&
      !fieldDescribe.isDefaultedOnCreate();
  }

  private Boolean isSystemField(Schema.DescribeFieldResult fieldDescribe) {
    return fieldDescribe.isDefaultedOnCreate() ||
      fieldDescribe.isCalculated() ||
      fieldDescribe.isAutoNumber() ||
      fieldDescribe.isDefaultedOnCreate() ||
      fieldDescribe.isNameField() ||
      !fieldDescribe.isUpdateable() ||
      !fieldDescribe.isCreateable() ||
      !fieldDescribe.isNillable() ||
      fieldDescribe.isExternalId();
  }

  private Boolean isNonCountedField(Schema.DescribeFieldResult fieldDescribe) {
    Schema.DisplayType fieldType = fieldDescribe.getType();
    return fieldDescribe.isEncrypted() ||
      fieldType == Schema.DisplayType.ENCRYPTEDSTRING ||
      fieldType == Schema.DisplayType.MULTIPICKLIST ||
      fieldType == Schema.DisplayType.TEXTAREA ||
      fieldType == Schema.DisplayType.TIME ||
      fieldType == Schema.DisplayType.BOOLEAN ||
      fieldType == Schema.DisplayType.LOCATION ||
      fieldType == Schema.DisplayType.BASE64 ||
      fieldType == Schema.DisplayType.ADDRESS ||
      fieldType == Schema.DisplayType.ANYTYPE;
  }
}
