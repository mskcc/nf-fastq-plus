# Container image that runs your code
FROM alpine:3.10

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY e2e/samplesheet_stats_main_test.sh /samplesheet_stats_main_test.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/samplesheet_stats_main_test.sh"]
