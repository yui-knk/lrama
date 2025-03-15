# frozen_string_literal: true

RSpec.describe Lrama::Counterexamples::Node do
  describe ".to_a" do
    it "returns an array whose elements are same with the node" do
      node = Lrama::Counterexamples::Node.new(0, nil)
      node = Lrama::Counterexamples::Node.new(1, node)
      expect(Lrama::Counterexamples::Node.to_a(node)).to eq([1, 0])
    end
  end

  describe ".include?" do
    it "returns true if elem is included into the node" do
      node = Lrama::Counterexamples::Node.new(0, nil)
      node = Lrama::Counterexamples::Node.new(1, node)
      expect(Lrama::Counterexamples::Node.include?(node, 0)).to eq(true)
      expect(Lrama::Counterexamples::Node.include?(node, 1)).to eq(true)
    end

    it "returns false if elem is not included into the node" do
      node = Lrama::Counterexamples::Node.new(0, nil)
      node = Lrama::Counterexamples::Node.new(1, node)
      expect(Lrama::Counterexamples::Node.include?(node, 2)).to eq(false)
    end
  end
end