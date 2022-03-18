version 1.0

workflow nanoseq {
	input{
		File samplesheet = "./samplesheet.csv"
		String protocol
		String outdir = "./results"
		String? email
		String? multiqc_title
		String? input_path
		String? flowcell
		String? kit
		String? barcode_kit
		Boolean? barcode_both_ends
		String? guppy_config
		String? guppy_model
		Boolean? guppy_gpu
		Int guppy_gpu_runners = 6
		Int guppy_cpu_threads = 1
		String gpu_device = "auto"
		String? gpu_cluster_options
		Int qcat_min_score = 60
		Boolean? qcat_detect_middle
		Boolean? skip_basecalling
		Boolean? skip_demultiplexing
		Boolean? run_nanolyse
		String? nanolyse_fasta
		String aligner = "minimap2"
		Boolean? stranded
		Boolean? save_align_intermeds
		String? skip_alignment
		String quantification_method = "bambu"
		Boolean? skip_quantification
		Boolean? skip_differential_analysis
		Boolean? skip_bigbed
		Boolean? skip_bigwig
		Boolean? skip_pycoqc
		Boolean? skip_nanoplot
		Boolean? skip_fastqc
		Boolean? skip_multiqc
		Boolean? skip_qc
		String igenomes_base = "s3://ngi-igenomes/igenomes"
		Boolean? igenomes_ignore
		String custom_config_version = "master"
		String custom_config_base = "https://raw.githubusercontent.com/nf-core/configs/master"
		String? hostnames
		String? config_profile_name
		String? config_profile_description
		String? config_profile_contact
		String? config_profile_url
		Int max_cpus = 16
		String max_memory = "128.GB"
		String max_time = "240.h"
		Boolean? help
		String publish_dir_mode = "copy"
		String? email_on_fail
		Boolean? plaintext_email
		String max_multiqc_email_size = "25.MB"
		Boolean? monochrome_logs
		String? multiqc_config
		String tracedir = "./results/pipeline_info"
		Boolean validate_params = true
		Boolean? show_hidden_params
		Boolean? enable_conda
		Boolean? singularity_pull_docker_container

	}

	call make_uuid as mkuuid {}
	call touch_uuid as thuuid {
		input:
			outputbucket = mkuuid.uuid
	}
	call run_nfcoretask as nfcoretask {
		input:
			samplesheet = samplesheet,
			protocol = protocol,
			outdir = outdir,
			email = email,
			multiqc_title = multiqc_title,
			input_path = input_path,
			flowcell = flowcell,
			kit = kit,
			barcode_kit = barcode_kit,
			barcode_both_ends = barcode_both_ends,
			guppy_config = guppy_config,
			guppy_model = guppy_model,
			guppy_gpu = guppy_gpu,
			guppy_gpu_runners = guppy_gpu_runners,
			guppy_cpu_threads = guppy_cpu_threads,
			gpu_device = gpu_device,
			gpu_cluster_options = gpu_cluster_options,
			qcat_min_score = qcat_min_score,
			qcat_detect_middle = qcat_detect_middle,
			skip_basecalling = skip_basecalling,
			skip_demultiplexing = skip_demultiplexing,
			run_nanolyse = run_nanolyse,
			nanolyse_fasta = nanolyse_fasta,
			aligner = aligner,
			stranded = stranded,
			save_align_intermeds = save_align_intermeds,
			skip_alignment = skip_alignment,
			quantification_method = quantification_method,
			skip_quantification = skip_quantification,
			skip_differential_analysis = skip_differential_analysis,
			skip_bigbed = skip_bigbed,
			skip_bigwig = skip_bigwig,
			skip_pycoqc = skip_pycoqc,
			skip_nanoplot = skip_nanoplot,
			skip_fastqc = skip_fastqc,
			skip_multiqc = skip_multiqc,
			skip_qc = skip_qc,
			igenomes_base = igenomes_base,
			igenomes_ignore = igenomes_ignore,
			custom_config_version = custom_config_version,
			custom_config_base = custom_config_base,
			hostnames = hostnames,
			config_profile_name = config_profile_name,
			config_profile_description = config_profile_description,
			config_profile_contact = config_profile_contact,
			config_profile_url = config_profile_url,
			max_cpus = max_cpus,
			max_memory = max_memory,
			max_time = max_time,
			help = help,
			publish_dir_mode = publish_dir_mode,
			email_on_fail = email_on_fail,
			plaintext_email = plaintext_email,
			max_multiqc_email_size = max_multiqc_email_size,
			monochrome_logs = monochrome_logs,
			multiqc_config = multiqc_config,
			tracedir = tracedir,
			validate_params = validate_params,
			show_hidden_params = show_hidden_params,
			enable_conda = enable_conda,
			singularity_pull_docker_container = singularity_pull_docker_container,
			outputbucket = thuuid.touchedbucket
            }
		output {
			Array[File] results = nfcoretask.results
		}
	}
