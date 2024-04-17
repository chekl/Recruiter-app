@isTest
public class TestDataFactory {
  public static User createUser(Id profileId, Integer userNum) {
    return new User(
      ProfileId = profileId,
      FirstName = 'Test',
      LastName = 'User',
      Email = 'testchuser@tuser.com',
      Username = 'tuser+chaika+@tuser+.com+' + userNum,
      Alias = 'tuser',
      CommunityNickname = 'testuser',
      TimeZoneSidKey = 'America/Los_Angeles',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      IsActive = true
    );
  }

  public static Position__c createPosition(String title) {
    return new Position__c(
      Title__c = title,
      Open_Date__c = Date.today(),
      Status__c = 'Open',
      Location__c = 'test'
    );
  }

  public static Candidate__c createCandidate(String lastName) {
    return new Candidate__c(
      Email__c = 'test@g.com',
      First_Name__c = 'test',
      Last_Name__c = lastName,
      Location__c = 'test'
    );
  }

  public static Job_Application__c createJobApplication(
    Id positionId,
    Id candidateId
  ) {
    return new Job_Application__c(
      Position__c = positionId,
      Candidate__c = candidateId,
      Status__c = 'Need review'
    );
  }

  public static Review__c createReview(String feedBack, Id jobApplicationId) {
    return new Review__c(
      Job_Application__c = jobApplicationId,
      Status__c = 'Need review',
      Feedback__c = feedBack
    );
  }
}
