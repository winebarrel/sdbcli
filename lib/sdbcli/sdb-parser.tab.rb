#
# DO NOT MODIFY!!!!
# This file is automatically generated by Racc 1.4.9
# from Racc grammer file "".
#

require 'racc/parser.rb'


require 'strscan'

module SimpleDB

class Parser < Racc::Parser

module_eval(<<'...end sdb-parser.y/module_eval...', 'sdb-parser.y', 372)

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
      yield [:NEXT, @ss.scan(/\s*[|!]\s*.*/)]
    elsif (tok = @ss.scan /C(URRENT)?\b/i)
      yield [:CURRENT, @ss.scan(/\s*[|!]\s*.*/)]
    elsif (tok = @ss.scan /P(REV)?\b/i)
      yield [:PREV, @ss.scan(/\s*[|!]\s*.*/)]
    elsif (tok = @ss.scan /PAGE(\s+-?\d+)?/i)
      yield [:PAGE, tok + @ss.scan(/(\s*[|!]\s*.*)?/)]
    elsif (tok = @ss.scan /TAIL\b\s*[^\s]+/i)
      yield [:TAIL, tok + @ss.scan(/(\s*[|!]\s*.*)?/)]
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
    elsif (tok = @ss.scan /[a-z_$][0-9a-z_$]*\b/i)
      yield [:IDENTIFIER, tok]
    elsif (tok = @ss.scan /\|/i)
      yield [:RUBY, @ss.scan(/.*/)]
    elsif (tok = @ss.scan /!/i)
      yield [:EXEC, @ss.scan(/.*/)]
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
    20,    10,    81,    78,    21,    77,    43,    76,    79,    79,
    41,    77,    39,    76,    22,    89,    90,    23,    89,    90,
    24,    25,    26,    27,    28,    29,    64,    30,    31,    32,
    33,    50,    51,    34,    35,    36,    37,    38,    89,    90,
    89,    90,   109,   110,    89,    90,   114,   110,    89,    90,
    85,    86,    59,    60,    89,    90,    89,    90,    71,    72,
    65,    66,    69,    69,    62,    73,    57,    61,    80,    63,
    82,    83,    84,    58,    87,    69,    57,    92,    93,    94,
    95,    56,    97,    98,    99,    55,   101,    54,    53,    52,
    49,   108,    48,   111,    43,    45,    44 ]

racc_action_check = [
     0,     0,    70,    67,     0,    66,    21,    66,    70,    67,
    21,    86,     1,    86,     0,    97,    97,     0,   101,   101,
     0,     0,     0,     0,     0,     0,    56,     0,     0,     0,
     0,    33,    33,     0,     0,     0,     0,     0,    99,    99,
    98,    98,   106,   106,    94,    94,   113,   113,    80,    80,
    74,    74,    45,    45,   110,   110,   111,   111,    61,    61,
    57,    58,    59,    60,    48,    64,    47,    46,    69,    49,
    71,    72,    73,    44,    78,    79,    42,    81,    82,    84,
    85,    40,    87,    92,    93,    39,    95,    36,    35,    34,
    32,   102,    29,   108,    24,    23,    22 ]

racc_action_pointer = [
    -1,    12,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,    -1,    80,    88,    87,   nil,   nil,   nil,   nil,    65,
   nil,   nil,    63,    -1,    82,    81,    80,   nil,   nil,    85,
    75,   nil,    62,   nil,    66,    33,    61,    52,    57,    62,
   nil,   nil,   nil,   nil,   nil,   nil,    19,    53,    49,    55,
    56,    51,   nil,   nil,    57,   nil,    -2,    -5,   nil,    58,
    -6,    62,    62,    63,    37,   nil,   nil,   nil,    65,    68,
    45,    68,    69,   nil,    69,    63,     4,    72,   nil,   nil,
   nil,   nil,    73,    74,    41,    74,   nil,    12,    37,    35,
   nil,    15,    77,   nil,   nil,   nil,    29,   nil,    81,   nil,
    51,    53,   nil,    33,   nil ]

