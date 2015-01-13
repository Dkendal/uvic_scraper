defmodule UVic do
  use HTTPoison.Base

  defp default_params do
    %{term: {"", "" },
      course_range: {"", ""},
      subject: "",
      level: "" }
  end

  def process_url(url) do
    "https://www.uvic.ca/" <> url
  end

  def display_courses do
    display_courses(%{})
  end

  def display_courses(options) do
    get! ("BAN2P/bwckctlg.p_display_courses?" <> build_query_string( options ))
  end

  defp build_query_string(map) do
    %{term: {year, month },
      course_range: {course_start_range, course_end_range},
      subject: subject,
      level: level } = map

    URI.encode_query %{ term_in: year <> month,
      one_subj: "",
      sel_crse_strt: course_start_range,
      sel_crse_end: course_end_range,
      sel_subj: subject,
      sel_levl: level,
      sel_schd: "",
      sel_coll: "",
      sel_divs: "",
      sel_dept: "",
      sel_attr: "",
    }
  end

  def subject_list(term) do
    ( Map.merge(default_params, %{ term: term })
    |> display_courses ).body
    |> Floki.find("#subj_id")
    |> Floki.find("option")
    |> Floki.attribute("value")
  end
end
