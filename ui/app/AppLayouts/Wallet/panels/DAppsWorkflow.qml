import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Wallet.controls 1.0

import shared.popups.walletconnect 1.0

ConnectedDappsButton {
    id: root

    signal dAppsListReady()
    signal connectDappReady()

    onClicked: {
        dappsListLoader.active = true
    }

    highlighted: dappsListLoader.active

    Loader {
        id: connectDappLoader

        active: false

        onLoaded: {
            item.open()
            root.connectDappReady()
        }

        sourceComponent: ConnectDappModal {
            visible: true

            onClosed: connectDappLoader.active = false

            onPair: (uri) => {
                this.close()
                console.debug(`TODO(#14556): ConnectionRequestDappModal with ${uri}`)
            }
        }
    }

    Loader {
        id: dappsListLoader

        active: false

        onLoaded: {
            item.open()
            root.dAppsListReady()
        }

        sourceComponent: DAppsListPopup {
            visible: true

            onConnectDapp: {
                connectDappLoader.active = true
                this.close()
            }
            onOpened: {
                this.x = root.width - this.menuWidth - 2 * this.padding
                this.y = root.height + 4
            }
            onClosed: dappsListLoader.active = false
        }
    }
}
