Action = require('./job.coffee')
class ScrapeProfile extends Action
  collection: 'profile'
  query:
    finishTime: null,
    $or: [
      {startTime: { $lte : new Date(new Date() - 20*60000) } }, #Havent started in the last 20 mins
      {startTime:  null}
    ]
    removed: null
  sort: {}
  command:
    action: "ProfileScraper"
  setup: (done)=>
    @botColl = @db.collection('bot')
    cursor = @botColl.find({questionsComplete:true}).sort({lastUse:1})
    cursor.nextObject((err, obj)=>
      if(err)
        console.log(err)
        setTimeout((=> @setup(done) ),@timeLimit/3)
      else
        @botName = @command.bot = obj.uname
        console.log('bot is: '+@botName)
        @botColl.update({uname:@botName}, { $set: {lastUse:new Date()} }, =>)
        done()
    )
  processResponse: (data) =>
    if(data.emptyProfile)
      @coll.update({uname:data.uname},{$set:{removed:true}}, =>)
      @nextObj( (obj) =>
        console.log('sending request to bot: ')
        console.log(JSON.stringify({uname:obj.uname}))
        @worker.stdin.write(JSON.stringify({uname:obj.uname})+"\n");
      )
    if(data.data)
      $set = data
      $set.scraperBot = @botName
      $set.finishTime = new Date()
      @coll.update({uname:data.uname},{$set:data.data}, =>
        @nextObj( (obj) =>
          console.log('sending request to bot: ')
          console.log(JSON.stringify({uname:obj.uname}), =>)
          @worker.stdin.write(JSON.stringify({uname:obj.uname})+"\n");
        )
      )
      @botColl.update({uname:@botName}, { $set: {lastUse:new Date()} }, =>)
    if(data.scrapeStarted)
      @coll.update({uname:data.uname}, {$set:{startTime:new Date()}},(err, res) =>)
      @botColl.update({uname:@botName}, {$set:{lastUse:new Date()}}, =>)

module.exports = ScrapeProfile