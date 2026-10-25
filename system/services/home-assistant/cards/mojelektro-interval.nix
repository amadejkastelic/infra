slug: {
  type = "statistics-graph";
  title = "Electricity (hourly)";
  chart_type = "bar";
  stat_types = [ "change" ];
  period = "hour";
  days_to_show = 2;
  entities = [
    {
      entity = "mojelektro_stats:${slug}_a_plus_15";
      name = "Usage";
    }
  ];
}
