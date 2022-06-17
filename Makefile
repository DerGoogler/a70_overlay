BIN = ./generate.sh

overlays:
	chmod +x ${BIN}

	${BIN} samsung a70 ${name} ${code}

	${BIN} google raven ${name} ${code}
	${BIN} google redfin ${name} ${code}
	${BIN} google sunfish ${name} ${code}
	${BIN} google coral ${name} ${code}
	${BIN} google cheetah ${name} ${code}
	${BIN} google bonito ${name} ${code}
	${BIN} google bluejay ${name} ${code}
	