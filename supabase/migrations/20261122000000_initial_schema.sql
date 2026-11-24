-- ==============================================================================
-- STYLE HOUSE CAMBODIA — E-COMMERCE DATABASE SCHEMA
-- PostgreSQL + Supabase with Row Level Security (RLS)
-- ==============================================================================

-- 1. EXTENSIONS & ENUMS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('customer', 'admin', 'manager');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE gender_type AS ENUM ('women', 'men', 'unisex', 'all');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'processing', 'delivering', 'delivered', 'cancelled');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE payment_method_type AS ENUM ('khqr', 'cod', 'card');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE payment_status AS ENUM ('pending', 'completed', 'failed', 'refunded');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. PROFILES TABLE (linked to auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    phone_number TEXT,
    avatar_url TEXT,
    role user_role DEFAULT 'customer' NOT NULL,
    preferred_language VARCHAR(5) DEFAULT 'en' NOT NULL,
    preferred_currency VARCHAR(5) DEFAULT 'USD' NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 3. CATEGORIES TABLE
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug TEXT UNIQUE NOT NULL,
    name_en TEXT NOT NULL,
    name_km TEXT NOT NULL,
    description_en TEXT,
    description_km TEXT,
    image_url TEXT NOT NULL,
    gender gender_type DEFAULT 'all' NOT NULL,
    is_featured BOOLEAN DEFAULT false NOT NULL,
    display_order INT DEFAULT 0 NOT NULL,
    parent_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 4. PRODUCTS TABLE
CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sku TEXT UNIQUE NOT NULL,
    name_en TEXT NOT NULL,
    name_km TEXT NOT NULL,
    description_en TEXT NOT NULL,
    description_km TEXT NOT NULL,
    price_usd NUMERIC(10, 2) NOT NULL CHECK (price_usd >= 0),
    original_price_usd NUMERIC(10, 2) CHECK (original_price_usd IS NULL OR original_price_usd >= price_usd),
    category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE RESTRICT,
    gender gender_type NOT NULL,
    material_en TEXT NOT NULL,
    material_km TEXT NOT NULL,
    details_en TEXT[] DEFAULT '{}' NOT NULL,
    details_km TEXT[] DEFAULT '{}' NOT NULL,
    is_new_arrival BOOLEAN DEFAULT false NOT NULL,
    is_best_seller BOOLEAN DEFAULT false NOT NULL,
    is_featured BOOLEAN DEFAULT false NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 5. PRODUCT VARIANTS TABLE (Color & Size Matrix)
CREATE TABLE IF NOT EXISTS public.product_variants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    color_name_en TEXT NOT NULL,
    color_name_km TEXT NOT NULL,
    color_hex VARCHAR(10) NOT NULL,
    size TEXT NOT NULL,
    sku_variant TEXT UNIQUE NOT NULL,
    price_override_usd NUMERIC(10, 2) CHECK (price_override_usd IS NULL OR price_override_usd >= 0),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE (product_id, color_name_en, size)
);

-- 6. INVENTORY TABLE (Physical stock in Cambodia)
CREATE TABLE IF NOT EXISTS public.inventory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    variant_id UUID UNIQUE NOT NULL REFERENCES public.product_variants(id) ON DELETE CASCADE,
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    reserved_quantity INT NOT NULL DEFAULT 0 CHECK (reserved_quantity >= 0),
    location TEXT DEFAULT 'BKK1 Flagship Atelier, Phnom Penh' NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 7. PRODUCT IMAGES TABLE
CREATE TABLE IF NOT EXISTS public.product_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    display_order INT DEFAULT 0 NOT NULL,
    is_primary BOOLEAN DEFAULT false NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 8. ADDRESSES TABLE (Cambodian Provinces & Districts)
CREATE TABLE IF NOT EXISTS public.addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    recipient_name TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    province TEXT NOT NULL,
    district TEXT NOT NULL,
    street_address TEXT NOT NULL,
    delivery_notes TEXT,
    is_default BOOLEAN DEFAULT false NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 9. CARTS & CART ITEMS
