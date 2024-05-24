@RestResource(UrlMapping='/JobApplication/*')
global with sharing class JobApplicationREST {
  @HttpGet
  global static void getJobApplicationDetails() {
    try {
      Id id = Id.valueOf(RestContext.request.params.get('id'));
      validateJobApplicationId(id);

      List<Job_Application__c> jobApplication = Database.query(
        'SELECT ' +
          CandidateRelatedController.generateFieldsForQueryByFieldSet(
            CandidateRelatedController.getJobApplicationFields(
              'Details_Job_Application'
            )
          ) +
          ' FROM Job_Application__c WHERE Id =: id LIMIT 1'
      );

      validateListSize(jobApplication);
      RestHelpers.setSuccessResponse(jobApplication.get(0), 200);
    } catch (Exception e) {
      RestHelpers.setExceptionResponse(e);
    }
  }

  @HttpPost
  global static void createJobApplication() {
    try {
      RestRequest req = RestContext.request;
      Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(
        req.requestBody.toString()
      );

      Job_Application__c newJobApplication = new Job_Application__c();

      validateFieldNamesJobApplication(params.keySet());

      for (String fieldName : params.keySet()) {
        if (newJobApplication.get(fieldName) == null) {
          newJobApplication.put(fieldName, params.get(fieldName));
        }
      }

      insert newJobApplication;

      RestHelpers.setSuccessResponse(newJobApplication, 200);
    } catch (Exception e) {
      RestHelpers.setExceptionResponse(e);
    }
  }

  @HttpPatch
  global static void updateJobApplication() {
    try {
      RestRequest req = RestContext.request;
      Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(
        req.requestBody.toString()
      );
      Id jobApplicationId = (Id) params.get('id');
      validateJobApplicationId(jobApplicationId);

      List<Job_Application__c> jobApplicationToUpdate = [
        SELECT Id
        FROM Job_Application__c
        WHERE Id = :jobApplicationId
        LIMIT 1
      ];

      validateListSize(jobApplicationToUpdate);
      validateFieldNamesJobApplication(params.keySet());
      for (String fieldName : params.keySet()) {
        jobApplicationToUpdate.get(0).put(fieldName, params.get(fieldName));
      }

      update jobApplicationToUpdate;

      RestHelpers.setSuccessResponse(jobApplicationToUpdate.get(0), 200);
    } catch (Exception e) {
      RestHelpers.setExceptionResponse(e);
    }
  }

  @HttpDelete
  global static void deleteJobApplication() {
    try {
      Id id = Id.valueOf(RestContext.request.params.get('id'));
      validateJobApplicationId(id);
      List<Job_Application__c> jobApplication = [
        SELECT Id
        FROM Job_Application__c
        WHERE Id = :id
        LIMIT 1
      ];

      validateListSize(jobApplication);

      delete jobApplication;
      RestHelpers.setSuccessResponse(jobApplication, 200);
    } catch (Exception e) {
      RestHelpers.setExceptionResponse(e);
    }
  }

  private static void validateJobApplicationId(Id id) {
    if (
      String.isBlank(id) ||
      id.getSObjectType() != Job_Application__c.SObjectType
    ) {
      throw new CustomException(System.Label.Invalid_Id_Error);
    }
  }

  private static void validateListSize(List<Object> objectList) {
    if (objectList.isEmpty()) {
      throw new CustomException(System.Label.Unexisting_Record_Error);
    }
  }

  private static void validateFieldNamesJobApplication(Set<String> fieldNames) {
    Map<String, Schema.SObjectField> jobApplicationFields = Job_Application__c.SObjectType.getDescribe()
      .fields.getMap();

    for (String fieldName : fieldNames) {
      if (!jobApplicationFields.containsKey(fieldName)) {
        throw new CustomException(
          'Invalid field for Job Application object: ' + fieldName
        );
      }
    }
  }
}
