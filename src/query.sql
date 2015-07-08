-- MC, MFC, GM
-- kindFlow(all,fnf,fff,fff,graduacao,doutorado...)
-- kindContext(instituition,city,state,region,country,continent)
-- kingTime(all,rangeAll,rangeYear)
-- id16(all,set,specific)

#### list regions
SELECT id, name, kind, latitude, longitude, belong_to
  FROM place where kind = 'region';

#### list countries
SELECT id, name, kind, latitude, longitude, belong_to
  FROM place where kind = 'country';

#### cities from states
SELECT city.id, city.name, city.kind, city.latitude, city.longitude
  FROM public.place city, public.place state
  WHERE city.belong_to = state.id AND state.kind = 'state' AND state.name = 'paraiba';




#### fnf-instituition-all
SELECT 
  row_number() OVER () as id,
  source.name oname,
  source.latitude oy, 
  source.longitude ox, 
  target.name dname, 
  cityTarget.latitude dy, 
  cityTarget.longitude dx,
  count(*) trips
FROM 
  public.place source,
  public.place target,
  public.place cityTarget,
  public.edge edge
WHERE 
  source.id = edge.source AND
  source.kind = 'city' AND
  
  target.id = edge.target AND
  target.belong_to = cityTarget.id AND
  cityTarget.kind = 'city'
GROUP BY
  oy, ox, oname, dx, dy, dname
ORDER BY oname, dname;




#### fnf-city-all
SELECT 
  row_number() OVER () as id,
  source.name oname,
  source.latitude oy, 
  source.longitude ox, 
  cityTarget.name dname, 
  cityTarget.latitude dy, 
  cityTarget.longitude dx,
  count(*) trips
FROM 
  public.place source,
  public.place target,
  public.place cityTarget,
  public.edge edge
WHERE 
  source.id = edge.source AND
  source.kind = 'city' AND
  
  target.id = edge.target AND
  target.belong_to = cityTarget.id AND
  cityTarget.kind = 'city'
GROUP BY
  oy, ox, oname, dx, dy, dname
ORDER BY oname, dname;




#### fnf-state-all
SELECT 
  row_number() OVER () as id,
  stateSource.name oname,
  stateSource.latitude oy, 
  stateSource.longitude ox, 
  stateTarget.name dname, 
  stateTarget.latitude dy, 
  stateTarget.longitude dx,
  count(*) trips
FROM 
  public.place source,
  public.place target,
  public.place cityTaget,
  public.place stateSource,
  public.place stateTarget,
  public.edge edge
WHERE 
  source.id = edge.source AND
  source.belong_to = stateSource.id AND
  stateSource.kind = 'state' AND
  
  target.id = edge.target AND
  target.belong_to = cityTaget.id AND
  cityTaget.belong_to = stateTarget.id AND
  stateTarget.kind = 'state'
GROUP BY
  oy, ox, oname, dx, dy, dname
ORDER BY oname, dname;




#### fnf-region-1950-2013
SELECT 
  row_number() OVER () as id,
  regionSource.name oname,
  regionSource.latitude oy, 
  regionSource.longitude ox, 
  regionTarget.name dname, 
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
  edge.end_year BETWEEN 1950 AND 2013 AND

  source.id = edge.source AND
  source.belong_to = stateSource.id AND
  stateSource.belong_to = regionSource.id AND
  regionSource.kind = 'region' AND
  
  target.id = edge.target AND
  target.belong_to = cityTaget.id AND
  cityTaget.belong_to = stateTarget.id AND
  stateTarget.belong_to = regionTarget.id AND
  regionTarget.kind = 'region'
GROUP BY
  oy, ox, oname, dx, dy, dname, eyear 
ORDER BY oname, dname, eyear;

#### fnf-region-all
SELECT 
  row_number() OVER () as id,
  regionSource.name oname,
  regionSource.latitude oy, 
  regionSource.longitude ox, 
  regionTarget.name dname, 
  regionTarget.latitude dy, 
  regionTarget.longitude dx,
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
  source.id = edge.source AND
  source.belong_to = stateSource.id AND
  stateSource.belong_to = regionSource.id AND
  regionSource.kind = 'region' AND
  
  target.id = edge.target AND
  target.belong_to = cityTaget.id AND
  cityTaget.belong_to = stateTarget.id AND
  stateTarget.belong_to = regionTarget.id AND
  regionTarget.kind = 'region'
