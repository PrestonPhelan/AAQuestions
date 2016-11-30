class ModelBase

  HASH = {
    User: 'users',
    Reply: 'replies',
    Question: 'questions',
    QuestionLike: 'question_likes',
    QuestionFollow: 'question_follows'
  }.freeze

  def self.all
    table = HASH[self.name.to_sym]
    query = <<-SQL
      SELECT
      *
      FROM
      #{table}
    SQL

    data = QuestionsDBConnection.instance.execute(query)
    data.map { |datum| self.new(datum) }
  end


  def self.find_by_id(id)
    table = HASH[self.name.to_sym]
    query = <<-SQL, id
      SELECT
        *
      FROM
        #{table}
      WHERE
        id = ?
    SQL
    result = QuestionsDBConnection.instance.execute(query, id)
    return nil unless result.length > 0

    self.new(result.first)
  end

  def save
    var = instance_variables.delete(:@id)
    set_string = ""
    var.each_with_index do |v, idx|
      set_string << v.to_s + " = ?"
      set_string << ", " unless idx == var.length - 1
    end

    table = HASH[self.name.to_sym]
    if @id
      query = <<-SQL
        UPDATE
          #{table}
        SET
          #{set_string}
        WHERE
          id = ?
      SQL

      var << :@id
      QuestionsDBConnection.instance.execute(query, *var)
    else
      insert_string = ""
      var.each_with_index do |v, idx|
        insert_string << v.to_s
        insert_string << ", " unless idx == var.length - 1
      end

      values_string = ""
      var.length.times do
        values_string << "?, "
      end
      values_string = values_string[0...-2]

      query = <<-SQL
        INSERT INTO
          #{table} (#{insert_string})
        VALUES
          (#{values_string})
      SQL

      QuestionsDBConnection.instance.execute(query, *var)
      @id = QuestionsDBConnection.instance.last_insert_row_id
    end
  end
end
