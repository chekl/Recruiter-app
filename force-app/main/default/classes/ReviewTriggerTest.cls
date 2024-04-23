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
      WHERE Position__c = :positionId AND Candidate__c = :candidateId
      LIMIT 1
    ]
    .Id;

    List<Review__c> reviews = new List<Review__c>();
    for (Integer i = 0; i < 2000; i++) {
      Review__c review = TestDataFactory.createReview('Test', jobApplicationId);
      review.Rating__c = null;
      reviews.add(review);
    }
    insert reviews;

    List<Review__c> reviewsToUpdate = [SELECT Id, Feedback__c FROM Review__c WHERE Job_Application__c = :jobApplicationId AND Rating__c = null];
    Integer halfSize = reviewsToUpdate.size() / 2;
    
    for(Integer i = 0; i < halfSize; i++) {
      reviewsToUpdate.get(i).Status__c = 'Reviewed';
      reviewsToUpdate.get(i).Rating__c = 20; 
    }

    update reviewsToUpdate; 

    List<Review__c> reviewsToDelete = new List<Review__c>{reviewsToUpdate.get(0), reviewsToUpdate.get(1)};
    delete reviewsToDelete;

    List<Review__c> reviewsToUndelete = new List<Review__c>{reviewsToUpdate.get(0)};
    undelete reviewsToUndelete;
    Test.stopTest();

    Job_Application__c updatedJobApplication = [
      SELECT Id, Full_Rating__c, Number_Of_Reviews__c
      FROM Job_Application__c
      WHERE Position__c = :positionId AND Candidate__c = :candidateId
      LIMIT 1
    ];

    Integer expectedNumberOfReviews = halfSize - 1;
    Integer expectedFullRating = 20000 - 20;

    Assert.areEqual(
      expectedNumberOfReviews,
      updatedJobApplication.Number_Of_Reviews__c,
      'The expected number of reviews is ' + expectedNumberOfReviews + ', but insted get: ' +
      updatedJobApplication.Number_Of_Reviews__c
    );
    Assert.areEqual(
      expectedFullRating,
      updatedJobApplication.Full_Rating__c,
      'The expected full rating is '+ expectedFullRating +', but insted get: ' +
      updatedJobApplication.Full_Rating__c
    );
  }
}
