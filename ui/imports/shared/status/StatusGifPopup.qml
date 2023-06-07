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

import "./StatusGifPopup"

Popup {
    id: root

    property var gifSelected: function () {}
    property var searchGif: Backpressure.debounce(searchBox, 500, function (query) {
        RootStore.searchGifs(query)
    })
    property var toggleCategory: function(newCategory) {
        previousCategory = currentCategory
        currentCategory = newCategory
        searchBox.text = ""
        if (currentCategory === GifPopupDefinitions.Category.Trending) {
            RootStore.getTrendingsGifs()
        } else if(currentCategory === GifPopupDefinitions.Category.Favorite) {
            RootStore.getFavoritesGifs()
        } else if(currentCategory === GifPopupDefinitions.Category.Recent) {
            RootStore.getRecentsGifs()
        }
    }
    property var toggleFavorite: function(item) {
        RootStore.toggleFavoriteGif(item.id, currentCategory === GifPopupDefinitions.Category.Favorite)
    }
    property alias searchString: searchBox.text
    property int currentCategory: GifPopupDefinitions.Category.Trending
    property int previousCategory: GifPopupDefinitions.Category.Trending
    property bool loading: RootStore.gifLoading

    modal: false
    width: 360

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

    onAboutToShow: {
        searchBox.text = ""
        searchBox.input.edit.forceActiveFocus()
        if (RootStore.isTenorWarningAccepted) {
            RootStore.getTrendingsGifs()
        }
    }

    onClosed: {
        root.currentCategory = GifPopupDefinitions.Category.Trending
        root.previousCategory = GifPopupDefinitions.Category.Trending

        if (confirmationPopupLoader.active) {
            confirmationPopupLoader.active = false
        }
    }

    padding: 0

    Item {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Item {
                readonly property int headerMargin: 8

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
                    input.edit.onTextChanged: {
                        if (searchBox.text === "") {
                            toggleCategory(GifPopupDefinitions.Category.Trending)
                            return
                        }
                        if (root.currentCategory !== GifPopupDefinitions.Category.Search) {
                            root.previousCategory = root.currentCategory
                            root.currentCategory = GifPopupDefinitions.Category.Search
                        }
                        Qt.callLater(searchGif, searchBox.text)
                    }
                }
            }

            StatusBaseText {
                id: headerText
                text: {
                    if (currentCategory === GifPopupDefinitions.Category.Trending) {
                        return qsTr("TRENDING")
                    } else if(currentCategory === GifPopupDefinitions.Category.Favorite) {
                        return qsTr("FAVORITES")
                    } else if(currentCategory === GifPopupDefinitions.Category.Recent) {
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
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.preferredHeight: {
                    const headerTextHeight = searchBox.text === "" ? headerText.height : 0
                    return 400 - gifHeader.height - headerTextHeight
                }
                sourceComponent: RootStore.gifColumnA.rowCount() === 0 ? emptyPlaceholderComponent : gifItemsComponent
            }

            Row {
                id: categorySelector
                Layout.fillWidth: true
                leftPadding: Style.current.smallPadding / 2
                rightPadding: Style.current.smallPadding / 2
                spacing: 0


                StatusTabBarIconButton {
                    icon.name: "flash"
                    highlighted: GifPopupDefinitions.Category.Trending === root.currentCategory
                    onClicked: {
                        toggleCategory(GifPopupDefinitions.Category.Trending)
                    }
                    enabled: RootStore.isTenorWarningAccepted
                }

                StatusTabBarIconButton {
                    icon.name: "time"
                    highlighted: GifPopupDefinitions.Category.Recent === root.currentCategory
                    onClicked: {
                        toggleCategory(GifPopupDefinitions.Category.Recent)
                    }
                    enabled: RootStore.isTenorWarningAccepted
                }

                StatusTabBarIconButton {
                    icon.name: "favourite"
                    highlighted: GifPopupDefinitions.Category.Favorite === root.currentCategory
                    onClicked: {
                        toggleCategory(GifPopupDefinitions.Category.Favorite)
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
            visible: confirmationPopupLoader.active
        }
    }

    Loader {
        id: confirmationPopupLoader

        anchors.centerIn: parent

        sourceComponent: ConfirmationPopup {
            visible: true
        }
        active: !RootStore.isTenorWarningAccepted
    }

    Component {
        id: gifItemsComponent

        StatusScrollView {
            id: scrollView
            contentWidth: availableWidth

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

    Component {
        id: emptyPlaceholderComponent

        EmptyPlaceholder {
            Layout.margins: Style.current.smallPadding
            currentCategory: root.currentCategory
            loading: root.loading
            onDoRetry: searchBox.text === ""
                        ? RootStore.getTrendingsGifs()
                        : searchGif(searchBox.text)
        }
    }
}
