Job = require('./job.coffee')
class AnswerQuestions extends Job
  collection: 'bot'
  query:
    questionsComplete: null,
    $or: [
      {updateTime: { $lte : new Date(new Date() - 20*60000) } }, #No updates in the last 20 minutes
      {updateTime:  null}
    ]
  sort:
    totalQuestions:1
  command:
    action: "Answerer"
    answerNum: 0
  passParam: "uname"
  processResponse: (data) =>
    if(data.totalQuestions)
      $set =
        totalQuestions:parseInt(data.totalQuestions),
        updateTime:new Date()
      @coll.update({uname:@uname},{$set:$set}, ->)
      return
    if(data.questionsComplete)
      @coll.update({uname:@uname},{$set:{questionsComplete:true}}, =>
        @nextObj(@advance)
        @worker.kill()
      )
      return
    if(data.question)
      question = data.question
      @db.collection('question').update({_id:question._id}, question, {upsert:true}, ->)
    @coll.update({uname:@uname},{$set:{updateTime:new Date()}}, ->)

module.exports = AnswerQuestions