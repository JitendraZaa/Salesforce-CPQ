# Episode 37: The dealer site

## What this episode builds

A site where Velora's dealers sign in: the Experience Cloud site Velora Dealers (Partner Central template), a partner account, Brightside Motors, a partner user, Sam Okafor, and the permission sets that let him quote and configure products.

## Before you start

Starting point: the end of episode 36. You need the Digital Experiences feature on, Partner Community licences (the example org has 20) and the permissions Create and Set Up Experiences, View Setup and Configuration and Manage External Users.

To bring a fresh org as far as it can go by loading data, run `sh scripts/reset-to.sh ep28-end <your org alias>`. A git tag restores files only, never the org. (This repository has no `ep36-end` tag yet.)

## Click path

1. Load the dealer account and contact (see Files below).
2. Setup, Quick Find "Digital Experiences", All Sites, New. Pick the Partner Central template, Get Started. Name Velora Dealers, URL dealers, Create. The site is created in Preview status (nobody outside can reach it yet).
3. Open the account Brightside Motors, action menu, Enable as Partner.
4. Open the contact Sam Okafor, action menu, Enable Partner User. On the user record set User License Partner Community, Profile Custom Partner Community User, choose a Role, untick Generate new password and notify user immediately, Save.
5. Open Sam's user record, Permission Set Assignments, Edit Assignments: add "Create Orders from Quotes for Partner Community License" and "Price and Tax Calculations on Quotes for Partner Community License". Add "Velora Dealer Configurator" after deploying it (Files below).
6. Open Experience Builder for Velora Dealers (Workspaces, Builder), Administration, Members: under Selected Permission Sets add Velora Dealer Configurator and Save. The site updates its membership in the background.

## Files in this repo used by this episode

- `data/ep37-dealers/Account.json`: the account Brightside Motors with its contact Sam Okafor. Load it with `sf data import tree --files data/ep37-dealers/Account.json --target-org <alias>`. Parts: `import tree` creates records from a JSON file (children under the account are created too), `--files` names the file, `--target-org` the alias.
- `force-app/main/default/permissionsets/Velora_Dealer_Configurator.permissionset-meta.xml`: a custom permission set that grants the user permission ProductConfiguratorUser (the standard Product Configurator permission set cannot be given to a site user, so this one grants the same permission). Deploy it with `sf project deploy start --source-dir force-app/main/default/permissionsets/Velora_Dealer_Configurator.permissionset-meta.xml --target-org <alias>` (`--source-dir` the file to deploy).

## What you should see

The site Velora Dealers in the Workspaces list, status Preview and unpublished; Sam Okafor with the Partner Community licence and three permission sets; Velora Dealer Configurator listed as a site member.

## Records and values

All names are invented examples.

- Account: Brightside Motors (Sacramento, CA), channel partner; contact Sam Okafor, Sales Manager.
- Site: Velora Dealers, URL path dealers, template Partner Central.

## Try it yourself

Create a second contact at Brightside Motors, enable a second partner user, and compare the two users' licences, profiles and permission sets.
