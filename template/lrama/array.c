#define YY_ARRAY_DEFAULT_SIZE 16

typedef struct yy_array_struct {
    /* Number of node of the array. */
    long len;
    /* Capacity of the array */
    long capa;
    /* Pointer to the C array */
    void *ary[];
} yy_array_t;

static void *
yy_array_ary_alloc(size_t capa)
{
    void *ptr;

    if (capa == 0) {
        return NULL;
    }

    ptr = YYMALLOC(sizeof(void *) * capa);
    if (!ptr) {

    }

    return ptr;
}

static void
yy_array_ary_realloc(yy_array_t *ary, size_t capa)
{
    void *ptr = realloc(ary->ary, sizeof(void *) * capa);
    if (!ptr) {

    }
}

static void
yy_array_ary_free(yy_array_t *ary)
{
    YYFREE(ary->ary);
}

static void
yy_array_resize_capa(yy_array_t *ary, long capacity)
{
    YY_ASSERT(ary->len <= capacity);

    if (ary->len == 0) {
        ary->ary = yy_array_ary_alloc(capacity);
    }
    else {
        yy_array_ary_realloc(ary, capacity);
    }
    ary->capa = capacity;
}

static void
yy_array_double_capa(yy_array_t *ary, long min)
{
    long new_capa = min;

    if (new_capa < YY_ARRAY_DEFAULT_SIZE) {
        new_capa = YY_ARRAY_DEFAULT_SIZE;
    }
    new_capa += min;
    yy_array_resize_capa(ary, new_capa);
}

static yy_array_t *
yy_array_ensure_room_for_push(yy_array_t *ary, long add_len)
{
    long old_len = ary->len;
    long new_len = old_len + add_len;

    if (new_len > ary->capa) {
        yy_array_double_capa(ary, new_len);
    }

    return ary;
}

static yy_array_t *
yy_array_new_capa(long capa)
{
    yy_array_t *ary;

    YY_ASSERT(capa >= 0);

    ary = YYMALLOC(sizeof(yy_array_t));
    ary->capa = capa;
    ary->len = 0;
    ary->ary = yy_array_ary_alloc(capa);

    return ary;
}

static yy_array_t *
yy_array_push(yy_array_t *ary, NODE *node)
{
    yy_array_ensure_room_for_push(ary, 1);
    ary->ary[ary->len++] = node;

    return ary;
}

static yy_array_t *
yy_array_new(void)
{
    return yy_array_new_capa(0);
}

void
yy_array_free(yy_array_t *ary)
{
    yy_array_ary_free(ary);
    YYFREE(ary);
}
