@isTest
private class PageSettingsRelatedCandidatesTest {
  @isTest
  static void testGetObjectFields() {
    Test.startTest();
    List<String> objectFields = PageSettingsRelatedCandidatesController.getObjectFields(
      'Job_Application__c',
      'Related_Candidate_Tile'
    );
    Test.stopTest();
    Assert.areNotEqual(0, objectFields.size(), 'objectFields is empty');
  }

  @isTest
  static void testGetCustomMetadataForRelatedCandidate() {
    Test.startTest();
    List<String> qualifiedApiNames = PageSettingsRelatedCandidatesController.getAllQualifiedApiNamesForRelatedCandidate();
    Related_Candidate_Setting__mdt customMetadata = PageSettingsRelatedCandidatesController.getCustomMetadataForRelatedCandidate(
      qualifiedApiNames[0]
    );
    Test.stopTest();
    Assert.areNotEqual(
      0,
      qualifiedApiNames.size(),
      'qualifiedApiNames is empty'
    );
    Assert.areNotEqual(null, customMetadata, 'Custom metadata is null');
  }

  @isTest
  static void testGetPicklistValues() {
    Test.startTest();
    List<String> picklistValues = PageSettingsRelatedCandidatesController.getPicklistValues(
      'Field_Set_For_Candidate_Tile__c'
    );
    Test.stopTest();
    Assert.areNotEqual(0, picklistValues.size(), 'picklistValues is emply');
  }
}
