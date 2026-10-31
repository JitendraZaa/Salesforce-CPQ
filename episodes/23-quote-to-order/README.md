# Episode 23: Quote to order

All names, people, companies and numbers in this project are invented examples.

## What this episode builds

V2 is sent for approval again after the ramp and the added terms, its final PDF is generated with the three yearly groups and the two terms, and it is accepted. The fleet order is created in Draft with the same lines, the purchase order number PO-SC-2027-014 and the link to Swift's contract. One small test record is also created from a terminal through the Place Sales Transaction service, then deleted.

## Before you start

- Starting point: the org as episode 22 left it (git tag `ep22-end`). A git tag restores files only, not the org.
- To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep22-end <org alias>`. It loads the data and lists the clicks that a script cannot do.
- Words used here are explained in `GLOSSARY.md` in this folder.

## Click path

1. On V2 set the Status to **Needs Review**. This starts the approval flow. The manager (Daniel Brooks) and then the admin approve the work items. Afterwards the status is Approved. Why: the ramp and the terms changed the offer after the first approval.
2. On V2 click **Generate PDF Document**, then **Preview PDF**, then **Create PDF**. Check the preview shows Year 1, Year 2 and Year 3 groups and the two terms. Under Related, Quote PDFs, the new final file appears.
3. Edit V2 and set the **Status** to **Accepted** (acceptance is recorded in the status). Save.
4. Click **Create Order** on V2 and watch the notifications. An order in **Draft** appears; it copies product, quantity, price and tax from the quote.
5. On the order set **PO Number** to `PO-SC-2027-014` and **Contract** to Swift's contract. Contracts can be linked only to Draft orders. Save.
6. Compare the order lines with V2's Lines tab: products, quantities, prices and total. The billing treatment is blank on every line now; it is filled when the order is activated in episode 24. Do not activate the order here.
7. In a terminal run the order-lines query to compare the order with the quote. To show the Place Sales Transaction service, run the small anonymous Apex that places one quote through it (see the files below) and check the new record in the org.
8. Delete any test quote or order the API call created, so it does not create an asset in episode 24.

## Files in this repo used by this episode

- `queries/ep23-order-lines.soql`: the order lines of the fleet order (product, quantity, unit price, total, service date, end date, billing treatment). Edit the order number inside the file to your order's number first (it is written for order 00000121, from the earlier chain). Command: `sf data query --query "$(cat queries/ep23-order-lines.soql)" --target-org <org alias>`
  - `sf data query`: run a read-only SOQL query.
  - `--query "$(cat ...)"`: the query text from the file.
  - `--target-org <org alias>`: which org.
- `scripts/anonymous/place-one-quote.apex`: Apex that calls the Create Connect Quote action once for Swift's opportunity `Swift Couriers - Connect`, to see the Place Sales Transaction call work. It creates a real quote, so run it only on purpose. Command: `sf apex run --file scripts/anonymous/place-one-quote.apex --target-org <org alias>`
  - `sf apex run`: run anonymous Apex.
  - `--file`: the file to run.
- `force-app/main/default/classes/ConnectQuoteAction.cls`, `QuotePlacer.cls`, `PstQuotePlacer.cls`, `QuoteInput.cls`, `QuoteOutcome.cls`: the Apex that builds the call. Deploy: `sf project deploy start --source-dir force-app/main/default/classes --target-org <org alias>`.
- `force-app/main/default/flows/Velora_Fleet_Discount_Approval.flow-meta.xml` and `Update_Quote_Status.flow-meta.xml`: the approval flow started by Needs Review and the flow that moves the quote status. Their approver group is `Admin_Group` (`force-app/main/default/groups/`).
- Not in the repo: the order-placing request body for the order API (`ep23-place-order.json`) was promised but does not exist; the order step is shown with the quote action above.

## What you should see

V2 with status Approved, then Accepted, with a new PDF in Quote PDFs. A Draft order with the same lines, PO number PO-SC-2027-014 and Swift's contract. Billing treatment empty on every line. The test order from the API is gone after the take.

## Records and values

Where this page and an older note differ, the latest recorded values (31 Oct 2026) and the Velora example values win.

- PO number PO-SC-2027-014. Approver: Daniel Brooks (sales manager). Sales rep: Priya Raman.
- Quote Status values: Draft, Needs Review, In Review, Approved, Rejected, Presented, Accepted, Denied.
- Margin check shown with the approval: Standard Panel van 16.2 percent in Year 1 (40,550.40 against cost 34,000) and 13.4 percent in Years 2 and 3 (39,283.20 against 34,000). Floor is 10 percent.
- V2: Wall Chargers removed; displayed total 5,083,636; twelve-month basis 5,115,536. Ramped V2 after Year 2 and 3 groups: 13,146,176 including the Connect segments.
- Order start date defaults to today; Revenue Management does not create orders from future-dated contracts.
