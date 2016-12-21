update:
	cp ../../../../../address_map.h address_map.h
	$(RM) hardware/offsets
	mkdir -p hardware/
	cp -r ../../../../../hardware/offsets/ hardware/offsets/

update-main:
	cp main.c main.c.old
	cp ../../../../../software/main.c main.c
	diff main.c.old main.c
