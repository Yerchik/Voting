import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
const NAME_FIELD  = 'Location_for_Campaing__c.Name';
const LOCATION_LATITUDE_FIELD = 'Location_for_Campaing__c.Latitude__c';
const LOCATION_LONGITUDE_FIELD = 'Location_for_Campaing__c.Longitude__c';
const LocationFields = [
	NAME_FIELD,
	LOCATION_LATITUDE_FIELD,
	LOCATION_LONGITUDE_FIELD
];
export default class Location extends LightningElement {
    @api recordId;
    name;
    mapMarkers = [];
    @wire(getRecord, { recordId: '$recordId', fields: LocationFields })
    loadCoordinate({ error, data }) {
        if (error) {
        // TODO: handle error
        } else if (data) {
            // Get Location data
            this.name =  getFieldValue(data, NAME_FIELD);
            const Latitude = getFieldValue(data, LOCATION_LATITUDE_FIELD);
            const Longitude = getFieldValue(data, LOCATION_LONGITUDE_FIELD);
            // Transform Location data into map markers
            this.mapMarkers = [{
                location: { Latitude, Longitude },
                title: this.name,
                description: `Coords: ${Latitude}, ${Longitude}`
            }];
        }
    }
    get cardTitle() {
        return (this.name) ? `${this.name}'s location` : 'Location';
    }

}    
    