CREATE TABLE IF NOT EXISTS public.carts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.cart_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cart_id UUID NOT NULL REFERENCES public.carts(id) ON DELETE CASCADE,
    variant_id UUID NOT NULL REFERENCES public.product_variants(id) ON DELETE CASCADE,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(cart_id, variant_id)
);

-- 10. COUPONS TABLE
CREATE TABLE IF NOT EXISTS public.coupons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE NOT NULL,
    discount_percentage NUMERIC(5, 2) NOT NULL CHECK (discount_percentage > 0 AND discount_percentage <= 100),
    min_spend_usd NUMERIC(10, 2) DEFAULT 0 NOT NULL,
    max_discount_usd NUMERIC(10, 2),
    expires_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 11. ORDERS & ORDER ITEMS
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number TEXT UNIQUE NOT NULL,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    status order_status DEFAULT 'pending' NOT NULL,
    subtotal_usd NUMERIC(10, 2) NOT NULL CHECK (subtotal_usd >= 0),
    delivery_fee_usd NUMERIC(10, 2) DEFAULT 0 NOT NULL CHECK (delivery_fee_usd >= 0),
    discount_usd NUMERIC(10, 2) DEFAULT 0 NOT NULL CHECK (discount_usd >= 0),
    total_usd NUMERIC(10, 2) NOT NULL CHECK (total_usd >= 0),
    shipping_address_snapshot JSONB NOT NULL,
    delivery_notes TEXT,
    tracking_code TEXT,
    coupon_id UUID REFERENCES public.coupons(id),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    variant_id UUID NOT NULL REFERENCES public.product_variants(id) ON DELETE RESTRICT,
    product_name_snapshot TEXT NOT NULL,
    variant_snapshot TEXT NOT NULL,
    unit_price_usd NUMERIC(10, 2) NOT NULL CHECK (unit_price_usd >= 0),
    quantity INT NOT NULL CHECK (quantity > 0),
    total_price_usd NUMERIC(10, 2) NOT NULL CHECK (total_price_usd >= 0)
);

-- 12. PAYMENTS TABLE (KHQR, COD, Cards)
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID UNIQUE NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    payment_method payment_method_type NOT NULL,
    payment_status payment_status DEFAULT 'pending' NOT NULL,
    amount_usd NUMERIC(10, 2) NOT NULL CHECK (amount_usd >= 0),
    amount_khr NUMERIC(15, 0) NOT NULL CHECK (amount_khr >= 0),
    transaction_ref TEXT,
    khqr_payload TEXT,
    verified_at TIMESTAMPTZ,
    verified_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 13. REVIEWS TABLE
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    rating NUMERIC(2, 1) NOT NULL CHECK (rating >= 1.0 AND rating <= 5.0),
    comment_en TEXT,
    comment_km TEXT,
    is_verified_purchase BOOLEAN DEFAULT false NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE (product_id, user_id)
);

-- 14. NOTIFICATIONS TABLE
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title_en TEXT NOT NULL,
    title_km TEXT NOT NULL,
    body_en TEXT NOT NULL,
    body_km TEXT NOT NULL,
    type TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false NOT NULL,
    data JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- ==============================================================================
