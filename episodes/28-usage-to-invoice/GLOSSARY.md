# Glossary: episode 28, From usage to invoice

Terms this episode introduces. The full project glossary is `GLOSSARY.md` in the repository root.

- **Usage, consumption**: What the customer used, and the act of using it.
- **Transaction journal**: The raw log of usage readings.
- **Aggregation**: Combining a period's readings under a policy, such as a sum, before rating.
- **Usage summary**: The combined usage of one asset for a usage period.
- **Usage ratable summary**: The usage summary prepared for rating, with the quantity ready to be priced.
- **Rating**: Applying rates to usage to price it.
- **Rating procedure**: The procedure that does the rating (named only).
- **Net unit rate**: The usage price per unit after any rate adjustments.
- **Overage**: Usage above the included or committed amount.
- **Liable summary**: The record of calculated overages and their charge. In the API it is the usage billing period item.
- **Rating delay**: The waiting time after the period ends before usage is rated; the default is 3 days.
- **Commitment**: A promise to use or pay for a minimum quantity over a period.
- **Shortfall**: The gap when use is lower than the commitment.
- **Grant, entitlement, prepaid, wallet, bucket, drawdown, rollover, true-up**: Concepts shown for contrast on a slide: a quantity of usage with its rules, the grant assigned with a product, paid in advance, balance holders, deducting use from a balance, carrying unused units over, and a later reconciliation. They are not built.
