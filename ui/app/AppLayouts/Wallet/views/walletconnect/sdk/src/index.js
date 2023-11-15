import { Core } from "@walletconnect/core";
import { Web3Wallet } from "@walletconnect/web3wallet";

import AuthClient from '@walletconnect/auth-client'

// import the builder util
import { buildApprovedNamespaces, getSdkError } from "@walletconnect/utils";
import { formatJsonRpcResult, formatJsonRpcError } from "@walletconnect/jsonrpc-utils";

window.wc = {
    core: null,
    web3wallet: null,
    authClient: null,
    statusObject: null,

    init: function (projectId) {
        (async () => {
            if (!window.statusq) {
                console.error('missing window.statusq! Forgot to execute "ui/StatusQ/src/StatusQ/Components/private/qwebchannel/helpers.js" first?');
                return;
            }

            if (window.statusq.error) {
                console.error("Failed initializing WebChannel: " + window.statusq.error);
                return;
            }

            wc.statusObject = window.statusq.channel.objects.statusObject;
            if (!wc.statusObject) {
                console.error("Failed initializing WebChannel or initialization not run");
                return;
            }

            window.wc.core = new Core({
                projectId: projectId,
            });

            window.wc.web3wallet = await Web3Wallet.init({
                core: window.wc.core, // <- pass the shared `core` instance
                metadata: {
                    name: "Status",
                    description: "Status Wallet",
                    url: "http://localhost",
                    icons: ['https://status.im/img/status-footer-logo.svg'],
                },
            });

            window.wc.authClient = await AuthClient.init({
                projectId: projectId,
                metadata: window.wc.web3wallet.metadata,
            });

            // connect session responses https://specs.walletconnect.com/2.0/specs/clients/sign/session-events#events
            window.wc.web3wallet.on("session_proposal", async (details) => {
                wc.statusObject.onSessionProposal(details)
            });

            window.wc.web3wallet.on("session_update", async (details) => {
                wc.statusObject.onSessionUpdate(details)
            });

            window.wc.web3wallet.on("session_extend", async (details) => {
                wc.statusObject.onSessionExtend(details)
            });

            window.wc.web3wallet.on("session_ping", async (details) => {
                wc.statusObject.onSessionPing(details)
            });

            window.wc.web3wallet.on("session_delete", async (details) => {
                wc.statusObject.onSessionDelete(details)
            });

            window.wc.web3wallet.on("session_expire", async (details) => {
                wc.statusObject.onSessionExpire(details)
            });

            window.wc.web3wallet.on("session_request", async (details) => {
                wc.statusObject.onSessionRequest(details)
            });

            window.wc.web3wallet.on("session_request_sent", async (details) => {
                wc.statusObject.onSessionRequestSent(details)
            });

            window.wc.web3wallet.on("session_event", async (details) => {
                wc.statusObject.onSessionEvent(details)
            });

            window.wc.web3wallet.on("proposal_expire", async (details) => {
                wc.statusObject.onProposalExpire(details)
            });

            wc.statusObject.sdkInitialized("");
        })();

        return { result: "ok", error: "" };
    },

    // TODO: there is a corner case when attempting to pair with a link that is already paired or was rejected won't trigger any event back
    pair: function (uri) {
        return {
            result: window.wc.web3wallet.pair({ uri }),
            error: ""
        };
    },

    getPairings: function () {
        return {
            result: window.wc.core.pairing.getPairings(),
            error: ""
        };
    },

    disconnect: function (topic) {
        return {
            result: window.wc.core.pairing.disconnect({ topic: topic }),
            error: ""
        };
    },

    approvePairSession: function (sessionProposal, supportedNamespaces) {
        const { id, params } = sessionProposal;

        const approvedNamespaces = buildApprovedNamespaces({
            proposal: params,
            supportedNamespaces: supportedNamespaces,
        });

        return {
            result: window.wc.web3wallet.approveSession({
                id,
                namespaces: approvedNamespaces,
            }),
            error: ""
        };
    },
    rejectPairSession: function (id) {
        return {
            result: window.wc.web3wallet.rejectSession({
                id: id,
                reason: getSdkError("USER_REJECTED"), // TODO USER_REJECTED_METHODS, USER_REJECTED_CHAINS, USER_REJECTED_EVENTS
            }),
            error: ""
        };
    },

    auth: function (uri) {
        return {
            result: window.wc.authClient.core.pairing.pair({ uri }),
            error: ""
        };
    },

    approveAuth: function (authProposal) {
        const { id, params } = authProposal;

        // TODO: source user’s address
        const iss = `did:pkh:eip155:1:${"0x0123456789"}`;

        // format the cacao payload with the user’s address
        const message = window.wc.authClient.formatMessage(params.cacaoPayload, iss);

        // TODO: signature
        const signature = "0x123456789"

        return {
            result: window.wc.authClient.respond(
            {
                id: id,
                signature: {
                    s: signature,
                    t: "eip191",
                },
            },
            iss),
            error: ""
        };
    },

    rejectAuth: function (id) {
        return {
            result: window.wc.authClient.reject(id),
            error: ""
        };
    },

    respondSessionRequest: function (topic, id, signature) {
        const response = formatJsonRpcResult(id, signature)

        try {
            let r = window.wc.web3wallet.respondSessionRequest({ topic: topic, response: response });
            return {
                result: r,
                error: ""
            };

        } catch (e) {
            wc.statusObject.bubbleConsoleMessage("error", `respondSessionRequest error: ${JSON.stringify(e, null, 2)}`)
            return {
                result: "",
                error: e
            };
        }
    },

    rejectSessionRequest: function (topic, id, error = false) {
        const errorType = error ? "SESSION_SETTLEMENT_FAILED" : "USER_REJECTED";
        return {
            result: window.wc.web3wallet.respondSessionRequest({
                topic: topic,
                response: formatJsonRpcError(id, getSdkError(errorType)),
            }),
            error: ""
        };
    },
};
