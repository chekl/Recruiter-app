public with sharing class ReviewTriggerHandler {
  public static List<Review__c> getReviewsWithChangedRating(
    Map<Id, Review__c> reviewsNewMap,
    Map<Id, Review__c> reviewsOldMap
  ) {
    List<Review__c> changedReviews = new List<Review__c>();
    for (Id reviewId : reviewsNewMap.keySet()) {
      Review__c newPosition = reviewsOldMap.get(reviewId);
      if (
        reviewsNewMap.get(reviewId).Rating__c !=
        reviewsOldMap.get(reviewId).Rating__c
      ) {
        changedReviews.add(newPosition);
      }
    }
    return changedReviews;
  }

  private static Integer createNewNumberOfReviews(
    Integer currentNumberOfReviews,
    Boolean isDeleted
  ) {
    if (currentNumberOfReviews == null) {
      currentNumberOfReviews = 0;
    }
    if (!isDeleted) {
      currentNumberOfReviews += 1;
    } else {
      currentNumberOfReviews -= 1;
    }
    return currentNumberOfReviews;
  }

  private static Decimal createNewFullRating(
    Decimal currentRating,
    Decimal relatedRating,
    Boolean isDeleted
  ) {
    if (currentRating == null) {
      currentRating = 0;
    }
    if (relatedRating != null) {
      if (isDeleted) {
        currentRating -= relatedRating;
      } else {
        currentRating += relatedRating;
      }
    }
    return currentRating;
  }

  private static void calculateJobApplicationReviewStats(
    List<Review__c> reviews,
    Set<Id> jobApplicationIds,
    Map<Id, Decimal> fullRatings,
    Map<Id, Integer> numbersOfReviews,
    Boolean isDeleted
  ) {
    for (Review__c relatedReview : reviews) {
      Id jobApplicationId = relatedReview.Job_Application__c;
      jobApplicationIds.add(jobApplicationId);

      if (relatedReview.Status__c == 'Reviewed') {
        fullRatings.put(
          jobApplicationId,
          createNewFullRating(
            fullRatings.get(jobApplicationId),
            relatedReview.Rating__c,
            isDeleted
          )
        );

        numbersOfReviews.put(
          jobApplicationId,
          createNewNumberOfReviews(
            numbersOfReviews.get(jobApplicationId),
            isDeleted
          )
        );
      } else {
        numbersOfReviews.put(jobApplicationId, 0);
        fullRatings.put(jobApplicationId, 0);
      }
    }
  }

  private static List<Job_Application__c> updateJobApplicationsWithReviewStats(
    Set<Id> jobApplicationIds,
    Map<Id, Decimal> fullRatings,
    Map<Id, Integer> numbersOfReviews
  ) {
    List<Job_Application__c> jobApplications = new List<Job_Application__c>();

    for (Job_Application__c jobApplication : [
      SELECT Id, Number_Of_Reviews__c, Full_Rating__c
      FROM Job_Application__c
      WHERE Id IN :jobApplicationIds
    ]) {
      if (jobApplication.Number_Of_Reviews__c == null) {
        jobApplication.Number_Of_Reviews__c = 0;
      }
      jobApplication.Number_Of_Reviews__c += numbersOfReviews.get(
        jobApplication.Id
      );

      if (jobApplication.Full_Rating__c == null) {
        jobApplication.Full_Rating__c = 0;
      }
      jobApplication.Full_Rating__c += fullRatings.get(jobApplication.Id);

      jobApplications.add(jobApplication);
    }
    return jobApplications;
  }

  public static void updateJobApplicationRatingAndReviews(
    List<Review__c> reviews,
    Boolean isDeleted
  ) {
    Set<Id> jobApplicationIds = new Set<Id>();
    Map<Id, Decimal> fullRatings = new Map<Id, Decimal>();
    Map<Id, Integer> numbersOfReviews = new Map<Id, Integer>();

    calculateJobApplicationReviewStats(
      reviews,
      jobApplicationIds,
      fullRatings,
      numbersOfReviews,
      isDeleted
    );

    List<Job_Application__c> jobApplications = updateJobApplicationsWithReviewStats(
      jobApplicationIds,
      fullRatings,
      numbersOfReviews
    );

    if (!jobApplications.isEmpty()) {
      update jobApplications;
    }
  }
}
