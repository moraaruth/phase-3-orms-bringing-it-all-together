require 'pry'
require_relative "../config/environment.rb"

class Dog

    attr_accessor :name, :breed, :id

    def initialize (name, breed, id: nil)
        @id = id
        @name = name
        @breed = breed
    end

    #class method on Dog that will execute the correct SQL to create a dogs table
    
    def self.create_table
        #store that in a variable called sql using a heredoc (<<-) since our string will go onto multiple lines:
        sql = <<-SQL
         CREATE TABLE IF NOT EXISTS dogs (
             id INTEGER PRIMARY KEY,
             name TEXT
             breed TEXT
         )

        SQL
        #call to our database using DB[:conn]. This DB hash is located in the config/environment.rb file
        DB[:conn].excute(sql)
    end

   #drop the dogs table from the database
   def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
   end

   #save will insert a new record into the database and return the instance
   def save
    if self.id
        self.update
    else 
        sql = <<-SQL
          INSERT INTO dogs (name, breed)
          VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
   end

   #reusing save to return new row and new instance of the Dog class
   def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
   end

   #return an array representing a dog's data
   #cast that data into the appropriate attributes of a dog
   def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE name = ?
          AND breed = ?
          LIMIT 1
    SQL
    
    dog = DB[:conn].execute(sql, name, breed)

    if !dog.empty?
        dog_data = dog[0]
        dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
        dog = self.create(name: name, breed: breed)
    end
    dog
    end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        self.new(id: id, name: name, breed: breed)
    end

    def self.find_by_name(name)
        sql = <<-SQL
           SELECT 8
           FROM dogs
           WHERE name = ?
           LIMIT 1
        SQL

        DB[:conn].execute(sql,name).map do |row|
            self.new_from_db(row)
        end.first
    end

    #class method takes in an ID, and should return a single Dog
    def self.find_by_id(id)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
        LIMIT 1
        SQL

        DB[:conn].execute(sql,id).map do |row|
            self.new_from_db(row)
        end.first
    end
    #class method takes in an ID, and should return a single Dog
    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE  id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end 
