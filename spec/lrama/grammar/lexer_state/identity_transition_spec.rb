# frozen_string_literal: true

RSpec.describe Lrama::Grammar::LexerState::IdentityTransition do
  let(:state_bit_1) { Lrama::Grammar::LexerState::StateBit.new(0, "EXPR_BEG") }
  let(:state_bit_2) { Lrama::Grammar::LexerState::StateBit.new(1, "EXPR_MID") }
  let(:state_bit_3) { Lrama::Grammar::LexerState::StateBit.new(2, "EXPR_END") }
  let(:pattern) do
    pattern = Lrama::Grammar::LexerState::PatternPredication::Pattern.new(state_bit_1)
    pattern.add_state_bit(state_bit_2)
    pattern
  end
  let(:predication) { Lrama::Grammar::LexerState::PatternPredication.new("IS_BEG_ANY", pattern, false) }
  let(:state_1) { Lrama::Grammar::LexerState::State.new([state_bit_1]) }
  let(:state_2) { Lrama::Grammar::LexerState::State.new([state_bit_2]) }
  let(:state_3) { Lrama::Grammar::LexerState::State.new([state_bit_3]) }
  let(:transition) { Lrama::Grammar::LexerState::Transition.new(predication, state_3) }
  let(:tdentity_transition) { Lrama::Grammar::LexerState::IdentityTransition.new }
  let(:tdentity_transition_2) { Lrama::Grammar::LexerState::IdentityTransition.new }

  describe "#==" do
    it "returns true if other is IdentityTransition" do
      expect(tdentity_transition == tdentity_transition).to be true
      expect(tdentity_transition == tdentity_transition_2).to be true
      expect(tdentity_transition == transition).to be false
    end
  end

  describe "#to_state" do
    it "returns from_state" do
      expect(tdentity_transition.to_state(state_1)).to eq state_1
      expect(tdentity_transition.to_state(state_2)).to eq state_2
      expect(tdentity_transition.to_state(state_3)).to eq state_3
    end
  end

  describe "#merge" do
    it "returns other" do
      expect(tdentity_transition.merge(tdentity_transition_2)).to be tdentity_transition_2
      expect(tdentity_transition.merge(transition)).to be transition
    end
  end

  describe "#match?" do
    it "returns true" do
      expect(tdentity_transition.match?(state_1)).to be true
      expect(tdentity_transition.match?(state_2)).to be true
      expect(tdentity_transition.match?(state_3)).to be true
    end
  end
end
