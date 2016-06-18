Promise = require("bluebird")
mongo = require('mongoskin')
_ = require('lodash')

for key, value of mongoskin
  Promise.promisifyAll(value);
  Promise.promisifyAll(value.prototype);
  Promise.promisifyAll(mongoskin)

dbUrl = "mongodb://#{process.env.mongoUser}:#{process.env.mongoPassword}@107.170.29.70:27017/okhack"
db = mongo.db(dbUrl, {native_parser: true});

module.exports = _.merge(db, {
  fetchQuestions: ->
    db.collection('question').find().toArrayAsync()

  fetchProfiles: ->
    query = {questions: {$ne: null}}
    fields = {questions: 1, uname: 1}
    db.collection('profile').find(query, fields).find().toArrayAsync()
})
