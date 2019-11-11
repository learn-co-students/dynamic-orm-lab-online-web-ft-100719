require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |column|
      column_names << column["name"]
    end
    column_names.compact
  end

  def initialize(attributes={})
    attributes.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []

    self.class.column_names.each do |col_name|
        values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save
    DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})")
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM #{self.table_name}
    WHERE name = ?
    SQL

    DB[:conn].execute(sql, [name])
  end

  def self.find_by(attribute)
    # binding.pry
    if attribute.has_key?(:id)
      DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE id = ?", attribute.values)
    elsif attribute.has_key?(:name)
      DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?", attribute.values)
    elsif attribute.has_key?(:grade)
      DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE grade = ?", attribute.values)
    end
  end
end
