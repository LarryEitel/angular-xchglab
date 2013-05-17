/**
 * frisby.js: Twitter Example
 * (C) 2012, Vance Lucas
 */
var frisby = require('../../vendor/frisby/lib/frisby');

frisby.globalSetup({ // globalSetup is for ALL requests
  request: {
    headers: { 'Authorization': 'Basic admin@orgtec.com:xxxxxx' }
  }
});

frisby.create('Get Brightbit Twitter feed')
  .get('http://exi.xchg.com/api/users')
    .expectStatus(200)
    .expectHeaderContains('content-type', 'application/json')
    .inspectJSON()
    .expectJSONTypes('?', {
        dNam: "admin@orgtec.com"
    })
.toss();
