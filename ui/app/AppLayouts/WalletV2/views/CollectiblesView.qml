import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import StatusQ.Components 0.1

import utils 1.0
import shared.panels 1.0

import "../popups"
import "collectibles"

import StatusQ.Components 0.1

Item {
    id: root
    width: parent.width
    property var store
    signal collectibleClicked()

    Loader {
        id: contentLoader
        width: parent.width
        height: parent.height

        sourceComponent: {
            // Not Refactored Yet
//            if (root.store.walletModelV2Inst.collectiblesView.isLoading) {
//                return loading;
//            }
//            if (root.store.walletModelV2Inst.collectiblesView.collections.rowCount() === 0) {
//                return empty;
//            }
            return loaded;
        }
    }

    Component {
        id: loading
        Item {
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

        ScrollView {
            id: scrollView
            clip: true

            Column {
                id: collectiblesSection
                width: parent.width

                Repeater {
                    id: collectionsRepeater
                    // Not Refactored Yet
//                    model: root.store.walletModelV2Inst.collectiblesView.collections
                    //model: 5
                    delegate: StatusExpandableItem {
                        width: parent.width - 156
                        anchors.horizontalCenter: parent.horizontalCenter

                        primaryText: model.name
                        image.source: model.imageUrl
                        type: StatusExpandableItem.Type.Secondary
                        expandableComponent:  CollectibleCollectionView {
                            store: root.store
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
