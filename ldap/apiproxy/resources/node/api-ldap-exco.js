var application_root = __dirname,
    express = require("express"),
    path = require("path"),
    ldapjs = require('ldapjs');

var app = express();

var ldap_url = "ldaps://ldap.exco.com:636";
var tlsOptions = { 'rejectUnauthorized': false }
var username = "";
var password = "";

// username:password
var unpw=new Buffer('YXBpZ2VlazpBUElzUjBjayE=', 'base64').toString('ascii');
var admin_username=unpw.substr(0,6);
var admin_password=unpw.substr(unpw.indexOf(':')+1);
var admin_dn = "CN=" + admin_username + ",CN=Service,CN=Non-People Accounts,DC=exco,DC=com"

app.configure(function () {
	// app.use(express.bodyParser());
	app.use(express.json());
	app.use(express.urlencoded());

	// app.use(express.methodOverride());
	app.use(app.router);
	app.use(express.static(path.join(application_root, "public")));
	app.use(express.errorHandler({
		dumpExceptions: true,
		showStack: true
	})); 
});

app.get('/status', function (req, res) {
	var body = {
		"status": {
			"code": "OK",
			"message": "Internal Directory API is running."
		}
	}
	res.type('application/json');
	res.send(200, body);
});

// Form URL encoded or JSON data
app.post('/authenticate', function (req, res) {
	username = req.body.username;
	password = req.body.password;
	if ( password == "" ) {
		password = 'foo';
	}
	// console.log('LDAP Node username = "' + username + '" password = "' + password + '"' );
	authenticate(req, res);
});

// search user profiles
app.get('/users', function (req, res) {
	// Need to convert the filter string from Web API terms to LDAP terms e.g. familyName --> sn
	// ?filter='(%26(givenName=kurt)(c=US)(st=PA))'
	// ?filter="sn=kanaskie"
	// familyName=kanaskie --> sn=kanaskie
	var str;
	if( req.query.filter ) {
		str = convertFilter( req.query.filter );
	}
	// console.log('LDAP Node filter = "' + req.query.filter + '" --- converted = "' + str + '"' );
	profile(req, res, str);
});

// user profile
app.get('/users/:username', function (req, res) {
	username = req.params.username;
	var str = 'sAMAccountName=' + username;
	profile(req, res, str);
});

// user profile
/* Approach:
   1. Get just the manager name for username
   2. Extract manager name
   2. Get the profile for manager name
   */
app.get('/users/:username/manager', function (req, res) {
	username = req.params.username;

	getManagerName( username, function( response, error ) {
		if ( error ) {
			console.log('LDAP Node getManagerName ERROR response = ' + JSON.stringify(response));
			res.type('application/json');
			res.send(404, response);
		} else {
			console.log('LDAP Node getManagerName SUCCESS response = ' + JSON.stringify(response));
			var filter = 'CN=' + response.datasets.records[0].managerFullName;
			console.log('LDAP Node getManagerName username = "' + username + '" filter = "' + filter + '"' );
			profile(req, res, filter);
		}
	});
});

function convertFilter( str ) {
	var res = str;
	res = res.replace("familyName=","sn=");
	res = res.replace("ISID=","sAMAccountName=");
	res = res.replace("email=","mail=");
	res = res.replace("country=","co=");
	res = res.replace("countryCode=","c=");
	res = res.replace("state=","st=");
	res = res.replace("mobileNumber=","mobile=");
	res = res.replace("location=","l=");
	res = res.replace("fullName=","name=");
	return res;
}

