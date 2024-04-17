@isTest
private class RecordManagerTest {
  @TestSetup
  static void makeData() {
    Id profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = 'Recruiter'
      LIMIT 1
    ]
    .Id;
    User testUser = TestDataFactory.createUser(profileId, 1);
    insert testUser;
    User testRecruiter = [
      SELECT Id
      FROM User
      WHERE ProfileId = :profileId AND IsActive = TRUE
      LIMIT 1
    ];

    System.runAs(testRecruiter) {
      List<SObject> objs = new List<SObject>();
      for (Integer i = 0; i < 4; i++) {
        objs.add(TestDataFactory.createPosition('Developer Title'));
        objs.add(TestDataFactory.createCandidate('Last Name developer'));
      }
      insert objs;

      Id positionId = [SELECT Id FROM Position__c LIMIT 1].Id;
      Id candidateId = [SELECT Id FROM Candidate__c LIMIT 1].Id;
      Job_Application__c jobApplication = TestDataFactory.createJobApplication(
        positionId,
        candidateId
      );
      insert jobApplication;

      Id jobApplicationId = [SELECT Id FROM Job_Application__c LIMIT 1].Id;
      List<Review__c> reviews = new List<Review__c>();
      for (Integer i = 0; i < 4; i++) {
        reviews.add(
          TestDataFactory.createReview('develop FeedBack', jobApplicationId)
        );
      }
      insert reviews;
    }
  }

  @isTest
  static void testSelectJobApplicationsWithReviewsCreatedLastWeek() {
    List<Job_Application__c> jobApplications = RecordManager.selectJobApplicationsWithReviewsCreatedLastWeek();
    Assert.areEqual(
      1,
      jobApplications.size(),
      'The expected size of list is 1, but instead get: ' +
      jobApplications.size()
    );
  }

  @isTest
  static void testGetOldDevelopRecords() {
    List<Id> objIds = new List<Id>();
    for (Position__c pos : [SELECT Id FROM Position__c]) {
      objIds.add(pos.Id);
    }
    for (Candidate__c candidate : [SELECT Id FROM Candidate__c]) {
      objIds.add(candidate.Id);
    }
    for (Review__c review : [SELECT Id FROM Review__c]) {
      objIds.add(review.Id);
    }
    for (Id objId : objIds) {
      Test.setCreatedDate(objId, Date.today().addDays(-100));
    }

    Test.startTest();
    Test.setFixedSearchResults(objIds);
    List<List<SObject>> result = RecordManager.selectOldRecordsWithKeyword(
      'develop'
    );
    Test.stopTest();

    Assert.areNotEqual(
      true,
      result == null || result.isEmpty(),
      'Result cannot be empty!'
    );

    for (List<SObject> sub : result) {
      Assert.areEqual(
        4,
        sub.size(),
        'The expected size of list is 4, but instead get: ' + sub.size()
      );
    }
  }
}
