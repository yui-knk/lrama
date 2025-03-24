# frozen_string_literal: true

RSpec.describe Lrama::Grammar::LexerState::PatternPredication do
  let(:state_bit_1) { Lrama::Grammar::LexerState::StateBit.new(0, "EXPR_BEG") }
  let(:state_bit_2) { Lrama::Grammar::LexerState::StateBit.new(1, "EXPR_MID") }
  let(:state_bit_3) { Lrama::Grammar::LexerState::StateBit.new(2, "EXPR_END") }
  let(:pattern) do
    pattern = Lrama::Grammar::LexerState::PatternPredication::Pattern.new(state_bit_1)
    pattern.add_state_bit(state_bit_2)
    pattern
  end
  let(:pattern_2) do
    Lrama::Grammar::LexerState::PatternPredication::Pattern.new(state_bit_1)
  end
  let(:predication) { Lrama::Grammar::LexerState::PatternPredication.new("IS_BEG_ANY", pattern, false) }
  let(:n_predication) { Lrama::Grammar::LexerState::PatternPredication.new("IS_BEG_ANY", pattern, true) }

  describe "#name" do
    it "returns name of predication" do
      expect(predication.name).to eq("IS_BEG_ANY")
      expect(n_predication.name).to eq("IS_BEG_ANY")
    end
  end

  describe "#==" do
    it "returns true if pattern and negative are same otherwise returns false" do
      predication_1 = Lrama::Grammar::LexerState::PatternPredication.new("IS_BEG_ANY_2", pattern, false)
      predication_2 = Lrama::Grammar::LexerState::PatternPredication.new("IS_BEG_ANY", pattern, true)
      predication_3 = Lrama::Grammar::LexerState::PatternPredication.new("IS_BEG_ANY", pattern_2, false)

      expect(predication == predication).to be true
      expect(predication == predication_1).to be true
      expect(predication == predication_2).to be false
      expect(predication == predication_3).to be false
    end
  end

  describe "#match?" do
    context "it's positive predication" do
      it "returns true if passed state matchs with pattern" do
        expect(predication.match?(Lrama::Grammar::LexerState::State.new([state_bit_1]))).to be true
        expect(predication.match?(Lrama::Grammar::LexerState::State.new([state_bit_2]))).to be true
        expect(predication.match?(Lrama::Grammar::LexerState::State.new([state_bit_1, state_bit_2]))).to be true
        expect(predication.match?(Lrama::Grammar::LexerState::State.new([state_bit_1, state_bit_3]))).to be true
      end

      it "returns false if passed state doesn't matchs with pattern" do
        expect(predication.match?(Lrama::Grammar::LexerState::State.new([state_bit_3]))).to be false
      end
    end

    context "it's negative predication" do
      it "returns false if passed state matchs with pattern" do
        expect(n_predication.match?(Lrama::Grammar::LexerState::State.new([state_bit_1]))).to be false
        expect(n_predication.match?(Lrama::Grammar::LexerState::State.new([state_bit_2]))).to be false
        expect(n_predication.match?(Lrama::Grammar::LexerState::State.new([state_bit_1, state_bit_2]))).to be false
        expect(n_predication.match?(Lrama::Grammar::LexerState::State.new([state_bit_1, state_bit_3]))).to be false
      end

      it "returns true if passed state doesn't matchs with pattern" do
        expect(n_predication.match?(Lrama::Grammar::LexerState::State.new([state_bit_3]))).to be true
      end
    end
  end

  describe "#negative_predication" do
    it "returns negative version of the predication" do
      predication_2 = predication.negative_predication
      expect(predication_2.name).to eq("IS_BEG_ANY")
      expect(predication_2.pattern).to eq(predication.pattern)
      expect(predication_2.negative).to be true

      predication_3 = n_predication.negative_predication
      expect(predication_3.name).to eq("IS_BEG_ANY")
      expect(predication_3.pattern).to eq(n_predication.pattern)
      expect(predication_3.negative).to be false
    end
  end
end
