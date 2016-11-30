require_relative 'questions_database'
require_relative 'user'
require_relative 'questions'
require_relative 'model_base'

class QuestionFollow < ModelBase
  attr_accessor :question_id, :follower_id

  def self.find_by_question_id(question_id)
    follow = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        question_id = ?
    SQL
    return nil unless follow.length > 0

    QuestionFollow.new(follow.first)
  end

  def self.find_by_follower_id(follower_id)
    follow = QuestionsDBConnection.instance.execute(<<-SQL, follower_id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        follower_id = ?
    SQL
    return nil unless follow.length > 0

    QuestionFollow.new(follow.first)
  end

  def self.followers_for_question_id(question_id)
    followers = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        question_follows
      JOIN
        users ON users.id = question_follows.follower_id
      WHERE
        question_id = ?
    SQL
    return nil unless followers.length > 0

    result = []
    followers.each do |follower|
      result << User.new(follower)
    end

    result
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        question_follows
      JOIN
        questions ON questions.id = question_follows.question_id
      WHERE
        follower_id = ?
    SQL
    return nil unless questions.length > 0

    result = []
    questions.each do |question|
      result << Question.new(question)
    end

    result
  end

  def self.most_followed_questions(n)
    questions = QuestionsDBConnection.instance.execute(<<-SQL, n)
      SELECT
        questions.*, COUNT(*)
      FROM
        question_follows
      JOIN
        questions ON questions.id = question_follows.question_id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(*) desc
      LIMIT
        ?
    SQL
    return nil unless questions.length > 0

    result = []
    questions.each do |question|
      result << Question.new(question)
    end

    result
  end

  def initialize(options)
    @question_id = options['question_id']
    @follower_id = options['follower_id']
  end
end
