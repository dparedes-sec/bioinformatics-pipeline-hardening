# Bioinformatics Pipeline Security Hardening

![Security Pipeline](https://github.com/dparedes-sec/bioinformatics-pipeline-hardening/actions/workflows/security.yml/badge.svg)

> Applying supply-chain security principles to a genomic quality control
> pipeline using Nextflow + Docker. Built as part of a cybersecurity
> portfolio focused on the intersection of DevSecOps and bioinformatics.

---

## Overview

This project demonstrates security hardening of a bioinformatics pipeline
that performs quality control (FastQC) on genomic FASTQ input files.

The focus is not on the biology — it is on securing every layer of the
pipeline: the container images, the input data, the CI/CD workflow, and
the secrets management.

---

## Security Controls Applied

| Control | Tool | Status |
|---------|------|--------|
| Container image pinned to SHA256 digest | Docker | ✅ Active |
| Drop all Linux capabilities | Docker (`--cap-drop ALL`) | ✅ Active |
| Non-root container execution | Docker (`--user`) | ✅ Active |
| Secret detection on every push | TruffleHog (GitHub Actions) | ✅ Active |
| Dependency & config vulnerability scan | Trivy (GitHub Actions) | ✅ Active |
| Automated dependency updates | Dependabot | ✅ Active |
| SBOM — repository components | Syft (SPDX format) | ✅ Generated |
| SBOM — container image (403 components) | Syft (SPDX format) | ✅ Generated |
| Input data integrity verification | SHA256 checksums | ✅ Active |
| No credentials in codebase | git-secrets + TruffleHog | ✅ Verified |

---

## Threat Model

Full STRIDE analysis covering:
- Docker container image (spoofing, tampering, privilege escalation)
- Input data integrity (tampering, information disclosure)
- CI/CD pipeline (injection, secret exposure)
- Secrets and configuration management

→ See [docs/THREAT_MODEL.md](docs/THREAT_MODEL.md)

---

## Project Structure
```
bioinformatics-pipeline-hardening/
├── .github/
│   └── workflows/
│       ├── security.yml          # Trivy + TruffleHog on every push
│       └── dependabot.yml        # Automated dependency updates
├── data/
│   └── mock/
│       ├── sample1.fastq.gz      # Synthetic data for testing
│       └── checksums.sha256      # SHA256 integrity verification
├── docs/
│   ├── THREAT_MODEL.md           # STRIDE analysis
│   ├── HARDENING_CHECKLIST.md    # Security controls status
│   └── LESSONS_LEARNED.md        # Mistakes made and insights gained
├── sbom-repo.json                # SBOM — repository (SPDX)
├── sbom-fastqc-image.json        # SBOM — FastQC container (403 components)
├── main.nf                       # Nextflow pipeline (DSL2)
├── nextflow.config               # Docker profile configuration
├── .env.example                  # Required environment variables
├── .gitignore
├── SECURITY.md                   # Vulnerability reporting policy
├── LICENSE                       # MIT 2026
└── README.md
```
---

## Running the Pipeline

**Requirements:**
- WSL2 (Ubuntu) or Linux
- Nextflow 23+
- Docker Desktop (with WSL2 integration enabled)

**Setup:**
```bash
git clone https://github.com/dparedes-sec/bioinformatics-pipeline-hardening
cd bioinformatics-pipeline-hardening

# Verify input data integrity before running
cd data/mock && sha256sum --check checksums.sha256 && cd ../..

# Run the pipeline
nextflow run main.nf -profile docker
```

**Results** will be saved to `results/fastqc/`.

---

## Security Documentation

| Document | Description |
|----------|-------------|
| [THREAT_MODEL.md](docs/THREAT_MODEL.md) | STRIDE analysis for all pipeline components |
| [HARDENING_CHECKLIST.md](docs/HARDENING_CHECKLIST.md) | Security controls with implementation status |
| [LESSONS_LEARNED.md](docs/LESSONS_LEARNED.md) | Mistakes made and insights gained |
| [SECURITY.md](SECURITY.md) | How to report vulnerabilities |

---

## SBOM

Two Software Bill of Materials files are included in SPDX JSON format:

- **`sbom-repo.json`** — GitHub Actions and repository-level components
- **`sbom-fastqc-image.json`** — 403 components inside the FastQC
  Docker container (Java libraries, system packages, bioinformatics tools)

Generated with [Syft](https://github.com/anchore/syft).

---

## Tech Stack

![Nextflow](https://img.shields.io/badge/Nextflow-0DC09D?style=flat&logo=nextflow&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat&logo=linux&logoColor=black)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=flat&logo=github-actions&logoColor=white)

---

## Author

**Daniel Paredes**
Developer transitioning into Cybersecurity | DevSecOps | OWASP

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?style=flat&logo=linkedin&logoColor=white)](https://linkedin.com/in/tu-perfil)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white)](https://github.com/dparedes-sec)