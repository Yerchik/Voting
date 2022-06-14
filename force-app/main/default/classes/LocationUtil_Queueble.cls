/**
 * contains methods with Location for Campaing object
 */ 
public with sharing class LocationUtil_Queueble implements Queueable, Database.AllowsCallouts{
    // key to OpenCage Geocoding API
    private final String KEY = [SELECT KEY__c FROM OpenCage_Setting__mdt LIMIT 1].KEY__c;
    // list of locations
    private List<Location_for_Campaing__c> locations = new List<Location_for_Campaing__c>();
    /**
     * @description constructor 
     * @param  locationsToUpdate - list of updated locations related to Location for Campaing object
     */ 
    public LocationUtil_Queueble(List<Location_for_Campaing__c> locationsToUpdate) {
        this.locations = locationsToUpdate; 
    }
    /**
     * @description constructor 
     */ 
    public LocationUtil_Queueble() {
    }
    /**
     * @description update locations
     * @param  context
     */
    public void execute(QueueableContext context){
        List<Location_for_Campaing__c> locationsToUpdate = new List<Location_for_Campaing__c>();
        for (Location_for_Campaing__c location : locations) {
            Location_for_Campaing__c locationToUpdate = addCoordinate(location.clone(true, false, false, false));
            locationsToUpdate.add(locationToUpdate);
        }
        try {
            update locationsToUpdate; 
        } catch (Exception e) {
            System.enqueueJob(new ExceptionUtility(e));
        }   
    }
    /**
     * @description update fields Latitude and Longitude in Location for Campaing object
     * @param  location location that need to be updated
     * @return updated location 
     */
    public Location_for_Campaing__c addCoordinate(Location_for_Campaing__c location){
        String encodedAddress = EncodingUtil.urlEncode(locationAddress(location), 'UTF-8');
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.opencagedata.com/geocode/v1/json?q=' + encodedAddress + '&key=' + KEY);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200){
            location.Latitude__c = getCoordinateFromJSON((Map<String, Object>) JSON.deserializeUntyped(response.getBody()), 'lat');
            location.Longitude__c = getCoordinateFromJSON((Map<String, Object>) JSON.deserializeUntyped(response.getBody()), 'lng'); 
        }
        return location;
    }
    /**
     * @description return adress to updatedLocation method
     * @param location adress of that location returned 
     * @return string format of adress  
     */
    public String locationAddress(Location_for_Campaing__c location){
        String address = '';
        if (location.Street__c!=null) {
            address += location.Street__c + ',';
        }       
        if (location.State__c!=null) {
            address += location.State__c + ',';
        }        
        if (location.City__c!=null) {
        	address += location.City__c + ',';
        }  
        if (location.Zip__c!=null) {
            address += location.Zip__c + ',';
        }
        if (location.Country__c!=null) {
            address += location.Country__c ;
        }
        return address;
    }
    /**
     * @description return coordinate of location
     * @param locaJSONResulttion location in JSON format 
     * @param typeOfCoordinate type of coordinate
     * @return coordinate  
     */
    public Double getCoordinateFromJSON(Map<String, Object> JSONResult, String CoordinateType){
        List<Object> results = (List<Object>) JSONResult.get('results');
        Map<String, Object> allMap = (Map<String, Object>)results[0];
        Map<String, Object> geometry = (Map<String, Object>) allMap.get('geometry');        
        return (Double)geometry.get(CoordinateType);
    }
    /**
     * @description checks for changes of updated locations
     * @param oldLocations locations before update
     * @param newLocations updated locations
     * @return list of updated locations 
     */
    public List<Location_for_Campaing__c> locationToUpdate(List<Location_for_Campaing__c> oldLocations, List<Location_for_Campaing__c> newLocations){
        List<Location_for_Campaing__c> locationsToUpdate = new List<Location_for_Campaing__c>();
        Map<Id,Location_for_Campaing__c> oldLocationsMap = new Map<Id,Location_for_Campaing__c>(oldLocations);
        Map<Id,Location_for_Campaing__c> newLocationsMap = new Map<Id,Location_for_Campaing__c>(newLocations);
        List<Location_Platform_Event__e> locationsEvent = new List<Location_Platform_Event__e>();
        for (Id id : newLocationsMap.keySet()) {
            if (oldLocationsMap.get(id).City__c != newLocationsMap.get(id).City__c  ||
                oldLocationsMap.get(id).Country__c != newLocationsMap.get(id).Country__c || 
                oldLocationsMap.get(id).State__c != newLocationsMap.get(id).State__c || 
                oldLocationsMap.get(id).Street__c != newLocationsMap.get(id).Street__c ||
                oldLocationsMap.get(id).Zip__c != newLocationsMap.get(id).Zip__c) {
                locationsToUpdate.add(newLocationsMap.get(id));
                locationsEvent.add(new Location_Platform_Event__e(Record_Id__c = id));

            }   
        }
        if (locationsEvent.size() > 0) {
            System.debug('111111' + locationsEvent);
            EventBus.publish(locationsEvent);
            
        }
        return locationsToUpdate;
    }
}