@RestResource(UrlMapping='/JobApplication/*')
global with sharing class JobApplicationEndpoint {
  @HttpGet
  global static void getJobApplicationDetails() {
    try {
      String id = RestContext.request.params.get('id');
      if (id == null || id.length() != 18) {
        throw new JSONException('Valid id must be specified');
      }
      try {
        Job_Application__c jobApplication = Database.query(
          'SELECT ' +
            CandidateRelatedController.generateFieldsForQueryByFieldSet(
              CandidateRelatedController.getJobApplicationFields(
                'Details_Job_Application'
              )
            ) +
            ' FROM Job_Application__c WHERE Id =: id LIMIT 1'
        );
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(
          JSON.serialize(jobApplication)
        );
        RestContext.response.statusCode = 200;
      } catch (QueryException e) {
        throw new QueryException('This record does not exist');
      }
    } catch (Exception e) {
      setExceptionResponse(e);
    }
  }

  @HttpPost
  global static void createJobApplication() {
    try {
      RestRequest req = RestContext.request;
      Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(
        RestContext.request.requestBody.toString()
      );

      Job_Application__c newJobApplication = new Job_Application__c();

      for (String fieldName : params.keySet()) {
        if (newJobApplication.get(fieldName) == null) {
          newJobApplication.put(fieldName, params.get(fieldName));
        }
      }

      insert newJobApplication;

      RestContext.response.addHeader('Content-Type', 'application/json');
      RestContext.response.responseBody = Blob.valueOf(
        JSON.serialize(newJobApplication)
      );
      RestContext.response.statusCode = 200;
    } catch (Exception e) {
      setExceptionResponse(e);
    }
  }

  @HttpPatch
  global static void updateJobApplication() {
    try {
      RestRequest req = RestContext.request;
      Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(
        RestContext.request.requestBody.toString()
      );
      Id jobApplicationId = (Id) params.get('id');

      if (jobApplicationId == null) {
        throw new JSONException('id must be specified');
      }

      Job_Application__c jobApplicationToUpdate = new Job_Application__c();
      try {
        jobApplicationToUpdate = [
          SELECT Id
          FROM Job_Application__c
          WHERE Id = :jobApplicationId
          LIMIT 1
        ];
      } catch (QueryException e) {
        throw new QueryException('This record does not exist');
      }

      for (String fieldName : params.keySet()) {
        jobApplicationToUpdate.put(fieldName, params.get(fieldName));
      }

      update jobApplicationToUpdate;

      RestContext.response.addHeader('Content-Type', 'application/json');
      RestContext.response.responseBody = Blob.valueOf(
        JSON.serialize(jobApplicationToUpdate)
      );
      RestContext.response.statusCode = 200;
    } catch (Exception e) {
      setExceptionResponse(e);
    }
  }

  @HttpDelete
  global static void deleteJobApplication() {
    try {
      String id = RestContext.request.params.get('id');
      if (id == null || id.length() != 18) {
        throw new JSONException('Valid id must be specified');
      }
      try {
        Job_Application__c jobApplication = [
          SELECT Id
          FROM Job_Application__c
          WHERE Id = :id
          LIMIT 1
        ];
        delete jobApplication;
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(
          '{ "message" : "Record was deleted"}'
        );
        RestContext.response.statusCode = 200;
      } catch (QueryException e) {
        throw new QueryException('This record does not exist');
      }
    } catch (Exception e) {
      setExceptionResponse(e);
    }
  }

  private static void setExceptionResponse(Exception e) {
    RestContext.response.responseBody = Blob.valueOf(
      '{ "message" : "' + e + '"}'
    );
    RestContext.response.statusCode = 500;
  }
}
