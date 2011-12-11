require 'spec_helper'

describe Carl::Base do
  it "should have a Cassandra connection" do
    Carl::Base.connection.should be_kind_of CassandraCQL::Database
  end

  it "should establish a connection with given parameters" do
    CassandraCQL::Database.should_receive(:new).with(['localhost:9160'], :keyspace => 'carl')
    Carl::Base.establish_connection :keyspace => 'carl', :hosts => ['localhost:9160']
  end

  subject { Carl::Base.new.select('row-name').from('my_cf') }

  context "simple queries" do

    it "should generate a simple query" do
      expect { subject }.to generate_query 'SELECT ? FROM ?', 'row-name', 'my_cf'
    end
    
    it "should fallback to SELECT *" do
      expect { Carl::Base.new.from('my_cf') }.to generate_query 'SELECT * FROM ?', 'my_cf'
    end

    it "should allow to specify a consistency level" do
      expect { subject.using_consistency(:quorum) }.to generate_query 'SELECT ? FROM ? USING CONSISTENCY ?', 'row-name', 'my_cf', 'quorum'
    end

    it "should allow to specify a limit" do
      expect { subject.limit(10) }.to generate_query 'SELECT ? FROM ? LIMIT ?', 'row-name', 'my_cf', 10
    end
  end
  
  context "conditions" do
    it "should allow to specify simple conditions" do
      expect { subject.where(:condition => 42) }.to generate_query 'SELECT ? FROM ? WHERE condition = ?', 'row-name', 'my_cf', 42
    end

    it "should allow to specify multiple conditions chained by AND" do
      expect { subject.where(:condition1 => 42).and(:condition2 => 24) }.to generate_query 'SELECT ? FROM ? WHERE condition1 = ? AND condition2 = ?', 'row-name', 'my_cf', 42, 24
    end

    it "should allow to specify CQL in conditions" do
      expect { subject.where("condition => 42") }.to generate_query 'SELECT ? FROM ? WHERE condition => 42', 'row-name', 'my_cf'
    end

    it "should allow to add bindings to string conditions" do
      expect { subject.where("condition1 = ? and condition2 = ?", 24, 42) }.to generate_query 'SELECT ? FROM ? WHERE condition1 = ? and condition2 = ?', 'row-name', 'my_cf', 24, 42
    end
  end

  context "projections" do

    subject { Carl::Base.new.from('my_cf') }
    
    it "should count rows" do
      expect { subject.count }.to generate_query 'SELECT COUNT(*) FROM ?', 'my_cf'
    end

    it "should allow multiple columns" do
      expect { subject.select(:column1, :column2) }.to generate_query 'SELECT ?, ? FROM ?', 'column1', 'column2', 'my_cf'
    end

    it "should accept ranges" do
      expect { subject.range(24, 42) }.to generate_query 'SELECT ? .. ? FROM ?', 24, 42, 'my_cf'
    end

    it "should allow FIRST statements" do
      # We don't use #first as it is already taken by Enumerable
      expect { subject.column_limit(10) }.to generate_query 'SELECT FIRST ? * FROM ?', 10, 'my_cf'
    end

    it "should allow REVERSED keyword" do
      expect { subject.reversed }.to generate_query 'SELECT REVERSED * FROM ?', 'my_cf'
    end
  end


  context "deletions" do
    subject { Carl::Base.new }
    it "should truncate column family" do
      expect { subject.truncate('my_cf')}.to generate_query 'TRUNCATE ?', 'my_cf'
    end

  end

  context "execution" do
    subject { Carl::Base.new.from('my_cf') }

    it "should execute the query" do
      Carl::Base.connection.should_receive(:execute).with(*subject.query)
      subject.execute
    end
  end
end
