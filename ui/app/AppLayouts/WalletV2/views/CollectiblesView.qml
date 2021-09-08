import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status/core"
import "../components"

import StatusQ.Components 0.1

Item {
    id: collectiblesTab

    Loader {
        id: contentLoader
        width: parent.width
        height: parent.height

        sourceComponent: {
            if (walletV2Model.collectiblesView.isLoading) {
                return loading
            }
            if (walletV2Model.collectiblesView.collections.rowCount() == 0) {
                return empty
            }

            return loaded
        }
    }

    Component {
        id: loading

        Item {
            StatusLoadingIndicator {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                width: 20
                height: 20
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
                width: collectiblesTab.width

                Repeater {
                    id: collectionsRepeater
                    model: walletV2Model.collectiblesView.collections

                    StatusExpandableItem {
                        width: parent.width - 156
                        anchors.horizontalCenter: parent.horizontalCenter

                        primaryText: model.name
                        image.source: model.imageUrl
                        type: StatusExpandableItem.Type.Secondary
                        expandableComponent: CollectibleCollection {
                            slug: model.slug
                            collectionImageUrl:  model.imageUrl
                            collectionIndex: model.index
                        }
                    }
                }
            }
        }
    }
}
