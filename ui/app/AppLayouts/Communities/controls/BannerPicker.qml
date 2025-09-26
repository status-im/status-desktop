import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import shared.panels

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Controls

Item {
    id: root

    property alias source: editor.source
    property alias cropRect: editor.cropRect
    property alias imageData: editor.dataImage

    readonly property bool hasSelectedImage: localAppSettings.testEnvironment ?
                                                 true : editor.userSelectedImage

    implicitHeight: layout.implicitHeight

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

            Layout.fillWidth: true
            Layout.maximumWidth: 475
            Layout.preferredHeight: width / aspectRatio
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

