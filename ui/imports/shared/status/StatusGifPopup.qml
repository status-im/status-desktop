import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Backpressure 0.1

import utils 1.0
import shared.panels 1.0
import shared.stores 1.0
import shared.controls 1.0

import "./StatusGifPopup"

Popup {
    id: root

    property bool gifUnfurlingEnabled

    property var searchGif: Backpressure.debounce(searchBox, 500, function (query) {
        root.searchGifsRequest(query)
    })
    property var toggleCategory: function(newCategory) {
        previousCategory = currentCategory
        currentCategory = newCategory
        searchBox.text = ""
        if (currentCategory === GifPopupDefinitions.Category.Trending) {
            root.getTrendingsGifs()
        } else if(currentCategory === GifPopupDefinitions.Category.Favorite) {
            root.getFavoritesGifs()
        } else if(currentCategory === GifPopupDefinitions.Category.Recent) {
            root.getRecentsGifs()
        }
    }
    property var toggleFavorite: function(item) {
        root.toggleFavoriteGif(item.id, currentCategory === GifPopupDefinitions.Category.Favorite)
    }
    property alias searchString: searchBox.text
    property int currentCategory: GifPopupDefinitions.Category.Trending
    property int previousCategory: GifPopupDefinitions.Category.Trending

    property bool loading: false
    property var gifColumnA: null
    property var gifColumnB: null
    property var gifColumnC: null

    property var isFavorite: function () {}
    property var addToRecentsGif: function () {}
    property var searchGifsRequest: function () {}
    property var getTrendingsGifs: function () {}
    property var getFavoritesGifs: function () {}
    property var getRecentsGifs: function () {}
    property var toggleFavoriteGif: function () {}
    property var setGifUnfurlingEnabled: function () {}

    signal gifSelected(var event, var url)

    modal: false
    width: 360

    background: Rectangle {
        radius: Theme.radius
        color: Theme.palette.background
        border.color: Theme.palette.border
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
        if (root.gifUnfurlingEnabled) {
            root.getTrendingsGifs()
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
                    enabled: root.gifUnfurlingEnabled
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
                color: Theme.palette.secondaryText
                font.pixelSize: 13
                topPadding: gifHeader.headerMargin
                leftPadding: gifHeader.headerMargin
            }

            Loader {
                id: gifsLoader
                active: root.opened && root.gifUnfurlingEnabled
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.preferredHeight: {
                    const headerTextHeight = searchBox.text === "" ? headerText.height : 0
                    return 400 - gifHeader.height - headerTextHeight
                }
                sourceComponent: root.gifColumnA.rowCount() === 0 ? emptyPlaceholderComponent : gifItemsComponent
            }

            Row {
                id: categorySelector
                Layout.fillWidth: true
                leftPadding: Theme.smallPadding / 2
                rightPadding: Theme.smallPadding / 2
                spacing: 0


                StatusTabBarIconButton {
                    icon.name: "flash"
                    highlighted: GifPopupDefinitions.Category.Trending === root.currentCategory
                    onClicked: {
                        toggleCategory(GifPopupDefinitions.Category.Trending)
                    }
                    enabled: root.gifUnfurlingEnabled
                }

                StatusTabBarIconButton {
                    icon.name: "time"
                    highlighted: GifPopupDefinitions.Category.Recent === root.currentCategory
                    onClicked: {
                        toggleCategory(GifPopupDefinitions.Category.Recent)
                    }
                    enabled: root.gifUnfurlingEnabled
                }

                StatusTabBarIconButton {
                    icon.name: "favourite"
                    highlighted: GifPopupDefinitions.Category.Favorite === root.currentCategory
                    onClicked: {
                        toggleCategory(GifPopupDefinitions.Category.Favorite)
                    }
                    enabled: root.gifUnfurlingEnabled
                }
            }
        }

        Rectangle {
            color: 'black'
            opacity: 0.4
            radius: Theme.radius
            anchors.fill: parent
            visible: confirmationPopupLoader.active
        }
    }

    Loader {
        id: confirmationPopupLoader

        anchors.centerIn: parent

        sourceComponent: ConfirmationPopup {
            visible: true

            onEnableGifsRequested: {
                root.setGifUnfurlingEnabled(true)
                root.getTrendingsGifs()
            }
        }
        active: !root.gifUnfurlingEnabled
    }

    Component {
        id: gifItemsComponent

        StatusScrollView {
            id: scrollView
            contentWidth: availableWidth

            Row {
                id: gifs
                width: scrollView.availableWidth
                spacing: Theme.halfPadding

                property string lastHoveredId

                StatusGifColumn {
                    gifList.model: root.gifColumnA
                    gifWidth: (root.width / 3) - Theme.padding
                    lastHoveredId: gifs.lastHoveredId

                    toggleFavorite: root.toggleFavorite
                    isFavorite: root.isFavorite
                    addToRecentsGif: root.addToRecentsGif

                    onGifHovered: {
                        gifs.lastHoveredId = id
                    }
                    onGifSelected: root.gifSelected(event, url)
                }

                StatusGifColumn {
                    gifList.model: root.gifColumnB
                    gifWidth: (root.width / 3) - Theme.padding
                    lastHoveredId: gifs.lastHoveredId

                    toggleFavorite: root.toggleFavorite
                    isFavorite: root.isFavorite
                    addToRecentsGif: root.addToRecentsGif

                    onGifHovered: {
                        gifs.lastHoveredId = id
                    }
                    onGifSelected: root.gifSelected(event, url)
                }

                StatusGifColumn {
                    gifList.model: root.gifColumnC
                    gifWidth: (root.width / 3) - Theme.padding
                    lastHoveredId: gifs.lastHoveredId

                    toggleFavorite: root.toggleFavorite
                    isFavorite: root.isFavorite
                    addToRecentsGif: root.addToRecentsGif

                    onGifHovered: º
                    onGifSelected: root.gifSelected(event, url)
                }
            }
        }
    }

    Component {
        id: emptyPlaceholderComponent

        EmptyPlaceholder {
            Layout.margins: Theme.smallPadding
            currentCategory: root.currentCategory
            loading: root.loading
            onDoRetry: searchBox.text === ""
                        ? root.getTrendingsGifs()
                        : searchGif(searchBox.text)
        }
    }
}
