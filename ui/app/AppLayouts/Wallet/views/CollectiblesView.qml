import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared 1.0
import shared.panels 1.0

import "../stores"
import "../popups"
import "collectibles"

import StatusQ.Components 0.1

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
                font.pixelSize: Style.current.primaryTextFontSize
            }
        }
    }

    Component {
        id: loaded

        ScrollView {
            id: scrollView
            clip: true

            Column {
                id: collectiblesSection
                width: root.width

                Repeater {
                    id: collectionsRepeater
                    model: RootStore.collectionList
                    delegate: StatusExpandableItem {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        primaryText: model.name
                        image.source: model.imageUrl
                        type: StatusExpandableItem.Type.Secondary
                        expandableComponent:  CollectibleCollectionView {
                            slug: model.slug
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
