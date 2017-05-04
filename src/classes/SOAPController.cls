public with sharing class SOAPController {
    
    String strEndPoint = 'https://rev-int.api.us.fleetmatics.com/Vehicle/SageQuest/VehicleService.svc';
    String soapNS = 'https://rev-int.api.us.fleetmatics.com/Vehicle/SageQuest/VehicleService.svc?wsdl'; 
    String xsd = 'http://rev-int.api.us.fleetmatics.com/Vehicle/SageQuest/VehicleService.svc?xsd=xsd0'; 
    String xsi = 'http://www.w3.org/2001/XMLSchema-instance'; //MAKE SURE TO USE CORRECT ONE HERE
    
    public SOAPController(){
        sendSOAPRequest();
    }
    
    private void sendSOAPRequest(){
    Long randomLong = Crypto.getRandomLong();
    String nonce = EncodingUtil.base64Encode(Blob.valueOf(String.valueOf(randomLong)));
        String soapBody = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:veh="http://wcf.sage-quest.com/v1.0/Services/VehicleService"> '+
               '<soapenv:Header>'+
                  '<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+
                     '<wsse:UsernameToken wsu:Id="UsernameToken-AEE30D5DAE343BD1AD14460582643606">'+
                        '<wsse:Username>wcf@psixbox.com</wsse:Username>'+
                        '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">cN3X06usbFDa</wsse:Password>'+
                        '<wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">'+nonce+'</wsse:Nonce>'+
                        '<wsu:Created>2015-10-28T18:51:04.360Z</wsu:Created>'+
                     '</wsse:UsernameToken>'+
                     //'<wsu:Timestamp wsu:Id="TS-AEE30D5DAE343BD1AD14460582610705">'+
                     //   '<wsu:Created>2015-10-28T18:51:01.070Z</wsu:Created>'+
                     //   '<wsu:Expires>2015-10-28T18:52:01.070Z</wsu:Expires>'+
                     //'</wsu:Timestamp>'+
                  '</wsse:Security>'+
               '</soapenv:Header>'+
               '<soapenv:Body>'+
                  '<veh:GetAllVehiclesRequest/>'+
               '</soapenv:Body>'+
            '</soapenv:Envelope>';
        Http objHttp = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type','text/xml;charset=UTF-8');
        request.setHeader('SOAPAction', 'http://wcf.sage-quest.com/v1.0/Services/VehicleService/IVehicleService/GetAllVehicles');
        request.setTimeout(120000);
        request.setBody(soapBody);
        request.setMethod('POST');
        request.setEndpoint(strEndPoint);
        
        HttpResponse response = new HttpResponse();
        response = objHttp.send(request);
        
        system.assert(false, response.getBody());
    }
    
    
    /*
    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:veh="http://wcf.sage-quest.com/v1.0/Services/VehicleService">
   <soapenv:Header>
      <wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
         <wsse:UsernameToken wsu:Id="UsernameToken-AEE30D5DAE343BD1AD14460582643606">
            <wsse:Username>wcf@psixbox.com</wsse:Username>
            <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">cN3X06usbFDa</wsse:Password>
            <wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">5J3s5xT9CYNE0ypJajtjOA==</wsse:Nonce>
            <wsu:Created>2015-10-28T18:51:04.360Z</wsu:Created>
         </wsse:UsernameToken>
         <wsu:Timestamp wsu:Id="TS-AEE30D5DAE343BD1AD14460582610705">
            <wsu:Created>2015-10-28T18:51:01.070Z</wsu:Created>
            <wsu:Expires>2015-10-28T18:52:01.070Z</wsu:Expires>
         </wsu:Timestamp>
      </wsse:Security>
   </soapenv:Header>
   <soapenv:Body>
      <veh:GetAllVehiclesRequest/>
   </soapenv:Body>
</soapenv:Envelope>
    */
    
    /*
    
        HTTP h = new HTTP();
HTTPRequest req = new HTTPRequest();
req.setMethod('POST');
req.setHeader('Content-Type', 'text/xml');
req.setHeader('SOAPAction', 'create');

String b = '<?xml version="1.0" encoding="UTF-8"?>';
b += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
b += '<soapenv:Header>';
b += '<ns1:SessionHeader soapenv:mustUnderstand="0" xmlns:ns1="http://soap.sforce.com/2006/04/metadata">';
b += '<ns1:sessionId>' + UserInfo.getSessionId() + '</ns1:sessionId>';
b += '</ns1:SessionHeader>';
b += '</soapenv:Header>';
b += '<soapenv:Body>';
b += '<create xmlns="http://soap.sforce.com/2006/04/metadata">';
b += '<metadata xsi:type="ns2:CustomObject" xmlns:ns2="http://soap.sforce.com/2006/04/metadata">';
b += '<fullName>sample__c</fullName>';
b += '<deploymentStatus>Deployed</deploymentStatus>';
b += '<description>created by the Metadata API</description>';
b += '<enableActivities>true</enableActivities>';
b += '<label>sample Object</label>';
b += '<nameField>';
b += '<displayFormat>AN-{0000}</displayFormat>';
b += '<label>sample__c Name</label>';
b += '<type>AutoNumber</type>';
b += '</nameField>';
b += '<pluralLabel>sample Objects</pluralLabel>';
b += '<sharingModel>ReadWrite</sharingModel>';
b += '</metadata>';
b += '</create>';
b += '</soapenv:Body>';
b += '</soapenv:Envelope>';

req.setBody(b);
req.setCompressed(false);
req.setEndpoint('https://c.ap1.visual.force.com/services/Soap/m/25.0');
HTTPResponse resp = h.send(req);
System.debug(resp.getBody());
    
    */

}