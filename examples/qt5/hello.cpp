#include <QApplication>
#include <QTranslator>
#include <QLocale>
#include <iostream>
#include "mainwindow.h"

int main(int argc, char* argv[])
{
	QApplication app (argc, argv);

	QTranslator default_translator;
	if(!default_translator.load("en_GB",":/translations"))
	{
		std::cerr << "error loading default translator 'en_GB'.\n";
		return 1;
	}
	app.installTranslator(&default_translator);

	QTranslator locale_translator;
	if(argc >= 2)
	{
		if(!locale_translator.load(argv[1],":/translations"))
		{
			std::cerr << "error loading translator '" << argv[1] << "'.\n";
			return 1;
		}

		app.installTranslator(&locale_translator);
	}
	else
	{
		QString locale = QLocale::system().name();
		if(!locale_translator.load(locale,":/translations"))
		{
			std::cerr << "error loading translator '" << locale.toStdString() << "'.\n";
		}
		else
		{
			app.installTranslator(&locale_translator);
		}
	}

	MainWindow mw;
	mw.show();

	return app.exec();
}
