# frozen_string_literal: true

require "set"

RSpec.describe Lrama::Grammar::LexerState::AnyPredication do
  let(:state_bit_1) { Lrama::Grammar::LexerState::StateBit.new("EXPR_BEG") }
  let(:state_bit_2) { Lrama::Grammar::LexerState::StateBit.new("EXPR_MID") }
  let(:state_bit_3) { Lrama::Grammar::LexerState::StateBit.new("EXPR_END") }
  let(:predication) { Lrama::Grammar::LexerState::AnyPredication.new }

  describe "#name" do
    it "returns '*'" do
      expect(predication.name).to eq("*")
    end
  end

  describe "#match?" do
    it "returns true for any state" do
      expect(predication.match?(Set[])).to be true
      expect(predication.match?(Set[state_bit_1])).to be true
      expect(predication.match?(Set[state_bit_2])).to be true
      expect(predication.match?(Set[state_bit_1, state_bit_2])).to be true
      expect(predication.match?(Set[state_bit_1, state_bit_3])).to be true
    end
  end
end
