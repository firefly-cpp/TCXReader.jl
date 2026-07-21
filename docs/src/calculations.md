# Calculation semantics

[`loadTCXFile`](@ref) calls [`calculate_averages_and_totals`](@ref) for each activity. The resulting values populate the aggregate fields on [`TCXActivity`](@ref). The behavior below is intentionally preserved for compatibility.

## Lap totals

`total_time`, `total_distance`, and `total_calories` are sums of the corresponding lap metadata. Missing lap values are parsed as zero. These totals are still available when the activity has no track points.

## Track-point statistics

Track points are flattened in lap order. Every available sample has equal weight; averages are not weighted by elapsed time or distance.

- `avg_hr` and `max_hr` use available heart-rate samples and ignore missing samples.
- `avg_speed` and `max_speed` use available track-point speed samples. A lap's `maximumSpeed` or extension `avgSpeed` field is not substituted into these activity metrics.
- `avg_cadence_zero_avg_on` uses only strictly positive cadence samples.
- `avg_cadence_zero_avg_off` includes every track point, treating a missing cadence value as zero.
- `max_cadence` is the maximum strictly positive cadence sample.
- `avg_watts_zero_avg_on` and `max_watts` use only strictly positive power samples.
- `avg_watts_zero_avg_off` includes every track point, treating a missing power value as zero.

If no usable sample exists for one of these metrics, its aggregate value is zero.

## Elevation

`max_altitude` is the maximum available altitude sample. Ascent and descent are calculated from consecutive *available* altitude values after missing altitudes have been removed. Consequently, the calculation bridges missing-altitude samples and lap boundaries:

- positive changes contribute to `total_ascent`;
- negative changes contribute their absolute value to `total_descent`;
- unchanged altitude contributes to neither.

If an activity has no track points, all track-point-derived statistics, including elevation, are zero while its lap totals are retained.

## CSV representation

CSV output is trackpoint-oriented rather than lap-oriented. Each track point produces one row containing its author, activity, and lap context. Missing optional track-point and heart-rate values become empty CSV cells. Laps without track points produce no row, so CSV row count is not an activity or lap count.
