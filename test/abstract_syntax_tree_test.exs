defmodule ASTTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  alias AbstractSyntaxTree, as: AST

  test "parsing a single course" do
    assert AST.parse("SENG 330 D") == [
      %AST.Course{subject: "SENG", number: "330", grade: "D" }]
  end

  test "parsing a single course with parens" do
    assert AST.parse("( SENG 330 D )") == [
      %AST.Course{subject: "SENG", number: "330", grade: "D" }]
  end

  test "parsing two courses with a conjunction" do
    assert AST.parse("SENG 330 D and CSC 350 D") == [
      :and,
      %AST.Course{subject: "CSC", number: "350", grade: "D" },
      %AST.Course{subject: "SENG", number: "330", grade: "D" }]
  end

  test "parsing a complex rule" do
    result = AST.parse( "( SENG 330 D or SENG 271 D or SENG 299 D or CENG 356 D ) and ( CENG 460 D or CSC 361 D )")

    assert length(result) == 3
    assert result == [
      :and,
      [
        :or,
        %AST.Course{grade: "D", number: "361", subject: "CSC"},
        %AST.Course{grade: "D", number: "460", subject: "CENG"}
      ],
      [
        :or,
        %AST.Course{grade: "D", number: "356", subject: "CENG"},
        [
          :or,
          %AST.Course{grade: "D", number: "299", subject: "SENG"},
          [
            :or,
            %AST.Course{grade: "D", number: "271", subject: "SENG"},
            %AST.Course{grade: "D", number: "330", subject: "SENG"}
          ]
        ]
      ]
    ]
  end
end
