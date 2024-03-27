// These tests are for development only to be run manually
// There is more work needed to automate them not to depend on an existing account and internet connection

package wallet

import (
	"fmt"
	"testing"

	"github.com/status-im/status-desktop/test/status-go/integration/helpers"
	"github.com/stretchr/testify/require"
)

// TODO DEV used to debug the DB lock at login experienced with broken account
func TestAccountLogin(t *testing.T) {
	_ /*td*/, close := setupAccountsAndTransactions(t)
	defer close()

	res, err := helpers.CallPrivateMethod("wakuext_startMessenger", nil)
	require.NoError(t, err)
	fmt.Println("@dd res:", res)
}
