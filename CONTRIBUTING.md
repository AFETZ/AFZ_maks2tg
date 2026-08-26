# Contributing

1. Create a branch from `main`.
2. Keep secrets and real message payloads out of commits and test fixtures.
3. Add or update tests for behavior changes.
4. Run `pytest -q` and `docker compose config --quiet` before opening a pull
   request.
5. Describe user-visible changes and any new environment variables in the pull
   request and README.

Use focused commits and avoid drive-by formatting changes unrelated to the
problem being solved.