racc_action_default = [
   -69,   -69,    -1,    -2,    -3,    -4,    -5,    -6,    -7,    -8,
    -9,   -10,   -11,   -12,   -13,   -14,   -15,   -16,   -17,   -18,
   -19,   -23,   -69,   -69,   -48,   -50,   -51,   -52,   -53,   -69,
   -55,   -56,   -69,   -69,   -69,   -69,   -69,   -63,   -64,   -69,
   -69,   -24,   -25,   -65,   -69,   -69,   -69,   -49,   -69,   -69,
   -58,   -59,   -60,   -61,   -62,   115,   -69,   -69,   -69,   -69,
   -69,   -69,   -54,   -57,   -69,   -66,   -69,   -34,   -41,   -69,
   -38,   -45,   -46,   -69,   -69,   -29,   -31,   -32,   -35,   -69,
   -69,   -39,   -69,   -47,   -69,   -69,   -69,   -36,   -42,   -20,
   -21,   -43,   -40,   -69,   -69,   -69,   -30,   -69,   -69,   -69,
   -22,   -69,   -28,   -33,   -37,   -44,   -69,   -67,   -69,   -26,
   -69,   -69,   -68,   -69,   -27 ]

racc_goto_table = [
    91,    75,   106,    42,    67,    70,    47,    16,     7,     8,
     9,    11,   113,    12,   100,    13,    14,   103,   104,   105,
    15,    96,     6,    17,    18,    19,     1,    40,     5,   102,
   112,     4,    74,     3,     2,    88,    46 ]

racc_goto_check = [
    19,    25,    23,    21,    26,    26,    21,    15,     7,     8,
     9,    10,    23,    11,    19,    12,    13,    19,    19,    19,
    14,    25,     6,    16,    17,    18,     1,    20,     5,    22,
    19,     4,    24,     3,     2,    27,    28 ]

racc_goto_pointer = [
   nil,    26,    34,    33,    31,    28,    22,     8,     9,    10,
    11,    13,    15,    16,    20,     7,    23,    24,    25,   -80,
     6,   -18,   -66,   -99,   -34,   -65,   -55,   -44,    12 ]

racc_goto_default = [
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   107,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,    68,   nil ]

racc_reduce_table = [
  0, 0, :racc_error,
  1, 40, :_reduce_none,
  1, 40, :_reduce_none,
  1, 40, :_reduce_none,
  1, 40, :_reduce_none,
  1, 40, :_reduce_none,
  1, 40, :_reduce_none,
  1, 40, :_reduce_none,
  1, 40, :_reduce_none,
  1, 40, :_reduce_none,
  1, 40, :_reduce_none,
  1, 40, :_reduce_none,
  1, 40, :_reduce_none,
  1, 40, :_reduce_none,
  1, 40, :_reduce_none,
  1, 40, :_reduce_none,
  1, 40, :_reduce_none,
  1, 40, :_reduce_none,
  1, 40, :_reduce_none,
  1, 40, :_reduce_19,
  1, 58, :_reduce_none,
  1, 58, :_reduce_none,
  8, 41, :_reduce_22,
  0, 59, :_reduce_23,
  1, 59, :_reduce_24,
  1, 59, :_reduce_none,
  3, 61, :_reduce_26,
  5, 61, :_reduce_27,
  8, 42, :_reduce_28,
  1, 63, :_reduce_29,
  3, 63, :_reduce_30,
  1, 64, :_reduce_none,
  1, 64, :_reduce_none,
  8, 43, :_reduce_33,
  4, 43, :_reduce_34,
  5, 43, :_reduce_35,
  6, 43, :_reduce_36,
  8, 44, :_reduce_37,
  4, 44, :_reduce_38,
  5, 44, :_reduce_39,
  6, 44, :_reduce_40,
  1, 65, :_reduce_41,
  3, 65, :_reduce_42,
  3, 66, :_reduce_43,
  8, 45, :_reduce_44,
  4, 45, :_reduce_45,
  4, 45, :_reduce_46,
  5, 45, :_reduce_47,
  0, 67, :_reduce_48,
  1, 67, :_reduce_none,
  1, 46, :_reduce_50,
  1, 47, :_reduce_51,
  1, 48, :_reduce_52,
  1, 47, :_reduce_53,
  3, 50, :_reduce_54,
  1, 49, :_reduce_55,
  1, 57, :_reduce_56,
  3, 51, :_reduce_57,
  2, 52, :_reduce_58,
  2, 52, :_reduce_59,
  2, 53, :_reduce_60,
  2, 54, :_reduce_61,
  2, 54, :_reduce_62,
  1, 55, :_reduce_63,
  1, 56, :_reduce_64,
  1, 60, :_reduce_65,
  3, 60, :_reduce_66,
  1, 62, :_reduce_67,
  3, 62, :_reduce_68 ]

