import { Core } from "@walletconnect/core";
import { Web3Wallet } from "@walletconnect/web3wallet";

import AuthClient from '@walletconnect/auth-client'

// import the builder util
import { buildApprovedNamespaces, getSdkError } from "@walletconnect/utils";

// "Export" API to window
// Workaround, tried using export via output.module: true in webpack.config.js, but it didn't work
window.wc = {
    core: null,
    web3wallet: null,
    authClient: null,

    init: function (projectId) {
        return new Promise(async (resolve) => {
            window.wc.core = new Core({
                projectId: projectId,
            });

            window.wc.web3wallet = await Web3Wallet.init({
                core: window.wc.core, // <- pass the shared `core` instance
                metadata: {
                    name: "Status",
                    description: "Status Wallet",
                    url: "https://status.app",
                    icons: ['https://status.im/img/status-footer-logo.svg'],
                },
            });

            window.wc.authClient = await AuthClient.init({
                projectId: projectId,
                metadata: window.wc.web3wallet.metadata,
            })

            resolve()
        })
    },

    alreadyPaired: new Error("Already paired"),
    waitingForApproval: new Error("Waiting for approval"),
    // TODO: there is a corner case when attempting to pair with a link that is already paired or was rejected won't trigger any event back
    pair: function (uri) {
        let pairingTopic = getPairingTopicFromPairingUrl(uri);

        const pairings = window.wc.core.pairing.getPairings();
        // Find pairing by topic
        const pairing = pairings.find((p) => p.topic === pairingTopic);
        if (pairing) {
            if (pairing.active) {
                return new Promise((_, reject) => {
                    reject(window.wc.alreadyPaired);
                });
            }
        }

        let pairPromise = window.wc.web3wallet
            .pair({ uri: uri })


        return new Promise((resolve, reject) => {
            pairPromise
                .then(() => {
                    window.wc.web3wallet.on("session_proposal", async (sessionProposal) => {
                        resolve(sessionProposal);
                    });
                })
                .catch((error) => {
                    reject(error);
                });
        });
    },

    registerForSessionRequest: function (callback) {
        window.wc.web3wallet.on("session_request", callback);
    },

    registerForSessionDelete: function (callback) {
        window.wc.web3wallet.on("session_delete", callback);
    },

    approvePairSession: function (sessionProposal, supportedNamespaces) {
        const { id, params } = sessionProposal;

        const approvedNamespaces = buildApprovedNamespaces({
            proposal: params,
            supportedNamespaces: supportedNamespaces,
        });

        return window.wc.web3wallet.approveSession({
            id,
            namespaces: approvedNamespaces,
        });
    },
    rejectPairSession: function (id) {
        return window.wc.web3wallet.rejectSession({
            id: id,
            reason: getSdkError("USER_REJECTED"), // TODO USER_REJECTED_METHODS, USER_REJECTED_CHAINS, USER_REJECTED_EVENTS
        });
    },

    auth: function (uri) {
        let pairingTopic = getPairingTopicFromPairingUrl(uri);

        const pairings = window.wc.core.pairing.getPairings();
        // Find pairing by topic
        const pairing = pairings.find((p) => p.topic === pairingTopic);
        if (pairing) {
            if (pairing.active) {
                return new Promise((_, reject) => {
                    reject(window.wc.alreadyPaired);
                });
            }
        }

        let pairPromise = window.wc.authClient.core.pairing
            .pair({ uri })

        return new Promise((resolve, reject) => {
            pairPromise
                .then(() => {
                    // TODO: check if we can separate using the URI info
                    window.wc.authClient.on("auth_request", async (authProposal) => {
                        resolve(authProposal);
                    });
                })
                .catch((error) => {
                    reject(error);
                });
        });
    },

    approveAuth: function (authProposal) {
        const { id, params } = authProposal;

        // TODO: source user’s address
        const iss = `did:pkh:eip155:1:${"0x0123456789"}`;

        // format the cacao payload with the user’s address
        const message = window.wc.authClient.formatMessage(params.cacaoPayload, iss);

        // TODO: signature
        const signature = "0x123456789"

        return window.wc.authClient.respond(
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
    rejectAuth: function (id) {
        return window.wc.authClient.reject(id);
    },

    respondSessionRequest: function (topic, response) {
        window.wc.web3wallet.respondSessionRequest({ topic, response });
    },

    disconnectAll: function () {
        const pairings = window.wc.core.pairing.getPairings();
        pairings.forEach((p) => {
            window.wc.core.pairing.disconnect({ topic: p.topic });
        });
    },
};

// Returns null if not a pairing url
function getPairingTopicFromPairingUrl(url) {
    if (!url.startsWith("wc:")) {
        return null;
    }
    const atIndex = url.indexOf("@");
    if (atIndex < 0) {
        return null;
    }
    return url.slice(3, atIndex);
}
