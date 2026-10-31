# Episode 14: Promotions

## What this episode builds

How a promotion works in the price waterfall. In this series the promotion is shown on slides as a labelled worked example, because the example org holds no promotion records. A Refrigerated launch offer of 1,000 off each Refrigerated van would take the 100-van test price from 54,591 to 53,591, and a Standard Panel van would get no promotion line.

## Before you start

Starting point: tag `ep13-end`. Velora Pricing has the Volume Discount element and the option prices are loaded, so a Refrigerated Long Range van lists at 58,700. Quote V1 exists. Building a live promotion needs the Promotions licences and the Promotion Designer and Apply Promotions permission sets; check them under Setup, Company Information, Licenses.

To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep13-end --org <your org alias>`. The script loads the data and lists the steps that must be done by hand. A git tag restores files only, never the org, so do not rely on `git checkout` to rebuild the org.

## Click path

1. Open Setup, Company Information, and look at the licences. Why: promotions need the Revenue Cloud Advanced licence plus a promotions add-on; this shows whether the org can build one.
2. If the licence is present: set up the promotion rule library, add the Promotion Execution element to Velora Pricing (save, simulate, activate), and turn promotions on. If not, the episode uses slides, and the numbers below are a labelled calculation, not Salesforce output.
3. In Promotions & Offers click New Promotion. Name it Refrigerated Launch Offer, set the quarter's dates, leave coupons off so the offer applies automatically.
4. Choose the template Get Discount + Rewards on X (Based on Selling Model). Product Volt Van, selling model One Time, amount discount 1,000, for Refrigerated bodies only. Review, save and activate.
5. Run Sync Pricing Data in Salesforce Pricing Setup.
6. On the fleet quote use Browse Catalogs and the promotions button beside the Volt Van to see the offer.
7. On the Lines tab open the Volt Van's side panel, Promotions tab, and hover or click the net unit price. A 100-van Refrigerated Long Range line reads 58,700, volume discount to 54,591, launch offer 1,000, net 53,591. A Standard Panel van shows no promotion line (44,640).

## Files in this repo used by this episode

- `force-app/main/default/expressionSetDefinition/Velora_Pricing.expressionSetDefinition-meta.xml`: the pricing procedure. In this series' org it holds no Promotion Execution element, so this file has no promotion step.
- The repository holds no promotion records or promotion metadata. The promotion is done by hand in the org, or shown on slides. Nothing in `data/` creates it.

## What you should see

On slides: the waterfall for a Refrigerated Long Range van at quantity 100 reads list 58,700, volume 7 percent to 54,591, launch offer 1,000 off, net 53,591. A Standard Panel van at the same quantity stays at 44,640. If you build it live, the offer appears as its own line in the waterfall.

## Records and values

All names and numbers are invented examples. Prices are in US dollars.

- Launch offer: 1,000 off each Refrigerated van for one quarter (a slide-only calculation in this series).
- 100-unit test basis: 58,700 -> 54,591 after the 7 percent tier -> 53,591 net.
- The real V1 prices its 60 Refrigerated vans at their own quantity: 58,700 less 4 percent = 56,352 each, with no promotion.
