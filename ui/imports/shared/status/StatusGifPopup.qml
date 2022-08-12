import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.panels 1.0
import shared.stores 1.0
import shared.controls 1.0

Popup {
    id: root

    enum Category {
        Trending,
        Recent,
        Favorite,
        Search
    }

    property var gifSelected: function () {}
    property var searchGif: Backpressure.debounce(searchBox, 500, function (query) {
        RootStore.searchGifs(query)
    })
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
        root.currentCategory = StatusGifPopup.Category.Trending
        root.previousCategory = StatusGifPopup.Category.Trending

        if (confirmationPopup.opened) {
            confirmationPopup.close()
        }
    }

    contentItem: Item {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Item {
                property int headerMargin: 8

                id: gifHeader
                Layout.fillWidth: true
                Layout.preferredHeight: searchBox.height + gifHeader.headerMargin

                SearchBox {
                    id: searchBox
                    placeholderText: qsTr("Search")
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
                        if (root.currentCategory !== StatusGifPopup.Category.Search) {
                            root.previousCategory = root.currentCategory
                            root.currentCategory = StatusGifPopup.Category.Search
                        }
                        Qt.callLater(searchGif, searchBox.text)
                    }
                }
            }

            StatusBaseText {
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
                active: root.opened && RootStore.isTenorWarningAccepted
                Layout.fillWidth: true
                Layout.rightMargin: Style.current.smallPadding / 2
                Layout.leftMargin: Style.current.smallPadding / 2
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.preferredHeight: {
                    const headerTextHeight = searchBox.text === "" ? headerText.height : 0
                    return 400 - gifHeader.height - headerTextHeight
                }
                sourceComponent: RootStore.gifColumnA.rowCount() === 0 ? empty : gifItems
            }

            Row {
                id: categorySelector
                Layout.fillWidth: true
                leftPadding: Style.current.smallPadding / 2
                rightPadding: Style.current.smallPadding / 2
                spacing: 0


                StatusTabBarIconButton {
                    icon.name: "flash"
                    highlighted: StatusGifPopup.Category.Trending === root.currentCategory
                    onClicked: {
                        toggleCategory(StatusGifPopup.Category.Trending)
                    }
                    enabled: RootStore.isTenorWarningAccepted
                }

                StatusTabBarIconButton {
                    icon.name: "time"
                    highlighted: StatusGifPopup.Category.Recent === root.currentCategory
                    onClicked: {
                        toggleCategory(StatusGifPopup.Category.Recent)
                    }
                    enabled: RootStore.isTenorWarningAccepted
                }

                StatusTabBarIconButton {
                    icon.name: "favourite"
                    highlighted: StatusGifPopup.Category.Favorite === root.currentCategory
                    onClicked: {
                        toggleCategory(StatusGifPopup.Category.Favorite)
                    }
                    enabled: RootStore.isTenorWarningAccepted
                }
            }
        }

        Rectangle {
            color: 'black'
            opacity: 0.4
            radius: Style.current.radius
            anchors.fill: parent
            visible: confirmationPopup.opened
        }
    }

    Popup {
        id: confirmationPopup

        anchors.centerIn: parent
        height: 278
        width: 291

        horizontalPadding: 6
        verticalPadding: 32

        modal: false
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

        SVGImage {
            id: gifImage
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            source: Style.svg(`gifs-${Style.current.name}`)
        }

        StatusBaseText {
            id: title
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: gifImage.bottom
            anchors.topMargin: 8
            text: qsTr("Enable Tenor GIFs?")
            font.weight: Font.Medium
            font.pixelSize: Style.current.primaryTextFontSize
        }

        StatusBaseText {
            id: headline
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: title.bottom
            anchors.topMargin: 4

            text: qsTr("Once enabled, GIFs posted in the chat may share your metadata with Tenor.")
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: 13
            color: Style.current.secondaryText
        }

        StatusButton {
            id: removeBtn
            objectName: "enableGifsButton"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            text: qsTr("Enable")

            size: StatusBaseButton.Size.Small

            onClicked: {
                RootStore.setIsTenorWarningAccepted(true)
                RootStore.getTrendingsGifs()
                confirmationPopup.close()
            }
        }
    }

    Component {
        id: empty
        Rectangle {
            height: parent.height
            width: parent.width
            color: Style.current.background

            StatusBaseText {
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
        StatusScrollView {
            id: scrollView
            property ScrollBar vScrollBar: ScrollBar.vertical
            topPadding: Style.current.smallPadding
            leftPadding: Style.current.smallPadding
            rightPadding: Style.current.smallPadding
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Row {
                id: gifs
                width: scrollView.availableWidth
                spacing: Style.current.halfPadding

                property string lastHoveredId

                StatusGifColumn {
                    gifList.model: RootStore.gifColumnA
                    gifWidth: (root.width / 3) - Style.current.padding
                    gifSelected: root.gifSelected
                    toggleFavorite: root.toggleFavorite
                    lastHoveredId: gifs.lastHoveredId
                    store: RootStore
                    onGifHovered: {
                        gifs.lastHoveredId = id
                    }
                }

                StatusGifColumn {
                    gifList.model: RootStore.gifColumnB
                    gifWidth: (root.width / 3) - Style.current.padding
                    gifSelected: root.gifSelected
                    toggleFavorite: root.toggleFavorite
                    lastHoveredId: gifs.lastHoveredId
                    store: RootStore
                    onGifHovered: {
                        gifs.lastHoveredId = id
                    }
                }

                StatusGifColumn {
                    gifList.model: RootStore.gifColumnC
                    gifWidth: (root.width / 3) - Style.current.padding
                    gifSelected: root.gifSelected
                    toggleFavorite: root.toggleFavorite
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
