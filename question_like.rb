require_relative 'questions_database'
require_relative 'user'
require_relative 'questions'
require_relative 'model_base'

class QuestionLike < ModelBase
  attr_accessor :question_id, :liker_id

  def self.likers_for_question_id(question_id)
    likes = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        question_likes
      JOIN
        users ON question_likes.liker_id = users.id
      WHERE
        question_id = ?
    SQL
    return nil unless likes.length > 0

    result = []
    likes.each do |like|
      result << User.new(like)
    end

    result
  end

  def self.liked_questions_for_user_id(liker_id)
    likes = QuestionsDBConnection.instance.execute(<<-SQL, liker_id)
      SELECT
        questions.*
      FROM
        question_likes
      JOIN
        questions ON question_likes.question_id = questions.id
      WHERE
        liker_id = ?
    SQL
    return nil unless likes.length > 0

    result = []
    likes.each do |like|
      result << Question.new(like)
    end

    result
  end

  def self.num_likes_for_question_id(question_id)
    likes = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        question_id, COUNT(*) AS num_likes
      FROM
        question_likes
      WHERE
        question_id = ?
      GROUP BY
        question_id
    SQL
    return nil unless likes.length > 0

    likes.first["num_likes"]
  end

  def self.most_liked_questions(n)
  questions = QuestionsDBConnection.instance.execute(<<-SQL, n)
    SELECT
      questions.*, COUNT(*)
    FROM
      question_likes
    JOIN
      questions ON questions.id = question_likes.question_id
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
    @liker_id = options['liker_id']
  end

end
