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

    property string subtitle: qsTr("Would you like to enable biometrics to fill in your password? You will use biometrics for signing in to Status and for signing transactions.")

    signal enableBiometricsRequested(bool enable)

    pageClassName: "EnableBiometricsPage"

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

            StatusButton {
                Layout.topMargin: Theme.halfPadding
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Yes, use biometrics")
                onClicked: root.enableBiometricsRequested(true)
            }

            StatusFlatButton {
                Layout.topMargin: -Theme.halfPadding
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Maybe later")
                onClicked: root.enableBiometricsRequested(false)
            }
        }
    }
}
