module SimpleDB
  class ResultSet
    include Enumerable

    def initialize(items)
      @items = items
    end

    def each(&block)
      @items.each(&block)
    end

    def to_s
      @items.to_s
    end

    def inspect
      @items.inspect
    end
  end # ResultSet
end # SimpleDB
