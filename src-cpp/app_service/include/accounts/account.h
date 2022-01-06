#pragma once

#include <QJsonValue>
#include <QString>
#include <QVector>

namespace Accounts
{
class Image
{
public:
	QString keyUid;
	QString imgType;
	QString uri;
	int width;
	int height;
	int fileSize;
	int resizeTarget;
};

class AccountDto
{
public:
	QString name;
	long timestamp;
	QString identicon;
	QString keycardPairing;
	QString keyUid;
	QVector<Image> images;

	bool isValid();
};

Image toImage(const QJsonValue jsonObj);

AccountDto toAccountDto(const QJsonValue jsonObj);
} // namespace Accounts