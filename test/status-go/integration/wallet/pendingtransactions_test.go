// These tests are for development only to be run manually
// There is more work needed to automate them not to depend on an existing account and internet connection

package wallet

import (
	"testing"
	"time"

	"github.com/stretchr/testify/require"

	"github.com/status-im/status-desktop/test/status-go/integration/helpers"

	"github.com/status-im/status-go/eth-node/types"
	"github.com/status-im/status-go/services/wallet/walletevent"
	"github.com/status-im/status-go/transactions"
)

// TestPendingTx_NotificationStatus tests that a pending transaction is created, then updated and finally deleted.
func TestPendingTx_NotificationStatus(t *testing.T) {
	td, close := setupAccountsAndTransactions(t)
	defer close()

	sendTransaction(t, td)

	// Start history download ...
	_, err := helpers.CallPrivateMethod("wallet_checkRecentHistoryForChainIDs", []interface{}{[]uint64{5}, []types.Address{td.sender.Address, td.recipient.Address}})
	require.NoError(t, err)

	// ... and wait for the new transaction download to trigger deletion from pending_transactions
	updatePayloads, err := helpers.WaitForWalletEvents[transactions.PendingTxUpdatePayload](
		td.eventQueue, []walletevent.EventType{
			transactions.EventPendingTransactionUpdate,
			transactions.EventPendingTransactionUpdate,
		},
		60*time.Second,
	)
	require.NoError(t, err)

	// Validate that we received both add and delete event
	require.False(t, updatePayloads[0].Deleted)
	require.True(t, updatePayloads[1].Deleted)
}
