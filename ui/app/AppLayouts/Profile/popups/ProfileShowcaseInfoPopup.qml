import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Popups.Dialog
import StatusQ.Controls
import StatusQ.Core.Theme

import AppLayouts.Communities.panels

import utils

StatusDialog {
    id: root

    width: 480 // by design
    padding: Theme.padding
    closePolicy: Popup.NoAutoClose
    footer.visible: false
    header: Item {
        width: root.width

        StatusHeaderActions {
            anchors {
                top: parent.top
                right: parent.right
                margins: Theme.smallPadding
            }
            closeButton.onClicked: root.close()
        }
    }
    contentItem: ColumnLayout {
        spacing: Theme.padding

        IntroPanel {
            Layout.fillWidth: true

            image: Assets.png("onboarding/welcome")
            imageWidth: 200
            imageBottomMargin: Theme.padding
            bottomPadding: 0
            padding: 0
            title: qsTr("Build your profile showcase")
            subtitle: qsTr("Show visitors to your profile...")
            background: Item {}
            checkersModel: [
                qsTr("Communities you are a member of"),
                qsTr("Assets and collectibles you hodl"),
                qsTr("Accounts you own to make sending your funds easy"),
                qsTr("Choose your level of privacy with visibility controls")
            ]
        }

        StatusButton {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: Theme.bigPadding
            objectName: "buildShowcaseButton"

            text: qsTr("Build your showcase")
            onClicked: root.close()
        }
    }
}
