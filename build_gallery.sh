#!/bin/bash
  
  full_path='./full'
  thumb_path='./thumbs'

#options -f full_path
while getopts ":f:t:" opt; do
  case $opt in
    f)
      full_path=$OPTARG
      ;;
    t)
      thumb_path=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

echo -e "Creating thumbnails for images that are in '$full_path' directory"
  thumb_count=0
  touch "tmp_links.part"

  for photo in $full_path/*.jpg; do
    mogrify -resize 100x100 -format jpg -quality 85 -path $thumb_path $photo

    dimensions=(`identify -format "%w %h" $photo`)
    width=${dimensions[0]}
    height=${dimensions[1]}
    if [ "$width" -lt "$height" ]; then
      ratio='portrait'
    else
      ratio='landscape'
    fi

    b_photo=$(basename $photo)
    echo '
<div class="image">
  <a class="preview" rel="gallery" href="'$full_path/$b_photo'">
    <img class="'$ratio'" src="'$thumb_path/$b_photo'"/>
  </a>
  <a class="original" href="'$full_path/$b_photo'">
      <span>Originaal fail</span>
  </a>
</div>' >> 'tmp_links.part'
    thumb_count=$((thumb_count+1))
    echo "processing '$photo'"
  done
    echo -e "Created $thumb_count thumbnails."

function build_gallery(){
  cat _tmp/header.part > "index.html"
  cat tmp_links.part >> "index.html"
  echo -e "</div>\n</body>\n</html>" >> "index.html"
  rm tmp_links.part
  echo -e "==============================================\n"
  echo -e "Gallery ready!\n\nUpload these files and directories to your site:\nindex.html\n'misc'\n'$thumb_path'\n'$full_path'\n"
}

if [ -d "_tmp" ]; then 
  if [ -f "_tmp/header.part" ]; then
    #we have what we need, run gallery builder
    build_gallery
  else
    #missing header.part    
    echo "error: missing _tmp/header.part, exiting"
    exit 1
  fi
  else
    echo "error: missing _tmp directory, exiting"
    exit 1
fi

