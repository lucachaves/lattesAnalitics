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
  FROM 
    public.place source,
    public.place target,
    public.place citySource,
    public.place cityTarget,
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
    edge.kind = 'work' AND
    source.id = edge.source AND
    source.kind = 'instituition' AND
    source.belong_to = citySource.id AND
    citySource.belong_to = stateSource.id AND
    citySource.kind = 'city' AND
    stateSource.belong_to = regionSource.id AND
    stateSource.kind = 'state' AND
    regionSource.belong_to = countrySource.id AND
    regionSource.kind = 'region' AND
    countrySource.belong_to = continentSource.id AND
    countrySource.kind = 'country' AND
    continentSource.kind = 'continent' AND
    target.id = edge.target AND
    target.kind = 'instituition' AND
    target.belong_to = cityTarget.id AND
    cityTarget.belong_to = stateTarget.id AND
    cityTarget.kind = 'city' AND
    stateTarget.belong_to = regionTarget.id AND
    stateTarget.kind = 'state' AND
    regionTarget.belong_to = countryTarget.id AND
    regionTarget.kind = 'region' AND
    countryTarget.belong_to = continentTarget.id AND
    countryTarget.kind = 'country' AND
    continentTarget.kind = 'continent'
  UNION ALL
  SELECT 
    continentSource.acronym oname,
    continentSource.latitude oy, 
    continentSource.longitude ox, 
    continentTarget.acronym dname, 
    continentTarget.latitude dy, 
    continentTarget.longitude dx
  FROM 
    public.place source,
    public.place target,
    public.place citySource,
    public.place cityTarget,
    public.place stateSource,
    public.place regionSource,
    public.place countrySource,
    public.place countryTarget,
    public.place continentSource,
    public.place continentTarget,
    public.edge edge
  WHERE 
    edge.kind = 'work' AND
    source.id = edge.source AND
    source.kind = 'instituition' AND
    source.belong_to = citySource.id AND
    citySource.belong_to = stateSource.id AND
    citySource.kind = 'city' AND
    stateSource.belong_to = regionSource.id AND
    stateSource.kind = 'state' AND
    regionSource.belong_to = countrySource.id AND
    regionSource.kind = 'region' AND
    countrySource.belong_to = continentSource.id AND
    continentSource.kind = 'continent' AND
    target.id = edge.target AND
    target.kind = 'instituition' AND
    target.belong_to = cityTarget.id AND
    cityTarget.belong_to = countryTarget.id AND
    cityTarget.kind = 'city' AND
    countryTarget.belong_to = continentTarget.id AND
    countryTarget.kind = 'country' AND
    continentTarget.kind = 'continent'
  UNION ALL
  SELECT 
    continentSource.acronym oname,
    continentSource.latitude oy, 
    continentSource.longitude ox, 
    continentTarget.acronym dname, 
    continentTarget.latitude dy, 
    continentTarget.longitude dx
  FROM 
    public.place source,
    public.place target,
    public.place citySource,
    public.place cityTarget,
    public.place stateTarget,
    public.place regionTarget,
    public.place countrySource,
    public.place countryTarget,
    public.place continentSource,
    public.place continentTarget,
    public.edge edge
  WHERE 
    edge.kind = 'work' AND
    source.id = edge.source AND
    source.kind = 'instituition' AND
    source.belong_to = citySource.id AND
    citySource.belong_to = countrySource.id AND
    citySource.kind = 'city' AND
    countrySource.belong_to = continentSource.id AND
    countrySource.kind = 'country' AND
    continentSource.kind = 'continent' AND
    target.id = edge.target AND
    target.kind = 'instituition' AND
    target.belong_to = cityTarget.id AND
    cityTarget.belong_to = stateTarget.id AND
    cityTarget.kind = 'city' AND
    stateTarget.belong_to = regionTarget.id AND
    stateTarget.kind = 'state' AND
    regionTarget.belong_to = countryTarget.id AND
    regionTarget.kind = 'region' AND
    countryTarget.belong_to = continentTarget.id AND
    countryTarget.kind = 'country' AND
    continentTarget.kind = 'continent'
  UNION ALL
  SELECT 
    continentSource.acronym oname,
    continentSource.latitude oy, 
    continentSource.longitude ox, 
    continentTarget.acronym dname, 
    continentTarget.latitude dy, 
    continentTarget.longitude dx
  FROM 
    public.place source,
    public.place target,
    public.place citySource,
    public.place cityTarget,
    public.place countrySource,
    public.place countryTarget,
    public.place continentSource,
    public.place continentTarget,
    public.edge edge
  WHERE 
    edge.kind = 'work' AND
    source.id = edge.source AND
    source.kind = 'instituition' AND
    source.belong_to = citySource.id AND
    citySource.belong_to = countrySource.id AND
    citySource.kind = 'city' AND
    countrySource.belong_to = continentSource.id AND
    countrySource.kind = 'country' AND
    continentSource.kind = 'continent' AND
    target.id = edge.target AND
    target.kind = 'instituition' AND
    target.belong_to = cityTarget.id AND
    cityTarget.belong_to = countryTarget.id AND
    cityTarget.kind = 'city' AND
    countryTarget.belong_to = continentTarget.id AND
    countryTarget.kind = 'country' AND
    continentTarget.kind = 'continent') flows
GROUP BY
  oy, ox, oname, dx, dy, dname
ORDER BY oname, dname
