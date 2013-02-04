#
# DO NOT MODIFY!!!!
# This file is automatically generated by Racc 1.4.9
# from Racc grammer file "".
#

require 'racc/parser.rb'


require 'strscan'

module SimpleDB

class Parser < Racc::Parser

module_eval(<<'...end sdb-parser.y/module_eval...', 'sdb-parser.y', 282)

KEYWORDS = %w(
  ADD
  AND
  ASC
  BETWEEN
  BY
  CREATE
  DELETE
  DESCRIBE
  DESC
  DOMAINS
  DOMAIN
  DROP
  EVERY
  FROM
  GET
  INSERT
  INTERSECTION
  INTO
  IN
  IS
  ITEMNAME
  LIKE
  LIMIT
  NOT
  ORDER
  OR
  REGIONS
  SET
  SHOW
  UPDATE
  USE
  VALUES
  WHERE
)

KEYWORD_REGEXP = Regexp.compile("#{KEYWORDS.join '|'}\\b", Regexp::IGNORECASE)

def initialize(obj)
  src = obj.is_a?(IO) ? obj.read : obj.to_s
  @ss = StringScanner.new(src)
end

@@structs = {}

def struct(name, attrs = {})
  unless (clazz = @@structs[name])
    clazz = attrs.empty? ? Struct.new(name.to_s) : Struct.new(name.to_s, *attrs.keys)
    @@structs[name] = clazz
  end

  obj = clazz.new

  attrs.each do |key, val|
    obj.send("#{key}=", val)
  end

  return obj
end
private :struct

def scan
  tok = nil

  until @ss.eos?
    if (tok = @ss.scan /\s+/)
      # nothing to do
    elsif (tok = @ss.scan /(?:!=|>=|<=|>|<|=)/)
      yield [tok, tok]
    elsif (tok = @ss.scan KEYWORD_REGEXP)
      yield [tok.upcase.to_sym, tok]
    elsif (tok = @ss.scan /SELECT\b/i)
      yield [:SELECT, tok + @ss.scan(/.*/)]
    elsif (tok = @ss.scan /N(EXT)?\b/i)
      yield [:NEXT, @ss.scan(/\s*\|\s*.*/)]
    elsif (tok = @ss.scan /C(URRENT)?\b/i)
      yield [:CURRENT, @ss.scan(/\s*\|\s*.*/)]
    elsif (tok = @ss.scan /P(REV)?\b/i)
      yield [:PREV, @ss.scan(/\s*\|\s*.*/)]
    elsif (tok = @ss.scan /PAGE(\s+\d+)?/i)
      yield [:PAGE, tok + @ss.scan(/(\s*\|\s*.*)?/)]
    elsif (tok = @ss.scan /NULL\b/i)
      yield [:NULL, nil]
    elsif (tok = @ss.scan /`([^`]|``)*`/)
      yield [:IDENTIFIER, tok.slice(1...-1).gsub(/``/, '`')]
    elsif (tok = @ss.scan /'([^']|'')*'/) #'
      yield [:STRING, tok.slice(1...-1).gsub(/''/, "'")]
    elsif (tok = @ss.scan /"([^"]|"")*"/) #"
      yield [:STRING, tok.slice(1...-1).gsub(/""/, '"')]
    elsif (tok = @ss.scan /\d+(\.\d+)?/)
      yield [:NUMBER, tok]
    elsif (tok = @ss.scan /[,\(\)\*]/)
      yield [tok, tok]
    elsif (tok = @ss.scan /[a-z_$][-0-9a-z_$.]*\b/i)
      yield [:IDENTIFIER, tok]
    else
      raise Racc::ParseError, ('parse error on value "%s"' % @ss.rest.inspect)
    end
  end

  yield [false, '$']
end
private :scan

def parse
  yyparse self, :scan
end

def self.parse(obj)
  self.new(obj).parse
end

def on_error(error_token_id, error_value, value_stack)
  if @stmt_with_expr
    @stmt_with_expr.expr << (error_value + @ss.scan_until(/\Z/))
  else
    super
  end
end

...end sdb-parser.y/module_eval...
##### State transition tables begin ###