-- INDEXES FOR PERFORMANCE
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_products_category ON public.products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_gender ON public.products(gender);
CREATE INDEX IF NOT EXISTS idx_products_created ON public.products(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_variants_product ON public.product_variants(product_id);
CREATE INDEX IF NOT EXISTS idx_orders_user ON public.orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON public.orders(status);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON public.order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_cart ON public.cart_items(cart_id);
CREATE INDEX IF NOT EXISTS idx_addresses_user ON public.addresses(user_id);

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.carts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Helper function: Is admin?
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role IN ('admin', 'manager')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Profiles Policies
CREATE POLICY "Public profiles are viewable by everyone"
    ON public.profiles FOR SELECT USING (true);

CREATE POLICY "Users can insert their own profile"
    ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
    ON public.profiles FOR UPDATE USING (auth.uid() = id OR public.is_admin());

-- Catalog (Products, Categories, Variants, Images, Inventory) Policies
CREATE POLICY "Categories viewable by everyone"
    ON public.categories FOR SELECT USING (true);

CREATE POLICY "Admins can manage categories"
    ON public.categories FOR ALL USING (public.is_admin());

CREATE POLICY "Active products viewable by everyone"
    ON public.products FOR SELECT USING (is_active = true OR public.is_admin());

CREATE POLICY "Admins can manage products"
    ON public.products FOR ALL USING (public.is_admin());

CREATE POLICY "Product variants viewable by everyone"
    ON public.product_variants FOR SELECT USING (true);

CREATE POLICY "Admins can manage product variants"
    ON public.product_variants FOR ALL USING (public.is_admin());

CREATE POLICY "Product images viewable by everyone"
    ON public.product_images FOR SELECT USING (true);

CREATE POLICY "Admins can manage product images"
    ON public.product_images FOR ALL USING (public.is_admin());

CREATE POLICY "Inventory viewable by authenticated users"
    ON public.inventory FOR SELECT USING (true);

CREATE POLICY "Admins can manage inventory"
    ON public.inventory FOR ALL USING (public.is_admin());

-- Address Policies
CREATE POLICY "Users manage their own addresses"
    ON public.addresses FOR ALL USING (auth.uid() = user_id OR public.is_admin());

-- Cart Policies
CREATE POLICY "Users view and manage their own cart"
    ON public.carts FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users view and manage their cart items"
    ON public.cart_items FOR ALL USING (
        EXISTS (SELECT 1 FROM public.carts WHERE id = cart_items.cart_id AND user_id = auth.uid())
    );

-- Coupons Policies
CREATE POLICY "Active coupons viewable by anyone"
    ON public.coupons FOR SELECT USING (is_active = true OR public.is_admin());

CREATE POLICY "Admins manage coupons"
    ON public.coupons FOR ALL USING (public.is_admin());

-- Orders & Order Items Policies
CREATE POLICY "Users can view their own orders"
    ON public.orders FOR SELECT USING (auth.uid() = user_id OR public.is_admin());

CREATE POLICY "Users can create their own orders"
    ON public.orders FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can update orders"
    ON public.orders FOR UPDATE USING (public.is_admin());

CREATE POLICY "Users can view their order items"
    ON public.order_items FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.orders WHERE id = order_items.order_id AND (user_id = auth.uid() OR public.is_admin()))
    );

CREATE POLICY "Users can insert order items for their own orders"
    ON public.order_items FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM public.orders WHERE id = order_items.order_id AND user_id = auth.uid())
    );

-- Payments Policies
CREATE POLICY "Users can view payments for their orders"
    ON public.payments FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.orders WHERE id = payments.order_id AND (user_id = auth.uid() OR public.is_admin()))
    );

CREATE POLICY "Users can insert initial payment for their orders"
    ON public.payments FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM public.orders WHERE id = payments.order_id AND user_id = auth.uid())
    );

CREATE POLICY "Admins can update and verify payments"
    ON public.payments FOR UPDATE USING (public.is_admin());

-- Reviews Policies
CREATE POLICY "Reviews viewable by everyone"
    ON public.reviews FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create reviews"
    ON public.reviews FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own reviews"
    ON public.reviews FOR UPDATE USING (auth.uid() = user_id OR public.is_admin());

-- Notifications Policies
CREATE POLICY "Users can view and update their own notifications"
    ON public.notifications FOR ALL USING (auth.uid() = user_id OR public.is_admin());

-- ==============================================================================
-- AUTOMATIC PROFILE TRIGGER ON SIGNUP
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, phone_number, avatar_url, role)
    VALUES (
        new.id,
        COALESCE(new.raw_user_meta_data->>'full_name', 'VIP Member'),
        new.raw_user_meta_data->>'phone_number',
        new.raw_user_meta_data->>'avatar_url',
        'customer'
    );
    -- Initialize user cart
    INSERT INTO public.carts (user_id)
    VALUES (new.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
