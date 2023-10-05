import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1

import utils 1.0

import shared.popups.addaccount.panels 1.0

SplitView {
    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        ColumnLayout {
            id: controlLayout

            anchors.fill: parent

            DerivationPathInput {
                id: testControl

                levelsLimit: levelsLimitSpinBox.value

                onEditingFinished: { lastEvent.text = "Editing finished" }

                input.rightComponent: StatusIcon {
                    icon: "chevron-down"
                    color: Theme.palette.baseColor1

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            derivationPathSelection.popup(0, testControl.height + Style.current.halfPadding)
                        }
                    }
                }

                StatusMenu {
                    id: derivationPathSelection

                    ColumnLayout {
                        StatusBaseText {
                            text: "Test Popup"
                            Layout.margins: 10
                        }
                        StatusBaseText {
                            text: "Some more content here"
                            Layout.margins: 10
                        }
                    }
                }
            }

            // Vertical separator
            ColumnLayout {}


            RowLayout {
                Label {
                    text: "Levels limit"
                }
                SpinBox {
                    id: levelsLimitSpinBox
                    from: 0
                    to: 20
                    value: 0
                }
            }
            RowLayout {
                Layout.preferredHeight: customDerivationPathInput.height * 1.5

                Label {
                    text: "Custom path:"
                }
                TextInput {
                    id: customDerivationPathInput

                    Layout.minimumWidth: 100
                }
            }

            RowLayout {
                Layout.preferredHeight: customDerivationPathBaseInput.height * 1.5

                Label {
                    text: "Custom base:"
                }

                TextInput {
                    id: customDerivationPathBaseInput

                    Layout.minimumWidth: 100
                }
            }

            Button {
                text: "Set custom derivation path"
                hoverEnabled: true
                highlighted: hovered

                onClicked: {
                    testControl.resetDerivationPath(customDerivationPathBaseInput.text, customDerivationPathInput.text)
                }
            }

            Label {
                text: testControl.errorMessage
                visible: testControl.errorMessage.length > 0

                Layout.fillWidth: true

                font.pixelSize: 22
                font.italic: true
                color: "red"
            }
            Label {
                text: testControl.warningMessage
                visible: testControl.warningMessage.length > 0

                Layout.fillWidth: true

                font.pixelSize: 22
                font.italic: true
                color: "orange"
            }
            RowLayout {
                Label { text: "Output: " }
                Label { id: base; text: testControl.derivationPath }
            }
            RowLayout {
                Label { text: "Last event: " }
                Label { id: lastEvent; text: "" }
            }
            CheckBox {
                id: reflexiveMode
                text: "Auto echo derivation path onto itself every " + reflexiveTimer.interval + " ms"
                checked: false
            }
            CheckBox {
                text: "Standard base path detected"
                checked: testControl.detectedStandardBasePath
                enabled: false
            }
        }

        Timer {
            id: reflexiveTimer
            interval: 100
            running: false
            repeat: false
            onTriggered: testControl.resetDerivationPath(testControl.basePath, testControl.derivationPath)
        }
        Connections {
            target: testControl
            function onDerivationPathChanged() {
                if (reflexiveMode.checked) {
                    reflexiveTimer.restart()
                }
            }
        }

        Border {
            target: customDerivationPathInput
        }
        Border {
            target: customDerivationPathBaseInput
        }
        Border {
            target: testControl
        }
        Border {
            target: testControl
            radius: 0
            border.color: "#22FF0000"
        }
    }
    Pane {
        SplitView.minimumWidth: 300
        SplitView.fillWidth: true
        SplitView.minimumHeight: 300

        ListView {
            id: stdBaseListView
            anchors.fill: parent

            model: standardBasePathModel

            onCurrentIndexChanged: {
                const newBasePath = standardBasePathModel.get(currentIndex).derivationPath
                testControl.resetDerivationPath(newBasePath, newBasePath + (newBasePath.split("'").length > 3 ? "/0" : "/0'"))
            }

            delegate: ItemDelegate {
                width: stdBaseListView.width
                implicitHeight: delegateRowLayout.implicitHeight

                highlighted: ListView.isCurrentItem

                RowLayout {
                    id: delegateRowLayout
                    anchors.fill: parent

                    Column {
                        Layout.margins: 5

                        spacing: 3

                        Label {
                            text: name
                            Layout.fillWidth: true
                        }

                        Label {
                            text: derivationPath
                            Layout.fillWidth: true
                        }
                    }
                }

                Border {
                    anchors.fill: delegateRowLayout
                    anchors.margins: 1
                    z: delegateRowLayout.z - 1
                }

                onClicked: stdBaseListView.currentIndex = index
            }
        }

        ListModel {
            id: standardBasePathModel

            ListElement {
                name: "Custom"
                derivationPath: "m/44'"
            }

            ListElement {
                name: "Ethereum"
                derivationPath: "m/44'/60'/0'/0"
            }

            ListElement {
                name: "Ethereum Classic"
                derivationPath: "m/44'/61'/0'/0"
            }

            ListElement {
                name: "Ethereum Testnet (Ropsten)"
                derivationPath: "m/44'/1'/0'/0"
            }

            ListElement {
                name: "Ethereum (Ledger)"
                derivationPath: "m/44'/60'/0'"
            }

            ListElement {
                name: "Ethereum Classic (Ledger)"
                derivationPath: "m/44'/60'/160720'/0"
            }

            ListElement {
                name: "Ethereum Classic (Ledger, Vintage MEW)"
                derivationPath: "m/44'/60'/160720'/0'"
            }

            ListElement {
                name: "Ethereum (Ledger Live)"
                derivationPath: "m/44'/60'"
            }

            ListElement {
                name: "Ethereum Classic (Ledger Live)"
                derivationPath: "m/44'/61'"
            }

            ListElement {
                name: "Ethereum (KeepKey)"
                derivationPath: "m/44'/60'"
            }

            ListElement {
                name: "Ethereum Classic (KeepKey)"
                derivationPath: "m/44'/61'"
            }

            ListElement {
                name: "RSK Mainnet"
                derivationPath: "m/44'/137'/0'/0"
            }

            ListElement {
                name: "Expanse"
                derivationPath: "m/44'/40'/0'/0"
            }

            ListElement {
                name: "Ubiq"
                derivationPath: "m/44'/108'/0'/0"
            }

            ListElement {
                name: "Ellaism"
                derivationPath: "m/44'/163'/0'/0"
            }

            ListElement {
                name: "EtherGem"
                derivationPath: "m/44'/1987'/0'/0"
            }

            ListElement {
                name: "Callisto"
                derivationPath: "m/44'/820'/0'/0"
            }

            ListElement {
                name: "Ethereum Social"
                derivationPath: "m/44'/1128'/0'/0"
            }

            ListElement {
                name: "Musicoin"
                derivationPath: "m/44'/184'/0'/0"
            }

            ListElement {
                name: "EOS Classic"
                derivationPath: "m/44'/2018'/0'/0"
            }

            ListElement {
                name: "Akroma"
                derivationPath: "m/44'/200625'/0'/0"
            }

            ListElement {
                name: "Ether Social Network"
                derivationPath: "m/44'/31102'/0'/0"
            }

            ListElement {
                name: "PIRL"
                derivationPath: "m/44'/164'/0'/0"
            }

            ListElement {
                name: "GoChain"
                derivationPath: "m/44'/6060'/0'/0"
            }

            ListElement {
                name: "Ether-1"
                derivationPath: "m/44'/1313114'/0'/0"
            }

            ListElement {
                name: "Atheios"
                derivationPath: "m/44'/1620'/0'/0"
            }

            ListElement {
                name: "TomoChain"
                derivationPath: "m/44'/889'/0'/0"
            }

            ListElement {
                name: "Mix Blockchain"
                derivationPath: "m/44'/76'/0'/0"
            }

            ListElement {
                name: "Iolite"
                derivationPath: "m/44'/1171337'/0'/0"
            }

            ListElement {
                name: "ThunderCore"
                derivationPath: "m/44'/1001'/0'/0"
            }

        }
    }

    component Border: Rectangle {
        property Item target: null
        Component.onCompleted: setTargetAsParent()
        onTargetChanged: setTargetAsParent()
        function setTargetAsParent() {
            if(!!target) {
                parent = target
            }
        }

        x: !!target ? -radius : 0
        y: !!target ? -radius : 0
        width: !!target ? target.width+2*radius : 0
        height: !!target ? target.height+2*radius : 0
        z: !!target ? target.z - 1 : 0

        color: "transparent"

        border.color: "black"
        border.width: 1

        radius: 5
    }
}

// category: Components

// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?node-id=12272%3A269692&t=YiipgcxOhdOvqprP-0
