run:
	nextflow run main.nf --force true

clean:
	rm -rf work && rm -rf pipeline_out
