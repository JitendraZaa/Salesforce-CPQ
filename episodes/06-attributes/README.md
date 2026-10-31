# Episode 6: Attributes and classifications

## What this episode builds

You give the Volt Van its choices. You create two attribute picklists, Battery (Standard 60 kWh, Long Range 90 kWh) and
Body (Panel, Refrigerated), turn them into attributes, put both in a product classification called Electric Vehicle,
and base the Volt Van on that classification. When the van is added to the pilot quote, the configurator opens with the
two choices.

## Before you start

- Starting point: end of episode 5 (tag `ep05-end`): catalog, categories and six products; the pilot quote carries one Volt Van line.
- Fresh org: `sh scripts/reset-to.sh ep05-end`. Tag at the end: `ep06-end`.

## Click path

1. Product Catalog Management, Picklists, New. Name Battery, a text data type, status Active. Save.
2. On Battery open Related, Attribute Picklist Values, New: Standard 60 kWh (code BAT-STD, Active, Default, sequence 1)
   and Long Range 90 kWh (BAT-LR, Active, sequence 2). Only one value can be the default.
3. Repeat for Body: Panel (BODY-PAN, default, sequence 1) and Refrigerated (BODY-REF, sequence 2).
4. Attributes, New. Label Battery, Source System ID `ATTR-BATTERY`, data type Picklist, picklist Battery, Required and
   Active. Save. Repeat for Body (`ATTR-BODY`). Why: only active attributes can be put in a classification.
5. Product Classifications, New. Name Electric Vehicle, code EV. Save and make it active so attributes can be assigned.
6. Open the classification, Attributes tab, Assign, Assign individual attributes, Next, tick Battery and Body, Assign.
   Set sequence 1 for Battery and 2 for Body.
7. Products, Volt Van, Edit, set Based On to Electric Vehicle. Save. Why: the product inherits the classification's attributes.
8. On the pilot quote delete the Volt Van line. Browse Catalogs, Velora Catalog, Vehicles, Vans, Volt Van, add and add
   items to the quote. The configurator opens with Battery (Standard 60 kWh) and Body (Panel) selected by default.

## Files in this repo used by this episode

| File | What it contains |
|---|---|
| `data/seed/10-AttributePicklist.json`, `11-AttributePicklistValue.json`, `12-AttributeDefinition.json` | The Battery and Body picklists, their values and the two attributes. |
| `data/seed/15-ProductClassification.json`, `16-ProductClassificationAttr.json` | The Electric Vehicle classification and the assignment of the two attributes. |
| `data/seed/19-ProductAttributeDefinition.json` | The link between the Volt Van and its attributes. |
| `scripts/seed-ep06.sh` | Runs the episode 5 data scripts and prints the by-hand list for this episode. |

```sh
sh scripts/seed-all.sh my_alias --dry-run
sh scripts/seed-all.sh my_alias
python3 scripts/seed.py load my_alias
```

- `seed-all.sh <alias>`: loads all example data into the org with that alias, in dependency order. Run again, it skips what exists.
- `--dry-run`: prints what would be created, creates nothing.
- `seed.py load <alias>`: the loader that `seed-all.sh` calls.
- Things made in Draft are activated by the loader where possible; anything left in Draft is listed in its output: activate it by hand (picklists, attributes, classification).

## What you should see

The configurator for the Volt Van shows a Battery picklist (Standard 60 kWh, Long Range 90 kWh) and a Body picklist (Panel, Refrigerated), both inherited from the classification. The line still prices at 48,000.

## Records and values

Battery: Standard 60 kWh, Long Range 90 kWh (+6,500 in the first story). Body: Panel, Refrigerated (+4,200 in the
first story). The org does not add these amounts per option: from episode 13 the prices come from Attribute Based
Adjustments, with Override prices Panel plus Long Range 54,500 and Refrigerated plus Long Range 58,700 (decision 62).
Standard battery with Panel stays 48,000.
