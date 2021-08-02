RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
# Function to test whether an IP (first argument) is available from this host
testIp() {
	if ping -c1 -w1 $1 &>/dev/null
	then
		 printf "Connection to ${GREEN} $1 ${NC} is up \n"
	else
		 printf "Connection to ${RED} $1  ${NC} is down \n"
	fi
}

ips=(
12.12.0.1
13.13.0.1
10.8.0.1
)

for index in  "${ips[@]}"
	do testIp "$index"
done
