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
| `Passport` | `schemas/Passport.json` | `schemas/Passport.jsonld` |
| `DrivingLicence` | `schemas/DrivingLicence.json` | `schemas/DrivingLicence.jsonld` |
| `ProofOfAddress` | `schemas/ProofOfAddress.json` | `schemas/ProofOfAddress.jsonld` |

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
https://raw.githubusercontent.com/ie4real/secyour-schemas/master/schemas/Passport.json
https://raw.githubusercontent.com/ie4real/secyour-schemas/master/schemas/Passport.jsonld
https://raw.githubusercontent.com/ie4real/secyour-schemas/master/schemas/DrivingLicence.json
https://raw.githubusercontent.com/ie4real/secyour-schemas/master/schemas/DrivingLicence.jsonld
https://raw.githubusercontent.com/ie4real/secyour-schemas/master/schemas/ProofOfAddress.json
https://raw.githubusercontent.com/ie4real/secyour-schemas/master/schemas/ProofOfAddress.jsonld
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

## Passport

Partner-checked passport. Claims: `attestation`, `givenName`, `familyName`,
`birthday`, `nationality`, `issuingCountry`, `documentNumber`, `issuedAt`
(optional), `expiresOn`, `checkedAt`, `scanHashHi`, `scanHashLo`,
`portraitHashHi`, `portraitHashLo`. Expiry of the credential = document expiry
(`expiresOn`). `attestation` is `chip-verified` only when the chip was read and
its signature verified, otherwise `partner-verified`.

- Countries are ISO 3166-1 alpha-3, uppercase; dates are yyyymmdd integers (UTC).
- Each image hash is a SHA-256 split into two strings of 32 lower-case hex
  characters (`...Hi` first half, `...Lo` second half). Strings, not integers,
  because a 128-bit number does not survive JSON number handling.

## DrivingLicence

Partner-checked driving licence. Required claims: `attestation`, `givenName`,
`familyName`, `birthday`, `documentNumber`, `issuingCountry`, `expiresOn`,
`checkedAt`, `frontHashHi`, `frontHashLo`, `portraitHashHi`, `portraitHashLo`.
Optional claims: `issuedAt`, `issuingAuthority` (for example RSA or a US state
DMV), the address parts `street`, `city`, `region`, `postalCode`,
`addressCountry` (only licences that print an address), `sex` (`M`, `F` or `X`,
omitted when unknown), `categories` (comma-separated, upper case, for example
`AM,B,BE`), `heightCm`, `weightKg` (integers), `eyeColour`, and
`backHashHi`, `backHashLo` (single-sided licences have no back).
Expiry of the credential = document expiry (`expiresOn`), set by the issuer.
`attestation` is `partner-verified`.

- Countries are ISO 3166-1 alpha-3, uppercase; dates are yyyymmdd integers (UTC).
- Each image hash is a SHA-256 split into two strings of 32 lower-case hex
  characters (`...Hi` first half, `...Lo` second half), as in `Passport`.

## ProofOfAddress

Partner-checked proof of address. Required claims: `attestation`, `givenName`,
`familyName`, `documentType` (`utility_bill`, `bank_statement`, `government` or
`other`), `documentIssuer` (for example Electric Ireland), `issuedAt` (the
document's date), `street`, `city`, `addressCountry`, `checkedAt`,
`scanHashHi`, `scanHashLo`. Optional claims: `region`, `postalCode`.
The address is split into parts so a verifier can ask only what it needs (for
example `addressCountry = IRL`). There is no expiry claim. `attestation` is
`partner-verified`.

- The issuer of the document is `documentIssuer`, not `issuer`: a claim named
  `issuer` clashes with the protected `issuer` term of the W3C credentials
  context and breaks JSON-LD expansion.
- `addressCountry` is ISO 3166-1 alpha-3, uppercase; dates are yyyymmdd
  integers (UTC); the scan hash is split as in `Passport`.
