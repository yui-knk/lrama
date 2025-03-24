# frozen_string_literal: true

RSpec.describe Lrama::Grammar::LexerState::State do
  let(:state_bit_1) { Lrama::Grammar::LexerState::StateBit.new(0, "EXPR_BEG") }
  let(:state_bit_2) { Lrama::Grammar::LexerState::StateBit.new(1, "EXPR_MID") }
  let(:state_bit_3) { Lrama::Grammar::LexerState::StateBit.new(2, "EXPR_END") }
  let(:state_1) { Lrama::Grammar::LexerState::State.new([]) }
  let(:state_2) { Lrama::Grammar::LexerState::State.new([state_bit_1]) }
  let(:state_3) { Lrama::Grammar::LexerState::State.new([state_bit_1, state_bit_2]) }
  let(:state_4) { Lrama::Grammar::LexerState::State.new([state_bit_3]) }
  let(:state_5) { Lrama::Grammar::LexerState::State.new([state_bit_1, state_bit_2, state_bit_3]) }

  describe "#==" do
    it "returns true if both state has same state bits otherwise returns false" do
      expect(state_1 == state_1).to be true
      expect(state_1 == state_2).to be false
      expect(state_1 == state_3).to be false
      expect(state_1 == state_4).to be false

      expect(state_2 == state_1).to be false
      expect(state_2 == state_2).to be true
      expect(state_2 == state_3).to be false
      expect(state_2 == state_4).to be false

      expect(state_3 == state_1).to be false
      expect(state_3 == state_2).to be false
      expect(state_3 == state_3).to be true
      expect(state_3 == state_4).to be false

      expect(state_4 == state_1).to be false
      expect(state_4 == state_2).to be false
      expect(state_4 == state_3).to be false
      expect(state_4 == state_4).to be true
    end
  end

  describe "#<=>" do
    it "returns -1, 0 or 1 based on bitmap" do
      expect(state_1 <=> state_1).to eq  0
      expect(state_1 <=> state_2).to eq -1
      expect(state_1 <=> state_3).to eq -1
      expect(state_1 <=> state_4).to eq -1

      expect(state_2 <=> state_1).to eq  1
      expect(state_2 <=> state_2).to eq  0
      expect(state_2 <=> state_3).to eq -1
      expect(state_2 <=> state_4).to eq -1

      expect(state_3 <=> state_1).to eq  1
      expect(state_3 <=> state_2).to eq  1
      expect(state_3 <=> state_3).to eq  0
      expect(state_3 <=> state_4).to eq -1

      expect(state_4 <=> state_1).to eq 1
      expect(state_4 <=> state_2).to eq 1
      expect(state_4 <=> state_3).to eq 1
      expect(state_4 <=> state_4).to eq 0
    end
  end

  describe "as hash key" do
    it "works as hash key if states have same bitmap" do
      state_1_1 = Lrama::Grammar::LexerState::State.new([])
      state_2_1 = Lrama::Grammar::LexerState::State.new([state_bit_1])

      h = {}
      h[state_1] = true
      expect(h[state_1_1]).to be true
      expect(h[state_2_1]).to be nil

      h = {}
      h[state_2] = true
      expect(h[state_1_1]).to be nil
      expect(h[state_2_1]).to be true
    end
  end

  describe "#<<" do
    it "adds state_bit to state" do
      state_3 << state_bit_3
      expect(Lrama::Bitmap.to_array(state_3.bitmap)).to eq([0, 1, 2])
    end
  end

  describe "#is?" do
    it "returns true if state has bit for passed state otherwise returns false" do
      expect(state_3.is?(state_2)).to be true
      expect(state_3.is?(state_3)).to be true
      expect(state_3.is?(state_4)).to be false
      expect(state_3.is?(state_5)).to be true
    end
  end

  describe "#is_all?" do
    it "returns true if state has bit for passed state otherwise returns false" do
      expect(state_3.is_all?(state_2)).to be false
      expect(state_3.is_all?(state_3)).to be true
      expect(state_3.is_all?(state_4)).to be false
      expect(state_3.is_all?(state_5)).to be true
    end
  end

  describe "#each" do
    it "accepts block and call the block with each state_bit" do
      a = []

      state_3.each do |bit|
        a << bit
      end

      expect(a).to eq([state_bit_1, state_bit_2])
    end
  end  

  describe "#to_s" do
    it "returns state bit names" do
      expect(state_1.to_s).to eq("")
      expect(state_2.to_s).to eq("EXPR_BEG")
      expect(state_3.to_s).to eq("EXPR_BEG|EXPR_MID")
    end
  end
end
