CREATE TABLE rqd2_jobs (
  id     bigserial PRIMARY KEY,
  method text not null check (length(method) > 0),
  args   json not null using (args::json),
  enqueued_at timestamp without time zone NOT NULL DEFAULT NOW(),
  locked_at timestamp without time zone
);
