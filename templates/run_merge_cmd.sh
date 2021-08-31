#!/bin/bash

# Evaluate the merge command (e.g. "samtools merge ${TARGET_BAM} ${SRC_BAM_1} ${SRC_BAM_2}...")
echo ${MERGE_CMD} >> ${CMD_FILE}
echo ${MERGE_CMD}
eval ${MERGE_CMD}
