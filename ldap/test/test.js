var chai = require('chai')
var should = chai.should();
var expect = chai.expect;
var assert = chai.assert;
var supertest = require('supertest');   
var di = require('di');

process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';
process.env.NODE_ENV = 'test-test';

var injector = new di.Injector([
	{
		"config":['type', require('./config')]
	}
]);
injector.invoke(function(config) {

var apiUrl = config.api.url;
var apiKey = config.app.apiKey;
console.log ('ENV: ' + process.env.NODE_ENV);
console.log ('URL: ' + apiUrl);
console.log ('KEY: ' + apiKey);

var api = supertest(apiUrl);

// describe.skip or describe.only, I like skip as I can see all the tests
describe('Basics', function() {
	describe('Validate API KEY', function() {

		it('Valid Error Condition - no key', function(done) {
			this.timeout(15000);
			api.get('/status')    
			.expect(401,done);
		});

		it('Valid Error Condition - bad x-exco-apikey header', function(done) {
			this.timeout(15000);
			api.get('/status')
			.set('x-exco-apikey', '123myapikey')
			.expect(401, done);
		});

		it('Valid API Key', function(done) {
			this.timeout(15000);
			api.get('/status')
			.set('x-exco-apikey', apiKey)
			.expect(200, done);    
		});

	});

	describe('JSON and XML', function() {

		it('Get Status JSON, default', function(done) {
			this.timeout(15000);
			api.get('/status')
			.set('x-exco-apikey', apiKey) 
			.expect('Content-Type', 'application/json')
			.expect(200)
			.end(function(err, res) {    	
				if ( err ) return done (err);

				// (res.body).should.have.property("status.code");
				(res.body.status.code).should.equal('OK');
				assert.equal(res.body.status.code, 'OK');
				expect(res.body).to.have.property('status');
				expect(res.body.status).to.have.property('code');
				expect(res.body.status.code).to.equal('OK');
				expect(res.body.status).to.have.property('message');
				expect(res.body.status.message, JSON.stringify(res.body)).to.equal('Internal Directory API is running.');
				done();
			});
		});

		it('Get Status XML', function(done) {
			this.timeout(15000);
			api.get('/status')
			.set('x-exco-apikey', apiKey) 
			.set('Accept', 'application/xml')      
			// This is an Apigee bug, its supposed to be set to application/xml by the JSON to XML policy
			// .expect('Content-Type', 'application/xml')
			// .expect('Content-Type', 'text/xml;charset=UTF-8')
			.expect('Content-Type', /\/xml/)
			.expect(200)
			.end(function(err, res) {    	
				if ( err ) return done (err);
				done();
			});
		});
	}); 
}); 

describe('Happy Paths', function() {
	describe('Get /users', function() {
		it('Get /users default count', function(done) {
			this.timeout(15000);
			api.get('/users')
			.set('x-exco-apikey', apiKey) 
			.expect('Content-Type', 'application/json')
			.expect(206)
			.end(function(err, res) {    	
				if ( err ) return done (err);

				expect(res.body.users.metadata.count).to.equal(10);
				done();
			});
		});
		it('Get /users 42 count', function(done) {
			this.timeout(15000);
			api.get('/users')
			.set('x-exco-apikey', apiKey) 
			.query({'limit':'42'}) 
			.expect('Content-Type', 'application/json')
			.expect(206)
			.end(function(err, res) {    	
				if ( err ) return done (err);

				expect(res.body.users.metadata.count).to.equal(42);
				done();
			});
		});
		it('Get /users/CSTAPITeam', function(done) {
			this.timeout(15000);
			api.get('/users/CSTAPITeam')
			.set('x-exco-apikey', apiKey) 
			.expect('Content-Type', 'application/json')
			.expect(200)
			.end(function(err, res) {    	
				if ( err ) return done (err);

				(res.body.users.metadata.count).should.equal(1);
				expect(res.body.users.user[0].ISID).to.equal('CSTAPITeam');
				// expect(res.body.users.user[0].ISID, res.body.users.user[0].ISID + ' value doesnt match kanaskik').to.equal('2kanaskik');
				// assert(res.body.users.user[0].ISID == 'kanaskik', res.body.users.user[0].ISID + ' value doesnt match 2kanaskik');
				done();
			});
		});
		it('Get /users?filter=email=apiteam@exco.com', function(done) {
			this.timeout(15000);
			api.get('/users')
			.set('x-exco-apikey', apiKey) 
			.query({'filter':'email=apiteam@exco.com'}) 
			.expect('Content-Type', 'application/json')
			.expect(200)
			.end(function(err, res) {    	
				if ( err ) return done (err);

				expect(res.body.users.metadata.count).to.equal(1);
				expect(res.body.users.user[0].email).to.equal('apiteam@exco.com');
				done();
			});
		});
		// There are 28 "Foo"s as of 2015-07-15, returns default value of 10
		it('Get /users?filter=familyName=Foo', function(done) {
			this.timeout(15000);
			api.get('/users')
			.set('x-exco-apikey', apiKey) 
			.query({'filter':'familyName=foo'}) 
			.expect('Content-Type', 'application/json')
			.expect(206)
			.end(function(err, res) {    	
				if ( err ) return done (err);

				expect(res.body.users.metadata.count).to.be.above(1);
				expect(res.body.users.user[0].familyName).to.equal('Foo');
				done();
			});
		});
		// There are 25 "Smith"s as of 2015-07-15, returns default value of 10
		it('Get /users?filter=(%26(familyName=Smith)(givenName=Michael))', function(done) {
			this.timeout(15000);
			api.get('/users')
			.set('x-exco-apikey', apiKey) 
			// .query({'filter':'(%26(familyName=Smith)(givenName=Michael))'}) 
			.query({'filter':'(&(givenName=Michael)(familyName=Smith))'}) 
			.expect('Content-Type', 'application/json')
			.expect(206)
			.end(function(err, res) {    	
				if ( err ) return done (err);

				expect(res.body.users.metadata.count).to.be.above(1);
				expect(res.body.users.user[0].familyName).to.equal('Smith');
				expect(res.body.users.user[0].givenName).to.equal('Michael');
				done();
			});
		});
	}); 

	describe('POST /authenticate', function() {
		it('Post /authenticate success', function(done) {
			this.timeout(15000);
			api.post('/authenticate')
			.type('application/x-www-form-urlencoded')
			.set('x-exco-apikey', apiKey) 
			.send({username : 'DEMO_UN', password : 'DEMO_PW'})
			.expect('Content-Type', 'application/json')
			.expect(200)
			.end(function(err, res) {    	
				if ( err ) return done (err);

				expect(res.body.authentication.user.ISID).to.equal('apigee');
				done();
			});
		});
	}); 
}); 

describe('Un Happy Paths', function() {
	describe('Get /users', function() {
		it('Get /users/no-isid-like-this', function(done) {
			this.timeout(15000);
			api.get('/users/no-isid-like-this')
			.set('x-exco-apikey', apiKey) 
			.expect('Content-Type', 'application/json')
			.expect(404,done);
		});
		it('Get /users?filter=email=aint-nobody@exco.com', function(done) {
			this.timeout(15000);
			api.get('/users')
			.set('x-exco-apikey', apiKey) 
			.query({'filter':'email=aint-nobody@exco.com'}) 
			.expect('Content-Type', 'application/json')
			.expect(404,done);
		});
		it('Get /users?filter=familyName=AintNoLastNameLikeThis', function(done) {
			this.timeout(15000);
			api.get('/users')
			.set('x-exco-apikey', apiKey) 
			.query({'filter':'familyName=AintNoLastNameLikeThis'}) 
			.expect('Content-Type', 'application/json')
			.expect(404,done);
		});
	}); 

	describe('POST /authenticate', function() {
		it('Post /authenticate wrong username', function(done) {
			this.timeout(15000);
			api.post('/authenticate')
			.type('application/x-www-form-urlencoded')
			.set('x-exco-apikey', apiKey) 
			.send({username : 'wrongusername', password : 'wrongpassword'})
			.expect('Content-Type', 'application/json')
			.expect(401)
			.end(function(err, res) {    	
				if ( err ) return done (err);

				expect(res.body.authentication.metadata.message, JSON.stringify(res.body)).to.exist;
				done();
			});
		});
		it('Post /authenticate wrong password', function(done) {
			this.timeout(15000);
			api.post('/authenticate')
			.type('application/x-www-form-urlencoded')
			.set('x-exco-apikey', apiKey) 
			.send({username : 'apigee', password : 'wrongpassword'})
			.expect('Content-Type', 'application/json')
			.expect(401)
			.end(function(err, res) {    	
				if ( err ) return done (err);

				expect(res.body.authentication.metadata.message, JSON.stringify(res.body)).to.exist;
				done();
			});
		});
		it('Post /authenticate empty username', function(done) {
			this.timeout(15000);
			api.post('/authenticate')
			.type('application/x-www-form-urlencoded')
			.set('x-exco-apikey', apiKey) 
			.send({username : '', password : 'wrongpassword'})
			.expect('Content-Type', 'application/json')
			.expect(400)
			.end(function(err, res) {    	
				if ( err ) return done (err);

				expect(res.body.authentication.metadata.message, JSON.stringify(res.body))
				    .to.contain('Form Params username and password are required and cannot be empty');
				// expect(res.body.authentication.metadata.message, JSON.stringify(res.body)).to.not.exist;
				done();
			});
		});
		it('Post /authenticate empty password', function(done) {
			this.timeout(15000);
			api.post('/authenticate')
			.type('application/x-www-form-urlencoded')
			.set('x-exco-apikey', apiKey) 
			.send({username : 'apigee', password : ''})
			.expect('Content-Type', 'application/json')
			.expect(400)
			.end(function(err, res) {    	
				if ( err ) return done (err);

				expect(res.body.authentication.metadata.message, JSON.stringify(res.body))
				    .to.contain('Form Params username and password are required and cannot be empty');
				// expect(res.body.authentication.metadata.message, JSON.stringify(res.body)).to.not.exist;
				done();
			});
		});
		it('Post /authenticate empty username and password', function(done) {
			this.timeout(15000);
			api.post('/authenticate')
			.type('application/x-www-form-urlencoded')
			.set('x-exco-apikey', apiKey) 
			.send({username : '', password : ''})
			.expect('Content-Type', 'application/json')
			.expect(400)
			.end(function(err, res) {    	
				if ( err ) return done (err);

				expect(res.body.authentication.metadata.message, JSON.stringify(res.body))
				    .to.contain('Form Params username and password are required and cannot be empty');
				// expect(res.body.authentication.metadata.message, JSON.stringify(res.body)).to.not.exist;
				done();
			});
		});
		it('Post /authenticate missing username', function(done) {
			this.timeout(15000);
			api.post('/authenticate')
			.type('application/x-www-form-urlencoded')
			.set('x-exco-apikey', apiKey) 
			.send({password : 'wrong'})
			.expect('Content-Type', 'application/json')
			.expect(400)
			.end(function(err, res) {    	
				if ( err ) return done (err);

				expect(res.body.authentication.metadata.message, JSON.stringify(res.body)).to.exist;
				done();
			});
		});
		it('Post /authenticate missing password', function(done) {
			this.timeout(15000);
			api.post('/authenticate')
			.type('application/x-www-form-urlencoded')
			.set('x-exco-apikey', apiKey) 
			.send({username : 'wrong'})
			.expect('Content-Type', 'application/json')
			.expect(400)
			.end(function(err, res) {    	
				if ( err ) return done (err);

				expect(res.body.authentication.metadata.message, JSON.stringify(res.body)).to.exist;
				done();
			});
		});
		it('Post /authenticate missing username and password', function(done) {
			this.timeout(15000);
			api.post('/authenticate')
			.type('application/x-www-form-urlencoded')
			.set('x-exco-apikey', apiKey) 
			.send()
			.expect('Content-Type', 'application/json')
			.expect(400)
			.end(function(err, res) {    	
				if ( err ) return done (err);

				expect(res.body.authentication.metadata.message, JSON.stringify(res.body)).to.exist;
				done();
			});
		});
	}); 
}); 
}); 
