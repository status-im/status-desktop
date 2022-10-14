# Implement historical balance

Task [#7662](https://github.com/status-im/status-desktop/issues/7662)

## Summary

User story: as a user I want to see the historical balance of a specific token in the Asset view Balance tab

UI design [Figma](https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?node-id=6770%3A76490)

## Considerations

Technical requirements

- New UI View
  - Time interval tabs
    - [ ] Save last selected tab? Which is the default?
      - The price history uses All Time as default
  - Show the graph for the selected tab
- New Controller fetch API entry and async Response
- `status-go` API call to fetch token historical balance

### Assumptions

Data source

- The balance history is unique for each address and token.
- It is represented by the blockchain transactions (in/out) for a specific address and token
- The original data resides in blocks on blockchain as transactions
- Direct data fetch is not possible so using infura APIs that caches the data is the alternative
- We already fetch part of the data when displaying `Activity` as a list of transactions
- Constructing the data forward (from the block 0) is not practical.
  - Given that we have to show increasing period of activity starting from 1H to All time best is to fetch the data backwards
  - Start going from current balance to the past and inverse the operations while going back
  - Q
    - [ ] What information do we get with each transaction request?

Caching the data

- It is a requirement to reduce the number of requests and improve future performance
- Q
  - [ ] How do we match the data points not to duplicate?
    - [ ] What unique key should we use as primary key in the `balance_cache` DB?
      - How about `chainID` + `address` + `token`?
    - [x] Is our sqlite DB the best time series data store we have at hand?
      - Yes, great integration
    - [x] Do we adjust the data points later on or just add forever?
      - For start we just add. We might prune old data later on based on age and granularity
  - [ ] What do we already cache with transaction history API?
  - [x] What granularity do we cache?
    - All we fetch for now. Can't see yet how to manage gaps beside the current merging blocks implementation
  - [x] What is the cache eviction policy?
    - None yet, always growing. Can't see concerns of cache size yet due to scarce transactions for regular users
    - Can be done later as an optimization

View

- Q
  - [ ] How do we represent data? Each transaction is a point and interpolate in between?
  - [x] Are "Overview" and "Activity" tabs affected somehow?
    - It seems not, quite isolated and no plan to update transactions for now. Can be done later as an optimization

### Dependencies

Infura API

### Constraints

- Data points granularity should be optimal
  - In theory it doesn't make sense to show more than 1 data point per pixel
  - In practice it make no sense to show more than 1 data point per few pixels
  - Q
    - [ ] What is the optimal granularity? Time range based?
    - [ ] How do we prune the data points to match the optimal granularity? Do we need this in practice? Can we just show all the data points?
    - [ ] How about having 10  transactions in a day and showing the ALL time plot
- Q
  - [ ] What is the interval for Showing All Time case? Starting from the first transaction? Or from the first block?
    - It seems the current price history start from 2010

## Development

Data scattered in `transfers` DB table and `balanceCache`

Q:

- [ ] Unify it, update? Is there a relation in between these two sources?
- [ ] How to fill the gaps?

### Reference

Token historical price PRs

- status-desktop [#7599](https://github.com/status-im/status-desktop/pull/7599/files)
  - See `TokenMarketValuesStore` for converting from raw data to QML friendly JS data: `ui/imports/shared/stores/TokenMarketValuesStore.qml`
- status-go [#2882](https://github.com/status-im/status-go/pull/2882/files)

Building blocks

- status-go
  - Transaction history, common data: `CheckRecentHistory` - `services/wallet/transfer/controller.go`
    - setup a running task that fetches balances for chainIDs and accounts
    - caches balances in memory see `balanceCache`
    - Q
      - [x] Queries block ranges?
        - Retrieve all "old" block ranges (from block - to block) in table `blocks_ranges` to match the specified network and address. Also order by block from
          - See `BlocksRange {from, to *big.Int}` - `services/wallet/transfer/block.go`
        - Merge them in continuous blocks simplifying the ranges
          - See `TestGetNewRanges` - `services/wallet/transfer/block_test.go`
        - Deletes the simplified and add new ranges to the table
      - [x] When are block ranges fragmented?
        - `setInitialBlocksRange` for all the accounts and watched addresses added initially from block 0 to latest - `services/wallet/transfer/block.go`
          - Q:
            - [ ] What does latest means? Latest block in the chain?
          - `eth_getBlockByNumber` in `HeaderByNumber` - `services/wallet/chain/client.go`
        - Event `EventFetchingRecentHistory` processes the history and updates the block ranges via `ProcessBlocks`-> `upsertRange` - `services/wallet/transfer/commands.go`
      - [x] Reactor loops?
        - Reactor listens to new blocks and stores transfers into the database.
        - `ERC20TransfersDownloader`, `ETHDownloader`
        - Updates **in memory cache of balances** maps (an address to a map of a block number and the balance of this particular address)
          - `balanceCache` - `services/wallet/transfer/balance_cache.go`
      - [x] Why `watchAccountsChanges`?
        - To update the reactor when list of accounts is updated (added/removed)
      - [ ] How do we identify a balance cache entry?
- NIM
- QML
  - `RootStore` - `ui/imports/shared/stores/RootStore.qml`
    - Entry point for accessing underlying NIM model
  - `RightTabView` - `ui/app/AppLayouts/Wallet/views/RightTabView.qml`
    - Contains the "Asset" tab from which user selects the token to see history for
  - StatusQ's `StatusChartPanel` - `ui/StatusQ/src/StatusQ/Components/StatusChartPanel.qml`
    - `Chart` - `ui/StatusQ/src/StatusQ/Components/private/chart/Chart.qml`
      - Canvas based drawing using `Chart.js`
  - `HistoryView` calls `RootStore.getTransfersByAddress` to retrieve list of transfers which are delivered as async signals
    - `getTransfersByAddress` will call `status-go`'s `GetTransfersByAddress` which will update `blocks` and `transfers` DB tables
      - Q:
        - [ ] How is this overlapping with the check recent history?

### TODO

- [x] New `status-go` API to fetch balance history from existing cache using rules (granularity, time range)
  - ~~In the meantime use fetch transactions to populate the cache for testing purposes~~
    - This doesn't work because of the internal transactions that don't show up in the transaction history
- [ ] Sample blocks using `eth_getBalance`
- [ ] Extend Controller to Expose balance history API
- [ ] Implement UI View to use the new API and display the graph of existing data
- [ ] Extend `status-go`
  - [ ] Control fetching of new balances for history purpose
  - [ ] Premature optimization?
    - DB cache eviction policy
    - DB cache granularity control
- [ ] Add balance cache DB and sync it with in memory cache
  - [ ] Retrieve from the DB if missing exists optimization
- [ ] Extend UI View with controls for time range