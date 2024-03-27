package wallet

import (
	"math/big"
	"testing"
	"time"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/common/hexutil"
	"github.com/status-im/status-desktop/test/status-go/integration/helpers"
	"github.com/status-im/status-go/multiaccounts/accounts"
	"github.com/status-im/status-go/services/wallet/bridge"
	"github.com/status-im/status-go/services/wallet/transfer"
	"github.com/status-im/status-go/transactions"
	"github.com/stretchr/testify/require"
)

type testUserData struct {
	sender         accounts.Account
	recipient      accounts.Account
	hashedPassword string
	eventQueue     chan helpers.GoEvent
}

func setupAccountsAndTransactions(t *testing.T) (td testUserData, close func()) {
	eventQueue, conf, _ := helpers.LoginToTestAccount(t)

	_, err := helpers.WaitForEvent(eventQueue, helpers.NodeReadyEvent, 600000*time.Second)
	require.NoError(t, err)

	opAccounts, err := helpers.GetWalletOperableAccounts()
	require.NoError(t, err)
	require.Greater(t, len(opAccounts), 0)

	watchAccounts, err := helpers.GetWalletWatchOnlyAccounts()
	require.NoError(t, err)
	require.Greater(t, len(watchAccounts), 0)

	return testUserData{
			opAccounts[0],
			watchAccounts[0],
			conf.HashedPassword,
			eventQueue,
		}, func() {
			helpers.Logout(t)
		}
}

// sendTransaction generates multi_transactions and pending entries then it creates and publishes a transaction
func sendTransaction(t *testing.T, td testUserData) {
	mTCommand := transfer.MultiTransactionCommand{
		FromAddress: common.Address(td.sender.Address),
		ToAddress:   common.Address(td.recipient.Address),
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
				From:  td.sender.Address,
				To:    &td.recipient.Address,
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
