import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.panels 1.0
import shared.stores 1.0
import shared.controls 1.0

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
        RootStore.searchGifs(query)
    });
    property var toggleCategory: function(newCategory) {
        previousCategory = currentCategory
        currentCategory = newCategory
        searchBox.text = ""
        if (currentCategory === StatusGifPopup.Category.Trending) {
            RootStore.getTrendingsGifs()
        } else if(currentCategory === StatusGifPopup.Category.Favorite) {
            RootStore.getFavoritesGifs()
        } else if(currentCategory === StatusGifPopup.Category.Recent) {
            RootStore.getRecentsGifs()
        }
    }
    property var toggleFavorite: function(item) {
        RootStore.toggleFavoriteGif(item.id, currentCategory === StatusGifPopup.Category.Favorite)
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
        layer.effect: DropShadow {
            verticalOffset: 3
            radius: 8
            samples: 15
            cached: true
            color: "#22000000"
        }
    }

    onOpened: {
        searchBox.text = ""
        searchBox.input.edit.forceActiveFocus()
        if (RootStore.isTenorWarningAccepted) {
            RootStore.getTrendingsGifs()
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
                input.placeholderText: qsTr("Search Tenor")
                enabled: RootStore.isTenorWarningAccepted
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
            id: gifsLoader
            active: popup.opened
            Layout.fillWidth: true
            Layout.rightMargin: Style.current.smallPadding / 2
            Layout.leftMargin: Style.current.smallPadding / 2
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            Layout.preferredHeight: {
                const headerTextHeight = searchBox.text === "" ? headerText.height : 0
                return 400 - gifHeader.height - headerTextHeight
            }
            sourceComponent: RootStore.gifColumnA.rowCount() == 0 ? empty : gifItems
        }

        Row {
            id: categorySelector
            Layout.fillWidth: true
            leftPadding: Style.current.smallPadding / 2
            rightPadding: Style.current.smallPadding / 2
            spacing: 0


            StatusTabBarIconButton {
                icon.name: "flash"
                highlighted: StatusGifPopup.Category.Trending === popup.currentCategory
                onClicked: {
                    toggleCategory(StatusGifPopup.Category.Trending)
                }
                enabled: RootStore.isTenorWarningAccepted
            }

            StatusTabBarIconButton {
                icon.name: "time"
                highlighted: StatusGifPopup.Category.Recent === popup.currentCategory
                onClicked: {
                    toggleCategory(StatusGifPopup.Category.Recent)
                }
                enabled: RootStore.isTenorWarningAccepted
            }

            StatusTabBarIconButton {
                icon.name: "favourite"
                highlighted: StatusGifPopup.Category.Favorite === popup.currentCategory
                onClicked: {
                    toggleCategory(StatusGifPopup.Category.Favorite)
                }
                enabled: RootStore.isTenorWarningAccepted
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
                source: Style.svg(`gif-${Style.current.name}`)
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
                    RootStore.setIsTenorWarningAccepted(true);
                    RootStore.getTrendingsGifs()
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
                        RootStore.getTrendingsGifs()

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
                id: gifs
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: Style.current.halfPadding

                property string lastHoveredId

                StatusGifColumn {
                    gifList.model: RootStore.gifColumnA
                    gifWidth: (popup.width / 3) - Style.current.padding
                    gifSelected: popup.gifSelected
                    toggleFavorite: popup.toggleFavorite
                    lastHoveredId: gifs.lastHoveredId
                    store: RootStore
                    onGifHovered: {
                        gifs.lastHoveredId = id
                    }
                }

                StatusGifColumn {
                    gifList.model: RootStore.gifColumnB
                    gifWidth: (popup.width / 3) - Style.current.padding
                    gifSelected: popup.gifSelected
                    toggleFavorite: popup.toggleFavorite
                    lastHoveredId: gifs.lastHoveredId
                    store: RootStore
                    onGifHovered: {
                        gifs.lastHoveredId = id
                    }
                }

                StatusGifColumn {
                    gifList.model: RootStore.gifColumnC
                    gifWidth: (popup.width / 3) - Style.current.padding
                    gifSelected: popup.gifSelected
                    toggleFavorite: popup.toggleFavorite
                    lastHoveredId: gifs.lastHoveredId
                    store: RootStore
                    onGifHovered: {
                        gifs.lastHoveredId = id
                    }
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
