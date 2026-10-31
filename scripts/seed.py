#!/usr/bin/env python3
"""Export and load the Velora Motors reference data (no Ids, references by name).

  python3 scripts/seed.py export <source-alias> [--since 2026-10-30T22:00:00Z]
  python3 scripts/seed.py load   <target-alias> [--only Product2,PricebookEntry] [--dry-run]

Why a script and not `sf data export tree`: the Revenue Cloud objects are linked by lookups to records that already
exist in the source org (selling models, the standard price book, record types). The tree format cannot point at
records outside the file, and the Ids differ in every org. This script writes one JSON file per object into
data/seed/, in load order (data/seed/manifest.json). Every lookup is written as the name (and match fields) of the
record it points at, and the loader turns it back into the Id of the target org. Records that are already in the
target (same Name and same lookups) are skipped, so the load can be run again.

Export keeps the records created after --since (the Velora work) plus every record they point at (the "closure"),
whoever created it. Read-only on the source org. Only the Salesforce CLI and Python 3 are needed.

@author Jitendra Zaa
"""
import argparse
import json
import os
import subprocess
import sys
import urllib.error
import urllib.parse
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SEED = os.path.join(ROOT, "data", "seed")
API = "v68.0"

# Objects that carry Velora reference data. Order here is only a hint; the load order is computed from the lookups.
OBJECTS = """ProductSpecificationRecType Account Contact Pricebook2 ProductCatalog ProductCategory ProductSellingModel UnitOfMeasureClass UnitOfMeasure
AttributePicklist AttributePicklistValue AttributeDefinition AttributeCategory AttributeCategoryAttribute
ProductClassification ProductClassificationAttr Product2 ProductAttributeDefinition ProductCategoryProduct
PricebookEntry ProductSellingModelOption ProductComponentGroup ProductRelatedComponent ProductRampSegment
ProductConfigurationFlow ProductConfigFlowAssignment ProductConfigurationRule ProductQualification
ProductDisqualification PriceAdjustmentSchedule PriceAdjustmentTier BundleBasedAdjustment AttributeBasedAdjRule
AttributeAdjustmentCondition AttributeBasedAdjustment UsageResource ProductUsageResource RateCard RateCardEntry
PriceBookRateCard LegalEntity BillingPolicy BillingTreatment BillingTreatmentItem UsageResourceBillingPolicy
RatingFrequencyPolicy UsageOveragePolicy UsageCommitmentPolicy UsageGrantRenewalPolicy UsageGrantRolloverPolicy UsageResourcePolicy
ProductUsageResourcePolicy ProductUsageGrant ProrationPolicy PaymentTerm PaymentTermItem
FulfillmentWorkspace FulfillmentStepDefinitionGroup FulfillmentStepDefinition FulfillmentStepDependencyDef
FulfillmentWorkspaceItem FulfillmentFalloutRule FulfillmentStepJeopardyRule ProductFulfillmentDecompRule
ProductFulfillmentScenario ProductDecompEnrichmentRule ClauseCatgConfiguration DocumentClauseSet DocumentClause
DocumentClauseContentToken""".split()

# How the loader recognises a record that is already in the target (default: Name plus the lookups).
MATCH = {"Product2": ["ProductCode"], "Contact": ["LastName", "FirstName"], "Account": ["Name"],
         "ProductCategory": ["Name", "CatalogId"], "UnitOfMeasure": ["Name"], "RatingFrequencyPolicy": ["RatingPeriod", "RatingDelayDuration"], "ProductSpecificationRecType": ["DeveloperName"], "UnitOfMeasureClass": ["Name"]}

# Whole tables that are exported even when nobody on the Velora side created a row.
ALWAYS = {"ProductSpecificationRecType", "BillingTreatmentItem"}

# Lookups that point in a circle (class <-> unit, policy <-> treatment): created empty, filled in the last step.
DEFER = {"UnitOfMeasureClass": {"DefaultUnitOfMeasureId", "BaseUnitOfMeasureId"},
         "BillingPolicy": {"DefaultBillingTreatmentId"}}

# Per-object fields left out: values that only make sense in the source org (an Id stored in a picklist).
SKIP_BY_OBJECT = {"Account": {"CleanStatus"}, "Contact": {"CleanStatus"}}

