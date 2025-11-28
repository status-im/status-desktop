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

    property string subtitle: qsTr("Use biometrics to fill in your password")

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
                source: Assets.png("onboarding/enable_biometrics")
            }

            StatusBaseText {
                Layout.fillWidth: true
                text: root.title
                font.pixelSize: Theme.fontSize(22)
                font.bold: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
            StatusBaseText {
                Layout.fillWidth: true
                text: root.subtitle
                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            StatusButton {
                objectName: "btnEnableBiometrics"
                Layout.topMargin: Theme.halfPadding
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Enable")
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
