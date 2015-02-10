# Array with recipe names
expressions=("Chicken Parmagiana" "Lemon Chicken" "Chicken Farfale" "Butter Chicken")

# Seed random generator

while [ : ]
do
	echo -e "POST to sync gateway"

	selectedexpression=${expressions[$RANDOM % ${#expressions[@]} ]}

	curl -X POST -H 'Content-Type: application/json' \
	-d '{"type":"recipe", "title":"'"${selectedexpression}"'"}' \
	http://localhost:4984/cookbook/ -w "\n"

	sleep 2
done