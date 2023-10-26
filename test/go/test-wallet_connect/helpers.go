package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"reflect"

	statusgo "github.com/status-im/status-go/mobile"
	"github.com/status-im/status-go/multiaccounts"
)

func loginToAccount(hashedPassword, userFolder, nodeConfigJson string) error {
	absUserFolder, err := filepath.Abs(userFolder)
	if err != nil {
		return err
	}
	accountsJson := statusgo.OpenAccounts(absUserFolder)
	accounts := make([]multiaccounts.Account, 0)
	err = getApiResponse(accountsJson, &accounts)
	if err != nil {
		return err
	}

	if len(accounts) == 0 {
		return fmt.Errorf("no accounts found")
	}

	account := accounts[0]
	keystorePath := filepath.Join(filepath.Join(absUserFolder, "keystore/"), account.KeyUID)
	initKeystoreJson := statusgo.InitKeystore(keystorePath)
	apiResponse := statusgo.APIResponse{}
	err = getApiResponse(initKeystoreJson, &apiResponse)
	if err != nil {
		return err
	}

	//serialize account of type multiaccounts.Account
	accountJson, err := json.Marshal(account)
	if err != nil {
		return err
	}
	loginJson := statusgo.LoginWithConfig(string(accountJson), hashedPassword, nodeConfigJson)
	err = getApiResponse(loginJson, &apiResponse)
	if err != nil {
		return err
	}

	return nil
}

type jsonrpcMessage struct {
	Version string          `json:"jsonrpc"`
	ID      json.RawMessage `json:"id"`
}

type jsonrpcRequest struct {
	jsonrpcMessage
	ChainID uint64          `json:"chainId"`
	Method  string          `json:"method"`
	Params  json.RawMessage `json:"params,omitempty"`
}

func callPrivateMethod(method string, params interface{}) string {
	var paramsJson json.RawMessage
	var err error
	if params != nil {
		paramsJson, err = json.Marshal(params)
		if err != nil {
			return ""
		}
	}

	msg := jsonrpcRequest{
		jsonrpcMessage: jsonrpcMessage{
			Version: "2.0",
		},
		Method: method,
		Params: paramsJson,
	}

	msgJson, err := json.Marshal(msg)
	if err != nil {
		return ""
	}

	return statusgo.CallPrivateRPC(string(msgJson))
}

type Config struct {
	HashedPassword string `json:"hashedPassword"`
	NodeConfigFile string `json:"nodeConfigFile"`
}

func processConfigArgs() (config *Config, nodeConfigJson string, userFolder string, err error) {
	var configFilePath string
	flag.StringVar(&configFilePath, "config", "", "path to json config file")
	flag.StringVar(&userFolder, "dataDir", "../../../Status/data", "path to json config file")
	flag.Parse()

	if configFilePath == "" {
		flag.Usage()
		return
	}

	config = &Config{}
	// parse config file
	configFile, err := os.Open(configFilePath)
	if err != nil {
		panic(err)
	}
	defer configFile.Close()
	jsonParser := json.NewDecoder(configFile)
	if err = jsonParser.Decode(&config); err != nil {
		panic(err)
	}

	// Read config.NodeConfigFile json file and store it as string
	nodeConfigFile, err := os.Open(config.NodeConfigFile)
	if err != nil {
		panic(err)
	}
	defer nodeConfigFile.Close()
	nodeConfigData, err := io.ReadAll(nodeConfigFile)
	if err == nil {
		nodeConfigJson = string(nodeConfigData)
	}
	return
}

func getApiResponse[T any](responseJson string, res T) error {
	apiResponse := statusgo.APIResponse{}
	err := json.Unmarshal([]byte(responseJson), &apiResponse)
	if err == nil {
		if apiResponse.Error != "" {
			return fmt.Errorf("API error: %s", apiResponse.Error)
		}
	}

	typeOfT := reflect.TypeOf(res)
	kindOfT := typeOfT.Kind()

	// Check for valid types: pointer, slice, map
	if kindOfT != reflect.Ptr && kindOfT != reflect.Slice && kindOfT != reflect.Map {
		return fmt.Errorf("type T must be a pointer, slice, or map")
	}

	if err := json.Unmarshal([]byte(responseJson), &res); err != nil {
		return fmt.Errorf("failed to unmarshal data: %w", err)
	}

	return nil
}
