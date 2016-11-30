require_relative 'questions_database'
require_relative 'user'
require_relative 'questions'
require_relative 'model_base'

class Reply < ModelBase
  attr_accessor :question_id, :parent_reply, :user_id, :body

  def self.find_by_question_id(question_id)
    reply = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    return nil unless reply.length > 0

    result = []
    reply.each do |r|
      result << Reply.new(r)
    end

    result
  end

  def self.find_by_parent_reply(parent_reply)
    reply = QuestionsDBConnection.instance.execute(<<-SQL, parent_reply)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_reply = ?
    SQL
    return nil unless reply.length > 0

    Reply.new(reply.first)
  end

  def self.find_by_user_id(user_id)
    reply = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    return nil unless reply.length > 0

    result = []
    reply.each do |r|
      result << Reply.new(r)
    end

    result
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_reply = options['parent_reply']
    @user_id = options['user_id']
    @body = options['body']
  end

  def author
    User.find_by_id(@user_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    Reply.find_by_id(@parent_reply)
  end

  def child_replies
    replies = QuestionsDBConnection.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_reply = ?
    SQL
    return nil if replies.length > 0

    result = []
    replies.each do |reply|
      result << Reply.new(reply)
    end

    result
  end

  def save
    if @id
      QuestionsDBConnection.instance.execute(<<-SQL, @question_id, @parent_reply, @user_id, @body, @id)
        UPDATE
          replies
        SET
          question_id = ?, parent_reply = ?, user_id = ?, body = ?
        WHERE
          id = ?
      SQL
    else
      QuestionsDBConnection.instance.execute(<<-SQL, @question_id, @parent_reply, @user_id, @body)
        INSERT INTO
          replies (question_id, parent_reply, user_id, body)
        VALUES
          (?, ?, ?, ?)
      SQL

      @id = QuestionsDBConnection.instance.last_insert_row_id
    end
  end
end
