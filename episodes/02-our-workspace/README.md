# Episode 2: Our workspace

## What this episode builds

You set up the place where all the work in the series lives. You copy the project to your computer, open it in the
editor, connect it to a Salesforce org that has Revenue Cloud, deploy one custom field (Has Depot) with the permission
set that gives access to it, check the Revenue Settings page, and run the first pricing data sync. Nothing is sold yet.

## Before you start

- Starting point: none. You need a Developer Edition org that contains Revenue Cloud (Agentforce Revenue Management),
  VS Code with the Salesforce extensions, the Salesforce CLI (`sf`) and git.
- No earlier episode and no reset is needed. Tag at the end of this episode: `ep02-end`.

## Click path

1. Open a terminal in VS Code. Copy the project with git (command below). Why: the project folder is the single
   source of truth for everything the series builds.
2. In VS Code choose File, Open Folder, and pick the `Salesforce-CPQ` folder. The Explorer shows `force-app`, `data`,
   `scripts` and `sfdx-project.json`.
3. Open `README.md`, then the Has Depot field file. It is a checkbox, default unchecked, label Has Depot. Why: this is
   exactly what the deploy will carry to the org.
4. Connect the terminal to your org with a web login and give the org an alias. Why: every later command needs to
   know which org it talks to.
5. Make that org the project default. Why: so later commands need no org name.
6. Deploy the project. The result table lists the Has Depot field and the `Velora_Fields` permission set.
7. Assign the permission set to your own user. Why: a new custom field stays hidden until a permission set grants
   access to it.
8. Open Setup from the terminal. In Setup, type "Revenue Settings" in Quick Find and open the page. Scroll through it.
   Check these are on: Enable Revenue Cloud Features, Configure Products at Runtime, Document Builder, Ramp Deals,
   Create Application Usage Type. Turn on any that is off.
9. In Quick Find open "Salesforce Pricing Setup". The default pricing procedure is "Revenue Management Default
   Pricing Procedure V1".
10. On the same page, in the Sync Pricing Data section, choose Sync, then Confirm. Why: pricing reads copies of the
    price data, and the copies must be refreshed. This first sync runs before any price exists, so it runs again in
    episode 4.
11. Look at your own name on records you create. In a scratch org, rename the running user to your own name so Created
    By shows it.

## Files in this repo used by this episode

| File | What it contains | Command |
|---|---|---|
| `sfdx-project.json` | The project definition: the source folder (`force-app`) and the API version 68.0. | none, read by `sf` |
| `README.md` | The series overview and the list of episodes. | none |
| `force-app/main/default/objects/Account/fields/Has_Depot__c.field-meta.xml` | The Has Depot checkbox on Account. | deployed by step 6 |
| `force-app/main/default/permissionsets/Velora_Fields.permissionset-meta.xml` | Field access for the custom fields, and for the two product record types. | deployed by step 6 |

Commands, in order:

```sh
git clone https://github.com/JitendraZaa/Salesforce-CPQ.git
sf org login web --alias demo_cpq
sf config set target-org demo_cpq
sf project deploy start --source-dir force-app
sf org assign permset --name Velora_Fields
sf org open --path lightning/setup/SetupOneHome/home
```

- `git clone <address>`: copies the project and its history into a new folder named `Salesforce-CPQ`.
- `sf org login web`: opens a browser to log in. `--alias demo_cpq` gives the org a short name; use any name you like.
- `sf config set target-org demo_cpq`: stores the default org for this project, so commands need no `--target-org`.
- `sf project deploy start`: sends source files to the org. `--source-dir force-app` sends everything under that folder.
- `sf org assign permset`: gives a permission set to the logged-in user. `--name Velora_Fields` names the set.
- `sf org open`: opens the org in the browser. `--path` is the page to land on (Setup home here). The address contains
  a one-time login link; do not share a screenshot of the address bar.

A full rebuild of a new org in one go (all metadata and all data) is `sh scripts/setup-org.sh <alias>`; see
`docs/REBUILD.md`. This episode does only the first part of it by hand.

## What you should see

- The deploy table lists the Has Depot field and the `Velora_Fields` permission set as Created or Unchanged.
- Revenue Settings shows the five switches above on.
- Sync Pricing Data finishes without an error.

## Records and values

No records are created. Invented example values for the rest of the series: seller Velora Motors; sales rep Priya
Raman; sales manager Daniel Brooks; billing Elena Ortiz. The series reuses one company, Swift Couriers, as the customer.
