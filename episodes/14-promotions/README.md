# Episode 14: Promotions

## What this episode builds

A concept episode: how a promotion works and where it sits in the price waterfall. It is taught on slides with a labelled worked example, a Refrigerated launch offer of 1,000 off each Refrigerated van for one quarter. There is no hands-on build in this series, so nothing is created in the org and this episode adds no files. The example is an illustration, not Salesforce output.

## Before you start

Starting point: tag `ep13-end`. Velora Pricing has the Volume Discount element and the option prices are loaded, so a Refrigerated Long Range van lists at 58,700. Quote V1 (00000036) exists.

To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep13-end <your org alias>`. The script loads the data and lists the steps that must be done by hand. A git tag restores files only, never the org, so do not rely on `git checkout` to rebuild the org.

## What the slides cover

1. Promotion versus manual discount. A manual discount is typed on a line by a rep. A promotion is a rule-based reward that the system applies to eligible products on a transaction, with its own start and end dates, so finance can report what it cost.
2. The parts of a promotion: eligibility (which products, selling model, channel, customer group), the reward (here 1,000 off), and the dates. It is automatic when no coupon is needed, or manual when a coupon (a code the offer needs before it applies) is required.
3. Where it runs. A promotion has effect only if the pricing procedure has a Promotion Execution element; the offer then shows as its own line in the price waterfall.
4. What an org needs. Promotions depend on your Revenue Management licences and on the promotions feature being available in your org. To see what your org has, open Setup, Company Information, Licenses, and Setup, Permission Set Licenses, and look for the Revenue Management Promotions Run Time licence and the promotion permission sets. In Promotions and Offers (App Launcher) you can see whether promotion design is available to you.
5. The worked example (slides only): Refrigerated Launch Offer, 1,000 off each Refrigerated van, for the launch quarter. A Standard Panel van gets no promotion line.

## Files in this repo used by this episode

- `force-app/main/default/expressionSetDefinition/Velora_Pricing.expressionSetDefinition-meta.xml`: the pricing procedure, which you can open to see where a Promotion Execution element would sit, after the volume step. This file holds no promotion step.
- The repository holds no promotion records or promotion metadata, and nothing in `data/` creates them.

## What you should see

On the slides, the waterfall for a Refrigerated Long Range van at quantity 100 reads list 58,700, volume 7 percent to 54,591, launch offer 1,000 off, net 53,591 (an illustration). A Standard Panel van at the same quantity stays at 44,640.

## Records and values

All names and numbers are invented examples. Prices are in US dollars.

- Launch offer: 1,000 off each Refrigerated van for one quarter (an illustration on slides).
- 100-unit test basis: 58,700 -> 54,591 after the 7 percent tier -> 53,591 with the illustrated offer.
- The real V1 prices its 60 Refrigerated vans at their own quantity: 58,700 less 4 percent = 56,352 each, with no promotion.

## Try it yourself

This is a reading task. In your own org open Setup, Pricing Procedures, Velora Pricing, and find the steps after Volume Discount. Write down where a Promotion Execution element would go and which line of the waterfall it would add. Then, in Setup, Permission Set Licenses, note whether a promotions licence is listed for your org.
