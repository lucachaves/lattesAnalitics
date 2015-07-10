
-- list regions
SELECT * FROM place where kind = 'region';

-- list countries
SELECT * FROM place where kind = 'country';

-- cities from states
SELECT city.id, city.name, city.kind, city.latitude, city.longitude
  FROM public.place city, public.place state
  WHERE city.belong_to = state.id AND state.kind = 'state' AND state.name = 'paraiba';

-- sql.top10.instituition.doutorado
SELECT  
  place.acronym place,
  count(*) degree 
FROM 
  public.edge, 
  public.place
WHERE 
  edge.target = place.id
  AND edge.kind = 'doutorado'
  AND place.kind = 'instituition'
GROUP BY
  place
ORDER BY
  degree DESC
LIMIT 10

-- UPDATE acronym by id
UPDATE place SET acronym='UNICAMP' WHERE id = 450;



















#### fnf-instituition-all
SELECT 
  row_number() OVER () as id,
  source.acronym oname,
  source.latitude oy, 
  source.longitude ox, 
  target.acronym dname, 
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
  source.acronym oname,
  source.latitude oy, 
  source.longitude ox, 
  cityTarget.acronym dname, 
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
  stateSource.acronym oname,
  stateSource.latitude oy, 
  stateSource.longitude ox, 
  stateTarget.acronym dname, 
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
  regionSource.acronym oname,
  regionSource.latitude oy, 
  regionSource.longitude ox, 
  regionTarget.acronym dname, 
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
  regionSource.acronym oname,
  regionSource.latitude oy, 
  regionSource.longitude ox, 
  regionTarget.acronym dname, 
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
  regionSource.acronym oname,
  regionSource.latitude oy, 
  regionSource.longitude ox, 
  regionTarget.acronym dname, 
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
    regionSource.acronym oname,
    regionSource.latitude oy, 
    regionSource.longitude ox, 
    regionTarget.acronym dname, 
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
    regionSource.acronym oname,
    regionSource.latitude oy, 
    regionSource.longitude ox, 
    regionTarget.acronym dname, 
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
    regionSource.acronym oname,
    regionSource.latitude oy, 
    regionSource.longitude ox, 
    regionTarget.acronym dname, 
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
    countrySource.acronym oname,
    countrySource.latitude oy, 
    countrySource.longitude ox, 
    countryTarget.acronym dname, 
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
    countrySource.acronym oname,
    countrySource.latitude oy, 
    countrySource.longitude ox, 
    countryTarget.acronym dname, 
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
    countrySource.acronym oname,
    countrySource.latitude oy, 
    countrySource.longitude ox, 
    countryTarget.acronym dname, 
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
    countrySource.acronym oname,
    countrySource.latitude oy, 
    countrySource.longitude ox, 
    countryTarget.acronym dname, 
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


###### CONTINENT ######

instituition -> 
  city ->
    country -> continent
    state -> region -> country -> continent

nacional instituition
foreign instituition
nacional city
foreign city

fnf
  city <-> instituition
fff, fft
  instituition <-> instituition
all
  city <-> instituition, instituition <-> instituition

city ->

SELECT 
  row_number() OVER () as id, oname, oy, ox, dname, dy, dx, count(*) trips
FROM

(SELECT 
  continentSource.acronym oname,
  continentSource.latitude oy, 
  continentSource.longitude ox, 
  continentTarget.acronym dname, 
  continentTarget.latitude dy, 
  continentTarget.longitude dx

-- nacional instituition
FROM 
  public.place instituitionSource,
  public.place citySource,
  public.place stateSource,
  public.place regionSource,
  public.place countrySource,
  public.place continentSource,
  public.edge edge
WHERE
  instituitionSource.id = edge.source AND
  instituitionSource.kind = 'instituition' AND
  instituitionSource.belong_to = citySource.id AND
  citySource.kind = 'city' AND
  citySource.belong_to = stateSource.id AND
  stateSource.kind = 'state' AND
  stateSource.belong_to = regionSource.id AND
  regionSource.kind = 'region' AND
  regionSource.belong_to = countrySource.id AND
  countrySource.kind = 'country' AND
  countrySource.belong_to = continentSource.id AND
  continentSource.kind = 'continent'

-- foreign instituition
FROM 
  public.place instituitionSource,
  public.place citySource,
  public.place countrySource,
  public.place continentSource,
  public.edge edge
WHERE
  instituitionSource.id = edge.source AND
  instituitionSource.kind = 'instituition' AND
  instituitionSource.belong_to = citySource.id AND
  citySource.kind = 'city' AND
  citySource.belong_to = countrySource.id AND
  countrySource.kind = 'country' AND
  countrySource.belong_to = continentSource.id AND
  continentSource.kind = 'continent'

-- nacional city
FROM 
  public.place citySource,
  public.place stateSource,
  public.place regionSource,
  public.place countrySource,
  public.place continentSource,
  public.edge edge
WHERE
  citySource.id = edge.source AND
  citySource.kind = 'city' AND
  citySource.belong_to = stateSource.id AND
  stateSource.kind = 'state' AND
  stateSource.belong_to = regionSource.id AND
  regionSource.kind = 'region' AND
  regionSource.belong_to = countrySource.id AND
  countrySource.kind = 'country' AND
  countrySource.belong_to = continentSource.id AND
  continentSource.kind = 'continent'

-- foreign city
FROM 
  public.place citySource,
  public.place countrySource,
  public.place continentSource,
  public.edge edge
WHERE
  citySource.id = edge.source AND
  citySource.belong_to = countrySource.id AND
  citySource.kind = 'city' AND
  countrySource.belong_to = continentSource.id AND
  countrySource.kind = 'country' AND
  continentSource.kind = 'continent') flows

GROUP BY
  oy, ox, oname, dx, dy, dname
ORDER BY oname, dname

#### fnf
city <-> instituition

city -> state -> region -> country -> continent 
instituition -> city -> state -> region -> country -> continent

city -> state -> region -> country -> continent 
instituition -> city -> country -> continent

city -> country -> continent
instituition -> city -> state -> region -> country -> continent

city -> country -> continent 
instituition -> city -> country -> continent


#### fff
instituition <-> instituition (WHERE kind != work)

instituition -> city -> state -> region -> country -> continent
instituition -> city -> state -> region -> country -> continent

instituition -> city -> state -> region -> country -> continent
instituition -> city -> country -> continent

instituition -> city -> country -> continent
instituition -> city -> state -> region -> country -> continent

instituition -> city -> country -> continent
instituition -> city -> country -> continent

#### fft
instituition <-> instituition (WHERE kind = work)

instituition -> city -> state -> region -> country -> continent
instituition -> city -> state -> region -> country -> continent

instituition -> city -> state -> region -> country -> continent
instituition -> city -> country -> continent

instituition -> city -> country -> continent
instituition -> city -> state -> region -> country -> continent

instituition -> city -> country -> continent
instituition -> city -> country -> continent

#### all

city -> state -> region -> country -> continent 
instituition -> city -> state -> region -> country -> continent

city -> state -> region -> country -> continent 
instituition -> city -> country -> continent

city -> country -> continent
instituition -> city -> state -> region -> country -> continent

city -> country -> continent 
instituition -> city -> country -> continent

instituition -> city -> state -> region -> country -> continent
instituition -> city -> state -> region -> country -> continent

instituition -> city -> state -> region -> country -> continent
instituition -> city -> country -> continent

instituition -> city -> country -> continent
instituition -> city -> state -> region -> country -> continent

instituition -> city -> country -> continent
instituition -> city -> country -> continent
