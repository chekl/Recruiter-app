@isTest
public with sharing class ReviewTriggerTest {
  @isTest
  static void testUpdateJobApplicationRatingAndReviews() {
    Test.startTest();
    Position__c position = TestDataFactory.createPosition('Test');
    Candidate__c candidate = TestDataFactory.createCandidate('Test');
    insert position;
    insert candidate;
    Id candidateId = [
      SELECT Id
      FROM Candidate__c
      WHERE Last_Name__c = 'Test'
      LIMIT 1
    ]
    .Id;
    Id positionId = [SELECT Id FROM Position__c WHERE Title__c = 'Test' LIMIT 1]
    .Id;
    Job_Application__c jobApplication = TestDataFactory.createJobApplication(
      positionId,
      candidateId
    );
    insert jobApplication;
    Id jobApplicationId = [
      SELECT Id
      FROM Job_Application__c
      WHERE Position__c = :positionId
      LIMIT 1
    ]
    .Id;

    List<Review__c> reviews = new List<Review__c>();
    for (Integer i = 0; i < 2000; i++) {
      Review__c review = TestDataFactory.createReview('Test', jobApplicationId);
      review.Rating__c = Math.mod(i, 2) == 0 ? 10 : 20;
      reviews.add(review);
    }
    insert reviews;

    Review__c reviewToDelete = [
      SELECT Id
      FROM Review__c
      WHERE Rating__c = 10
      LIMIT 1
    ];
    delete reviewToDelete;
    Test.stopTest();

    Job_Application__c updatedJobApplication = [
      SELECT Id, Rating__c, Number_Of_Reviews__c
      FROM Job_Application__c
      WHERE Position__c = :positionId
      LIMIT 1
    ];

    Assert.areEqual(
      1999,
      updatedJobApplication.Number_Of_Reviews__c,
      'The expected number of reviews is 1999, but insted get: ' +
      updatedJobApplication.Number_Of_Reviews__c
    );
    Assert.areEqual(
      15,
      Integer.ValueOf(updatedJobApplication.Rating__c),
      'The expected avg rating is 15, but insted get: ' +
      Integer.ValueOf(updatedJobApplication.Rating__c)
    );
  }
}
