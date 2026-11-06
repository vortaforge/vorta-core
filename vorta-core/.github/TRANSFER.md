# Transfer / Maintenance Note

This repository (and the organization) has **very high technical debt**.

- Estimated time to properly fix: could take 4 months or more
- Extremely high number of issues in security, CI, code quality, and architecture
- Current maintainer is stepping away from the project

New maintainer / owner:
- Accepts the project **as-is**
- All previous tokens, secrets, and permissions have been cleaned
- Full responsibility is transferred to the new owner

Date: 2026-10-11

## Status update (2026-10-29)

This file is retained as the dated handover record above. It is **not** a
current statement that the project is unmaintained: `vortaforge/core` has
active commits and pull requests after 2026-10-11. Check that repository's
recent history and open pull requests for the current maintenance state. The
technical-debt warning remains a useful caution, but individual claims in it
should be re-measured before being repeated as current facts.

## Handover preparation update (2026-10-29)

A new maintainer handover is being prepared, but it has **not** completed. The
preferred model is to keep `core` and this `.github` repository in the existing
`vortaforge` organization, promote an accepting successor to organization
Owner, verify billing, settings, releases, and credential custody with two
owners in place, and only then have the outgoing owner step down.

The operational runbook is `HANDOVER.md` in `vortaforge/core`. Earlier text in
this file saying that all previous tokens, secrets, and permissions had been
cleaned must not be treated as current proof: every token, App grant, deploy
key, environment reviewer, webhook, and organization/repository/environment
secret name must be inventoried again during this handover, and successor-owned
credentials should replace outgoing-owner credentials where practical.

Until a successor explicitly accepts and the completion checklist is recorded,
the current maintainer remains responsible and no contributor should be
described as the new owner.
