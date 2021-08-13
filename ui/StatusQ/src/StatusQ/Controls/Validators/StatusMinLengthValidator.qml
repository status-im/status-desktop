import StatusQ.Controls 0.1

StatusValidator {

    property int minLength: 0

    name: "minLength"

    validate: function (value) {
        return value.length >= minLength ? true : {
            min: minLength,
            actual: value.length
        }
    }
}

