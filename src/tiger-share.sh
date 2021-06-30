#!/usr/bin/env bash

HERE="$(dirname "$(readlink -f "${0}")")"

LOCAL_IP=$(hostname -I | cut -d' ' -f1)

PORT="8743"

filename=$(readlink -f "${1}")

[ ! -f "${filename}" ] && {
  filename=$(yad --file --borders=32 --width=800 --center --fixed --height=540 --text="Escolha o arquivo que deseja compartilhar:\n" --window-icon="nm-signal-100" --title="Tiger QuickShare" || exit )
}

[ ! -f "${filename}" ] && {
  exit
}

[ -f "${filename}" ] && {

  DOC_ROOT=$(mktemp -d)
  BASE_NAME=$(basename "${filename}")
  
  BASE_NAME=$(echo -n "${BASE_NAME}" | tr '[[:space:]]' '_')
  
  FULL_NAME=$(readlink -f "${filename}")
  
  ln -s "${FULL_NAME}" "${DOC_ROOT}/${BASE_NAME}"
  
  cp "${HERE}/download.php" "${DOC_ROOT}/index.php"
  
  sed -i "s|§filename|${BASE_NAME}|g" "${DOC_ROOT}/index.php"
  
  qrencode "http://$LOCAL_IP:$PORT" -o "${DOC_ROOT}/qrcode.png" -m 4 -s 16 -d 600
    
  php -S ${LOCAL_IP}:${PORT} -t ${DOC_ROOT} &
  
  PHP_PID=${!}
  
  sleep .5
  
  GTK_THEME=Adwaita:dark yad --picture --size=fit --filename="${DOC_ROOT}/qrcode.png" --width=640 --height=640 --center --no-buttons --borders=32 --text="<big>Escaneie o código QR abaixo para baixar o arquivo '${BASE_NAME}':</big>\n\nOu acesse http://${LOCAL_IP}:${PORT} a partir de um navegador\n" --window-icon="nm-signal-100" --title="Tiger QuickShare - ${BASE_NAME}"
  
  rm -rf ${DOC_ROOT}
  
  kill "${PHP_PID}"
  
  exit 0
}

echo "Você precisa passar um arquivo para ser compartilhado!"
exit 1
