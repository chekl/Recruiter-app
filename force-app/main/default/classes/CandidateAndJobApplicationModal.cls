public with sharing class CandidateAndJobApplicationModal {
  @AuraEnabled(cacheable=true)
  public static List<String> getFormFieldsByObjectType(String sObjectType) {
    Create_Candidate_Setting__mdt mtd = getMetadata();
    return generateFieldsArray(
      getFieldSetFields(sObjectType, (String) mtd.get(sObjectType))
    );
  }

  private static List<String> generateFieldsArray(
    List<Schema.FieldSetMember> fields
  ) {
    List<String> form = new List<String>();
    for (Schema.FieldSetMember field : fields) {
      form.add(field.getFieldPath());
    }
    return form;
  }

  private static List<Schema.FieldSetMember> getFieldSetFields(
    String sObjectType,
    String fieldSetName
  ) {
    Schema.SObjectType sObjectTypeToken = Schema.getGlobalDescribe()
      .get(sObjectType);
    if (sObjectTypeToken == null) {
      return new List<Schema.FieldSetMember>();
    }
    Schema.DescribeSObjectResult sObjectDescribe = sObjectTypeToken.getDescribe();
    Schema.FieldSet fieldSet = sObjectDescribe.fieldSets.getMap()
      .get(fieldSetName);
    return fieldSet != null
      ? fieldSet.getFields()
      : new List<Schema.FieldSetMember>();
  }

  private static Create_Candidate_Setting__mdt getMetadata() {
    return [
      SELECT Candidate__c, Job_Application__c
      FROM Create_Candidate_Setting__mdt
      WHERE QualifiedApiName = 'Universal_Modal'
      LIMIT 1
    ];
  }
}
