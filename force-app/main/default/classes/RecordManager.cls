public with sharing class RecordManager {
  public static List<Job_Application__c> getRecentRecruiterJAAndRelated() {
    Date lastWeek = Date.today().addDays(-7);
    return [
      SELECT Id, Candidate__c, Position__c, (SELECT Id FROM Reviews__r)
      FROM Job_Application__c
      WHERE
        CreatedDate >= :lastWeek
        AND CreatedById IN (
          SELECT Id
          FROM User
          WHERE Profile.Name = 'Recruiter'
        )
    ];
  }

  public static List<List<SObject>> getOldRecordsWithKeyword(String keyword) {
    Date lastWeek = Date.today().addDays(-7);
    return [
      FIND :keyword
      IN ALL FIELDS
      RETURNING
        Position__c(Id WHERE CreatedDate < :lastWeek),
        Candidate__c(Id WHERE CreatedDate < :lastWeek),
        Review__c(Id WHERE CreatedDate < :lastWeek)
    ];
  }
}
