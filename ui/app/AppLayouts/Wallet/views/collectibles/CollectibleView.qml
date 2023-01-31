import QtQuick 2.13
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import shared.panels 1.0

import utils 1.0

Item {
    id: root

    property var collectibleModel
    property bool isLoadingDelegate

    signal collectibleClicked(string slug, int collectibleId)

    QtObject {
        id: d
        readonly property bool modeDataValid: !!root.collectibleModel && root.collectibleModel !== undefined
        readonly property bool isLoaded: modeDataValid ? root.collectibleModel.collectionCollectiblesLoaded : false
    }

    implicitHeight: 225
    implicitWidth: 176

    ColumnLayout {
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
            image.source: d.modeDataValid ? root.collectibleModel.imageUrl : ""
            border.color: Theme.palette.baseColor2
            border.width: 1
            showLoadingIndicator: true
            color: d.modeDataValid ? root.collectibleModel.backgroundColor : "transparent"
            Loader {
                anchors.fill: parent
                active: root.isLoadingDelegate
                sourceComponent: LoadingComponent {radius: image.radius}
            }
        }
        StatusTextWithLoadingState {
            id: collectibleLabel
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.leftMargin: 8
            Layout.topMargin: 9
            Layout.preferredWidth: isLoadingDelegate ? 134 : 144
            Layout.preferredHeight: 21
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 15
            customColor: Theme.palette.directColor1
            font.weight: Font.DemiBold
            elide: Text.ElideRight
            text: isLoadingDelegate ? Constants.dummyText : d.isLoaded && d.modeDataValid ? root.collectibleModel.name : "..."
            loading: root.isLoadingDelegate
        }
        StatusTextWithLoadingState {
            id: collectionLabel
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.leftMargin: 8
            Layout.preferredWidth: isLoadingDelegate ? 88 : 144
            Layout.preferredHeight: 18
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 13
            customColor: Theme.palette.baseColor1
            elide: Text.ElideRight
            text: isLoadingDelegate ? Constants.dummyText : d.modeDataValid ? root.collectibleModel.collectionName : ""
            loading: root.isLoadingDelegate
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 18
        border.width: 1
        border.color: Theme.palette.primaryColor1
        color: Theme.palette.indirectColor3
        visible: d.isLoaded && mouse.containsMouse
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if (d.isLoaded) {
                root.collectibleClicked(root.collectibleModel.collectionSlug, root.collectibleModel.id);
            }
        }
    }
}
