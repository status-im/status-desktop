import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15
import QtQml.Models 2.14

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

StatusDialog {
    id: root

    required property var community

    signal importControlNode(string privateKey)
    signal requestCommunityInfo(string privateKey)

    function setCommunityInfo(communityInfo) {
        d.requestedCommunityInfo = communityInfo
        d.privateKeyCheckInProgress = false
    }

    onRequestCommunityInfo: d.privateKeyCheckInProgress = true

    width: 640
    height: Math.max(552, implicitHeight)
    title: qsTr("Make this device the control node for %1").arg(root.community.name)

    closePolicy: Popup.NoAutoClose

    component Paragraph: StatusBaseText {
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        font.pixelSize: Style.current.primaryTextFontSize
        lineHeightMode: Text.FixedHeight
        lineHeight: 22
        wrapMode: Text.Wrap
        verticalAlignment: Text.AlignVCenter
    }

    component PasteButton: StatusButton {
        id: pasteButton
        borderColor: textColor
        text: qsTr("Paste")
        size: StatusButton.Size.Tiny
    }

    component ChatDetails: Control {
        verticalPadding: 6
        horizontalPadding: 4

        contentItem: RowLayout {
            StatusChatInfoButton {
                id: communityInfoButton
                Layout.alignment: Qt.AlignVCenter
                title: community.name
                subTitle: qsTr("%n member(s)", "", community.members.count || 0)
                asset.name: community.image
                asset.color: community.color
                asset.isImage: true
                type: StatusChatInfoButton.Type.OneToOneChat
                hoverEnabled: false
                visible: false
            }
            Item { Layout.fillWidth: true }
            StatusBaseText {
                id: detectionLabel
                Layout.alignment: Qt.AlignVCenter
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Style.current.additionalTextSize
                visible: !!text
            }
        }

        states: [
            State {
                name: "matchingPrivateKey"
                when: d.isPrivateKeyMatching
                PropertyChanges { target: detectionLabel; text: qsTr("Private key is valid") }
                PropertyChanges { target: detectionLabel; color: Theme.palette.successColor1 }
                PropertyChanges { target: communityInfoButton; visible: true }
            },
            State {
                name: "mismatchingPrivateKey"
                when: !d.isPrivateKeyMatching && d.isPrivateKey && !d.privateKeyCheckInProgress
                PropertyChanges { target: detectionLabel; text: qsTr("This is not the correct private key for %1").arg(root.community.name) }
                PropertyChanges { target: detectionLabel; color: Theme.palette.dangerColor1 }
            },
            State {
                name: "checking"
                when: d.privateKeyCheckInProgress
                PropertyChanges { target: detectionLabel; text: qsTr("Checking private key...") }
                PropertyChanges { target: detectionLabel; color: Theme.palette.baseColor1 }
            },
            State {
                name: "invalidPrivateKey"
                when: !d.isPrivateKey && d.isPrivateKeyInserted
                PropertyChanges { target: detectionLabel; text: qsTr("This is not a private key") }
                PropertyChanges { target: detectionLabel; color: Theme.palette.dangerColor1 }
            }
        ]
    }

    QtObject {
        id: d
        readonly property bool isPrivateKey: Utils.isPrivateKey(privateKeyTextArea.text)
        readonly property bool isPrivateKeyMatching: d.requestedCommunityInfo ? d.requestedCommunityInfo.id === community.id : false
        readonly property bool isPrivateKeyInserted: privateKeyTextArea.text.length > 0

        property bool privateKeyCheckInProgress: false
        property var requestedCommunityInfo: undefined

        onIsPrivateKeyChanged: {
            if(!isPrivateKey) {
                requestedCommunityInfo = undefined
                privateKeyCheckInProgress = false
                return
            }

            privateKeyCheckInProgress = true
            requestedCommunityInfo = undefined
            requestCommunityInfo(privateKeyTextArea.text)
        }
    }

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        spacing: 0
        Paragraph {
            Layout.preferredHeight: 22
            Layout.bottomMargin: Style.current.halfPadding
            text: qsTr("To move the %1 control node to this device: ").arg(root.community.name)
        }
        Paragraph {
            text: qsTr("1. Stop using any other devices as the control node for this Community")
        }
        Paragraph {
            text: qsTr("2. Paste the Community’s private key below:")
        }
        StatusBaseInput {
            id: privateKeyTextArea
            Layout.fillWidth: true
            Layout.preferredHeight: 86
            rightPadding: Style.current.padding
            multiline: true
            valid: d.isPrivateKey || !d.isPrivateKeyInserted
            placeholderText: qsTr("e.g. %1").arg("0x0454f2231543ba02583e4c55e513a75092a4f2c86c04d0796b195e964656d6cd94b8237c64ef668eb0fe268387adc3fe699bce97190a631563c82b718c19cf1fb8")
            rightComponent: PasteButton {
                onClicked: {
                    privateKeyTextArea.edit.clear()
                    privateKeyTextArea.edit.paste()
                }
            }
        }
        ChatDetails {
            Layout.topMargin: Style.current.halfPadding
            Layout.fillWidth: true
            Layout.minimumHeight: 46
        }
        Item {
            Layout.fillHeight: true
            Layout.minimumHeight: Style.current.xlPadding
        }
        ColumnLayout {
            id: agreementLayout
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: mainLayout.spacing

            visible: d.isPrivateKeyMatching

            StatusDialogDivider {
                Layout.fillWidth: true
            }
            Paragraph {
                Layout.topMargin: Style.current.padding
                text: qsTr("I acknowledge that...")
            }
            StatusCheckBox {
                id: agreementCheckBox
                Layout.fillWidth: true
                font.pixelSize: Style.current.primaryTextFontSize
                text: qsTr("I must keep this device online and running Status for the Community to function")
            }
        }
    }

    footer: StatusDialogFooter {
        rightButtons: ObjectModel { 
            StatusButton {
                text: qsTr("Make this device the control node for %1").arg(root.community.name)
                enabled: d.isPrivateKeyMatching && agreementCheckBox.checked
                onClicked: {
                    root.importControlNode(privateKeyTextArea.text)
                    root.close()
                }
            }
        }
    }
}
