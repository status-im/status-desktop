#ifndef ICONTROLLER_H
#define ICONTROLLER_H

namespace Modules
{
namespace Main
{
//   Abstract class for any input/interaction with this module.
class IController
{
public:
    virtual void init() = 0;
};
} // namespace Main
} // namespace Modules

#endif // ICONTROLLER_H
