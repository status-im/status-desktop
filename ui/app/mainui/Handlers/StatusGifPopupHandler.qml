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
        property var controlParent: null // StatusChatInput object type
        property var controlXPosition: null // StatusChatInput rigth
        property var controlYPosition: null // StatusChatInput bottom
    }

    function openGifs(params, cbOnGifSelected, cbOnClose)
    {
        _d.cbOnGifSelected = cbOnGifSelected
        _d.cbOnClose = cbOnClose
        _d.controlParent = params.controlParent
        _d.controlXPosition = _d.controlParent.x + _d.controlParent.width
        _d.controlYPosition = _d.controlParent.y

        let gifPopupInst = gifPopupComponent.createObject(_d.controlParent)
        gifPopupInst.open()
    }

    readonly property Component gifPopupComponent: Component {
        StatusGifPopup {
            id: popup

            gifStore: root.gifStore
            gifUnfurlingEnabled: root.gifUnfurlingEnabled

            width: 360
            height: 440
            x: _d.controlXPosition - width - Theme.halfPadding
            y: _d.controlYPosition - height
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

            gifSelected: _d.cbOnGifSelected
            onClosed: {
                _d.cbOnClose()
                destroy()
            }
        }
    }
}
