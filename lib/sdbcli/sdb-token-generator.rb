# original code: http://d.hatena.ne.jp/tottokug/20120810/1344611039
# original author: tottokug (http://www.hatena.ne.jp/tottokug/)

module SimpleDB
  class TokenGenerator

    BASE_STRING = %w(
      101011001110110100000000000001010111001101110010000000000010011101100011011011110110110100101110
      011000010110110101100001011110100110111101101110001011100111001101100100011100110010111001010001
      011101010110010101110010011110010101000001110010011011110110001101100101011100110111001101101111
      011100100010111001001101011011110111001001100101010101000110111101101011011001010110111011101011
      011010011100010111001011100111001000001101001101101010110000001100000000000010110100100100000000
      000101000110100101101110011010010111010001101001011000010110110001000011011011110110111001101010
      011101010110111001100011011101000100100101101110011001000110010101111000010110100000000000001110
      011010010111001101010000011000010110011101100101010000100110111101110101011011100110010001100001
      011100100111100101001010000000000000110001101100011000010111001101110100010001010110111001110100
      011010010111010001111001010010010100010001011010000000000000101001101100011100100111000101000101
      011011100110000101100010011011000110010101100100010010010000000000001111011100010111010101100101
      011100100111100101000011011011110110110101110000011011000110010101111000011010010111010001111001
      010010100000000000010011011100010111010101100101011100100111100101010011011101000111001001101001
      011011100110011101000011011010000110010101100011011010110111001101110101011011010100100100000000
      000010100111010101101110011010010110111101101110010010010110111001100100011001010111100001011010
      000000000000110101110101011100110110010101010001011101010110010101110010011110010100100101101110
      011001000110010101111000010011000000000000001101011000110110111101101110011100110110100101110011
      011101000110010101101110011101000100110001010011010011100111010000000000000100100100110001101010
      011000010111011001100001001011110110110001100001011011100110011100101111010100110111010001110010
      011010010110111001100111001110110100110000000000000100100110110001100001011100110111010001000001
      011101000111010001110010011010010110001001110101011101000110010101010110011000010110110001110101
      011001010111000100000000011111100000000000000001010011000000000000001001011100110110111101110010
      011101000100111101110010011001000110010101110010011101000000000000101111010011000110001101101111
      011011010010111101100001011011010110000101111010011011110110111000101111011100110110010001110011
      001011110101000101110101011001010111001001111001010100000111001001101111011000110110010101110011
      011100110110111101110010001011110101000101110101011001010111001001111001001001000101001101101111
      011100100111010001001111011100100110010001100101011100100011101101111000011100000000000000000000
      000000000000000000000000
      %064d
      000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000001110000011100000111000001111000
    ).join

    CODE_TABLE = Hash[
      *(0b000000..0b111111).map {|i| '%06d' % i.to_s(2) }.zip(
        ('A'..'Z').to_a +
        ('a'..'z').to_a +
        ('0'..'9').to_a +
        ['+', '/']
      ).flatten]

    def self.next_token(limit, page)
      offset = limit * (page - 1)
      base = BASE_STRING % offset.to_s(2)

      base.scan(/.{6}/).map {|bits|
        CODE_TABLE[bits]
      }.join
    end
  end
end