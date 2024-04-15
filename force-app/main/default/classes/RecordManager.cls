public with sharing class RecordManager {
  private static final String RECRUITER = 'Recruiter';

  public static List<Job_Application__c> selectJobApplicationsWithReviewsCreatedLastWeek() {
    return [
      SELECT Id, Candidate__c, Position__c, (SELECT Id FROM Reviews__r)
      FROM Job_Application__c
      WHERE CreatedDate >= LAST_WEEK AND CreatedBy.Profile.Name = :RECRUITER
    ];
  }

  public static List<List<SObject>> selectOldRecordsWithKeyword(
    String keyword
  ) {
    return [
      FIND :keyword
      IN ALL FIELDS
      RETURNING
        Position__c(Id WHERE CreatedDate < LAST_WEEK),
        Candidate__c(Id WHERE CreatedDate < LAST_WEEK),
        Review__c(Id WHERE CreatedDate < LAST_WEEK)
    ];
  }
}
