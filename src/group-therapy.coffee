# Description:
#   Analyze users in a Flowdock thread using sentiment (https://github.com/thisandagain/sentiment)
#
# Commands:
#   hubot group therapy
#
# Examples:
#   hubot group therapy
#
# Author:
#   Andrew Connor (andrew.connor@postlight.com)

sentiment = require('sentiment')

baseUrl = "https://#{process.env.HUBOT_FLOWDOCK_API_TOKEN}@api.flowdock.com/"

module.exports = (robot) ->

  emoteScore = (score) ->
    score = parseFloat(score)
    return ":sob:"  if(score <= -3.5)
    return ":cry:" if(score <= -2.5)
    return ":confused:" if(score <= -1.5)
    return ":unamused:" if(score <= -0.2)
    return ":smiley:" if(score >= 3.5)
    return ":smile:" if(score >= 2.5)
    return ":relaxed:" if(score >= 1.5)
    return ":relieved:" if(score >= 0.2)
    return ":neutral_face:"

  scoreUserMessages = (userMessages) ->
    userAnalysis = []
    totalScore = 0

    for user, content of userMessages
      analysis = sentiment content
      totalScore += analysis.score
      userAnalysis.push {
        'userId': user,
        'score': analysis.score,
        'words': analysis.words,
        'emotion': emoteScore analysis.score
      }
    return [userAnalysis, totalScore]

  getUserNickname = (res, user, userEmotions, userAnalysis, totalScore) ->
    robot.http("#{baseUrl}/users/#{user.userId}").get() (err, msg, body) ->
      userData = JSON.parse body
      user['nickname'] = userData.nick
      userEmotions.push user

      if userEmotions.length == userAnalysis.length
        overallEmotion = emoteScore(totalScore / userEmotions.length)
        sendEmotions res, userEmotions, overallEmotion

  sendEmotions = (res, userEmotions, overallEmotion) ->
    message = ''
    for user in userEmotions
      message += "#{user.nickname} is #{user.emotion} "
      if user.words.length > 0
        message += "`"
        for word in user.words
          message += " #{word}, "
        message = message.trim().replace(/,+$/, "");
        message += "`"
      message += "\n"

    message += "\nOverall, everyone is #{overallEmotion}"
    res.send message

  robot.respond /group therapy/i, (res) ->
    metadata = res.envelope.metadata || res.envelope.message?.metadata || {}
    flow = metadata.room || res.envelope.room

    robot.http("#{baseUrl}/flows/find?id=#{flow}").get() (err, msg, body) ->
      data = JSON.parse body
      flow = data.parameterized_name
      organization = data.organization.parameterized_name
      threadId = metadata.thread_id

      threadMessagesUrl = "#{baseUrl}/flows/#{organization}/#{flow}/threads/#{threadId}/messages?limit=100"
      robot.http(threadMessagesUrl).get() (err, msg, body) ->
        messages = JSON.parse body
        userMessages = {}
        for message in messages
          if userMessages[message.user]?
            userMessages[message.user] += " #{message.content}"
          else
            userMessages[message.user] = message.content

        scores = scoreUserMessages userMessages
        userAnalysis = scores[0]
        totalScore = scores[1]
        userEmotions = []

        for user in userAnalysis
          getUserNickname res, user, userEmotions, userAnalysis, totalScore
