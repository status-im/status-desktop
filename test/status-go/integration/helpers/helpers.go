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

	"github.com/ethereum/go-ethereum/common"
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

func WaitForWalletEvents(eventQueue chan GoEvent, eventNames []walletevent.EventType, timeout time.Duration, condition func(walletEvent *walletevent.Event) bool) (walletEvents []*walletevent.Event, err error) {
	return WaitForWalletEventsWithOptionals(eventQueue, eventNames, timeout, condition, nil)
}

// WaitForWalletEvents waits for the given events to be received on the eventQueue.
// It returns the wallet events in the order they are received.
// If a condition is provided, only returning true on the respective call will discard that event.
func WaitForWalletEventsWithOptionals(eventQueue chan GoEvent, eventNames []walletevent.EventType, timeout time.Duration, condition func(walletEvent *walletevent.Event) bool, optionalEventNames []walletevent.EventType) (walletEvents []*walletevent.Event, err error) {
	if len(eventNames) == 0 {
		return nil, errors.New("no event names provided")
	}

	startTime := time.Now()
	expected := make([]walletevent.EventType, len(eventNames))
	copy(expected, eventNames)
	walletEvents = make([]*walletevent.Event, 0, len(eventNames))

infiniteLoop:
	for {
		toWait := timeout - time.Since(startTime)
		if toWait <= 0 {
			return nil, fmt.Errorf("timeout waiting for events %+v", expected)
		}
		event, err := WaitForEvent(eventQueue, WalletEvent, toWait)
		if err != nil {
			return nil, fmt.Errorf("error waiting for events %+v: %w", expected, err)
		}

		walletEvent, ok := event.Payload.(walletevent.Event)
		if !ok {
			return nil, errors.New("event payload is not a wallet event")
		}

		for i, event := range expected {
			if walletEvent.Type == event && (condition == nil || condition(&walletEvent)) {
				walletEvents = append(walletEvents, &walletEvent)
				if len(expected) == 1 {
					return walletEvents, nil
				}
				// Remove found event from the list of expected events
				expected = append(expected[:i], expected[i+1:]...)
				continue infiniteLoop
			}
		}
		for _, event := range optionalEventNames {
			if walletEvent.Type == event && condition != nil {
				_ = condition(&walletEvent)
			}
		}
	}
}

type payloadRes struct {
	eventName walletevent.EventType
	data      []byte
}

// WaitForWalletEventsGetPayloads returns payloads corresponding to the given eventNames in the order they are received for duplicate events
func WaitForWalletEventsGetPayloads(eventQueue chan GoEvent, eventNames []walletevent.EventType, timeoutEach time.Duration) (payloads []payloadRes, err error) {
	walletEvents, err := WaitForWalletEvents(eventQueue, eventNames, timeoutEach, nil)
	if err != nil {
		return nil, err
	}

	payloads = make([]payloadRes, len(walletEvents))
	for i, event := range walletEvents {
		payloads[i] = payloadRes{
			eventName: event.Type,
		}
		if event.Message != "" {
			payloads[i].data = []byte(event.Message)
		}
	}
	return payloads, nil
}

type payloadMapRes struct {
	EventName walletevent.EventType
	JsonData  map[string]interface{}
}

// WaitForWalletEventsGetMap returns parsed JSON payloads; @see WaitForWalletEventsGetPayloads
func WaitForWalletEventsGetMap(eventQueue chan GoEvent, eventNames []walletevent.EventType, timeout time.Duration) (payloads []payloadMapRes, err error) {
	bytePayloads, err := WaitForWalletEventsGetPayloads(eventQueue, eventNames, timeout)
	if err != nil {
		return nil, err
	}
	payloads = make([]payloadMapRes, len(bytePayloads))
	for i, payload := range bytePayloads {
		var mapPayload map[string]interface{}
		if payload.data != nil {
			mapPayload = make(map[string]interface{})
			err = json.Unmarshal(payload.data, &mapPayload)
			if err != nil {
				return nil, err
			}
		}
		payloads[i] = payloadMapRes{
			EventName: payload.eventName,
			JsonData:  mapPayload,
		}
	}
	return payloads, nil
}

func WaitForWalletEventGetPayload[T any](eventQueue chan GoEvent, eventName walletevent.EventType, timeout time.Duration) (payload *T, err error) {
	res, err := WaitForWalletEventsGetPayloads(eventQueue, []walletevent.EventType{eventName}, timeout)
	if err != nil {
		return nil, err
	}
	if res[0].data == nil {
		return nil, nil
	}

	newPayload := new(T)
	err = json.Unmarshal(res[0].data, newPayload)
	if err != nil {
		return nil, err
	}
	return newPayload, nil
}

