# lvgm-ethereum-governance

> **Layered Verifiable Governance Model (LVGM) — A Research Prototype for Ethereum**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Solidity](https://img.shields.io/badge/Solidity-%5E0.8.20-lightgrey)](https://docs.soliditylang.org/)
[![Built with Foundry](https://img.shields.io/badge/Built%20With-Foundry-orange)](https://book.getfoundry.sh/)
[![Status: Research Prototype](https://img.shields.io/badge/Status-Research%20Prototype-yellow)]()

---

## Overview

LVGM is a PhD-level research project that proposes a **Layered Verifiable Governance Model** for on-chain institutions
operating on Ethereum. It addresses the fundamental tension in decentralised governance between *immutability*
(safety guarantees) and *adaptability* (operational flexibility) by decomposing governance into three formally
distinct, composable layers.

The system is designed to be studied, extended, and evaluated against real-world DAO governance failures and
Ethereum protocol-upgrade scenarios. It is **not** a production-ready protocol — it is an executable research
artefact intended for academic review, adversarial testing, and formal analysis.

---

## Research Motivation

Decentralised governance on Ethereum suffers from well-documented structural problems:

| Problem | Manifestation |
|---|---|
| **Ruleset ambiguity** | Governance contracts mix invariant rules with mutable policies, making audits hard |
| **Authority creep** | Admin keys and multisigs accumulate unchecked override power over time |
| **Upgrade unsafety** | Protocol upgrades can silently violate invariants established at deployment |
| **Low accountability** | On-chain actions are traceable but rarely linked to a formal governance model |
| **Governance capture** | Concentrated token voting allows minority actors to override majority intent |

Existing work (Compound Governor, OpenZeppelin Governor, Aragon) provides useful primitives but does not
enforce a *layered separation* between what is immutable, what is policy-adjustable, and what requires
explicit authority delegation. LVGM addresses this gap.

---

## Core Concept — The Three Governance Layers

```
┌─────────────────────────────────────────────────────┐
│              AUTHORITY LAYER                        │
│   Bounded overrides · Role delegation · Emergency  │
│   AuthorityController.sol                          │
├─────────────────────────────────────────────────────┤
│              POLICY LAYER                           │
│   Adjustable parameters · Upgrade proposals        │
│   PolicyRegistry.sol                               │
├─────────────────────────────────────────────────────┤
│              CONSTRAINT LAYER                       │
│   Immutable invariants · Safety properties         │
│   ConstraintEngine.sol                             │
└─────────────────────────────────────────────────────┘
               coordinated by
          GovernanceKernel.sol
```

### Constraint Layer (`ConstraintEngine`)
- Encodes **immutable invariants** that must hold across all governance states.
- Examples: quorum floor, maximum single-actor power, veto rights.
- Cannot be modified after deployment without a new deployment and migration.
- Corresponds to the *constitutional* level of governance.

### Policy Layer (`PolicyRegistry`)
- Encodes **adjustable governance parameters** subject to standard proposal processes.
- Examples: voting period, proposal threshold, reward rates.
- Modifications require passing through the constraint layer's safety checks.
- Corresponds to the *legislative* level of governance.

### Authority Layer (`AuthorityController`)
- Manages **role-based bounded overrides** for emergency and operational exceptions.
- All override actions are time-bounded, logged, and subject to constraint checks.
- Prevents unbounded admin power by design.
- Corresponds to the *executive* level of governance.

---

## Architecture Overview

LVGM follows a **clean architecture** pattern adapted for smart-contract research:

```
lvgm-ethereum-governance/
├── src/
│   ├── domain/            # Core rules, invariants, types (no Solidity dependencies)
│   │   ├── interfaces/    # IGovernanceAction, IConstraint, IPolicy, IAuthority
│   │   ├── types/         # GovernanceTypes.sol (structs, enums, errors)
│   │   └── invariants/    # GovernanceInvariants.sol (pure verification logic)
│   ├── application/       # Use-case orchestration
│   │   ├── interfaces/    # IGovernanceKernel, IPolicyUseCase, IAuthorityUseCase
│   │   └── usecases/      # Thin wrappers coordinating domain + infrastructure
│   └── infrastructure/    # Concrete Solidity implementations
│       ├── contracts/     # GovernanceKernel, ConstraintEngine, PolicyRegistry, AuthorityController
│       └── adapters/      # External integrations (token voting, timelock, etc.)
├── test/
│   ├── unit/              # Isolated contract unit tests
│   ├── integration/       # End-to-end governance workflow tests
│   ├── invariants/        # Foundry invariant test handlers
│   └── fuzz/              # Fuzz tests for adversarial inputs
├── script/                # Foundry deployment and interaction scripts
├── docs/
│   ├── overview/          # Architecture, roadmap
│   ├── domain/            # Formal model, invariant catalogue
│   └── research/          # Methodology, related work, evaluation
└── experiments/
    └── simulations/       # DAO scenario simulations and evaluation data
```

---

## Smart Contract Modules

| Contract | Layer | Responsibility |
|---|---|---|
| `GovernanceKernel.sol` | Infrastructure | Central coordinator; routes actions through constraint → policy → authority pipeline |
| `ConstraintEngine.sol` | Infrastructure | Enforces immutable invariants; rejects any action violating constitutional rules |
| `PolicyRegistry.sol` | Infrastructure | Stores and updates adjustable governance parameters via proposal process |
| `AuthorityController.sol` | Infrastructure | Manages roles, delegation, and time-bounded emergency overrides |

All contracts implement domain-layer interfaces defined in `src/domain/interfaces/`, ensuring the infrastructure
is swappable and the domain logic is independently testable.

---

## Testing Strategy

```
test/
├── unit/
│   ├── GovernanceKernelTest.t.sol      # Action routing, constraint rejection
│   └── AuthorityControllerTest.t.sol   # Role assignment, override bounds
├── integration/
│   └── GovernanceWorkflowTest.t.sol    # Full proposal → vote → execute flow
├── invariants/
│   └── GovernanceInvariantTest.t.sol   # Foundry invariant handler: safety properties
└── fuzz/
    └── FuzzGovernanceInputs.t.sol      # Adversarial parameter fuzzing
```

**Unit tests** verify that each contract behaves correctly in isolation, with both positive and negative cases.

**Integration tests** simulate a complete governance workflow: proposal submission, constraint validation, policy
update, and execution — verifying correct event emission at each step.

**Invariant tests** use Foundry's stateful fuzzing to assert that global safety properties (e.g., quorum floor
always respected, no unauthorised override succeeds) hold across arbitrary state sequences.

**Fuzz tests** send random, boundary, and adversarial inputs to critical functions to surface edge-case failures.

---

## Evaluation and Experiments

Located in `experiments/simulations/`, the evaluation layer applies LVGM to three governance scenarios:

1. **Baseline DAO** — Simulates a standard token-vote DAO without LVGM; used to establish failure baselines.
2. **LVGM-protected DAO** — Identical scenario with LVGM constraints active; measures invariant preservation.
3. **Adversarial Scenario** — Simulates governance capture attempts; measures authority-layer resistance.

**Evaluation Metrics**

| Metric | Description |
|---|---|
| Transparency | Proportion of governance actions with full on-chain audit trail |
| Accountability | Ratio of actions attributable to a bounded authority role |
| Upgrade Safety | Rate at which upgrades pass constraint checks without manual review |
| Efficiency | Average blocks from proposal submission to execution |
| Invariant Preservation | Percentage of state transitions that satisfy all invariants |

---

## Roadmap

| Milestone | Target | Deliverable |
|---|---|---|
| M1 — Foundation | Month 1–2 | Formal model, domain interfaces, folder structure, initial contracts |
| M2 — Core Implementation | Month 3–4 | Full contract suite, Foundry tests (unit + invariant), CI pipeline |
| M3 — Formal Verification | Month 5–6 | Certora/Halmos specs for ConstraintEngine and AuthorityController |
| M4 — Scenario Evaluation | Month 7–8 | Three-scenario simulation suite, evaluation metrics dashboard |
| M5 — Research Paper Draft | Month 9–10 | Academic paper draft: motivation, model, implementation, results |
| M6 — Public Release | Month 11–12 | Audited prototype, public repository, Ethereum Foundation report |

---

## Why This Benefits the Ethereum Ecosystem

- **Protocol Governance**: LVGM's constraint/policy separation maps directly onto Ethereum protocol upgrade
  governance, where immutable safety properties must coexist with adaptable parameters (e.g., gas limits, EIP
  activation thresholds).
- **DAO Safety**: Provides a reusable, formally grounded governance framework that DAO developers can adapt
  to prevent governance capture and unsafe upgrades.
- **Research Baseline**: Creates an open, executable reference model for Ethereum governance research,
  reducing the effort required to build comparable systems for academic study.
- **Accountability Infrastructure**: The authority-layer design directly addresses the "admin key problem"
  affecting many DeFi protocols — offering a bounded, auditable alternative.

---

## Getting Started

```bash
# Install Foundry (https://book.getfoundry.sh/getting-started/installation)
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Clone and build
git clone https://github.com/dr-saeed-asif/lvgm-ethereum-governance
cd lvgm-ethereum-governance
forge install
forge build

# Run tests
forge test

# Run with verbosity for research analysis
forge test -vvv

# Run invariant + fuzz tests (CI profile)
FOUNDRY_PROFILE=ci forge test
```

---

## Development Status Disclaimer

> **This repository is a research prototype in active development.**
>
> LVGM contracts are designed for academic study, evaluation, and adversarial testing. They have **not** been
> audited and are **not** suitable for production deployment or management of real funds. The architecture and
> interfaces are subject to change as the research evolves.
>
> Contributions, critiques, and peer review are welcome. Please open an issue or discussion for substantive
> feedback.

---

## License

[MIT](LICENSE) — Research use encouraged. Attribution appreciated.

---

*LVGM — Layered Verifiable Governance Model · Ethereum Governance Research · 2024–2025*