racc_action_table = [
    17,    10,    75,    72,    18,    71,    37,    70,    73,    73,
    35,    71,    33,    70,    19,    83,    84,    20,    83,    84,
    21,    22,    23,    24,    25,    26,    58,    27,    28,    29,
    44,    45,    30,    31,    32,    83,    84,    83,    84,   103,
   104,    83,    84,   108,   104,    83,    84,    79,    80,    53,
    54,    83,    84,    83,    84,    65,    66,    59,    60,    63,
    63,    56,    67,    51,    55,    74,    57,    76,    77,    78,
    52,    81,    63,    51,    86,    87,    88,    89,    50,    91,
    92,    93,    49,    95,    48,    47,    46,    43,   102,    42,
   105,    37,    39,    38 ]

racc_action_check = [
     0,     0,    64,    61,     0,    60,    18,    60,    64,    61,
    18,    80,     1,    80,     0,    91,    91,     0,    95,    95,
     0,     0,     0,     0,     0,     0,    50,     0,     0,     0,
    29,    29,     0,     0,     0,    93,    93,    92,    92,   100,
   100,    88,    88,   107,   107,    74,    74,    68,    68,    39,
    39,   104,   104,   105,   105,    55,    55,    51,    52,    53,
    54,    42,    58,    41,    40,    63,    43,    65,    66,    67,
    38,    72,    73,    36,    75,    76,    78,    79,    34,    81,
    86,    87,    33,    89,    32,    31,    30,    28,    96,    26,
   102,    21,    20,    19 ]

racc_action_pointer = [
    -1,    12,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,    -1,    77,
    85,    84,   nil,   nil,   nil,   nil,    62,   nil,    60,    -1,
    79,    78,    77,    82,    72,   nil,    59,   nil,    63,    30,
    58,    49,    54,    59,   nil,   nil,   nil,   nil,   nil,   nil,
    19,    50,    46,    52,    53,    48,   nil,   nil,    54,   nil,
    -2,    -5,   nil,    55,    -6,    59,    59,    60,    34,   nil,
   nil,   nil,    62,    65,    42,    65,    66,   nil,    66,    60,
     4,    69,   nil,   nil,   nil,   nil,    70,    71,    38,    71,
   nil,    12,    34,    32,   nil,    15,    74,   nil,   nil,   nil,
    26,   nil,    78,   nil,    48,    50,   nil,    30,   nil ]

racc_action_default = [
   -63,   -63,    -1,    -2,    -3,    -4,    -5,    -6,    -7,    -8,
    -9,   -10,   -11,   -12,   -13,   -14,   -15,   -16,   -20,   -63,
   -63,   -45,   -47,   -48,   -49,   -50,   -63,   -52,   -63,   -63,
   -63,   -63,   -63,   -63,   -63,   -21,   -22,   -59,   -63,   -63,
   -63,   -46,   -63,   -63,   -54,   -55,   -56,   -57,   -58,   109,
   -63,   -63,   -63,   -63,   -63,   -63,   -51,   -53,   -63,   -60,
   -63,   -31,   -38,   -63,   -35,   -42,   -43,   -63,   -63,   -26,
   -28,   -29,   -32,   -63,   -63,   -36,   -63,   -44,   -63,   -63,
   -63,   -33,   -39,   -17,   -18,   -40,   -37,   -63,   -63,   -63,
   -27,   -63,   -63,   -63,   -19,   -63,   -25,   -30,   -34,   -41,
   -63,   -61,   -63,   -23,   -63,   -63,   -62,   -63,   -24 ]

racc_goto_table = [
    85,    69,   100,    36,    61,    64,    41,    14,     7,     8,
     9,    11,   107,    12,    94,    13,     6,    97,    98,    99,
    15,    90,    16,     1,    34,     5,    96,     4,    68,     3,
   106,     2,    82,    40 ]

racc_goto_check = [
    16,    22,    20,    18,    23,    23,    18,    13,     7,     8,
     9,    10,    20,    11,    16,    12,     6,    16,    16,    16,
    14,    22,    15,     1,    17,     5,    19,     4,    21,     3,
    16,     2,    24,    25 ]

racc_goto_pointer = [
   nil,    23,    31,    29,    27,    25,    16,     8,     9,    10,
    11,    13,    15,     7,    20,    22,   -74,     6,   -15,   -63,
   -93,   -32,   -59,   -49,   -41,    12 ]

racc_goto_default = [
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   101,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,    62,   nil ]

