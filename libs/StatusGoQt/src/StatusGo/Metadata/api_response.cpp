#include "api_response.h"

namespace Status::StatusGo {

void checkApiError(const json &response) {
    if(response.contains("error")) {
        const auto &error = response["error"];
        if(error.is_object()) {
            const auto apiErr = response["error"].get<ApiErrorResponseWithCode>();
            throw CallGenericPrepareJsonError(apiErr);
        }
        assert(error.is_string());
        const auto apiError = response.get<ApiErrorResponse>();
        if(!apiError.error.empty())
            throw CallGenericMakeJsonError(response.get<ApiErrorResponse>());
    }
}

/// \throws \c CallPrivateRpcError, \c nlohmann::exception
void checkPrivateRpcCallResultAndReportError(const json &response) {
    if(response.contains("error"))
        throw CallPrivateRpcError(response.get<CallPrivateRpcErrorResponse>());
}

} // namespace
