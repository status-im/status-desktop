import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import utils

import StatusQ.Controls
import StatusQ.Core.Theme
import StatusQ.Popups.Dialog

StatusDialog {
    id: root

    property string link

    title: qsTr("Choose browser")
    width: 400
    footer: null

    contentItem: ColumnLayout {
        spacing: 20

        Image {
            source: Theme.png("browser/chooseBrowserImage@2x")
            Layout.preferredWidth: 240
            Layout.preferredHeight: 148
            Layout.alignment: Qt.AlignHCenter
            cache: false
        }

        StatusButton {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Open in Status")
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
            Layout.bottomMargin: Theme.smallPadding
            id: rememberChoiceCheckBox
            font.pixelSize: Theme.additionalTextSize
            text: qsTr("Remember my choice. To override it, go to Settings.")
        }
    }
}
