@isTest
public class TestRecordsFactory {
  public static void insertUser(String profileName) {
    id profileId = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1]
    .Id;

    insert new User(
      ProfileId = profileId,
      FirstName = 'Test',
      LastName = 'User',
      Email = 'testchuser@tuser.com',
      Username = 'tuser+chaika+@tuser+.com+',
      Alias = 'tuser',
      CommunityNickname = 'testuser',
      TimeZoneSidKey = 'America/Los_Angeles',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      IsActive = true
    );
  }

  public static void insertPositions(Integer num, String keyWord) {
    List<Position__c> pos = new List<Position__c>();

    for (Integer i = 0; i < num; i++) {
      pos.add(
        new Position__c(
          Title__c = keyWord + i,
          Open_Date__c = Date.today(),
          Status__c = 'Open',
          Location__c = 'test'
        )
      );
    }
      insert pos;
  }

  public static void insertCandidates(Integer num, String keyWord) {
    List<Candidate__c> can = new List<Candidate__c>();

    for (Integer i = 0; i < num; i++) {
      can.add(
        new Candidate__c(
          Email__c = 'test@g.com' + i,
          First_Name__c = 'test' + i,
          Last_Name__c = keyWord + i,
          Location__c = 'test'
        )
      );
    }

    insert can;
  }

  public static void insertJobApplications(Integer num, String keyWord) {
    List<Job_Application__c> ja = new List<Job_Application__c>();

    TestRecordsFactory.insertPositions(num, keyWord);
    TestRecordsFactory.insertCandidates(num, keyWord);

    List<Position__c> posIds = [SELECT Id FROM Position__c];
    List<Candidate__c> canIds = [SELECT Id FROM Candidate__c];

    for (Integer i = 0; i < num; i++) {
      ja.add(
        new Job_Application__c(
          Position__c = posIds[i].Id,
          Candidate__c = canIds[i].Id,
          Status__c = 'Need review'
        )
      );
    }

    insert ja;
  }

  public static void insertReviews(Integer num, String keyWord) {
    List<Review__c> rew = new List<Review__c>();

    TestRecordsFactory.insertJobApplications(num, keyWord);

    List<Job_Application__c> jaId = [SELECT Id FROM Job_Application__c];

    for (Integer i = 0; i < num; i++) {
      rew.add(
        new Review__c(
          Job_Application__c = jaId[i].Id,
          Status__c = 'Need review',
          Feedback__c = keyWord + i
        )
      );
    }

    insert rew;
  }
}
