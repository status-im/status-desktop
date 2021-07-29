import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import StatusQ.Components 0.1
import "../../imports"
import "../../shared"

Popup {
    id: popup
    property var loading: true
    property var gifSelected: function () {}
    property var searchGif: Backpressure.debounce(searchBox, 500, function (query) {
        loading = true
        chatsModel.gif.search(query)
    });
    property alias searchString: searchBox.text
    modal: false
    width: 360
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    background: Rectangle {
        radius: Style.current.radius
        color: Style.current.background
        border.color: Style.current.border
        layer.enabled: true
        layer.effect: DropShadow{
            verticalOffset: 3
            radius: 8
            samples: 15
            fast: true
            cached: true
            color: "#22000000"
        }
    }

    onOpened: {
        searchBox.text = ""
        searchBox.forceActiveFocus(Qt.MouseFocusReason)
    }

    Connections {
        target: chatsModel.gif
        onDataLoaded: {
            loading = false
        }
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            property int headerMargin: 8

            id: gifHeader
            Layout.fillWidth: true
            height: searchBox.height + gifHeader.headerMargin

            SearchBox {
                id: searchBox
                anchors.right: parent.right
                anchors.rightMargin: gifHeader.headerMargin
                anchors.top: parent.top
                anchors.topMargin: gifHeader.headerMargin
                anchors.left: parent.left
                anchors.leftMargin: gifHeader.headerMargin
                Keys.onReleased: {
                    Qt.callLater(searchGif, searchBox.text);
                }
            }
        }

        Loader {
            Layout.fillWidth: true
            Layout.rightMargin: Style.current.smallPadding / 2
            Layout.topMargin: Style.current.smallPadding
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            Layout.preferredHeight: 400 - gifHeader.height
            sourceComponent: loading ? gifLoading : gifItems
        }
    }

    Component {
        id: gifLoading
        StatusLoadingIndicator {}
    }

    Component {
        id: gifItems

        ScrollView {
            id: scrollView
            property ScrollBar vScrollBar: ScrollBar.vertical
            clip: true
            topPadding: Style.current.smallPadding
            leftPadding: Style.current.smallPadding
            rightPadding: Style.current.smallPadding
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                StatusGifColumn {
                    gifList.model: chatsModel.gif.columnA
                    gifWidth: (popup.width / 3) - 12
                    gifSelected: popup.gifSelected
                }

                StatusGifColumn {
                    gifList.model: chatsModel.gif.columnB
                    gifWidth: (popup.width / 3) - 12
                    gifSelected: popup.gifSelected
                }

                StatusGifColumn {
                    gifList.model: chatsModel.gif.columnC
                    gifWidth: (popup.width / 3) - 12
                    gifSelected: popup.gifSelected
                }
            }

        }
    }
}
/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:440;width:360}
}
##^##*/
