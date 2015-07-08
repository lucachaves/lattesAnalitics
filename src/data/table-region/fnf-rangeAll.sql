SELECT 
  row_number() OVER () as id,
  regionSource.acronym oname,
  regionSource.latitude oy, 
  regionSource.longitude ox, 
  regionTarget.acronym dname, 
  regionTarget.latitude dy, 
  regionTarget.longitude dx,
  edge.end_year eyear,
  count(*) trips
FROM 
  public.place source,
  public.place target,
  public.place cityTaget,
  public.place stateSource,
  public.place stateTarget,
  public.place regionSource,
  public.place regionTarget,
  public.edge edge
WHERE 
  edge.end_year BETWEEN _START_YEAR_ AND _END_YEAR_ AND
  source.id = edge.source AND
  source.belong_to = stateSource.id AND
  stateSource.kind = 'state' AND
  stateSource.belong_to = regionSource.id AND
  regionSource.kind = 'region' AND
  target.id = edge.target AND
  target.belong_to = cityTaget.id AND
  cityTaget.belong_to = stateTarget.id AND
  stateTarget.belong_to = regionTarget.id AND
  stateTarget.kind = 'state' AND
  regionTarget.kind = 'region'
GROUP BY
  oy, ox, oname, dx, dy, dname, eyear 
ORDER BY oname, dname, eyear