task make_uuid {
	meta {
		volatile: true
}

command <<<
        python <<CODE
        import uuid
        print("gs://truwl-internal-inputs/nf-nanoseq/{}".format(str(uuid.uuid4())))
        CODE
>>>

  output {
    String uuid = read_string(stdout())
  }
  
  runtime {
    docker: "python:3.8.12-buster"
  }
}

task touch_uuid {
    input {
        String outputbucket
    }

    command <<<
        echo "sentinel" > sentinelfile
        gsutil cp sentinelfile ~{outputbucket}/sentinelfile
    >>>

    output {
        String touchedbucket = outputbucket
    }

    runtime {
        docker: "google/cloud-sdk:latest"
    }
}

task fetch_results {
    input {
        String outputbucket
        File execution_trace
    }
    command <<<
        cat ~{execution_trace}
        echo ~{outputbucket}
        mkdir -p ./resultsdir
        gsutil cp -R ~{outputbucket} ./resultsdir
    >>>
    output {
        Array[File] results = glob("resultsdir/*")
    }
    runtime {
        docker: "google/cloud-sdk:latest"
    }
}

task run_nfcoretask {
    input {
        String outputbucket
		File samplesheet = "./samplesheet.csv"
		String protocol
		String outdir = "./results"
		String? email
		String? multiqc_title
		String? input_path
		String? flowcell
		String? kit
		String? barcode_kit
		Boolean? barcode_both_ends
		String? guppy_config
		String? guppy_model
		Boolean? guppy_gpu
		Int guppy_gpu_runners = 6
		Int guppy_cpu_threads = 1
		String gpu_device = "auto"
		String? gpu_cluster_options
		Int qcat_min_score = 60
		Boolean? qcat_detect_middle
		Boolean? skip_basecalling
		Boolean? skip_demultiplexing
		Boolean? run_nanolyse
		String? nanolyse_fasta
		String aligner = "minimap2"
		Boolean? stranded
		Boolean? save_align_intermeds
		String? skip_alignment
		String quantification_method = "bambu"
		Boolean? skip_quantification
		Boolean? skip_differential_analysis
		Boolean? skip_bigbed
		Boolean? skip_bigwig
		Boolean? skip_pycoqc
		Boolean? skip_nanoplot
		Boolean? skip_fastqc
		Boolean? skip_multiqc
		Boolean? skip_qc
		String igenomes_base = "s3://ngi-igenomes/igenomes"
		Boolean? igenomes_ignore
		String custom_config_version = "master"
		String custom_config_base = "https://raw.githubusercontent.com/nf-core/configs/master"
		String? hostnames
		String? config_profile_name
		String? config_profile_description
		String? config_profile_contact
		String? config_profile_url
		Int max_cpus = 16
		String max_memory = "128.GB"
		String max_time = "240.h"
		Boolean? help
		String publish_dir_mode = "copy"
		String? email_on_fail
		Boolean? plaintext_email
		String max_multiqc_email_size = "25.MB"
		Boolean? monochrome_logs
		String? multiqc_config
		String tracedir = "./results/pipeline_info"
		Boolean validate_params = true
		Boolean? show_hidden_params
		Boolean? enable_conda
		Boolean? singularity_pull_docker_container

	}
	command <<<
		export NXF_VER=21.10.5
		export NXF_MODE=google
		echo ~{outputbucket}
		/nextflow -c /truwl.nf.config run /nanoseq-2.0.1  -profile truwl,nfcore-nanoseq  --input ~{samplesheet} 	~{"--samplesheet '" + samplesheet + "'"}	~{"--protocol '" + protocol + "'"}	~{"--outdir '" + outdir + "'"}	~{"--email '" + email + "'"}	~{"--multiqc_title '" + multiqc_title + "'"}	~{"--input_path '" + input_path + "'"}	~{"--flowcell '" + flowcell + "'"}	~{"--kit '" + kit + "'"}	~{"--barcode_kit '" + barcode_kit + "'"}	~{true="--barcode_both_ends  " false="" barcode_both_ends}	~{"--guppy_config '" + guppy_config + "'"}	~{"--guppy_model '" + guppy_model + "'"}	~{true="--guppy_gpu  " false="" guppy_gpu}	~{"--guppy_gpu_runners " + guppy_gpu_runners}	~{"--guppy_cpu_threads " + guppy_cpu_threads}	~{"--gpu_device '" + gpu_device + "'"}	~{"--gpu_cluster_options '" + gpu_cluster_options + "'"}	~{"--qcat_min_score " + qcat_min_score}	~{true="--qcat_detect_middle  " false="" qcat_detect_middle}	~{true="--skip_basecalling  " false="" skip_basecalling}	~{true="--skip_demultiplexing  " false="" skip_demultiplexing}	~{true="--run_nanolyse  " false="" run_nanolyse}	~{"--nanolyse_fasta '" + nanolyse_fasta + "'"}	~{"--aligner '" + aligner + "'"}	~{true="--stranded  " false="" stranded}	~{true="--save_align_intermeds  " false="" save_align_intermeds}	~{"--skip_alignment '" + skip_alignment + "'"}	~{"--quantification_method '" + quantification_method + "'"}	~{true="--skip_quantification  " false="" skip_quantification}	~{true="--skip_differential_analysis  " false="" skip_differential_analysis}	~{true="--skip_bigbed  " false="" skip_bigbed}	~{true="--skip_bigwig  " false="" skip_bigwig}	~{true="--skip_pycoqc  " false="" skip_pycoqc}	~{true="--skip_nanoplot  " false="" skip_nanoplot}	~{true="--skip_fastqc  " false="" skip_fastqc}	~{true="--skip_multiqc  " false="" skip_multiqc}	~{true="--skip_qc  " false="" skip_qc}	~{"--igenomes_base '" + igenomes_base + "'"}	~{true="--igenomes_ignore  " false="" igenomes_ignore}	~{"--custom_config_version '" + custom_config_version + "'"}	~{"--custom_config_base '" + custom_config_base + "'"}	~{"--hostnames '" + hostnames + "'"}	~{"--config_profile_name '" + config_profile_name + "'"}	~{"--config_profile_description '" + config_profile_description + "'"}	~{"--config_profile_contact '" + config_profile_contact + "'"}	~{"--config_profile_url '" + config_profile_url + "'"}	~{"--max_cpus " + max_cpus}	~{"--max_memory '" + max_memory + "'"}	~{"--max_time '" + max_time + "'"}	~{true="--help  " false="" help}	~{"--publish_dir_mode '" + publish_dir_mode + "'"}	~{"--email_on_fail '" + email_on_fail + "'"}	~{true="--plaintext_email  " false="" plaintext_email}	~{"--max_multiqc_email_size '" + max_multiqc_email_size + "'"}	~{true="--monochrome_logs  " false="" monochrome_logs}	~{"--multiqc_config '" + multiqc_config + "'"}	~{"--tracedir '" + tracedir + "'"}	~{true="--validate_params  " false="" validate_params}	~{true="--show_hidden_params  " false="" show_hidden_params}	~{true="--enable_conda  " false="" enable_conda}	~{true="--singularity_pull_docker_container  " false="" singularity_pull_docker_container}	-w ~{outputbucket}
	>>>
        
    output {
        File execution_trace = "pipeline_execution_trace.txt"
        Array[File] results = glob("results/*/*html")
    }
    runtime {
        docker: "truwl/nfcore-nanoseq:2.0.1_0.1.0"
        memory: "2 GB"
        cpu: 1
    }
}
    