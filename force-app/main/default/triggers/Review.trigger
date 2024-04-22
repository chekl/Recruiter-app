trigger Review on Review__c(after insert, after update, after delete) {
  if (Trigger.isAfter) {
    if (Trigger.isInsert || Trigger.isUpdate) {
      ReviewTriggerHandler.updateJobApplicationRatingAndReviews(Trigger.new);
    }
    if (Trigger.isDelete) {
      ReviewTriggerHandler.updateJobApplicationRatingAndReviews(Trigger.old);
    }
  }
}
