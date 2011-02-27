# MBTA Real-Time Subway Predictions

This script converts the MBTA's real-time subway data into a JSON feed.

This script was written for the [Open Civic Data][ocd] project.

[ocd]:http://opencivicdata.org/

## Demonstration Feed

Predictions:

* <http://openmbta.org/ocd/subway_predictions.json>

To estimate train positions:

* <http://openmbta.org/ocd/train_locations.json>

## Usage

    ruby geo_subway_stops.rb
    ruby polylines.rb

    ruby subway_predictions.rb  
    ruby train_locations.rb

Run the latter two on cron every x minutes.

## Predictions Response Format
    [
      {
        "line": "Red",
        "trips": [
          {
            "trip_id": 95,
            "predictions": [
              {
                "name": "Quincy Adams Station",
                "status": "Arrived",
                "time": "2011-02-26T16:23:59+00:00",
                "type": "Revenue",
                "route": "Braintree Branch"
              },
              {
                "name": "Braintree Station",
                "status": "Predicted",
                "time": "2011-02-26T16:28:00+00:00",
                "type": "Revenue",
                "route": "Braintree Branch"
              }
            ]
          }, ...
        ]
      },
      {
        "line": "Blue",
        "trips": [
          {
            "trip_id": 112,
            "predictions": [
              {
                "name": "Bowdoin Station",
                "status": "Arrived",
                "time": "2011-02-26T16:19:51+00:00",
                "type": "Revenue",
                "route": "0"
              }
            ]
          },
        ...

## Locations Response Format

    {
      "Red": [
        {
          "left": {
            "name": "Quincy Adams Station",
            "time": "2011-02-26 13:32:39 -0500",
            "geo": [
              -71.006839,
              42.23334
            ]
          },
          "arriving": {
            "name": "Braintree Station",
            "time": "2011-02-26 13:36:53 -0500",
            "geo": [
              -71.001601,
              42.207411
            ]
          }
        },

## References

<http://www.eot.state.ma.us/developers/>

<http://developer.mbta.com/RT_Archive/DataExplained.txt>

<http://developer.mbta.com/RT_Archive/RealTimeHeavyRailKeys.csv>


