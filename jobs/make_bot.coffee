Action = require('./job.coffee')
class MakeBot extends Action
  command:
    action: "BotMaker"
  collection: 'bot'
  work: -> @advance()

  processResponse: (data)->
    if(data.newBot)
      @coll.insert({uname:data.newBot},->)
      console.log('made a new bot!')
    else

module.exports = MakeBot