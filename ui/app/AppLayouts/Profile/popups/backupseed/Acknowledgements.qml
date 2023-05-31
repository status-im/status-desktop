import QtQuick 2.12
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.12

import shared.panels 1.0
import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1

ColumnLayout {
    id: root

    readonly property bool allAccepted: havePen.checked && writeDown.checked && storeIt.checked

    spacing: Style.current.padding

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        Item {
            anchors.fill: parent
            anchors.margins: -1000
            anchors.bottomMargin: -root.spacing

            clip: true

            StatusScrollView {
                id: flick

                anchors.fill: parent
                anchors.margins: -parent.anchors.margins
                anchors.bottomMargin: -parent.anchors.bottomMargin
                contentWidth: availableWidth

                ScrollBar.vertical.policy: ScrollBar.AlwaysOn

                clip: false

                ColumnLayout {
                    id: flickLayout
                    width: flick.availableWidth
                    spacing: Style.current.padding

                    Image {
                        id: keysImg
                        fillMode: Image.PreserveAspectFit
                        source: Style.png("onboarding/keys")
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
                        font.pixelSize: 22
                        Layout.fillWidth: true
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: Style.current.padding
                        Layout.rightMargin: Style.current.padding
                        spacing: Style.current.bigPadding

                        StyledText {
                            id: txtDesc
                            font.pixelSize: Style.current.primaryTextFontSize
                            horizontalAlignment: Text.AlignHCenter
                            text: qsTr("Your seed phrase is a 12-word passcode to your funds.")
                            Layout.fillWidth: true
                        }

                        StyledText {
                            id: secondTxtDesc
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            textFormat: Text.RichText
                            font.pixelSize: Style.current.primaryTextFontSize
                            lineHeight: 1.2
                            text: qsTr("Your seed phrase cannot be recovered if lost. Therefore, you <b>must</b> back it up. The simplest way is to <b>write it down offline and store it somewhere secure.</b>")
                            Layout.fillWidth: true
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: Style.current.xlPadding
                        Layout.rightMargin: Style.current.xlPadding
                        Layout.topMargin: Style.current.bigPadding
                        spacing: Style.current.bigPadding/2

                        StatusCheckBox {
                            id: havePen
                            objectName: "Acknowledgements_havePen"
                            spacing: Style.current.padding
                            text: qsTr("I have a pen and paper")
                            font.pixelSize: Style.current.primaryTextFontSize
                            Layout.fillWidth: true
                        }

                        StatusCheckBox {
                            id: writeDown
                            objectName: "Acknowledgements_writeDown"
                            spacing: Style.current.padding
                            text: qsTr("I am ready to write down my seed phrase")
                            font.pixelSize: Style.current.primaryTextFontSize
                            Layout.fillWidth: true
                        }

                        StatusCheckBox {
                            id: storeIt
                            objectName: "Acknowledgements_storeIt"
                            spacing: Style.current.padding
                            text: qsTr("I know where I’ll store it")
                            font.pixelSize: Style.current.primaryTextFontSize
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        color: Theme.palette.statusModal.backgroundColor
        Layout.fillWidth: true
        Layout.preferredHeight: 60

        StyledText {
            anchors.fill: parent
            anchors.margins: Style.current.halfPadding
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Style.current.primaryTextFontSize
            wrapMode: Text.WordWrap
            color: Theme.palette.dangerColor1
            lineHeight: 1.2
            text: qsTr("You can only complete this process once. Status will not store your seed phrase and can never help you recover it.")
        }

        Rectangle {
            anchors.fill: parent
            radius: Style.current.radius
            color: Theme.palette.dangerColor1
            opacity: 0.1
        }
    }
}