racc_reduce_table = [
  0, 0, :racc_error,
  1, 37, :_reduce_none,
  1, 37, :_reduce_none,
  1, 37, :_reduce_none,
  1, 37, :_reduce_none,
  1, 37, :_reduce_none,
  1, 37, :_reduce_none,
  1, 37, :_reduce_none,
  1, 37, :_reduce_none,
  1, 37, :_reduce_none,
  1, 37, :_reduce_none,
  1, 37, :_reduce_none,
  1, 37, :_reduce_none,
  1, 37, :_reduce_none,
  1, 37, :_reduce_none,
  1, 37, :_reduce_none,
  1, 37, :_reduce_16,
  1, 52, :_reduce_none,
  1, 52, :_reduce_none,
  8, 38, :_reduce_19,
  0, 53, :_reduce_20,
  1, 53, :_reduce_21,
  1, 53, :_reduce_none,
  3, 55, :_reduce_23,
  5, 55, :_reduce_24,
  8, 39, :_reduce_25,
  1, 57, :_reduce_26,
  3, 57, :_reduce_27,
  1, 58, :_reduce_none,
  1, 58, :_reduce_none,
  8, 40, :_reduce_30,
  4, 40, :_reduce_31,
  5, 40, :_reduce_32,
  6, 40, :_reduce_33,
  8, 41, :_reduce_34,
  4, 41, :_reduce_35,
  5, 41, :_reduce_36,
  6, 41, :_reduce_37,
  1, 59, :_reduce_38,
  3, 59, :_reduce_39,
  3, 60, :_reduce_40,
  8, 42, :_reduce_41,
  4, 42, :_reduce_42,
  4, 42, :_reduce_43,
  5, 42, :_reduce_44,
  0, 61, :_reduce_45,
  1, 61, :_reduce_none,
  1, 43, :_reduce_47,
  1, 44, :_reduce_48,
  1, 45, :_reduce_49,
  1, 44, :_reduce_50,
  3, 47, :_reduce_51,
  1, 46, :_reduce_52,
  3, 48, :_reduce_53,
  2, 49, :_reduce_54,
  2, 49, :_reduce_55,
  2, 50, :_reduce_56,
  2, 51, :_reduce_57,
  2, 51, :_reduce_58,
  1, 54, :_reduce_59,
  3, 54, :_reduce_60,
  1, 56, :_reduce_61,
  3, 56, :_reduce_62 ]

racc_reduce_n = 63

racc_shift_n = 109

racc_token_table = {
  false => 0,
  :error => 1,
  :prev_stmt => 2,
  :STRING => 3,
  :NUMBER => 4,
  :GET => 5,
  :FROM => 6,
  :IDENTIFIER => 7,
  :WHERE => 8,
  :ITEMNAME => 9,
  "=" => 10,
  "*" => 11,
  "(" => 12,
  ")" => 13,
  "," => 14,
  :INSERT => 15,
  :INTO => 16,
  :VALUES => 17,
  :UPDATE => 18,
  :SET => 19,
  :ADD => 20,
  :DELETE => 21,
  :SELECT => 22,
  :NEXT => 23,
  :CURRENT => 24,
  :PREV => 25,
  :CREATE => 26,
  :DOMAIN => 27,
  :PAGE => 28,
  :DROP => 29,
  :SHOW => 30,
  :DOMAINS => 31,
  :REGIONS => 32,
  :USE => 33,
  :DESC => 34,
  :DESCRIBE => 35 }

racc_nt_base = 36

racc_use_result_var = false

Racc_arg = [
  racc_action_table,
  racc_action_check,
  racc_action_default,
  racc_action_pointer,
  racc_goto_table,
  racc_goto_check,
  racc_goto_default,
  racc_goto_pointer,
  racc_nt_base,
  racc_reduce_table,
  racc_token_table,
  racc_shift_n,
  racc_reduce_n,
  racc_use_result_var ]

Racc_token_to_s_table = [
  "$end",
  "error",
  "prev_stmt",
  "STRING",
  "NUMBER",
  "GET",
  "FROM",
  "IDENTIFIER",
  "WHERE",
  "ITEMNAME",
  "\"=\"",
  "\"*\"",
  "\"(\"",
  "\")\"",
  "\",\"",
  "INSERT",
  "INTO",
  "VALUES",
  "UPDATE",
  "SET",
  "ADD",
  "DELETE",
  "SELECT",
  "NEXT",
  "CURRENT",
  "PREV",
  "CREATE",
  "DOMAIN",
  "PAGE",
  "DROP",
  "SHOW",
  "DOMAINS",
  "REGIONS",
  "USE",
  "DESC",
  "DESCRIBE",
  "$start",
  "stmt",
  "get_stmt",
  "insert_stmt",
  "update_stmt",
  "merge_stmt",
  "delete_stmt",
  "select_stmt",
  "next_stmt",
  "current_stmt",
  "page_stmt",
  "create_stmt",
  "drop_stmt",
  "show_stmt",
  "use_stmt",
  "desc_stmt",
  "value",
  "get_output_list",
  "identifier_list",
  "value_list_list",
  "value_list",
  "insert_identifier_list",
  "itemname_identifier",
  "set_clause_list",
  "set_clause",
  "delete_attr_list" ]

