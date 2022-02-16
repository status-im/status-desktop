#ifndef ICONTROLLER_H
#define ICONTROLLER_H

namespace Modules::Main
{
//   Abstract class for any input/interaction with this module.
class IController
{
public:
    virtual void init() = 0;
};
} // namespace Modules::Main

#endif // ICONTROLLER_H
