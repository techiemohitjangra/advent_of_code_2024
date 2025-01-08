#include <stdio.h>
#include <stdlib.h>

struct TreeNode {
    int value;
    struct TreeNode *added;
    struct TreeNode *multiplied;
};
typedef struct TreeNode tree_node_t;

tree_node_t *create_tree_node(int value) {
    tree_node_t *temp = (tree_node_t *)malloc(sizeof(tree_node_t));
    if (temp == NULL) {
        fprintf(stderr, "failed to allocate tree_node_t on heap");
        return NULL;
    }
    temp->value = value;
    temp->multiplied = NULL;
    temp->added = NULL;
    return temp;
}

void free_tree(tree_node_t *root) {
    if (root->added != NULL && root->multiplied != NULL) {
        free_tree(root->added);
        free_tree(root->multiplied);
    }
    free(root);
}

void test_tree_alloc_and_free() {
    tree_node_t *root = create_tree_node(1);
    root->added = create_tree_node(2);
    root->multiplied = create_tree_node(2);
    root->added->added = create_tree_node(3);
    root->added->multiplied = create_tree_node(3);
    root->multiplied->added = create_tree_node(3);
    root->multiplied->multiplied = create_tree_node(3);
    free_tree(root);
}

tree_node_t *prase_array_to_tree(int *arr, size_t size) {
    if (size == 0) {
        return NULL;
    }
    tree_node_t *root = create_tree_node(*arr);
    root->added = prase_array_to_tree(arr + 1, size - 1);
    root->multiplied = prase_array_to_tree(arr + 1, size - 1);
    return root;
}

void print_tree(tree_node_t *root, size_t tab_count) {
    if (root == NULL) {
        return;
    }
    for (size_t i = 0; i < tab_count; ++i) {
        printf("    ");
    }
    printf("%d\n", root->value);
    print_tree(root->added, tab_count + 1);
    print_tree(root->multiplied, tab_count + 1);
}

int get_closest_sum(tree_node_t *root, int target) {
    if (root->added == NULL && root->multiplied == NULL) {

        return 0;
    }
    int addition_result = root->value + get_closest_sum(root, target);
    int multiplication_result = root->value * get_closest_sum(root, target);
    if (target == addition_result || target == multiplication_result) {
        return target;
    }
    if (abs(target - addition_result) > abs(target - multiplication_result)) {
        return multiplication_result;
    } else {
        return addition_result;
    }
}

int main() {
    test_tree_alloc_and_free();
    int arr[] = {81, 40, 27};
    int target = 3267;
    tree_node_t *root = prase_array_to_tree(arr, 3);

    int result = get_closest_sum(root, target);
    printf("%d\n", result);
    if (0 == result) {
        printf("is valid");
    }

    print_tree(root, 0);
    free_tree(root);
    return 0;
}
