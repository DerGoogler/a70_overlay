BIN = ./generate.sh

overlays:
	chmod +x ./generate.sh
	${BIN} google raven
	${BIN} google redfin
	${BIN} google sunfish
	${BIN} google coral
	${BIN} google cheetah
	${BIN} google bonito
	${BIN} google bluejay