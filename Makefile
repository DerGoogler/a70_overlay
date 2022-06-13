NORMAL = ./generate.sh --normal
SYSTEMUI = ./generate.sh --systemui

normal:
	chmod +x ./generate.sh
	${NORMAL} google raven
	${NORMAL} google redfin
	${NORMAL} google sunfish
	${NORMAL} google coral
	${NORMAL} google cheetah
	${NORMAL} google bonito
	${NORMAL} google bluejay

systemui:
	chmod +x ./generate.sh
	${NORMAL} google raven
	${NORMAL} google redfin
	${NORMAL} google sunfish
	${NORMAL} google coral
	${NORMAL} google cheetah
	${NORMAL} google bonito
	${NORMAL} google bluejay

overlays: normal systemui