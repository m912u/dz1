#!/bin/bash

#параметры
count=10    				#кол-во файлов для генерации
size=1000   				#размер файлов для генерации
localpath="/tmp/" 			#локальный путь для генерации файлов
filemask="rndfile"    			#префикс имени генерируемых файлов
remotehost="84.201.179.174"		#удаленный хост
remotepath="/tmp"			#путь на удаленном хосте, используемый для хранения бэкапов
remoteuser="root"			#пользователь на удаленном хосте, используется для подключения по SSH. Должны быть настроены ключи!
remotefilemaxage=10080			#максимальный возраст файла на удаленном хосте в минутах (так проще тестить)

#удаляем существующие файлы
echo "`date` Начало удаления старых локальных файлов"
rm $localpath/$filemask*
echo "`date` Конец удаления старых локальных файлов"

#генерация новых файлов
echo "`date` Начало генерации новых локальных файлов"
timestamp=$(date +%s)
for ((i=1; i <= $count; i++))
do
	echo "`date` Генерация $i/$count файла размером $size с меткой $timestamp"
	head -c $size /dev/urandom > $localpath/$filemask-$timestamp-$i
done
echo "`date` Конец генерации новых локальных файлов"


#передача файлов на удаленный хост
echo "`date` Начало передачи файлов на удаленный хост"
rsync $localpath/$filemask* $remoteuser@$remotehost:$remotepath/
echo "`date` Конец передачи локальных файлов на удаленный хост"

#удаление старых файлов на удаленном хосте
echo "`date` Начало очистки старых файлов на удаленном хосте"
ssh $remoteuser@$remotehost "find $remotepath/ -name "$filemask*" -type f -mmin +$remotefilemaxage -exec rm -f {} \;"
echo "`date` Конец очистки файлов на удаленном хосте"