# Picklists whose values are the (15 character) Id of a record of another object.
ID_IN_PICKLIST = {("DocumentClauseSet", "Category"): "ClauseCatgConfiguration"}

# Lookups to a user or group that the loader sets to the user running the load.
RUNNING_USER = {"FulfillmentStepDefinition": ["AssignedToId"]}

# Created after these (the platform refuses a price book entry before the selling model option exists).
EXTRA_DEPS = {"PricebookEntry": ["ProductSellingModelOption"]}

SKIP_FIELDS = {"OwnerId", "CreatedById", "LastModifiedById", "CreatedDate", "LastModifiedDate", "SystemModstamp"}


_CONN = {}


def conn(alias):
    """Access token and instance URL of an org the CLI is logged in to (asked once per run)."""
    if alias not in _CONN:
        p = subprocess.run(["sf", "org", "display", "-o", alias, "--json"], capture_output=True, text=True)
        try:
            d = json.loads(p.stdout[p.stdout.index("{"):])["result"]
        except ValueError:
            raise SystemExit("sf org display failed for %s: %s" % (alias, p.stdout[-300:] + p.stderr[-300:]))
        tok = d.get("accessToken", "")
        if not tok or "REDACTED" in tok:
            p = subprocess.run(["sf", "org", "auth", "show-access-token", "-o", alias, "--json"],
                               capture_output=True, text=True)
            tok = json.loads(p.stdout[p.stdout.index("{"):])["result"]["accessToken"]
        _CONN[alias] = (tok, d["instanceUrl"])
    return _CONN[alias]


def http(alias, path, method="GET", body=None):
    tok, url = conn(alias)
    req = urllib.request.Request(url + path, method=method, headers={
        "Authorization": "Bearer " + tok, "Content-Type": "application/json"},
        data=json.dumps(body).encode() if body is not None else None)
    try:
        with urllib.request.urlopen(req, timeout=300) as r:
            txt = r.read().decode()
    except urllib.error.HTTPError as e:
        txt = e.read().decode()
        if e.code == 401:
            _CONN.pop(alias, None)
        return json.loads(txt) if txt else {"error": e.code}
    return json.loads(txt) if txt else {}


def rest(alias, path, method="GET", body=None):
    return http(alias, "/services/data/%s/%s" % (API, path), method, body)


def query(alias, soql):
    out = []
    d = http(alias, "/services/data/%s/query?q=%s" % (API, urllib.parse.quote(soql)))
    while True:
        if isinstance(d, list):
            raise RuntimeError(d[0].get("message", str(d))[:300])
        out += d["records"]
        if d.get("done", True):
            return out
        d = http(alias, d["nextRecordsUrl"])


def me(alias):
    """Id of the user the CLI is logged in as."""
    if ("me", alias) not in _CONN:
        p = subprocess.run(["sf", "org", "display", "-o", alias, "--json"], capture_output=True, text=True)
        user = json.loads(p.stdout[p.stdout.index("{"):])["result"]["username"]
        _CONN[("me", alias)] = query(alias, "SELECT Id FROM User WHERE Username = %s" % q(user))[0]["Id"]
    return _CONN[("me", alias)]


def describe(alias, obj):
    d = rest(alias, "sobjects/%s/describe" % obj)
    return d if isinstance(d, dict) and "fields" in d else None


def q(v):
    return "'" + str(v).replace("\\", "\\\\").replace("'", "\\'") + "'"


