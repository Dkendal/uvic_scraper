defmodule ASTTest do
  use ExSpec

  @tag timeout: 100
  describe "bottom_up_parse" do
    context "the string is in the grammar" do
      it "returns a parse tree" do
        input = String.split "( AAAA 100 D or BBBB 200 D ) and CCCC 300 A+"
        assert AST.bottom_up_parse(input, []) == [
          and: [
            or: [
              course: [ subject: "AAAA", number: "100", grade: "D" ],
              course: [ subject: "BBBB", number: "200", grade: "D" ] ],
            course: [ subject: "CCCC", number: "300", grade: "A+" ] ] ]
      end
    end
  end
end
