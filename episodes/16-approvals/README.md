# Episode 16: Approvals

## What this episode builds

A deal discount that needs a manager's yes. The fleet quote V1 (Swift's complete Year 1 fleet) gets 12 percent more off the 40 Standard Panel vans, is moved to Needs Review, and goes through two approval work items in turn: a manager approval and an admin approval. The margin is shown beside the first and stays above Velora's 10 percent floor.

## Before you start

Starting point: tag `ep15-end`. Quote V1 (00000036) already exists from episode 13 and is not rebuilt. Velora Pricing has its manual discount elements. You need Customize Application and Approval Designer permissions. The story names Priya Raman (sales rep) and Daniel Brooks (manager); in your org your own user does both jobs.

To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep15-end <your org alias>`. The script loads the data and lists the steps that must be done by hand. A git tag restores files only, never the org, so do not rely on `git checkout` to rebuild the org.

## Click path

1. The approver is your own user. Roles are named in the story (sales rep Priya Raman, manager Daniel Brooks), and you act as both: make sure your user has the Revenue Cloud permission set licence and the approval permission sets (Setup, Permission Sets, Manage Assignments).
2. Create the cost book Velora Costs (App Launcher, Cost Books) and make it the default. Add entries: Volt Van 34,000 and Velora Connect 9 (per vehicle per month).
3. In Setup, Approval Settings, check Use Flow Approval Process and Use Advanced Approvals are on.
4. Open Velora Pricing in the builder (Setup, Pricing Procedures) and look at the manual discount elements after the volume step: Amount Based Line Level and Percentage Based Line Level. Add nothing. Why: a discount typed on a line is read by the percentage element.
5. In Setup, Flows, open the sample approval MultiLevel Quote Approval and Save As New Flow Approval Process named Velora Fleet Discount Approval. Set the first stage (Manager Approval) to your user, add the second stage (Admin Approval) for the public group Admin_Group, and activate. Or deploy the flow from this repo (see files).
6. Open quote V1 (Swift Couriers Fleet V1), Lines tab. On the 40 Standard Panel van line enter a 12 percent discount and click Reprice All. The net unit price becomes 40,550.40. The refrigerated vans, Connect, chargers and installations carry no manual discount.
7. Read the line's margin fields (cost comes from the cost book). Margin is (price - cost) / price: 16.2 percent, above the 10 percent floor.
8. Set the quote Status to Needs Review (the Status path, then Mark as Current Status). This starts the approval flow.
9. Open the Approvals tab (or App Launcher, Approvals, My Approval Work Items). Approve the manager work item, then the admin work item. The quote ends Approved.

## Files in this repo used by this episode

- `force-app/main/default/flows/Velora_Fleet_Discount_Approval.flow-meta.xml`: the approval flow (record-triggered on Quote). Its first stage names the approver; open the flow in Flow Builder and set that step to your own user if you are in a new org.
- `force-app/main/default/flows/Update_Quote_Status.flow-meta.xml`: the helper flow that sets the quote status at the end of the approval.
- `force-app/main/default/groups/Admin_Group.group-meta.xml`: the public group that does the second approval.
- `force-app/main/default/permissionsets/Velora_Fields.permissionset-meta.xml`: field access used in the episodes. Assign with `sf org assign permset --name Velora_Fields --target-org <alias>` (`--name` the permission set, `--target-org` the org).
- Deploy the flows and group with `sf project deploy start --source-dir force-app --target-org <alias>`, or run `sh scripts/setup-org.sh <alias>`, which also loads the data.
- No script builds quote V1 or its cost book; those are done in the UI as above.

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

## Try it yourself

Set the discount to 9 percent and move the quote to Needs Review: the flow still starts, because it follows the status, not the discount size. Then compare the two work items with those of the 12 percent quote.
