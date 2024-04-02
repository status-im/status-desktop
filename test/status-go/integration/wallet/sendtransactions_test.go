// These tests are for development only to be run manually
// There is more work needed to automate them not to depend on an existing account and internet connection

package wallet

import (
	"math/big"
	"strings"
	"testing"
	"time"

	"github.com/ethereum/go-ethereum/accounts/abi"
	eth "github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/common/hexutil"
	"github.com/stretchr/testify/require"

	"github.com/status-im/status-desktop/test/status-go/integration/helpers"

	"github.com/status-im/status-go/contracts/ierc20"
	"github.com/status-im/status-go/eth-node/types"
	"github.com/status-im/status-go/services/wallet"
	"github.com/status-im/status-go/services/wallet/activity"
	"github.com/status-im/status-go/services/wallet/bridge"
	"github.com/status-im/status-go/services/wallet/common"
	"github.com/status-im/status-go/services/wallet/transfer"
	"github.com/status-im/status-go/services/wallet/walletevent"
	"github.com/status-im/status-go/transactions"
)

type dataPayload struct {
	transferType         wallet.SendType
	accountFrom          eth.Address
	accountTo            eth.Address
	amount               *hexutil.Big
	tokenIdentity        string // Format: "<HexTokenAddress>:<TokenID>" or "<Symbol>"
	disabledFromChainIDs []uint64
	disabledToChainIDs   []uint64
	preferredChainIDs    []uint64
	gasFeeMode           wallet.GasFeeMode
	fromLockedAmount     map[uint64]*hexutil.Big
}

func dataToCallingPayload(data dataPayload) []interface{} {
	return []interface{}{
		data.transferType,
		data.accountFrom,
		data.accountTo,
		data.amount,
		data.tokenIdentity,
		data.disabledFromChainIDs,
		data.disabledToChainIDs,
		data.preferredChainIDs,
		data.gasFeeMode,
		data.fromLockedAmount,
	}
}

func basicPayload() dataPayload {
	defaultDisabled := []uint64{common.OptimismSepolia, common.ArbitrumSepolia}
	return dataPayload{
		transferType:         wallet.Transfer,
		tokenIdentity:        "",
		accountFrom:          eth.HexToAddress("0xe2d622c817878da5143bbe06866ca8e35273ba8a"),
		accountTo:            eth.HexToAddress("0xbd54a96c0ae19a220c8e1234f54c940dfab34639"),
		amount:               (*hexutil.Big)(big.NewInt(1)),
		disabledFromChainIDs: defaultDisabled,
		disabledToChainIDs:   defaultDisabled,
		preferredChainIDs:    []uint64{common.EthereumSepolia},
		gasFeeMode:           wallet.GasFeeMedium,
		fromLockedAmount:     map[uint64]*hexutil.Big{},
	}
}

func customBasicPayload(transType wallet.SendType, tokenIdentity string) dataPayload {
	payload := basicPayload()
	payload.transferType = transType
	payload.tokenIdentity = tokenIdentity
	return payload
}

func erc721Payload(tokenIdentity string) dataPayload {
	return customBasicPayload(wallet.ERC721Transfer, tokenIdentity)
}

func erc1155Payload(tokenIdentity string) dataPayload {
	return customBasicPayload(wallet.ERC1155Transfer, tokenIdentity)
}

func TestSendTransaction_Collectible_Routes(t *testing.T) {

	tests := []struct {
		name string
		data dataPayload
	}{
		{"ERC721", erc721Payload("0x9f64932be34d5d897c4253d17707b50921f372b6:37")},
		{"ERC1155", erc1155Payload("0x1ed60fedff775d500dde21a974cd4e92e0047cc8:32")},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, close := setupAccountsAndTransactions(t)
			defer close()

			payload := dataToCallingPayload(tt.data)
			res, err := helpers.CallPrivateMethodAndGetT[wallet.SuggestedRoutes]("wallet_getSuggestedRoutes", payload)
			require.NoError(t, err)
			require.Greater(t, len(res.Candidates), 0)
		})
	}
}

