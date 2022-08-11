import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Components 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0

import "../stores"
import "../popups"
import "collectibles"

Item {
    id: root
    width: parent.width
    signal collectibleClicked()

    Loader {
        id: contentLoader
        width: parent.width
        height: parent.height

        sourceComponent: {
            if (RootStore.collectionList.count === 0) {
                return empty;
            }
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

        StatusScrollView {
            id: scrollView

            Column {
                id: collectiblesSection
                width: root.width

                Repeater {
                    objectName: "collectionsRepeater"
                    id: collectionsRepeater
                    model: RootStore.collectionList
                    delegate: StatusExpandableItem {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        primaryText: model.name
                        asset.name: model.imageUrl
                        asset.isImage: true
                        type: StatusExpandableItem.Type.Secondary
                        expandableComponent:  CollectibleCollectionView {
                            slug: model.slug
                            collectionImageUrl: model.imageUrl
                            anchors.left: parent.left
                            anchors.right: parent.right
                            onCollectibleClicked: {
                                root.collectibleClicked();
                            }
                        }
                        onExpandedChanged: {
                            if(expanded) {
                               RootStore.fetchCollectionCollectiblesList(model.slug)
                            }
                        }
                    }
                }
            }
        }
    }
}
