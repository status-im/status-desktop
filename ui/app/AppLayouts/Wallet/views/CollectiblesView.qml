import QtQuick 2.13
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import shared.panels 1.0

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
            if (!root.areCollectionsLoaded)
            {
                return loading
            } else if (root.collectiblesModel.collectionCount === 0) {
                return empty;
            } else if (root.collectiblesModel.count === 0) {
                return loading
            }
            return loaded;
        }
    }

    Component {
        id: loading

        Item {
            id: loadingIndicator
            height: 164
            StatusLoadingIndicator {
                width: 20
                height: 20
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
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
            model: root.collectiblesModel
            cellHeight: 229
            cellWidth: 176
            delegate: Item {
                height: gridView.cellHeight
                width: gridView.cellWidth
                CollectibleView {
                    collectibleModel: model
                    anchors.fill: parent
                    anchors.bottomMargin: 4
                    onCollectibleClicked: {
                        root.collectibleClicked(slug, collectibleId);
                    }
                }
            }
        }
    }
}
