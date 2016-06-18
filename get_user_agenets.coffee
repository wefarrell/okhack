url = 'http://techpatterns.com/downloads/firefox/useragentswitcher.xml'
fileDate = []
require('request')(url, (err,res,xml)->
  xml = require('xml2js').parseString(xml.toString(), (err, xml)->
    for n in xml.useragentswitcher.folder.slice(0,4)
      if(n.useragent)
        for u in n.useragent
          if(u.$.useragent)
            fileDate.push(u.$.useragent)
    require('fs').writeFileSync('user_agents',fileDate.join('\n'))
  )
)
