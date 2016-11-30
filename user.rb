require_relative 'questions_database'
require_relative 'questions'
require_relative 'reply'
require_relative 'question_follow'
require_relative 'question_like'
require_relative 'model_base'

class User < ModelBase
  attr_accessor :fname, :lname

  def self.find_by_name(fname, lname)
    user = QuestionsDBConnection.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    return nil unless user.length > 0

    result = []
    user.each do |u|
      result << Reply.new(u)
    end

    result
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    counts = QuestionsDBConnection.instance.execute(<<-SQL, @id)
      SELECT
        CAST(COUNT(DISTINCT(questions.id)) AS FLOAT) AS num_questions, COUNT(question_likes.liker_id) AS num_likes
      FROM
        questions
      LEFT OUTER JOIN
        question_likes ON questions.id = question_likes.question_id
      WHERE
        questions.author_id = ?
      GROUP BY
        questions.author_id
    SQL
    return nil unless counts.length > 0

    ## counts = [{ num_questions => X, num_likes => Y }]
    num_questions = counts.first['num_questions']
    num_likes = counts.first['num_likes']

    num_likes / num_questions
  end

  # def save
  #   if @id
  #     QuestionsDBConnection.instance.execute(<<-SQL, @fname, @lname, @id)
  #       UPDATE
  #         users
  #       SET
  #         fname = ?, lname = ?
  #       WHERE
  #         id = ?
  #     SQL
  #   else
  #     QuestionsDBConnection.instance.execute(<<-SQL, @fname, @lname)
  #       INSERT INTO
  #         users (fname, lname)
  #       VALUES
  #         (?, ?)
  #     SQL
  #
  #     @id = QuestionsDBConnection.instance.last_insert_row_id
  #   end
  # end
end
