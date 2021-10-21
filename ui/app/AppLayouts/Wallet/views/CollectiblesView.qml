import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import utils 1.0
import "../../../../shared"
import "../../../../shared/panels"
import "../../../../shared/status/core"

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
            console.log(RootStore.collectionList.count)
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

        ScrollView {
            id: scrollView
            clip: true

            Column {
                id: collectiblesSection
                width: parent.width

                Repeater {
                    id: collectionsRepeater
                    model: RootStore.collectionList
                    //model: 5
                    delegate: StatusExpandableItem {
                        width: parent.width - 156
                        anchors.horizontalCenter: parent.horizontalCenter

                        primaryText: model.name
                        image.source: model.imageUrl
                        type: StatusExpandableItem.Type.Secondary
                        expandableComponent:  CollectibleCollectionView {
                            slug: model.slug
                            anchors.left: parent.left
                            anchors.leftMargin: Style.current.bigPadding
                            anchors.right: parent.right
                            anchors.rightMargin: Style.current.bigPadding
                            onCollectibleClicked: {
                                root.collectibleClicked();
                            }
                        }
                    }
                }
            }
        }
    }
}
