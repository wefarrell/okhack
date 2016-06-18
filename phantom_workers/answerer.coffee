OkCupid = require('./ok_cupid')
class Answerer extends OkCupid
  work: -> @thenOpen('http://www.okcupid.com/questions',@answerQuestion)
  answerQuestion: =>
    @json({totalQuestions: parseInt( @fetchText('#q_num_answered .value') )})
    if @visible('#questions_warning_comment') and @getHTML('#questions_warning_comment')
      @json({questionsComplete:1})
    questionNum = @getQuestionNum()
    for s in [ 'input[name="their_answer"]',
      "input[name=\"my_answer\"][type=\"radio\"]",
      'input[name="importance"][value="3"]']
      selector = "form##{@getFormName()} #{s}"
      @waitForSelector(selector)
      @click(selector)

    questionText = @fetchText("#qtext_#{questionNum} p")
    answerElements = @getElementsInfo("form##{@getFormName()} .my_answer label")
    answers = ($a.text for $a in answerElements)
    @json({question:{_id:questionNum,question:questionText,answers:answers}})

    @submitAnswer(questionNum)
    @waitWhileVisible('form#answer_'+questionNum+' input[name="their_answer"]')
    @wait(Math.random()*2000)
    @then(@answerQuestion)

  @submitAnswer = (questionNum) ->
    @click('#submit_btn_'+questionNum)

  @getQuestionNum = ->
    @getFormName().split('_')[1]

  @getFormName = ->
    @getElementAttribute('form', 'name')

module.exports = Answerer