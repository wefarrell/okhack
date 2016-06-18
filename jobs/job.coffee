class Job
  spawn = require('child_process').spawn
  mongo = require('mongoskin')
  database = require('./database')
  db: database()
  constructor: ->
  timeLimit: 180000
  work: => @nextObj(@advance)
  execute: ->
    @coll = @db.collection(@collection)
    if(@setup)
      @setup(@work)
    else
      @work()

  nextObj: (callback)=>
    cursor = @coll.find(@query).sort(@sort)
    cursor.nextObject((err, object)->
      if err
        console.error(err);
        setTimeout((=> @nextObj(callback)),@timeLimit/3)
      else
        callback(object)
    )
  advance: (object)=>
    if (object)
      @uname = @command.uname = object.uname
    command = ['run_phantom_worker.coffee', JSON.stringify(@command)]
    if(process.argv.pop() == '--tor')
      command = ['--proxy=127.0.0.1:9050','--proxy-type=socks5'].concat(command)
      console.log('using tor')
    @worker = spawn('casperjs', command)
    killOnTimeout = null
    restart = =>
      console.log('restarting bots')
      @worker.kill()
      @execute()
    buffer = ''
    @worker.stdout.on('data',(data)=>
      clearTimeout(killOnTimeout)
      killOnTimeout = setTimeout(restart, @timeLimit)
      data = data.toString()
      buffer += data
      if(data.substr(-1)=='\n')
        console.log(buffer)
        processLine(buffer)
        buffer = ''
    )
    processLine = (line) =>
      try
        data = JSON.parse(line)
        @processResponse(data)
      catch e

module.exports = Job