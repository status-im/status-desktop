#include "GlobalEvents.h"

using namespace Status;

GlobalEvents& GlobalEvents::instance()
{
    static GlobalEvents events;

    return events;
}

GlobalEvents::GlobalEvents()
{
}

GlobalEvents::~GlobalEvents()
{
}
