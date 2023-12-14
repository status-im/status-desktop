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
        return new Promise(async (resolve, reject) => {
            if (!window.statusq) {
                const errMsg = 'missing window.statusq! Forgot to execute "ui/StatusQ/src/StatusQ/Components/private/qwebchannel/helpers.js" first?'
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
            window.wc.web3wallet.on("session_proposal", (details) => {
                wc.statusObject.onSessionProposal(details)
            });

            window.wc.web3wallet.on("session_update", (details) => {
                wc.statusObject.onSessionUpdate(details)
            });

            window.wc.web3wallet.on("session_extend", (details) => {
                wc.statusObject.onSessionExtend(details)
            });

            window.wc.web3wallet.on("session_ping", (details) => {
                wc.statusObject.onSessionPing(details)
            });

            window.wc.web3wallet.on("session_delete", (details) => {
                wc.statusObject.onSessionDelete(details)
            });

            window.wc.web3wallet.on("session_expire", (details) => {
                wc.statusObject.onSessionExpire(details)
            });

            window.wc.web3wallet.on("session_request", (details) => {
                wc.statusObject.onSessionRequest(details)
            });

            window.wc.web3wallet.on("session_request_sent", (details) => {
                wc.statusObject.onSessionRequestSent(details)
            });

            window.wc.web3wallet.on("session_event", (details) => {
                wc.statusObject.onSessionEvent(details)
            });

            window.wc.web3wallet.on("proposal_expire", (details) => {
                wc.statusObject.onProposalExpire(details)
            });

            window.wc.authClient.on("auth_request", (details) => {
                wc.statusObject.onAuthRequest(details)
            });

            wc.statusObject.sdkInitialized("");
            resolve("");
        });
    },

    // TODO: there is a corner case when attempting to pair with a link that is already paired or was rejected won't trigger any event back
    pair: async function (uri) {
        await window.wc.web3wallet.pair({ uri });
    },

    getPairings: function () {
        return window.wc.web3wallet.core.pairing.getPairings();
    },

    getActiveSessions: function () {
        return window.wc.web3wallet.getActiveSessions();
    },

    disconnect: async function (topic) {
        await window.wc.web3wallet.disconnectSession(
            {
                topic,
                reason: getSdkError('USER_DISCONNECTED')
            }
        );
    },

    ping: async function (topic) {
        await window.wc.web3wallet.engine.signClient.ping({ topic });
    },

    approveSession: async function (sessionProposal, supportedNamespaces) {
        const { id, params } = sessionProposal;

        const { relays } = params

        const approvedNamespaces = buildApprovedNamespaces(
            {
                proposal: params,
                supportedNamespaces: supportedNamespaces,
            }
        );

        return await window.wc.web3wallet.approveSession(
            {
                id,
                relayProtocol: relays[0].protocol,
                namespaces: approvedNamespaces,
            }
        );
    },

    rejectSession: async function (id) {
        await window.wc.web3wallet.rejectSession(
            {
                id,
                reason: getSdkError("USER_REJECTED"), // TODO USER_REJECTED_METHODS, USER_REJECTED_CHAINS, USER_REJECTED_EVENTS
            }
        );
    },

    auth: async function (uri) {
        await window.wc.authClient.core.pairing.pair({ uri });
    },

    formatAuthMessage: function (cacaoPayload, address) {
        const iss = `did:pkh:eip155:1:${address}`;
        return window.wc.authClient.formatMessage(cacaoPayload, iss);
    },

    approveAuth: async function (authRequest, address, signature) {
        const { id } = authRequest;

        const iss = `did:pkh:eip155:1:${address}`;

        await window.wc.authClient.respond(
            {
                id: id,
                signature: {
                    s: signature,
                    t: "eip191",
                },
            },
            iss
        );
    },

    rejectAuth: async function (id, address) {
        const iss = `did:pkh:eip155:1:${address}`;

        await window.wc.authClient.respond(
            {
                id: id,
                error: {
                    code: 4001,
                    message: 'Auth request has been rejected'
                },
            },
            iss
        );
    },

    respondSessionRequest: async function (topic, id, signature) {
        const response = formatJsonRpcResult(id, signature)

        await window.wc.web3wallet.respondSessionRequest(
            {
                topic: topic,
                response: response
            }
        );
    },

    rejectSessionRequest: async function (topic, id, error = false) {
        const errorType = error ? "SESSION_SETTLEMENT_FAILED" : "USER_REJECTED";

        await window.wc.web3wallet.respondSessionRequest(
            {
                topic: topic,
                response: formatJsonRpcError(id, getSdkError(errorType)),
            }
        );
    },
};
