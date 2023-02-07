import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1

StatusValidator {
    name: "url"

    errorMessage: qsTr("Please enter a valid URL")

    validate: function (value) {
        return Utils.isURL(value);
    }
}
