trigger Review on Review__c(after insert, after update, after delete, after undelete) {
  if (Trigger.isAfter) {
    if (Trigger.isInsert || Trigger.isUndelete) {
      ReviewTriggerHandler.updateJobApplicationRatingAndReviews(Trigger.new, false);
    }
    if(Trigger.isUpdate) {
       List<Review__c> reviews = ReviewTriggerHandler.getReviewsWithChangedRating(Trigger.newMap, Trigger.oldMap);
      if(!reviews.isEmpty()) { 
        ReviewTriggerHandler.updateJobApplicationRatingAndReviews(Trigger.new, false);
      }
    }
    if (Trigger.isDelete) {
      ReviewTriggerHandler.updateJobApplicationRatingAndReviews(Trigger.old, true);
    }
  }
}
