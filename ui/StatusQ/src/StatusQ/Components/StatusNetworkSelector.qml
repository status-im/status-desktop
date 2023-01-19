import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14 as QC

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1

/*!
   \qmltype StatusItemSelector
   \inherits Rectangle
   \inqmlmodule StatusQ.Components
   \since StatusQ.Components 0.1
   \brief It allows to add items and display them as a tag item with an image and text. It also allows to store and display logical `and` / `or` operators into the list. Inherits \l{https://doc.qt.io/qt-6/qml-qtquick-rectangle.html}{Item}.

   The \c StatusItemSelector is populated with a data model. The data model is commonly a JavaScript array or a ListModel object with specific expected roles.

   Example of how the component looks like:
   \image status_item_selector.png

   Example of how to use it:
   \qml
        StatusItemSelector {
            icon: Style.svg("contact_verified")
            title: qsTr("Who holds")
            defaultItemText: qsTr("Example: 10 SNT")
            andOperatorText: qsTr("and")
            orOperatorText: qsTr("or")

            CustomPopup {
                id: popup
            }

            addButton.onClicked: {
                popup.x = mouse.x
                popup.y = mouse.y
                popup.open()
            }
        }
   \endqml
   For a list of components available see StatusQ.
*/
Rectangle {
    id: root

    // /*!
    //    \qmlproperty string StatusItemSelector::title
    //    This property holds the titel shown on top of the component.
    // */
    // property string title
    /*!
       \qmlproperty string StatusItemSelector::defaultItemText
       This property holds the default item text shown when the list of items is empty.
    */
    property string defaultItemText
    /*!
       \qmlproperty url StatusItemSelector::defaultItemImageSource
       This property holds the default item icon shown when the list of items is empty.
    */
    property url defaultItemImageSource: ""
    /*!
       \qmlproperty StatusRoundButton StatusItemSelector::addButton
       This property holds an alias to the `add` button.
    */
    readonly property alias addButton: addItemButton
    /*!
       \qmlproperty ListModel StatusItemSelector::itemsModel
       This property holds the data that will be populated in the items selector.

       Here an example of the model roles expected:
       \qml
            itemsModel: ListModel {
            ListElement {
                text: "Socks"
                imageSource: "qrc:imports/assets/png/tokens/SOCKS.png"
                operator: Utils.Operator.None
            }
            ListElement {
                text: "ZRX"
                imageSource: "qrc:imports/assets/png/tokens/ZRX.png"
                operator: Utils.Operator.Or
            }
        }
       \endqml
    */
    property var itemsModel: ListModel { }
    /*!
       \qmlproperty bool StatusItemSelector::useIcons
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
    // property int tagLeftPadding: 6

    /*!
       \qmlproperty bool StatusItemSelector::useLetterIdenticons
       This property determines if letter identicons should be used. If set to
       true, the model is expected to contain roles "color" and "emoji".
    */
    property bool useLetterIdenticons: false

    /*!
       \qmlsignal StatusItemSelector::itemClicked
       This signal is emitted when the item is clicked.
    */
    signal itemClicked(var item, int index, var mouse)
    signal itemButtonClicked(var item, int index, var mouse)

    color: "transparent"

    implicitHeight: flow.implicitHeight
    implicitWidth: 560
    clip: true

    property bool closeButtonVisible: false

    property alias defaultItem: defaultListItemTag

    Flow {
        id: flow

        // Layout.fillWidth: true
        spacing: 6

        StatusNetworkListItemTag {
            id: defaultListItemTag

            // bgColor: root.asset.bgColor
            // bgBorderColor: root.asset.bgColor
            visible: !itemsModel || itemsModel.count === 0
            title: root.defaultItemText
            // asset.name: root.defaultItemImageSource
            // asset.bgColor: root.asset.bgColor
            // asset.color: root.asset.color
            // backgroundRect.border.color: Theme.palette.baseColor2
            // backgroundRect.radius: height / 2

            // bgSettings.color.normal: "black"
            // bgSettings.borderColor.normal: "red"
            // bgSettings.radius: height / 2

            // asset.isImage: true
            button.visible: true
            button.icon.name: "add"
            button.enabled: false
            // button.icon.disabledColor: button.icon.color
            button.icon.disabledColor: Theme.palette.primaryColor1
            button.onClicked: {
                console.log("Default add button clicked")
                addButton.clicked(mouse)
            }
            // titleText.color: Theme.palette.
            // titleText.color: root.asset.color
            // titleText.font.pixelSize: 15
            onClicked: {
                console.log("Default item clicked:", mouse.x, mouse.y, 0)
                root.itemClicked(this, 0, mouse)
            }
        }

        Repeater {
            model: itemsModel

            RowLayout {
                spacing: flow.spacing

                StatusNetworkListItemTag {
                    title: model.text

                    asset.height: root.asset.height
                    asset.width: root.asset.width
                    asset.name: root.useLetterIdenticons ? model.text : model.imageSource
                    asset.isImage: root.asset.isImage
                    asset.bgColor: root.asset.bgColor
                    asset.emoji: model.emoji ? model.emoji : ""
                    asset.color: model.color ? model.color : ""
                    asset.isLetterIdenticon: root.useLetterIdenticons
                    //color: Theme.palette.primaryColor3
                    button.visible: root.closeButtonVisible
                    titleText.color: Theme.palette.primaryColor1
                    // titleText.font.pixelSize: 15
                    // leftPadding: root.tagLeftPadding
                    // bgSettings.color.hover: "transparent"
                    hoverEnabled: false

                    onClicked: {
                        console.log("Item clicked:", mouse.x, mouse.y, index)
                        root.itemClicked(this, index, mouse)
                    }

                    button.onClicked: {
                        console.log("Close button clicked for item:", index)
                        root.itemButtonClicked(this, index, mouse)
                        // addButton.clicked(mouse)
                    }
                }
            }
        }

        StatusRoundButton {
            id: addItemButton

            implicitHeight: 32
            implicitWidth: implicitHeight
            height: width
            type: StatusRoundButton.Type.Secondary
            icon.name: "add"
            visible: itemsModel.count > 0
            onClicked: console.log("addItemButton clickced")
        }
    }
}
