# Sqlidity

Simplified sqlite3 implementation on-chain written in Solidity.

# Why?

Sqlidity is part of an experiment to merge the world of classic databases and blockchains.

Blockchain *is* a database but it is hardly used as a classic database. With strange account-storage trees, 32-byte slots and niche languages to access and manipulate them, the friction of using such database as an actual database is very high.

Ideally one key benefit this technological improvement will allow is to easily on-board the 20 million web2 developers such that the transition is seamless, while inheriting web3 properties such as security, accessibility, liveness, integrated finance, etc.

# How?

There are several approaches to bring classic databases on chain.

`Sqlidity` aims to implement SQLite databases on EVM chains, starting as a Solidity smart contract.

SQLite is a perfect candidate for initial proof of concept:
- synchronous, no multiprocess / multithreaded access (just like EVM blockchains)
- built-in rollbacks (simply revert the transaction)
- aimed towards small-mid sized databases
- simple structure

See [opcodes.md](./opcodes.md) to see implementation progress.

# Different Approaches

Several frameworks have taken different approaches to bringing the worlds of databases and blockchains together.

- [TheGraph](https://thegraph.com/docs/en/network/indexing/) is a blockchain indexing network anyone can participate in. Indexing and querying happens off-chain.
- [Dune Analytics](https://dune.com/) is the largest off-chain index service and can be queries with PostgreSQL.
- [Tableland](https://docs.tableland.xyz/creating-tables-from-contracts) implement a query oracle that can be instantiated on-chain. Query strings are built on chain and emitted as an event to be executed by the oracle off-chain.
- [BigchainDB](https://www.bigchaindb.com/) is an experiment to bring blockchain to databases, rather than bring databases to blockchain. It seems inactive, but is one interesting approaching the Sqlidity experiment is interested in.
- [MUD](https://mud.dev/) engine by [@latticexyz](https://twitter.com/latticexyz) is building data querying on-chain.

# Roadmap

The future of on-chain SQL (and databases in general) is unknown, but I believe it has a bright future.

1. Table database smart contract (SQLite)  **<== we are here - PoC ready**
2. Production deployed to mainnet, optimistic and ZK rollups
3. Implement as a whole new rollup
4. Add ZK proofs to new rollup
5. Implement on cosmos ecosystem as L0 or whatever

