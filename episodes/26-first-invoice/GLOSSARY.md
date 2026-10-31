# Glossary: episode 26, The first invoice, and tax

Terms this episode introduces. The full project glossary is `GLOSSARY.md` in the repository root.

- **Invoice, invoice line**: The bill sent to the customer, and each charge on it.
- **Billing period item**: One billing period of a subscription, passed to an invoice line.
- **Invoice date, due date**: When the invoice is issued, and when payment is expected under the payment term.
- **Invoice scheduler**: The Billing Batch Scheduler record that tells Billing when and for whom to create invoices.
- **Invoice batch run (bill run)**: One run of the scheduler; its record shows how many schedules and invoices it handled.
- **Target date**: The date up to which a run bills; schedules due on or before it are included.
- **Draft and posted**: A draft invoice can still change; a posted invoice is final.
- **Catch-up bill run**: A run that bills periods missed earlier.
- **Invoice preview**: A look at the next invoice before it is created.
- **Invoice PDF**: The invoice as a document, made from a template.
- **Tax, tax policy, tax treatment, tax engine**: Tax added to a sale, the product's tax rule and treatment, and the engine that calculates it.
- **Tax-exclusive versus tax-inclusive**: Tax added to the price, or already inside it. Velora prices exclude tax.
- **Exemption**: A sale not taxed under a rule.
