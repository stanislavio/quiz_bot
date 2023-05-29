require 'telegram/bot'

token = '5949994252:AAFCp-pFHuMGooBwy8cFnpbdLkrsphZMBrs'

questions = [
  {
    question: 'Яка столиця Франції?',
    options: ['Лондон', 'Париж', 'Мадрид'],
    answer: 'Париж'
  },
  {
    question: 'Яка найбільша планета в Сонячній системі?',
    options: ['Марс', 'Венера', 'Юпітер'],
    answer: 'Юпітер'
  },
  {
    question: 'Яка річка є найдовшою у світі?',
    options: ['Амазонка', 'Ніл', 'Янцзи'],
    answer: 'Амазонка'
  },
  {
    question: 'Яка столиця України?',
    options: ['Київ', 'Львів', 'Одеса'],
    answer: 'Київ'
  },
  {
    question: 'Як називається найдовший річковий рейс в Україні?',
    options: ['Дніпро', 'Дунай', 'Південний Буг'],
    answer: 'Дніпро'
  },
  {
    question: 'У якому році Україна відновила свою незалежність?',
    options: ['1991', '1989', '1994'],
    answer: '1991'
  },
  {
    question: 'Який найвищий гірський масив в Україні?',
    options: ['Карпати', 'Бескиди', 'Кримські гори'],
    answer: 'Карпати'
  },
  {
    question: 'Як називається найдовший річка в Україні?',
    options: ['Дніпро', 'Дунай', 'Сіверський Донець'],
    answer: 'Дніпро'
  }
]


user_answers = {}

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    chat_id = message.chat.id

    if user_answers[chat_id].nil?
      # Якщо це новий користувач, починаємо тест
      user_answers[chat_id] = {}
      question = questions.first
      user_answers[chat_id][:current_question] = question
      user_answers[chat_id][:score] = 0

      options = question[:options].map { |option| Telegram::Bot::Types::KeyboardButton.new(text: option) }
      options_keyboard = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: options.each_slice(1).to_a, one_time_keyboard: true)

      bot.api.send_message(chat_id: chat_id, text: question[:question], reply_markup: options_keyboard)
    else
      # Якщо користувач уже відповідав на питання
      current_question = user_answers[chat_id][:current_question]
      answer = current_question[:answer]

      if message.text == answer
        # Якщо відповідь правильна, збільшуємо рахунок
        user_answers[chat_id][:score] += 1
      end

      # Перехід до наступного питання або завершення тесту
      index = questions.index(current_question)
      if index + 1 < questions.length
        next_question = questions[index + 1]
        user_answers[chat_id][:current_question] = next_question

        options = next_question[:options].map { |option| Telegram::Bot::Types::KeyboardButton.new(text: option) }
        options_keyboard = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: options.each_slice(1).to_a, one_time_keyboard: true)

        bot.api.send_message(chat_id: chat_id, text: next_question[:question], reply_markup: options_keyboard)
      else
        score = user_answers[chat_id][:score]
        total_questions = questions.length
        bot.api.send_message(chat_id: chat_id, text: "Тест завершено!\n\nВаш рахунок: #{score}/#{total_questions}")
                                                                                                                                                        user_answers.delete(chat_id) # Скидання даних користувача
      end
    end
  end
end
