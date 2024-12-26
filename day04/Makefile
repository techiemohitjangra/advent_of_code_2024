python:
	@python3 day04.py $(filter-out $@,$(MAKECMDGOALS))

zig: clean
	@zig build-exe -OReleaseSmall day04.zig
	@day04

zigdebug: clean
	@zig build-exe day04.zig
	@day04

zigtest: clean
	@zig test -OReleaseSmall day04.zig

c: clean
	@gcc -Os day04.c -o day04
	@day04

clean:
	@rm -f day04

%:
	@:
