# secyour-schemas

Public credential schemas for SecYour-issued verifiable credentials (iden3 /
Privado format: JSON schema + JSON-LD context per type).

**This repo must stay public** — the issuer node fetches schemas by raw URL at
issuance time, and any verifier needs them to interpret proofs.

| Type | JSON schema | JSON-LD context |
|---|---|---|
| `PurchaseReceipt` | `schemas/PurchaseReceipt.json` | `schemas/PurchaseReceipt.jsonld` |
| `ProfileIdentity` | `schemas/ProfileIdentity.json` | `schemas/ProfileIdentity.jsonld` |
| `ProfileContact` | `schemas/ProfileContact.json` | `schemas/ProfileContact.jsonld` |
| `ProfileWork` | `schemas/ProfileWork.json` | `schemas/ProfileWork.jsonld` |
| `ProfileGovernmentIds` | `schemas/ProfileGovernmentIds.json` | `schemas/ProfileGovernmentIds.jsonld` |
| `VerifiedHuman` | `schemas/VerifiedHuman.json` | `schemas/VerifiedHuman.jsonld` |

Raw URLs (what goes into issuance requests / verifier queries):

```
https://raw.githubusercontent.com/ie4real/secyour-schemas/master/schemas/PurchaseReceipt.json
https://raw.githubusercontent.com/ie4real/secyour-schemas/master/schemas/PurchaseReceipt.jsonld
https://raw.githubusercontent.com/ie4real/secyour-schemas/master/schemas/ProfileIdentity.json
https://raw.githubusercontent.com/ie4real/secyour-schemas/master/schemas/ProfileIdentity.jsonld
https://raw.githubusercontent.com/ie4real/secyour-schemas/master/schemas/ProfileContact.json
https://raw.githubusercontent.com/ie4real/secyour-schemas/master/schemas/ProfileContact.jsonld
https://raw.githubusercontent.com/ie4real/secyour-schemas/master/schemas/ProfileWork.json
https://raw.githubusercontent.com/ie4real/secyour-schemas/master/schemas/ProfileWork.jsonld
https://raw.githubusercontent.com/ie4real/secyour-schemas/master/schemas/ProfileGovernmentIds.json
https://raw.githubusercontent.com/ie4real/secyour-schemas/master/schemas/ProfileGovernmentIds.jsonld
https://raw.githubusercontent.com/ie4real/secyour-schemas/master/schemas/VerifiedHuman.json
https://raw.githubusercontent.com/ie4real/secyour-schemas/master/schemas/VerifiedHuman.jsonld
```

## PurchaseReceipt

Merchant-confirmed purchase attestation, issued by SecYour on behalf of an SP.
Design notes:

- `amountCents` is an **integer** so reward grantors can run ZK range queries
  ("amountCents >= 7000 AND productId == X") without seeing anything else.
- `orderRefHash = keccak256(orderRef ++ salt)` — the raw merchant order id
  never enters SecYour's DB or any credential; the salt lives in SecYour's
  `purchases` row so a claimed order id can be verified later.
- Refunds/chargebacks: the credential is **revoked** at the issuer; any later
  non-revocation proof fails. Reward grantors should delay release past the
  merchant's return window.
- Subscriptions: one receipt per billing period (`periodStart`/`periodEnd`).

Schemas are immutable once published — issued credentials reference them by
URL. To change a type, add a new version file (e.g. `PurchaseReceipt-v2.json`)
rather than editing in place.

## Profile credentials

`attestation` is set by the issuer (SecYour), never by the app: `self-declared` values were typed by the user; `partner-verified` were checked by a verification partner.
