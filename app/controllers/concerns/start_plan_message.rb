module StartPlanMessage

  def start_plan_message(user_names)
    formatted_user_names = user_names.map {|n| "@#{n}"}.join(', ')

    {
      text: "OK! We'll see if we can plan something with #{formatted_user_names}.",
      attachments: [
        {
          "text": "Sound good?",
          "fallback": "You are unable to create a plan",
          "callback_id": "start_plan_response",
          "color": "#3AA3E3",
          "attachment_type": "default",
          "actions": [
            {
              "name": "response",
              "text": "Yeah, let's go",
              "type": "button",
              "value": "yes"
            },
            {
              "name": "response",
              "text": "No. Let me try again.",
              "type": "button",
              "value": "no"
            }
          ]
        }
      ]
    }
  end
end
