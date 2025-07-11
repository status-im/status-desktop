import StatusQ.Core.Utils
import StatusQ.Controls

StatusValidator {
    name: "url"

    errorMessage: qsTr("Please enter a valid URL")

    validate: function (value) {
        return Utils.isURL(value);
    }
}
