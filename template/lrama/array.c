#define LR_ARRAY_DEFAULT_SIZE 16

#ifndef LR_ASSERT
# define LR_ASSERT(expr) ((void) expr)
#endif

typedef struct lr_array_struct {
    /* Number of node of the array. */
    long len;
    /* Capacity of the array */
    long capa;
    /* Pointer to the C array */
    void *ary[];
} lr_array_t;

static void
lr_array_heap_alloc(lr_array_t *ary, size_t capa)
{

}

static void
lr_array_heap_realloc(lr_array_t *ary, size_t capa)
{
    
}

static void
lr_array_heap_free(lr_array_t *ary)
{
    
}

static void
lr_array_resize_capa(lr_array_t *ary, long capacity)
{
    LR_ASSERT(ary->len <= capacity);

    if (ary->len == 0) {
        lr_array_heap_alloc(ary, capacity);
    }
    else {
        lr_array_heap_realloc(ary, capacity);
    }
    ary->capa = capacity;
}

static void
lr_array_double_capa(lr_array_t *ary, long min)
{
    long new_capa = min;

    if (new_capa < LR_ARRAY_DEFAULT_SIZE) {
        new_capa = LR_ARRAY_DEFAULT_SIZE;
    }
    new_capa += min;
    lr_array_resize_capa(ary, new_capa);
}

static lr_array_t *
lr_array_ensure_room_for_push(lr_array_t *ary, long add_len)
{
    long old_len = ary->len;
    long new_len = old_len + add_len;

    if (new_len > ary->capa) {
        lr_array_double_capa(ary, new_len);
    }

    return ary;
}

static lr_array_t *
lr_array_new_capa(long capa)
{
    lr_array_t *ary;

    LR_ASSERT(capa >= 0);

    ary = ruby_xmalloc(sizeof(lr_array_t));
    ary->capa = capa;
    // alloc
    ary->len = 0;

    return ary;
}

static lr_array_t *
lr_array_push(lr_array_t *ary, NODE *node)
{
    lr_array_ensure_room_for_push(ary, 1);
    ary->ary[ary->len++] = node;

    return ary;
}

static void *
lr_array_pop(lr_array_t *ary)
{
    long len = ary->len;

    if (len == 0) return 0;
    ary->len--;

    return ary->ary[len];
}

static lr_array_t *
lr_array_new(void)
{
    return lr_array_new_capa(0);
}

void
lr_array_free(lr_array_t *ary)
{
    // lr_array_heap_free
}
