package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"os/signal"
	"strings"
	"syscall"
)

type Node struct {
	enr     string
	name    string
	rpcPort int
}

type ClusterConfig struct {
	Enabled                  bool
	Fleet                    string
	StaticNodes              []string
	BootNodes                []string
	TrustedMailServers       []string
	PushNotificationsServers []string
}

type Mailserver struct {
	ID      string
	Address string
	Fleet   string
	Version int
}

func main() {
	// Only supports 1 boot node
	mailserverNum := flag.Int("mailservers", 1, "number of mailservers")
	whisperNum := flag.Int("whisper", 1, "number of whisper nodes")
	flag.Parse()

	fmt.Println("Starting a bootnode...")
	bootnodeENR, err := startBootnode()
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println("Bootnode enr: ", bootnodeENR)
	defer stopBootnode()

	nodeCnt := 0
	var mailservers []Node
	for i := 0; i < *mailserverNum; i++ {
		fmt.Println(fmt.Sprintf("Starting mailserver #%d...", i+1))
		node, err := startNode(nodeCnt, bootnodeENR, true)
		if err != nil {
			stopNodes(mailservers)
			fmt.Println("Could not start node", err)
			return
		}
		fmt.Println(fmt.Sprintf("Mailserver #%d enr: %s", i+1, node.enr))
		mailservers = append(mailservers, node)
		nodeCnt++
	}

	var whisperNodes []Node
	for i := 0; i < *whisperNum; i++ {
		fmt.Println(fmt.Sprintf("Starting whisperNode #%d...", i+1))
		node, err := startNode(nodeCnt, bootnodeENR, false)
		if err != nil {
			stopNodes(whisperNodes)
			return
		}
		fmt.Println(fmt.Sprintf("Whisper #%d enr: %s", i+1, node.enr))
		whisperNodes = append(whisperNodes, node)
		nodeCnt++
	}

	for _, node := range append(mailservers, whisperNodes...) {
		fmt.Println("Adding peers to ", node.name)
		for _, peer := range append(mailservers, whisperNodes...) {
			addPeer(peer.enr, node.rpcPort)
		}
	}

	// Output config

	cluster := ClusterConfig{
		Enabled:   true,
		Fleet:     "eth.prod",
		BootNodes: []string{bootnodeENR},
	}
	for _, node := range mailservers {
		cluster.TrustedMailServers = append(cluster.TrustedMailServers, node.enr)
	}
	for _, node := range whisperNodes {
		cluster.StaticNodes = append(cluster.StaticNodes, node.enr)
	}

	clusterJSON, _ := json.Marshal(cluster)
	fmt.Println("\nNew cluster config:\n", string(clusterJSON))

	// ===============================================================================
	// Replacing status-go fleets.go file
	statusGoMailserverFleet := ""
	mailserverStrTemplate := `            Mailserver {
                ID: "%s",
                Address: "%s",
                Fleet: "eth.prod",
                Version: 1,
            },
`
	for _, m := range mailservers {
		statusGoMailserverFleet += fmt.Sprintf(mailserverStrTemplate, m.name, m.enr)
	}

	b, _ := os.ReadFile("./fleet.go.template")
	statusGoMailserverFleet = strings.Replace(string(b), "%MAILSERVER_LIST%", statusGoMailserverFleet, -1)

	err = os.WriteFile("../../vendor/status-go/services/mailservers/fleet.go", []byte(statusGoMailserverFleet), 0600)
	if err != nil {
		fmt.Println("Could not write fleet in status-go")
		stopNodes(mailservers)
		stopNodes(whisperNodes)
		return
	}
	fmt.Println("\nvendor/status-go/services/mailservers/fleet.go was updated")

	// =====================================================================================================
	// Replacing status-desktop fleets.go file
	b, _ = os.ReadFile("./fleets.json.template")

	fleetsJSON := strings.Replace(string(b), "%BOOTNODE%", bootnodeENR, -1)

	desktopMailserverFleet := ""
	for _, m := range mailservers {
		desktopMailserverFleet += fmt.Sprintf("\"%s\": \"%s\",", m.name, m.enr)
	}
	desktopMailserverFleet = strings.TrimSuffix(desktopMailserverFleet, ",")
	fleetsJSON = strings.Replace(fleetsJSON, "%MAILSERVER_LIST%", desktopMailserverFleet, -1)

	desktopWhisperFleet := ""
	for _, m := range whisperNodes {
		desktopWhisperFleet += fmt.Sprintf("\"%s\": \"%s\",", m.name, m.enr)
	}
	desktopWhisperFleet = strings.TrimSuffix(desktopWhisperFleet, ",")
	fleetsJSON = strings.Replace(fleetsJSON, "%WHISPER_LIST%", desktopWhisperFleet, -1)

	err = os.WriteFile("../../fleets.json", []byte(fleetsJSON), 0600)
	if err != nil {
		fmt.Println("Could not write fleet in status-desktop")
		stopNodes(mailservers)
		stopNodes(whisperNodes)
		return
	}
	fmt.Println("fleets.json was updated")

	fmt.Println("\nDONE! rebuild status-go and desktop to use this new fleet")

	// Wait for a SIGINT or SIGTERM signal
	fmt.Println("\n\nPress Crtl+C to shutdown nodes")
	ch := make(chan os.Signal, 1)
	signal.Notify(ch, syscall.SIGINT, syscall.SIGTERM)
	<-ch
	fmt.Println("\nReceived signal, shutting down...")

	stopNodes(mailservers)
	stopNodes(whisperNodes)
}