GROUP BY
  oy, ox, oname, dx, dy, dname
ORDER BY oname, dname;

#### fff-region-all
SELECT 
  row_number() OVER () as id,
  regionSource.name oname,
  regionSource.latitude oy, 
  regionSource.longitude ox, 
  regionTarget.name dname, 
  regionTarget.latitude dy, 
  regionTarget.longitude dx,
  count(*) trips
FROM 
  public.place source,
  public.place target,
  public.place cityTaget,
  public.place citySource,
  public.place stateSource,
  public.place stateTarget,
  public.place regionSource,
  public.place regionTarget,
  public.edge edge
WHERE 
  edge.kind != 'work' AND
  
  source.id = edge.source AND
  source.belong_to = citySource.id AND
  citySource.belong_to = stateSource.id AND
  stateSource.belong_to = regionSource.id AND
  regionSource.kind = 'region' AND

  target.id = edge.target AND
  target.belong_to = cityTaget.id AND
  cityTaget.belong_to = stateTarget.id AND
  stateTarget.belong_to = regionTarget.id AND
  regionTarget.kind = 'region'
GROUP BY
  oy, ox, oname, dx, dy, dname
ORDER BY oname, dname;

#### fft-region-all
SELECT 
  row_number() OVER () as id,
  regionSource.name oname,
  regionSource.latitude oy, 
  regionSource.longitude ox, 
  regionTarget.name dname, 
  regionTarget.latitude dy, 
  regionTarget.longitude dx,
  count(*) trips
FROM 
  public.place source,
  public.place target,
  public.place cityTaget,
  public.place citySource,
  public.place stateSource,
  public.place stateTarget,
  public.place regionSource,
  public.place regionTarget,
  public.edge edge
WHERE 
  edge.kind = 'work' AND
  
  source.id = edge.source AND
  source.belong_to = citySource.id AND
  citySource.belong_to = stateSource.id AND
  stateSource.belong_to = regionSource.id AND
  regionSource.kind = 'region' AND

  target.id = edge.target AND
  target.belong_to = cityTaget.id AND
  cityTaget.belong_to = stateTarget.id AND
  stateTarget.belong_to = regionTarget.id AND
  regionTarget.kind = 'region'
GROUP BY
  oy, ox, oname, dx, dy, dname
ORDER BY oname, dname;

#### all-region-all
SELECT 
  row_number() OVER () as id, oname, oy, ox, dname, dy, dx, count(*) trips
FROM 
  (SELECT 
    regionSource.name oname,
    regionSource.latitude oy, 
    regionSource.longitude ox, 
    regionTarget.name dname, 
    regionTarget.latitude dy, 
    regionTarget.longitude dx
  FROM 
    public.place source,
    public.place target,
    public.place cityTaget,
    public.place citySource,
    public.place stateSource,
    public.place stateTarget,
    public.place regionSource,
    public.place regionTarget,
    public.edge edge
  WHERE 
    edge.kind = 'work' AND
    
    source.id = edge.source AND
    source.belong_to = citySource.id AND
    citySource.belong_to = stateSource.id AND
    stateSource.belong_to = regionSource.id AND
    regionSource.kind = 'region' AND

    target.id = edge.target AND
    target.belong_to = cityTaget.id AND
    cityTaget.belong_to = stateTarget.id AND
    stateTarget.belong_to = regionTarget.id AND
    regionTarget.kind = 'region'
  UNION ALL
  SELECT 
    regionSource.name oname,
    regionSource.latitude oy, 
    regionSource.longitude ox, 
    regionTarget.name dname, 
    regionTarget.latitude dy, 
    regionTarget.longitude dx
  FROM 
    public.place source,
    public.place target,
    public.place cityTaget,
    public.place citySource,
    public.place stateSource,
    public.place stateTarget,
    public.place regionSource,
    public.place regionTarget,
    public.edge edge
  WHERE 
    edge.kind != 'work' AND
    
    source.id = edge.source AND
    source.belong_to = citySource.id AND
    citySource.belong_to = stateSource.id AND
    stateSource.belong_to = regionSource.id AND
    regionSource.kind = 'region' AND

    target.id = edge.target AND
    target.belong_to = cityTaget.id AND
    cityTaget.belong_to = stateTarget.id AND
    stateTarget.belong_to = regionTarget.id AND
    regionTarget.kind = 'region'
  UNION ALL
  SELECT 
    regionSource.name oname,
    regionSource.latitude oy, 
    regionSource.longitude ox, 
    regionTarget.name dname, 
    regionTarget.latitude dy, 
    regionTarget.longitude dx
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
    source.id = edge.source AND
    source.belong_to = stateSource.id AND
    stateSource.belong_to = regionSource.id AND
    regionSource.kind = 'region' AND
    
    target.id = edge.target AND
    target.belong_to = cityTaget.id AND
    cityTaget.belong_to = stateTarget.id AND
    stateTarget.belong_to = regionTarget.id AND
    regionTarget.kind = 'region') flows
