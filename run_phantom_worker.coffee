phantom.require = require
_ = require('underscore/underscore.js')
args = require('system').args

commands =
  try
    [].concat(JSON.parse(args[args.length-1]))
  catch e
    require('utils').dump args[args.length-1]

runCommand = (i, options)->
  command = _.extend(commands[i],options)
  WorkerClass = require("./phantom_worker/#{command.action}")
  worker = new WorkerClass(command)
  worker.execute()
  worker.success = (opts)->
    require('utils').dump(opts)
    if i < commands.length
      runCommand(i+1, opts)

runCommand(0)
