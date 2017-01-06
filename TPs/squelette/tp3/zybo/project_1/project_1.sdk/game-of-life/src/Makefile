update:
	cp ../../../../../address_map.h address_map.h
	$(RM) -r hardware/offsets/
	mkdir -p hardware/
	cp -r ../../../../../hardware/offsets/ hardware/offsets/

update-main:
	cp main.c main.c.old
	cd ../../../../../software/ && generer-squelette.pl -o $(PWD) main.c
	diff -u main.c.old main.c
