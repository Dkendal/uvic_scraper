defmodule UVicTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    UVic.start
  end

  test "course_list" do
    use_cassette "course_list_csc" do
      result = UVic.course_list "2015", "01", ["CSC"], "100".."140"
      assert is_list result
      assert is_tuple hd result
      assert {"CSC", "100", "ELEMENTARY COMPUTING"} = hd( result )
    end
  end

  test "display_courses" do
    use_cassette "display_courses_term_only" do
      assert_raise FunctionClauseError, fn ->
        UVic.display_courses("2015", "01", "")
      end
    end
  end

  test "subject_list" do
    use_cassette "display_courses_term_only" do
      result = UVic.subject_list("2015", "01")
      assert is_list result
      assert "CYCB" = hd result
    end
  end
end
