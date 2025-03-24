# frozen_string_literal: true

RSpec.describe Lrama::UniqueArray do
  let(:uary) { Lrama::UniqueArray.new }

  describe "#<<" do
    context "it doesn't contain passed elememt" do
      it "stores the elememt and returns true" do
        uary << 1

        expect(uary << 2).to be true
        expect(uary.to_a).to eq([1, 2])
      end
    end

    context "it contains passed elememt" do
      it "doesn't store the elememt and returns false" do
        uary << 1
        uary << 2

        expect(uary << 1).to be false
        expect(uary.to_a).to eq([1, 2])
      end
    end
  end

  describe "#shift" do
    it "returns the first elememt of unique array and delete the elememt from unique array" do
      uary << 1
      uary << 2

      expect(uary.shift).to eq(1)
      expect(uary << 1).to be true
      expect(uary.to_a).to eq([2, 1])
    end
  end
end
