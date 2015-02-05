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
    assert AST.parse("( SENG 330 D and CSC 350 D ) or CSC 400 D") == [
      :or,
      %AST.Course{subject: "CSC", number: "400", grade: "D" },
      [
        :and,
        %AST.Course{subject: "CSC", number: "350", grade: "D" },
        %AST.Course{subject: "SENG", number: "330", grade: "D" }] ]
  end
end
