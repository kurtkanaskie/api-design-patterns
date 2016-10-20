Internal-Directory
==================

#Exco's internal Active Directory API.

Apiproxy can be fetched using:
<br/>
`apigeetool fetchproxy -L http://{MANAGMENT-SERVER}:8080 -u "username" -p 'password' -o exco -n internal-directory -r 4 -f internal-directory.zip `

<br/>
Apiproxy can be deployed from the directory where the apiproxy directory exists, using:
<br/>
`apigeetool deployproxy -L http://{MANAGEMENT-SERVER}:8080 -u "username" -p 'password' -V -d . -n internal-directory -o exco -b /v1/internalDirectory -i`

#Creating Static Documentation using API Blueprint and aglio

## Show in browser and allow dynamic editing
aglio -t flatly -i internal-directory.apib -s

## Generate final result
aglio -t flatly -i internal-directory.apib -o internal-directory.html

#Testing

##Mocha
Just run "mocha" from the top level directory, it will run "test.js" in the "test" directory.

##Apigee's APIB

Internal-Directory tests for Spike Arrest.

Download Apigee "apib" tool from Apigee Github.

Example Usage:
	``apib -c 100 -d 60 http://test.example.com``

	The command above will hit "test.example.com" as fast as it can for up to 60 seconds using 100 concurrent network connections.

Internal Directory Specific Usage:
	``apib -v -c 50 -d 5 https://iapitest-dev.exco.com/v1/internalDirectory/status``

	Obsvere the results looking for a Fault for Spike arrest

