# Ray Assembler

Signature: `ray:[fastq A] -> contigs B, scaffolds C`

## Quickstart

1. git clone https://github.com/bioboxes/ray
2. cd ray
3. docker build -t ray .
4. sudo docker run -v /path/to/your/assembler.yaml:/bbx/input/biobox.yaml -v /path/to/reads.fastq.gz:/bbx/input/test1/reads.fastq.gz -v /path/to/output:/bbx/output ray default

#### Example biobox.yaml:

```YAML
---
version: 0.9.0
arguments:
    - fastq:
      - id: "pe" 
        value: "/bbx/input/test1/reads.fastq.gz"
        type: paired
```

## Required
* gzipped reads with the path provided in biobox.yaml
* mount your input files to /bbx/input.
* mount your output directory to /bbx/output
* mount your .yaml to /bbx/input/biobox.yaml
* "default" task at the end of your docker run command
