require 'sqlite3'

# Methods to make sqlite3 interation more concise.
module SQLite3Tools

	# Array methods.
	class ::Array
		# Converts an array of symbols to a string of backquoted strings for use in SELECT statement
		# @return [String]
		# @example
		#  a = [ :col_1, :col_2 ]
		#  a.sqlite3_to_str #=> "`col_1`, `col_2`"
		def sqlite3_to_str
			self.map { |sym| "`" + sym.to_s + "`" }.join(", ")
		end

		# Converts an sqlite3 result array to a hash.
		# @param keys [Array]
		# @return [Hash]
		# @example
		#  a = [ "val_1", 42 ]
		#  k = [ :col_1, :col_2 ]
		#  a.to_hash k #=> { :col_1 => "val_1", :col_2 => 42 }
		def to_hash keys
			Hash[ *( 0...self.size ).inject( [] ) { |arr, ix| arr.push( keys[ix], self[ix] ) } ]
		end
	end

	# Integer methods.
	class ::Integer
		# Generates placeholder string for INSERT statements.
		# @return String placeholder
		# @example
		#  3.make_placeholders #=> "?, ?, ?"
		def make_placeholders
			n = self - 1
			placeholders = "?"
			n.times { placeholders << ", ?" }
			placeholders
		end
	end

	# SQLite3 database methods.
	class SQLite3::Database
		# Selects given columns using given query and converts results to to hashes.
		# @param [Array<Symbol>] columns names of columns to select
		# @param [String] query sqlite3 query fragment to append to SELECT part of query
		# @return [Array<Hash>] results with each row a hash in :col => value form
		def select columns, query
			result = [];
			self.execute "SELECT #{columns.sqlite3_to_str} #{query}" do |row|
				result.push row.to_hash columns
			end
			result
		end
	end
end

# Backend abstracts database interactions.
class Backend < Kit

	include SQLite3Tools

	attr_reader :db_paths

	# (see #db_prepare)
	def initialize db_paths
		db_paths.each do |key, db|
			name = File.basename db
			dir = File.dirname db
			dir = @@config_path unless [ "/", "~" ].include? dir[0]
			db_paths[key] = "#{dir}/#{name}"
		end

		@db_paths = db_paths

		dbs = db_prepare @db_paths
		@info_db = dbs[:info]
		@action_db = dbs[:actions]
	end

	private
	# Loads existing database files or creates new ones with kit database schema
	# @param [Hash] db_paths absolute or relitive paths to database files
	def db_prepare db_paths

		# Makes kit database schema
		# @param [Symbol] type name of database
		# @param db [SQLite3::Database] database object to load schema into
		def db_initialize type, db
			sql = File.read @@kit_path + "/sqlite3_#{type}.sql"
			db.execute_batch sql
		end

		dbs = {}
		db_paths.each do |type, path|
			dbs[type] = [ ( File.exists? path ), ( SQLite3::Database.new path ) ]
		end

		# Set sqlite3 options here
		dbs.each do |type, db|
			db[1].type_translation = true
		end

		dbs.each do |type, db|
			begin
				( db_initialize type, db[1] ) unless db[0]
			rescue
				File.delete db_paths[type]
			end
		end

		dbs.each do |type, db|
			dbs[type] = db[1]
		end

		return dbs

	end

	public

	# Deletes database files.
	def delete
		@db_paths.each do |key, f|
			File.delete f
		end
	end

	# Gets the row from an info table with the given id.
	# @param [Symbol] table what database table to query
	# @param [Array] fields list of column names to return
	# @param [Integer] id rowid of record to return
	# @return [Hash] first matched row with a key for each requested field
	def select_info_by_id table, fields, id
		info = @info_db.select fields, "FROM `#{table}` WHERE `rowid` = '#{id}'"
		info.first
	end

	# Gets the rows from an info table with the given name.
	# @param table (see #select_info_by_id)
	# @param fields (see #select_info_by_id)
	# @param [String] name of records to return
	# @return (see #select_info_by_id)
	def select_info_by_name table, fields, name
		info = @info_db.select fields, "FROM `#{table}` WHERE `name` = '#{name}'"
		info.first
	end

	# Gets the rows from an info table with the given criteria.
	# @param table (see #select_info_by_id)
	# @param fields (see #select_info_by_id)
	# @param [Hash] criteria key / value pairs required to match
	# @return [Array] hash for each returned row with a key for each requested field
	def select_info_by_criteria table, fields, criteria
		q = []
		criteria.each do |key, value|
			q << "`#{key}` = '#{value}'"
		end

		info = @info_db.select fields, "FROM `#{table}` WHERE #{q.join " AND "}"
	end

	# Inserts a new row into an info table.
	# @param table (see #select_info_by_id)
	# @param [Hash] data key / value pairs for new row
	# @return [Integer] rowid of new row
	def insert_info table, data
		@info_db.execute "INSERT INTO #{table} ( `#{data.keys.join "`, `"}` ) VALUES ( #{data.length.make_placeholders} )", data.values
		@info_db.last_insert_row_id
	end

	# Gets the rows from the action table with given status.
	# @param table (see #select_info_by_id)
	# @param fields (see #select_info_by_id)
	# @param [Symbol] status name of status to match
	# @return (see #select_info_by_id)
	def select_all_actions_by_status table, fields, status
		query = "FROM `#{table}` WHERE `status` = '#{status}'"
		rows = @action_db.select fields, query

		rows.map { |t| t.merge ( { :action => table, :status => t[:status].to_sym } ) }
	end

	# Inserts a new row into an action table.
	# @param (see #insert_info)
	# @return (see #insert_info)
	def insert_action table, data
		data.merge! ( { :status => :pending.to_s, :time => Time.now.to_i  } )
		@action_db.execute "INSERT INTO #{table} ( `#{data.keys.join "`, `"}` ) VALUES ( #{data.length.make_placeholders} )", data.values
		@action_db.last_insert_row_id
	end

	# Updates the status of a task in an action table.
	# @param [Symbol] table name of the action table
	# @param [Integer] action rowid to update
	# @param [Hash] data key / value pairs to set
	def update_action_status table, id, data
		data.merge! ( { :status => data[:status].to_s, :time => Time.now.to_i } )
		set = []
		data.each do |key, value|
			set << "`#{key}` = '#{value}'"
		end

		@action_db.execute "UPDATE #{table} SET #{set.join ", "} WHERE `rowid` = '#{id}'"
	end

	# 	def delete_action_by_id action, id
	# 		puts "DELETE FROM `#{action}` WHERE `rowid` = #{id}"
	# 	end

end
