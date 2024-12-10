#include <assert.h>
#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum { false, true } bool;

void swap(int64_t *first, int64_t *second) {
    int64_t temp = *first;
    *first = *second;
    *second = temp;
}

void bubble_sort(int64_t *arr, size_t len) {
    for (int i = 0; i < len; i++) {
        for (int j = i; j < len; j++) {
            if (arr[i] > arr[j]) {
                swap(&arr[i], &arr[j]);
            }
        }
    }
}

typedef struct {
    int64_t *items;
    size_t len;
    size_t cap;
} arraylist_t;

void init_arraylist_t(arraylist_t *const al, const size_t cap);
void append_arraylist_t(arraylist_t *const al, const size_t value);
int64_t get_arraylist_t(arraylist_t *const al, const size_t index);
void deinit_arraylist_t(arraylist_t *const al);
void print_arraylist_t(arraylist_t *const al);

void init_arraylist_t(arraylist_t *const al, const size_t cap) {
    int64_t *arr = (int64_t *)malloc(cap * sizeof(int64_t));
    if (arr == NULL) {
        exit(EXIT_FAILURE);
    }
    al->cap = cap;
    al->len = 0;
    al->items = arr;
}

void append_arraylist_t(arraylist_t *const al, const size_t value) {
    if (al->len >= al->cap) {
        int64_t *arr = (int64_t *)malloc(al->cap * 2 * sizeof(int64_t));
        if (arr == NULL) {
            exit(EXIT_FAILURE);
        }
        al->cap *= 2;
        memcpy(arr, al->items, sizeof(int64_t) * al->len);
        free(al->items);
        al->items = arr;
    }
    al->items[al->len++] = value;
}

int64_t get_arraylist_t(arraylist_t *const al, const size_t index) {
    if (index >= al->len) {
        exit(EXIT_FAILURE);
    }
    return al->items[index];
}

void deinit_arraylist_t(arraylist_t *const al) {
    free(al->items);
    al->items = NULL;
}

void print_arraylist_t(arraylist_t *const al) {
    for (size_t i = 0; i < al->len; i++) {
        printf("%ld, ", al->items[i]);
    }
    printf("\n");
}

void test_array_t() {
    arraylist_t arr;
    init_arraylist_t(&arr, 2);
    assert(arr.len == 0);
    assert(arr.cap == 2);
    printf("Array:\nlen: %lu\ncap: %lu\n", arr.len, arr.cap);
    append_arraylist_t(&arr, 1);
    append_arraylist_t(&arr, 2);
    append_arraylist_t(&arr, 3);
    append_arraylist_t(&arr, 4);
    append_arraylist_t(&arr, 5);
    print_arraylist_t(&arr);
    printf("Array:\nlen: %lu\ncap: %lu\n", arr.len, arr.cap);
    assert(get_arraylist_t(&arr, 0) == 1);
    assert(get_arraylist_t(&arr, 1) == 2);
    assert(get_arraylist_t(&arr, 2) == 3);
    assert(get_arraylist_t(&arr, 3) == 4);
    assert(get_arraylist_t(&arr, 4) == 5);
    assert(arr.len == 5);
    assert(arr.cap == 8);
    deinit_arraylist_t(&arr);
    assert(arr.items == NULL);
}

void test() {
    char *testFile = "day1.test";
    FILE *file = fopen(testFile, "r");
    if (!file) {
        fprintf(stderr, "filed to open file with error no: %d\n", errno);
        exit(EXIT_FAILURE);
    }

    int64_t left_num, right_num;
    arraylist_t left, right;

    init_arraylist_t(&left, 6);
    init_arraylist_t(&right, 6);

    while (fscanf(file, "%ld %ld", &left_num, &right_num) > 0) {
        append_arraylist_t(&left, left_num);
        append_arraylist_t(&right, right_num);
    };

    print_arraylist_t(&left);
    print_arraylist_t(&right);
    printf("\n");
    for (size_t i = 0; i < left.len; ++i) {
        int64_t ln = get_arraylist_t(&left, i);
        int64_t rn = get_arraylist_t(&right, i);
        printf("%ld %ld\n", ln, rn);
    }
    printf("\n");

    deinit_arraylist_t(&left);
    deinit_arraylist_t(&right);
    fclose(file);
}

int main() {
    // test_array_t();
    // test();
    char *inputFile = "day1.input";
    FILE *file = fopen(inputFile, "r");
    int32_t dict[100000] = {0};

    int64_t left_num, right_num;
    arraylist_t left, right;

    init_arraylist_t(&left, 1000);
    init_arraylist_t(&right, 1000);

    while (fscanf(file, "%ld %ld", &left_num, &right_num) > 0) {
        append_arraylist_t(&left, left_num);
        append_arraylist_t(&right, right_num);
        dict[right_num] += 1;
    };

    // TODO: sort arraylist_t left and right
    bubble_sort(left.items, left.len);
    bubble_sort(right.items, right.len);

    int64_t res = 0;
    int64_t res2 = 0;
    for (size_t i = 0; i < left.len; ++i) {
        int64_t ln, rn;
        ln = get_arraylist_t(&left, i);
        rn = get_arraylist_t(&right, i);
        res += labs(rn - ln);
        res2 += labs(ln * dict[ln]);
    }
    printf("total distance: %ld\n", res);
    printf("total similarity: %ld\n", res2);

    deinit_arraylist_t(&left);
    deinit_arraylist_t(&right);
    fclose(file);
    return 0;
}
