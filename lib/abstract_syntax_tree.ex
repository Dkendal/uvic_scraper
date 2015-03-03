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

  def bottom_up_parse [], r do
    bottom_up_parse Enum.reverse(r), []
  end

  def bottom_up_parse [ {:course, _} = h | t ], r do
    bottom_up_parse t, [ { :expr, [ h ] } | r ]
  end

  def bottom_up_parse [ { :expr, _ } ] = h, [] do
    bottom_up_parse [], [ { :start, h } ]
  end

  def bottom_up_parse [ { :start, _ } ] = r, [] do
    r
  end

  def bottom_up_parse [ { :subject, _ }, { :number, _ }, { :grade, _ } | t ] = l, r do
    bottom_up_parse t, [ { :course, l -- t } | r ]
  end

  def bottom_up_parse [ { :lhs, _ }, { :expr, _ } = h, { :rhs, _ } | t ], r do
    bottom_up_parse t, [ h | r ]
  end

  def bottom_up_parse [ { :expr, _ }, { :op, _ }, { :expr, _ }| t ] = l, r do
    bottom_up_parse t, [ { :expr, l -- t } | r ]
  end
    #[ lhs: _, expr: _, rhs: _ ] -> :expr
    #[ expr: _, op: _, expr: _ ] -> :expr
  def bottom_up_parse([h | t], r) when is_binary h do
    subject = ~r/[A-Z]{2,}/
    number =  ~r/[0-9]+[A-Z]?/
    grade =   ~r/[A-F][+-]?/

    result = case h do
      "(" -> :lhs
      ")" -> :rhs
      "or" -> :op
      "and" -> :op
      _ ->
        cond do
          Regex.match?(subject, h) -> :subject
          Regex.match?(number, h) -> :number
          Regex.match?(grade, h) -> :grade
        end
    end

    bottom_up_parse t, [{result, h } | r]
  end

  def bottom_up_parse [ h | t ], r do
    bottom_up_parse t, [ h | r ]
  end

  def parse str do
    str
    |> String.split
    |> bottom_up_parse []
  end
end