# ---------------------------------------------------------------- export
def export(alias, since):
    os.makedirs(SEED, exist_ok=True)
    desc = {}
    for o in OBJECTS:
        d = describe(alias, o)
        if d and "fields" in d and d.get("createable"):
            desc[o] = d
        else:
            print("skip (not creatable here): " + o)
    fields = {}  # object -> list of exported field descriptors
    for o, d in desc.items():
        fl = []
        for f in d["fields"]:
            n = f["name"]
            if n in SKIP_FIELDS or n in SKIP_BY_OBJECT.get(o, ()) or not f["createable"] or f["calculated"] or f["type"] in ("base64", "location"):
                continue
            if f["type"] == "reference":
                tgt = f["referenceTo"]
                if len(tgt) != 1 or tgt[0] in ("User", "Group"):
                    continue
            fl.append(f)
        fields[o] = fl
    # an object is named by Name only when Name can be written (Contact's and Case's cannot)
    has_name = {o: any(f["name"] == "Name" and f["createable"] for f in d["fields"]) for o, d in desc.items()}
    rec_types = {}

    def cols(o):
        c = [f["name"] for f in fields[o]]
        if has_name[o] and "Name" not in c:
            c.append("Name")
        return c

    data = {o: {} for o in desc}  # object -> Id -> record
    for o in desc:
        where = "CreatedDate >= " + since if o not in ALWAYS else "Id != null"
        recs = query(alias, "SELECT Id, %s FROM %s WHERE %s" % (", ".join(cols(o)), o, where))
        for r in recs:
            data[o][r["Id"]] = r
        print("%-32s %d created since %s" % (o, len(recs), since))
    # closure: pull in the records the exported ones point at
    id_obj = {}
    changed = True
    while changed:
        changed = False
        for o in list(desc):
            for r in list(data[o].values()):
                for f in fields[o]:
                    v = r.get(f["name"])
                    if f["type"] != "reference" or not v:
                        continue
                    t = f["referenceTo"][0]
                    if t in desc and v not in data[t]:
                        rr = query(alias, "SELECT Id, %s FROM %s WHERE Id = %s" % (", ".join(cols(t)), t, q(v)))
                        if rr:
                            data[t][v] = rr[0]
                            changed = True
    # ProductSpecificationRecType.ProductSpecificationType holds the Id of a metadata record: carry its DeveloperName
    for r in data.get("ProductSpecificationRecType", {}).values():
        pst = query(alias, "SELECT DeveloperName FROM ProductSpecificationType WHERE Id = %s" % q(r["ProductSpecificationType"]))
        r["ProductSpecificationType"] = None
        r["_pst"] = pst[0]["DeveloperName"]
    # references outside the set: resolved by Name in the target (record types, standard objects)
    ext = {}  # (object, Id) -> {"object", "Name"/"DeveloperName"}
    for o in desc:
        for r in data[o].values():
            for f in fields[o]:
                v = r.get(f["name"])
                if f["type"] == "reference" and v and f["referenceTo"][0] not in desc:
                    t = f["referenceTo"][0]
                    if (t, v) in ext:
                        continue
                    key = "DeveloperName" if t == "RecordType" else "Name"
                    rr = query(alias, "SELECT %s%s FROM %s WHERE Id = %s" % (
                        key, ", SobjectType" if t == "RecordType" else "", t, q(v)))
                    ext[(t, v)] = dict({"object": t, key: rr[0][key]} if rr else {"object": t, "missing": v})
                    if rr and t == "RecordType":
                        ext[(t, v)]["SobjectType"] = rr[0]["SobjectType"]

    def ref_of(t, v):
        """Describes the record behind Id v of type t, by name and its own lookups."""
        if t in desc:
            return {"object": t, "key": key_of(t, v)}
        return ext[(t, v)]

    keycache = {}

    def key_of(o, i):
        """Name of the record; when two records of the object share a name, the names of what they point at too."""
        if (o, i) in keycache:
            return keycache[(o, i)]
        r = data[o][i]
        name = str(r.get("Name") or r.get("DeveloperName") or "")
        same = [x for x in data[o].values() if str(x.get("Name") or "") == name]
        parts = [name]
        if len(same) > 1 or not name:
            for f in fields[o]:
                v = r.get(f["name"])
                if f["type"] == "reference" and v and f["referenceTo"][0] in desc and not f["name"].startswith("Parent"):
                    t = f["referenceTo"][0]
                    parts.append(str(data[t][v].get("Name") or v) if v in data[t] else str(v))
        keycache[(o, i)] = "|".join(parts)
        return keycache[(o, i)]

    # load order: topological on lookups
    deps = {o: set() for o in desc}
    for o in desc:
        for f in fields[o]:
            if f["type"] == "reference" and f["referenceTo"][0] in desc and f["referenceTo"][0] != o \
                    and f["name"] not in DEFER.get(o, ()):
                deps[o].add(f["referenceTo"][0])
    for o_, extra in EXTRA_DEPS.items():
        if o_ in deps:
            deps[o_] |= {e for e in extra if e in desc}
    order, seen = [], set()

    def visit(o):
        if o in seen:
            return
        seen.add(o)
        for d in sorted(deps[o], key=OBJECTS.index):
            visit(d)
        order.append(o)

    for o in OBJECTS:
        if o in desc:
            visit(o)

    manifest = []
    for n, o in enumerate(order, 1):
        if not data[o]:
            continue
        recs = []
        for i, r in data[o].items():
            rec = {"_key": key_of(o, i)}
            for f in fields[o]:
                v = r.get(f["name"])
                if v is None or v == "":
                    continue
                if (o, f["name"]) in ID_IN_PICKLIST:
                    t = ID_IN_PICKLIST[(o, f["name"])]
                    tid = next((i2 for i2 in data.get(t, {}) if i2[:15] == v[:15]), None)
                    if tid:
                        rec["#" + f["name"]] = {"object": t, "key": key_of(t, tid)}
                elif f["type"] == "reference":
                    rec[("@@" if f["name"] in DEFER.get(o, ()) else "@") + f["name"]] = ref_of(f["referenceTo"][0], v)
                else:
                    rec[f["name"]] = v
            if r.get("_pst"):
                rec["@ProductSpecificationType"] = {"object": "ProductSpecificationType", "DeveloperName": r["_pst"]}
            if has_name[o] and "Name" not in rec and r.get("Name"):
                rec["Name"] = r["Name"]
            recs.append(rec)
        recs.sort(key=lambda x: x["_key"])
        match = MATCH.get(o) or ((["Name"] if has_name[o] else []) + [
            f["name"] for f in fields[o]
            if f["type"] == "reference" and f["referenceTo"][0] in desc and not f["name"].startswith("Parent")
            and f["name"] not in DEFER.get(o, ())])
        fn = "%02d-%s.json" % (n, o)
        with open(os.path.join(SEED, fn), "w") as fh:
            json.dump({"object": o, "match": match, "records": recs}, fh, indent=1, sort_keys=True)
            fh.write("\n")
        manifest.append(fn)
        print("wrote %s (%d records)" % (fn, len(recs)))
    for fn in os.listdir(SEED):
        if fn.endswith(".json") and fn != "manifest.json" and fn not in manifest and fn[:2].isdigit():
            os.unlink(os.path.join(SEED, fn))
    with open(os.path.join(SEED, "manifest.json"), "w") as fh:
        json.dump({"files": manifest}, fh, indent=1)
        fh.write("\n")


