#pragma once

#include <nlohmann/json.hpp>

#include <QDebug>

#include <string>

using json = nlohmann::json;

namespace Status::StatusGo {

/*!
 * \brief General API response if an internal status-go error occured
 *
 * \see makeJSONResponse@status.go
 * \see APIResponsee@types.go
 *
 * \note update NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE when changing structure's content
 */
struct ApiErrorResponse {
    std::string error;
};

NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(ApiErrorResponse, error)

/*!
 * \brief General API response if an internal status-go error occured
 *
 * \see prepareJSONResponseWithCode@response.go
 *
 * \note update NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE when changing structure's content
 */
struct JsonError {
    int code{};
    std::string message;
};

NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(JsonError, code, message)

/*!
 * \brief General API response if an internal status-go error occured
 *
 * \see prepareJSONResponseWithCode@response.go
 * \see jsonrpcSuccessfulResponse@response.go
 * \note update NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE when changing structure's content
 */
struct ApiErrorResponseWithCode {
    JsonError error;
};

NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(ApiErrorResponseWithCode, error)

/*!
 * \brief General API response if no error occured
 *
 * \see jsonrpcSuccessfulResponse@response.go
 * \see jsonrpcSuccessfulResponse@call_raw.go
 * \see prepareJSONResponseWithCode@response.go
 *
 * \note update NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE when changing structure's content
 */
struct ApiResponse {
    json result;
};

NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(ApiResponse, result)

/*!
 * \brief Response of status-go's \c CallPrivateRPC
 *
 * There are multiple stages in calling private RPC and they return the following values
 *
 * 1. CallPrivateRPC@status.go returns `APIResponse` with the returned error if the underlying implementation failed
 *    otherwise returns result of CallRaw@call_raw.go, see 2.
 *  - \see makeJSONResponse@status-go
 * 2. CallRaw@call_raw.go returns newErrorResponse@call_raw.go or newSuccessResponse@call_raw.go
 *
 * \see \c libstatus.h
 */
struct CallPrivateRpcErrorResponse
{
    std::string jsonrpc;
    int id;
    JsonError error;
};

NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(CallPrivateRpcErrorResponse, jsonrpc, id, error)

/*!
 * \brief Response of status-go's \c CallPrivateRPC
 *
 * There are multiple stages in calling private RPC and they return the following values
 *
 * 1. CallPrivateRPC@status.go returns `APIResponse` with the returned error if the underlying implementation failed
 *    otherwise returns result of CallRaw@call_raw.go, see 2.
 *  - \see makeJSONResponse@status-go
 * 2. CallRaw@call_raw.go returns newErrorResponse@call_raw.go or newSuccessResponse@call_raw.go
 *
 * \see \c libstatus.h
 */
struct CallPrivateRpcResponse
{
    std::string jsonrpc;
    int id;
    json result;
};

NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(CallPrivateRpcResponse, jsonrpc, id, result)

/*!
 * \brief Check generic API calls for error
 * \throws \c CallGenericMakeJsonError or CallGenericPrepareJsonError in case of error
 */
void checkApiError(const json& response);

constexpr int defaultErrorCode = -32000;

class CallGenericMakeJsonError: public std::runtime_error {
public:
    CallGenericMakeJsonError(const ApiErrorResponse error)
        : std::runtime_error("CallGenericMakeJsonError@status-go failed")
        , m_error(std::move(error))
    {}

    const ApiErrorResponse &errorResponse() const { return m_error; };
private:
    const ApiErrorResponse m_error;
};

class CallGenericPrepareJsonError: public std::runtime_error {
public:
    CallGenericPrepareJsonError(const ApiErrorResponseWithCode error)
        : std::runtime_error("CallGenericPrepareJsonError@status-go failed")
        , m_error(std::move(error))
    {}

    const ApiErrorResponseWithCode &errorResponse() const { return m_error; };
private:
    const ApiErrorResponseWithCode m_error;
};

class CallPrivateRpcError: public std::runtime_error {
public:
    CallPrivateRpcError(const CallPrivateRpcErrorResponse error)
        : std::runtime_error("CallPrivateRPC@status-go failed")
        , m_error(std::move(error))
    {}

    const CallPrivateRpcErrorResponse &errorResponse() const { return m_error; };
private:
    const CallPrivateRpcErrorResponse m_error;
};

/*!
 * \brief check response from \c CallPrivateRPC call
 * \param response json api response from \c CallPrivateRPC
 * \return true if no error found
 * \throws \c CallPrivateRpcError
 */
void checkPrivateRpcCallResultAndReportError(const json& response);

}
