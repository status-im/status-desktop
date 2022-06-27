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
            popupItem: CustomPopup {
                id: customPopup
                onAddItem: {
                    tokensSelector.addItem(itemText, itemImage, operator)
                    customPopup.close()
                }
            }
        }
   \endqml
   For a list of components available see StatusQ.
*/
Rectangle {
    id: root
    /*!
       \qmlproperty string StatusItemSelector::icon
       This property holds the icon name for the icon represented on top of the component as a title icon.
    */
    property string icon
    /*!
       \qmlproperty int StatusItemSelector::iconSize
       This property holds the icon size for the icon represented on top of the component as a title icon.
    */
    property int iconSize: 18
    /*!
       \qmlproperty string StatusItemSelector::title
       This property holds the titel shown on top of the component.
    */
    property string title
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
       \qmlproperty QC.Popup StatusItemSelector::popupItem
       This property holds a custom popup item to be opened near the `add` button in order to select new items.
    */
    property QC.Popup popupItem
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
    property ListModel itemsModel: ListModel { }
    /*!
       \qmlproperty string StatusItemSelector::andOperatorText
       This property holds the string text representation for an `AND` logical operator.
    */
    property string andOperatorText: qsTr("and")
    /*!
       \qmlproperty string StatusItemSelector::orOperatorText
       This property holds the string text representation for an `OR` logical operator.
    */
    property string orOperatorText: qsTr("or")
    /*
        \qmlmethod StatusItemSelector::addItem()
        It is used to add new items into the selector control. The expected arguments are:
        string `text`, url `imageSource` and int `operator` (None = 0, And = 1 and Or = 2)
    */
    function addItem(text, imageSource, operator) {
        itemsModel.insert(itemsModel.count, { "text": text, "imageSource": imageSource.toString(), "operator": operator })
    }

    QtObject {
        id: d

        function operatorTextFormat(operator) {
            switch(operator)
            {
            case Utils.Operators.And:
                return root.andOperatorText
            case Utils.Operators.Or:
                return root.orOperatorText
            case Utils.Operators.None:
                return ""
            }
        }
    }

    color: Theme.palette.baseColor4
    implicitHeight: columnLayout.implicitHeight + columnLayout.anchors.topMargin + columnLayout.anchors.bottomMargin
    implicitWidth: 560
    radius: 16
    clip: true

    ColumnLayout {
        id: columnLayout
        anchors.top: parent.top
        anchors.topMargin: 12
        anchors.bottomMargin: anchors.topMargin
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.right: parent.right
        anchors.rightMargin: 16
        spacing: 12
        clip: true
        RowLayout {
            id: headerRow
            spacing: 8
            Image {
                sourceSize.width: width || undefined
                sourceSize.height: height || undefined
                fillMode: Image.PreserveAspectFit
                mipmap: true
                antialiasing: true
                width: root.iconSize
                height: width
                source: root.icon
            }
            StatusBaseText {
                Layout.alignment: Qt.AlignVCenter
                text: root.title
                color: Theme.palette.directColor1
                font.pixelSize: 17
            }
        }        
        Flow {
            id: flow
            Layout.fillWidth: true
            spacing: 6
            StatusListItemTag {
                visible: itemsModel.count === 0
                title: root.defaultItemText
                image.source: root.defaultItemImageSource
                color: Theme.palette.baseColor2
                closeButtonVisible: false
                titleText.color: Theme.palette.baseColor1
                titleText.font.pixelSize: 15
            }
            Repeater {
                model: itemsModel
                RowLayout {
                    spacing: flow.spacing
                    StatusBaseText {                        
                        visible: model.operator !== Utils.Operators.None
                        Layout.alignment: Qt.AlignVCenter
                        text: d.operatorTextFormat(model.operator)
                        color: Theme.palette.primaryColor1
                        font.pixelSize: 17
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                // Switch operator
                                if(model.operator === Utils.Operators.And)
                                    model.operator = Utils.Operators.Or
                                else
                                    model.operator = Utils.Operators.And
                            }
                        }
                    }
                    StatusListItemTag {
                        title: model.text
                        image.source: model.imageSource
                        color: Theme.palette.primaryColor3
                        closeButtonVisible: false
                        titleText.color: Theme.palette.primaryColor1
                        titleText.font.pixelSize: 15
                        //onClicked: // TODO: Open remove or edit dialog
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
                onClicked: {
                    root.popupItem.x = addItemButton.x + addItemButton.width + 4 * flow.spacing
                    root.popupItem.y = addItemButton.y + addItemButton.height
                    root.popupItem.open()
                }
            }
        }
    }
}
