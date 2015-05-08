#!/bin/bash

set -o errexit
set -o nounset

INPUT=/bbx/input/biobox.yaml
OUTPUT=/bbx/output
TASK=$1

#validate yaml
${VALIDATOR}/validate-biobox-file --schema=${VALIDATOR}schema.yaml --input=${INPUT}

# Parse the read locations from this file
READS=$(sudo /usr/local/bin/yaml2json < ${INPUT} \
        | jq --raw-output '.arguments[] | select(has("fastq")) | .fastq[].value ')

#get fastq entries
FASTQS=$(sudo /usr/local/bin/yaml2json < ${INPUT} | jq --raw-output '.arguments[] | select(has("fastq")) | [.fastq[] | {value,type}] ' | tr '\n' ' ' )

#get length of fastq array
LENGTH=$( echo "$FASTQS" | jq  --raw-output 'length')

TMP_DIR="$(mktemp -d)/ray"

FASTQ_TYPE=""

mkdir -p $OUTPUT

for ((COUNTER=0; COUNTER <$LENGTH; COUNTER++))
do
         FASTQ_GZ=$( echo "$FASTQS" | jq --arg COUNTER "$COUNTER"  --raw-output '.['$COUNTER'].value')
         TYPE=$( echo "$FASTQS" | jq --arg COUNTER "$COUNTER"  --raw-output '.['$COUNTER'].type')
         
         if [ $TYPE == "paired" ]; then 
             FASTQ_TYPE="$FASTQ_TYPE -i $FASTQ_GZ"
         else
             FASTQ_TYPE="$FASTQ_TYPE -s $FASTQ_GZ"
         fi
done

# Run the given task
CMD=$(egrep ^${TASK}: /Taskfile | cut -f 2 -d ':')
if [[ -z ${CMD} ]]; then
  echo "Abort, no task found for '${TASK}'."
  exit 1
fi

eval $CMD

mv ${TMP_DIR}/Contigs.fasta ${OUTPUT}
mv ${TMP_DIR}/Scaffolds.fasta ${OUTPUT}

cat << EOF > ${OUTPUT}/biobox.yaml
version: 0.9.0
arguments:
  - fasta:
    - id: 1
      value: Contigs.fasta
      type: contig
    - id: 2
      value: Scaffolds.fasta
      type: scaffold
EOF
