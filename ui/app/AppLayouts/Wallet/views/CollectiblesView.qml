import QtQuick 2.13
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import shared.panels 1.0
import utils 1.0

import utils 1.0

import "collectibles"

Item {
    id: root
    property var collectiblesModel
    width: parent.width

    signal collectibleClicked(string collectionSlug, int collectibleId)

    readonly property bool areCollectionsLoaded: root.collectiblesModel.collectionsLoaded

    Loader {
        id: contentLoader
        width: parent.width
        height: parent.height

        sourceComponent: {
            if (root.areCollectionsLoaded && root.collectiblesModel.collectionCount === 0)
                return empty;
            return loaded;
        }
    }

    Component {
        id: empty
        Item {
            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                color: Style.current.secondaryText
                text: qsTr("Collectibles will appear here")
                font.pixelSize: 15
            }
        }
    }

    Component {
        id: loaded
        StatusGridView {
            id: gridView
            anchors.fill: parent
            model: root.areCollectionsLoaded ? root.collectiblesModel : Constants.dummyModelItems
            cellHeight: 229
            cellWidth: 176
            delegate: CollectibleView {
                height: gridView.cellHeight
                width: gridView.cellWidth
                collectibleModel: root.areCollectionsLoaded ? model : undefined
                isLoadingDelegate: !root.areCollectionsLoaded
                onCollectibleClicked: {
                    root.collectibleClicked(slug, collectibleId);
                }
            }
        }
    }
}
