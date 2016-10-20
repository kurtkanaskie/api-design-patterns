# api-design-patterns
A collection of common API design patterns encountered in large enterprises, implemented as example Apigee API proxies, which can be used as a starting point for a more complete design.

## Node.js Adapter Design Pattern
Often a large enterprise customer will want to connect to "legacy" systems and databases. Although Apigee doesn't support DB connectors directly, Node.js can be used as an adapter layer by combining express with a backend specific module. The general proxy design pattern is:

Apigee "Node.js App" proxy <--> express <--> adapter module <--> backend

The examples in this pattern include:
* LDAP (node-to-ldap)
* mySQL (node-to-mysql) TBD
* MongoDB (node-to-mongodb) TBD
* MS SQL (node-to-mssql) TBD
* Terradata (node-to-terradata) TBD
* Postgres (node-to-postgres) TBD
* Oracle (node-to-oracle) TBD

## Proxy to Many WSDLs Design Pattern

Some enterprise applications, such as SAP, use a micro-services or singular approach to WSDL designs where there is a single WSDL with a single operation. Therefore the proxy will need to use multiple WSDLs to create the right context. The proxy design pattern is one proxy to many WSDLs:

Apigee "SOAP service" proxy[1] <--> WSDL[1..n].

The high level flow for each proxy endpoint resource (proxy-to-multiple-wsdls):

####REQUEST:
* Extract Variables to get RESTful request parameters and body.
* Assign Message to create the SOAP request, change verb, add authorization and set target URL

####RESPONSE:
* if backend response is OK (2xx)
	* Extract Variables to get the SOAP fault message.
	* Raise Fault with the SOAP fault message.
* else
	* XSL Transform the backend response to the RESTful response.
	* XML to JSON conditionally based on request parameters. 
