module.exports = class Clusterer
  fs = require('fs')
  matrixFile = 'profile_matrix.csv'
  profileCentroidsFile = 'profile_centroids.json'
  _ = require('lodash')
  exec = require('child-process-promise').exec

  cluster = (profiles, questionIndexMap) ->
    profileQuestionValues = (profile)->
      _(questionIndexMap).map((questionId) => profile[questionId]).reject(_.isNil).join(',')

    csv = _(profiles).map(profileQuestionValues).reject(_.isNil).join('\n')

    fs.writeFileSync(matrixFile, csv)
    exec("rscript cluster_profiles.r")

  loadCentroids = ->
    readCsv = (csvFile)->
      csv = fs.readFileSync(csvFile)
      ( row.split(',') for row in csv.toString().split('\n') )

    getCentroidsFile = ->
      readCsv('centroids.csv').slice(1,-1)

    rowToJsonQuestionValueMap = (row) ->
      row.shift()
      questionIndexMap.filter( (questionId) => questions[questionId]? )
      .map ( (questionId, index) =>
        question = questions[questionId]?.question
        answerNum = row[index].replace(/"/g,'')
        { "#{questionId}" = answerNum }
      ).reduce(_.merge)
      JSON.stringify(hash)

    centroids = getCentroidsFile()
    centroids.slice(1).map(rowToJsonQuestionValueMap).join('\n')

  writeCentroidsFile = (profileCentroids) ->
    fs.writeFileSync(profileCentroidsFile, profileCentroids)
    process.exit(0)

  aggregateQuestionCounts = (questionCounts, questionId) ->
    questionCounts[questionId] ||= 0
    questionCounts[questionId] += 1
    return questionCounts

  buildProfileQuestionMap = (questions) ->
    questionIdtoVal = (questionValues, questionId) ->
      questionValue = questionValues[0]
      if questionValue? then { "#{questionId}": parseInt(questionValue) }
    _(questions).map(questionIdtoVal).reduce(_.merge)

  getPopular = (questionCounts, n) ->
    min = _.values(questionCounts).sort((a,b)-> b-a)[n]
    _questions = Object.keys(questionCounts)
    (q for q in _questions when questionCounts[q] > min)

  constructor: (@questionIdMap) ->

  calculateClusterCentroids: (profiles) =>
    profilesQuestions = _(profiles).map('questions')
    questionCounts = _(profilesQuestions)(_.keys).flatten().reduce(aggregateQuestionCounts, {})
    profiles = _(profilesQuestions).map(buildProfileQuestionMap).reject(_.isEmpty).value()
    questionIndexMap = getPopular(questionCounts, 50)
    console.time('r');
    cluster(profiles, questionIndexMap, @questionIdMap)
    .then ->
      console.timeEnd('r');
      profileCentroids = loadCentroids()
      writeCentroidsFile(profileCentroids)
