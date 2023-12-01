package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"

	"github.com/ethereum/go-ethereum/log"
	webview "github.com/webview/webview_go"

	statusgo "github.com/status-im/status-go/mobile"
	wc "github.com/status-im/status-go/services/wallet/walletconnect"
	"github.com/status-im/status-go/services/wallet/walletevent"
	"github.com/status-im/status-go/signal"
)

// l is used for local logging
var l log.Logger

func init() {
	l = log.New()
	l.SetHandler(log.CallerFileHandler(log.StreamHandler(os.Stdout, log.TerminalFormat(false))))
}

type PairResult struct {
	SessionProposal string `json:"sessionProposal"`
}

type Configuration struct {
	ProjectId string `json:"projectId"`
}

type GoEvent struct {
	Name    string      `json:"name"`
	Payload interface{} `json:"payload"`
}

var eventQueue chan GoEvent = make(chan GoEvent, 10000)

func signalHandler(jsonEvent string) {
	// parse signal.Envelope from jsonEvent
	envelope := signal.Envelope{}
	err := json.Unmarshal([]byte(jsonEvent), &envelope)
	if err != nil {
		// check for error in json
		apiResponse := statusgo.APIResponse{}
		err = json.Unmarshal([]byte(jsonEvent), &apiResponse)
		if err != nil {
			log.Error("Error parsing the signal event: ", err)
			return
		}
	}

	if envelope.Type == signal.EventNodeReady {
		eventQueue <- GoEvent{Name: "nodeReady", Payload: ""}
	} else if envelope.Type == "wallet" {
		// parse envelope.Event to json
		walletEvent := walletevent.Event{}
		err := json.Unmarshal([]byte(jsonEvent), &walletEvent)
		if err != nil {
			log.Error("Error parsing the wallet event: ", err)
			return
		}
		// TODO: continue from here
		// if walletEvent.Type == "WalletConnectProposeUserPair" {
		// 	eventQueue <- GoEvent{Name: "proposeUserPair", Payload: walletEvent.Message}
		// }
	}
}

func main() {
	// Setup status-go logger
	log.Root().SetHandler(log.CallerFileHandler(log.StdoutHandler))

	signal.SetDefaultNodeNotificationHandler(signalHandler)
	config, nodeConfigJson, userFolder, err := processConfigArgs()
	if err != nil {
		panic(err)
	}

	// Login to first account
	err = loginToAccount(config.HashedPassword, userFolder, nodeConfigJson)
	if err != nil {
		panic(err)
	}

	// Start WebView
	w := webview.New(true)
	defer w.Destroy()
	w.SetTitle("WC status-go test")
	w.SetSize(1280, 1024, webview.HintNone)

	w.Bind("sessionRequest", func(sessionRequestJson, hashedPassword string) bool {
		fmt.Println("sessionRequestJson:", sessionRequestJson)
		sessionReqRes := callPrivateMethod("wallet_wCSessionRequest", []interface{}{sessionRequestJson})
		fmt.Println("sessionReqRes:", sessionReqRes)
		var apiResponse wc.SessionRequestResponse
		err = getRPCAPIResponse(sessionReqRes, &apiResponse)
		if err != nil {
			l.Error("Error parsing wallet_wCSessionRequest response", "error", err)
			return false
		}
		if apiResponse.SignOnKeycard {
			l.Error("SignOnKeycard is not supported in this test")
			return false
		}

		sessionReqRes = callPrivateMethod("wallet_wCSignMessage", []interface{}{apiResponse.MessageToSign, apiResponse.Address, hashedPassword})
		fmt.Println("sessionReqRes:", sessionReqRes)
		var signature string
		err = getRPCAPIResponse(sessionReqRes, &signature)
		if err != nil {
			l.Error("Error parsing wallet_wCSignMessage response", "error", err)
			return false
		}

		// TODO: process the request type ...

		go func() {
			eventQueue <- GoEvent{Name: "sessionRequestResult", Payload: apiResponse}
		}()

		return true
	})

	w.Bind("getConfiguration", func() Configuration {
		projectID := os.Getenv("STATUS_BUILD_WALLET_CONNECT_PROJECT_ID")
		if projectID == "" {
			projectID = "87815d72a81d739d2a7ce15c2cfdefb3"
		}
		return Configuration{ProjectId: projectID}
	})

	w.Bind("echo", func(message string) bool {
		fmt.Println("<D> WebView:", message)
		return true
	})

	// Setup go to webview event queue
	w.Bind("popNextEvent", func() GoEvent {
		select {
		case event := <-eventQueue:
			return event
		default:
			return GoEvent{Name: "", Payload: ""}
		}
	})

	mockStatusObject(w)
	mockController(w)

	// Start a local server to serve the files
	http.HandleFunc("/bundle.js", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Cache-Control", "no-store, no-cache, must-revalidate, post-check=0, pre-check=0")
		http.ServeFile(w, r, "../../../../ui/app/AppLayouts/Wallet/views/walletconnect/sdk/generated/bundle.js")
	})

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Cache-Control", "no-store, no-cache, must-revalidate, post-check=0, pre-check=0")
		http.ServeFile(w, r, "./index.html")
	})

	go http.ListenAndServe(":8081", nil)

	w.Navigate("http://localhost:8081")
	w.Run()
}

func mockController(w webview.WebView) {
	w.Bind("controller_recordSuccessfulPairing", func(sessionProposalJson string) {
		fmt.Println("controller_recordSuccessfulPairing:", sessionProposalJson)
		sessionProposalRes := callPrivateMethod("wallet_wCRecordSuccessfulPairing", []interface{}{sessionProposalJson})
		var apiResponse wc.PairSessionResponse
		err := getRPCAPIResponse(sessionProposalRes, &apiResponse)
		if err != nil {
			l.Error("Error parsing the API response", "error", err)
		}
	})

	w.Bind("controller_changePairingState", func(topic string, active bool) {
		sessionProposalRes := callPrivateMethod("wallet_wCChangePairingState", []interface{}{topic, active})
		var apiResponse wc.PairSessionResponse
		err := getRPCAPIResponse(sessionProposalRes, &apiResponse)
		if err != nil {
			l.Error("Error parsing the API response", "error", err)
		}
	})
}

func mockStatusObject(w webview.WebView) {
	w.Bind("statusObject_sdkInitialized", func(error string) {
		// All OK here
	})
	w.Bind("statusObject_onSessionProposal", func(sessionProposalJson string) bool {
		sessionProposalRes := callPrivateMethod("wallet_wCPairSessionProposal", []interface{}{sessionProposalJson})
		var apiResponse wc.PairSessionResponse
		err := getRPCAPIResponse(sessionProposalRes, &apiResponse)
		if err != nil {
			l.Error("Error parsing the API response", "error", err)
			return false
		}

		go func() {
			eventQueue <- GoEvent{Name: "proposeUserPair", Payload: apiResponse}
		}()

		return true
	})
	w.Bind("statusObject_onSessionRequest", func(sessionRequestJson string) bool {
		sessionReqRes := callPrivateMethod("wallet_wCSessionRequest", []interface{}{sessionRequestJson})
		var apiResponse wc.SessionRequestResponse
		err := getRPCAPIResponse(sessionReqRes, &apiResponse)
		if err != nil {
			l.Error("Error parsing the API response", "error", err)
			return false
		}
		return true
	})

	//     function onSessionUpdate(details)
	//     function onSessionExtend(details)
	//     function onSessionPing(details)
	//     function onSessionDelete(details)
	//     function onSessionExpire(details)
	//     function onSessionRequestSent(details)
	//     function onSessionEvent(details)
	//     function onProposalExpire(details)
}
