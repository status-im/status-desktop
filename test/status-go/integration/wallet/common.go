package wallet

import (
	"math/big"
	"testing"
	"time"

	eth "github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/common/hexutil"
	"github.com/status-im/status-desktop/test/status-go/integration/helpers"
	"github.com/status-im/status-go/multiaccounts/accounts"
	"github.com/status-im/status-go/services/wallet/bridge"
	"github.com/status-im/status-go/services/wallet/transfer"
	"github.com/status-im/status-go/transactions"
	"github.com/stretchr/testify/require"
)

type testUserData struct {
	operableAccounts []accounts.Account
	watchAccounts    []accounts.Account
	hashedPassword   string
	eventQueue       chan helpers.GoEvent
}

func setupAccountsAndTransactions(t *testing.T) (td testUserData, close func()) {
	return setupAccountsAndTransactionsWithTimeout(t, 60*time.Second)
}

func setupAccountsAndTransactionsWithTimeout(t *testing.T, timeout time.Duration) (td testUserData, close func()) {
	eventQueue, conf, _ := helpers.LoginToTestAccount(t)

	_, err := helpers.WaitForEvent(eventQueue, helpers.NodeReadyEvent, timeout)
	require.NoError(t, err)

	opAccounts, err := helpers.GetWalletOperableAccounts()
	require.NoError(t, err)
	require.Greater(t, len(opAccounts), 0)

	watchAccounts, err := helpers.GetWalletWatchOnlyAccounts()
	require.NoError(t, err)
	require.Greater(t, len(watchAccounts), 0)

	return testUserData{
			opAccounts,
			watchAccounts,
			conf.HashedPassword,
			eventQueue,
		}, func() {
			helpers.Logout(t)
		}
}

// sendTransaction generates a Multi Transaction and Bridge entry then
// calls createMultiTransaction which creates a pending entry and publishes a transaction
func sendTransaction(t *testing.T, td testUserData, chainID uint64) {
	mTCommand := transfer.MultiTransactionCommand{
		FromAddress: eth.Address(td.operableAccounts[0].Address),
		ToAddress:   eth.Address(td.watchAccounts[0].Address),
		FromAsset:   "ETH",
		ToAsset:     "ETH",
		FromAmount:  (*hexutil.Big)(new(big.Int).SetUint64(100000)),
		Type:        transfer.MultiTransactionSend,
	}
	data := []*bridge.TransactionBridge{
		{
			BridgeName: "Transfer",
			ChainID:    chainID,
			TransferTx: &transactions.SendTxArgs{
				From:  td.operableAccounts[0].Address,
				To:    &td.watchAccounts[0].Address,
				Value: (*hexutil.Big)(new(big.Int).Set(mTCommand.FromAmount.ToInt())),
			},
		},
	}

	sessionReqRes, err := helpers.CallPrivateMethod("wallet_createMultiTransaction", []interface{}{mTCommand, data, td.hashedPassword})
	require.NoError(t, err)

	var apiResponse *transfer.MultiTransactionCommandResult
	err = helpers.GetRPCAPIResponse(sessionReqRes, &apiResponse)
	require.NoError(t, err)
	require.Equal(t, 1, len(apiResponse.Hashes))
}
