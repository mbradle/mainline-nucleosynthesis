margs=1

function example {
    echo -e "example: $0 --model model1\n"
}

function usage {
    echo -e "usage: $0 MANDATORY [OPTION]\n"
}

function help {
  usage
    echo -e "MANDATORY:"
    echo -e "  --model  VAL  The output subdirectory"
    echo -e "OPTION:"
    echo -e "  --out_dir  VAL  The output directory (output)"
    echo -e "  -h, --help  Prints this help\n"
  example
}

function margs_precheck {
	if [ $2 ] && [ $1 -lt $margs ]; then
		if [ $2 == "--help" ] || [ $2 == "-h" ]; then
			help
			exit
		else
	    	usage
			example
	    	exit 1 # error
		fi
	fi
}

function margs_check {
	if [ $# -lt $margs ]; then
	    usage
	  	example
	    exit 1 # error
	fi
}

margs_precheck $# $1

# Args while-loop

out_dir=output

while [ "$1" != "" ];
do
   case $1 in
   --model )  shift
              model=$1
              ;;
   --out_dir )  shift
              out_dir=$1
              ;;
   -h   | --help )        help
                          exit
                          ;;
   *)                     
                          echo "$script: illegal option $1"
                          usage
						  example
						  exit 1 # error
                          ;;
    esac
    shift
done

# Mandatory paramter check

margs_check ${model}

# Clone the necessary codes.

if [[ ! -d wn_user ]]
then
   git clone https://bitbucket.org/mbradle/wn_user
else
   git -C wn_user pull
fi

if [[ ! -d single_zone ]]
then
   git clone https://bitbucket.org/mbradle/single_zone
else
   git -C single_zone pull
fi

# Save home directory

HOME=`pwd`

# Set the includes and make the code.

cd wn_user
git checkout develop
cd ..
export WN_USER=1
cp input/master.h single_zone
cd single_zone
git checkout develop
./project_make

# Set key data

output=${out_dir}/$model

# Download the data.

make data

# Run stages

for stage in h_burning he_burning c_burning ne_burning o_burning si_burning
do
  cd ${HOME}/input/$stage
  ./run.sh ${output}
  cp run.rsp ${HOME}/${output}/$stage
done

# Tar and zip model

cd ${HOME}/${out_dir}

tar cvf ${model}.tar -T /dev/null

for stage in h_burning he_burning c_burning ne_burning o_burning si_burning
do
  tar rvf ${model}.tar ${model}/$stage/out.xml ${model}/$stage/run.rsp
done

gzip ${model}.tar
