require IEx
defmodule AST do
  # CFG for requirements
  #=====================
  # EXPR = '(' EXPR ')'
  # EXPR = EXPR 'or' EXPR
  # EXPR = EXPR 'and' EXPR
  # EXPR = COURSE
  # COURSE = subject number grade
  # subject = [A-Z]{2,}
  # number = [0-9]+[A-Z]?
  # grade = [A-F][+-]?


  def pop(l, r \\ []) do
    case l do
      [] ->
        { r, [] }

      ["(" | t] ->
        { r, ["("|t] }

      [h|t] ->

        pop(t, r ++ [h])
    end
  end

  def shunting_yard([], [], output, []) do
    output
  end

  def shunting_yard([], operators, output, []) do
    Enum.reverse(operators) ++ output
  end

  def shunting_yard(l, ops, output, term) when length(term) == 3 do
    shunting_yard(l, ops, [term | output], [])
  end

  def shunting_yard([h|t], ops \\ [], output \\ [], term \\ []) do
    case_op = fn () ->
      {operators, remainder} = pop(ops)
      shunting_yard(t, [String.to_atom(h)|remainder], operators ++ output)
    end

    case h do
      "(" ->
        shunting_yard t, ["(" | ops], output

      ")" ->
        {operators, ["(" | stack_tail]} = pop ops
        shunting_yard t, stack_tail, operators ++ output

      "and" ->
        case_op.()

      "or" ->
        case_op.()

      _ ->
        shunting_yard t, ops, output, term ++ [h]
    end
  end

  def parse(str) do
    shunting_yard String.split( str )
  end
end
