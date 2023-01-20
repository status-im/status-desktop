import QtQuick 2.13
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import shared.panels 1.0

Item {
    id: root
    property var collectibleModel

    implicitHeight: 225
    implicitWidth: 176

    signal collectibleClicked(string slug, int collectibleId)

    readonly property bool isLoaded: root.collectibleModel.collectionCollectiblesLoaded

    ColumnLayout {
        //Layout.fillHeight: true
        //Layout.fillWidth: true
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 0

        StatusRoundedImage {
            id: image
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.topMargin: 8
            Layout.bottomMargin: 0
            implicitWidth: 160
            implicitHeight: 160
            radius: 12
            image.source: root.collectibleModel.imageUrl
            border.color: Theme.palette.baseColor2
            border.width: 1
            showLoadingIndicator: true
            color: root.collectibleModel.backgroundColor
        }
        StatusBaseText {
            id: collectibleLabel
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.topMargin: 9
            Layout.preferredWidth: 144
            Layout.preferredHeight: 21
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 15
            color: Theme.palette.directColor1
            font.weight: Font.DemiBold
            elide: Text.ElideRight
            text: isLoaded ? root.collectibleModel.name : "..."
        }
        StatusBaseText {
            id: collectionLabel
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.topMargin: 0
            Layout.preferredWidth: 144
            Layout.preferredHeight: 18
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 13
            color: Theme.palette.baseColor1
            elide: Text.ElideRight
            text: root.collectibleModel.collectionName
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 18
        border.width: 1
        border.color: Theme.palette.primaryColor1
        color: Theme.palette.indirectColor3
        visible: root.isLoaded && mouse.containsMouse
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if (root.isLoaded) {
                root.collectibleClicked(root.collectibleModel.collectionSlug, root.collectibleModel.id);
            }
        }
    }
}