racc_reduce_n = 69

racc_shift_n = 115

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
  :TAIL => 29,
  :DROP => 30,
  :SHOW => 31,
  :DOMAINS => 32,
  :REGIONS => 33,
  :USE => 34,
  :DESC => 35,
  :DESCRIBE => 36,
  :RUBY => 37,
  :EXEC => 38 }

racc_nt_base = 39

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
  "TAIL",
  "DROP",
  "SHOW",
  "DOMAINS",
  "REGIONS",
  "USE",
  "DESC",
  "DESCRIBE",
  "RUBY",
  "EXEC",
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
  "ruby_stmt",
  "exec_stmt",
  "tail_stmt",
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

# reduce 16 omitted

# reduce 17 omitted

# reduce 18 omitted

module_eval(<<'.,.,', 'sdb-parser.y', 23)
  def _reduce_19(val, _values)
               @stmt_with_expr
         
  end
.,.,

# reduce 20 omitted

# reduce 21 omitted

module_eval(<<'.,.,', 'sdb-parser.y', 31)
  def _reduce_22(val, _values)
                    struct(:GET, :domain => val[3], :item_name => val[7], :attr_names => val[1])
             
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 36)
  def _reduce_23(val, _values)
                          []
                    
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 40)
  def _reduce_24(val, _values)
                          []
                    
  end
.,.,

# reduce 25 omitted

module_eval(<<'.,.,', 'sdb-parser.y', 46)
  def _reduce_26(val, _values)
                          [val[1]]
                    
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 50)
  def _reduce_27(val, _values)
                          val[0] + [val[3]]
                    
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 55)
  def _reduce_28(val, _values)
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

module_eval(<<'.,.,', 'sdb-parser.y', 79)
  def _reduce_29(val, _values)
                                 [val[0]]
                           
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 83)
  def _reduce_30(val, _values)
                                 val[0] + [val[2]]
                           
  end
.,.,

# reduce 31 omitted

# reduce 32 omitted

