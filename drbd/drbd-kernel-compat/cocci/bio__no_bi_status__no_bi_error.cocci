@ find_endio @
struct bio *b;
identifier fn;
@@
b->bi_end_io = fn;

@@ identifier find_endio.fn, b; @@
- fn(struct bio* b)
+ fn(struct bio* b, int error)
{
...
}

@@ identifier find_endio.fn, b, e; @@
fn(struct bio *b, int e)
{
...
// Note that this doesn't cover the case of assigning something to the status,
// or using the status outside of the callback function. This is, however, the
// only way it's used in DRBD and this is still a whole lot more flexible than
// the old way, so it's fine for now.
- b->bi_status
+ errno_to_blk_status(e)
...
}

@@
expression errno;
struct bio *b;
@@
// Special case for complete_master_bio: we can only propagate our own input to
// bio_endio(bio, error); in those kernels, it still double checks on
// bio_flagged(bio, BIO_UPTODATE), it will map 0 to -EIO in case this bio
// was already "failed" and marked NOT up-to-date by some "child" bio.
complete_master_bio(...)
{
	...
-	if(...)
- 		b->bi_status = errno_to_blk_status(errno);
-	bio_endio(b);
+	bio_endio(b, errno);
	...
}

@@
struct bio *b;
@@
// specific, more readable variants
- if (...)
-	b->bi_status = BLK_STS_IOERR;
...
- bio_endio(b);
+ bio_endio(b, -EIO);

@@
expression status;
expression err;
struct bio *b;
@@
(
// specific, more readable variants
- b->bi_status = BLK_STS_IOERR;
...
- bio_endio(b);
+ bio_endio(b, -EIO);
|
- b->bi_status = BLK_STS_RESOURCE;
...
- bio_endio(b);
+ bio_endio(b, -ENOMEM);
|
- b->bi_status = BLK_STS_NOTSUPP;
...
- bio_endio(b);
+ bio_endio(b, -EOPNOTSUPP);
|
// gerenric variant, in case something is missing
- b->bi_status = status;
...
- bio_endio(b);
+ bio_endio(b, blk_status_to_errno(status));
)

@@
struct bio *b;
@@
// any remmaining bio_endio are hopefully "success" completions?
- bio_endio(b);
+ bio_endio(b, 0 /* COMPLETE AS SUCCESS */);
