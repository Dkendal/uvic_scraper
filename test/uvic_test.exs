defmodule UVicTest do
  use ExUnit.Case, async: true

  test "subject_list" do
    result = UVic.subject_list("2015", "01")
    assert is_list result
    assert "CYCB" = hd result
  end

  test "display_courses" do
    assert_raise FunctionClauseError, fn ->
      UVic.display_courses("2015", "01", "")
    end
  end
end
