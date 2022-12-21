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
    /*!
       \qmlsignal StatusItemSelector::itemClicked
       This signal is emitted when the item is clicked.
    */
    signal itemClicked(var item, int index, var mouse)

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
                bgColor: Theme.palette.baseColor2
                visible: !itemsModel || itemsModel.count === 0
                title: root.defaultItemText
                asset.name: root.defaultItemImageSource
                asset.isImage: true
                closeButtonVisible: false
                titleText.color: Theme.palette.baseColor1
                titleText.font.pixelSize: 15
            }
            Repeater {
                model: itemsModel

                RowLayout {
                    spacing: flow.spacing

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
                        asset.name: model.imageSource
                        asset.isImage: !root.useIcons
                        asset.bgColor: "transparent"
                        color: Theme.palette.primaryColor3
                        closeButtonVisible: false
                        titleText.color: Theme.palette.primaryColor1
                        titleText.font.pixelSize: 15

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: root.itemClicked(parent, model.index, mouse)
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
            }
        }
    }
}
