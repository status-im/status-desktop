import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15
import Qt.labs.settings 1.0
import QtTest 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups.Dialog 0.1

import Models 1.0
import Storybook 1.0

import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.services.dapps 1.0

import SortFilterProxyModel 0.2

import AppLayouts.Wallet.panels 1.0

import utils 1.0
import shared.stores 1.0

Item {
    id: root

    // qml Splitter
    SplitView {
        anchors.fill: parent

        ColumnLayout {
            SplitView.fillWidth: true

            Rectangle {
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: dappsWorkflow.implicitHeight + 20
                Layout.preferredHeight: dappsWorkflow.implicitHeight + 20

                border.color: "blue"
                border.width: 1

                DAppsWorkflow {
                    id: dappsWorkflow

                    anchors.centerIn: parent

                    spacing: 8
                }
            }
            ColumnLayout {}
        }

        ColumnLayout {
            id: optionsSpace

            RowLayout {
                Text { text: "projectId" }
                Text {
                    id: projectIdText
                    readonly property string projectId: SystemUtils.getEnvVar("WALLET_CONNECT_PROJECT_ID")
                    text: projectId.substring(0, 3) + "..." + projectId.substring(projectId.length - 3)
                    font.bold: true
                }
            }

            // spacer
            ColumnLayout {}

            RowLayout {
                Text { text: "URI" }
                TextField {
                    id: pairUriInput

                    placeholderText: "Enter WC Pair URI"
                    text: settings.pairUri
                    onTextChanged: {
                        settings.pairUri = text
                    }

                    Layout.fillWidth: true
                }
            }


            CheckBox {
                id: openPairCheckBox
                text: "Open Pair"
                checked: settings.openPair
                onCheckedChanged: {
                    settings.openPair = checked
                    if (checked) {
                        d.startPairing()
                    }
                }
                Connections {
                    target: dappsWorkflow

                    // Open Pairing workflow if selected in the side bar
                    function onDAppsListReady() {
                        if (!d.startPairingWorkflowActive)
                            return

                        let items = InspectionUtils.findItemsByTypeName(dappsWorkflow, "DAppsListPopup")
                        if (items.length === 1) {
                            let buttons = InspectionUtils.findItemsByTypeName(items[0], "StatusButton")
                            if (buttons.length === 1) {
                                buttons[0].clicked()
                            }
                        }
                    }

                    function onConnectDappReady() {
                        if (!d.startPairingWorkflowActive)
                            return

                        if (pairUriInput.text.length > 0) {
                            let items = InspectionUtils.findItemsByTypeName(dappsWorkflow, "StatusBaseInput")
                            if (items.length === 1) {
                                items[0].text = pairUriInput.text
                            }
                        }
                        d.startPairingWorkflowActive = false
                    }
                }
            }
        }
    }

    DAppsStore {
        wCSDK: WalletConnectSDK {
            active: true

            projectId: projectIdText.projectId

            onSessionRequestEvent: (details) => {
                // TODO #14556
                console.debug(`@dd onSessionRequestEvent: ${JSON.stringify(details)}`)
            }
        }
    }


    QtObject {
        id: d

        property bool startPairingWorkflowActive: false

        function startPairing() {
            startPairingWorkflowActive = true
            if(root.visible) {
                dappsWorkflow.clicked()
            }
        }
    }

    onVisibleChanged: {
        if (visible && d.startPairingWorkflowActive) {
            d.startPairing()
        }
    }

    Settings {
        id: settings

        property bool openPair: false
        property string pairUri: ""
    }
}

// category: Wallet
