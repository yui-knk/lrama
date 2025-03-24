# frozen_string_literal: true

RSpec.describe Lrama::Grammar::LexerState::PatternPredication::AllPattern do
  let(:state_bit_1) { Lrama::Grammar::LexerState::StateBit.new(0, "EXPR_BEG") }
  let(:state_bit_2) { Lrama::Grammar::LexerState::StateBit.new(1, "EXPR_MID") }
  let(:state_bit_3) { Lrama::Grammar::LexerState::StateBit.new(2, "EXPR_END") }
  let(:pattern) do
    pattern = Lrama::Grammar::LexerState::PatternPredication::AllPattern.new(state_bit_1)
    pattern.add_state_bit(state_bit_2)
    pattern
  end

  describe "#match?" do
    it "returns true if passed state matchs at least one of the state bit" do
      expect(pattern.match?(Lrama::Grammar::LexerState::State.new([state_bit_1, state_bit_2]))).to be true
    end

    it "returns false if passed state doesn't matchs any of the state bit" do
      expect(pattern.match?(Lrama::Grammar::LexerState::State.new([]))).to be false
      expect(pattern.match?(Lrama::Grammar::LexerState::State.new([state_bit_1]))).to be false
      expect(pattern.match?(Lrama::Grammar::LexerState::State.new([state_bit_2]))).to be false
      expect(pattern.match?(Lrama::Grammar::LexerState::State.new([state_bit_3]))).to be false
      expect(pattern.match?(Lrama::Grammar::LexerState::State.new([state_bit_1, state_bit_3]))).to be false
    end
  end

  describe "#to_s" do
    it "returns string which represents its state" do
      expect(pattern.to_s).to eq("all of (EXPR_BEG|EXPR_MID)")
    end
  end
end
