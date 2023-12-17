package helpers

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"reflect"
	"testing"
	"time"

	"github.com/ethereum/go-ethereum/log"
	statusgo "github.com/status-im/status-go/mobile"
	"github.com/status-im/status-go/multiaccounts"
	"github.com/status-im/status-go/services/wallet/walletevent"
	"github.com/status-im/status-go/signal"
	"github.com/stretchr/testify/require"
)

type StatusGoEventName string

const NodeReadyEvent StatusGoEventName = "nodeReady"
const WalletEvent StatusGoEventName = "wallet"

type GoEvent struct {
	Name    StatusGoEventName `json:"name"`
	Payload interface{}       `json:"payload"`
}

type envelope struct {
	Type  string          `json:"type"`
	Event json.RawMessage `json:"event"` // Use json.RawMessage to delay parsing
}

func signalHandler(eventQueue chan GoEvent, jsonEvent string) {
	envelope := envelope{}
	err := json.Unmarshal([]byte(jsonEvent), &envelope)
	if err != nil {
		apiResponse := statusgo.APIResponse{}
		err = json.Unmarshal([]byte(jsonEvent), &apiResponse)
		if err != nil {
			log.Error("Error parsing the signal event: ", err)
		} else if apiResponse.Error != "" {
			log.Error("Error from status-go: ", apiResponse.Error)
		} else {
			log.Error("Unknown JSON content for event", jsonEvent)
		}
		return
	}

	if envelope.Type == signal.EventNodeReady {
		eventQueue <- GoEvent{Name: NodeReadyEvent, Payload: string(envelope.Event)}
	} else if envelope.Type == string(WalletEvent) {
		walletEvent := walletevent.Event{}
		err := json.Unmarshal(envelope.Event, &walletEvent)
		if err != nil {
			log.Error("Error parsing the wallet event: ", err)
			return
		}
		eventQueue <- GoEvent{Name: WalletEvent, Payload: walletEvent}
	}
}

func LoginToTestAccount(t *testing.T) (eventQueue chan GoEvent, config *Config, l log.Logger) {
	l = log.New()
	l.SetHandler(log.CallerFileHandler(log.StreamHandler(os.Stdout, log.TerminalFormat(false))))

	// Setup status-go logger
	log.Root().SetHandler(log.CallerFileHandler(log.StdoutHandler))

	eventQueue = make(chan GoEvent, 10000)
	signal.SetDefaultNodeNotificationHandler(func(jsonEvent string) {
		signalHandler(eventQueue, jsonEvent)
	})

	conf, nodeConfigJson, userFolder, err := processConfigArgs("./.integration_tests_config.json")
	if err != nil {
		t.Fatal(err)
	}
	config = conf

	// Login to first account
	err = loginToAccount(config.HashedPassword, userFolder, nodeConfigJson)
	if err != nil {
		t.Fatal(err)
	}
	return
}

func Logout(t *testing.T) {
	err := logout()
	require.NoError(t, err)
}

func WaitForEvent(eventQueue chan GoEvent, eventName StatusGoEventName, timeout time.Duration) (event *GoEvent, err error) {
	for {
		select {
		case event := <-eventQueue:
			if event.Name == eventName {
				return &event, nil
			}
		case <-time.After(timeout):
			return nil, fmt.Errorf("timeout waiting for event %s", eventName)
		}
	}
}

// WaitForWalletEvents returns payloads corresponding to the given eventNames in the order they are received for duplicate events
func WaitForWalletEvents[T any](eventQueue chan GoEvent, eventNamesOrig []walletevent.EventType, timeout time.Duration) (payloads []*T, err error) {
	var event *GoEvent

	payloads = make([]*T, len(eventNamesOrig))
	processed := make([]bool, len(eventNamesOrig))
	processedCount := 0

	for {
		event, err = WaitForEvent(eventQueue, WalletEvent, timeout)
		if err != nil {
			return nil, err
		}

		walletEvent, ok := event.Payload.(walletevent.Event)
		if !ok {
			return nil, errors.New("event payload is not a wallet event")
		}

		var newPayload T
		foundIndex := -1
		for i, eventName := range eventNamesOrig {
			if walletEvent.Type == eventName && !processed[i] {
				foundIndex = i
				processed[i] = true
				processedCount += 1
				break
			}
		}

		if foundIndex != -1 {
			if walletEvent.Message != "" {
				err = json.Unmarshal([]byte(walletEvent.Message), &newPayload)
				if err != nil {
					return nil, err
				}
				payloads[foundIndex] = &newPayload
			} else {
				payloads[foundIndex] = nil
			}
			if processedCount == len(eventNamesOrig) {
				return payloads, nil
			}
		}
	}
}

func WaitForWalletEvent[T any](eventQueue chan GoEvent, eventName walletevent.EventType, timeout time.Duration) (payload *T, err error) {
	res, err := WaitForWalletEvents[T](eventQueue, []walletevent.EventType{eventName}, timeout)
	if err != nil {
		return nil, err
	}
	return res[0], nil
}