Racc_debug_parser = false

##### State transition tables end #####

# reduce 0 omitted

# reduce 1 omitted

# reduce 2 omitted

# reduce 3 omitted

# reduce 4 omitted

# reduce 5 omitted

# reduce 6 omitted

# reduce 7 omitted

# reduce 8 omitted

# reduce 9 omitted

# reduce 10 omitted

# reduce 11 omitted

# reduce 12 omitted

# reduce 13 omitted

# reduce 14 omitted

# reduce 15 omitted

module_eval(<<'.,.,', 'sdb-parser.y', 20)
  def _reduce_16(val, _values)
               @stmt_with_expr
         
  end
.,.,

# reduce 17 omitted

# reduce 18 omitted

module_eval(<<'.,.,', 'sdb-parser.y', 28)
  def _reduce_19(val, _values)
                    struct(:GET, :domain => val[3], :item_name => val[7], :attr_names => val[1])
             
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 33)
  def _reduce_20(val, _values)
                          []
                    
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 37)
  def _reduce_21(val, _values)
                          []
                    
  end
.,.,

# reduce 22 omitted

module_eval(<<'.,.,', 'sdb-parser.y', 43)
  def _reduce_23(val, _values)
                          [val[1]]
                    
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 47)
  def _reduce_24(val, _values)
                          val[0] + [val[3]]
                    
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 52)
  def _reduce_25(val, _values)
                      items = val[7].map do |vals|
                    unless val[4].length == vals.length
                      raise Racc::ParseError, 'The number of an attribute and values differs'
                    end

                    attrs = {}
                    val[4].zip(vals).each {|k, v| attrs[k] = v }
                    item_name = attrs.find {|k, v| k =~ /\AitemName\Z/i }

                    unless item_name
                      raise Racc::ParseError,'itemName is not contained in the INSERT statement'
                    end

                    attrs.delete(item_name[0])
                    item_name = item_name[1]

                    [item_name, attrs]
                  end

                  struct(:INSERT, :domain => val[2], :items => items)
                
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 76)
  def _reduce_26(val, _values)
                                 [val[0]]
                           
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 80)
  def _reduce_27(val, _values)
                                 val[0] + [val[2]]
                           
  end
.,.,

# reduce 28 omitted

# reduce 29 omitted

module_eval(<<'.,.,', 'sdb-parser.y', 88)
  def _reduce_30(val, _values)
                      attrs = {}
                  val[3].each {|k, v| attrs[k] = v }
                  struct(:UPDATE, :domain => val[1], :items => [[val[7], attrs]])
                
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 94)
  def _reduce_31(val, _values)
                      attrs = {}
                  val[3].each {|k, v| attrs[k] = v }
                  @stmt_with_expr = struct(:UPDATE_WITH_EXPR, :domain => val[1], :attrs => attrs, :expr => '')
                
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 100)
  def _reduce_32(val, _values)
                      attrs = {}
                  val[3].each {|k, v| attrs[k] = v }
                  @stmt_with_expr = struct(:UPDATE_WITH_EXPR, :domain => val[1], :attrs => attrs, :expr => 'WHERE ')
                
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 106)
  def _reduce_33(val, _values)
                      attrs = {}
                  val[3].each {|k, v| attrs[k] = v }
                  @stmt_with_expr = struct(:UPDATE_WITH_EXPR, :domain => val[1], :attrs => attrs, :expr => 'WHERE itemName')
                
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 113)
  def _reduce_34(val, _values)
                     attrs = {}
                 val[3].each {|k, v| attrs[k] = v }
                 struct(:MERGE, :domain => val[1], :items => [[val[7], attrs]])
               
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 119)
  def _reduce_35(val, _values)
                     attrs = {}
                 val[3].each {|k, v| attrs[k] = v }
                 @stmt_with_expr = struct(:MERGE_WITH_EXPR, :domain => val[1], :attrs => attrs, :expr => '')
               
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 125)
  def _reduce_36(val, _values)
                     attrs = {}
                 val[3].each {|k, v| attrs[k] = v }
                 @stmt_with_expr = struct(:MERGE_WITH_EXPR, :domain => val[1], :attrs => attrs, :expr => 'WHERE ')
               
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 131)
  def _reduce_37(val, _values)
                     attrs = {}
                 val[3].each {|k, v| attrs[k] = v }
                 @stmt_with_expr = struct(:MERGE_WITH_EXPR, :domain => val[1], :attrs => attrs, :expr => 'WHERE itemName')
               
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 138)
  def _reduce_38(val, _values)
                          [val[0]]
                    
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 142)
  def _reduce_39(val, _values)
                          val[0] + [val[2]]
                    
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 147)
  def _reduce_40(val, _values)
                     [val[0], val[2]]
               
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 152)
  def _reduce_41(val, _values)
                      struct(:DELETE, :domain => val[3], :items => [[val[7], val[1]]])
                
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 156)
  def _reduce_42(val, _values)
                      @stmt_with_expr = struct(:DELETE_WITH_EXPR, :domain => val[3], :attrs => val[1],  :expr => '')
                
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 160)
  def _reduce_43(val, _values)
                      @stmt_with_expr = struct(:DELETE_WITH_EXPR, :domain => val[3], :attrs => val[1],  :expr => 'WHERE ')
                
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 164)
  def _reduce_44(val, _values)
                      @stmt_with_expr = struct(:DELETE_WITH_EXPR, :domain => val[3], :attrs => val[1],  :expr => 'WHERE itemName')
                
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 169)
  def _reduce_45(val, _values)
                           []
                     
  end
