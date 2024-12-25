python:
	@python3 day01.py

zig: clean
	@zig build-exe -OReleaseSmall day01.zig
	@day01

zigdebug: clean
	@zig build-exe day01.zig
	@day01

zigtest: clean
	@zig test -OReleaseSmall day01.zig

c: clean
	@gcc -Os day01.c -o day01
	@day01

clean:
	@rm -f day01
