import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Core.Theme
import StatusQ.Core


Control {
    id: root

    padding: Theme.padding

    readonly property bool allAccepted: havePen.checked &&
                                        writeDown.checked &&
                                        storeIt.checked
    function setAllAccepted() {
        havePen.checked = true
        writeDown.checked = true
        storeIt.checked = true
    }

    QtObject {
        id: d

        readonly property real lineHeight: 1.2
    }

    contentItem: ColumnLayout {
        id: layout

        spacing: root.Theme.padding

        Image {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Theme.padding
            Layout.preferredWidth: 120
            Layout.preferredHeight: 120

            sourceSize: Qt.size(width, height)
            fillMode: Image.PreserveAspectFit
            source: Assets.png("onboarding/keys")
        }

        StatusBaseText {
            Layout.fillWidth: true

            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.bold: true
            font.pixelSize: Theme.fontSize(22)
            text: qsTr("Secure Your Assets and Funds")
        }

        StatusBaseText {
            Layout.fillWidth: true

            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            textFormat: Text.RichText
            font.pixelSize: Theme.primaryTextFontSize
            lineHeight: d.lineHeight
            text: qsTr("Your recovery phrase is a 12-word passcode to your funds.<br/><br/>Your recovery phrase cannot be recovered if lost. Therefore, you <b>must</b> back it up. The simplest way is to <b>write it down offline and store it somewhere secure.</b>")
        }

        StatusCheckBox {
            id: havePen

            objectName: "AddAccountPopup-HavePenAndPaper"

            Layout.fillWidth: true
            Layout.leftMargin: Theme.xlPadding
            Layout.topMargin: Theme.padding
            Layout.alignment: Qt.AlignHCenter

            spacing: Theme.padding
            font.pixelSize: Theme.primaryTextFontSize
            text: qsTr("I have a pen and paper")
        }

        StatusCheckBox {
            id: writeDown

            Layout.fillWidth: true
            Layout.leftMargin: Theme.xlPadding
            Layout.alignment: Qt.AlignHCenter

            objectName: "AddAccountPopup-SeedPhraseWritten"
            spacing: Theme.padding
            font.pixelSize: Theme.primaryTextFontSize
            text: qsTr("I am ready to write down my recovery phrase")
        }

        StatusCheckBox {
            id: storeIt

            Layout.fillWidth: true
            Layout.leftMargin: Theme.xlPadding
            Layout.alignment: Qt.AlignHCenter

            objectName: "AddAccountPopup-StoringSeedPhraseConfirmed"
            spacing: Theme.padding
            font.pixelSize: Theme.primaryTextFontSize
            text: qsTr("I know where I’ll store it")
        }

        Control {
            Layout.fillWidth: true
            Layout.maximumWidth: implicitWidth
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: root.Theme.padding

            padding: root.Theme.padding

            background: Rectangle {
                radius: root.Theme.radius
                color: root.Theme.palette.dangerColor3
            }

            contentItem: StatusBaseText {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Theme.primaryTextFontSize
                wrapMode: Text.WordWrap
                color: Theme.palette.dangerColor1
                lineHeight: d.lineHeight
                text: qsTr("You can only complete this process once. Status will not store your recovery phrase and can never help you recover it.")
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
