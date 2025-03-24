# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  # @rbs generic T
  class UniqueArray
    # @rbs!
    #
    #   @ary: Array[T]
    #   @hash: Hash[T, bool]

    extend Forwardable

    # @rbs [T] (Array[T] ary) -> UniqueArray[T]
    def self.from_array(ary)
      a = UniqueArray.new

      ary.each do |e|
        a << e
      end

      a
    end

    # @rbs!
    #
    #   def each: () { (T item) -> void } -> self
    #   def to_a: () -> Array[T]
    #   def empty?: () -> bool
    #   def product: (untyped) -> untyped
    #   def +: (Array[T]) -> Array[T]
    #   
    def_delegators "@ary", :each, :to_a, :empty?, :product, :+

    # @rbs () -> void
    def initialize
      @ary = []
      @hash = {}
    end

    # @rbs (T elem) -> bool
    def <<(elem)
      return false if @hash[elem]

      @hash[elem] = true
      @ary << elem
      true
    end

    # @rbs () -> T?
    def shift
      e = @ary.shift
      @hash.delete(e)
      e
    end

    # @rbs () -> Array[T]
    def to_ary
      @ary
    end

    # @rbs (T elem) -> self?
    def add?(elem)
      return nil if @hash[elem]

      @hash[elem] = true
      @ary << elem
      self
    end
  end
end
