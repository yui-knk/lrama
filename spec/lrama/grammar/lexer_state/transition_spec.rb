# frozen_string_literal: true

RSpec.describe Lrama::Grammar::LexerState::Transition do
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
  let(:transition_1) { Lrama::Grammar::LexerState::Transition.new(predication, state_3) }
  let(:transition_2) { Lrama::Grammar::LexerState::Transition.new(predication, state_2) }
  let(:transition_3) { Lrama::Grammar::LexerState::Transition.new(predication.negative_predication, state_3) }
  let(:tdentity_transition) { Lrama::Grammar::LexerState::IdentityTransition.new }

  describe "#==" do
    it "returns true if predication and _to_state are same otherwise returns false" do
      expect(transition == transition_1).to be true
      expect(transition == transition_2).to be false
      expect(transition == transition_3).to be false
    end
  end

  describe "as hash key" do
    it "works as hash key even if other instance" do
      h = {}
      h[transition] = true

      expect(h[transition]).to be true
      expect(h[transition_1]).to be true
      expect(h[transition_2]).to be nil
      expect(h[transition_3]).to be nil
    end
  end

  describe "#to_state" do
    it "returns _to_state for any from_state" do
      expect(transition.to_state(state_1)).to eq state_3
      expect(transition.to_state(state_2)).to eq state_3
      expect(transition.to_state(state_3)).to eq state_3
    end
  end

  describe "#merge" do
    context "IdentityTransition is passed" do
      it "returns self" do
        expect(transition.merge(tdentity_transition)).to eq transition
      end
    end

    context "Transition is passed" do
      context "_to_state matches with passed transition" do
        it "returns new transition whose predication is same self and _to_state is same with passed transition" do
          transition_1 = Lrama::Grammar::LexerState::Transition.new(predication.negative_predication, state_1)
          transition_2 = transition.merge(transition_1)

          expect(transition_2.predication).to eq transition.predication
          expect(transition_2._to_state).to eq transition_1._to_state
        end
      end

      context "_to_state doesn't match with passed transition" do
        it "returns nil" do
          transition_1 = Lrama::Grammar::LexerState::Transition.new(predication, state_1)

          expect(transition.merge(transition_1)).to be nil
        end
      end
    end
  end

  describe "#match?" do
    it "returns true if predication matches with passed state otherwise returns false" do
      expect(transition.match?(state_1)).to be true
      expect(transition.match?(state_2)).to be true
      expect(transition.match?(state_3)).to be false
    end
  end
end
