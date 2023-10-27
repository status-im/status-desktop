import QtQuick 2.15
import QtWebView 1.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

Item {
    id: root

    implicitWidth: Math.min(mainLayout.implicitWidth, 400)
    implicitHeight: Math.min(mainLayout.implicitHeight, 700)

    required property color backgroundColor

    // wallet_connect.Controller \see wallet_section/wallet_connect/controller.nim
    required property var controller

    ColumnLayout {
        id: mainLayout

        anchors.fill: parent

        StatusBaseText {
            text: qsTr("Debugging UX until design is ready")
        }

        StatusInput {
            id: pairLinkInput

            Layout.fillWidth: true

            placeholderText: "Insert pair link"
        }

        RowLayout {
            Layout.fillWidth: true

            StatusButton {
                text: "Pair"
                onClicked: {
                    statusText.text = "Pairing..."
                    sdkView.pair(pairLinkInput.text)
                }
                enabled: pairLinkInput.text.length > 0 && sdkView.sdkReady
            }

            StatusButton {
                text: "Auth"
                onClicked: {
                    statusText.text = "Authenticating..."
                    sdkView.auth()
                }
                enabled: false && pairLinkInput.text.length > 0 && sdkView.sdkReady
            }

            StatusButton {
                text: "Accept"
                onClicked: {
                    sdkView.approvePairSession(d.sessionProposal, d.supportedNamespaces)
                }
                visible: root.state === d.waitingPairState
            }
            StatusButton {
                text: "Reject"
                onClicked: {
                    sdkView.rejectPairSession(d.sessionProposal.id)
                }
                visible: root.state === d.waitingPairState
            }
        }

        ColumnLayout {
            StatusBaseText {
                id: statusText
                text: "-"
            }
            Flickable {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                Layout.maximumHeight: 400

                contentWidth: detailsText.width
                contentHeight: detailsText.height

                StatusBaseText {
                    id: detailsText
                    text: ""
                    visible: text.length > 0

                    color: "#FF00FF"
                }

                ScrollBar.vertical: ScrollBar {}

                clip: true
            }
        }

        // TODO: DEBUG JS Loading in DMG
        // RowLayout {
        //     TextField {
        //         id: urlInput

        //         Layout.fillWidth: true

        //         placeholderText: "Insert URL here"
        //     }
        //     Button {
        //         text: "Set URL"
        //         onClicked: {
        //             sdkView.url = urlInput.text
        //         }
        //     }
        // }

        // Button {
        //     text: "Set HTML"
        //     onClicked: {
        //         sdkView.loadHtml(htmlContent.text, "http://status.im")
        //     }
        // }

        // StatusInput {
        //     id: htmlContent

        //     Layout.fillWidth: true
        //     Layout.minimumHeight: 200
        //     Layout.maximumHeight: 300

        //     text: `<!DOCTYPE html><html><head><title>TODO: Test</title>\n<!--<script src="http://127.0.0.1:8080/bundle.js" defer></script>-->\n<script type='text/javascript'>\n  console.log("@dd loaded dummy script!")\n</script>\n</head><body style='background-color: ${root.backgroundColor.toString()};'></body></html>`

        //     multiline: true
        //     minimumHeight: Layout.minimumHeight
        //     maximumHeight: Layout.maximumHeight

        // }
        // END DEBUGGING

        // Separator
        ColumnLayout {}

        WalletConnectSDK {
            id: sdkView

            projectId: controller.projectId
            backgroundColor: root.backgroundColor

            Layout.fillWidth: true
            // Note that a too smaller height might cause the webview to generate rendering errors
            Layout.preferredHeight: 10

            onSdkInit: function(success, info) {
                d.setDetailsText(info)
                if (success) {
                    d.setStatusText("Ready to pair or auth")
                    root.state = d.sdkReadyState
                } else {
                    d.setStatusText("SDK Error", "red")
                    root.state = ""
                }
            }

            onPairSessionProposal: function(success, sessionProposal) {
                d.setDetailsText(sessionProposal)
                if (success) {
                    d.setStatusText("Pair ID: " + sessionProposal.id + "; Topic: " + sessionProposal.params.pairingTopic)
                    root.controller.pairSessionProposal(JSON.stringify(sessionProposal))
                    // Expecting signal onProposeUserPair from controller
                } else {
                    d.setStatusText("Pairing error", "red")
                }
            }

            onPairAcceptedResult: function(success, result) {
                d.setDetailsText(result)
                if (success) {
                    d.setStatusText("Pairing OK")
                    root.state = d.pairedState
                } else {
                    d.setStatusText("Pairing error", "red")
                    root.state = d.sdkReadyState
                }
            }

            onPairRejectedResult: function(success, result) {
                d.setDetailsText(result)
                root.state = d.sdkReadyState
                if (success) {
                    d.setStatusText("Pairing rejected")
                } else {
                    d.setStatusText("Rejecting pairing error", "red")
                }
            }

            onStatusChanged: function(message) {
                statusText.text = message
            }

            onResponseTimeout: {
                d.setStatusText(`Timeout waiting for response. Reusing URI?`, "red")
            }
        }
    }

    QtObject {
        id: d

        property var sessionProposal: null
        property var supportedNamespaces: null

        readonly property string sdkReadyState: "sdk_ready"
        readonly property string waitingPairState: "waiting_pairing"
        readonly property string pairedState: "paired"

        function setStatusText(message, textColor) {
            statusText.text = message
            if (textColor === undefined) {
                textColor = "green"
            }
            statusText.color = textColor
        }
        function setDetailsText(message) {
            if (message === undefined) {
                message = "undefined"
            } else if (typeof message !== "string") {
                message = JSON.stringify(message, null, 2)
            }
            detailsText.text = message
        }
    }

    Connections {
        target: root.controller
        function onProposeUserPair(sessionProposalJson, supportedNamespacesJson) {
            d.setStatusText("Waiting user accept")

            d.sessionProposal = JSON.parse(sessionProposalJson)
            d.supportedNamespaces = JSON.parse(supportedNamespacesJson)

            d.setDetailsText(JSON.stringify(d.supportedNamespaces, null, 2))

            root.state = d.waitingPairState
        }
    }
}
