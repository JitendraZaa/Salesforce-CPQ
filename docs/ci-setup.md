# Setting up the CI check

The workflow in `.github/workflows/ci.yml` signs in to a test org with the JWT flow, validates the deploy of
`force-app` (nothing is saved in the org) and runs two test classes: `DealMetricsTest` and `ConnectQuoteActionTest`.
It runs on every push to `main` and on every pull request to `main`.

Use a test org that has the Revenue Management features the project needs. Do not point it at an org you use for
anything else.

## 1. Make a key and a certificate

Create them outside this repository:

```sh
openssl genrsa -out server.key 2048
openssl req -new -x509 -key server.key -out server.crt -days 365 -subj "/CN=ci"
```

`server.key` is private. It is listed in `.gitignore`; never commit it.

## 2. Create an external client app in the test org

In Setup, create an external client app configured for Salesforce DX. Upload `server.crt` as the certificate, turn on
the JWT bearer flow, and give the app the scopes `api` and `refresh_token`. Note the consumer key. Make sure the user
who will sign in is allowed to use the app and has the right to author Apex.

The JWT flow cannot be used for headless sign-in in an org that requires high-assurance (stepped-up) login.

## 3. Add four repository secrets

In the GitHub repository, open Settings, Secrets and variables, Actions, and add these four names. The values are
yours; they are never written in a file.

| Secret | What it holds |
|---|---|
| `SF_CLIENT_ID` | The consumer key of the external client app |
| `SF_USERNAME` | The user name the workflow signs in as |
| `SF_INSTANCE_URL` | The login address of the test org (its My Domain URL) |
| `SF_JWT_KEY` | The whole text of `server.key` |

## 4. Try it by hand first

Before the first push, run the same check from your own machine with an org you have signed in to with
`sf org login web`:

```sh
sf project deploy validate --source-dir force-app --target-org <your alias> \
  --test-level RunSpecifiedTests --tests DealMetricsTest --tests ConnectQuoteActionTest
```

A red first run on the pipeline then tells you something about the pipeline, not about the code.

Workflows triggered from a fork do not receive repository secrets, so a pull request from a fork cannot run the
sign-in step.

## Turn the workflow on

The workflow skips every run until the repository variable `CI_ENABLED` is `true`. After adding the four secrets,
set it under Settings, Secrets and variables, Actions, Variables, or with `gh variable set CI_ENABLED --body true`.

## The fleet discount approval flow

`flows/Velora_Fleet_Discount_Approval.flow-meta.xml` sends the manager step to the quote owner's manager (the
user's Manager field). In the video the approver was picked by hand in Flow Builder; set a Manager on your quoting
user, or pick your approver in Flow Builder after deploying, before you activate the flow.
