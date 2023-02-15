#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

echo "Downloading files..."

for specdir in ${SCRIPT_DIR}/SPECS/*; do
	if [[ -f ${specdir}/urls.txt ]]; then
		for url in $(grep . ${specdir}/urls.txt); do
			hash=$(cat ${specdir}/$(basename $specdir).signatures.json | jq -r ".Signatures.\"$(basename $url)\"")
			if [[ -f ${specdir}/$(basename $url) ]]; then
				existing_hash=$(sha256sum ${specdir}/$(basename $url) | cut --delimiter=" " -f1)
				if [[ "$hash" == "${existing_hash}" ]]; then
					echo "$(basename $url)... skipping (present with correct hash)."
					continue
				else
					echo "$(basename $url)... file has bad hash; retrying..."
					rm -f "${specdir}/$(basename $url)"
				fi
			else
				echo "$(basename $url)... downloading."
			fi

			wget -q -O ${specdir}/$(basename $url) $url
		done
	fi
done
