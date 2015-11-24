project: SalesForceCFC
version: 0.8
date: 2/28/2010

-overview-
This CFC allows you to connect and work with SalesForce.com,
one of the largest CRMs out there. It does so by generating SOAP requests,
and manipulating their responses.
This will make it easy to work with their SObjects,
and allow you to do more than just query.

-requirements-
ColdFusion 7 or Higher
Salesforce.com Account (Developer Accounts are freely available)

-usage-
The constructor (init method) is required.

if not using auto login, 
you will have to call the login() method manually to activate a session

SalesForce requires you to add your IP to the their Control Panel under SETUP \ SECURITY CONTROLS \ NETWORK ACCESS.

-note-
be careful with concurrency issues if using multiple accounts.
it is not meant to be persistent if using more than 1 account.

-credits-
Daniel Llewellyn
Pete Freitag

0.8 -CHANGE LOG- 2/2/2010
- enhancement - unpaged queries with queryObject using disablePagination param
- enhancement - batchSize default removed from queryObject for better performance
- fix - batchSize of 0 would throw error

0.7 -CHANGE LOG- 1/24/2010
- enhancement - added support for batch save
- enhancement - added support for AssignmentHeader
- enhancement - added support for EmailHeader
- enhancement - added result size to query return data
- enhancement - updated typing and case of component
- enhancement - increased default SOAP timeout
- deprecated - unnecessary setters (setServerURL,setSessionId,setLastLogin)

0.6 -CHANGE LOG- 2/22/2009
- enhancement - auto login
- enhancement - upgraded constructor
- enhancement - more getters and setters
- enhancement - last login added to instance
- enhancement - added utility calls getUserInfo and getServerTimeStamp
- enhancement - upgraded soap handling to minimize code
- enhancement - session handling added to test form to demo persistence
- deprecated - username and password parameters have been removed from login
- deprecated - objDataStruct on return from describeObject()
- fix - validate method getServerURL missing parenthesis
- fix - test form updated to avoid crossover and better cleanup

0.5 -CHANGE LOG- 2/8/2009
- enhancement - added support for queryMore (pagination)
- enhancement - started upgrading SOAP response handling

0.4 -CHANGE LOG- 4/5/2008
- enhancement - added timeout handling for cfhttp
- enhancement - added getMemento()
- fix - added xmlFormat() to query and save methods
- fix - disabled throwonerror for cfhttp to return accurate success

0.3 -CHANGE LOG- 3/22/2008
- fix - added support for relational queries
- enhancement - updated test form with relational query example
- enhancement - added screen shots to package

0.2 -CHANGE LOG- 3/1/2008
- feature - added landing page
- feature - added test form
- feature - added cfcDoc
- enhancement - created sendSoapRequest method and updated code
- enhancement - added validate method
- fix - retrieve now returns array of struct for results
- fix - added caching control for cfhttp and soap requests

0.1 -INITIAL RELEASE- 2/19/2008
-login, retrieve, query, create, update, delete, and describe methods.