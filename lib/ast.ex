defmodule AST do
  require Zipper
  alias Zipper, as: Z

  def bottom_up_parse [], r do
    bottom_up_parse Enum.reverse(r), []
  end

  def bottom_up_parse [ [ :expr | _ ] = r ] , [] do
     Z.prewalk(r, fn
      [ :expr, child ] -> child
      tree -> tree
    end)
    # collapse recursive `or` and `and` nodes into single nodes with many leafs
    |> Z.prewalk(fn
      [ op | children ] = tree when op == :or or op == :and ->
        case Enum.partition(children, &( hd(&1) == op ) ) do
          # these are always initially binary expression trees so the match on
          # first element of the tuple will always be only one element
          { [ [ op | new_children ] ], old_children } ->
            [ op | new_children ++ old_children ]

          { [], _ } ->
            tree
        end

      t -> t
    end)
  end

  def bottom_up_parse [ [ :course | _ ] = h | t ], r do
    bottom_up_parse t, [ [ :expr , h ] | r ]
  end

  def bottom_up_parse [ [ :subject | _ ], [ :number | _ ], [ :grade | _ ] | t ] = l, r do
    bottom_up_parse t, [ [ :course | l -- t ] | r ]
  end

  def bottom_up_parse [ [ :lhs | _ ], [ :expr | _ ] = h, [ :rhs | _ ] | t ], r do
    bottom_up_parse t, [ h | r ]
  end

  def bottom_up_parse [ [ :expr | _ ] = a, [ :op , o ], [ :expr | _ ] = b | t ], r do
    bottom_up_parse t, [ [ :expr | [ [ String.to_atom(o), a, b ] ] ] | r ]
  end

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
    bottom_up_parse t, [[ result , h ] | r]
  end

  def bottom_up_parse [ h | t ], r do
    bottom_up_parse t, [ h | r ]
  end

  def parse str do
    str
    |> String.split
    |> bottom_up_parse( [] )
  end
end
