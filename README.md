# ParkingService

To start server:

- Install dependencies with `mix deps.get`
- Start Phoenix server with `mix phx.server`

Configured resources:

```
  resources: [
    %{id: 534_001, refresh_period: 1},
    %{id: 534_002, refresh_period: 4},
    %{id: 534_003, refresh_period: 5},
    %{id: 534_004, refresh_period: 6},
    %{id: 534_005, refresh_period: 5},
    %{id: 534_013, refresh_period: 5},
    %{id: 534_007, refresh_period: 6}
  ]
```

Endpoint [`localhost:4000/parkings/534001`](http://localhost:4000/parkings/534001) for getting data about parking places:

```
curl http://localhost:4000/parkings/534001 | jq .
```

Due to the initial 1 minute delay of the `crawler` and the `refresh_period` of 1 minute the data will be sync in about 2 minutes for resource `534001`

Endpoint `/crawlers/534013` for changing refresh_period for a particular resource:

```
curl -X POST -H "Content-Type: application/json" \
 -d '{"refresh_period": 8}' \
 http://localhost:4000/crawlers/534013
```
