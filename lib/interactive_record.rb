require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        DB[:conn].results_as_hash=true
        sql="pragma table_info('#{table_name}')"
        table_info=DB[:conn].execute(sql)
        column_names=[]
        table_info.each do |row| 
            column_names << row["name"]
        end
        column_names.compact
    end

    def initialize(columns={})
        columns.each{|property,value| self.send("#{property}=",value)}
    end

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names.delete_if{|column| column=="id"}.join(", ")
    end

    def values_for_insert
        values=[]
        self.class.column_names.each do |column_name| 
            values << "'#{send(column_name)}'" unless send(column_name).nil?
        end
        values.join(", ")
    end

    def save
        sql= <<-SQL
        INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
        VALUES (#{values_for_insert})
        SQL
        DB[:conn].execute(sql).flatten
        @id=DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name)
        sql= <<-SQL
        SELECT * FROM #{self.table_name}
        WHERE name=?
        SQL
        DB[:conn].execute(sql,name)
    end

    def self.find_by(info)
        # binding.pry
        sql= <<-SQL
        SELECT * FROM #{self.table_name}
        WHERE #{info.flatten[0].to_s}="#{info.flatten[1]}"
        SQL
        DB[:conn].execute(sql)
    end
end