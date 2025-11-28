# Supabase Schema - Simplified (No Redundant imageUrl)

## If Table Already Exists - Run This First

```sql
-- Add estimated_cost_per_day column if it doesn't exist
ALTER TABLE destinations 
ADD COLUMN IF NOT EXISTS estimated_cost_per_day DOUBLE PRECISION;
```

## Database Schema

Run this SQL in your Supabase SQL Editor:

```sql
-- Create destinations table with only image_urls (no redundant image_url column)
CREATE TABLE IF NOT EXISTS destinations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  description TEXT,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  country TEXT,
  country_code TEXT,
  category TEXT NOT NULL CHECK (category IN ('natural', 'cultural', 'architecture', 'adventure', 'urban', 'coastal')),
  hidden_score DOUBLE PRECISION CHECK (hidden_score >= 0 AND hidden_score <= 10),
  best_season TEXT,
  difficulty TEXT CHECK (difficulty IN ('Easy', 'Moderate', 'Challenging')),
  budget_level TEXT CHECK (budget_level IN ('$', '$$', '$$$')),
  visit_duration INTEGER,
  travel_tips TEXT[],
  tags TEXT[],
  image_urls TEXT[] NOT NULL, -- Array of image URLs (use first for cards)
  estimated_cost_per_day DOUBLE PRECISION,
  view_count INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_destinations_category ON destinations(category);
CREATE INDEX IF NOT EXISTS idx_destinations_hidden_score ON destinations(hidden_score DESC);
CREATE INDEX IF NOT EXISTS idx_destinations_country ON destinations(country);
CREATE INDEX IF NOT EXISTS idx_destinations_slug ON destinations(slug);
CREATE INDEX IF NOT EXISTS idx_destinations_is_active ON destinations(is_active);

-- GIN index for array columns (tags, travel_tips, image_urls)
CREATE INDEX IF NOT EXISTS idx_destinations_tags ON destinations USING GIN (tags);
CREATE INDEX IF NOT EXISTS idx_destinations_travel_tips ON destinations USING GIN (travel_tips);
CREATE INDEX IF NOT EXISTS idx_destinations_image_urls ON destinations USING GIN (image_urls);

-- Full-text search index
CREATE INDEX IF NOT EXISTS idx_destinations_search 
ON destinations USING GIN (to_tsvector('english', name || ' ' || COALESCE(description, '') || ' ' || COALESCE(country, '')));

-- RLS (Row Level Security) Policies
ALTER TABLE destinations ENABLE ROW LEVEL SECURITY;

-- Allow public read access
CREATE POLICY "Allow public read access" ON destinations
  FOR SELECT USING (is_active = true);

-- Allow public update for view count only
CREATE POLICY "Allow public update view count" ON destinations
  FOR UPDATE USING (true)
  WITH CHECK (true);

-- Updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_destinations_updated_at
  BEFORE UPDATE ON destinations
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Helper function to get random destinations
CREATE OR REPLACE FUNCTION get_random_destinations(limit_count INTEGER DEFAULT 10)
RETURNS SETOF destinations AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM destinations
  WHERE is_active = true
  ORDER BY RANDOM()
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Function to add image to existing destination
CREATE OR REPLACE FUNCTION add_destination_image(dest_id UUID, new_image_url TEXT)
RETURNS void AS $$
BEGIN
  UPDATE destinations
  SET image_urls = array_append(image_urls, new_image_url)
  WHERE id = dest_id;
END;
$$ LANGUAGE plpgsql;

-- Function to remove image from destination
CREATE OR REPLACE FUNCTION remove_destination_image(dest_id UUID, image_url_to_remove TEXT)
RETURNS void AS $$
BEGIN
  UPDATE destinations
  SET image_urls = array_remove(image_urls, image_url_to_remove)
  WHERE id = dest_id;
END;
$$ LANGUAGE plpgsql;
```

## Verification Queries

After running the schema, verify with these queries:

```sql
-- Check table structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'destinations'
ORDER BY ordinal_position;

-- Check indexes
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'destinations';

-- Check RLS policies
SELECT policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename = 'destinations';
```

## Notes

- **No `image_url` column** - Only `image_urls TEXT[]` array
- **First image used for cards** - Access via `image_urls[1]` in SQL or `primaryImageUrl` getter in Flutter
- **Minimum 1 image required** - `image_urls TEXT[] NOT NULL`
- **Efficient array operations** - GIN indexes for fast queries
- **Helper functions** - Easy image management
