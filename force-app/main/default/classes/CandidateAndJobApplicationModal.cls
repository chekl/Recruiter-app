public with sharing class CandidateAndJobApplicationModal {
  @AuraEnabled
  public static List<String> getCandidateForm() {
    Create_Candidate_Setting__mdt mtd = getMetadata();
    List<String> form = new List<String>();
    for (Schema.FieldSetMember field : getCandidateFields(mtd.Candidate__c)) {
      form.add(field.getFieldPath());
    }
    return form;
  }

  @AuraEnabled
  public static List<String> getJobApplicationForm() {
    Create_Candidate_Setting__mdt mtd = getMetadata();
    List<String> form = new List<String>();
    for (
      Schema.FieldSetMember field : getJobApplicationFields(
        mtd.Job_Application__c
      )
    ) {
      form.add(field.getFieldPath());
    }
    return form;
  }

  private static List<Schema.FieldSetMember> getJobApplicationFields(
    String fieldSetName
  ) {
    Schema.DescribeSObjectResult jobApplicationDescribe = Job_Application__c.SObjectType.getDescribe();
    Schema.FieldSet jobApplicationFieldSet = jobApplicationDescribe.fieldSets.getMap()
      .get(fieldSetName);
    if (jobApplicationFieldSet != null) {
      return jobApplicationFieldSet.getFields();
    } else {
      return new List<Schema.FieldSetMember>();
    }
  }

  private static List<Schema.FieldSetMember> getCandidateFields(
    String fieldSetName
  ) {
    Schema.DescribeSObjectResult candidateDescribe = Candidate__c.SObjectType.getDescribe();
    Schema.FieldSet candidateFieldSet = candidateDescribe.fieldSets.getMap()
      .get(fieldSetName);
    if (candidateFieldSet != null) {
      return candidateFieldSet.getFields();
    } else {
      return new List<Schema.FieldSetMember>();
    }
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
