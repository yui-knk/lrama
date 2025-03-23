# frozen_string_literal: true

RSpec.describe Lrama::Grammar::LexerState::PatternPredication::OrPattern do
  let(:state_bit_1) { Lrama::Grammar::LexerState::StateBit.new("EXPR_BEG") }
  let(:state_bit_2) { Lrama::Grammar::LexerState::StateBit.new("EXPR_MID") }
  let(:state_bit_3) { Lrama::Grammar::LexerState::StateBit.new("EXPR_END") }
  let(:pattern_1) { Lrama::Grammar::LexerState::PatternPredication::Pattern.new(state_bit_1) }
  let(:pattern_2) { Lrama::Grammar::LexerState::PatternPredication::Pattern.new(state_bit_2) }
  let(:or_pattern) { Lrama::Grammar::LexerState::PatternPredication::OrPattern.new(pattern_1, pattern_2) }

  describe "#match?" do
    it "returns true if left or right match with passed state" do
      expect(or_pattern.match?(Set[state_bit_1])).to be true
      expect(or_pattern.match?(Set[state_bit_2])).to be true
    end

    it "returns true if left and right don't match with passed state" do
      expect(or_pattern.match?(Set[])).to be false
      expect(or_pattern.match?(Set[state_bit_3])).to be false
    end
  end

  describe "#to_s" do
    it "returns string which represents its left and right" do
      expect(or_pattern.to_s).to eq("(EXPR_BEG || EXPR_MID)")
    end
  end
end
