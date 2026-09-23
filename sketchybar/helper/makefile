# sketchybarrc ejecuta `make` sin argumentos, que construye solo el primer
# target: por eso `all` va primero y cubre ambos binarios.
all: helper ssid

helper: helper.c cpu.h sketchybar.h
	clang -std=c99 -O3 helper.c -o helper

# El SSID solo es legible para procesos autorizados en Localizacion, y macOS
# unicamente muestra ese dialogo a codigo con identidad de bundle: de ahi el
# .app y la firma ad-hoc (que le da un cdhash estable para que TCC lo recuerde).
ssid: ssid.swift SSID.app/Contents/Info.plist
	swiftc -O ssid.swift -o SSID.app/Contents/MacOS/ssid
	codesign --force --sign - --identifier local.sketchybar.ssid SSID.app

.PHONY: all
