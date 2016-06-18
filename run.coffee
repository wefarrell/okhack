spawn = require('child_process').spawn
fs = require('fs')
mongo = require('mongoskin')
db = mongo.db("mongodb://okhack:sailing@107.170.29.70:27017/okhack", {native_parser:true});
db.bind('bot');

argument = require('system').args[0]

Job = require("./jobs/#{argument}.coffee")
job = new Job()
job.execute()