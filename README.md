# Sqlidity

SQL on chain

# Why?

Blockchain is a database but it is hardly used as a classic database. With strange account-storage trees, 32-byte slots and niche languages the friction of using such database as an actual database is very high.

Imagine you could easily on-board the 20 million web2 developers such that the transition is seamless, while inheriting web3 properties such as security, accessibility, liveness, integrated finance, etc.

# How?

There are several approaches to bring classic databases on chain.

`Sqlidity` aims to implement SQLite databases on EVM chains, starting as a Solidity smart contract.

SQLite is a perfect candidate for initial proof of concept:
- synchronous, no multiprocess / multithreaded access (just like EVM blockchains)
- built-in rollbacks (simply revert the transaction)
- aimed towards small-mid sized databases
- simple structure

# Roadmap

The future of on-chain SQL (and databases in general) is unknown, but I believe it has a bright future.

1. Table database smart contract (SQLite)
2. Production deployed to mainnet, optimistic and ZK rollups
3. Implement as a whole new rollup
4. Add ZK proofs to new rollup
5. Implement on cosmos ecosystem as L0 or whatever

