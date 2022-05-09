import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1

StatusAsyncValidator {
    readonly property string uuid: Utils.uuid()

    name: "asyncEns"

    errorMessage: qsTr("ENS name could not be resolved in to an address")

    validate: function (asyncResult) {
        return Utils.isValidAddress(asyncResult)
    }
}

