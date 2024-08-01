import QtQuick 2.15
import StatusQ.Core.Utils 0.1
import AppLayouts.Wallet.services.dapps 1.0
import shared.stores 1.0
import utils 1.0

QObject {
    id: root

    readonly property alias dappsModel: d.dappsModel

    function addSession(session) {
        d.addSession(session)
    }

    function revokeSession(session) {
        d.revokeSession(session)
    }

    function getActiveSession(dAppUrl) {
        return d.getActionSession(dAppUrl)
    }

    QObject {
        id: d

        property ListModel dappsModel: ListModel {
            id: dapps
        }

        function addSession(dappInfo) {
            let dappItem = JSON.parse(dappInfo)
            dapps.append(dappItem)
        }

        function revokeSession(dappInfo) {
            let dappItem = JSON.parse(dappInfo)
            for (let i = 0; i < dapps.count; i++) {
                let existingDapp = dapps.get(i)
                if (existingDapp.url === dappItem.url) {
                    dapps.remove(i)
                    break
                }
            }
        }

        function revokeAllSessions() {
            for (let i = 0; i < dapps.count; i++) {
                dapps.remove(i)
            }
        }

        function getActionSession(dAppUrl) {
            for (let i = 0; i < dapps.count; i++) {
                let existingDapp = dapps.get(i)

                if (existingDapp.url === dAppUrl) {
                    return JSON.stringify({
                        name: existingDapp.name,
                        url: existingDapp.url,
                        icon: existingDapp.iconUrl
                    });
                }
            }

            return null
        }
    }
}
