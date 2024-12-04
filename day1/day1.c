#include <ctype.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum { false, true } bool;

typedef struct {
    int64_t *items;
    size_t len;
    size_t cap;
} arraylist_t;

void append_arraylist_t(arraylist_t *al, size_t value);
int64_t get_arraylist_t(arraylist_t *al, size_t index);
void init_arraylist(arraylist_t *al, size_t cap);
void deinit_arraylist(arraylist_t *al);

void init_arraylist(arraylist_t *al, size_t cap) {
    int64_t *arr = (int64_t *)malloc(cap * sizeof(int64_t));
    if (arr == NULL) {
        exit(EXIT_FAILURE);
    }
    al->cap = cap;
    al->len = 0;
    al->items = arr;
}

void deinit_arraylist(arraylist_t *al) { free(al->items); }

void append_arraylist_t(arraylist_t *al, size_t value) {
    if (al->len >= al->cap) {
        int64_t *arr = (int64_t *)malloc(al->cap * 2 * sizeof(int64_t));
        if (arr == NULL) {
            exit(EXIT_FAILURE);
        }
        al->cap *= 2;
        al->items = arr;
        free(al->items);
    }
    al->items[al->len++] = value;
}

int64_t get_arraylist_t(arraylist_t *al, size_t index) {
    if (index >= al->len) {
        exit(EXIT_FAILURE);
    }
    return al->items[index];
}

int main() {
    char *fileName = "../day1.input";
    FILE *file = fopen(fileName, "r");
    if (file == NULL) {
        return EXIT_FAILURE;
    }

    if (fseek(file, 0, SEEK_END) == -1) {
        return EXIT_FAILURE;
    }

    size_t file_size = ftell(file);
    if (file_size == -1) {
        return EXIT_FAILURE;
    }

    rewind(file);

    uint8_t *input_data = (uint8_t *)malloc(file_size * sizeof(uint8_t));
    if (input_data == NULL) {
        return EXIT_FAILURE;
    }

    size_t read_size = fread(input_data, 1, file_size, file);
    if (read_size != file_size) {
        return EXIT_FAILURE;
    }
    input_data[file_size] = '\0';

    arraylist_t right, left;

    init_arraylist(&right, 1000);
    init_arraylist(&left, 1000);

    // TODO: parse numbers from input_data
    char *buffer;
    char *temp = (char *)malloc(sizeof(char) * 6);
    if (!temp) {
        exit(EXIT_FAILURE);
    }
    buffer = temp;
    bool toggle = true;
    size_t count = 0;
    char *test;
    char *temp2 = (char *)malloc(sizeof(char) * 6);
    if (!temp) {
        exit(EXIT_FAILURE);
    }
    test = temp2;
    char *endptr;
    for (int i = 0; i < read_size; ++i) {
        if (isdigit(input_data[i])) {
            buffer[count] = i;
            count++;
        } else {
            if (memcmp(&buffer, &test, 6) == 0) {
                count = 0;
                continue;
            }
            buffer[5] = '\0';
            printf("%s", buffer);
            int64_t num = strtoll(buffer, &endptr, 10);
            if (toggle) {
                append_arraylist_t(&left, num);
            } else {
                append_arraylist_t(&right, num);
            }
            toggle = !toggle;
            count = 0;
            memset(buffer, 0, 6);
        }
    }

    // for (int i = 0; i < 1000; i++) {
    //     printf("%ld\n", right.items[i]);
    // }

    // deinit_arraylist(&right);
    // deinit_arraylist(&left);
    free(test);
    free(buffer);
    free(input_data);
    input_data = NULL;
    fclose(file);
}
