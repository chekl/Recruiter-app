public with sharing class ReviewTriggerHandler {
  public static void updateJobApplicationRatingAndReviews(
    List<Review__c> reviews
  ) {
    Set<String> jobApplicationIds = new Set<String>();
    for (Review__c review : reviews) {
      jobApplicationIds.add(review.Job_Application__c);
    }

    Map<Id, Decimal> fullRatings = new Map<Id, Decimal>();
    Map<Id, Integer> numbersOfReviews = new Map<Id, Integer>();

    for (Review__c relatedReview : [
      SELECT Rating__c, Job_Application__c
      FROM Review__c
      WHERE Job_Application__c IN :jobApplicationIds
    ]) {
      Decimal newFullRating = fullRatings.get(relatedReview.Job_Application__c);
      if (newFullRating == null) {
        newFullRating = 0;
      }
      if (relatedReview.Rating__c != null) {
        newFullRating += relatedReview.Rating__c;
      }
      fullRatings.put(relatedReview.Job_Application__c, newFullRating);

      Integer newNumberOfReviews = numbersOfReviews.get(
        relatedReview.Job_Application__c
      );
      if (newNumberOfReviews == null) {
        newNumberOfReviews = 0;
      }
      newNumberOfReviews += 1;
      numbersOfReviews.put(
        relatedReview.Job_Application__c,
        newNumberOfReviews
      );
    }

    List<Job_Application__c> jobApplications = new List<Job_Application__c>();

    for (Job_Application__c jobApplication : [
      SELECT Id, Number_Of_Reviews__c, Rating__c
      FROM Job_Application__c
      WHERE Id IN :jobApplicationIds
    ]) {
      jobApplication.Number_Of_Reviews__c = numbersOfReviews.get(
        jobApplication.Id
      );
      jobApplication.Rating__c =
        fullRatings.get(jobApplication.Id) /
        numbersOfReviews.get(jobApplication.Id);

      jobApplications.add(jobApplication);
    }

    if (!jobApplications.isEmpty()) {
      update jobApplications;
    }
  }
}
