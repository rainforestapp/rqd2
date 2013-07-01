BEGIN;

/* Use unlogged if you want more speed / feeling brave
CREATE UNLOGGED TABLE rqd2_jobs (
*/

CREATE TABLE rqd2_jobs (
  id          bigserial PRIMARY KEY,
  q_name      varchar(255) not null,
  klass       text not null check (length(klass) > 0),
  args        json not null,
  enqueued_at timestamp without time zone NOT NULL DEFAULT NOW(),
  locked_at   timestamp without time zone
)  WITH (OIDS=FALSE);

ALTER SEQUENCE rqd2_jobs_id_seq CACHE 50;

COMMIT;
