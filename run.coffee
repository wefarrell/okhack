argument = require('system').args[0]

Job = require("./jobs/#{argument}.coffee")
job = new Job()
job.execute()