module_eval(<<'.,.,', 'sdb-parser.y', 91)
  def _reduce_33(val, _values)
                      attrs = {}
                  val[3].each {|k, v| attrs[k] = v }
                  struct(:UPDATE, :domain => val[1], :items => [[val[7], attrs]])
                
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 97)
  def _reduce_34(val, _values)
                      attrs = {}
                  val[3].each {|k, v| attrs[k] = v }
                  @stmt_with_expr = struct(:UPDATE_WITH_EXPR, :domain => val[1], :attrs => attrs, :expr => '')
                
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 103)
  def _reduce_35(val, _values)
                      attrs = {}
                  val[3].each {|k, v| attrs[k] = v }
                  @stmt_with_expr = struct(:UPDATE_WITH_EXPR, :domain => val[1], :attrs => attrs, :expr => 'WHERE ')
                
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 109)
  def _reduce_36(val, _values)
                      attrs = {}
                  val[3].each {|k, v| attrs[k] = v }
                  @stmt_with_expr = struct(:UPDATE_WITH_EXPR, :domain => val[1], :attrs => attrs, :expr => 'WHERE itemName')
                
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 116)
  def _reduce_37(val, _values)
                     attrs = {}
                 val[3].each {|k, v| attrs[k] = v }
                 struct(:MERGE, :domain => val[1], :items => [[val[7], attrs]])
               
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 122)
  def _reduce_38(val, _values)
                     attrs = {}
                 val[3].each {|k, v| attrs[k] = v }
                 @stmt_with_expr = struct(:MERGE_WITH_EXPR, :domain => val[1], :attrs => attrs, :expr => '')
               
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 128)
  def _reduce_39(val, _values)
                     attrs = {}
                 val[3].each {|k, v| attrs[k] = v }
                 @stmt_with_expr = struct(:MERGE_WITH_EXPR, :domain => val[1], :attrs => attrs, :expr => 'WHERE ')
               
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 134)
  def _reduce_40(val, _values)
                     attrs = {}
                 val[3].each {|k, v| attrs[k] = v }
                 @stmt_with_expr = struct(:MERGE_WITH_EXPR, :domain => val[1], :attrs => attrs, :expr => 'WHERE itemName')
               
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 141)
  def _reduce_41(val, _values)
                          [val[0]]
                    
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 145)
  def _reduce_42(val, _values)
                          val[0] + [val[2]]
                    
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 150)
  def _reduce_43(val, _values)
                     [val[0], val[2]]
               
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 155)
  def _reduce_44(val, _values)
                      struct(:DELETE, :domain => val[3], :items => [[val[7], val[1]]])
                
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 159)
  def _reduce_45(val, _values)
                      @stmt_with_expr = struct(:DELETE_WITH_EXPR, :domain => val[3], :attrs => val[1],  :expr => '')
                
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 163)
  def _reduce_46(val, _values)
                      @stmt_with_expr = struct(:DELETE_WITH_EXPR, :domain => val[3], :attrs => val[1],  :expr => 'WHERE ')
                
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 167)
  def _reduce_47(val, _values)
                      @stmt_with_expr = struct(:DELETE_WITH_EXPR, :domain => val[3], :attrs => val[1],  :expr => 'WHERE itemName')
                
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 172)
  def _reduce_48(val, _values)
                           []
                     
  end
.,.,

# reduce 49 omitted

