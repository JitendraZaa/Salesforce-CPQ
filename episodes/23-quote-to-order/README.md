# Episode 23: Quote to order

All names, people, companies and numbers in this project are invented examples.

## What this episode builds

Swift's final fleet quote V2 goes through approval, its final PDF is generated with the three yearly groups and the two special terms, and it is accepted. An order is then created from it in Draft with the same lines, linked to Swift's contract. In the example the order is 00000126, a Draft order of 13,154,621.96.

## Before you start

- Starting point: the org as episode 22 left it (git tag `ep22-end`): V2 ramped with the uplift, special terms on V2, contract 00000104 in Draft or Activated, billing policy on the products. A git tag restores files only, not the org.
- To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep22-end <org alias>`. It loads the data and lists the clicks that a script cannot do.
- Words used here are explained in `GLOSSARY.md` in this folder.

## Click path

1. Setup, Revenue Settings, Advanced Order Creation: name the template flow `revenue_adv_q2o__CreateOrdersFromQuote` as the order creation flow. Save. (This is what the Create Order button uses.)
2. Setup, Document Builder (Quick Find), open the template **Velora Fleet Quote**, row menu, Edit. Add a Rich Text block headed "Special Terms" and a Related Record Table on the related entity Quote Clauses, with the fields Document Clause ID and Reason. Save.
3. Open V2. Set Status to **Needs Review**: this starts the approval flow. The sales manager approves each work item (here the admin user, who plays the manager). When the work items are done the status is Approved. Why again: the ramp and the terms changed the offer after the first approval.
4. On V2 click **Generate PDF Document**, then **Preview**, then **Create**. Check the preview shows the Year 1, Year 2 and Year 3 groups and, under the lines, "Special Terms" with Battery Warranty and Telematics Data Ownership. Related, Quote PDFs lists the new final file.
5. Edit V2 and set **Status** to **Accepted**. Save.
6. Click **Create Order**. The dialog offers Single Order, By Group and By Field. Choose **Create Single Order** (Single keeps the ramped groups together on one order).
7. A toast shows the new order number. Open the order (Draft). It copies product, quantity, price and groups from the quote; the contract link (00000104) is set by the platform. Compare the order lines with V2's lines: same products, quantities and total (13,154,621.96).
8. Do not activate the order here; episode 24 does.
9. In a terminal run the order-lines query to compare order and quote (see the files).

## Files in this repo used by this episode

- `queries/ep23-order-lines.soql`: the order lines (product, quantity, unit price, total, service date, end date, billing treatment). The file is written for order 00000121: edit the order number inside it to your order's number (00000126 in the example). Command: `sf data query --query "$(cat queries/ep23-order-lines.soql)" --target-org <org alias>`
  - `sf data query`: run a read-only SOQL query.
  - `--query "$(cat ...)"`: the query text read from the file.
  - `--target-org <org alias>`: which org to ask.
- `force-app/main/default/flows/Velora_Fleet_Discount_Approval.flow-meta.xml` and `Update_Quote_Status.flow-meta.xml`: the approval flow started by Needs Review and the flow that moves the quote status. Their approver group is `Admin_Group` (`force-app/main/default/groups/`). Deploy: `sf project deploy start --source-dir force-app/main/default/flows --target-org <org alias>`
  - `--source-dir`: deploy only that folder.
- The order-placing Apex (`ConnectQuoteAction.cls`, `QuotePlacer.cls`, `PstQuotePlacer.cls`) belongs to episode 42; it is not used here.
- No Document Builder template file is in the repo (the template is built in the org, step 2).

## What you should see

V2 with status Approved, then Accepted, with a new PDF in Quote PDFs that shows the three groups and the Special Terms. A Draft order with the same lines, linked to the contract, whose billing treatment is empty on every line (it is filled when the order is activated in episode 24).

## Records and values

- Order 00000126: Draft, 13,154,621.96 (12,937,376 one-time + Connect 34,800 + 71,688 + 110,757.96 with the 3 percent uplift). Order start date defaults to today; Revenue Management does not create orders from future-dated contracts.
- Quote Status values: Draft, Needs Review, In Review, Approved, Rejected, Presented, Accepted, Denied.
- Margin check shown with the approval: Standard Panel van 16.2 percent in Year 1 (40,550.40 against cost 34,000) and 13.4 percent in Years 2 and 3 (39,283.20 against 34,000). Floor 10 percent.

## Try it yourself

Create the order again with **By Group** instead of Single Order on a clone of V2 and compare how the lines are split. Delete the extra order before episode 24.
