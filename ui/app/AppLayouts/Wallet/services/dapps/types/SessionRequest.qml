pragma Singleton

import QtQml 2.15

import utils 1.0

QtObject {
    /// Supported methods
    /// userString is used in the context `dapp.url #{userString} <accepted/rejected>`
    /// requestDisplay is used in the context `dApp wants you to ${requestDisplay} with <Account Name Here>`
    property QtObject methods: QtObject {
        readonly property QtObject personalSign: QtObject {
            readonly property string name: Constants.personal_sign
            readonly property string userString: qsTr("sign")
            readonly property string requestDisplay: qsTr("sign this message")

            function buildDataObject(message) { return {message} }
            function getMessageFromData(data) { return data.message }
        }
        readonly property QtObject sign: QtObject {
            readonly property string name: "eth_sign"
            readonly property string userString: qsTr("sign")
            readonly property string requestDisplay: qsTr("sign this message")

            function buildDataObject(message) { return {message} }
            function getMessageFromData(data) { return data.message }
        }
        readonly property QtObject signTypedData_v4: QtObject {
            readonly property string name: "eth_signTypedData_v4"
            readonly property string userString: qsTr("sign typed data")
            readonly property string requestDisplay: qsTr("sign this message")

            function buildDataObject(message) { return {message} }
            function getMessageFromData(data) { return data.message }
        }
        readonly property QtObject signTypedData: QtObject {
            readonly property string name: "eth_signTypedData"
            readonly property string userString: qsTr("sign typed data")
            readonly property string requestDisplay: qsTr("sign this message")

            function buildDataObject(message) { return {message} }
            function getMessageFromData(data) { return data.message }
        }
        readonly property QtObject signTransaction: QtObject {
            readonly property string name: "eth_signTransaction"
            readonly property string userString: qsTr("sign transaction")
            readonly property string requestDisplay: qsTr("sign this transaction")

            function buildDataObject(tx) { return {tx} }
            function getTxObjFromData(data) { return data.tx }
        }

        readonly property QtObject sendTransaction: QtObject {
            readonly property string name: "eth_sendTransaction"
            readonly property string userString: qsTr("transaction")
            readonly property string requestDisplay: qsTr("sign this transaction")

            function buildDataObject(tx) { return {tx}}
            function getTxObjFromData(data) { return data.tx }
        }
        readonly property var all: [personalSign, sign, signTypedData_v4, signTypedData, signTransaction, sendTransaction]
    }

    function getSupportedMethods() {
        return methods.all.map(function(method) {
            return method.name
        })
    }

    function methodToUserString(method) {
        for (let i = 0; i < methods.all.length; i++) {
            if (methods.all[i].name === method) {
                return methods.all[i].userString
            }
        }
        return ""
    }
}