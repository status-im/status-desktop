import QtQuick
import QtQuick.Controls

import utils

import StatusQ.Popups
import shared.controls.chat.menuItems


StatusMenu {
    property bool isCommunityChat: false

    signal muteTriggered(interval: int)

    title: isCommunityChat ? qsTr("Mute Channel") : qsTr("Mute Chat")

    assetSettings.name: "notification-muted"

    StatusAction {
        text: qsTr("For 15 mins")
        onTriggered: muteTriggered(Constants.MutingVariations.For15min)
    }

    StatusAction {
        text: qsTr("For 1 hour")
        onTriggered: muteTriggered(Constants.MutingVariations.For1hr)
    }

    StatusAction {
        text: qsTr("For 8 hours")
        onTriggered: muteTriggered(Constants.MutingVariations.For8hr)
    }

    StatusAction {
        text: qsTr("For 24 hours")
        onTriggered: muteTriggered(Constants.MutingVariations.For24hr)
    }

    StatusAction {
        text: qsTr("For 7 days")
        onTriggered: muteTriggered(Constants.MutingVariations.For1week)
    }

    StatusAction {
        text: qsTr("Until I turn it back on")
        onTriggered: muteTriggered(Constants.MutingVariations.TillUnmuted)
    }
}
