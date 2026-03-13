# Hardening Checklist — Bioinformatics Pipeline Security Hardening

Last updated: March 2026
Status: v0.5.0 — Core hardening complete, documentation in progress

---

## Container Security

| Status | Control | Implementation | Commit |
|--------|---------|---------------|--------|
| ✅ | Pin container images to exact SHA256 digest | `biocontainers/fastqc@sha256:8ff2a7...` in `main.nf` | `security(docker): pin FastQC image...` |
| ✅ | Drop all Linux capabilities | `--cap-drop ALL` in `nextflow.config` | initial config |
| ✅ | Run container as non-root user | `--user $(id -u):$(id -g)` in `nextflow.config` | initial config |
| ⬜ | Enable read-only filesystem | `--read-only` flag — pending | — |
| ⬜ | Scan container image for CVEs | Trivy image scan — pending local verification | — |

---

## Secret Management

| Status | Control | Implementation | Commit |
|--------|---------|---------------|--------|
| ✅ | No hardcoded credentials in codebase | Verified — all secrets via env vars | — |
| ✅ | `.env` excluded from version control | `.gitignore` rule active | initial .gitignore |
| ✅ | `.env.example` documents required variables | File present in repo root | `docs(config): add .env.example...` |
| ✅ | Secret scanning on every push | TruffleHog via GitHub Actions | `ci(actions): add security pipeline...` |

---

## Input Data Integrity

| Status | Control | Implementation | Commit |
|--------|---------|---------------|--------|
| ✅ | SHA256 checksums for input files | `data/mock/checksums.sha256` | `security(integrity): add SHA256...` |
| ✅ | Block genomic data formats in `.gitignore` | `.fastq`, `.bam`, `.vcf`, etc. excluded | initial .gitignore |
| ✅ | Use only mock/synthetic data in repo | `data/mock/sample1.fastq.gz` is synthetic | — |
| ⬜ | Automate checksum verification in pipeline | Add verification step to `main.nf` — pending | — |

---

## CI/CD Security

| Status | Control | Implementation | Commit |
|--------|---------|---------------|--------|
| ✅ | Vulnerability scanning on every push | Trivy filesystem scan via GitHub Actions | `ci(actions): add security pipeline...` |
| ✅ | Secret detection on every push | TruffleHog via GitHub Actions | `ci(actions): add security pipeline...` |
| ⬜ | Pin GitHub Actions to exact commit SHA | Currently pinned to version tags only | — |
| ⬜ | Add branch protection rules on `main` | Require PR + status checks — pending | — |

---

## Supply Chain

| Status | Control | Implementation | Commit |
|--------|---------|---------------|--------|
| ✅ | SBOM generated for repository | `sbom-repo.json` (SPDX format, Syft) | `security(sbom): add SPDX SBOM...` |
| ✅ | SBOM generated for container image | `sbom-fastqc-image.json` (403 components) | `security(sbom): add SPDX SBOM...` |
| ⬜ | Automate SBOM generation in CI/CD | Add Syft step to GitHub Actions — pending | — |
| ⬜ | Dependabot alerts enabled | Activate in repo Settings → Security | — |

---

## Documentation

| Status | Control | Implementation | Commit |
|--------|---------|---------------|--------|
| ✅ | STRIDE threat model documented | `docs/THREAT_MODEL.md` | `docs(threat-model): add STRIDE...` |
| ✅ | Vulnerability reporting policy | `SECURITY.md` in repo root | `docs(security): add vulnerability...` |
| ✅ | License defined | `LICENSE` (MIT 2026) | — |
| ⬜ | Lessons learned documented | `docs/LESSONS_LEARNED.md` — pending | — |

---

## Legend
- ✅ Implemented and verified
- ⬜ Identified, not yet implemented
- ❌ Descoped — not applicable to this project