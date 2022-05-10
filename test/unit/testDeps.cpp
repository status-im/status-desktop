#include <fruit/fruit.h>
#include <gtest/gtest.h>

namespace
{
class Greeter
{
public:
	virtual std::string greet() = 0;
};

fruit::Component<Greeter> getGreeterComponent();

class GreeterImpl : public Greeter
{
public:
	INJECT(GreeterImpl()) = default;

	std::string greet() override
	{
		return "Hello, world!";
	}
};

fruit::Component<Greeter> getGreeterComponent()
{
	return fruit::createComponent().bind<Greeter, GreeterImpl>();
}
} // namespace

TEST(TestDeps, Fruit)
{
	auto injector = fruit::Injector<Greeter>{getGreeterComponent};
	ASSERT_NE(injector.get<Greeter*>(), nullptr);
}
