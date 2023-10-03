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


    required property string projectId
    required property color backgroundColor

    property alias optionalSdkPath: sdkView.optionalSdkPath

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
                enabled: pairLinkInput.text.length > 0 && sdkView.state === sdkView.disconnectedState
            }

            StatusButton {
                text: "Auth"
                onClicked: {
                    statusText.text = "Authenticating..."
                    sdkView.auth()
                }
                enabled: false && pairLinkInput.text.length > 0 && sdkView.state === sdkView.disconnectedState
            }

            StatusButton {
                text: "Accept"
                onClicked: {
                    sdkView.acceptPairing()
                }
                visible: sdkView.state === sdkView.waitingPairState
            }
            StatusButton {
                text: "Reject"
                onClicked: {
                    sdkView.rejectPairing()
                }
                visible: sdkView.state === sdkView.waitingPairState
            }
        }

        RowLayout {
            StatusBaseText {
                id: statusText
                text: "-"
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

            projectId: root.projectId
            backgroundColor: root.backgroundColor

            Layout.fillWidth: true
            // Note that a too smaller height might cause the webview to generate rendering errors
            Layout.preferredHeight: 10

            onStatusChanged: function(message) {
                statusText.text = message
            }
        }
    }
}
