@isTest
private class RecordManagerTest {
  @isTest
  static void testGetRecentRecruiterJAAndRelated() {
    Test.startTest();
    TestRecordsFactory.insertUser('Recruiter');

    id profileId = [SELECT Id FROM Profile WHERE Name = 'Recruiter' LIMIT 1].Id;
    User testRecruiter = [SELECT Id FROM User WHERE ProfileId = :profileId AND IsActive = true LIMIT 1];
    
    System.runAs(testRecruiter) {
        TestRecordsFactory.insertReviews(5, '');
    }
    
    Test.stopTest();

    List<Job_Application__c> ja = RecordManager.getRecentRecruiterJAAndRelated();
    System.assertEquals(
      ja.size(), 5,
      'Test getRecentRecruiterJAAndRelated not success'
    );
  }

  @isTest
  static void testGetOldDevelopRecords() {
    TestRecordsFactory.insertReviews(5, 'develop');
 
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
        Test.setCreatedDate(objId, Date.today().addDays(-10));
    }

    Test.startTest();
    Test.setFixedSearchResults(objIds);
    List<List<SObject>> result = RecordManager.getOldRecordsWithKeyword('develop');

    Test.stopTest();

    for (List<SObject> sub : result) {
      System.assertEquals(
        5,
        sub.size(),
        'The size of the list is not 5'
      );
    }
  }

  
}
