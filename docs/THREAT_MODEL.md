# Threat Model — Bioinformatics Pipeline Security Hardening

## 1. System Overview

This pipeline performs genomic variant calling on FASTQ input files
using FastQC for quality control, running inside Docker containers
orchestrated by Nextflow.

**Components:**
- Input data (FASTQ files from local filesystem)
- Nextflow workflow engine
- Docker containers (FastQC image)
- GitHub Actions CI/CD
- Output results (HTML/ZIP reports)

**Data flow:**
```
[FASTQ files] → [Nextflow] → [FastQC container] → [Results]
```

## 2. Threat Analysis (STRIDE)

### Component: Docker Container Image

| STRIDE | Threat | Likelihood | Impact | Risk |
|--------|--------|-----------|--------|------|
| **Spoofing** | Attacker replaces container image in registry with malicious version | Medium | Critical | HIGH |
| **Tampering** | Container image modified after pull, before execution | Low | Critical | MEDIUM |
| **Info Disclosure** | Container runs as root, exposing host filesystem | Medium | High | HIGH |
| **Elevation of Privilege** | Container escapes to host via misconfiguration | Low | Critical | HIGH |

**Mitigations applied:**
- Pinned image to exact SHA256 digest — image substitution is detectable
- `--cap-drop ALL` in Docker run options — removes all Linux capabilities
- `--user $(id -u):$(id -g)` — container runs as current user, not root

---

### Component: Input Data (FASTQ files)

| STRIDE | Threat | Likelihood | Impact | Risk |
|--------|--------|-----------|--------|------|
| **Tampering** | Input files modified before pipeline execution | Low | High | MEDIUM |
| **Repudiation** | No record of which data version was analyzed | Medium | Medium | MEDIUM |
| **Info Disclosure** | Real patient genomic data accidentally committed to repo | Medium | Critical | HIGH |

**Mitigations applied:**
- SHA256 checksums generated for all input files
- Only mock/synthetic data used in this repo
- `.gitignore` blocks all genomic file formats (`.fastq`, `.bam`, `.vcf`)

---

### Component: CI/CD Pipeline (GitHub Actions)

| STRIDE | Threat | Likelihood | Impact | Risk |
|--------|--------|-----------|--------|------|
| **Tampering** | Malicious code injected via compromised GitHub Action | Medium | Critical | HIGH |
| **Info Disclosure** | Secrets exposed in workflow logs | Low | Critical | HIGH |
| **Spoofing** | Attacker uses similar-named Action (typosquatting) | Low | High | MEDIUM |

**Mitigations applied:**
- Actions pinned to specific versions (`@v4`, `@master`)
- TruffleHog scans every push for exposed secrets
- No secrets stored in workflow files — `.env` is gitignored

---

### Component: Nextflow Secrets and Configuration

| STRIDE | Threat | Likelihood | Impact | Risk |
|--------|--------|-----------|--------|------|
| **Info Disclosure** | API keys or credentials hardcoded in `.nf` or `.config` files | Medium | High | HIGH |
| **Repudiation** | No audit trail of pipeline executions | Medium | Low | LOW |

**Mitigations applied:**
- All credentials managed via environment variables
- `.env.example` documents required variables without exposing values
- `git-secrets` configured to block credential commits

---

## 3. Risk Summary

| Risk Level | Count | Components |
|-----------|-------|-----------|
| HIGH | 5 | Container image, input data privacy, CI/CD injection |
| MEDIUM | 3 | Image tampering, data integrity, Action typosquatting |
| LOW | 1 | Execution audit trail |

## 4. Residual Risks (accepted, not mitigated)

- **No runtime monitoring:** container behavior during execution is not
  monitored. Acceptable for a local research pipeline.
- **No network isolation:** containers have outbound internet access.
  Acceptable for public tool images with verified digests.

## 5. References

- STRIDE methodology: https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats
- Docker security: https://docs.docker.com/engine/security/
- Nextflow secrets: https://www.nextflow.io/docs/latest/secrets.html