python:
	@python3 day1.py

zig: clean
	@zig build-exe -OReleaseSmall day1.zig
	@day1

c: clean
	@gcc -Os day1.c -o day1
	@day1

clean:
	@rm -f day1
