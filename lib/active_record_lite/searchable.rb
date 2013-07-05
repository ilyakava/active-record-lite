require_relative './db_connection'

module Searchable
  
  def where(params)
  	where_clause = params.keys.map do |key|
  		"#{key.to_s} = ?"
  	end.join(" AND ")

  	match = DBConnection.execute("
			SELECT
				*
			FROM
				#{table_name}
			WHERE
				#{where_clause}
  		", *(params.values))
  	parse_all(match)
  end
end