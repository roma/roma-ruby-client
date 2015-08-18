require File.expand_path(File.join('..', '..', 'spec_helper'), File.dirname(__FILE__))

describe Roma::Client::VERSION do
  it 'should string' do
    expect(Roma::Client::VERSION::STRING).to eq(
      "#{Roma::Client::VERSION::MAJOR}." +
      "#{Roma::Client::VERSION::MINOR}." +
      "#{Roma::Client::VERSION::TINY}"
    )
  end
end
