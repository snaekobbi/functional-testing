FTP_HOST=ftp://ftpcluster.loopia.se
[[ -z "$FTP_USER" ]] && read -p "user: " FTP_USER
[[ -z "$FTP_SECRET" ]] && read -s -p "secret: " FTP_SECRET
for file in target/classes/**/*; do
    if [[ -f $file && $file != target/classes/META-INF/* ]]; then
        curl --ftp-create-dirs -T $file $FTP_HOST/${file#target/classes/} --user $FTP_USER:$FTP_SECRET
    fi
done
