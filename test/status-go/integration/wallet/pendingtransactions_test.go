// These tests are for development only to be run manually
// There is more work needed to automate them not to depend on an existing account and internet connection

package wallet

import (
	"testing"
	"time"

	"github.com/stretchr/testify/require"

	"github.com/status-im/status-desktop/test/status-go/integration/helpers"

	"github.com/status-im/status-go/eth-node/types"
	"github.com/status-im/status-go/services/wallet/common"
	"github.com/status-im/status-go/services/wallet/walletevent"
	"github.com/status-im/status-go/transactions"
)

// TestPendingTx_NotificationStatus tests that a pending transaction is created, then updated and finally deleted.
func TestPendingTx_NotificationStatus(t *testing.T) {
	td, close := setupAccountsAndTransactions(t)
	defer close()

	chainID := common.OptimismSepolia
	sendTransaction(t, td, chainID)

	// Wait for transaction to be included in block
	confirmationPayloads, err := helpers.WaitForWalletEventsGetMap(
		td.eventQueue, []walletevent.EventType{
			transactions.EventPendingTransactionUpdate,
			transactions.EventPendingTransactionStatusChanged,
		},
		60*time.Second,
	)
	require.NoError(t, err)

	// Validate that we received update event
	for _, payload := range confirmationPayloads {
		if payload.EventName == transactions.EventPendingTransactionUpdate {
			require.False(t, payload.JsonData["deleted"].(bool))
		} else {
			require.Equal(t, transactions.Success, payload.JsonData["status"].(transactions.TxStatus))
		}
	}

	// Start history download ...
	_, err = helpers.CallPrivateMethod("wallet_checkRecentHistoryForChainIDs", []interface{}{[]uint64{chainID}, []types.Address{td.operableAccounts[0].Address, td.watchAccounts[0].Address}})
	require.NoError(t, err)

	// Wait for transaction to be included in block
	pendingUpdated, err := helpers.WaitForWalletEventGetPayload[transactions.PendingTxUpdatePayload](
		td.eventQueue, transactions.EventPendingTransactionUpdate, 60*time.Second)
	require.NoError(t, err)

	require.True(t, pendingUpdated.Deleted)
}
