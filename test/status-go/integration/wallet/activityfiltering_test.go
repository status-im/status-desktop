// These tests are for development only to be run manually
// There is more work needed to automate them not to depend on an existing account and internet connection

package wallet

import (
	"testing"
	"time"

	"github.com/stretchr/testify/require"

	"github.com/status-im/status-desktop/test/status-go/integration/helpers"

	"github.com/status-im/status-go/eth-node/types"
	"github.com/status-im/status-go/services/wallet/activity"
	"github.com/status-im/status-go/services/wallet/common"
	"github.com/status-im/status-go/services/wallet/walletevent"
	"github.com/status-im/status-go/transactions"
)

// TestActivityIncrementalUpdates_NoFilterNewPendingTransactions tests that a pending transaction is created, then updated and finally deleted.
func TestActivityIncrementalUpdates_NoFilterNewPendingTransactions(t *testing.T) {
	td, close := setupAccountsAndTransactions(t)
	defer close()

	_, err := helpers.CallPrivateMethod("wallet_startActivityFilterSession", []interface{}{[]types.Address{td.sender.Address}, false, []common.ChainID{5}, activity.Filter{}, 3})
	require.NoError(t, err)

	// Confirm async filtering results
	filterRes, err := helpers.WaitForWalletEvents[activity.FilterResponse](
		td.eventQueue, []walletevent.EventType{activity.EventActivityFilteringDone},
		5*time.Second,
	)
	require.NoError(t, err)
	res := filterRes[0]
	require.Equal(t, activity.ErrorCodeSuccess, res.ErrorCode)
	require.Equal(t, 3, len(res.Activities))

	// Trigger updating of activity results
	sendTransaction(t, td)

	// Wait for EventActivitySessionUpdated signal triggered by the EventPendingTransactionUpdate
	update, err := helpers.WaitForWalletEvent[activity.SessionUpdate](td.eventQueue, activity.EventActivitySessionUpdated, 2*time.Second)
	require.NoError(t, err)
	require.Equal(t, 1, len(update.NewEntries))

	// Step x: Trigger downloading of the new transaction ...
	_, err = helpers.CallPrivateMethodWithTimeout("wallet_checkRecentHistoryForChainIDs", []interface{}{[]uint64{5}, []types.Address{td.sender.Address, td.recipient.Address}}, 2*time.Second)
	require.NoError(t, err)

	// ... and wait for the new transaction download to trigger deletion from pending_transactions
	updatePayload, err := helpers.WaitForWalletEvent[transactions.PendingTxUpdatePayload](
		td.eventQueue, transactions.EventPendingTransactionUpdate, 120*time.Second)
	require.NoError(t, err)
	require.Equal(t, true, updatePayload.Deleted)
}
