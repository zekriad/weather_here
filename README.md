# WeatherHere Demo App

This demo app exposes 2 endpoints: `GET /api/forecasts/zip/:zip` & `GET /api/forecasts/address/:address`.
Both return current weather conditions for the location.
Caching and logic are contained in `/app/interactors/forecast/`.
Basic RSpec tests in `/spec/`.

The exclusion of ActiveRecord models in this project was an intentional choice.
The Rails cache has the features required and does not need any infrastructure or setup.

### Improvements
Any address works, as long as it ends in a zip code. This is an obvious place that needs improvement.
Another improvement would be a static zip/coordinate yaml file loaded into memory on startup.

### Demo
`rails dev:cache`

`rails s`

```
❯ curl localhost:3000/api/forecasts/zip/90210.json
{"starts_at":"2024-10-21T07:00:00-07:00","ends_at":"2024-10-21T08:00:00-07:00","temperature":64,"short_forecast":"Mostly Sunny","icon":"https://api.weather.gov/icons/land/day/sct?size=small","cached":false}%

❯ curl localhost:3000/api/forecasts/zip/90210.json
{"starts_at":"2024-10-21T07:00:00-07:00","ends_at":"2024-10-21T08:00:00-07:00","temperature":64,"short_forecast":"Mostly Sunny","icon":"https://api.weather.gov/icons/land/day/sct?size=small","cached":true}%

❯ curl localhost:3000/api/forecasts/address/hiya%20st%2090210.json
{"starts_at":"2024-10-21T07:00:00-07:00","ends_at":"2024-10-21T08:00:00-07:00","temperature":64,"short_forecast":"Mostly Sunny","icon":"https://api.weather.gov/icons/land/day/sct?size=small","cached":true}
```

