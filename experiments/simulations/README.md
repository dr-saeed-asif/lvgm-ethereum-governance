# Simulations and Evaluation

## Purpose

This directory contains scenario definitions and outputs for evaluating LVGM governance behavior under normal and adversarial conditions.

## Simulation Objectives

- validate safety properties under repeated governance transitions;
- measure policy adaptability without violating hard constraints;
- evaluate behavior of bounded override paths in stress conditions.

## Scenario Categories

### Baseline Governance Workflow
- proposal/action execution by authorized operators;
- policy adjustments within admissible ranges.

### Authority Abuse Attempts
- unauthorized override requests;
- unauthorized policy mutation and replay attempts.

### Constraint Stress Cases
- policy updates at or beyond boundary values;
- rapid sequence updates testing transition resilience.

## Metrics Captured

- successful vs rejected governance actions;
- invariant violation attempts prevented;
- event trace completeness for audit reconstruction;
- gas and execution overhead of layered checks.

## Expected Outputs

- scenario run logs;
- metric summaries by scenario class;
- comparative interpretation notes for research reporting.

## Link to Implementation

Simulation assumptions should align with:
- contracts in `src/infrastructure/contracts/`;
- tests in `test/`;
- formal assumptions in `docs/domain/formal-model.md`.
