import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.1

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

StatusModal {
    id: root

    property string name
    property string introMessage
    property url imageSrc

    signal joined

    // Code below is needed because StatusModal content padding is messed up
    // FIXME: when StatusModal is reworked
    width: undefined       // popup is able to determine size from its content
    topPadding: 64 + 16    // 64 is header height
    leftPadding: 16
    rightPadding: 16
    bottomPadding: 71 + 16 // 71 is footer height

    header.title: qsTr("Welcome to %1").arg(name)

    rightButtons: [
        StatusButton {
            text: qsTr("Join %1").arg(root.name)
            enabled: checkBox.checked
            onClicked: {
                root.joined()
                root.close()
            }
        }
    ]

    ColumnLayout {
        anchors.fill: parent

        spacing: 24

        StatusRoundedImage {
            Layout.alignment: Qt.AlignCenter
            Layout.preferredHeight: 64
            Layout.preferredWidth: 64

            visible: image.status == Image.Loading || image.status == Image.Ready
            image.source: root.imageSrc
        }

        ScrollView {
            Layout.preferredWidth: contentWidth
            Layout.minimumWidth: 300

            Layout.fillHeight: true
            Layout.preferredHeight: contentHeight
            Layout.maximumHeight: 400

            contentWidth: messageContent.width
            contentHeight: messageContent.height

            clip: true

            StatusBaseText {
                id: messageContent

                width: Math.min(implicitWidth, 640)

                text: root.introMessage !== "" ? root.introMessage : qsTr("Community <b>%1</b> has no intro message...").arg(root.name)
                clip: true
                color: Theme.palette.directColor1
                wrapMode: Text.WordWrap
            }
        }

        StatusCheckBox {
            id: checkBox
            Layout.alignment: Qt.AlignCenter
            text: qsTr("I agree with the above")
        }
    }
}
