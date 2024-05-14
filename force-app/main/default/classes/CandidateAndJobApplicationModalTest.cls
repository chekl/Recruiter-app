@isTest
private class CandidateAndJobApplicationModalTest {
  @isTest
  static void testGetFormFields() {
    Test.startTest();
    List<String> formFields = CandidateAndJobApplicationModal.getFormFieldsByObjectType(
      'Candidate__c'
    );
    Test.stopTest();
    Assert.isNotNull(formFields, 'formFields is null');
    Assert.isTrue(
      formFields.size() > 0,
      'The candidate fields should not be empty'
    );
  }
}
