require_relative 'questions_database'
require_relative 'question_follow'
require_relative 'user'
require_relative 'reply'
require_relative 'question_like'
require_relative 'model_base'

class Question < ModelBase
  attr_accessor :title, :body, :author_id

  def self.find_by_author_id(author_id)
    questions = QuestionsDBConnection.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL
    return nil unless questions.length > 0

    result = []
    questions.each do |question|
      result << Question.new(question)
    end

    result
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def author
    User.find_by_id(@author_id)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end

  def save
    if @id
      ## UPDATE SET WHERE
      QuestionsDBConnection.instance.execute(<<-SQL, @title, @body, @author_id, @id)
        UPDATE
          questions
        SET
          title = ?, body = ?, author_id = ?
        WHERE
          id = ?
      SQL
    else
      ## Insert into
      QuestionsDBConnection.instance.execute(<<-SQL, @title, @body, @author_id)
        INSERT INTO
          questions (title, body, author_id)
        VALUES
          (?, ?, ?)
      SQL

      @id = QuestionsDBConnection.instance.last_insert_row_id
    end
  end
end
