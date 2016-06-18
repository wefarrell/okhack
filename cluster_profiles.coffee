Clusterer = require('./profile_clusterer')
database = require('./database')

db = database()
db.fetchQuestions()
.then (docs) ->
  questionIdMap = _(docs).map( (doc) ->
    "#{doc._id}" : {
      question: doc.question,
      answers: doc.answers
    }
  ).reduce(_.merge)
  clusterer = new Clusterer(questionIdMap)
  db.fetchProfiles()
  .then(clusterer.calculateClusterCentroids)

