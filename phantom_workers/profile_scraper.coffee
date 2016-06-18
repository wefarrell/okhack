OkCupid = require('./ok_cupid')

class ProfileScraper extends OkCupid
  $ = require('jquery/dist/jquery.js')
  botAnswer = 0
  jsonIn: -> JSON.parse(require('system').stdin.readLine())
  constructor: (options)->
    @profile = options.uname
    @uname = options.bot
    super({})
  error: (error) => console.log(error)
  work: -> @scrapeProfile(@profile)
  scrapeProfile: (uname) =>
    @json( {scrapeStarted:true, uname:uname} )
    profileObj = {questions : {}}
    @thenOpen('https://www.okcupid.com/profile/'+uname, =>
      if(@profileNoLongerExists())
        @json({emptyProfile:uname})
        @scrapeNextProfile()
      @echo 'scraping profile ' + uname
      @echo 'scraping essays'
      if @exists('.essay')
        essayNodes = @getElementsInfo('.essay')
        for element in essayNodes
          essay = $(element.html).find('div.nostyle').html()
          profileObj[element.attributes.id] = essay
      profileObj.what_i_want = @getHTML('.what_i_want')
      @totalPages = null
      onFinish = =>
        @json({uname: uname, data: profileObj})
        @scrapeNextProfile()
      addQuestions = (questionId, answerValue, answerPreference) ->
        profileObj.questions[questionId] = [answerValue , answerPreference]
      @scrapeVisibleQuestions(uname, profileObj.questions, 1, onFinish, @error)
    )

  profileNoLongerExists: ->
    @getHTML('#main_content').indexOf('Sorry, we don’t have anyone by that name!') isnt -1

  scrapeVisibleQuestions: (profile, questions, questionStart, finish, error) =>
    @thenOpen "http://www.okcupid.com/profile/#{profile}/questions?low=#{questionStart}", =>
      @totalPages ||= @getHTML('a.last')
      if(!@exists('#questions'))
        @capture('no_questions.png')
      $questions = $(@getHTML('#questions', 1)).find('.question.public')
      for q in $questions
        qId = $(q).attr('id').split('_')[1]
        botIncompatible = $(q).find('p.answer:last span:first').hasClass('not_accepted')
        answerPreference = if botIncompatible then null else botAnswer
        answerText = $(q).find('p.answer:first span:first').text().trim();
        throw "cant find answer text" unless answerText
        answerValue = @getAnswerValue(qId, answerText,$(q))
        throw "unable to get the answer number from form" unless answerValue
        addQuestions(qId, answerValue, answerPreference)
      @echo "scraping questions, page #{ Math.ceil(questionStart/10)} of #{@totalPages}"
      if(@exists('li.next.disabled'))
        finish()
      else if $questions.length > 0
        @wait( 2000, => @scrapeVisibleQuestions(profile, questions, questionStart+10, finish) )
      else
        @error

  getAnswerValue: (qid, answerText, $html) =>
    inputSelector = "form#answer_#{qid} input[type=radio]"
    radios = Array::slice.call($html.find(inputSelector))
    if radios.length == 0 then throw "cant find question radio buttons"
    for input in radios
      text = $html.find("label[for=#{input.id}]").text().trim()
      if text is answerText
        return input.value

  scrapeNextProfile: ->
    @scrapeProfile(@jsonIn().uname)

module.exports = ProfileScraper