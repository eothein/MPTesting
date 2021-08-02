#! /bin/bash -

Help()
{
   # Display Help
   echo "Perform the iperf3 function on the different links from the testbed"
   echo "Leave paramters out to just run the script "
   echo "Syntax: performanceTest.sh [-h|f|t]"
   echo "options:"
   echo "h     Print this Help."
   echo "f     fileName  Optional file name to write the output to"
   echo "t     time The time of the iperf test"
   echo
}

FILENAME=output.txt
TIME=30


################################################################################
# Process the input options. Add options as needed.                            #
################################################################################
# Get the options
while getopts "hft:" option; do
	case $option in
 		h) # display Help
         		Help
         		exit;;
		f) # Define output file name
			FILENAME=${OPTARG}
			if [[ ! -e ${OPTARG} ]]; then
			echo "Creating $FILENAME"
			    touch ${OPTARG}
			fi;;
		t) # Define time interval
			TIME=${OPTARG};;
     		\?) # incorrect option
         		echo "Error: Invalid option"
         		exit;;
   	esac
done

performBandwidthTest() {
  echo "Performing iperf3 for $1 -t $TIME"
	tempFile="raw_$1.txt"
	iperf3 -c $1 -t $TIME --forceflush --logfile $tempFile
	lines=$(wc -l $tempFile | awk '{ print $1 }')

	let "line=lines-3"
	# Gathering bandwidth for sender
	rateSender=$(awk 'NR==line {print $7}' line="${line}"   $tempFile)
	# Gathering mb sent for sender
	bwSent=$(awk 'NR==line {print $5}' line="${line}"   $tempFile)
	# Gathering number of retries for sender
	retriesSender=$(awk 'NR==line {print $9}' line="${line}"   $tempFile)

	let "line=line+1"
	# Gathering bandwidth for receiver
  	rateReceiver=$(awk 'NR==line {print $7}' line="${line}"   $tempFile)
  	# Gathering mb received
  	bwReceived=$(awk 'NR==line {print $5}' line="${line}"   $tempFile)
	# Retries received receiver
	retriesReceived==$(awk 'NR==line {print $9}' line="${line}"   $tempFile)

	echo -e "$1 \t $TIME \t $rateSender \t $bwSent \t $retriesSender \t $rateReceiver \t $bwReceived \t $retriesReceived" >> "${FILENAME}"
}

ips=(
12.12.0.1
13.13.0.1
10.8.0.1
)


echo "###########################" >> "${FILENAME}"
echo "Metadata for the test: " >> "${FILENAME}"
echo "###########################" >> "${FILENAME}"
echo `date -u` >> "${FILENAME}"
echo "###########################" >> "${FILENAME}"
echo -e "Ratesender \t Bandwidthsender \t Ratereceiver \t Bandwidthreceiver \t retriesSender" >> "${FILENAME}"
for index in  "${ips[@]}"
  do performBandwidthTest "$index"
done
