import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1

StatusValidator {
    name: "addressOrEns"

    errorMessage: "Please enter a valid address or ENS name."

    validate: function (t) {
        return Utils.isValidAddress(t) || Utils.isValidEns(t) ?
            true :
            { actual: t }
    }
}

