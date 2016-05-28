#!/bin/sh
#
MIDIPIX_PATH_DEFAULTS="/c/Midipix /z";

if [ "${1}" = -h ]; then
        echo "usage: $0 [drive_letter [dirname]]";
        exit 1;
elif [ ${#} -eq 0 ]; then
for MIDIPIX_PATH in ${MIDIPIX_PATH_DEFAULTS}; do
	[ -d /cygdrive${MIDIPIX_PATH} ] || continue;
	MIDIPIX_DRIVE=${MIDIPIX_PATH#/};
	MIDIPIX_DRIVE=${MIDIPIX_DRIVE%%/*};
	MIDIPIX_PNAME=${MIDIPIX_PATH#/${MIDIPIX_DRIVE}};
	MIDIPIX_PNAME=${MIDIPIX_PNAME#/};
	break;
done;
else
	MIDIPIX_DRIVE="${1}"; MIDIPIX_PNAME="${2}";
	if [ "${MIDIPIX_DRIVE#*[ 	]*}" != "${MIDIPIX_DRIVE}" ]\
	|| [ "${MIDIPIX_PNAME#*[ 	]*}" != "${MIDIPIX_PNAME}" ]; then
		echo "Error: drive_letter/dirname must not contain SP (\` ') or VT (\`\\\t') characters.";
		exit 1;
	fi;
fi;
MIDIPIX_PATH=/${MIDIPIX_DRIVE}${MIDIPIX_PNAME:+/${MIDIPIX_PNAME}};
if [ ! -d /cygdrive${MIDIPIX_PATH} ]; then
	echo "Error: Midipix path non-existent or invalid (\`${MIDIPIX_PATH}'.)";
	exit 1;
else
	if [ -f /cygdrive${MIDIPIX_PATH}/bin/libpsxscl.log ]; then
		echo Found libpsxscl.log, copying to /cygdrive${MIDIPIX_PATH}/bin/libpsxscl.last.
		cp /cygdrive${MIDIPIX_PATH}/bin/libpsxscl.log	\
			/cygdrive${MIDIPIX_PATH}/bin/libpsxscl.last;
	fi;
	echo "Midipix drive letter.....: ${MIDIPIX_DRIVE}";
	echo "Midipix pathname.........: ${MIDIPIX_PNAME}";
	echo "Absolute Midipix pathname: ${MIDIPIX_PATH}";
	echo --------------------------------------------------------
	echo WARNING: The cygdrive path prefix will be changed to /
	echo whilst the Midipix shell window is running. It will be
	echo reset to its original value of /cygdrive after it exits.
	echo --------------------------------------------------------
	mintty -h always -e /bin/sh -c "
		set -o errexit; stty raw -echo;
		mount --change-cygdrive-prefix /;
		cd ${MIDIPIX_PATH}/native/bin;
		export PATH=${MIDIPIX_PATH}/native/bin:${MIDIPIX_PATH}/native/lib;
		./ntctty.exe -e chroot //${MIDIPIX_PATH#/}/native /bin/bash";
	echo --------------------------------------------------------
	echo Resetting cygdrive path prefix to /.
	echo --------------------------------------------------------
	mount --change-cygdrive-prefix /cygdrive;
fi;