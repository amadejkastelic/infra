# The `easyeffects` aspect (home-manager, Linux desktop).
# Converted from home/services/media/easyeffects.nix.
{
  den.aspects.easyeffects.homeManager = {
    services.easyeffects = {
      enable = true;
    };

    xdg.configFile."easyeffects/autoload/output/alsa_output.usb-FiiO_K3-00.pro-output-0.json" = {
      text = ''
        {
          "device": "alsa_output.usb-FiiO_K3-00.pro-output-0",
          "device-description": "K3 Analog Stereo",
          "device-profile": "pro-audio",
          "preset-name": "Blessing3"
        }
      '';
    };

    xdg.configFile."easyeffects/autoload/output/alsa_output.usb-GuangZhou_FiiO_Electronics_Co._Ltd_FiiO_K7-00.analog-stereo.json" =
      {
        text = ''
          {
            "device": "alsa_output.usb-GuangZhou_FiiO_Electronics_Co._Ltd_FiiO_K7-00.analog-stereo",
            "device-description": "FiiO K7 Analog Stereo",
            "device-profile": "analog-output",
            "preset-name": "660S"
          }
        '';
      };

    xdg.configFile."easyeffects/output/Blessing3.json" = {
      text = ''
          {
            "output": {
                "blocklist": [],
                "equalizer#0": {
                    "balance": 0.0,
                    "bypass": false,
                    "input-gain": -2.01,
                    "left": {
                        "band0": {
                            "frequency": 105.0,
                            "gain": -4.300000190734863,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 0.699999988079071,
                            "slope": "x1",
                            "solo": false,
                            "type": "Lo-shelf",
                            "width": 4.0
                        },
                        "band1": {
                            "frequency": 57.599998474121094,
                            "gain": 1.2000000476837158,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 1.5299999713897705,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band2": {
                            "frequency": 122.69999694824219,
                            "gain": 2.4000000953674316,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 0.9200000166893005,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band3": {
                            "frequency": 191.8000030517578,
                            "gain": -0.800000011920929,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 4.130000114440918,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band4": {
                            "frequency": 437.5,
                            "gain": 1.7999999523162842,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 1.0700000524520874,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band5": {
                            "frequency": 1391.9000244140625,
                            "gain": -2.200000047683716,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 1.2100000381469727,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band6": {
                            "frequency": 4007.300048828125,
                            "gain": -0.800000011920929,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 2.0,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band7": {
                            "frequency": 6045.10009765625,
                            "gain": -2.4000000953674316,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 6.0,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band8": {
                            "frequency": 7286.10009765625,
                            "gain": 1.5,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 4.110000133514404,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band9": {
                            "frequency": 10000.0,
                            "gain": -3.0999999046325684,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 0.699999988079071,
                            "slope": "x1",
                            "solo": false,
                            "type": "Hi-shelf",
                            "width": 4.0
                        }
                    },
                    "mode": "IIR",
                    "num-bands": 10,
                    "output-gain": 0.0,
                    "pitch-left": 0.0,
                    "pitch-right": 0.0,
                    "right": {
                        "band0": {
                            "frequency": 105.0,
                            "gain": -4.300000190734863,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 0.699999988079071,
                            "slope": "x1",
                            "solo": false,
                            "type": "Lo-shelf",
                            "width": 4.0
                        },
                        "band1": {
                            "frequency": 57.599998474121094,
                            "gain": 1.2000000476837158,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 1.5299999713897705,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band2": {
                            "frequency": 122.69999694824219,
                            "gain": 2.4000000953674316,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 0.9200000166893005,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band3": {
                            "frequency": 191.8000030517578,
                            "gain": -0.800000011920929,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 4.130000114440918,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band4": {
                            "frequency": 437.5,
                            "gain": 1.7999999523162842,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 1.0700000524520874,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band5": {
                            "frequency": 1391.9000244140625,
                            "gain": -2.200000047683716,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 1.2100000381469727,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band6": {
                            "frequency": 4007.300048828125,
                            "gain": -0.800000011920929,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 2.0,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band7": {
                            "frequency": 6045.10009765625,
                            "gain": -2.4000000953674316,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 6.0,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band8": {
                            "frequency": 7286.10009765625,
                            "gain": 1.5,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 4.110000133514404,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band9": {
                            "frequency": 10000.0,
                            "gain": -3.0999999046325684,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 0.699999988079071,
                            "slope": "x1",
                            "solo": false,
                            "type": "Hi-shelf",
                            "width": 4.0
                        }
                    },
                    "split-channels": false
                },
                "plugins_order": [
                    "equalizer#0"
                ]
            }
        }
      '';
    };

    xdg.configFile."easyeffects/output/660S.json" = {
      text = ''
              {
            "output": {
                "blocklist": [],
                "equalizer#0": {
                    "balance": 0.0,
                    "bypass": false,
                    "input-gain": -12.77,
                    "left": {
                        "band0": {
                            "frequency": 105.0,
                            "gain": 6.400000095367432,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 0.699999988079071,
                            "slope": "x1",
                            "solo": false,
                            "type": "Lo-shelf",
                            "width": 4.0
                        },
                        "band1": {
                            "frequency": 20.0,
                            "gain": 3.5,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 5.869999885559082,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band2": {
                            "frequency": 25.0,
                            "gain": 4.300000190734863,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 1.4700000286102295,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band3": {
                            "frequency": 59.599998474121094,
                            "gain": -0.30000001192092896,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 1.090000033378601,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band4": {
                            "frequency": 171.0,
                            "gain": -3.0,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 0.4699999988079071,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band5": {
                            "frequency": 1274.4000244140625,
                            "gain": -2.299999952316284,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 1.5,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band6": {
                            "frequency": 2136.89990234375,
                            "gain": 1.600000023841858,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 2.619999885559082,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band7": {
                            "frequency": 5456.60009765625,
                            "gain": -6.599999904632568,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 5.239999771118164,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band8": {
                            "frequency": 9125.2998046875,
                            "gain": 7.300000190734863,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 0.6700000166893005,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band9": {
                            "frequency": 10000.0,
                            "gain": -2.5999999046325684,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 0.699999988079071,
                            "slope": "x1",
                            "solo": false,
                            "type": "Hi-shelf",
                            "width": 4.0
                        }
                    },
                    "mode": "IIR",
                    "num-bands": 10,
                    "output-gain": 0.0,
                    "pitch-left": 0.0,
                    "pitch-right": 0.0,
                    "right": {
                        "band0": {
                            "frequency": 105.0,
                            "gain": 6.400000095367432,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 0.699999988079071,
                            "slope": "x1",
                            "solo": false,
                            "type": "Lo-shelf",
                            "width": 4.0
                        },
                        "band1": {
                            "frequency": 20.0,
                            "gain": 3.5,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 5.869999885559082,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band2": {
                            "frequency": 25.0,
                            "gain": 4.300000190734863,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 1.4700000286102295,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band3": {
                            "frequency": 59.599998474121094,
                            "gain": -0.30000001192092896,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 1.090000033378601,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band4": {
                            "frequency": 171.0,
                            "gain": -3.0,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 0.4699999988079071,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band5": {
                            "frequency": 1274.4000244140625,
                            "gain": -2.299999952316284,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 1.5,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band6": {
                            "frequency": 2136.89990234375,
                            "gain": 1.600000023841858,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 2.619999885559082,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band7": {
                            "frequency": 5456.60009765625,
                            "gain": -6.599999904632568,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 5.239999771118164,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band8": {
                            "frequency": 9125.2998046875,
                            "gain": 7.300000190734863,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 0.6700000166893005,
                            "slope": "x1",
                            "solo": false,
                            "type": "Bell",
                            "width": 4.0
                        },
                        "band9": {
                            "frequency": 10000.0,
                            "gain": -2.5999999046325684,
                            "mode": "APO (DR)",
                            "mute": false,
                            "q": 0.699999988079071,
                            "slope": "x1",
                            "solo": false,
                            "type": "Hi-shelf",
                            "width": 4.0
                        }
                    },
                    "split-channels": false
                },
                "plugins_order": [
                    "equalizer#0"
                ]
            }
        }
      '';
    };
  };
}
