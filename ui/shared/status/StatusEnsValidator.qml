import QtQuick 2.13
import StatusQ.Controls.Validators 0.1

import "../../imports"
import "../../shared"

StatusValidator {

    id: root

    name: "ensValidator"
    errorMessage: "Couldn't resolve ENS name."

    readonly property string uuid: Utils.uuid()

    property int debounceTime: 600

    signal ensResolved(string address)
    
    validate: Backpressure.debounce(root, root.debounceTime, function (name) {
        name = name.startsWith("@") ? name.substring(1) : name
        walletModel.ensView.resolveENS(name, uuid)
    })

    Connections {
        target: walletModel.ensView
        onEnsWasResolved: {
            if (uuid !== root.uuid) {
                return
            }
            root.ensResolved(resolvedAddress)
            input.updateValidity(root.name, resolvedAddress !== "")
        }
    }
}
