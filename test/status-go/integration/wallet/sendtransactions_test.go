// These tests are for development only to be run manually
// There is more work needed to automate them not to depend on an existing account and internet connection

package wallet

import (
	"math/big"
	"testing"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/common/hexutil"
	"github.com/stretchr/testify/require"

	"github.com/status-im/status-desktop/test/status-go/integration/helpers"

	"github.com/status-im/status-go/services/wallet"
)

func TestSendTransaction_Collectible(t *testing.T) {
	_, close := setupAccountsAndTransactions(t)
	defer close()

	payload := []interface{}{
		wallet.ERC721Transfer,
		common.HexToAddress("0xe2d622c817878da5143bbe06866ca8e35273ba8a"), /*accountFrom*/
		common.HexToAddress("0xbd54a96c0ae19a220c8e1234f54c940dfab34639"), /*accountTo*/
		(*hexutil.Big)(big.NewInt(1)),                                     /*amount*/
		"0x9f64932be34d5d897c4253d17707b50921f372b6:28",                   /*tokenID*/
		[]uint64{11155420, 421614},                                        /*disabledFromChainIDs*/
		[]uint64{11155420, 421614},                                        /*disabledToChainIDs*/
		[]uint64{11155111},                                                /*preferredChainIDs*/
		wallet.GasFeeMedium,
		map[uint64]*hexutil.Big{}, /*fromLockedAmount*/
	}
	//res, err := helpers.CallPrivateMethodAndGetTWithTimeout[wallet.SuggestedRoutes]("wallet_getSuggestedRoutes", payload¸, 10000*time.Minute)
	res, err := helpers.CallPrivateMethodAndGetT[wallet.SuggestedRoutes]("wallet_getSuggestedRoutes", payload)
	require.NoError(t, err)
	require.Greater(t, len(res.Candidates), 0)
}
