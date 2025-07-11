import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import shared.panels
import utils

import StatusQ.Controls
import StatusQ.Core.Theme
import StatusQ.Core

ColumnLayout {
    id: root

    readonly property bool allAccepted: havePen.checked && writeDown.checked && storeIt.checked

    spacing: Theme.padding

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        Item {
            anchors.fill: parent
            clip: true

            StatusScrollView {
                id: flick

                anchors.fill: parent
                contentWidth: availableWidth

                ScrollBar.vertical.policy: ScrollBar.AlwaysOn

                clip: false

                ColumnLayout {
                    id: flickLayout
                    width: flick.availableWidth
                    spacing: Theme.padding

                    Image {
                        id: keysImg
                        fillMode: Image.PreserveAspectFit
                        source: Theme.png("onboarding/keys")
                        mipmap: true
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: width
                        cache: false
                    }

                    StyledText {
                        id: txtTitle
                        text: qsTr("Secure Your Assets and Funds")
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        font.bold: true
                        font.pixelSize: Theme.fontSize22
                        Layout.fillWidth: true
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: Theme.padding
                        Layout.rightMargin: Theme.padding
                        spacing: Theme.bigPadding

                        StyledText {
                            id: txtDesc
                            font.pixelSize: Theme.primaryTextFontSize
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            text: qsTr("Your recovery phrase is a 12-word passcode to your funds.")
                            Layout.fillWidth: true
                        }

                        StyledText {
                            id: secondTxtDesc
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            textFormat: Text.RichText
                            font.pixelSize: Theme.primaryTextFontSize
                            lineHeight: 1.2
                            text: qsTr("Your recovery phrase cannot be recovered if lost. Therefore, you <b>must</b> back it up. The simplest way is to <b>write it down offline and store it somewhere secure.</b>")
                            Layout.fillWidth: true
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: Theme.xlPadding
                        Layout.rightMargin: Theme.xlPadding
                        Layout.topMargin: Theme.bigPadding
                        spacing: Theme.bigPadding/2

                        StatusCheckBox {
                            id: havePen
                            objectName: "Acknowledgements_havePen"
                            spacing: Theme.padding
                            text: qsTr("I have a pen and paper")
                            font.pixelSize: Theme.primaryTextFontSize
                            Layout.fillWidth: true
                        }

                        StatusCheckBox {
                            id: writeDown
                            objectName: "Acknowledgements_writeDown"
                            spacing: Theme.padding
                            text: qsTr("I am ready to write down my recovery phrase")
                            font.pixelSize: Theme.primaryTextFontSize
                            Layout.fillWidth: true
                        }

                        StatusCheckBox {
                            id: storeIt
                            objectName: "Acknowledgements_storeIt"
                            spacing: Theme.padding
                            text: qsTr("I know where I’ll store it")
                            font.pixelSize: Theme.primaryTextFontSize
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: (warningText.contentHeight + Theme.padding)

        StyledText {
            id: warningText
            anchors.fill: parent
            anchors.margins: Theme.halfPadding
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Theme.primaryTextFontSize
            wrapMode: Text.WordWrap
            color: Theme.palette.dangerColor1
            lineHeight: 1.2
            text: qsTr("You can only complete this process once. Status will not store your recovery phrase and can never help you recover it.")
        }

        Rectangle {
            anchors.fill: parent
            radius: Theme.radius
            color: Theme.palette.dangerColor1
            opacity: 0.1
        }
    }
}
