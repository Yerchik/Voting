/**
 * class for mocking response for LocationUtil_Queueble using HttpCalloutMock interface
 */ 
@isTest
global class LocationUtil_QueuebleMock implements HttpCalloutMock{
    private final String END_POINT = 'https://api.opencagedata.com/geocode/v1/json?q=Rua+Cafel%C3%A2ndia%2CCarapicu%C3%ADba%2C6321%2CBrasil&key=456e2e6a408d47379c3e6e03c57d92df'; 
    // Implement this interface method
	global HTTPresponse respond(HTTPrequest request) {
        System.assertEquals(END_POINT, request.getEndpoint());
        System.assertEquals('GET', request.getMethod());
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        StaticResource staticResource = [SELECT body FROM staticresource WHERE name = 'JSON_TestForLocationIntegration'];
        response.setBody(staticResource.body.toString());
        response.setStatusCode(200);
        return response; 
    }
}