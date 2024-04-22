@isTest
public with sharing class ReviewTriggerTest {
  @isTest
  static void testUpdateJobApplicationRatingAndReviews() {
    Position__c position = TestDataFactory.createPosition('Test');
    Candidate__c candidate = TestDataFactory.createCandidate('Test');
    Test.startTest();
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
    for (Integer i = 1; i <= 3; i++) {
      Review__c review = TestDataFactory.createReview('Test', jobApplicationId);
      review.Status__c = 'Reviewed';
      review.Rating__c = 10 * i;
      reviews.add(review);
    }
    insert reviews;
    delete reviews[0];
    Test.stopTest();

    Job_Application__c updatedJobApplication = [
      SELECT Id, Rating__c, Number_Of_Reviews__c
      FROM Job_Application__c
      WHERE Position__c = :positionId
      LIMIT 1
    ];

    Assert.areEqual(
      2,
      updatedJobApplication.Number_Of_Reviews__c,
      'The expected number of reviews is 2, but insted get: ' +
      updatedJobApplication.Number_Of_Reviews__c
    );
    Assert.areEqual(
      25,
      updatedJobApplication.Rating__c,
      'The expected avg rating is 25, but insted get: ' +
      updatedJobApplication.Rating__c
    );
  }
}
