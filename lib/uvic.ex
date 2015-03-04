# course listings
# /BAN2P/bwckctlg.p_display_courses?
#   term_in=201501
#   one_subj=CSC
#   sel_crse_strt=320
#   sel_crse_end=320
#   sel_subj=
#   sel_levl=
#   sel_schd=
#   sel_coll=
#   sel_divs=
#   sel_dept=
#   sel_attr=

# course requirements
# /BAN2P/bwckctlg.p_disp_course_detail?
#   cat_term_in=201501
#   subj_code_in=CSC
#   crse_numb_in=320

# class schedules
# /BAN2P/bwckctlg.p_disp_listcrse?
#   term_in=201501
#   subj_in=CSC
#   crse_in=320
#   schd_in=

# class size information
# /BAN2P/bwckschd.p_disp_detail_sched?
#   term_in=201501
#   crn_in=20711

defmodule UVic do
  use HTTPoison.Base
  use PatternTap

  @semesters %{
    spring: "01",
    summer: "05",
    winter: "09"
  }

  def process_url(url) do
    "https://www.uvic.ca/BAN2P/" <> url
  end

  def courses(year, semester, subjects, course_start..course_end) do
    display_courses(year, semester, subjects, course_start, course_end).body
    |> Floki.find(".nttitle")
    |> Floki.find("a")
    |> Enum.map fn(course) ->
      [dep, course_number, _ | title] = Floki.text(course) |> String.split(" ")
      { dep, course_number, Enum.join(title, " ") }
    end
  end

  def subjects(year, semester) do
    display_courses(year, semester).body
    |> Floki.find("#subj_id")
    |> Floki.find("option")
    |> Floki.attribute("value")
  end

  def requirements(year, semester, subject, number) do
    disp_course_detail(year, semester, subject, number).body
    # html structure of source is ass so use regex :'(
    |> tap(s ~> Regex.run(~r/Faculty.*\n.*\n(.*)/, s)) # find list of prereq
    |> tap([_, match] ~> match)
    |> String.replace(~r/\<A.*?\>|\<\/A\>/, "") # remove opening anchor tags
    |> String.replace(~r/\(|\)/, " \\0 ") # pad parens
    |> String.split(" ")
    |> Enum.filter(&(&1 != ""))
    |> Enum.join(" ")
    |> String.replace ~r/Undergraduate level ([A-Z]+ [0-9]+[A-Z]?) Minimum Grade of ([A-Z][+-]?)/, "\\1 \\2"
  end

  defp term(year, semester), do: year <> @semesters[semester]

  defp display_courses(year, semester, subjects \\ [], course_start \\ "", course_end \\ "") when is_list( subjects ) do
    q = [
      { :term_in,  term(year,semester) },
      { :sel_subj, ""},
      { :sel_levl, ""},
      { :sel_schd, ""},
      { :sel_coll, ""},
      { :sel_divs, ""},
      { :sel_dept, ""},
      { :sel_attr, ""} ]

    q = q ++ if (course_start && course_end) do
      [ { :sel_crse_strt, course_start }]
    end

    q = q ++ if (course_end) do
      [ { :sel_crse_end, course_end } ]
    end

    q = q ++ if (is_list subjects) do
      Enum.map subjects, &({:sel_subj, &1})
    end

    URI.encode_query(q)
    |> tap(q ~> post!("bwckctlg.p_display_courses", q))
  end

  defp disp_course_detail year, semester, subject, number do
    [
      { :cat_term_in, term(year, semester) },
      { :subj_code_in, subject },
      { :crse_numb_in, number } ]
    |> URI.encode_query
    |> tap(q ~> post!("bwckctlg.p_disp_course_detail", q))
  end
end
