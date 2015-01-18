defmodule UVicTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    UVic.start
  end

  test "course_list" do
    use_cassette "course_list_csc" do
      result = UVic.course_list "2015", :spring, ["CSC"], "100".."140"
      assert is_list result
      assert is_tuple hd result
      assert {"CSC", "100", "ELEMENTARY COMPUTING"} == hd( result )
    end
  end

  test "subject_list" do
    use_cassette "display_courses_term_only" do
      result = UVic.subject_list("2015", :spring)
      assert is_list result
      assert "CYCB" == hd result
    end
  end

  test "course_requirements" do
    use_cassette "course_requirements" do
      result = UVic.course_requirements("2015", :spring, "SENG", "462")
      assert "(Undergraduate level SENG 330 Minimum Grade of D or Undergraduate level SENG 271 Minimum Grade of D or Undergraduate level SENG 299 Minimum Grade of D or Undergraduate level CENG 356 Minimum Grade of D) and (Undergraduate level CENG 460 Minimum Grade of D or Undergraduate level CSC 361 Minimum Grade of D)" == result
    end
  end
end
