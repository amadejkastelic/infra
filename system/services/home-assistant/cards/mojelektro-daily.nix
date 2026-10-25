slug: {
  type = "statistics-graph";
  title = "Electricity (VT / MT)";
  chart_type = "bar";
  stat_types = [ "change" ];
  period = "day";
  days_to_show = 14;
  entities = [
    {
      entity = "mojelektro_stats:${slug}_a_plus_t1";
      name = "VT";
    }
    {
      entity = "mojelektro_stats:${slug}_a_plus_t2";
      name = "MT";
    }
  ];
}
