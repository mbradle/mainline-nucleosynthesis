bin_dir=../../single_zone
out=../../$1/
in_dir=${out}/h_burning
out_dir=${out}/he_burning

mkdir -p ${out_dir}

${bin_dir}/single_zone_network @run.rsp --zone_xml ${in_dir}/out.xml --output_xml ${out_dir}/out.xml > ${out_dir}/log.txt
