// These tests are for development only to be run manually
// There is more work needed to automate them not to depend on an existing account and internet connection

package wallet

import (
	"math/big"
	"testing"

	eth "github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/common/hexutil"
	"github.com/stretchr/testify/require"

	"github.com/status-im/status-desktop/test/status-go/integration/helpers"

	"github.com/status-im/status-go/services/wallet"
	"github.com/status-im/status-go/services/wallet/common"
)

type dataPayload struct {
	transferType         wallet.SendType
	accountFrom          eth.Address
	accountTo            eth.Address
	amount               *hexutil.Big
	tokenIdentity        string // Format: "<HexTokenAddress>:<TokenID>"
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

func TestSendTransaction_Collectible(t *testing.T) {

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
