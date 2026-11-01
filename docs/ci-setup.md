# Setting up the CI check

The workflow in `.github/workflows/ci.yml` signs in to a test org with the JWT flow, validates the deploy of the
`DealMetrics` class and its test (nothing is saved in the org) and runs `DealMetricsTest` only, so the check answers in
minutes.
It runs on every push to `main` and on every pull request to `main`.

Use a test org that has the Revenue Management features the project needs. Do not point it at an org you use for
anything else.

## 1. Make a key and a certificate

Create them in `certs-local/`, a folder git ignores:

```sh
mkdir -p certs-local && cd certs-local
openssl genrsa -out server.key 2048
openssl req -new -x509 -key server.key -out server.crt -days 730 -subj "/CN=ci"
```

The certificate in `force-app/main/default/extlClntAppGlobalOauthSets/CI_Deploy.ecaGlblOauth-meta.xml` is the text of
`server.crt` without its first and last lines; paste the new text there if you make a new pair.

`server.key` is private. It is listed in `.gitignore`; never commit it.

## 2. Create an external client app in the test org

The project carries the app as metadata (`CI_Deploy`, in `externalClientApps/` and the `extlClntApp...` folders): the
certificate, the JWT bearer flow, the scopes `api` and `refresh_token`, and the System Administrator profile as
pre-approved. Deploy it with
`sf project deploy start --metadata ExternalClientApplication:CI_Deploy --metadata ExtlClntAppGlobalOauthSettings:CI_Deploy --metadata ExtlClntAppOauthSettings:CI_Deploy --metadata ExtlClntAppOauthConfigurablePolicies:CI_Deploy --target-org <your alias>`.
To make it by hand instead, create an external client app in Setup, upload `server.crt` as the certificate, turn on
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
sf project deploy validate --source-dir force-app/main/default/classes/DealMetrics.cls \
  --source-dir force-app/main/default/classes/DealMetricsTest.cls --target-org <your alias> \
  --test-level RunSpecifiedTests --tests DealMetricsTest
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
