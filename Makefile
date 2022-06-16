BIN = ./generate.sh

overlays:
	chmod +x ${BIN}
	${BIN} google raven ${name} ${code}
	${BIN} google redfin ${name} ${code}
	${BIN} google sunfish ${name} ${code}
	${BIN} google coral ${name} ${code}
	${BIN} google cheetah ${name} ${code}
	${BIN} google bonito ${name} ${code}
	${BIN} google bluejay ${name} ${code}

# Don't do this on every build!
fetchUpdateBinary:
	curl -o ./build/module/META-INF/com/google/android/update-binary https://raw.githubusercontent.com/Googlers-Magisk-Repo/Module-Template-Generator/master/build/META-INF/com/google/android/update-binary