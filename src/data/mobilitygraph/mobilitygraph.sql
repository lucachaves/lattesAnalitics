
-- Table: place

-- DROP TABLE place;

CREATE TABLE place
(
  id serial NOT NULL,
  name character varying,
  acronym character varying,
  kind character varying,
  latitude double precision,
  longitude double precision,
  belong_to integer,
  CONSTRAINT pk_place PRIMARY KEY (id),
  CONSTRAINT fk_belong_to FOREIGN KEY (belong_to)
      REFERENCES place (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE place
  OWNER TO postgres;

-- Index: place_index_kind

-- DROP INDEX place_index_kind;

CREATE INDEX place_index_kind
  ON place
  USING btree
  (kind COLLATE pg_catalog."default");
  
-- Table: edge

-- DROP TABLE edge;

CREATE TABLE edge
(
  id serial NOT NULL,
  id16 bigint,
  kind character varying,
  source integer,
  target integer,
  start_year integer,
  end_year integer,
  CONSTRAINT pk_edge PRIMARY KEY (id),
  CONSTRAINT fk_source FOREIGN KEY (source)
      REFERENCES place (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_target FOREIGN KEY (target)
      REFERENCES place (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE edge
  OWNER TO postgres;

-- Index: edge_index_end_year

-- DROP INDEX edge_index_end_year;

CREATE INDEX edge_index_end_year
  ON edge
  USING btree
  (end_year);

-- Index: edge_index_id16

-- DROP INDEX edge_index_id16;

CREATE INDEX edge_index_id16
  ON edge
  USING btree
  (id16);

-- Index: edge_index_kind

-- DROP INDEX edge_index_kind;

CREATE INDEX edge_index_kind
  ON edge
  USING btree
  (kind COLLATE pg_catalog."default");

-- Index: edge_index_start_year

-- DROP INDEX edge_index_start_year;

CREATE INDEX edge_index_start_year
  ON edge
  USING btree
  (start_year);

