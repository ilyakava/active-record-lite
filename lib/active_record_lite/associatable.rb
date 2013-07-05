require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

# require_relative '../../test/associatable.rb'
# require_relative './sql_object.rb'

class AssocParams
  def other_class
    # Human / House
    @other_class_name.constantize
  end

  def other_table
    # "humans" / "houses"
    @other_class_name.constantize.table_name
  end
end

class BelongsToAssocParams < AssocParams
  
  attr_reader :other_class_name, :primary_key, :foreign_key

  def initialize(name, params = {})
    # same as HasManyAssocParams
    # "Human" / "House"
    @other_class_name = params[:class_name] || name.to_s.camelize.singularize
    # "id" / "id"
    @primary_key = params[:primary_key] || :id
    # "owner_id" / "house_id"
    @foreign_key = params[:foreign_key] || "#{name.to_s.singularize}_id"
  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  
  attr_reader :other_class_name, :primary_key, :foreign_key

  def initialize(name, params, self_class = self.class)
    @other_class_name = params[:class_name] || name.to_s.camelize.singularize
    @primary_key = params[:primary_key] || :id
    @foreign_key = params[:foreign_key] || "#{name.to_s.singularize}_id"
  end

  def type
  end
end

module Associatable

  def assoc_params
    @assoc_params ||= Hash.new
  end


  def belongs_to(name, params = {})

    aps = BelongsToAssocParams.new(name, params)
    assoc_params[name] = BelongsToAssocParams.new(name, params)

    define_method "#{aps.other_class_name.downcase}" do

      hashes_arr = DBConnection.execute("
        SELECT
          *
        FROM
          #{aps.other_table}
        WHERE
          #{aps.other_table}.#{aps.primary_key} = #{self.send(aps.foreign_key)}
        ")

      aps.other_class.parse_all(hashes_arr).first
    end
  end

  def has_many(name, params = {})
    aps = HasManyAssocParams.new(name, params)

    define_method(name) do

      hashes_arr = DBConnection.execute("
        SELECT
          *
        FROM
          #{aps.other_table}
        WHERE
          #{aps.other_table}.#{aps.foreign_key} = #{aps.primary_key}
        ")

      aps.other_class.parse_all(hashes_arr)
    end
  end

  def has_one_through(name, assoc1, assoc2)
    

    define_method(name) do
      
      father = self.class.assoc_params[assoc1]
      grandfather = father.other_class.assoc_params[assoc2]

      father_id = self.send(father.foreign_key)


      hashes_arr = DBConnection.execute("
        SELECT
          *
        FROM
          #{father.other_table} JOIN #{grandfather.other_table}
          ON #{father.other_table}.#{grandfather.foreign_key} = #{grandfather.other_table}.id
        WHERE
          #{father.other_table}.id = #{father_id}
        ")
      grandfather.other_class.parse_all(hashes_arr)
    end
  end
end
