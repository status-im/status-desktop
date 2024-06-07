import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ.Core 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQ

import utils 1.0

StatusDialog {
    id: root

    objectName: "dappsRequestModal"

    implicitWidth: 480

    required property string dappName
    required property string dappUrl
    required property url dappIcon
    required property string method
    required property string signContent
    required property string maxFeesText
    required property string estimatedTimeText

    required property var account
    property var network: null

    signal sign()
    signal reject()

    title: qsTr("Sign request")

    padding: 20

    onSignContentChanged: d.updatePayloadToDisplay()
    onMethodChanged: d.updatePayloadToDisplay()
    Component.onCompleted: d.updatePayloadToDisplay()

    contentItem: StatusScrollView {
        id: scrollView
        padding: 0
        ColumnLayout {
            spacing: 20
            clip: true

            width: scrollView.availableWidth

            IntentionPanel {
                Layout.fillWidth: true

                dappName: root.dappName
                dappIcon: root.dappIcon
                account: root.account
            }

            ContentPanel {
                Layout.fillWidth: true
                Layout.preferredHeight: 340
            }

            // TODO: externalize as a TargetPanel
            ColumnLayout {
                spacing: 8

                StatusBaseText {
                    text: qsTr("Sign with")
                    font.pixelSize: 13
                    color: Theme.palette.directColor1
                }

                // TODO #14762: implement proper control to display the accounts details
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 76

                    radius: 8
                    border.width: 1
                    border.color: Theme.palette.baseColor2
                    color: "transparent"

                    RowLayout {
                        spacing: 12
                        anchors.fill: parent
                        anchors.margins: 16

                        StatusSmartIdenticon {
                            width: 40
                            height: 40

                            asset: StatusAssetSettings {
                                color: Theme.palette.primaryColor1
                                isImage: false
                                isLetterIdenticon: true
                                useAcronymForLetterIdenticon: false
                                emoji: root.account.emoji
                            }
                        }

                        ColumnLayout {
                            Layout.alignment: Qt.AlignLeft

                            StatusBaseText {
                                text: root.account.name

                                Layout.alignment: Qt.AlignLeft

                                font.pixelSize: 13
                            }
                            StatusBaseText {
                                text: StatusQ.Utils.elideAndFormatWalletAddress(root.account.address, 6, 4)

                                Layout.alignment: Qt.AlignLeft

                                font.pixelSize: 13

                                color: Theme.palette.baseColor1
                            }
                        }

                        Item {Layout.fillWidth: true }
                    }
                }
                // TODO #14762: implement proper control to display the chain
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 76

                    visible: root.network !== null

                    radius: 8
                    border.width: 1
                    border.color: Theme.palette.baseColor2
                    color: "transparent"

                    RowLayout {
                        spacing: 12
                        anchors.fill: parent
                        anchors.margins: 16

                        StatusSmartIdenticon {
                            width: 40
                            height: 40

                            asset: StatusAssetSettings {
                                isImage: true
                                name: !!root.network ? Style.svg("tiny/" + root.network.iconUrl) : ""
                            }
                        }

                        StatusBaseText {
                            text: !!root.network ? root.network.chainName : ""

                            Layout.alignment: Qt.AlignLeft

                            font.pixelSize: 13
                        }
                        Item {Layout.fillWidth: true }
                    }
                }
            }
        }
    }

    header: StatusDialogHeader {
        leftComponent: Item {
            width: 46
            height: 46

            StatusSmartIdenticon {
                anchors.fill: parent
                anchors.margins: 3

                asset: StatusAssetSettings {
                    width: 40
                    height: 40
                    bgRadius: bgWidth / 2
                    imgIsIdenticon: false
                    isImage: true
                    useAcronymForLetterIdenticon: false
                    name: root.dappIcon
                }
                bridgeBadge.visible: true
                bridgeBadge.width: 16
                bridgeBadge.height: 16
                bridgeBadge.image.source: "assets/sign.svg"
                bridgeBadge.border.width: 3
                bridgeBadge.border.color: "transparent"
                bridgeBadge.color: Theme.palette.miscColor1
            }
        }
        headline.title: qsTr("Sign request")
        headline.subtitle: root.dappUrl
    }

    footer: StatusDialogFooter {
        id: footer

        leftButtons: ObjectModel {
            MaxFeesDisplay {
            }
            Item {
                width: 20
            }
            EstimatedTimeDisplay {
                visible: !!root.estimatedTimeText
            }
        }

        rightButtons: ObjectModel {
            StatusButton {
                objectName: "rejectButton"

                height: 44
                text: qsTr("Reject")

                onClicked: {
                    root.reject()
                }
            }
            StatusButton {
                height: 44
                text: qsTr("Sign")

                onClicked: {
                    root.sign()
                }
            }
        }
    }

    component MaxFeesDisplay: ColumnLayout {
        StatusBaseText {
            text: qsTr("Max fees:")

            font.pixelSize: 12
            color: Theme.palette.directColor1
        }
        StatusBaseText {
            id: maxFeesDisplay
            text: root.maxFeesText

            visible: !!root.maxFeesText

            font.pixelSize: 16
            font.weight: Font.DemiBold
        }
        StatusBaseText {
            text: qsTr("No fees")

            visible: !maxFeesDisplay.visible

            font.pixelSize: maxFeesDisplay.font.pixelSize
            font.weight: maxFeesDisplay.font.weight
        }
    }

    component EstimatedTimeDisplay: ColumnLayout {
        StatusBaseText {
            text: qsTr("Est. time:")
            font.pixelSize: 12
            color: Theme.palette.directColor1
        }
        StatusBaseText {
            text: root.estimatedTimeText
            font.pixelSize: 16
            font.weight: Font.DemiBold
        }
    }

    component IntentionPanel: ColumnLayout {
        spacing: 8

        required property string dappName
        required property url dappIcon
        required property var account

        // Icons
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 8

            StatusRoundedImage {
                id: dappIconComponent

                width: height
                height: parent.height

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: -16
                anchors.verticalCenter: parent.verticalCenter

                image.source: root.dappIcon
            }
            StatusRoundIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: 16
                anchors.verticalCenter: parent.verticalCenter

                asset: StatusAssetSettings {
                    width: 24
                    height: 24
                    color: Theme.palette.primaryColor1
                    bgWidth: 40
                    bgHeight: 40
                    bgColor: Theme.palette.desktopBlue10
                    bgRadius: bgWidth / 2
                    bgBorderWidth: 2
                    bgBorderColor: Theme.palette.statusAppLayout.backgroundColor
                    source: "assets/sign.svg"
                }
            }
        }

        // Names and intentions
        StatusBaseText {
            text: qsTr("%1 wants you to sign this transaction with %2").arg(dappName).arg(account.name)

            Layout.preferredWidth: 400
            Layout.alignment: Qt.AlignHCenter

            font.pixelSize: 15
            font.weight: Font.DemiBold

            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        // TODO #14762: externalize as a InfoPill and merge base implementation with
        // the existing IssuePill reusable component
        Rectangle {
            Layout.preferredWidth: operationStatusLayout.implicitWidth + 24
            Layout.preferredHeight: operationStatusLayout.implicitHeight + 14

            Layout.alignment: Qt.AlignHCenter

            visible: true

            border.color: Theme.palette.successColor2
            border.width: 1
            color: "transparent"
            radius: height / 2

            RowLayout {
                id: operationStatusLayout

                spacing: 8

                anchors.centerIn: parent

                StatusIcon {
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16

                    visible: true

                    color: Theme.palette.directColor1
                    icon: "info"
                }

                StatusBaseText {
                    text: qsTr("Only sign if you trust the dApp")

                    font.pixelSize: 12
                    color: Theme.palette.directColor1
                }
            }
        }
    }

    component ContentPanel: Rectangle {
        id: contentPanelRect
        border.width: 1
        border.color: Theme.palette.baseColor2
        color: "transparent"
        radius: 8

        MouseArea {
            anchors.fill: parent
            cursorShape: contentScrollView.enabled ? undefined : Qt.PointingHandCursor

            onClicked: {
                contentScrollView.enabled = !contentScrollView.enabled
            }
            z: contentScrollView.z + 1
        }

        StatusScrollView {
            id: contentScrollView
            anchors.fill: parent

            contentWidth: availableWidth
            contentHeight: contentText.implicitHeight

            padding: 0

            enabled: false

            StatusBaseText {
                id: contentText
                anchors.fill: parent
                anchors.margins: 20

                width: contentScrollView.availableWidth

                text: d.payloadToDisplay

                wrapMode: Text.WrapAnywhere
            }
        }
    }

    QtObject {
        id: d

        property string payloadToDisplay: ""

        function updatePayloadToDisplay() {
            if (root.method === "eth_signTypedData_v4" && root.signContent) {
                payloadToDisplay = JSON.stringify(JSON.parse(root.signContent), null, 2)
                return
            }
            payloadToDisplay = root.signContent
        }
    }
}