# ---------------------------------------------------------------- load
def load(alias, only, dry):
    with open(os.path.join(SEED, "manifest.json")) as fh:
        files = json.load(fh)["files"]
    ids = {}  # (object, key) -> Id in the target
    sched_from = {}
    later = []  # circular lookups, set after everything exists
    late_status = []  # (object, Id, Status) for records created as Draft
    ext_cache = {}
    totals = {}

    def resolve_ext(ref):
        k = json.dumps(ref, sort_keys=True)
        if k in ext_cache:
            return ext_cache[k]
        t = ref["object"]
        if "DeveloperName" in ref:
            w = "DeveloperName = %s" % q(ref["DeveloperName"])
            if "SobjectType" in ref:
                w += " AND SobjectType = %s" % q(ref["SobjectType"])
        elif "Name" in ref:
            w = "Name = %s" % q(ref["Name"])
        else:
            ext_cache[k] = None
            return None
        rr = query(alias, "SELECT Id FROM %s WHERE %s LIMIT 1" % (t, w))
        ext_cache[k] = rr[0]["Id"] if rr else None
        return ext_cache[k]

    for fn in files:
        with open(os.path.join(SEED, fn)) as fh:
            spec = json.load(fh)
        o, match, recs = spec["object"], spec["match"], spec["records"]
        if only and o not in only:
            # still learn the Ids of what exists, so later objects can point at them
            pass
        # fields the target org does not have (a feature that is off there) are dropped; required User lookups
        # that the export could not carry are set to the user running the load
        td = describe(alias, o)
        if not td:
            print("%-32s not available in the target org, skipped" % o)
            totals[o] = ("not available in target", len(recs))
            continue
        tfields = {f["name"]: f for f in td["fields"] if f["createable"]}
        required_users = [n for n, f in tfields.items() if not f["nillable"] and f["type"] == "reference"
                          and "User" in f["referenceTo"] and not f["defaultedOnCreate"]]
        dropped = set()
        # existing records in the target, to skip duplicates and learn their Ids
        try:
            cols = ", ".join(match + (["Status"] if "Status" in tfields and "Status" not in match else []))
            existing = query(alias, "SELECT Id%s FROM %s" % ((", " + cols) if cols else "", o))
        except RuntimeError as e:
            print("%-30s cannot read target: %s" % (o, str(e)[:120]))
            totals[o] = ("unreadable", len(recs))
            continue
        index = {}
        status_now = {}
        for r in existing:
            index[tuple(r.get(m) for m in match)] = r["Id"]
            status_now[r["Id"]] = r.get("Status")
        todo, errs = [], 0
        pending = list(recs)
        created = skipped = 0
        if only and o not in only:
            totals[o] = ("not selected", len(recs))
            continue
        while pending:
            todo, deferred = [], []
            for rec in pending:
                body, bad, wait = {}, None, False
                for k, v in rec.items():
                    if k == "_key":
                        continue
                    if k.startswith("#"):  # a picklist whose value is the Id of another record
                        tid = ids.get((v["object"], v["key"]))
                        if tid:
                            body[k[1:]] = tid[:15]
                        else:
                            wait = True
                        continue
                    if k.startswith("@@"):
                        later.append((o, rec["_key"], k[2:], v))
                        continue
                    if k.startswith("@"):
                        tid = ids.get((v["object"], v["key"])) if "key" in v else resolve_ext(v)
                        if not tid:
                            if v.get("object") == o:
                                wait = True  # points at a record of the same object, created in a later pass
                            else:
                                bad = "%s -> %s not found" % (k[1:], json.dumps(v)[:100])
                            break
                        body[k[1:]] = tid
                    else:
                        if k not in tfields:
                            dropped.add(k)
                            continue
                        body[k] = v
                if "PriceAdjustmentScheduleId" in body and body.get("EffectiveFrom"):
                    # the target's own schedule may start later than the source's did
                    sid = body["PriceAdjustmentScheduleId"]
                    if sid not in sched_from:
                        r_ = query(alias, "SELECT EffectiveFrom FROM PriceAdjustmentSchedule WHERE Id = %s" % q(sid)) \
                            if sid != "dry" else []
                        sched_from[sid] = r_[0]["EffectiveFrom"] if r_ else None
                    if sched_from[sid] and body["EffectiveFrom"][:19] < sched_from[sid][:19]:
                        body["EffectiveFrom"] = sched_from[sid]
                        if body.get("EffectiveTo") and body["EffectiveTo"][:19] <= body["EffectiveFrom"][:19]:
                            print("  %-28s skipped, it ended before the target's schedule started: %s" % (
                                o, rec["_key"][:60]))
                            skipped += 1
                            continue
                for n in required_users + RUNNING_USER.get(o, []):
                    body.setdefault(n, me(alias))
                if bad:
                    print("  %-28s %s: %s" % (o, rec["_key"][:40], bad))
                    errs += 1
                elif wait:
                    deferred.append(rec)
                else:
                    mt = tuple(body.get(m) for m in match)
                    if mt in index:
                        ids[(o, rec["_key"])] = index[mt]
                        skipped += 1
                        if body.get("Status") and status_now.get(index[mt]) == "Draft" and body["Status"] != "Draft":
                            late_status.append((o, index[mt], body["Status"]))  # left in Draft by an earlier run
                    else:
                        todo.append((rec["_key"], body))
            if dry:
                for k, _ in todo:
                    ids[(o, k)] = "dry"
                created += len(todo)
            else:
                for i in range(0, len(todo), 200):
                    batch = todo[i:i + 200]
                    payload = {"allOrNone": False, "records": [dict(b, attributes={"type": o}) for _, b in batch]}
                    res = rest(alias, "composite/sobjects", "POST", payload)
                    if not isinstance(res, list):
                        print("  %s: %s" % (o, str(res)[:300]))
                        errs += len(batch)
                        continue
                    retry = []
                    for (k, b), r in zip(batch, res):
                        if r.get("success"):
                            ids[(o, k)] = r["id"]
                            created += 1
                        elif b.get("Status") not in (None, "Draft"):
                            retry.append((k, b))  # many Revenue Cloud objects can only be created in Draft
                        else:
                            errs += 1
                            print("  %-28s %s: %s" % (o, k[:40], "; ".join(
                                e.get("message", "")[:200] for e in r.get("errors", []))))
                    if retry:
                        drafts = [dict(b, Status="Draft", attributes={"type": o}) for _, b in retry]
                        res2 = rest(alias, "composite/sobjects", "POST", {"allOrNone": False, "records": drafts})
                        upd = []
                        for (k, b), r in zip(retry, res2):
                            if r.get("success"):
                                ids[(o, k)] = r["id"]
                                created += 1
                                upd.append({"id": r["id"], "Status": b["Status"], "attributes": {"type": o}})
                            else:
                                errs += 1
                                print("  %-28s %s: %s" % (o, k[:40], "; ".join(
                                    e.get("message", "")[:200] for e in r.get("errors", []))))
                        late_status += [(o, u["id"], u["Status"]) for u in upd]
            if len(deferred) == len(pending):
                errs += len(deferred)
                print("  %s: %d records point at records that could not be created" % (o, len(deferred)))
                break
            pending = deferred
        if dropped:
            print("  %-28s dropped (not in this org): %s" % (o, ", ".join(sorted(dropped))))
        totals[o] = ("%s %d, already there %d, failed %d" % ("would create" if dry else "created", created, skipped, errs), len(recs))
        print("%-32s %s" % (o, totals[o][0]))
    # circular lookups, then the statuses that had to wait for them
    if not dry:
        by_obj = {}
        for o, key, field, ref in later:
            tid = ids.get((ref["object"], ref["key"]))
            if tid and ids.get((o, key)):
                by_obj.setdefault(o, []).append({"id": ids[(o, key)], field: tid, "attributes": {"type": o}})
        merged = {}
        for o, recs_ in by_obj.items():
            for r in recs_:
                merged.setdefault((o, r["id"]), {"id": r["id"], "attributes": {"type": o}}).update(r)
        for o in {k[0] for k in merged}:
            batch = [v for k, v in merged.items() if k[0] == o]
            for i in range(0, len(batch), 200):
                res = rest(alias, "composite/sobjects", "PATCH", {"allOrNone": False, "records": batch[i:i + 200]})
                for r in (res if isinstance(res, list) else []):
                    if not r.get("success"):
                        print("  %-28s circular lookup not set: %s" % (o, "; ".join(
                            e.get("message", "")[:160] for e in r.get("errors", []))))
        for _ in range(4):  # a policy can only be activated after its treatment, and that after its items
            left = []
            for o, i, st in late_status:
                res = rest(alias, "composite/sobjects", "PATCH", {"allOrNone": False, "records": [
                    {"id": i, "Status": st, "attributes": {"type": o}}]})
                if isinstance(res, list) and not res[0].get("success"):
                    left.append((o, i, st, "; ".join(e.get("message", "")[:160] for e in res[0].get("errors", []))))
            if len(left) == len(late_status):
                break
            late_status = [(o, i, st) for o, i, st, _m in left]
        for o, i, st, m in left if late_status else []:
            print("  %-28s %s left in Draft, activate by hand: %s" % (o, i, m))
    print("\nSummary")
    for o, (s, n) in totals.items():
        print("  %-30s %s" % (o, s))


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("cmd", choices=["export", "load"])
    ap.add_argument("alias")
    ap.add_argument("--since", default="2026-10-30T22:00:00Z")
    ap.add_argument("--only", default="")
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()
    if a.cmd == "export":
        export(a.alias, a.since)
    else:
        load(a.alias, set(filter(None, a.only.split(","))), a.dry_run)
