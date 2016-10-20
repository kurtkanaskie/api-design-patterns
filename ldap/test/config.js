'use strict';

/**
 * Config() Class responsible storing the general
 * configuration of the API.
 *
 * @return {Object} Configuration
 */	
module.exports = function (){

var IAPI_DEV_TEST = 'https://iapitest-dev.exco.com/internalDirectory/v1';
var IAPI_DEV_PROD = 'https://iapi-dev.exco.com/internalDirectory/v1';
var EAPI_DEV_TEST = 'https://apitest-dev.exco.com/internalDirectory/v1';
var EAPI_DEV_PROD = 'https://api-dev.exco.com/internalDirectory/v1';

var IAPI_TST_TEST = 'https://iapitest-test.exco.com/internalDirectory/v1';
var IAPI_TST_PROD = 'https://iapi-test.exco.com/internalDirectory/v1';
var EAPI_TST_TEST = 'https://apitest-test.exco.com/internalDirectory/v1';
var EAPI_TST_PROD = 'https://api-test.exco.com/internalDirectory/v1';

var IAPI_PRD_TEST = 'https://iapitest.exco.com/internalDirectory/v1';
var IAPI_PRD_PROD = 'https://iapi.exco.com/internalDirectory/v1';
var EAPI_PRD_TEST = 'https://apitest.exco.com/internalDirectory/v1';
var EAPI_PRD_PROD = 'https://api.exco.com/internalDirectory/v1';

var API_KEY_DEV = 'azF5mbg3rGdfGcCU55jN1c0Sfooc3Dtz';
var API_KEY_TST = 'uB847GL5nHOPEKqiBE3RM6z04XsTccjI';
var API_KEY_PRD = 'BcXJIUoFFR7WncfGiYwRuFmjsbUqcBX8';

switch(process.env.NODE_ENV){
	case 'local-development':
		return {
			app: {
				name: "Internal Directory",
				apiKey: ""
			},
			api: {
			        url: "http://localhost:4242",
				protocol: "http://",
				hosts: "localhost",
				baseUrl: ""
			}
		};
	case 'development-test':
		return {
			app: {
				name: "Internal Directory",
				apiKey: API_KEY_DEV
			},
			api: {
				url: IAPI_DEV_PROD,
				protocol: "https://",
				hosts: "iapitest-dev.exco.com",
				baseUrl: "/internalDirectory/v1"
			}
		};
	case 'development-prod':
		return {
			app: {
				name: "Internal Directory",
				apiKey: API_KEY_DEV
			},
			api: {
				url: IAPI_DEV_PROD,
				protocol: "https://",
				hosts: "iapi-dev.exco.com",
				baseUrl: "/internalDirectory/v1"
			}
		};
	case 'test-test':
		return {
			app: {
				name: "Internal Directory",
				apiKey: API_KEY_TST
			},
			api: {
				url: IAPI_TST_TEST,
				protocol: "https://",
				hosts: "iapitest-test.exco.com",
				baseUrl: "/internalDirectory/v1"
			}
		};
	case 'test-prod':
		return {
			app: {
				name: "Internal Directory",
				apiKey: API_KEY_TST
			},
			api: {
				url: IAPI_TST_TEST,
				protocol: "https://",
				hosts: "iapi-test.exco.com",
				baseUrl: "/internalDirectory/v1"
			}
		};
	case 'production-test':
		return {
			app: {
				name: "Internal Directory",
				apiKey: API_KEY_PRD
			},
			api: {
				url: IAPI_PRD_TEST,
				protocol: "https://",
				hosts: "iapitest.exco.com",
				baseUrl: "/internalDirectory/v1"
			}
		};
	case 'production-prod':
		return {
			app: {
				name: "Internal Directory",
				apiKey: API_KEY_PRD
			},
			api: {
				url: IAPI_PRD_TEST,
				protocol: "https://",
				hosts: "iapi.exco.com",
				baseUrl: "/internalDirectory/v1"
			}
		};

	default:
		console.log('No enviroment (process.env.NODE_ENV) has been set!');
		return 'An error happened here!';
}

};
