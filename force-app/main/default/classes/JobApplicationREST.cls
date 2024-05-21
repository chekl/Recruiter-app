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
      setSuccessResponse(jobApplication.get(0), 200);
    } catch (Exception e) {
      setExceptionResponse(e);
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

      setSuccessResponse(newJobApplication, 200);
    } catch (Exception e) {
      setExceptionResponse(e);
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

      setSuccessResponse(jobApplicationToUpdate.get(0), 200);
    } catch (Exception e) {
      setExceptionResponse(e);
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
      setSuccessResponse(jobApplication, 200);
    } catch (Exception e) {
      setExceptionResponse(e);
    }
  }

  private static void setExceptionResponse(Exception e) {
    Map<String, String> responseMap = new Map<String, String>{
      'message' => e.getMessage()
    };
    RestContext.response.responseBody = Blob.valueOf(
      JSON.serialize(responseMap)
    );
    RestContext.response.statusCode = 400;
  }

  private static void setSuccessResponse(
    Object responseBody,
    Integer statusCode
  ) {
    RestContext.response.addHeader('Content-Type', 'application/json');
    RestContext.response.responseBody = Blob.valueOf(
      JSON.serialize(responseBody)
    );
    RestContext.response.statusCode = statusCode;
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

    List<String> invalidFieldNames = new List<String>();

    for (String fieldName : fieldNames) {
      if (!jobApplicationFields.containsKey(fieldName)) {
        invalidFieldNames.add(fieldName);
      }
    }

    if (!invalidFieldNames.isEmpty()) {
      throw new CustomException(
        'Invalid field(s) for Job Application object: ' +
        String.join(invalidFieldNames, ', ')
      );
    }
  }
}
