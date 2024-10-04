import { Core } from "@walletconnect/core";
import { WalletKit } from "@reown/walletkit";

// import the builder util
import { buildApprovedNamespaces, getSdkError } from "@walletconnect/utils";
import { formatJsonRpcResult, formatJsonRpcError } from "@walletconnect/jsonrpc-utils";

window.wc = {
    core: null,
    walletKit: null,
    statusObject: null,

    init: function (projectId) {
        return new Promise(async (resolve, reject) => {
            if (!window.statusq) {
                const errMsg = 'missing window.statusq! Forgot to execute "ui/app/AppLayouts/Wallet/services/dapps/helpers.js" first?'
                console.error(errMsg);
                reject(errMsg);
            }

            if (window.statusq.error) {
                const errMsg = "Failed initializing WebChannel: " + window.statusq.error
                console.error(errMsg);
                reject(errMsg);
            }

            wc.statusObject = window.statusq.channel.objects.statusObject;
            if (!wc.statusObject) {
                const errMsg = "Failed initializing WebChannel or initialization not run"
                console.error(errMsg);
                reject(errMsg);
            }

            try {
                const coreInst = new Core({
                    projectId: projectId,
                });
                window.wc.walletKit = await WalletKit.init({
                    core: coreInst, // <- pass the shared `core` instance
                    metadata: {
                        name: "Status",
                        description: "Status Wallet",
                        url: "http://localhost",
                        icons: ['https://avatars.githubusercontent.com/u/11767950'],
                    },
                });
                window.wc.core = coreInst

                // connect session responses https://specs.walletconnect.com/2.0/specs/clients/sign/session-events#events
                window.wc.walletKit.on("session_proposal", (details) => {
                    wc.statusObject.onSessionProposal(details)
                });

                window.wc.walletKit.on("session_update", (details) => {
                    wc.statusObject.onSessionUpdate(details)
                });

                window.wc.walletKit.on("session_extend", (details) => {
                    wc.statusObject.onSessionExtend(details)
                });

                window.wc.walletKit.on("session_ping", (details) => {
                    wc.statusObject.onSessionPing(details)
                });

                window.wc.walletKit.on("session_delete", (details) => {
                    wc.statusObject.onSessionDelete(details)
                });

                window.wc.walletKit.on("session_expire", (details) => {
                    wc.statusObject.onSessionExpire(details)
                });

                window.wc.walletKit.on("session_request", (details) => {
                    wc.statusObject.onSessionRequest(details)
                });

                window.wc.walletKit.on("session_request_sent", (details) => {
                    wc.statusObject.onSessionRequestSent(details)
                });

                window.wc.walletKit.on("session_event", (details) => {
                    wc.statusObject.onSessionEvent(details)
                });

                window.wc.walletKit.on("proposal_expire", (details) => {
                    wc.statusObject.onProposalExpire(details)
                });

                // Debug event handlers
                window.wc.walletKit.on("pairing_expire", (event) => {
                    wc.statusObject.echo("debug", `WC unhandled event: "pairing_expire" ${JSON.stringify(event)}`);
                    // const { topic } = event;
                });
                window.wc.walletKit.on("session_request_expire", (event) => {
                    const { id } = event
                    wc.statusObject.onSessionRequestExpire(id)
                });
                window.wc.core.relayer.on("relayer_connect", () => {
                    wc.statusObject.echo("debug", `WC unhandled event: "relayer_connect" connection to the relay server is established`);
                })
                window.wc.core.relayer.on("relayer_disconnect", () => {
                    wc.statusObject.echo("debug", `WC unhandled event: "relayer_disconnect" connection to the relay server is lost`);
                })

                resolve("");
            } catch(error) {
                reject(error)
            }
        });
    },

    // TODO: there is a corner case when attempting to pair with a link that is already paired or was rejected won't trigger any event back
    pair: async function (uri) {
        await window.wc.walletKit.pair({ uri });
    },

    getPairings: function () {
        return window.wc.walletKit.core.pairing.getPairings();
    },

    getActiveSessions: function () {
        return window.wc.walletKit.getActiveSessions();
    },

    disconnect: async function (topic) {
        await window.wc.walletKit.disconnectSession(
            {
                topic,
                reason: getSdkError('USER_DISCONNECTED')
            }
        );
    },

    ping: async function (topic) {
        await window.wc.walletKit.engine.signClient.ping({ topic });
    },

    buildApprovedNamespaces: async function (params, supportedNamespaces) {
        return buildApprovedNamespaces({
            proposal: params,
            supportedNamespaces: supportedNamespaces,
        });
    },

    approveSession: async function (sessionProposal, approvedNamespaces) {
        const { id, params } = sessionProposal;

        const { relays } = params

        return await window.wc.walletKit.approveSession(
            {
                id,
                relayProtocol: relays[0].protocol,
                namespaces: approvedNamespaces,
            }
        );
    },

    rejectSession: async function (id) {
        await window.wc.walletKit.rejectSession(
            {
                id,
                reason: getSdkError("USER_REJECTED"), // TODO USER_REJECTED_METHODS, USER_REJECTED_CHAINS, USER_REJECTED_EVENTS
            }
        );
    },

    respondSessionRequest: async function (topic, id, signature) {
        const response = formatJsonRpcResult(id, signature)

        await window.wc.walletKit.respondSessionRequest(
            {
                topic: topic,
                response: response
            }
        );
    },

    rejectSessionRequest: async function (topic, id, error = false) {
        const errorType = error ? "SESSION_SETTLEMENT_FAILED" : "USER_REJECTED";

        await window.wc.walletKit.respondSessionRequest(
            {
                topic: topic,
                response: formatJsonRpcError(id, getSdkError(errorType)),
            }
        );
    },
};
