#!/usr/bin/env bash

if [ "$EUID" = 0 ]; then
  echo "Please do not run this script as root!"
  exit 1
fi

if [ "$1" == "" ]; then
  echo "Please provide the directory to sites! Example:"
  echo "$ ./wordpress-timecapsule-fix.sh /www/sites"
  exit 1
fi

print_log() {
  SITE_ROOT_DIRECTORY="$1"
  SITE_DIRECTORY_NAME=$(basename ${SITE_ROOT_DIRECTORY})
  NAMESPACE="$2"
  MESSAGE="$3"

  GREEN='\033[0;32m'
  NC='\033[0m' # No Color

  printf "${GREEN}[${SITE_DIRECTORY_NAME}][$NAMESPACE]${NC} ${MESSAGE}\n"
}

remove_timecapsule() {
  SITE_ROOT_DIRECTORY="$1"
  TIMECAPSULE_DIRECTORY="${SITE_ROOT_DIRECTORY}/wp-content/plugins/wp-time-capsule"
  if [ -d "${TIMECAPSULE_DIRECTORY}" ]; then
    print_log ${SITE_ROOT_DIRECTORY} 'wordpress' 'removing the "WP Time Capsule" plugin directory'
    rm -r ${TIMECAPSULE_DIRECTORY}
  fi
}

remove_malicious_content_from_files() {
  DIRECTORY_PATH="$1"

  find ${DIRECTORY_PATH} \
     -type f \
     ! -name "*.*" \
     -o \
     -name "*.php" \
     -exec \
     perl -0pi -e 's/<\?php[\s\S]*?\*\/\s*global\s*\/\*[\s\S]*?\n\?>//g' {} +   

  find ${DIRECTORY_PATH} \
     -type f \
     ! -name "*.*" \
     -o \
     -name "*.php" \
     -exec \
     perl -0pi -e 's/<\?php[\s\S]*?\*\/\s*if\s*\/\*[\s\S]*?\n\?>//g' {} + 

  find ${DIRECTORY_PATH} \
     -type f \
     ! -name "*.*" \
     -o \
     -name "*.php" \
     -exec \
     perl -0pi -e 's/<\?php[\s\S]*?if\/\*\-.*?\*\-[\s\S]*?\n\?>//g' {} +
}

remove_malicious_files_from_directory() {
  DIRECTORY_PATH="$1"

  find ${DIRECTORY_PATH} \
     -type f \
     ! -name "*.*" \
     -o \
     -name "*.php" \
     -exec \
     grep -q \
     -e "Tiny File Manager" \
     -e "17OKNtKmnPJb" \
     -e "} \$fuction_info" \
     -e "x3d\"; goto " \
     -e "3Ww6jXpopHVh4Gjssu1+Hq85cvx4l/M+mhyw" \
     -e "RfdGltZV9saW1pdCgzNjAwKTtAaWdub3JlX3VzZXJfYW" \
     -e "NDFMXHg1MyJ9WyJuXHg2Y2tceDY3XHg2Y3" \
     -e "VudCBhbmQgVGVtcGxhdGUgKi8NCnJlcXVp" \
     -e "jAwKTtAaWdub3JlX3VzZXJfYWJvcnQoMSk7JGl4diA9ICI" \
     -e "@pack(" \
     -e "count(\$func)))" \
     -e "\$func[\$i]); goto" \
     -e "}}}die();" \
     -e " ( Array(6" \
     -e "Array(6 " \
     -e "str_replace('pqhbts" \
     -e "'/ind' . 'ex.php';" \
     -e "\$_POST);foreach (\$" \
     -e "_COOKIE\['pw_name" '{}' \; -delete

  find ${DIRECTORY_PATH} \
     -type f \
     -name "*.php" \
     -exec \
     grep -qzP '";(\n|.)*?substr.*\(.*",.*0.*\);' {} \; -delete

  find ${DIRECTORY_PATH} \
     -type f \
     -name "*.suspected" -delete
     
}

remove_malicious_htaccess() {
  DIRECTORY_PATH="$1"
  find ${DIRECTORY_PATH} -type f -name '*.htaccess' -exec grep -q ".(py|exe|phtml" '{}' \; -delete
}

remove_known_malicious_files() {
  DIRECTORY_PATH="$1"
  MALICIOUS_FILES=(about.php adminfuns.php wp-cron.php wp-blog-header.php)

  for i in "${MALICIOUS_FILES[@]}"; do
    MALICIOUS_FILE_PATH="${DIRECTORY_PATH}/${i}"
    if [ -f "${MALICIOUS_FILE_PATH}" ]; then
      rm "${MALICIOUS_FILE_PATH}"
    fi
  done
}

