import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Components 0.1
import StatusQ.Components.private 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

import AppLayouts.Wallet.panels 1.0

import utils 1.0

Control {
    id: root

    /** Expected model structure: see TokenSelectorPanel::assetsModel **/
    property alias assetsModel: tokenSelectorPanel.assetsModel

    /** Expected model structure: see TokenSelectorPanel::collectiblesModel **/
    property alias collectiblesModel: tokenSelectorPanel.collectiblesModel

    readonly property bool isTokenSelected: d.isTokenSelected

    signal assetSelected(string key)
    signal collectionSelected(string key)
    signal collectibleSelected(string key)

    // Index of the current tab, indexes ​​correspond to the
    // TokensSelectorPanel.Tabs enum values.
    property alias currentTab: tokenSelectorPanel.currentTab

    function setCustom(name: string, icon: url, key: string) {
        d.isTokenSelected = true
        d.currentName = name
        d.currentIcon = icon
        tokenSelectorPanel.highlightedKey = key ?? ""
    }

    padding: 10

    QtObject {
        id: d

        property bool isTokenSelected: false

        property string currentName
        property url currentIcon
    }

    background: StatusComboboxBackground {
        border.width: 0
        color: {
            if (d.isTokenSelected)
                return "transparent"

            return root.hovered || dropdown.opened
                    ? Theme.palette.primaryColor2
                    : Theme.palette.primaryColor3
        }
    }

    contentItem: Loader {
        sourceComponent: d.isTokenSelected ? selectedContent
                                           : notSelectedContent
    }

    Component {
        id: notSelectedContent

        RowLayout {
            spacing: 10

            StatusBaseText {
                objectName: "tokenSelectorContentItemText"
                font.pixelSize: root.font.pixelSize
                font.weight: Font.Medium
                color: Theme.palette.primaryColor1
                text: qsTr("Select token")
            }

            StatusComboboxIndicator {
                color: Theme.palette.primaryColor1
            }
        }
    }

    Component {
        id: selectedContent

        RowLayout {
            spacing: Style.current.halfPadding
            width: parent.width

            StatusRoundedImage {
                id: tokenSelectorIcon
                objectName: "tokenSelectorIcon"
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                image.source: d.currentIcon
            }

            StatusBaseText {
                objectName: "tokenSelectorContentItemText"
                font.pixelSize: 28
                color: root.hovered ? Theme.palette.blue : Theme.palette.darkBlue
                Layout.maximumWidth: parent.width - (tokenSelectorIcon.width + comboboxIndicator.width + parent.spacing * 2)
                elide: Text.ElideRight
                Layout.alignment: Qt.AlignLeft

                text: d.currentName
            }

            Item {
                // Encapsulated into the item to not resize the icon
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                StatusComboboxIndicator {
                    id: comboboxIndicator
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.palette.primaryColor1
                }
            }
        }
    }

    StatusDropdown {
        id: dropdown

        y: parent.height + 4

        closePolicy: Popup.CloseOnPressOutsideParent
        bottomPadding: 0

        contentItem: TokenSelectorPanel {
            id: tokenSelectorPanel

            objectName: "tokenSelectorPanel"

            function findSubitem(key) {
                const count = collectiblesModel.rowCount()

                for (let i = 0; i < count; i++) {
                    const entry = ModelUtils.get(collectiblesModel, i)
                    const subitem = ModelUtils.getByKey(
                                      entry.subitems, "key", key)
                    if (subitem)
                        return subitem
                }
            }

            function setCurrentAndClose(name, icon) {
                d.currentName = name
                d.currentIcon = icon
                d.isTokenSelected = true
                dropdown.close()
            }

            onAssetSelected: {
                const entry = ModelUtils.getByKey(assetsModel, "tokensKey", key)
                highlightedKey = key

                setCurrentAndClose(entry.symbol, entry.iconSource)
                root.assetSelected(key)
            }

            onCollectibleSelected: {
                highlightedKey = key

                const subitem = findSubitem(key)
                setCurrentAndClose(subitem.name, subitem.icon)

                root.collectibleSelected(key)
            }

            onCollectionSelected: {
                highlightedKey = key

                const subitem = findSubitem(key)
                setCurrentAndClose(subitem.name, subitem.icon)

                root.collectionSelected(key)
            }
        }
    }

    MouseArea {
        cursorShape: root.enabled ? Qt.PointingHandCursor : undefined
        anchors.fill: parent
        onClicked: dropdown.opened ? dropdown.close() : dropdown.open()
    }
}
