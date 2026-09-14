#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QUrl>
#include "../include/telemetry_core.hpp"

int main(int argc, char *argv[])
{
    qputenv("QML_DISABLE_DISK_CACHE", "1");

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    TelemetryEngine vehicleSim;
    engine.rootContext()->setContextProperty("vehicleSim", &vehicleSim);

    const QUrl url = QUrl::fromLocalFile("C:/Users/aybob/Desktop/Luminus-Automotive-OS/ui/qml/Main.qml");

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}