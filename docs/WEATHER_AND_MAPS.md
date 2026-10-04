# Weather and maps

Weather was demo data until this phase; it is now a real forecast. Maps were a
painted placeholder; they are now OpenStreetMap.

Both reach the network, which makes them the only two features in the app that
do (besides the one-time language model download). Both are built the same way:
**fetch when there is a signal, store on the phone, and read from the phone
from then on**. Neither can block a screen, and neither has an API key.

## Weather — Open-Meteo

`lib/services/weather/open_meteo_client.dart`

| | |
|---|---|
| **Service** | https://open-meteo.com |
| **Key** | None. No account, no registration, nothing secret in the APK |
| **Licence** | Data CC-BY 4.0; free tier is non-commercial. Credited on the About screen |
| **Endpoint** | `GET https://api.open-meteo.com/v1/forecast` |
| **Sent** | A latitude/longitude pair and the field list. No identifier, no farm data |
| **Transport** | `dart:io` `HttpClient`, the same as the model downloader — no new package |

Requested fields:

```
current  temperature_2m, relative_humidity_2m, precipitation, weather_code, wind_speed_10m
hourly   temperature_2m, weather_code, precipitation_probability, soil_moisture_3_to_9cm
daily    weather_code, temperature_2m_max, temperature_2m_min,
         precipitation_probability_max, precipitation_sum
timezone auto          forecast_days 7
```

### Soil moisture is now measured, not invented

`soil_moisture_3_to_9cm` is volumetric water content (m³/m³) in the layer where
most seedling roots sit — deeper than the surface layer, which dries too fast
to mean anything. It becomes the words on the Home card:

| m³/m³ | Label |
|---|---|
| < 0.10 | Dry |
| 0.10 – 0.19 | Low |
| 0.20 – 0.38 | Good |
| > 0.38 | Wet |

The arrow next to it is the real 24-hour change, taken from the hourly series.

This feeds the risk engine, so the risk level now moves with actual
conditions. On the first live run in Dili, soil moisture came back 0.13 → "Low",
and overall crop risk rose from Medium to **High** — a conclusion drawn from
measurement rather than a fixed demo number.

### WMO codes

Open-Meteo returns WMO interpretation codes; the app has six conditions, so
bands collapse onto the nearest one. An unrecognised code resolves to
`cloudy`, never `sunny` — guessing fair weather is the one wrong answer,
because it invites a farmer to leave a crop unprotected.

### Order of preference

```
live  → fetched from Open-Meteo, written to weather_cache  ("Live · Open-Meteo")
      → older than 3 hours                                  ("Saved · Open-Meteo")
manual→ conditions the farmer typed in                      ("Entered by you")
demo  → bundled sample, first run with no signal ever        ("Demo data (offline)")
```

`LocalWeatherService.refreshFromNetwork` **never throws**. A failed fetch logs
and returns false; the stored forecast stays on screen with its true age. That
is the entire point of the cache — a farmer in a valley with no bars still sees
the forecast from this morning, correctly labelled as this morning's.

A live payload records `baseTime`, the hour it starts from, so a forecast read
back hours later still labels its hours honestly instead of sliding to "now".

### Where the forecast is for

`FarmState.weatherLocation` is the first farm location with coordinates. With
none, it falls back to Dili (−8.5569, 125.5603). The Weather screen shows the
point on a map, because in Timor-Leste the coast and the highlands differ
sharply and "28°C" is meaningless without knowing where.

## Maps — OpenStreetMap

`lib/widgets/farm_map.dart`, `lib/services/map/tile_cache.dart`

| | |
|---|---|
| **Package** | `flutter_map` 8.3 + `latlong2` |
| **Tiles** | `https://tile.openstreetmap.org/{z}/{x}/{y}.png` |
| **Licence** | Map data © OpenStreetMap contributors, ODbL. Credited in the map corner — that notice must not be removed |
| **User-Agent** | `LafaekAIFarm/0.1`, as the OSM tile usage policy requires |

### Offline tiles

`MapTileCache` stores tiles under `<app support>/map_tiles/<z>_<x>_<y>.png`.
Written by hand rather than taken from a package: `path_provider` was already a
dependency, the behaviour needed is small, and the dedicated caching packages
carry licences this project would have to account for.

* A stored tile is served immediately — that is what makes the map work with
  no signal.
* Past 30 days it is still served, and refreshed quietly in the background.
* Cache holds 1,500 tiles (~25–40 MB), trimmed oldest-first.
* **Nothing throws.** No tile and no network draws a 1×1 transparent PNG, so
  the pin and the surrounding tiles stay readable instead of an error grid.
