import QtQuick 2.15
import QtQuick.Controls 2.15

import shared.status 1.0
import shared.stores 1.0

import StatusQ.Core.Theme 0.1

QtObject {
    id: root

    required property GifStore gifStore
    required property bool gifUnfurlingEnabled

    property QtObject _d: QtObject {
        property var cbOnGifSelected: function () {} // It stores callback for gifSelected
        property var cbOnClose: function () {} // It stores callback for popup closed
        property var popupParent: null // Gifs button object type
        property var parentXPosition: null // Gifs button rigth
        property var parentYPosition: null // Gifs button bottom
        property bool closeAfterSelection: true
    }

    function openGifs(params, cbOnGifSelected, cbOnClose)
    {
        _d.cbOnGifSelected = cbOnGifSelected
        _d.cbOnClose = cbOnClose
        _d.popupParent = params.popupParent
        _d.parentXPosition = _d.popupParent.x + _d.popupParent.width
        _d.parentYPosition = _d.popupParent.y
        _d.closeAfterSelection = params.closeAfterSelection

        let gifPopupInst = gifPopupComponent.createObject(_d.popupParent)
        gifPopupInst.open()
    }

    readonly property Component gifPopupComponent: Component {
        StatusGifPopup {
            id: popup

            width: 360
            height: 440
            x: _d.parentXPosition - width - Theme.halfPadding
            y: _d.parentYPosition - height
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

            gifUnfurlingEnabled: root.gifUnfurlingEnabled
            loading: root.gifStore.gifLoading
            gifColumnA: root.gifStore.gifColumnA
            gifColumnB: root.gifStore.gifColumnB
            gifColumnC: root.gifStore.gifColumnC

            isFavorite: root.gifStore.isFavorite
            addToRecentsGif: root.gifStore.addToRecentsGif
            searchGifsRequest: root.gifStore.searchGifs
            getTrendingsGifs: root.gifStore.getTrendingsGifs
            getFavoritesGifs: root.gifStore.getFavoritesGifs
            getRecentsGifs: root.gifStore.getRecentsGifs
            toggleFavoriteGif: root.gifStore.toggleFavoriteGif
            setGifUnfurlingEnabled: root.gifStore.setGifUnfurlingEnabled

            onGifSelected: {
                _d.cbOnGifSelected(event, url)

                if (_d.closeAfterSelection) {
                    close()
                }
            }
            onClosed: {
                _d.cbOnClose()
                destroy()
            }
        }
    }
}
