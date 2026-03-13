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
both SBOM