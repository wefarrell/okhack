macPath = "/usr/local/Cellar/casperjs/1.1-beta3/libexec"
ubuntuPath = "/usr/lib/node_modules/casperjs";
phantom.casperPath = macPath
Casper = phantom.require('casper').Casper
_ = require('underscore/underscore.js')
OKC_URL = "https://www.okcupid.com/"

class OkCupid extends Casper
  loggedIn = false
  reqOptions: {
    headers: {
      ":host":"www.okcupid.com",
      "pragma":"no-cache",
      "accept-encoding":"gzip, deflate, sdch",
      "accept-language":"en-US,en;q=0.8",
      "user-agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.115 Safari/537.36",
      ":path":"/",
      "accept":"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
      ":version":"HTTP/1.1",
      "cache-control":"no-cache",
      "cookie":"__cfduid=dd51afb15c7cbd5df67838ffa63e74d141425428161; guest=14561027414527552631; core=1936cb80_c05.f80.d07.d01.f62.f60.d05.f59.b01.f33.f13.f23.f21.f18.f14.f12.c01.f27.j85.f65.f66.f76.f67.f70.f26.j62.d04.f77.c16_d03.f34.f71.f85.j57.j95; signup_exp_2014_09_13=2014_simpleblue",
      ":scheme":"https",
      ":method":"GET"
    }
  }
  userAgentFile: 'user_agents'
  fs: require('fs')
  waitTimeout: 20000
  loginRequired: true

  constructor: (options)->
    _.extend(@, options)
    super( logLevel: "debug" )
  execute: ->
    @start()
    if not loggedIn and @loginRequired
      @login()
    @work()
    @run()
  setUseragent: ->
    ua = @randomUserAgent()
    @then -> @userAgent(ua)
  login: =>
    @echo "trying to login"
    unless @uname
      @die('username not specified')
    @setUseragent()
    @thenOpen(OKC_URL, @reqOptions)
    @then(@attemptLogin)
    @then(@handleLoginAttemptResult)

  attemptLogin: =>
    @echo 'attempting login'
    @wait 5000, ->
      if @exists('form#loginbox_form')
        @fill('form#loginbox_form', {username:@uname, password:@pass}, true)
      else
        @die("Can't find login form, login page content:" + @getPageContent())

  handleLoginAttemptResult: =>
    @echo "Login form submitted #{@uname}"
    if @getCurrentUrl().split('/').pop() is 'home'
      loggedIn = true
      @json {'loggedIn':1}
    else
      @capture('logn-fail.png')
      @wait(50000, -> @die("unable to log in") )

  randomUserAgent: ->
    @fs.read(@userAgentFile).split('\n')[parseInt(Math.random()*10)]
  json: (obj) ->
    @echo JSON.stringify(obj)

module.exports = OkCupid