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

            window.wc.authClient.on("auth_request", async (details) => {
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
        await window.wc.web3wallet.disconnectSession({
                                                        topic,
                                                        reason: getSdkError('USER_DISCONNECTED')
                                                     });
    },

    ping: async function (topic) {
        await window.wc.web3wallet.engine.signClient.ping({ topic });
    },

    approveSession: async function (sessionProposal, supportedNamespaces) {
        const { id, params } = sessionProposal;

        const { relays } = params

        const approvedNamespaces = buildApprovedNamespaces({
            proposal: params,
            supportedNamespaces: supportedNamespaces,
        });

        await window.wc.web3wallet.approveSession({
                id,
                relayProtocol: relays[0].protocol,
                namespaces: approvedNamespaces,
            });
    },

    rejectSession: async function (id) {
        await window.wc.web3wallet.rejectSession({
                id,
                reason: getSdkError("USER_REJECTED"), // TODO USER_REJECTED_METHODS, USER_REJECTED_CHAINS, USER_REJECTED_EVENTS
            });
    },

    auth: function (uri) {
        try {
            return {
                result: window.wc.authClient.core.pairing.pair({ uri }),
                error: ""
            };
        } catch (e) {
            return {
                result: "",
                error: e
            };
        }
    },

    formatAuthMessage: function (cacaoPayload, address) {
        const iss = `did:pkh:eip155:1:${address}`;

        return {
            result: window.wc.authClient.formatMessage(cacaoPayload, iss),
            error: ""
        };
    },

    approveAuth: function (authRequest, address, signature) {
        const { id, params } = authRequest;

        const iss = `did:pkh:eip155:1:${address}`;

        const message = window.wc.authClient.formatMessage(params.cacaoPayload, iss);

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

    rejectAuth: function (id, address) {
        const iss = `did:pkh:eip155:1:${address}`;

        return {
            result: window.wc.authClient.respond(
                {
                    id: id,
                    error: {
                        code: 4001,
                        message: 'Auth request has been rejected'
                    },
                },
                iss),
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
