import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.13

import utils 1.0
import shared.panels 1.0
import shared.popups 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Layout 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

Item {
    id: root

    property alias source: editor.source
    property alias cropRect: editor.cropRect
    property alias imageData: editor.dataImage

    readonly property bool hasSelectedImage: localAppSettings.testEnvironment ? true : editor.userSelectedImage

    implicitHeight: layout.childrenRect.height

    ColumnLayout {
        id: layout

        anchors.fill: parent

        spacing: 8

        StatusBaseText {
            text: qsTr("Community banner")

            font.pixelSize: 15
            color: Theme.palette.directColor1
        }

        EditCroppedImagePanel {
            id: editor

            Layout.preferredWidth: 475
            Layout.preferredHeight: Layout.preferredWidth / aspectRatio
            Layout.alignment: Qt.AlignHCenter

            imageFileDialogTitle: qsTr("Choose an image for banner")
            title: qsTr("Community banner")
            acceptButtonText: qsTr("Make this my Community banner")

            roundedImage: false
            aspectRatio: 375/184

            NoImageUploadedPanel {
                anchors.centerIn: parent

                visible: !editor.userSelectedImage && !root.imageData
                showAdditionalInfo: true
            }
        }
    }
}

