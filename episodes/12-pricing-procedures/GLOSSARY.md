# Glossary: episode 12, Pricing procedures

Terms introduced in this episode. The full project glossary is `GLOSSARY.md` in the repository root.

- **Pricing procedure**: An ordered list of pricing steps that the system runs to price a quote line.
- **Pricing element**: One step in a pricing procedure, such as Pricing Setting or List Price.
- **Recipe**: The series' plain word for a pricing procedure.
- **Context definition**: The description of which quote and line fields a procedure can read and write.
- **Price waterfall**: The list of steps that moved a price from list price to net price, shown step by step.
- **Unit price and net unit price**: Unit price is the price of one unit before adjustments; net unit price is the price of one unit after them.
- **Subtotal**: The net unit price multiplied by the quantity.
- **Stacking**: The order in which adjustments apply, each starting from the price the previous one left.
- **STLE, TLE, TLT**: Sales Transaction Line Editor (the current line grid), Transaction Line Editor (the older one), and Transaction Line Table (where lines and prices are held).
- **Simulate**: Run a procedure on sample or real input to see the result without saving a quote.
- **Rank**: The number that decides which of several enabled versions is used; the highest rank wins.