function convertResponse( from ) {
	var user = {};
	user.metadata = {};
	user.metadata.link = [];

	var link = { "rel":"self", "href":'/users/' + from.sAMAccountName };
	user.metadata.link.push(link);

	user.country = from.co;
	user.countryCode = from.c;
	user.department = from.department;
	user.displayName = from.displayName;
	user.DN = from.dn;
	user.email = from.mail;
	user.employeeID = from.employeeID;
	user.familyName = from.sn;
	user.fullName = from.name;
	user.givenName = from.givenName;
	user.ISID = from.sAMAccountName;
	user.location = from.l;
	// Get the manager "name" from the LDAP representation
	// CN=Lastname\\, Firstname,OU=eCore Office,OU=People Accounts,DC=exco,DC=com
	if ( from.manager ) {
		var str = from.manager;
		if ( str ) {
			user.managerFullName = str.replace('\\','').replace('CN=','').replace(/,OU=.*/,'');
		}
		user.managerDN = from.manager;

		var link = { "rel":"manager", "href":'/users/' + from.sAMAccountName + '/manager' };
		user.metadata.link.push(link);
	}
	// TODO: Not ready for this yet
/*
	if ( from.memberOf ) {
		link = { "rel":"groups", "href":'/users/' + from.sAMAccountName + '/memberOf' };
		user.metadata.link.push(link);
	}

	if ( from.directReports ) {
		link = { "rel":"directReports", "href":'/users/' + from.sAMAccountName + '/directReports' };
		user.metadata.link.push(link);
	}
*/
	user.mobileNumber = from.mobile;
	user.postalCode = from.postalCode;
	user.region = from.region;
	user.state = from.st;
	user.streetAddress = from.streetAddress;
	user.telephoneNumber = from.telephoneNumber;
	user.title = from.title;
	user.userPrincipalName = from.userPrincipalName;
	return user;
}
var optsAttributes = [ 'dn', 'userPrincipalName', 'streetAddress', 'co', 'c', 'department', 'mail', 'displayName', 'name', 'givenName', 'sAMAccountName', 'employeeID', 'sn', 'l', 'manager', 'region', 'st', 'title', 'postalCode', 'telephoneNumber', 'mobile', 'memberOf', 'directReports' ]; 

// Tag AUTHENTICATE
function authenticate(req,res) {
	var client = ldapjs.createClient({
		url: ldap_url,
	    tlsOptions:tlsOptions
	});

	var opts = {
		filter: 'sAMAccountName=' + username,
		scope: 'sub',
		attributes: optsAttributes
	};

	var foundUser = false;
	var body = {};
	body.authentication = {}
	body.authentication.metadata = {};
	body.authentication.metadata.message = "Authenticated";
	body.authentication.user = {};

	client.bind(admin_dn, admin_password, function(err, bind) {
		if (err) {
			console.log('LDAP Node authenticate bind error: ' + err);
			body.authentication.metadata.message = "Authenticate Bind Error";
			body.authentication.metadata.complete = false;
			res.type('application/json');
			res.send(500, body);
		} else {
			client.search('dc=exco,dc=com', opts, function(error, search) {
				if(error){
					res.send("Search Error");
					throw new Error('Search Execution Failed');
				} else {
					// Get here even when no match on username, but no event 
					search.on('searchEntry', function(entry) {
						if(entry.object){
							// Found the user, now try and bind to check the password
							foundUser = true;
							client.bind(entry.object.dn, password, function(err, bind) {
								if (err) {
									// Bad password
									body.authentication.metadata.message = "Invalid password";
									body.authentication.metadata.complete = false;
									res.type('application/json');
									res.send(401, body);
								} else {
									body.authentication.user = convertResponse( entry.object );
									// Happy Path
									body.authentication.metadata.complete = true;
									res.type('application/json');
									res.send(200, body);
								}
							});
						}
					});
					search.on('error', function(err) {
						console.error('error.error: ' + err.message);
					});
					search.on('end', function(result) {
						if( foundUser == false) {
							// Bad username
							body.authentication.metadata.message = "Invalid username";
							body.authentication.metadata.complete = false;
							res.type('application/json');
							res.send(401, body);
						}
					});
				}

			});
		}
	});
}

