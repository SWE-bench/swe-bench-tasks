# Changelog

- **[2026-08-13] Remove future commits reliably when cloning**: the tag prune ran as
  `git tag -l | while read`, and a git call in the loop body ate the piped stdin so it
  stopped after ~29 tags; switched to a `for` loop and added `git gc --prune=now` so
  unreferenced future commits are physically gone. All instances.
- **[2026-08-13] Fall back to a full clone when a mapped branch is gone**: sympy deleted
  its `1.7` branch, so `git clone --branch 1.7` exited 128 and failed the whole build.
  `sympy__sympy-20590` (and any instance whose `REPO_BASE_COMMIT_BRANCH` entry goes stale).
- **[2026-08-13] Pin tzdata for matplotlib**: `apt-get upgrade` pulled tzdata 2026c, whose
  future DST rules give Canada/Pacific 2040 = `-0700` where the tests hardcode `-0800`;
  pinned `tzdata=2022a-0ubuntu1`. `matplotlib__matplotlib-21568`, `-22871` (applies to all
  34 matplotlib instances).
- **[2026-08-13] Drop conflicting pins from xarray environments**: `dask==2022.8.1` and
  `scitools-iris==3.10.0` cannot co-resolve, so image builds failed; removed the unused
  iris pin, and for the one instance whose tests need iris downgraded it to 3.4.1 for
  numpy 1.23. 12 `pydata__xarray-*` instances (iris kept for `-6992`).
- **[2026-08-13] Add `dockerfile_extra` and spec-level `eval_pre` hooks**: lets a repo spec
  append Dockerfile stanzas or pre-test commands, so fixes needing a service in the
  container can ship in the image rather than requiring a dataset revision. No instances
  changed.

## Known issues

- `psf__requests-2317` fails while `httpbin.org` is unavailable (503/504). All 8 of its
  FAIL_TO_PASS tests hit httpbin, so it cannot be made hermetic by dropping tests. A local
  `httpbin==0.7.0` fixes `test_set_cookie_on_301` but breaks `test_requests_history_is_saved`
  and `test_mixed_case_scheme_acceptable`, so it was reverted.
