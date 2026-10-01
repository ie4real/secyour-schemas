#!/usr/bin/env bash
# Every type in README's table must have a JSON schema + JSON-LD context whose
# $metadata.type / title / context key all agree, and whose context URL points
# at the sibling .jsonld. Fails on the first mismatch.
set -euo pipefail
cd "$(dirname "$0")/.."
status=0
for t in PurchaseReceipt ProfileIdentity ProfileContact ProfileWork ProfileGovernmentIds; do
  j="schemas/$t.json"; l="schemas/$t.jsonld"
  [ -f "$j" ] && [ -f "$l" ] || { echo "MISSING $t"; status=1; continue; }
  python3 - "$t" "$j" "$l" <<'PY' || status=1
import json, sys
t, j, l = sys.argv[1:]
s = json.load(open(j)); c = json.load(open(l))
assert s["$metadata"]["type"] == t and s["title"] == t, f"{t}: type/title mismatch"
assert s["$metadata"]["uris"]["jsonLdContext"].endswith(f"/schemas/{t}.jsonld"), f"{t}: context url"
ctx = c["@context"][0][t]["@context"]
props = s["properties"]["credentialSubject"]["properties"]
claims = {k for k in props if k != "id"}
assert claims == {k for k in ctx if not k.startswith("@") and k not in ("secyour-vocab", "xsd")}, f"{t}: claims differ between schema and context"
print(f"ok {t}: {sorted(claims)}")
PY
done
exit $status
