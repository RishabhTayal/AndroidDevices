#!/bin/bash

set -e
psql -U postgres -d homekitty -p 5432 -a -f seed_categories.sql || (echo "🚨  Failed seed categories"; exit 1;)
psql -U postgres -d homekitty -p 5432 -a -f seed_manufacturers.sql || (echo "🚨  Failed seed manufacturers"; exit 1;)
psql -U postgres -d homekitty -p 5432 -a -f seed_lights.sql || (echo "🚨  Failed seed lights"; exit 1;)
psql -U postgres -d homekitty -p 5432 -a -f seed_outlets.sql || (echo "🚨  Failed seed outlets"; exit 1;)
echo "✅  Seed completed ✅"
