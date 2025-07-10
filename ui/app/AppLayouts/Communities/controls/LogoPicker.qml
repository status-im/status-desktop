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
            id: label
            Layout.fillWidth: true
            text: qsTr("Community logo")
            color: Theme.palette.directColor1
            horizontalAlignment: Qt.AlignLeft
        }

        EditCroppedImagePanel {
            id: editor

            Layout.preferredWidth: 128
            Layout.preferredHeight: Layout.preferredWidth / aspectRatio
            Layout.alignment: Qt.AlignHCenter

            imageFileDialogTitle: qsTr("Choose an image as logo")
            title: qsTr("Community logo")
            acceptButtonText: qsTr("Make this my Community logo")

            NoImageUploadedPanel {
                anchors.centerIn: parent

                visible: !editor.userSelectedImage && !root.imageData
            }
        }

        StatusBaseText {
            Layout.fillWidth: true
            visible: editor.isError
            text: qsTr("Upload a community logo")
            font.pixelSize: Theme.tertiaryTextFontSize
            color: Theme.palette.dangerColor1
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
    }
}