// WaitForTxDownloaderToFinishForAccountsCondition returns a stateful condition function that checks that at least on account that has been seen with the events until the entire list is seen.
// The loadBlocksAndTransfersCommand.fetchHistoryBlocksForAccount reports only for one account history ready, even though the downloaded history might contain other accounts.
func WaitForTxDownloaderToFinishForAccountsCondition(t *testing.T, accounts []common.Address) func(walletEvent *walletevent.Event) bool {
	return func(walletEvent *walletevent.Event) bool {
		for _, acc := range walletEvent.Accounts {
			for _, a := range accounts {
				if acc == a {
					return true
				}
			}
		}
		return false
	}
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
	done := make(chan string)
	go func() {
		responseJson := statusgo.CallPrivateRPC(string(msgJson))
		if didTimeout {
			log.Warn("Call to CallPrivateRPC returned after timeout", "payload", string(msgJson))
			return
		}

		done <- responseJson
	}()

	select {
	case res := <-done:
		return res, nil
	case <-time.After(timeout):
		didTimeout = true
		return "", fmt.Errorf("timeout waiting for response to statusgo.CallPrivateRPC; payload \"%s\"", string(msgJson))
	}
}

func CallPrivateMethod(method string, params []interface{}) (string, error) {
	return CallPrivateMethodWithTimeout(method, params, 60*time.Second)
}

func CallPrivateMethodAndGetT[T any](method string, params []interface{}) (*T, error) {
	return CallPrivateMethodAndGetTWithTimeout[T](method, params, 60*time.Second)
}

func CallPrivateMethodAndGetTWithTimeout[T any](method string, params []interface{}, timeout time.Duration) (*T, error) {
	resJson, err := CallPrivateMethodWithTimeout(method, params, timeout)
	if err != nil {
		return nil, err
	}

	var res T
	rawJson, err := GetRPCAPIResponseRaw(resJson)
	if err != nil {
		return nil, err
	}

	if err := json.Unmarshal(rawJson, &res); err != nil {
		return nil, fmt.Errorf("failed to unmarshal data: %w", err)
	}

	return &res, nil
}
func CallPrivateMethodAndGetSliceOfT[T any](method string, params []interface{}) ([]T, error) {
	return CallPrivateMethodAndGetSliceOfTWithTimeout[T](method, params, 60*time.Second)
}

func CallPrivateMethodAndGetSliceOfTWithTimeout[T any](method string, params []interface{}, timeout time.Duration) ([]T, error) {
	resJson, err := CallPrivateMethodWithTimeout(method, params, timeout)
	if err != nil {
		return nil, err
	}

	res := make([]T, 0)
	rawJson, err := GetRPCAPIResponseRaw(resJson)
	if err != nil {
		return nil, err
	}

	if err := json.Unmarshal(rawJson, &res); err != nil {
		return nil, fmt.Errorf("failed to unmarshal data: %w", err)
	}

	return res, nil
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
	typeOfT := reflect.TypeOf(res)
	kindOfT := typeOfT.Kind()
	// Check for valid types: pointer, slice, map
	if kindOfT != reflect.Ptr && kindOfT != reflect.Slice && kindOfT != reflect.Map {
		return fmt.Errorf("type T must be a pointer, slice, or map")
	}

	rawJson, err := GetRPCAPIResponseRaw(responseJson)
	if err != nil {
		return err
	}

	if err := json.Unmarshal(rawJson, &res); err != nil {
		return fmt.Errorf("failed to unmarshal data: %w", err)
	}

	return nil
}

func GetRPCAPIResponseRaw(responseJson string) (json.RawMessage, error) {
	errApiResponse := jsonrpcErrorResponse{}
	err := json.Unmarshal([]byte(responseJson), &errApiResponse)
	if err == nil && errApiResponse.Error.Code != 0 {
		return nil, fmt.Errorf("API error: %#v", errApiResponse.Error)
	}

	apiResponse := jsonrpcSuccessfulResponse{}
	err = json.Unmarshal([]byte(responseJson), &apiResponse)
	if err != nil {
		return nil, fmt.Errorf("failed to unmarshal jsonrpcSuccessfulResponse: %w", err)
	}

	return apiResponse.Result, nil
}
