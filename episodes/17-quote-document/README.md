# Episode 17: The quote document

## What this episode builds

A printable PDF of quote V1 that Swift can read: a quote template named Velora Fleet Quote built in Document Builder, set as the default template, then used to preview and create the PDF and see it under the quote's Quote PDFs.

## Before you start

Starting point: tag `ep16-end`. Quote V1 holds Swift's full Year 1 fleet and is Approved. Your own user plays the sales rep. Document Builder is part of the Growth and Advanced licences. You need Customize Application and the Document Builder User permission set.

To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep16-end <your org alias>`. The script loads the data and lists the steps that must be done by hand. A git tag restores files only, never the org, so do not rely on `git checkout` to rebuild the org.

## Click path

1. Open quote V1 and check its Lines tab: two Volt Van Fleet Package lines (40 and 60), the Connect and Wall Charger children, 2 Depot Chargers, 2 Charger Installations, the 12 percent on the Standard Panel line, Status Approved.
2. In Setup, Revenue Settings, check Document Builder is on. Refresh the page after turning it on.
3. In Setup, Permission Sets, open Document Builder User, click Manage Assignments, and assign it to your user (the person who builds the template).
4. In Setup, search Document Builder, click New Template. Label it Velora Fleet Quote, choose Quote, click Next, pick the default quote template, click Done. Template Builder opens with account and contact details, line items and acceptance details.
5. Add an Image component at the top with the Velora logo. Keep Quote Line Items as it is (its fields cannot be customised). Do not add Signature (it is available for quotes only in orgs with Field Service). Save and Activate, and make it the default template.
6. On quote V1 open the actions menu, choose Generate PDF Document and Preview PDF. Check vans, quantity, net price and total against the Lines tab.
7. Click Create PDF, wait for the notification, then open Related, Quote PDFs and open the file.

## Files in this repo used by this episode

- `force-app/main/default/permissionsets/Velora_Fields.permissionset-meta.xml`: field access used in the series. The Document Builder User permission set is Salesforce's own and is assigned by hand.
- `force-app/main/default/layouts/DocumentTemplate-Document Template Layout.layout-meta.xml`: the layout of the template record.
- The template itself has no metadata type, so it is not in the repository. Build it by hand with the steps above. The Velora Fleet Quote record page (needs the Document Builder page type) is not deployable to a scratch org either.

## What you should see

A PDF of V1 with the Velora logo, account and contact details, the line items and acceptance details. The totals match the Lines tab. The file is listed under Quote PDFs on the quote.

## Records and values

All names and numbers are invented examples. Prices are in US dollars.

- Template: Velora Fleet Quote, default for Quote.
- V1 displayed total 5,193,636 (Connect for one month); twelve-month basis 5,225,536.
- Standard Panel van 40,550.40; Refrigerated van 56,352; 100 Wall Chargers at 1,100 each = 110,000; Depot Chargers 64,000; Installations 13,600.

## Try it yourself

Copy the template, add a Rich Text component with a payment note, activate it without making it the default, and generate the PDF by picking that template.