.,.,

# reduce 46 omitted

module_eval(<<'.,.,', 'sdb-parser.y', 175)
  def _reduce_47(val, _values)
                      query = ''
                  ruby = nil

                  ss = StringScanner.new(val[0])

                  until ss.eos?
                    if (tok = ss.scan /[^`'"|]+/) #'
                      query << tok
                    elsif (tok = ss.scan /`(?:[^`]|``)*`/)
                      query << tok
                    elsif (tok = ss.scan /'(?:[^']|'')*'/) #'
                      query << tok
                    elsif (tok = ss.scan /"(?:[^"]|"")*"/) #"
                      query << tok
                    elsif (tok = ss.scan /\|/)
                      ruby = ss.scan_until(/\Z/)
                    elsif (tok = ss.scan /./)
                      query << tok
                    end
                  end

                  struct(:SELECT, :query => query, :ruby => ruby)
                
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 201)
  def _reduce_48(val, _values)
                    ruby = val[0].sub(/\A\s*\|\s*/, '') if val[0]
                struct(:NEXT, :ruby => ruby)
              
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 207)
  def _reduce_49(val, _values)
                       ruby = val[0].sub(/\A\s*\|\s*/, '') if val[0]
                   struct(:CURRENT, :ruby => ruby)
                 
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 213)
  def _reduce_50(val, _values)
                    ruby = val[0].sub(/\A\s*\|\s*/, '') if val[0]
                struct(:PREV, :ruby => ruby)
              
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 219)
  def _reduce_51(val, _values)
                      struct(:CREATE, :domain => val[2])
                
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 224)
  def _reduce_52(val, _values)
                    page, ruby = val[0].split(/\s*\|\s*/, 2)
                page = page.split(/\s+/, 2)[1]
                page = page.strip.to_i if page
                struct(:PAGE, :page => page, :ruby => ruby)
              
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 232)
  def _reduce_53(val, _values)
                    struct(:DROP, :domain => val[2])
              
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 237)
  def _reduce_54(val, _values)
                    struct(:SHOW, :operand => :domains)
              
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 241)
  def _reduce_55(val, _values)
                    struct(:SHOW, :operand => :regions)
              
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 245)
  def _reduce_56(val, _values)
                   struct(:USE, :endpoint => val[1])
             
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 249)
  def _reduce_57(val, _values)
                    struct(:DESCRIBE, :domain => val[1])
              
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 253)
  def _reduce_58(val, _values)
                    struct(:DESCRIBE, :domain => val[1])
              
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 258)
  def _reduce_59(val, _values)
                         [val[0]]
                   
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 262)
  def _reduce_60(val, _values)
                         val[0] + [val[2]]
                   
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 267)
  def _reduce_61(val, _values)
                     [val[0]]
               
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 271)
  def _reduce_62(val, _values)
                     [val[0], val[2]].flatten
               
  end
.,.,

def _reduce_none(val, _values)
  val[0]
end

end   # class Parser


end # module SimpleDB
