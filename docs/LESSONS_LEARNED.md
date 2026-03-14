# Lessons Learned — Bioinformatics Pipeline Security Hardening

## Overview

This document captures the key security findings, mistakes made,
and insights gained while hardening this bioinformatics pipeline.
It is written to be honest about what went wrong, not just what
went right.

---

## 1. Container Image Pinning

### What I did
Replaced the version tag `biocontainers/fastqc:v0.11.9_cv7` with
the exact SHA256 digest of the image.

### What I learned
Version tags in Docker are mutable — a registry owner can push a
different image under the same tag at any time. This means that
`fastqc:v0.11.9_cv7` today is not guaranteed to be the same image
tomorrow. SHA256 digests are immutable: if the image changes by a
single byte, the digest changes and the pipeline fails instead of
running unknown code.

### Mistake I made
I initially used single quotes in the Nextflow script block:
`script: 'fastqc $reads'`
This caused a "reads: unbound variable" error because Groovy single
quotes are literal strings — variables are not interpolated.
Fix: use double quotes or triple double quotes `"""..."""`.

---

## 2. SBOM Generation

### What I did
Generated two SBOMs using Syft in SPDX JSON format:
- `sbom-repo.json` — components in the repository itself
- `sbom-fastqc-image.json` — 403 components inside the FastQC
  Docker image

### What I learned
Scanning only the repository filesystem gives an incomplete picture.
The real dependencies are inside the container — Java libraries,
system packages, bioinformatics tools. A repo-only SBOM would miss
403 components that could contain known CVEs.

### Mistake I made
The initial `.gitignore` had a pattern `sbom-*.json` that blocked
both SBOM files from being committed. I learned to always verify
`git status` after adding files — if nothing shows up in staging,
check the `.gitignore` before using `git add -f`.

---

## 3. GitHub Actions and CodeQL

### What I did
Removed CodeQL from the security workflow after it failed with
"no Python source code found".

### What I learned
CodeQL requires actual source code in the target language to
analyze. A Nextflow pipeline has no Python or JavaScript files —
applying CodeQL here was misconfigured from the start. The right
tools for a Nextflow pipeline are Trivy (container/dependency
scanning) and TruffleHog (secret detection). CodeQL belongs in
projects with application source code like the Bio API (P3).

---

## 4. Trivy Installation

### What I did
Installed Trivy using the modern keyring method instead of the
deprecated `apt-key` approach.

### What I learned
Ubuntu 22.04+ deprecates `apt-key`. The correct method uses
`/usr/share/keyrings/` with `gpg --dearmor`. This is a common
pattern for any third-party apt repository — the old method still
works but generates warnings and is being removed in future
releases.

### Mistake I made
The original command had `-q0` (zero) instead of `-qO` (capital O)
in the `wget` call. One character difference caused the entire
key installation to fail silently with "no valid OpenPGP data".

---

## 5. Secret Management

### What I did
Added `.env.example` documenting required environment variables
without exposing real values. Verified `.env` is blocked by
`.gitignore`. Configured TruffleHog in CI to scan every push.

### What I learned
The `.env.example` pattern serves two audiences: developers who
need to know what to configure, and security reviewers who need
to confirm no secrets are hardcoded. Having both `.env` in
`.gitignore` AND TruffleHog in CI is defense in depth —
`.gitignore` prevents accidents, TruffleHog catches what
`.gitignore` misses.

---

## 6. What I Would Do Differently

- **Start with the threat model.** I built the pipeline first and
  documented threats after. The right order is threat model first —
  it shapes what controls you build in, not bolt on.
- **Automate checksum verification.** Currently checksums are
  generated manually. A production pipeline should verify them
  automatically as the first step before processing any data.
- **Pin GitHub Actions to commit SHAs.** Using `@v4` is better
  than `@latest` but still mutable. The most secure approach is
  pinning to the exact commit SHA of each Action.

---

## References

- Nextflow DSL2 string interpolation:
  https://www.nextflow.io/docs/latest/script.html
- Docker image digest pinning:
  https://docs.docker.com/reference/cli/docker/image/pull/#pull-an-image-by-digest
- SPDX SBOM format:
  https://spdx.dev/use/specifications/
- TruffleHog documentation:
  https://github.com/trufflesecurity/trufflehog