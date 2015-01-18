defmodule UVic do
  use HTTPoison.Base

  def process_url(url) do
    "https://www.uvic.ca/BAN2P/" <> url
  end
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

  def course_list(year, month, subjects, course_start..course_end) do
    courses = display_courses(year, month, subjects, course_start, course_end).body
    |> Floki.find(".nttitle")
    |> Floki.find("a")

    Enum.map courses, fn(course) ->
      [dep, course_number, _ | title] = Floki.text(course) |> String.split(" ")
      { dep, course_number, Enum.join(title, " ") }
    end
  end

  defp display_courses(year, month, subjects \\ [], course_start \\ "",
    course_end \\ "") when is_list( subjects ) do

    q = [
      { :term_in,  year <> month },
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
      Enum.map subjects, fn (x) -> {:sel_subj, x} end
    end

    post!("bwckctlg.p_display_courses", URI.encode_query(q))
  end

  def subject_list(year, month) do
    display_courses(year, month).body
    |> Floki.find("#subj_id")
    |> Floki.find("option")
    |> Floki.attribute("value")
  end
end
