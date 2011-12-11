module Carl
  class Base
    include Enumerable

    class << self
      attr_accessor :config

      def connection
        @connection ||= establish_connection
      end

      def establish_connection(config={:keyspace => 'carl', :hosts => ['localhost:9160']})
        @config = config
        @connection = CassandraCQL::Database.new config[:hosts], :keyspace => config[:keyspace]
      end
    end

    # Define single argument methods
    [:from, :using_consistency, :limit, :count, :column_limit, :reversed, :truncate].each do |meth|
      class_eval %Q$
        attr_accessor :#{meth}_value

        def #{meth}(value=true)
          clone.tap {|c| c.#{meth}_value = value }
        end
      $
    end

    # Define multiple argument methods
    [:select, :range].each do |meth|
      class_eval %Q$
        attr_accessor :#{meth}_values

        def #{meth}(*values)
          clone.tap {|c| c.#{meth}_values = values }
        end
      $
    end

    # Define "additive" methods
    attr_accessor :where_sql, :where_bindings
    def where(*conditions)
      clone.tap do |c|
        c.where_sql ||= []
        c.where_bindings ||= []
        # Simple conditions: {:condition => 42}

        if conditions.first.is_a?(Hash)
          conditions.first.each do |k,v|
            c.where_sql << "#{k} = ?"
            c.where_bindings << v
          end
        elsif conditions.first.is_a?(String)
          c.where_sql << conditions.shift
          c.where_bindings += conditions
        end
      end
    end

    alias :and :where

    # Build query
    def query
      @sql = []
      @bindings = []
      # TRUNCATE 
      if truncate_value
       add_to_sql "TRUNCATE ?", truncate_value 
       return [@sql.join(" ")] + @bindings
      end
      # SELECT
      add_to_sql "SELECT" 
      if select_values
        add_to_sql (["?"] * select_values.count).join(", "), *select_values.map(&:to_s)
      elsif count_value
        add_to_sql "COUNT(*)"
      else
        add_to_sql "FIRST ?", column_limit_value if column_limit_value
        add_to_sql "REVERSED" if reversed_value
        if range_values
          add_to_sql (["?"] * range_values.count).join(" .. "), *range_values
        else
          add_to_sql "*"
        end
      end

      # FROM
      add_to_sql "FROM ?", from_value if from_value

      # USING CONSISTENCY
      add_to_sql "USING CONSISTENCY ?", using_consistency_value.to_s if using_consistency_value

      # WHERE
      if where_sql && !where_sql.empty?
        add_to_sql "WHERE"
        add_to_sql where_sql.join(" AND "), *where_bindings
      end

      # LIMIT
      add_to_sql "LIMIT ?", limit_value if limit_value

      [@sql.join(" ")] + @bindings
    end
    
    def execute
      self.class.connection.execute(*query)
    end

    def to_hash
      execute.result.fetch_hash
    end

    def each
      to_hash.each do |_,v|
        yield v
      end
    end

    private

    def add_to_sql(*args)
      @sql << args.shift
      @bindings += args
    end

  end
end