func gweiToWei(gwei *big.Float) *big.Int {
	weiMultiplier := big.NewFloat(1e9 /*10^9*/)
	weiValue := new(big.Float).Mul(gwei, weiMultiplier)
	res, _ := weiValue.Int(nil)
	return res
}

// TestSendTransaction_Assets_KeepMTID is here to debug why the MTID is not kept
// when migrating a transaction from pending_transactions to transfers table
func TestSendTransaction_Assets_KeepMTID(t *testing.T) {
	td, close := setupAccountsAndTransactions(t)
	defer close()

	chainID := common.OptimismSepolia
	amount, ok := new(big.Int).SetString("0x3e8", 0)
	require.True(t, ok)
	info := dataPayload{
		transferType:         wallet.Transfer,
		tokenIdentity:        "USDC",
		accountFrom:          eth.HexToAddress("0xe2d622c817878da5143bbe06866ca8e35273ba8a"),
		accountTo:            eth.HexToAddress("0xbd54a96c0ae19a220c8e1234f54c940dfab34639"),
		amount:               (*hexutil.Big)(amount),
		disabledFromChainIDs: []uint64{common.OptimismMainnet},
		disabledToChainIDs:   []uint64{common.OptimismMainnet},
		preferredChainIDs:    []uint64{chainID},
		gasFeeMode:           wallet.GasFeeHigh,
		fromLockedAmount:     map[uint64]*hexutil.Big{},
	}

	payload := dataToCallingPayload(info)
	res, err := helpers.CallPrivateMethodAndGetT[wallet.SuggestedRoutes]("wallet_getSuggestedRoutes", payload)
	require.NoError(t, err)
	require.Greater(t, len(res.Candidates), 0)

	suggested := res.Candidates[0]

	mtCmd := transfer.MultiTransactionCommand{
		FromAddress: info.accountFrom,
		ToAddress:   info.accountTo,
		FromAsset:   info.tokenIdentity,
		ToAsset:     info.tokenIdentity,
		FromAmount:  info.amount,
		Type:        transfer.MultiTransactionSend,
	}

	abi, err := abi.JSON(strings.NewReader(ierc20.IERC20ABI))
	require.NoError(t, err)
	input, err := abi.Pack("transfer",
		info.accountTo,
		info.amount.ToInt(),
	)
	require.NoError(t, err)

	txArgs := transactions.SendTxArgs{
		From:                 types.Address(info.accountFrom),
		To:                   common.NewAndSet(types.HexToAddress("0x5fd84259d66cd46123540766be93dfe6d43130d7")),
		Gas:                  common.NewAndSet(hexutil.Uint64(suggested.GasAmount)),
		GasPrice:             (*hexutil.Big)(gweiToWei(suggested.GasFees.GasPrice)),
		Value:                (*hexutil.Big)(big.NewInt(0)),
		MaxFeePerGas:         (*hexutil.Big)(gweiToWei(suggested.GasFees.MaxFeePerGasHigh)),
		MaxPriorityFeePerGas: (*hexutil.Big)(gweiToWei(suggested.GasFees.MaxPriorityFeePerGas)),
		MultiTransactionID:   common.NoMultiTransactionID,
		Symbol:               info.tokenIdentity,
		Data:                 types.HexBytes(input),
	}

	bridge := []*bridge.TransactionBridge{{
		BridgeName: suggested.BridgeName,
		ChainID:    chainID,
		TransferTx: &txArgs,
	}}

	sendPayload := []interface{}{mtCmd, bridge, td.hashedPassword}

	// Simulate the transaction creation as a result to SendModal user actions for an asset
	sendRes, err := helpers.CallPrivateMethodAndGetT[transfer.MultiTransactionCommandResult]("wallet_createMultiTransaction", sendPayload)
	require.NoError(t, err)
	require.NotNil(t, sendRes)
	require.Greater(t, len(sendRes.Hashes), 0)

	// Wait for transaction to be included in block
	_, err = helpers.WaitForWalletEventsGetMap(
		td.eventQueue, []walletevent.EventType{
			transactions.EventPendingTransactionUpdate,
			transactions.EventPendingTransactionStatusChanged,
		},
		20*time.Second,
	)
	require.NoError(t, err)

	// Start history download
	_, err = helpers.CallPrivateMethod("wallet_checkRecentHistoryForChainIDs", []interface{}{[]uint64{chainID}, []types.Address{types.Address(info.accountFrom), types.Address(info.accountTo)}})
	require.NoError(t, err)

	newHash := eth.Hash(sendRes.Hashes[chainID][0])
	// Wait for transaction to be deleted by downloader and also ensure we receive notification that transaction entries
	// stored in transfers for the sender account
	_, err = helpers.WaitForWalletEventsWithOptionals(
		td.eventQueue,
		[]walletevent.EventType{transactions.EventPendingTransactionUpdate, transfer.EventNewTransfers},
		60*time.Second,
		func(e *walletevent.Event) bool {
			if e.Type == transactions.EventPendingTransactionUpdate {
				update, err := walletevent.GetPayload[transactions.PendingTxUpdatePayload](*e)
				require.NoError(t, err)

				return update.Deleted && update.TxIdentity.Hash == newHash
			} else if e.Type == transfer.EventNewTransfers {
				for _, acc := range e.Accounts {
					if acc == info.accountFrom {
						return true
					}
				}
			} else if e.Type == transfer.EventFetchingHistoryError {
				require.Fail(t, "History download failed")
				return true
			}
			return false
		},
		[]walletevent.EventType{transfer.EventFetchingHistoryError},
	)
	require.NoError(t, err)

	// Ensure the transaction is not pending anymore
	pendings, err := helpers.CallPrivateMethodAndGetSliceOfT[transactions.PendingTransaction]("wallet_getPendingTransactions", []interface{}{})
	require.NoError(t, err)
	require.Len(t, pendings, 0)

	_, err = helpers.CallPrivateMethodAndGetT[activity.SessionID]("wallet_startActivityFilterSession", []interface{}{
		[]eth.Address{info.accountFrom},
		false, /* allAddresses */
		[]common.ChainID{common.ChainID(chainID)},
		activity.Filter{},
		5,
	})
	require.NoError(t, err)

	newMTID := sendRes.ID
	// Confirm filtering results have a MT with expected MTID as last entry and the next one is not pending as reported
	// by #14071 issue
	resMap, err := helpers.WaitForWalletEventsGetMap(td.eventQueue, []walletevent.EventType{activity.EventActivityFilteringDone}, 5*time.Second)
	require.NoError(t, err)
	require.Len(t, resMap, 1)
	require.Equal(t, resMap[0].EventName, activity.EventActivityFilteringDone)
	activityRes := resMap[0].JsonData
	require.Equal(t, activity.ErrorCodeSuccess, activity.ErrorCode(int(activityRes["errorCode"].(float64))))
	activities := activityRes["activities"].([](interface{}))
	require.Greater(t, len(activities), 1)
	lastEntry := activities[0].(map[string]interface{})
	require.Equal(t, activity.MultiTransactionPT, activity.PayloadType(int(lastEntry["payloadType"].(float64))))
	require.Equal(t, newMTID, int64(lastEntry["id"].(float64)))
	if len(activities) > 1 {
		secondEntry := activities[1].(map[string]interface{})
		require.NotEqual(t, activity.PendingTransactionPT, activity.PayloadType(int(secondEntry["payloadType"].(float64))))
		if tr, ok := secondEntry["transaction"]; ok {
			require.NotEqual(t, newHash, tr.(map[string]interface{})["hash"].(eth.Hash))
		}
	}
}
