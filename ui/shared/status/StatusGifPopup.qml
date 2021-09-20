import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import StatusQ.Components 0.1
import "../../imports"
import "../../shared"

Popup {
    enum Category {
        Trending,
        Recent,
        Favorite,
        Search
    }

    id: popup
    property var gifSelected: function () {}
    property var searchGif: Backpressure.debounce(searchBox, 500, function (query) {
        chatsModel.gif.search(query)
    });
    property var toggleCategory: function(newCategory) {
        previousCategory = currentCategory
        currentCategory = newCategory
        searchBox.text = ""
        if (currentCategory === StatusGifPopup.Category.Trending) {
            chatsModel.gif.getTrendings()
        } else if(currentCategory === StatusGifPopup.Category.Favorite) {
            chatsModel.gif.getFavorites()
        } else if(currentCategory === StatusGifPopup.Category.Recent) {
            chatsModel.gif.getRecents()
        }
    }
    property var toggleFavorite: function(item) {
        chatsModel.gif.toggleFavorite(item.id, currentCategory === StatusGifPopup.Category.Favorite)
    }
    property alias searchString: searchBox.text
    property int currentCategory: StatusGifPopup.Category.Trending
    property int previousCategory: StatusGifPopup.Category.Trending

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
        if (appSettings.isTenorWarningAccepted) {
            chatsModel.gif.getTrendings()
        } else {
            confirmationPopup.open()
        }
    }

    onClosed: {
        popup.currentCategory = StatusGifPopup.Category.Trending
        popup.previousCategory = StatusGifPopup.Category.Trending

        if (confirmationPopup.opened) {
            confirmationPopup.close()
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
                placeholderText: qsTr("Search Tenor")
                enabled: appSettings.isTenorWarningAccepted
                anchors.right: parent.right
                anchors.rightMargin: gifHeader.headerMargin
                anchors.top: parent.top
                anchors.topMargin: gifHeader.headerMargin
                anchors.left: parent.left
                anchors.leftMargin: gifHeader.headerMargin
                Keys.onReleased: {
                    if (searchBox.text === "") {
                        toggleCategory(previousCategory)
                        return
                    }
                    if (popup.currentCategory !== StatusGifPopup.Category.Search) {
                        popup.previousCategory = popup.currentCategory
                        popup.currentCategory = StatusGifPopup.Category.Search
                    }
                    Qt.callLater(searchGif, searchBox.text);
                }
            }

            StatusIconButton {
                id: clearBtn
                icon.name: "close-icon"
                type: "secondary"
                visible: searchBox.text !== ""
                icon.width: 14
                icon.height: 14
                width: 14
                height: 14
                anchors.right: searchBox.right
                anchors.rightMargin: Style.current.padding
                anchors.verticalCenter: searchBox.verticalCenter
                onClicked: toggleCategory(previousCategory)
            }
        }

        StyledText {
            id: headerText
            text: {
                if (currentCategory === StatusGifPopup.Category.Trending) {
                    return qsTr("TRENDING")
                } else if(currentCategory === StatusGifPopup.Category.Favorite) {
                    return qsTr("FAVORITES")
                } else if(currentCategory === StatusGifPopup.Category.Recent) {
                    return qsTr("RECENT")
                }
                return ""
            }
            visible: searchBox.text === ""
            color: Style.current.secondaryText
            font.pixelSize: 13
            topPadding: gifHeader.headerMargin
            leftPadding: gifHeader.headerMargin
        }

        Loader {
            Layout.fillWidth: true
            Layout.rightMargin: Style.current.smallPadding / 2
            Layout.leftMargin: Style.current.smallPadding / 2
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            Layout.preferredHeight: {
                const headerTextHeight = searchBox.text === "" ? headerText.height : 0
                return 400 - gifHeader.height - headerTextHeight
            }
            sourceComponent: chatsModel.gif.columnA.rowCount() == 0 ? empty : gifItems
        }

        Row {
            id: categorySelector
            Layout.fillWidth: true
            leftPadding: Style.current.smallPadding / 2
            rightPadding: Style.current.smallPadding / 2
            spacing: 0

            StatusCategoryButton {
                source: `../../app/img/gifCategories/trending.svg`
                active: StatusGifPopup.Category.Trending === popup.currentCategory
                changeCategory: function () {
                    toggleCategory(StatusGifPopup.Category.Trending)
                }
                enabled: appSettings.isTenorWarningAccepted
            }
            StatusCategoryButton {
                source: `../../app/img/gifCategories/recent.svg`
                active: StatusGifPopup.Category.Recent === popup.currentCategory
                changeCategory: function () {
                    toggleCategory(StatusGifPopup.Category.Recent)
                }
                enabled: appSettings.isTenorWarningAccepted
            }
            StatusCategoryButton {
                source: `../../app/img/gifCategories/favorite.svg`
                active: StatusGifPopup.Category.Favorite === popup.currentCategory
                changeCategory: function () {
                    toggleCategory(StatusGifPopup.Category.Favorite)
                }
                enabled: appSettings.isTenorWarningAccepted
            }
        }
    }

    Popup {
        id: confirmationPopup
        modal: false
        anchors.centerIn: parent
        height: 290
        width: 280
        closePolicy: Popup.NoAutoClose

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

        Column {
            anchors.fill: parent
            spacing: 12

            SVGImage {
                id: gifImage
                anchors.horizontalCenter: parent.horizontalCenter
                source: `./assets/img/gif-${Style.current.name}.svg`
            }

            StyledText {
                id: title
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Enable Tenor GIFs?")
                font.weight: Font.Medium
                font.pixelSize: Style.current.primaryTextFontSize
            }

            StyledText {
                id: headline
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Once enabled, GIFs posted in the chat may share your metadata with Tenor.")
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font.pixelSize: 13
                color: Style.current.secondaryText
            }

            StatusButton {
                id: removeBtn
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Enable")
                onClicked: {
                    appSettings.isTenorWarningAccepted = true
                    chatsModel.gif.getTrendings()
                    confirmationPopup.close()
                }
            }
        }
    }

    Component {
        id: empty
        Rectangle {
            height: parent.height
            width: parent.width
            color: Style.current.background

            StyledText {
                id: emptyText
                anchors.centerIn: parent
                text: {
                    if(currentCategory === StatusGifPopup.Category.Favorite) {
                        return qsTr("Favorite GIFs will appear here")
                    } else if(currentCategory === StatusGifPopup.Category.Recent) {
                        return qsTr("Recent GIFs will appear here")
                    }

                    return qsTr("Error while contacting Tenor API, please retry.")
                }
                font.pixelSize: 15
                color: Style.current.secondaryText
            }

            StatusButton {
                id: retryBtn
                anchors.top: emptyText.bottom
                anchors.topMargin: Style.current.padding
                anchors.horizontalCenter: parent.horizontalCenter

                text: qsTr("Retry")
                visible: currentCategory === StatusGifPopup.Category.Trending || currentCategory === StatusGifPopup.Category.Search
                onClicked: {
                    if (searchBox.text === "") {
                        chatsModel.gif.getTrendings()
                        return
                    }

                    searchGif(searchBox.text)
                }
            }
        }
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
                spacing: Style.current.halfPadding

                StatusGifColumn {
                    gifList.model: chatsModel.gif.columnA
                    gifWidth: (popup.width / 3) - Style.current.padding
                    gifSelected: popup.gifSelected
                    toggleFavorite: popup.toggleFavorite
                }

                StatusGifColumn {
                    gifList.model: chatsModel.gif.columnB
                    gifWidth: (popup.width / 3) - Style.current.padding
                    gifSelected: popup.gifSelected
                    toggleFavorite: popup.toggleFavorite
                }

                StatusGifColumn {
                    gifList.model: chatsModel.gif.columnC
                    gifWidth: (popup.width / 3) - Style.current.padding
                    gifSelected: popup.gifSelected
                    toggleFavorite: popup.toggleFavorite
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