func startBootnode() (string, error) {
	envVars := os.Environ()
	envVars = append(envVars, "CONTAINER_NAME=test-bootnode")
	envVars = append(envVars, "COMPOSE_UP_FLAGS=-f ./docker-compose.yml -f ../../../../../scripts/localfleet/docker-compose-host.yml")

	e := exec.Command("make", "-C", "../../vendor/status-go", "run-bootnode-docker")
	var stderr bytes.Buffer
	e.Stderr = &stderr
	e.Env = envVars
	if err := e.Run(); err != nil {
		return "", fmt.Errorf("could not start bootnode: %w, %s", err, stderr.String())
	}

	e = exec.Command("make", "-s", "-C", "../../vendor/status-go/_assets/compose/bootnode", "enode")
	e.Env = envVars
	var out bytes.Buffer
	e.Stdout = &out
	err := e.Run()
	if err != nil {
		return "", fmt.Errorf("could not obtain bootnode enr: %w", err)
	}

	return strings.TrimSpace(out.String()), nil
}

func stopBootnode() {
	fmt.Println("Stopping bootnode...")
	envVars := os.Environ()
	envVars = append(envVars, "CONTAINER_NAME=test-bootnode")
	e := exec.Command("make", "-C", "../../vendor/status-go/_assets/compose/bootnode", "stop")
	e.Env = envVars
	err := e.Run()
	if err != nil {
		fmt.Println(fmt.Errorf("could not stop bootnode: %w", err))
	}
}

func startNode(i int, bootnodeENR string, mailserver bool) (Node, error) {
	envVars := os.Environ()

	name := fmt.Sprintf("%s-%d", "test-mailserver", i)
	if !mailserver {
		name = fmt.Sprintf("%s-%d", "test-whisper", i)
		envVars = append(envVars, "MAILSERVER_ENABLED=false")
	}

	rpcPort := 8656 + i

	envVars = append(envVars, fmt.Sprintf("RPC_HOST=%s", "0.0.0.0"))
	envVars = append(envVars, fmt.Sprintf("LISTEN_PORT=%d", 30310+i))
	envVars = append(envVars, fmt.Sprintf("METRICS_PORT=%d", 9191+i))
	envVars = append(envVars, fmt.Sprintf("RPC_PORT=%d", rpcPort))
	envVars = append(envVars, fmt.Sprintf("CONTAINER_NAME=%s", name))
	envVars = append(envVars, fmt.Sprintf("DATA_PATH=/var/tmp/%s", name))
	envVars = append(envVars, fmt.Sprintf("BOOTNODE=%s", strings.TrimSpace(bootnodeENR)))
	envVars = append(envVars, "CONTAINER_IMG=statusteam/status-go")
	envVars = append(envVars, "LOG_LEVEL=DEBUG")
	envVars = append(envVars, "CONTAINER_TAG=v0.84.0")
	envVars = append(envVars, "API_MODULES=eth,web3,admin,waku,wakuext")
	envVars = append(envVars, "REGISTER_TOPIC=whispermail")
	envVars = append(envVars, "MAIL_PASSWORD=status-offline-inbox")

	e := exec.Command("./gen-config.sh")
	e.Env = envVars
	if err := e.Run(); err != nil {
		return Node{}, fmt.Errorf("could not generate config: %w", err)
	}

	e = exec.Command("docker-compose", "-p", name, "-f", "../../vendor/status-go/_assets/compose/mailserver/docker-compose.yml", "-f", "./docker-compose-host.yml", "up", "-d")
	e.Env = envVars
	var stderr bytes.Buffer
	e.Stderr = &stderr

	if err := e.Run(); err != nil {
		return Node{}, fmt.Errorf("could not start mailserver: %w", errors.New(stderr.String()))
	}

	e = exec.Command("make", "-s", "-C", "../../vendor/status-go/_assets/compose/mailserver", "enode")
	e.Env = envVars
	var out bytes.Buffer
	e.Stdout = &out
	err := e.Run()
	if err != nil {
		return Node{}, fmt.Errorf("could not obtain mailserver #%d enr: %w", i, err)
	}

	return Node{
		enr:     strings.Replace(strings.TrimSpace(out.String()), ":status-offline-inbox", "", -1),
		name:    name,
		rpcPort: 8656 + i,
	}, nil
}

func stopNodes(nodes []Node) {
	for _, node := range nodes {
		fmt.Println(fmt.Sprintf("Stopping node %s...", node.name))
		envVars := os.Environ()
		envVars = append(envVars, fmt.Sprintf("CONTAINER_NAME=%s", node.name))
		e := exec.Command("docker-compose", "-p", node.name, "down")
		e.Env = envVars
		if err := e.Run(); err != nil {
			fmt.Println(fmt.Errorf("could not stop node #%s: %w", node.name, err))
		}
	}
}

func addPeer(peerENR string, port int) {
	envVars := os.Environ()

	envVars = append(envVars, fmt.Sprintf("RPC_HOST=%s", "0.0.0.0"))
	envVars = append(envVars, fmt.Sprintf("RPC_PORT=%d", port))

	e := exec.Command("../../vendor/status-go/_assets/scripts/rpc.sh", "admin_addPeer", peerENR)
	e.Env = envVars
	var out bytes.Buffer
	e.Stdout = &out
	err := e.Run()
	if err != nil {
		fmt.Println("could not add peer: ", err)
	}
}
