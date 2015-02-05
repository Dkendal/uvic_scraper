defmodule AbstractSyntaxTree do
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

  defmodule Course do
    defstruct subject: nil, number: nil, grade: nil
  end

  # pop off each elem until a left parens is reached
  defp pop l, r \\ [] do
    case l do
      [] ->
        { r, [] }

      ["(" | t] ->
        { r, ["("|t] }

      [h|t] ->

        pop(t, r ++ [h])
    end
  end

  # this is a modified version of Dijkstra's "shunting yard" alogrithim to
  # generate an intermediate prefix notation version of the grammar
  # http://en.wikipedia.org/wiki/Shunting-yard_algorithm

  defp shunting_yard tokens, operator_stack \\ [], output_stack \\ [],
    terminals_stack \\ []

  defp shunting_yard [], [], output, [] do
    output
  end

  defp shunting_yard [], operators, output, [] do
    Enum.reverse(operators) ++ output
  end

  defp shunting_yard(l, ops, output, term) when length(term) == 3 do
    [subj, num, grade] = term
    course = %Course{ subject: subj, number: num, grade: grade }
    shunting_yard(l, ops, [course | output], [])
  end

  defp shunting_yard [h|t], ops, output, term do
    case h do
      "(" ->
        shunting_yard t, ["(" | ops], output

      ")" ->
        {operators, ["(" | stack_tail]} = pop ops
        shunting_yard t, stack_tail, operators ++ output

      _ ->
        if h in ["and", "or"] do
          {operators, remainder} = pop(ops)
          shunting_yard(t, [String.to_atom(h)|remainder], operators ++ output)
        else
          shunting_yard t, ops, output, term ++ [h]
        end
    end
  end

  defp build_tree([], r) do
    r
  end

  defp build_tree([h|t], r) when is_map h do
    build_tree t, r ++ [ h ]
  end

  defp build_tree([h|t], []) when is_atom h do
    build_tree t, [h]
  end

  defp build_tree([h|t], r) when is_atom h do
    r ++ [build_tree(t, [h])]
  end

  def parse str do
    str
    |> String.split
    |> shunting_yard
    |> build_tree []
  end
end
