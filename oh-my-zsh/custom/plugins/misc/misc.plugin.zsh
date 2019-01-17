mov2gif() {
    output=${1}
    if [ -z "$2" ]; then
        output="${output:r}.gif"
    else
        output=${2}
    fi
    ffmpeg -i $1 -vf fps=15,scale=1080:-1:flags=lanczos,palettegen palette.png
    ffmpeg -i $1 -i palette.png -filter_complex "fps=15,scale=1080:-1:flags=lanczos[x];[x] [1:v]paletteuse" ${output}
    rm palette.png
}
