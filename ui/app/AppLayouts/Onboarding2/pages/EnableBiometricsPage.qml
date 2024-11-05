import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

OnboardingPage {
    id: root

    title: qsTr("Enable biometrics")

    property string subtitle

    signal enableBiometricsRequested(bool enable)

    contentItem: Item {
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20
            width: Math.min(400, root.availableWidth)

            StatusBaseText {
                Layout.fillWidth: true
                text: root.title
                font.pixelSize: 22
                font.bold: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
            StatusBaseText {
                Layout.fillWidth: true
                Layout.topMargin: -12
                text: root.subtitle
                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            StatusImage {
                Layout.preferredWidth: 260
                Layout.preferredHeight: 260
                Layout.topMargin: 20
                Layout.bottomMargin: 20
                Layout.alignment: Qt.AlignHCenter
                mipmap: true
                source: Theme.png("onboarding/enable_biometrics")
            }

            StatusButton {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Yes, use biometrics")
                onClicked: root.enableBiometricsRequested(true)
            }

            StatusFlatButton {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Maybe later")
                onClicked: root.enableBiometricsRequested(false)
            }
        }
    }
}
