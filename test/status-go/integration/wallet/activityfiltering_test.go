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
	"github.com/status-im/status-go/services/wallet/activity"
	"github.com/status-im/status-go/services/wallet/common"
	"github.com/status-im/status-go/services/wallet/transfer"
	"github.com/status-im/status-go/services/wallet/walletevent"
)

// TestActivityIncrementalUpdates_NoFilterNewPendingTransactions tests that a pending transaction is created, then updated and finally deleted.
func TestActivityIncrementalUpdates_NoFilterNewPendingTransactions(t *testing.T) {
	td, close := setupAccountsAndTransactions(t)
	defer close()

	chainID := common.OptimismSepolia
	rawSessionID, err := helpers.CallPrivateMethodAndGetT[int32]("wallet_startActivityFilterSession", []interface{}{[]types.Address{td.operableAccounts[0].Address}, false, []common.ChainID{common.ChainID(chainID)}, activity.Filter{}, 3})
	require.NoError(t, err)
	require.NotNil(t, rawSessionID)
	sessionID := activity.SessionID(*rawSessionID)

	// Confirm async filtering results
	res, err := helpers.WaitForWalletEventGetPayload[activity.FilterResponse](td.eventQueue, activity.EventActivityFilteringDone, 5*time.Second)
	require.NoError(t, err)
	require.Equal(t, activity.ErrorCodeSuccess, res.ErrorCode)
	require.Equal(t, 3, len(res.Activities))

	// Trigger updating of activity results
	sendTransaction(t, td, chainID)

	// Wait for EventActivitySessionUpdated signal triggered by the first EventPendingTransactionUpdate
	update, err := helpers.WaitForWalletEventGetPayload[activity.SessionUpdate](td.eventQueue, activity.EventActivitySessionUpdated, 60*time.Second)
	require.NoError(t, err)
	require.NotNil(t, update.HasNewOnTop)
	require.True(t, *update.HasNewOnTop)

	// TODO #12120 check EventActivitySessionUpdated due to EventPendingTransactionStatusChanged
	// statusPayload, err := helpers.WaitForWalletEventGetPayload[transactions.StatusChangedPayload](td.eventQueue, activity.EventActivitySessionUpdated, 60*time.Second)
	// require.NoError(t, err)
	// require.NotNil(t, update.HasNewOnTop)
	// require.True(t, *update.HasNewOnTop)

	// Start history download to cleanup pending transactions
	_, err = helpers.CallPrivateMethod("wallet_checkRecentHistoryForChainIDs", []interface{}{[]uint64{chainID}, []types.Address{td.operableAccounts[0].Address, td.watchAccounts[0].Address}})
	require.NoError(t, err)

	downloadDoneFn := helpers.WaitForTxDownloaderToFinishForAccountsCondition(t, []eth.Address{eth.Address(td.operableAccounts[0].Address), eth.Address(td.watchAccounts[0].Address)})

	update = nil
	// Wait for EventRecentHistoryReady.
	// It is expected that downloading will generate a  EventPendingTransactionUpdate that in turn will generate a second EventActivitySessionUpdated signal marked by the update non nil value
	_, err = helpers.WaitForWalletEventsWithOptionals(
		td.eventQueue,
		[]walletevent.EventType{activity.EventActivitySessionUpdated},
		120*time.Second,
		func(e *walletevent.Event) bool {
			if e.Type == activity.EventActivitySessionUpdated {
				update, err = walletevent.GetPayload[activity.SessionUpdate](*e)
				require.NoError(t, err)

				require.NotNil(t, update.HasNewOnTop)
				require.True(t, *update.HasNewOnTop)
				//require.NotNil(t, update.Removed)
				//require.True(t, *update.Removed)
				return true
			} else if e.Type == transfer.EventFetchingHistoryError {
				require.Fail(t, "History download failed")
				return false
			} else if downloadDoneFn(e) {
				return false
			}
			return false
		},
		[]walletevent.EventType{transfer.EventFetchingHistoryError},
	)
	require.NoError(t, err)
	require.NotNil(t, update, "EventActivitySessionUpdated signal was triggered by the second EventPendingTransactionUpdate during history download")
	require.NotNil(t, update.HasNewOnTop)
	require.True(t, *update.HasNewOnTop)

	// Start history download to cleanup pending transactions
	_, err = helpers.CallPrivateMethodAndGetT[interface{}]("wallet_resetActivityFilterSession", []interface{}{sessionID, 3})
	require.NoError(t, err)

	updatedRes, err := helpers.WaitForWalletEventsGetMap(td.eventQueue, []walletevent.EventType{activity.EventActivityFilteringDone}, 1*time.Second)
	require.NoError(t, err)
	require.Equal(t, activity.ErrorCodeSuccess, activity.ErrorCode(updatedRes[0].JsonData["errorCode"].(float64)))
	activitiesList := updatedRes[0].JsonData["activities"].([]interface{})
	require.Equal(t, 3, len(activitiesList))
	firstActivity := activitiesList[0].(map[string]interface{})
	isNew, found := firstActivity["isNew"]
	require.True(t, found)
	require.True(t, isNew.(bool))
}