* If the cache directory cannot be opened at all, the map simply works online
  only.

### Pinning a field

The Add Location screen replaced a decorative background image and a "Use my
current location" button that only set a flag. Now:

* tap the map to drop a pin;
* or use GPS, which asks for permission at that moment;
* choosing a municipality moves the map there, so the farmer is not hunting;
* the pin is optional — without it, weather uses Dili.

Coordinates are stored on `farm_locations` (columns that existed but were
unused) and travel with the sync queue payload for the cloud phase.

## Connection quality

`lib/services/network_probe.dart`, `lib/services/connectivity_service.dart`

The app used to decide connection quality from the **interface type** alone:
Wi-Fi/ethernet → good, mobile → limited, none → offline. That was wrong in both
directions, and both cases matter here:

* **Wi-Fi attached to a router with no upstream** — or a captive portal, or a
  spent data bundle — reported *good*. The app said "You are online", the
  weather refresh failed silently, and the farmer had no idea why.
* **Ordinary 4G reported *limited***. Mobile data is the normal way to be
  online in Timor-Leste, so the app was telling most farmers their connection
  was weak when it was fine.

So the type is now only a **trigger**; the verdict comes from a measured
round-trip.

```
connectivity_plus says what is attached   (instant, free)
   none        → offline. No probe at all: offline must cost no battery or data
   anything else → probe and time it
         no reply / wrong status → offline  ("Wi-Fi · no internet")
         > 1500 ms               → limited  ("Mobile data · 2400 ms")
         otherwise               → good     ("Wi-Fi · 180 ms")
```

| | |
|---|---|
| **Endpoint** | `https://connectivitycheck.gstatic.com/generate_204` — Android's own check: HTTP 204, empty body, a few hundred bytes of headers and nothing else |
| **Timeout** | 5 s |
| **Slow threshold** | 1500 ms, set so a usable 3G link still counts as good. Slow pages are still pages |
| **Throttle** | At most one probe per 20 s, and concurrent callers share one in-flight probe |
| **Captive portals** | A portal answers 200 with a login page rather than 204; only the expected empty reply counts as working internet |

`ConnectivityState.connectionDetail` is the one line the UI shows — transport
plus the real number — and it appears in the AI status sheet and on Offline &
Sync, where "Check now" re-measures on demand.

### A startup flaw this uncovered

The first version assumed "no transport" until the platform answered, which
made the app report **offline for a moment on every launch** before flickering
to online. `check()` now waits for the first `checkConnectivity()` answer
instead of assuming. A test covers it.

### What it does not do

It measures *reachability and latency*, not bandwidth. A link can answer a
204 in 90 ms and still be too slow to pull a 770 MB model. Throughput would
need a real transfer, which is not worth a farmer's data to find out.

## Permissions

| Permission | Why | If refused |
|---|---|---|
| `INTERNET` | Forecast, map tiles, model download | Everything still works from local data |
| `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` | The "Use my current location" button only | Tap the map instead; nothing else changes |

`DeviceLocationService` turns every failure — services off, denied, denied
forever, no fix — into a plain sentence that tells the farmer to tap the map
instead. There is no dead end.

## What is deliberately still local

Weather and tiles are *data*. Every piece of **inference** stays on the phone:
the crop scanner, the language model, retrieval and the risk engine. No photo,
prompt or farm record leaves the device. Open-Meteo receives a coordinate pair
and nothing else.

## Tests

`test/weather_test.dart` — 18 tests against a recorded Open-Meteo response in
`test/fixtures/open_meteo_dili.json`:

* WMO code mapping, including the "never guess sunny" rule;
* soil moisture labels and the 24-hour delta, including divide-by-zero;
* payload shape, 8 hourly + 7 daily points, real rainfall in mm per day;
* hourly starts at the reading's hour, not midnight;
* attribution present;
* an incomplete response is rejected rather than half-parsed;
* demo data carries **no** rainfall figures, so the chart cannot imply measured
  data it does not have;
* a failed fetch leaves the cached forecast intact;
* freshness: a recent forecast reads "Live", an aged one reads "Saved".

## The rainfall chart

The Weather screen used to show a "Rainfall Map": a hand-painted gradient on a
hand-drawn island with four fixed blobs. It looked like data and was
decoration — identical whatever the weather.

It is now "Rain this week": one bar per day, height in millimetres from
`precipitation_sum`, with the chance of rain beneath. Millimetres is the number
a farmer can act on; a percentage alone does not say whether to irrigate. Days
with no data show a dash, and when the app only has demo data the card says so
rather than drawing a shape.
