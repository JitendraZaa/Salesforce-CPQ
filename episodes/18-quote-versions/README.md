# Episode 18: Quote versions and the primary quote

## What this episode builds

A second version of Swift's quote. V1 is cloned with Deep Clone into V2, V2 drops the Wall Chargers, is synced to the opportunity as the primary quote, goes through approval, gets its own PDF, and is moved to Presented with an expiration date. V2 is not accepted here.

## Before you start

Starting point: tag `ep17-end`. V1 (quote 00000036) is approved and has its PDF. Clone Quotes and Orders is off and Document Builder is on. You need Customize Application. The users Priya Raman and Daniel Brooks exist from episode 16.

To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep17-end --org <your org alias>`. The script loads the data and lists the steps that must be done by hand. A git tag restores files only, never the org, so do not rely on `git checkout` to rebuild the org.

## Click path

1. In Setup, Revenue Settings, turn on Clone Quotes and Orders. Why: without it the Deep Clone action is not offered on screen.
2. In Setup, Object Manager, Quote, Page Layouts, edit the layout in use, open Mobile & Lightning Actions, and drag Deep Clone into the Salesforce Mobile and Lightning Experience Actions section. Save.
3. On V1 open the menu, choose Deep Clone and confirm. A copy appears on the opportunity's Quotes list in Draft with the same lines. The approval work items and the PDF are not copied.
4. On V2 remove the Wall Charger 11 kW component from each package line (100 in all). The displayed total falls by 110,000.
5. On V2 run the quick action Start Sync. The opportunity's Synced Quote becomes V2 and its products follow V2's lines.
6. Set the V2 status to Needs Review. The two approval work items go through again; approve both.
7. Generate the PDF for V2 (Preview PDF, then Create PDF) and check it under Quote PDFs.
8. Set V2's Expiration Date to 30 days from today and its Status to Presented. Do not set Accepted.

## Files in this repo used by this episode

- `force-app/main/default/layouts/Quote-Quote Layout.layout-meta.xml`: the Quote page layout, with the Deep Clone and Start Sync actions. Deploy with `sf project deploy start --source-dir force-app/main/default/layouts --target-org <alias>` (`--source-dir` the folder, `--target-org` the org).
- `force-app/main/default/flexipages/Quote_Record_Page.flexipage-meta.xml`: the Quote record page.
- `force-app/main/default/flows/Velora_Fleet_Discount_Approval.flow-meta.xml`: the approval V2 goes through again.
- There is no script for the clone; it is a button in the org. The repository has no separate clicks document for this episode, so the Click path above is the record.

## What you should see

V2 sits in Draft after the clone, then is Approved, then Presented with an expiration date. The opportunity shows V2 as its Synced Quote, and V2's PDF lists the lines without Wall Chargers.

## Records and values

All names and numbers are invented examples. Prices are in US dollars.

- V1 displayed total 5,193,636 (twelve-month 5,225,536).
- V2 (quote 00000037) = V1 without the Wall Chargers: displayed 5,083,636 (5,193,636 less 100 x 1,100 = 110,000); twelve-month 5,115,536.
- Status values: Draft, Needs Review, In Review, Approved, Rejected, Presented, Accepted, Denied.
- Signature is not used: acceptance is set by hand later in the series.
