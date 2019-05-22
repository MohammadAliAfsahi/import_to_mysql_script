#!/bin/bash
echo "Database Name(or Path)": 
read database_name
echo UserName :
read user_name



while true; do
    read -s -p "Password: " password
    echo
    read -s -p "Password (again): " password2
    echo
    [ "$password" = "$password2" ] && break
    echo "Please try again"
done

echo root password:
read -s rootpassword
FILES=""
database=""
filename=''
case $database_name in 
	*.sql ) ## here we have a single file we separate extension and file name(database name)
		filename=$(basename $database_name)
		name="${database_name%.*}"
		database="$(echo $name | sed 's/[)(]//g')"
		;;
	*)
		FILES=$database_name"/*"
		database=${database_name##*/}
		;;
esac

# what if the user has entered a single database? maybe we should use a case block here
# or we can allow directories containing database files only, not a single file :)

mysql -u root -p$rootpassword -e "DROP DATABASE IF EXISTS ${database}_db;"
mysql -u root -p$rootpassword -e "CREATE DATABASE ${database}_db;"

 


if [ -z "$filename" ] ## if we have a single file filename is empyty so we have a directory
then

for f in $FILES;
do
  mysql $database"_db" < "$f"

done

else ## else we a single file that we want to import it to database!
echo  	
  mysql $database"_db" < "$filename"
fi

mysql -u root -p$rootpassword -e "CREATE USER $user_name@'localhost' IDENTIFIED BY '$password';"
mysql -u root -p$rootpassword -e "GRANT ALL PRIVILEGES ON ${database}_db.* TO ${user_name}@localhost; FLUSH PRIVILEGES;"