GROUP BY
  oname, oy, ox, dname, dy, dx
ORDER BY oname, dname;




#### fnf-country-all
SELECT 
  row_number() OVER () as id, oname, oy, ox, dname, dy, dx, count(*) trips
FROM
  (SELECT 
    countrySource.name oname,
    countrySource.latitude oy, 
    countrySource.longitude ox, 
    countryTarget.name dname, 
    countryTarget.latitude dy, 
    countryTarget.longitude dx
  FROM 
    public.place source,
    public.place target,
    public.place cityTaget,
    public.place stateSource,
    public.place stateTarget,
    public.place regionSource,
    public.place regionTarget,
    public.place countrySource,
    public.place countryTarget,
    public.edge edge
  WHERE 
    source.id = edge.source AND
    source.belong_to = stateSource.id AND
    stateSource.belong_to = regionSource.id AND
    regionSource.belong_to = countrySource.id AND
    countrySource.kind = 'country' AND
    
    target.id = edge.target AND
    target.belong_to = cityTaget.id AND
    cityTaget.belong_to = stateTarget.id AND
    stateTarget.belong_to = regionTarget.id AND
    regionTarget.belong_to = countryTarget.id AND
    countryTarget.kind = 'country'
  UNION ALL
  SELECT 
    countrySource.name oname,
    countrySource.latitude oy, 
    countrySource.longitude ox, 
    countryTarget.name dname, 
    countryTarget.latitude dy, 
    countryTarget.longitude dx
  FROM 
    public.place source,
    public.place target,
    public.place cityTaget,
    public.place stateSource,
    public.place regionSource,
    public.place countrySource,
    public.place countryTarget,
    public.edge edge
  WHERE 
    source.id = edge.source AND
    source.belong_to = stateSource.id AND
    stateSource.belong_to = regionSource.id AND
    regionSource.belong_to = countrySource.id AND
    countrySource.kind = 'country' AND
    
    target.id = edge.target AND
    target.belong_to = cityTaget.id AND
    cityTaget.belong_to = countryTarget.id AND
    countryTarget.kind = 'country'
  UNION ALL
  SELECT 
    countrySource.name oname,
    countrySource.latitude oy, 
    countrySource.longitude ox, 
    countryTarget.name dname, 
    countryTarget.latitude dy, 
    countryTarget.longitude dx
  FROM 
    public.place source,
    public.place target,
    public.place cityTaget,
    public.place stateTarget,
    public.place regionTarget,
    public.place countrySource,
    public.place countryTarget,
    public.edge edge
  WHERE 
    source.id = edge.source AND
    source.belong_to = countrySource.id AND
    countrySource.kind = 'country' AND
    
    target.id = edge.target AND
    target.belong_to = cityTaget.id AND
    cityTaget.belong_to = stateTarget.id AND
    stateTarget.belong_to = regionTarget.id AND
    regionTarget.belong_to = countryTarget.id AND
    countryTarget.kind = 'country'
  UNION ALL
  SELECT 
    countrySource.name oname,
    countrySource.latitude oy, 
    countrySource.longitude ox, 
    countryTarget.name dname, 
    countryTarget.latitude dy, 
    countryTarget.longitude dx
  FROM 
    public.place source,
    public.place target,
    public.place cityTaget,
    public.place countrySource,
    public.place countryTarget,
    public.edge edge
  WHERE 
    source.id = edge.source AND
    source.belong_to = countrySource.id AND
    countrySource.kind = 'country' AND
    
    target.id = edge.target AND
    target.belong_to = cityTaget.id AND
    cityTaget.belong_to = countryTarget.id AND
    countryTarget.kind = 'country') flows
GROUP BY
  oy, ox, oname, dx, dy, dname
ORDER BY oname, dname;

#### fnf-continent-all
SELECT 
  row_number() OVER () as id, oname, oy, ox, dname, dy, dx, count(*) trips
