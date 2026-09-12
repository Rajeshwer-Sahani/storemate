alter table public.products
add column if not exists barcode text;

create unique index if not exists products_store_barcode_unique
on public.products (store_id, barcode)
where barcode is not null and is_active = true;
