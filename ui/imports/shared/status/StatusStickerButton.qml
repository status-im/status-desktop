import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml 2.15

import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0

StatusButton {
    id: root

    enum StyleType {
        Default,
        LargeNoIcon
    }

    property alias tooltip: tooltip
    property int style: StatusStickerButton.StyleType.Default
    property int packPrice: 0
    property bool isBought: false
    property bool isPending: false
    property bool isInstalled: false
    property bool hasUpdate: false
    property bool isTimedOut: false
    property bool hasInsufficientFunds: false
    property bool greyedOut: false

    signal uninstallClicked()
    signal installClicked()
    signal cancelClicked()
    signal updateClicked()
    signal buyClicked()

    text: root.style === StatusStickerButton.StyleType.Default ? packPrice : qsTr("Buy for %1 SNT").arg(packPrice)
    icon.name: root.style === StatusStickerButton.StyleType.Default ? d.iconName : ""

    size: root.style === StatusStickerButton.StyleType.LargeNoIcon ? StatusBaseButton.Size.Large : StatusBaseButton.Size.Small
    radius: root.style === StatusStickerButton.StyleType.LargeNoIcon ? 8 : width/2
    type: StatusBaseButton.Type.Primary

    QtObject {
        id: d
        property string iconName: "status"
    }

    Binding on textColor {
        when: root.greyedOut && !root.isInstalled
        value: disabledTextColor
        delayed: true
    }

    Binding on normalColor {
        when: root.greyedOut && !root.isInstalled
        value: disabledColor
        delayed: true
    }

    states: [
        State {
            name: "installed_main"
            when: root.isInstalled && root.style === StatusStickerButton.StyleType.Default
            PropertyChanges {
                target: root;
                width: 24
                height: 24
                icon.width: 12
                icon.height: 12
                display: AbstractButton.IconOnly
                text: ""
                tooltip.text: qsTr("Uninstall")
                textColor: Theme.palette.white
                normalColor: Theme.palette.successColor1
                hoverColor: Theme.palette.hoverColor(normalColor)
            }
            PropertyChanges {
                target: d
                iconName: "checkmark"
            }
        },
        State {
            name: "installed_popup"
            when: root.isInstalled && root.style === StatusStickerButton.StyleType.LargeNoIcon
            PropertyChanges {
                target: root;
                text: qsTr("Uninstall")
                tooltip.text: ""
                type: StatusBaseButton.Type.Danger
            }
        },
        State {
            name: "hasUpdate"
            when: root.hasUpdate
            extend: "bought"
            PropertyChanges {
                target: root;
                text: qsTr("Update");
            }
        },
        State {
            name: "free"
            when: root.packPrice === 0;
            extend: "bought"
            PropertyChanges {
                target: root;
                text: qsTr("Free");
            }
        },
        State {
            name: "bought"
            when: root.isBought;
            PropertyChanges {
                target: root;
                text: qsTr("Install");
            }
            PropertyChanges {
                target: d
                iconName: "download"
            }
        },
        State {
            name: "timedOut"
            when: root.isTimedOut
            extend: "pending"
            PropertyChanges {
                target: root;
                text: qsTr("Cancel");
                enabled: true
                type: StatusBaseButton.Type.Danger
            }
        },
        State {
            name: "pending"
            when: root.isPending
            PropertyChanges {
                target: root;
                text: qsTr("Pending...");
                enabled: false;
                loading: true
            }
        },
        State {
            name: "insufficientFunds"
            when: root.hasInsufficientFunds
            PropertyChanges {
                target: root;
                text: root.style === StatusStickerButton.StyleType.Default ? packPrice : "%1 SNT".arg(packPrice)
                enabled: false;
            }
        }
    ]

    // Tooltip only in case we are browsing an item to be installed/downloaded/bought
    StatusToolTip {
        id: tooltip
        visible: root.hovered && text && (root.greyedOut || root.isInstalled)
        maxWidth: 300
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: !root.isPending ? Qt.PointingHandCursor : undefined
        onClicked: {
            if (root.isPending || root.greyedOut)
                return;

            if (root.isInstalled) return root.uninstallClicked();
            if (root.packPrice === 0 || root.isBought) return root.installClicked()
            if (root.isTimedOut) return root.cancelClicked()
            if (root.hasUpdate) return root.updateClicked()
            return root.buyClicked()
        }
    }
}
