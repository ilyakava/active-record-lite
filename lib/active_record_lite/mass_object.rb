class MassObject
  def self.set_attrs(*attributes)
  	@attribute_arr = attributes.map{ |str| str.to_sym }
  	attr_accessor *attributes
  end

  def self.attributes
  	@attribute_arr
  end

  def self.parse_all(hashes_arr)
  	set_attrs(*hashes_arr.first.keys)
    obj_arr = []
    hashes_arr.each do |hash|
      obj_arr << new(hash)
    end
    obj_arr
  end

  def initialize(params = {})
  	params.each do |attribute, value|
  		if self.class.attributes.include?(attribute.to_sym)
  			send("#{attribute}=", value)
  		else
  			raise "Mass assignment to unregistered attribute #{attribute}"
  		end
  	end
  end
end


class MyClass < MassObject

	set_attrs :x, :y

end