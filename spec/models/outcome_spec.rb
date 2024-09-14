# spec/models/result_spec.rb
require 'rails_helper'

RSpec.describe Outcome, type: :model do
  describe '.success' do
    it 'creates a successful result with a value and message' do
      result = Outcome.success(42, 'Operation was successful')

      expect(result).to be_success
      expect(result.value).to eq(42)
      expect(result.message).to eq('Operation was successful')
    end

    it 'creates a successful result with default message' do
      result = Outcome.success(42)

      expect(result).to be_success
      expect(result.message).to eq('Success')
    end
  end

  describe '.failure' do
    it 'creates a failure result with a message' do
      result = Outcome.failure('Something went wrong')

      expect(result).to be_failure
      expect(result.value).to be_nil
      expect(result.message).to eq('Something went wrong')
    end

    it 'creates a failure result with default message' do
      result = Outcome.failure

      expect(result).to be_failure
      expect(result.message).to eq('Failure')
    end
  end
end
