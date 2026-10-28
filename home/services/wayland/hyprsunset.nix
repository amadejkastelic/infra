{
  services.hyprsunset = {
    enable = true;

    settings = {
      max-gamma = 150;

      profile = [
        {
          time = "7:30";
          identity = true;
        }
        {
          time = "17:00";
          temperature = 3000;
        }
      ];
    };
  };
}
