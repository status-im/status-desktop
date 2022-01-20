#pragma once

namespace Modules
{
namespace Startup
{
namespace Login
{
class ModuleControllerDelegateInterface
{
public:
	virtual void emitAccountLoginError(QString error) = 0;

	virtual void emitObtainingPasswordError(QString errorDescription) = 0;

	virtual void emitObtainingPasswordSuccess(QString password) = 0;
};
}; // namespace Login
}; // namespace Startup
}; // namespace Modules