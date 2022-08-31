import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1

StatusDialog {
    id: root

    property string link

    title: qsTr("Choose browser")
    width: 400
    footer: null

    contentItem: ColumnLayout {
        spacing: 20

        Image {
            source: Style.png("browser/chooseBrowserImage@2x")
            Layout.preferredWidth: 240
            Layout.preferredHeight: 148
            Layout.alignment: Qt.AlignHCenter
        }

        StatusButton {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Open in Status")
            font.weight: Font.Medium
            onClicked: {
                localAccountSensitiveSettings.showBrowserSelector = !rememberChoiceCheckBox.checked
                if (rememberChoiceCheckBox.checked) {
                    localAccountSensitiveSettings.openLinksInStatus = true
                }
                Global.changeAppSectionBySectionType(Constants.appSection.browser)
                Global.openLinkInBrowser(root.link)
                root.close()
            }
        }

        StatusFlatButton {
            text: qsTr("Open in my default browser")
            Layout.alignment: Qt.AlignHCenter
            font.weight: Font.Medium
            onClicked: {
                localAccountSensitiveSettings.showBrowserSelector = !rememberChoiceCheckBox.checked
                if (rememberChoiceCheckBox.checked) {
                    localAccountSensitiveSettings.openLinksInStatus = false
                }
                Qt.openUrlExternally(root.link)
                root.close()
            }
        }

        StatusCheckBox {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: Style.current.smallPadding
            id: rememberChoiceCheckBox
            font.pixelSize: 13
            text: qsTr("Remember my choice. To override it, go to settings.")
        }
    }
}
