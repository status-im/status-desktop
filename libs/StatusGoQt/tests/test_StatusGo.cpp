#include <gtest/gtest.h>

#include <StatusGo/Metadata/api_response.h>

#include <nlohmann/json.hpp>

using json = nlohmann::json;
namespace StatusGo = Status::StatusGo;
namespace Status::Testing {

TEST(StatusGoQt, TestJsonParsing)
{
    auto callRawRPCJsonStr = R"({"jsonrpc":"2.0","id":42,"error":{"code":-32601,"message":"Method not found"}})";
    auto callRawRPCJson = json::parse(callRawRPCJsonStr).get<StatusGo::CallPrivateRpcErrorResponse>();
    ASSERT_EQ(callRawRPCJson.jsonrpc, "2.0");
    ASSERT_EQ(callRawRPCJson.id, 42);
    StatusGo::JsonError expectedJsonError = {-32601, "Method not found"};
    ASSERT_EQ(callRawRPCJson.error.code, expectedJsonError.code);
    ASSERT_EQ(callRawRPCJson.error.message, expectedJsonError.message);

    auto callRawRPCBadJsonKeyStr = R"({"unknown":"2.0","id":42,"error":{"code":-32601,"message":"Method not found"}})";
    ASSERT_THROW(json::parse(callRawRPCBadJsonKeyStr).get<StatusGo::CallPrivateRpcErrorResponse>(), nlohmann::detail::out_of_range);
    auto callRawRPCBadJsonValStr = R"({"jsonrpc":"2.0","id":42,"error":23})";
    ASSERT_THROW(json::parse(callRawRPCBadJsonValStr).get<StatusGo::CallPrivateRpcErrorResponse>(), nlohmann::detail::type_error);

    auto statusGoWithResultJsonStr = R"({"result":"0x123"})";
    auto statusGoWithResultJson = json::parse(statusGoWithResultJsonStr).get<StatusGo::ApiResponse>();
    ASSERT_EQ(statusGoWithResultJson.result, "0x123");
}

} // namespace
