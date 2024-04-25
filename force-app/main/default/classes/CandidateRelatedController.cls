public with sharing class CandidateRelatedController {
  private static List<Schema.FieldSetMember> getCandidateFields() {
    return Schema.SObjectType.Candidate__c.FieldSets.All_Fields.getFields();
  }

  @AuraEnabled(cacheable=true)
  public static List<AggregateResult> selectCountOfRelatedCandidates(
    Id positionId
  ) {
    return [
      SELECT COUNT(Candidate__c)
      FROM Job_Application__c
      WHERE Position__c = :positionId
    ];
  }

  @AuraEnabled(cacheable=true)
  public static List<Job_Application__c> selectCandidatesRelatedToPosition(
    Id positionId,
    Integer pageSize,
    Integer pageOffset
  ) {
    return [
      SELECT
        Candidate__c,
        Candidate__r.Name,
        Candidate__r.First_Name__c,
        Candidate__r.Last_Name__c,
        Candidate__r.Email__c
      FROM Job_Application__c
      WHERE Position__c = :positionId
      LIMIT :pageSize
      OFFSET :pageOffset
    ];
  }

  @AuraEnabled(cacheable=true)
  public static Job_Application__c selectJobApplicationRelatedToCandidate(
    Id candidateId,
    Id positionId
  ) {
    return [
      SELECT Id, Status__c, Avg_Rating__c
      FROM Job_Application__c
      WHERE Candidate__c = :candidateId AND Position__c = :positionId
      LIMIT 1
    ];
  }

  @AuraEnabled(cacheable=true)
  public static Candidate__c selectCandidateById(Id candidateId) {
    String query = 'SELECT ';
    for (
      Schema.FieldSetMember field : CandidateRelatedController.getCandidateFields()
    ) {
      query += field.getFieldPath() + ', ';
    }
    query += 'Id FROM Candidate__c WHERE Id =:candidateId LIMIT 1';
    return Database.query(query);
  }
}
