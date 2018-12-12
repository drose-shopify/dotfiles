mov2gif() {
    output=${1}
    if [ -z "$2" ]; then
        output="${output:r}.gif"
    else
        output=${2}
    fi
    ffmpeg -i $1 -f gif - | gifsicle --optimize=3 > ${output}
}
