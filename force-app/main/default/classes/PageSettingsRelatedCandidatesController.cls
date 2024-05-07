public with sharing class PageSettingsRelatedCandidatesController {
  @AuraEnabled(cacheable=true)
  public static List<String> getObjectFields(
    String objectApiName,
    String fieldSetName
  ) {
    Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe()
      .get(objectApiName)
      .getDescribe();
    Schema.FieldSet objectFieldSet = objectDescribe.fieldSets.getMap()
      .get(fieldSetName);
    List<String> fields = new List<String>();
    if (objectFieldSet != null) {
      for (Schema.FieldSetMember field : objectFieldSet.getFields()) {
        fields.add(field.getLabel());
      }
    }
    return fields;
  }

  @AuraEnabled(cacheable=true)
  public static List<String> getAllQualifiedApiNamesForRelatedCandidate() {
    List<String> qualifiedApiNames = new List<String>();
    for (Related_Candidate_Setting__mdt record : [
      SELECT QualifiedApiName
      FROM Related_Candidate_Setting__mdt
    ]) {
      qualifiedApiNames.add(record.QualifiedApiName);
    }
    return qualifiedApiNames;
  }

  @AuraEnabled(cacheable=true)
  public static Related_Candidate_Setting__mdt getCustomMetadataForRelatedCandidate(
    String qualifiedApiName
  ) {
    return [
      SELECT
        Is_Avatars_Shown__c,
        Is_Unaccessable_Shown__c,
        Candidates_Per_Page__c,
        Field_Set_For_Candidate_Modal__c,
        Field_Set_For_Candidate_Tile__c,
        Field_Set_For_Related_Job_Application__c
      FROM Related_Candidate_Setting__mdt
      WHERE QualifiedApiName = :qualifiedApiName
      LIMIT 1
    ];
  }

  @AuraEnabled
  public static void updateCustomMetadataRecord(
    String qualifiedApiName,
    Map<String, Object> fieldWithValuesMap
  ) {
    MetadataUtils.updateMetadata(
      'Related_Candidate_Setting.' + qualifiedApiName,
      qualifiedApiName,
      fieldWithValuesMap
    );
  }

  @AuraEnabled(cacheable=true)
  public static List<String> getPicklistValues(String picklistField) {
    List<String> pickListValues = new List<String>();

    Schema.DescribeFieldResult fieldDescribe = Related_Candidate_Setting__mdt.getSObjectType()
      .getDescribe()
      .fields.getMap()
      .get(picklistField)
      .getDescribe();

    for (Schema.PicklistEntry pickVal : fieldDescribe.getPicklistValues()) {
      pickListValues.add(pickVal.getValue());
    }

    return pickListValues;
  }
}