func loginToAccount(hashedPassword, userFolder, nodeConfigJson string) error {
	absUserFolder, err := filepath.Abs(userFolder)
	if err != nil {
		return err
	}
	accountsJson := statusgo.OpenAccounts(absUserFolder)
	accounts := make([]multiaccounts.Account, 0)
	err = GetCAPIResponse(accountsJson, &accounts)
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
	err = GetCAPIResponse(initKeystoreJson, &apiResponse)
	if err != nil {
		return err
	}

	//serialize account of type multiaccounts.Account
	accountJson, err := json.Marshal(account)
	if err != nil {
		return err
	}
	loginJson := statusgo.LoginWithConfig(string(accountJson), hashedPassword, nodeConfigJson)
	err = GetCAPIResponse(loginJson, &apiResponse)
	if err != nil {
		return err
	}

	return nil
}

func logout() error {
	logoutJson := statusgo.Logout()
	apiResponse := statusgo.APIResponse{}
	err := GetCAPIResponse(logoutJson, &apiResponse)
	if err != nil {
		return err
	}
	if apiResponse.Error != "" {
		return fmt.Errorf("API error: %s", apiResponse.Error)
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

func CallPrivateMethodWithTimeout(method string, params []interface{}, timeout time.Duration) (string, error) {
	var paramsJson json.RawMessage
	var err error
	if params != nil {
		paramsJson, err = json.Marshal(params)
		if err != nil {
			return "", err
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
		return "", err
	}

	didTimeout := false
	done := make(chan bool)
	var responseJson string
	go func() {
		responseJson = statusgo.CallPrivateRPC(string(msgJson))
		if didTimeout {
			log.Warn("Call to CallPrivateRPC returned after timeout", "payload", string(msgJson))
			return
		}

		done <- true
	}()

	select {
	case <-done:
	case <-time.After(timeout):
		didTimeout = true
		return "", fmt.Errorf("timeout waiting for response to statusgo.CallPrivateRPC; payload \"%s\"", string(msgJson))
	}

	return responseJson, nil
}

func CallPrivateMethod(method string, params []interface{}) (string, error) {
	return CallPrivateMethodWithTimeout(method, params, 60*time.Second)
}

type Config struct {
	HashedPassword string `json:"hashedPassword"`
	NodeConfigFile string `json:"nodeConfigFile"`
	DataDir        string `json:"dataDir"`
}

// processConfigArgs expects that configFilePath points to a JSON file that contains a Config struct
// For now this are for developer to manually run them using an existing user folder.
// TODO: ideally we would generate a temporary user folder to be used in the entire suite.
func processConfigArgs(configFilePath string) (config *Config, nodeConfigJson string, userFolder string, err error) {
	config = &Config{}
	// parse config file
	configFile, err := os.Open(configFilePath)
	if err != nil {
		return nil, "", "", err
	}
	defer configFile.Close()

	jsonParser := json.NewDecoder(configFile)
	if err = jsonParser.Decode(&config); err != nil {
		panic(err)
	}

	nodeConfigFile, err := os.Open(config.NodeConfigFile)
	if err != nil {
		panic(err)
	}
	defer nodeConfigFile.Close()

	nodeConfigData, err := io.ReadAll(nodeConfigFile)
	if err == nil {
		nodeConfigJson = string(nodeConfigData)
	}

	userFolder = config.DataDir

	return
}

// GetCAPIResponse expects res to be a pointer to a struct, a pointer to a slice or a pointer to a map for marshaling
func GetCAPIResponse[T any](responseJson string, res T) error {
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

type jsonrpcSuccessfulResponse struct {
	jsonrpcMessage
	Result json.RawMessage `json:"result"`
}

type jsonrpcErrorResponse struct {
	jsonrpcMessage
	Error jsonError `json:"error"`
}

// jsonError represents Error message for JSON-RPC responses.
type jsonError struct {
	Code    int         `json:"code"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
}

func GetRPCAPIResponse[T any](responseJson string, res T) error {
	errApiResponse := jsonrpcErrorResponse{}
	err := json.Unmarshal([]byte(responseJson), &errApiResponse)
	if err == nil && errApiResponse.Error.Code != 0 {
		return fmt.Errorf("API error: %#v", errApiResponse.Error)
	}

	apiResponse := jsonrpcSuccessfulResponse{}
	err = json.Unmarshal([]byte(responseJson), &apiResponse)
	if err != nil {
		return fmt.Errorf("failed to unmarshal jsonrpcSuccessfulResponse: %w", err)
	}

	typeOfT := reflect.TypeOf(res)
	kindOfT := typeOfT.Kind()

	// Check for valid types: pointer, slice, map
	if kindOfT != reflect.Ptr && kindOfT != reflect.Slice && kindOfT != reflect.Map {
		return fmt.Errorf("type T must be a pointer, slice, or map")
	}

	if err := json.Unmarshal(apiResponse.Result, &res); err != nil {
		return fmt.Errorf("failed to unmarshal data: %w", err)
	}

	return nil
}
