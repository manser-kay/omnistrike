#!/bin/bash
TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com" && exit 1

echo "[API-FUZZ] Ищу скрытые API..."

# База API эндпоинтов
ENDPOINTS=(
    "/api/v1/users" "/api/v2/auth" "/api/auth/login" "/api/users/me"
    "/graphql" "/v1/graphql" "/api/graphql"
    "/.well-known/openapi.json" "/swagger.json" "/openapi.json"
    "/api-docs" "/swagger-ui.html" "/redoc"
    "/api/health" "/api/status" "/api/ping"
    "/rest/api/latest" "/services/rest"
    "/actuator/health" "/actuator/mappings" "/actuator/env"
    "/_ah/api" "/wp-json/wp/v2/users"
    "/api/v1/products" "/api/v1/orders" "/api/v1/customers"
)

for ep in "${ENDPOINTS[@]}"; do
    CODE=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 5 "$TARGET$ep" 2>/dev/null)
    [ "$CODE" != "404" ] && [ "$CODE" != "000" ] && echo "  🔗 $ep [HTTP $CODE]"
done

# GraphQL интроспекция
for ep in /graphql /v1/graphql /api/graphql; do
    RESP=$(curl -sk --max-time 5 -X POST -H "Content-Type: application/json" \
        -d '{"query":"{__schema{types{name}}}"}' "$TARGET$ep" 2>/dev/null)
    echo "$RESP" | grep -q "__schema" && echo "  🎯 GraphQL INTROSPECTION: $ep"
done

echo "[API-FUZZ] Готово"
