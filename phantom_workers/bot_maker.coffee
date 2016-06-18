OkCupid = require('./ok_cupid')
#specific question url is http://www.okcupid.com/questions?rqid=[question id]

class BotMaker extends OkCupid
  cpSpawn = require('child_process').spawn
  screenName = null
  solveCapcha = (file, callback) ->
    process = cpSpawn("./deathbycapcha.sh", [process.env.DBC_USER, process.env.DBC_PASS, file])
    dbcOutput = []
    process.stdout.on('data', (data) ->
      dbcOutput.push(data)
    )
    process.on('exit', ->
      capcha = decodeURI(dbcOutput[1]).replace(/\+/g,' ')
      callback( capcha )
    )
  loginRequired: false
  work: ->
    @setUseragent()
    @thenOpen('http://www.generate-password.com/', @getScreenName)
    @thenOpen('http://www.okcupid.com', @fillPage1)
    @then(@fillPage2)
    @thenOpen('http://www.okcupid.com/home', @confirm)
  getScreenName: ->
    screenName = @getElementAttribute('input[name=random_password]', 'value')
  fillPage1: ->
    email = screenName + '@mailinator.com'
    @fill('form#signup_form',{gender: '1'})
    @click('#sign_up_email')
    @fill('form#signup_form',
      birthyear: '1990'
      zip_or_city: '10002'
      email: email
      email2: email
      gender: 1
    )
    @click('button[type=submit][tabindex="12"].flatbutton.okblue')
    @wait(1000)
  fillPage2: ->
    if not @exists('form#signup_form')
      @capture('form-maybe.png')
      @die('cant find form')
    capchaFile = 'captcha.png'
    @capture('captcha.png',{
      top:540,
      left: 200,
      width:305,
      height:58
    },{
      format: 'png',
      quality: 100
    })
    solveCapcha.call(this,capchaFile, (capcha)=>
      @fill('form#signup_form',
        screenname: screenName
        password: 'botpassword',
        recaptcha_response_field: capcha
      )
      @click('button[type=submit].flatbutton.okblue')
      @capture('after-submitted.png')
      @unwait()
    )
    @wait(30000)
  confirm: =>
    if @getCurrentUrl() is 'http://www.okcupid.com/home'
      @json({newBot:screenName})
    else
      @json({error:true})
      @capture('last-step-fail.png')


module.exports = BotMaker