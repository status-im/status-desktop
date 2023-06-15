import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14 as QC

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0

/*!
   \qmltype StatusNetworkSelector
   \inherits Rectangle
   \inqmlmodule StatusQ.Components
   \since StatusQ.Components 0.1
   \brief It allows to add items and display them as a tag item with an image and text. It also allows to store and display logical `and` / `or` operators into the list. Inherits \l{https://doc.qt.io/qt-6/qml-qtquick-rectangle.html}{Item}.

   The \c StatusNetworkSelector is populated with a data model. The data model is commonly a JavaScript array or a ListModel object with specific expected roles.

   Example of how the component looks like:
   \image status_item_selector.png

   Example of how to use it:
   \qml
        StatusNetworkSelector {
            id: networkSelector

            title: "Network preference"
            enabled: addressInput.valid
            defaultItemText: "Add networks"
            defaultItemImageSource: "add"

            itemsModel: ListModel {}

            addButton.onClicked: {
            }

            onItemClicked: {
            }

            onItemRightButtonClicked: {
            }
        }
   \endqml
   For a list of components available see StatusQ.
*/
Rectangle {
    id: root

    /*!
       \qmlproperty string StatusNetworkSelector::title
       This property holds the title shown on top of the component.
    */
    property string title
    /*!
       \qmlproperty string StatusNetworkSelector::defaultItemText
       This property holds the default item text shown when the list of items is empty.
    */
    property string defaultItemText
    /*!
       \qmlproperty url StatusNetworkSelector::defaultItemImageSource
       This property holds the default item icon shown when the list of items is empty.
    */
    property string defaultItemImageSource: ""
    /*!
       \qmlproperty StatusRoundButton StatusNetworkSelector::addButton
       This property holds an alias to the `add` button.
    */
    readonly property alias addButton: addItemButton
    /*!
       \qmlproperty ListModel StatusNetworkSelector::itemsModel
       This property holds the data that will be populated in the items selector.

       Here an example of the model roles expected:
       \qml
            itemsModel: ListModel {
            ListElement {
                text: "Ethereum"
                iconUrl: "Network=Ethereum"
            }
            ListElement {
                text: "Optimism"
                iconUrl: "Network=Optimism"
            }
        }
       \endqml
    */
    property var itemsModel: ListModel { }
    /*!
       \qmlproperty bool StatusNetworkSelector::useIcons
       This property determines if the imageSource role from the model will be handled as
       an image or an icon.
    */
    property bool useIcons: false

    property StatusAssetSettings asset: StatusAssetSettings {
        height: 20
        width: 20
        bgColor: "transparent"
        isImage: !root.useIcons
        isLetterIdenticon: root.useLetterIdenticons
    }

    /*!
       \qmlproperty bool StatusNetworkSelector::useLetterIdenticons
       This property determines if letter identicons should be used. If set to
       true, the model is expected to contain roles "color" and "emoji".
    */
    property bool useLetterIdenticons: false

    /*!
       \qmlsignal StatusNetworkSelector::itemClicked
       This signal is emitted when the item is clicked.
    */
    signal itemClicked(var item, int index, var mouse)

    /*!
       \qmlsignal StatusNetworkSelector::itemRightButtonClicked
       This signal is emitted when the item's right button is clicked.
    */
    signal itemRightButtonClicked(var item, int index, var mouse)

    color: "transparent"

    implicitHeight: columnLayout.implicitHeight
    implicitWidth: 560

    property bool rightButtonVisible: false

    /*!
       \qmlproperty StatusNetworkListItemTag StatusNetworkSelector::defaultItem
       This property holds an alias to the `defaultItem` tag
    */

    property alias defaultItem: defaultListItemTag

    ColumnLayout {
        id: columnLayout

        spacing: 8

        StatusBaseText {
            text: root.title
            color: Theme.palette.directColor1
            font.pixelSize: 15
        }

        Flow {
            id: flow

            Layout.preferredWidth: root.width
            Layout.fillWidth: true

            spacing: 6

            StatusRoundButton {
                id: addItemButton
                objectName: "addNetworkTagItemButton"
                
                implicitHeight: 32
                implicitWidth: implicitHeight
                height: width
                type: StatusRoundButton.Type.Tertiary
                border.color: Theme.palette.baseColor2
                icon.name: root.defaultItemImageSource
                visible: itemsModel.count > 0
                icon.color: Theme.palette.primaryColor1
            }

            StatusNetworkListItemTag {
                id: defaultListItemTag
                objectName: "networkSelectorTag"
                visible: !itemsModel || itemsModel.count === 0
                title: root.defaultItemText
                button.visible: true
                button.icon.name: root.defaultItemImageSource
                button.enabled: false
                button.icon.disabledColor: titleText.color
                button.icon.color: titleText.color
                onClicked: {
                    root.itemClicked(this, 0, mouse)
                }
            }

            Repeater {
                model: itemsModel

                StatusNetworkListItemTag {
                    id: networkTag

                    title: model.chainName

                    asset.height: root.asset.height
                    asset.width: root.asset.width
                    asset.name: root.useLetterIdenticons ? model.text : Style.svg(model.iconUrl)
                    asset.isImage: root.asset.isImage
                    asset.bgColor: root.asset.bgColor
                    asset.isLetterIdenticon: root.useLetterIdenticons
                    button.visible: root.rightButtonVisible
                    titleText.color: Theme.palette.primaryColor1
                    button.icon.disabledColor: titleText.color
                    button.icon.color: titleText.color
                    hoverEnabled: false

                    property var modelRef: model // model is not reachable outside via item.model.someData, so expose it

                    onClicked: {
                        root.itemClicked(this, index, mouse)
                    }

                    button.onClicked: {
                        root.itemRightButtonClicked(networkTag, index, mouse)
                    }
                }
            }
        }
    }
}