module_eval(<<'.,.,', 'sdb-parser.y', 178)
  def _reduce_50(val, _values)
                      query = ''
                  script = nil
                  script_type = nil

                  ss = StringScanner.new(val[0])

                  until ss.eos?
                    if (tok = ss.scan /[^`'"|!]+/) #'
                      query << tok
                    elsif (tok = ss.scan /`(?:[^`]|``)*`/)
                      query << tok
                    elsif (tok = ss.scan /'(?:[^']|'')*'/) #'
                      query << tok
                    elsif (tok = ss.scan /"(?:[^"]|"")*"/) #"
                      query << tok
                    elsif (tok = ss.scan /\|/)
                      script = ss.scan_until(/\Z/)
                      script_type = :ruby
                    elsif (tok = ss.scan /!/)
                      script = ss.scan_until(/\Z/)
                      script_type = :shell
                    elsif (tok = ss.scan /./)
                      query << tok
                    end
                  end

                  struct(:SELECT, :query => query, :script => script, :script_type => script_type)
                
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 209)
  def _reduce_51(val, _values)
                    script = nil
                script_type = nil

                case val[0]
                when /\A\s*\|\s*/
                  script = val[0].sub(/\A\s*\|\s*/, '')
                  script_type = :ruby
                when /\A\s*!\s*/
                  script = val[0].sub(/\A\s*!\s*/, '')
                  script_type = :shell
                end

                struct(:NEXT, :script => script, :script_type => script_type)
              
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 226)
  def _reduce_52(val, _values)
                       script = nil
                   script_type = nil

                   case val[0]
                   when /\A\s*\|\s*/
                     script = val[0].sub(/\A\s*\|\s*/, '')
                     script_type = :ruby
                   when /\A\s*!\s*/
                     script = val[0].sub(/\A\s*!\s*/, '')
                     script_type = :shell
                   end

                   struct(:CURRENT, :script => script, :script_type => script_type)
                 
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 243)
  def _reduce_53(val, _values)
                    script = nil
                script_type = nil

                case val[0]
                when /\A\s*\|\s*/
                  script = val[0].sub(/\A\s*\|\s*/, '')
                  script_type = :ruby
                when /\A\s*!\s*/
                  script = val[0].sub(/\A\s*!\s*/, '')
                  script_type = :shell
                end

                struct(:PREV, :script => script, :script_type => script_type)
              
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 260)
  def _reduce_54(val, _values)
                      struct(:CREATE, :domain => val[2])
                
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 265)
  def _reduce_55(val, _values)
                    page = nil
                script = nil
                script_type = nil

                case val[0]
                when /\s*\|\s*/
                  page, script = val[0].split(/\s*\|\s*/, 2)
                  script_type = :ruby
                when /\s*!\s*/
                  page, script = val[0].split(/\s*!\s*/, 2)
                  script_type = :shell
                else
                  page = val[0]
                end

                page = page.split(/\s+/, 2)[1]
                page = page.strip.to_i if page
                struct(:PAGE, :page => page, :script => script, :script_type => script_type)
              
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 287)
  def _reduce_56(val, _values)
                    domain_name = nil
                script = nil
                script_type = nil

                case val[0]
                when /\s*\|\s*/
                  domain_name, script = val[0].split(/\s*\|\s*/, 2)
                  script_type = :ruby
                when /\s*!\s*/
                  domain_name, script = val[0].split(/\s*\!\s*/, 2)
                  script_type = :shell
                else
                  domain_name = val[0]
                end

                domain_name = domain_name.split(/\b/, 2).last.strip
                struct(:TAIL, :domain => domain_name, :script => script, :script_type => script_type)
              
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 308)
  def _reduce_57(val, _values)
                    struct(:DROP, :domain => val[2])
              
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 313)
  def _reduce_58(val, _values)
                    struct(:SHOW, :operand => :domains)
              
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 317)
  def _reduce_59(val, _values)
                    struct(:SHOW, :operand => :regions)
              
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 322)
  def _reduce_60(val, _values)
                   struct(:USE, :endpoint => val[1])
             
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 327)
  def _reduce_61(val, _values)
                    struct(:DESCRIBE, :domain => val[1])
              
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 331)
  def _reduce_62(val, _values)
                    struct(:DESCRIBE, :domain => val[1])
              
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 336)
  def _reduce_63(val, _values)
                    script = val[0].sub(/\A\s*\|\s*/, '')
                struct(:RUBY, :script => script)
              
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 342)
  def _reduce_64(val, _values)
                    script = val[0].sub(/\A\s*!\s*/, '')
                struct(:EXEC, :script => script)
              
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 348)
  def _reduce_65(val, _values)
                         [val[0]]
                   
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 352)
  def _reduce_66(val, _values)
                         val[0] + [val[2]]
                   
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 357)
  def _reduce_67(val, _values)
                     [val[0]]
               
  end
.,.,

module_eval(<<'.,.,', 'sdb-parser.y', 361)
  def _reduce_68(val, _values)
                     [val[0], val[2]].flatten
               
  end
.,.,

def _reduce_none(val, _values)
  val[0]
end

end   # class Parser


end # module SimpleDB
