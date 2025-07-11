import StatusQ.Controls
import StatusQ.Core.Utils

StatusValidator {
    name: "addressOrEns"

    errorMessage: qsTr("Please enter a valid address or ENS name.")

    validate: function (t) {
        return Utils.isValidAddress(t) || Utils.isValidEns(t) ?
            true :
            { actual: t }
    }
}

