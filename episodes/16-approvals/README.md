# Episode 16: Approvals

## What this episode builds

A deal discount that needs a manager's yes. The fleet quote V1 (Swift's complete Year 1 fleet) gets 12 percent more off the 40 Standard Panel vans, is moved to Needs Review, and goes through two approval work items in turn: a manager approval and an admin approval. The margin is shown beside the first and stays above Velora's 10 percent floor.

## Before you start

Starting point: tag `ep15-end`. Quote V1 (00000036) already exists from episode 13 and is not rebuilt. Velora Pricing has its manual discount elements. You need Customize Application and Approval Designer permissions. The example users Priya Raman (sales rep) and Daniel Brooks (manager) may have to be created.

To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep15-end --org <your org alias>`. The script loads the data and lists the steps that must be done by hand. A git tag restores files only, never the org, so do not rely on `git checkout` to rebuild the org.

## Click path

1. Create the users Priya Raman and Daniel Brooks (Setup, Users, New User) and give them the Revenue Cloud User permission set licence plus the approval permission sets: Approval Submitter for Priya, Approval Reviewer for Daniel.
2. Create the cost book Velora Costs (App Launcher, Cost Books) and make it the default. Add entries: Volt Van 34,000 and Velora Connect 9 (per vehicle per month).
3. In Setup, Approval Settings, check Use Flow Approval Process and Use Advanced Approvals are on.
4. Open Velora Pricing in the builder and look at the manual discount elements after the volume step. Add nothing. Why: a discount typed on a line is read by the percentage element; there is no element for a header-level adjustment.
5. In Setup, Flows, open the sample approval MultiLevel Quote Approval and Save As New Flow Approval Process named Velora Fleet Discount Approval. Remove the discount condition, change the manager step's approver to a user, and activate. The flow has two stages: Manager Approval, then Admin Approval for the group Admin_Group.
6. Open quote V1, Lines tab. On the 40 Standard Panel van line enter a 12 percent discount and click Reprice All. The net unit price becomes 40,550.40. The refrigerated vans, Connect, chargers and installations carry no manual discount.
7. Read the line's margin fields (cost comes from the cost book). Margin is (price - cost) / price: 16.2 percent, above the 10 percent floor.
8. Set the quote Status to Needs Review. This starts the approval flow.
9. Approve the manager work item, then the admin work item, from the quote's Approvals tab. The quote ends Approved.

## Files in this repo used by this episode

- `force-app/main/default/flows/Velora_Fleet_Discount_Approval.flow-meta.xml`: the approval flow (record-triggered on Quote). It names the approver as the quote owner's manager, so the quote owner needs a manager in a new org, or change that step in Flow Builder.
- `force-app/main/default/flows/Update_Quote_Status.flow-meta.xml`: the helper flow that sets the quote status at the end of the approval.
- `force-app/main/default/groups/Admin_Group.group-meta.xml`: the public group that does the second approval.
- `force-app/main/default/permissionsets/Velora_Fields.permissionset-meta.xml`: field access used in the episodes. Assign with `sf org assign permset --name Velora_Fields --target-org <alias>` (`--name` the permission set, `--target-org` the org).
- Deploy the flows and group with `sf project deploy start --source-dir force-app --target-org <alias>`, or run `sh scripts/setup-org.sh <alias>`, which also loads the data.
- No script builds quote V1, its cost book or the users; those are done by hand.

## What you should see

Quote V1 moves Draft, Needs Review, In Review, Approved. Two approval work items appear in turn and each is approved. The Standard Panel van line reads 40,550.40, the margin 16.2 percent.

## Records and values

All names and numbers are invented examples. Prices are in US dollars.

- V1 lines: 40 Standard Panel and 60 Refrigerated Long Range in the Volt Van Fleet Package, each van with one Connect and one optional Wall Charger; 2 Depot Chargers; 2 Charger Installations.
- Standard Panel van: 46,080 (4 percent tier) less 12 percent = 40,550.40. Refrigerated van: 58,700 less 4 percent = 56,352.
- Displayed quote total (Connect counted for one month): 5,414,820 before the manual discount, 5,193,636 after. Twelve-month basis: 5,446,720 and 5,225,536.
- Costs: Volt Van 34,000; Long Range +4,800; Refrigerated +3,100; Connect 9 per vehicle per month. Margin floor 10 percent.
- Margin at 46,080: 12,080, 26.2 percent. At 40,550.40: 6,550.40, 16.2 percent; markup 19.3 percent. Floor price at 10 percent: 34,000 / 0.9 = 37,777.78.
- A sales rep may give up to 10 percent more by hand; above that the sales manager approves.
