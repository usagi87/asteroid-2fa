/*
 * Copyright (C) 2017 - Florent Revest <revestflo@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include <QQuickView>
#include <QQmlEngine>
#include <QQmlApplicationEngine>
#include <QGuiApplication>
#include <QScreen>
#include <twofactor.h>
#include <crypt.h>
#include <vault.h>
#include <qrcode.h>
#include "QZXing.h"
#include <asteroidapp.h>


int main(int argc, char *argv[])
{
#if 1
    QScopedPointer<QGuiApplication> app(AsteroidApp::application(argc, argv));
    QScopedPointer<QQuickView> view(AsteroidApp::createView());
    
    QQmlApplicationEngine engine;

    QZXing::registerQMLTypes();
    QZXing::registerQMLImageProvider(engine);

    qmlRegisterType<TwoFactor>("TwoFactor", 1, 0, "TwoFactor");
    qmlRegisterType<Vault>("Vault", 1, 0, "Vault");
    qmlRegisterType<Crypt>("Crypt", 1, 0, "Crypt");
    qmlRegisterType<QRCode>("QRCode", 1, 0, "QRCode");
    view->setSource(QUrl("qrc:/main.qml"));
    view->resize(app->primaryScreen()->size());
    view->show();;
    return app->exec();
#else
    return AsteroidApp::main(argc, argv);
#endif
}

