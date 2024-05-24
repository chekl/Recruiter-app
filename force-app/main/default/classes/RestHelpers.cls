public with sharing class RestHelpers {
  public static void setExceptionResponse(Exception e) {
    Map<String, String> responseMap = new Map<String, String>{
      'message' => e.getMessage()
    };
    RestContext.response.responseBody = Blob.valueOf(
      JSON.serialize(responseMap)
    );
    RestContext.response.statusCode = 400;
  }

  public static void setSuccessResponse(
    Object responseBody,
    Integer statusCode
  ) {
    RestContext.response.addHeader('Content-Type', 'application/json');
    RestContext.response.responseBody = Blob.valueOf(
      JSON.serialize(responseBody)
    );
    RestContext.response.statusCode = statusCode;
  }
}
