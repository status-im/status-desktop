import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../../../imports"
import "../../../shared"
import "../../../shared/status/core"
import "./components"

Item {
    id: root

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

    CollectibleModal {
        id: collectibleModalComponent
    }

    Component {
        id: loaded

        ScrollView {
            id: scrollView
            clip: true

            Column {
                id: collectiblesSection
                spacing: Style.current.halfPadding
                width: root.width

                Repeater {
                    id: collectionsRepeater
                    model: walletV2Model.collectiblesView.collections

                    CollectibleCollection {
                        name: model.name
                        imageUrl: model.imageUrl
                        ownedAssetCount: model.ownedAssetCount
                        slug: model.slug
                        collectibleModal: collectibleModalComponent
                        anchors.left: parent.left
                        anchors.leftMargin: Style.current.bigPadding
                        anchors.right: parent.right
                        anchors.rightMargin: Style.current.bigPadding
                    }
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:480;width:640}
}
##^##*/
