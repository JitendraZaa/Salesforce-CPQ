# Glossary: episode 13, Volume pricing

Terms introduced in this episode. The full project glossary is `GLOSSARY.md` in the repository root.

- **Volume discount**: A lower unit price when more units are bought.
- **Tiered discount**: The everyday name for Range and Slab pricing: the discount depends on which quantity band the order falls in.
- **Price adjustment schedule**: The record that groups price adjustments of one type, for example volume or attribute, and the dates they apply.
- **Adjustment method (Range and Slab)**: Range gives every unit the discount of the band the quantity reaches. Slab prices each band's units at that band's price.
- **Price adjustment tier**: One quantity band on a schedule, with a lower bound, an upper bound and a discount.
- **Tier bounds**: The lowest and highest quantity in a band. In this org both are included, so bands must not share a number.
- **Block price**: A fixed price for a block of units. Shown on a slide for contrast only.
- **Attribute based adjustment**: A price change that depends on the chosen attribute values, for example Long Range battery.
- **Decision table refresh**: Updating the table the pricing procedure reads so it sees changed records. Without it the old values are used.
