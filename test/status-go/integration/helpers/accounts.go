package helpers

import (
	"github.com/status-im/status-go/multiaccounts/accounts"
)

func GetAllAccounts() (res []accounts.Account, err error) {
	jsonRes, err := CallPrivateMethod("accounts_getAccounts", []interface{}{})
	if err != nil {
		return nil, err
	}

	var allAccounts []accounts.Account
	err = GetRPCAPIResponse(jsonRes, &allAccounts)
	if err != nil {
		return nil, err
	}
	return allAccounts, nil
}

func GetWalletWatchOnlyAccounts() (res []accounts.Account, err error) {
	accounts, err := GetAllAccounts()
	if err != nil {
		return nil, err
	}

	for _, acc := range accounts {
		if !acc.IsWalletNonWatchOnlyAccount() {
			res = append(res, acc)
		}
	}
	return res, nil
}

func GetWalletOperableAccounts() (res []accounts.Account, err error) {
	accounts, err := GetAllAccounts()
	if err != nil {
		return nil, err
	}

	for _, acc := range accounts {
		if acc.IsWalletAccountReadyForTransaction() {
			res = append(res, acc)
		}
	}
	return res, nil
}