reinstall_wordpress() {
  SITE_ROOT_DIRECTORY="$1"
  TEMP_DIRECTORY_NAME="wordpress-timecapsule-fix-temp"
  TEMP_ROOT_DIRECTORY="${SITE_ROOT_DIRECTORY}/${TEMP_DIRECTORY_NAME}"

  print_log ${SITE_ROOT_DIRECTORY} 'reinstall-wordpress' 'removing directiories "wp-admin" and "wp-includes"'
  rm -r ${SITE_ROOT_DIRECTORY}/wp-admin ${SITE_ROOT_DIRECTORY}/wp-includes

  print_log ${SITE_ROOT_DIRECTORY} 'reinstall-wordpress' 'creating a temporary directory'
  mkdir ${TEMP_ROOT_DIRECTORY}

  print_log ${SITE_ROOT_DIRECTORY} 'reinstall-wordpress' 'removing malicious files from "wp-content"'
  remove_known_malicious_files ${SITE_ROOT_DIRECTORY}/wp-content
  remove_malicious_files_from_directory ${SITE_ROOT_DIRECTORY}/wp-content
  print_log ${SITE_ROOT_DIRECTORY} 'reinstall-wordpress' 'removing malicious htaccess from "wp-content"'
  remove_malicious_htaccess ${SITE_ROOT_DIRECTORY}/wp-content
  print_log ${SITE_ROOT_DIRECTORY} 'reinstall-wordpress' 'removing malicious content from files in "wp-content"'
  remove_malicious_content_from_files ${SITE_ROOT_DIRECTORY}/wp-content

  print_log ${SITE_ROOT_DIRECTORY} 'reinstall-wordpress' 'moving important files to the temporary directory'
  if [ -d ${SITE_ROOT_DIRECTORY}/wp-content ]; then
    mv ${SITE_ROOT_DIRECTORY}/wp-content ${TEMP_ROOT_DIRECTORY}
  fi
  if [ -f ${SITE_ROOT_DIRECTORY}/wp-config.php ]; then
    mv ${SITE_ROOT_DIRECTORY}/wp-config.php ${TEMP_ROOT_DIRECTORY}
  fi
  if [ -f ${SITE_ROOT_DIRECTORY}/.htaccess ]; then
    mv ${SITE_ROOT_DIRECTORY}/.htaccess ${TEMP_ROOT_DIRECTORY}
  fi

  print_log ${SITE_ROOT_DIRECTORY} 'reinstall-wordpress' 'remove everything except the temporary directory'
  find ${SITE_ROOT_DIRECTORY} -mindepth 1 -maxdepth 1 -type f -print0 | while IFS= read -r -d $'\0' file; do
    rm ${file}
  done
  find ${SITE_ROOT_DIRECTORY} -mindepth 1 -maxdepth 1 -type d -print0 | while IFS= read -r -d $'\0' directory; do
    if [ "${directory}" != "${TEMP_ROOT_DIRECTORY}" ]; then
      rm -r ${directory}
    fi
  done

  print_log ${SITE_ROOT_DIRECTORY} 'reinstall-wordpress' 'installing WordPress using WP-CLI'
  php wp-cli.phar core download --force --skip-content --path=${SITE_ROOT_DIRECTORY}
  rm -r ${SITE_ROOT_DIRECTORY}/wp-content 

  print_log ${SITE_ROOT_DIRECTORY} 'reinstall-wordpress' 'moving the files from the temporary directory'
  mv ${TEMP_ROOT_DIRECTORY}/* ${SITE_ROOT_DIRECTORY}
  if [ -f ${TEMP_ROOT_DIRECTORY}/.htaccess ]; then
    mv ${TEMP_ROOT_DIRECTORY}/.htaccess ${SITE_ROOT_DIRECTORY}
  fi
  print_log ${SITE_ROOT_DIRECTORY} 'reinstall-wordpress' 'removing the temporary directory'
  rm -r ${TEMP_ROOT_DIRECTORY}  
}

SITES_ROOT_DIRECTORY="$1"
find ${SITES_ROOT_DIRECTORY} -mindepth 1 -maxdepth 1 -type d -print0 | while IFS= read -r -d $'\0' directory; do
  # Check if the directory contains a WordPress site
  if [ -f "${directory}/wp-config.php" ] && [ -d "${directory}/wp-content" ]; then
    remove_timecapsule "${directory}"
    reinstall_wordpress "${directory}"
  else
    remove_known_malicious_files "${directory}"
  fi
done

