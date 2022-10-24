# frozen_string_literal: true

require 'spec_helper'

describe PuppetlabsSpec::PuppetInternals do
  before(:all) do # this is only needed once # rubocop:disable RSpec/BeforeAfterAll
    Puppet.initialize_settings
  end

  describe '.scope' do
    subject(:scope) { described_class.scope }

    it 'returns a Puppet::Parser::Scope instance' do
      expect(scope).to be_a_kind_of Puppet::Parser::Scope
    end

    it 'is suitable for function testing' do
      expect(scope.function_inline_template(['foo'])).to eq('foo')
    end

    it 'accepts a compiler' do
      compiler = described_class.compiler
      scope = described_class.scope(compiler: compiler)
      expect(scope.compiler).to eq(compiler)
    end

    it 'has a source set' do
      expect(scope.source).not_to be_nil
      expect(scope.source.name).to eq('foo')
    end
  end

  describe '.resource' do
    subject(:resource) { described_class.resource }

    it 'can have a defined type' do
      expect(described_class.resource(type: :node).type).to eq(:node)
    end

    it 'defaults to a type of hostclass' do
      expect(resource.type).to eq(:hostclass)
    end

    it 'can have a defined name' do
      expect(described_class.resource(name: 'testingrsrc').name).to eq('testingrsrc')
    end

    it 'defaults to a name of testing' do
      expect(resource.name).to eq('testing')
    end
  end

  describe '.compiler' do
    let(:node) { described_class.node }

    it 'can have a defined node' do
      expect(described_class.compiler(node: node).node).to be node
    end
  end

  describe '.node' do
    it 'can have a defined name' do
      expect(described_class.node(name: 'mine').name).to eq('mine')
    end

    it 'can have a defined environment' do
      expect(described_class.node(environment: 'mine').environment.name).to eq(:mine)
    end

    it 'defaults to a name of testinghost' do
      expect(described_class.node.name).to eq('testinghost')
    end

    it 'accepts facts via options for rspec-puppet' do
      fact_values = { 'fqdn' => 'jeff.puppetlabs.com' }
      node = described_class.node(options: { parameters: fact_values })
      expect(node.parameters).to eq(fact_values)
    end
  end

  describe '.function_method' do
    it 'accepts an injected scope' do
      expect(Puppet::Parser::Functions).to receive(:function).with('my_func').and_return(true)
      scope = instance_double(described_class.scope.to_s)
      expect(scope).to receive(:method).with(:function_my_func).and_return(:fake_method)
      expect(described_class.function_method('my_func', scope: scope)).to eq(:fake_method)
    end

    it "returns nil if the function doesn't exist" do
      expect(Puppet::Parser::Functions).to receive(:function).with('my_func').and_return(false)
      scope = instance_double(described_class.scope.to_s)
      expect(described_class.function_method('my_func', scope: scope)).to be_nil
    end
  end
end
