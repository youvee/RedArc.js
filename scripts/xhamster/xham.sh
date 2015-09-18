#!/bin/bash
# xhamster video/photo retriever


urldecode() { 
    local url_encoded="${1//+/ }";
    printf '%b' "${url_encoded//%/\x}"
}

for i in "$@";
    do 
     if [ $(echo "$i" | grep "/movies/\|embed.php") ]
      then
# video download
	echo $i is being downloaded. ;
        TITLE=$(echo "$i" | sed -e 's|\.html||' -e 's|\?.*||' |awk -F'/' '{print $6"-"$5}');
        LINK=$(curl  -A 'Mozilla/5.0 (Windows; U; Windows NT 6.1; rv:2.2) Gecko/20110201' -s "$i" | grep 'mp4\|flv' |sed -e 's|srv=|\n|' -e 's|&image|\n|' |grep 'file:\|speed' | grep -Eo "http.*\.mp4.*'" | cut -d"'" -f1 | head -1);
        URL=$(urldecode "$LINK");
        wget "$URL" -c -O "$TITLE.mp4";
     
     elif [ $(echo "$i" | grep "/photos/gallery/") ]
      then
# gallery download
	PAGES=$(curl -s "$i" | grep "<div class='pager'>.*class='last'" | sed 's|>|\n|g' | grep -o "^[0-9]"| tail -1) ;
	TITLE=$(echo "$i" | sed -e 's|\.html||' -e 's|\?.*||' |awk -F'/' '{print $7"-"$6}') ;
	echo $i is being downloaded to $TITLE. ;
	for images in {1..$PAGES} ;
		do curl -A 'Mozilla/5.0 (Windows; U; Windows NT 6.1; rv:2.2) Gecko/20110201' -s "${i%.html}-$images.html" | grep -o "/photos/view/[^']*" | sed 's|^|http://xhamster.com|g' | xargs curl  -A 'Mozilla/5.0 (Windows; U; Windows NT 6.1; rv:2.2) Gecko/20110201' -Ls | grep "src='.*align='center'" | grep -o "http[^']*" | xargs wget -nv -c -U 'Mozilla/5.0 (Windows; U; Windows NT 6.1; rv:2.2) Gecko/20110201' -P "$TITLE" ;
	done  
	
     elif [ $(echo "$i" | grep "/photos/view/") ]
# single image downloader
      then
       echo $i is being downloaded. ;
       curl "$i" -A 'Mozilla/5.0 (Windows; U; Windows NT 6.1; rv:2.2) Gecko/20110201' -Ls | grep "src='.*align='center'" | grep -o "http[^']*" | xargs wget -nv -c -U 'Mozilla/5.0 (Windows; U; Windows NT 6.1; rv:2.2) Gecko/20110201' ;
     
     else [ $(echo "$i" | grep -v "xhamster.com") ]
      echo $i is not supported!
    fi    
done
