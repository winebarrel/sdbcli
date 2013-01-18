class Parser
options no_result_var
rule
  stmt : get_stmt
       | insert_stmt
       | update_stmt
       | delete_stmt
       | select_stmt
       | create_stmt
       | drop_stmt
       | show_stmt
       | use_stmt
       | desc_stmt

  get_stmt : GET get_output_list FROM IDENTIFIER WHERE ITEMNAME '=' VALUE
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

  insert_stmt : INSERT INTO IDENTIFIER '(' insert_identifier_list ')' VALUES '(' value_list ')'
              {
                unless val[4].length == val[8].length
                  raise Racc::ParseError, 'The number of an attribute and values differs'
                end

                attrs = {}
                val[4].zip(val[8]).each {|k, v| attrs[k] = v }
                item_name = attrs.find {|k, v| k =~ /\AitemName\Z/i }

                unless item_name
                  raise Racc::ParseError,'itemName is not contained in the INSERT statement'
                end

                attrs.delete(item_name[0])
                item_name = item_name[1]

                struct(:INSERT, :domain => val[2], :item_name => item_name, :attrs => attrs)
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

  update_stmt : UPDATE IDENTIFIER SET set_clause_list WHERE ITEMNAME '=' VALUE
              {
                attrs = {}
                val[3].each {|k, v| attrs[k] = v }
                struct(:UPDATE, :domain => val[1], :items => [[val[7], attrs]])
              }

  set_clause_list : set_clause
                    {
                      [val[0]]
                    }
                  | set_clause_list ',' set_clause
                    {
                      val[0] + [val[2]]
                    }

  set_clause : IDENTIFIER '=' VALUE
               {
                 [val[0], val[2]]
               }

  delete_stmt : DELETE delete_attr_list FROM IDENTIFIER WHERE ITEMNAME '=' VALUE
                {
                  struct(:DELETE, :domain => val[3], :items => [[val[7], val[1]]])
                }

  delete_attr_list : 
                     {
                       []
                     }
                   | identifier_list

  select_stmt : SELECT
                {
                  struct(:SELECT, :query => val[0])
                }

  create_stmt : CREATE DOMAIN IDENTIFIER
                {
                  struct(:CREATE, :domain => val[2])
                }

  drop_stmt : DROP DOMAIN IDENTIFIER
              {
                struct(:DROP, :domain => val[2])
              }

  show_stmt : SHOW DOMAINS
              {
                struct(:SHOW, :operand => :domains)
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

  identifier_list: IDENTIFIER
                             {
                               [val[0]]
                             }
                           | identifier_list ',' IDENTIFIER
                             {
                               val[0] + [val[2]]
                             }

  value_list : VALUE
                         {
                           [val[0]]
                         }
                       | value_list ',' VALUE
                         {
                          [val[0], val[2]].flatten
                         }

---- header

require 'strscan'

module SimpleDB

---- inner

KEYWORDS = %w(
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
    elsif (tok = @ss.scan /NULL\b/i)
      yield [:NULL, nil]
    elsif (tok = @ss.scan /`([^`]|``)*`/)
      yield [:IDENTIFIER, tok.slice(1...-1).gsub(/``/, '`')]
    elsif (tok = @ss.scan /'([^']|'')*'/) #'
      yield [:VALUE, tok.slice(1...-1).gsub(/''/, "'")]
    elsif (tok = @ss.scan /"([^"]|"")*"/) #"
      yield [:VALUE, tok.slice(1...-1).gsub(/""/, '"')]
    elsif (tok = @ss.scan /(0|[1-9]\d*)/)
      yield [:NATURAL_NUMBER, tok.to_i]
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

---- footer

end # module SimpleDB
