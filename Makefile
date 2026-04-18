.PHONY: help install build test test-unit test-integration test-invariant test-fuzz fmt fmt-check clean snapshot anvil deploy-local deploy-sepolia check

help:
	@echo "LVGM research/dev commands"
	@echo "  make install          - install Foundry stdlib"
	@echo "  make build            - compile contracts"
	@echo "  make test             - run all tests"
	@echo "  make test-unit        - run unit tests only"
	@echo "  make test-integration - run integration tests only"
	@echo "  make test-invariant   - run invariant tests only"
	@echo "  make test-fuzz        - run fuzz tests only"
	@echo "  make fmt              - format Solidity code"
	@echo "  make fmt-check        - check formatting"
	@echo "  make snapshot         - gas snapshot"
	@echo "  make anvil            - start local node"
	@echo "  make deploy-local     - deploy to local anvil"
	@echo "  make deploy-sepolia   - deploy to sepolia (env required)"
	@echo "  make check            - format check + build + tests"

install:
	forge install foundry-rs/forge-std --no-commit

build:
	forge build

test:
	forge test -vv

test-unit:
	forge test --match-path "test/unit/*.t.sol" -vv

test-integration:
	forge test --match-path "test/integration/*.t.sol" -vv

test-invariant:
	forge test --match-path "test/invariants/*.t.sol" -vv

test-fuzz:
	forge test --match-path "test/fuzz/*.t.sol" -vv

fmt:
	forge fmt

fmt-check:
	forge fmt --check

snapshot:
	forge snapshot

anvil:
	anvil

deploy-local:
	forge script script/DeployLVGM.s.sol:DeployLVGM --rpc-url http://127.0.0.1:8545 --broadcast -vvv

deploy-sepolia:
	forge script script/DeployLVGM.s.sol:DeployLVGM --rpc-url $$SEPOLIA_RPC_URL --broadcast --verify -vvv

check: fmt-check build test

clean:
	forge clean
