#include "ruby.h"

VALUE rb_mDjbHash2;

uint64_t
djb_hash_2(const char *string, long length)
{
    uint64_t hash = 5381;
    long index;
    for (index = 0; index < length; index++) {
        hash = (hash * 33) ^ (unsigned char)string[index];
    }
    return hash;
}

static VALUE
rb_djb_hash_2(VALUE self, VALUE str)
{
    Check_Type(str, T_STRING);
    return ULL2NUM(djb_hash_2(RSTRING_PTR(str), RSTRING_LEN(str)));
}

RUBY_FUNC_EXPORTED void
Init_djb_hash_2(void)
{
  rb_mDjbHash2 = rb_define_module("DjbHash2");
  rb_define_singleton_method(rb_mDjbHash2, "digest", rb_djb_hash_2, 1);
}
