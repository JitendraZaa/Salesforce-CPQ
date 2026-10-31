# Episode 9: Configuration rules

## What this episode builds

You add rules that keep the Volt Van's choices valid. First rule: a Refrigerated body needs the Long Range battery,
because the fridge runs from the battery. Second rule: with a Refrigerated body, the Standard battery cannot be chosen.
You prove both in the configurator on the pilot quote, then put the pilot back to Standard battery and Panel body.

## Before you start

- Starting point: end of episode 8 (tag `ep08-end`): the Volt Van Fleet Package is in the catalog and on the pilot quote; Battery and Body are independent picklists. Configuration Rules with Business Rules Engine is off.
- Fresh org: `sh scripts/reset-to.sh ep08-end`. Tag at the end: `ep09-end`.

## Click path

1. Setup, Revenue Settings: turn on "Configuration Rules with Business Rules Engine". Leave the Constraints Engine option
   off (it is greyed out and not used).
2. Check you hold the Product Configuration Rules Designer, Rule Engine Designer and Rule Engine Runtime permissions.
3. Open the pilot quote and check its Transaction Type field. It must name the type whose rule engine is Standard
   Configurator. Changing the default affects new quotes only. Add the field to the layout if hidden.
4. Product Catalog Management, Product Configuration Rules, New. Name `Refrigerated Needs Long Range`, status Active,
   sequence 10. Next.
5. Criteria: scope Product; condition product Volt Van; sub-condition Body equals Refrigerated. A rule allows up to three
   conditions and nine sub-conditions, joined by AND.
6. Actions: Set Attribute, Battery = Long Range 90 kWh, with a message. Save.
7. Create the second rule `Refrigerated Blocks Standard Battery`: product scope, Volt Van, Body equals Refrigerated;
   action Disable Attribute Value, Battery, value Standard 60 kWh, with an informational message. Sequence 20, Active.
8. Validate the rules, then open the Volt Van Fleet Package line in the configurator. Change Body to Refrigerated.
   Battery becomes Long Range 90 kWh, both messages appear, and the Battery list offers only Long Range.
9. Restore the pilot: Body back to Panel, Battery back to Standard 60 kWh, save the configuration, and confirm the quote shows Standard and Panel.

## Files in this repo used by this episode

No file in the repo creates the rules. A rule record cannot be created through the API; it is made in the rule library
on screen. This episode has no script and no data file of its own. The repo still helps in two ways:

| File | Use |
|---|---|
| `force-app/main/default/settings/` | The Revenue Settings switches (deployed by `sh scripts/setup-org.sh <alias>`). Check the Business Rules Engine switch by hand in step 1. |
| `scripts/seed-ep09.sh` | Runs the episode 8 chain and prints the by-hand list for this episode. |

```sh
sh scripts/seed-ep09.sh
```

- No flags: it uses your default org, or `TARGET_ORG=<alias>` before the command to choose one.
- The rule library also needs a release of the latest rule version activated: Product Catalog Management, Configuration Rules library, activate the latest version.

## What you should see

In the configurator, choosing Refrigerated sets the Battery to Long Range 90 kWh, the Standard 60 kWh value is unavailable
with a message, and after the restore the pilot quote shows Standard and Panel again.

## Records and values

Rule 1 "Refrigerated Needs Long Range": sequence 10, Product scope, Volt Van, Body equals Refrigerated, Set Attribute
Battery = Long Range 90 kWh. Rule 2 "Refrigerated Blocks Standard Battery" (decision 59 and 63): sequence 20, Disable
Attribute Value Battery = Standard 60 kWh, informational message. No Transaction Type step was needed beyond the quote's engine.
