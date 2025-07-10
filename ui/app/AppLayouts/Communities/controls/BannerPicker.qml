import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import Qt5Compat.GraphicalEffects

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

    function validate() {
        editor.isError = !hasSelectedImage
    }

    ColumnLayout {
        id: layout

        anchors.fill: parent

        spacing: 16

        StatusBaseText {
            text: qsTr("Community banner")

            font.pixelSize: Theme.primaryTextFontSize
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
            aspectRatio: 475/184

            NoImageUploadedPanel {
                anchors.centerIn: parent

                visible: !editor.userSelectedImage && !root.imageData
                showAdditionalInfo: true
                contentSpacing: 2
                iconWidth: 24
                iconHeight: 24
                additionalText: qsTr("Optimal aspect ratio 16:9")
                additionalTextPixelSize: Theme.tertiaryTextFontSize
            }
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.topMargin: -layout.spacing/2
            visible: editor.isError
            text: qsTr("Upload a community banner")
            font.pixelSize: Theme.tertiaryTextFontSize
            color: Theme.palette.dangerColor1
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
    }
}

