import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Core.Theme

OnboardingPage {
    id: root

    title: qsTr("Enable biometrics")

    property string subtitle: qsTr("Would you like to enable biometrics to fill in your password? You will use biometrics for signing in to Status and for signing transactions.")

    signal enableBiometricsRequested(bool enable)

    contentItem: Item {
        ColumnLayout {
            anchors.centerIn: parent
            spacing: Theme.bigPadding
            width: Math.min(400, root.availableWidth)

            StatusImage {
                Layout.preferredWidth: 270
                Layout.preferredHeight: 260
                Layout.alignment: Qt.AlignHCenter
                mipmap: true
                smooth: false
                source: Theme.png("onboarding/enable_biometrics")
            }

            StatusBaseText {
                Layout.fillWidth: true
                text: root.title
                font.pixelSize: Theme.fontSize22
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

            StatusButton {
                objectName: "btnEnableBiometrics"
                Layout.topMargin: Theme.halfPadding
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Yes, use biometrics")
                onClicked: root.enableBiometricsRequested(true)
            }

            StatusFlatButton {
                objectName: "btnDontEnableBiometrics"
                Layout.topMargin: -Theme.halfPadding
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Maybe later")
                onClicked: root.enableBiometricsRequested(false)
            }
        }
    }
}
