@isTest
private class CandidateAndJobApplicationModalTest {
  @isTest
  static void testGetFormFields() {
    Test.startTest();
    Map<String, List<String>> formFields = CandidateAndJobApplicationModal.getFormFields();
    Test.stopTest();
    Assert.isNotNull(formFields, 'formFields is null');
    Assert.areEqual(2, formFields.size(), 'formFields should contain two keys');
    Assert.isNotNull(
      formFields.get('jobApplicationFields'),
      'The job application fields should not be null'
    );
    Assert.isNotNull(
      formFields.get('candidateFields'),
      'The candidate fields should not be null'
    );
    Assert.isTrue(
      !formFields.get('candidateFields').isEmpty(),
      'The candidate fields should not be empty'
    );
    Assert.isTrue(
      !formFields.get('candidateFields').isEmpty(),
      'The job application fields should not be empty'
    );
  }
}
