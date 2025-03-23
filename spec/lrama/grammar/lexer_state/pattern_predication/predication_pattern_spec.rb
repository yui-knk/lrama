# frozen_string_literal: true

RSpec.describe Lrama::Grammar::LexerState::PatternPredication::PredicationPattern do
  let(:state_bit_1) { Lrama::Grammar::LexerState::StateBit.new("EXPR_BEG") }
  let(:state_bit_2) { Lrama::Grammar::LexerState::StateBit.new("EXPR_MID") }
  let(:state_bit_3) { Lrama::Grammar::LexerState::StateBit.new("EXPR_END") }
  let(:pattern) do
    pattern = Lrama::Grammar::LexerState::PatternPredication::Pattern.new(state_bit_1)
    pattern.add_state_bit(state_bit_2)
    pattern
  end
  let(:predication) { Lrama::Grammar::LexerState::PatternPredication.new("IS_BEG_ANY", pattern, false) }
  let(:predication_pattern) { Lrama::Grammar::LexerState::PatternPredication::PredicationPattern.new(predication) }

  describe "#match?" do
    it "returns true if passed state matchs with predication" do
      expect(predication_pattern.match?(Set[state_bit_1])).to be true
      expect(predication_pattern.match?(Set[state_bit_2])).to be true
      expect(predication_pattern.match?(Set[state_bit_1, state_bit_2])).to be true
      expect(predication_pattern.match?(Set[state_bit_1, state_bit_3])).to be true
    end

    it "returns false if passed state doesn't matchs with predication" do
      expect(predication_pattern.match?(Set[])).to be false
      expect(predication_pattern.match?(Set[state_bit_3])).to be false
    end
  end

  describe "#to_s" do
    it "returns string which represents its predication" do
      expect(predication_pattern.to_s).to eq("IS_BEG_ANY")
    end
  end
end
