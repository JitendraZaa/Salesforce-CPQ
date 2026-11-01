# Episode 41: Testing every change

All names, people, companies and numbers in this project are invented examples. Prices are in US dollars.

## What this episode builds

A safety net for Velora's deal-metrics rule. You read the Apex class `DealMetrics` and its six tests, deploy and run them in the test org (`velora_qa`), read the GitHub Actions workflow, and push so the workflow signs in to the test org and validates the two files and runs `DealMetricsTest`. Then you run the rule on the real pilot quote in `demo_cpq`: MRR 29.00, ARR 348.00, TCV 48,348.00.

## Before you start

- Starting point: the source on `main` as episode 40 left it; `velora_qa` is the test org. No org reset is needed, the tests build their own data in memory.
- For the automatic check follow `docs/ci-setup.md`: a key and certificate in `certs-local/` (git ignores it), the external client app `CI_Deploy` deployed to the test org, and four repository secrets: `SF_CLIENT_ID`, `SF_USERNAME`, `SF_INSTANCE_URL`, `SF_JWT_KEY`. The consumer key for `SF_CLIENT_ID` is in Setup, External Client Apps Manager, CI Deploy, Settings, OAuth Settings, Consumer Key and Secret.

## Click path

1. In VS Code open `force-app/main/default/classes/DealMetrics.cls`. The comment states the rule: MRR counts charges that repeat every month, ARR is MRR x 12, TCV counts every charge over the whole term. The class `Line` holds one deal row (product code, recurring, unit price, quantity, months) and `Result` holds the three numbers.
2. Read `calculate`: each line's price x quantity; a recurring line adds to MRR and, when it has a term, times its months to TCV; an evergreen line has no term and adds nothing to TCV; a one-time line adds straight to TCV.
3. Read `forQuote` (reads one quote's lines in user mode) and `fromQuoteLines` (turns rows into lines without a query, so a test can feed it rows). A line is recurring when its selling model is term defined or evergreen; the months come from the pricing term count (12 for a year of Connect), not from the subscription term, which holds the billing period (1).
4. Open `DealMetricsTest.cls`: the pilot (a 48,000 van once and Connect at 29 for 12 months: MRR 29, ARR 348, TCV 48,348), a van alone (`oneTimeOnly_hasNoRecurringRevenue`), the ramp's first year (`rampYear1_100Connect12Months`: 2,900, 34,800, 34,800), the mapper (`mapper_readsPilotLines`), a quote with a van line inserted as test data, and a null list (TCV zero). Six tests.
5. Deploy the two files to the test org: `sf project deploy start --source-dir force-app/main/default/classes/DealMetrics.cls --source-dir force-app/main/default/classes/DealMetricsTest.cls --target-org velora_qa`. Succeeded, four files (each class and its meta file).
6. Run the tests: `sf apex run test --class-names DealMetricsTest --target-org velora_qa --result-format human --code-coverage --wait 10`. Six tests pass, 100 percent pass rate, DealMetrics 95 percent covered (the empty constructor, the skip for a line with no price or quantity and the evergreen branch are not covered).
7. Open `.github/workflows/ci.yml`. It runs on a push to `main`, on a pull request, or by hand, and only when the repository variable `CI_ENABLED` is `true`. The job checks out the code, sets up Node 22, installs the Salesforce CLI, signs in with `sf org login jwt` using the four secrets (the key is written to a file for the length of the job), runs `sf project deploy validate` for the two files with `--test-level RunSpecifiedTests --tests DealMetricsTest`, and deletes the key file.
8. In GitHub, Settings, Secrets and variables, Actions: the four secret names are listed (a stored value is never shown again). Under Variables add `CI_ENABLED` with the value `true`. Why a variable and not a secret: it is not sensitive, it only switches the job on.
9. In the terminal run `git status`, then `git log --oneline origin/main..main`, then `git push origin main`.
10. In the Actions tab open the newest run, then the `test` job. Every step is green: check out the code, set up Node, install the Salesforce CLI, sign in to the test org, validate the deploy and run the named tests, remove the key. In the validate log the Test Results Summary reads Passing 6 and the last line "Successfully validated". GitHub masks the secrets.
11. On real data: open `scripts/anonymous/metrics-pilot.apex` (it finds Swift Couriers Pilot Quote and prints the result with `System.debug`) and run `sf apex run --file scripts/anonymous/metrics-pilot.apex --target-org demo_cpq | grep USER_DEBUG`. It prints MRR 29.00, ARR 348.00 and TCV 48348.00. The classes must be in `demo_cpq` first: `sf project deploy start --source-dir force-app/main/default/classes/DealMetrics.cls --source-dir force-app/main/default/classes/DealMetricsTest.cls --target-org demo_cpq`.

## Background on slides (not steps)

- A test class is code that checks other code; an assertion is a statement that must be true; code coverage is the share of executable lines the tests ran; CI (continuous integration) runs the tests on every push.
- The JWT flow lets a robot sign in with a private key; the key is stored as a repository secret because the repository is public.

## Files in this repo used by this episode

- `force-app/main/default/classes/DealMetrics.cls` and `DealMetricsTest.cls`, each with its `-meta.xml`.
- `.github/workflows/ci.yml`: the workflow.
- `docs/ci-setup.md`: the key, certificate, external client app and secrets.
- `scripts/anonymous/metrics-pilot.apex`: the rule applied to the real pilot quote.
- `force-app/main/default/externalClientApps/CI_Deploy.eca-meta.xml`, `extlClntAppGlobalOauthSets/CI_Deploy.ecaGlblOauth-meta.xml` (holds the public certificate and turns the JWT bearer flow on), `extlClntAppOauthSettings/CI_Deploy.ecaOauth-meta.xml` (scopes `api` and `refresh_token`) and `extlClntAppOauthPolicies/CI_Deploy.ecaOauthPlcy-meta.xml` (the System Administrator profile is pre-approved). Deploy them with `sf project deploy start --metadata ExternalClientApplication:CI_Deploy --metadata ExtlClntAppGlobalOauthSettings:CI_Deploy --metadata ExtlClntAppOauthSettings:CI_Deploy --metadata ExtlClntAppOauthConfigurablePolicies:CI_Deploy --target-org velora_qa`.
- The private key is never committed.
- Flags in parts: `--source-dir` names a file or folder to send (repeat it); `--target-org` is the org; `--class-names` picks the test class; `--result-format human` prints readable output; `--code-coverage` adds the coverage table; `--wait 10` waits up to ten minutes.

## What you should see

Six tests passing, DealMetrics 95 percent covered, a green run in the Actions tab ending "Successfully validated", and the pilot quote returning MRR 29.00, ARR 348.00 and TCV 48348.00.

## Try it yourself

Open DealMetrics and DealMetricsTest, run the tests in your org, then in your own copy of the repository add the secrets from `docs/ci-setup.md`, push a change and watch the workflow run.
