// These tests are for development only to be run manually
// There is more work needed to automate them not to depend on an existing account and internet connection

package wallet

import (
	"math/big"
	"testing"
	"time"

	"github.com/ethereum/go-ethereum/common/hexutil"
	"github.com/stretchr/testify/require"

	"github.com/ethereum/go-ethereum/common"

	"github.com/status-im/status-desktop/test/status-go/integration/helpers"

	"github.com/status-im/status-go/eth-node/types"
	"github.com/status-im/status-go/services/wallet/bridge"
	"github.com/status-im/status-go/services/wallet/transfer"
	"github.com/status-im/status-go/transactions"
)

// TestPendingTx_NotificationStatus tests that a pending transaction is created, then updated and finally deleted.
func TestPendingTx_NotificationStatus(t *testing.T) {
	eventQueue, conf, _ := helpers.LoginToTestAccount(t)

	_, err := helpers.WaitForEvent(eventQueue, helpers.NodeReadyEvent, 60*time.Second)
	require.NoError(t, err)

	opAccounts, err := helpers.GetWalletOperableAccounts()
	require.NoError(t, err)
	require.Greater(t, len(opAccounts), 0)
	sender := opAccounts[0]

	watchAccounts, err := helpers.GetWalletWatchOnlyAccounts()
	require.NoError(t, err)
	require.Greater(t, len(watchAccounts), 0)
	recipient := watchAccounts[0]

	mTCommand := transfer.MultiTransactionCommand{
		FromAddress: common.Address(sender.Address),
		ToAddress:   common.Address(recipient.Address),
		FromAsset:   "ETH",
		ToAsset:     "ETH",
		FromAmount:  (*hexutil.Big)(new(big.Int).SetUint64(100000)),
		Type:        transfer.MultiTransactionSend,
	}
	data := []*bridge.TransactionBridge{
		{
			BridgeName: "Transfer",
			ChainID:    5,
			TransferTx: &transactions.SendTxArgs{
				From:  sender.Address,
				To:    &recipient.Address,
				Value: (*hexutil.Big)(new(big.Int).Set(mTCommand.FromAmount.ToInt())),
			},
		},
	}

	password := conf.HashedPassword

	// Step 1: send a transaction that will generate a pending entry
	sessionReqRes, err := helpers.CallPrivateMethod("wallet_createMultiTransaction", []interface{}{mTCommand, data, password})
	require.NoError(t, err)

	var apiResponse *transfer.MultiTransactionCommandResult
	err = helpers.GetRPCAPIResponse(sessionReqRes, &apiResponse)
	require.NoError(t, err)
	require.Equal(t, 1, len(apiResponse.Hashes))

	// Step 2: wait for the pending entry to be confirmed
	statusPayload, err := helpers.WaitForWalletEvent[transactions.StatusChangedPayload](eventQueue, transactions.EventPendingTransactionStatusChanged, 60*time.Second)
	require.NoError(t, err)
	require.Equal(t, statusPayload.Status, transactions.Success)

	// Step 3: Trigger downloading of the new transaction ...
	_, err = helpers.CallPrivateMethod("wallet_checkRecentHistoryForChainIDs", []interface{}{[]uint64{5}, []types.Address{sender.Address, recipient.Address}})
	require.NoError(t, err)

	// ... and wait for the new transaction download to trigger deletion from pending_transactions
	updatePayload, err := helpers.WaitForWalletEvent[transactions.PendingTxUpdatePayload](eventQueue, transactions.EventPendingTransactionUpdate, 60*time.Second)
	require.NoError(t, err)
	require.True(t, updatePayload.Deleted)
}
