# design-pattern-proxy-to-multiple-wsdls

## Proxy to Many WSDLs Design Pattern
An example API proxy to expose RESTful APIs from multiple WSDL backend endpoints.

Some enterprise applications, such as SAP, use a micro-services or singular approach to WSDL designs where there is a single WSDL with a single operation. Therefore the proxy will need to use multiple WSDLs to create the right context. The proxy design pattern is one proxy to many WSDLs:

Apigee "SOAP service" proxy[1] <--> WSDL[1..n]

The request to response sequential policy execution flow.

###REQUEST:
####PROXY REQUEST PRE-FLOW:
####PROXY REQUEST CONDITIONAL-FLOW: for each verb and pathsuffix resource endpoint
	* Extract Variables to get RESTful request parameters and body.
	* Assign Message to create the SOAP request
		- Copy and paste an example WSDL request body and add params extracted earlier.
		- Add Authorization for the backend WSDL. If the same "service account" is used for all WSDLs this could be done once in TARGET REQUEST POST-FLOW
		- Change verb to POST, all WSDLs use POST.
		- Add a variable (e.g. am.target.url) to hold the target URL for the backend WSLD associated with this resource, which will be used later.
####PROXY REQUEST POST-FLOW:

####TARGET REQUEST PRE-FLOW:
	* Javascript callout to set the target URL from variable am.target.url and to set target.copy.pathsuffix to false.
####TARGET REQUEST CONDITIONAL-FLOW:
####TARGET REQUEST POST-FLOW:


###RESPONSE:
####TARGET RESPONSE PRE-FLOW:
####TARGET RESPONSE CONDITIONAL-FLOW: if backend response is not OK (2xx)
	* Extract Variables to get the SOAP fault message.
	* Raise Fault with the SOAP fault message.
####TARGET RESPONSE POST-FLOW:

####PROXY RESPONSE PRE-FLOW:
####PROXY RESPONSE CONDITIONAL-FLOW: for each verb and pathsuffix resource endpoint
	* XSL Transform the backend response to the RESTful response.
####PROXY RESPONSE POST-FLOW:
	* XML to JSON conditionally based on request parameters (e.g. request.header.accept != "application/xml")

