require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

  def self.find_by(props={})
    if !props[:name].nil?
      find_by_name(props[:name])
    else
      sql = "SELECT * FROM #{self.table_name} WHERE grade = ?"
      DB[:conn].execute(sql, props[:grade])
    end
  end
end
