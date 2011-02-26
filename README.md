# MBTA Real-Time Subway Predictions

This script converts the MBTA's real-time subway data into a JSON feed.

This script was written for the [Open Civic Data][ocd] project.

[ocd]:http://opencivicdata.org/

## Demonstration Feed

<http://openmbta.org/ocd/subway_predictions.json>

## Usage

    ruby subway_predictions.rb  > subway_predictions.json

Run this on cron every x minutes.


## Response Format
[
  {
    "line": "Red",
    "trips": [
      {
        "trip_id": 95,
        "predictions": [
          {
            "name": "Quincy Adams Station",
            "code1": "place-qamnl",
            "code2": "RQUAS",
            "status": "Arrived",
            "time": "2011-02-26T16:23:59+00:00",
            "offset": "-00:03:04",
            "type": "Revenue",
            "route": "Braintree Branch"
          },
          {
            "name": "Braintree Station",
            "code1": "place-brntn",
            "code2": "RBRAS",
            "status": "Predicted",
            "time": "2011-02-26T16:28:00+00:00",
            "offset": "00:00:56",
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
            "code1": "place-bomnl",
            "code2": "BBOWW",
            "status": "Arrived",
            "time": "2011-02-26T16:19:51+00:00",
            "offset": "-00:07:08",
            "type": "Revenue",
            "route": "0"
          }
        ]
      },
    ...

## References

<http://www.eot.state.ma.us/developers/>

<http://developer.mbta.com/RT_Archive/DataExplained.txt>

<http://developer.mbta.com/RT_Archive/RealTimeHeavyRailKeys.csv>





