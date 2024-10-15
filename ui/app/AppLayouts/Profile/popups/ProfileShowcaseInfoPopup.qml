import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Popups.Dialog 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Communities.panels 1.0

import utils 1.0

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

            image: Theme.png("onboarding/welcome")
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
