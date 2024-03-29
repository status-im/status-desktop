// These tests are for development only to be run manually
// There is more work needed to automate them not to depend on an existing account and internet connection

package wallet

import (
	"testing"
	"time"

	eth "github.com/ethereum/go-ethereum/common"
	"github.com/stretchr/testify/require"

	"github.com/status-im/status-desktop/test/status-go/integration/helpers"

	"github.com/status-im/status-go/eth-node/types"
	"github.com/status-im/status-go/services/wallet/transfer"
	"github.com/status-im/status-go/services/wallet/walletevent"
	"github.com/status-im/status-go/transactions"
)

// TestPendingTx_NotificationStatus tests that a pending transaction is created, then updated and finally deleted.
func TestPendingTx_NotificationStatus(t *testing.T) {
	td, close := setupAccountsAndTransactions(t)
	defer close()

	sendTransaction(t, td)

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
	_, err = helpers.CallPrivateMethod("wallet_checkRecentHistoryForChainIDs", []interface{}{[]uint64{5}, []types.Address{td.operableAccounts[0].Address, td.watchAccounts[0].Address}})
	require.NoError(t, err)

	downloadDoneFn := helpers.WaitForTxDownloaderToFinishForAccountsCondition(t, []eth.Address{eth.Address(td.operableAccounts[0].Address), eth.Address(td.watchAccounts[0].Address)})

	// ... and wait for the new transaction download to trigger deletion from pending_transactions
	_, err = helpers.WaitForWalletEventsWithOptionals(
		td.eventQueue,
		[]walletevent.EventType{transfer.EventRecentHistoryReady},
		60*time.Second,
		func(e *walletevent.Event) bool {
			if e.Type == transfer.EventFetchingHistoryError {
				require.Fail(t, "History download failed")
				return false
			}
			return downloadDoneFn(e)
		},
		[]walletevent.EventType{transfer.EventFetchingHistoryError},
	)
	require.NoError(t, err)
}
