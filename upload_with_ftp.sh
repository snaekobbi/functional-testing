set -x
set -e
FTP_HOST=ftp://ftpcluster.loopia.se
[[ -z "$FTP_USER" ]] && read -p "user: " FTP_USER
[[ -z "$FTP_SECRET" ]] && read -s -p "secret: " FTP_SECRET
shopt -s globstar
for file in target/site/**/*; do
    [ -f $file ] && curl --ftp-create-dirs -T $file $FTP_HOST/${file#target/site/} --user $FTP_USER:$FTP_SECRET
done

