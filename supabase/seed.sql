-- ==============================================================================
-- STYLE HOUSE CAMBODIA — INITIAL SEED DATA
-- ==============================================================================

-- 1. SEED CATEGORIES
INSERT INTO public.categories (id, slug, name_en, name_km, image_url, gender, is_featured, display_order)
VALUES
    ('c1111111-1111-1111-1111-111111111111', 'women', 'Women', 'ម៉ូដនារី', 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?q=80&w=800', 'women', true, 1),
    ('c2222222-2222-2222-2222-222222222222', 'men', 'Men', 'ម៉ូដបុរស', 'https://images.unsplash.com/photo-1617137984095-74e4e5e3613f?q=80&w=800', 'men', true, 2),
    ('c3333333-3333-3333-3333-333333333333', 'tailoring', 'Atelier Tailoring', 'ឈុតកាត់ដេរពិសេស', 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?q=80&w=800', 'all', true, 3),
    ('c4444444-4444-4444-4444-444444444444', 'bags', 'Leather Bags', 'កាបូបស្បែកប្រណីត', 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?q=80&w=800', 'all', true, 4),
    ('c5555555-5555-5555-5555-555555555555', 'footwear', 'Footwear & Loafers', 'ស្បែកជើង និងឡូហ្វឺរ', 'https://images.unsplash.com/photo-1549298916-b41d501d3772?q=80&w=800', 'all', false, 5),
    ('c6666666-6666-6666-6666-666666666666', 'accessories', 'Silk & Accessories', 'គ្រឿងតុបតែង & សូត្រ', 'https://images.unsplash.com/photo-1606760227091-3dd870d97f1d?q=80&w=800', 'all', false, 6)
ON CONFLICT (id) DO NOTHING;

-- 2. SEED PRODUCTS
INSERT INTO public.products (id, sku, name_en, name_km, description_en, description_km, price_usd, original_price_usd, category_id, gender, material_en, material_km, is_new_arrival, is_best_seller, is_featured)
VALUES
    (
        'p1111111-1111-1111-1111-111111111111',
        'SH-W-DRS-001',
        'Atelier Silk Wrap Midi Dress',
        'រ៉ូបសូត្រប្រណីតម៉ូដ Midi',
        'Cut from pure mulberry silk with a lustrous sheen, this wrap midi dress embodies fluid movement and timeless sophistication.',
        'កាត់ដេរពីសរសៃសូត្រធម្មជាតិ 100% ផ្តល់នូវភាពរលោងស្រទន់ និងភាពថ្លៃថ្នូរ។ មានខ្សែក្រវាត់ចង្កេះយ៉ាងផ្ចិតផ្ចង់។',
        185.00,
        220.00,
        'c1111111-1111-1111-1111-111111111111',
        'women',
        '100% Pure Mulberry Silk (19 Momme)',
        'សូត្រធម្មជាតិសុទ្ធ 100%',
        true, true, true
    ),
    (
        'p2222222-2222-2222-2222-222222222222',
        'SH-M-SHT-002',
        'Relaxed Linen Camp Collar Overshirt',
        'អាវដៃខ្លីក្រណាត់កប្បាសលីនិនម៉ូដបុរស',
        'Crafted from Normandy organic linen, this relaxed camp-collar overshirt delivers breathable luxury suited for Cambodia’s tropical climate.',
        'ផលិតពីក្រណាត់លីនិនសរីរាង្គទន់ត្រជាក់ សមស្របបំផុតសម្រាប់អាកាសធាតុក្តៅក្នុងរាជធានីភ្នំពេញ។',
        115.00,
        null,
        'c2222222-2222-2222-2222-222222222222',
        'men',
        '100% European Certified Organic Linen',
        'ក្រណាត់លីនិនសុទ្ធ 100%',
        true, true, true
    ),
    (
        'p3333333-3333-3333-3333-333333333333',
        'SH-W-BLZ-003',
        'Sculpted Tailored Wool Blazer',
        'អាវធំ Blazer កាត់ដេរប្រណីត',
        'A modern masterclass in tailoring with structured shoulders and peaked lapels.',
        'ស្នាដៃកាត់ដេរកម្រិតខ្ពស់ជាមួយនឹងស្មាកាត់ស្អាត និងចង្កេះរាងស្អាត ឆ្លុះបញ្ចាំងពីភាពរឹងមាំ និងថ្លៃថ្នូរ។',
        260.00,
        310.00,
        'c3333333-3333-3333-3333-333333333333',
        'women',
        '96% Virgin Wool, 4% Elastane',
        'រោមចៀម Virgin Wool 96%',
        false, true, true
    ),
    (
        'p4444444-4444-4444-4444-444444444444',
        'SH-U-BAG-004',
        'Monogram Flap Leather Crossbody Bag',
        'កាបូបស្បែកពិតស្ពាយចំហៀងម៉ូដ Monogram',
        'Crafted from Italian full-grain vegetable-tanned calfskin with signature gold-finished clasp.',
        'ផលិតពីស្បែកកូនគោអ៊ីតាលីគុណភាពលេខ១ បំពាក់ដោយគន្លឹះចាក់សោលោហធាតុពណ៌មាសរលោង។',
        295.00,
        350.00,
        'c4444444-4444-4444-4444-444444444444',
        'women',
        '100% Italian Full-Grain Calf Leather',
        'ស្បែកកូនគោអ៊ីតាលីសុទ្ធ 100%',
        false, true, true
    )
ON CONFLICT (id) DO NOTHING;

-- 3. SEED COUPONS
INSERT INTO public.coupons (id, code, discount_percentage, min_spend_usd, max_discount_usd, is_active)
VALUES
    ('d1111111-1111-1111-1111-111111111111', 'STYLE10', 10.00, 50.00, 50.00, true),
    ('d2222222-2222-2222-2222-222222222222', 'CAMBODIA', 10.00, 30.00, 30.00, true),
    ('d3333333-3333-3333-3333-333333333333', 'VIP20', 20.00, 100.00, 100.00, true)
ON CONFLICT (code) DO NOTHING;
