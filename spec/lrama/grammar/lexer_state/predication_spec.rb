# frozen_string_literal: true

require "set"

RSpec.describe Lrama::Grammar::LexerState::Predication do
  let(:state_bit_1) { Lrama::Grammar::LexerState::StateBit.new("EXPR_BEG") }
  let(:state_bit_2) { Lrama::Grammar::LexerState::StateBit.new("EXPR_MID") }
  let(:state_bit_3) { Lrama::Grammar::LexerState::StateBit.new("EXPR_END") }
  let(:pattern) do
    pattern = Lrama::Grammar::LexerState::Predication::Pattern.new(state_bit_1)
    pattern.add_state_bit(state_bit_2)
    pattern
  end
  let(:predication) { Lrama::Grammar::LexerState::Predication.new("IS_BEG_ANY", pattern, false) }
  let(:n_predication) { Lrama::Grammar::LexerState::Predication.new("IS_BEG_ANY", pattern, true) }

  describe "#name" do
    it "returns name of predication" do
      expect(predication.name).to eq("IS_BEG_ANY")
      expect(n_predication.name).to eq("IS_BEG_ANY")
    end
  end

  describe "#match?" do
    context "it's positive predication" do
      it "returns true if passed state matchs with pattern" do
        expect(predication.match?(Set[state_bit_1])).to be true
        expect(predication.match?(Set[state_bit_2])).to be true
        expect(predication.match?(Set[state_bit_1, state_bit_2])).to be true
        expect(predication.match?(Set[state_bit_1, state_bit_3])).to be true
      end

      it "returns false if passed state doesn't matchs with pattern" do
        expect(predication.match?(Set[state_bit_3])).to be false
      end
    end

    context "it's negative predication" do
      it "returns false if passed state matchs with pattern" do
        expect(n_predication.match?(Set[state_bit_1])).to be false
        expect(n_predication.match?(Set[state_bit_2])).to be false
        expect(n_predication.match?(Set[state_bit_1, state_bit_2])).to be false
        expect(n_predication.match?(Set[state_bit_1, state_bit_3])).to be false
      end

      it "returns true if passed state doesn't matchs with pattern" do
        expect(n_predication.match?(Set[state_bit_3])).to be true
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