// Tag PROFILE
function profile(req,res, filterString) {
	var client = ldapjs.createClient({
		url: ldap_url,
	    tlsOptions:tlsOptions
	});

	// console.log('LDAP Node profile req.query.limit=' + req.query.limit);

	var opts = {
		// filter: 'sAMAccountName=' + username,
		filter: filterString,
		sizeLimit: Number(req.query.limit),
		scope: 'sub',
		attributes: optsAttributes
	};

	var body = {};
	body.users = {}
	body.users.metadata = {};
	if ( filterString ) body.users.metadata.filter = filterString;
	body.users.metadata.count = 0;
	body.users.metadata.complete = false;
	body.users.user = [];

	client.bind(admin_dn, admin_password, function(err, bind) {
		if (err) {
			console.log('LDAP Node profile bind error: ' + err);
			body.users.metadata.message = "Profile Bind Error";
			body.users.metadata.complete = false;
			res.type('application/json');
			res.send(500, body);
		} else {
			try {
				client.search('dc=exco,dc=com', opts, function(error, search) {
					if(error){
						res.send("Search Error");
						throw new Error('Search Execution Failed');
					} else if (search) {
						// Get here even when no match on username, but no event
						search.on('searchEntry', function(entry) {
							// console.log('LDAP Node profile event searchEntry: ' + entry);
							if(entry.object){
								// Add another user to the body
								user = convertResponse( entry.object );
								body.users.metadata.count++;
								body.users.user.push(user);
							} else {
								body.users.metadata.message = "Figure out how we get here.";
								body.users.metadata.complete = false;
								res.send(500, body);
							}
						});
						search.on('searchReference', function(referral) {
							console.log('LDAP Node profile event searchReference: ' + referral.uris.join());
						});
						search.on('error', function(err) {
							console.log('LDAP Node profile event error: ' + err);
							console.error('error.error: ' + err.message);

							body.users.metadata.message = err.message;
							body.users.metadata.complete = false;
							res.type('application/json');
							if( body.users.metadata.count == 0 ) {
								res.send(500, body);
							}
							else {
								res.send(206, body);
							}
						});
						search.on('end', function(result) {
							// console.log('LDAP Node profile event end: ' + JSON.stringify(body));
							if( body.users.metadata.count == 0 ) {
								if( req.params.username ) {
									body.users.metadata.message = 'username "' + req.params.username + '" not found';
								}
								else if( req.query.filter ) {
									body.users.metadata.message = 'filter "' + req.query.filter + '" returned no results';
								}
								else {
									body.users.metadata.message = 'No results';
								}
						body.users.metadata.complete = false;
						res.type('application/json');
						res.send(404, body);
						// res.status(404).json({ error: 'Not Found' })
							}
							else {
								// Happy Path
								body.users.metadata.complete = true;
								res.type('application/json');
								res.send(200, body);
							}
						});
					} else {
						console.log('LDAP Node profile not error and not search: ');
					}
				});
			} catch (err) {
				console.log('LDAP Node profile catcher: ' + err );
				res.send(500, { caughtError: String(err) });
			}
		}
	});
}

// Tag getManagerName
function getManagerName(username, callback) {
	var client = ldapjs.createClient({
		url: ldap_url,
	    tlsOptions:tlsOptions
	});

	var managerAttributes = [ 'manager' ]; 

	var opts = {
		filter: 'sAMAccountName=' + username,
		scope: 'sub',
		attributes: managerAttributes
	};

	var body = {
		"datasets" : {
			"metadata" : {
				"count":0,
				"total":0,
				"error":false,
				"complete":false },
			"records":[]
		}
	};

	client.bind(admin_dn, admin_password, function(err, bind) {
		if (err) {
			console.log('LDAP Node getManagerName bind error: ' + err);
			body.datasets.metadata.message = "Profile Bind Error";
			body.datasets.metadata.complete = false;
			body.datasets.metadata.error = true;
			return body;
		} else {
			try {
				client.search('dc=exco,dc=com', opts, function(error, search) {
					if(error){
						console.log("Search Error " + error);
						throw new Error('Search Execution Failed');
					} else if (search) {
						// Get here even when no match on username, but no event
						search.on('searchEntry', function(entry) {
							// console.log('LDAP Node getManagerName event searchEntry: ' + entry);
							if(entry.object){
								// Add another user to the body
								console.log('LDAP Node getManagerName MANAGER: ' + entry.object.manager);
								var str = entry.object.manager;
								str = str.replace('\\','').replace('CN=','').replace(/,OU=.*/,'');

								record = { "managerFullName":str }
								body.datasets.metadata.count++;
								body.datasets.records.push(record);
								console.log('LDAP Node getManagerName MANAGER RECORD: ' + record.managerFullName);
							} else {
								body.datasets.metadata.message = "Figure out how we get here.";
								body.datasets.metadata.complete = false;
								return body;
							}
						});
						search.on('searchReference', function(referral) {
							console.log('LDAP Node getManagerName event searchReference: ' + referral.uris.join());
						});
						search.on('error', function(err) {
							console.log('LDAP Node getManagerName event error: ' + err);
							console.error('error.error: ' + err.message);

							body.datasets.metadata.message = err.message;
							body.datasets.metadata.complete = false;
							return body;
						});
						search.on('end', function(result) {
							// console.log('LDAP Node getManagerName event end: ' + JSON.stringify(body));
							if( body.datasets.metadata.count == 0 ) {
								body.datasets.metadata.message = 'No results';
								body.datasets.metadata.error = true;
								body.datasets.metadata.complete = false;
								callback(body, 'No Results');
							}
							else {
								// Happy Path
								body.datasets.metadata.complete = true;
								callback(body);
							}
						});
					} else {
						console.log('LDAP Node getManagerName not error and not search: ');
					}
				});
			} catch (err) {
				console.log('LDAP Node getManagerName catcher: ' + err );
			}
		}
	});
}

app.listen(4242, function() {
	console.log('LDAP Node api-ldap-exco server listening 4242 - use: http://localhost:4242/');
});
