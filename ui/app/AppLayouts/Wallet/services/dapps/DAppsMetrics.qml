import QtQml 2.15

import shared.stores 1.0
import StatusQ.Core.Utils 0.1 as SQUtils

import utils 1.0

SQUtils.QObject {
    id: root

    required property MetricsStore metricsStore

    enum DAppsHealthState {
        WcAvailable,
        WcUnavailable,
        ChainsDown,
        NetworkDown,
        PairError,
        ConnectError,
        SignError
    }

    enum DAppsNavigationAction {
        DAppListOpened,
        DAppConnectInitiated,
        DAppDisconnectInitiated,
        DAppPairInitiated
    }

    enum DAppsConnectFlows {
        ProposalReceived,
        ProposalAccepted,
        ProposalRejected,
        Connected,
        Disconnected
    }

    enum DAppsSignFlows {
        SignRequestReceived,
        SignRequestAccepted,
        SignRequestRejected
    }
    //checked
    function logHealthEvent(healthState /*DAppsHealthState*/, error = "") {
        try {
            const { eventName, eventValue } = d.buildDappsHealthEvent(healthState, error)
            metricsStore.addCentralizedMetricIfEnabled(eventName, eventValue)
        } catch (e) {
            console.error("Failed to log dapps health check", e)
        }
    }

    function logNavigationEvent(navigationAction /*DAppsNavigationAction*/, connector /*Constants.DAppConnectors*/) {
        try {
            const { eventName, eventValue } = d.buildDappsNavigationEvent(navigationAction, connector)
            metricsStore.addCentralizedMetricIfEnabled(eventName, eventValue)
        } catch (e) {
            console.error("Failed to log dapps navigation", e)
        }
    }

    function logConnectionProposal(networks, methods, dapp, connector) {
        try {
            const { eventName, eventValue } = d.buildDAppConnectionEvent(DAppsMetrics.DAppsConnectFlows.ProposalReceived, networks, methods, dapp, connector, false)
            metricsStore.addCentralizedMetricIfEnabled(eventName, eventValue)
        } catch (e) {
            console.error("Failed to log dapps session proposal", e)
        }
    }

    function logSiweConnectionProposal(networks, dapp, connector) {
        try {
            const { eventName, eventValue } = d.buildDAppConnectionEvent(DAppsMetrics.DAppsConnectFlows.ProposalReceived, networks, [], dapp, connector, true)
            metricsStore.addCentralizedMetricIfEnabled(eventName, eventValue)
        } catch (e) {
            console.error("Failed to log dapps session proposal", e)
        }
    }

    function logConnectionProposalAccepted(dapp, networks, connector) {
        try {
            const { eventName, eventValue } = d.buildDAppConnectionEvent(DAppsMetrics.DAppsConnectFlows.ProposalAccepted, networks, [], dapp, connector, null)
            metricsStore.addCentralizedMetricIfEnabled(eventName, eventValue)
        } catch (e) {
            console.error("Failed to log dapps session proposal accepted", e)
        }
    }

    function logConnectionProposalRejected(dapp, connector) {
        try {
            const { eventName, eventValue } = d.buildDAppConnectionEvent(DAppsMetrics.DAppsConnectFlows.ProposalRejected, [], [], dapp, connector, null)
            metricsStore.addCentralizedMetricIfEnabled(eventName, eventValue)
        } catch (e) {
            console.error("Failed to log dapps session proposal rejected", e)
        }
    }

    function logDAppConnected(dapp, connector) {
        try {
            const { eventName, eventValue } = d.buildDAppConnectionEvent(DAppsMetrics.DAppsConnectFlows.Connected, [], [], dapp, connector, null)
            metricsStore.addCentralizedMetricIfEnabled(eventName, eventValue)
        } catch (e) {
            console.error("Failed to log dapps session connected", e)
        }
    }

    function logDAppDisconnected(dapp, connector) {
        try {
            const { eventName, eventValue } = d.buildDAppConnectionEvent(DAppsMetrics.DAppsConnectFlows.Disconnected, [], [], dapp, connector, null)
            metricsStore.addCentralizedMetricIfEnabled(eventName, eventValue)
        } catch (e) {
            console.error("Failed to log dapps session disconnected", e)
        }
    }

    function logSignRequestReceived(connector, method, chainId, dapp) {
        try {
            const { eventName, eventValue } = d.buildDAppSignEvent(DAppsMetrics.DAppsSignFlows.SignRequestReceived, connector, method, chainId, dapp)
            metricsStore.addCentralizedMetricIfEnabled(eventName, eventValue)
        } catch (e) {
            console.error("Failed to log dapps sign request received", e)
        }
    }

    function logSignRequestAccepted(connector, method, chainId, dapp) {
        try {
            const { eventName, eventValue } = d.buildDAppSignEvent(DAppsMetrics.DAppsSignFlows.SignRequestAccepted, connector, method, chainId, dapp)
            metricsStore.addCentralizedMetricIfEnabled(eventName, eventValue)
        } catch (e) {
            console.error("Failed to log dapps sign request accepted", e)
        }
    }

    function logSignRequestRejected(connector, method, chainId, dapp) {
        try {
            const { eventName, eventValue } = d.buildDAppSignEvent(DAppsMetrics.DAppsSignFlows.SignRequestRejected, connector, method, chainId, dapp)
            metricsStore.addCentralizedMetricIfEnabled(eventName, eventValue)
        } catch (e) {
            console.error("Failed to log dapps sign request rejected", e)
        }
    }

    SQUtils.QObject {
        id: d

        readonly property var healthStateMap: new Map([
            [DAppsMetrics.DAppsHealthState.WcAvailable, "wc-available"],
            [DAppsMetrics.DAppsHealthState.WcUnavailable, "wc-unavailable"],
            [DAppsMetrics.DAppsHealthState.ChainsDown, "chains-down"],
            [DAppsMetrics.DAppsHealthState.NetworkDown, "network-down"],
            [DAppsMetrics.DAppsHealthState.PairError, "pair-error"],
            [DAppsMetrics.DAppsHealthState.ConnectError, "connect-error"],
            [DAppsMetrics.DAppsHealthState.SignError, "sign-error"]
        ])

        readonly property var navigationActionMap: new Map([
            [DAppsMetrics.DAppsNavigationAction.DAppListOpened, "dapp-list-opened"],
            [DAppsMetrics.DAppsNavigationAction.DAppConnectInitiated, "dapp-connect-initiated"],
            [DAppsMetrics.DAppsNavigationAction.DAppDisconnectInitiated, "dapp-disconnect-initiated"],
            [DAppsMetrics.DAppsNavigationAction.DAppPairInitiated, "dapp-pair-initiated"]
        ])

        readonly property var connectorMap: new Map([
            [Constants.DAppConnectors.WalletConnect, "wallet-connect"],
            [Constants.DAppConnectors.StatusConnect, "browser-connect"]
        ])

        readonly property var dappConnectFlowMap: new Map([
            [DAppsMetrics.DAppsConnectFlows.ProposalReceived, "proposal-received"],
            [DAppsMetrics.DAppsConnectFlows.ProposalAccepted, "proposal-accepted"],
            [DAppsMetrics.DAppsConnectFlows.ProposalRejected, "proposal-rejected"],
            [DAppsMetrics.DAppsConnectFlows.Connected, "connected"],
            [DAppsMetrics.DAppsConnectFlows.Disconnected, "disconnected"]
        ])

        readonly property var dappSignFlowMap: new Map([
            [DAppsMetrics.DAppsSignFlows.SignRequestReceived, "sign-received"],
            [DAppsMetrics.DAppsSignFlows.SignRequestAccepted, "sign-accepted"],
            [DAppsMetrics.DAppsSignFlows.SignRequestRejected, "sign-rejected"]
        ])

        function buildDappsHealthEvent(healthState, error) {
            if (!d.healthStateMap.has(healthState)) {
                throw new Error("Invalid health state")
            }
            let state = d.healthStateMap.get(healthState)

            return {
                eventName: "dapps-health",
                eventValue: {
                    state,
                    error
                }
            }
        }

        function buildDappsNavigationEvent(navigationAction, connector) {
            if (!d.navigationActionMap.has(navigationAction)) {
                throw new Error("Invalid navigation action")
            }

            const action = d.navigationActionMap.get(navigationAction)
            const connectorStr = d.connectorMap.has(connector) ? d.connectorMap.get(connector) : ""

            return {
                eventName: "dapps-navigation",
                eventValue: {
                    action,
                    connector: connectorStr
                }
            }
        }

        function buildDAppConnectionEvent(flow, networks, methods, dapp, connector, isSiwe) {
            if (!d.dappConnectFlowMap.has(flow)) {
                throw new Error("Invalid dapp connect flow")
            }

            const connectorStr = d.connectorMap.has(connector) ? d.connectorMap.get(connector) : ""

            return {
                eventName: "dapps-connection",
                eventValue: {
                    flow: d.dappConnectFlowMap.get(flow),
                    networks,
                    methods,
                    dapp,
                    connector: connectorStr,
                    isSiwe
                }
            }
        }

        function buildDAppSignEvent(flow, connector, method, chain, dapp) {
            if (!d.dappSignFlowMap.has(flow)) {
                throw new Error("Invalid dapp sign flow")
            }

            const connectorStr = d.connectorMap.has(connector) ? d.connectorMap.get(connector) : ""

            return {
                eventName: "dapps-sign",
                eventValue: {
                    flow: d.dappSignFlowMap.get(flow),
                    connector: connectorStr,
                    method,
                    chain,
                    dapp
                }
            }
        }
    }
}