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
    signal collectibleClicked(string collectionSlug, int collectibleId)

    Loader {
        id: contentLoader
        width: parent.width
        height: parent.height

        sourceComponent: {
            if (!RootStore.collections.collectionsLoaded)
            {
                return loading
            } else if (RootStore.collections.count === 0) {
                return empty;
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

        StatusScrollView {
            id: scrollView

            Column {
                id: collectiblesSection
                width: root.width

                Repeater {
                    objectName: "collectionsRepeater"
                    id: collectionsRepeater
                    model: RootStore.collections
                    delegate: StatusExpandableItem {
                        id: collectionDelegate
                        anchors.left: parent.left
                        anchors.right: parent.right
                        primaryText: model.name
                        asset.name: model.imageUrl
                        asset.isImage: true
                        type: StatusExpandableItem.Type.Secondary
                        expandableComponent:  CollectibleCollectionView {
                            collectionImageUrl: model.imageUrl
                            collectiblesLoaded: model.collectiblesLoaded
                            collectiblesModel: model.collectiblesModel
                            anchors.left: parent.left
                            anchors.right: parent.right
                            onCollectibleClicked: {
                                RootStore.selectCollectible(model.slug, collectibleId)
                                root.collectibleClicked(model.slug, collectibleId);
                            }
                        }
                        onExpandedChanged: {
                            if(expanded) {
                               RootStore.fetchCollectibles(model.slug)
                            }
                        }
                    }
                }
            }
        }
    }
}
