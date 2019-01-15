mov2gif() {
    output=${1}
    if [ -z "$2" ]; then
        output="${output:r}.gif"
    else
        output=${2}
    fi
    ffmpeg -i $1 -vf scale=1080:-1:flags=lanczos,palettegen -f palette.png
    ffmpeg -i $1 -i -i palette.png -filter_complex "fps=15,scale=1080:-1:flags=lanczos[x];[x][1:v]paletteuse" $2
    rm palette.png
}
