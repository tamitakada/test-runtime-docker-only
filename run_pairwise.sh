#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
SCRIPT_USERNAME="runtimeprofiler"

# project details
url="$1"
sha="$2"
module="$3"
ver="$4"

# file with test classes to run as prefixes on each line
prefix_test_classes="$5" 

# file with test classes to run after all above prefixes on each line
target_test_classes="$6"

echo "About to run: $url, $sha, $module"
project_name=$(basename $url)
project_name="${project_name%.git}"
full_path=$project_name

if [ -n "$module" ]; then
    full_path="$project_name/$module"
fi

echo $project_name
echo $full_path

image="java-${ver}"

# Create base Docker image if it does not exist
docker inspect $image > /dev/null 2>&1
if [ $? == 1 ]; then
    sed -i.bak -e "s|REPO_LINK|$url|g" -e "s|REPO_NAME|$project_name|g" -e "s|SHA|$sha|g" -e "s|JAVA_VER|$ver|g" ProjectDockerFile
    docker build -t $image -f ProjectDockerFile .
    rm ProjectDockerFile
    mv ProjectDockerFile.bak ProjectDockerFile
fi

while read tc1; do
    if [ -n "$tc1" ]; then

        mkdir -p results-java-cpy/$full_path/$tc1
        echo "$tc1\n" > ord.txt # single test class order

        # run baseline
        docker run -t --name "temp" -v ${SCRIPT_DIR}:/Scratch ${image} /bin/bash -x /Scratch/run_pair.sh "$tc1" /Scratch/ord.txt "$full_path"
        docker wait temp
        echo "$full_path/$tc1"
        mkdir -p results-java-cpy/$full_path/$tc1/none
        mv results-java/$full_path/* results-java-cpy/$full_path/$tc1/none

        docker rm temp

        # run pairs
        while read tc2; do
            if [[ -n "$tc2" && "$tc1" != "$tc2" ]]; then
                echo "Running $tc2->$tc1"
                echo "$tc2\n$tc1" > ord.txt # set order
            
                docker run -t --name "temp" -v ${SCRIPT_DIR}:/Scratch ${image} /bin/bash -x /Scratch/run_pair.sh "$tc1,$tc2" /Scratch/ord.txt "$full_path"
                docker wait temp
                echo "$full_path/$tc1/$tc2"
                mkdir -p results-java-cpy/$full_path/$tc1/$tc2
                mv results-java/$full_path/* results-java-cpy/$full_path/$tc1/$tc2
                mv ord.txt results-java-cpy/$full_path/$tc1/$tc2
            
                docker rm temp
            fi
        done < "$prefix_test_classes"
    fi
done < "$target_test_classes"

docker rmi $image
