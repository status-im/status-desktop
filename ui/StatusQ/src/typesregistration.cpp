#include "StatusQ/typesregistration.h"

#include "StatusQ/statuswindow.h"

#include <QQmlEngine>

void registerStatusQTypes()
{
	qmlRegisterType<StatusWindow>("StatusQ", 0 , 1, "StatusWindow");
}