FROM
  (SELECT 
    continentSource.name oname,
    continentSource.latitude oy, 
    continentSource.longitude ox, 
    continentTarget.name dname, 
    continentTarget.latitude dy, 
    continentTarget.longitude dx
  FROM 
    public.place source,
    public.place target,
    public.place cityTaget,
    public.place stateSource,
    public.place stateTarget,
    public.place regionSource,
    public.place regionTarget,
    public.place countrySource,
    public.place countryTarget,
    public.place continentSource,
    public.place continentTarget,
    public.edge edge
  WHERE 
    source.id = edge.source AND
    source.belong_to = stateSource.id AND
    stateSource.belong_to = regionSource.id AND
    stateSource.kind = 'state' AND
    regionSource.belong_to = countrySource.id AND
    countrySource.belong_to = continentSource.id AND
    continentSource.kind = 'continent' AND
    
    target.id = edge.target AND
    target.belong_to = cityTaget.id AND
    cityTaget.belong_to = stateTarget.id AND
    stateTarget.belong_to = regionTarget.id AND
    stateTarget.kind = 'state' AND
    regionTarget.belong_to = countryTarget.id AND
    countryTarget.belong_to = continentTarget.id AND
    continentTarget.kind = 'continent'
  UNION ALL
  SELECT 
    continentSource.name oname,
    continentSource.latitude oy, 
    continentSource.longitude ox, 
    continentTarget.name dname, 
    continentTarget.latitude dy, 
    continentTarget.longitude dx
  FROM 
    public.place source,
    public.place target,
    public.place cityTaget,
    public.place stateSource,
    public.place regionSource,
    public.place countrySource,
    public.place countryTarget,
    public.place continentSource,
    public.place continentTarget,
    public.edge edge
  WHERE 
    source.id = edge.source AND
    source.belong_to = stateSource.id AND
    stateSource.belong_to = regionSource.id AND
    stateSource.kind = 'state' AND
    regionSource.belong_to = countrySource.id AND
    countrySource.belong_to = continentSource.id AND
    continentSource.kind = 'continent' AND
    
    target.id = edge.target AND
    target.belong_to = cityTaget.id AND
    cityTaget.belong_to = countryTarget.id AND
    countryTarget.belong_to = continentTarget.id AND
    continentTarget.kind = 'continent'
  UNION ALL
  SELECT 
    continentSource.name oname,
    continentSource.latitude oy, 
    continentSource.longitude ox, 
    continentTarget.name dname, 
    continentTarget.latitude dy, 
    continentTarget.longitude dx
  FROM 
    public.place source,
    public.place target,
    public.place cityTaget,
    public.place stateTarget,
    public.place regionTarget,
    public.place countrySource,
    public.place countryTarget,
    public.place continentSource,
    public.place continentTarget,
    public.edge edge
  WHERE 
    source.id = edge.source AND
    source.belong_to = countrySource.id AND
    countrySource.belong_to = continentSource.id AND
    continentSource.kind = 'continent' AND
    
    target.id = edge.target AND
    target.belong_to = cityTaget.id AND
    cityTaget.belong_to = stateTarget.id AND
    stateTarget.belong_to = regionTarget.id AND
    stateTarget.kind = 'state' AND
    regionTarget.belong_to = countryTarget.id AND
    countryTarget.belong_to = continentTarget.id AND
    continentTarget.kind = 'continent'
  UNION ALL
  SELECT 
    continentSource.name oname,
    continentSource.latitude oy, 
    continentSource.longitude ox, 
    continentTarget.name dname, 
    continentTarget.latitude dy, 
    continentTarget.longitude dx
  FROM 
    public.place source,
    public.place target,
    public.place cityTaget,
    public.place countrySource,
    public.place countryTarget,
    public.place continentSource,
    public.place continentTarget,
    public.edge edge
  WHERE 
    source.id = edge.source AND
    source.belong_to = countrySource.id AND
    countrySource.belong_to = continentSource.id AND
    continentSource.kind = 'continent' AND
    
    target.id = edge.target AND
    target.belong_to = cityTaget.id AND
    cityTaget.belong_to = countryTarget.id AND
    countryTarget.belong_to = continentTarget.id AND
    continentTarget.kind = 'continent') flows
GROUP BY
  oy, ox, oname, dx, dy, dname
ORDER BY oname, dname;
