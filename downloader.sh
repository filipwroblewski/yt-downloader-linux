#!/bin/bash

clear

librariesInstallation(){
	echo ""
	echo "***"
	printf "Prosze czekac, trwa instalowanie potrzebnych pakietow\n"
	printf "Moze to zajac okolo 2-3 minuty\n"
	{
		apt update --yes
		
		apt-get install python
		apt-get install youtube-dl
		
		apt --yes install ffmpeg
	} &> /dev/null
	echo "***"
	echo ""
	
}

getExtension(){
	echo ""
	echo "***"
	printf "Wybierz rozszerzenie pliku wyjsciowego (mp3/mp4)> "
	read FILEEXTENSION
	if [ "$FILEEXTENSION" == "mp3" ]
	then
		fileCut
	elif [ "$FILEEXTENSION" == "mp4" ]
	then
		fileCut
	else
		printf "Wprowadzone rozszerzenie nie jest obslugiwane.\n"
		getExtension
	fi
	echo "***"
	echo ""
}

fileCut(){
	echo ""
	echo "***"
	printf "Przycinanie pliku $FILEEXTENSION\n"
	{
		ffmpeg -i "$PATHTOVIDEO" -ss "$STARTVIDEO" -to "$ENDOFVIDEO" "$MAINOUTPUTFILENAME.$FILEEXTENSION"
	} &> /dev/null
	printf "Pomyslnie przycieto plik $FILEEXTENSION\n"
	#printf "$PATHTOVIDEO"
	rm -f "$PATHTOVIDEO"
	echo "***"
	echo ""
}

getYtVideo(){
	echo ""
	echo "***"
	printf "Pobieranie filmiku z serwisu YouTube ($LINKTOYTVIDEO)\n"
	
	youtube-dl -f 18 -q "$LINKTOYTVIDEO"
	OUTPUTFILENAME=`youtube-dl -f 18 --get-filename "$LINKTOYTVIDEO"`
	CURRENTPATH=`pwd`
	PATHTOVIDEO="$CURRENTPATH/$OUTPUTFILENAME"
	printf "$PATHTOVIDEO\n"
	echo "***"
	echo ""
}
#wstep
echo ""
echo "***"
echo "YouTube Cut/Downloader"
echo "***"
echo ""

echo "Uruchomiono $0"
[[ $(id -u) -ne 0 ]] && { printf "Skrypt wymaga uprawnien root'a!\n"; exit 1; }
echo "Pomyslna weryfikacja uzytkownika jako sudo"

#instalacja wszystkich potrzebnych bibliotek
librariesInstallation

#https://www.youtube.com/watch?v=a6RVze4Z15w
#link do filmiku na youtube, gdzie jest filmik, ktory nas interesuje
echo ""
echo "***"
echo -n "Podaj link do video (np. https://www.youtube.com/watch?v=a6RVze4Z15w): "
read LINKTOYTVIDEO
startTxt="https://www.youtube.com/watch?v="
while [[ !("$LINKTOYTVIDEO" = $startTxt*) ]]
do
	
	if [[ "$LINKTOYTVIDEO" = $startTxt* ]]
		then
			continue
	else 
		echo "Zly format"
		echo -n "Podaj link do video (np. https://www.youtube.com/watch?v=a6RVze4Z15w): "
		read LINKTOYTVIDEO
	fi 
done
echo "***"
echo ""
#LINKTOYTVIDEO=$1

#czas od ktorego chcemy przyciac nasz filmik, podany w formacie np: 
#00:00:05
echo ""
echo "***"
echo -n "Podaj czas od ktorego chcesz przyciac filmik (np. 00:00:05): "
read STARTVIDEO
while [[ !("$STARTVIDEO" =~ ^[0-9][0-9]+:+[0-9][0-9]+:+[0-9][0-9]$) ]]
do
	
	if [[ "$STARTVIDEO" =~ ^[0-9][0-9]+:+[0-9][0-9]+:+[0-9][0-9]$  ]]
		then
			continue
	else 
		echo "Zly format"
		echo -n "Podaj czas od ktorego chcesz przyciac filmik (np. 00:00:05): "
		read STARTVIDEO
	fi 
done
echo "***"
echo ""
#STARTVIDEO=$2

#czas do ktorego chcemy przyciac nasz filmik, podany w formacie np: 
#00:00:22
echo ""
echo "***"
echo -n "Podaj czas do ktorego chcemy przyciac nasz filmik (np. 00:00:15): "
read ENDOFVIDEO
while [[ !("$ENDOFVIDEO" =~ ^[0-9][0-9]+:+[0-9][0-9]+:+[0-9][0-9]$) ]]
do
	if [[ "$ENDOFVIDEO" =~ ^[0-9][0-9]+:+[0-9][0-9]+:+[0-9][0-9]$  ]]
		then
			continue
	else 
		echo "Zly format"
		echo -n "Podaj czas do ktorego chcemy przyciac nasz filmik (np. 00:00:15): "
		read ENDOFVIDEO
	fi 
done
echo "***"
echo ""
#ENDOFVIDEO=$3

#nazwa naszego pliku wyjsciowego, podana bez rozszerzenia np:
#nazwaPliku
echo ""
echo "***"
echo -n "Podaj nazwe wyjsciowa pliku (np. fajnaPiosenka): "
read MAINOUTPUTFILENAME
while [[ -z "$MAINOUTPUTFILENAME" ]]
do
	
	if [[ -z "$MAINOUTPUTFILENAME" ]]
		then
			echo "Nie moze byc puste"
			echo -n "Podaj nazwe wyjsciowa pliku (np. fajnaPiosenka): "
			read MAINOUTPUTFILENAME
	else 
		continue
	fi 
done
echo "***"
echo ""
#MAINOUTPUTFILENAME=$4

#przykladowe wywolanie skryptu: 
#sudo ./ytDownloader.sh

#pobranie filmiku z serwisu youtube
getYtVideo

#wybranie rozszerzenia pliku wyjsciowego i wywolanie funkcji (fileCut) odpowiedzialnej za przycinanie pliku
getExtension

# laczenie z FTP i wysylanie na niego pliku
HOST='ftp.nazwastrony.webd.pro'
USER='sysop@nazwastrony.pl'
PASS=''

echo ""
echo "***"
echo "Wysylanie pliku na serwer..."
echo "***"
echo ""
{
ftp -p -inv $HOST<< EOF
user $USER $PASS
d ./
put ./$MAINOUTPUTFILENAME.$FILEEXTENSION
bye
EOF
} &> /dev/null
echo ""
echo "***"
echo "Link do pobrania twojego pliku: https://www.nazwastrony.pl/sysop/$MAINOUTPUTFILENAME.$FILEEXTENSION"
echo "***"
echo ""