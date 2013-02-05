class Parser
options no_result_var
rule
  stmt : get_stmt
       | insert_stmt
       | update_stmt
       | merge_stmt
       | delete_stmt
       | select_stmt
       | next_stmt
       | current_stmt
       | prev_stmt
       | page_stmt
       | create_stmt
       | drop_stmt
       | show_stmt
       | use_stmt
       | desc_stmt
       | ruby_stmt
       | exec_stmt
       | error
         {
           @stmt_with_expr
         }

  value : STRING
        | NUMBER

  get_stmt : GET get_output_list FROM IDENTIFIER WHERE ITEMNAME '=' value
             {
                struct(:GET, :domain => val[3], :item_name => val[7], :attr_names => val[1])
             }

  get_output_list :
                    {
                      []
                    }
                  | '*'
                    {
                      []
                    }
                  | identifier_list

  value_list_list : '(' value_list ')'
                    {
                      [val[1]]
                    }
                  | value_list_list ',' '(' value_list ')'
                    {
                      val[0] + [val[3]]
                    }

  insert_stmt : INSERT INTO IDENTIFIER '(' insert_identifier_list ')' VALUES value_list_list
                {
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
                }

  insert_identifier_list : itemname_identifier
                           {
                             [val[0]]
                           }
                         | insert_identifier_list ',' itemname_identifier
                           {
                             val[0] + [val[2]]
                           }

  itemname_identifier : ITEMNAME
                      | IDENTIFIER

  update_stmt : UPDATE IDENTIFIER SET set_clause_list WHERE ITEMNAME '=' value
                {
                  attrs = {}
                  val[3].each {|k, v| attrs[k] = v }
                  struct(:UPDATE, :domain => val[1], :items => [[val[7], attrs]])
                }
              | UPDATE IDENTIFIER SET set_clause_list
                {
                  attrs = {}
                  val[3].each {|k, v| attrs[k] = v }
                  @stmt_with_expr = struct(:UPDATE_WITH_EXPR, :domain => val[1], :attrs => attrs, :expr => '')
                }
              | UPDATE IDENTIFIER SET set_clause_list WHERE
                {
                  attrs = {}
                  val[3].each {|k, v| attrs[k] = v }
                  @stmt_with_expr = struct(:UPDATE_WITH_EXPR, :domain => val[1], :attrs => attrs, :expr => 'WHERE ')
                }
              | UPDATE IDENTIFIER SET set_clause_list WHERE ITEMNAME
                {
                  attrs = {}
                  val[3].each {|k, v| attrs[k] = v }
                  @stmt_with_expr = struct(:UPDATE_WITH_EXPR, :domain => val[1], :attrs => attrs, :expr => 'WHERE itemName')
                }

  merge_stmt : UPDATE IDENTIFIER ADD set_clause_list WHERE ITEMNAME '=' value
               {
                 attrs = {}
                 val[3].each {|k, v| attrs[k] = v }
                 struct(:MERGE, :domain => val[1], :items => [[val[7], attrs]])
               }
             | UPDATE IDENTIFIER ADD set_clause_list
               {
                 attrs = {}
                 val[3].each {|k, v| attrs[k] = v }
                 @stmt_with_expr = struct(:MERGE_WITH_EXPR, :domain => val[1], :attrs => attrs, :expr => '')
               }
             | UPDATE IDENTIFIER ADD set_clause_list WHERE
               {
                 attrs = {}
                 val[3].each {|k, v| attrs[k] = v }
                 @stmt_with_expr = struct(:MERGE_WITH_EXPR, :domain => val[1], :attrs => attrs, :expr => 'WHERE ')
               }
             | UPDATE IDENTIFIER ADD set_clause_list WHERE ITEMNAME
               {
                 attrs = {}
                 val[3].each {|k, v| attrs[k] = v }
                 @stmt_with_expr = struct(:MERGE_WITH_EXPR, :domain => val[1], :attrs => attrs, :expr => 'WHERE itemName')
               }

  set_clause_list : set_clause
                    {
                      [val[0]]
                    }
                  | set_clause_list ',' set_clause
                    {
                      val[0] + [val[2]]
                    }

  set_clause : IDENTIFIER '=' value
               {
                 [val[0], val[2]]
               }

  delete_stmt : DELETE delete_attr_list FROM IDENTIFIER WHERE ITEMNAME '=' value
                {
                  struct(:DELETE, :domain => val[3], :items => [[val[7], val[1]]])
                }
              | DELETE delete_attr_list FROM IDENTIFIER
                {
                  @stmt_with_expr = struct(:DELETE_WITH_EXPR, :domain => val[3], :attrs => val[1],  :expr => '')
                }
              | DELETE delete_attr_list FROM WHERE
                {
                  @stmt_with_expr = struct(:DELETE_WITH_EXPR, :domain => val[3], :attrs => val[1],  :expr => 'WHERE ')
                }
              | DELETE delete_attr_list FROM WHERE ITEMNAME
                {
                  @stmt_with_expr = struct(:DELETE_WITH_EXPR, :domain => val[3], :attrs => val[1],  :expr => 'WHERE itemName')
                }

  delete_attr_list : 
                     {
                       []
                     }
                   | identifier_list

  select_stmt : SELECT
                {
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
                }

  next_stmt : NEXT
              {
                ruby = val[0].sub(/\A\s*\|\s*/, '') if val[0]
                struct(:NEXT, :ruby => ruby)
              }

  current_stmt : CURRENT
                 {
                   ruby = val[0].sub(/\A\s*\|\s*/, '') if val[0]
                   struct(:CURRENT, :ruby => ruby)
                 }

  next_stmt : PREV
              {
                ruby = val[0].sub(/\A\s*\|\s*/, '') if val[0]
                struct(:PREV, :ruby => ruby)
              }

  create_stmt : CREATE DOMAIN IDENTIFIER
                {
                  struct(:CREATE, :domain => val[2])
                }

  page_stmt : PAGE
              {
                page, ruby = val[0].split(/\s*\|\s*/, 2)
                page = page.split(/\s+/, 2)[1]
                page = page.strip.to_i if page
                struct(:PAGE, :page => page, :ruby => ruby)
              }

  drop_stmt : DROP DOMAIN IDENTIFIER
              {
                struct(:DROP, :domain => val[2])
              }

  show_stmt : SHOW DOMAINS
              {
                struct(:SHOW, :operand => :domains)
              }
            | SHOW REGIONS
              {
                struct(:SHOW, :operand => :regions)
              }
  use_stmt : USE IDENTIFIER
             {
               struct(:USE, :endpoint => val[1])
             }
  desc_stmt : DESC IDENTIFIER
              {
                struct(:DESCRIBE, :domain => val[1])
              }
            | DESCRIBE IDENTIFIER
              {
                struct(:DESCRIBE, :domain => val[1])
              }
  ruby_stmt : RUBY
              {
                script = val[0].sub(/\A\s*\|\s*/, '')
                struct(:RUBY, :script => script)
              }
  exec_stmt : EXEC
              {
                script = val[0].sub(/\A\s*!\s*/, '')
                struct(:EXEC, :script => script)
              }

  identifier_list: IDENTIFIER
                   {
                     [val[0]]
                   }
                 | identifier_list ',' IDENTIFIER
                   {
                     val[0] + [val[2]]
                   }

  value_list : value
               {
                 [val[0]]
               }
             | value_list ',' value
               {
                 [val[0], val[2]].flatten
               }

---- header

require 'strscan'

module SimpleDB

---- inner

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

---- footer

end # module SimpleDB
