defmodule UVicTest do
  use ExSpec
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup do
    UVic.start
  end

  describe "courses" do
    it "returns all courses for the given query" do
      use_cassette "courses_csc" do
        result = UVic.courses"2015", :spring, ["CSC"], "100".."140"
        assert is_list result
        assert is_tuple hd result
        assert {"CSC", "100", "ELEMENTARY COMPUTING"} == hd( result )
      end
    end
  end

  describe "subjects" do
    it "returns all subjects available in the term" do
      use_cassette "display_courses_term_only" do
        result = UVic.subjects("2015", :spring)
        assert is_list result
        assert "CYCB" == hd result
      end
    end
  end

  describe "requirements" do
    it "returns the requirements for the course" do
      use_cassette "requirements" do
        result = UVic.requirements "2015", :spring, "SENG", "462"
        assert  "( SENG 330 D or SENG 271 D or SENG 299 D or CENG 356 D ) and ( CENG 460 D or CSC 361 D )"== result
      end
    end
  end
end
