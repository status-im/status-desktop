import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1

StatusValidator {
    name: "address"

    errorMessage: qsTr("Please enter a valid address.")

    validate: function (t) {
        return Utils.isValidAddress(t) ? true : { actual: t }
    }
}

