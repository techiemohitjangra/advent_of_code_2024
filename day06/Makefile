python:
	@python3 day06.py $(filter-out $@,$(MAKECMDGOALS))

zig: clean
	@zig build-exe -OReleaseFast -fstrip day06.zig
	@./day06

zigsmall: clean
	@zig build-exe -OReleaseSmall -fstrip day06.zig
	@./day06

zigdebug: clean
	@zig build-exe -ODebug -fno-strip -fvalgrind -fsanitize-c day06.zig
	@./day06

zigtest: clean
	@zig test -fno-strip -fvalgrind day06.zig

c: clean
	@gcc -Os -o day06 -std=c11 -Wall day06.c
	@./day06

clean:
	@rm -f day06

%:
	@:
