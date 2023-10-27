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
			fmt.Println("@dd Error parsing the event: ", err)
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
			fmt.Println("@dd Error parsing the wallet event: ", err)
			return
		}
		// TODO: continue from here
		if walletEvent.Type == "WalletConnectProposeUserPair" {
			eventQueue <- GoEvent{Name: "proposeUserPair", Payload: walletEvent.Message}
		}
	}
}

func main() {
	// Setup status-go logger
	log.Root().SetHandler(log.StdoutHandler)

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
	w.SetSize(620, 480, webview.HintNone)

	w.Bind("pairSessionProposal", func(sessionProposalJson string) bool {
		sessionReqRes := callPrivateMethod("wallet_wCPairSessionProposal", []interface{}{sessionProposalJson})
		var apiResponse wc.PairSessionResponse
		err = getRPCAPIResponse(sessionReqRes, &apiResponse)
		if err != nil {
			log.Error("Error parsing the API response", "error", err)
			return false
		}

		go func() {
			eventQueue <- GoEvent{Name: "proposeUserPair", Payload: apiResponse}
		}()

		return true
	})

	w.Bind("getConfiguration", func() Configuration {
		projectID := os.Getenv("STATUS_BUILD_WALLET_CONNECT_PROJECT_ID")
		return Configuration{ProjectId: projectID}
	})

	w.Bind("echo", func(message string) bool {
		fmt.Println("@dd WebView:", message)
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

	// Start a local server to serve the files
	http.HandleFunc("/bundle.js", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Cache-Control", "no-store, no-cache, must-revalidate, post-check=0, pre-check=0")
		http.ServeFile(w, r, "../../../ui/app/AppLayouts/Wallet/views/walletconnect/sdk/generated/bundle.js")
	})

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Cache-Control", "no-store, no-cache, must-revalidate, post-check=0, pre-check=0")
		http.ServeFile(w, r, "./index.html")
	})

	go http.ListenAndServe(":8080", nil)

	w.Navigate("http://localhost:8080")
	w.Run()
}
