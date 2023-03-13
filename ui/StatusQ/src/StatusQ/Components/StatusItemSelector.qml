import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

/*!
   \qmltype StatusItemSelector
   \inherits StatusFlowSelector
   \inqmlmodule StatusQ.Components
   \since StatusQ.Components 0.1
   \brief It allows to add items and display them as a tag item with an image
   and text. It also allows to store and display logical `and` / `or` operators
   into the list.

   The \c StatusItemSelector is populated with a data model. The data model is
   commonly a JavaScript array or a ListModel object with specific expected roles.

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
StatusFlowSelector {
    id: root

    /*!
       \qmlproperty ListModel StatusItemSelector::model
       This property holds the data that will be populated in the items selector.

       Here an example of the model roles expected:
       \qml
        model: ListModel {
            ListElement {
                text: "Socks"
                imageSource: "qrc:imports/assets/png/tokens/SOCKS.png"
                color: ""
                emoji: ""
                operator: Utils.Operator.None
            }
            ListElement {
                text: "ZRX"
                imageSource: "qrc:imports/assets/png/tokens/ZRX.png"
                color: ""
                emoji: ""
                operator: Utils.Operator.Or
            }
            ListElement {
                text: "Custom Token"
                imageSource: ""
                color: "red"
                emoji: "⚽"
                operator: Utils.Operator.Or
            }
        }
       \endqml
    */
    property alias model: repeater.model
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
    property int tagLeftPadding: 6

    /*!
       \qmlproperty bool StatusItemSelector::useLetterIdenticons
       This property determines if letter identicons should be used. If set to
       true, the model is expected to contain roles "color" and "emoji".
    */
    property bool useLetterIdenticons: false

    /*!
       \qmlproperty bool StatusItemSelector::itemsClickable
       This property determines if items in the selector are clickable (cursor
       is changed on hover and itemClicked emitted when clicked)
    */
    property bool itemsClickable: true

    /*!
       \qmlsignal StatusItemSelector::itemClicked
       This signal is emitted when the item is clicked.
    */
    signal itemClicked(var item, int index, var mouse)

    placeholderItem.visible: repeater.count === 0

    implicitWidth: 560

    Repeater {
        id: repeater

        RowLayout {
            spacing: flowSpacing

            StatusBaseText {
                visible: model.operator !== OperatorsUtils.Operators.None
                Layout.alignment: Qt.AlignVCenter
                text: OperatorsUtils.setOperatorTextFormat(model.operator)
                color: Theme.palette.primaryColor1
                font.pixelSize: 17
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        // Switch operator
                        if(model.operator === OperatorsUtils.Operators.And)
                            model.operator = OperatorsUtils.Operators.Or
                        else
                            model.operator = OperatorsUtils.Operators.And
                    }
                }
            }
            StatusListItemTag {
                title: model.text

                asset.height: root.asset.height
                asset.width: root.asset.width
                asset.name: root.useLetterIdenticons ? model.text : (model.imageSource ?? "")
                asset.isImage: root.asset.isImage
                asset.bgColor: root.asset.bgColor
                asset.emoji: model.emoji ? model.emoji : ""
                asset.color: model.color ? model.color : ""
                asset.isLetterIdenticon: root.useLetterIdenticons
                closeButtonVisible: false
                titleText.color: Theme.palette.primaryColor1
                titleText.font.pixelSize: 15
                leftPadding: root.tagLeftPadding

                MouseArea {
                    anchors.fill: parent
                    enabled: root.itemsClickable
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: root.itemClicked(parent, model.index, mouse)
                }
            }
        }
    }
}
