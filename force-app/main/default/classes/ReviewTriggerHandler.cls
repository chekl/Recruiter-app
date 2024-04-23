public with sharing class ReviewTriggerHandler {
  public static List<Review__c> getReviewsWithChangedRating(Map<Id, Review__c> reviewsNewMap, Map<Id, Review__c> reviewsOldMap) {
    List<Review__c> changedReviews = new List<Review__c>();
    for(Id reviewId : reviewsNewMap.keySet()) {
      Review__c newPosition = reviewsOldMap.get(reviewId);
      if(reviewsNewMap.get(reviewId).Rating__c != reviewsOldMap.get(reviewId).Rating__c) {
        changedReviews.add(newPosition);
      }
    }
    return changedReviews;
  }
  
  public static void updateJobApplicationRatingAndReviews(
    List<Review__c> reviews,
    Boolean isDeleted
  ) {
    Set<Id> jobApplicationIds = new Set<Id>();
    Map<Id, Decimal> fullRatings = new Map<Id, Decimal>();
    Map<Id, Integer> numbersOfReviews = new Map<Id, Integer>();

    for (Review__c relatedReview : reviews) {
      Id jobApplicationId = relatedReview.Job_Application__c;
      jobApplicationIds.add(jobApplicationId);

      if(relatedReview.Status__c == 'Reviewed') {
        Decimal newFullRating = fullRatings.get(jobApplicationId);
        if (newFullRating == null) {
          newFullRating = 0;
        }
        if (relatedReview.Rating__c != null) {
          if(isDeleted) {
            newFullRating -= relatedReview.Rating__c;
          } else {
            newFullRating += relatedReview.Rating__c;
          }
        }
        fullRatings.put(jobApplicationId, newFullRating);
  
        Integer newNumberOfReviews = numbersOfReviews.get(
          jobApplicationId
        );
        if (newNumberOfReviews == null) {
          newNumberOfReviews = 0;
        }
        if(!isDeleted) {
          newNumberOfReviews += 1;
        } else {
          newNumberOfReviews -= 1;
        } 
        numbersOfReviews.put(
          jobApplicationId,
          newNumberOfReviews
        );  
      } else {
        numbersOfReviews.put(
          jobApplicationId,
          0
        );  
        fullRatings.put(jobApplicationId, 0);
      }
    }

    List<Job_Application__c> jobApplications = new List<Job_Application__c>();

    for (Job_Application__c jobApplication : [
      SELECT Id, Number_Of_Reviews__c, Full_Rating__c
      FROM Job_Application__c
      WHERE Id IN :jobApplicationIds
    ]) {
      if(jobApplication.Number_Of_Reviews__c != null) {
      jobApplication.Number_Of_Reviews__c += numbersOfReviews.get(
        jobApplication.Id
      );        
      } else {
        jobApplication.Number_Of_Reviews__c = numbersOfReviews.get(
          jobApplication.Id
        ); 
      }
      if(jobApplication.Full_Rating__c != null) {
        jobApplication.Full_Rating__c += fullRatings.get(jobApplication.Id);
      } else {
        jobApplication.Full_Rating__c = fullRatings.get(jobApplication.Id);
      }
      

      jobApplications.add(jobApplication);
    }

    if (!jobApplications.isEmpty()) {
      update jobApplications;
    }
  }
}
