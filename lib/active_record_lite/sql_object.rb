require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'
require 'active_support/inflector'

# require 'pry'
# require 'debugger'


class SQLObject < MassObject
  
  extend Searchable, Associatable

  def self.set_table_name(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name.underscore
  end

  def self.all
    hashes_arr = DBConnection.execute("
        SELECT
          *
        FROM
          #{table_name}
      ")
    parse_all(hashes_arr)
  end

  def self.find(id)
    hashes_arr = DBConnection.execute("
        SELECT
          *
        FROM
          #{table_name}  
        WHERE
          #{table_name}.id = #{id}
      ")
    parse_all(hashes_arr).first
  end

  def save
    self.id ? update : create
  end

  private

  def create
    query = attribute_values

    DBConnection.execute("
      INSERT INTO
        #{self.class.table_name} (#{query[:columns].join(", ")})
      VALUES
        (#{query[:question_mark_str]})
      ", *(query[:values]))
    
    self.id = self.class.all.last.id
  end

  def update
    query = attribute_values

    set_line = query[:columns].map{ |attribute| "#{attribute} = ?" }.join(", ")

    DBConnection.execute("
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        #{self.class.table_name}.id = #{@id}
      ", *(query[:values]))
  end

  def attribute_values
    output_info = Hash.new

    columns = self.class.attributes.map{|sym| sym.to_s }

    output_info[:columns] = columns
    
    output_info[:question_mark_str] = columns.map{|sym| "?" }.join(", ")

    output_info[:values] = columns.map { |attribute| self.send(attribute) }

    output_info
  end
end
