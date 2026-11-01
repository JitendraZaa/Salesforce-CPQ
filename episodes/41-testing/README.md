# Episode 41: Testing every change

Status: planned, not recorded yet; steps below may change when the episode is recorded.

## What this episode builds

An automatic check. A push to the repository runs a GitHub Actions workflow that signs in to the test org, validates the deploy of `force-app` and runs `DealMetricsTest`. The deal-metrics rule gives MRR 29, ARR 348 and TCV 48,348 for the pilot fixture.

## Before you start

Starting point: source on `main` as episode 40 left it (tag `ep40-end`); `velora_qa` is the test org. No org reset is needed; the tests build their own data in memory. Follow [docs/ci-setup.md](../../docs/ci-setup.md) for the key, certificate, external client app and the four repository secrets (`SF_CLIENT_ID`, `SF_USERNAME`, `SF_INSTANCE_URL`, `SF_JWT_KEY`).

## Planned steps

1. Open `force-app/main/default/classes/DealMetrics.cls`: `calculate` adds recurring lines to MRR, multiplies by 12 for ARR, and adds one-time lines plus recurring lines times their term to TCV. `fromQuoteLines` maps quote lines to the rule without a query.
2. Open `DealMetricsTest.cls` and read the pilot fixture: a 48,000 van and a 29 per month plan for 12 months.
3. Run the tests in the test org:

```sh
sf project deploy start --source-dir force-app/main/default/classes --target-org velora_qa --test-level RunSpecifiedTests --tests DealMetricsTest --wait 30
sf apex run test --class-names DealMetricsTest --target-org velora_qa --result-format human --code-coverage --wait 10
```

- `--source-dir` limits the deploy to the classes folder; `--target-org` is the test org.
- `--test-level RunSpecifiedTests` with `--tests` runs only the named test class.
- `--wait 30` waits up to thirty minutes for the deploy.
- `apex run test` runs the tests; `--class-names` names them, `--result-format human` prints readable output, `--code-coverage` adds the coverage, `--wait 10` waits up to ten minutes.

4. Open `.github/workflows/ci.yml`: it installs the Salesforce CLI, signs in with `sf org login jwt` (client id, key file, username, instance URL), runs `sf project deploy validate --source-dir force-app --test-level RunSpecifiedTests --tests DealMetricsTest --tests ConnectQuoteActionTest --wait 30`, and removes the key. `validate` checks a deploy and runs the tests without saving anything.
5. Add the four secrets in GitHub (Settings > Secrets and variables > Actions) and set the variable `CI_ENABLED` to `true`.
6. Push a commit and watch the Actions tab until the run is green.
7. Change the TCV rule so it leaves out one-time lines, push, and see the pilot assertion fail with expected 48348.00; revert and push to see it pass.
8. Check the same rule on the real quote in `demo_cpq` with a short anonymous Apex file (`scripts/anonymous/metrics-pilot.apex`, planned), run with `sf apex run --file <file> --target-org demo_cpq`.

## Files in this repo used by this episode

- `force-app/main/default/classes/DealMetrics.cls`, `DealMetricsTest.cls` (each with its `-meta.xml`).
- `.github/workflows/ci.yml` and `docs/ci-setup.md`.
- Planned and not in the repository yet: `scripts/anonymous/metrics-pilot.apex`.

## What you should see (planned)

Every test passes, a coverage line for `DealMetrics`, and a green run in the Actions tab; the pilot fixture returns MRR 29.00, ARR 348.00 and TCV 48,348.00.

## Try it yourself

Add a test for an evergreen Connect line, write the assertion first, run it and see it fail, then change the class until it passes.

All names and numbers are invented examples. Prices are in US dollars.
