require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

# require_relative '../../test/associatable.rb'
# require_relative './sql_object.rb'

class AssocParams
  def other_class
  end

  def other_table
  end
end

class BelongsToAssocParams < AssocParams
  def initialize(name, params)
  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, self_class)
  end

  def type
  end
end

module Associatable

  def assoc_params(name, params = {})
    {
      :other_class_name => (params[:class_name] || name.to_s.camelize.singularize),
      :primary_key => (params[:primary_key] || :id),
      :foreign_key => (params[:foreign_key] || "#{name.to_s.singularize}_id")
    }
  end

  def belongs_to(name, params = {})

    relations = assoc_params(name, params)

    other_class_name = relations[:other_class_name]
    primary_key = relations[:primary_key]
    foreign_key = relations[:foreign_key]
  

    define_method "#{other_class_name.downcase}" do
      other_class = other_class_name.constantize

      other_table_name = other_class.table_name

      hashes_arr = DBConnection.execute("
        SELECT
          *
        FROM
          #{other_table_name}
        WHERE
          #{other_table_name}.id = #{self.send(foreign_key)}
        ")

      other_class.parse_all(hashes_arr).first
    end
  end

  def has_many(name, params = {})
    relations = assoc_params(name, params)

    other_class_name = relations[:other_class_name]
    primary_key = relations[:primary_key]
    foreign_key = relations[:foreign_key]
  
    define_method "#{other_class_name.downcase.pluralize}" do
      other_class = other_class_name.constantize

      other_table_name = other_class.table_name

      hashes_arr = DBConnection.execute("
        SELECT
          *
        FROM
          #{other_table_name}
        WHERE
          #{other_table_name}.#{foreign_key} = #{self.id}
        ")

      other_class.parse_all(hashes_arr)
    end
  end

  def has_one_through(name, assoc1, assoc2)
  end
end
