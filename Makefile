# Run the same scans locally that the pipelines run:  make secrets | sast | sca | container | dast | all
.PHONY: secrets sast sca container dast all
secrets:   ; bash scripts/scan-secrets.sh
sast:      ; bash scripts/scan-sast.sh
sca:       ; bash scripts/scan-sca.sh
container: ; bash scripts/scan-container.sh
dast:      ; bash scripts/scan-dast.sh
all: secrets sast sca container dast
