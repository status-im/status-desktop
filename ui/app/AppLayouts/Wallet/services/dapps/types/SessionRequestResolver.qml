pragma Singleton

import QtQuick 2.15

import StatusQ.Core.Utils 0.1 as SQUtils

/// Component that resolves a session request event
/// and returns a validated SessionRequest js object
/// @returns { 
///    error: SessionRequest.Error,
///    request: {
///         event, - original event
///         topic, - dapp session identifier
///         requestId, - unique request identifier
///         method, - RPC method
///         account, - account address to sign the request
///         chainId, - chain id
///         data, - challenge data
///         preparedData, - human readable data
///         expiryTimestamp, - request expiry timestamp
///         transaction: {
///             value,
///             maxFeePerGas,
///             maxPriorityFeePerGas,
///             gasPrice,
///             gasLimit,
///             nonce
///         }
///     }
///}
SQUtils.QObject {
    id: root

    function resolveEvent(event, accountsModel, networksModel, hexToDec) {
        if (!event) {
            console.warn("SessionRequestResolver - resolveEvent - invalid event")
            return { request: null, error: SessionRequest.InvalidEvent }
        }
        if (!accountsModel) {
            console.warn("SessionRequestResolver - resolveEvent - invalid accountsModel")
            return { request: null, error: SessionRequest.RuntimeError }
        }
        if (!networksModel) {
            console.warn("SessionRequestResolver - resolveEvent - invalid networksModel")
            return { request: null, error: SessionRequest.RuntimeError }
        }

        try {
            const { request, error } = SessionRequest.parse(event, hexToDec)
            if (error) {
                console.warn("SessionRequestResolver - resolveEvent - failed to build request", error)
                return { request: null, error }
            }
            if (!request) {
                console.warn("SessionRequestResolver - resolveEvent - failed to build request")
                return { request: null, error: SessionRequest.RuntimeError }
            }
            const validChainId = !!SQUtils.ModelUtils.getByKey(networksModel, "chainId", request.chainId)
            if (!validChainId) {
                console.warn("SessionRequestResolver - resolveEvent - invalid chainId", request.chainId)
                return { request: null, error: SessionRequest.InvalidChainId }
            }

            const validAccount = SQUtils.ModelUtils.getFirstModelEntryIf(accountsModel, (account) => {
                return account.address.toLowerCase() === request.account.toLowerCase();
            })
            if (!validAccount) {
                console.warn("SessionRequestResolver - resolveEvent - invalid account", request.account)
                return { request: null, error: SessionRequest.InvalidAccount }
            }
            // Override the account with the validated one to always match the case
            request.account = validAccount.address

            return { request, error: SessionRequest.NoError }
        } catch (e) {
            console.warn("SessionRequestResolver - resolveEvent - failed to resolve event", e)
            return { request: null, error: SessionRequest.RuntimeError }
        }
    }
}