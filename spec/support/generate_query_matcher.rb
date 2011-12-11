require 'rspec/expectations'

RSpec::Matchers.define :generate_query do |*query|
  match do |block|
    block.call.query == query
  end

  failure_message_for_should do |block|
    %Q(expected query "#{query}",\ngot query "#{block.call.query}")
  end
end
