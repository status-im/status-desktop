import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.controls 1.0

Popup {
    property var modelList
    property alias listView: listView
    property var getImageSource
    property var getImageComponent
    property var getText: function () {}
    property var getId: function () {}
    signal clicked(int index, string id)
    property int imageWidth: 22
    property int imageHeight: 22
    property string title
    property bool showSearchBox: false
    property var messageInput

    function openPopup(listParam) {
        modelList = listParam
        popup.open()
    }

    onOpened: {
        listView.currentIndex = 0
        if (showSearchBox) {
            searchBox.text = ""
            searchBox.textField.forceActiveFocus()
        }
    }

    id: popup
    padding: Theme.smallPadding
    width: messageInput.width
    height: {
        let possibleHeight = listView.contentHeight + Theme.smallPadding * 2
        if (popupTitle.visible) {
            possibleHeight += popupTitle.height + Theme.smallPadding
        }
        if (searchBox.visible) {
            possibleHeight += searchBox.height + Theme.smallPadding
        }

        return Math.min(400, possibleHeight)
    }
    x: messageInput.x
    y: -height
    background: Rectangle {
        id: bgRectangle
        visible: !!popup.title || (!!popup.modelList && popup.modelList.length > 0)
        color: Theme.palette.background
        border.width: 0
        radius: Theme.radius
        layer.enabled: true
        layer.effect: DropShadow{
            width: bgRectangle.width
            height: bgRectangle.height
            x: bgRectangle.x
            y: bgRectangle.y + 10
            visible: bgRectangle.visible
            source: bgRectangle
            horizontalOffset: 0
            verticalOffset: 2
            radius: 10
            samples: 15
            color: Theme.palette.dropShadow
        }
    }

    StyledText {
        id: popupTitle
        visible: !!popup.title
        height: visible ? implicitHeight : 0
        text: popup.title
        font.pixelSize: 17
        anchors.top: parent.top
    }

    SearchBox {
        id: searchBox
        visible: showSearchBox
        height: visible ? implicitHeight : 0
        width: parent.width
        anchors.top: popupTitle.bottom
        anchors.topMargin: popupTitle.visible ? Theme.smallPadding : 0

        function goToNextAvailableIndex(up) {
            do {
                if (!up && listView.currentIndex === listView.count - 1) {
                    listView.currentIndex = 0
                    return
                } else if (up && listView.currentIndex === 0) {
                    listView.currentIndex = listView.count - 1
                    return
                }

                if (up) {
                    listView.decrementCurrentIndex()
                } else {
                    listView.incrementCurrentIndex()
                }
            } while (!listView.currentItem.visible)
        }

        Keys.onReleased: {
            if (event.key === Qt.Key_Down) {
                searchBox.goToNextAvailableIndex(false)
            }
            if (event.key === Qt.Key_Up) {
                searchBox.goToNextAvailableIndex(true)
            }
            if (event.key === Qt.Key_Escape) {
                return popup.close()
            }
            if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                return popup.clicked(listView.currentIndex, popup.getId(listView.currentItem.myData))
            }
            if (!listView.currentItem.visible) {
                goToNextAvailableIndex(false)
            }
        }
    }

    StatusListView {
        id: listView
        model: popup.modelList || []
        keyNavigationEnabled: true
        width: parent.width
        anchors.top: searchBox.bottom
        anchors.topMargin: searchBox.visible ? Theme.smallPadding : 0
        anchors.bottom: parent.bottom

        delegate: Rectangle {
            id: rectangle
            objectName: "inputListRectangle_" + index
            property var myData: typeof modelData === "undefined" ? model : modelData
            property string myText: popup.getText(myData)
            visible: searchBox.text === "" || myText.includes(searchBox.text)
            color: listView.currentIndex === index ? Theme.palette.backgroundHover : Theme.palette.transparent
            border.width: 0
            width: ListView.view.width
            height: visible ? 42 : 0
            radius: Theme.radius

            Loader {
                id: imageLoader
                active: !!popup.getImageComponent || !!popup.getImageSource
                width: popup.imageWidth
                height: popup.imageHeight
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Theme.smallPadding
                sourceComponent: popup.getImageComponent ? customImageComponent : normalImageComponent
            }

            Component {
                id: customImageComponent
                Item {
                    id: imageComponentContainer
                    children: {
                        if (!popup.getImageComponent) {
                            return ""
                        }
                        return popup.getImageComponent(imageComponentContainer, myData)
                    }
                }
            }

            Component {
                id: normalImageComponent
                SVGImage {
                    visible: !!source
                    width: popup.imageWidth
                    height: popup.imageHeight
                    source: {
                        if (!popup.getImageSource) {
                            return ""
                        }
                        return popup.getImageSource(myData)
                    }
                }
            }

            StyledText {
                text: rectangle.myText
                color: Theme.palette.textColor
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: imageLoader.right
                anchors.leftMargin: Theme.smallPadding
                font.pixelSize: 15
            }

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    listView.currentIndex = index
                }
                onClicked: {
                    popup.clicked(index, popup.getId(myData))
                }
            }
        }
    }
}
